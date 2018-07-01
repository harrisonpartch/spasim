MODULE WMGLWindow; (** AUTHOR "fnecati"; PURPOSE "an OpenGL Context enabled WM.Window using GLXPixmap for LinuxAos"; *)

IMPORT
	Kernel32, User32, KernelLog, WinApi, GL:=OpenGL, GLC := OpenGLConst, Raster,
	WM := WMWindowManager,  SYSTEM, Strings;

CONST
	debug = FALSE;
	COMPATIBILITY_PROFILE* = 0;
	CORE_PROFILE* = 1;

CONST
	WMSetup = User32.WMUser + 1;

CONST
	opDoubleBuffered = 0;
	opStereo = 1;

TYPE
	WindowStruct = POINTER TO RECORD
		windowClassName, title: ARRAY 32 OF CHAR;
		Instance: Kernel32.HMODULE;
		hWind: WinApi.HWND;   (* handle of this window *)
		hDC: WinApi.HDC; (* drawing context of this window*)
		hGLRC : WinApi.HGLRC; (* GL render context handles for this window *)
		width, height: LONGINT; (* size of window *)
		doublebuffer: BOOLEAN;
		context: Context;
	END;

	Buffer = POINTER TO ARRAY OF CHAR;

TYPE
	Context= OBJECT
	VAR
		glWin : WindowStruct;
		wincreated: BOOLEAN;
		initialized: BOOLEAN;
		res: BOOLEAN;
		buffer: Buffer;	(* for speedup flip image in y*)
		mode: Raster.Mode;

    	PROCEDURE Init(w, h: LONGINT);
    	BEGIN  {EXCLUSIVE}
    		wincreated := FALSE;
		initialized := FALSE;
    		NEW(glWin);
    		glWin.doublebuffer := TRUE;
    		glWin.width := w; glWin.height := h;

    		glWin.title:="GLContext.Window";
		glWin.context := SELF;

    		NEW(buffer, w*h*4);
		Raster.InitMode(mode, Raster.srcCopy);
    		initialized := TRUE;

		AWAIT (wincreated);
    	END Init;

	(* create a new opengl context with opengl version major, minor *)
	PROCEDURE SetProfile(major, minor: LONGINT; flags: SET): BOOLEAN;
	VAR res: LONGINT;
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

		tempContext := GL.wglCreateContextAttribsARB(glWin.hDC,0, ADDRESSOF(attr[0]));
		IF tempContext = NIL THEN
			IF debug THEN
				(* It's not possible to make a GL 3.x context. Use the old style context (GL 2.1 and before) *)
				KernelLog.String("Using old style context"); KernelLog.Ln;
			END;
			RETURN FALSE
		END;

		GL.wglMakeCurrent(0, 0);
		GL.wglDeleteContext(glWin.hGLRC);
		glWin.hGLRC := tempContext;
		GL.wglMakeCurrent(glWin.hDC,  glWin.hGLRC);
		GL.ReadExtensions();
		IF debug THEN
			KernelLog.String("Using new style context"); KernelLog.Ln;
		END;

  		RETURN TRUE;
	END SetProfile;

	PROCEDURE Close;
	VAR res: LONGINT;
	BEGIN
		 wincreated := FALSE;
		 res := User32.SendMessage(glWin.hWind, User32.WMQuit, 0, 0);

		IF debug THEN KernelLog.String("Close SendMessage res = "); KernelLog.Int(res, 0); KernelLog.Ln; END;

	END Close;

	PROCEDURE MakeCurrent();
	BEGIN
		res := GL.wglMakeCurrent(glWin.hDC, glWin.hGLRC);
		IF debug THEN KernelLog.String("ctx MakeCurrent res= "); KernelLog.Boolean(res); KernelLog.Ln; END;
	END MakeCurrent;

	PROCEDURE DeActivate();
	BEGIN
		res := GL.wglMakeCurrent(0, 0);
		IF debug THEN KernelLog.String("ctx DeActivate res= "); KernelLog.Boolean(res); KernelLog.Ln; END;
	END DeActivate;

	PROCEDURE SwapBuffers();
	VAR res: WinApi.BOOL;
	BEGIN {EXCLUSIVE}
		IF glWin.doublebuffer THEN
		 	res := WinApi.SwapBuffers(glWin.hDC);
		ELSE
	 	 	GL.Flush();
		END;
	END SwapBuffers;

		(** move the window to x,y and  resize width,height *)
	PROCEDURE MoveResizeWindow(x, y, w, h: LONGINT);
	BEGIN
		User32.MoveWindow(glWin.hWind, x, y, w, h, 1); (* repaint *)
	END MoveResizeWindow;

	PROCEDURE Resize(w, h: LONGINT);
	BEGIN
		buffer := NIL;
		NEW(buffer, w*h*4);
		MoveResizeWindow(0,0, w, h);
		glWin.width := w; glWin.height := h;
	END Resize;

	PROCEDURE RenderInto(image: Raster.Image);
	VAR
		i: LONGINT;
		w, h: LONGINT;
		sadr, dadr: ADDRESS;
	BEGIN
		IF (image = NIL) OR (image.adr = NIL) THEN RETURN END;
		w := image.width; h := image.height;
		GL.ReadPixels(0, 0, w, h, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(buffer^[0]));

		(* flip vertical, y *)
		sadr := ADDRESSOF(buffer[4*w*(h-1)]); dadr := image.adr;
		FOR i := 0 TO h - 1 DO
			SYSTEM.MOVE(sadr - i*w*4, dadr + i*w*4, w*4);
		END;

(*		FOR i := 0 TO h - 1 DO
			Raster.PutPixels(image, 0, h-1-i, w, Raster.BGRA8888, buffer^, i * w * 4, mode)
		END;
*)
	END RenderInto;

	(* handler for this context's window *)
	PROCEDURE WindowHandler( uMsg: LONGINT;  wParam: User32.WParam;
													  lParam: User32.LParam ): User32.LResult;
	BEGIN
		CASE uMsg OF
			User32.WMQuit:
			IF debug THEN KernelLog.String("Get WMQuit message"); KernelLog.Ln; END;
			CloseWindow(glWin);
			RETURN 1;
		ELSE
		END;
		RETURN User32.DefWindowProc(glWin.hWind, uMsg, wParam, lParam );
	END WindowHandler;

	PROCEDURE MyLoop;
	VAR
		 res: Kernel32.BOOL;
		  msg: User32.Msg;
	BEGIN
		BEGIN {EXCLUSIVE} AWAIT (initialized); END;
		wincreated := CreateHWND( glWin);
		IF ~wincreated THEN CloseWindow(glWin); RETURN; END;

		(* load opengl core funcs. *)
		MakeCurrent();
		GL.ReadOpenGLCore();
		DeActivate();

		BEGIN {EXCLUSIVE} AWAIT (wincreated);   END;
		IF debug THEN  KernelLog.String("entering messageLoop"); KernelLog.Ln; END;
		LOOP

			(* Check for new window messages *)
			IF User32.GetMessage(msg, 0, 0, 0) # 0 THEN
				IF msg.message=User32.WMClose THEN
						EXIT;
				ELSE
					res := User32.DispatchMessage(msg);
				END;
				Kernel32.Sleep( 1 );
			END;
		END;

	END MyLoop;

BEGIN {ACTIVE}
			MyLoop;
END Context;

TYPE
	Window* =  OBJECT(WM.DoubleBufferWindow)
	VAR
		context : Context;

		PROCEDURE &Init*(w, h: LONGINT; alpha: BOOLEAN);
		BEGIN
			Init^(w, h, alpha); (* use alpha, for 32bpp img *)
			NEW(context);
			context.Init(w, h);
		END Init;

		PROCEDURE SetProfile*(major, minor: LONGINT; flags: SET): BOOLEAN;
		VAR res: BOOLEAN;
		BEGIN
			res := context.SetProfile(major, minor, flags);
			RETURN res;
		END SetProfile;

		(** *)
		PROCEDURE Close*();
		BEGIN
			context.Close();
			(*context := NIL;*)
			Close^;
		END Close;

		PROCEDURE MakeCurrent*();
		BEGIN
			context.MakeCurrent();
		END MakeCurrent;

		PROCEDURE DeActivate*();
		BEGIN
			context.DeActivate();
		END DeActivate;

		PROCEDURE SwapGLBuffer*();
		BEGIN
			context.RenderInto(backImg);
		END SwapGLBuffer;

		PROCEDURE Reshape*(w,h: LONGINT);
		END Reshape;

		PROCEDURE UpdateImage*();
		END UpdateImage;

		PROCEDURE Resized(w, h: LONGINT);
		BEGIN
			context.Resize(w, h);
			ReInit(w, h);
			Reshape(w, h);
			UpdateImage;
		END Resized;

		PROCEDURE GetDisplay*(): LONGINT;
		VAR x: LONGINT;
		BEGIN
			x := SYSTEM.VAL(LONGINT, context.glWin.hDC);
			RETURN x;
		END GetDisplay;

		PROCEDURE GetContext*(): LONGINT;
		VAR x: LONGINT;
		BEGIN
			x := SYSTEM.VAL(LONGINT, context.glWin.hGLRC);
			RETURN x
		END GetContext;

		PROCEDURE GetScreen*(): LONGINT;
		BEGIN
			RETURN 0; (* unnecessary for windows; context.glWin.screen*)
		END GetScreen;

	END Window;

VAR
	ctxtcounter: LONGINT;

    PROCEDURE CreateHWND(VAR glWin:WindowStruct): BOOLEAN;
		VAR res: Kernel32.BOOL;
			 dwStyle: WORDSET;
			 dwExStyle: WORDSET;
			 windowClass: User32.WndClassEx;
			 bres: BOOLEAN;
			 scnt: ARRAY 16 OF CHAR;
       BEGIN

		glWin.Instance := Kernel32.GetModuleHandle( NIL );

		(* to create multiple GLContext with different window, change class name by appending and increasing counter value  *)
		ctxtcounter:=Kernel32.GetTickCount(); Strings.IntToStr(ctxtcounter, scnt);
		glWin.windowClassName := "WinAos.GLWindow";
		Strings.Append(glWin.windowClassName, scnt);
		IF debug THEN KernelLog.String("glWin.windowClassName= "); KernelLog.String(glWin.windowClassName); KernelLog.Ln; END;

		windowClass.cbSize := SIZEOF( User32.WndClassEx );
		windowClass.style := WinApi.CS_OWNDC + WinApi.CS_VREDRAW + WinApi.CS_HREDRAW;
		windowClass.lpfnWndProc := WindowProc; (* Message handler *)
		windowClass.cbClsExtra := 0;
		windowClass.cbWndExtra := 0;
		windowClass.hInstance := glWin.Instance;
		windowClass.hIcon := Kernel32.NULL;
		windowClass.hIconSm := Kernel32.NULL;
		windowClass.hCursor := Kernel32.NULL;
		windowClass.hbrBackground := Kernel32.NULL;
		windowClass.lpszMenuName := Kernel32.NULL;
		windowClass.lpszClassName := SYSTEM.VAL( Kernel32.LPSTR, ADDRESSOF( glWin.windowClassName ) );

		(* register window class *)
		res := User32.RegisterClassEx( windowClass );
		IF res = 0 THEN
			IF debug THEN
				KernelLog.String("RegisterClassEx res= "); KernelLog.Int(res, 0); KernelLog.Ln;
				KernelLog.String("ERROR: "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;

		dwExStyle :={};
		dwStyle := WinApi.WS_POPUP +  WinApi.WS_CLIPSIBLINGS + WinApi.WS_CLIPCHILDREN;

		 (* create the window *)
		glWin.hWind := User32.CreateWindowEx(SYSTEM.VAL(LONGINT, dwExStyle) , glWin.windowClassName, glWin.title, dwStyle , 10, 10, glWin.width, glWin.height, 0, 0,  glWin.Instance, SYSTEM.VAL( User32.LParam, glWin));
		IF glWin.hWind = 0 THEN
			IF debug THEN
				KernelLog.String("CreateWindowEx hWind= "); KernelLog.Int(glWin.hWind, 0); KernelLog.Ln;
				KernelLog.String("ERROR: CreateWindowEx: "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;

		res := User32.UpdateWindow(glWin.hWind);

		(* get drawing context for this window *)
		glWin.hDC := User32.GetDC(glWin.hWind);

		IF glWin.hDC = 0 THEN
			IF debug THEN
				KernelLog.String("hDC= "); KernelLog.Int(glWin.hDC, 0); KernelLog.Ln;
				KernelLog.String("ERROR: GetDC: "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;

		(* create GL context for this window *)
		bres := CreateGLRC(glWin, {opDoubleBuffered}, 24, 8, 8, 8,0,0);
		RETURN bres;
	END CreateHWND;

	PROCEDURE CloseWindow(VAR glWin: WindowStruct);
	VAR res: Kernel32.BOOL;
		bres : BOOLEAN;
	BEGIN (*{EXCLUSIVE}*)

	   (* do we have a rendering context *)
    IF  glWin.hGLRC # 0 THEN
        (* Release the DC and RC contexts *)
        GL.wglMakeCurrent(0, 0 );

        (* Delete the rendering context *)

        bres := GL.wglDeleteContext( glWin.hGLRC );

        glWin.hGLRC := 0;
         IF debug THEN KernelLog.String("delete glcontext .."); KernelLog.Ln; END;
    END;

    (* Do we have a device context *)
    IF glWin.hDC # 0 THEN

        (* Release the device context *)
        res := User32.ReleaseDC(glWin.hWind, glWin.hDC);
        glWin.hDC := 0;
      IF debug THEN KernelLog.String("release hdc .."); KernelLog.Ln; END;
    END;



    (* Do we have a window *)
    IF glWin.hWind # 0 THEN
        (* Destroy the window *)
		res := User32.DestroyWindow(glWin.hWind );
		glWin.hWind := Kernel32.NULL;
        IF debug THEN KernelLog.String("destroy window .."); KernelLog.Ln; END;
   END;

    (* Do we have an instance? *)
    IF  glWin.Instance # 0 THEN
        (* Unregister class *)
        res := User32.UnregisterClass( glWin.windowClassName, glWin.Instance );
        glWin.Instance := Kernel32.NULL;
        IF debug THEN KernelLog.String("unregister class .."); KernelLog.Ln; END;
    END;

	IF debug THEN KernelLog.String("CloseWindow Ok."); KernelLog.Ln; END;
	END CloseWindow;

PROCEDURE CreateGLRC(VAR glWin: WindowStruct; Options: SET; colorbits, depthbits, stencilbits, accumbits, auxbuffers: LONGINT; layer: LONGINT): BOOLEAN;

VAR
  pfd: WinApi.PIXELFORMATDESCRIPTOR;
  pixelformat : LONGINT;
  res: LONGINT;
  tmpflag: WORDSET;
BEGIN

    pfd.nSize := SIZEOF(WinApi.PIXELFORMATDESCRIPTOR);
    pfd.nVersion := 1;
    tmpflag := WinApi.PFD_SUPPORT_OPENGL + WinApi.PFD_DRAW_TO_WINDOW + WinApi.PFD_DOUBLEBUFFER;

    IF opStereo IN Options THEN
        tmpflag := tmpflag + WinApi.PFD_STEREO;
    END;

    pfd.dwFlags := tmpflag;
    pfd.iPixelType := CHR(WinApi.PFD_TYPE_RGBA);
    pfd.cColorBits := CHR(colorbits);
    pfd.cDepthBits := CHR(depthbits);
    pfd.cStencilBits := CHR(stencilbits);
    pfd.cAccumBits := CHR(accumbits);
    pfd.cAuxBuffers := CHR(auxbuffers);

	IF layer = 0 THEN
		pfd.iLayerType := CHR(WinApi.PFD_MAIN_PLANE);
	ELSIF layer > 0 THEN
		pfd.iLayerType := CHR(WinApi.PFD_OVERLAY_PLANE);
	ELSE
		pfd.iLayerType := CHR(WinApi.PFD_UNDERLAY_PLANE);
	END;

	pixelformat := WinApi.ChoosePixelFormat(glWin.hDC, ADDRESSOF(pfd));
	IF pixelformat = 0 THEN
		IF debug THEN
			KernelLog.String("pixelformat= "); KernelLog.Int(pixelformat, 0); KernelLog.Ln;
			KernelLog.String(" ERROR: Choosepixelformat Kernel32.GetLastError()= "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
		END;
		RETURN FALSE;
	END;
  (*    ASSERT(pixelformat # 0, 201); *)

	res := WinApi.DescribePixelFormat(glWin.hDC, pixelformat, SIZEOF(WinApi.PIXELFORMATDESCRIPTOR), ADDRESSOF(pfd));
	IF res = 0 THEN
		IF debug THEN
			KernelLog.String("ERROR: Describepixelformat Kernel32.GetLastError()= "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
		END;
   		RETURN FALSE;
   	END;

	res := WinApi.SetPixelFormat(glWin.hDC, pixelformat, ADDRESSOF(pfd));
	IF res =0 THEN
		IF debug THEN
			KernelLog.String("ERROR: SetpixelFormat: "); KernelLog.Int(Kernel32.GetLastError(), 0); KernelLog.Ln;
		END;
		RETURN FALSE;
	END;
  	(* ASSERT(res # 0, 202); *)

	glWin.hGLRC := GL.wglCreateContext(glWin.hDC);

  RETURN (glWin.hGLRC # 0)

END CreateGLRC;

PROCEDURE {WINAPI} WindowProc( wnd: User32.HWND;  uMsg: LONGINT;  wParam: User32.WParam;
															    lParam: User32.LParam ): User32.LResult;
VAR
	glWin: WindowStruct;
	context: Context;
	ret: Kernel32.BOOL;
BEGIN
	context := SYSTEM.VAL( Context, User32.GetWindowLong( wnd, WinApi.GWL_USERDATA));

	IF context # NIL THEN
		RETURN context.WindowHandler( uMsg, wParam, lParam );
	END;


	CASE uMsg OF
		 User32.WMCreate:
			SYSTEM.GET( lParam, glWin );  wParam := SYSTEM.VAL( User32.WParam, glWin );
			lParam := SYSTEM.VAL( User32.LParam, glWin.context );
			ret := User32.PostMessage( wnd, WMSetup, wParam, lParam );
			RETURN 0;
		| WMSetup:
			context := SYSTEM.VAL( Context, lParam );  ret := User32.SetWindowLong( wnd, WinApi.GWL_USERDATA, SYSTEM.VAL(LONGINT, lParam ));
			glWin := SYSTEM.VAL( WindowStruct, wParam );
			RETURN 0;
	ELSE
	END;
	RETURN User32.DefWindowProc(wnd, uMsg, wParam, lParam)
END WindowProc;

BEGIN
	ctxtcounter := 0;
END WMGLWindow.

SystemTools.Free WMGLWindow ~

SystemTools.FreeDownTo OpenGL ~
