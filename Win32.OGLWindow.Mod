MODULE OGLWindow;  (** AUTHOR "fnecati"; PURPOSE "OpenGL enabled OO Win32 Window wrapper"; *)

(* stripped from Win32.Display.Mod *)
(*! todo:
  _- check and cleanup Message handles, key handling and others
  - set fullwindow, decorations on/off  window:
  - add window icons
  - etc.

 *)

IMPORT SYSTEM, Kernel32, User32, Kernel, Modules, KernelLog,
	Inputs, Objects, GL:=OpenGL, Strings, WinApi, GLC := OpenGLConst;

CONST
	debug = FALSE;

CONST
	WMSetup = User32.WMUser + 1;

	Insert = 0A0X;  Delete = 0A1X;  Backspace = 07FX;  Home = 0A8X;  End = 0A9X;  PageUp = 0A2X;  PageDown = 0A3X;
	Up = 0C1X;  Down = 0C2X;  Right = 0C3X;  Left = 0C4X;   (* cursor mkeys *) Enter = 0DX;  F1 = 0A4X;  F2 = 0A5X;
	F3 = 0A6X;  F4 = 0A7X;  F5 = 0F5X;  F6 = 0F6X;  F7 = 0F7X;  F8 = 0F8X;  F9 = 0F9X;  F10 = 0FAX;  F11 = 0FBX;  F12 = 0FCX;
	update = 0;   minimized = 2;   maximized = 5;

	(** mouse buttons *)

	ML* = 0;  MM* = 1;  MR* = 2;
	MX = 3;   SHIFT = 0;  CTRL = 1;ALT = 2;   (** constants for KeyState *)

	create = 0;  remove = 1;   (** display has been created or destroyed *)
	restore = 2;  suspend = 3;   (** display has been minimized or restored *)
	redraw = 4;  resize = 5;   (** display needs redraw *)
	print = 6;   (** print the display in the give context *)
	focus = 7;  defocus = 8;   (** display got or lost the keyboard focus *)
	consume = 9;  track = 10;   (** keyboard or mouse data available *)
	dupdate = 11;   (** notification, that an object has been updated *)
	execute = 12;   (** request to execute a command *)
	quit = 13;   (** notification, that the Event service is shutdown *)
	ping = 14;   (** checks whether the event dispatcher (Oberon.Loop) is running *)
	wheel = 15;   (** mouse wheel *)
	get = 0;  set = 1;

	pressed = 15;

CONST
	kPageUp = User32.VKPrior;  kPageDown = User32.VKNext;  kEnd = User32.VKEnd;  kHome = User32.VKHome;
	kLeft = User32.VKLeft;  kRight = User32.VKRight;  kUp = User32.VKUp;  kDown = User32.VKDown;
	kInsert = User32.VKInsert;  kDelete = User32.VKDelete;  kF1 = User32.VKF1;  kF2 = User32.VKF2;  kF3 = User32.VKF3;
	kF4 = User32.VKF4;  kF5 = User32.VKF5;  kF6 = User32.VKF6;  kF7 = User32.VKF7;  kF8 = User32.VKF8;  kF9 = User32.VKF9;
	kF10 = User32.VKF10;  kF11 = User32.VKF11;  kF12 = User32.VKF12;  kCtrl = 17;  kAlt = 18;  kWindows = 91;  kShift = 16;
	kMenu = 93;  kNumlock = 144;  kEnter = 13;  kPAdd = 107;  kPMinus = 109;  kPDiv = 111;  kPMult = 106;  kPause = 19;
	kCapsLock = 20;  kEscape = 27;  kTab = 9;
	VK0 = 030H; VK9 = 39H;


	VKLShift = 160;  VKRShift = 161;   VKLCtrl = 162; VKRCtrl = 163; VKLMenu = 164; VKRMenu = 165;
	VKLWin = 05BH; VKRWin = 05CH;

CONST
		(* context creation options *)
		opDoubleBuffered = 0;
		opGDI = 1;
		opStereo = 2;


TYPE
	CreateStruct = POINTER TO RECORD
		win: Window;
		dwExStyle: WORDSET;
		dwStyle: WORDSET;
		x, y, w, h: LONGINT;
	END;

