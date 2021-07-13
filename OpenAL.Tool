# OpenAL Bindings for LinuxAos and WinAos
#  https://github.com/fnec/openaloberon
 
# For WIN and UNIX platforms:
Compiler.Compile
	openaloberon/OpenAL.Mod
	openaloberon/OpenALefx.Mod
	openaloberon/OpenALext.Mod
	
~

# Examples:

Compiler.Compile
	openaloberon/OpenALinfo.Mod
	openaloberon/OpenALUtil.Mod
	openaloberon/TestOpenAL0.Mod
	openaloberon/TestOpenALWav.Mod
	openaloberon/TestOpenALWav3.Mod
~

System.FreeDownTo OpenAL  ~ 

# Configuration:
Possibly, there are more then one sound playback and capture devices available in today computers.
If you want to use one of them in openaloberon run this command from

	A2 window:  OpenALinfo.Do ~
	or
	command line: aos -x OpenALinfo.Do

This command lists the playback and capture devices available in your computer and saves them
	to the files: "openalplay.ini" is for playback device names,
	"openalcap.ini" for capture device names.

If you particularly want to choose one of playback device name in the list,
open "openalplay.ini" file with any editor, and remove "#" character which is in front of
the device name that you would like choose, finally save the file.
If "#" is available in front of  all device names or if these files are not available, then,
openaloberon will use the default device.

# Install openal libraries

#  UnixA2
# install 32bit libopenal1:
   sudo apt install libopenal1:i386
   
#install 64bit libopenal1: 
     sudo apt install libopenal1
 
# Win32, Win64
Download the latest openal-soft libraries from:

	http://kcat.strangesoft.net/openal/

Extract "soft_oal.dll",  rename it "OpenAL32.dll" and put it into your work directory.
 
#-----------------------------------------------------------------------
# Quote from openal-soft-1.16.0-bin.zip readme.txt

OpenAL Soft Binary Distribution

These binaries are provided as a convenience. Users and developers may use it
so they can use OpenAL Soft without having to build it from source.

Note that it is still expected to install the OpenAL redistributable provided
by Creative Labs (at http://openal.org/), as that will provide the "router"
OpenAL32.dll that applications talk to, and may provide extra drivers for the
user`s hardware. The DLLs provided here will simply add additional devices for
applications to select from. If you do not wish to use the redistributable,
then rename soft_oal.dll to OpenAL32.dll (note: even the 64-bit DLL should be
named OpenAL32.dll). Just be aware this will prevent other system-installed
OpenAL implementations from working.

To use the 32-bit DLL, copy it from the bin\Win32 folder to the folder that
the 32-bit OpenAL32.dll router is installed in.
For 32-bit Windows, the Win32 DLL will typically go into the system32 folder.
For 64-bit Windows, the Win32 DLL will typically go into the SysWOW64 folder.
#-----------------------------------------------------------------------


# Usefull links for documentation and examples:
http://kcat.strangesoft.net/openal.html
http://openal.org
http://github.com/kcat/openal-soft


Test files ( s*pcm.wav, s*ulaw.wav) are copied from http://en.wikipedia.org/wiki/WAV

System.FreeDownTo OpenAL ~

