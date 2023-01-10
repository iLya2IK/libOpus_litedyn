{
 OGLOpusWrapper:
   Wrapper for Opus library

   Copyright (c) 2023 by Ilya Medvedkov

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit OGLOpusWrapper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, libOpus_dynlite, OGLOGGWrapper;

type

  {The picture type according to the ID3v2 APIC frame:
     Default = -1
     <ol start="0">
     <li>Other</li>
     <li>32x32 pixels 'file icon' (PNG only)</li>
     <li>Other file icon</li>
     <li>Cover (front)</li>
     <li>Cover (back)</li>
     <li>Leaflet page</li>
     <li>Media (e.g. label side of CD)</li>
     <li>Lead artist/lead performer/soloist</li>
     <li>Artist/performer</li>
     <li>Conductor</li>
     <li>Band/Orchestra</li>
     <li>Composer</li>
     <li>Lyricist/text writer</li>
     <li>Recording Location</li>
     <li>During recording</li>
     <li>During performance</li>
     <li>Movie/video screen capture</li>
     <li>A bright colored fish</li>
     <li>Illustration</li>
     <li>Band/artist logotype</li>
     <li>Publisher/Studio logotype</li>
     </ol> }
  TAPICType = (apicDefault, apicOther, apic32x32Icon, apicOtherIcon,
                  apicCoverFront, apicCoverBack, apicLeafletPage,
                  apicMediaCD, apicArtist, apicConductor, apicBand,
                  apicComposer, apicTextWriter, apicRecordingLoc,
                  apicDuringRec, apicDuringPerf, apicScreenCapture,
                  apicBCF, apicIllustration, apicBandLogo, apicPublisherLogo);

  TOpusPicFormat = (opfUnknown, opfURL, opfJPEG, opfPNG, opfGIF);

  { IOpusEncComment }

  IOpusEncComment = interface(IOGGComment)
  ['{8A2DEE25-1796-47B4-A1FC-1FBEF617C6B0}']
  procedure AddPicture(const filename: String; aPic : TAPICType; const descr : String);
  procedure AddPictureFromMem(const mem : Pointer; sz : Integer; aPic : TAPICType; const descr : String);
  end;

  { IOpusDecPicture }

  IOpusDecPicture = interface(IUnknown)
  ['{7EC4D0A6-47FB-4E6D-89E4-7F16CB05226C}']
  function Ref : pOpusPictureTag;

  procedure Init;
  procedure Done;
  procedure Parse(src : IOGGComment; const tag : String);

  function APICType : TAPICType;
  function MIMEType : String;
  function Description : String;
  function Width : Cardinal;
  function Height : Cardinal;
  function Depth : Cardinal;
  function Colors : Cardinal;
  function Format : TOpusPicFormat;
  function DataLength : Cardinal;
  function Data : Pointer;
  end;

  { IOpusDecHead }

  IOpusDecHead = interface(IUnknown)
  ['{24ABD2F6-E021-4108-83B1-F718D019AAAD}']
  function Ref : pOpusHead;

  procedure Init;
  procedure Done;

  function Version : Integer;
  function Channels : Integer;
  function Frequency : Cardinal;
  function Gain : Integer;
  function MappingFamily : Integer;
  function StreamCount  : Integer;
  function CoupledCount : Integer;
  end;

  { TRefOpusDecHead }

  TRefOpusDecHead = class(TInterfacedObject, IOpusDecHead)
  private
    FRef : pOpusHead;
    procedure Init;
    procedure Done;
  public
    function Ref : pOpusHead; inline;

    constructor Create(aRef : pOpusHead);

    function Version : Integer; inline;
    function Channels : Integer; inline;
    function Frequency : Cardinal; inline;
    function Gain : Integer; inline;
    function MappingFamily : Integer; inline;
    function StreamCount  : Integer; inline;
    function CoupledCount : Integer; inline;
  end;

  { TUniqOpusDecHead }

  TUniqOpusDecHead = class(TRefOpusDecHead)
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TRefOpusDecComment }

  TRefOpusDecComment = class(TInterfacedObject, IOGGComment)
  private
    FRef : pOpusTags;
    procedure Init;
    procedure Done;
  public
    function Ref : Pointer; inline;

    constructor Create(aRef : pOpusTags);

    procedure Add(const comment: String);
    procedure AddTag(const tag, value: String);
    function Query(const tag: String; index: integer): String;
    function QueryCount(const tag: String): integer;
  end;

  { TUniqOpusDecComment }

  TUniqOpusDecComment = class(TRefOpusDecComment)
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TRefOpusEncComment }

  TRefOpusEncComment = class(TInterfacedObject, IOpusEncComment)
  private
    FRef : pOggOpusComments;
    procedure Init;
    procedure Done;
  public
    function Ref : Pointer; inline;

    constructor Create(aRef : pOggOpusComments);

    procedure Add(const comment: String);
    procedure AddTag(const tag, value: String);
    function Query(const tag: String; index: integer): String;
    function QueryCount(const tag: String): integer;
    procedure AddPicture(const filename: String; aPic : TAPICType; const descr : String);
    procedure AddPictureFromMem(const mem : Pointer; sz : Integer; aPic : TAPICType; const descr : String);
  end;

  { TUniqOpusEncComment }

  TUniqOpusEncComment = class(TRefOpusEncComment)
  public
    constructor Create;
    constructor Create(src : IOpusEncComment);
    destructor Destroy; override;
  end;

  { TOpusOggEncoder }

  TOpusOggEncoder = class(TOGGSoundEncoder)
  private
    fRef : pOggOpusEnc;
    fComm : IOGGComment;
    fChannels : Cardinal;
    fFreq : Cardinal;
    fenc_callbacks : OpusEncCallbacks;
  protected
    procedure Init(aMode : TOGGSoundEncoderMode;
                   aChannels : Cardinal;
                   aFreq, aBitrate, aBitdepth : Cardinal;
                   aQuality : Single;
                   aComments : IOGGComment); override;
    procedure Done; override;

    function GetBitdepth : Cardinal; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetMode : TOGGSoundEncoderMode; override;
    function GetQuality : Single; override;
    function GetVersion : Integer; override;

    procedure SetBitrate(AValue : Cardinal); override;
    procedure SetMode(AValue : TOGGSoundEncoderMode); override;
    procedure SetQuality(AValue : Single); override;
  public
    function Ref : pOggOpusEnc; inline;

    constructor Create(aMode : TOGGSoundEncoderMode;
                       aChannels : Cardinal;
                       aFreq, aBitrate : Cardinal;
                       aComplexity : Integer;
                       aComments : IOGGComment);
    destructor Destroy; override;

    function  Comments : IOGGComment; override;

    function DataMode : TOGGSoundDataMode; override;

    function  WriteData(Buffer : Pointer; Count : Integer; {%H-}Par : Pointer) : Integer; override;
    procedure WriteHeader({%H-}Par : Pointer); override;
    procedure Close({%H-}Par : Pointer); override;

    function Ready : Boolean; override;
  end;

  { TOpusOggStreamingEncoder }

  TOpusOggStreamingEncoder = class(TOpusOggEncoder)
  private
    fStream : TStream;
  protected
    function DoWrite(Buffer : Pointer; BufferSize : Integer) : Integer; override;
  public
    constructor Create(aStream : TStream;
                       aMode : TOGGSoundEncoderMode;
                       aChannels : Cardinal;
                       aFreq, aBitrate : Cardinal;
                       aComplexity : Integer;
                       aComments : IOGGComment);
  end;

  { TOpusOggDecoder }

  TOpusOggDecoder = class(TOGGSoundDecoder)
  private
    fRef  : pOggOpusFile;
    fHead : IOpusDecHead;
    fComm : IOGGComment;
    fdec_callbacks : OpusFileCallbacks;
  protected
    procedure Init; override;
    procedure Done; override;

    function GetBitdepth : Cardinal; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetVersion : Integer; override;
  public
    function Ref : pOggOpusFile; inline;

    constructor Create;
    destructor Destroy; override;

    function  Comments : IOGGComment; override;

    function DataMode : TOGGSoundDataMode; override;

    function ReadData(Buffer : Pointer; Count : Integer; {%H-}Par : Pointer) : Integer; override;
    procedure ResetToStart; override;

    function Ready : Boolean; override;
  end;

  { TOpusOggStreamingDecoder }

  TOpusOggStreamingDecoder = class(TOpusOggDecoder)
  private
    fStream : TStream;
  protected
    function DoRead(_ptr : Pointer; _nbytes : Integer) : Integer; override;
    function DoSeek(_offset:Int64; _whence:Integer): Integer; override;
    function DoTell:Int64; override;
  public
    constructor Create(aStream : TStream);
  end;

  { TOpusFile }

  TOpusFile = class(TOGGSoundFile)
  protected
    function InitEncoder(aMode : TOGGSoundEncoderMode;
                   aChannels : Cardinal;
                   aFreq, aBitrate, aBitdepth : Cardinal;
                   aQuality : Single;
                   aComments : IOGGComment) : TOGGSoundEncoder; override;
    function InitDecoder : TOGGSoundDecoder; override;
  end;

  TOpus = class
  public
    class function NewEncComment : IOpusEncComment; overload;
    class function NewEncComment(src : IOpusEncComment) : IOpusEncComment; overload;
    class function RefEncComment(src : pOggOpusComments) : IOpusEncComment;
    class function NewDecComment : IOGGComment;
    class function RefDecComment(src : pOpusTags) : IOGGComment;
    class function RefDecHead(src : pOpusHead) : IOpusDecHead;
    //class function NewDecPicture : IOpusDecPicture;
    class function NewStreamingEncoder(aStream : TStream;
                       aMode : TOGGSoundEncoderMode;
                       aChannels : Cardinal;
                       aFreq, aBitrate : Cardinal;
                       aComplexity : Integer;
                       aComments : IOGGComment) : TOpusOggEncoder;
    class function NewStreamingDecoder(aStream : TStream) : TOpusOggDecoder;

    class function OpusLibsLoad(const aOpusLibs : array of String) : Boolean;
    class function OpusLibsLoadDefault : Boolean;
    class function IsOpusLibsLoaded : Boolean;
    class function OpusLibsUnLoad : Boolean;
  end;

  EOpus = class(Exception);

