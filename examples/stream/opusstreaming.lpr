program opusstreaming;

uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLOpusWrapper, OGLOGGWrapper;

const cInputFile  = '..' + PathDelim + 'media' + PathDelim + 'testing.opus';
      cStreamFile = '..' + PathDelim + 'media' + PathDelim + 'opuspackets.stream';
      cOutputFile = '..' + PathDelim + 'media' + PathDelim + 'output.opus';
      {$ifdef Windows}
      cOpusDLL : Array [0..2] of String = ('..\libs\opus.dll',
                                           '..\libs\opusenc.dll',
                                           '..\libs\opusfile.dll');
      {$endif}
      Dur : TOpusFrameSize = ofs_20ms;

var
  oggf : TOpusFile;
  pack_enc : TOpusStreamEncoder;
  pack_dec : TOpusStreamDecoder;
  aFileStream : TFileStream;
  Buffer : Pointer;
  len, max_len, bitrate : Integer;
begin
  {$ifdef Windows}
  if TOpus.OpusLibsLoad(cOpusDLL) then
  {$else}
  if TOpus.OpusLibsLoadDefault then
  {$endif}
  begin
    oggf := TOpusFile.Create;
    try
      if oggf.LoadFromFile(cInputFile, false) then
      begin
        max_len := TOpus.MinBufferSizeInt16(oggf.Frequency, oggf.Channels, Dur);
        bitrate := oggf.Decoder.Bitrate;

        Buffer := GetMem(max_len);
        try
          aFileStream := TFileStream.Create(cStreamFile, fmOpenWrite or fmCreate);
          try
            pack_enc := TOpusStreamEncoder.Create(aFileStream, oemVBR,
                                                           oggf.Channels,
                                                           oggf.Frequency,
                                                           bitrate, 5,
                                                           120);
            try
              repeat
                len := oggf.ReadData(Buffer, max_len, nil);

                if len > 0 then
                begin
                  pack_enc.WriteInt16(Buffer,
                                      pack_enc.Encoder.BytesToFrameSize(len,
                                                                        false));
                end;
              until len < max_len;

              pack_enc.Close;
            finally
              pack_enc.Free;
            end;
          finally
            aFileStream.Free;
          end;
        finally
          FreeMemAndNil(Buffer);
        end;

        if oggf.SaveToFile(cOutputFile, oemVBR, oggf.Channels,
                                                oggf.Frequency,
                                                bitrate, 16, 0.5, nil) then
        begin
          aFileStream := TFileStream.Create(cStreamFile, fmOpenRead);
          try
            max_len := TOpus.MinBufferSizeInt16(oggf.Frequency, oggf.Channels,
                                                                Dur);

            Buffer := GetMem(max_len);

            try
              pack_dec := TOpusStreamDecoder.Create(aFileStream,
                                                             oggf.Frequency,
                                                             oggf.Channels);
              try
                repeat
                  len := pack_dec.ReadDataInt16(Buffer, max_len);

                  if len > 0 then begin
                    oggf.WriteSamples(Buffer, len, nil);
                  end;

                until len < pack_dec.Decoder.BytesToSamples(max_len, false);
              finally
                pack_dec.Free;
              end;
            finally
              FreeMemAndNil(Buffer);
            end;

            oggf.StopStreaming;
          finally
            aFileStream.Free;
          end;
        end;
      end;
    finally
      oggf.Free;
    end;

    TOpus.OpusLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
end.

