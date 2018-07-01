MODULE  WGLinfo; (** AUTHOR "fnecati"; PURPOSE "Print GL and GLU  version, vendor and extension info"; *)
IMPORT
	GL := OpenGL, GLC:= OpenGLConst, GLU, KernelLog, GLContext, Strings;

PROCEDURE  Do*;
VAR context: GLContext.Context;
      s: Strings.String;

BEGIN

	NEW(context);
	context.Init(100, 100);
	context.MakeCurrent;
	GL.Read_WGL_EXT_extensions_string();
	GL.Read_WGL_ARB_extensions_string();

	(* WGL info *)
	KernelLog.Ln;
	s := GL.wglEXTStrings();  KernelLog.String("WGL EXTString: ");  KernelLog.String(s^); KernelLog.Ln;
	s := GL.wglARBStrings(); KernelLog.String("WGL ARBStrings : "); KernelLog.String(s^); KernelLog.Ln;
	KernelLog.Ln;

	(* OpenGL info *)
	s := GL.GetString(GLC.GL_VENDOR);  KernelLog.String("OpenGL GL_VENDOR: ");  KernelLog.String(s^); KernelLog.Ln;
	s := GL.GetString(GLC.GL_RENDERER); KernelLog.String("OpenGL GL_RENDERER: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GetString(GLC.GL_VERSION); KernelLog.String("OpenGL GL_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GetString(GLC.GL_SHADING_LANGUAGE_VERSION); KernelLog.String("OpenGL GL_SHADING_LANGUAGE_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GetString(GLC.GL_EXTENSIONS); KernelLog.String("OpenGL GL_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln;
	KernelLog.Ln;

	(* GLU info *)
	s := GLU.GetString(GLU.GLU_VERSION); KernelLog.String("GLU_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GLU.GetString(GLU.GLU_EXTENSIONS); KernelLog.String("GLU_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln;
	KernelLog.Ln;

	context.DeActivate;
	context.Close;
	context := NIL;
END Do;

BEGIN
END  WGLinfo.

WGLinfo.Do ~

System.Free WGLinfo GLContext ~




