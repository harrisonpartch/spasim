MODULE MyXGear2; (** AUTHOR "fnecati"; PURPOSE "glxgears for commandline run"; *)

(* Test: FULLSCREEN,  Press F1, F11 F12,  window close events *)

IMPORT
	X11, Api := X11Api, GL:=OpenGL, GLC := OpenGLConst, Kernel, Inputs, KS := X11KeySymDef,
	 Math , Raster, WMGraphics,  SYSTEM, V := XF86VMode, StdIO, Commands ;

(*
Opens a native X11 window and renders.
From command line, linux terminal, run with : aos  -x  MyXGear2.Open
or
 from oberon window:   MyXGear2.Open ~
*)


CONST
	debug = TRUE; (* for window creation/closing *)
	debugevents = TRUE; (* for testing events *)

	 (* show window with window decorations *)

	pi = Math.pi;
	TITLE= "Oberon GL Gear";


TYPE
	Hints = RECORD
		flags: SET;
		functions: LONGWORD;
		decorations: LONGWORD;
		inputMode: LONGWORD;
		status: LONGWORD;
	END;


VAR
	timer : Kernel.MilliTimer;
	context: Commands.Context; (* StdIO context *)

	display: X11.DisplayPtr;
	screen: LONGINT;
	win: X11.Window; (* our window instance *)
	glctx : GL.GLXContext;  (* GL context *)

	fullscreen, fullwindow, windecorations : BOOLEAN;

	doubleBuffered: BOOLEAN;
	winAttr : Api.XSetWindowAttributes; (* set window attributes*)
	wmDelete: X11.Atom;

(* original desktop mode which we save so we can restore it later *)

	 desktopMode: V.ModeInfo;
	width, height : LONGINT; (* size of window *)

	alive : BOOLEAN; (* for main loop control *)
	curcursor: LONGINT;

CONST
	ML = 0;  MM = 1;  MR = 2;


VAR
	event: Api.XEvent;  xbuttons: SET;
	compstatus: Api.ComposeStatus;

	MMseen, MRseen: BOOLEAN;
	noEventCount: LONGINT;


VAR
	keySymbol: ARRAY 256 OF LONGINT;
	currX, currY: LONGINT;

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
     interval, bres: LONGINT;
BEGIN
	rotx := 20;  roty := 30;  rotz := 0;  angle := 20;

(*	(* lightPos := [ 5.0, 5.0, 10.0, 1.0];*)
	lightPos := [ 1.0, 1.0, 1.0, 0.0];  (* directional *)
	red := [ 0.8, 0.1, 0.0, 1.0];
	green := [ 0.0, 0.8, 0.2, 1.0];
	blue := [ 0.2, 0.2, 1.0, 1.0];
*)
	interval := 0;
		IF GL.glXSwapIntervalEXT # NIL THEN
			GL.glXSwapIntervalEXT(display, win, interval);
			context.out.String("GL.glXSwapIntervalEXT # NIL"); context.out.Ln;
		ELSIF GL.glXSwapIntervalSGI # NIL THEN
			bres := GL.glXSwapIntervalSGI(interval);
			context.out.String("GL.glXSwapIntervalSGI # NIL"); context.out.Ln;
		ELSIF GL.glXSwapIntervalMESA # NIL THEN
			bres := GL.glXSwapIntervalMESA(interval);
			context.out.String("GL.glXSwapIntervalMESA # NIL"); context.out.Ln;
		END;
	context.out.Ln; context.out.Update;


    lightPos[0] := 5.0;	lightPos[1] := 5.0;  lightPos[2] := 10.0; lightPos[3] := 1.0;
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
	GL.Rotatef( -2.0 * angle - 25.0, 0.0, 0.0, 1.0);
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
	GL.Frustum(-1, 1, -1, 1,  5.0, 100.0);
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

	(* switch back to original desktop resolution if we were in fullscreen *)
	IF fullscreen THEN
		res := V.SwitchToMode(display, screen, desktopMode);
		res := V.SetViewPort(display, screen, 0, 0);
	END;


	(* do we have a window *)
	IF win # 0 THEN
		(* Unmap the window*)
		Api.UnmapWindow(display, win);
		(* Destroy the window *)
		res:= Api.DestroyWindow(display, win);
		win := 0;
		IF debug THEN context.out.String("window deleted"); context.out.Ln; context.out.Update; END;
	END;

	(* do we have a display *)
	IF display # 0 THEN
		res := Api.CloseDisplay(display);
		IF debug THEN context.out.String("display deleted"); context.out.Ln; context.out.Update; END;
	END;

 END Close;

