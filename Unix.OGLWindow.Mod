MODULE OGLWindow; (** AUTHOR "fnecati"; PURPOSE "OpenGL enabled OO X11Window wrapper"; *)
(*! fullscreen added *)
IMPORT
	 SYSTEM, X11, Api := X11Api, V := XF86VMode, Modules, GL:=OpenGL, GLC := OpenGLConst,
	 Kernel, Inputs , Objects, KernelLog;

(* Note: in OpenGL, window origin is lower left
	todo: ???

	*)
CONST
	debug = FALSE; (* for window creation/closing *)
	debugevents = FALSE; (* for testing events *)


	COMPATIBILITY_PROFILE* = 0;
	CORE_PROFILE* = 1;

CONST
	(** mouse buttons *)
	ML* = 0;  MM* = 1;  MR* = 2;


TYPE
	Hints = RECORD
		flags: SET;
		functions: LONGWORD;
		decorations: LONGWORD;
		inputMode: LONGWORD;
		status: LONGWORD;
	END;

	GLXFBConfig = POINTER {UNSAFE} TO RECORD END;
	GLXFBConfigPtr =  POINTER {UNSAFE} TO ARRAY OF GLXFBConfig;

VAR
	keySymbol: ARRAY 256 OF LONGINT;
	xbuttons: SET32;
	compstatus: Api.ComposeStatus;


