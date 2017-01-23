MODULE GLContext; (** AUTHOR "fnecati"; PURPOSE "OpenGL Context for LinuxAos using hiddend X11Window"; *)
IMPORT
	Machine, X11, Api:=X11Api, GL:=OpenGL, GLC := OpenGLConst, Raster,
	KernelLog,  Strings, SYSTEM;

(*! not resizeble, SetProfile 3, 3 added *)

CONST debug = TRUE;

	   COMPATIBILITY_PROFILE* = 0;
	   CORE_PROFILE* = 1;
	   
TYPE
	WindowStruct = POINTER TO RECORD
		display: X11.DisplayPtr;
		win: X11.Window ;
		glctx: GL.GLXContext;
		width, height: LONGINT; (* size of GL window *)
		visualInfoPtr: Api.VisualInfoPtr;
		wmDeleteWindow : X11.Atom;
	END;

	Buffer = POINTER TO ARRAY OF CHAR;
	GLXFBConfigPtr =  POINTER TO ARRAY OF LONGINT;
	
TYPE Context* = OBJECT
	VAR

		glWin : WindowStruct;
		doublebuffered: BOOLEAN; (* is context doublebuffered *)
	 	buffer: Buffer; (* for speedup flip image in y*)
	 	rastermode: Raster.Mode;

	PROCEDURE Init*(w, h: LONGINT);
	VAR
		res, i: LONGINT;
		resb: GL.Boolean;
		att: POINTER TO  ARRAY OF GL.Int;
	  	masks, dumy1, dumy2: LONGINT;
	  	defwin: X11.Window;
	  	screen: LONGINT;
	BEGIN
		NEW(glWin);
		glWin.width := w; glWin.height := h;
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
		IF ( GL.glXQueryExtension( glWin.display, dumy1, dumy2 ) = 0 ) THEN
			Machine.Release( Machine.X11 );
		       KernelLog.String("GLX is NOT supported on this display"); KernelLog.Ln;
		       Close;
			RETURN
		END;

		(* Catch WM close*)
		glWin.wmDeleteWindow := Api.InternAtom( glWin.display, "WM_DELETE_WINDOW", Api.False);

		NEW(att, 24);
		i := 0;