PROCEDURE  InitWindow(): BOOLEAN;
VAR
	res: LONGINT;
	masks: LONGWORD;
	buf: X11.Buffer;

	visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)
	cmap : X11.Colormap; (* colormap for window *)
	att : POINTER TO ARRAY OF GL.Int;  (* attributes of GL window *)
	glxMajor, glxMinor, wmMajor, wmMinor: LONGINT;
	dispWidth, dispHeight: LONGINT;
	modes : V.PModeInfo;
	bmodes : V.ModeInfo;
	modnum, bestmode: LONGINT;
	i: LONGINT;
	dumysize: Api.XSizeHints;
	defwin: X11.Window;

BEGIN
	display := Api.OpenDisplay("");
	IF display =0 THEN
		context.out.String(" cannot connect to X server"); context.out.Ln; context.out.Update;
		RETURN FALSE;
	END;

	screen := X11.DefaultScreen(display);
	res := V.QueryVersion(display, wmMajor, wmMinor);
	IF debug THEN
		context.out.String("XF86 VideoMode extension version ");
		context.out.Int(wmMajor,0); context.out.Char(".");
		context.out.Int(wmMinor,0); context.out.Ln; context.out.Update;
	END;


	res := V.GetAllModeLines(display, screen, modnum, modes);

	(* save desktop-resolution before switching modes *)
	desktopMode := modes[0];
	IF debug THEN
		context.out.String("desktopMode=");
		context.out.Int( desktopMode.hdisplay, 6);
		context.out.Int(desktopMode.vdisplay, 6); context.out.Ln;
		context.out.String(" # of modes= "); context.out.Int(modnum,0); context.out.Ln;
		context.out.Update;
	END;

	bestmode := 0;  (* set best mode to current *)

	(* look for mode with requested resolution *)
	 FOR i:=0 TO modnum-1 DO
 		bmodes := modes[i];
 		IF (bmodes.hdisplay=width) & (bmodes.vdisplay = height) THEN bestmode:=i; END;
 		IF debug THEN
 			context.out.Int(i+1, 0); context.out.Char(":");
 			context.out.Int( bmodes.hdisplay, 6);
			context.out.Int(bmodes.vdisplay, 6); context.out.Ln;
			context.out.Update;
		END;
	 END;
	bmodes := modes[bestmode];
	dispWidth := bmodes.hdisplay;
	dispHeight := bmodes.vdisplay;

 	IF debug THEN
		context.out.String("bestmode: "); context.out.Int(bestmode,0); context.out.Ln;
		context.out.String("resolution:  "); context.out.Int(dispWidth,0); context.out.Char("x");
		context.out.Int(dispHeight, 0); context.out.Ln; context.out.Update;
 	END;

(*	X11.Free(ADDRESSOF(modes));*)

	doubleBuffered := TRUE;

