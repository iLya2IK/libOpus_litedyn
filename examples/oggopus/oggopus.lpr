program oggopus;

uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLOpusWrapper, OGLOpenALWrapper, OGLOGGWrapper;

type

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
  Result := FStream.ReadData(Buffer, Sz, nil);
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

  Result := FStream.SaveToFile(Fn, oemVBR, channels, Frequency, 128000, 16, 0.5, nil);
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
  Result := FStream.WriteSamples(Buffer, Count, nil);
end;

const cCaptureFile = 'capture.opus';
      {$ifdef Windows}
      cOALDLL = '..\libs\soft_oal.dll';
      cOpusDLL : Array [0..2] of String = ('..\libs\opus.dll',
                                           '..\libs\opusenc.dll',
                                           '..\libs\opusfile.dll');
      {$endif}

var
  OALCapture : TOALCapture;
  OALPlayer  : TOALPlayer;
  dt: Integer;
begin
  {$ifdef Windows}
  if TOpenAL.OALLibsLoad([cOALDLL]) and TOpus.OpusLibsLoad(cOpusDLL) then
  {$else}
  if TOpenAL.OALLibsLoadDefault and TOpus.OpusLibsLoadDefault then
  {$endif}
  begin
    OALCapture := TOALCapture.Create;
    try
      try
        OALCapture.DataRecClass := TOALOpusDataRecorder;
        OALCapture.Init;
        if OALCapture.SaveToFile(cCaptureFile) then
        begin
          OALCapture.Start;

          dt := 0;
          while dt < 1000 do begin
            OALCapture.Proceed;
            TThread.Sleep(10);
            inc(dt);
          end;

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


    OALPlayer := TOALPlayer.Create;
    try
      try
        OALPlayer.DataSourceClass := TOALOpusDataSource;
        OALPlayer.Init;
        if OALPlayer.LoadFromFile(cCaptureFile) then
        begin

          OALPlayer.Play;

          while OALPlayer.Status = oalsPlaying do begin
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

    TOpenAL.OALLibsUnLoad;
    TOpus.OpusLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
  ReadLn;
end.

