{ --------------------------------------------------------------------------- }
{ - ROM Checksum Calculator (romcksum.dpr)                                  - }
{ - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }
program romcksum;

{$APPTYPE CONSOLE}

{$R RES\romcksum.res}

uses
  SysUtils, Classes;

const
  { program constants }
  kOptionROMSignature    = $AA55;
  kBytesPerBlock         = 512;

  k1KiB                  = 1024;

  { program stringtable }
  sProgramTitle          = 'ROM Checksum Calculator  VER: 0.2 REV: A';
  sProgramCopyright      = 'Copyright (C) 1998-2020 Microprogramming TECHNIQUES';
  sProgramAuthor         = 'Programming/PC Code: Alexandru Groza';
  sProgramRights         = 'All rights reserved.';

  sParametersMissing     = 'Parameters missing.' + #13#10#10 +
                           'Usage is:' + #13#10 +
                           '  %s [-o] <romfile.bin>' + #13#10#10 +
                           'Where -o is an optional parameter.' + #13#10 +
                           'If issued, the file will be tested to see if it is a valid OPTION ROM.';
  sParameterIgnored      = 'Unexpected "%s" parameter ignored.' + #13#10;                         

  pDelimiter             = '-';
  pTestOptionROM         = 'O';

  sROMFileNotFound       = 'ROM file: %s not found.';
  sROMFile               = 'ROM file: %s has a disk size of %d (%d KiB).';
  sROMFileIsOptionROM    = 'ROM file: %s is an OPTION ROM.';
  sROMFileIsNotOptionROM = 'ROM file: %s is not an OPTION ROM.';
  sROMFileCorrectSize    = 'ROM file: %s has a correct size of %d (%d KiB).';
  sROMFileWrongSize      = 'ROM file: %s has a wrong size of %d (%d KiB) instead of %d (%d KiB).';
  sROMChecksum           = 'ROM checksum: 0x%xh (8-bit)';
  sROMChecksumUpdated    = 'ROM file checksum updated.';
  sROMChecksumNotUpdated = 'ROM file checksum not updated.';

procedure CalculateUpdateChecksum(const AFileName: String; const ATestOptionROM: Boolean);
var
  I: Integer;

  LOnlyFileName: String;
  LFileStream: TFileStream;
  LFileSize: Int64;
  LFileSizeKiB: Integer;

  LOptionROMSignature: Word;
  LOptionROMBlocks: Byte;
  LOptionROMSize: Integer;
  LOptionROMSizeKiB: Integer;

  LROMData: array of Byte;
  LROMChecksum: Byte;
  LROMTestChecksum: Byte;

begin
  LOnlyFileName := ExtractFileName(AFileName);

  if not FileExists(AFileName) then
  begin
    Writeln(Format(sROMFileNotFound, [LOnlyFileName]));
    Exit;
  end;

  LFileStream := nil;
  try
    LFileStream := TFileStream.Create(AFileName, fmOpenReadWrite);
    LFileSize := LFileStream.Size;
    LFileSizeKiB := LFileSize div k1KiB;

    Writeln(Format(sROMFile, [LOnlyFileName, LFileSize, LFileSizeKiB]));

    if ATestOptionROM then
    begin
      LFileStream.Seek(0, soFromBeginning);
      LFileStream.Read(LOptionROMSignature, SizeOf(LOptionROMSignature));
      if LOptionROMSignature = kOptionROMSignature then
      begin
        Writeln(Format(sROMFileIsOptionROM, [LOnlyFileName]));
      end else
      begin
        Writeln(Format(sROMFileIsNotOptionROM, [LOnlyFileName]));
      end;

      LFileStream.Read(LOptionROMBlocks, SizeOf(LOptionROMBlocks));
      LOptionROMSize := LOptionROMBlocks * kBytesPerBlock;
      LOptionROMSizeKiB := LOptionROMSize div k1KiB;

      if LOptionROMSize = LFileSize then
      begin
        Writeln(Format(sROMFileCorrectSize, [LOnlyFileName, LOptionROMSize, LOptionROMSizeKiB]));
      end else
      begin
        Writeln(Format(sROMFileWrongSize, [LOnlyFileName, LFileSize, LFileSizeKiB, LOptionROMSize, LOptionROMSizeKiB]));
      end;
    end;

    SetLength(LROMData, LFileSize);

    LFileStream.Seek(0, soFromBeginning);
    LFileStream.Read(LROMData[0], Pred(Length(LROMData)));

    LROMChecksum := 0;
    for I := 0 to Pred(Length(LROMData)) do
      LROMChecksum := LROMChecksum + LROMData[I];
    LROMChecksum := (256 - LROMChecksum) mod 256;

    Writeln(Format(sROMChecksum, [LROMChecksum]));

    LFileStream.Seek(-SizeOf(LROMChecksum), soFromEnd);
    LFileStream.Write(LROMChecksum, SizeOf(LROMChecksum));

    LFileStream.Seek(-SizeOf(LROMTestChecksum), soFromEnd);
    LFileStream.Read(LROMTestChecksum, SizeOf(LROMTestChecksum));

    Writeln;
    if LROMChecksum = LROMTestChecksum then
    begin
      Writeln(sROMChecksumUpdated);
    end else
    begin
      Writeln(sROMChecksumNotUpdated);
    end;
  finally
    LFileStream.Free;
  end;
end;

var
  GTestOptionROM: Boolean;

begin
  Writeln;
  Writeln(sProgramTitle);
  Writeln(sProgramCopyright);
  Writeln(sProgramAuthor);
  Writeln(sProgramRights);
  Writeln;

  case ParamCount of
    0:
      Writeln(Format(sParametersMissing, [ExtractFileName(ParamStr(0))]));

    1:
      CalculateUpdateChecksum(ParamStr(1), False);

    2..MaxInt:
      begin
        GTestOptionROM := (ParamStr(1)[1] = pDelimiter) and (UpCase(ParamStr(1)[2]) = pTestOptionROM);
        if not GTestOptionROM then
          Writeln(Format(sParameterIgnored, [ParamStr(1)]));

        CalculateUpdateChecksum(ParamStr(2), GTestOptionROM);
      end;

  end;
end.