(*  NEW(att, 13);
  att[0] := GLC.GLX_RGBA;
  att[1] := GLC.GLX_DOUBLEBUFFER;
  att[2] := GLC.GLX_DEPTH_SIZE;		att[3] := 24;
  att[4] := GLC.GLX_STENCIL_SIZE;	att[5] := 8;
  att[6] := GLC.GLX_RED_SIZE;  		att[7] := 8;
  att[8] := GLC.GLX_GREEN_SIZE;	att[9] := 8;
  att[10] := GLC.GLX_BLUE_SIZE;		att[11] := 8;
  att[12] := 0 ;
*)

 NEW(att, 11);
  att[0] := GLC.GLX_RGBA;
  att[1] := GLC.GLX_DOUBLEBUFFER;
  att[2] := GLC.GLX_DEPTH_SIZE;		att[3] := 16;
  att[4] := GLC.GLX_RED_SIZE;  		att[5] := 4;
  att[6] := GLC.GLX_GREEN_SIZE;	att[7] := 4;
  att[8] := GLC.GLX_BLUE_SIZE;		att[9] := 4;
  att[10] := 0 ;


	(* try to find a visual with this attribs *)
	visinfoptr := GL.glXChooseVisual(display, screen , ADDRESSOF(att[0]));
	 IF visinfoptr = NIL THEN
		IF debug THEN context.out.String(" NO appropriate visual found"); context.out.Ln; context.out.Update; END;
		Close;
		RETURN FALSE;
	ELSE
		IF debug THEN
			context.out.String("visinfoptr.depth= "); context.out.Int(visinfoptr.depth,0); context.out.Ln;
			context.out.String("visinfoptr.visual ");  context.out.Int(visinfoptr.visualID, 0); context.out.Ln;
			context.out.Update;
		END;
	END;


	res := GL.glXQueryVersion(display, glxMajor, glxMinor);
	IF debug THEN
		context.out.String("GLX-Version "); context.out.Int(glxMajor,0); context.out.Char("."); context.out.Int(glxMinor,0); context.out.Ln;
		context.out.Update;
	END;

	(* create GL context *)
	 (* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
	glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
	IF debug THEN context.out.String("glXCreateContext glctx= "); context.out.Int(glctx, 0); context.out.Ln; context.out.Update; END;

	defwin :=  Api.RootWindow(display, visinfoptr.screen);
	(* create a color map *)
	cmap := X11.CreateColormap(display,  defwin, visinfoptr.visual, X11.AllocNone);
	IF cmap = 0 THEN
		IF debug THEN
			context.out.String(" cannot create colormap"); context.out.Ln;
(*			X11.GetErrorText(display, cmap, buf, LEN(buf));
			context.out.String("ERROR: CreateColormap = "); context.out.String(buf); context.out.Ln;
*)
			context.out.Update;
		END;
	END;

	(* window attributes *)
	winAttr.colormap := cmap;
	winAttr.borderPixel := 0;
	winAttr.backgroundPixel := 0;


	IF fullscreen THEN
		context.out.String("fullscreen"); context.out.Ln; context.out.Update;
		(* Use the XF86VidMode extension to control video resolution *)
		(* Change the current video mode, switch to fullscreen *)
		(* Unlock mode switch if necessary *)
		res := V.LockModeSwitch(display, screen, 0);
		(* Change the video mode to the desired mode *)
		res := V.SwitchToMode(display, screen, bmodes);
		(* Set viewport to upper left corner (where our window will be) *)
       	res:= V.SetViewPort(display, screen, 0, 0);
       	(* Lock mode switch *)
  		res := V.LockModeSwitch(display, screen, 1);

		context.out.String("resolution-2 "); context.out.Int(dispWidth,0); context.out.Char("x"); context.out.Int(dispHeight, 0);
		context.out.Ln; context.out.Update;

		winAttr.overrideRedirect := TRUE;
		 (* window event masks *)
		winAttr.eventMask :=  Api.ExposureMask + Api.KeyPressMask + Api.ButtonPressMask + Api.StructureNotifyMask ;
		masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask + Api.CWOverrideRedirect;

		win := Api.CreateWindow(display, defwin,  0, 0, dispWidth, dispHeight,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, winAttr);

		(*Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, 0, 0);*)
		Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, dispWidth DIV 2, dispHeight DIV 2);
		Api.MapWindow(display, win);
		res := Api.GrabKeyboard(display, win, Api.True, Api.GrabModeAsync , Api.GrabModeAsync, Api.CurrentTime);
		res := Api.GrabPointer(display, win, Api.True, Api.ButtonPressMask, Api.GrabModeAsync, Api.GrabModeAsync, win, X11.None, Api.CurrentTime);
		context.out.String("fullscreen ends"); context.out.Ln; context.out.Update;
	ELSE
		context.out.String("NOT fullscreen"); context.out.Ln; context.out.Update;
		(* create a window in windowed mode *)
		(* window event masks *)
		winAttr.eventMask := Api.ExposureMask + Api.KeyPressMask + Api.ButtonPressMask + Api.StructureNotifyMask;

		masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask;
		win := Api.CreateWindow(display, defwin,  100, 100, width, height,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, winAttr);

		(* only set window title and handle wm_delete_events if in windowed mode *)
		wmDelete := Api.InternAtom(display, "WM_DELETE_WINDOW", Api.True);
		res := Api.SetWMProtocols(display, win, ADDRESSOF(wmDelete), 1);
		Api.SetStandardProperties(display, win, TITLE, TITLE, Api.None, 0, 0, dumysize);
		Api.MapWindow(display, win);
	END;
	IF win = 0 THEN
		Close;
		RETURN FALSE;
	END;


	res := GL.glXMakeCurrent(display, win, glctx);
	IF res = 0 THEN
		Close;
		RETURN FALSE;
	END;

	IF debug THEN
		context.out.String("glXMakeCurrent res= "); context.out.Int(res, 0); context.out.Ln;
		IF GL.glXIsDirect(display, glctx)=1 THEN
			context.out.String("DRI enabled"); context.out.Ln;
		ELSE
			context.out.String("no DRI available"); context.out.Ln;
		END;
		context.out.Update;
	END;

 RETURN TRUE;
