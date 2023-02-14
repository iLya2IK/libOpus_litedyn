{
   OpusStreaming example - part of libOpus_dyn

   Copyright 2023 Ilya Medvedkov

   In this example, an opus-ogg file (named cInputFile) is opened and decoded
   into a data stream. The resulting stream is then re-encoded into a set of
   Opus packages. A set of packages is saved to a file on disk (cStreamFile) in
   the user's format. A file with a set of packages is opened, decoded into a
   data stream and saved in a new file in opus-ogg format (cOutputFile).

   step 1.
   cInputFile->OpusOggDecoder->[pcm]->OpusEncoder->[packets...]->cStreamFile
   step 2.
   cStreamFile->OpusDecoder->[pcm]->OpusOggEncoder->[ogg container]->cOutputFile
}

program opusstreaming;

uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLOpusWrapper, OGLOGGWrapper, OGLSoundUtils, OGLSoundUtilTypes;

const // the name of source opus-ogg file
      cInputFile  = '..' + PathDelim + 'media' + PathDelim + 'testing.opus';
      // the name of the intermediate file with encoded packets in user`s format
      cStreamFile = '..' + PathDelim + 'media' + PathDelim + 'opuspackets.stream';
      // the name of dest reencoded opus-ogg file
      cOutputFile = '..' + PathDelim + 'media' + PathDelim + 'output.opus';
      {$ifdef Windows}
      cOpusDLL : Array [0..2] of String = ('..\libs\opus.dll',
                                           '..\libs\opusenc.dll',
                                           '..\libs\opusfile.dll');
      {$endif}
      // duration of data chunk to encode
      cDur : TOpusFrameSize = ofs_20ms;
      {$ifdef DEBUG}
      cHeapTrace = 'heaptrace.trc';
      {$endif}

var
  oggf : TOpusFile; // interface to encode/decode Opus-Ogg data
  pack_enc : ISoundStreamEncoder; // opus custom streaming encoder
  pack_dec : ISoundStreamDecoder; // opus custom streaming decoder
  aFileStream : TFileStream;     // TFileStream linked to cStreamFile
  Buffer : Pointer;              // intermediate buffer
  bitrate : Integer;             // current bitrate
  frame_size : ISoundFrameSize;
  len : ISoundFrameSize;         // length of writed/read data
  aEncProp : ISoundEncoderProps;
begin
  {$ifdef DEBUG}
  if FileExists(cHeapTrace) then
     DeleteFile(cHeapTrace);
  SetHeapTraceOutput(cHeapTrace);
  {$endif}

  // Initialize opus, opusenc, opusfile interfaces - load libraries
  {$ifdef Windows}
  if TOpus.OpusLibsLoad(cOpusDLL) then
  {$else}
  if TOpus.OpusLibsLoadDefault then
  {$endif}
  begin
    // Create Opus-Ogg encoder/decoder interface
    oggf := TOpusFile.Create;
    try
      // Config TOpusFile to decoder state (opusfile mode)
      if oggf.LoadFromFile(cInputFile, false) then
      begin
        // cInputFile opended and headers/coments are loaded
        // create framesize from cDur
        frame_size := oggf.Decoder.FrameFromDuration(TOpus.FrameSizeToTime(cDur));
        // get the file bitrate from opus-ogg decoder
        bitrate := oggf.Decoder.Bitrate;

        // gen encoder properties
        // complexity = 5, max packet duration = 120 ms,
        aEncProp := TOGLSound.EncProps([TOGLSound.PROP_MODE, oemVBR,
                                        TOGLSound.PROP_CHANNELS, oggf.Channels,
                                        TOGLSound.PROP_FREQUENCY, oggf.Frequency,
                                        TOGLSound.PROP_BITRATE, bitrate,
                                        TOpus.PROP_COMPLEXITY, 5,
                                        // for streaming encoder:
                                        TOpus.PROP_MAX_PACKET_DURATION_MS, 120,
                                        // there's no necessity for that. just for an example:
                                        TOpus.PROP_HEADER_TYPE, ophState]);

        // initialize intermediate buffer to store decoded data chunk
        Buffer := GetMem(frame_size.AsBytes);
        try
          // create/open to write cStreamFile
          aFileStream := TFileStream.Create(cStreamFile, fmOpenWrite or fmCreate);
          try
            // initialize custom streaming encoder
            // header type - default (ophState: every header contains
            //                        len, freq, numofchannels: 6 bytes total)
            // to change header type set the PacketHeaderType property
            //   or set another value for TOpus.PROP_HEADER_TYPE (look above)
            //   or redefine the OnPacketWriteHeader property
            pack_enc := TOpus.NewStreamEncoder(aFileStream, aEncProp);
            try
              repeat
                // read decoded pcm data from opus-ogg file
                // len - length of decoded data
                len := oggf.ReadData(Buffer, frame_size, nil);

                if len.IsValid then
                begin
                  // this is where pcm data is encoded into the opus frame.
                  // the encoded frames are automatically packaged into a set of
                  // packets, and then written to the stream file as a sequence:
                  // [packet1_header][paket1_data][packet2_header][paket2_data]...[packetN_header][paketN_data]
                  pack_enc.WriteData(Buffer, len, nil);
                end;
              until len.Less(frame_size);
              // complete the stream formation process.
              // write the packets that are in the cache.
              pack_enc.Close(nil);
            finally
              pack_enc := nil;
            end;
          finally
            aFileStream.Free;
          end;
        finally
          FreeMemAndNil(Buffer);
        end;

        // Config TOpusFile to encode state (opusenc mode)
        // and create/open to write cOutputFile
        // same encoder properties
        if oggf.SaveToFile(cOutputFile, aEncProp, nil) then
        begin
          // cOutputFile has been created/opened and headers/comments have
          // been
          // open file stream to read from cStreamFile
          aFileStream := TFileStream.Create(cStreamFile, fmOpenRead);
          try
            // get size of cDur in bytes
            frame_size := oggf.Encoder.FrameFromDuration(TOpus.FrameSizeToTime(cDur));
            // initialize intermediate buffer to store decoded data chunk
            Buffer := GetMem(frame_size.AsBytes);
            try
              // initialize custom streaming decoder
              // header type - default (ophState: every header contains
              //                        len, freq, numofchannels: 6 bytes total)
              // to change header type set the PacketHeaderType property
              // or redefine the OnPacketReadHeader property
              pack_dec := TOpus.NewStreamDecoder(aFileStream,
                                                             oggf.Frequency,
                                                             oggf.Channels);
              try
                repeat
                  // read decoded pcm data from opus streaming file
                  // len - length of decoded data in samples per channels
                  len := pack_dec.ReadData(Buffer, frame_size, nil);

                  if len.IsValid then begin
                    // this is where pcm data samples are encoded into the
                    // opus-ogg format and then written to the opus-ogg file.
                    oggf.WriteData(Buffer, len, nil);
                  end;

                until len.Less(frame_size);
              finally
                pack_dec := nil;
              end;
            finally
              FreeMemAndNil(Buffer);
            end;
            // complete the ogg stream formation process.
            // write the ogg data that is in the cache.
            oggf.StopStreaming;
          finally
            aFileStream.Free;
          end;
        end;
      end;
    finally
      oggf.Free;
    end;
    // close opus interfaces
    TOpus.OpusLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
end.

