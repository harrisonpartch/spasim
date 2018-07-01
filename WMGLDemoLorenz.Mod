MODULE WMGLDemoLorenz; (** AUTHOR "fnecati"; PURPOSE "opengl Lorenz Strange Attractor demo"; *)

(* Adapted from freeglut examples:

 * Lorenz Strange Attractor
 *
 * Written by John F. Fay in honor of the "freeglut" 2.0.0 release in July 2003
 *
 * What it does:
 *  This program starts with two particles right next to each other.  The particles
 *  move through a three-dimensional phase space governed by the following equations:
 *       dx/dt = sigma * ( y - x )
 *       dy/dt = r * x - y + x * z
 *       dz/dt = x * y + b * z
 *  These are the Lorenz equations and define the "Lorenz Attractor."  Any two particles
 *  arbitrarily close together will move apart as time increases, but their tracks are
 *  confined within a region of the space.
 *
 * Commands:
 *  Arrow keys:  Rotate the view
 *  PgUp, PgDn:  Zoom in and out

 *
 *  'r'/'R':  Reset the simulation
 *  'a'/'A':  Animate
 * '-' / '+' : decrease, increase simulation time between time steps
 *  <spacebar>:  Single-step advancement in time
 *  'q':  Quit
 * 's' save window image
 *)

IMPORT
	WMRectangles, WMGraphics, Strings, Kernel, Random, MathL, Modules,
	WM := WMWindowManager, Inputs, WMMessages,
	gl := OpenGL, glc := OpenGLConst, WMGL := WMGLWindow;


CONST

	(* Number of points to draw in the curves *)
	NUM_POINTS  =  512;

	(* Angle to rotate when the user presses an arrow key *)
	ROTATION_ANGLE = 5.0;

	(* Amount to scale bu when the user presses PgUp or PgDn *)
	SCALE_FACTOR = 0.8;

TYPE
	Vector3d = ARRAY [3] OF gl.Double;
	Positions = ARRAY [NUM_POINTS] OF Vector3d;


TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		timer: Kernel.MilliTimer;
		waittime: LONGINT; (* between animation time *)
		alive,  animated: BOOLEAN;

		red_position: Positions ;          (* Path of the red point *)
		grn_position: Positions ;          (* Path of the green point *)
		array_index: LONGINT ;                             (* Position in *_position arrays of most recent point *)
		distance: LONGREAL ;                       (* Distance between the two points *)

		(* GLUT variables *)
		yaw, pit: LONGREAL ;                 (* Euler angles of the viewing rotation *)
		scale: LONGREAL;                          (* Scale factor *)
		xcen, ycen, zcen: LONGREAL ;   (* Coordinates of the point looked at *)

		animate: LONGINT; ;                             (* 0 - stop, 1 = go, 2 = single-step *)

		(* Lorenz Attractor variables *)
		s0, r0, b0 : LONGREAL ;   (* Default Lorenz attactor parameters *)
		time_step : LONGREAL ;                     (* Time step in the simulation *)
		sigma, r, b: LONGREAL ;  (* Lorenz attactor parameters *)

		distancestr: ARRAY 64 OF CHAR; (* to display distance on the window *);

	PROCEDURE &New(w, h: LONGINT);
	BEGIN
		Init(w, h, FALSE); (* use alpha, for 32bpp img *)
		WM.DefaultAddWindow(SELF);

		SetTitle(Strings.NewString("WMGLDemoLorenz: Lorenz Attractor "));

		animated := FALSE;
		waittime := 60;

		canvas.SetFont(canvas.GetFont());
		array_index:= 0;

	(*	NEW(red_position, NUM_POINTS);
		NEW(grn_position, NUM_POINTS); *)
		initGL;
		Reshape(w, h);
		UpdateImage;
		alive := TRUE;
		IncCount
	END New;

	PROCEDURE ResetPositions;
	VAR i: LONGINT;
	BEGIN

		(* Reset the Lorenz parameters *)
		sigma := s0 ;  b := b0 ;  r := r0 ;
		(* Set an initial position *)
		red_position[0,0] := random.Uniform();
		red_position[0,1] := random.Uniform();
		red_position[0,2] := random.Uniform();
		grn_position[0,0] := random.Uniform();
		grn_position[0,1] := random.Uniform();
		grn_position[0,2] := random.Uniform();
		array_index := 0 ;

		(* Initialize the arrays *)
		FOR i := 1 TO NUM_POINTS-1 DO
			red_position[i,..] := red_position[0,..];

			grn_position[i,..] := grn_position[0,..];
		END;

	END ResetPositions;

	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	BEGIN
		CASE CHR(ucs) OF
			"a" :	BEGIN {EXCLUSIVE} animated := ~ animated; END;
					IF animated THEN animate := 1; ELSE animate := 0 END;

			| "-" :	DEC(waittime,5); IF waittime < 10 THEN waittime := 10; END;
			| "+" :	INC(waittime,5); IF waittime>1000 THEN waittime := 1000; END;
			| "r" :	ResetPositions; UpdateImage;
			| " " : 	animate := 2;  UpdateImage;
			| "q" :	Close; RETURN;

		ELSE
			IF  keysym = Inputs.KsLeft  THEN
				MakeCurrent();

				gl.Rotated ( ROTATION_ANGLE, 0.0, 0.0, 1.0 );

				DeActivate();
				UpdateImage;
			ELSIF keysym = Inputs.KsRight THEN
				MakeCurrent();

				gl.Rotated ( -ROTATION_ANGLE, 0.0, 0.0, 1.0 );

				DeActivate();
				UpdateImage;
			ELSIF keysym = Inputs.KsDown THEN
				MakeCurrent();

				gl.Rotated ( -ROTATION_ANGLE, 0.0, 1.0, 0.0 );

				DeActivate();
				UpdateImage;
			ELSIF keysym = Inputs.KsUp THEN
				MakeCurrent();

				gl.Rotated ( ROTATION_ANGLE, 0.0, 1.0, 0.0 );

				DeActivate();
				UpdateImage;
			ELSIF keysym = Inputs.KsPageDown THEN
				MakeCurrent();

				gl.Scaled ( SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR );

				DeActivate();
				UpdateImage;
			ELSIF keysym = Inputs.KsPageUp THEN
				MakeCurrent();

				gl.Scaled ( 1.0 / SCALE_FACTOR, 1.0 / SCALE_FACTOR, 1.0 / SCALE_FACTOR );

				DeActivate();
				UpdateImage;
			END;
		END;

	END KeyEvent;

	PROCEDURE Close;
	BEGIN
		BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE; END;
		Close^;
		DecCount
	END Close;

	PROCEDURE Handle(VAR m: WMMessages.Message);
	BEGIN
		IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
			Close;
		ELSE Handle^(m)
		END
	END Handle;

	PROCEDURE UpdateImage;
	BEGIN
		MakeCurrent();
			Display;
			 TimerCB;
			SwapGLBuffer();
		DeActivate();

		canvas.SetColor(WMGraphics.White);
		canvas.DrawString(10,15, distancestr);
		Swap();
		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

	PROCEDURE initGL;
	BEGIN
		s0 := 10.0; r0 := 28.0; b0 := 8.0/3.0 ;
		time_step := 0.03;
		sigma := 10.0; r := 28.0; b := 8.0/3.0 ;
		distance := 0.0 ;

		yaw := 0.0; pit := 0.0;
		scale := 1.0 ;
		xcen := 0.0; ycen := 0.0; zcen := 0.0 ;

		animate := 1 ;

		ResetPositions;

		MakeCurrent;
		(* Set up the OpenGL parameters *)
		gl.Enable ( glc.GL_DEPTH_TEST ) ;
		gl.ClearColor ( 0.0, 0.0, 0.0, 0.0 ) ;
		gl.ClearDepth ( 1.0 ) ;
		DeActivate;
	END initGL;

	PROCEDURE DrawCurve (index: LONGINT; CONST position: Positions);
	VAR i: LONGINT;
	BEGIN
		i := index;
		gl.Begin (glc.GL_LINE_STRIP) ;

		REPEAT
			IF i = NUM_POINTS-1 THEN i := 0 ELSE i := i + 1 END;
			 gl.Vertex3dv ( position[i] ) ;
		 UNTIL ( i = index ) ;

		gl.End () ;
	END DrawCurve;

	PROCEDURE Display;
	BEGIN
		gl.Clear ( glc.GL_COLOR_BUFFER_BIT + glc.GL_DEPTH_BUFFER_BIT );

		(* Draw some axes *)
		gl.Begin ( glc.GL_LINES ) ;
		gl.Color3f ( 0.0, 0.0, 1.0 ) ;  (* blue *)
		gl.Vertex3d ( 0.0, 0.0, 0.0 ) ;
		gl.Vertex3d ( 2.0, 0.0, 0.0 ) ; (* x- axis *)

		gl.Color3f ( 1.0, 1.0, 0.0 ) ;  (* yellow *)
		gl.Vertex3d ( 0.0, 0.0, 0.0 ) ;
		gl.Vertex3d ( 0.0, 1.0, 0.0 ) ; (* y- axis *)

		gl.Color3f (0.0, 1.0, 1.0 ) ;  (* cyan *)
		gl.Vertex3d ( 0.0, 0.0, 0.0 ) ;
		gl.Vertex3d ( 0.0, 0.0, 1.0 ) ; (* z- axis *)
	 	gl.End ();

	 	gl.Color3d ( 1.0, 0.0, 0.0 ) ;  (* Red *)
	 	DrawCurve ( array_index, red_position ) ;

	 	gl.Color3d ( 0.0, 1.0, 0.0 ) ;  (* Green *)
	 	DrawCurve ( array_index, grn_position ) ;

	END Display;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		MakeCurrent();
		gl.Viewport(0, 0, w, h);
		(* Set up the OpenGL parameters *)
		gl.Enable ( glc.GL_DEPTH_TEST ) ;
		gl.ClearColor ( 0.0, 0.0, 0.0, 0.0 ) ;
		gl.ClearDepth ( 1.0 ) ;

		gl.MatrixMode ( glc.GL_PROJECTION ) ;
		gl.LoadIdentity ();

			gl.Frustum ( -1.0, 1.0, -1.0, 1.0, 10.0, 100.0 ) ;

		xcen := 0.0; ycen := 0.0; zcen := 0.0;

		gl.MatrixMode ( glc.GL_MODELVIEW ) ;
		gl.LoadIdentity () ;

			gl.Translated ( 0.0, 0.0, zcen-40.0 ) ;

	END Reshape;

	PROCEDURE TimerCB;
	VAR
		deltax, deltay, deltaz: LONGREAL;
		new_index: LONGINT;
		str: ARRAY 64 OF CHAR;
	BEGIN

		(* Function called at regular intervals to update the positions of the points *)
		new_index := array_index + 1 ;

		(* Set the next timed callback *)
		IF  animate > 0  THEN
			IF  new_index = NUM_POINTS THEN new_index := 0  END;
			AdvanceInTime ( time_step, red_position[array_index], red_position[new_index] ) ;
			AdvanceInTime ( time_step, grn_position[array_index], grn_position[new_index] ) ;
			(*  WritePositions;*)
		 	array_index := new_index ;

			deltax := red_position[array_index,0] - grn_position[array_index,0] ;
			deltay := red_position[array_index,1] - grn_position[array_index,1] ;
			deltaz := red_position[array_index,2] - grn_position[array_index,2] ;
			distance := MathL.sqrt ( deltax * deltax + deltay * deltay + deltaz * deltaz ) ;

			distancestr :="Distance= ";
			Strings.FloatToStr(distance, 10,4,0, str);
			Strings.Append(distancestr, str);

			IF ( animate = 2 ) THEN animate := 0 END ;
		END;

	END TimerCB;

	(* ********** Functions ***************** *)

	(* The Lorenz Attractor *)
	PROCEDURE CalcDeriv ( CONST position: Vector3d; VAR deriv: Vector3d);
	BEGIN
		(* Calculate the Lorenz attractor derivatives *)
	 	deriv[0] := sigma * ( position[1] - position[0] ) ;
	 	deriv[1] := ( r + position[2] ) * position[0] - position[1] ;
	 	deriv[2] := -position[0] * position[1] - b * position[2] ;
	END CalcDeriv;

	PROCEDURE AdvanceInTime (time_step: LONGREAL;  CONST position: Vector3d; VAR new_position: Vector3d );
	VAR
	       deriv0, deriv1, deriv2, deriv3: Vector3d;
	BEGIN
		(* Move a point along the Lorenz attractor *)
		(* Save the present values *)
		new_position := position;
		(* First pass in a Fourth-Order Runge-Kutta integration method *)
		CalcDeriv ( position, deriv0 ) ;

		new_position := position + 0.5 * time_step * deriv0 ;

		(* Second pass *)
		CalcDeriv ( new_position, deriv1 ) ;
		new_position := position + 0.5 * time_step * deriv1 ;

		(* Third pass *)
		CalcDeriv ( position, deriv2 ) ;
		new_position := position + time_step * deriv2 ;

		(* Second pass *)
		CalcDeriv ( new_position, deriv3 ) ;
		new_position := position + 0.1666666666666666667 * time_step * ( deriv0 + 2.0 * ( deriv1 + deriv2 ) + deriv3 ) ;

	END AdvanceInTime;

BEGIN{ACTIVE}
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		IF Kernel.Expired(timer) THEN
			UpdateImage();
			Kernel.SetTimer(timer, waittime);
		END;
	END;
END GLWindow;


VAR
	random: Random.Generator;
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
	NEW(random);
	random.InitSeed(12345);
	Modules.InstallTermHandler(Cleanup)
END WMGLDemoLorenz.

System.Free  WMGLDemoLorenz   ~

WMGLDemoLorenz.Open ~

