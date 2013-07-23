MODULE XLGear; (** AUTHOR "fnecati"; PURPOSE "Adjusted for commandline run"; *)

IMPORT
	WMWindowManager, X11, Api := MyX11Api, GL:=OpenGL, GLC := OpenGLConst, Kernel,
	Trace,  Math ,  SYSTEM ;

(*
Opens a native X11 window and renders.
From command line, linux terminal, run with : aos  -x  MyXGear.Test
or
 from oberon window:   MyXGear.Open ~
*)

CONST
	debug = FALSE; (* for window creation/closing *)
	debugevents = TRUE; (* for testing events *)
	pi = Math.pi;

TYPE

	Vector = ARRAY [*] OF REAL;
	Vertex = RECORD
		tu, tv: REAL;
    		x, y, z: REAL;
	END;
	VertexArray = POINTER TO ARRAY OF Vertex;

TYPE XGLControl = OBJECT(WMWindowManager.DoubleBufferWindow)
VAR
	pointerlastx, pointerlasty, pointercenterx, pointercentery: LONGINT;
	pi: WMWindowManager.PointerInfo;
	Key: CHAR;
	movemode: CHAR;


PROCEDURE & New();
BEGIN
	Init(100,100, TRUE);

END New;

PROCEDURE FocusGot*;
BEGIN

END FocusGot;

PROCEDURE FocusLost*;
BEGIN

END FocusLost;


PROCEDURE KeyEvent (ucs : LONGINT; flags : SET; keysym : LONGINT);
(* We only want one event per frame!*)
BEGIN

END KeyEvent ;

PROCEDURE PointerDown (x, y : LONGINT; keys : SET);
BEGIN

END PointerDown;

PROCEDURE PointerUp (x, y : LONGINT; keys : SET);
BEGIN

END PointerUp;

PROCEDURE PointerMove (x, y : LONGINT; keys : SET);

BEGIN

END PointerMove;

PROCEDURE PointerLeave;
BEGIN

END PointerLeave;

PROCEDURE WheelMove*(dz : LONGINT);
BEGIN

END WheelMove;

END XGLControl;

VAR

	timer : Kernel.MilliTimer;

	(* window variables *)
	display : X11.DisplayPtr;
	win : X11.Window ;
	control: XGLControl;
	visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)
	glctx : GL.GLXContext;  (* GL context *)

	(*	gc : X11.GC; (* graphics context, may be useful for X11 drawing operations *)	*)

	gwa : Api.XWindowAttributes; (* get window attributes *)
	swa : Api.XSetWindowAttributes; (* set window attributes*)
	cmap : X11.Colormap; (* colormap for window *)

	width, height : LONGINT; (* size of window *)
	alive : BOOLEAN; (* for main loop control *)


PROCEDURE drawstars;
VAR
	i,j,k: LONGINT;
BEGIN
	GL.SetFCR();
	GL.glClear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
	GL.glBegin(GLC.GL_POINTS);
	FOR i:=-20 TO 20 DO FOR j:=-20 TO 20 DO FOR k:=-20 TO 20 DO
		GL.glVertex3f(i,j,k);
	END END END;
	GL.glEnd;
	GL.DelFCR();
	GL.glXSwapBuffers(display, win);
END drawstars;


PROCEDURE Reshape(w, h: LONGINT);
BEGIN
GL.SetFCR();
	GL.glViewport(0, 0, w, h);
	GL.glClearColor(0.0, 0.0, 0.0, 0.0);
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.glFrustum(-1,1,-1,1, 5, 60);
	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity();
	GL.glTranslatef(0.0, 0.0, -40.0);
GL.DelFCR();
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
		IF debug THEN Trace.String("context deleted"); Trace.Ln; END;
	END;

	(* do we have a window *)
	IF win # 0 THEN
		(* Unmap the window*)
		Api.UnmapWindow(display, win);
		(* Destroy the window *)
		res:= Api.DestroyWindow(display, win);
		win := 0;
		IF debug THEN Trace.String("window deleted"); Trace.Ln; END;
	END;

	(* do we have a display *)
	IF display # 0 THEN
		res := Api.CloseDisplay(display);
		display := 0;
		IF debug THEN Trace.String("display deleted"); Trace.Ln; END;
	END;

 END Close;