END InitWindow;

PROCEDURE ToggleDecorations;
VAR 	hints: Hints;
	property: X11.Atom;
BEGIN
	IF  ~fullwindow OR  ~fullscreen THEN
	windecorations := ~windecorations;

		property := Api.InternAtom(display, "_MOTIF_WM_HINTS", Api.True);

		IF ~windecorations THEN hints.flags := {1};END;
		X11.ChangeProperty(display, win, property, property, 32, Api.PropModeReplace, ADDRESSOF(hints), 5);
	END;

END ToggleDecorations;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN context.out.String(str); context.out.Ln; context.out.Update; END;
END Wr;

(* save the rendered image to disk when mouse clicked *)
PROCEDURE SaveImage(CONST fname: ARRAY OF CHAR);
VAR image: Raster.Image;
	i, res: LONGINT;
BEGIN
	NEW(image);
	Raster.Create(image, width, height,Raster.BGRA8888);

(* needs to be flipped in y *)
	FOR i:=0 TO height-1 DO
		GL.ReadPixels(0, height-1-i, width, 1, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, image.adr + i*width*4);
	END;

(* GL.ReadPixels(0, 0, width, height, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, image.adr); *)
(* and  flip using Raster module  *)
	WMGraphics.StoreImage(image, fname,res);
	IF res = 0 THEN
	  context.out.String(fname); context.out.String(" saved"); context.out.Ln; context.out.Update;
	END;
	image := NIL;
END SaveImage;

	PROCEDURE CheckAlternateKeys( VAR mb: SET );
	BEGIN
		IF ~MMseen & (Api.ControlMask IN xbuttons) THEN INCL( mb, MM ) END;
		IF ~MRseen & (Api.Mod1Mask IN xbuttons) THEN INCL( mb, MR ) END
	END CheckAlternateKeys;

	(* mouse handler *)
	PROCEDURE SendMouseMsg( x, y, dz: LONGINT; xbuttons: SET32 );
	VAR mm: Inputs.AbsMouseMsg;
	BEGIN
		mm.keys := {};
		mm.x := x;  mm.y := y;  mm.dz := dz;
		IF Api.Button1Mask IN xbuttons THEN  INCL( mm.keys, ML )  END;
		IF Api.Button2Mask IN xbuttons THEN  INCL( mm.keys, MM );  MMseen := TRUE  END;
		IF Api.Button3Mask IN xbuttons THEN  INCL( mm.keys, MR );  MRseen := TRUE  END;
		IF ~(MMseen & MRseen) THEN  CheckAlternateKeys( mm.keys )  END;