implementation

uses ctypes;

const cOpusError = 'Opus error %d';

function ope_write(user_data : pointer; const ptr : pcuchar; len : opus_int32) : integer; cdecl;
begin
  Result := TOpusOggEncoder(user_data).DoWrite(ptr, len);
end;

function ope_close({%H-}user_data : pointer): integer; cdecl;
begin
  Result := 0;
end;

function opd_read_func(_stream : pointer; _ptr : pcuchar; _nbytes : Integer) : Integer; cdecl;
begin
  Result := TOpusOggDecoder(_stream).DoRead(_ptr, _nbytes);
end;

function opd_seek_func(_stream : pointer;_offset:opus_int64;_whence:Integer): Integer; cdecl;
begin
  Result := TOpusOggDecoder(_stream).DoSeek(_offset, _whence);
end;

function opd_tell_func(_stream : pointer):opus_int64;  cdecl;
begin
  Result := TOpusOggDecoder(_stream).DoTell;
end;

function opd_close_func({%H-}_stream : pointer):integer; cdecl;
begin
  result := 0;
end;

{ TUniqOpusDecHead }

constructor TUniqOpusDecHead.Create;
begin
  Init;
end;

destructor TUniqOpusDecHead.Destroy;
begin
  Done;
  inherited Destroy;