(*		att[i] := GLC.GLX_RGBA; INC(i);
		att[i] := GLC.GLX_X_RENDERABLE; INC(i); 		att[i] := GLC.GL_TRUE; INC(i);
		att[i] := GLC.GLX_DOUBLEBUFFER; INC(i);		att[i] := GLC.GL_TRUE; INC(i);
		att[i] := GLC.GLX_DRAWABLE_TYPE; INC(i);	att[i] := GLC.GLX_WINDOW_BIT; INC(i);
		att[i] := GLC.GLX_RENDER_TYPE; INC(i);		att[i] := GLC.GLX_TRUE_COLOR; INC(i);
		att[i] := GLC.GLX_DEPTH_SIZE; INC(i); 			att[i] := 24; INC(i);
		att[i] := GLC.GLX_STENCIL_SIZE; INC(i);			att[i] := 8; INC(i);
		att[i] := GLC.GLX_RED_SIZE; INC(i); 				att[i] := 8; INC(i);
		att[i] := GLC.GLX_GREEN_SIZE;	INC(i);			att[i] := 8; INC(i);
		att[i] := GLC.GLX_BLUE_SIZE; INC(i);				att[i] := 8; INC(i);
		att[i] := GLC.GLX_ALPHA_SIZE; INC(i);			att[i] := 8; INC(i);
		att[i] := 0 ;
*)
		att[i] := GLC.GLX_RGBA; INC(i);
		att[i] := GLC.GLX_DOUBLEBUFFER; INC(i);
		att[i] := GLC.GLX_DEPTH_SIZE; INC(i); 			att[i] := 24; INC(i);
		att[i] := GLC.GLX_STENCIL_SIZE; INC(i);			att[i] := 8; INC(i);
		att[i] := GLC.GLX_RED_SIZE; INC(i); 				att[i] := 8; INC(i);
		att[i] := GLC.GLX_GREEN_SIZE;	INC(i);			att[i] := 8; INC(i);
		att[i] := GLC.GLX_BLUE_SIZE; INC(i);				att[i] := 8; INC(i);
	(*	att[i] := GLC.GLX_ALPHA_SIZE; INC(i);			att[i] := 8; INC(i); *)
		att[i] := 0 ;
		
		doublebuffered := TRUE;
		screen := X11.DefaultScreen(glWin.display);
		glWin.visualInfoPtr := GL.glXChooseVisual(glWin.display, screen , ADDRESSOF(att[0]));

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
		defwin := X11.DefaultRootWindow(glWin.display);
		glWin.win := X11.CreateSimpleWindow(glWin.display, defwin, 0, 0, glWin.width, glWin.height, 0, 0, 0);
		IF debug THEN
			KernelLog.String("win opened: "); KernelLog.Int(glWin.win,0); KernelLog.Ln;
		END;
		IF glWin.win = 0 THEN
			Machine.Release( Machine.X11 );
			KernelLog.String(" could not create window");
			Close;
			RETURN;
		END;

		masks := Api.ExposureMask + Api.StructureNotifyMask;
		X11.SelectInput(glWin.display, glWin.win, masks );

 		res := Api.StoreName(glWin.display, glWin.win, "GLContext.Window");

		(*GL.glXWaitX(); *)
		(* X11.Sync(glWin.display,X11.True);*)

	 	(* create GL context *)
	 	(* GL_TRUE: Use direct rendering, GL_FLASE: use X server for rendering *)
	 	glWin.glctx := GL.glXCreateContext(glWin.display, glWin.visualInfoPtr, 0, GLC.GL_TRUE);
	 	IF glWin.glctx = NIL THEN
	 		Machine.Release( Machine.X11 );
			KernelLog.String(" could not create context");
			Close;
			RETURN;
		END;

  		IF debug THEN
			KernelLog.String("context1 created: "); KernelLog.Int(glWin.glctx,0); KernelLog.Ln;
		END;

	 	resb := GL.glXMakeCurrent(glWin.display, glWin.win, glWin.glctx);
	 	IF debug THEN
			KernelLog.String("glXMakeCurrent res= "); KernelLog.Int(res, 0); KernelLog.Ln;
	 	END;

	 	X11.Flush(glWin.display);
	 	GL.glXWaitX();
		Machine.Release( Machine.X11 );

		IF debug THEN KernelLog.String("GL.glXIsDirect(glWin.display, gglWin.lctx)= "); KernelLog.Boolean(GL.glXIsDirect(glWin.display, glWin.glctx)=1); KernelLog.Ln; END;

		NEW(buffer, w*h*4); (* create RGBA buffer for render operations *)
		Raster.InitMode(rastermode, Raster.srcCopy);

		(* after creating context, load OpenGL core functions *)
	(*	GL.ReadOpenGLCore(); *)
	END Init;

	(* create a new opengl context with opengl version major, minor *)
	PROCEDURE SetProfile*(major, minor: LONGINT; flags: SET): BOOLEAN;
	VAR
		elemc,  i: LONGINT;
		resb: GL.Boolean;
		fbcfg: GL.XID; (*GLXFBConfigPtr;*)
		fbcfgPtr: GLXFBConfigPtr;
(*		str: Strings.String;*)
		attr: POINTER TO  ARRAY OF GL.Int;
		newctxt: GL.GLXContext;
	BEGIN
		Machine.Acquire( Machine.X11 );
	
		
		(* We need this for OpenGL3 *)
		fbcfg := GL.glXChooseFBConfig(glWin.display, 0, 0, elemc);
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
		i := 0;
		attr[i] := GLC.GLX_CONTEXT_MAJOR_VERSION_ARB; INC(i);
		attr[i] := major; INC(i);
		attr[i] := GLC.GLX_CONTEXT_MINOR_VERSION_ARB; INC(i);
		attr[i]:=minor; INC(i);
    
