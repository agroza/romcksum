{ --------------------------------------------------------------------------- }
{ - ROM Checksum Calculator (romcksum32.dpr)                                - }
{ - Copyright (C) 1998-2020 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

program romcksum32;

{$APPTYPE CONSOLE}

{$R RES\romcksum32.res}

uses
  SysUtils, Classes;

const
  { program constants }
  kOptionROMSignature    = $AA55;
  kBytesPerBlock         = 512;

  k1KiB                  = 1024;

  { program stringtable }
  sProgramTitle          = 'ROM Checksum Calculator  VER: 0.2 REV: D';
  sProgramCopyright      = 'Copyright (C) 1998-2021 Microprogramming TECHNIQUES';
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

  sROMFileNotFound       = 'ROM file "%s" not found.';
  sROMFile               = 'ROM file     : %s';
  sROMFileDiskSize       = 'Disk size    : %d (%d KiB)';
  sROMFileOptionROM      = 'Option ROM   : %s';
  sROMFileROMBlocks      = 'ROM blocks   : %d, %d (%d KiB), %s';
  sROMUsage              = 'ROM usage    : %2f%% (%d/%d)';
  sROMChecksum           = 'ROM checksum : 0x%xh (8-bit)';
  sROMChecksumUpdated    = 'ROM file checksum updated.';
  sROMChecksumNotUpdated = 'ROM file checksum not updated.';

  sYESNO: array[Boolean] of String = (
    'NO',
    'YES'
  );

  sWRONGCORRECT: array[Boolean] of String = (
    'WRONG',
    'CORRECT'
  );

function CalculateROMUsage(const AROMData: array of Byte): Integer;
var
  I: Integer;

begin
  Result := Length(AROMData);

  for I := Pred(Result) downto 0 do
  begin
    if AROMData[I] = $00 then
    begin
      Dec(Result);
    end else
    begin
      Break;
    end;
  end;

  Inc(Result);
end;

function CalculateROMChecksum(const AROMData: array of Byte): Byte;
var
  I: Integer;

begin
  Result := 0;

  for I := 0 to Pred(Length(AROMData)) do
    Result := Result + AROMData[I];

  Result := (256 - Result) mod 256;
end;

procedure CalculateUpdateChecksum(const AFileName: String; const ATestOptionROM: Boolean);
var
  LOnlyFileName: String;
  LFileStream: TFileStream;
  LFileSize: Int64;
  LFileSizeKiB: Integer;

  LOptionROMSignature: Word;
  LOptionROMBlocks: Byte;
  LOptionROMSize: Integer;
  LOptionROMSizeKiB: Integer;

  LROMData: array of Byte;
  LBytesUsed: Integer;
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

    Writeln(Format(sROMFile, [LOnlyFileName]));
    Writeln(Format(sROMFileDiskSize, [LFileSize, LFileSizeKiB]));

    if ATestOptionROM then
    begin
      LFileStream.Seek(0, soFromBeginning);
      LFileStream.Read(LOptionROMSignature, SizeOf(LOptionROMSignature));
      Writeln(Format(sROMFileOptionROM, [sYESNO[LOptionROMSignature = kOptionROMSignature]]));

      LFileStream.Read(LOptionROMBlocks, SizeOf(LOptionROMBlocks));
      LOptionROMSize := LOptionROMBlocks * kBytesPerBlock;
      LOptionROMSizeKiB := LOptionROMSize div k1KiB;
      Writeln(Format(sROMFileROMBlocks, [LOptionROMBlocks, LOptionROMSize, LOptionROMSizeKiB, sWRONGCORRECT[LOptionROMSize = LFileSize]]));
    end;

    SetLength(LROMData, LFileSize);

    LFileStream.Seek(0, soFromBeginning);
    LFileStream.Read(LROMData[0], Pred(Length(LROMData)));

    LBytesUsed := CalculateROMUsage(LROMData);
    Writeln(Format(sROMUsage, [(LBytesUsed / LFileSize) * 100, LBytesUsed, LFileSize]));

    LROMChecksum := CalculateROMChecksum(LROMData);
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