end;

{ TUniqOpusDecComment }

constructor TUniqOpusDecComment.Create;
begin
  Init;
end;

destructor TUniqOpusDecComment.Destroy;
begin
  Done;
  inherited Destroy;
end;

{ TRefOpusDecComment }

procedure TRefOpusDecComment.Init;
begin
  fRef := GetMem(Sizeof(OpusTags));
  opus_tags_init(fRef);
end;

procedure TRefOpusDecComment.Done;
begin
  if Assigned(fRef) then
  begin
    opus_tags_clear(fRef);
    FreeMemAndNil(fRef);
  end;
end;

function TRefOpusDecComment.Ref : Pointer;
begin
  Result := fRef;
end;

constructor TRefOpusDecComment.Create(aRef : pOpusTags);
begin
  fRef := aRef;
end;

procedure TRefOpusDecComment.Add(const comment : String);
begin
  opus_tags_add_comment(fRef, pcchar( PChar(comment) ));
end;

procedure TRefOpusDecComment.AddTag(const tag, value : String);
begin
  opus_tags_add(fRef, pcchar( PChar(tag) ), pcchar( PChar(value) ));
end;

function TRefOpusDecComment.Query(const tag : String; index : integer) : String;
begin
  Result := StrPas( PChar(opus_tags_query(fRef, pcchar( PChar(tag) ), index)) );