(** OpenGL enabled Window Object *)
TYPE Window* = OBJECT
VAR
	fpstimer-, idletimer : Kernel.MilliTimer;

	(* window variables *)
	display: X11.DisplayPtr;
	screen: LONGINT;
	win : X11.Window ; (* window handle *)
	glctx : GL.GLXContext;  (* GL context handle *)

	(* original desktop mode which we save so we can restore it later *)
	 desktopMode :  V.ModeInfo;

	title-: ARRAY 128 OF CHAR; (** title of window *)
	active : BOOLEAN; (* for main loop control *)

	left-, top-: LONGINT; (** top left origin of window *)
	width-, height- : LONGINT; (** size of window *)

	debugframes-: BOOLEAN; (** print FPS ? *)
	frames-:LONGINT;  (** # of frames *)

	idletime-: LONGINT; (** ms, for IdleDisplay *)
	cmdlinerun*: BOOLEAN; (** is this window opened from command line? *)

	fullscreen-, fullwindow-, decorations-: BOOLEAN;


	glxMajor, glxMinor, wmMajor, wmMinor: LONGINT;
(*	dispWidth, dispHeight: LONGINT; *)

	gamemode-: BOOLEAN; (** if true poll Display procedure *)
	hidecursor-: BOOLEAN; (** hide/show cursor *)
	currentfms-: LONGINT; (* current frame update time *)
	wmDelete : X11.Atom;
(*	wmstate, wmfullscreen: X11.Atom; *)

	(** constructor, initlialize window object, fs: fullscreen: true/false *)
	PROCEDURE & Init*(w, h, l, t: LONGINT; fs: BOOLEAN);
	BEGIN
		width := w; height := h;
		left := l;  top := t ;
		title:="OGLWindow";
		idletime := 0;
		fullscreen := fs;
		fullwindow := FALSE;
		decorations := TRUE;
		hidecursor := FALSE;
		cmdlinerun := FALSE;
		IF ~ InitWindow() THEN Close; RETURN END;
	END Init;

	PROCEDURE GetWidth*(): LONGINT;
	BEGIN
		RETURN width;
	END GetWidth;

	PROCEDURE GetHeight*(): LONGINT;
	BEGIN
		RETURN height;
	END GetHeight;

	(** Close the window *)
	PROCEDURE Close*;
	BEGIN
		active := FALSE;
	END Close;

	(** abstract: reshape GL window, called while resizing the window *)
	PROCEDURE Reshape*(w, h: LONGINT);
	END Reshape;

	(** abstract: Display procedure for GL window *)
	PROCEDURE Display*();
	END Display;

	(** Redisplay proc for GL,  sends update message to the Window to call Display proc. *)
	PROCEDURE ReDisplay*();
	VAR
		xev: Api.XEvent;
		res: LONGINT;
	BEGIN
		xev.typ := Api.Expose;
		xev.window := win;
		res := Api.SendEvent(display, win, Api.False, Api.ExposureMask, ADDRESSOF(xev));
		X11.Flush(display);
	END ReDisplay;

	(** abstract: called when window opened and GL context created *)
	PROCEDURE OnLoad*();
	END OnLoad;

	(** abstract: when iddle time expired, redisplay GL content.
	Called when SetIdleTime (> 0) and SetGameMode(TRUE) *)
	PROCEDURE IdleDisplay*();
	END IdleDisplay;

	(** make GL context current *)
	PROCEDURE MakeCurrent*();
	VAR resb: X11.Bool;
	BEGIN
		resb := GL.glXMakeCurrent(display, win, glctx);
		IF debug THEN KernelLog.String(" MakeCurrent:"); KernelLog.Boolean(resb=1); KernelLog.Ln; END;
	END MakeCurrent;

	(** deactivate the current GL context *)
	PROCEDURE DeActivate*();
	VAR resb: X11.Bool;
	 BEGIN
		resb := GL.glXMakeCurrent(display, 0, 0);
		IF debug THEN KernelLog.String(" DeActivate:"); KernelLog.Boolean(resb=1); KernelLog.Ln; END;
	END DeActivate;

	(** swap the GL context contents to the window *)
	PROCEDURE SwapBuffers*();
	BEGIN
		GL.glXSwapBuffers(display, win);
	END SwapBuffers;

	(* get current display of this window *)
	PROCEDURE GetDisplay*(): ADDRESS;
	BEGIN
		RETURN display;
	END GetDisplay;

	(* get current gl context of this window *)
	PROCEDURE GetContext*(): Api.XID;
	BEGIN
		RETURN glctx;
	END GetContext;

	(** Abstract Window Procedures *)
	(** called when window get focus *)
	PROCEDURE FocusGot*();
	END FocusGot;

	(** called when window lost fucus  *)
	PROCEDURE FocusLost*();
	END FocusLost;

	(** called when a key pressed *)
	PROCEDURE KeyEvent* (ucs : LONGINT; flags : SET; keysym : LONGINT);
	END KeyEvent ;

	(** called when mouse button pressed *)
	PROCEDURE PointerDown* (x, y : LONGINT; keys : SET);
	END PointerDown;

	(** called when mouse button up  *)
	PROCEDURE PointerUp* (x, y : LONGINT; keys : SET);
	END PointerUp;

	(** called when mouse pointer moved *)
	PROCEDURE PointerMove* (x, y : LONGINT; keys : SET);
	END PointerMove;

	(** called when mouse wheel changed  *)
	PROCEDURE WheelMove*(dz : LONGINT);
	END WheelMove;

	(** resize the window *)
	PROCEDURE ResizeWindow*(w, h: LONGINT);
	BEGIN
		X11.ResizeWindow(display, win, ABS(w) ,ABS(h));
	END ResizeWindow;

	(** move the window to x,y and  resize width,height *)
	PROCEDURE MoveResizeWindow*(left0, top0, w, h: LONGINT);
	BEGIN
		X11.MoveResizeWindow(display, win, left0, top0, ABS(w) ,ABS(h));
	END MoveResizeWindow;

	(* close the window and its resources *)
	 PROCEDURE CloseWindow*();
	  VAR resb: X11.Bool;
	  	    res: LONGINT;
	 BEGIN
		(* do we have a rendering context *)
		IF glctx # 0 THEN
			(* Release the context *)
		    	resb := GL.glXMakeCurrent(display, 0, 0);
		    	(* Delete the context *)
			GL.glXDestroyContext(display, glctx);
			glctx := 0;
			IF debug THEN KernelLog.String("context deleted"); KernelLog.Ln; END;
		END;

		(* switch back to original desktop resolution if we were in fullscreen *)
		IF fullscreen THEN
			res := V.SwitchToMode(display, screen, desktopMode);
			X11.Flush(display);
			res := V.SetViewPort(display, screen, 0, 0);
			IF debug THEN KernelLog.String("switching desktop resolution"); KernelLog.Ln; END;
		END;

		(* do we have a window *)
		IF win # 0 THEN
			(* Unmap the window*)
			Api.UnmapWindow(display, win);
			(* Destroy the window *)
			res:= Api.DestroyWindow(display, win);
			IF debug THEN KernelLog.String("window deleted"); KernelLog.Ln; END;

		END;

		(* do we have a display *)
		IF display # 0 THEN
			res := Api.CloseDisplay(display);
			IF debug THEN KernelLog.String("display deleted"); KernelLog.Ln; END;
		END;

		IF cmdlinerun THEN
			Modules.Shutdown( Modules.Reboot );
		END;
	 END CloseWindow;

	(** make null cursor for mouse pointer *)
	PROCEDURE HideMousePointer*(hide: BOOLEAN);
	VAR
		fg : X11.Color;
		pixmap: X11.Pixmap;
		noCursor: X11.Cursor;
		data: ARRAY 8 OF CHAR;
		i : LONGINT;
	BEGIN
	(*	IF hide = hidecursor THEN RETURN END; *)
		hidecursor := hide;
		IF hidecursor THEN
			fg.red := 0;  fg.green := 0;  fg.blue :=0;
			FOR i:=0 TO 7 DO data[i] := 0X  END;
			pixmap := X11.CreateBitmapFromData( display, win, ADDRESSOF( data[0] ), 8, 8 );
			noCursor := X11.CreatePixmapCursor( display, pixmap, pixmap,  fg , fg, 0, 0 );

			X11.DefineCursor( display, win, noCursor );
			Api.FreeCursor(display, noCursor);
			X11.FreePixmap(display, pixmap);
		ELSE
			X11.DefineCursor( display, win, Api.XC_X_cursor );
		END;
	END HideMousePointer;

	(** Set mouse position to x,y *)
	PROCEDURE SetMousePosition*(x, y: LONGINT);
	BEGIN
		Api.WarpPointer(display, win, win,  0, 0, width, height, x, height-y-1);
		X11.Flush(display);
	END SetMousePosition;

	(** warp pointer to x,y *)
	PROCEDURE WarpPointer*(w, h: LONGINT; x, y: LONGINT);
	BEGIN
		Api.WarpPointer( display, 0, win, 0,0, w, h, x, y);
		(*X11.Flush(display);*)
	END WarpPointer;


	(** set title of the window *)
	PROCEDURE SetTitle*(tit: ARRAY OF CHAR);
	VAR res: LONGINT;
	BEGIN
		COPY(tit, title);
		 res := Api.StoreName(display, win, title);
	END SetTitle;

	(** set idle time  for calling IdleDisplay proc *)
	PROCEDURE SetIdleTime*(ms: LONGINT);
	BEGIN
		IF ms < 0 THEN ms := 0 END;
		idletime := ms;
	END SetIdleTime;

	(** print # frames per second, true/false *)
	PROCEDURE SetPrintFPS*(df: BOOLEAN);
	BEGIN
		debugframes := df;
	END SetPrintFPS;

	(** gm: TRUE-> Display procedure polled continuously *)
	PROCEDURE SetGameMode*(gm: BOOLEAN);
	BEGIN
		gamemode := gm;
	END SetGameMode;

	(** interval=1: vertical sync to video update rate; interval=0: disable vsynch, full speed *)
	PROCEDURE SetSwapInterval*(interval: LONGINT);
	VAR bres: LONGINT;
	BEGIN
		IF GL.glXSwapIntervalEXT # NIL THEN
			GL.glXSwapIntervalEXT(display, win, interval);
			(* KernelLog.String("GL.glXSwapIntervalEXT # NIL"); KernelLog.Ln; *)
		ELSIF GL.glXSwapIntervalSGI # NIL THEN
			bres := GL.glXSwapIntervalSGI(interval);
			(* KernelLog.String("GL.glXSwapIntervalSGI # NIL"); KernelLog.Ln; *)
		ELSIF GL.glXSwapIntervalMESA # NIL THEN
			bres := GL.glXSwapIntervalMESA(interval);
			(* KernelLog.String("GL.glXSwapIntervalMESA # NIL"); KernelLog.Ln; *)
		END;
	END SetSwapInterval;

	 (** set  window decorartion on: TRUE /off : FALSE *)
	PROCEDURE SetDecorations*(decor: BOOLEAN);
	VAR 	hints: Hints;
		property: X11.Atom;
	BEGIN
		IF  ~(fullscreen OR fullwindow) THEN
			decorations := decor;
			property := Api.InternAtom(display, "_MOTIF_WM_HINTS", Api.False);
			IF ~decor THEN
				hints.flags := {1};
			END;
			X11.ChangeProperty(display, win, property, property, 32, Api.PropModeReplace, ADDRESSOF(hints), 5);
		END;
	END SetDecorations;

	(** Set  window state to full window *)
	PROCEDURE SetFullWindow*(fullw: BOOLEAN);
	VAR
		cm: Api.XClientMessageEvent;
		xev: Api.XEvent;
		dl: Api.Data40;
		res: LONGINT;
		wmstate, wmfullscreen: X11.Atom;
		defwin: X11.Window;
	BEGIN
		IF (fullw = fullwindow) THEN RETURN END; (* no need to set again*)

		wmstate := Api.InternAtom(display, "_NET_WM_STATE", Api.False);
		wmfullscreen := Api.InternAtom(display, "_NET_WM_STATE_FULLSCREEN", Api.False);

		fullwindow := fullw;

		cm.typ := Api.ClientMessage; cm.window := win;  cm.messageType := wmstate;
		cm.format := 32;
		IF fullwindow THEN dl[0] := 1; ELSE dl[0] := 0; END;
		dl[1] := wmfullscreen;  dl[2] := 0;
		cm.data:=dl;  xev := SYSTEM.VAL(Api.XEvent, cm);
		defwin := X11.DefaultRootWindow(display);
		res := Api.SendEvent(display, defwin, Api.False, Api.SubstructureNotifyMask, ADDRESSOF(xev));
	END SetFullWindow;

	(** create a new opengl context with opengl version major, minor *)
	PROCEDURE SetProfile*(major, minor: LONGINT; flags: SET): BOOLEAN;
	VAR
		elemc, i: LONGINT;
		fbcfg {UNTRACED}: GLXFBConfig;
		fbcfgPtr {UNTRACED} : GLXFBConfigPtr;
(*		str: Strings.String;*)
		attr: POINTER TO  ARRAY OF GL.Int;
		newctxt: GL.GLXContext;
		res: X11.Bool;
	BEGIN

		res := GL.glXMakeCurrent(display, 0, 0);

		(* We need this for OpenGL3 *)
		fbcfgPtr := GL.glXChooseFBConfig(display, 0, 0, elemc);
		IF fbcfg = NIL THEN
			KernelLog.String("Couldn't get FB configs"); KernelLog.Ln;
		ELSE
			KernelLog.String("# of Got FB configs: ");
			KernelLog.Int(elemc, 0); KernelLog.Ln;
		END;

		NEW(attr, 13);
		(* for example OpenGL 3.3*)
		attr[i] := GLC.GLX_CONTEXT_MAJOR_VERSION_ARB; INC(i);
		attr[i] := major; INC(i);
		attr[i] := GLC.GLX_CONTEXT_MINOR_VERSION_ARB; INC(i);
		attr[3]:=minor; INC(i);

(*		 attr[i] := GLC.GLX_CONTEXT_FLAGS_ARB; INC(i);
		 attr[i] := GLC.GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB; INC(i);
*)

		attr[i] := GLC.GLX_CONTEXT_PROFILE_MASK_ARB; INC(i);
	(*		attr[i] := GLC.GLX_CONTEXT_CORE_PROFILE_BIT_ARB; INC(i) *)
		attr[i] := GLC.GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB; INC(i);

		attr[i] := 0; (* end of attribute list *)
		fbcfg := fbcfgPtr[0];

		newctxt := GL.glXCreateContextAttribsARB(display, fbcfg, 0, GLC.GL_TRUE, ADDRESSOF(attr[0]));
		IF newctxt = 0 THEN
			KernelLog.String("could not create OpenGL "); KernelLog.Int(major, 0); KernelLog.Char("."); KernelLog.Int(minor, 0);
			KernelLog.String(" context"); KernelLog.Ln;
			RETURN FALSE;
		END;

		IF glctx # 0 THEN
(*			(* Release the context *)
		    	res := GL.glXMakeCurrent(glWin.display, 0, 0);*)
		    	(* Delete the context *)
			GL.glXDestroyContext(display, glctx);
			IF debug THEN KernelLog.String("old context deleted"); KernelLog.Ln; END;
		END;

		glctx := newctxt;

		res := GL.glXMakeCurrent(display, win, glctx);

		GL.ReadOpenGLCore();

(*		str := GL.GetString(GLC.GL_VENDOR);
		KernelLog.String(" Vendor: "); KernelLog.String(str^); KernelLog.Ln;

		str := GL.GetString(GLC.GL_RENDERER);
		KernelLog.String(" Renderer: "); KernelLog.String(str^); KernelLog.Ln;

		str := GL.GetString(GLC.GL_VERSION);
		KernelLog.String(" Version: "); KernelLog.String(str^); KernelLog.Ln;
*)
		X11.Free(fbcfgPtr);
  		RETURN TRUE;
	END SetProfile;

	(* create an X11 window, and GL context *)
	PROCEDURE  InitWindow*(): BOOLEAN;
	VAR
		masks: LONGWORD;
		res: LONGINT;
		resb: X11.Bool;
		attrib : POINTER TO ARRAY OF GL.Int;  (* attributes of GL window *)
		swa : Api.XSetWindowAttributes; (* set window attributes*)
		visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)

		sizehints: Api.XSizeHints;

		modeInfos {UNTRACED}: V.PModeInfo;
		bestmodeInfo {UNTRACED} : V.ModeInfo;
		numModes, bestmodeNum: LONGINT;

		i: LONGINT;
		isbestFound: BOOLEAN;
		rootwin: Api.Window;
	BEGIN


	     (* get a connection *)
		display := X11.OpenDisplay(0);
		IF display =0 THEN
			KernelLog.String(" cannot connect to X server"); KernelLog.Ln;
		     RETURN FALSE;
		END;

(* ========================= *)

		screen := X11.DefaultScreen(display);
		res := V.QueryVersion(display, wmMajor, wmMinor);
		IF debug THEN
			KernelLog.String("XF86 VideoMode extension version ");
			KernelLog.Int(wmMajor,0); KernelLog.Char(".");
			KernelLog.Int(wmMinor,0); KernelLog.Ln;
		END;

(* ======================================= *)

		NEW(attrib, 13);

		attrib[0] := GLC.GLX_RGBA;
		attrib[1] := GLC.GLX_DOUBLEBUFFER;
		attrib[2] := GLC.GLX_DEPTH_SIZE;	attrib[3] := 24;
		attrib[4] := GLC.GLX_STENCIL_SIZE;	attrib[5] := 8;
		attrib[6] := GLC.GLX_RED_SIZE;  	attrib[7] := 8;
		attrib[8] := GLC.GLX_GREEN_SIZE;	attrib[9] := 8;
		attrib[10] := GLC.GLX_BLUE_SIZE;	attrib[11] := 8;
		attrib[12] := 0 ;

(*
		NEW(attrib, 17);
		attrib[0] := GLC.GLX_RGBA;
		attrib[1] := GLC.GLX_DOUBLEBUFFER;
		attrib[2] := GLC.GLX_DEPTH_SIZE;	attrib[3] := 24;
		attrib[4] := GLC.GLX_STENCIL_SIZE;	attrib[5] := 8;
		attrib[6] := GLC.GLX_RED_SIZE;  	attrib[7] := 8;
		attrib[8] := GLC.GLX_GREEN_SIZE;	attrib[9] := 8;
		attrib[10] := GLC.GLX_BLUE_SIZE;	attrib[11] := 8;

		attrib[12] := GLC.GLX_SAMPLE_BUFFERS;	attrib[13] := 1; (* MSAA *)
		attrib[14] := GLC.GLX_SAMPLES;	attrib[15] := 4; (* MSAA *)

		attrib[16] := 0 ;

*)

		(* try to find a visual with this attribs *)
		visinfoptr := GL.glXChooseVisual(display, screen , ADDRESSOF(attrib[0]));

		IF visinfoptr = NIL THEN
			IF debug THEN KernelLog.String(" NO appropriate visual found"); KernelLog.Ln; END;
			RETURN FALSE;
		END;

		IF debug THEN
			KernelLog.String("visinfoptr.depth= "); KernelLog.Int(visinfoptr.depth,0); KernelLog.Ln;
			KernelLog.String("visinfoptr.visual ");  KernelLog.Hex(visinfoptr.visualID, -4); KernelLog.String("H"); KernelLog.Ln;
		END;

		resb := GL.glXQueryVersion(display, glxMajor, glxMinor);
		IF debug THEN
			KernelLog.String("GLX-Version "); KernelLog.Int(glxMajor,0);
			KernelLog.Char("."); KernelLog.Int(glxMinor,0); KernelLog.Ln;
		END;

		rootwin :=  Api.RootWindow(display, visinfoptr.screen);

 		(* window attributes *)
 		swa.backgroundPixel := 0;
 		swa.borderPixel := 0;
		swa.colormap := X11.CreateColormap(display, rootwin, visinfoptr.visual, X11.AllocNone);

	 	IF swa.colormap = 0 THEN
			IF debug THEN
				KernelLog.String(" cannot create colormap"); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;


		IF fullscreen THEN

			res := V.GetAllModeLines(display, screen, numModes, modeInfos);

			(* save desktop-resolution before switching modes *)
			desktopMode := modeInfos[0];
			IF debug THEN
 				KernelLog.String("Desktop Mode Info:");KernelLog.Int(desktopMode.hdisplay, 6);
 				KernelLog.Int(desktopMode.vdisplay, 6);
				KernelLog.Ln;
				KernelLog.String("Other Modes: "); KernelLog.Ln;
				FOR i := 0 TO numModes-1 DO
					 KernelLog.Int(i, 0); KernelLog.Char(":");
					 KernelLog.Int(modeInfos[i].hdisplay, 6);
					 KernelLog.Int(modeInfos[i].vdisplay, 6);
					 KernelLog.Ln;
				 END;
			END;

			(* look for mode with the requested resolution and choose the best matched one *)
			i := 0;
		    bestmodeNum := 0;
		    WHILE (i < numModes) & (~isbestFound) DO
				bestmodeInfo := modeInfos[i];
	 			IF (bestmodeInfo.hdisplay = width) & (bestmodeInfo.vdisplay = height) THEN
	 				bestmodeNum := i;
	 				isbestFound := TRUE;
	 			END;
	 			INC(i);
			 END;

			(* if cant find the required mode choose desktop mode *)
			IF ~isbestFound THEN
				bestmodeInfo := desktopMode;
				fullscreen := FALSE;
				KernelLog.String("Full screen mode is not found: ");
				KernelLog.String("width= "); KernelLog.Int(width, 0);
				KernelLog.String(", height= "); KernelLog.Int(height, 0);
				KernelLog.Ln;
			ELSE
				bestmodeInfo := modeInfos[bestmodeNum];
			END;

			IF debug THEN
				KernelLog.String("bestmodeNum = "); KernelLog.Int(bestmodeNum, 0); KernelLog.Ln;
				KernelLog.String("bestmodeInfo.hdisplay= "); KernelLog.Int(bestmodeInfo.hdisplay, 0);  KernelLog.Ln;
				KernelLog.String("bestmodeInfo.vdisplay= "); KernelLog.Int(bestmodeInfo.vdisplay, 5); KernelLog.Ln;
			END;
		END;

		IF fullscreen & isbestFound THEN
			width := bestmodeInfo.hdisplay;
			height := bestmodeInfo.vdisplay;

			left := 0; top := 0;
			IF debug THEN
				KernelLog.String("Full screen width: "); KernelLog.Int(width, 0);
				KernelLog.String(" height= "); KernelLog.Int(height, 5);
				KernelLog.String(" bestmodeNum= "); KernelLog.Int(bestmodeNum, 0);
				KernelLog.Ln;
			END;
			(* Use the XF86VidMode extension to control video resolution *)
			(* Change the current video mode, switch to fullscreen *)
			(* Unlock mode switch if necessary *)
			res := V.LockModeSwitch(display, screen, 0);
			(* Change the video mode to the desired mode *)
			res := V.SwitchToMode(display, screen, bestmodeInfo);
			X11.Flush(display);
			(* Set viewport to upper left corner (where our window will be) *)
	       	res:= V.SetViewPort(display, screen, 0, 0);
	       	(* Lock mode switch *)
			res := V.LockModeSwitch(display, screen, 1);
			swa.overrideRedirect := TRUE;
			 (* window event masks *)
			swa.eventMask := Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask+ Api.ButtonReleaseMask + Api.PointerMotionMask +
	 		Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask ;

			masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask + Api.CWOverrideRedirect;

			win := Api.CreateWindow(display,  rootwin, 0, 0, width, height,
				        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);

			IF win = 0 THEN RETURN FALSE END;

			(* Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, 0, 0);*)
			Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, width DIV 2, height DIV 2);
			Api.MapWindow(display, win);
			res := Api.GrabKeyboard(display, win, Api.True, Api.GrabModeAsync , Api.GrabModeAsync, Api.CurrentTime);
			res := Api.GrabPointer(display, win, Api.True, Api.ButtonPressMask, Api.GrabModeAsync, Api.GrabModeAsync, win, X11.None, Api.CurrentTime);

		ELSE
 			(* create a window in windowed mode *)
	 		(* window event masks *)
			swa.eventMask := Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask+ Api.ButtonReleaseMask + Api.PointerMotionMask +
	 		Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask ;

	 		masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask ;

	 		win := Api.CreateWindow(display, rootwin, left, top, width, height,
			        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);
			IF win = 0 THEN RETURN FALSE END;

			(* set wm_delete_events if in windowed mode *)
			wmDelete := Api.InternAtom(display, "WM_DELETE_WINDOW", Api.True);
			res := Api.SetWMProtocols(display, win, ADDRESSOF(wmDelete), 1);

			sizehints.flags := Api.USPosition + Api.USSize;
			sizehints.x := left;  sizehints.y := top;  sizehints.width := width; sizehints.height := height;
			Api.SetStandardProperties(display, win, title, title, 0, 0, 0, sizehints);
	 		Api.MapWindow(display, win);
		END;

		IF ~fullscreen & fullwindow THEN
			SetFullWindow(TRUE);
		END;

		(* create GL context:
		GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
 		glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
		IF glctx = 0 THEN
			IF debug THEN KernelLog.String("glXCreateContext glctx= "); KernelLog.Int(glctx, 0); KernelLog.Ln; END;
			RETURN FALSE;
		END;

		RETURN TRUE;
	END InitWindow;

	(* Returns wether key (SHIFT, CTRL or ALT) is pressed *)
	PROCEDURE KeyState( ): SET32;
	VAR keys: SET32;
	BEGIN
		keys := {};
		IF Api.ShiftMask IN xbuttons THEN  INCL( keys, Inputs.LeftShift )  END;
		IF Api.ControlMask IN xbuttons THEN  INCL( keys, Inputs.LeftCtrl )  END;
		IF Api.Mod1Mask IN xbuttons THEN  INCL( keys, Inputs.LeftAlt )  END;
		IF Api.Mod4Mask IN xbuttons THEN  INCL( keys, Inputs.LeftMeta )  END;
		IF Api.Mod5Mask IN xbuttons THEN  INCL( keys, Inputs.RightAlt )  END;
		RETURN keys
	END KeyState;

	(* process pending X11 events for this window *)
	PROCEDURE LoopForEvents*();
	CONST bufsize=20;
	VAR
		event: Api.XEvent;
		kp : Api.XKeyEvent; 	be : Api.XButtonPressedEvent; em: Api.XExposeEvent;
		cm : Api.XClientMessageEvent; cn : Api.XConfigureEvent; me: Api.XMotionEvent;
	       keycount, xr, yr, x, y, i: LONGINT;
		keysym: X11.KeySym;
		newxbuttons, bdiff: SET32;
		rw, cw: X11.Window;
		ch: CHAR;
		flags: SET32;
		buffer: ARRAY bufsize OF CHAR;
		events: LONGINT;
	BEGIN
		events := Api.Pending(display);
		WHILE  events > 0 DO
			Api.NextEvent(display, event);
			CASE event.typ OF

			Api.KeyPress:
				kp := SYSTEM.VAL(Api.XKeyEvent, event);
				keycount := Api.LookupString( kp, buffer, bufsize, keysym, compstatus );
				X11.QueryPointer( display, event.window, rw, cw, xr, yr, x, y, newxbuttons );
				i := 0;
				IF keycount = 0 THEN
					bdiff := newxbuttons / xbuttons;  xbuttons := newxbuttons;
					ch := 0X;
					IF Api.ShiftMask IN bdiff THEN keysym := Inputs.KsShiftL
					ELSIF Api.ControlMask IN bdiff THEN keysym := Inputs.KsControlL
					ELSIF Api.Mod1Mask IN bdiff THEN keysym := Inputs.KsAltL
					ELSIF Api.Mod4Mask IN bdiff THEN keysym := Inputs.KsMetaL
					ELSIF Api.Mod5Mask IN bdiff THEN keysym := Inputs.KsAltR
					END;
					flags := KeyState();
					KeyEvent( ORD(0X), flags, LONGINT(keysym) )
				ELSE
					xbuttons := newxbuttons;
					WHILE i < keycount DO
						ch := buffer[i];  flags := KeyState( );
						keysym := keySymbol[ORD( ch )];
						IF ch = 0F1X THEN  ch := 0A4X
						ELSIF ch = 0F2X THEN ch := 0A5X
						END;
						KeyEvent( ORD(ch), flags, LONGINT(keysym));
						INC( i )
					END
				END;

			| Api.KeyRelease:
				kp := SYSTEM.VAL(Api.XKeyEvent, event);
				X11.QueryPointer( display, event.window, rw, cw, xr, yr, x, y, newxbuttons );
				bdiff := newxbuttons / xbuttons;  xbuttons := newxbuttons;
				IF bdiff # {} THEN
					ch := 0X;
					IF Api.ShiftMask IN bdiff THEN keysym := Inputs.KsShiftL
					ELSIF Api.ControlMask IN bdiff THEN keysym := Inputs.KsControlL
					ELSIF Api.Mod1Mask IN bdiff THEN keysym := Inputs.KsAltL
					ELSIF Api.Mod4Mask IN bdiff THEN keysym := Inputs.KsMetaL
					ELSIF Api.Mod5Mask IN bdiff THEN keysym := Inputs.KsAltR
					END;
					flags := KeyState( ) + {Inputs.Release};
					KeyEvent(ORD(ch), flags, LONGINT(keysym));
				END;

			| Api.ButtonPress: be := SYSTEM.VAL(Api.XButtonPressedEvent, event); Wr("ButtonPressed");
				be.y := height-be.y-1; (* gl window coord is lower-left *)
				CASE be.button OF
					| Api.Button1:   INCL( xbuttons, ML ); PointerDown( be.x, be.y, xbuttons );
					| Api.Button2:   INCL( xbuttons, MM ); PointerDown( be.x, be.y, xbuttons );
					| Api.Button3:   INCL( xbuttons, MR ); PointerDown( be.x, be.y, xbuttons );
					| Api.Button4:  WheelMove(-1);
					| Api.Button5:  WheelMove(+1);
					ELSE  (* ignore *)
					END;

			| Api.ButtonRelease:
				be := SYSTEM.VAL(Api.XButtonReleasedEvent, event);
				be.y := height-be.y -1 ; (* gl window coord is lower-left *)
				CASE be.button OF
					| Api.Button1:   EXCL( xbuttons, ML );PointerUp( be.x, be.y, xbuttons );
					| Api.Button2:   EXCL( xbuttons, MM );  PointerUp( be.x, be.y, xbuttons );
					| Api.Button3:  EXCL( xbuttons, MR );  PointerUp( be.x, be.y, xbuttons );
				(* 	| Api.Button4:  WheelMove(-1);
					| Api.Button5:  WheelMove(+1);
				*)
				ELSE  (* ignore *)
				END;

			| Api.MotionNotify: Wr("MotionNotify");
				me := SYSTEM.VAL(Api.XMotionEvent, event);
				PointerMove( me.x, height-me.y-1,  xbuttons );

			| Api.Expose, Api.GraphicsExpose:
				em := SYSTEM.VAL( Api.XExposeEvent, event );
				IF em.count = 0 THEN (* wait until last message*)
					Display;
				END;

			| Api.ConfigureNotify: Wr("ConfigureNotify");
				cn := SYSTEM.VAL(Api.XConfigureEvent, event);
				(* call Reshape only if our window-size changed *)
				IF (cn.width # width) OR  (cn.height # height) THEN
					left := cn.x; top := cn.y;
					width := cn.width;
					height := cn.height;
					Reshape(width, height);
				END;

				IF debugevents THEN
					KernelLog.String("x,y, w, h: ");
					KernelLog.Int(left,0); KernelLog.Int(top,5); KernelLog.Int(width, 5); KernelLog.Int(height,5);
					KernelLog.Ln;
				END;

			| Api.FocusIn: FocusGot();
			| Api.FocusOut: FocusLost();

			| Api.ClientMessage:
				cm := SYSTEM.VAL( Api.XClientMessageEvent, event );
				IF  cm.data[0]  = wmDelete THEN
					(* shutdown *)
					Close;
				END;
			ELSE
			END;
			events := Api.Pending( display );
	  	END;
	END LoopForEvents;

(*
	(* if gamemode is enabled, call this proc in MainLoop. *)
	PROCEDURE GameModeLoop();
	BEGIN
		IF idletime # 0 THEN
			IF Kernel.Expired(idletimer) THEN
				IdleDisplay;
				Kernel.SetTimer(idletimer, idletime);
			END;
		ELSE
			Display;
		END;

		(* measure timing info *)
		IF debugframes THEN
			INC(frames);
			IF Kernel.Expired(fpstimer) THEN
				KernelLog.Int(frames,0); KernelLog.String(" frames in 5 secs.");
				KernelLog.String(" FPS = "); KernelLog.Int(frames DIV 5, 0);
				KernelLog.Ln;
				Kernel.SetTimer(fpstimer, 5000);
				frames := 0;
			END;
		END;

	END GameModeLoop;


	(** windows main loop *)
	PROCEDURE MainLoop*();
	BEGIN
		frames := 0;
		Kernel.SetTimer(fpstimer, 5000);

		MakeCurrent();
	(*	GL.ReadOpenGLCore;*)
 		OnLoad;
		Reshape(width, height);
		active := TRUE;

		WHILE  active  DO
			(* process X11 events *)
			LoopForEvents;

			(* ------------ game mode starts ------------- *)
			IF gamemode THEN
				GameModeLoop();
			END;
			(* ------------ game mode ends ------------- *)
		END;

		CloseWindow();
	END MainLoop;
*)


PROCEDURE GetCurrentFrameMs*():LONGINT;
BEGIN
	RETURN currentfms;
END GetCurrentFrameMs;

(*  called in gamemode , use according to your needs *)
PROCEDURE GameLogic*();
BEGIN
END GameLogic;

	(** windows main loop *)
	PROCEDURE MainLoop*();
		VAR fms,fmsum: LONGINT;
		ft: ARRAY 10 OF LONGINT;
		i,ii: LONGINT;
	BEGIN
		MakeCurrent();
		OnLoad;
		Reshape(width, height);
		Display();
		active := TRUE;
		WHILE  active  DO
			i:=(i+1)MOD 10;
			Kernel.SetTimer(fpstimer, 1000);

			(* process X11 events *)
			LoopForEvents;

			(* ------------ game mode starts ------------- *)
			IF gamemode THEN
				IF  idletime # 0 THEN
					IF Kernel.Expired(idletimer) THEN
						IdleDisplay;
						Kernel.SetTimer(idletimer, idletime);
					END;
				ELSE
					Display;
				END;
			END;

			Objects.Yield();

			(* measure frame timing info, ms *)
			IF gamemode & debugframes & (idletime = 0) THEN
				ft[i]:=Kernel.Elapsed(fpstimer);
				currentfms := ft[i];

				fmsum:=0;
				FOR ii:=0 TO 9 DO
					fmsum:=fmsum+ft[ii]
				END;
				fms:=fmsum DIV 10;

				GameLogic();

				IF i=9 THEN
					fmsum:=0;
					KernelLog.Int(fms, 6); KernelLog.String(" ms."); KernelLog.Ln
				END;
			END;
		END;
		CloseWindow();

	END MainLoop;

BEGIN  {ACTIVE, PRIORITY (Objects.Normal) }
	MainLoop;
END Window;

PROCEDURE InitKeysym;
VAR i: LONGINT;
BEGIN
	FOR i := 0 TO 255 DO keySymbol[i] := i END;
	keySymbol[07FH] := Inputs.KsBackSpace;
	keySymbol[009H] := Inputs.KsTab;
	keySymbol[00AH] := Inputs.KsReturn;
	keySymbol[00DH] := Inputs.KsReturn;

	keySymbol[0C1H] := Inputs.KsUp;
	keySymbol[0C2H] := Inputs.KsDown;
	keySymbol[0C3H] := Inputs.KsRight;
	keySymbol[0C4H] := Inputs.KsLeft;

	keySymbol[0A0H] := Inputs.KsInsert;
	keySymbol[0A1H] := Inputs.KsDelete;
	keySymbol[0A2H] := Inputs.KsPageUp;
	keySymbol[0A3H] := Inputs.KsPageDown;
	keySymbol[0A8H] := Inputs.KsHome;
	keySymbol[0A9H] := Inputs.KsEnd;

	keySymbol[01BH] := Inputs.KsEscape;

	FOR i := 0F1H TO 0FCH DO keySymbol[i] := 0FFBEH + (i - 0F1H) END
END InitKeysym;

PROCEDURE Wr(CONST str: ARRAY OF CHAR);
BEGIN
	IF debugevents THEN KernelLog.String(str); KernelLog.Ln END;
END Wr;

BEGIN
	InitKeysym;
END OGLWindow.

System.Free OGLWindow ~

System.FreeDownTo OpenGL ~
