MODULE OGLWindow; (** AUTHOR "fnecati"; PURPOSE "OpenGL enabled OO X11Window wrapper"; *)

IMPORT
	 SYSTEM, X11, Api := X11Api, Modules, GL:=OpenGL, GLC := OpenGLConst,
	 Kernel, Inputs , KernelLog;

(* Note: in OpenGL, window origin is lower left, check! *)
	(** todo:
		setting position of window (left, top) needs  a clever solution
	*)
CONST
	debug = FALSE; (* for window creation/closing *)
	debugevents = FALSE; (* for testing events *)

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

VAR
	keySymbol: ARRAY 256 OF LONGINT;
	xbuttons: SET;
	compstatus: Api.ComposeStatus;


(** OpenGL enabled Window Object *)
TYPE Window* = OBJECT
VAR
	fpstimer, idletimer : Kernel.MilliTimer;

	(* window variables *)
	display: X11.DisplayPtr;
	win : X11.Window ; (* window handle *)
	glctx : GL.GLXContext;  (* GL context handle *)

	title-: ARRAY 128 OF CHAR; (** title of window *)
	active : BOOLEAN; (* for main loop control *)

	left-, top-: LONGINT; (** top left origin of window *)
	width-, height- : LONGINT; (** size of window *)

	debugframes-: BOOLEAN; (** print FPS ? *)
	frames-:LONGINT;  (** # of frames *)

	idletime-: LONGINT; (** ms, for IdleDisplay *)
	cmdlinerun*: BOOLEAN; (** is this window opened from command line? *)

	fullscreen-, fullwindow-, decorations-: BOOLEAN;
	gamemode-: BOOLEAN; (** if true poll Display procedure *)
	hidecursor-: BOOLEAN; (** hide/show cursor *)
	wmDelete : X11.Atom;
	wmstate, wmfullscreen: X11.Atom;

	(** constructor, initlialize window object, fs: fullscale: true/false *)
	PROCEDURE & Init*(w, h, l, t: LONGINT; fs: BOOLEAN);
	BEGIN
		width := w; height := h;
		left := l;  top := t ;
		title:="OGLWindow";
		idletime := 0;
		fullscreen := FALSE;
		decorations := TRUE;
		fullwindow := fs;
		hidecursor := FALSE;
		cmdlinerun := FALSE;
		InitWindow(width, height, left, top);

	END Init;

	(** Close the window *)
	PROCEDURE Close*;
	BEGIN {EXCLUSIVE}
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
		res := Api.SendEvent(display, win, Api.False, Api.ExposureMask, ADDRESSOF(xev));
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
	VAR res: LONGINT;
	BEGIN
		res := GL.glXMakeCurrent(display, win, glctx);
		IF debug THEN KernelLog.String(" MakeCurrent:"); KernelLog.Boolean(res=1); KernelLog.Ln; END;
	END MakeCurrent;

	(** deactivate the current GL context *)
	PROCEDURE DeActivate*();
	VAR res: LONGINT;
	 BEGIN
		res := GL.glXMakeCurrent(display, 0, 0);
		IF debug THEN KernelLog.String(" DeActivate:"); KernelLog.Boolean(res=1); KernelLog.Ln; END;
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
	 PROCEDURE CloseWindow;
	  VAR res: LONGINT;
	 BEGIN

		(* do we have a rendering context *)
		IF glctx # 0 THEN
			(* Release the context *)
		    	res := GL.glXMakeCurrent(display, 0, 0);
		    	(* Delete the context *)
			GL.glXDestroyContext(display, glctx);
			glctx := 0;
			IF debug THEN KernelLog.String("context deleted"); KernelLog.Ln; END;
		END;

		(* do we have a window *)
		IF win # 0 THEN
			(* Unmap the window*)
			Api.UnmapWindow(display, win);
			(* Destroy the window *)
			res:= Api.DestroyWindow(display, win);
			win := 0;
			IF debug THEN KernelLog.String("window deleted"); KernelLog.Ln; END;
		END;

		(* do we have a display *)
		IF display # 0 THEN
			res := Api.CloseDisplay(display);
			display := 0;
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
		IF hide = hidecursor THEN RETURN END;
		hidecursor := hide;
		IF hidecursor THEN
			fg.red := 0;  fg.green := 0;  fg.blue :=0;
			FOR i:=0 TO 7 DO data[i] := 0X  END;
			pixmap := X11.CreateBitmapFromData( display, win, ADDRESSOF( data[0] ), 8, 8 );
			noCursor := X11.CreatePixmapCursor( display, pixmap, pixmap, ADDRESSOF( fg ), ADDRESSOF( fg ), 0, 0 );
			X11.DefineCursor( display, win, noCursor );
			Api.FreeCursor(display, noCursor);
			X11.FreePixmap(display, pixmap);
		END;
	END HideMousePointer;

	(** Set mouse position to x,y *)
	PROCEDURE SetMousePosition*(x, y: LONGINT);
	BEGIN
		Api.WarpPointer(display, win, win,  0, 0, width, height, x, height-y-1);
	END SetMousePosition;

	(** set title of the window *)
	PROCEDURE SetTitle*(tit: ARRAY OF CHAR);
	VAR res: LONGINT;
	BEGIN {EXCLUSIVE}
		COPY(tit, title);
		 res := Api.StoreName(display, win, title);
	END SetTitle;

	(** set idle time  for calling IdleDisplay proc *)
	PROCEDURE SetIdleTime*(ms: LONGINT);
	BEGIN {EXCLUSIVE}
		IF ms < 1 THEN ms := 1 END;
		idletime := ms;
	END SetIdleTime;

	(** print # frames per second, true/false *)
	PROCEDURE SetPrintFPS*(df: BOOLEAN);
	BEGIN {EXCLUSIVE}
		debugframes := df;
	END SetPrintFPS;

	(** gm: TRUE-> Display procedure polled continuously *)
	PROCEDURE SetGameMode*(gm: BOOLEAN);
	BEGIN {EXCLUSIVE}
		gamemode := gm;
	END SetGameMode;

	(** interval=1: vertical sync to video update rate; interval=0: disable vsynch, full speed *)
	PROCEDURE SetSwapInterval*(interval: LONGINT);
	VAR bres: BOOLEAN;
	BEGIN {EXCLUSIVE}
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
	BEGIN
		IF (fullw = fullwindow) THEN RETURN END; (* no need to set again*)
		fullwindow := fullw;

		cm.typ := Api.ClientMessage; cm.window := win;  cm.messageType := wmstate;
		cm.format := 32;
		IF fullwindow THEN dl[0] := 1; ELSE dl[0] := 0; END;
		dl[1] := wmfullscreen;  dl[2] := 0;
		cm.data:=SYSTEM.VAL(Api.Data40, dl);  xev := SYSTEM.VAL(Api.XEvent, cm);

		res := Api.SendEvent(display, X11.DefaultRootWindow(display), Api.False, Api.SubstructureNotifyMask, ADDRESSOF(xev));
	END SetFullWindow;

	(* create an X11 window, and GL context *)
	PROCEDURE  InitWindow(w, h, l, t: LONGINT);
	VAR
		masks, res: LONGINT;
		attrib : POINTER TO ARRAY OF GL.Int;  (* attributes of GL window *)
		swa : Api.XSetWindowAttributes; (* set window attributes*)
		visinfoptr : Api.VisualInfoPtr; (* pointer to X11 VisualInfo *)
		xev: Api.XEvent;
		sizehints: Api.XSizeHints;
	BEGIN

		display := X11.OpenDisplay(0);
		IF display =0 THEN
			KernelLog.String(" cannot connect to X server"); KernelLog.Ln;
			Close;
		     RETURN;
		END;

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
			IF debug THEN KernelLog.String(" NO appropriate visual found"); KernelLog.Ln; END;
			Close;
			RETURN;
		END;

		IF debug THEN
			KernelLog.String("visinfoptr.depth= "); KernelLog.Int(visinfoptr.depth,0); KernelLog.Ln;
			KernelLog.String("visinfoptr.visual ");  KernelLog.Int(visinfoptr.visualID, 0); KernelLog.Ln;
		END;

 		(* window attributes *)
 		swa.backgroundPixel := 0;
 		swa.borderPixel := 0;
 		swa.colormap := X11.CreateColormap(display, X11.DefaultRootWindow(display), visinfoptr.visual, X11.AllocNone);
 		(* window event masks *)
		swa.eventMask := Api.KeyPressMask + Api.KeyReleaseMask + Api.ButtonPressMask+ Api.ButtonReleaseMask + Api.PointerMotionMask +
 		Api.ButtonMotionMask + Api.ExposureMask + Api.StructureNotifyMask + Api.FocusChangeMask ;

 		masks := Api.CWBorderPixel + Api.CWColormap + Api.CWEventMask ;

 		win := Api.CreateWindow(display, X11.DefaultRootWindow(display), l, t, w, h,
		        0, visinfoptr.depth, Api.InputOutput,  visinfoptr.visual, masks, swa);

		(* set wm_delete_events if in windowed mode *)
		wmDelete := Api.InternAtom(display, "WM_DELETE_WINDOW", Api.True);
		res := Api.SetWMProtocols(display, win, ADDRESSOF(wmDelete), 1);

		sizehints.flags := Api.PPosition + Api.PSize;
		sizehints.x := l; sizehints.y := t;
		sizehints.width := w; sizehints.height := h;
		Api.SetNormalHints(display, win, sizehints);

 		Api.MapWindow(display, win);

 		res := Api.StoreName(display, win, title);

		(* Wait for map notification *)
	 	REPEAT
			Api.NextEvent( display, xev );
	 		IF debug THEN KernelLog.String("Event type="); KernelLog.Int(xev.typ,4); KernelLog.Ln; END;
		UNTIL (xev.typ = Api.MapNotify) & (xev.window = win);

 		glctx := GL.glXCreateContext(display, visinfoptr, 0, GLC.GL_TRUE);
		IF glctx = 0 THEN
			IF debug THEN KernelLog.String("glXCreateContext glctx= "); KernelLog.Int(glctx, 0); KernelLog.Ln; END;
			Close;
			RETURN;
		END;

		wmstate := Api.InternAtom(display, "_NET_WM_STATE", Api.False);
		wmfullscreen := Api.InternAtom(display, "_NET_WM_STATE_FULLSCREEN", Api.False);

		IF fullwindow THEN
			SetFullWindow(TRUE);
		END;
	(*	 MakeCurrent();

	GL.ReadOpenGLCore;
		DeActivate; *)
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
	PROCEDURE LoopForEvents;
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
	BEGIN
		WHILE Api.Pending(display) > 0 DO
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

			| Api.MotionNotify:
				me := SYSTEM.VAL(Api.XMotionEvent, event);
				PointerMove( me.x, height-me.y-1,  xbuttons )

			| Api.Expose, Api.GraphicsExpose:
				em := SYSTEM.VAL( Api.XExposeEvent, event );
				IF em.count = 0 THEN (* wait until last message*)
					Wr("Expose");
					Display;
				END;

			| Api.ConfigureNotify: Wr("ConfigureNotify");
				cn := SYSTEM.VAL(Api.XConfigureEvent, event);
				(* call Reshape only if our window-size changed *)
			(*	IF (cn.width # width) OR  (cn.height # height) THEN*)
					(* left := cn.x; top := cn.y; *)
					width := cn.width;
					height := cn.height;
					Reshape(width, height);
					IF debugevents THEN
						KernelLog.String("x,y, w, h: ");
						KernelLog.Int(left,0); KernelLog.Int(top,5); KernelLog.Int(width, 5); KernelLog.Int(height,5);
						KernelLog.Ln;
					END;
				(* END;*)

			| Api.ClientMessage:
				cm := SYSTEM.VAL( Api.XClientMessageEvent, event );
				datal := SYSTEM.VAL( Api.Data40l, cm.data );
				IF  SYSTEM.VAL( X11.Atom,datal[0] ) = wmDelete THEN
					(* shutdown *)
					active := FALSE;
				END;
			ELSE
			END;
	  	END;
	END LoopForEvents;

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

BEGIN (* {ACTIVE}
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
