{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit libopus_ilya2ik;

{$warn 5023 off : no warning about unused units}
interface

uses
  OGLOpusWrapper, libopus_dynlite, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('libopus_ilya2ik', @Register);
end.
