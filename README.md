# romcksum
ROM Checksum Calculator

This program calculates the 8-bit checksum of binary ROM files.\
It can also make a test on the ROM file to see if it actually is a valid OPTION ROM.\
At the end of the calculation the checksum byte is updated in the binary file.

```
Usage is:
  romcksum.exe [-o] <romfile.bin>

Where -o is an optional parameter.
If issued, the file will be tested to see if it is a valid OPTION ROM.
```
