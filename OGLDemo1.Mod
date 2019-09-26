MODULE OGLDemo1; (** AUTHOR "fnecati"; PURPOSE "an OGLWindow demo"; *)

IMPORT
	 GL:=OpenGL, GLC := OpenGLConst, GLU, OGW := OGLWindow, Inputs,
	KernelLog, GLLib ;

TYPE
	MyGLControl = OBJECT(OGW.Window)
	VAR
		listenerPos, source0Pos, source1Pos,  source2Pos  : ARRAY [3] OF REAL;
		transdz: REAL;

	PROCEDURE &New(w, h: LONGINT );
	BEGIN
		Init(w,h,400,100, FALSE);
		listenerPos := [ 0.0, 0.0, 4.0];
		source0Pos := [ -2.0, 0.0, 0.0];
		source1Pos := [ 2.0, 0.0, 0.0];
		source2Pos := [ 0.0, 0.0, -4.0];
		transdz := -6.6;
		SetTitle("OGLDemo1");
		SetIdleTime(60);
		SetGameMode(TRUE);
		(* cmdlinerun := TRUE;*)
	END New;

	(** *)
	PROCEDURE IdleDisplay*();
	BEGIN
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
		KernelLog.String("PointerDown: "); KernelLog.Int(x, 0); KernelLog.Int(y,4); KernelLog.String(" : "); KernelLog.Bits(keys, 0, 4);  KernelLog.Ln;
	END PointerDown;

	PROCEDURE PointerUp* (x, y : LONGINT; keys : SET);
	BEGIN
		(* KernelLog.String("PointerUp: "); KernelLog.Int(x, 0); KernelLog.Int(y,4); KernelLog.String(" : "); KernelLog.Bits(keys, 0, 4);  KernelLog.Ln;*)
	END PointerUp;

	(** *)
	PROCEDURE WheelMove*(dz: LONGINT);
	BEGIN
		transdz := transdz + dz;
		Reshape(width, height);
		ReDisplay;
	END WheelMove;

	(** *)
	PROCEDURE KeyEvent* (ucs : LONGINT; flags : SET; keysym : LONGINT);
	BEGIN
		CASE CHR(ucs) OF
		"q": Close;
		| "t": SetTitle("MyTest22222222222");
		| "p": SetMousePosition(0, 0);
		| "P": SetMousePosition(width-1, height-1);
		| "m": MoveResizeWindow( 200,200, 400, 400);
		ELSE
		END;
			CASE keysym OF
				Inputs.KsLeft: listenerPos[0] := listenerPos[0]- 0.1;
				| Inputs.KsRight: listenerPos[0] := listenerPos[0]+ 0.1;
				| Inputs.KsUp: 	listenerPos[2] := listenerPos[2]- 0.1;
				| Inputs.KsDown: listenerPos[2] := listenerPos[2]+ 0.1;
		ELSE
		END;

	END KeyEvent ;

	PROCEDURE ChangePosititon*;
	VAR x: REAL;
	BEGIN
		x := listenerPos[0] + 0.1;
		IF x > 3.0 THEN x := -3.0; END;
		listenerPos[0] := x;
	END ChangePosititon;


	PROCEDURE Display;
	VAR x: REAL;
	BEGIN
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT) ;
		GL.PushMatrix() ;
		GL.Rotatef(20.0,1.0,1.0, 0.0) ;

		(* sources *)
		GL.PushMatrix() ;
			GL.Translatef(source0Pos[0], source0Pos[1], source0Pos[2]) ;
			GL.Color3f(1.0, 0.0, 0.0) ;
			GLLib.WireCube(0.5) ;
			GL.PopMatrix() ;

			GL.PushMatrix() ;
				GL.Translatef(source2Pos[0], source2Pos[1], source2Pos[2]) ;
				GL.Color3f(0.0, 0.0,1.0) ;
				GLLib.WireCube(0.5) ;
			GL.PopMatrix() ;

			GL.PushMatrix() ;
				GL.Translatef(source1Pos[0], source0Pos[1], source0Pos[2]) ;
				GL.Color3f(0.0,1.0, 0.0) ;
				GLLib.WireCube(0.5) ;
			GL.PopMatrix() ;

			(* the listener *)
			GL.PushMatrix() ;
				GL.Translatef(listenerPos[0], listenerPos[1], listenerPos[2]) ;
 				GL.Color3f(1.0,1.0, 1.0);
				GLLib.WireCube(0.5) ;
			GL.PopMatrix() ;

			GL.PopMatrix() ;
			SwapBuffers();

			(* update poisition for next display *)
			x := listenerPos[0] + 0.1;
			IF x > 4.0 THEN x := -4.0; END;
			listenerPos[0] :=x;

		END Display;


		PROCEDURE Reshape(w, h: LONGINT);
		VAR ratio: LONGREAL;
		BEGIN
			ratio := w / h;
			GL.Viewport(0, 0, w, h) ;
			GL.ClearColor(0.0, 0.0 ,0.0, 1.0) ;

			GL.MatrixMode(GLC.GL_PROJECTION) ;
			GL.LoadIdentity() ;

				GLU.Perspective(60.0,ratio,1.0,30.0) ;


			GL.MatrixMode(GLC.GL_MODELVIEW) ;
			GL.LoadIdentity() ;

				GL.Translatef(0.0,0.0, transdz) ;

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
END OGLDemo1.

OGLDemo1.Open~

System.Free OGLDemo1 OGLWindow~

System.FreeDownTo OpenGL ~

