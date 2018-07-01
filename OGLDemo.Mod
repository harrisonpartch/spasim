MODULE OGLDemo; (** AUTHOR "fnecati"; PURPOSE "an empty OGLWindow demo"; *)

IMPORT
	 GL:=OpenGL, GLC := OpenGLConst, OGW := OGLWindow,
	KernelLog ;

TYPE
	MyGLControl = OBJECT(OGW.Window)

	(** constructor for this window *)
	PROCEDURE &New(w, h: LONGINT );
	BEGIN
		Init(w,h,300,200, FALSE);  				(* initilialize the inherited window first *)
		SetTitle("OGLDemo"); 	(* set title of this window *)
	END New;

	(* process keyboard events *)
	PROCEDURE KeyEvent* (ucs : LONGINT; flags : SET; keysym : LONGINT);
	BEGIN
		CASE CHR(ucs) OF
		"q": Close;
		| "t": SetTitle("OGLDemo-000000");
		| "p": SetMousePosition(1, 1);
		| "m": MoveResizeWindow( 200,200, 256, 256);
		| "n": MoveResizeWindow( 100,200, 300, 300);
		| "s":
				KernelLog.String("width= "); KernelLog.Int(width, 0); KernelLog.Ln;
				KernelLog.String("height= "); KernelLog.Int(height, 0); KernelLog.Ln;
		ELSE
		END;
	END KeyEvent ;

	(* OpenGL display procedure *)
	PROCEDURE Display;
	BEGIN
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT) ;
		SwapBuffers();
	END Display;

	(* reshape OpenGL window *)
	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		GL.Viewport(0, 0, w, h) ;
		GL.ClearColor(0.8, 0.1 ,0.8, 1.0) ;
	END Reshape;

	BEGIN

	END MyGLControl;

(* open a window *)
PROCEDURE Open*;
VAR
	mywin: MyGLControl;
BEGIN
	NEW(mywin, 256, 256);
END Open;

BEGIN
END OGLDemo.

OGLDemo.Open ~

System.Free OGLDemo OGLWindow ~

System.FreeDownTo OpenGL ~



