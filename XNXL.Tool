# WinAos
Compiler.Compile
	 OpenGLConst.Mod
	 Win32.OpenGL.Mod
	 Win32.GLU.Mod
	 WinApi.Mod
	 Win32.OGLWindow.Mod
	 GLShaderUtils.Mod
	~
# add spasim directory to aos.ini search path

# LinuxAos
Compiler.Compile
	 OpenGLConst.Mod
	 Unix.OpenGL.Mod
	 Unix.GLU.Mod
	 Unix.OGLWindow.Mod
	 GLShaderUtils.Mod
 	Unix.X11KeySymDef.Mod
	~

# compile spasim modules:

Compiler.Compile 	XNXL.Mod ~

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
	Marsh.Mod

	FRep.Mod
	NCompiler.Mod

	Render.Mod

	OGLRender.Mod
~
SystemTools.Show Time elapsed: ~ SystemTools.Ln ~
SystemTools.Timer elapsed ~ SystemTools.Ln ~~

# run spasim
Render.Open ~ 

OGLRender.Open ~ 

# remove spasim modules from memory
SystemTools.FreeDownTo Base~

# compile anonymous modules
NCompiler.ncompile ~
 
 

 
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