end;

function TRefOpusDecComment.QueryCount(const tag : String) : integer;
begin
  Result := opus_tags_query_count(fRef, pcchar( PChar(tag) ) );
end;

{ TRefOpusDecHead }

procedure TRefOpusDecHead.Init;
begin
  fRef := GetMem(sizeof(OpusHead));
end;

procedure TRefOpusDecHead.Done;
begin
  if Assigned(fRef) then
  begin
    FreeMemAndNil(fRef);
  end;
end;

function TRefOpusDecHead.Ref : pOpusHead;
begin
  Result := fRef;
end;

constructor TRefOpusDecHead.Create(aRef : pOpusHead);
begin
  fRef := aRef;
end;

function TRefOpusDecHead.Version : Integer;
begin
  Result := fRef^.version;
end;

function TRefOpusDecHead.Channels : Integer;
begin
  Result := fRef^.channel_count;
end;

function TRefOpusDecHead.Frequency : Cardinal;
begin
  Result := fRef^.input_sample_rate;
end;

function TRefOpusDecHead.Gain : Integer;
begin
  Result := fRef^.output_gain;
end;

function TRefOpusDecHead.MappingFamily : Integer;
begin
  Result := fRef^.mapping_family;
end;

function TRefOpusDecHead.StreamCount : Integer;
begin
  Result := fRef^.stream_count;
end;

function TRefOpusDecHead.CoupledCount : Integer;
begin
  Result := fRef^.coupled_count;
end;

{ TOpusFile }

function TOpusFile.InitEncoder(aMode : TOGGSoundEncoderMode;
  aChannels : Cardinal; aFreq, aBitrate, aBitdepth : Cardinal;
  aQuality : Single; aComments : IOGGComment) : TOGGSoundEncoder;
begin
  Result := TOpus.NewStreamingEncoder(Stream, aMode, aChannels,
                                      aFreq, aBitrate, Round(aQuality * 10),
                                      aComments);
end;

function TOpusFile.InitDecoder : TOGGSoundDecoder;
begin
  Result := TOpus.NewStreamingDecoder(Stream);
end;

{ TOpusOggDecoder }

procedure TOpusOggDecoder.Init;
var cError : Integer;
begin
  fdec_callbacks.read := @opd_read_func;
  fdec_callbacks.seek := @opd_seek_func;
  fdec_callbacks.close := @opd_close_func;
  fdec_callbacks.tell := @opd_tell_func;

  fRef := op_open_callbacks(Self, @fdec_callbacks, nil, 0, @cError);
  if cError <> 0 then
    raise EOpus.CreateFmt(cOpusError, [cError]);

  FHead := Topus.RefDecHead(op_head(fRef, -1));
  FComm := TOpus.RefDecComment(op_tags(fRef, -1));
end;

procedure TOpusOggDecoder.Done;
begin
  if assigned(fRef) then
    op_free(fRef);

  fComm := nil;
  fHead := nil;
end;

function TOpusOggDecoder.GetBitdepth : Cardinal;
begin
  Result := 16;
end;

function TOpusOggDecoder.GetChannels : Cardinal;
begin
  Result := op_channel_count(fRef, -1);
