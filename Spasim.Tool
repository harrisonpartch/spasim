<?xml version="1.0" encoding="UTF-8"?>
<?bluebottle format version="0.1" ?>
<?xml-stylesheet type="text/xsl" href="http://bluebottle.ethz.ch/bluebottle.xsl" ?>
<Text>
<Span style="Normal"><![CDATA[# LinuxAos
]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
	OpenGLConst.Mod
	Unix.OpenGL.Mod
	Unix.GLU.Mod
	Unix.XF86VMode.Mod
 	Unix.X11KeySymDef.Mod
	Unix.OGLWindow.Mod
	GLShaderUtils.Mod 	
 	Unix.GLContext.Mod
 	Unix.GLXinfo.Mod 	
	~
	
]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
Unix.OpenAL.Mod 
Unix.OpenALefx.Mod 
Unix.OpenALext.Mod 
OpenALinfo.Mod
OpenALUtil.Mod
TestOpenAL0.Mod
TestOpenALWav.Mod 
XNXLAudio.Mod
TestOpenALWav3.Mod

~

#Linux or Windows:

]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
Base.Mod
XNXLE.Mod 
XNXLMath.Mod
XNXLHex.Mod
Noise.Mod
XNXLVoxel.Mod
FRep.Mod
Retina.Mod
MPEG.Mod
FilmLoop.Mod
TexVox.Mod
CellAuto.Mod
Voxel4.Mod
XNXLHalfSpace.Mod
XNXLRotaVox.Mod
Engrainer.Mod
Saboteur.Mod
FRep.Mod
RotaVox.Mod
NCompiler.Mod
NanonyPET.Mod
Marsh.Mod
Render.Mod ~

]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[The compile command stops looking for arguments when it encounters the tilde ]]></Span><Span style="Normal"><![CDATA[~ 

]]></Span><Span style="Bold"><![CDATA[NCompiler.ncompile]]></Span><Span style="Normal"><![CDATA[ ~
]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[
ncompile compiles the "anonymous" modules]]></Span><Span style="Normal"><![CDATA[ 


]]></Span><Span style="Bold"><![CDATA[Render.]]></Span><Span style="Normal"><![CDATA[Open ~ 
]]></Span><Span style="Bold"><![CDATA[

**********************************************************************************************************


SystemTools.FreeDownTo	Base ]]></Span><Span style="Normal"><![CDATA[~
]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[
Modules must be freed to force their reloading after being changed and recompiled, or to return them to their original state. ]]></Span><Span style="Normal"><![CDATA[

~

NanonyPET.Open NanonyPET.Mod ~  
XNXLLifeVox.Mod		''	''
XNXLSierp.Mod		''	''

OpenAL.Tool
OpenGL.Tool

OpenALinfo.Do 
======

XNXLAudio.Mod

WMSearchTool.Open

Compiler.Compile XNXLRender.Mod ~

alice.png

Windows:
# for WinAos add spasim directory to aos.ini or myaos.ini search path:
# Paths.Search = Work;spasim;obj;../source;PELinker;../UnixAos;vy.ants/source;vy.ants/documents
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
]]></Span>

</Text>