(*		Inputs.mouse.Handle( mm );*)
		currX := x; currY := y;
		IF debugevents THEN context.out.Int(x,0); context.out.Int(y, 4);  context.out.Int(dz,5); context.out.Ln;  context.out.Update; END;
	END SendMouseMsg;

	(* keyboard handler *)
	PROCEDURE SendKeyboardMsg( km: Inputs.KeyboardMsg );
	BEGIN
	     IF km.ch='q' THEN alive := FALSE; END;
	     IF km.ch = 's' THEN SaveImage('glxgears.bmp'); END;
		IF debugevents THEN context.out.Char(km.ch); context.out.Ln; context.out.Update; END;
	END SendKeyboardMsg;

	(* Returns wether key (SHIFT, CTRL or ALT) is pressed *)
	PROCEDURE KeyState( ): SET;
	VAR keys: SET;
	BEGIN
		keys := {};
		IF Api.ShiftMask IN xbuttons THEN  INCL( keys, Inputs.LeftShift )  END;
		IF Api.ControlMask IN xbuttons THEN  INCL( keys, Inputs.LeftCtrl )  END;
		IF Api.Mod1Mask IN xbuttons THEN  INCL( keys, Inputs.LeftAlt )  END;
		IF Api.Mod4Mask IN xbuttons THEN  INCL( keys, Inputs.LeftMeta )  END;
		IF Api.Mod5Mask IN xbuttons THEN  INCL( keys, Inputs.RightAlt )  END;
		RETURN keys
	END KeyState;


	PROCEDURE ToggleFullWindow;
	VAR
		cm: Api.XClientMessageEvent;
		xev: Api.XEvent;
		dl: Api.Data40;
		wmstate, wmfullscreen: X11.Atom;
		res: LONGINT;
		defwin: X11.Window;
	BEGIN
	wmstate := Api.InternAtom(display, "_NET_WM_STATE", Api.False);
	wmfullscreen := Api.InternAtom(display, "_NET_WM_STATE_FULLSCREEN", Api.False);

	fullwindow := ~ fullwindow;
	cm.typ := Api.ClientMessage;
	cm.window := win;
	cm.messageType := wmstate;
	cm.format := 32;
	IF fullwindow THEN dl[0] := 1; ELSE dl[0] := 0; END;
	dl[1] := wmfullscreen;	dl[2] := 0;
	cm.data:= dl;
	xev := SYSTEM.VAL(Api.XEvent, cm);
	defwin := X11.DefaultRootWindow(display);
	res := Api.SendEvent(display, defwin, Api.False, Api.SubstructureNotifyMask, ADDRESSOF(xev));

	END ToggleFullWindow;

	(* toggle all X11- predefined cursors *)
	PROCEDURE ChangeCursor;
	VAR cursor: X11.Cursor;
	BEGIN
		curcursor := (curcursor MOD Api.XC_num_glyphs);
		cursor := X11.CreateFontCursor(display, curcursor);
		X11.DefineCursor(display, win, cursor);
		Api.FreeCursor(display, cursor);
		X11.Flush(display);
		INC(curcursor);
	END ChangeCursor;

	PROCEDURE WrKey(keyc: LONGINT; buf: ARRAY OF CHAR; keysym: X11.KeySym);
	BEGIN
		context.out.String("keysym: "); context.out.Int(keysym,0); context.out.String(":"); context.out.Hex(keysym, 8);

		context.out.String("  char: "); context.out.Char(CHR(keysym)); context.out.Ln;
		context.out.String("keycount: "); context.out.Int(keyc,0); context.out.Ln;
		context.out.String("keybuffer: "); context.out.String(buf); context.out.Ln;
		context.out.Update;
	END WrKey;


