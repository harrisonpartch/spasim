MODULE  GLinfo;
(*
Print GL and GLU  version and extension info
*)

IMPORT  GL := OpenGL, GLC:= OpenGLConst, KernelLog, GLContext, Strings;


PROCEDURE  Do*;
VAR context: GLContext.Context;
      s: Strings.String;

BEGIN

	NEW(context);
	context.Init(100, 100, "Info", FALSE);
	context.MakeCurrent;

	KernelLog.Ln; 
	s := GL.GLGetString(GLC.GL_VERSION); KernelLog.String("GL_VERSION: "); KernelLog.String(s^); KernelLog.Ln; 
	s := GL.GLGetString(GLC.GL_EXTENSIONS); KernelLog.String("GL_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln; 
	s := GL.GLGetString(GLC.GL_RENDERER); KernelLog.String("GL_RENDERER: "); KernelLog.String(s^); KernelLog.Ln; 	
	s := GL.GLGetString(GLC.GL_VENDOR);  KernelLog.String("GL_VENDOR: ");  KernelLog.String(s^); KernelLog.Ln; 
     KernelLog.Ln; 
	
	s := GL.GLUGetString(GLC.GLU_VERSION); KernelLog.String("GLU_VERSION: "); KernelLog.String(s^); KernelLog.Ln;
	s := GL.GLUGetString(GLC.GLU_EXTENSIONS); KernelLog.String("GLU_EXTENSIONS: "); KernelLog.String(s^); KernelLog.Ln;
	
    context.DeActivate;
    context.Close;
    context := NIL;
    
END Do;

BEGIN
END  GLinfo.

GLinfo.Do ~

SystemTools.Free GLinfo GLContext ~




