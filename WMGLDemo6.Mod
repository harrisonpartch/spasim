MODULE WMGLDemo6;  (** AUTHOR "fnecati"; PURPOSE "simple radar sweep example "; *)

IMPORT
	WMRectangles, Strings, Kernel, Math, Modules,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, WMGL:=WMGLWindow;

CONST waittime = 50;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		 timer: Kernel.MilliTimer;
		alive,  animated: BOOLEAN;
		angle : REAL;

		plane: GL.Uint; (* radar plane list *)
		circle: GL.Uint;
		drawMode: LONGINT;

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);
			SetTitle(Strings.NewString("WMGLDemo6-RadarSweep"));

			angle := 00.0;
			drawMode:= 0;
			animated := FALSE;
			alive := TRUE;
			initGL;
			DrawMode(0);
			Reshape(w, h);
			UpdateImage;
			IncCount
		END New;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			CASE CHR(ucs) OF
				"a", "A": BEGIN {EXCLUSIVE} animated := ~ animated; END;
				| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
				| "-" : angle := angle - 3.0; UpdateImage;
				| "+" : angle := angle + 3.0; UpdateImage;

				| "q" : Close;
			ELSE
			END;
		END KeyEvent;

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
				DrawPlane;
				SwapGLBuffer();
			DeActivate();
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

		 DeActivate();
	END DrawMode;

	PROCEDURE initGL;
	VAR i, n: LONGINT;
		  da,  a, b: GL.Float;
		  ga, gb: GL.Float;
		  twopi: REAL;

	BEGIN
		n := 120;
		twopi := 2.0*Math.pi;
		da := twopi / n;

	MakeCurrent();
		GL.ClearColor (0, 0, 0, 0);

		(* make the plane list *)
		plane := GL.GenLists(1);
		GL.NewList(plane, GLC.GL_COMPILE);

		GL.Begin (GLC.GL_QUADS);
			FOR i := 0 TO n-1 DO
				a := i*da;
				b := a + da;
				ga := 0.90 * (i / n);
				gb := 0.90 * ((i + 1) / n);
				GL.Color3f  (0.0, ga, 0.0);
				GL.Vertex2i (0, 0);
				GL.Vertex2f (Math.cos(a),  Math.sin(a));
				GL.Color3f(0.0, gb, 0.0);
		          	GL.Vertex2f (Math.cos(b), Math.sin(b));
		          	GL.Vertex2i (0, 0);
			END;
		GL.End ();
		GL.EndList;

		(* create circle list *)
		circle := GL.GenLists(1);
		GL.NewList(circle, GLC.GL_COMPILE);
		GL.Color3f  (1.0, 0.0, 0.0);
		GL.LineWidth(8.0);

		a := 0.0;
		GL.Begin (GLC.GL_LINES);
		FOR i := 0 TO n-1 DO
			a := i*da;
			b := a + da;
			GL.Vertex2f( 1.1*Math.cos(a), 1.1*Math.sin(a));
			GL.Vertex2f( 1.1*Math.cos(b),  1.1*Math.sin(b));
		END;
		GL.End ();
		GL.EndList;
		DeActivate();
	 END initGL;

	PROCEDURE DrawPlane();
	BEGIN
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT+ GLC.GL_DEPTH_BUFFER_BIT);
		(* draw circle *)
		GL.CallList(circle);
		GL.PushMatrix();

				GL.Rotatef(angle, 0, 0, 1);

	    (* draw radar plane *)
		GL.CallList(plane);
		GL.PopMatrix();
	END DrawPlane;


	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		MakeCurrent();
		GL.Viewport(0,0, w, h);
		GL.MatrixMode(GLC.GL_PROJECTION);
		GL.LoadIdentity ();
			GL.Ortho(-1.5 ,1.5, -1.5, 1.5, -1.0, 1.0);
		GL.MatrixMode (GLC.GL_MODELVIEW);
		GL.LoadIdentity ();
		DeActivate();
	END Reshape;

BEGIN {ACTIVE}
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		 IF Kernel.Expired(timer) THEN
		 	 UpdateImage();
		 	  angle := angle + 5.0;
			Kernel.SetTimer(timer, waittime);
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
END WMGLDemo6.

System.Free  WMGLDemo6  ~

WMGLDemo6.Open ~
