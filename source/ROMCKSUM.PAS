{ --------------------------------------------------------------------------- }
{ - ROM Checksum Calculator (romcksum.pas)                                  - }
{ - Copyright (C) 1998-2021 Alexandru Groza of Microprogramming TECHNIQUES  - }
{ - All rights reserved.                                                    - }
{ --------------------------------------------------------------------------- }
{ - License: GNU General Public License v3.0                                - }
{ --------------------------------------------------------------------------- }

program romcksum;

uses
  Crt;

const
  { program stringtable }
  sEmpty                  = '';

  sProgramTitle           = 'ROM Checksum Calculator  VER: 0.2 REV: A';
  sProgramCopyright       = 'Copyright (C) 1998-2021 Microprogramming TECHNIQUES';
  sProgramAuthor          = 'Programming/PC Code: Alexandru Groza';
  sProgramRights          = 'All rights reserved.';

  sParameterMissing       = 'Filename parameter incorrect or missing.';

  sTypeHelp               = 'Type:' + #13#10 +
                            '  romcksum.exe -help';
  sHelpUsage              = 'Usage is:' + #13#10 +
                            '  romcksum.exe [-help] <romfile.bin>' + #13#10;
  sHelpParameters1        = 'Where:' + #13#10 +
                            '  -help          shows this screen; all other parameters are ignored' + #13#10 +
                            '  <romfile.bin>  is the actual ROM file for checksum calculation';

  sCannotOpenInputFile    = 'Cannot open input file ';
  sCannotReadInputFile    = 'Cannot read input file ';
  sCannotWriteChecksum    = 'Cannot write checksum ';

  sROMChecksum            = 'ROM Checksum: ';

  { program commandline parameters }
  pHelp                   = '-help';

  { color constants }
  clError                 = Red;
  clNormal                = LightGray;
  clHighlight             = White;

  { file mode constants }
  fmReadOnly              = 0;
  fmWriteOnly             = 1;
  fmReadWrite             = 2;

function IntToHex(const AInteger: Integer): String;
const
  kHexLength = 4;
  kHexDigits: array[$00..$0F] of Char = '0123456789ABCDEF';

var
  I: Integer;
  LInteger: Integer;

begin
  LInteger := AInteger;

  IntToHex[0] := Char(kHexLength);

  for I := kHexLength downto 1 do
  begin
    IntToHex[I] := kHexDigits[LInteger and $0F];
    LInteger := LInteger shr $04;
  end;
end;

procedure WriteProgramHeader;
begin
  TextColor(clHighlight);
  Writeln;
  Writeln(sProgramTitle);

  TextColor(clNormal);
  Writeln(sProgramCopyright);
  Writeln(sProgramAuthor);
  Writeln(sProgramRights);
  Writeln;
end;

procedure WriteHelp;
begin
  Writeln(sHelpUsage);
  Writeln(sHelpParameters1);
end;

procedure WriteParameterErrors;
begin
  TextColor(clError);
  Writeln(sParameterMissing);

  TextColor(clNormal);
  Writeln;
  Writeln(sTypeHelp);
end;

function CalculateROMChecksum(const AFileName: String; var AChecksum: Byte;
  const AWriteChecksum: Boolean): Boolean;
var
  I: Longint;
  LByte: Byte;
  LInputFile: File of Byte;

begin
  AChecksum := 0;
  CalculateROMChecksum := False;
{$I-}
  Assign(LInputFile, AFileName);
  FileMode := fmReadWrite;
  Reset(LInputFile);
{$I+}
  if IOResult <> 0 then
  begin
    Writeln(sCannotOpenInputFile, AFileName);
{$I-}
    Close(LInputFile);
{$I+}
    Exit;
  end;

  for I := 0 to Pred(Pred(FileSize(LInputFile))) do
  begin
{$I-}
    Read(LInputFile, LByte);
{$I+}
    if IOResult <> 0 then
    begin
      Writeln(sCannotReadInputFile, AFileName);
{$I-}
      Close(LInputFile);
{$I+}
      Exit;
    end;

    AChecksum := AChecksum + LByte;
  end;

  AChecksum := (256 - AChecksum) mod 256;

  if AWriteChecksum then
  begin
{$I-}
    Write(LInputFile, AChecksum);
{$I+}
    if IOResult <> 0 then
    begin
      Writeln(sCannotWriteChecksum, AFileName);
{$I-}
      Close(LInputFile);
{$I+}
      Exit;
    end;
  end;
{$I-}
  Close(LInputFile);
{$I+}
  CalculateROMChecksum := True;
end;

var
  GChecksum: Byte;
  LFileName: String;

begin
  WriteProgramHeader;

  if (ParamCount > 0) and (ParamStr(1) = pHelp) then
  begin
    WriteHelp;
  end else
  begin
    LFileName := ParamStr(1);
    if (LFileName <> sEmpty) and (CalculateROMChecksum(LFileName, GChecksum, True)) then
    begin
      Writeln(sROMChecksum, IntToHex(GChecksum));
    end else
    begin
      WriteParameterErrors;
    end;
  end;
end.