TYPE
(** OpenGL enabled Window Object *)
	Window* = OBJECT
	VAR
		fpstimer, idletimer: Kernel.MilliTimer;
		hWnd: User32.HWND;   (* handle of this window *)
		hDC: User32.HDC;
		hGLRC: WinApi.HGLRC; (* GL render context handles for this window *)

		left-, top-: LONGINT;
		width-, height-: LONGINT;   (** current size *)

		(** title *)
		title-, className: ARRAY 128 OF CHAR;

		defWindowProc: User32.WndProc;   (* default window procedure for all messages not handled here *)
		state: SET (* update, dummy, minimized, external, control *) ;

		debugframes-: BOOLEAN; (** print FPS ? *)
		frames-:LONGINT;  (** # of frames *)
		hidecursor-: BOOLEAN; (** hide/show cursor *)
		currentfms-: LONGINT; (* current frame update time *)

		idletime-: LONGINT; (** ms, for IdleDisplay *)
		cmdlinerun* : BOOLEAN; (* run from commandline, exe ? *)

		active : BOOLEAN;  (* for main loop control *)
		fullscreen-, fullwindow-,  decorations-: BOOLEAN;
		gamemode-: BOOLEAN; (** if true poll Display procedure *)

		create: CreateStruct;
		mkeys: SET; (* current mouse keys *)
		screenSettings: WinApi.DEVMODE;

	(** constructor, initlialize window object, fs: fullscreen: true/false *)
	PROCEDURE &Init*( w, h, left, top: LONGINT; fs: BOOLEAN );
	VAR
		str: ARRAY 8 OF CHAR;
	BEGIN
		decorations := TRUE;
		fullscreen := fs;
		fullwindow := FALSE;

		SELF.left := left; SELF.top := top;
		(* Initialize the fields of a new Window instance with default values.*)
		defWindowProc := User32.DefWindowProc;  state := {update};

		idletime := 0;

		NEW( create );  create.win := SELF;
		title := "OGLWindow";

		(* each window has different class name *)
		Strings.IntToStr(classCount, str);
		className := "OGLWindow";
		Strings.Append(className, str);
		INC(classCount);

		create.x := left; create.y := top;
		create.w := w;
		create.h := h;

		width := w;
		height := h;
	END Init;

	PROCEDURE GetWidth*(): LONGINT;
	BEGIN
		RETURN width;
	END GetWidth;

	PROCEDURE GetHeight*(): LONGINT;
	BEGIN
		RETURN height;
	END GetHeight;

	(** sets title of window *)
	PROCEDURE SetTitle*(tit: ARRAY OF CHAR);
	VAR res: LONGINT;
	BEGIN
		COPY(tit, title);
		res:=User32.SetWindowText(SELF.hWnd, title);
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

	(** make GL context current *)
	PROCEDURE MakeCurrent*();
	VAR res: BOOLEAN;
	BEGIN
		res := GL.wglMakeCurrent(hDC, hGLRC);
		IF debug THEN KernelLog.String("MakeCurrent res= "); KernelLog.Boolean(res); KernelLog.Ln; END;
	END MakeCurrent;

	(** deactivate the current GL context *)
	PROCEDURE DeActivate*();
		VAR res: BOOLEAN;
	BEGIN
		res := GL.wglMakeCurrent(0, 0);
	END DeActivate;

	(** swap the GL context contents to the window *)
	PROCEDURE SwapBuffers*();
	VAR res: WinApi.BOOL;
	BEGIN
		res := WinApi.SwapBuffers(hDC);
		IF debug THEN KernelLog.String("SwapBuffers res= "); KernelLog.Int(res,0); KernelLog.Ln; END;
	END SwapBuffers;

	(** interval=1: vertical sync to video update rate; interval=0: disable vsynch, full speed *)
	PROCEDURE SetSwapInterval*(interval: LONGINT);
	VAR bres: BOOLEAN;
	BEGIN
		IF GL.wglSwapIntervalEXT # NIL THEN
			 bres := GL.wglSwapIntervalEXT(interval);
		END;
		IF debug THEN
			IF GL.wglSwapIntervalEXT #NIL THEN
				KernelLog.String("wglSwapIntervalEXT # NIL ");
			ELSE
				KernelLog.String("wglSwapIntervalEXT = NIL ");
			END;
			IF bres THEN KernelLog.String("bres=TRUE"); ELSE KernelLog.String("bres= FALSE"); END;
			KernelLog.Ln;
		END;
	END SetSwapInterval;

	(** create a new opengl context with opengl version major, minor *)
	PROCEDURE SetProfile*(major, minor: LONGINT; flags: SET): BOOLEAN;
	VAR
		attr: POINTER TO ARRAY OF LONGINT;
		tempContext: WinApi.HGLRC;
		i: LONGINT;
	BEGIN
		(* create opengl compatibilitity mode context *)
		NEW(attr, 13);
		i := 0;
		attr[i] := GLC.WGL_CONTEXT_MAJOR_VERSION_ARB;	INC(i);
		attr[i] := major; INC(i);
		attr[i] := GLC.WGL_CONTEXT_MINOR_VERSION_ARB; INC(i);
		attr[i] := minor; INC(i);

(*		attr[i] := GLC.WGL_CONTEXT_FLAGS_ARB; INC(i);
			attr[i] := GLC.WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB; INC(i);
*)
		attr[i] := GLC.WGL_CONTEXT_PROFILE_MASK_ARB; INC(i);
			(* attr[i] := GLC.WGL_CONTEXT_CORE_PROFILE_BIT_ARB; INC(i); *)
			attr[i] := GLC.WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB; INC(i);
		attr[i] := 0; (* end of attribute list *)

(*	attribs:= [
				GLC.WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
				GLC.WGL_CONTEXT_MINOR_VERSION_ARB, 1,
				(* GLC.WGL_CONTEXT_FLAGS_ARB, GLC.WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB, *)
				GLC.WGL_CONTEXT_PROFILE_MASK_ARB, (*GLC.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,*)
				GLC.WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB,
				0
			];
*)
		GL.Read_WGL_ARB_create_context(); (* read wglCreateContextAttribsARB function *)

		IF GL.wglCreateContextAttribsARB = NIL THEN RETURN FALSE END;

		tempContext := GL.wglCreateContextAttribsARB(hDC,0, ADDRESSOF(attr[0]));
		IF tempContext = NIL THEN
			IF debug THEN
				(* It's not possible to make a GL 3.x context. Use the old style context (GL 2.1 and before) *)
				KernelLog.String("Using old style context"); KernelLog.Ln;
			END;
			RETURN FALSE
		END;

		GL.wglMakeCurrent(0, 0);
		GL.wglDeleteContext(hGLRC);
		hGLRC := tempContext;
		GL.wglMakeCurrent(hDC,  hGLRC);
		GL.ReadExtensions();
		IF debug THEN
			KernelLog.String("Using new style context"); KernelLog.Ln;
		END;

  		RETURN TRUE;
	END SetProfile;

	(* create GLRC context *)
	PROCEDURE CreateGLRC(Options: SET; colorbits, depthbits, stencilbits, accumbits, auxbuffers: LONGINT; layer: LONGINT): BOOLEAN;
	VAR
		pfd: WinApi.PIXELFORMATDESCRIPTOR;
		pixelformat : LONGINT;
		res: LONGINT;
		tmpflag: WORDSET;
	BEGIN
		pfd.nSize := SIZEOF(WinApi.PIXELFORMATDESCRIPTOR);
		pfd.nVersion := 1;
		 tmpflag := WinApi.PFD_SUPPORT_OPENGL + WinApi.PFD_DRAW_TO_WINDOW + WinApi.PFD_DOUBLEBUFFER;

		IF opStereo IN Options THEN  tmpflag :=  tmpflag + WinApi.PFD_STEREO; END;

		pfd.dwFlags := tmpflag;
		pfd.iPixelType := CHR(WinApi.PFD_TYPE_RGBA);
		pfd.cColorBits := CHR(colorbits);
		pfd.cDepthBits := CHR(depthbits);
		pfd.cStencilBits := CHR(stencilbits);
		pfd.cAccumBits := CHR(accumbits);
		pfd.cAuxBuffers := CHR(auxbuffers);

		IF layer = 0 THEN pfd.iLayerType := CHR(WinApi.PFD_MAIN_PLANE);
		ELSIF layer > 0 THEN pfd.iLayerType := CHR(WinApi.PFD_OVERLAY_PLANE);
		ELSE pfd.iLayerType := CHR(WinApi.PFD_UNDERLAY_PLANE);
		END;

		hDC := User32.GetDC( hWnd );
		pixelformat := WinApi.ChoosePixelFormat(hDC, ADDRESSOF(pfd));
		IF pixelformat = 0 THEN
			IF debug THEN
				KernelLog.String("pixelformat= "); KernelLog.Int(pixelformat, 0); KernelLog.Ln;
				KernelLog.String(" ERROR: Choosepixelformat Kernel32.GetLastError()= "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;

		res := WinApi.SetPixelFormat(hDC, pixelformat, ADDRESSOF(pfd));
		IF res =0 THEN
			IF debug THEN
				KernelLog.String("ERROR: SetpixelFormat: "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;

		hGLRC := GL.wglCreateContext(hDC);
		RETURN (hGLRC # 0)
	END CreateGLRC;

	(** get current display of this window *)
	PROCEDURE GetDisplay*(): LONGINT;
	BEGIN
		RETURN LONGINT(hDC);
	END GetDisplay;

	(** get current gl context of this window *)
	PROCEDURE GetContext*(): LONGINT;
	BEGIN
		RETURN LONGINT(hGLRC);
	END GetContext;

	(** Abstract Window Procedures *)
	(** called when window get focus *)
	PROCEDURE FocusGot*();
	END FocusGot;

	(** called when window lost fucus  *)
	PROCEDURE FocusLost*();
	END FocusLost;

	(** abstract: called when window opened and GL context created *)
	PROCEDURE OnLoad*();
	END OnLoad;

	(** Redisplay proc for GL,  sends update message to the Window to call Display proc. *)
	PROCEDURE ReDisplay*();
	BEGIN
		User32.SendMessage(hWnd, User32.WMPaint, 0, 0);
	END ReDisplay;

	(** abstract: when iddle time expired, redisplay GL content.
	Called when SetIdleTime (> 0) and SetGameMode(TRUE) *)
	PROCEDURE IdleDisplay*();
	END IdleDisplay;

	(** abstract: reshape GL window, called while resizing the window *)
	PROCEDURE Reshape*(w, h: LONGINT);
	END Reshape;

	(** abstract: Display procedure for GL window *)
	PROCEDURE Display*();
	END Display;

	(** Close the window *)
	PROCEDURE Close*();
	BEGIN (* {EXCLUSIVE} *)
		active := FALSE;
	END Close;

	(** resize the window *)
	PROCEDURE ResizeWindow*(w, h: LONGINT);
	BEGIN
		MoveResizeWindow(left, top, w, h);
	END ResizeWindow;

	 (** set  window decorartion on/off *)
	PROCEDURE SetDecorations*(decor: BOOLEAN);
	BEGIN
		KernelLog.String('SetDecorations is not implemented, yet' ); KernelLog.Ln;
	END SetDecorations;

	(** Set  window state to full window *)
	PROCEDURE SetFullWindow*(fullw: BOOLEAN);
	BEGIN
		KernelLog.String('SetFullWindow is not implemented, yet' ); KernelLog.Ln;
	END SetFullWindow;

	(** move the window to x,y and  resize width,height *)
	PROCEDURE MoveResizeWindow*(x, y, w, h: LONGINT);
	BEGIN
		User32.MoveWindow(hWnd, x, y, w, h, 1); (* repaint *)
	END MoveResizeWindow;

	(** Set mouse position to x,y *)
	PROCEDURE SetMousePosition*(x, y: LONGINT);
	VAR pt: User32.Point;
	BEGIN
		(* convert client coords. to screen coords. *)
		pt.x := x; pt.y := height-1 - y;
		WinApi.ClientToScreen(hWnd, pt);
		(* chage cursor position *)
		User32.SetCursorPos(pt.x, pt.y);
	END SetMousePosition;

	(** warp pointer to x,y *)
	PROCEDURE WarpPointer*(w, h: LONGINT; x, y: LONGINT);
	BEGIN
		SetMousePosition(x, y);
	END WarpPointer;

	(** make null cursor for mouse pointer *)
	PROCEDURE HideMousePointer*(hide: BOOLEAN);
	BEGIN
		hidecursor := hide;
		IF hide THEN
			(* hide cursor *)
			User32.SetCapture(hWnd); (*  capture mouse to user window *)
			User32.ShowCursor(0); (* FALSE *)

		ELSE
			(* show cursor *)
			User32.ReleaseCapture(); (*  un-capture mouse from user window *)
			User32.ShowCursor(1); (* TRUE *)
		END;
	END HideMousePointer;

	(** called when mouse wheel changed  *)
	PROCEDURE WheelMove*(dz: LONGINT);
	END WheelMove;

	(** called when a key pressed *)
	PROCEDURE KeyEvent*(ucs: LONGINT; flags: SET; mkeysym: LONGINT);
	END KeyEvent;

	(** called when mouse button pressed *)
	PROCEDURE PointerDown*(x, y: LONGINT; flags: SET);
	END PointerDown;

	(** called when mouse button up  *)
	PROCEDURE PointerUp*(x, y: LONGINT; flags: SET);
	END PointerUp;

	(** called when mouse pointer moved *)
	PROCEDURE PointerMove*(x, y: LONGINT; flags: SET);
	END PointerMove;

	PROCEDURE HandleFocus(uMsg: LONGINT;  wParam: User32.WParam );
	BEGIN
		IF (uMsg = User32.WMSetFocus) THEN
			Kernel32.Sleep( 0 );   (* ????????????????????? *)
			FocusGot();
		ELSIF uMsg = User32.WMKillFocus THEN
			FocusLost();
		END
	END HandleFocus;

	PROCEDURE HandleMouse(uMsg: LONGINT;  wParam: User32.WParam;  lParam: User32.LParam );
	VAR m: Inputs.AbsMouseMsg;
		ret: Kernel32.HANDLE;
		keys: SET;
	BEGIN
		User32.SetCursor(hCurrentCursor);
		m.x := LONGINT(lParam MOD ASH( 1, 16 ));
		m.y := LONGINT(height-1-ASH( lParam, -16 )); (* opengl coordinates origin is lower-left  *)
	(*	m.y := ASH( lParam, -16 ) -1;*)
		keys := mkeys;

		CASE uMsg OF
		User32.WMMouseMove: PointerMove(m.x, m.y, keys);
		| User32.WMLButtonDown:
						INCL(keys, ML );
						PointerDown(m.x, m.y, keys);
		| User32.WMLButtonUp:
						EXCL(keys, ML );
						PointerUp(m.x, m.y, keys);
		| User32.WMMButtonDown:
						INCL( keys, MM );
						PointerDown(m.x, m.y, keys);
		| User32.WMMButtonUp:
						EXCL( keys, MM );
						PointerUp(m.x, m.y, keys);
		| User32.WMRButtonDown:
						INCL( keys, MR );
						PointerDown(m.x, m.y, keys);
		| User32.WMRButtonUp:
						EXCL( keys, MR );
						PointerUp(m.x, m.y, keys);
		| User32.WMXButtonDown:
						INCL( keys, MX );
						PointerDown(m.x, m.y, keys);
		| User32.WMXButtonUp:
						EXCL( keys, MX );
						PointerUp(m.x, m.y, keys);
		| User32.WMMouseWheel:
				IF LONGINT(wParam) DIV 10000H  > 0  THEN m.dz := -1 ELSE m.dz := 1 END;
				WheelMove(m.dz);

		ELSE
		END;

		IF (keys # {}) THEN ret := User32.SetCapture( hWnd );
		ELSIF (keys = {}) THEN ret := User32.ReleaseCapture();
		END;
		mkeys := keys;

	END HandleMouse;

	(* Get the state of CTRL, ALT and SHIFT mkeys *)
	PROCEDURE GetKeyFlags(VAR flags : SET);
	BEGIN
		flags := {};
		IF GetKeyState( VKLShift, pressed ) THEN INCL( flags, Inputs.LeftShift );  END;
		IF GetKeyState( VKRShift, pressed ) THEN INCL( flags, Inputs.RightShift );  END;
		IF GetKeyState( VKLCtrl, pressed ) THEN INCL( flags, Inputs.LeftCtrl ); END;
		IF GetKeyState( VKRCtrl, pressed ) THEN INCL( flags, Inputs.RightCtrl ); END;
		IF GetKeyState( VKLMenu, pressed ) THEN INCL( flags, Inputs.LeftAlt ); END;
		IF GetKeyState( VKRMenu, pressed ) THEN INCL( flags, Inputs.RightAlt ); END;
		IF GetKeyState( VKLWin, pressed) THEN INCL(flags, Inputs.LeftMeta); END;
		IF GetKeyState( VKRWin, pressed) THEN INCL(flags, Inputs.RightMeta); END;
	END GetKeyFlags;

	(* default handler for WMChar messages *)
	PROCEDURE HandleChar(wParam: User32.WParam;  lParam: User32.LParam );
	VAR ch: CHAR;  msg: Inputs.KeyboardMsg;  key: LONGINT;
	BEGIN
		GetChar( LONGINT(wParam), LONGINT(lParam), ch, key );
		GetKeyFlags(msg.flags);
		msg.ch := ch;  msg.keysym := key;

		IF  (*ch # 0X*) TRUE THEN
			lParam := lParam MOD ASH( 1, 16 );
			WHILE lParam > 0 DO KeyEvent( ORD(msg.ch), msg.flags, msg.keysym );
				DEC( lParam )
			END
		END;
	END HandleChar;

	(* default handler for WMKeyDown or WMKeyUp messages *)
	PROCEDURE HandleKey(wParam: User32.WParam;  lParam: User32.LParam );
	VAR ch: CHAR;  msg: Inputs.KeyboardMsg;  key : LONGINT;
	BEGIN
		DecomposeKeyEvent( LONGINT(wParam), LONGINT(lParam), ch, key, FALSE );
		GetKeyFlags(msg.flags);

		  msg.ch := ch;  msg.keysym := key;

		(* ch := TranslateKey(wParam, FALSE);  *)
		(*IF ch # 0X THEN*)
		lParam := lParam MOD ASH( 1, 16 );
		IF (msg.keysym # 0) OR (msg.ch # 0X)  THEN

			KeyHandled := TRUE;
			WHILE lParam > 0 DO KeyEvent( ORD(msg.ch), msg.flags, msg.keysym );
				 DEC( lParam )
			END;

		ELSE KeyHandled := FALSE;
		END;

	END HandleKey;

	(* default handler for WMKeyDown or WMKeyUp messages *)
	PROCEDURE HandleKeyUp( wParam: User32.WParam;  lParam: User32.LParam );
	VAR ch: CHAR;  msg: Inputs.KeyboardMsg; key : LONGINT;
	BEGIN
		DecomposeKeyEvent( LONGINT(wParam), LONGINT(lParam), ch, key, TRUE );
		GetKeyFlags(msg.flags);
		msg.flags := msg.flags  + {Inputs.Release};
		msg.ch := ch;
		msg.keysym := key;
		KeyEvent( ORD(msg.ch), msg.flags, msg.keysym );
	END HandleKeyUp;

	PROCEDURE GetMinMaxInfo(lParam: User32.LParam ): BOOLEAN;
	VAR mm: User32.MinMaxInfo;
	BEGIN
		SYSTEM.MOVE( lParam, ADDRESSOF( mm ), SIZEOF( User32.MinMaxInfo ) );  mm.ptMaxSize.x := width;
		mm.ptMaxSize.y := height;  mm.ptMaxTrackSize := mm.ptMaxSize;  RETURN TRUE;
	END GetMinMaxInfo;

	PROCEDURE Minimize();
	BEGIN
		INCL(state, minimized );  EXCL(state, maximized );
	END Minimize;

	PROCEDURE Maximize();
	BEGIN
		EXCL( state, minimized );  INCL( state, maximized );
	END Maximize;

	PROCEDURE Restore();
	BEGIN
		EXCL( state, minimized );  EXCL( state, maximized );
	END Restore;

	PROCEDURE PosChanging(  lParam: User32.LParam );
	VAR pos: User32.WindowPos;
	BEGIN
		SYSTEM.MOVE( lParam, ADDRESSOF( pos ), SIZEOF( User32.WindowPos ) );
		IF ~(User32.SWPNoMove IN pos.flags) THEN
			IF (pos.x < -width) & (pos.y < -height) THEN Minimize()
			ELSIF (pos.x >= 0) & (pos.y >= 0) THEN Restore()
			END
		END;
	END PosChanging;

	PROCEDURE UpdateDisplay(id: LONGINT;  lParam: User32.LParam; wParam: User32.WParam );
	VAR
		ps: User32.PaintStruct;
	BEGIN
		IF ~(minimized IN state) THEN
			IF id = resize THEN
				width := LONGINT(lParam) MOD ASH( 1, 16 );
				height := LONGINT(lParam) DIV ASH( 1, 16 );
				Reshape(width, height);

			ELSIF id = redraw THEN
				User32.BeginPaint(hWnd, ps);
				Display();
				User32.EndPaint(hWnd, ps);
			END;
		END;
	END UpdateDisplay;


	(** Common base handler for all visual windows (document or control) provided by this module. *)
	PROCEDURE WindowHandler( uMsg: LONGINT;  wParam: User32.WParam;
													  lParam: User32.LParam ): User32.LResult;
	VAR handled: BOOLEAN; ret: Kernel32.HANDLE;
	BEGIN
				handled := TRUE;
				CASE uMsg OF
				(*| User32.WMMove:
						KernelLog.String("WMMove"); KernelLog.Ln; *)

				 WinApi.WM_ERASEBKGND: RETURN 1; (* disble flickering *)
				| WinApi.WM_SIZING :

				| WinApi.WM_SIZE:
						IF wParam = User32.SizeMaximized THEN Maximize();  UpdateDisplay( resize, lParam, wParam );
						ELSIF wParam = User32.SizeMinimized THEN Minimize();
						ELSIF wParam = User32.SizeRestored THEN Restore();  UpdateDisplay(resize, lParam, wParam );
						END;
						RETURN 0;

				| User32.WMPaint:
						UpdateDisplay(redraw, lParam, wParam );
						RETURN 0;
				| User32.WMMouseActivate:
						IF ((lParam MOD 65536) # (User32.HTClient)) THEN ret := User32.SetFocus( hWnd ) END;
						RETURN User32.MANoActivate
				| User32.WMGetMinMaxInfo:
						handled := GetMinMaxInfo(lParam )
				| User32.WMWindowPosChanging:
						handled := GetMinMaxInfo(lParam );  PosChanging(lParam );  handled := FALSE
				| User32.WMSetFocus, User32.WMKillFocus:
						HandleFocus(uMsg, wParam );
						RETURN 0;
				| User32.WMClose, User32.WMQuit: 	Close;
						(*active := FALSE;*)
						RETURN 0;

				| User32.WMKeyDown:
						HandleKey(wParam, lParam);
						RETURN 0;
				(*| User32.WMKeyUp:
						HandleKeyUp(wParam, lParam ); *)
						(* RETURN 0; *)
				| User32.WMChar:
						IF ~KeyHandled THEN
							HandleChar(wParam, lParam );
							RETURN 0;
						END;
				| User32.WMSysKeyDown: HandleKey(wParam, lParam); RETURN 0;
				| User32.WMSysKeyUp: HandleKeyUp(wParam, lParam); RETURN 0;

				| User32.WMLButtonDown, User32.WMLButtonUp,User32.WMMButtonDown, User32.WMMButtonUp,
					User32.WMRButtonDown, User32.WMRButtonUp, User32.WMXButtonDown,
				 User32.WMXButtonUp, User32.WMMouseWheel, User32.WMMouseMove:
				 					HandleMouse(uMsg, wParam, lParam );
				 					RETURN 0;
		ELSE
			handled := FALSE;
		END;
		IF ~handled THEN RETURN defWindowProc(hWnd,uMsg, wParam, lParam );  ELSE RETURN 0 END;

(*		RETURN User32.DefWindowProc(hWnd,uMsg, wParam, lParam ) *)
	END WindowHandler;

	PROCEDURE RegisterClasses();
	VAR str: ARRAY 32 OF CHAR;
		ret: Kernel32.ATOM;
		windowClass: User32.WndClassEx;
		cur: User32.HCursor;
	BEGIN
		windowClass.cbSize := SIZEOF( User32.WndClassEx );
		windowClass.style := WinApi.CS_OWNDC + WinApi.CS_VREDRAW + WinApi.CS_HREDRAW;   (* Cs_parentdc: INTEGER is 128  = 2^7 *)
		windowClass.lpfnWndProc := WindowProc;  windowClass.cbClsExtra := 0;  windowClass.cbWndExtra := 4;
		windowClass.hInstance := Kernel32.hInstance;  str := "Console";  windowClass.hIcon := User32.LoadIcon( Kernel32.hInstance, str );
		str := "Console.Small";  windowClass.hIconSm := User32.LoadIcon( Kernel32.hInstance, str );
		windowClass.hCursor := Kernel32.NULL;

		windowClass.hbrBackground := Kernel32.NULL;  windowClass.lpszMenuName := Kernel32.NULL;
		windowClass.lpszClassName := SYSTEM.VAL( Kernel32.LPSTR, ADDRESSOF(className ) );
		ret := User32.RegisterClassEx( windowClass );

	END RegisterClasses;

	PROCEDURE UnregisterClasses();
	VAR ret: Kernel32.BOOL;
	BEGIN
		ret := User32.UnregisterClass(className, Kernel32.hInstance );
	END UnregisterClasses;

	PROCEDURE CreateWindow(): BOOLEAN;
	VAR
		rect: User32.Rect;
	BEGIN
		IF fullscreen THEN
			screenSettings.dmSize:=SIZEOF(WinApi.DEVMODE);
			screenSettings.dmPelsWidth := width;
			screenSettings.dmPelsHeight := height;
			screenSettings.dmBitsPerPel := 32;
			screenSettings.dmFields := WinApi.DM_BITSPERPEL + WinApi.DM_PELSWIDTH + WinApi.DM_PELSHEIGHT;

			IF WinApi.ChangeDisplaySettings(ADDRESSOF(screenSettings), WinApi.CDS_FULLSCREEN) # WinApi.DISP_CHANGE_SUCCESSFUL THEN
				IF debug THEN KernelLog.String("could not change to fullscreen"); KernelLog.Ln; END;

				(* could not change, so revert to windowed mode *)
				fullscreen := FALSE;
			END;
		END;

		IF fullscreen THEN
			create.dwExStyle := WinApi.WS_EX_APPWINDOW;
			create.dwStyle := WinApi.WS_POPUP + WinApi.WS_CLIPSIBLINGS + WinApi.WS_CLIPCHILDREN;
			User32.ShowCursor(0);
		ELSE
			create.dwExStyle := WinApi.WS_EX_APPWINDOW + WinApi.WS_EX_WINDOWEDGE;
			create.dwStyle := WinApi.WS_OVERLAPPEDWINDOW + WinApi.WS_CLIPSIBLINGS + WinApi.WS_CLIPCHILDREN;
		END;

		rect.left := 0 ;
		rect.top := 0;

		IF fullscreen THEN
			left := 0;
			top := 0;
		END;

		rect.right := width; 	rect.bottom := height;
		WinApi.AdjustWindowRectEx(rect, create.dwStyle, 0, create.dwExStyle);

		hWnd :=
			User32.CreateWindowEx( SYSTEM.VAL(LONGINT, create.dwExStyle) , className, title, create.dwStyle, left, top,  (rect.right - rect.left) , (rect.bottom - rect.top),
													   0 ,0, Kernel32.hInstance,
													   SYSTEM.VAL( User32.LParam, create));
		RETURN (hWnd # 0);
	END CreateWindow;

	(* close the window and its resources *)
	PROCEDURE CloseWindow*();
	VAR res: Kernel32.BOOL;
		bres : BOOLEAN;
	BEGIN
		active := FALSE;
		IF fullscreen THEN
			WinApi.ChangeDisplaySettings(0, {});
			User32.SetCursor(1);
		END;

		(* do we have a rendering context *)
		IF  hGLRC # 0 THEN
			(* Release the DC and RC contexts *)
			GL.wglMakeCurrent(0, 0 );
			(* Delete the rendering context *)
			bres := GL.wglDeleteContext( hGLRC );
			hGLRC := 0;
		END;

		IF hDC # 0 THEN
			(* Release the device context *)
			res := User32.ReleaseDC(hWnd, hDC);
			hDC := 0;
		END;

		(* Do we have a window *)
		IF hWnd # 0 THEN
			(* Destroy the window *)
			res := User32.DestroyWindow(hWnd );
			hWnd := Kernel32.NULL;
		END;

		UnregisterClasses();

		IF cmdlinerun THEN
			Modules.Shutdown( Modules.Reboot );
		END;
		IF debug THEN
			KernelLog.String("CloseWindow Ok."); KernelLog.Ln;
		END;
	END CloseWindow;


	PROCEDURE LoopForEvents*();
	VAR msg: User32.Msg;
	BEGIN
		IF WinApi.PeekMessage(msg, 0, 0,0, WinApi.PM_REMOVE) # 0 THEN
			IF msg.message = User32.WMQuit THEN
				active := FALSE
			ELSE;
				User32.TranslateMessage(msg);
				User32.DispatchMessage(msg);
			END
		END;
	END LoopForEvents;

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

		RegisterClasses();
		IF ~CreateWindow() THEN Close(); RETURN END;

		User32.ShowWindow( hWnd, User32.SWShow);
		User32.SetForegroundWindow(hWnd);

		(*User32.UpdateWindow(hWnd);*)
		(*User32.SetWindowText(hWnd, title);*)
		(*User32.SetFocus(hWnd);*)

		(* create GL context for this window *)
		IF ~CreateGLRC({opDoubleBuffered}, 32, 16, 8, 0,0,0) THEN
			Close;
			RETURN;
		END;

		MakeCurrent();

		GL.ReadOpenGLCore();
	(*	GL.Read_WGL_EXT_swap_control; (* needed for swap interval *)
		SetSwapInterval(0); *)

		OnLoad();
		Reshape(width, height);
		Display();
		active := TRUE;

		WHILE active DO (* loop until WMQuit received *)
			i:=(i+1)MOD 10;
			Kernel.SetTimer(fpstimer, 1000);

			LoopForEvents();
			(* ------------ game mode starts ------------- *)
			IF gamemode THEN
				IF idletime # 0 THEN
					IF Kernel.Expired(idletimer) THEN
						IdleDisplay;
						Kernel.SetTimer(idletimer, idletime);
					END;
				ELSE
					Display();
			(*		Kernel32.Sleep(0); *)
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

		END; (* while *)
		CloseWindow();
	END MainLoop;

	BEGIN {ACTIVE, PRIORITY(Objects.Normal) }
		MainLoop()
	END Window;

VAR
	classCount: LONGINT; (* for each window increase this number *);

	fixedFrameX, fixedFrameY, frameX, frameY, captionY, menuY: LONGINT;
	hCurrentCursor, hAlternativeCursor: User32.HCursor;

	ISOToOberon: ARRAY 256 OF CHAR;
	moduleCS: Kernel32.CriticalSection;

	KeyHandled: BOOLEAN;


	(* wParam contains the virtual key code
	 	lParam: {0..15}: Key repeat count, {16..23}: Scan code, {24}: Extended-key flag, {25..28}: Reserved,
	 	{29}: Context code (1 if ALT was down, 0 otherwise), {30}: Previous key-state flag, {31}: Transition-state flag *)
	PROCEDURE DecomposeKeyEvent( wParam, lParam: LONGINT;  VAR ch: CHAR;  VAR key: LONGINT;  char: BOOLEAN );
	VAR scancode: LONGINT;  previous: LONGINT;  repeat: LONGINT;  extended: BOOLEAN;
	BEGIN
		repeat := lParam MOD ASH( 1, 16 );  scancode := ASH( lParam, -16 ) MOD ASH( 1, 8 );  extended := ODD( ASH( lParam, -24 ) );
		previous := ASH( lParam, -30 ) MOD 2;

		key := 0;  ch := 0X;

		CASE wParam OF
		| kEnter:
				IF extended THEN key := Inputs.KsKPEnter ELSE key := Inputs.KsReturn END; ch := Enter;
		| kPageUp:
				key := Inputs.KsPageUp; ch := PageUp (* if ~extended then on numerical pad *)
		| kPageDown:
				key := Inputs.KsPageDown;  ch := PageDown;
		| kEnd:
				key := Inputs.KsEnd;  ch := End;
		| kHome:
				key := Inputs.KsHome;  ch := Home;
		| kLeft:
				key := Inputs.KsLeft;  ch := Left;
		| kRight:
				key := Inputs.KsRight;  ch := Right;
		| kUp:
				key := Inputs.KsUp;  ch := Up;
		| kDown:
				key := Inputs.KsDown;  ch := Down;
		| kInsert:
				key := Inputs.KsInsert;  ch := Insert;
		| kDelete:
				key := Inputs.KsDelete;  ch := Delete;
		| kF1:
				key := Inputs.KsF1;  ch := F1;
		| kF2:
				key := Inputs.KsF2;  ch := F2;
		| kF3:
				key := Inputs.KsF3;  ch := F3;
		| kF4:
				key := Inputs.KsF4;  ch := F4;
		| kF5:
				key := Inputs.KsF5;  ch := F5;
		| kF6:
				key := Inputs.KsF6;  ch := F6;
		| kF7:
				key := Inputs.KsF7;  ch := F7;
		| kF8:
				key := Inputs.KsF8;  ch := F8;
		| kF9:
				key := Inputs.KsF9;  ch := F9;
		| kF10:
				key := Inputs.KsF10;  ch := F10;
		| kF11:
				key := Inputs.KsF11;  ch := F11;
		| kF12:
				key := Inputs.KsF12;  ch := F12;
		| kCtrl:
				IF extended THEN key := Inputs.KsControlR ELSE key := Inputs.KsControlL END;
		| kAlt:
				IF extended THEN key := Inputs.KsAltR ELSE key := Inputs.KsAltL END;
		| kMenu:
				key := Inputs.KsMenu;
		| kNumlock:
				key := Inputs.KsNumLock
		| kShift:
				IF extended THEN key := Inputs.KsShiftR ELSE key := Inputs.KsShiftL END;
		| kPause:
				key := Inputs.KsPause
		| kCapsLock:
				key := Inputs.KsCapsLock;
		| kEscape:
				key := Inputs.KsEscape;
		| kTab:
				key := Inputs.KsTab;  ch := 09X;
		| User32.VKBack:
				key := Inputs.KsBackSpace; ch := Backspace;
		ELSE
			IF char THEN GetChar( wParam, lParam, ch, key ); END;
		END;
	END DecomposeKeyEvent;

	PROCEDURE GetChar( wParam, lParam: LONGINT;  VAR ch: CHAR;  VAR key: LONGINT );
	BEGIN
		ch := ISOToOberon[wParam]; key := ORD( ch );
	END GetChar;

	PROCEDURE GetKeyState( key: LONGINT;  what: INTEGER ): BOOLEAN;
	VAR state: INTEGER;
	BEGIN
		state := User32.GetKeyState( key );  RETURN what IN SYSTEM.VAL( SET, state );
	END GetKeyState;


	PROCEDURE {WINAPI} WindowProc( hwnd: User32.HWND;  uMsg: LONGINT;  wParam: User32.WParam;
															    lParam: User32.LParam ): User32.LResult;
	VAR
		win: Window; create: CreateStruct;  ret: Kernel32.BOOL;
	BEGIN
		win := SYSTEM.VAL( Window, User32.GetWindowLong( hwnd, WinApi.GWL_USERDATA));

		IF win # NIL THEN
			RETURN win.WindowHandler( uMsg, wParam, lParam );
		END;

		CASE uMsg OF
			 User32.WMCreate:
				SYSTEM.GET( lParam, create );  wParam := SYSTEM.VAL( User32.WParam, create );
				lParam := SYSTEM.VAL( User32.LParam, create.win );
				ret := User32.PostMessage( hwnd, WMSetup, wParam, lParam );
				RETURN 0;
			| WMSetup:
				win := SYSTEM.VAL( Window, lParam );  ret := User32.SetWindowLong( hwnd, WinApi.GWL_USERDATA, LONGINT( lParam ));
				create := SYSTEM.VAL( CreateStruct, wParam );
				RETURN 0;
		ELSE
		END;

		RETURN  User32.DefWindowProc( hwnd, uMsg, wParam, lParam );
	END WindowProc;

	PROCEDURE InitMod;
	VAR  i: LONGINT;
		str: ARRAY 32 OF CHAR;
	BEGIN
		classCount := 1;

		fixedFrameX := User32.GetSystemMetrics( User32.SMCXFixedFrame );
		fixedFrameY := User32.GetSystemMetrics( User32.SMCYFixedFrame );
		frameX := User32.GetSystemMetrics( User32.SMCXFrame );
		frameY := User32.GetSystemMetrics( User32.SMCYFrame );
		captionY := User32.GetSystemMetrics( User32.SMCYCaption );
		menuY := User32.GetSystemMetrics( User32.SMCYMenu );
(*
		str := "Arrow.cur"; hCurrentCursor := User32.LoadCursor( Kernel32.hInstance, str );   (* Kernel32.NULL;  *)
		str := "Cross.cur";  hAlternativeCursor := User32.LoadCursor( Kernel32.hInstance, str );
*)

		str := "../PELinker/Arrow.cur"; hCurrentCursor := User32.LoadCursorFromFile( str );
		str := "../PELinker/Cross.cur";  hAlternativeCursor := User32.LoadCursorFromFile( str );

		Kernel32.InitializeCriticalSection( moduleCS );

		FOR i := 0 TO 255 DO ISOToOberon[i] := CHR( i );  END;
		ISOToOberon[146] := CHR( 39 );  ISOToOberon[160] := CHR( 32 );  ISOToOberon[162] := CHR( 99 );
		ISOToOberon[166] := CHR( 124 );  ISOToOberon[168] := CHR( 34 );  ISOToOberon[169] := CHR( 99 );  ISOToOberon[170] := CHR( 97 );
		ISOToOberon[171] := CHR( 60 );  ISOToOberon[173] := CHR( 45 );  ISOToOberon[174] := CHR( 114 );  ISOToOberon[175] := CHR( 45 );
		ISOToOberon[176] := CHR( 111 );  ISOToOberon[178] := CHR( 50 );  ISOToOberon[179] := CHR( 51 );  ISOToOberon[180] := CHR( 39 );
		ISOToOberon[183] := CHR( 46 );  ISOToOberon[185] := CHR( 49 );  ISOToOberon[186] := CHR( 48 );  ISOToOberon[187] := CHR( 62 );
		ISOToOberon[192] := CHR( 65 );  ISOToOberon[193] := CHR( 65 );  ISOToOberon[194] := CHR( 65 );  ISOToOberon[195] := CHR( 65 );
		ISOToOberon[196] := CHR( 128 );  ISOToOberon[197] := CHR( 65 );  ISOToOberon[198] := CHR( 65 );  ISOToOberon[199] := CHR( 67 );
		ISOToOberon[200] := CHR( 69 );  ISOToOberon[201] := CHR( 69 );  ISOToOberon[202] := CHR( 69 );  ISOToOberon[203] := CHR( 69 );
		ISOToOberon[204] := CHR( 73 );  ISOToOberon[205] := CHR( 73 );  ISOToOberon[206] := CHR( 73 );  ISOToOberon[207] := CHR( 73 );
		ISOToOberon[208] := CHR( 68 );  ISOToOberon[209] := CHR( 78 );  ISOToOberon[210] := CHR( 79 );  ISOToOberon[211] := CHR( 79 );
		ISOToOberon[212] := CHR( 79 );  ISOToOberon[213] := CHR( 79 );  ISOToOberon[214] := CHR( 129 );  ISOToOberon[215] := CHR( 42 );
		ISOToOberon[216] := CHR( 79 );  ISOToOberon[217] := CHR( 85 );  ISOToOberon[218] := CHR( 85 );  ISOToOberon[219] := CHR( 85 );
		ISOToOberon[220] := CHR( 130 );  ISOToOberon[221] := CHR( 89 );  ISOToOberon[222] := CHR( 80 );
		ISOToOberon[223] := CHR( 150 );  ISOToOberon[224] := CHR( 139 );  ISOToOberon[225] := CHR( 148 );
		ISOToOberon[226] := CHR( 134 );  ISOToOberon[227] := CHR( 97 );  ISOToOberon[228] := CHR( 131 );
		ISOToOberon[229] := CHR( 97 );  ISOToOberon[230] := CHR( 97 );  ISOToOberon[231] := CHR( 147 );
		ISOToOberon[232] := CHR( 140 );  ISOToOberon[233] := CHR( 144 );  ISOToOberon[234] := CHR( 135 );
		ISOToOberon[235] := CHR( 145 );  ISOToOberon[236] := CHR( 141 );  ISOToOberon[237] := CHR( 105 );
		ISOToOberon[238] := CHR( 136 );  ISOToOberon[239] := CHR( 146 );  ISOToOberon[240] := CHR( 100 );
		ISOToOberon[241] := CHR( 149 );  ISOToOberon[242] := CHR( 142 );  ISOToOberon[243] := CHR( 111 );
		ISOToOberon[244] := CHR( 137 );  ISOToOberon[245] := CHR( 111 );  ISOToOberon[246] := CHR( 132 );
		ISOToOberon[248] := CHR( 111 );  ISOToOberon[249] := CHR( 143 );  ISOToOberon[250] := CHR( 117 );
		ISOToOberon[251] := CHR( 138 );  ISOToOberon[252] := CHR( 133 );  ISOToOberon[253] := CHR( 121 );
		ISOToOberon[254] := CHR( 112 );  ISOToOberon[255] := CHR( 121 );

	END InitMod;

BEGIN
	InitMod();    KeyHandled := FALSE;
END OGLWindow.


System.Free OGLWindow ~

System.FreeDownTo OpenGL ~
