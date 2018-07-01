MODULE WMGLDemo3; (** AUTHOR "fnecati"; PURPOSE "opengl glxgears implementation"; *)

IMPORT
	WMRectangles, WMGraphics, Strings, Kernel, Math, Modules,
	WM := WMWindowManager,  WMMessages, KernelLog,
	GL := OpenGL, GLC := OpenGLConst, WMGL:=WMGLWindow;

CONST
	debug = TRUE;
	pi = Math.pi;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		timer: Kernel.MilliTimer;
		alive, animated: BOOLEAN;
		font: WMGraphics.Font;
		frames: LONGINT;
		fpsstr: ARRAY 30 OF CHAR;

		ztrans: REAL;

		(* for gears *)
		light: BOOLEAN;
		drawMode: LONGINT;
	  	gear1, gear2, gear3: GL.Uint;
	  	rotx, roty, rotz, angle, angley: GL.Float;

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);
			SetTitle(Strings.NewString("WMGLDemo3: Gears "));
			canvas.SetColor(WMGraphics.Green);
			font := canvas.GetFont();
			fpsstr := "FPS: ";

			angle := 0.0;
			angley := 0.0;
			ztrans := -40.0;
			light := TRUE;
			drawMode := 0;
			InitGears;
			Reshape(w,h);
			UpdateImage;
			IncCount;
			animated := FALSE;
			alive := TRUE;
		END New;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN

			CASE CHR(ucs) OF
				"a", "A": BEGIN {EXCLUSIVE}  animated := ~ animated; END;

				| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
				| "l": light := ~ light;
						MakeCurrent();
						IF light THEN GL.Enable(GLC.GL_LIGHTING ); ELSE  GL.Disable(GLC.GL_LIGHTING ); END;
						DeActivate();
						UpdateImage;
				| "y": angley := angley + 5.0; UpdateImage;
				| "-" : angle := angle - 1.0; UpdateImage;
				| "+" : angle := angle + 1.0; UpdateImage;

				| "q" : Close;
			ELSE

			END;
		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			ztrans := ztrans + dz;
			IF ztrans > -1.0 THEN ztrans := -1.0; END;
			IF ztrans <-100.0 THEN ztrans := -100.0; END;
			Reshape(GetWidth(), GetHeight());
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
		VAR textWidth, textHeight: LONGINT;
		BEGIN
			MakeCurrent();
			DrawGears;
			SwapGLBuffer();
			DeActivate();


			font.GetStringSize(fpsstr, textWidth, textHeight);
			canvas.DrawString(4, textHeight, fpsstr);

			Swap();
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));

		END UpdateImage;

	PROCEDURE DrawMode(dm: LONGINT);
	VAR drawMode: LONGINT;
	BEGIN
		drawMode := dm;
		MakeCurrent();

	        IF drawMode = 0 THEN       (* fill mode*)
	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
	            GL.Enable(GLC.GL_DEPTH_TEST);
	            GL.Enable(GLC.GL_CULL_FACE);
	        ELSIF drawMode = 1 THEN  (* wireframe mode *)
	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
	            GL.Disable(GLC.GL_DEPTH_TEST);
	            GL.Disable(GLC.GL_CULL_FACE);
	        ELSE                    (* point mode *)

	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
	            GL.Disable(GLC.GL_DEPTH_TEST);
	            GL.Disable(GLC.GL_CULL_FACE);
		  END;

		 DeActivate();;

	END DrawMode;

	PROCEDURE  MakeGear (innerRadius, outerRadius, width: GL.Float; teeth: LONGINT;  toothDepth: GL.Float);
	VAR  r0, r1, r2 , angle, da, u, v, len: GL.Float;
		  i: LONGINT;
	BEGIN

		r0 := innerRadius;
		r1 := outerRadius - toothDepth / 2.0;
		r2 := outerRadius + toothDepth / 2.0;

		da := 2.0 * pi / teeth / 4.0;

		GL.ShadeModel(GLC.GL_FLAT);

		GL.Normal3f(0.0, 0.0, 1.0);

		(* draw front face *)
		GL.Begin(GLC.GL_QUAD_STRIP);
			FOR  i := 0 TO teeth DO
				angle := i * 2.0 * Math.pi / teeth;
				GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
				GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
			END;
		GL.End;

		(* draw front sides of teeth *)
		GL.Begin(GLC.GL_QUADS);
			da := 2.0 * Math.pi / teeth / 4.0;
			FOR  i := 0 TO teeth - 1 DO
				angle := i * 2.0 * Math.pi / teeth;
				GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
			END;
		GL.End;

		GL.Normal3f(0.0, 0.0, -1.0);

		(* draw back face *)
		GL.Begin(GLC.GL_QUAD_STRIP);
			 FOR i := 0 TO teeth DO
					angle := i * 2.0 * Math.pi / teeth;
					GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
					GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
					GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
					GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
			END;
		GL.End;

		(* draw back sides of teeth *)
		GL.Begin(GLC.GL_QUADS);
			da := 2.0 * Math.pi / teeth / 4.0;
			FOR i := 0 TO teeth - 1 DO
				angle := i * 2.0 * Math.pi / teeth;
				GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), -width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), -width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
			END;
		GL.End;

		(* draw outward faces of teeth *)
		GL.Begin(GLC.GL_QUAD_STRIP);
			FOR i := 0 TO teeth - 1 DO
				angle := i * 2.0 * Math.pi / teeth;
				GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
				u := r2 * Math.cos(angle + da) - r1 * Math.cos(angle);
				v := r2 * Math.sin(angle + da) - r1 * Math.sin(angle);
				len := Math.sqrt(u * u + v * v);
				u := u / len;  v := v / len;
				GL.Normal3f(v, -u, 0.0);
				GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), -width * 0.5);
				GL.Normal3f(Math.cos(angle), Math.sin(angle), 0.0);
				GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), width * 0.5);
				GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), -width * 0.5);
				u := r1 * Math.cos(angle + 3 * da) - r2 * Math.cos(angle + 2 * da);
				v := r1 * Math.sin(angle + 3 * da) - r2 * Math.sin(angle + 2 * da);
				GL.Normal3f(v, -u, 0.0);
				GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
				GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
				GL.Normal3f(Math.cos(angle), Math.sin(angle), 0.0);
			END;

			GL.Vertex3f(r1 * Math.cos(0), r1 * Math.sin(0), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(0), r1 * Math.sin(0), -width * 0.5);
		GL.End;

		GL.ShadeModel(GLC.GL_SMOOTH);

		(* draw inside radius cylinder *)
		GL.Begin(GLC.GL_QUAD_STRIP);
			FOR i := 0 TO teeth DO
				angle := i * 2.0 * Math.pi / teeth;
				GL.Normal3f(-Math.cos(angle), -Math.sin(angle), 0.0);
				GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
				GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
			END;
		GL.End;
		GL.Finish();

	END MakeGear;

	PROCEDURE  InitGears;
	VAR
		red, green, blue, lightPos: ARRAY [4] OF GL.Float;

	BEGIN
		rotx := 20;  roty := 30;  rotz := 0;  angle := 20;

		lightPos := [ 1.0, 1.0, 1.0, 0.0];  (* directional *)
		red := [ 0.8, 0.1, 0.0, 1.0];
		green := [ 0.0, 0.8, 0.2, 1.0];
		blue := [ 0.2, 0.2, 1.0, 1.0];

	MakeCurrent;


		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, lightPos);
		GL.Enable(GLC.GL_CULL_FACE);
		GL.Enable(GLC.GL_LIGHTING);
		GL.Enable(GLC.GL_LIGHT0);
		GL.Enable(GLC.GL_DEPTH_TEST);

		(* make the gears *)
		gear1 := GL.GenLists(1);
		GL.NewList(gear1, GLC.GL_COMPILE);
		GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, red);
		MakeGear( 1.0, 4.0, 1.0, 20, 0.7);
		GL.EndList;


		gear2 := GL.GenLists(1);
		GL.NewList(gear2, GLC.GL_COMPILE);
		GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, green);
		MakeGear( 0.5, 2.0, 2.0, 10, 0.7);
		GL.EndList;


		gear3 := GL.GenLists(1);
		GL.NewList(gear3, GLC.GL_COMPILE);
		GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, blue);
		MakeGear(1.3, 2.0, 0.5, 10, 0.7);
		GL.EndList;

		 GL.Enable(GLC.GL_NORMALIZE);

	END InitGears;

	PROCEDURE DrawGears();
	BEGIN

			GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);

			GL.PushMatrix;
				GL.Rotatef(angley, 0.0, 1.0, 0.0);

			GL.PushMatrix;

			GL.Rotatef(rotx, 1.0, 0.0, 0.0);
			GL.Rotatef(roty, 0.0, 1.0, 0.0);
			GL.Rotatef(rotz, 0.0, 0.0, 1.0);


			GL.PushMatrix;
			GL.Translatef(-3.0, -2.0, 0.0);
			GL.Rotatef(angle, 0.0, 0.0, 1.0);
			GL.CallList(gear1);
			GL.PopMatrix;

			GL.PushMatrix;
			GL.Translatef(3.1, -2.0, 0.0);
			GL.Rotatef(-2.0 * angle - 9.0, 0.0, 0.0, 1.0);
			GL.CallList(gear2);
			GL.PopMatrix;

			GL.PushMatrix;
			GL.Translatef(-3.1, 4.2, 0.0);
			GL.Rotatef(-2.0 * angle - 25.0, 0.0, 0.0, 1.0);
			GL.CallList(gear3);
			GL.PopMatrix;

			GL.PopMatrix;
		GL.PopMatrix;

	END DrawGears;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		MakeCurrent();

			GL.Viewport(0, 0, w, h);
			GL.ClearColor(0.0, 0.0, 0.0, 0.0);
			GL.MatrixMode(GLC.GL_PROJECTION);
			GL.LoadIdentity();
		(*	GLU.gluPerspective(45.0, w/h, 1.0, 100.0); *)
			GL.Frustum(-1,1,-1,1, 5, 100);
			GL.MatrixMode(GLC.GL_MODELVIEW);
			GL.LoadIdentity();

			GL.Translatef(0.0, 0.0, ztrans);

		DeActivate();
	END Reshape;


BEGIN  {ACTIVE}
	Kernel.SetTimer(timer, 5000);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
	 	UpdateImage();
	 	angle := angle + 0.5;
		INC(frames);

		IF Kernel.Expired(timer) THEN
			Strings.FloatToStr(frames/5.0, 0, 2, 0, fpsstr);
			Strings.Concat("FPS:", fpsstr, fpsstr);
			Kernel.SetTimer(timer, 5000);
			IF debug THEN
				KernelLog.String(fpsstr); KernelLog.Ln;
			END;
			frames := 0;
		END;
	END;
END GLWindow;

VAR
	nofWindows : LONGINT;

PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, 256, 256);
END Open;

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
	Modules.InstallTermHandler(Cleanup)
END WMGLDemo3.

System.Free  WMGLDemo3   ~

WMGLDemo3.Open ~

System.FreeDownTo WMGLWindow ~
