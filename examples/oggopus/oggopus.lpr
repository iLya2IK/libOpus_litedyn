{
   OggOpus example - part of libOpus_dyn

   Copyright 2023 Ilya Medvedkov

   In this example, pcm audio data is recorded by OpenAL, encoded and saved
   to a file in opus-ogg format in streaming mode.
   Then the saved file is opened, audio data is read and decoded, then played
   by OpenAL with buffering.

   Additionally required the OpenAL_soft library:
      https://github.com/iLya2IK/libOpenALsoft_dyn
}

program oggopus;

uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLOpusWrapper, OGLOpenALWrapper, OGLOGGWrapper,
  OGLSoundUtils, OGLSoundUtilTypes;

type

  { TOALStreamDataRecorder, TOALStreamDataSource child classes
    to implement Opus-Ogg data encoding/decoding in streaming mode }

  { TOALOpusDataRecorder }

  TOALOpusDataRecorder = class(TOALStreamDataRecorder)
  private
    FStream : TOpusFile;
  public
    constructor Create(aFormat : TOALFormat; aFreq : Cardinal); override;
    destructor Destroy; override;
    function SaveToFile(const Fn : String) : Boolean; override;
    function SaveToStream({%H-}Str : TStream) : Boolean; override;

    procedure StopRecording; override;

    function WriteSamples(const Buffer : Pointer;
                          Count : Integer) : Integer; override;
  end;

  { TOALOpusDataSource }

  TOALOpusDataSource = class(TOALStreamDataSource)
  private
    FStream : TOpusFile;
  public
    constructor Create; override;
    destructor Destroy; override;

    function LoadFromFile(const Fn : String) : Boolean; override;
    function LoadFromStream({%H-}Str : TStream) : Boolean; override;

    function ReadChunk(const Buffer : Pointer;
                         {%H-}Pos : Int64;
                         Sz  : Integer;
                         {%H-}isloop : Boolean;
                         var fmt : TOALFormat;
                         var freq : Cardinal) : Integer; override;
  end;

constructor TOALOpusDataSource.Create;
begin
  inherited Create;
  FStream := TOpusFile.Create;
end;

destructor TOALOpusDataSource.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TOALOpusDataSource.LoadFromFile(const Fn : String) : Boolean;
begin
  Result := FStream.LoadFromFile(Fn, false);
end;

function TOALOpusDataSource.LoadFromStream(Str : TStream) : Boolean;
begin
  Result := false;
end;

function TOALOpusDataSource.ReadChunk(const Buffer : Pointer; Pos : Int64;
  Sz : Integer; isloop : Boolean; var fmt : TOALFormat; var freq : Cardinal
  ) : Integer;
begin
  fmt := TOpenAL.OALFormat(FStream.Channels, FStream.Bitdepth);
  freq := FStream.Frequency;
  Result := FStream.ReadData(Buffer, FStream.Decoder.FrameFromBytes(Sz),
                                     nil).AsBytes;
end;

constructor TOALOpusDataRecorder.Create(aFormat : TOALFormat; aFreq : Cardinal
  );
begin
  inherited Create(aFormat, aFreq);
  FStream := TOpusFile.Create;
end;

destructor TOALOpusDataRecorder.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TOALOpusDataRecorder.SaveToFile(const Fn : String) : Boolean;
var
  channels : Cardinal;
  comments : ISoundComment;
begin
  case Format of
  oalfMono8 :
    Exit(false);
  oalfMono16 :
    channels := 1;
  oalfStereo8 :
    Exit(false);
  oalfStereo16 :
    channels := 2;
  end;

  comments := TOpus.NewEncComment;
  comments.Vendor := 'OALOpusDataRecorder';
  comments.AddTag(COMMENT_ARTIST, 'Your voice');
  comments.AddTag(COMMENT_TITLE,  'Record');
  Result := FStream.SaveToFile(Fn,
                TOGLSound.EncProps([TOGLSound.PROP_MODE, oemVBR,
                                    TOGLSound.PROP_CHANNELS, channels,
                                    TOGLSound.PROP_FREQUENCY, Frequency,
                                    TOGLSound.PROP_QUALITY, 5,
                                    TOGLSound.PROP_BITRATE, 128000]), comments);
