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
		functions: LONGINT;
		decorations: LONGINT;
		inputMode: LONGINT;
		status: LONGINT;
	END;

	GLXFBConfigPtr =  POINTER TO ARRAY OF LONGINT;
	
VAR
	keySymbol: ARRAY 256 OF LONGINT;
	xbuttons: SET;
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
	 desktopMode :  V.XF86VidModeModeInfo;

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
	dispWidth, dispHeight: LONGINT;

	gamemode-: BOOLEAN; (** if true poll Display procedure *)
	hidecursor-: BOOLEAN; (** hide/show cursor *)
	currentfms-: LONGINT; (* current frame update time *)
	noCursor: X11.Cursor;
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
	VAR resb: GL.Boolean;
	BEGIN
		resb := GL.glXMakeCurrent(display, win, glctx);
		IF debug THEN KernelLog.String(" MakeCurrent:"); KernelLog.Boolean(resb=1); KernelLog.Ln; END;
	END MakeCurrent;

	(** deactivate the current GL context *)
	PROCEDURE DeActivate*();
	VAR resb: GL.Boolean;
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
	PROCEDURE GetDisplay*(): LONGINT;
	BEGIN
		RETURN display;
	END GetDisplay;

	(* get current gl context of this window *)
	PROCEDURE GetContext*(): LONGINT;
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
	  VAR resb: GL.Boolean;
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
			res := V.XF86VidModeSwitchToMode(display, screen, desktopMode);
			X11.Flush(display);
			res := V.XF86VidModeSetViewPort(display, screen, 0, 0);
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
	VAR bres: BOOLEAN;
	BEGIN
	(*
		IF GL.glXSwapIntervalSGI # NIL THEN
			 bres := GL.glxSwapIntervalSGI(interval);
		END;
	*)
	END SetSwapInterval;


	 (** set  window decorartion on/off *)
	PROCEDURE SetDecorations*(decor: BOOLEAN);
	VAR 	hints: Hints;
		property: X11.Atom;
	BEGIN
	(*	IF (decor = decorations) OR fullwindow THEN RETURN END; (* no need to set again *)*)
(*		decorations := decor;*)
		IF  ~(fullscreen OR fullwindow) THEN
			decorations := decor;
			hints.flags := {1};
	 		IF ~decor THEN hints.decorations := 0; ELSE hints.decorations := 1; END;
			property := Api.InternAtom(display, "_MOTIF_WM_HINTS", Api.True);
			X11.ChangeProperty(display, win, property, property, 32, Api.PropModeReplace, ADDRESSOF(hints), 5);
		END;
	END SetDecorations;

	(** Set  window state to full window *)
	PROCEDURE SetFullWindow*(fullw: BOOLEAN);
	VAR
		cm: Api.XClientMessageEvent;
		xev: Api.XEvent;
		dl: Api.Data40l;
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
		cm.data:=SYSTEM.VAL(Api.Data40, dl);  xev := SYSTEM.VAL(Api.XEvent, cm);
		defwin := X11.DefaultRootWindow(display);
		res := Api.SendEvent(display, defwin, Api.False, Api.SubstructureNotifyMask, ADDRESSOF(xev));
	END SetFullWindow;

	(** create a new opengl context with opengl version major, minor *)
	PROCEDURE SetProfile*(major, minor: LONGINT; flags: SET): BOOLEAN;
	VAR
		elemc, res, i: LONGINT;
		fbcfg: GL.XID; (*GLXFBConfigPtr;*)
		fbcfgPtr: GLXFBConfigPtr;
