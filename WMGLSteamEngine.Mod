MODULE WMGLSteamEngine; (** AUTHOR "fnecati"; PURPOSE "opengl steam engine demo"; *)

(*
	Based on steam.c written by Troy Robinette.
	Miniature Steam Engine Simulation.
*)


IMPORT
	WMRectangles, Strings, Kernel, Math:=MathL, Modules,
	WM := WMWindowManager,  WMMessages, Inputs, GLLib,
	GL := OpenGL, GLC := OpenGLConst, WMGL:=WMGLWindow,
	GLU;

CONST waittime=50;

CONST
	pi = 3.141592653;
	degToRad = pi / 180;

	mag = 120.0;  phase = -4;  arcLen = 2.7;  arcR = 0.15;
	dAngle = 10.0;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		 timer: Kernel.MilliTimer;
		alive, animated: BOOLEAN;
		eyeposz: LONGREAL;
		piston, flywheel, pole: GL.Uint;
		crankAngle: REAL;
		headAngle: REAL;
		angleY, angleX: REAL;
		obj: GLU.Quadric;

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);

			SetTitle(Strings.NewString("WMGLSteamEngine"));

			animated := FALSE;

			InitGL;
			Reshape(w, h);
			UpdateImage();

			alive := TRUE;
			IncCount
		END New;


		PROCEDURE ChangeAngle();
		BEGIN
				crankAngle := crankAngle + dAngle;
				IF crankAngle >= 360.0 THEN crankAngle := crankAngle - 360.0 END;
				headAngle := angles[ENTIER(crankAngle)];

				UpdateImage;
		END ChangeAngle;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			CASE CHR(ucs) OF
				"a", "A": BEGIN {EXCLUSIVE} animated := ~ animated; END;
				| "q" : Close;
				| " ": ChangeAngle();
			ELSE
				IF keysym = Inputs.KsUp THEN angleY := angleY - 10.0;  UpdateImage;
				ELSIF keysym = Inputs.KsDown THEN angleY := angleY + 10.0; UpdateImage;
				ELSIF keysym = Inputs.KsRight THEN angleX := angleX + 10.0;  UpdateImage;
				ELSIF  keysym = Inputs.KsLeft  THEN angleX := angleX - 10.0; UpdateImage;
				END;
			END;

		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			eyeposz := eyeposz + dz;
			IF eyeposz < -100 THEN eyeposz:= -100.0; END;
			IF eyeposz > 200.0 THEN eyeposz:= 200.0; END;

			UpdateImage;
		END WheelMove;

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Close;
		BEGIN
			BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE END;
			Close^;
			DecCount
		END Close;

		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				Display;
				SwapGLBuffer();
			DeActivate();
			Swap;
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

	PROCEDURE  DrawBox(x, y, z: GL.Double);
	BEGIN
		GL.PushMatrix();
			 GL.Scaled(x, y, z);
			 GLLib.SolidCube(1.0);

		GL.PopMatrix();
	END DrawBox;

	PROCEDURE  DrawCylinder (outerR, innerR, length: GL.Double);
	BEGIN
		GL.PushMatrix;
			GLU.Cylinder(obj, outerR, outerR, length, 20, 1);

			GL.PushMatrix;
				GL.Rotatef(180, 0.0, 1.0, 0.0);
				GLU.Disk(obj, innerR, outerR, 20, 1);
			GL.PopMatrix;
			GL.Translated(0.0, 0.0, length);
			GLU.Disk(obj, innerR, outerR, 20, 1);
		GL.PopMatrix
	END DrawCylinder;

	PROCEDURE  DrawPiston;
	BEGIN
		GL.PushMatrix;
			GL.Color4f(0.3, 0.6, 0.9, 1.0);

			GL.PushMatrix;
				GL.Rotatef(90, 0.0, 1.0, 0.0);
				GL.Translatef(0.0, 0.0, -0.07);
				DrawCylinder( 0.125, 0.06, 0.12);
			GL.PopMatrix;

			GL.Rotatef(-90, 1.0, 0.0, 0.0);
			GL.Translatef(0.0, 0.0, 0.05);

			DrawCylinder(0.06, 0.0, 0.6);
			GL.Translatef(0.0, 0.0, 0.6);
			DrawCylinder(0.2, 0.0, 0.5);
		GL.PopMatrix
	END DrawPiston;

	PROCEDURE  DrawEnginePole;
	BEGIN
		GL.PushMatrix;
			GL.Color4d(0.8, 0.8, 0.6, 1.0);
			DrawBox(0.5, 3.0, 0.5);

			GL.Color3f(0.5, 0.1, 0.5);
			GL.Rotatef(90, 0.0, 1.0, 0.0);
			GL.Translatef(0.0, 0.9, -0.4);

			DrawCylinder(0.1, 0.0, 2);

		GL.PopMatrix
	END DrawEnginePole;

	PROCEDURE  DrawCylinderHead;
	BEGIN
		GL.PushMatrix;
			GL.Color4f(0.5, 1.0, 0.5, 0.1);
			GL.Rotatef(90, 1.0, 0.0, 0.0);
			GL.Translatef(0, 0.0, 0.4);
			GL.Rotatef(headAngle, 1, 0, 0);
			GL.Translatef(0, 0.0, -0.4);
			DrawCylinder( 0.25, 0.21, 1.6);
			GL.Rotatef(180, 1.0, 0.0, 0.0);
			GLU.Disk(obj, 0, 0.25, 20, 1);
		GL.PopMatrix
	END DrawCylinderHead;

	PROCEDURE  DrawFlywheel;
	BEGIN
		GL.PushMatrix;
			GL.Color4f(0.5, 0.5, 1.0, 1.0);
			GL.Rotatef(90, 0.0, 1.0, 0.0);
			DrawCylinder( 0.625, 0.08, 0.5);
		GL.PopMatrix
	END DrawFlywheel;

	PROCEDURE  DrawCrankBell;
	VAR ang: REAL;
	BEGIN
		ang := crankAngle - headAngle;

		GL.PushMatrix;
			GL.Color4f(1.0, 0.5, 0.5, 1.0);
			GL.Rotatef(90.0, 0.0, 1.0, 0.0);
			DrawCylinder(0.3, 0.08, 0.12);

			GL.Color4f(0.5, 0.1, 0.5, 1.0);
			GL.Translatef(0.0, 0.2, 0.0);
			DrawCylinder( 0.06, 0.0, 0.34);

			GL.Translatef(0.0, 0.0, 0.22);
			GL.Rotatef(90.0, 0.0, 1.0, 0.0);

			GL.Rotatef(ang, 1.0, 0.0, 0.0);
			GL.CallList(piston);
		GL.PopMatrix;
	END DrawCrankBell;

	PROCEDURE  DrawCrank;
	BEGIN
		GL.PushMatrix;

			GL.Rotatef(crankAngle, 1.0, 0.0, 0.0);

			GL.PushMatrix();
				GL.Rotatef(90.0, 0.0, 1.0, 0.0);
				GL.Translatef(0.0, 0.0, -1.0);
				DrawCylinder( 0.08, 0.0, 1.4);
			GL.PopMatrix;

			GL.PushMatrix;
				GL.Translatef(0.28, 0.0, 0.0);
				DrawCrankBell;
			GL.PopMatrix;

			GL.PushMatrix();
				GL.Translatef(-0.77, 0.0, 0.0);
				GL.CallList(flywheel);
			GL.PopMatrix;

		GL.PopMatrix
	END DrawCrank;


	PROCEDURE  InitGL;
		VAR  matSpecular, lightPos: ARRAY [4] OF GL.Float;
			ambient, diffuse, specular, position: ARRAY [4] OF GL.Float;
			shininess: GL.Float;
	BEGIN

		ambient := [ 0.0, 0.0, 0.0, 1.0];
		diffuse := [ 1.0, 1.0, 1.0, 1.0];
		specular := [1.0, 1.0, 1.0, 1.0];
		position := [ 1.0, 1.0, 10.0, 0.0];

		shininess := 50.0;

		angleX := 200.0;  angleY := 0.0;
		headAngle := 0.0;  crankAngle := 0.0;
		eyeposz := 1.0;

	MakeCurrent;
		GL.ClearColor(0.1, 0.2, 0.2, 1.0);



		(* Set light position that moves with the viewpoint *)
		lightPos := [0.0, 0.0, 10.0, 1.0];  (* In eye coordinates *)
		GL.MatrixMode(GLC.GL_MODELVIEW);
		GL.LoadIdentity;

		GL.DepthFunc(GLC.GL_LEQUAL);
		GL.Enable(GLC.GL_DEPTH_TEST);
		GL.Disable(GLC.GL_ALPHA_TEST);
		GL.ShadeModel(GLC.GL_SMOOTH);

		GL.Enable(GLC.GL_LIGHTING);
		GL.Enable(GLC.GL_LIGHT0);


				GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_AMBIENT, ambient);
				GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_DIFFUSE, diffuse);
				GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, position);
				GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_SPECULAR, specular);


		GL.Enable(GLC.GL_COLOR_MATERIAL);

		GL.ColorMaterial(GLC.GL_FRONT, GLC.GL_DIFFUSE);

		GL.Materialfv(GLC.GL_FRONT, GLC.GL_SPECULAR, matSpecular);
		GL.Materialf(GLC.GL_FRONT, GLC.GL_SHININESS, shininess);




		obj := GLU.NewQuadric();

		pole := GL.GenLists(1);
		GL.NewList(pole, GLC.GL_COMPILE);
			DrawEnginePole();
		GL.EndList;

		piston := GL.GenLists(1);
		GL.NewList(piston, GLC.GL_COMPILE);
			DrawPiston();
		GL.EndList;

		flywheel := GL.GenLists(1);
		GL.NewList(flywheel, GLC.GL_COMPILE);
			DrawFlywheel();
		GL.EndList;

		DeActivate();
	END InitGL;


	PROCEDURE  Display;
	BEGIN

		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);


		GL.PushMatrix;
			GL.Translated(0.0, 0.0, eyeposz);
			GL.Rotatef(angleX, 0.0, 1.0, 0.0);
			GL.Rotatef(angleY, 1.0, 0.0, 0.0);

			(* DrawEnginePole(); *)
			GL.CallList(pole);

			GL.PushMatrix();
				GL.Translatef(0.5, 1.4, 0.0);
				DrawCylinderHead;
			GL.PopMatrix;

			GL.PushMatrix();
				GL.Translatef(0.0, -0.8, 0.0);
				DrawCrank;
			GL.PopMatrix;

		GL.PopMatrix();

	END Display;

	PROCEDURE  Reshape (w, h: LONGINT);
	BEGIN
		 MakeCurrent;
		GL.Viewport(0, 0, w, h);

		GL.MatrixMode (GLC.GL_PROJECTION);
		GL.LoadIdentity;

		GLU.Perspective(45.0, 1.0, 0.1, 2000.0);

		GL.MatrixMode (GLC.GL_MODELVIEW);
		GL.LoadIdentity;

		GL.Translated(0.0, 0.0, -10);


		DeActivate;
	END Reshape;


BEGIN {ACTIVE}
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		IF Kernel.Expired(timer) THEN
			ChangeAngle();
			Kernel.SetTimer(timer, waittime);
		END
	END
END GLWindow;

VAR
	angles: ARRAY 360 OF REAL;
	nofWindows : LONGINT;

PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, 256, 256);
END Open;

PROCEDURE InitAngleTable;
	VAR  i: LONGINT;
BEGIN
	FOR  i := 0 TO 359 DO
		angles[i] := SHORT(mag * Math.arctan( arcR * Math.sin((phase - i) * degToRad) /
						(arcLen - arcR * Math.cos((phase - i) * degToRad))) )
	END
END InitAngleTable;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows)
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows)
END DecCount;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN {EXCLUSIVE}
	NEW(die);
	msg.ext := die;
	msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0)
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup);
	InitAngleTable;
END WMGLSteamEngine.

System.Free  WMGLSteamEngine ~

WMGLSteamEngine.Open ~

System.FreeDownTo OpenGL ~