end;

function TOpusOggDecoder.GetFrequency : Cardinal;
begin
  Result := fHead.Frequency;
end;

function TOpusOggDecoder.GetVersion : Integer;
begin
  Result := fHead.Version;
end;

function TOpusOggDecoder.GetBitrate : Cardinal;
begin
  Result := op_bitrate(Self, -1);
end;

function TOpusOggDecoder.Ref : pOggOpusFile;
begin
  Result := Fref;
end;

constructor TOpusOggDecoder.Create;
begin
  fdec_callbacks.read := @opd_read_func;
  fdec_callbacks.tell := @opd_tell_func;
  fdec_callbacks.seek := @opd_seek_func;
  fdec_callbacks.close := @opd_close_func;
  Init;
end;

destructor TOpusOggDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusOggDecoder.Comments : IOGGComment;
begin
  Result := fComm;
end;

function TOpusOggDecoder.DataMode : TOGGSoundDataMode;
begin
  Result := odmSamples;
end;

function TOpusOggDecoder.ReadData(Buffer : Pointer; Count : Integer;
  Par : Pointer) : Integer;
begin
  Result := op_read(fRef, Buffer, Count, nil);
end;

procedure TOpusOggDecoder.ResetToStart;
begin
  op_pcm_seek(fRef, 0);
end;

function TOpusOggDecoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TOpusOggStreamingDecoder }

function TOpusOggStreamingDecoder.DoRead(_ptr : Pointer; _nbytes : Integer
  ) : Integer;
begin
  if (_nbytes <= 0) then begin Result := 0; Exit; end;
  try
    Result := Int64(fStream.Read(_ptr^, _nbytes));
  except
    Result := 0;
  end;
end;

function TOpusOggStreamingDecoder.DoSeek(_offset : Int64; _whence : Integer
  ) : Integer;
begin
  try
    with fStream do
      case _whence of
        0: Seek(_offset, soBeginning);
        1: Seek(_offset, soCurrent);
        2: Seek(_offset, soEnd);
      end;
    result := 0;
  except
    result := -1;
  end;
end;

function TOpusOggStreamingDecoder.DoTell : Int64;
begin
  try
    result := fStream.Position;
  except
    result := -1;
  end;
end;

constructor TOpusOggStreamingDecoder.Create(aStream : TStream);
begin
  fStream := aStream;
  Inherited Create;
end;

{ TOpusOggStreamingEncoder }

function TOpusOggStreamingEncoder.DoWrite(Buffer : Pointer; BufferSize : Integer
  ) : Integer;
begin
  if (BufferSize < 0) then Exit(1);
  if not (Assigned(Buffer) and (BufferSize > 0)) then Exit(1);
  fStream.Write(Buffer^, BufferSize);
  Result := 0;
end;

constructor TOpusOggStreamingEncoder.Create(aStream : TStream;
  aMode : TOGGSoundEncoderMode; aChannels : Cardinal; aFreq,
  aBitrate : Cardinal; aComplexity : Integer; aComments : IOGGComment);
begin
  fStream := aStream;
  inherited Create(aMode, aChannels, aFreq, aBitrate, aComplexity, aComments);
end;

{ TOpusOggEncoder }

procedure TOpusOggEncoder.Init(aMode : TOGGSoundEncoderMode;
  aChannels : Cardinal; aFreq, aBitrate, aBitdepth : Cardinal;
  aQuality : Single; aComments : IOGGComment);
var
  ope_error    : integer;
  ctl_serial   : opus_int32;
begin
  fChannels := achannels;
  fFreq := aFreq;

  fenc_callbacks.close := @ope_close;
  fenc_callbacks.write := @ope_write;

  if Assigned(aComments) then
    fComm := aComments else
    fComm := TOpus.NewEncComment;

  fRef := ope_encoder_create_callbacks(@fenc_callbacks,
                                       Self,
                                       fComm.Ref,
                                       aFreq,
                                       fChannels,
                                       0,
                                       @ope_error);
  if ope_error = 0 then
  begin
    ctl_serial := Abs(Random(Int64(Now)));
    ope_encoder_ctl_set_serialno(fRef, ctl_serial);

    SetBitrate(aBitrate);
    SetMode(aMode);
    SetQuality(aQuality);
  end else
    raise EOpus.CreateFmt(cOpusError, [ope_error]);