(*		 attr[i] := GLC.GLX_CONTEXT_FLAGS_ARB; INC(i);
			 attr[i] := GLC.GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB; INC(i);
   
   
		attr[i] := GLC.GLX_CONTEXT_PROFILE_MASK_ARB; INC(i);
	(*		attr[i] := GLC.GLX_CONTEXT_CORE_PROFILE_BIT_ARB; INC(i) *)		
			attr[i] := GLC.GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB; INC(i);

*)  
		attr[i] := 0; (* end of attribute list *)
		
		IF GL.glXCreateContextAttribsARB = NIL THEN
			Machine.Release( Machine.X11 );
			KernelLog.String("OpenGL 3.0 context is not supported");
			KernelLog.Ln;
			RETURN FALSE
		END;
		
		newctxt := GL.glXCreateContextAttribsARB(glWin.display, SYSTEM.VAL(LONGINT, fbcfgPtr[0]), 0, X11.True, ADDRESSOF(attr[0]));
		IF newctxt = NIL THEN 
			Machine.Release( Machine.X11 );
			IF debug THEN
				KernelLog.String("could not create OpenGL Context for OpenGL.3.0 "); KernelLog.Int(major, 0); KernelLog.Char("."); KernelLog.Int(minor, 0); 
				KernelLog.String(" context"); KernelLog.Ln; 
			END;
			RETURN FALSE;
		END;
		resb := GL.glXMakeCurrent(glWin.display, glWin.win, newctxt);
		IF debug THEN 
			KernelLog.String(" OpenGL3.0 MakeCurrent:"); KernelLog.Boolean(resb=1); KernelLog.Ln;
			KernelLog.String("new context created: "); KernelLog.Int(newctxt ,0); KernelLog.Ln;
		END;
				
		IF glWin.glctx # NIL THEN
			(* Release the context *)
		    	resb := GL.glXMakeCurrent(glWin.display, 0, 0);
		    	(* Delete the context *)
			GL.glXDestroyContext(glWin.display, glWin.glctx);
			IF debug THEN KernelLog.String("old context deleted"); KernelLog.Ln; END;
		END;
				
	
		

				
		glWin.glctx := newctxt;

		
		GL.ReadOpenGLCore();
		
