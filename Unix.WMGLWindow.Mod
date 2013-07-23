MODULE WMGLWindow; (** AUTHOR "fnecati"; PURPOSE "an OpenGL Context enabled WM.Window using GLXPixmap for LinuxAos"; *)
(*! Hidden context  *)
IMPORT
	Machine, X11, Api:=X11Api, GL:=OpenGL, GLC := OpenGLConst, Raster,
	WM := WMWindowManager, KernelLog;

CONST debug = FALSE;

TYPE
	WindowStruct *= RECORD
		display* : X11.DisplayPtr;
		glctx* : GL.GLXContext;
		visualInfoPtr* : Api.VisualInfoPtr;
		pixmap*: X11.Pixmap;
		glxpixmap*: GL.GLXPixmap;
	END;

	Buffer = POINTER TO ARRAY OF CHAR;

TYPE Context = OBJECT
	VAR
		glWin- : WindowStruct;
		doublebuffered-: BOOLEAN; (* is context doublebuffered *)
	 	buffer: Buffer; (* for speedup flip image in y*)
	 	rastermode: Raster.Mode;
		width-, height-: LONGINT;

	PROCEDURE Init(w, h: LONGINT);
	VAR
		res: LONGINT;
		att: POINTER TO  ARRAY OF GL.Int;
	  	dumy1, dumy2: LONGINT;
	BEGIN

		Machine.Acquire( Machine.X11 );

	(*  get a connection *)
		glWin.display := X11.OpenDisplay(0);
		IF glWin.display =0 THEN
 			Machine.Release( Machine.X11 );
 			KernelLog.String(" cannot connect to X server"); KernelLog.Ln;
			Close;
			RETURN;
		END;

		(* Check if GLX is supported on this display *)
		IF ( GL.glXQueryExtension( glWin.display, dumy1, dumy2 ) =  0 ) THEN
			Machine.Release( Machine.X11 );
		       KernelLog.String("GLX is NOT supported on this display"); KernelLog.Ln;
		       Close;
			RETURN
		END;

		NEW(att, 13);
		att[0] := GLC.GLX_RGBA;
		att[1] := GLC.GLX_DOUBLEBUFFER;
		att[2] := GLC.GLX_DEPTH_SIZE;	att[3] := 24;
		att[4] := GLC.GLX_STENCIL_SIZE;	att[5] := 8;
		att[6] := GLC.GLX_RED_SIZE;  	att[7] := 8;
		att[8] := GLC.GLX_GREEN_SIZE;	att[9] := 8;
		att[10] := GLC.GLX_RED_SIZE;	att[11] := 8;
		att[12] := 0 ;

		doublebuffered := TRUE;
		glWin.visualInfoPtr := GL.glXChooseVisual(glWin.display, 0, ADDRESSOF(att[0]));

		IF glWin.visualInfoPtr = NIL THEN
			Machine.Release( Machine.X11 );
			KernelLog.String(" NO appropriate visual found"); KernelLog.Ln;
			Close;
			RETURN;
		ELSE
			IF debug THEN
				KernelLog.String("visualInfoPtr.depth= "); KernelLog.Int(glWin.visualInfoPtr.depth,0); KernelLog.Ln;
			 	KernelLog.String("visualInfoPtr.visual ");  KernelLog.Int(glWin.visualInfoPtr.visualID, 0); KernelLog.Hex(glWin.visualInfoPtr.visualID, 4);KernelLog.Ln;
			 	KernelLog.String("visualInfoPtr.screen ");  KernelLog.Int(glWin.visualInfoPtr.screen, 0); KernelLog.Ln;
			 END;
		END;

		glWin.pixmap := X11.CreatePixmap(glWin.display, X11.DefaultRootWindow(glWin.display), w, h, glWin.visualInfoPtr.depth);
		IF glWin.pixmap = 0 THEN
			Machine.Release( Machine.X11 );
			KernelLog.String(" glWin.pixmap ERROR"); KernelLog.Ln;
			Close;
			RETURN;
		END;

		glWin.glxpixmap := GL.glXCreateGLXPixmap(glWin.display,glWin.visualInfoPtr, glWin.pixmap);

		IF glWin.glxpixmap = 0 THEN
			Machine.Release( Machine.X11 );
			KernelLog.String("glWin.glxpixmap ERROR"); KernelLog.Ln;
			Close;
			RETURN;
		END;

		GL.glXWaitX();
		 X11.Sync(glWin.display,X11.False);

	 	(* create GL context *)
	 	(* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
	 	glWin.glctx := GL.glXCreateContext(glWin.display, glWin.visualInfoPtr, 0, GLC.GL_TRUE);
	 	IF glWin.glctx = 0 THEN
	 		Machine.Release( Machine.X11 );
			KernelLog.String("could not create context");
			Close;
			RETURN;
		END;


	 	res := GL.glXMakeCurrent(glWin.display, glWin.glxpixmap, glWin.glctx);
	 	IF debug THEN
			KernelLog.String("glXMakeCurrent res= "); KernelLog.Int(res, 0); KernelLog.Ln;
	 	END;

	 	X11.Flush(glWin.display);
	 	GL.glXWaitX();
		Machine.Release( Machine.X11 );

		IF debug THEN KernelLog.String("GL.glXIsDirect(glWin.display, glWin.lctx)= "); KernelLog.Boolean(GL.glXIsDirect(glWin.display, glWin.glctx)=1); KernelLog.Ln; END;

		width := w; height := h;

		NEW(buffer, w*h*4); (* create RGBA buffer for render operations *)
		Raster.InitMode(rastermode, Raster.srcCopy);

(*		GL.ReadOpenGLCore; *)

	END Init;

	(** *)
	PROCEDURE CreatePixmaps(w, h: LONGINT): BOOLEAN;
	VAR
	BEGIN

		Machine.Acquire( Machine.X11 );
		(* first delete these, do we have a gxpixmap *)
		IF glWin.glxpixmap # 0 THEN
			GL.glXDestroyGLXPixmap(glWin.display, glWin.glxpixmap);
			IF debug THEN KernelLog.String("GLXPixmap deleted"); KernelLog.Ln; END;
		END;

		(* do we have a pixmap *)
		IF glWin.pixmap # 0 THEN
			X11.FreePixmap(glWin.display, glWin.pixmap);
			IF debug THEN KernelLog.String("X11-Pixmap deleted"); KernelLog.Ln; END;
		END;

		(* now create them *)
		glWin.pixmap := X11.CreatePixmap(glWin.display, X11.DefaultRootWindow(glWin.display), w, h, glWin.visualInfoPtr.depth);
		IF glWin.pixmap = 0 THEN
			KernelLog.String(" glWin.pixmap ERROR"); KernelLog.Ln;
			Machine.Release( Machine.X11 );
			RETURN FALSE;
		END;

		glWin.glxpixmap := GL.glXCreateGLXPixmap(glWin.display,glWin.visualInfoPtr, glWin.pixmap);

		IF glWin.glxpixmap = 0 THEN
			KernelLog.String("glWin.glxpixmap ERROR"); KernelLog.Ln;
			Machine.Release( Machine.X11 );
			RETURN FALSE;

		END;
		Machine.Release( Machine.X11 );
		RETURN TRUE

	END CreatePixmaps;

	PROCEDURE MakeCurrent();
	 VAR res: LONGINT;
	 BEGIN 
	(* 	Machine.Acquire( Machine.X11 );*)
		res := GL.glXMakeCurrent(glWin.display, glWin.glxpixmap, glWin.glctx);
		 IF debug THEN KernelLog.String(" MakeCurrent:"); KernelLog.Boolean(res=1); KernelLog.Ln; END;
	(* Machine.Release( Machine.X11 ); *)
	END MakeCurrent;

	PROCEDURE SwapBuffers;
	 BEGIN
		Machine.Acquire( Machine.X11 );
		IF doublebuffered THEN
			GL.glXSwapBuffers(glWin.display, glWin.glxpixmap);
		ELSE
	 		GL.Flush();
		END;
 		Machine.Release( Machine.X11 );
	END SwapBuffers;

	PROCEDURE DeActivate();
 	VAR res: LONGINT;
 	BEGIN
	(*	Machine.Acquire( Machine.X11 ); *)
		res := GL.glXMakeCurrent(glWin.display, 0, 0);
		IF debug THEN KernelLog.String(" DeActivate:"); KernelLog.Boolean(res=1); KernelLog.Ln; END;
	(*	Machine.Release( Machine.X11 ); *)
	END DeActivate;

		(** Close the window *)
	PROCEDURE Close;
	BEGIN (* {EXCLUSIVE}*)
		CloseWindow();
	END Close;

	PROCEDURE CloseWindow;
	VAR res: LONGINT;
	BEGIN
		Machine.Acquire( Machine.X11 );
		(* do we have a rendering context *)
		IF glWin.glctx # 0 THEN
			(* Release the context *)
		    	res := GL.glXMakeCurrent(glWin.display, 0, 0);
		    	(* Delete the context *)
			GL.glXDestroyContext(glWin.display, glWin.glctx);
			IF debug THEN KernelLog.String("context deleted"); KernelLog.Ln; END;
		END;

		(* do we have a window *)
		IF glWin.glxpixmap # 0 THEN
			GL.glXDestroyGLXPixmap(glWin.display, glWin.glxpixmap);
			IF debug THEN KernelLog.String("GLXPixmap deleted"); KernelLog.Ln; END;
		END;

		(* do we have a window *)
		IF glWin.pixmap # 0 THEN
			X11.FreePixmap(glWin.display, glWin.pixmap);
			IF debug THEN KernelLog.String("X11-Pixmap deleted"); KernelLog.Ln; END;
		END;

		(* do we have a display *)
		IF glWin.display # 0 THEN
			 res := Api.CloseDisplay(glWin.display);
			IF debug THEN KernelLog.String("display deleted"); KernelLog.Ln; END;
		END;

		Machine.Release( Machine.X11 );
 	END CloseWindow;


	PROCEDURE Resize(w, h: LONGINT);
	BEGIN {EXCLUSIVE}
		IF (w = width) & (h=height) THEN RETURN END;
		width := w; height := h;
		buffer := NIL;
		NEW(buffer, w*h*4);
		IF ~ CreatePixmaps(w, h) THEN
			Close;
		END;
	END Resize;

	PROCEDURE RenderInto(image: Raster.Image);
	VAR
		i: LONGINT;
		w, h: LONGINT;
	BEGIN
		w := image.width;
		h := image.height;
		Machine.Acquire( Machine.X11 );		
		GL.ReadPixels(0, 0, w, h, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(buffer^[0])); 
		Machine.Release( Machine.X11 ); 

		(* flip vertical, y *)
		FOR i := 0 TO h - 1 DO
			Raster.PutPixels(image, 0, h-1-i, w, Raster.BGRA8888, buffer^, i * w * 4, rastermode)
		END
		
	END RenderInto;

	(** *)
	PROCEDURE Info;
	VAR res: LONGINT;
	BEGIN

	END Info;

BEGIN
END Context;

	Window* =  OBJECT(WM.DoubleBufferWindow)
	VAR
		context : Context;

		PROCEDURE &Init(w, h: LONGINT; alpha: BOOLEAN);
		BEGIN
			Init^(w, h, alpha); (* use alpha, for 32bpp img *)
			NEW(context);
			context.Init(w, h);

		END Init;

		(** *)
		PROCEDURE Close*();
		BEGIN
			context.Close();
			context := NIL;
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
		BEGIN
			RETURN context.glWin.display;
		END GetDisplay;

		PROCEDURE GetContext*(): LONGINT;
		BEGIN
			RETURN context.glWin.glctx;
		END GetContext;

		PROCEDURE GetScreen*(): LONGINT;
		BEGIN
			RETURN 0; (*context.glWin.screen*)
		END GetScreen;

	END Window;

BEGIN
END WMGLWindow.

SystemTools.Free WMGLWindow ~

SystemTools.FreeDownTo OpenGL ~ 