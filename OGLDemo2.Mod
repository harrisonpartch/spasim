MODULE OGLDemo2; (** AUTHOR "fnecati"; PURPOSE "an OGLWindow demo"; *)

IMPORT
	 Inputs, GL:=OpenGL, GLC := OpenGLConst, GLU, OGW := OGLWindow,
	KernelLog ;

TYPE
	MyGLControl = OBJECT(OGW.Window)
	VAR
		eyeposz: LONGREAL;
		anglez: REAL;
		left : BOOLEAN;

	PROCEDURE &New(w, h: LONGINT );
	BEGIN
		Init(w, h, 400, 300, FALSE);
			anglez := 30.0;
			eyeposz := 10.0;
		SetTitle("OGLDemo2");
		SetIdleTime(1000); (* set idle time to 50ms *)

		SetGameMode(TRUE);
	END New;

	(** *)
	PROCEDURE IdleDisplay();
	BEGIN
			IF left THEN
			anglez := anglez - 5.0;
			IF anglez < 0 THEN anglez := 360 ; END;

		ELSE  anglez := anglez + 5.0;
			  IF anglez > 360 THEN anglez := 0; END;
		END;
		 ReDisplay();
	END IdleDisplay;

	(** *)
	PROCEDURE Close*;
	BEGIN
		KernelLog.String("Closing.."); KernelLog.Ln;
		Close^;
	END Close;


	PROCEDURE PointerMove* (x, y : LONGINT; keys : SET);
	BEGIN
	(*	KernelLog.String("PointerMove: "); KernelLog.Int(x, 0); KernelLog.Int(y,4); KernelLog.String(" : "); KernelLog.Bits(keys, 0, 4);  KernelLog.Ln;*)
	END PointerMove;

	PROCEDURE PointerDown* (x, y : LONGINT; keys : SET);
	BEGIN
	(*	KernelLog.String("PointerDown: "); KernelLog.Int(x, 0); KernelLog.Int(y,4); KernelLog.String(" : "); KernelLog.Bits(keys, 0, 4);  KernelLog.Ln;*)
	END PointerDown;

	PROCEDURE PointerUp* (x, y : LONGINT; keys : SET);
	BEGIN
		(* KernelLog.String("PointerUp: "); KernelLog.Int(x, 0); KernelLog.Int(y,4); KernelLog.String(" : "); KernelLog.Bits(keys, 0, 4);  KernelLog.Ln;*)
	END PointerUp;

	(** *)
	PROCEDURE WheelMove*(dz: LONGINT);
	BEGIN
		eyeposz := eyeposz + dz;
		IF eyeposz < 0.0 THEN eyeposz := 0.0; END;
		IF eyeposz > 99.0 THEN eyeposz := 99.0; END;

		Reshape(width, height);
		ReDisplay;
	END WheelMove;

	(** *)
	PROCEDURE KeyEvent* (ucs : LONGINT; flags : SET; keysym : LONGINT);
	BEGIN
		IF keysym = Inputs.KsLeft THEN left := TRUE; ReDisplay;
		ELSIF keysym = Inputs.KsRight THEN left := FALSE; ReDisplay;
		 ELSIF keysym = Inputs.KsUp THEN
		 	SetIdleTime(1+ ENTIER(idletime/1.2)); (* faster *)
			KernelLog.String("idletime= "); KernelLog.Int(idletime, 0); KernelLog.Ln;
		ELSIF keysym = Inputs.KsDown THEN
			SetIdleTime(1+ ENTIER(idletime*1.2)); (* slowdown *)
			KernelLog.String("idletime= "); KernelLog.Int(idletime, 0); KernelLog.Ln;

		ELSIF keysym =  ORD("r") THEN MoveResizeWindow(10,10, 400, 400);
		ELSIF keysym =  ORD("d") THEN SetDecorations(FALSE);
 		ELSIF keysym =  ORD("D") THEN SetDecorations(TRUE);
 		ELSIF keysym =  ORD("F") THEN SetFullWindow(TRUE);
 		ELSIF keysym =  ORD("f") THEN SetFullWindow(FALSE);
		ELSIF keysym =  ORD("q") THEN Close;
		END;
	END KeyEvent ;

	PROCEDURE DrawAQuad();
	BEGIN
 		GL.PushMatrix();

		GL.Rotatef(anglez, 0.0, 0.0, 1.0);

 		GL.Begin(GLC.GL_QUADS);
 		GL.Color3f(1., 0., 0.); GL.Vertex3f(-0.75, -0.75, 1.);
 		GL.Color3f(0., 1., 0.); GL.Vertex3f( 0.75, -0.75, 1.);
 		GL.Color3f(0., 0., 1.); GL.Vertex3f( 0.75,  0.75, 1.);
 		GL.Color3f(1., 1., 0.); GL.Vertex3f(-0.75,  0.75, 1.);
 		GL.End();

 		GL.PopMatrix();

	END DrawAQuad;

	PROCEDURE  Cube*;
	BEGIN
	GL.PushMatrix();

		GL.Rotatef(anglez, 1.0, 1.0, 0.0);


	GL.Begin(GLC.GL_POLYGON); (* top face oriented toward y *)
		GL.Color3f(0.0,0.0,1.0);
		GL.Vertex3f(-1.0, 1.0, 1.0);
		GL.Vertex3f(1.0, 1.0, 1.0);
		GL.Vertex3f(1.0, 1.0, -1.0);
		GL.Vertex3f(-1.0, 1.0, -1.0);
	GL.End();

	GL.Begin(GLC.GL_POLYGON); (* back face oriented toward -z *)
		GL.Color3f(0.0,1.0,0.0);
		GL.Vertex3f(-1.0, 1.0, -1.0);
		GL.Vertex3f(1.0, 1.0, -1.0);
		GL.Vertex3f(1.0, -1.0, -1.0);
		GL.Vertex3f(-1.0, -1.0, -1.0);
	GL.End();

	GL.Begin(GLC.GL_POLYGON); (* right face oriented toward x *)
		GL.Color3f(1.0,0.0,0.0);
		GL.Vertex3f(1.0, 1.0, 1.0);
		GL.Vertex3f(1.0, -1.0, 1.0);
		GL.Vertex3f(1.0, -1.0, -1.0);
		GL.Vertex3f(1.0, 1.0, -1.0);
	GL.End();

	GL.Begin(GLC.GL_POLYGON); (* left face oriented toward -x *)
		GL.Color3f(1.0,0.0,0.0);
		GL.Vertex3f(-1.0, -1.0, 1.0);
		GL.Vertex3f(-1.0, 1.0, 1.0);
		GL.Vertex3f(-1.0, 1.0, -1.0);
		GL.Vertex3f(-1.0, -1.0, -1.0);
	GL.End();

	GL.Begin(GLC.GL_POLYGON); (* bottom face oriented toward -y *)
		GL.Color3f(0.0,0.0,1.0);
		GL.Vertex3f(-1.0, -1.0, 1.0);
		GL.Vertex3f(-1.0, -1.0, -1.0);
		GL.Vertex3f(1.0, -1.0, -1.0);
		GL.Vertex3f(1.0, -1.0, 1.0);
	GL.End();

	GL.Begin(GLC.GL_POLYGON); (* front face oriented toward z*)
		GL.Color3f(0.0,1.0,0.0);
		GL.Vertex3f(1.0, 1.0, 1.0);
		GL.Vertex3f(-1.0, 1.0, 1.0);
		GL.Vertex3f(-1.0, -1.0, 1.0);
		GL.Vertex3f(1.0, -1.0, 1.0);
	GL.End();

	GL.PopMatrix;

	END Cube;

	PROCEDURE Display;
	BEGIN
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
		DrawAQuad();
		Cube();
		SwapBuffers();
	END Display;


	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		GL.Viewport(0, 0, w, h) ;

		GL.ClearColor(0.0, 0.0 ,0.0, 1.0) ;
		GL.Enable(GLC.GL_DEPTH_TEST);

		GL.MatrixMode(GLC.GL_PROJECTION);
		GL.LoadIdentity();
		GLU.Perspective(45.0, MAX(w, h)/MIN(w, h), 0.1, 100.0);

		GL.MatrixMode(GLC.GL_MODELVIEW);
		GL.LoadIdentity();
		GLU.LookAt(0.0, 0.0, eyeposz, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
	END Reshape;

	BEGIN

	END MyGLControl;

PROCEDURE Open*;
VAR
	mywin: MyGLControl;
BEGIN
	NEW(mywin, 640, 480);
END Open;

BEGIN
END OGLDemo2.

	OGLDemo2.Open~

System.Free OGLDemo2 OGLWindow~

System.FreeDownTo  OpenGL ~ 