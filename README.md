# ROM Checksum Calculator

This project is also known as either ```romcksum``` or ```romcksum32```, depending on the target operating system.

## Synopsis

The ROM Checksum Calculator program calculates the 8-bit checksum of binary ROM files.\
It can also make a test on the ROM file to see if it actually is a valid OPTION ROM.\
At the end of the calculation the checksum byte is updated in the binary file.

There are two programs available, one for 16-bit MS-DOS (```romcksum.exe```) and one for 32-bit Windows (```romcksum32.exe```).

### romcksum Program Usage

The following lines are taken directly from the commandline help screen.

```
Usage is:
  romcksum.exe [-help] <romfile.bin>

Where:
  -help          shows this screen; all other parameters are ignored
  <romfile.bin>  is the actual ROM file for checksum calculation
```

### romcksum32 Program Usage

The following lines are taken directly from the commandline help screen.

```
Usage is:
  romcksum32.exe [-o] <romfile.bin>

Where -o is an optional parameter.
If issued, the file will be tested to see if it is a valid OPTION ROM.
```