(*		str := GL.GetString(GLC.GL_VENDOR); 
		KernelLog.String(" Vendor: "); KernelLog.String(str^); KernelLog.Ln;

		str := GL.GetString(GLC.GL_RENDERER); 
		KernelLog.String(" Renderer: "); KernelLog.String(str^); KernelLog.Ln;
	
		str := GL.GetString(GLC.GL_VERSION); 
		KernelLog.String(" Version: "); KernelLog.String(str^); KernelLog.Ln;
*)
		X11.Free(fbcfg);	
		Machine.Release( Machine.X11 );	
  		RETURN TRUE;
	END SetProfile;

	PROCEDURE Close*;
	VAR resb: GL.Boolean;
		  res: LONGINT;
	BEGIN
		Machine.Acquire( Machine.X11 );
		GL.glXWaitX();
		X11.Sync(glWin.display,X11.False);

		(* do we have a rendering context *)
		IF glWin.glctx # 0 THEN
			(* Release the context *)
		    	resb := GL.glXMakeCurrent(glWin.display, 0, 0);
		    	(* Delete the context *)
			GL.glXDestroyContext(glWin.display, glWin.glctx);
			IF debug THEN KernelLog.String("context deleted"); KernelLog.Ln; END;
		END;

		(* do we have a window *)
		IF glWin.win # 0 THEN
			(* Unmap the window*)
			Api.UnmapWindow(glWin.display, glWin.win);
			(* Destroy the window *)
			res:= Api.DestroyWindow(glWin.display, glWin.win);
			IF debug THEN KernelLog.String("window deleted"); KernelLog.Ln; END;
		END;

		(* do we have a display *)
		IF glWin.display # 0 THEN
			 res := Api.CloseDisplay(glWin.display);
			IF debug THEN KernelLog.String("display deleted"); KernelLog.Ln; END;
		END;

		Machine.Release( Machine.X11 );
 	END Close;

	PROCEDURE GetWidth*(): LONGINT;
	BEGIN
		RETURN glWin.width;
	END GetWidth;

	PROCEDURE GetHeight*(): LONGINT;
	BEGIN
		RETURN glWin.height;
	END GetHeight;

	PROCEDURE GetDisplay*(): LONGINT;
	BEGIN
		RETURN glWin.display;
	END GetDisplay;

	PROCEDURE GetContext*(): LONGINT;
	BEGIN
		RETURN glWin.glctx;
	END GetContext;

	PROCEDURE GetScreen*(): LONGINT;
	BEGIN
		RETURN 0; (*context.glWin.screen*)
	END GetScreen;

	(** move the window to x,y and  resize width,height *)
	PROCEDURE MoveResizeWindow(left0, top0, w, h: LONGINT);
	BEGIN
		X11.MoveResizeWindow(glWin.display, glWin.win, left0, top0, ABS(w) ,ABS(h));
	END MoveResizeWindow;

	PROCEDURE Resize*(w, h: LONGINT);
	BEGIN
		buffer := NIL;
		NEW(buffer, w*h*4);
		MoveResizeWindow(0,0, w, h);
		glWin.width := w; glWin.height := h;
	END Resize;

	PROCEDURE MakeCurrent*();
	 VAR resb: GL.Boolean;
	 BEGIN
		Machine.Acquire( Machine.X11 );
(*		GL.glXWaitX();
		X11.Sync(glWin.display,X11.False);
*)
		resb := GL.glXMakeCurrent(glWin.display, glWin.win, glWin.glctx);
		 IF debug THEN KernelLog.String(" MakeCurrent:"); KernelLog.Boolean(resb=1); KernelLog.Ln; END;

 		Machine.Release( Machine.X11 );
	END MakeCurrent;

	PROCEDURE DeActivate*();
 	VAR res: GL.Boolean;
 	BEGIN
		Machine.Acquire( Machine.X11 );
(*		GL.glXWaitX();
		X11.Sync(glWin.display,X11.False);
*)
		res := GL.glXMakeCurrent(glWin.display, 0, 0);
		IF debug THEN KernelLog.String(" DeActivate:"); KernelLog.Boolean(res=1); KernelLog.Ln; END;
		Machine.Release( Machine.X11 );
	END DeActivate;

	PROCEDURE RenderInto*(image: Raster.Image);
	VAR
		i: LONGINT;
		w, h: LONGINT;
	BEGIN (*{EXCLUSIVE}*)
		IF (image = NIL) OR (image.adr = NIL) THEN RETURN END;
		w := image.width;
		h := image.height;
		Machine.Acquire( Machine.X11 );
(*		GL.glXWaitX();
		X11.Sync(glWin.display,X11.False);*)
		GL.ReadPixels(0, 0, w, h, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, ADDRESSOF(buffer^[0]));
		Machine.Release( Machine.X11 );

		(* flip vertical, y *)
		FOR i := 0 TO h - 1 DO
			Raster.PutPixels(image, 0, h-1-i, w, Raster.BGRA8888, buffer^, i * w * 4, rastermode)
		END
	END RenderInto;

	PROCEDURE SwapBuffers*;
	 BEGIN
		Machine.Acquire( Machine.X11 );
		IF doublebuffered THEN
			GL.glXSwapBuffers(glWin.display, glWin.win);
		ELSE
	 		GL.Flush();
		END;
 		Machine.Release( Machine.X11 );
	END SwapBuffers;

BEGIN
END Context;

BEGIN
END GLContext.

SystemTools.Free GLContext ~
