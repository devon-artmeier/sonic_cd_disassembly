# Sonic CD Disassembly

**NOTICE**: This disassembly is currently being totally refactored, and thus is far from complete. Go here for [the old version](https://github.com/DevsArchive/sonic-cd-disassembly), which can be built.

## Requirements

* make
* [vasm](http://sun.hasenbraten.de/vasm/)
  * M68k CPU, Motorola syntax
  * Z80 CPU, old style syntax
* [vlink](http://sun.hasenbraten.de/vlink/)
* [extract_asm_symbols](https://github.com/devon-artmeier/extract_asm_symbols)
* [make_asm_depend](https://github.com/devon-artmeier/make_asm_depend)
* [sonic_cd_file_tool](https://github.com/devon-artmeier/sonic_cd_file_tool)
* mkisofs (from [cdrtools](https://sourceforge.net/projects/cdrtools/))

## Building

Make sure the required tools are built and can be called from the root of this disassembly. When running the Makefile, you must set which region to build like one of the following:

~~~
make REGION=JAPAN
~~~
~~~
make REGION=USA
~~~
~~~
make REGION=EUROPE
~~~

## Special Thanks

Special thanks to flamewing and TheStoneBanana for helping out and contributing, especially for R11A in the disassembly's infancy stages back in 2015.