end;

function TOALOpusDataRecorder.SaveToStream(Str : TStream) : Boolean;
begin
  //do nothing
  Result := false;
end;

procedure TOALOpusDataRecorder.StopRecording;
begin
  FStream.StopStreaming;
end;

function TOALOpusDataRecorder.WriteSamples(const Buffer : Pointer; Count : Integer
  ) : Integer;
begin
  Result := FStream.WriteData(Buffer, FStream.Encoder.FrameFromSamples(Count),
                                      nil).AsSamples;
end;

const // name of file to capture data
      cCaptureFile = 'capture.opus';
      {$ifdef Windows}
      cOALDLL = '..\libs\soft_oal.dll';
      cOpusDLL : Array [0..2] of String = ('..\libs\opus.dll',
                                           '..\libs\opusenc.dll',
                                           '..\libs\opusfile.dll');
      {$endif}
      {$ifdef DEBUG}
      cHeapTrace = 'heaptrace.trc';
      {$endif}

var
  OALCapture : TOALCapture; // OpenAL audio recoder
  OALPlayer  : TOALPlayer;  // OpenAL audio player
  dt: Integer;
begin
  {$ifdef DEBUG}
  if FileExists(cHeapTrace) then
     DeleteFile(cHeapTrace);
  SetHeapTraceOutput(cHeapTrace);
  {$endif}
  // Open Opus, Ogg, OpenAL libraries and initialize interfaces
  {$ifdef Windows}
  if TOpenAL.OALLibsLoad([cOALDLL]) and TOpus.OpusLibsLoad(cOpusDLL) then
  {$else}
  if TOpenAL.OALLibsLoadDefault and TOpus.OpusLibsLoadDefault then
  {$endif}
  begin
    // create OpenAL audio recoder
    OALCapture := TOALCapture.Create;
    try
      try
        // config OpenAL audio recoder
        OALCapture.DataRecClass := TOALOpusDataRecorder;
        // initialize OpenAL audio recoder
        OALCapture.Init;
        // configure buffering for the audio recorder to save data to a file
        if OALCapture.SaveToFile(cCaptureFile) then
        begin
          // start to record data with OpanAL
          OALCapture.Start;

          // run recording loop
          dt := 0;
          while dt < 1000 do begin
            // capture new data chunk and encode/write with opusenc to
            // cCaptureFile in opus-ogg format
            OALCapture.Proceed;
            TThread.Sleep(10);
            inc(dt);
          end;

          //stop recording. close opus-ogg file cCaptureFile
          OALCapture.Stop;

          WriteLn('Capturing completed successfully!');

        end else
          WriteLn('Cant save to ogg-opus file');

      except
        on e : Exception do WriteLn(e.ToString);
      end;
    finally
      OALCapture.Free;
    end;

    // create OpenAL audio player
    OALPlayer := TOALPlayer.Create;
    try
      try
        // config OpenAL audio player
        OALPlayer.DataSourceClass := TOALOpusDataSource;
        // initialize OpenAL audio player
        OALPlayer.Init;
        // configure buffering for the audio player to read data from file
        if OALPlayer.LoadFromFile(cCaptureFile) then
        begin
          // start to play audio data with OpanAL
          OALPlayer.Play;

          // run playing loop. do while the data is available
          while OALPlayer.Status = oalsPlaying do begin
            // if there are empty buffers available - read/decode new data chunk
            // from cCaptureFile with opusfile and put them in the queue
            OALPlayer.Stream.Proceed;
            TThread.Sleep(10);
          end;

          WriteLn('Playing completed successfully!');

        end else
          WriteLn('Cant load ogg-opus file');

      except
        on e : Exception do WriteLn(e.ToString);
      end;
    finally
      OALPlayer.Free;
    end;

    // close interfaces
    TOpenAL.OALLibsUnLoad;
    TOpus.OpusLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
end.