(*		str: Strings.String;*)
		attr: POINTER TO  ARRAY OF GL.Int;
		newctxt: GL.GLXContext;
	BEGIN

		res := GL.glXMakeCurrent(display, 0, 0);
		
		(* We need this for OpenGL3 *)
		fbcfg := GL.glXChooseFBConfig(display, 0, 0, elemc);
		IF fbcfg = 0 THEN
			KernelLog.String("Couldn't get FB configs"); KernelLog.Ln;
		ELSE
			KernelLog.String("# of Got FB configs: "); 
			KernelLog.Int(elemc, 0); KernelLog.Ln;
		END;
  
		NEW(fbcfgPtr, elemc);  	
		fbcfgPtr := SYSTEM.VAL(GLXFBConfigPtr, fbcfg);

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

		newctxt := GL.glXCreateContextAttribsARB(display, SYSTEM.VAL(LONGINT, fbcfgPtr[0]), 0, X11.True, ADDRESSOF(attr[0]));
		IF newctxt = NIL THEN 
			KernelLog.String("could not create OpenGL "); KernelLog.Int(major, 0); KernelLog.Char("."); KernelLog.Int(minor, 0); 
			KernelLog.String(" context"); KernelLog.Ln; 
			RETURN FALSE;
		END;

		IF glctx # NIL THEN
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
		X11.Free(fbcfg);	
  		RETURN TRUE;
	END SetProfile;
	
	(* create an X11 window, and GL context *)
	PROCEDURE  InitWindow*(): BOOLEAN;
	VAR
		masks, res: LONGINT;
		resb: GL.Boolean;
		attrib : POINTER TO ARRAY OF GL.Int;  (* attributes of GL window *)
		swa : Api.XSetWindowAttributes; (* set window attributes*)
		visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)

		sizehints: Api.XSizeHints;

		modes : V.PPXF86VidModeModeInfo;
		bmodes : V.XF86VidModeModeInfo;
		modnum, bestmode: LONGINT;
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
		res := V.XF86VidModeQueryVersion(display, wmMajor, wmMinor);
		IF debug THEN
			KernelLog.String("XF86 VideoMode extension version ");
			KernelLog.Int(wmMajor,0); KernelLog.Char(".");
			KernelLog.Int(wmMinor,0); KernelLog.Ln;
		END;

		res := V.VidModeGetAllModeLines(display, screen, modes);
		modnum := LEN(modes,0);

		(* save desktop-resolution before switching modes *)
		desktopMode := modes[0]^;
		bmodes := modes[0]^;

		IF debug THEN
			FOR i:=0 TO modnum-1 DO
 				bmodes := modes[i]^;
 				KernelLog.Int(i, 0); KernelLog.Char(":"); KernelLog.Int( bmodes.hdisplay, 6);
 				KernelLog.Int(bmodes.vdisplay, 6);
				KernelLog.Ln;
			END;
		END;

		(* look for mode with the requested resolution and choose the best matched one *)
	    i := 0;
	    bestmode := 0;
	    isbestFound := FALSE;

		WHILE (i < modnum-1) & (~isbestFound) DO
 			bmodes := modes[i]^;
 			IF (bmodes.hdisplay = width) & (bmodes.vdisplay = height) THEN
 				bestmode := i;
 				isbestFound := TRUE;
 			END;
 			INC(i);
		 END;

		(* if cant find the required mode choose desktop mode *)
		IF ~isbestFound THEN
			bmodes := desktopMode;
			fullscreen := FALSE;
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
			KernelLog.String("visinfoptr.visual ");  KernelLog.Int(visinfoptr.visualID, 0); KernelLog.Ln;
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

			dispWidth := bmodes.hdisplay;
			dispHeight := bmodes.vdisplay;

			left := 0; top := 0;
			width := dispWidth; 	height := dispHeight;

			(* Use the XF86VidMode extension to control video resolution *)
			(* Change the current video mode, switch to fullscreen *)
			(* Unlock mode switch if necessary *)
			res := V.XF86VidModeLockModeSwitch(display, screen, 0);

			(* Change the video mode to the desired mode *)
			res := V.XF86VidModeSwitchToMode(display, screen, bmodes);
			X11.Flush(display);
			(* Set viewport to upper left corner (where our window will be) *)
	       	res:= V.XF86VidModeSetViewPort(display, screen, 0, 0);

	       	(* Lock mode switch *)
			res := V.XF86VidModeLockModeSwitch(display, screen, 1);

			swa.overrideRedirect := TRUE;
			 (* window event masks *)
			swa.eventMask := Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask+ Api.ButtonReleaseMask + Api.PointerMotionMask +
	 		Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask ;

			masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask + Api.CWOverrideRedirect;
			
			win := Api.CreateWindow(display,  rootwin, 0, 0, dispWidth, dispHeight,
				        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);

			(* Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, 0, 0);*)
			Api.WarpPointer(display, Api.None, win, 0, 0, 0, 0, dispWidth DIV 2, dispHeight DIV 2);
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

	(* process pending X11 events for this window *)
	PROCEDURE LoopForEvents*();
	CONST bufsize=20;
	VAR
		event: Api.XEvent;
		kp : Api.XKeyEvent; 	be : Api.XButtonPressedEvent; em: Api.XExposeEvent;
		cm : Api.XClientMessageEvent; cn : Api.XConfigureEvent; me: Api.XMotionEvent;
		datal: Api.Data40l;
	       keycount, xr, yr, x, y, i: LONGINT;
		keysym: X11.KeySym;
		newxbuttons, bdiff: SET;
		rw, cw: X11.Window;
		ch: CHAR;
		flags: SET;
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
					KeyEvent( ORD(0X), flags, keysym )
				ELSE
					xbuttons := newxbuttons;
					WHILE i < keycount DO
						ch := buffer[i];  flags := KeyState( );
						keysym := keySymbol[ORD( ch )];
						IF ch = 0F1X THEN  ch := 0A4X
						ELSIF ch = 0F2X THEN ch := 0A5X
						END;
						KeyEvent( ORD(ch), flags, keysym);
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
					KeyEvent(ORD(ch), flags, keysym);
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
				datal := SYSTEM.VAL( Api.Data40l, cm.data );
				IF  SYSTEM.VAL( X11.Atom,datal[0] ) = wmDelete THEN
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

BEGIN (*  {ACTIVE}
	MainLoop;
	*)
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

SystemTools.Free OGLWindow ~

SystemTools.FreeDownTo OpenGL ~