end;

procedure TOpusOggEncoder.Done;
begin
  if Assigned(fRef) then
    ope_encoder_destroy(fRef);
  fComm := nil;
end;

function TOpusOggEncoder.GetBitdepth : Cardinal;
begin
  Result := 16;
end;

function TOpusOggEncoder.GetChannels : Cardinal;
begin
  Result := fChannels;
end;

function TOpusOggEncoder.GetFrequency : Cardinal;
begin
  Result := fFreq;
end;

function TOpusOggEncoder.GetBitrate : Cardinal;
var
  v : opus_int32;
begin
  ope_encoder_ctl_get_bitrate(fRef, @v);
  Result := v div 1000;
end;

function TOpusOggEncoder.GetQuality : Single;
var
  v : opus_int32;
begin
  ope_encoder_ctl_get_complexity(fRef, @v);
  Result := Single(v) / 10.0;
end;

function TOpusOggEncoder.GetMode : TOGGSoundEncoderMode;
var
  v : opus_int32;
begin
  ope_encoder_ctl_get_vbr(fRef, @v);
  if v = 0 then Result := oemCBR else Result := oemVBR;
end;

function TOpusOggEncoder.GetVersion : Integer;
begin
  Result := 0;
end;

procedure TOpusOggEncoder.SetBitrate(AValue : Cardinal);
begin
  ope_encoder_ctl_set_bitrate(fRef, opus_int32(AValue * 1000));
end;

procedure TOpusOggEncoder.SetMode(AValue : TOGGSoundEncoderMode);
begin
  if (AValue = oemCBR) then
  begin
    ope_encoder_ctl_set_vbr(fRef, opus_int32(0));
  end else
  begin
    ope_encoder_ctl_set_vbr(fRef, opus_int32(1));
    ope_encoder_ctl_set_vbr_constraint(fRef, opus_int32(0));
  end;
end;

procedure TOpusOggEncoder.SetQuality(AValue : Single);
var
  ctl_complex : opus_int32;
begin
  ctl_complex := Round(AValue * 10.0);
  if ctl_complex > 10 then ctl_complex := 10;
  if ctl_complex < 0  then ctl_complex := 0;
  ope_encoder_ctl_set_complexity(fRef, ctl_complex);
end;

function TOpusOggEncoder.Ref : pOggOpusEnc;
begin
  Result := fRef;
end;

constructor TOpusOggEncoder.Create(aMode : TOGGSoundEncoderMode;
  aChannels : Cardinal; aFreq, aBitrate : Cardinal; aComplexity : Integer;
  aComments : IOGGComment);
begin
  Init(aMode, aChannels, aFreq, aBitrate, 16, Single(aComplexity) / 10.0,
              aComments);
end;

destructor TOpusOggEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusOggEncoder.Comments : IOGGComment;
begin
  Result := fComm;
end;

function TOpusOggEncoder.DataMode : TOGGSoundDataMode;
begin
  Result := odmSamples;
end;

function TOpusOggEncoder.WriteData(Buffer : Pointer; Count : Integer;
  Par : Pointer) : Integer;
begin
  Result := ope_encoder_write(fRef, Buffer, Count);
end;

procedure TOpusOggEncoder.WriteHeader(Par : Pointer);
begin
  ope_encoder_flush_header(fRef);
end;

procedure TOpusOggEncoder.Close(Par : Pointer);
begin
  ope_encoder_drain(fRef);
end;

function TOpusOggEncoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TUniqOpusEncComment }

constructor TUniqOpusEncComment.Create;
begin
  Init;
end;

constructor TUniqOpusEncComment.Create(src : IOpusEncComment);
begin
  fRef := ope_comments_copy(src.Ref);
end;

destructor TUniqOpusEncComment.Destroy;
begin
  Done;
  inherited Destroy;
