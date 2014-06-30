MODULE  GLXinfo; (** AUTHOR "fnecati"; PURPOSE "Print GLX, GL and GLU  version, vendor and extension info"; *)
IMPORT
	GL := OpenGL, GLC:= OpenGLConst, GLU, KernelLog, GLContext, Strings;

PROCEDURE  Do*;
VAR context: GLContext.Context;
      s: Strings.String;

BEGIN

	NEW(context);
	context.Init(100, 100);
	context.MakeCurrent;

	(* GLX server and client info *)
	s := GL.GLXQueryServerString(context.GetDisplay(), 0, GLC.GLX_VENDOR); KernelLog.String("Server GLX_VENDOR: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GLXQueryServerString(context.GetDisplay(), 0, GLC.GLX_VERSION); KernelLog.String("Server GLX_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GLXQueryServerString(context.GetDisplay(), 0, GLC.GLX_EXTENSIONS); KernelLog.String("Server GLX_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln;
	KernelLog.Ln;

	s := GL.GLXGetClientString(context.GetDisplay(), GLC.GLX_VENDOR); KernelLog.String("Client GLX_VENDOR: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GLXGetClientString(context.GetDisplay(), GLC.GLX_VERSION); KernelLog.String("Client GLX_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GLXGetClientString(context.GetDisplay(), GLC.GLX_EXTENSIONS); KernelLog.String("Client GLX_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln;
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
END GLXinfo.

GLXinfo.Do ~

SystemTools.Free GLXinfo GLContext ~




