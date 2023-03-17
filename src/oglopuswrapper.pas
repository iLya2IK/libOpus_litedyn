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
  Classes, SysUtils, libOpus_dynlite,
  OGLSoundUtilTypes, OGLSoundUtils, OGLSoundDataConverting,
  OGLFastList;

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

  TOpusEncSignal = (oesAuto, oesVoice, oesMusic);
  TOpusEncApp = (oeaVOIP, oeaAudio, oeaLowDelay);
  TOpusFrameSize = (ofs_2_5ms, ofs_5ms, ofs_10ms, ofs_20ms, ofs_40ms,
                    ofs_60ms, ofs_80ms, ofs_100ms, ofs_120ms, ofs_Error);
  TOpusBandWidth = (obwError, obwAuto, obwNarrowBand, obwMediumBand,
                              obwWideBand, obwSuperWideBand, obwFullBand);

  OpusPacket = record
    data : pcuchar;
    len  : integer;
  end;

  pOpusPacket = ^OpusPacket;

  { IOpusEncComment }

  IOpusEncComment = interface(ISoundComment)
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
  procedure Parse(src : ISoundComment; const tag : String);

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

  IOpusEncoderDecoder = interface(IUnknown)
  ['{85E2202D-BBF3-4CE7-918D-A7FD2DE398BC}']
  { Frequency of signal }
  function GetFrequency : Cardinal;
  { Number of channels }
  function GetChannels : Cardinal;

  { Convert frame size to number of bytes. isfloat defines size of sample }
  function FrameSizeToBytes(fSz : TOpusFrameSize; isfloat : Boolean) : Integer;
  { Convert frame size to number of samples per channel }
  function FrameSizeToSamples(fSz : TOpusFrameSize) : Integer;
  { Convert samples per channel to frame size }
  function SamplesToFrameSize(fSamples : Integer) : TOpusFrameSize;
  { Convert samples per channel to bytes number. isfloat defines size of sample }
  function SamplesToBytes(fSamples : Integer; isfloat : Boolean) : Integer;
  { Convert bytes to frame size. isfloat defines size of sample }
  function BytesToFrameSize(fBytes : Integer; isfloat : Boolean) : TOpusFrameSize;
  { Convert bytes to samples per channel. isfloat defines size of sample }
  function BytesToSamples(fBytes : Integer; isfloat : Boolean) : Integer;
  end;

  { IOpusEncoder }

  IOpusEncoder = interface(IOpusEncoderDecoder)
  ['{673D4CDC-E222-4961-BE78-C002538D5597}']
  function Ref : pOpusEncoder;

  { Init encoder. @see opus_encoder_init
    @afreq Frequency
    @achannels Number of channels
    @aApp Coding mode }
  procedure Init(afreq : Cardinal; achannels : Cardinal; aApp : TOpusEncApp);
  { Done encoder. }
  procedure Done;

  { Get final range for encoder }
  function FinalRange : Integer;

  { Encode an Opus frame from 16-bit input. @see opus_encode
    @param Buffer Buffer to encode
    @param Fsz Size (duration) of frame
    @param Data Output payload. This must contain storage for at least MaxDataSz
    @param MaxDataSz Size of the allocated memory for the output payload
    @returns The length of the encoded packet (in bytes) }
  function EncodeFrameInt16(Buffer : Pointer; Fsz : TOpusFrameSize;
                            Data : Pointer; MaxDataSz : Integer) : Integer;
  { Encode an Opus frame from floating point input. @see opus_encode_float
    @param Buffer Buffer to encode
    @param Fsz Size (duration) of frame
    @param Data Output payload. This must contain storage for at least MaxDataSz
    @param MaxDataSz Size of the allocated memory for the output payload
    @returns The length of the encoded packet (in bytes) }
  function EncodeFrameFloat(Buffer : Pointer; Fsz : TOpusFrameSize;
                            Data : Pointer; MaxDataSz : Integer) : Integer;

  procedure SetBitrate(bitrate : Integer);
  procedure SetBandwidth(bandwidth : Integer);
  procedure SetComplexity(complex : Integer);
  procedure SetSignal(sig : TOpusEncSignal);
  procedure SetApplication(app : TOpusEncApp);
  procedure SetMode(mode : TSoundEncoderMode);
  end;

  { IOpusRepacketizer }

  IOpusRepacketizer = interface(IUnknown)
  ['{74DD0896-DAC7-4052-9595-B4F638625F0D}']
  function Ref : pOpusRepacketizer;

  procedure Init;
  procedure Done;

  procedure ReInit;
  procedure Cat(aData : Pointer; aLen : Integer);
  function OutRange(aBegin, aEnd : Integer;
                            aBuffer : Pointer; aMaxLen : Integer) : integer;
  function OutAll(aBuffer : Pointer; aMaxLen : Integer) : integer;

  function NumberOfFrames : Integer;
  end;

  { IOpusFrames }

  IOpusFrames = interface(IUnknown)
  ['{283058E9-7B61-4DE1-A43E-8D56E1F8253C}']
  procedure Init(aData : PPointer; aSizes : PInteger; aCnt : Integer);

  function Data(aIndex : Integer) : Pointer;
  function Size(aIndex : Integer) : Integer;
  function Count : Integer;
  end;

  { IOpusPacket }

  IOpusPacket = interface(IUnknown)
  ['{10A5C4F2-2400-48C3-BCC9-477BB2293EE9}']
  function Ref : pOpusPacket;

  procedure Init(aData : Pointer; aLen : Integer);
  procedure Done;

  function Data : Pointer;
  function Length : Integer;

  function Parse(var aTOC: Byte; var aOffset: Integer) : IOpusFrames;
  function Bandwidth: TOpusBandWidth;
  function SamplesPerFrame(aFrequency: Cardinal): Integer;
  function Channels: Integer;
  function Frames: Integer;
  function Samples(aFrequency: Cardinal): Integer;
  end;

  IOpusDecoder = interface(IOpusEncoderDecoder)
  ['{4CF7B3A6-EF89-4D1B-AF71-415B45145E65}']
  function Ref : pOpusDecoder;

  procedure Init(afreq : Cardinal; achannels : Cardinal);
  procedure Done;

  function DecodeInt16(aBuffer : Pointer; aBuffSize : Integer;
                        aDecodedData : Pointer;
                        aDecSampCount : Integer;
                        FECmode : Boolean) : Integer;
  function DecodeFloat(aBuffer : Pointer; aBuffSize : Integer;
                        aDecodedData : Pointer;
                        aDecSampCount : Integer;
                        FECmode : Boolean) : Integer;

  procedure SetGain(aValue : Integer);
  function Samples(aPacket : IOpusPacket) : Integer;
  function Samples(aPacket : Pointer; aBytes : Integer) : Integer;
  function LastPacketDuration : Integer;
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

  TRefOpusDecComment = class(TNativeVorbisCommentCloneable)
  private
    FRef : pOpusTags;
  protected
    procedure Init; override;
    procedure Done; override;

    procedure SetNativeVendor(v : PChar); override;
    function GetNativeVendor : PChar; override;
    function GetNativeComment(index : integer) : PChar; override;
    function GetNativeCommentLength(index : integer) : Int32; override;
    function GetNativeCommentCount : Int32; override;
  public
    function Ref : Pointer; override;

    constructor Create(aRef : pOpusTags); overload;

    procedure Add(const comment: String); override;
    procedure AddTag(const tag, value: String); override;
    function Query(const tag: String; index: integer): String; override;
    function QueryCount(const tag: String): integer; override;
  end;

  { TUniqOpusDecComment }

  TUniqOpusDecComment = class(TRefOpusDecComment)
  public
    destructor Destroy; override;
  end;

  { TRefOpusEncComment }

  TRefOpusEncComment = class(TSoundCommentCloneable, IOpusEncComment)
  private
    FRef : pOggOpusComments;
  protected
    procedure Init; override;
    procedure Done; override;
    function GetVendor : String; override;
    procedure SetVendor(const {%H-}S : String); override;
  public
    function Ref : Pointer; override;

    constructor Create(aRef : pOggOpusComments); overload;

    procedure Add(const comment: String); override;
    procedure AddTag(const tag, value: String); override;
    function TagsCount : Integer; override;
    function GetTag({%H-}index : integer) : String; override;
    function Query(const {%H-}tag: String; {%H-}index: integer): String; override;
    function QueryCount(const {%H-}tag: String): integer; override;
    procedure AddPicture(const filename: String; aPic : TAPICType; const descr : String);
    procedure AddPictureFromMem(const mem : Pointer; sz : Integer; aPic : TAPICType; const descr : String);
  end;

  { TUniqOpusEncComment }

  TUniqOpusEncComment = class(TRefOpusEncComment)
  public
    constructor Create(src : IOpusEncComment); overload;
    destructor Destroy; override;
  end;

  { TOpusEncoderDecoder }

  TOpusEncoderDecoder = class(TInterfacedObject, IOpusEncoderDecoder)
  private
    fFreq : Cardinal;
    fChannels : Cardinal;
  protected
    procedure SetChannels({%H-}AValue : Cardinal); virtual;
    procedure SetFrequency({%H-}AValue : Cardinal); virtual;
    function GetFrequency : Cardinal;
    function GetChannels : Cardinal;
  public
    constructor Create(afreq : Cardinal; achannels : Cardinal);

    property Frequency : Cardinal read GetFrequency write SetFrequency;
    property Channels : Cardinal read GetChannels write SetChannels;

    function FrameSizeToBytes(fSz : TOpusFrameSize; isfloat : Boolean) : Integer;
    function FrameSizeToSamples(fSz : TOpusFrameSize) : Integer;
    function SamplesToFrameSize(fSamples : Integer) : TOpusFrameSize;
    function SamplesToBytes(fSamples : Integer; isfloat : Boolean) : Integer;
    function BytesToFrameSize(fBytes : Integer; isfloat : Boolean) : TOpusFrameSize;
    function BytesToSamples(fBytes : Integer; isfloat : Boolean) : Integer;
  end;

  { TOpusEncoder }

  TOpusEncoder = class(TOpusEncoderDecoder, IOpusEncoder)
  private
    fRef : pOpusEncoder;
    procedure Init(afreq : Cardinal; achannels : Cardinal; aApp : TOpusEncApp);
    procedure Done;
  public
    function Ref : pOpusEncoder;

    constructor Create(afreq : Cardinal; achannels : Cardinal; aApp : TOpusEncApp);
    destructor Destroy; override;

    function FinalRange : Integer;

    function EncodeFrameInt16(Buffer : Pointer; Fsz : TOpusFrameSize;
                              Data : Pointer; MaxDataSz : Integer) : Integer;
    function EncodeFrameFloat(Buffer : Pointer; Fsz : TOpusFrameSize;
                              Data : Pointer; MaxDataSz : Integer) : Integer;

    function GetBitrate : Integer;
    function GetMode : TSoundEncoderMode;
    function GetComplexity : Integer;
    function GetVersion : Integer;

    procedure SetBitrate(bitrate : Integer);
    procedure SetBandwidth(bandwidth : Integer);
    procedure SetComplexity(complex : Integer);
    procedure SetSignal(sig : TOpusEncSignal);
    procedure SetApplication(app : TOpusEncApp);
    procedure SetMode(mode : TSoundEncoderMode);
  end;

  { TOpusRepacketizer }

  TOpusRepacketizer = class(TInterfacedObject, IOpusRepacketizer)
  private
    fRef : pOpusRepacketizer;
    procedure Init;
    procedure Done;
  public
    function Ref : pOpusRepacketizer;

    constructor Create;
    destructor Destroy; override;

    procedure ReInit;
    procedure Cat(aData : Pointer; aLen : Integer);
    function OutRange(aBegin, aEnd : Integer;
                              aBuffer : Pointer; aMaxLen : Integer) : integer;
    function OutAll(aBuffer : Pointer; aMaxLen : Integer) : integer;

    function NumberOfFrames : Integer;
  end;

  POpusPacketHeaderSimple = ^TOpusPacketHeaderSimple;
  TOpusPacketHeaderSimple = packed record
    len : Int32;
  end;

  POpusPacketHeaderRange = ^TOpusPacketHeaderRange;
  TOpusPacketHeaderRange = packed record
    len : Int32;
    enc_range : Int32;
  end;

  POpusPacketHeaderState = ^TOpusPacketHeaderState;
  TOpusPacketHeaderState = packed record
    len : Int32;
    channels : Byte;
    freq_khz : Byte;
  end;

  TOpusPacketHeaderType = (ophCustom, ophSimple, ophFinalRange, ophState);

  TOpusStreamEncoder = class;

  TOpusPacketWriteHeader = procedure (Sender : TOpusStreamEncoder;
                                      packetLen : Integer) of object;
  POpusPacketWriteHeaderRef = ^TOpusPacketWriteHeaderRef;
  TOpusPacketWriteHeaderRef = record
    ref : TOpusPacketWriteHeader;
  end;

  { TOpusStreamEncoder }

  TOpusStreamEncoder = class(TSoundAbstractEncoder, ISoundStreamEncoder)
  private
    fEncoder  : TOpusEncoder;
    FOnPacketWriteHeader : TOpusPacketWriteHeader;
    fPacketHeaderType : TOpusPacketHeaderType;
    fRepacker : TOpusRepacketizer;
    fRepackerDurationMs : Single;
    fMaxPacketDurationMs : Single;
    fBuffers : TFastPointerCollection;
    fMaxDataBufferSize : Integer;
    fLastDuration : TOpusFrameSize;

    procedure Initialize(aStream : TStream;
                         aProp : ISoundEncoderProps);
    function WriteFrame(aPCM : Pointer; aCount : TOpusFrameSize; isfloat : Boolean
      ) : Integer;
    procedure PushPacket;
    procedure WritePacketHeader(packetLen : Integer);
    procedure SetOnPacketWriteHeader(AValue : TOpusPacketWriteHeader);
  protected
    procedure InternalWriteHeader(Sender : TOpusStreamEncoder;
                                  packetLen : Integer);
    procedure Init(aProps : ISoundEncoderProps;
                   {%H-}aComment : ISoundComment); override;
    procedure Done; override;
    function GetSampleSize : TSoundSampleSize; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetMode : TSoundEncoderMode; override;
    function GetQuality : Single; override;
    function GetVersion : Integer; override;
  public
    constructor Create(aStream : TStream;
                       aProps : ISoundEncoderProps);
    destructor Destroy; override;

    function WriteInt16(aPCM : Pointer; aCount : TOpusFrameSize) : Integer;
    function WriteFloat(aPCM : Pointer; aCount : TOpusFrameSize) : Integer;
    function WriteSamplesInt16(aPCM : Pointer; aCount : Integer) : Integer;
    function WriteSamplesFloat(aPCM : Pointer; aCount : Integer) : Integer;
    function WriteDataInt16(aPCM : Pointer; aBytes : Integer) : Integer;
    function WriteDataFloat(aPCM : Pointer; aBytes : Integer) : Integer;

    function  Comments : ISoundComment; override;
    function  WriteData(Buffer : Pointer; Count : ISoundFrameSize;
                       {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure Close({%H-}Par : Pointer); override;
    procedure Flush({%H-}Par : Pointer); override;
    procedure SetStream(aStream : TStream); virtual;

    function Ready : Boolean; override;

    property Encoder : TOpusEncoder read fEncoder;
    property PacketHeaderType : TOpusPacketHeaderType read
                                fPacketHeaderType write fPacketHeaderType;
    property OnPacketWriteHeader : TOpusPacketWriteHeader read FOnPacketWriteHeader write SetOnPacketWriteHeader;
  end;

  { TOpusDecoder }

  TOpusDecoder = class(TOpusEncoderDecoder, IOpusDecoder)
  private
    fRef : pOpusDecoder;

    procedure Init(afreq : Cardinal; achannels : Cardinal);
    procedure Done;
  protected
    procedure SetChannels(AValue : Cardinal); override;
    procedure SetFrequency(AValue : Cardinal); override;
  public
    function Ref : pOpusDecoder;

    constructor Create;
    constructor Create(afreq : Cardinal; achannels : Cardinal);
    destructor Destroy; override;

    function DecodeInt16(aBuffer : Pointer; aBuffSize : Integer;
                         aDecodedData : Pointer;
                         aDecSampCount : Integer;
                         FECmode : Boolean) : Integer;
    function DecodeFloat(aBuffer : Pointer; aBuffSize : Integer;
                         aDecodedData : Pointer;
                         aDecSampCount : Integer;
                         FECmode : Boolean) : Integer;

    procedure SetGain(aValue : Integer);
    function Samples(aPacket : IOpusPacket) : Integer; overload;
    function Samples(aPacket : Pointer; aBytes : Integer) : Integer; overload;
    function LastPacketDuration : Integer;
    function Bitrate : Integer;
    function Version : Cardinal;
  end;

  TOpusStreamDecoder = class;

  TOpusPacketReadHeader = function (Sender : TOpusStreamDecoder) : Integer of object;
  POpusPacketReadHeaderRef = ^TOpusPacketReadHeaderRef;
  TOpusPacketReadHeaderRef = record
    ref : TOpusPacketReadHeader;
  end;

  { TOpusDecodedPacket }

  TOpusDecodedPacket = class
  private
    fData : Pointer;
    fLength : Integer;
  public
    constructor Create(aLength : Integer);
    destructor Destroy; override;

    procedure UpdateLength(newLen : Integer);

    function Read(aDest : Pointer; offset, aSz : Integer) : Integer;

    property Length : Integer read FLength;
    property Data : Pointer read FData;
  end;

  { TOpusStreamDecoder }

  TOpusStreamDecoder = class(TSoundAbstractDecoder, ISoundStreamDecoder)
  private
    fDecoder  : TOpusDecoder;
    FOnPacketReadHeader : TOpusPacketReadHeader;
    fPacketHeaderType : TOpusPacketHeaderType;

    fPacketHeader : Pointer;
    fPacketHeaderSize : Integer;
    fPacket       : Pointer;
    fPacketSize   : Integer;

    fDecodedData  : TOpusDecodedPacket;
    fDecodedOffset: Integer;

    procedure ReallocHeader;
    procedure ReallocPacket;
    procedure SetOnPacketReadHeader(AValue : TOpusPacketReadHeader);
    procedure SetPacketHeaderType(AValue : TOpusPacketHeaderType);
    function ReadByteDataRaw(aPCM : Pointer; aSize : Integer; isfloat : Boolean) : integer;
    function PopNewPacket(isfloat : Boolean) : Integer;

    procedure InitDecoder(aFreq : Cardinal; aChannels : Cardinal);
  protected
    function InternalGetPacketHeader(Sender : TOpusStreamDecoder) : Integer;
    // ISoundDecoder
    procedure Init; override;
    procedure Done; override;
    function GetSampleSize : TSoundSampleSize; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetVersion : Integer; override;
  public
    constructor Create(aStream : TStream;
                       aFreq : Cardinal;
                       aChannels : Cardinal); overload;
    constructor Create(aStream : TStream; aHeaderType : TOpusPacketHeaderType;
      aOnReadHeader : TOpusPacketReadHeader); overload;
    destructor Destroy; override;

    function ReadNextPacket(isfloat : Boolean) : Integer;
    procedure ReadPacketHeader;

    function ReadInt16(aPCM : Pointer; aCount : TOpusFrameSize) : Integer;
    function ReadFloat(aPCM : Pointer; aCount : TOpusFrameSize) : Integer;
    function ReadSamplesInt16(aPCM : Pointer; aCount : Integer) : Integer;
    function ReadSamplesFloat(aPCM : Pointer; aCount : Integer) : Integer;
    function ReadDataInt16(aPCM : Pointer; aBytes : Integer) : Integer;
    function ReadDataFloat(aPCM : Pointer; aBytes : Integer) : Integer;
    // ISoundDecoder
    function ReadData(aPCM : Pointer; aFrame : ISoundFrameSize; {%H-}Par : Pointer) : ISoundFrameSize; override;
    function Comments : ISoundComment; override;
    function Ready : Boolean; override;
    //ISoundStreamDecoder
    procedure SetStream(aStream : TStream); virtual;

    property Decoder : TOpusDecoder read fDecoder;
    property Header  : Pointer read fPacketHeader;
    property PacketSize : Integer read fPacketSize write fPacketSize;
    property PacketData : Pointer read fPacket;
    property PacketHeaderType : TOpusPacketHeaderType read
                                fPacketHeaderType write SetPacketHeaderType;
    property OnPacketReadHeader : TOpusPacketReadHeader read
                                FOnPacketReadHeader write SetOnPacketReadHeader;
  end;

  OpusFrames = Array [0..47] of Pointer;
  OpusFrameSizes = Array [0..47] of Integer;
  pOpusFrames = ^OpusFrames;
  pOpusFrameSizes = ^OpusFrameSizes;

  { TOpusFrames }

  TOpusFrames = class(TInterfacedObject, IOpusFrames)
  private
    fFrames : pOpusFrames;
    fSizes  : pOpusFrameSizes;
    fCount  : Integer;

    procedure Init(aData : PPointer; aSizes : PInteger; aCnt : Integer);
  public
    constructor Create(aData : PPointer; aSizes : PInteger; aCnt : Integer);

    function Data(aIndex : Integer) : Pointer;
    function Size(aIndex : Integer) : Integer;
    function Count : Integer;
  end;

  { TOpusOggEncoder }

  TOpusOggEncoder = class(TSoundAbstractEncoder, ISoundStreamEncoder)
  private
    fRef : pOggOpusEnc;
    fComm : ISoundComment;
    fChannels : Cardinal;
    fFreq : Cardinal;
  protected
    procedure InitEncoder(ope_error : PInteger); virtual;
    procedure Init(aProps : ISoundEncoderProps;
                   aComments : ISoundComment); override;
    procedure Done; override;

    function GetSampleSize : TSoundSampleSize; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetMode : TSoundEncoderMode; override;
    function GetQuality : Single; override;
    function GetVersion : Integer; override;

    procedure SetBitrate(AValue : Cardinal); override;
    procedure SetMode(AValue : TSoundEncoderMode); override;
    procedure SetQuality(AValue : Single); override;
    procedure SetDecisionDelay(AValue : Integer);
    procedure SetCommentPadding(AValue : Integer);
  public
    function Ref : pOggOpusEnc; inline;

    constructor Create(aProps : ISoundEncoderProps;
                       aComments : ISoundComment);
    destructor Destroy; override;

    //ISoundEncoder
    function  Comments : ISoundComment; override;

    function  WriteData(Buffer : Pointer; Count : ISoundFrameSize;
                       {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure WriteHeader({%H-}Par : Pointer); override;
    procedure Close({%H-}Par : Pointer); override;
    procedure Flush({%H-}Par : Pointer); override;
    //ISoundStreamEncoder
    procedure SetStream(aStream : TStream); virtual;

    function Ready : Boolean; override;
  end;

  { TOpusOggStreamEncoder }

  TOpusOggStreamEncoder = class(TOpusOggEncoder)
  public
    constructor Create(aStream : TStream;
      aProps : ISoundEncoderProps; aComments : ISoundComment);
  end;

  { TOpusAltOggStreamEncoder }

  TOpusAltOggStreamEncoder = class(TOpusOggStreamEncoder)
  protected
    procedure InitEncoder(ope_error : PInteger); override;
    procedure WritePages(aFlush : Boolean);
  public
    function  WriteData(Buffer : Pointer; Count : ISoundFrameSize;
                               {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure WriteHeader({%H-}Par : Pointer); override;
    procedure Close({%H-}Par : Pointer); override;
    procedure Flush({%H-}Par : Pointer); override;
  end;

  { TOpusOggDecoder }

  TOpusOggDecoder = class(TSoundAbstractDecoder)
  private
    fRef  : pOggOpusFile;
    fHead : IOpusDecHead;
    fComm : ISoundComment;
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

    function  Comments : ISoundComment; override;

    function ReadData(Buffer : Pointer; Count : ISoundFrameSize;
                       {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure ResetToStart; override;
    procedure RawSeek(pos : Int64); override;
    procedure SampleSeek(pos : Integer); override;
    procedure TimeSeek(pos : Double); override;
    function RawTell : Int64; override;
    function SampleTell : Integer; override;
    function TimeTell : Double; override;
    function RawTotal : Int64; override;
    function SampleTotal : Integer; override;
    function TimeTotal : Double; override;

    function Ready : Boolean; override;
  end;

  { TOpusOggStreamDecoder }

  TOpusOggStreamDecoder = class(TOpusOggDecoder, ISoundStreamDecoder)
  public
    constructor Create(aStream : TStream; aDataLimits : TSoundDataLimits);
    procedure SetStream(aStream : TStream); virtual;
  end;

  { TOpusFile }

  TOpusFile = class(TSoundFile)
  protected
    function InitEncoder(aProps : ISoundEncoderProps;
                   aComments : ISoundComment) : ISoundEncoder; override;
    function InitDecoder : ISoundDecoder; override;
  end;

  TOpus = class
  private
    class function NativeFrameSizeToEnum(fz : Integer) : TOpusFrameSize;
    class function EnumToNativeFrameSize(fz : TOpusFrameSize) : Integer;
    class function NativeBandWidthToEnum(fz : Integer) : TOpusBandWidth;
    class function EnumToNativeBandWidth(fz : TOpusBandWidth) : Integer;
    class function NativeAppSpecToEnum(fz : Integer) : TOpusEncApp;
    class function EnumToNativeAppSpec(fz : TOpusEncApp) : Integer;
    class function NativeSigToEnum(fz : Integer) : TOpusEncSignal;
    class function EnumToNativeSig(fz : TOpusEncSignal) : Integer;
    class function TimeToLowFrameSize(dur : Single) : TOpusFrameSize;
    class function TimeToHighFrameSize(dur : Single) : TOpusFrameSize;
  public
    {  Create the new Opus encoder comment
       @returns New IOpusEncComment interface }
    class function NewEncComment : IOpusEncComment; overload;
    class function NewEncComment(src : ISoundComment) : IOpusEncComment; overload;
    {  Create copy of Opus encoder comment
       @param src Encoder comment interface to copy from
       @returns New IOpusEncComment interface }
    class function NewEncComment(src : IOpusEncComment) : IOpusEncComment; overload;
    {  Create the new Opus encoder comment referenced to native pOggOpusComments
       @param src Native encoder comment to reference to
       @returns New IOpusEncComment interface }
    class function RefEncComment(src : pOggOpusComments) : IOpusEncComment;
    {  Create the new Opus decoder comment
       @returns New ISoundComment interface }
    class function NewDecComment : ISoundComment;
    class function NewDecComment(src : ISoundComment) : ISoundComment;
    {  Create the new Opus decoder comment referenced to native pOpusTags
       @param src Native decoder comment to reference to
       @returns New ISoundComment interface }
    class function RefDecComment(src : pOpusTags) : ISoundComment;
    {  Create the new Opus decoder header referenced to native pOpusHead
       @param src Native decoder header to reference to
       @returns New IOpusDecHead interface }
    class function RefDecHead(src : pOpusHead) : IOpusDecHead;
    //class function NewDecPicture : IOpusDecPicture;

    class function FrameFromDuration(aFreq : Cardinal; aChannels : Cardinal;
                         aDurationMs : TOpusFrameSize;
                         isfloat : Boolean) : ISoundFrameSize;

    {  Converts the number of bytes to a frame size (frame duration)
       with a sample size equal to int16. The resulting frame duration is
       rounded to the maximum available value.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aBytes Amount of bytes
       @returns Frame size (duration) as TOpusFrameSize }
    class function HighFrameSizeInt16(aFreq, aChannels : Cardinal;
                   aBytes : Integer) : TOpusFrameSize;
    {  Converts the number of bytes to a frame size (frame duration)
       with a sample size equal to float. The resulting frame duration is
       rounded to the maximum available value.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aBytes Amount of bytes
       @returns Frame size (duration) as TOpusFrameSize }
    class function HighFrameSizeFloat(aFreq, aChannels : Cardinal;
                   aBytes : Integer) : TOpusFrameSize;
    {  Converts the number of bytes to a frame size (frame duration)
       with a sample size equal to int16. The resulting frame duration is
       rounded to the minimum available value.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aBytes Amount of bytes
       @returns Frame size (duration) as TOpusFrameSize }
    class function LowFrameSizeInt16(aFreq, aChannels : Cardinal;
                   aBytes : Integer) : TOpusFrameSize;
    {  Converts the number of bytes to a frame size (frame duration)
       with a sample size equal to float. The resulting frame duration is
       rounded to the minimum available value.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aBytes Amount of bytes
       @returns Frame size (duration) as TOpusFrameSize }
    class function LowFrameSizeFloat(aFreq, aChannels : Cardinal;
                   aBytes : Integer) : TOpusFrameSize;
    {  Converts the number of samples to a frame size (frame duration).
       The resulting frame duration is rounded to the maximum available value.
       @param aFreq Frequency of frame in Hz
       @param aBytes Amount of samples
       @returns Frame size (duration) as TOpusFrameSize }
    class function HighFrameSizeSamples(aFreq : Cardinal;
                   aSamples : Integer) : TOpusFrameSize;
    {  Converts the number of samples to a frame size (frame duration).
       The resulting frame duration is rounded to the minimum available value.
       @param aFreq Frequency of frame in Hz
       @param aBytes Amount of samples
       @returns Frame size (duration) as TOpusFrameSize }
    class function LowFrameSizeSamples(aFreq : Cardinal;
                   aSamples : Integer) : TOpusFrameSize;
    {  Converts the frame size (frame duration) to a number of bytes.
       The sample size equal to int16.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aFs Frame size as TOpusFrameSize
       @returns Number of bytes per frame }
    class function MinBufferSizeInt16(aFreq, aChannels : Cardinal;
                   aFs : TOpusFrameSize) : Integer; overload;
    {  Converts the frame size (frame duration) to a number of bytes.
       The sample size equal to float.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aFs Frame size as TOpusFrameSize
       @returns Number of bytes per frame }
    class function MinBufferSizeFloat(aFreq, aChannels : Cardinal;
                   aFs : TOpusFrameSize) : Integer; overload;
    {  Converts the frame size (frame duration) to a number of bytes.
       The sample size equal to int16.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aFs Frame size in milliseconds
       @returns Number of bytes per frame }
    class function MinBufferSizeInt16(aFreq, aChannels : Cardinal;
                   aDuration : Single) : Integer; overload;
    {  Converts the frame size (frame duration) to a number of bytes.
       The sample size equal to float.
       @param aFreq Frequency of frame in Hz
       @param aChannels Number of channels in frame
       @param aFs Frame size in milliseconds
       @returns Number of bytes per frame }
    class function MinBufferSizeFloat(aFreq, aChannels : Cardinal;
                   aDuration : Single) : Integer; overload;
    {  Converts the frame size (frame duration) to a number of samples
       per channel.
       @param aFreq Frequency of frame in Hz
       @param aFs Frame size as TOpusFrameSize
       @returns Number of samples per frame per channel }
    class function SamplesCount(aFreq : Cardinal; aFs : TOpusFrameSize) : Integer;
    {  Converts the frame size (frame duration) to a duration in ms.
       @param aFs Frame size as TOpusFrameSize
       @returns Duration in milliseconds }
    class function FrameSizeToTime(fz : TOpusFrameSize) : Single;

    {  Creates an Opus encoder that packs data packets into an OGG container.
       @param aStream A reference to the stream object in which the encoded
                      data should be stored
       @param aProps Encoder properties
              PROP_MODE An encoding mode (VBR or CBR)
              PROP_CHANNELS Number of channels
              PROP_FREQUENCY Frequency of signal in Hz
              PROP_BITRATE A target value of bitrate in bits per second (bps)
              PROP_QUALITY = PROP_COMPLEXITY,
              PROP_COMPLEXITY A complexity value for encoder [0..10]
              PROP_DECISION_DELAY Set to zero for streaming encoding.
                                  Default value if 96000 samples.
                                  @see OPE_SET_DECISION_DELAY_REQUEST
                                  in Opus docs
              PROP_COMMENT_PADDING Sets the padding value in bytes between the
                                   comment block and the stream body
                                   @see OPE_SET_COMMENT_PADDING_REQUEST
                                   in Opus docs
       @param aComments A comment block to save to ogg container
       @returns New ISoundStreamEncoder object }
    class function NewOggStreamEncoder(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments : ISoundComment) : ISoundStreamEncoder;
    {  Creates an Opus alt encoder that packs data packets into an OGG container.
       Alternative encoder working in the "pull" mode (supports Flush method).
       @param aStream A reference to the stream object in which the encoded
                      data should be stored
       @param aProps Encoder properties
              PROP_MODE An encoding mode (VBR or CBR)
              PROP_CHANNELS Number of channels
              PROP_FREQUENCY Frequency of signal in Hz
              PROP_BITRATE A target value of bitrate in bits per second (bps)
              PROP_QUALITY = PROP_COMPLEXITY,
              PROP_COMPLEXITY A complexity value for encoder [0..10]
              PROP_DECISION_DELAY Set to zero for streaming encoding.
                                  Default value if 96000 samples.
                                  @see OPE_SET_DECISION_DELAY_REQUEST
                                  in Opus docs
              PROP_COMMENT_PADDING Sets the padding value in bytes between the
                                   comment block and the stream body
                                   @see OPE_SET_COMMENT_PADDING_REQUEST
                                   in Opus docs
       @param aComments A comment block to save to ogg container
       @returns New ISoundStreamEncoder object }
    class function NewAltOggStreamEncoder(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments : ISoundComment) : ISoundStreamEncoder;
    {  Creates an Opus decoder that unpacks data packets from an OGG container.
       @param aStream A reference to the stream object from which the encoded
                      data should be read
       @param aDataLimits Properties of data stream
       @returns New ISoundStreamDecoder object }
    class function NewOggStreamDecoder(aStream : TStream;
                       aDataLimits : TSoundDataLimits) : ISoundStreamDecoder;

    {  Creates an Opus encoder that packs data packets in custom manner.
       It can be recommended for organizing audio streaming.
       @param aStream A reference to the stream object in which the encoded
                      data should be stored
       @param aProps Encoder properties
              PROP_MODE An encoding mode (VBR or CBR)
              PROP_CHANNELS Number of channels
              PROP_FREQUENCY Frequency of signal in Hz
              PROP_BITRATE A target value of bitrate in bits per second (bps)
              PROP_QUALITY = PROP_COMPLEXITY,
              PROP_COMPLEXITY A complexity value for encoder [0..10]
              PROP_MAX_PACKET_DURATION_MS Max packet size (total length of all
                                   frames in milliseconds). Must be less than
                                   or equal to 120 ms.
              PROP_MAX_PACKET_SIZE Max packet size as TOpusFrameSize
              PROP_HEADER_TYPE Header type as TOpusPacketHeaderType
              PROP_HEADER_CALLBACK Header write callback as
                                   POpusPacketWriteHeaderRef
              PROP_DECISION_DELAY Set to zero for streaming encoding.
                                  Default value if 96000 samples.
                                  @see OPE_SET_DECISION_DELAY_REQUEST
                                  in Opus docs
              PROP_COMMENT_PADDING Sets the padding value in bytes between the
                                   comment block and the stream body
                                   @see OPE_SET_COMMENT_PADDING_REQUEST
                                   in Opus docs
       @returns New ISoundStreamEncoder object }
    class function NewStreamEncoder(aStream : TStream;
                       aProps : ISoundEncoderProps) : ISoundStreamEncoder;
    {  Creates an Opus decoder that unpacks data packets with custom format.
       It can be recommended for organizing audio streaming.
       @param aStream A reference to the stream object from which the encoded
                      data should be read
       @param aFreq Frequency of signal in Hz
       @param aChannels Number of channels
       @returns New ISoundStreamDecoder object }
    class function NewStreamDecoder(aStream : TStream;
                                        aFreq, aChannels : Cardinal) :
                                                         ISoundStreamDecoder; overload;
    {  Creates an Opus decoder that unpacks data packets with custom format.
       It can be recommended for organizing audio streaming.
       @param aStream A reference to the stream object from which the encoded
                      data should be read
       @param aHeaderType Header type as TOpusPacketHeaderType
       @param aOnReadHeader Header read callback as TOpusPacketWriteHeader
       @returns New ISoundStreamDecoder object }
    class function NewStreamDecoder(aStream : TStream;
                                      aHeaderType : TOpusPacketHeaderType;
                                      aOnReadHeader : TOpusPacketReadHeader)  :
                                                         ISoundStreamDecoder; overload;
    {  Creates an Opus decoder that unpacks data packets with custom format.
       It can be recommended for organizing audio streaming.
       @param aStream A reference to the stream object from which the encoded
                      data should be read
       @param aProps Decoder properties
             option 1:
              PROP_CHANNELS Number of channels
              PROP_FREQUENCY Frequency of signal in Hz
             option 2:
              PROP_HEADER_TYPE Header type as TOpusPacketHeaderType
              PROP_HEADER_CALLBACK Header read callback as
                                   POpusPacketReadHeaderRef
                                   (if PROP_HEADER_TYPE is empty or ophCustom)
       @returns New ISoundStreamDecoder object }
    class function NewStreamDecoder(aStream : TStream;
                                      aProps : ISoundProps) : ISoundStreamDecoder; overload;

    {  Applies soft-clipping to bring a float signal within the [-1,1] range.
       @see opus_pcm_soft_clip
       @param aBuffer Input PCM and modified PCM
       @param aSamplesCount Number of samples per channel to process
       @param aChannels Number of channels }
    class procedure PcmSoftClip(aBuffer : Pointer; aSamplesCount : Integer;
                                      aChannels : Cardinal);

    const PROP_MAX_PACKET_DURATION_MS  = $101;
    const PROP_MAX_PACKET_SIZE         = $102;
    const PROP_APPLICATION             = $103;
    const PROP_COMPLEXITY              = TOGLSound.PROP_QUALITY;
    const PROP_HEADER_TYPE             = $104;
    const PROP_HEADER_CALLBACK         = $105;
    const PROP_DECISION_DELAY          = $106;
    const PROP_COMMENT_PADDING         = $107;

    class function EncoderVersionString : String;

    class function OpusLibsLoad(const aOpusLibs : array of String) : Boolean;
    class function OpusLibsLoadDefault : Boolean;
    class function IsOpusLibsLoaded : Boolean;
    class function OpusLibsUnLoad : Boolean;
  end;

  { EOpus }

  EOpus = class(Exception)
  public
    constructor Create(aError : Integer); overload;
  end;

implementation

uses ctypes;

const cOpusError = 'Opus error %d';
      cOpusFullError = 'Opus error (%d) : %s';

      cesOPUS_OK               = 'No error';
      cesOPUS_BAD_ARG          = 'One or more invalid/out of range arguments';
      cesOPUS_BUFFER_TOO_SMALL = 'Not enough bytes allocated in the buffer';
      cesOPUS_INTERNAL_ERROR   = 'An internal error was detected';
      cesOPUS_INVALID_PACKET   = 'The compressed data passed is corrupted';
      cesOPUS_UNIMPLEMENTED    = 'Invalid/unsupported request number';
      cesOPUS_INVALID_STATE    = 'An encoder or decoder structure is invalid or already freed';
      cesOPUS_ALLOC_FAIL       = 'Memory allocation has failed';
      cesOPUS_USUPPORTED       = 'This feature is not supported';
      cesOPUS_TOO_LATE         = 'Object is already initialized';

function ope_write(user_data : pointer; const ptr : pcuchar; len : opus_int32) : integer; cdecl;
begin
  Result := TOpusOggEncoder(user_data).DataStream.DoWrite(ptr, len);
end;

function ope_close({%H-}user_data : pointer): integer; cdecl;
begin
  Result := 0;
end;

function opd_read_func(_stream : pointer; _ptr : pcuchar; _nbytes : Integer) : Integer; cdecl;
begin
  Result := TOpusOggDecoder(_stream).DataStream.DoRead(_ptr, _nbytes);
end;

function opd_seek_func(_stream : pointer;_offset:opus_int64;_whence:Integer): Integer; cdecl;
begin
  if TOpusOggDecoder(_stream).DataStream.Seekable then
    Result := TOpusOggDecoder(_stream).DataStream.DoSeek(_offset, _whence) else
    Result := -1;
end;

function opd_tell_func(_stream : pointer):opus_int64;  cdecl;
begin
  if TOpusOggDecoder(_stream).DataStream.Seekable then
    Result := TOpusOggDecoder(_stream).DataStream.DoTell else
    Result := -1;
end;

function opd_close_func({%H-}_stream : pointer):integer; cdecl;
begin
  result := 0;
end;

{ TOpusAltOggStreamEncoder }

procedure TOpusAltOggStreamEncoder.InitEncoder(ope_error : PInteger);
begin
  fRef := ope_encoder_create_pull(fComm.Ref, fFreq, fChannels, 0, ope_error);
end;

procedure TOpusAltOggStreamEncoder.WritePages(aFlush : Boolean);
var
  aPage : pcchar;
  aPageLen : opus_int32;
begin
  while ope_encoder_get_page(fRef, @aPage, @aPageLen, integer(aFlush)) > 0 do
  begin
    if aPageLen > 0 then
    begin
      DataStream.DoWrite(aPage, aPageLen)
    end;
  end;
end;

function TOpusAltOggStreamEncoder.WriteData(Buffer : Pointer;
  Count : ISoundFrameSize; Par : Pointer) : ISoundFrameSize;
begin
  Result := inherited WriteData(Buffer, Count, Par);
  if Result.IsValid then
    WritePages(false);
end;

procedure TOpusAltOggStreamEncoder.WriteHeader(Par : Pointer);
begin
  inherited WriteHeader(Par);
  WritePages(true);
end;

procedure TOpusAltOggStreamEncoder.Close(Par : Pointer);
begin
  inherited Close(Par);
  WritePages(true);
end;

procedure TOpusAltOggStreamEncoder.Flush(Par : Pointer);
begin
  inherited Flush(Par);
  WritePages(true);
end;

{ TOpusOggStreamDecoder }

constructor TOpusOggStreamDecoder.Create(aStream : TStream;
                                  aDataLimits : TSoundDataLimits);
begin
  InitStream(TOGLSound.NewDataStream(aStream, aDataLimits));
  inherited Create;
end;

procedure TOpusOggStreamDecoder.SetStream(aStream : TStream);
begin
  (DataStream as TSoundDataStream).Stream := aStream;
end;

{ TOpusOggStreamEncoder }

constructor TOpusOggStreamEncoder.Create(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : ISoundComment);
begin
  InitStream(TOGLSound.NewDataStream(aStream, [sdpForceNotSeekable]));
  inherited Create(aProps, aComments);
end;

{ TOpusEncoderDecoder }

procedure TOpusEncoderDecoder.SetChannels({%H-}AValue : Cardinal);
begin
  raise EOpus.Create(cesOPUS_USUPPORTED);
end;

procedure TOpusEncoderDecoder.SetFrequency(AValue : Cardinal);
begin
  raise EOpus.Create(cesOPUS_USUPPORTED);
end;

constructor TOpusEncoderDecoder.Create(afreq : Cardinal; achannels : Cardinal);
begin
  fFreq := afreq;
  fChannels := achannels;
end;

function TOpusEncoderDecoder.GetFrequency : Cardinal;
begin
  Result := fFreq;
end;

function TOpusEncoderDecoder.GetChannels : Cardinal;
begin
  Result := fChannels;
end;

function TOpusEncoderDecoder.FrameSizeToBytes(fSz : TOpusFrameSize;
  isfloat : Boolean) : Integer;
begin
  if isfloat then
    Result := TOpus.MinBufferSizeFloat(fFreq, fChannels, fSz)
  else
    Result := TOpus.MinBufferSizeInt16(fFreq, fChannels, fSz);
end;

function TOpusEncoderDecoder.FrameSizeToSamples(fSz : TOpusFrameSize) : Integer;
begin
  Result := Round(TOpus.FrameSizeToTime(fSz) / 1000.0 * fFreq);
end;

function TOpusEncoderDecoder.SamplesToFrameSize(fSamples : Integer
  ) : TOpusFrameSize;
begin
  Result := TOpus.LowFrameSizeSamples(fFreq, fSamples);
end;

function TOpusEncoderDecoder.SamplesToBytes(fSamples : Integer;
  isfloat : Boolean) : Integer;
begin
  if isfloat then
    Result := fSamples * fChannels * sizeof(cfloat)
  else
    Result := fSamples * fChannels * sizeof(cint16);
end;

function TOpusEncoderDecoder.BytesToFrameSize(fBytes : Integer;
  isfloat : Boolean) : TOpusFrameSize;
begin
  if isfloat then
    Result := TOpus.LowFrameSizeFloat(fFreq, fChannels, fBytes)
  else
    Result := TOpus.LowFrameSizeInt16(fFreq, fChannels, fBytes);
end;

function TOpusEncoderDecoder.BytesToSamples(fBytes : Integer; isfloat : Boolean
  ) : Integer;
begin
  if isfloat then
    Result := fBytes div fChannels div sizeof(cfloat)
  else
    Result := fBytes div fChannels div sizeof(cint16);
end;

{ TOpusDecodedPacket }

constructor TOpusDecodedPacket.Create(aLength : Integer);
begin
  fData := GetMem(aLength);
  fLength := aLength;
end;

destructor TOpusDecodedPacket.Destroy;
begin
  FreeMem(fData);
  inherited Destroy;
end;

procedure TOpusDecodedPacket.UpdateLength(newLen : Integer);
begin
  fLength := newLen;
end;

function TOpusDecodedPacket.Read(aDest : Pointer; offset, aSz : Integer) : Integer;
begin
  if (aSz + offset) > fLength then
    Result := fLength - offset else
    Result := aSz;
  Move(PByte(fData)[offset], aDest^, Result);
end;

{ TOpusDecoder }

procedure TOpusDecoder.Init(afreq : Cardinal; achannels : Cardinal);
var
  cError : Integer;
begin
  fChannels := achannels;
  fFreq := afreq;
  fRef := opus_decoder_create(afreq, achannels, @cError);
  if cError <> 0 then
    raise EOpus.Create(cError);
end;

procedure TOpusDecoder.Done;
begin
  if Assigned(fRef) then
  begin
    opus_decoder_destroy(fRef);
    fRef := nil;
  end;
end;

procedure TOpusDecoder.SetChannels(AValue : Cardinal);
begin
  if Assigned(fRef) then
  begin
    raise EOpus.Create(cesOPUS_TOO_LATE);
  end else
    fChannels := AValue;
end;

procedure TOpusDecoder.SetFrequency(AValue : Cardinal);
begin
  if Assigned(fRef) then
  begin
    raise EOpus.Create(cesOPUS_TOO_LATE);
  end else
    fFreq := AValue;
end;

function TOpusDecoder.Ref : pOpusDecoder;
begin
  Result := fRef;
end;

constructor TOpusDecoder.Create;
begin
  inherited Create(0, 0);
end;

constructor TOpusDecoder.Create(afreq : Cardinal; achannels : Cardinal);
begin
  inherited Create(afreq, achannels);
  Init(afreq, achannels);
end;

destructor TOpusDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusDecoder.DecodeInt16(aBuffer : Pointer; aBuffSize : Integer;
  aDecodedData : Pointer; aDecSampCount : Integer; FECmode : Boolean) : Integer;
begin
  Result := opus_decode(fRef, aBuffer, aBuffSize,
                              aDecodedData, aDecSampCount, Integer(FECmode));
  if Result < 0 then
    raise EOpus.Create(Result);
end;

function TOpusDecoder.DecodeFloat(aBuffer : Pointer; aBuffSize : Integer;
  aDecodedData : Pointer; aDecSampCount : Integer; FECmode : Boolean) : Integer;
begin
  Result := opus_decode_float(fRef, aBuffer, aBuffSize,
                              aDecodedData, aDecSampCount, Integer(FECmode));
  if Result < 0 then
    raise EOpus.Create(Result);
end;

procedure TOpusDecoder.SetGain(aValue : Integer);
begin
  opus_decoder_ctl_set_gain(fRef, aValue);
end;

function TOpusDecoder.Samples(aPacket : IOpusPacket) : Integer;
begin
  Result := opus_decoder_get_nb_samples(fRef, aPacket.Data, aPacket.Length);
end;

function TOpusDecoder.Samples(aPacket : Pointer; aBytes : Integer) : Integer;
begin
  Result := opus_decoder_get_nb_samples(fRef, aPacket, aBytes);
end;

function TOpusDecoder.LastPacketDuration : Integer;
begin
  opus_decoder_ctl_get_last_packet_duration(fRef, @Result);
end;

function TOpusDecoder.Bitrate : Integer;
begin
  opus_decoder_ctl_get_bitrate(fRef, @Result);
end;

function TOpusDecoder.Version : Cardinal;
begin
  Result := 0;
end;

{ TOpusStreamDecoder }

procedure TOpusStreamDecoder.ReallocHeader;
begin
  if Assigned(fPacketHeader) then
    FreeMemAndNil(fPacketHeader);
  if fPacketHeaderSize > 0 then
    fPacketHeader := GetMem(fPacketHeaderSize);
end;

procedure TOpusStreamDecoder.ReallocPacket;
begin
  if Assigned(fPacket) then
    FreeMemAndNil(fPacket);
  if fPacketSize > 0 then
    fPacket := GetMem(fPacketSize);
end;

function TOpusStreamDecoder.ReadNextPacket(isfloat : Boolean) : Integer;
var
  samples : integer;
  decoded_max_size : integer;
begin
  if Assigned(fPacket) and (fPacketSize > 0) then
  begin
    Result := DataStream.DoRead(fPacket, fPacketSize);

    if Result > 0 then
    begin
      samples := fDecoder.Samples(fPacket, Result);

      if samples > 0 then
      begin
        decoded_max_size := samples * fDecoder.Channels;
        if isfloat then
          decoded_max_size := decoded_max_size * Sizeof(cfloat)
        else
          decoded_max_size := decoded_max_size * Sizeof(cint16);

        if Assigned(fDecodedData) then fDecodedData.Free;
        fDecodedData := TOpusDecodedPacket.Create(decoded_max_size);

        try
          if isfloat then
            Result := fDecoder.DecodeFloat(fPacket, Result, fDecodedData.Data, samples, false) else
            Result := fDecoder.DecodeInt16(fPacket, Result, fDecodedData.Data, samples, false);

          decoded_max_size := Result * fDecoder.Channels;
          if isfloat then
            decoded_max_size := decoded_max_size * Sizeof(cfloat)
          else
            decoded_max_size := decoded_max_size * Sizeof(cint16);

          fDecodedData.UpdateLength(decoded_max_size);
        except
          on e : EOpus do FreeAndNil(fDecodedData);
        end;
      end;
    end;
  end;
end;

procedure TOpusStreamDecoder.ReadPacketHeader;
begin
  if Assigned(FOnPacketReadHeader) then
  begin
    fPacketSize := FOnPacketReadHeader(Self);
    ReallocPacket;
  end;
end;

procedure TOpusStreamDecoder.SetOnPacketReadHeader(
  AValue : TOpusPacketReadHeader);
begin
  if FOnPacketReadHeader = AValue then Exit;
  FOnPacketReadHeader := AValue;
  fPacketHeaderType := ophCustom;
end;

procedure TOpusStreamDecoder.SetPacketHeaderType(AValue : TOpusPacketHeaderType
  );
begin
  if fPacketHeaderType = AValue then Exit;
  fPacketHeaderType := AValue;
  case fPacketHeaderType of
    ophFinalRange : begin
      fPacketHeaderSize := Sizeof(TOpusPacketHeaderRange);
    end;
    ophSimple : begin
      fPacketHeaderSize := Sizeof(TOpusPacketHeaderSimple);
    end;
    ophState : begin
      fPacketHeaderSize := Sizeof(TOpusPacketHeaderState);
    end;
  else
    fPacketHeaderSize := 0;
  end;
  ReallocHeader;
end;

function TOpusStreamDecoder.ReadByteDataRaw(aPCM : Pointer; aSize : Integer;
  isfloat : Boolean) : integer;
var rsz : integer;
begin
  Result := 0;
  while Result < aSize do
  begin
    if Assigned(fDecodedData) then
    begin
      rsz := fDecodedData.Read(aPCM, fDecodedOffset, aSize - Result);
      if rsz < 0 then
      begin
        Result := -1;
        Break;
      end;
      Inc(fDecodedOffset, rsz);
      Inc(Result, rsz);
      if (fDecodedOffset >= fDecodedData.Length) then
      begin
        FreeAndNil(fDecodedData);
        fDecodedOffset := 0;
        try
          if PopNewPacket(isfloat) <= 0 then
            Break;
        except
          on e : Exception do Result := -1;
        end;
      end;
    end else
    begin
      try
        if PopNewPacket(isfloat) <= 0 then
          Break;
      except
        on e : Exception do Result := -1;
      end;
    end;
  end;
end;

function TOpusStreamDecoder.PopNewPacket(isfloat : Boolean) : Integer;
begin
  ReadPacketHeader;
  Result := ReadNextPacket(isfloat);
end;

procedure TOpusStreamDecoder.InitDecoder(aFreq : Cardinal; aChannels : Cardinal
  );
begin
  Init;
  fDecoder.Init(aFreq, aChannels);
end;

function TOpusStreamDecoder.InternalGetPacketHeader(Sender : TOpusStreamDecoder
  ) : Integer;
begin
  if Assigned(fPacketHeader) and (fPacketHeaderSize > 0) then
    DataStream.DoRead(fPacketHeader, fPacketHeaderSize);

  case fPacketHeaderType of
    ophFinalRange : begin
      Result := POpusPacketHeaderRange(fPacketHeader)^.len;
    end;
    ophSimple : begin
      Result := POpusPacketHeaderSimple(fPacketHeader)^.len;
    end;
    ophState : begin
      Result := POpusPacketHeaderState(fPacketHeader)^.len;
    end;
  else
    Result := 0;
  end;
end;

procedure TOpusStreamDecoder.Init;
begin
  fPacket := nil;
  fPacketHeader := nil;
  fDecodedData := nil;
  fDecodedOffset := 0;
  fDecoder := TOpusDecoder.Create;
end;

procedure TOpusStreamDecoder.Done;
begin
  if Assigned(fDecoder) then
    FreeAndNil(fDecoder);
  if Assigned(fPacketHeader) then
    FreeMemAndNil(fPacketHeader);
  if Assigned(fPacket) then
    FreeMemAndNil(fPacket);
  if Assigned(fDecodedData) then
    FreeAndNil(fDecodedData);
end;

function TOpusStreamDecoder.GetSampleSize : TSoundSampleSize;
begin
  Result := ss16bit;
end;

function TOpusStreamDecoder.GetBitrate : Cardinal;
begin
  Result := Decoder.Bitrate;
end;

function TOpusStreamDecoder.GetChannels : Cardinal;
begin
  Result := Decoder.Channels;
end;

function TOpusStreamDecoder.GetFrequency : Cardinal;
begin
  Result := Decoder.Frequency;
end;

function TOpusStreamDecoder.GetVersion : Integer;
begin
  Result := Decoder.Version;
end;

constructor TOpusStreamDecoder.Create(aStream : TStream; aFreq : Cardinal;
  aChannels : Cardinal);
begin
  InitStream(TOGLSound.NewDataStream(aStream, [sdpForceNotSeekable, sdpReadOnly]));

  InitDecoder(aFreq, aChannels);

  FOnPacketReadHeader := @InternalGetPacketHeader;
  PacketHeaderType := ophState;
end;

constructor TOpusStreamDecoder.Create(aStream : TStream;
  aHeaderType : TOpusPacketHeaderType;
  aOnReadHeader : TOpusPacketReadHeader);
var
  aFreq, aChannels : Cardinal;
begin
  InitStream(TOGLSound.NewDataStream(aStream, [sdpForceNotSeekable, sdpReadOnly]));
  Init;

  if assigned(aOnReadHeader) then
  begin
    PacketHeaderType := ophCustom;
    FOnPacketReadHeader := aOnReadHeader;
  end else
  begin
    PacketHeaderType := aHeaderType;
    FOnPacketReadHeader := @InternalGetPacketHeader;
  end;
  ReadPacketHeader;
  case aHeaderType of
    ophState : begin
      aFreq :=  Cardinal(POpusPacketHeaderState(fPacketHeader)^.freq_khz) * 1000;
      aChannels := POpusPacketHeaderState(fPacketHeader)^.channels;
      FDecoder.Init(aFreq, aChannels);
    end;
    ophCustom : begin
      // Frequency and Channels must be set during FOnPacketReadHeader
      FDecoder.Init(Decoder.GetFrequency, Decoder.GetChannels);
    end
  else
    //error
  end;
end;

destructor TOpusStreamDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusStreamDecoder.ReadInt16(aPCM : Pointer; aCount : TOpusFrameSize
  ) : Integer;
begin
  Result := ReadDataInt16(aPCM, fDecoder.FrameSizeToBytes(aCount, false));
end;

function TOpusStreamDecoder.ReadFloat(aPCM : Pointer; aCount : TOpusFrameSize
  ) : Integer;
begin
  Result := ReadDataFloat(aPCM, fDecoder.FrameSizeToBytes(aCount, true));
end;

function TOpusStreamDecoder.ReadSamplesInt16(aPCM : Pointer; aCount : Integer
  ) : Integer;
begin
  Result := ReadDataInt16(aPCM, fDecoder.SamplesToBytes(aCount, false));
end;

function TOpusStreamDecoder.ReadSamplesFloat(aPCM : Pointer; aCount : Integer
  ) : Integer;
begin
  Result := ReadDataFloat(aPCM,fDecoder.SamplesToBytes(aCount, true));
end;

function TOpusStreamDecoder.ReadDataInt16(aPCM : Pointer; aBytes : Integer
  ) : Integer;
begin
  Result := fDecoder.BytesToSamples(ReadByteDataRaw(aPCM, aBytes, false), false);
end;

function TOpusStreamDecoder.ReadDataFloat(aPCM : Pointer; aBytes : Integer
  ) : Integer;
begin
  Result := fDecoder.BytesToSamples(ReadByteDataRaw(aPCM, aBytes, true), true);
end;

function TOpusStreamDecoder.ReadData(aPCM : Pointer; aFrame : ISoundFrameSize;
  {%H-}Par : Pointer) : ISoundFrameSize;
begin
  Result := TOGLSound.NewEmptyFrame(aFrame);
  Result.IncBytes(ReadByteDataRaw(aPCM, aFrame.AsBytes,
                                  aFrame.SampleSize in [ss32bit, ssFloat]));
end;

function TOpusStreamDecoder.Comments : ISoundComment;
begin
  Result := nil;
end;

function TOpusStreamDecoder.Ready : Boolean;
begin
  Result := Assigned(fDecoder) and Assigned(fDecoder.Ref);
end;

procedure TOpusStreamDecoder.SetStream(aStream : TStream);
begin
  (DataStream as TSoundDataStream).Stream := aStream;
end;

{ TOpusStreamEncoder }

procedure TOpusStreamEncoder.Init(aProps : ISoundEncoderProps;
  aComment : ISoundComment);
var
  aApp : TOpusEncApp;
  aMode : TSoundEncoderMode;
  aBitrate : Cardinal;
  aComplexity : Single;
begin
  aMode    := aProps.GetDefault(TOGLSound.PROP_MODE,    oemVBR);
  aBitrate := aProps.GetDefault(TOGLSound.PROP_BITRATE, 128000);
  aApp     := aProps.GetDefault(TOpus.PROP_APPLICATION, oeaAudio);
  fMaxPacketDurationMs := aProps.GetDefault(TOpus.PROP_MAX_PACKET_DURATION_MS, 0);
  if fMaxPacketDurationMs > 0 then
  begin
    fMaxDataBufferSize := TOpus.MinBufferSizeFloat(aProps.Frequency,
                                                   aProps.Channels,
                                                   fMaxPacketDurationMs);
  end else
  begin
    fMaxPacketDurationMs := TOpus.FrameSizeToTime(aProps.GetDefault(TOpus.PROP_MAX_PACKET_SIZE, ofs_120ms));
  end;
  fMaxDataBufferSize := TOpus.MinBufferSizeFloat(aProps.Frequency,
                                                 aProps.Channels,
                                                 fMaxPacketDurationMs);
  fPacketHeaderType := aProps.GetDefault(TOpus.PROP_HEADER_TYPE, ophState);
  aComplexity := aProps.Quality;
  if aComplexity < 1.0 then aComplexity := aComplexity * 10.0;
  if aComplexity < 0 then aComplexity := 0;
  if aComplexity > 10 then aComplexity := 10;

  fEncoder := TOpusEncoder.Create(aProps.Frequency, aProps.Channels, aApp);
  fEncoder.SetBitrate(aBitrate);
  fEncoder.SetMode(aMode);
  fEncoder.SetComplexity(Round(aComplexity));

  fRepacker := TOpusRepacketizer.Create;
  fRepackerDurationMs := 0;

  fBuffers := TFastPointerCollection.Create;

  FOnPacketWriteHeader := @InternalWriteHeader;
  fLastDuration := ofs_Error;
end;

procedure TOpusStreamEncoder.Initialize(aStream : TStream;
  aProp : ISoundEncoderProps);
begin
  InitStream(TOGLSound.NewDataStream(aStream, [sdpForceNotSeekable, sdpWriteOnly]));
  Init(aProp, nil);
end;

procedure TOpusStreamEncoder.Done;
begin
  if Assigned(fEncoder) then
      FreeAndNil(fEncoder);
  if Assigned(fRepacker) then
    FreeAndNil(fRepacker);
  if Assigned(fBuffers) then
    FreeAndNil(fBuffers);
end;

function TOpusStreamEncoder.GetSampleSize : TSoundSampleSize;
begin
  Result := ss16bit;
end;

function TOpusStreamEncoder.GetBitrate : Cardinal;
begin
  Result := FEncoder.GetBitrate;
end;

function TOpusStreamEncoder.GetChannels : Cardinal;
begin
  Result := FEncoder.Channels;
end;

function TOpusStreamEncoder.GetFrequency : Cardinal;
begin
  Result := FEncoder.Frequency;
end;

function TOpusStreamEncoder.GetMode : TSoundEncoderMode;
begin
  Result := FEncoder.GetMode;
end;

function TOpusStreamEncoder.GetQuality : Single;
begin
  Result := FEncoder.GetComplexity;
end;

function TOpusStreamEncoder.GetVersion : Integer;
begin
  Result := FEncoder.GetVersion;
end;

procedure TOpusStreamEncoder.SetStream(aStream : TStream);
begin
  (DataStream as TSoundDataStream).Stream := aStream;
end;

function TOpusStreamEncoder.WriteFrame(aPCM : Pointer;
  aCount : TOpusFrameSize; isfloat : Boolean) : Integer;
var
  len, max_len : Integer;
  dur : Single;
  buf : Pointer;
begin
  if aCount = ofs_Error then Exit(0);

  dur := TOpus.FrameSizeToTime(aCount);
  if (Round(dur + fRepackerDurationMs) > fMaxPacketDurationMs) or
    (fLastDuration <> aCount) then
  begin
    PushPacket;
    fLastDuration := aCount;
  end;

  max_len := fEncoder.FrameSizeToBytes(aCount, isfloat);
  buf := GetMem(max_len);
  fBuffers.Add(buf);

  if isfloat then
    len := fEncoder.EncodeFrameFloat(aPCM, aCount, buf, max_len)
  else
    len := fEncoder.EncodeFrameInt16(aPCM, aCount, buf, max_len);

  fRepacker.Cat(buf, len);

  fRepackerDurationMs := fRepackerDurationMs + dur;

  Result := fEncoder.FrameSizeToSamples(aCount);
end;

procedure TOpusStreamEncoder.PushPacket;
var
  buf : Pointer;
  len : integer;
begin
  if fBuffers.Count > 0 then
  begin
    buf := GetMem(fMaxDataBufferSize);
    try
      len := fRepacker.OutAll(buf, fMaxDataBufferSize);
      fRepackerDurationMs := 0;

      if len > 0 then
      begin
        WritePacketHeader(len);
        DataStream.DoWrite(buf, len);
      end;

      fRepacker.ReInit;
    finally
      FreeMemAndNil(buf);
    end;

    fBuffers.Clear;
  end;
end;

procedure TOpusStreamEncoder.WritePacketHeader(packetLen : Integer);
begin
  if Assigned(FOnPacketWriteHeader) then
    FOnPacketWriteHeader(Self, packetLen);
end;

procedure TOpusStreamEncoder.SetOnPacketWriteHeader(
  AValue : TOpusPacketWriteHeader);
begin
  if FOnPacketWriteHeader = AValue then Exit;
  FOnPacketWriteHeader := AValue;
  fPacketHeaderType := ophCustom;
end;

procedure TOpusStreamEncoder.InternalWriteHeader(Sender : TOpusStreamEncoder;
  packetLen : Integer);
var
  header : Pointer;
  header_size : Integer;
begin
  case fPacketHeaderType of
    ophFinalRange : begin
      header_size := Sizeof(TOpusPacketHeaderRange);
      header := GetMem(header_size);
      with POpusPacketHeaderRange(header)^ do
      begin
        len := packetLen;
        enc_range := fEncoder.FinalRange;
      end;
    end;
    ophSimple : begin
      header_size := Sizeof(TOpusPacketHeaderSimple);
      header := GetMem(header_size);
      POpusPacketHeaderSimple(header)^.len := packetLen;
    end;
    ophState : begin
      header_size := Sizeof(TOpusPacketHeaderState);
      header := GetMem(header_size);
      with POpusPacketHeaderState(header)^ do
      begin
        len := packetLen;
        channels := fEncoder.Channels;
        freq_khz := fEncoder.Frequency div 1000;
      end;
    end;
    else
    begin
      header := nil;
      header_size := 0;
    end;
  end;
  if header_size > 0 then
  begin
    DataStream.DoWrite(header, header_size);
    FreeMemAndNil(header);
  end;
end;

constructor TOpusStreamEncoder.Create(aStream : TStream;
  aProps : ISoundEncoderProps);
begin
  Initialize(aStream, aProps);
end;

destructor TOpusStreamEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusStreamEncoder.WriteInt16(aPCM : Pointer; aCount : TOpusFrameSize
  ) : Integer;
begin
  Result := WriteFrame(aPCM, aCount, false);
end;

function TOpusStreamEncoder.WriteFloat(aPCM : Pointer; aCount : TOpusFrameSize
  ) : Integer;
begin
  Result := WriteFrame(aPCM, aCount, true);
end;

function TOpusStreamEncoder.WriteSamplesInt16(aPCM : Pointer; aCount : Integer
  ) : Integer;
begin
  Result := WriteFrame(aPCM, fEncoder.SamplesToFrameSize(aCount), false);
end;

function TOpusStreamEncoder.WriteSamplesFloat(aPCM : Pointer; aCount : Integer
  ) : Integer;
begin
  Result := WriteFrame(aPCM, fEncoder.SamplesToFrameSize(aCount), true);
end;

function TOpusStreamEncoder.WriteDataInt16(aPCM : Pointer; aBytes : Integer
  ) : Integer;
begin
  Result := WriteFrame(aPCM, fEncoder.BytesToFrameSize(aBytes, false), false);
end;

function TOpusStreamEncoder.WriteDataFloat(aPCM : Pointer; aBytes : Integer
  ) : Integer;
begin
  Result := WriteFrame(aPCM, fEncoder.BytesToFrameSize(aBytes, true), true);
end;

function TOpusStreamEncoder.Comments : ISoundComment;
begin
  Result := nil;
end;

function TOpusStreamEncoder.WriteData(Buffer : Pointer;
  Count : ISoundFrameSize; Par : Pointer) : ISoundFrameSize;
var
  Sz, Total : Integer;
begin
  Total := Count.AsSamples;
  Result := TOGLSound.NewEmptyFrame(Count);
  While Total > 0 do
  begin
    Sz := WriteFrame(@(PByte(Buffer)[Result.AsBytes]),
                     fEncoder.SamplesToFrameSize(Total),
                           Count.SampleSize in [ss32bit, ssFloat]);

    if Sz = 0 then Break;

    Result.IncSamples(Sz);
    Dec(Total, Sz);
  end;
end;

procedure TOpusStreamEncoder.Close(Par : Pointer);
begin
  PushPacket;
end;

procedure TOpusStreamEncoder.Flush(Par : Pointer);
begin
  PushPacket;
end;

function TOpusStreamEncoder.Ready : Boolean;
begin
  Result := Assigned(fEncoder);
end;

{ TOpusFrames }

procedure TOpusFrames.Init(aData : PPointer; aSizes : PInteger; aCnt : Integer);
begin
  fFrames := pOpusFrames(aData);
  fSizes := pOpusFrameSizes(aSizes);
  fCount := aCnt;
end;

constructor TOpusFrames.Create(aData : PPointer; aSizes : PInteger;
  aCnt : Integer);
begin
  Init(aData, aSizes, aCnt);
end;

function TOpusFrames.Data(aIndex : Integer) : Pointer;
begin
  Result := fFrames^[aIndex];
end;

function TOpusFrames.Size(aIndex : Integer) : Integer;
begin
  Result := fSizes^[aIndex];
end;

function TOpusFrames.Count : Integer;
begin
  Result := fCount;
end;

{ TOpusRepacketizer }

procedure TOpusRepacketizer.Init;
begin
  fRef := opus_repacketizer_create;
end;

procedure TOpusRepacketizer.Done;
begin
  if assigned(fRef) then
    opus_repacketizer_destroy(fRef);
end;

function TOpusRepacketizer.Ref : pOpusRepacketizer;
begin
  Result := fRef;
end;

constructor TOpusRepacketizer.Create;
begin
  Init;
end;

destructor TOpusRepacketizer.Destroy;
begin
  Done;
  inherited Destroy;
end;

procedure TOpusRepacketizer.ReInit;
begin
  if Assigned(fRef) then
    fRef := opus_repacketizer_init(fRef) else
    Init;
end;

procedure TOpusRepacketizer.Cat(aData : Pointer; aLen : Integer);
var cRes : Integer;
begin
  cRes := opus_repacketizer_cat(fRef, aData, aLen);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

function TOpusRepacketizer.OutRange(aBegin, aEnd : Integer; aBuffer : Pointer;
  aMaxLen : Integer) : integer;
begin
  Result := opus_repacketizer_out_range(fRef, aBegin, aEnd, aBuffer, aMaxLen);
  if Result < 0 then
    raise EOpus.Create(Result);
end;

function TOpusRepacketizer.OutAll(aBuffer : Pointer; aMaxLen : Integer
  ) : integer;
begin
  Result := opus_repacketizer_out(fRef, aBuffer, aMaxLen);
  if Result < 0 then
    raise EOpus.Create(Result);
end;

function TOpusRepacketizer.NumberOfFrames : Integer;
begin
  Result := opus_repacketizer_get_nb_frames(fRef);
end;

{ EOpus }

constructor EOpus.Create(aError : Integer);
var S : String;
begin
  if aError = OPUS_OK then
    S := cesOPUS_OK else
  if aError = OPUS_BAD_ARG then
    S := cesOPUS_BAD_ARG else
  if aError = OPUS_BUFFER_TOO_SMALL then
    S := cesOPUS_BUFFER_TOO_SMALL else
  if aError = OPUS_INTERNAL_ERROR then
    S := cesOPUS_INTERNAL_ERROR else
  if aError = OPUS_INVALID_PACKET then
    S := cesOPUS_INVALID_PACKET else
  if aError = OPUS_UNIMPLEMENTED then
    S := cesOPUS_UNIMPLEMENTED else
  if aError = OPUS_INVALID_STATE then
    S := cesOPUS_INVALID_STATE else
  if aError = OPUS_ALLOC_FAIL then
    S := cesOPUS_ALLOC_FAIL else
    S := '';
  if Length(s) > 0 then
    inherited CreateFmt(cOpusFullError, [aError, S]) else
    inherited CreateFmt(cOpusError, [aError]);
end;

{ TOpusEncoder }

procedure TOpusEncoder.Init(afreq : Cardinal; achannels : Cardinal;
  aApp : TOpusEncApp);
var
  cError : Integer;
begin
  fFreq := afreq;
  fChannels := achannels;
  fRef := opus_encoder_create(afreq, achannels,
                                     TOpus.EnumToNativeAppSpec(aApp), @cError);
  if cError <> 0 then
    raise EOpus.Create(cError);
end;

procedure TOpusEncoder.Done;
begin
  if Assigned(fRef) then
    opus_encoder_destroy(fRef);
end;

function TOpusEncoder.Ref : pOpusEncoder;
begin
  Result := fRef;
end;

constructor TOpusEncoder.Create(afreq : Cardinal; achannels : Cardinal;
  aApp : TOpusEncApp);
begin
  inherited Create(afreq, achannels);
  Init(afreq, achannels, aApp);
end;

destructor TOpusEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusEncoder.FinalRange : Integer;
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_get_final_range(fRef, @Result);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

function TOpusEncoder.EncodeFrameInt16(Buffer : Pointer; Fsz : TOpusFrameSize;
  Data : Pointer; MaxDataSz : Integer) : Integer;
begin
  Result := opus_encode(fRef, Buffer, FrameSizeToSamples(fsz), Data, MaxDataSz);
  if Result < 0 then
    raise EOpus.Create(Result);
end;

function TOpusEncoder.EncodeFrameFloat(Buffer : Pointer; Fsz : TOpusFrameSize;
  Data : Pointer; MaxDataSz : Integer) : Integer;
begin
  Result := opus_encode_float(fRef, Buffer, FrameSizeToSamples(fsz), Data, MaxDataSz);
  if Result < 0 then
    raise EOpus.Create(Result);
end;

function TOpusEncoder.GetBitrate : Integer;
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_get_bitrate(fRef, @Result);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

function TOpusEncoder.GetMode : TSoundEncoderMode;
var cRes, aMode : Integer;
begin
  cRes := opus_encoder_ctl_get_bitrate(fRef, @aMode);
  if cRes < 0 then
    raise EOpus.Create(cRes);
  if aMode = 0 then
    Result := oemCBR else
    Result := oemVBR;
end;

function TOpusEncoder.GetComplexity : Integer;
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_get_complexity(fRef, @Result);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

function TOpusEncoder.GetVersion : Integer;
begin
  Result := ope_get_abi_version;
end;

procedure TOpusEncoder.SetBitrate(bitrate : Integer);
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_set_bitrate(fRef, bitrate);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

procedure TOpusEncoder.SetBandwidth(bandwidth : Integer);
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_set_bandwidth(fRef, bandwidth);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

procedure TOpusEncoder.SetComplexity(complex : Integer);
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_set_complexity(fRef, complex);
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

procedure TOpusEncoder.SetSignal(sig : TOpusEncSignal);
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_set_signal(fRef, TOpus.EnumToNativeSig(sig));
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

procedure TOpusEncoder.SetApplication(app : TOpusEncApp);
var cRes : Integer;
begin
  cRes := opus_encoder_ctl_set_app(fRef, TOpus.EnumToNativeAppSpec(app));
  if cRes < 0 then
    raise EOpus.Create(cRes);
end;

procedure TOpusEncoder.SetMode(mode : TSoundEncoderMode);
var cRes : Integer;
begin
  case mode of
    oemVBR : begin
        cRes := opus_encoder_ctl_set_vbr(fRef, opus_int32(1));
        if cRes < 0 then
          raise EOpus.Create(cRes);
        cRes := opus_encoder_ctl_set_vbr_constraint(fRef, opus_int32(0));
        if cRes < 0 then
          raise EOpus.Create(cRes);
      end;
    oemCBR : begin
      cRes := opus_encoder_ctl_set_vbr(fRef, opus_int32(0));
      if cRes < 0 then
        raise EOpus.Create(cRes);
    end;
  end;
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

procedure TRefOpusDecComment.SetNativeVendor(v : PChar);
begin
  if Assigned(fREf^.vendor) then FreeMemAndNil(fREf^.vendor);
  fREf^.vendor := pcchar(v);
end;

function TRefOpusDecComment.GetNativeVendor : PChar;
begin
  Result := pchar(fREf^.vendor);
end;

function TRefOpusDecComment.GetNativeComment(index : integer) : PChar;
begin
  Result := pchar(fREf^.user_comments[index]);
end;

function TRefOpusDecComment.GetNativeCommentLength(index : integer) : Int32;
begin
  Result := fREf^.comment_lengths[index];
end;

function TRefOpusDecComment.GetNativeCommentCount : Int32;
begin
  Result := fREf^.comments;
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
  inherited Add(comment);
end;

procedure TRefOpusDecComment.AddTag(const tag, value : String);
begin
  opus_tags_add(fRef, pcchar( PChar(tag) ), pcchar( PChar(value) ));
  inherited AddTag(tag, value);
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
  Result := 48000; //possible issue, should be: fRef^.input_sample_rate;
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

function TOpusFile.InitEncoder(aProps : ISoundEncoderProps;
  aComments : ISoundComment) : ISoundEncoder;
begin
  Result := TOpus.NewOggStreamEncoder(Stream, aProps,
                                      aComments as ISoundComment) as ISoundEncoder;
end;

function TOpusFile.InitDecoder : ISoundDecoder;
begin
  Result := TOpus.NewOggStreamDecoder(Stream, DataLimits) as ISoundDecoder;
end;

{ TOpusOggDecoder }

procedure TOpusOggDecoder.Init;
var cError : Integer;
begin
  fdec_callbacks.read := @opd_read_func;
  if DataStream.Seekable then
  begin
    fdec_callbacks.seek := @opd_seek_func;
    fdec_callbacks.tell := @opd_tell_func;
  end else
  begin
    fdec_callbacks.seek := nil;
    fdec_callbacks.tell := nil;
  end;
  fdec_callbacks.close := @opd_close_func;

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
  Result := op_bitrate(fRef, -1);
end;

function TOpusOggDecoder.Ref : pOggOpusFile;
begin
  Result := Fref;
end;

constructor TOpusOggDecoder.Create;
begin
  Init;
end;

destructor TOpusOggDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusOggDecoder.Comments : ISoundComment;
begin
  Result := fComm;
end;

function TOpusOggDecoder.ReadData(Buffer : Pointer; Count : ISoundFrameSize;
  Par : Pointer) : ISoundFrameSize;
begin
  Result := TOGLSound.NewEmptyFrame(Count);
  Result.IncSamples(op_read(fRef, Buffer, Count.AsSamples, nil));
end;

procedure TOpusOggDecoder.ResetToStart;
begin
  op_pcm_seek(fRef, 0);
end;

procedure TOpusOggDecoder.RawSeek(pos : Int64);
begin
  if DataStream.Seekable then
    op_raw_seek(fRef, pos)
  else
    inherited RawSeek(pos);
end;

procedure TOpusOggDecoder.SampleSeek(pos : Integer);
begin
  if DataStream.Seekable then
    op_pcm_seek(fRef, pos)
  else
    inherited SampleSeek(pos);
end;

procedure TOpusOggDecoder.TimeSeek(pos : Double);
var v : int64;
begin
  if DataStream.Seekable then
  begin
    v := Round(pos * GetFrequency);
    op_pcm_seek(fRef, v)
  end
  else
    inherited TimeSeek(pos);
end;

function TOpusOggDecoder.RawTell : Int64;
begin
  if DataStream.Seekable then
    Result := op_raw_tell(fRef)
  else
    Result := inherited RawTell;
end;

function TOpusOggDecoder.SampleTell : Integer;
begin
  if DataStream.Seekable then
    Result := op_pcm_tell(fRef)
  else
    Result := inherited SampleTell;
end;

function TOpusOggDecoder.TimeTell : Double;
begin
  if DataStream.Seekable then
  begin
    Result := Double(op_pcm_tell(fRef)) / Double(GetFrequency);
  end
  else
    Result := inherited TimeTell;
end;

function TOpusOggDecoder.RawTotal : Int64;
begin
  if DataStream.Seekable then
  begin
    Result := op_raw_total(fRef, -1);
  end
  else
    Result := inherited RawTotal;
end;

function TOpusOggDecoder.SampleTotal : Integer;
begin
  if DataStream.Seekable then
  begin
    Result := op_pcm_total(fRef, -1);
  end
  else
    Result := inherited SampleTotal;
end;

function TOpusOggDecoder.TimeTotal : Double;
begin
  if DataStream.Seekable then
  begin
    Result := Double(op_pcm_total(fRef, -1)) / Double(GetFrequency);
  end
  else
    Result := inherited TimeTotal;
end;

function TOpusOggDecoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TOpusOggEncoder }

procedure TOpusOggEncoder.InitEncoder(ope_error : PInteger);
var
  fenc_callbacks : OpusEncCallbacks;
begin
  fenc_callbacks.close := @ope_close;
  fenc_callbacks.write := @ope_write;
  fRef := ope_encoder_create_callbacks(@fenc_callbacks,
                                         Self,
                                         fComm.Ref,
                                         fFreq,
                                         fChannels,
                                         0,
                                         ope_error);
end;

procedure TOpusOggEncoder.Init(aProps : ISoundEncoderProps;
  aComments : ISoundComment);
var
  ope_error : integer;
  ctl_serial : opus_int32;
  q : Single;
begin
  fChannels := aProps.Channels;
  fFreq := aProps.Frequency;

  if Assigned(aComments) then
    fComm := aComments as ISoundComment else
    fComm := TOpus.NewEncComment;

  InitEncoder(@ope_error);
  if ope_error = 0 then
  begin
    ctl_serial := Abs(Random(Int64(Now)));
    ope_encoder_ctl_set_serialno(fRef, ctl_serial);

    q := aProps.Quality;
    if q < 1 then q := q * 10.0;

    SetBitrate(aProps.Bitrate);
    SetMode(aProps.Mode);
    SetQuality(q);
    SetDecisionDelay(aProps.GetDefault(TOpus.PROP_DECISION_DELAY, 0));
    SetCommentPadding(aProps.GetDefault(TOpus.PROP_COMMENT_PADDING, 4));
  end else
    raise EOpus.CreateFmt(cOpusError, [ope_error]);
end;

procedure TOpusOggEncoder.Done;
begin
  if Assigned(fRef) then
    ope_encoder_destroy(fRef);
  fComm := nil;
end;

function TOpusOggEncoder.GetSampleSize : TSoundSampleSize;
begin
  Result := ss16bit;
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
  Result := v;
end;

function TOpusOggEncoder.GetQuality : Single;
var
  v : opus_int32;
begin
  ope_encoder_ctl_get_complexity(fRef, @v);
  Result := Single(v) / 10.0;
end;

function TOpusOggEncoder.GetMode : TSoundEncoderMode;
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
  ope_encoder_ctl_set_bitrate(fRef, opus_int32(AValue));
end;

procedure TOpusOggEncoder.SetMode(AValue : TSoundEncoderMode);
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
  ctl_complex := Round(AValue);
  if ctl_complex > 10 then ctl_complex := 10;
  if ctl_complex < 0  then ctl_complex := 0;
  ope_encoder_ctl_set_complexity(fRef, ctl_complex);
end;

procedure TOpusOggEncoder.SetDecisionDelay(AValue : Integer);
begin
  ope_encoder_ctl_set_decision_delay(fRef, AValue);
end;

procedure TOpusOggEncoder.SetCommentPadding(AValue : Integer);
begin
  ope_encoder_ctl_set_comment_padding(fRef, AValue);
end;

function TOpusOggEncoder.Ref : pOggOpusEnc;
begin
  Result := fRef;
end;

constructor TOpusOggEncoder.Create(aProps : ISoundEncoderProps;
  aComments : ISoundComment);
begin
  Init(aProps, aComments);
end;

destructor TOpusOggEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TOpusOggEncoder.Comments : ISoundComment;
begin
  Result := fComm;
end;

function TOpusOggEncoder.WriteData(Buffer : Pointer; Count : ISoundFrameSize;
  Par : Pointer) : ISoundFrameSize;
var res : Integer;
begin
  res := ope_encoder_write(fRef, Buffer, Count.AsSamples);
  if res = 0 then
    Result := TOGLSound.NewFrame(Count)
  else
    Result := TOGLSound.NewErrorFrame;
end;

procedure TOpusOggEncoder.WriteHeader(Par : Pointer);
begin
  ope_encoder_flush_header(fRef);
end;

procedure TOpusOggEncoder.Close(Par : Pointer);
begin
  ope_encoder_drain(fRef);
end;

procedure TOpusOggEncoder.Flush(Par : Pointer);
begin
  //ope_encoder_drain(fRef);
end;

procedure TOpusOggEncoder.SetStream(aStream : TStream);
begin
  (DataStream as TSoundDataStream).Stream := aStream;
end;

function TOpusOggEncoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TUniqOpusEncComment }

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

function TRefOpusEncComment.GetVendor : String;
begin
  Result := '';
end;

procedure TRefOpusEncComment.SetVendor(const {%H-}S : String);
begin
  // do nothing
end;

function TRefOpusEncComment.Ref : Pointer;
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

function TRefOpusEncComment.TagsCount : Integer;
begin
  Result := 0;
end;

function TRefOpusEncComment.GetTag(index : integer) : String;
begin
  Result := '';
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

class function TOpus.NewEncComment(src : ISoundComment) : IOpusEncComment;
begin
  Result := TUniqOpusEncComment.CreateFromInterface(src) as IOpusEncComment;
end;

class function TOpus.NewEncComment(src : IOpusEncComment) : IOpusEncComment;
begin
  Result := TUniqOpusEncComment.Create(src) as IOpusEncComment;
end;

class function TOpus.RefEncComment(src : pOggOpusComments) : IOpusEncComment;
begin
  Result := TRefOpusEncComment.Create(src) as IOpusEncComment;
end;

class function TOpus.NewDecComment : ISoundComment;
begin
  Result := TUniqOpusDecComment.Create as ISoundComment;
end;

class function TOpus.NewDecComment(src : ISoundComment) : ISoundComment;
begin
  Result := TUniqOpusDecComment.CreateFromInterface(src) as ISoundComment;
end;

class function TOpus.RefDecComment(src : pOpusTags) : ISoundComment;
begin
  Result := TRefOpusDecComment.Create(src) as ISoundComment;
end;

class function TOpus.RefDecHead(src : pOpusHead) : IOpusDecHead;
begin
  Result := TRefOpusDecHead.Create(src) as IOpusDecHead;
end;

class function TOpus.FrameFromDuration(aFreq : Cardinal; aChannels : Cardinal;
  aDurationMs : TOpusFrameSize; isfloat : Boolean) : ISoundFrameSize;
var
  SS : TSoundSampleSize;
begin
  if isfloat then SS := ssFloat else SS := ss16bit;
  Result := TOGLSound.FrameFromDuration(aFreq, aChannels,
                                               SS,
                                               FrameSizeToTime(aDurationMs));
end;

class function TOpus.TimeToHighFrameSize(dur : Single) : TOpusFrameSize;
begin
  if dur > 120.0 then
    Result := ofs_Error else
  if dur > 100.0 then
    Result := ofs_120ms else
  if dur > 80.0 then
    Result := ofs_100ms else
  if dur > 60.0 then
    Result := ofs_80ms else
  if dur > 40.0 then
    Result := ofs_60ms else
  if dur > 20.0 then
    Result := ofs_40ms else
  if dur > 10.0 then
    Result := ofs_20ms else
  if dur > 5.0 then
    Result := ofs_10ms else
  if dur > 2.5 then
    Result := ofs_5ms else
    Result := ofs_2_5ms;
end;

class function TOpus.TimeToLowFrameSize(dur : Single) : TOpusFrameSize;
begin
  if dur >= 120.0 then
    Result := ofs_120ms else
  if dur >= 100.0 then
    Result := ofs_100ms else
  if dur >= 80.0 then
    Result := ofs_80ms else
  if dur >= 60.0 then
    Result := ofs_60ms else
  if dur >= 40.0 then
    Result := ofs_40ms else
  if dur >= 20.0 then
    Result := ofs_20ms else
  if dur >= 10.0 then
    Result := ofs_10ms else
  if dur >= 5.0 then
    Result := ofs_5ms else
  if dur >= 2.5 then
    Result := ofs_2_5ms else
    Result := ofs_Error;
end;

class function TOpus.FrameSizeToTime(fz : TOpusFrameSize) : Single;
begin
  case fz of
    ofs_2_5ms : Result := 2.5;
    ofs_5ms : Result := 5.0;
    ofs_10ms : Result := 10.0;
    ofs_20ms : Result := 20.0;
    ofs_40ms : Result := 40.0;
    ofs_60ms : Result := 60.0;
    ofs_80ms : Result := 80.0;
    ofs_100ms : Result := 100.0;
    ofs_120ms : Result := 120.0;
  else
    Result := 0;
  end;
end;

class function TOpus.NativeFrameSizeToEnum(fz : Integer) : TOpusFrameSize;
begin
  case fz of
    OPUS_FRAMESIZE_2_5_MS : result := ofs_2_5ms;
    OPUS_FRAMESIZE_5_MS : result :=   ofs_5ms;
    OPUS_FRAMESIZE_10_MS : result :=  ofs_10ms;
    OPUS_FRAMESIZE_20_MS : result :=  ofs_20ms;
    OPUS_FRAMESIZE_40_MS : result :=  ofs_40ms;
    OPUS_FRAMESIZE_60_MS : result :=  ofs_60ms;
    OPUS_FRAMESIZE_80_MS : result :=  ofs_80ms;
    OPUS_FRAMESIZE_100_MS : result := ofs_100ms;
    OPUS_FRAMESIZE_120_MS : result := ofs_120ms;
  else
    result := ofs_Error;
  end;
end;

class function TOpus.EnumToNativeFrameSize(fz : TOpusFrameSize) : Integer;
begin
  case fz of
    ofs_2_5ms : result := OPUS_FRAMESIZE_2_5_MS;
    ofs_5ms   : result :=   OPUS_FRAMESIZE_5_MS;
    ofs_10ms  : result :=  OPUS_FRAMESIZE_10_MS;
    ofs_20ms  : result :=  OPUS_FRAMESIZE_20_MS;
    ofs_40ms  : result :=  OPUS_FRAMESIZE_40_MS;
    ofs_60ms  : result :=  OPUS_FRAMESIZE_60_MS;
    ofs_80ms  : result :=  OPUS_FRAMESIZE_80_MS;
    ofs_100ms : result := OPUS_FRAMESIZE_100_MS;
    ofs_120ms : result := OPUS_FRAMESIZE_120_MS;
  else
    result := OPUS_FRAMESIZE_ARG;
  end;
end;

class function TOpus.NativeBandWidthToEnum(fz : Integer) : TOpusBandWidth;
begin
  case fz of
    OPUS_BANDWIDTH_NARROWBAND : result := obwNarrowBand;
    OPUS_BANDWIDTH_MEDIUMBAND : result := obwMediumBand;
    OPUS_BANDWIDTH_WIDEBAND :   result := obwWideBand;
    OPUS_BANDWIDTH_SUPERWIDEBAND : result := obwSuperWideBand;
    OPUS_BANDWIDTH_FULLBAND : result :=  obwFullBand;
    OPUS_AUTO               : Result := obwAuto;
  else
    Result := obwError;
  end;
end;

class function TOpus.EnumToNativeBandWidth(fz : TOpusBandWidth) : Integer;
begin
  case fz of
    obwNarrowBand : result := OPUS_BANDWIDTH_NARROWBAND;
    obwMediumBand   : result := OPUS_BANDWIDTH_MEDIUMBAND;
    obwWideBand  : result := OPUS_BANDWIDTH_WIDEBAND;
    obwSuperWideBand  : result := OPUS_BANDWIDTH_SUPERWIDEBAND;
    obwFullBand  : result := OPUS_BANDWIDTH_FULLBAND;
  else
    result := OPUS_AUTO;
  end;
end;

class function TOpus.NativeAppSpecToEnum(fz : Integer) : TOpusEncApp;
begin
  case fz of
    OPUS_APPLICATION_VOIP : result := oeaVOIP;
    OPUS_APPLICATION_RESTRICTED_LOWDELAY : result := oeaLowDelay;
  else
    Result := oeaAudio;
  end;
end;

class function TOpus.EnumToNativeAppSpec(fz : TOpusEncApp) : Integer;
begin
  case fz of
    oeaAudio : result := OPUS_APPLICATION_AUDIO;
    oeaVOIP   : result := OPUS_APPLICATION_VOIP;
    oeaLowDelay  : result := OPUS_APPLICATION_RESTRICTED_LOWDELAY;
  else
    result := OPUS_APPLICATION_AUDIO;
  end;
end;

class function TOpus.NativeSigToEnum(fz : Integer) : TOpusEncSignal;
begin
  case fz of
    OPUS_SIGNAL_MUSIC : result := oesMusic;
    OPUS_SIGNAL_VOICE : result := oesVoice;
  else
    result := oesAuto;
  end;
end;

class function TOpus.EnumToNativeSig(fz : TOpusEncSignal) : Integer;
begin
  case fz of
    oesMusic : result := OPUS_SIGNAL_MUSIC;
    oesVoice : result := OPUS_SIGNAL_VOICE;
  else
    result := OPUS_AUTO;
  end;
end;

class function TOpus.HighFrameSizeInt16(aFreq, aChannels : Cardinal;
  aBytes : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aBytes) * 1000.0 / single(aChannels * aFreq * Sizeof(cint16));
  Result := TimeToHighFrameSize(dur);
end;

class function TOpus.HighFrameSizeFloat(aFreq, aChannels : Cardinal;
  aBytes : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aBytes) * 1000.0 / single(aChannels * aFreq * Sizeof(cfloat));
  Result := TimeToHighFrameSize(dur);
end;

class function TOpus.LowFrameSizeInt16(aFreq, aChannels : Cardinal;
  aBytes : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aBytes) * 1000.0 / single(aChannels * aFreq * Sizeof(cint16));
  Result := TimeToLowFrameSize(dur);
end;

class function TOpus.LowFrameSizeFloat(aFreq, aChannels : Cardinal;
  aBytes : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aBytes) * 1000.0 / single(aChannels * aFreq * Sizeof(cfloat));
  Result := TimeToLowFrameSize(dur);
end;

class function TOpus.HighFrameSizeSamples(aFreq : Cardinal;
  aSamples : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aSamples) * 1000.0 / single({aChannels * }aFreq);
  Result := TimeToHighFrameSize(dur);
end;

class function TOpus.LowFrameSizeSamples(aFreq : Cardinal;
  aSamples : Integer) : TOpusFrameSize;
var
  dur : Single;
begin
  dur := single(aSamples) * 1000.0 / single({aChannels * }aFreq);
  Result := TimeToLowFrameSize(dur);
end;

class function TOpus.MinBufferSizeInt16(aFreq, aChannels : Cardinal;
  aFs : TOpusFrameSize) : Integer;
begin
  Result := Round(FrameSizeToTime(aFs) / 1000.0 * aChannels * aFreq * Sizeof(cint16));
end;

class function TOpus.MinBufferSizeFloat(aFreq, aChannels : Cardinal;
  aFs : TOpusFrameSize) : Integer;
begin
  Result := Round(FrameSizeToTime(aFs) / 1000.0 * aChannels * aFreq * Sizeof(cfloat));
end;

class function TOpus.MinBufferSizeInt16(aFreq, aChannels : Cardinal;
  aDuration : Single) : Integer;
begin
  Result := Round(aDuration / 1000.0 * aChannels * aFreq * Sizeof(cint16));
end;

class function TOpus.MinBufferSizeFloat(aFreq, aChannels : Cardinal;
  aDuration : Single) : Integer;
begin
  Result := Round(aDuration / 1000.0 * aChannels * aFreq * Sizeof(cfloat));
end;

class function TOpus.SamplesCount(aFreq : Cardinal; aFs : TOpusFrameSize
  ) : Integer;
begin
  case aFs of
    ofs_2_5ms : Result := 25;
    ofs_5ms :   Result := 50;
    ofs_10ms :  Result := 100;
    ofs_20ms :  Result := 200;
    ofs_40ms :  Result := 400;
    ofs_60ms :  Result := 600;
    ofs_80ms :  Result := 800;
    ofs_100ms : Result := 1000;
    ofs_120ms : Result := 1200;
  else
    Result := 0;
  end;
  Result := aFreq div 1000 * Result div 10;
end;

{class function TOpus.NewDecPicture : IOpusDecPicture;
begin
  Result := TUniqOpusDecPicture.Create as IOpusDecPicture;
end; }

class function TOpus.NewOggStreamEncoder(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : ISoundComment) : ISoundStreamEncoder;
begin
  Result := TOpusOggStreamEncoder.Create(aStream, aProps, aComments);
end;

class function TOpus.NewAltOggStreamEncoder(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : ISoundComment) : ISoundStreamEncoder;
begin
  Result := TOpusAltOggStreamEncoder.Create(aStream, aProps, aComments);
end;

class function TOpus.NewOggStreamDecoder(aStream : TStream;
  aDataLimits : TSoundDataLimits) : ISoundStreamDecoder;
begin
  Result := TOpusOggStreamDecoder.Create(aStream, aDataLimits);
end;

class function TOpus.NewStreamEncoder(aStream : TStream;
  aProps : ISoundEncoderProps) : ISoundStreamEncoder;
begin
  Result := TOpusStreamEncoder.Create(aStream, aProps);
end;

class function TOpus.NewStreamDecoder(aStream : TStream; aFreq,
  aChannels : Cardinal) : ISoundStreamDecoder;
begin
  Result := TOpusStreamDecoder.Create(aStream, aFreq, aChannels);
end;

class function TOpus.NewStreamDecoder(aStream : TStream;
  aHeaderType : TOpusPacketHeaderType;
  aOnReadHeader : TOpusPacketReadHeader) : ISoundStreamDecoder;
begin
  Result := TOpusStreamDecoder.Create(aStream, aHeaderType, aOnReadHeader);
end;

class function TOpus.NewStreamDecoder(aStream : TStream; aProps : ISoundProps
  ) : ISoundStreamDecoder;
var
  aFreq, aChannels : Integer;
  aHeaderType : TOpusPacketHeaderType;
  aOnReadHeader : POpusPacketReadHeaderRef;
begin
  if not Assigned(aProps) then Exit(nil);

  aFreq := aProps.GetDefault(TOGLSound.PROP_FREQUENCY, 0);
  aChannels := aProps.GetDefault(TOGLSound.PROP_CHANNELS, 0);

  if (aFreq > 0) and (aChannels > 0) then
  begin
    Result := TOpus.NewStreamDecoder(aStream, aFreq, aChannels);
    if aProps.HasProp(TOpus.PROP_HEADER_TYPE) then
    begin
      aHeaderType := aProps.Get(TOpus.PROP_HEADER_TYPE);
      (Result as TOpusStreamDecoder).PacketHeaderType := aHeaderType;
    end;
  end else
  begin
    aOnReadHeader := POpusPacketReadHeaderRef(PtrUInt(aProps.GetDefault(TOpus.PROP_HEADER_CALLBACK, nil)));
    if Assigned(aOnReadHeader) then
    begin
      Result := TOpus.NewStreamDecoder(aStream, ophCustom, aOnReadHeader^.ref);
    end else
    begin
      aHeaderType := aProps.GetDefault(TOpus.PROP_HEADER_TYPE, ophState);
      Result := TOpus.NewStreamDecoder(aStream, aHeaderType, nil);
    end;
  end;
end;

class procedure TOpus.PcmSoftClip(aBuffer : Pointer; aSamplesCount : Integer;
  aChannels : Cardinal);
var m : Pointer;
begin
  m := GetMem(aChannels * sizeof(cfloat));
  FillByte(m^, aChannels * sizeof(cfloat), 0);
  opus_pcm_soft_clip(aBuffer, aSamplesCount, aChannels, m);
  Freemem(m);
end;

class function TOpus.EncoderVersionString : String;
begin
  Result := StrPas(PChar(ope_get_version_string()));
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

