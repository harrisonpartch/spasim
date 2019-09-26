MODULE MyXGear; (** AUTHOR "fnecati"; PURPOSE "glxgears for commandline run"; *)

IMPORT
	X11, GL:=OpenGL, GLC := OpenGLConst, Kernel, Commands,
	StdIO,  Math ;

(*
Opens a native X11 window and renders.
From command line, linux terminal, run with : aos  -x  MyXGear.Open
or
 from oberon window:   MyXGear.Open ~
*)

CONST
	debug = FALSE; (* for window creation/closing *)
	debugevents = FALSE; (* for testing events *)
	pi = Math.pi;

VAR

	timer : Kernel.MilliTimer;

	context: Commands.Context; (* StdIO context *)

	(* window variables *)
	display : X11.DisplayPtr;
	win : X11.Window ;
	visinfoptr : X11.VisualInfoPtr; (* pointer to X11 VisualInfo *)
	glctx : GL.GLXContext;  (* GL context *)

	(*	gc : X11.GC; (* graphics context, may be useful for X11 drawing operations *)	*)

	gwa : X11.XWindowAttributes; (* get window attributes *)
	swa : X11.XSetWindowAttributes; (* set window attributes*)
	cmap : X11.Colormap; (* colormap for window *)

	width, height : LONGINT; (* size of window *)
	alive : BOOLEAN; (* for main loop control *)


  (*  gear variables *)
  	gear1, gear2, gear3: GL.Uint;
  	rotx, roty, rotz, angle: GL.Float;

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
END MakeGear;

PROCEDURE  InitGears;
VAR
	red, green, blue, lightPos: ARRAY [4] OF GL.Float;

BEGIN
	rotx := 20;  roty := 30;  rotz := 0;  angle := 20;

(*	(* lightPos := [ 5.0, 5.0, 10.0, 1.0];*)
	lightPos := [ 1.0, 1.0, 1.0, 0.0];  (* directional *)
	red := [ 0.8, 0.1, 0.0, 1.0];
	green := [ 0.0, 0.8, 0.2, 1.0];
	blue := [ 0.2, 0.2, 1.0, 1.0];
*)

    lightPos[0] := 1.0;	lightPos[1] := 1.0;  lightPos[2] := 1.0; lightPos[3] := 0.0;
    red[0] := 0.8; red[1] := 0.1; red[2] := 0.0; red[3] := 1.0;
    green[0] := 0.0; green[1] := 0.8; green[2] := 0.2; green[3] := 1.0;
    blue[0] := 0.2; blue[1] := 0.2; blue[2] := 1.0; blue[3] := 1.0;

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



     GL.glXSwapBuffers(display, win);
END DrawGears;

PROCEDURE Reshape(w, h: LONGINT);
BEGIN

	GL.Viewport(0, 0, w, h);
	GL.ClearColor(0.0, 0.0, 0.0, 0.0);
	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity();
	GL.Frustum(-1,1,-1,1, 5, 60);
	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity();
	GL.Translatef(0.0, 0.0, -40.0);

END Reshape;

(* close the window and its resources *)
 PROCEDURE Close;
  VAR res: LONGINT;
 BEGIN
	(* do we have a rendering context *)
	IF glctx # 0 THEN
		(* Release the context *)
	    	res := GL.glXMakeCurrent(display, 0, 0);
	    	(* Delete the context *)
		GL.glXDestroyContext(display, glctx);
		glctx := 0;
		IF debug THEN context.out.String("context deleted"); context.out.Ln; context.out.Update; END;
	END;

	(* do we have a window *)
	IF win # 0 THEN
		(* Unmap the window*)
		X11.UnmapWindow(display, win);
		(* Destroy the window *)
		res:= X11.DestroyWindow(display, win);
		win := 0;
		IF debug THEN context.out.String("window deleted"); context.out.Ln; context.out.Update; END;
	END;

	(* do we have a display *)
	IF display # 0 THEN
		res := X11.CloseDisplay(display);
		display := 0;
		IF debug THEN context.out.String("display deleted"); context.out.Ln; context.out.Update; END;
	END;

 END Close;

PROCEDURE  InitWindow(w, h: LONGINT; CONST title: ARRAY OF CHAR);
VAR
	res: LONGINT;
	masks: LONGWORD;
	attrib : POINTER TO ARRAY OF GL.Int;  (* attributes of GL window *)
	defwin: X11.Window;
BEGIN
 display := X11.OpenDisplay("");
 IF display =0 THEN
 	context.out.String(" cannot connect to X server"); context.out.Ln; context.out.Update;
	Close;
     RETURN;
END;

(*  NEW(attrib, 7);
  attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DEPTH_SIZE; attrib[2] := 24;
  attrib[3] := GLC.GLX_STENCIL_SIZE; attrib[4] := 8;
  attrib[5] := GLC.GLX_DOUBLEBUFFER; attrib[6] := 0 ;
*)
(*
 attrib := [GLC.GLX_RGBA, GLC.GLX_DOUBLEBUFFER, GLC.GLX_DEPTH_SIZE,  24, 0];
 *)
  NEW(attrib, 13);
  attrib[0] := GLC.GLX_RGBA;
  attrib[1] := GLC.GLX_DOUBLEBUFFER;
  attrib[2] := GLC.GLX_DEPTH_SIZE;	attrib[3] := 24;
  attrib[4] := GLC.GLX_STENCIL_SIZE;	attrib[5] := 8;
  attrib[6] := GLC.GLX_RED_SIZE;  	attrib[7] := 8;
  attrib[8] := GLC.GLX_GREEN_SIZE;	attrib[9] := 8;
  attrib[10] := GLC.GLX_RED_SIZE;	attrib[11] := 8;
  attrib[12] := 0 ;

 (* try to find a visual with this attribs *)
 visinfoptr := GL.glXChooseVisual(display, 0 , ADDRESSOF(attrib[0]));

 IF visinfoptr = NIL THEN
  	IF debug THEN context.out.String(" NO appropriate visual found"); context.out.Ln; context.out.Update; END;
  	Close;
     RETURN;
 ELSE
	 IF debug THEN
		 context.out.String("visinfoptr.depth= "); context.out.Int(visinfoptr.depth,0); context.out.Ln;
	 	context.out.String("visinfoptr.visual ");  context.out.Int(visinfoptr.visualID, 0); context.out.Ln;
	 	context.out.Update;
	END;
