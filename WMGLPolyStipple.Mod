MODULE WMGLPolyStipple; (** AUTHOR "fnecati"; PURPOSE "a demo using glPolygonStipple"; *)
 (* example from OpenGL redbook pdf *)
IMPORT
	WMRectangles, Strings, Kernel, Modules, SYSTEM, KernelLog,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, WMGL := WMGLWindow;

CONST
	waittime = 50;

TYPE Stipples=ARRAY [*] OF CHAR;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		 timer: Kernel.MilliTimer;
		alive, animated: BOOLEAN;

		anglez: REAL;
		fly, halftone: Stipples;

		PROCEDURE &New(w, h: LONGINT);
		BEGIN

			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);

			SetTitle(Strings.NewString("WMGLPolyStipple"));

			animated := FALSE;
			anglez := 30.0;
   			GLinit;
			Reshape(w, h);
			UpdateImage;
			IncCount;
			alive := TRUE;
		END New;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN

		CASE CHR(ucs) OF
			"a", "A": BEGIN {EXCLUSIVE} animated := ~ animated; END;
			| "-" : anglez := anglez - 5.0; UpdateImage;
			| "+" : anglez := anglez + 5.0; UpdateImage;
			| "p": PrintVals;
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
			BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE; END;
			Close^;
			DecCount
		END Close;

		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				DrawStripple;
			SwapGLBuffer();
			DeActivate();
			Swap();
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

		(* print  stipples bits *)
		PROCEDURE PrintVals;
		VAR i: LONGINT;
		BEGIN
			KernelLog.Ln;
			KernelLog.String("--------- fly bits----------------");
			FOR i:=0 TO LEN(fly,0)-1 DO
				IF (i MOD 8) = 0 THEN KernelLog.Ln; END;
				KernelLog.Bits(SYSTEM.VAL(SET, fly[i]),0, 8);
			END;
			KernelLog.Ln; KernelLog.Ln;

			KernelLog.String("--------- halftone bits------------");

			FOR i:=0 TO LEN(fly,0)-1 DO
				IF (i MOD 8) = 0 THEN KernelLog.Ln; END;
				KernelLog.Bits(SYSTEM.VAL(SET, halftone[i]),0, 8);
			END;
			KernelLog.Ln;
			KernelLog.String("----------------------------");	KernelLog.Ln;
		END PrintVals;

		PROCEDURE GLinit;
		BEGIN
			fly := [ 0X,  0X,  0X,  0X,  0X,  0X,  0X,  0X,
				03X,  80X,  01X,  0C0X,  06X,  0C0X,  03X,  60X,
 				04X,  60X,  06X,  20X,  04X,  30X,  0CX,  20X,
 				04X,  18X,  18X,  20X,  04X,  0CX,  30X,  20X,
 				04X,  06X,  60X,  20X,  44X,  03X,  0C0X,  22X,
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X,
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X,
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X,
 				66X,  01X,  80X,  66X,  33X,  01X,  80X,  0CCX,
 				19X,  81X,  81X,  98X,  0CX,  0C1X,  83X,  30X,
 				07X,  0E1X,  87X,  0E0X,  03X,  3FX,  0FCX,  0C0X,
 				03X,  31X,  8CX,  0C0X,  03X,  33X,  0CCX,  0C0X,
				06X,  64X,  26X,  60X,  0CX,  0CCX,  33X,  30X,
 				18X,  0CCX,  33X,  18X,  10X,  0C4X,  23X,  08X,
 				10X,  63X,  0C6X,  08X,  10X,  30X,  0CX,  08X,
 				10X,  18X,  18X,  08X,  10X,  00X,  00X,  08X];

			 halftone := [   0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
 				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X];

			MakeCurrent();
			GL.ClearColor (0.0, 0.0, 0.0, 0.0); (*  clear the background and set it to black *)
   			GL.ShadeModel (GLC.GL_FLAT);  (* set the shading model to FLAT *)
			DeActivate;
		END GLinit;

		PROCEDURE Reshape(w, h: LONGINT);
		BEGIN
		MakeCurrent();
			GL.Viewport(0, 0, w, h);
			GL.MatrixMode(GLC.GL_PROJECTION);
			GL.LoadIdentity();

				 GL.Ortho(-2.0, 2.0, -2.0 , 2.0, -2.0, 2.0);

		DeActivate;
		END Reshape;

		(* create unit size square object *)
		PROCEDURE Square;
		BEGIN

			GL.Begin(GLC.GL_POLYGON);
			GL.Vertex3f(0.0,0.0 ,0.0);(* a *)
			GL.Vertex3f(1.0,0.0, 0.0);(* b *)
			GL.Vertex3f(1.0,1.0,0.0);(* c *)
			GL.Vertex3f(0.0,1.0,0.0);(* d *)
			GL.End();

		END Square;

		PROCEDURE DrawStripple;
		VAR ianglez : REAL;
		BEGIN
			ianglez := -anglez;
			GL.Clear (GLC.GL_COLOR_BUFFER_BIT);
			(* draw a solid unstippled red square *)
			GL.Color3f (1.0, 0.0, 0.0);
			Square();


			(* draw a stippled with fly, green square *)
			GL.Enable (GLC.GL_POLYGON_STIPPLE);	(* enable POLYGON_STIPPLE *)
			GL.PushMatrix();
				GL.Color3f (0.0, 1.0, 0.0);
				GL.Translatef(0.5, 0.0, 0);
				GL.PolygonStipple (ADDRESSOF(fly[0])); (* pass the fly stipple array *)
				Square();
			GL.PopMatrix();

			(* draw a stippled with halftone, blue square *)
			GL.PushMatrix();
				GL.Color3f (0.0, 0.0, 1.0);
				GL.Translatef(1.0, 0.0, 0.0);
					GL.PushMatrix();

							GL.Rotatef(ianglez, 0.0, 0.0, 1.0);

						GL.PolygonStipple (ADDRESSOF(halftone[0]));
						Square();
					GL.PopMatrix();
			GL.PopMatrix();

			(* draw a stippled with fly, rotating cyan square *)
			GL.Color3f (0.0, 1.0, 1.0);
			GL.PushMatrix();

					GL.Rotatef(anglez, 0.0, 0.0, 1.0);

				GL.PolygonStipple (ADDRESSOF(fly[0]));
			    	GL.Rectd (-1.9, 1.9, -0.1, 0.1);
			GL.PopMatrix();

			GL.Disable (GLC.GL_POLYGON_STIPPLE);    (* disable POLYGON STIPPLE *)
		END DrawStripple;

BEGIN {ACTIVE}
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		IF Kernel.Expired(timer) THEN
			UpdateImage();
 			anglez := anglez + 5;
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
END WMGLPolyStipple.

System.Free  WMGLPolyStipple   ~

WMGLPolyStipple.Open ~

System.FreeDownTo OpenGL~