end;

{ TRefOpusEncComment }

procedure TRefOpusEncComment.Init;
begin
  fRef := ope_comments_create;
end;

procedure TRefOpusEncComment.Done;
begin
  ope_comments_destroy(fRef);
  fRef := nil;
end;

function TRefOpusEncComment.Ref : pOggOpusComments;
begin
  Result := fRef;
end;

constructor TRefOpusEncComment.Create(aRef : pOggOpusComments);
begin
  fRef := aRef;
end;

procedure TRefOpusEncComment.Add(const comment : String);
begin
  ope_comments_add_string(fRef, pcchar(pchar( comment )));
end;

procedure TRefOpusEncComment.AddTag(const tag, value : String);
begin
  ope_comments_add(fRef, pcchar(pchar( tag )), pcchar(pchar( value )));
end;

function TRefOpusEncComment.Query(const tag : String; index : integer) : String;
begin
  Result := '';
end;

function TRefOpusEncComment.QueryCount(const tag : String) : integer;
begin
  Result := 0;
end;

procedure TRefOpusEncComment.AddPicture(const filename : String;
  aPic : TAPICType; const descr : String);
begin
  ope_comments_add_picture(fRef, pcchar(pchar( filename )), Integer(aPic) - 1,
                                 pcchar(pchar( descr )));
end;

procedure TRefOpusEncComment.AddPictureFromMem(const mem : Pointer;
  sz : Integer; aPic : TAPICType; const descr : String);
begin
  ope_comments_add_picture_from_memory(fRef, mem, sz, Integer(aPic) - 1,
                                 pcchar(pchar( descr )));
end;

{ TOpus }

class function TOpus.NewEncComment : IOpusEncComment;
begin
  Result := TUniqOpusEncComment.Create as IOpusEncComment;
end;

class function TOpus.NewEncComment(src : IOpusEncComment) : IOpusEncComment;
begin
  Result := TUniqOpusEncComment.Create(src) as IOpusEncComment;
end;

class function TOpus.RefEncComment(src : pOggOpusComments) : IOpusEncComment;
begin
  Result := TRefOpusEncComment.Create(src) as IOpusEncComment;
end;

class function TOpus.NewDecComment : IOGGComment;
begin
  Result := TUniqOpusDecComment.Create as IOGGComment;
end;

class function TOpus.RefDecComment(src : pOpusTags) : IOGGComment;
begin
  Result := TRefOpusDecComment.Create(src) as IOGGComment;
end;

class function TOpus.RefDecHead(src : pOpusHead) : IOpusDecHead;
begin
  Result := TRefOpusDecHead.Create(src) as IOpusDecHead;
end;

{class function TOpus.NewDecPicture : IOpusDecPicture;
begin
  Result := TUniqOpusDecPicture.Create as IOpusDecPicture;
end; }

class function TOpus.NewStreamingEncoder(aStream : TStream;
  aMode : TOGGSoundEncoderMode; aChannels : Cardinal; aFreq,
  aBitrate : Cardinal; aComplexity : Integer; aComments : IOGGComment
  ) : TOpusOggEncoder;
begin
  Result := TOpusOggStreamingEncoder.Create(aStream, aMode,
                                                  achannels,
                                                  aFreq, abitrate,
                                                  aComplexity,
                                                  aComments);
end;

class function TOpus.NewStreamingDecoder(aStream : TStream) : TOpusOggDecoder;
begin
  Result := TOpusOggStreamingDecoder.Create(aStream);
end;

class function TOpus.OpusLibsLoad(const aOpusLibs : array of String
  ) : Boolean;
begin
  Result := InitOpusInterface(aOpusLibs);
end;

class function TOpus.OpusLibsLoadDefault : Boolean;
begin
  Result := InitOpusInterface(OpusDLL);
end;

class function TOpus.IsOpusLibsLoaded : Boolean;
begin
  Result := IsOpusloaded;
end;

class function TOpus.OpusLibsUnLoad : Boolean;
begin
  Result := DestroyOpusInterface;
end;

end.