(* process pending X11 events, from Unix.KbdMouse.Mod *)
	PROCEDURE PollXQueue;
	VAR
		 keysym: X11.KeySym;
		 buffer: ARRAY 32 OF CHAR;
		keycount: LONGINT;
		 cm: Api.XClientMessageEvent;
		 ke: Api.XKeyEvent;
		 be: Api.XButtonEvent;
		 cn : Api.XConfigureEvent;
		 ee : Api.XExposeEvent;
		 atomName: Api.PChar;
	BEGIN
	 WHILE Api.Pending(display) > 0 DO

				Api.NextEvent( display, event );
				CASE event.typ OF
				| Api.Expose: Wr("Expose, GraphicsExpose");
								ee := SYSTEM.VAL(Api.XExposeEvent, event);
								context.out.String("expose serial"); context.out.Int(ee.serial,5); context.out.Ln;
								context.out.Update;
								IF ee.count = 0 THEN DrawGears(); END;

				| Api.ConfigureNotify: Wr("ConfigureNotify");
						cn := SYSTEM.VAL(Api.XConfigureEvent, event);

			                    (* call Reshape only if our window-size changed *)
						IF (cn.width # width) OR  (cn.height # height) THEN
								width := cn.width;
								height := cn.height;
								Reshape(width, height);
						END;

				| Api.ButtonPress: Wr("ButtonPress");
							be := SYSTEM.VAL(Api.XButtonEvent, event);
							context.out.String("sendEvent="); IF be.sendEvent  THEN context.out.String("TRUE") ELSE context.out.String("FALSE") END; context.out.Ln;
							context.out.String("be.button="); context.out.Int(be.button,2); context.out.Ln;
							context.out.Update;
							(* IF be.button = Api.Button1 THEN
								alive := FALSE;
							END; *)
				| Api.KeyPress: Wr("KeyPress");
								ke := SYSTEM.VAL(Api.XKeyEvent, event);
								keycount := Api.LookupString(ke, buffer, X11.BufferSize, keysym, compstatus );

								(* keysym := Api.LookupKeysym(ke, 0); *)
								WrKey(keycount, buffer, keysym);

								IF (keysym = KS.XK_Escape) OR (keysym = KS.XK_q1) OR (keysym = KS.XK_Q) THEN alive := FALSE

								ELSIF	(keysym = KS.XK_F1) THEN  Wr("F1 pressed"); (* start from begining *)
											Close;
											fullscreen := ~ fullscreen;
											IF InitWindow() THEN
												InitGears;
												Reshape(width, height);
											END;
								ELSIF (keysym = KS.XK_Up) THEN  Wr("K_Up"); roty := roty + 5.0;
								ELSIF (keysym = KS.XK_Down) THEN Wr("K_Down"); roty := roty -5.0;
								ELSIF (keysym = KS.XK_F11) THEN ToggleFullWindow;
								ELSIF (keysym = KS.XK_F12) THEN ToggleDecorations;
								ELSIF (keysym = KS.XK_m1) THEN ChangeCursor();
								END;

				| Api.ClientMessage: Wr("ClientMessage");
						cm := SYSTEM.VAL(Api.XClientMessageEvent, event);
						(* context.out.String("sendEvent="); context.out.Boolean(cm.sendEvent); context.out.Ln; *)
						atomName := Api.GetAtomName(display, cm.messageType);
						context.out.String("cm.messageType= "); context.out.Int(cm.messageType, 0); context.out.Ln;
						IF atomName # NIL THEN
							context.out.String("atomName="); context.out.String(atomName^); context.out.Ln;
						END;


						context.out.String("cm.data[0]="); context.out.Int(cm.data[0], 0); context.out.Ln;
						context.out.String("wmDeleteWindow="); context.out.Int(wmDelete,0); context.out.Ln;
						atomName := Api.GetAtomName(display, SYSTEM.VAL(X11.Atom, cm.data[0]));
						IF atomName # NIL THEN
							context.out.String("cm.data[0] atomName="); context.out.String(atomName^); context.out.Ln;
						END;
						context.out.Update;

						IF  cm.data[0] = wmDelete THEN
						    Wr("DeleteWindow");
						    alive := FALSE;
						END;
				ELSE

				END;
		END;
	END PollXQueue;

(* windows main loop *)
PROCEDURE MainLoop;
VAR	frames : LONGINT;
BEGIN
frames := 0;
Kernel.SetTimer(timer, 5000);
alive := TRUE;

WHILE  alive  DO
		(* process X11 events *)
		PollXQueue;
		DrawGears();
		angle := angle + 2.0;

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

	width := 800; height := 600; (* window size*)
	fullscreen := FALSE;
(*	fullwindow := TRUE; *)
	windecorations := TRUE;
	IF ~ InitWindow() THEN RETURN; END;
	GL.ReadExtensions();
	InitGears();
	Reshape(width, height);

	(* enter to main loop *)
	MainLoop;

	(* finally close the window *)
	Close;
END Open;


BEGIN

END MyXGear2.

MyXGear2.Open~

System.Free MyXGear2 ~

System.FreeDownTo OpenGL ~ 