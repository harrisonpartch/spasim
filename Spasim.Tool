# WinAos
Compiler.Compile
	 OpenGLConst.Mod
	 Win32.OpenGL.Mod
	 Win32.GLU.Mod
	 WinApi.Mod
	 Win32.OGLWindow.Mod
	 GLShaderUtils.Mod
	 Win32.GLContext.Mod
	 Win32.WGLinfo.Mod
	~

	WGLinfo.Do ~
	
# for WinAos add spasim directory to aos.ini or myaos.ini search path:
# Paths.Search = Work;spasim;obj;../source;PELinker;../UnixAos;vy.ants/source;vy.ants/documents


# LinuxAos
Compiler.Compile
	OpenGLConst.Mod
	Unix.OpenGL.Mod
	Unix.GLU.Mod
	Unix.OGLWindow.Mod
	GLShaderUtils.Mod
 	Unix.X11KeySymDef.Mod
 	Unix.XF86VMode.Mod
 	Unix.GLContext.Mod
 	Unix.GLXinfo.Mod 	
	~

GLXinfo.Do ~ 



SystemTools.DoCommands
SystemTools.Timer start ~
Compiler.Compile 
Base.Mod
XNXLE.Mod 
XNXLMath.Mod
XNXLHex.Mod
XNXLNoise.Mod
XNXLVoxel.Mod
XNXLFRep.Mod
Retina.Mod
XNXLMPEG.Mod
XNXLFilmLoop.Mod
TexVox.Mod
XNXLVoxel4.Mod
XNXLHalfSpace.Mod
XNXLRotaVox.Mod
Engrainer.Mod
Saboteur.Mod
NCompiler.Mod
XNXLVoxConsole.Mod
FRep.Mod
Marsh.Mod

OGLRender.Mod
~

SystemTools.Show Time elapsed: ~ SystemTools.Ln ~
SystemTools.Timer elapsed ~ SystemTools.Ln ~~

# *********************************


Render.Open ~

OGLRender.Open ~

SystemTools.FreeDownTo Base~

NanonyPET.Open NanonyPET.Mod ~  does not compile
XNXLLifeVox.Mod		''	''
XNXLSierp.Mod		''	''

MyXGear.Open 

OpenAL.Tool
OpenGL.Tool

Clipboard.Install

XNXLAudio.Mod

WMSearchTool.Open

Compiler.Compile XNXLRender.Mod ~

alice.png

NanonyTextView.Mod
NanonyPET.Mod
NM3.Mod

NnviGAernhjFK40xASZZVoQ.Mod
NXWCxXWLIcD2LegvoGXXBiQ.Mod
NnKyXYNiHwdxuM6wHrbxwuQ.Mod
NBsHFiBKkSckXBAd46ZbEQw.Mod
