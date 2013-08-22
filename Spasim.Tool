<?xml version="1.0" encoding="UTF-8"?>
<?bluebottle format version="0.1" ?>
<?xml-stylesheet type="text/xsl" href="http://bluebottle.ethz.ch/bluebottle.xsl" ?>
<Text>
<Span style="Normal"><![CDATA[
]]></Span><Span style="Bold"><![CDATA[# WinAos]]></Span><Span style="Normal"><![CDATA[
]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
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
]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
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

]]></Span><Span style="Bold"><![CDATA[Compiler.Compile]]></Span><Span style="Normal"><![CDATA[
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
Marsh.Mod
Render.Mod ~

]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[The compile command stops looking for arguments when it encounters the tilde ]]></Span><Span style="Normal"><![CDATA[~ 

]]></Span><Span style="Bold"><![CDATA[NCompiler.ncompile]]></Span><Span style="Normal"><![CDATA[ ~
]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[
ncompile compiles the "anonymous" modules. See the tail of the kernel log. If the files are not shown as compiled, open 
NCompiler.Mod, compile it with the button, and run the command again.]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[SystemTools.FreeDownTo	Base ]]></Span><Span style="Normal"><![CDATA[~
]]></Span><Span style="AdHoc Oberon 10 0 0 F00BFFF 0000000"><![CDATA[
Modules must be freed to force their reloading after being changed and recompiled, or to return them to their original state. ]]></Span><Span style="Normal"><![CDATA[

]]></Span><Span style="Bold"><![CDATA[Render.Open]]></Span><Span style="Normal"><![CDATA[ ~



~

NanonyPET.Open NanonyPET.Mod ~  does not compile
XNXLLifeVox.Mod		''	''
XNXLSierp.Mod		''	''

OpenAL.Tool
OpenGL.Tool


======
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

]]></Span>

</Text>