PROCEDURE  InitWindow(w, h: LONGINT; CONST title: ARRAY OF CHAR);
VAR
	res: LONGINT;
	masks: SET;
	buf: X11.Buffer;
	attrib : ARRAY [*] OF GL.GLint;  (* attributes of GL window *)

BEGIN
 display := X11.OpenDisplay(0);
 IF display =0 THEN
 	Trace.String(" cannot connect to X server"); Trace.Ln;
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
  	IF debug THEN Trace.String(" NO appropriate visual found"); Trace.Ln; END;
  	Close;
     RETURN;
 ELSE
	 IF debug THEN
		 Trace.String("visinfoptr.depth= "); Trace.Int(visinfoptr.depth,0); Trace.Ln;
	 	Trace.String("visinfoptr.visual ");  Trace.Int(visinfoptr.visualID, 0); Trace.Ln;
	END;
END;

 cmap := X11.CreateColormap(display, X11.DefaultRootWindow(display), visinfoptr.visual, X11.AllocNone);
 IF cmap = 0 THEN
 	IF debug THEN
	 	Trace.String(" cannot create colormap"); Trace.Ln;
	 	X11.GetErrorText(display, cmap, buf, LEN(buf));
	 	Trace.String("ERROR: CreateColormap = "); Trace.String(buf); Trace.Ln;
 	END;
 END;

 (* window event masks *)
 masks :=  Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask + Api.ButtonReleaseMask + Api.PointerMotionMask
 + Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask;

  (* window attributes *)
 swa.background_pixel := 0;
 swa.border_pixel := 0;
 swa.colormap := cmap;
 swa.event_mask := masks;

 masks := { Api.CWBackPixel, Api.CWBorderPixel, Api.CWColormap, Api.CWEventMask};

 win := Api.CreateWindow(display, X11.DefaultRootWindow(display), 0, 0, w, h,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, ADDRESSOF(swa));

  Api.MapWindow(display, win);

 res := Api.StoreName(display, win, title);


 glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
	 IF debug THEN Trace.String("glXCreateContext glctx= "); Trace.Int(glctx, 0); Trace.Ln; END;

 res := GL.glXMakeCurrent(display, win, glctx);
	IF debug THEN  Trace.String("glXMakeCurrent res= "); Trace.Int(res, 0); Trace.Ln; END;

END InitWindow;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN Trace.StringLn(str); Trace.Ln END;
END Wr;

(* process pending X11 events *)
PROCEDURE LoopForEvents;
VAR xev: X11.Event;
	res: LONGINT;
BEGIN
 WHILE Api.Pending(display)>0 DO
	X11.NextEvent(display, xev);
			CASE xev.typ OF
			X11.Expose:
					res := Api.GetWindowAttributes(display, win, ADDRESSOF(gwa));
					Reshape(gwa.width, gwa.height);
					Wr("Expose");
			| X11.KeyPress:	Wr("KeyPressed");
							alive := FALSE;
			| X11.KeyRelease:	Wr("KeyReleased");
			| X11.ButtonPress: Wr("ButtonPressed");
			| X11.ButtonRelease: Wr("ButtonRelease");
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

		drawstars;
		 (* measure timing info *)
		INC(frames);
		IF Kernel.Expired(timer) THEN
			Trace.Int(frames,0); Trace.String(" frames in 5 secs.");
			Trace.String(" FPS = "); Trace.Int(frames DIV 5,0);
			Trace.Ln;
			Kernel.SetTimer(timer,5000);
			frames := 0;
		END;
END;

END MainLoop;

PROCEDURE Open*;
BEGIN
	width := 300; height := 300;
	InitWindow(width, height, 'XOLOTL-HYBRID' );

	Reshape(width, height );
	(* enter to main loop *)
	MainLoop;

	(* finally close the window *)
	control.Close;
	Close;
END Open;


BEGIN
GL.InitOpenGL;
END XLGear.

XLGear.Open~

SystemTools.Free XLGear ~ 