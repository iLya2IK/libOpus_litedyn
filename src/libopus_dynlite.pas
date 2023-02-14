(******************************************************************************)
(*                             libOpus_dynlite                                *)
(*                   free pascal wrapper around Opus library                  *)
(*                          https://opus-codec.org                            *)
(*                                                                            *)
(* Copyright (c) 2023 Ilya Medvedkov                                          *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the  GNU Lesser General Public License  as published by *)
(* the Free Software Foundation; either version 3 of the License (LGPL v3).   *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.                                          *)
(* See the GNU Lesser General Public License for more details.                *)
(*                                                                            *)
(* A copy of the GNU Lesser General Public License is available on the World  *)
(* Wide Web at <https://www.gnu.org/licenses/lgpl-3.0.html>.                  *)
(*                                                                            *)
(******************************************************************************)

unit libOpus_dynlite;

{$mode objfpc}{$H+}

{$packrecords c}

interface

uses dynlibs, SysUtils, libOGG_dynlite, ctypes;

const
{$if defined(UNIX) and not defined(darwin)}
  OpusDLL: Array [0..2] of string = ('libopus.so', 'libopusenc.so', 'libopusfile.so');
{$ELSE}
{$ifdef WINDOWS}
  OpusDLL: Array [0..2] of string = ('opus.dll', 'opusenc.dll', 'opusfile.dll');
{$endif}
{$endif}

type
  opus_int16 = cint16;
  opus_int32 = cint32;
  opus_int64 = cint64;
  opus_uint32 = cuint32;

  pcint = ^cint;
  pcuchar = ^cuchar;
  ppcuchar = ^pcuchar;
  ppcchar = ^pcchar;
  pfloat = ^cfloat;
  popus_int16 = ^opus_int16;
  popus_int32 = ^opus_int32;
  
  pOpusDecoder = pointer;
  pOpusEncoder = pointer;
  pOpusRepacketizer = pointer;
  pOggOpusComments = pointer;
  pOggOpusEnc = pointer;

const
  OPUS_OK               =  0;
  OPUS_BAD_ARG          = -1;
  OPUS_BUFFER_TOO_SMALL = -2;
  OPUS_INTERNAL_ERROR   = -3;
  OPUS_INVALID_PACKET   = -4;
  OPUS_UNIMPLEMENTED    = -5;
  OPUS_INVALID_STATE    = -6;
  OPUS_ALLOC_FAIL       = -7;

  OPUS_SET_APPLICATION_REQUEST = 4000;
  OPUS_GET_APPLICATION_REQUEST = 4001;
  OPUS_SET_BITRATE_REQUEST = 4002;
  OPUS_GET_BITRATE_REQUEST = 4003;
  OPUS_SET_MAX_BANDWIDTH_REQUEST = 4004;
  OPUS_GET_MAX_BANDWIDTH_REQUEST = 4005;
  OPUS_SET_VBR_REQUEST = 4006;
  OPUS_GET_VBR_REQUEST = 4007;
  OPUS_SET_BANDWIDTH_REQUEST = 4008;
  OPUS_GET_BANDWIDTH_REQUEST = 4009;
  OPUS_SET_COMPLEXITY_REQUEST = 4010;
  OPUS_GET_COMPLEXITY_REQUEST = 4011;
  OPUS_SET_INBAND_FEC_REQUEST = 4012;
  OPUS_GET_INBAND_FEC_REQUEST = 4013;
  OPUS_SET_PACKET_LOSS_PERC_REQUEST = 4014;
  OPUS_GET_PACKET_LOSS_PERC_REQUEST = 4015;
  OPUS_SET_DTX_REQUEST = 4016;
  OPUS_GET_DTX_REQUEST = 4017;
  OPUS_SET_VBR_CONSTRAINT_REQUEST = 4020;
  OPUS_GET_VBR_CONSTRAINT_REQUEST = 4021;
  OPUS_SET_FORCE_CHANNELS_REQUEST = 4022;
  OPUS_GET_FORCE_CHANNELS_REQUEST = 4023;
  OPUS_SET_SIGNAL_REQUEST = 4024;
  OPUS_GET_SIGNAL_REQUEST = 4025;
  OPUS_GET_LOOKAHEAD_REQUEST = 4027;
  OPUS_GET_SAMPLE_RATE_REQUEST = 4029;
  OPUS_GET_FINAL_RANGE_REQUEST = 4031;
  OPUS_GET_PITCH_REQUEST = 4033;
  OPUS_SET_GAIN_REQUEST = 4034;
  OPUS_GET_GAIN_REQUEST = 4045;
  OPUS_SET_LSB_DEPTH_REQUEST = 4036;
  OPUS_GET_LSB_DEPTH_REQUEST = 4037;
  OPUS_GET_LAST_PACKET_DURATION_REQUEST = 4039;
  OPUS_SET_EXPERT_FRAME_DURATION_REQUEST = 4040;
  OPUS_GET_EXPERT_FRAME_DURATION_REQUEST = 4041;
  OPUS_SET_PREDICTION_DISABLED_REQUEST = 4042;
  OPUS_GET_PREDICTION_DISABLED_REQUEST = 4043;
  OPUS_SET_PHASE_INVERSION_DISABLED_REQUEST = 4046;
  OPUS_GET_PHASE_INVERSION_DISABLED_REQUEST = 4047;
  OPUS_GET_IN_DTX_REQUEST = 4049;

  OPUS_AUTO = -1000;
  OPUS_BITRATE_MAX = -1;
  OPUS_APPLICATION_VOIP = 2048;
  OPUS_APPLICATION_AUDIO = 2049;
  OPUS_APPLICATION_RESTRICTED_LOWDELAY = 2051;

  OPUS_SIGNAL_VOICE = 3001;
  OPUS_SIGNAL_MUSIC = 3002;
  OPUS_BANDWIDTH_NARROWBAND = 1101;
  OPUS_BANDWIDTH_MEDIUMBAND = 1102;
  OPUS_BANDWIDTH_WIDEBAND = 1103;
  OPUS_BANDWIDTH_SUPERWIDEBAND = 1104;
  OPUS_BANDWIDTH_FULLBAND = 1105;

  OPUS_FRAMESIZE_ARG = 5000;
  OPUS_FRAMESIZE_2_5_MS = 5001;
  OPUS_FRAMESIZE_5_MS = 5002;
  OPUS_FRAMESIZE_10_MS = 5003;
  OPUS_FRAMESIZE_20_MS = 5004;
  OPUS_FRAMESIZE_40_MS = 5005;
  OPUS_FRAMESIZE_60_MS = 5006;
  OPUS_FRAMESIZE_80_MS = 5007;
  OPUS_FRAMESIZE_100_MS = 5008;
  OPUS_FRAMESIZE_120_MS = 5009;

  OPE_API_VERSION = 0;

  OPE_OK = 0;
  OPE_BAD_ARG = -11;
  OPE_INTERNAL_ERROR = -13;
  OPE_UNIMPLEMENTED = -15;
  OPE_ALLOC_FAIL = -17;

  OPE_CANNOT_OPEN = -30;
  OPE_TOO_LATE = -31;
  OPE_INVALID_PICTURE = -32;
  OPE_INVALID_ICON = -33;
  OPE_WRITE_FAIL = -34;
  OPE_CLOSE_FAIL = -35;

  OPE_SET_DECISION_DELAY_REQUEST = 14000;
  OPE_GET_DECISION_DELAY_REQUEST = 14001;
  OPE_SET_MUXING_DELAY_REQUEST = 14002;
  OPE_GET_MUXING_DELAY_REQUEST = 14003;
  OPE_SET_COMMENT_PADDING_REQUEST = 14004;
  OPE_GET_COMMENT_PADDING_REQUEST = 14005;
  OPE_SET_SERIALNO_REQUEST = 14006;
  OPE_GET_SERIALNO_REQUEST = 14007;
  OPE_SET_PACKET_CALLBACK_REQUEST = 14008;
  OPE_GET_PACKET_CALLBACK_REQUEST = 14009;
  OPE_SET_HEADER_GAIN_REQUEST = 14010;
  OPE_GET_HEADER_GAIN_REQUEST = 14011;
  OPE_GET_NB_STREAMS_REQUEST = 14013;
  OPE_GET_NB_COUPLED_STREAMS_REQUEST = 14015;

  OP_FALSE = (-1);
  OP_EOF = (-2);
  OP_HOLE = (-3);
  OP_EREAD = (-128);
  OP_EFAULT = (-129);
  OP_EIMPL = (-130);
  OP_EINVAL = (-131);
  OP_ENOTFORMAT = (-132);
  OP_EBADHEADER = (-133);
  OP_EVERSION = (-134);
  OP_ENOTAUDIO = (-135);
  OP_EBADPACKET = (-136);
  OP_EBADLINK = (-137);
  OP_ENOSEEK = (-138);
  OP_EBADTIMESTAMP = (-139);

  OPUS_CHANNEL_COUNT_MAX = (255);

  OP_PIC_FORMAT_UNKNOWN = (-1);
  OP_PIC_FORMAT_URL = (0);
  OP_PIC_FORMAT_JPEG = (1);
  OP_PIC_FORMAT_PNG = (2);
  OP_PIC_FORMAT_GIF = (3);

type

  ope_write_func = function (user_data : pointer; const ptr : pcuchar; len : opus_int32) : cint; cdecl;
  ope_close_func = function (user_data : pointer): cint; cdecl;
  ope_packet_func = procedure(user_data : pointer; const packet_ptr : pcuchar; packet_len : opus_int32; flags : opus_uint32); cdecl;

  pOpusEncCallbacks = ^OpusEncCallbacks;
  OpusEncCallbacks = record
    write : ope_write_func;
    close : ope_close_func;
  end;

  pOpusHead = ^OpusHead;
  OpusHead = record
    version           : cint;
    channel_count     : cint;
    pre_skip          : cuint;
    input_sample_rate : opus_uint32;
    output_gain       : cint;
    mapping_family    : cint;
    stream_count      : cint;
    coupled_count     : cint;
    mapping : Array [0..OPUS_CHANNEL_COUNT_MAX-1] of cuchar;
  end;

  pOpusTags = ^OpusTags;
  OpusTags = record
    user_comments : ppcchar;
    comment_lengths : pcint;
    comments : cint;
    vendor : pcchar;
  end;

  pOpusPictureTag = ^OpusPictureTag;
  OpusPictureTag = record
    _type : opus_int32;
    mime_type : pcchar;
    description : pcchar;
    width       : opus_uint32;
    height      : opus_uint32;
    depth       : opus_uint32;
    colors      : opus_uint32;
    data_length : opus_uint32;
    data : pcuchar;
    format : cint;
  end;

  op_read_func=function(_stream : pointer; _ptr : pcuchar; _nbytes : cint) : cint; cdecl;
  op_seek_func=function(_stream : pointer;_offset:opus_int64;_whence:cint): cint;cdecl;
  op_tell_func=function(_stream : pointer):opus_int64;cdecl;
  op_close_func=function(_stream : pointer):cint;cdecl;

  pOggOpusFile = pointer;

  pOpusFileCallbacks = ^OpusFileCallbacks;
  OpusFileCallbacks = record
    read : op_read_func;
    seek : op_seek_func;
    tell : op_tell_func;
    close : op_close_func;
  end;

function opus_encoder_get_size(channels: cint): cint;
function opus_encoder_create(Fs: opus_int32; channels: cint; application: cint; error: pcint): pOpusEncoder;
function opus_encoder_init(st: pOpusEncoder; Fs: opus_int32; channels: cint; application: cint): cint;
function opus_encode(st: pOpusEncoder; const pcm: popus_int16; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32;
function opus_encode_float(st: pOpusEncoder; const pcm: pfloat; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32;
procedure opus_encoder_destroy(st: pOpusEncoder);
function opus_encoder_ctl(st: pOpusEncoder; request: cint; Args : Array of const): cint;
function opus_encoder_ctl_set_bitrate(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_bandwidth(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_signal(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_app(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_vbr(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_vbr_constraint(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_set_complexity(enc : pOpusEncoder; v : opus_int32): cint;
function opus_encoder_ctl_get_bitrate(enc : pOpusEncoder; v : popus_int32): cint;
function opus_encoder_ctl_get_complexity(enc : pOpusEncoder; v : popus_int32): cint;
function opus_encoder_ctl_get_vbr(enc : pOpusEncoder; v : popus_int32): cint;
function opus_encoder_ctl_get_final_range(enc : pOpusEncoder; v : popus_int32): cint;
function opus_decoder_get_size(channels: cint): cint;
function opus_decoder_create(Fs: opus_int32; channels: cint; error: pcint): pOpusDecoder;
function opus_decoder_init(st: pOpusDecoder; Fs: opus_int32; channels: cint): cint;
function opus_decode(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: popus_int16; frame_size: cint; decode_fec: cint): cint;
function opus_decode_float(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: pfloat; frame_size: cint; decode_fec: cint): cint;
function opus_decoder_ctl(st: pOpusDecoder; request: cint; Args : Array of const): cint;
function opus_decoder_ctl_set_gain(st: pOpusDecoder; val : opus_int32): cint;
function opus_decoder_ctl_get_last_packet_duration(st: pOpusDecoder; val : popus_int32): cint;
function opus_decoder_ctl_get_bitrate(st: pOpusDecoder; val : popus_int32): cint;
procedure opus_decoder_destroy(st: pOpusDecoder);
function opus_packet_parse(const data: pcuchar; len: opus_int32; out_toc: pcuchar; const frames: ppcuchar; size: popus_int16; payload_offset: pcint): cint;
function opus_packet_get_bandwidth(const data: pcuchar): cint;
function opus_packet_get_samples_per_frame(const data: pcuchar; Fs: opus_int32): cint;
function opus_packet_get_nb_channels(const data: pcuchar): cint;
function opus_packet_get_nb_frames(const packet: pcuchar; len: opus_int32): cint;
function opus_packet_get_nb_samples(const packet: pcuchar; len: opus_int32; Fs: opus_int32): cint;
function opus_decoder_get_nb_samples(const dec: pOpusDecoder; const packet: pcuchar; len: opus_int32): cint;
procedure opus_pcm_soft_clip(pcm: pfloat; frame_size: cint; channels: cint; softclip_mem: pfloat);
function opus_repacketizer_get_size(): cint;
function opus_repacketizer_init(rp: pOpusRepacketizer): pOpusRepacketizer;
function opus_repacketizer_create(): pOpusRepacketizer;
procedure opus_repacketizer_destroy(rp: pOpusRepacketizer);
function opus_repacketizer_cat(rp: pOpusRepacketizer; const data: pcuchar; len: opus_int32): cint;
function opus_repacketizer_out_range(rp: pOpusRepacketizer; vbegin: cint; vend: cint; data: pcuchar; maxlen: opus_int32): opus_int32;
function opus_repacketizer_get_nb_frames(rp: pOpusRepacketizer): cint;
function opus_repacketizer_out(rp: pOpusRepacketizer; data: pcuchar; maxlen: opus_int32): opus_int32;
function opus_packet_pad(data: pcuchar; len: opus_int32; new_len: opus_int32): cint;
function opus_packet_unpad(data: pcuchar; len: opus_int32): opus_int32;
function opus_multistream_packet_pad(data: pcuchar; len: opus_int32; new_len: opus_int32; nb_streams: cint): cint;
function opus_multistream_packet_unpad(data: pcuchar; len: opus_int32; nb_streams: cint): opus_int32;
function ope_comments_create(): pOggOpusComments;
function ope_comments_copy(comments: pOggOpusComments): pOggOpusComments;
procedure ope_comments_destroy(comments: pOggOpusComments);
function ope_comments_add(comments: pOggOpusComments; const tag: pcchar; const val: pcchar): cint;
function ope_comments_add_string(comments: pOggOpusComments; const tag_and_val: pcchar): cint;
function ope_comments_add_picture(comments: pOggOpusComments; const filename: pcchar; picture_type: cint; const description: pcchar): cint;
function ope_comments_add_picture_from_memory(comments: pOggOpusComments; const ptr: pcchar; size: csize_t; picture_type: cint; const description: pcchar): cint;
function ope_encoder_create_file(const path: pcchar; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
function ope_encoder_create_callbacks(const callbacks: pOpusEncCallbacks; user_data: pointer; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
function ope_encoder_create_pull(comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
function ope_encoder_deferred_init_with_mapping(enc: pOggOpusEnc; family: cint; streams: cint; coupled_streams: cint; const mapping: pcuchar): cint;
function ope_encoder_write_float(enc: pOggOpusEnc; const pcm: pfloat; samples_per_channel: cint): cint;
function ope_encoder_write(enc: pOggOpusEnc; const pcm: popus_int16; samples_per_channel: cint): cint;
function ope_encoder_get_page(enc: pOggOpusEnc; page: ppcuchar; len: popus_int32; flush: cint): cint;
function ope_encoder_drain(enc: pOggOpusEnc): cint;
procedure ope_encoder_destroy(enc: pOggOpusEnc);
function ope_encoder_chain_current(enc: pOggOpusEnc; comments: pOggOpusComments): cint;
function ope_encoder_continue_new_file(enc: pOggOpusEnc; const path: pcchar; comments: pOggOpusComments): cint;
function ope_encoder_continue_new_callbacks(enc: pOggOpusEnc; user_data: pointer; comments: pOggOpusComments): cint;
function ope_encoder_flush_header(enc: pOggOpusEnc): cint;
function ope_encoder_ctl(enc: pOggOpusEnc; request: cint; Args : Array of const): cint;
function ope_encoder_ctl_set_serialno(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_bitrate(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_vbr(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_vbr_constraint(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_decision_delay(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_comment_padding(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_set_complexity(enc: pOggOpusEnc; v : opus_int32): cint;
function ope_encoder_ctl_get_bitrate(enc: pOggOpusEnc; v : popus_int32): cint;
function ope_encoder_ctl_get_complexity(enc: pOggOpusEnc; v : popus_int32): cint;
function ope_encoder_ctl_get_vbr(enc: pOggOpusEnc; v : popus_int32): cint;
function ope_encoder_ctl_get_final_range(enc: pOggOpusEnc; v : popus_int32): cint;
function ope_strerror(error: cint): pcchar;
function ope_get_version_string(): pcchar;
function ope_get_abi_version(): cint;
function opus_head_parse(_head: pOpusHead; const _data: pcuchar; _len: csize_t): cint;
function opus_granule_sample(const _head: pOpusHead; _gp: ogg_int64_t): ogg_int64_t;
function opus_tags_parse(_tags: pOpusTags; const _data: pcuchar; _len: csize_t): cint;
function opus_tags_copy(_dst: pOpusTags; const _src: pOpusTags): cint;
procedure opus_tags_init(_tags: pOpusTags);
function opus_tags_add(_tags: pOpusTags; const _tag: pcchar; const _value: pcchar): cint;
function opus_tags_add_comment(_tags: pOpusTags; const _comment: pcchar): cint;
function opus_tags_set_binary_suffix(_tags: pOpusTags; const _data: pcuchar; _len: cint): cint;
function opus_tags_query(const _tags: pOpusTags; const _tag: pcchar; _count: cint): pcchar;
function opus_tags_query_count(const _tags: pOpusTags; const _tag: pcchar): cint;
function opus_tags_get_binary_suffix(const _tags: pOpusTags; _len: pcint): pcuchar;
function opus_tags_get_album_gain(const _tags: pOpusTags; _gain_q8: pcint): cint;
function opus_tags_get_track_gain(const _tags: pOpusTags; _gain_q8: pcint): cint;
procedure opus_tags_clear(_tags: pOpusTags);
function opus_tagcompare(const _tag_name: pcchar; const _comment: pcchar): cint;
function opus_tagncompare(const _tag_name: pcchar; _tag_len: cint; const _comment: pcchar): cint;
function opus_picture_tag_parse(_pic: pOpusPictureTag; const _tag: pcchar): cint;
procedure opus_picture_tag_init(_pic: pOpusPictureTag);
procedure opus_picture_tag_clear(_pic: pOpusPictureTag);
function op_fopen(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar): pointer;
function op_fdopen(_cb: pOpusFileCallbacks; _fd: cint; const _mode: pcchar): pointer;
function op_freopen(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar; _stream: pointer): pointer;
function op_mem_stream_create(_cb: pOpusFileCallbacks; const _data: pcuchar; _size: csize_t): pointer;
function op_open_file(const _path: pcchar; _error: pcint): pOggOpusFile;
function op_open_memory(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile;
function op_open_callbacks(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile;
function op_test_file(const _path: pcchar; _error: pcint): pOggOpusFile;
function op_test_memory(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile;
function op_test_callbacks(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile;
function op_test_open(_of: pOggOpusFile): cint;
procedure op_free(_of: pOggOpusFile);
function op_seekable(const _of: pOggOpusFile): cint;
function op_link_count(const _of: pOggOpusFile): cint;
function op_serialno(const _of: pOggOpusFile; _li: cint): opus_uint32;
function op_channel_count(const _of: pOggOpusFile; _li: cint): cint;
function op_raw_total(const _of: pOggOpusFile; _li: cint): opus_int64;
function op_pcm_total(const _of: pOggOpusFile; _li: cint): ogg_int64_t;
function op_head(const _of: pOggOpusFile; _li: cint): pOpusHead;
function op_tags(const _of: pOggOpusFile; _li: cint): pOpusTags;
function op_current_link(const _of: pOggOpusFile): cint;
function op_bitrate(const _of: pOggOpusFile; _li: cint): opus_int32;
function op_bitrate_instant(_of: pOggOpusFile): opus_int32;
function op_raw_tell(const _of: pOggOpusFile): opus_int64;
function op_pcm_tell(const _of: pOggOpusFile): ogg_int64_t;
function op_raw_seek(_of: pOggOpusFile; _byte_offset: opus_int64): cint;
function op_pcm_seek(_of: pOggOpusFile; _pcm_offset: ogg_int64_t): cint;
function op_set_gain_offset(_of: pOggOpusFile; _gain_type: cint; _gain_offset_q8: opus_int32): cint;
procedure op_set_dither_enabled(_of: pOggOpusFile; _enabled: cint);
function op_read(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint; _li: pcint): cint;
function op_read_float(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint; _li: pcint): cint;
function op_read_stereo(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint): cint;
function op_read_float_stereo(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint): cint;

function IsOpusloaded: boolean; 
function InitOpusInterface(const aLibs : Array of String): boolean; overload; 
function DestroyOpusInterface: boolean; 

implementation

var
  Opusloaded: boolean = False;
  OpusLib: Array of HModule;
resourcestring
  SFailedToLoadOpus = 'Failed to load Opus library';

type

  p_opus_encoder_get_size = function(channels: cint): cint; cdecl;
  p_opus_encoder_create = function(Fs: opus_int32; channels: cint; application: cint; error: pcint): pOpusEncoder; cdecl;
  p_opus_encoder_init = function(st: pOpusEncoder; Fs: opus_int32; channels: cint; application: cint): cint; cdecl;
  p_opus_encode = function(st: pOpusEncoder; const pcm:            popus_int16; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32; cdecl;
  p_opus_encode_float = function(st: pOpusEncoder; const pcm: pfloat; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32; cdecl;
  p_opus_encoder_destroy = procedure(st: pOpusEncoder); cdecl;
  p_opus_encoder_ctl = function(st: pOpusEncoder; request: cint): cint; cdecl varargs;
  p_opus_decoder_get_size = function(channels: cint): cint; cdecl;
  p_opus_decoder_create = function(Fs: opus_int32; channels: cint; error: pcint): pOpusDecoder; cdecl;
  p_opus_decoder_init = function(st: pOpusDecoder; Fs: opus_int32; channels: cint): cint; cdecl;
  p_opus_decode = function(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: popus_int16; frame_size: cint; decode_fec: cint): cint; cdecl;
  p_opus_decode_float = function(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: pfloat; frame_size: cint; decode_fec: cint): cint; cdecl;
  p_opus_decoder_ctl = function(st: pOpusDecoder; request: cint): cint; cdecl varargs;
  p_opus_decoder_destroy = procedure(st: pOpusDecoder); cdecl;
  p_opus_packet_parse = function(const data: pcuchar; len: opus_int32; out_toc: pcuchar; const frames: ppcuchar; size: popus_int16; payload_offset: pcint): cint; cdecl;
  p_opus_packet_get_bandwidth = function(const data: pcuchar): cint; cdecl;
  p_opus_packet_get_samples_per_frame = function(const data: pcuchar; Fs: opus_int32): cint; cdecl;
  p_opus_packet_get_nb_channels = function(const data: pcuchar): cint; cdecl;
  p_opus_packet_get_nb_frames = function(const packet: pcuchar; len: opus_int32): cint; cdecl;
  p_opus_packet_get_nb_samples = function(const packet: pcuchar; len: opus_int32; Fs: opus_int32): cint; cdecl;
  p_opus_decoder_get_nb_samples = function(const dec: pOpusDecoder; const packet: pcuchar; len: opus_int32): cint; cdecl;
  p_opus_pcm_soft_clip = procedure(pcm: pfloat; frame_size: cint; channels: cint; softclip_mem: pfloat); cdecl;
  p_opus_repacketizer_get_size = function(): cint; cdecl;
  p_opus_repacketizer_init = function(rp: pOpusRepacketizer): pOpusRepacketizer; cdecl;
  p_opus_repacketizer_create = function(): pOpusRepacketizer; cdecl;
  p_opus_repacketizer_destroy = procedure(rp: pOpusRepacketizer); cdecl;
  p_opus_repacketizer_cat = function(rp: pOpusRepacketizer; const data: pcuchar; len: opus_int32): cint; cdecl;
  p_opus_repacketizer_out_range = function(rp: pOpusRepacketizer; vbegin: cint; vend: cint; data: pcuchar; maxlen: opus_int32): opus_int32; cdecl;
  p_opus_repacketizer_get_nb_frames = function(rp: pOpusRepacketizer): cint; cdecl;
  p_opus_repacketizer_out = function(rp: pOpusRepacketizer; data: pcuchar; maxlen: opus_int32): opus_int32; cdecl;
  p_opus_packet_pad = function(data: pcuchar; len: opus_int32; new_len: opus_int32): cint; cdecl;
  p_opus_packet_unpad = function(data: pcuchar; len: opus_int32): opus_int32; cdecl;
  p_opus_multistream_packet_pad = function(data: pcuchar; len: opus_int32; new_len: opus_int32; nb_streams: cint): cint; cdecl;
  p_opus_multistream_packet_unpad = function(data: pcuchar; len: opus_int32; nb_streams: cint): opus_int32; cdecl;
  p_ope_comments_create = function(): pOggOpusComments; cdecl;
  p_ope_comments_copy = function(comments: pOggOpusComments): pOggOpusComments; cdecl;
  p_ope_comments_destroy = procedure(comments: pOggOpusComments); cdecl;
  p_ope_comments_add = function(comments: pOggOpusComments; const tag: pcchar; const val: pcchar): cint; cdecl;
  p_ope_comments_add_string = function(comments: pOggOpusComments; const tag_and_val: pcchar): cint; cdecl;
  p_ope_comments_add_picture = function(comments: pOggOpusComments; const filename: pcchar; picture_type: cint; const description: pcchar): cint; cdecl;
  p_ope_comments_add_picture_from_memory = function(comments: pOggOpusComments; const ptr: pcchar; size: csize_t; picture_type: cint; const description: pcchar): cint; cdecl;
  p_ope_encoder_create_file = function(const path: pcchar; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc; cdecl;
  p_ope_encoder_create_callbacks = function(const callbacks: pOpusEncCallbacks; user_data: pointer; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc; cdecl;
  p_ope_encoder_create_pull = function(comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc; cdecl;
  p_ope_encoder_deferred_init_with_mapping = function(enc: pOggOpusEnc; family: cint; streams: cint; coupled_streams: cint; const mapping: pcuchar): cint; cdecl;
  p_ope_encoder_write_float = function(enc: pOggOpusEnc; const pcm: pfloat; samples_per_channel: cint): cint; cdecl;
  p_ope_encoder_write = function(enc: pOggOpusEnc; const pcm: popus_int16; samples_per_channel: cint): cint; cdecl;
  p_ope_encoder_get_page = function(enc: pOggOpusEnc; page: ppcuchar; len: popus_int32; flush: cint): cint; cdecl;
  p_ope_encoder_drain = function(enc: pOggOpusEnc): cint; cdecl;
  p_ope_encoder_destroy = procedure(enc: pOggOpusEnc); cdecl;
  p_ope_encoder_chain_current = function(enc: pOggOpusEnc; comments: pOggOpusComments): cint; cdecl;
  p_ope_encoder_continue_new_file = function(enc: pOggOpusEnc; const path: pcchar; comments: pOggOpusComments): cint; cdecl;
  p_ope_encoder_continue_new_callbacks = function(enc: pOggOpusEnc; user_data: pointer; comments: pOggOpusComments): cint; cdecl;
  p_ope_encoder_flush_header = function(enc: pOggOpusEnc): cint; cdecl;
  p_ope_encoder_ctl = function(enc: pOggOpusEnc; request: cint): cint; cdecl varargs;
  p_ope_strerror = function(error: cint): pcchar; cdecl;
  p_ope_get_version_string = function(): pcchar; cdecl;
  p_ope_get_abi_version = function(): cint; cdecl;
  p_opus_head_parse = function(_head: pOpusHead; const _data: pcuchar; _len: csize_t): cint; cdecl;
  p_opus_granule_sample = function(const _head: pOpusHead; _gp: ogg_int64_t): ogg_int64_t; cdecl;
  p_opus_tags_parse = function(_tags: pOpusTags; const _data: pcuchar; _len: csize_t): cint; cdecl;
  p_opus_tags_copy = function(_dst: pOpusTags; const _src: pOpusTags): cint; cdecl;
  p_opus_tags_init = procedure(_tags: pOpusTags); cdecl;
  p_opus_tags_add = function(_tags: pOpusTags; const _tag: pcchar; const _value: pcchar): cint; cdecl;
  p_opus_tags_add_comment = function(_tags: pOpusTags; const _comment: pcchar): cint; cdecl;
  p_opus_tags_set_binary_suffix = function(_tags: pOpusTags; const _data: pcuchar; _len: cint): cint; cdecl;
  p_opus_tags_query = function(const _tags: pOpusTags; const _tag: pcchar; _count: cint): pcchar; cdecl;
  p_opus_tags_query_count = function(const _tags: pOpusTags; const _tag: pcchar): cint; cdecl;
  p_opus_tags_get_binary_suffix = function(const _tags: pOpusTags; _len: pcint): pcuchar; cdecl;
  p_opus_tags_get_album_gain = function(const _tags: pOpusTags; _gain_q8: pcint): cint; cdecl;
  p_opus_tags_get_track_gain = function(const _tags: pOpusTags; _gain_q8: pcint): cint; cdecl;
  p_opus_tags_clear = procedure(_tags: pOpusTags); cdecl;
  p_opus_tagcompare = function(const _tag_name: pcchar; const _comment: pcchar): cint; cdecl;
  p_opus_tagncompare = function(const _tag_name: pcchar; _tag_len: cint; const _comment: pcchar): cint; cdecl;
  p_opus_picture_tag_parse = function(_pic: pOpusPictureTag; const _tag: pcchar): cint; cdecl;
  p_opus_picture_tag_init = procedure(_pic: pOpusPictureTag); cdecl;
  p_opus_picture_tag_clear = procedure(_pic: pOpusPictureTag); cdecl;
  p_op_fopen = function(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar): pointer; cdecl;
  p_op_fdopen = function(_cb: pOpusFileCallbacks; _fd: cint; const _mode: pcchar): pointer; cdecl;
  p_op_freopen = function(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar; _stream: pointer): pointer; cdecl;
  p_op_mem_stream_create = function(_cb: pOpusFileCallbacks; const _data: pcuchar; _size: csize_t): pointer; cdecl;
  p_op_open_file = function(const _path: pcchar; _error: pcint): pOggOpusFile; cdecl;
  p_op_open_memory = function(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile; cdecl;
  p_op_open_callbacks = function(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile; cdecl;
  p_op_test_file = function(const _path: pcchar; _error: pcint): pOggOpusFile; cdecl;
  p_op_test_memory = function(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile; cdecl;
  p_op_test_callbacks = function(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile; cdecl;
  p_op_test_open = function(_of: pOggOpusFile): cint; cdecl;
  p_op_free = procedure(_of: pOggOpusFile); cdecl;
  p_op_seekable = function(const _of: pOggOpusFile): cint; cdecl;
  p_op_link_count = function(const _of: pOggOpusFile): cint; cdecl;
  p_op_serialno = function(const _of: pOggOpusFile; _li: cint): opus_uint32; cdecl;
  p_op_channel_count = function(const _of: pOggOpusFile; _li: cint): cint; cdecl;
  p_op_raw_total = function(const _of: pOggOpusFile; _li: cint): opus_int64; cdecl;
  p_op_pcm_total = function(const _of: pOggOpusFile; _li: cint): ogg_int64_t; cdecl;
  p_op_head = function(const _of: pOggOpusFile; _li: cint): pOpusHead; cdecl;
  p_op_tags = function(const _of: pOggOpusFile; _li: cint): pOpusTags; cdecl;
  p_op_current_link = function(const _of: pOggOpusFile): cint; cdecl;
  p_op_bitrate = function(const _of: pOggOpusFile; _li: cint): opus_int32; cdecl;
  p_op_bitrate_instant = function(_of: pOggOpusFile): opus_int32; cdecl;
  p_op_raw_tell = function(const _of: pOggOpusFile): opus_int64; cdecl;
  p_op_pcm_tell = function(const _of: pOggOpusFile): ogg_int64_t; cdecl;
  p_op_raw_seek = function(_of: pOggOpusFile; _byte_offset: opus_int64): cint; cdecl;
  p_op_pcm_seek = function(_of: pOggOpusFile; _pcm_offset: ogg_int64_t): cint; cdecl;
  p_op_set_gain_offset = function(_of: pOggOpusFile; _gain_type: cint; _gain_offset_q8: opus_int32): cint; cdecl;
  p_op_set_dither_enabled = procedure(_of: pOggOpusFile; _enabled: cint); cdecl;
  p_op_read = function(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint; _li: pcint): cint; cdecl;
  p_op_read_float = function(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint; _li: pcint): cint; cdecl;
  p_op_read_stereo = function(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint): cint; cdecl;
  p_op_read_float_stereo = function(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint): cint; cdecl;

var
  _opus_encoder_get_size: p_opus_encoder_get_size = nil;
  _opus_encoder_create: p_opus_encoder_create = nil;
  _opus_encoder_init: p_opus_encoder_init = nil;
  _opus_encode: p_opus_encode = nil;
  _opus_encode_float: p_opus_encode_float = nil;
  _opus_encoder_destroy: p_opus_encoder_destroy = nil;
  _opus_encoder_ctl: p_opus_encoder_ctl = nil;
  _opus_decoder_get_size: p_opus_decoder_get_size = nil;
  _opus_decoder_create: p_opus_decoder_create = nil;
  _opus_decoder_init: p_opus_decoder_init = nil;
  _opus_decode: p_opus_decode = nil;
  _opus_decode_float: p_opus_decode_float = nil;
  _opus_decoder_ctl: p_opus_decoder_ctl = nil;
  _opus_decoder_destroy: p_opus_decoder_destroy = nil;
  _opus_packet_parse: p_opus_packet_parse = nil;
  _opus_packet_get_bandwidth: p_opus_packet_get_bandwidth = nil;
  _opus_packet_get_samples_per_frame: p_opus_packet_get_samples_per_frame = nil;
  _opus_packet_get_nb_channels: p_opus_packet_get_nb_channels = nil;
  _opus_packet_get_nb_frames: p_opus_packet_get_nb_frames = nil;
  _opus_packet_get_nb_samples: p_opus_packet_get_nb_samples = nil;
  _opus_decoder_get_nb_samples: p_opus_decoder_get_nb_samples = nil;
  _opus_pcm_soft_clip: p_opus_pcm_soft_clip = nil;
  _opus_repacketizer_get_size: p_opus_repacketizer_get_size = nil;
  _opus_repacketizer_init: p_opus_repacketizer_init = nil;
  _opus_repacketizer_create: p_opus_repacketizer_create = nil;
  _opus_repacketizer_destroy: p_opus_repacketizer_destroy = nil;
  _opus_repacketizer_cat: p_opus_repacketizer_cat = nil;
  _opus_repacketizer_out_range: p_opus_repacketizer_out_range = nil;
  _opus_repacketizer_get_nb_frames: p_opus_repacketizer_get_nb_frames = nil;
  _opus_repacketizer_out: p_opus_repacketizer_out = nil;
  _opus_packet_pad: p_opus_packet_pad = nil;
  _opus_packet_unpad: p_opus_packet_unpad = nil;
  _opus_multistream_packet_pad: p_opus_multistream_packet_pad = nil;
  _opus_multistream_packet_unpad: p_opus_multistream_packet_unpad = nil;
  _ope_comments_create: p_ope_comments_create = nil;
  _ope_comments_copy: p_ope_comments_copy = nil;
  _ope_comments_destroy: p_ope_comments_destroy = nil;
  _ope_comments_add: p_ope_comments_add = nil;
  _ope_comments_add_string: p_ope_comments_add_string = nil;
  _ope_comments_add_picture: p_ope_comments_add_picture = nil;
  _ope_comments_add_picture_from_memory: p_ope_comments_add_picture_from_memory = nil;
  _ope_encoder_create_file: p_ope_encoder_create_file = nil;
  _ope_encoder_create_callbacks: p_ope_encoder_create_callbacks = nil;
  _ope_encoder_create_pull: p_ope_encoder_create_pull = nil;
  _ope_encoder_deferred_init_with_mapping: p_ope_encoder_deferred_init_with_mapping = nil;
  _ope_encoder_write_float: p_ope_encoder_write_float = nil;
  _ope_encoder_write: p_ope_encoder_write = nil;
  _ope_encoder_get_page: p_ope_encoder_get_page = nil;
  _ope_encoder_drain: p_ope_encoder_drain = nil;
  _ope_encoder_destroy: p_ope_encoder_destroy = nil;
  _ope_encoder_chain_current: p_ope_encoder_chain_current = nil;
  _ope_encoder_continue_new_file: p_ope_encoder_continue_new_file = nil;
  _ope_encoder_continue_new_callbacks: p_ope_encoder_continue_new_callbacks = nil;
  _ope_encoder_flush_header: p_ope_encoder_flush_header = nil;
  _ope_encoder_ctl: p_ope_encoder_ctl = nil;
  _ope_strerror: p_ope_strerror = nil;
  _ope_get_version_string: p_ope_get_version_string = nil;
  _ope_get_abi_version: p_ope_get_abi_version = nil;
  _opus_head_parse: p_opus_head_parse = nil;
  _opus_granule_sample: p_opus_granule_sample = nil;
  _opus_tags_parse: p_opus_tags_parse = nil;
  _opus_tags_copy: p_opus_tags_copy = nil;
  _opus_tags_init: p_opus_tags_init = nil;
  _opus_tags_add: p_opus_tags_add = nil;
  _opus_tags_add_comment: p_opus_tags_add_comment = nil;
  _opus_tags_set_binary_suffix: p_opus_tags_set_binary_suffix = nil;
  _opus_tags_query: p_opus_tags_query = nil;
  _opus_tags_query_count: p_opus_tags_query_count = nil;
  _opus_tags_get_binary_suffix: p_opus_tags_get_binary_suffix = nil;
  _opus_tags_get_album_gain: p_opus_tags_get_album_gain = nil;
  _opus_tags_get_track_gain: p_opus_tags_get_track_gain = nil;
  _opus_tags_clear: p_opus_tags_clear = nil;
  _opus_tagcompare: p_opus_tagcompare = nil;
  _opus_tagncompare: p_opus_tagncompare = nil;
  _opus_picture_tag_parse: p_opus_picture_tag_parse = nil;
  _opus_picture_tag_init: p_opus_picture_tag_init = nil;
  _opus_picture_tag_clear: p_opus_picture_tag_clear = nil;
  _op_fopen: p_op_fopen = nil;
  _op_fdopen: p_op_fdopen = nil;
  _op_freopen: p_op_freopen = nil;
  _op_mem_stream_create: p_op_mem_stream_create = nil;
  _op_open_file: p_op_open_file = nil;
  _op_open_memory: p_op_open_memory = nil;
  _op_open_callbacks: p_op_open_callbacks = nil;
  _op_test_file: p_op_test_file = nil;
  _op_test_memory: p_op_test_memory = nil;
  _op_test_callbacks: p_op_test_callbacks = nil;
  _op_test_open: p_op_test_open = nil;
  _op_free: p_op_free = nil;
  _op_seekable: p_op_seekable = nil;
  _op_link_count: p_op_link_count = nil;
  _op_serialno: p_op_serialno = nil;
  _op_channel_count: p_op_channel_count = nil;
  _op_raw_total: p_op_raw_total = nil;
  _op_pcm_total: p_op_pcm_total = nil;
  _op_head: p_op_head = nil;
  _op_tags: p_op_tags = nil;
  _op_current_link: p_op_current_link = nil;
  _op_bitrate: p_op_bitrate = nil;
  _op_bitrate_instant: p_op_bitrate_instant = nil;
  _op_raw_tell: p_op_raw_tell = nil;
  _op_pcm_tell: p_op_pcm_tell = nil;
  _op_raw_seek: p_op_raw_seek = nil;
  _op_pcm_seek: p_op_pcm_seek = nil;
  _op_set_gain_offset: p_op_set_gain_offset = nil;
  _op_set_dither_enabled: p_op_set_dither_enabled = nil;
  _op_read: p_op_read = nil;
  _op_read_float: p_op_read_float = nil;
  _op_read_stereo: p_op_read_stereo = nil;
  _op_read_float_stereo: p_op_read_float_stereo = nil;

{$IFNDEF WINDOWS}
{ Try to load all library versions until you find or run out }
procedure LoadLibUnix(const aLibs : Array of String);
var i : integer;
begin
  for i := 0 to High(aLibs) do
  begin
    OpusLib[i] := LoadLibrary(aLibs[i]);
  end;
end;

{$ELSE WINDOWS}
procedure LoadLibsWin(const aLibs : Array of String);
var i : integer;
begin
  for i := 0 to High(aLibs) do
  begin
    OpusLib[i] := LoadLibrary(aLibs[i]);
  end;
end;

{$ENDIF WINDOWS}

function IsOpusloaded: boolean;
begin
  Result := Opusloaded;
end;

procedure UnloadLibraries;
var i : integer;
begin
  Opusloaded := False;
  for i := 0 to High(OpusLib) do
  if OpusLib[i] <> NilHandle then
  begin
    FreeLibrary(OpusLib[i]);
    OpusLib[i] := NilHandle;
  end;
end;

function LoadLibraries(const aLibs : Array of String): boolean;
var i : integer;
begin
  SetLength(OpusLib, Length(aLibs));
  Result := False;
  {$IFDEF WINDOWS}
  LoadLibsWin(aLibs);
  {$ELSE}
  LoadLibUnix(aLibs);
  {$ENDIF}
  for i := 0 to High(aLibs) do
  if OpusLib[i] <> NilHandle then
     Result := true;
end;

function GetProcAddr(const module: Array of HModule; const ProcName: string): Pointer;
var i : integer;
begin
  for i := Low(module) to High(module) do 
  if module[i] <> NilHandle then 
  begin
    Result := GetProcAddress(module[i], PChar(ProcName));
    if Assigned(Result) then Exit;
  end;
end;

procedure LoadOpusEntryPoints;
begin
  _opus_encoder_get_size := p_opus_encoder_get_size(GetProcAddr(OpusLib, 'opus_encoder_get_size'));
  _opus_encoder_create := p_opus_encoder_create(GetProcAddr(OpusLib, 'opus_encoder_create'));
  _opus_encoder_init := p_opus_encoder_init(GetProcAddr(OpusLib, 'opus_encoder_init'));
  _opus_encode := p_opus_encode(GetProcAddr(OpusLib, 'opus_encode'));
  _opus_encode_float := p_opus_encode_float(GetProcAddr(OpusLib, 'opus_encode_float'));
  _opus_encoder_destroy := p_opus_encoder_destroy(GetProcAddr(OpusLib, 'opus_encoder_destroy'));
  _opus_encoder_ctl := p_opus_encoder_ctl(GetProcAddr(OpusLib, 'opus_encoder_ctl'));
  _opus_decoder_get_size := p_opus_decoder_get_size(GetProcAddr(OpusLib, 'opus_decoder_get_size'));
  _opus_decoder_create := p_opus_decoder_create(GetProcAddr(OpusLib, 'opus_decoder_create'));
  _opus_decoder_init := p_opus_decoder_init(GetProcAddr(OpusLib, 'opus_decoder_init'));
  _opus_decode := p_opus_decode(GetProcAddr(OpusLib, 'opus_decode'));
  _opus_decode_float := p_opus_decode_float(GetProcAddr(OpusLib, 'opus_decode_float'));
  _opus_decoder_ctl := p_opus_decoder_ctl(GetProcAddr(OpusLib, 'opus_decoder_ctl'));
  _opus_decoder_destroy := p_opus_decoder_destroy(GetProcAddr(OpusLib, 'opus_decoder_destroy'));
  _opus_packet_parse := p_opus_packet_parse(GetProcAddr(OpusLib, 'opus_packet_parse'));
  _opus_packet_get_bandwidth := p_opus_packet_get_bandwidth(GetProcAddr(OpusLib, 'opus_packet_get_bandwidth'));
  _opus_packet_get_samples_per_frame := p_opus_packet_get_samples_per_frame(GetProcAddr(OpusLib, 'opus_packet_get_samples_per_frame'));
  _opus_packet_get_nb_channels := p_opus_packet_get_nb_channels(GetProcAddr(OpusLib, 'opus_packet_get_nb_channels'));
  _opus_packet_get_nb_frames := p_opus_packet_get_nb_frames(GetProcAddr(OpusLib, 'opus_packet_get_nb_frames'));
  _opus_packet_get_nb_samples := p_opus_packet_get_nb_samples(GetProcAddr(OpusLib, 'opus_packet_get_nb_samples'));
  _opus_decoder_get_nb_samples := p_opus_decoder_get_nb_samples(GetProcAddr(OpusLib, 'opus_decoder_get_nb_samples'));
  _opus_pcm_soft_clip := p_opus_pcm_soft_clip(GetProcAddr(OpusLib, 'opus_pcm_soft_clip'));
  _opus_repacketizer_get_size := p_opus_repacketizer_get_size(GetProcAddr(OpusLib, 'opus_repacketizer_get_size'));
  _opus_repacketizer_init := p_opus_repacketizer_init(GetProcAddr(OpusLib, 'opus_repacketizer_init'));
  _opus_repacketizer_create := p_opus_repacketizer_create(GetProcAddr(OpusLib, 'opus_repacketizer_create'));
  _opus_repacketizer_destroy := p_opus_repacketizer_destroy(GetProcAddr(OpusLib, 'opus_repacketizer_destroy'));
  _opus_repacketizer_cat := p_opus_repacketizer_cat(GetProcAddr(OpusLib, 'opus_repacketizer_cat'));
  _opus_repacketizer_out_range := p_opus_repacketizer_out_range(GetProcAddr(OpusLib, 'opus_repacketizer_out_range'));
  _opus_repacketizer_get_nb_frames := p_opus_repacketizer_get_nb_frames(GetProcAddr(OpusLib, 'opus_repacketizer_get_nb_frames'));
  _opus_repacketizer_out := p_opus_repacketizer_out(GetProcAddr(OpusLib, 'opus_repacketizer_out'));
  _opus_packet_pad := p_opus_packet_pad(GetProcAddr(OpusLib, 'opus_packet_pad'));
  _opus_packet_unpad := p_opus_packet_unpad(GetProcAddr(OpusLib, 'opus_packet_unpad'));
  _opus_multistream_packet_pad := p_opus_multistream_packet_pad(GetProcAddr(OpusLib, 'opus_multistream_packet_pad'));
  _opus_multistream_packet_unpad := p_opus_multistream_packet_unpad(GetProcAddr(OpusLib, 'opus_multistream_packet_unpad'));
  _ope_comments_create := p_ope_comments_create(GetProcAddr(OpusLib, 'ope_comments_create'));
  _ope_comments_copy := p_ope_comments_copy(GetProcAddr(OpusLib, 'ope_comments_copy'));
  _ope_comments_destroy := p_ope_comments_destroy(GetProcAddr(OpusLib, 'ope_comments_destroy'));
  _ope_comments_add := p_ope_comments_add(GetProcAddr(OpusLib, 'ope_comments_add'));
  _ope_comments_add_string := p_ope_comments_add_string(GetProcAddr(OpusLib, 'ope_comments_add_string'));
  _ope_comments_add_picture := p_ope_comments_add_picture(GetProcAddr(OpusLib, 'ope_comments_add_picture'));
  _ope_comments_add_picture_from_memory := p_ope_comments_add_picture_from_memory(GetProcAddr(OpusLib, 'ope_comments_add_picture_from_memory'));
  _ope_encoder_create_file := p_ope_encoder_create_file(GetProcAddr(OpusLib, 'ope_encoder_create_file'));
  _ope_encoder_create_callbacks := p_ope_encoder_create_callbacks(GetProcAddr(OpusLib, 'ope_encoder_create_callbacks'));
  _ope_encoder_create_pull := p_ope_encoder_create_pull(GetProcAddr(OpusLib, 'ope_encoder_create_pull'));
  _ope_encoder_deferred_init_with_mapping := p_ope_encoder_deferred_init_with_mapping(GetProcAddr(OpusLib, 'ope_encoder_deferred_init_with_mapping'));
  _ope_encoder_write_float := p_ope_encoder_write_float(GetProcAddr(OpusLib, 'ope_encoder_write_float'));
  _ope_encoder_write := p_ope_encoder_write(GetProcAddr(OpusLib, 'ope_encoder_write'));
  _ope_encoder_get_page := p_ope_encoder_get_page(GetProcAddr(OpusLib, 'ope_encoder_get_page'));
  _ope_encoder_drain := p_ope_encoder_drain(GetProcAddr(OpusLib, 'ope_encoder_drain'));
  _ope_encoder_destroy := p_ope_encoder_destroy(GetProcAddr(OpusLib, 'ope_encoder_destroy'));
  _ope_encoder_chain_current := p_ope_encoder_chain_current(GetProcAddr(OpusLib, 'ope_encoder_chain_current'));
  _ope_encoder_continue_new_file := p_ope_encoder_continue_new_file(GetProcAddr(OpusLib, 'ope_encoder_continue_new_file'));
  _ope_encoder_continue_new_callbacks := p_ope_encoder_continue_new_callbacks(GetProcAddr(OpusLib, 'ope_encoder_continue_new_callbacks'));
  _ope_encoder_flush_header := p_ope_encoder_flush_header(GetProcAddr(OpusLib, 'ope_encoder_flush_header'));
  _ope_encoder_ctl := p_ope_encoder_ctl(GetProcAddr(OpusLib, 'ope_encoder_ctl'));
  _ope_strerror := p_ope_strerror(GetProcAddr(OpusLib, 'ope_strerror'));
  _ope_get_version_string := p_ope_get_version_string(GetProcAddr(OpusLib, 'ope_get_version_string'));
  _ope_get_abi_version := p_ope_get_abi_version(GetProcAddr(OpusLib, 'ope_get_abi_version'));
  _opus_head_parse := p_opus_head_parse(GetProcAddr(OpusLib, 'opus_head_parse'));
  _opus_granule_sample := p_opus_granule_sample(GetProcAddr(OpusLib, 'opus_granule_sample'));
  _opus_tags_parse := p_opus_tags_parse(GetProcAddr(OpusLib, 'opus_tags_parse'));
  _opus_tags_copy := p_opus_tags_copy(GetProcAddr(OpusLib, 'opus_tags_copy'));
  _opus_tags_init := p_opus_tags_init(GetProcAddr(OpusLib, 'opus_tags_init'));
  _opus_tags_add := p_opus_tags_add(GetProcAddr(OpusLib, 'opus_tags_add'));
  _opus_tags_add_comment := p_opus_tags_add_comment(GetProcAddr(OpusLib, 'opus_tags_add_comment'));
  _opus_tags_set_binary_suffix := p_opus_tags_set_binary_suffix(GetProcAddr(OpusLib, 'opus_tags_set_binary_suffix'));
  _opus_tags_query := p_opus_tags_query(GetProcAddr(OpusLib, 'opus_tags_query'));
  _opus_tags_query_count := p_opus_tags_query_count(GetProcAddr(OpusLib, 'opus_tags_query_count'));
  _opus_tags_get_binary_suffix := p_opus_tags_get_binary_suffix(GetProcAddr(OpusLib, 'opus_tags_get_binary_suffix'));
  _opus_tags_get_album_gain := p_opus_tags_get_album_gain(GetProcAddr(OpusLib, 'opus_tags_get_album_gain'));
  _opus_tags_get_track_gain := p_opus_tags_get_track_gain(GetProcAddr(OpusLib, 'opus_tags_get_track_gain'));
  _opus_tags_clear := p_opus_tags_clear(GetProcAddr(OpusLib, 'opus_tags_clear'));
  _opus_tagcompare := p_opus_tagcompare(GetProcAddr(OpusLib, 'opus_tagcompare'));
  _opus_tagncompare := p_opus_tagncompare(GetProcAddr(OpusLib, 'opus_tagncompare'));
  _opus_picture_tag_parse := p_opus_picture_tag_parse(GetProcAddr(OpusLib, 'opus_picture_tag_parse'));
  _opus_picture_tag_init := p_opus_picture_tag_init(GetProcAddr(OpusLib, 'opus_picture_tag_init'));
  _opus_picture_tag_clear := p_opus_picture_tag_clear(GetProcAddr(OpusLib, 'opus_picture_tag_clear'));
  _op_fopen := p_op_fopen(GetProcAddr(OpusLib, 'op_fopen'));
  _op_fdopen := p_op_fdopen(GetProcAddr(OpusLib, 'op_fdopen'));
  _op_freopen := p_op_freopen(GetProcAddr(OpusLib, 'op_freopen'));
  _op_mem_stream_create := p_op_mem_stream_create(GetProcAddr(OpusLib, 'op_mem_stream_create'));
  _op_open_file := p_op_open_file(GetProcAddr(OpusLib, 'op_open_file'));
  _op_open_memory := p_op_open_memory(GetProcAddr(OpusLib, 'op_open_memory'));
  _op_open_callbacks := p_op_open_callbacks(GetProcAddr(OpusLib, 'op_open_callbacks'));
  _op_test_file := p_op_test_file(GetProcAddr(OpusLib, 'op_test_file'));
  _op_test_memory := p_op_test_memory(GetProcAddr(OpusLib, 'op_test_memory'));
  _op_test_callbacks := p_op_test_callbacks(GetProcAddr(OpusLib, 'op_test_callbacks'));
  _op_test_open := p_op_test_open(GetProcAddr(OpusLib, 'op_test_open'));
  _op_free := p_op_free(GetProcAddr(OpusLib, 'op_free'));
  _op_seekable := p_op_seekable(GetProcAddr(OpusLib, 'op_seekable'));
  _op_link_count := p_op_link_count(GetProcAddr(OpusLib, 'op_link_count'));
  _op_serialno := p_op_serialno(GetProcAddr(OpusLib, 'op_serialno'));
  _op_channel_count := p_op_channel_count(GetProcAddr(OpusLib, 'op_channel_count'));
  _op_raw_total := p_op_raw_total(GetProcAddr(OpusLib, 'op_raw_total'));
  _op_pcm_total := p_op_pcm_total(GetProcAddr(OpusLib, 'op_pcm_total'));
  _op_head := p_op_head(GetProcAddr(OpusLib, 'op_head'));
  _op_tags := p_op_tags(GetProcAddr(OpusLib, 'op_tags'));
  _op_current_link := p_op_current_link(GetProcAddr(OpusLib, 'op_current_link'));
  _op_bitrate := p_op_bitrate(GetProcAddr(OpusLib, 'op_bitrate'));
  _op_bitrate_instant := p_op_bitrate_instant(GetProcAddr(OpusLib, 'op_bitrate_instant'));
  _op_raw_tell := p_op_raw_tell(GetProcAddr(OpusLib, 'op_raw_tell'));
  _op_pcm_tell := p_op_pcm_tell(GetProcAddr(OpusLib, 'op_pcm_tell'));
  _op_raw_seek := p_op_raw_seek(GetProcAddr(OpusLib, 'op_raw_seek'));
  _op_pcm_seek := p_op_pcm_seek(GetProcAddr(OpusLib, 'op_pcm_seek'));
  _op_set_gain_offset := p_op_set_gain_offset(GetProcAddr(OpusLib, 'op_set_gain_offset'));
  _op_set_dither_enabled := p_op_set_dither_enabled(GetProcAddr(OpusLib, 'op_set_dither_enabled'));
  _op_read := p_op_read(GetProcAddr(OpusLib, 'op_read'));
  _op_read_float := p_op_read_float(GetProcAddr(OpusLib, 'op_read_float'));
  _op_read_stereo := p_op_read_stereo(GetProcAddr(OpusLib, 'op_read_stereo'));
  _op_read_float_stereo := p_op_read_float_stereo(GetProcAddr(OpusLib, 'op_read_float_stereo'));
end;

procedure ClearOpusEntryPoints;
begin
  _opus_encoder_get_size := nil;
  _opus_encoder_create := nil;
  _opus_encoder_init := nil;
  _opus_encode := nil;
  _opus_encode_float := nil;
  _opus_encoder_destroy := nil;
  _opus_encoder_ctl := nil;
  _opus_decoder_get_size := nil;
  _opus_decoder_create := nil;
  _opus_decoder_init := nil;
  _opus_decode := nil;
  _opus_decode_float := nil;
  _opus_decoder_ctl := nil;
  _opus_decoder_destroy := nil;
  _opus_packet_parse := nil;
  _opus_packet_get_bandwidth := nil;
  _opus_packet_get_samples_per_frame := nil;
  _opus_packet_get_nb_channels := nil;
  _opus_packet_get_nb_frames := nil;
  _opus_packet_get_nb_samples := nil;
  _opus_decoder_get_nb_samples := nil;
  _opus_pcm_soft_clip := nil;
  _opus_repacketizer_get_size := nil;
  _opus_repacketizer_init := nil;
  _opus_repacketizer_create := nil;
  _opus_repacketizer_destroy := nil;
  _opus_repacketizer_cat := nil;
  _opus_repacketizer_out_range := nil;
  _opus_repacketizer_get_nb_frames := nil;
  _opus_repacketizer_out := nil;
  _opus_packet_pad := nil;
  _opus_packet_unpad := nil;
  _opus_multistream_packet_pad := nil;
  _opus_multistream_packet_unpad := nil;
  _ope_comments_create := nil;
  _ope_comments_copy := nil;
  _ope_comments_destroy := nil;
  _ope_comments_add := nil;
  _ope_comments_add_string := nil;
  _ope_comments_add_picture := nil;
  _ope_comments_add_picture_from_memory := nil;
  _ope_encoder_create_file := nil;
  _ope_encoder_create_callbacks := nil;
  _ope_encoder_create_pull := nil;
  _ope_encoder_deferred_init_with_mapping := nil;
  _ope_encoder_write_float := nil;
  _ope_encoder_write := nil;
  _ope_encoder_get_page := nil;
  _ope_encoder_drain := nil;
  _ope_encoder_destroy := nil;
  _ope_encoder_chain_current := nil;
  _ope_encoder_continue_new_file := nil;
  _ope_encoder_continue_new_callbacks := nil;
  _ope_encoder_flush_header := nil;
  _ope_encoder_ctl := nil;
  _ope_strerror := nil;
  _ope_get_version_string := nil;
  _ope_get_abi_version := nil;
  _opus_head_parse := nil;
  _opus_granule_sample := nil;
  _opus_tags_parse := nil;
  _opus_tags_copy := nil;
  _opus_tags_init := nil;
  _opus_tags_add := nil;
  _opus_tags_add_comment := nil;
  _opus_tags_set_binary_suffix := nil;
  _opus_tags_query := nil;
  _opus_tags_query_count := nil;
  _opus_tags_get_binary_suffix := nil;
  _opus_tags_get_album_gain := nil;
  _opus_tags_get_track_gain := nil;
  _opus_tags_clear := nil;
  _opus_tagcompare := nil;
  _opus_tagncompare := nil;
  _opus_picture_tag_parse := nil;
  _opus_picture_tag_init := nil;
  _opus_picture_tag_clear := nil;
  _op_fopen := nil;
  _op_fdopen := nil;
  _op_freopen := nil;
  _op_mem_stream_create := nil;
  _op_open_file := nil;
  _op_open_memory := nil;
  _op_open_callbacks := nil;
  _op_test_file := nil;
  _op_test_memory := nil;
  _op_test_callbacks := nil;
  _op_test_open := nil;
  _op_free := nil;
  _op_seekable := nil;
  _op_link_count := nil;
  _op_serialno := nil;
  _op_channel_count := nil;
  _op_raw_total := nil;
  _op_pcm_total := nil;
  _op_head := nil;
  _op_tags := nil;
  _op_current_link := nil;
  _op_bitrate := nil;
  _op_bitrate_instant := nil;
  _op_raw_tell := nil;
  _op_pcm_tell := nil;
  _op_raw_seek := nil;
  _op_pcm_seek := nil;
  _op_set_gain_offset := nil;
  _op_set_dither_enabled := nil;
  _op_read := nil;
  _op_read_float := nil;
  _op_read_stereo := nil;
  _op_read_float_stereo := nil;
end;

function InitOpusInterface(const aLibs : array of String): boolean;
begin
  Result := IsOpusloaded;
  if Result then
    exit;
  Result := LoadLibraries(aLibs);
  if not Result then
  begin
    UnloadLibraries;
    Exit;
  end;
  LoadOpusEntryPoints;
  Opusloaded := True;
  Result := True;
end;

function DestroyOpusInterface: boolean;
begin
  Result := not IsOpusloaded;
  if Result then
    exit;
  ClearOpusEntryPoints;
  UnloadLibraries;
  Result := True;
end;


function opus_encoder_get_size(channels: cint): cint;
begin
  if Assigned(_opus_encoder_get_size) then
    Result := _opus_encoder_get_size(channels)
  else
    Result := 0;
end;

function opus_encoder_create(Fs: opus_int32; channels: cint; application: cint; error: pcint): pOpusEncoder;
begin
  if Assigned(_opus_encoder_create) then
    Result := _opus_encoder_create(Fs, channels, application, error)
  else
    Result := nil;
end;

function opus_encoder_init(st: pOpusEncoder; Fs: opus_int32; channels: cint; application: cint): cint;
begin
  if Assigned(_opus_encoder_init) then
    Result := _opus_encoder_init(st, Fs, channels, application)
  else
    Result := 0;
end;

function opus_encode(st: pOpusEncoder; const pcm: popus_int16; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32;
begin
  if Assigned(_opus_encode) then
    Result := _opus_encode(st, pcm, frame_size, data, max_data_bytes)
  else
    Result := 0;
end;

function opus_encode_float(st: pOpusEncoder; const pcm: pfloat; frame_size: cint; data: pcuchar; max_data_bytes: opus_int32): opus_int32;
begin
  if Assigned(_opus_encode_float) then
    Result := _opus_encode_float(st, pcm, frame_size, data, max_data_bytes)
  else
    Result := 0;
end;

procedure opus_encoder_destroy(st: pOpusEncoder);
begin
  if Assigned(_opus_encoder_destroy) then
    _opus_encoder_destroy(st);
end;

function opus_encoder_ctl(st: pOpusEncoder; request: cint; Args : Array of const): cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(st, request{, Args})
  else
    Result := 0;
end;

function opus_encoder_ctl_set_bitrate(enc : pOpusEncoder; v : opus_int32) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_BITRATE_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_bandwidth(enc : pOpusEncoder; v : opus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_BANDWIDTH_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_signal(enc : pOpusEncoder; v : opus_int32) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_SIGNAL_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_app(enc : pOpusEncoder; v : opus_int32) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_APPLICATION_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_vbr(enc : pOpusEncoder; v : opus_int32) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_VBR_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_vbr_constraint(enc : pOpusEncoder; v : opus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_VBR_CONSTRAINT_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_set_complexity(enc : pOpusEncoder; v : opus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_SET_COMPLEXITY_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_get_bitrate(enc : pOpusEncoder; v : popus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_GET_BITRATE_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_get_complexity(enc : pOpusEncoder; v : popus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_GET_COMPLEXITY_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_get_vbr(enc : pOpusEncoder; v : popus_int32) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_GET_VBR_REQUEST, v)
  else
    Result := 0;
end;

function opus_encoder_ctl_get_final_range(enc : pOpusEncoder; v : popus_int32
  ) : cint;
begin
  if Assigned(_opus_encoder_ctl) then
    Result := _opus_encoder_ctl(enc, OPUS_GET_FINAL_RANGE_REQUEST, v)
  else
    Result := 0;
end;

function opus_decoder_get_size(channels: cint): cint;
begin
  if Assigned(_opus_decoder_get_size) then
    Result := _opus_decoder_get_size(channels)
  else
    Result := 0;
end;

function opus_decoder_create(Fs: opus_int32; channels: cint; error: pcint): pOpusDecoder;
begin
  if Assigned(_opus_decoder_create) then
    Result := _opus_decoder_create(Fs, channels, error)
  else
    Result := nil;
end;

function opus_decoder_init(st: pOpusDecoder; Fs: opus_int32; channels: cint): cint;
begin
  if Assigned(_opus_decoder_init) then
    Result := _opus_decoder_init(st, Fs, channels)
  else
    Result := 0;
end;

function opus_decode(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: popus_int16; frame_size: cint; decode_fec: cint): cint;
begin
  if Assigned(_opus_decode) then
    Result := _opus_decode(st, data, len, pcm, frame_size, decode_fec)
  else
    Result := 0;
end;

function opus_decode_float(st: pOpusDecoder; const data: pcuchar; len: opus_int32; pcm: pfloat; frame_size: cint; decode_fec: cint): cint;
begin
  if Assigned(_opus_decode_float) then
    Result := _opus_decode_float(st, data, len, pcm, frame_size, decode_fec)
  else
    Result := 0;
end;

function opus_decoder_ctl(st: pOpusDecoder; request: cint; Args : Array of const): cint;
begin
  if Assigned(_opus_decoder_ctl) then
    Result := _opus_decoder_ctl(st, request{, Args})
  else
    Result := 0;
end;

function opus_decoder_ctl_set_gain(st : pOpusDecoder; val : opus_int32) : cint;
begin
  if Assigned(_opus_decoder_ctl) then
    Result := _opus_decoder_ctl(st, OPUS_SET_GAIN_REQUEST, val)
  else
    Result := 0;
end;

function opus_decoder_ctl_get_last_packet_duration(st : pOpusDecoder;
  val : popus_int32) : cint;
begin
  if Assigned(_opus_decoder_ctl) then
    Result := _opus_decoder_ctl(st, OPUS_GET_LAST_PACKET_DURATION_REQUEST, val)
  else
    Result := 0;
end;

function opus_decoder_ctl_get_bitrate(st : pOpusDecoder; val : popus_int32
  ) : cint;
begin
  if Assigned(_opus_decoder_ctl) then
    Result := _opus_decoder_ctl(st, OPUS_GET_BITRATE_REQUEST, val)
  else
    Result := 0;
end;

procedure opus_decoder_destroy(st: pOpusDecoder);
begin
  if Assigned(_opus_decoder_destroy) then
    _opus_decoder_destroy(st);
end;

function opus_packet_parse(const data: pcuchar; len: opus_int32; out_toc: pcuchar; const frames: ppcuchar; size: popus_int16; payload_offset: pcint): cint;
begin
  if Assigned(_opus_packet_parse) then
    Result := _opus_packet_parse(data, len, out_toc, frames, size, payload_offset)
  else
    Result := 0;
end;

function opus_packet_get_bandwidth(const data: pcuchar): cint;
begin
  if Assigned(_opus_packet_get_bandwidth) then
    Result := _opus_packet_get_bandwidth(data)
  else
    Result := 0;
end;

function opus_packet_get_samples_per_frame(const data: pcuchar; Fs: opus_int32): cint;
begin
  if Assigned(_opus_packet_get_samples_per_frame) then
    Result := _opus_packet_get_samples_per_frame(data, Fs)
  else
    Result := 0;
end;

function opus_packet_get_nb_channels(const data: pcuchar): cint;
begin
  if Assigned(_opus_packet_get_nb_channels) then
    Result := _opus_packet_get_nb_channels(data)
  else
    Result := 0;
end;

function opus_packet_get_nb_frames(const packet: pcuchar; len: opus_int32): cint;
begin
  if Assigned(_opus_packet_get_nb_frames) then
    Result := _opus_packet_get_nb_frames(packet, len)
  else
    Result := 0;
end;

function opus_packet_get_nb_samples(const packet: pcuchar; len: opus_int32; Fs: opus_int32): cint;
begin
  if Assigned(_opus_packet_get_nb_samples) then
    Result := _opus_packet_get_nb_samples(packet, len, Fs)
  else
    Result := 0;
end;

function opus_decoder_get_nb_samples(const dec: pOpusDecoder; const packet: pcuchar; len: opus_int32): cint;
begin
  if Assigned(_opus_decoder_get_nb_samples) then
    Result := _opus_decoder_get_nb_samples(dec, packet, len)
  else
    Result := 0;
end;

procedure opus_pcm_soft_clip(pcm: pfloat; frame_size: cint; channels: cint; softclip_mem: pfloat);
begin
  if Assigned(_opus_pcm_soft_clip) then
    _opus_pcm_soft_clip(pcm, frame_size, channels, softclip_mem);
end;

function opus_repacketizer_get_size(): cint;
begin
  if Assigned(_opus_repacketizer_get_size) then
    Result := _opus_repacketizer_get_size()
  else
    Result := 0;
end;

function opus_repacketizer_init(rp: pOpusRepacketizer): pOpusRepacketizer;
begin
  if Assigned(_opus_repacketizer_init) then
    Result := _opus_repacketizer_init(rp)
  else
    Result := nil;
end;

function opus_repacketizer_create(): pOpusRepacketizer;
begin
  if Assigned(_opus_repacketizer_create) then
    Result := _opus_repacketizer_create()
  else
    Result := nil;
end;

procedure opus_repacketizer_destroy(rp: pOpusRepacketizer);
begin
  if Assigned(_opus_repacketizer_destroy) then
    _opus_repacketizer_destroy(rp);
end;

function opus_repacketizer_cat(rp: pOpusRepacketizer; const data: pcuchar; len: opus_int32): cint;
begin
  if Assigned(_opus_repacketizer_cat) then
    Result := _opus_repacketizer_cat(rp, data, len)
  else
    Result := 0;
end;

function opus_repacketizer_out_range(rp: pOpusRepacketizer; vbegin: cint; vend: cint; data: pcuchar; maxlen: opus_int32): opus_int32;
begin
  if Assigned(_opus_repacketizer_out_range) then
    Result := _opus_repacketizer_out_range(rp, vbegin, vend, data, maxlen)
  else
    Result := 0;
end;

function opus_repacketizer_get_nb_frames(rp: pOpusRepacketizer): cint;
begin
  if Assigned(_opus_repacketizer_get_nb_frames) then
    Result := _opus_repacketizer_get_nb_frames(rp)
  else
    Result := 0;
end;

function opus_repacketizer_out(rp: pOpusRepacketizer; data: pcuchar; maxlen: opus_int32): opus_int32;
begin
  if Assigned(_opus_repacketizer_out) then
    Result := _opus_repacketizer_out(rp, data, maxlen)
  else
    Result := 0;
end;

function opus_packet_pad(data: pcuchar; len: opus_int32; new_len: opus_int32): cint;
begin
  if Assigned(_opus_packet_pad) then
    Result := _opus_packet_pad(data, len, new_len)
  else
    Result := 0;
end;

function opus_packet_unpad(data: pcuchar; len: opus_int32): opus_int32;
begin
  if Assigned(_opus_packet_unpad) then
    Result := _opus_packet_unpad(data, len)
  else
    Result := 0;
end;

function opus_multistream_packet_pad(data: pcuchar; len: opus_int32; new_len: opus_int32; nb_streams: cint): cint;
begin
  if Assigned(_opus_multistream_packet_pad) then
    Result := _opus_multistream_packet_pad(data, len, new_len, nb_streams)
  else
    Result := 0;
end;

function opus_multistream_packet_unpad(data: pcuchar; len: opus_int32; nb_streams: cint): opus_int32;
begin
  if Assigned(_opus_multistream_packet_unpad) then
    Result := _opus_multistream_packet_unpad(data, len, nb_streams)
  else
    Result := 0;
end;

function ope_comments_create(): pOggOpusComments;
begin
  if Assigned(_ope_comments_create) then
    Result := _ope_comments_create()
  else
    Result := nil;
end;

function ope_comments_copy(comments: pOggOpusComments): pOggOpusComments;
begin
  if Assigned(_ope_comments_copy) then
    Result := _ope_comments_copy(comments)
  else
    Result := nil;
end;

procedure ope_comments_destroy(comments: pOggOpusComments);
begin
  if Assigned(_ope_comments_destroy) then
    _ope_comments_destroy(comments);
end;

function ope_comments_add(comments: pOggOpusComments; const tag: pcchar; const val: pcchar): cint;
begin
  if Assigned(_ope_comments_add) then
    Result := _ope_comments_add(comments, tag, val)
  else
    Result := 0;
end;

function ope_comments_add_string(comments: pOggOpusComments; const tag_and_val: pcchar): cint;
begin
  if Assigned(_ope_comments_add_string) then
    Result := _ope_comments_add_string(comments, tag_and_val)
  else
    Result := 0;
end;

function ope_comments_add_picture(comments: pOggOpusComments; const filename: pcchar; picture_type: cint; const description: pcchar): cint;
begin
  if Assigned(_ope_comments_add_picture) then
    Result := _ope_comments_add_picture(comments, filename, picture_type, description)
  else
    Result := 0;
end;

function ope_comments_add_picture_from_memory(comments: pOggOpusComments; const ptr: pcchar; size: csize_t; picture_type: cint; const description: pcchar): cint;
begin
  if Assigned(_ope_comments_add_picture_from_memory) then
    Result := _ope_comments_add_picture_from_memory(comments, ptr, size, picture_type, description)
  else
    Result := 0;
end;

function ope_encoder_create_file(const path: pcchar; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
begin
  if Assigned(_ope_encoder_create_file) then
    Result := _ope_encoder_create_file(path, comments, rate, channels, family, error)
  else
    Result := nil;
end;

function ope_encoder_create_callbacks(const callbacks: pOpusEncCallbacks; user_data: pointer; comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
begin
  if Assigned(_ope_encoder_create_callbacks) then
    Result := _ope_encoder_create_callbacks(callbacks, user_data, comments, rate, channels, family, error)
  else
    Result := nil;
end;

function ope_encoder_create_pull(comments: pOggOpusComments; rate: opus_int32; channels: cint; family: cint; error: pcint): pOggOpusEnc;
begin
  if Assigned(_ope_encoder_create_pull) then
    Result := _ope_encoder_create_pull(comments, rate, channels, family, error)
  else
    Result := nil;
end;

function ope_encoder_deferred_init_with_mapping(enc: pOggOpusEnc; family: cint; streams: cint; coupled_streams: cint; const mapping: pcuchar): cint;
begin
  if Assigned(_ope_encoder_deferred_init_with_mapping) then
    Result := _ope_encoder_deferred_init_with_mapping(enc, family, streams, coupled_streams, mapping)
  else
    Result := 0;
end;

function ope_encoder_write_float(enc: pOggOpusEnc; const pcm: pfloat; samples_per_channel: cint): cint;
begin
  if Assigned(_ope_encoder_write_float) then
    Result := _ope_encoder_write_float(enc, pcm, samples_per_channel)
  else
    Result := 0;
end;

function ope_encoder_write(enc: pOggOpusEnc; const pcm: popus_int16; samples_per_channel: cint): cint;
begin
  if Assigned(_ope_encoder_write) then
    Result := _ope_encoder_write(enc, pcm, samples_per_channel)
  else
    Result := 0;
end;

function ope_encoder_get_page(enc: pOggOpusEnc; page: ppcuchar; len: popus_int32; flush: cint): cint;
begin
  if Assigned(_ope_encoder_get_page) then
    Result := _ope_encoder_get_page(enc, page, len, flush)
  else
    Result := 0;
end;

function ope_encoder_drain(enc: pOggOpusEnc): cint;
begin
  if Assigned(_ope_encoder_drain) then
    Result := _ope_encoder_drain(enc)
  else
    Result := 0;
end;

procedure ope_encoder_destroy(enc: pOggOpusEnc);
begin
  if Assigned(_ope_encoder_destroy) then
    _ope_encoder_destroy(enc);
end;

function ope_encoder_chain_current(enc: pOggOpusEnc; comments: pOggOpusComments): cint;
begin
  if Assigned(_ope_encoder_chain_current) then
    Result := _ope_encoder_chain_current(enc, comments)
  else
    Result := 0;
end;

function ope_encoder_continue_new_file(enc: pOggOpusEnc; const path: pcchar; comments: pOggOpusComments): cint;
begin
  if Assigned(_ope_encoder_continue_new_file) then
    Result := _ope_encoder_continue_new_file(enc, path, comments)
  else
    Result := 0;
end;

function ope_encoder_continue_new_callbacks(enc: pOggOpusEnc; user_data: pointer; comments: pOggOpusComments): cint;
begin
  if Assigned(_ope_encoder_continue_new_callbacks) then
    Result := _ope_encoder_continue_new_callbacks(enc, user_data, comments)
  else
    Result := 0;
end;

function ope_encoder_flush_header(enc: pOggOpusEnc): cint;
begin
  if Assigned(_ope_encoder_flush_header) then
    Result := _ope_encoder_flush_header(enc)
  else
    Result := 0;
end;

function ope_encoder_ctl(enc: pOggOpusEnc; request: cint; Args : Array of const): cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, request{, Args})
  else
    Result := 0;
end;

function ope_encoder_ctl_set_serialno(enc : pOggOpusEnc; v : opus_int32) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPE_SET_SERIALNO_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_bitrate(enc : pOggOpusEnc; v : opus_int32) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_SET_BITRATE_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_vbr(enc : pOggOpusEnc; v : opus_int32) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_SET_VBR_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_vbr_constraint(enc : pOggOpusEnc; v : opus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_SET_VBR_CONSTRAINT_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_decision_delay(enc : pOggOpusEnc; v : opus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPE_SET_DECISION_DELAY_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_comment_padding(enc : pOggOpusEnc; v : opus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPE_SET_COMMENT_PADDING_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_set_complexity(enc : pOggOpusEnc; v : opus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_SET_COMPLEXITY_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_get_bitrate(enc : pOggOpusEnc; v : popus_int32) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_GET_BITRATE_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_get_complexity(enc : pOggOpusEnc; v : popus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_GET_COMPLEXITY_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_get_vbr(enc : pOggOpusEnc; v : popus_int32) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_GET_VBR_REQUEST, v)
  else
    Result := 0;
end;

function ope_encoder_ctl_get_final_range(enc : pOggOpusEnc; v : popus_int32
  ) : cint;
begin
  if Assigned(_ope_encoder_ctl) then
    Result := _ope_encoder_ctl(enc, OPUS_GET_FINAL_RANGE_REQUEST, v)
  else
    Result := 0;
end;

function ope_strerror(error: cint): pcchar;
begin
  if Assigned(_ope_strerror) then
    Result := _ope_strerror(error)
  else
    Result := nil;
end;

function ope_get_version_string(): pcchar;
begin
  if Assigned(_ope_get_version_string) then
    Result := _ope_get_version_string()
  else
    Result := nil;
end;

function ope_get_abi_version(): cint;
begin
  if Assigned(_ope_get_abi_version) then
    Result := _ope_get_abi_version()
  else
    Result := 0;
end;

function opus_head_parse(_head: pOpusHead; const _data: pcuchar; _len: csize_t): cint;
begin
  if Assigned(_opus_head_parse) then
    Result := _opus_head_parse(_head, _data, _len)
  else
    Result := 0;
end;

function opus_granule_sample(const _head: pOpusHead; _gp: ogg_int64_t): ogg_int64_t;
begin
  if Assigned(_opus_granule_sample) then
    Result := _opus_granule_sample(_head, _gp)
  else
    Result := 0;
end;

function opus_tags_parse(_tags: pOpusTags; const _data: pcuchar; _len: csize_t): cint;
begin
  if Assigned(_opus_tags_parse) then
    Result := _opus_tags_parse(_tags, _data, _len)
  else
    Result := 0;
end;

function opus_tags_copy(_dst: pOpusTags; const _src: pOpusTags): cint;
begin
  if Assigned(_opus_tags_copy) then
    Result := _opus_tags_copy(_dst, _src)
  else
    Result := 0;
end;

procedure opus_tags_init(_tags: pOpusTags);
begin
  if Assigned(_opus_tags_init) then
    _opus_tags_init(_tags);
end;

function opus_tags_add(_tags: pOpusTags; const _tag: pcchar; const _value: pcchar): cint;
begin
  if Assigned(_opus_tags_add) then
    Result := _opus_tags_add(_tags, _tag, _value)
  else
    Result := 0;
end;

function opus_tags_add_comment(_tags: pOpusTags; const _comment: pcchar): cint;
begin
  if Assigned(_opus_tags_add_comment) then
    Result := _opus_tags_add_comment(_tags, _comment)
  else
    Result := 0;
end;

function opus_tags_set_binary_suffix(_tags: pOpusTags; const _data: pcuchar; _len: cint): cint;
begin
  if Assigned(_opus_tags_set_binary_suffix) then
    Result := _opus_tags_set_binary_suffix(_tags, _data, _len)
  else
    Result := 0;
end;

function opus_tags_query(const _tags: pOpusTags; const _tag: pcchar; _count: cint): pcchar;
begin
  if Assigned(_opus_tags_query) then
    Result := _opus_tags_query(_tags, _tag, _count)
  else
    Result := nil;
end;

function opus_tags_query_count(const _tags: pOpusTags; const _tag: pcchar): cint;
begin
  if Assigned(_opus_tags_query_count) then
    Result := _opus_tags_query_count(_tags, _tag)
  else
    Result := 0;
end;

function opus_tags_get_binary_suffix(const _tags: pOpusTags; _len: pcint): pcuchar;
begin
  if Assigned(_opus_tags_get_binary_suffix) then
    Result := _opus_tags_get_binary_suffix(_tags, _len)
  else
    Result := nil;
end;

function opus_tags_get_album_gain(const _tags: pOpusTags; _gain_q8: pcint): cint;
begin
  if Assigned(_opus_tags_get_album_gain) then
    Result := _opus_tags_get_album_gain(_tags, _gain_q8)
  else
    Result := 0;
end;

function opus_tags_get_track_gain(const _tags: pOpusTags; _gain_q8: pcint): cint;
begin
  if Assigned(_opus_tags_get_track_gain) then
    Result := _opus_tags_get_track_gain(_tags, _gain_q8)
  else
    Result := 0;
end;

procedure opus_tags_clear(_tags: pOpusTags);
begin
  if Assigned(_opus_tags_clear) then
    _opus_tags_clear(_tags);
end;

function opus_tagcompare(const _tag_name: pcchar; const _comment: pcchar): cint;
begin
  if Assigned(_opus_tagcompare) then
    Result := _opus_tagcompare(_tag_name, _comment)
  else
    Result := 0;
end;

function opus_tagncompare(const _tag_name: pcchar; _tag_len: cint; const _comment: pcchar): cint;
begin
  if Assigned(_opus_tagncompare) then
    Result := _opus_tagncompare(_tag_name, _tag_len, _comment)
  else
    Result := 0;
end;

function opus_picture_tag_parse(_pic: pOpusPictureTag; const _tag: pcchar): cint;
begin
  if Assigned(_opus_picture_tag_parse) then
    Result := _opus_picture_tag_parse(_pic, _tag)
  else
    Result := 0;
end;

procedure opus_picture_tag_init(_pic: pOpusPictureTag);
begin
  if Assigned(_opus_picture_tag_init) then
    _opus_picture_tag_init(_pic);
end;

procedure opus_picture_tag_clear(_pic: pOpusPictureTag);
begin
  if Assigned(_opus_picture_tag_clear) then
    _opus_picture_tag_clear(_pic);
end;

function op_fopen(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar): pointer;
begin
  if Assigned(_op_fopen) then
    Result := _op_fopen(_cb, _path, _mode)
  else
    Result := nil;
end;

function op_fdopen(_cb: pOpusFileCallbacks; _fd: cint; const _mode: pcchar): pointer;
begin
  if Assigned(_op_fdopen) then
    Result := _op_fdopen(_cb, _fd, _mode)
  else
    Result := nil;
end;

function op_freopen(_cb: pOpusFileCallbacks; const _path: pcchar; const _mode: pcchar; _stream: pointer): pointer;
begin
  if Assigned(_op_freopen) then
    Result := _op_freopen(_cb, _path, _mode, _stream)
  else
    Result := nil;
end;

function op_mem_stream_create(_cb: pOpusFileCallbacks; const _data: pcuchar; _size: csize_t): pointer;
begin
  if Assigned(_op_mem_stream_create) then
    Result := _op_mem_stream_create(_cb, _data, _size)
  else
    Result := nil;
end;

function op_open_file(const _path: pcchar; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_open_file) then
    Result := _op_open_file(_path, _error)
  else
    Result := nil;
end;

function op_open_memory(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_open_memory) then
    Result := _op_open_memory(_data, _size, _error)
  else
    Result := nil;
end;

function op_open_callbacks(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_open_callbacks) then
    Result := _op_open_callbacks(_stream, _cb, _initial_data, _initial_bytes, _error)
  else
    Result := nil;
end;

function op_test_file(const _path: pcchar; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_test_file) then
    Result := _op_test_file(_path, _error)
  else
    Result := nil;
end;

function op_test_memory(const _data: pcuchar; _size: csize_t; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_test_memory) then
    Result := _op_test_memory(_data, _size, _error)
  else
    Result := nil;
end;

function op_test_callbacks(_stream: pointer; const _cb: pOpusFileCallbacks; const _initial_data: pcuchar; _initial_bytes: csize_t; _error: pcint): pOggOpusFile;
begin
  if Assigned(_op_test_callbacks) then
    Result := _op_test_callbacks(_stream, _cb, _initial_data, _initial_bytes, _error)
  else
    Result := nil;
end;

function op_test_open(_of: pOggOpusFile): cint;
begin
  if Assigned(_op_test_open) then
    Result := _op_test_open(_of)
  else
    Result := 0;
end;

procedure op_free(_of: pOggOpusFile);
begin
  if Assigned(_op_free) then
    _op_free(_of);
end;

function op_seekable(const _of: pOggOpusFile): cint;
begin
  if Assigned(_op_seekable) then
    Result := _op_seekable(_of)
  else
    Result := 0;
end;

function op_link_count(const _of: pOggOpusFile): cint;
begin
  if Assigned(_op_link_count) then
    Result := _op_link_count(_of)
  else
    Result := 0;
end;

function op_serialno(const _of: pOggOpusFile; _li: cint): opus_uint32;
begin
  if Assigned(_op_serialno) then
    Result := _op_serialno(_of, _li)
  else
    Result := 0;
end;

function op_channel_count(const _of: pOggOpusFile; _li: cint): cint;
begin
  if Assigned(_op_channel_count) then
    Result := _op_channel_count(_of, _li)
  else
    Result := 0;
end;

function op_raw_total(const _of: pOggOpusFile; _li: cint): opus_int64;
begin
  if Assigned(_op_raw_total) then
    Result := _op_raw_total(_of, _li)
  else
    Result := 0;
end;

function op_pcm_total(const _of: pOggOpusFile; _li: cint): ogg_int64_t;
begin
  if Assigned(_op_pcm_total) then
    Result := _op_pcm_total(_of, _li)
  else
    Result := 0;
end;

function op_head(const _of: pOggOpusFile; _li: cint): pOpusHead;
begin
  if Assigned(_op_head) then
    Result := _op_head(_of, _li)
  else
    Result := nil;
end;

function op_tags(const _of: pOggOpusFile; _li: cint): pOpusTags;
begin
  if Assigned(_op_tags) then
    Result := _op_tags(_of, _li)
  else
    Result := nil;
end;

function op_current_link(const _of: pOggOpusFile): cint;
begin
  if Assigned(_op_current_link) then
    Result := _op_current_link(_of)
  else
    Result := 0;
end;

function op_bitrate(const _of: pOggOpusFile; _li: cint): opus_int32;
begin
  if Assigned(_op_bitrate) then
    Result := _op_bitrate(_of, _li)
  else
    Result := 0;
end;

function op_bitrate_instant(_of: pOggOpusFile): opus_int32;
begin
  if Assigned(_op_bitrate_instant) then
    Result := _op_bitrate_instant(_of)
  else
    Result := 0;
end;

function op_raw_tell(const _of: pOggOpusFile): opus_int64;
begin
  if Assigned(_op_raw_tell) then
    Result := _op_raw_tell(_of)
  else
    Result := 0;
end;

function op_pcm_tell(const _of: pOggOpusFile): ogg_int64_t;
begin
  if Assigned(_op_pcm_tell) then
    Result := _op_pcm_tell(_of)
  else
    Result := 0;
end;

function op_raw_seek(_of: pOggOpusFile; _byte_offset: opus_int64): cint;
begin
  if Assigned(_op_raw_seek) then
    Result := _op_raw_seek(_of, _byte_offset)
  else
    Result := 0;
end;

function op_pcm_seek(_of: pOggOpusFile; _pcm_offset: ogg_int64_t): cint;
begin
  if Assigned(_op_pcm_seek) then
    Result := _op_pcm_seek(_of, _pcm_offset)
  else
    Result := 0;
end;

function op_set_gain_offset(_of: pOggOpusFile; _gain_type: cint; _gain_offset_q8: opus_int32): cint;
begin
  if Assigned(_op_set_gain_offset) then
    Result := _op_set_gain_offset(_of, _gain_type, _gain_offset_q8)
  else
    Result := 0;
end;

procedure op_set_dither_enabled(_of: pOggOpusFile; _enabled: cint);
begin
  if Assigned(_op_set_dither_enabled) then
    _op_set_dither_enabled(_of, _enabled);
end;

function op_read(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint; _li: pcint): cint;
begin
  if Assigned(_op_read) then
    Result := _op_read(_of, _pcm, _buf_size, _li)
  else
    Result := 0;
end;

function op_read_float(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint; _li: pcint): cint;
begin
  if Assigned(_op_read_float) then
    Result := _op_read_float(_of, _pcm, _buf_size, _li)
  else
    Result := 0;
end;

function op_read_stereo(_of: pOggOpusFile; _pcm: popus_int16; _buf_size: cint): cint;
begin
  if Assigned(_op_read_stereo) then
    Result := _op_read_stereo(_of, _pcm, _buf_size)
  else
    Result := 0;
end;

function op_read_float_stereo(_of: pOggOpusFile; _pcm: pfloat; _buf_size: cint): cint;
begin
  if Assigned(_op_read_float_stereo) then
    Result := _op_read_float_stereo(_of, _pcm, _buf_size)
  else
    Result := 0;
end;

end.
