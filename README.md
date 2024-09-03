# Gerbv-2.10.0 for windows multilingual -- build tools
---------------------------------------------
## What is this
This is a build tool for [Gerbv-2.10.0](https://github.com/gerbv/gerbv) executable on MS-Windows.  
Also executable binaries are in [Releases](https://github.com/kitanokitsune/gerbv_for_win_multilingual/releases) pages.

## Supported features
[These patches](./patch) are applied.
+ Support non-ASCII path and filename
+ Support slotted hole (patch from [sourceforge](https://sourceforge.net/p/gerbv/bugs/258/))

<img src="./route_slot.png" width="600px" alt="route_slot" title="route_slot">

## Build prerequisites
If you want to build __gerbv__ yourself, the followings are required.
+ MSYS2 + binutils + gcc (such as [i686-8.1.0-release-win32-dwarf-rt_v6-rev0](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/8.1.0/threads-win32/dwarf/i686-8.1.0-release-win32-dwarf-rt_v6-rev0.7z)  / [x86_64-8.1.0-release-win32-seh-rt_v6-rev0](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-win32/seh/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z) ) + etc.
+ [gerbv-2.10.0.tar.gz](https://github.com/gerbv/gerbv/releases/tag/v2.10.0) source file
+ [dxflib-3.26.4-src.tar.gz](https://qcad.org/en/dxflib-downloads) source file
+ [gtk+-2.24.33](https://github.com/kitanokitsune/gtk2.24-win-static-library-builder/releases) library

## How to build Gerbv-2.10.0 for win multilingual
1. Extract or `git pull` this project into some directory.
2. Put **dxflib-3.26.4-src.tar.gz** and **gerbv-2.10.0.tar.gz** into the above directory.
3. Edit **Makefile** as you need.
4. Execute command `make` in the directory.

## How to localize
1. Copy **gerbv.pot** to a file named ***&lt;lang&gt;***__.po__, where *&lt;lang&gt;* is a *[Language Code](https://www.gnu.org/software/gettext/manual/html_node/Usual-Language-Codes.html)*.
2. Edit translations in ***&lt;lang&gt;***__.po__ and save it using UTF-8 encoding.
3. Execute __msgfmt__ ***&lt;lang&gt;***__.po -o gerbv.mo__ in MSYS2.
4. Copy __gerbv.mo__ into &lt;*gerb_folder*&gt;\\share\\locale\\&lt;*lang*&gt;\\LC_MESSAGES\\.
