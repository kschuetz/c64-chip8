# C64 Chip 8

An emulation of the [CHIP-8](https://en.wikipedia.org/wiki/CHIP-8) that runs on the Commodore 64 (NTSC or PAL).

## Download

[**Download .PRG format**](https://kschuetz.github.io/c64-chip8/downloads/chip8.prg)

[**Download .D64 disk format**](https://kschuetz.github.io/c64-chip8/downloads/chip8.d64.zip)

## Instructions

The keys 1, 2, 3, 4, Q, W, E, R, A, S, D, F, Z, X, C, and V correspond to the 16 keys of the CHIP-8.

The following additional functions are available:

**F1** - Reset

**F3** - Go to previous ROM

**F5** - Go to next ROM

**F7** - Pause/Resume

**K** - Toggle key delay mode

**P** - Cycle pixel styles

**N** - Cycle background color

**M** - Cycle foreground color

**U** - Toggle sound

## Build Instructions

At a minimum, you need the following on your system:

- The ca65 assembler and ld65 linker from the [cc65 toolchain](http://cc65.github.io/cc65/)
- [GNU Make](https://www.gnu.org/software/make/)

Running `make` in the project directory will generate the .PRG file in `build/chip8.prg`.

Optionally, to compress the .PRG and make a .D64, you will need the following:

- [VICE](https://sourceforge.net/projects/vice-emu/files/)
- [Exomizer](https://bitbucket.org/magli143/exomizer/wiki/Home)

`make release` will place the compressed .PRG and the .D64 into the `dist` directory.

## Included ROMs

Included in this repository (in the `roms` directory) is the Chip-8 Program Pack from Revival Studios
(thanks to the https://github.com/dmatlack/chip8 repository).

The whole collection won't fit in the 64K of RAM available, but a good portion of them will.

The bundled ROM selection can be edited in `source/externalroms.s`.

Information about the ROMs and credit for the authors can be found in the `.txt` files in the `roms` directory.

## Reference

- [Cowgod's Chip-8 Technical Reference 1.0](http://devernay.free.fr/hacks/chip8/C8TECH10.HTM)

## Screenshots

![Title Screen](https://kschuetz.github.io/c64-chip8/screenshots/title-screen.png)

![Blinky](https://kschuetz.github.io/c64-chip8/screenshots/blinky.png)

![Space Invaders](https://kschuetz.github.io/c64-chip8/screenshots/space-invaders.png)

![Tetris](https://kschuetz.github.io/c64-chip8/screenshots/tetris.png)

![Hidden](https://kschuetz.github.io/c64-chip8/screenshots/hidden.png)

## License

The MIT License (MIT)

Copyright © 2018 Kevin Schuetz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