END;
 defwin :=  X11.DefaultRootWindow(display);
 cmap := X11.CreateColormap(display, defwin, visinfoptr.visual, X11.AllocNone);
 IF cmap = 0 THEN
 	IF debug THEN
	 	context.out.String(" cannot create colormap"); context.out.Ln;
(*	 	X11.GetErrorText(display, cmap, buf, LEN(buf));
	 	context.out.String("ERROR: CreateColormap = "); context.out.String(buf); context.out.Ln;
*)
	 	context.out.Update;
 	END;
 END;

 (* window event masks *)
 masks :=  X11.KeyPressMask + X11.KeyReleaseMask + X11.ButtonPressMask + X11.ButtonReleaseMask + X11.PointerMotionMask +
 X11.ButtonMotionMask + X11.ExposureMask + X11.StructureNotifyMask + X11.FocusChangeMask;

  (* window attributes *)
 swa.backgroundPixel := 0;
 swa.borderPixel := 0;
 swa.colormap := cmap;
 swa.eventMask := masks;

 masks := X11.CWBackPixel + X11.CWBorderPixel + X11.CWColormap + X11.CWEventMask;

 win := X11.CreateWindow(display, defwin, 0, 0, w, h,
		        0, visinfoptr.depth, X11.InputOutput,  visinfoptr.visual, masks, swa);

 (* show window *)
  X11.MapWindow(display, win);

 (* set title of window *)
 X11.StoreName(display, win, ADDRESSOF(title[0]));

(* create GL context *)
 (* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
 glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
	 IF debug THEN context.out.String("glXCreateContext glctx= "); context.out.Int(glctx, 0); context.out.Ln; END;

 res := GL.glXMakeCurrent(display, win, glctx);
	IF debug THEN  context.out.String("glXMakeCurrent res= "); context.out.Int(res, 0); context.out.Ln; END;

END InitWindow;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN context.out.String(str); context.out.Ln; context.out.Update; END;
END Wr;

(* process pending X11 events *)
PROCEDURE LoopForEvents;
VAR xev: X11.Event;
	res: LONGINT;
BEGIN
 WHILE X11.Pending(display)>0 DO
	X11.NextEvent(display, xev);
			CASE xev.typ OF
			X11.Expose:
					res := X11.GetWindowAttributes(display, win, gwa);
					Reshape(gwa.width, gwa.height);
					Wr("Expose");
			| X11.KeyPress:	Wr("KeyPressed");
							alive := FALSE;
			| X11.KeyRelease:	Wr("KeyReleased");
			| X11.ButtonPress: Wr("ButtonPressed");
			| X11.ButtonRelease: Wr("ButtonRelease");
			| X11.MotionNotify: Wr("MotionNotify");
			| X11.FocusIn: Wr("FocusIn");
			| X11.FocusOut: Wr("FocusOut");
			| X11.GraphicsExpose: Wr("GraphicsExpose");
			| X11.NoExpose: Wr("NoExpose");
			| X11.UnmapNotify: Wr("UnmapNotify");
			| X11.MapNotify: Wr("MapNotify");
			| X11.PropertyNotify: Wr("PropertyNotify");
			| X11.SelectionClear: Wr("SelectionClear");
			| X11.SelectionRequest: Wr("SelectionRequest");
			| X11.SelectionNotify: Wr("SelectionNotify");

			(* and others .... *)
			| X11.ClientMessage: Wr("ClientMessage");
			| X11.MappingNotify: Wr("MappingNotify");
			ELSE
			END;
	   	END;
END LoopForEvents;

(* windows main loop *)
PROCEDURE MainLoop;
VAR	frames : LONGINT;
BEGIN
frames := 0;
Kernel.SetTimer(timer, 5000);
alive := TRUE;

WHILE  alive  DO
		(* process X11 events *)
		LoopForEvents;

		DrawGears();
		angle := angle + 0.05;

		 (* measure timing info *)
		INC(frames);
		IF Kernel.Expired(timer) THEN
			context.out.Int(frames,0); context.out.String(" frames in 5 secs.");
			context.out.String(" FPS = "); context.out.Int(frames DIV 5,0);
			context.out.Ln; context.out.Update;
			Kernel.SetTimer(timer,5000);
			frames := 0;
		END;
END;

END MainLoop;

PROCEDURE Open*;
BEGIN
	context := StdIO.env;

	width := 300; height := 300;
	InitWindow(width, height, 'Oberon GL Gears' );

	InitGears();
	Reshape(width, height );

	(* enter to main loop *)
	MainLoop;

	(* finally close the window *)
	Close;
END Open;


BEGIN

END MyXGear.

MyXGear.Open~

System.Free MyXGear ~ 