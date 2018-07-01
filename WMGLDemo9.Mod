MODULE WMGLDemo9; (** AUTHOR "fnecati"; PURPOSE "a demo using opengl Frame Buffer Object FBO and texture "; *)

IMPORT
	WMRectangles, WMGraphics, Strings, Kernel, Raster, Inputs, Modules, KernelLog,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL := WMGLWindow;

CONST
		waittime=20;
		renderBufferWidth = 256;
		renderBufferHeight = 256;
TYPE
	Str256 = ARRAY 256 OF CHAR;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	Vector = ARRAY [*] OF REAL;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		 timer: Kernel.MilliTimer;

		alive, animated: BOOLEAN;
		eyeposz: LONGREAL;
		drawMode:LONGINT; (* fill, lines, points *)

		spinXL, spinYL, spinXR, spinYR : REAL;
		testTextureID, dynamicTextureID: GL.Uint;
		frameBuffer, depthRenderBuffer: GL.Uint;

		cubeVertices: Vector;
		(*cubeVertices: VertexArray;*)

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);
			SetTitle(Strings.NewString("WMGLDemo9: FBO"));
			IncCount;
			eyeposz := 1.0;
			drawMode := 0;
			animated := FALSE;
			alive := TRUE;
			IF ~initGL() THEN Close END;
			UpdateImage;

		  END New;

		PROCEDURE InitVertex;
		BEGIN
			 cubeVertices :=
			   [ 0.0,0.0, -1.0,-1.0, 1.0,
			    1.0,0.0,  1.0,-1.0, 1.0,
			    1.0,1.0,  1.0, 1.0, 1.0,
			    0.0,1.0, -1.0, 1.0, 1.0,

			    1.0,0.0, -1.0,-1.0,-1.0,
			    1.0,1.0, -1.0, 1.0,-1.0,
			    0.0,1.0,  1.0, 1.0,-1.0,
			    0.0,0.0,  1.0,-1.0,-1.0,

			    0.0,1.0, -1.0, 1.0,-1.0,
			    0.0,0.0, -1.0, 1.0, 1.0,
			    1.0,0.0,  1.0, 1.0, 1.0,
			    1.0,1.0,  1.0, 1.0,-1.0,

			    1.0,1.0, -1.0,-1.0,-1.0,
			    0.0,1.0,  1.0,-1.0,-1.0,
			    0.0,0.0,  1.0,-1.0, 1.0,
			    1.0,0.0, -1.0,-1.0, 1.0,

			    1.0,0.0,  1.0,-1.0,-1.0,
			    1.0,1.0,  1.0, 1.0,-1.0,
			    0.0,1.0,  1.0, 1.0, 1.0,
			    0.0,0.0,  1.0,-1.0, 1.0,

			    0.0,0.0, -1.0,-1.0,-1.0,
			    1.0,0.0, -1.0,-1.0, 1.0,
			    1.0,1.0, -1.0, 1.0, 1.0,
			    0.0,1.0, -1.0, 1.0,-1.0];
			(*
			NEW(cubeVertices, 24);
			cubeVertices[0]:=NewVertex( 0.0,0.0, -1.0,-1.0, 1.0);
			cubeVertices[1]:=NewVertex( 1.0,0.0,  1.0,-1.0, 1.0);
			cubeVertices[2]:=NewVertex(1.0,1.0,  1.0, 1.0, 1.0);
			cubeVertices[3]:=NewVertex(0.0,1.0, -1.0, 1.0, 1.0);

			cubeVertices[4]:=NewVertex( 1.0,0.0, -1.0,-1.0,-1.0);
			cubeVertices[5]:=NewVertex( 1.0,1.0, -1.0, 1.0,-1.0);
			cubeVertices[6]:=NewVertex( 0.0,1.0,  1.0, 1.0,-1.0);
			cubeVertices[7]:=NewVertex(0.0,0.0,  1.0,-1.0,-1.0);

			cubeVertices[8]:=NewVertex(0.0,1.0, -1.0, 1.0,-1.0);
			cubeVertices[9]:=NewVertex( 0.0,0.0, -1.0, 1.0, 1.0);
			cubeVertices[10]:=NewVertex(1.0,0.0,  1.0, 1.0, 1.0);
			cubeVertices[11]:=NewVertex(1.0,1.0,  1.0, 1.0,-1.0);

			cubeVertices[12]:=NewVertex(  1.0,1.0, -1.0,-1.0,-1.0);
			cubeVertices[13]:=NewVertex(  0.0,1.0,  1.0,-1.0,-1.0);
			cubeVertices[14]:=NewVertex( 0.0,0.0,  1.0,-1.0, 1.0);
			cubeVertices[15]:=NewVertex( 1.0,0.0, -1.0,-1.0, 1.0);

			cubeVertices[16]:=NewVertex(1.0,0.0,  1.0,-1.0,-1.0);
			cubeVertices[17]:=NewVertex(1.0,1.0,  1.0, 1.0,-1.0);
			cubeVertices[18]:=NewVertex(0.0,1.0,  1.0, 1.0, 1.0);
			cubeVertices[19]:=NewVertex(0.0,0.0,  1.0,-1.0, 1.0);

			cubeVertices[20]:=NewVertex( 0.0,0.0, -1.0,-1.0,-1.0);
			cubeVertices[21]:=NewVertex( 1.0,0.0, -1.0,-1.0, 1.0);
			cubeVertices[22]:=NewVertex(1.0,1.0, -1.0, 1.0, 1.0);
			cubeVertices[23]:=NewVertex( 0.0,1.0, -1.0, 1.0,-1.0);
*)
		END InitVertex;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			IF  keysym = Inputs.KsLeft  THEN  spinXL := spinXL - 5.0;    UpdateImage; (* Cursor Left *)
			ELSIF keysym = Inputs.KsRight  THEN  spinXR := spinXR + 5.0;   UpdateImage; (* Cursor Right *)
			ELSIF keysym = Inputs.KsDown THEN  spinYL := spinYL - 5.0;   UpdateImage; (* Cursor Down *)
			ELSIF keysym = Inputs.KsUp THEN  spinYR := spinYR + 5.0;   UpdateImage; (* Cursor Up *)
			ELSIF  ucs = ORD("q") THEN Close;
			ELSIF  ucs = ORD("a") THEN BEGIN {EXCLUSIVE} animated := ~ animated; END;
			ELSE
			END;
		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			eyeposz := eyeposz + dz;
			Reshape(GetWidth(), GetHeight());
			UpdateImage;
		END WheelMove;

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Close;
		BEGIN
			BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE; END;
			CleanBuffers;
			Close^;
			DecCount
		END Close;

		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				displayCB();
				SwapGLBuffer();
			DeActivate();
			Swap();

			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

		PROCEDURE Reshape(w, h: LONGINT);
		BEGIN
			MakeCurrent();
			GL.Viewport(0, 0, w, h);
			GL.MatrixMode(GLC.GL_MODELVIEW);
			GL.LoadIdentity();
				GLU.LookAt(5, 5, eyeposz,   0, 0, 0,   0, 1, 0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *)
			  DeActivate();
		END Reshape;


PROCEDURE initGL(): BOOLEAN;
VAR strstatus: Str256;
	status : GL.Enum;
BEGIN

	MakeCurrent();
	GL.ReadImplementationProperties;

	IF ~GL.GL_EXT_framebuffer_object THEN
		KernelLog.String("GL_EXT_framebuffer_object is not supported"); KernelLog.Ln;
		RETURN FALSE;
	END;

	GL.Read_GL_EXT_framebuffer_object();

 	InitVertex;
 	spinXL := 30.0; spinYL := 30.0; spinXR := 0.0; spinYR := 0.0;

	GL.ClearColor( 0.0, 0.0, 1.0, 1.0 );
	GL.Enable(GLC.GL_TEXTURE_2D);
	GL.Enable(GLC.GL_DEPTH_TEST);

	GL.MatrixMode( GLC.GL_PROJECTION );
	GL.LoadIdentity();

	GLU.Perspective( 45.0, 1.0, 1.0, 100.0 );



	(* Create a frame-buffer object and a render-buffer object...*)


	GL.GenFramebuffersEXT( 1, ADDRESSOF(frameBuffer));
	GL.GenRenderbuffersEXT( 1, ADDRESSOF(depthRenderBuffer));

	(* Initialize the render-buffer for usage as a depth buffer.
	 We don't really need this to render things into the frame-buffer object,
	 but without it the geometry will not be sorted properly. *)
	GL.BindRenderbufferEXT( GLC.GL_RENDERBUFFER_EXT, depthRenderBuffer);
	GL.RenderbufferStorageEXT( GLC.GL_RENDERBUFFER_EXT, GLC.GL_DEPTH_COMPONENT24, renderBufferWidth, renderBufferHeight );


	(* Check for errors...*)

	status := GL.CheckFramebufferStatusEXT( GLC.GL_FRAMEBUFFER_EXT );
	IF status # GLC.GL_FRAMEBUFFER_COMPLETE_EXT THEN
		strstatus := FramebufferStatusToString(GL.CheckFramebufferStatusEXT(GLC.GL_FRAMEBUFFER_EXT));
		KernelLog.String("framebuffer completeness: "); KernelLog.String(strstatus);  KernelLog.Ln;
		RETURN FALSE;
	END;

	(* Now, create our dynamic texture. It doesn't actually get loaded with any
	 pixel data, but its texture ID becomes associated with the pixel data
	 contained in the frame-buffer object. This allows us to bind to this data
	 like we would any regular texture.
	*)



	GL.GenTextures( 1, ADDRESSOF(dynamicTextureID));

	GL.BindTexture( GLC.GL_TEXTURE_2D, dynamicTextureID );

	GL.TexImage2D( GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA8,
		          renderBufferWidth, renderBufferHeight,
		          0, GLC.GL_RGBA, GLC.GL_UNSIGNED_BYTE, 0 );

	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR );
	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR );

	(* Load a regular texture... *)


	loadTexture();
	DeActivate();
	RETURN TRUE;
END initGL;

PROCEDURE loadTexture;
VAR teximg: Raster.Image;
BEGIN
 teximg := WMGraphics.LoadImage("WMIcons.tar://WMKernelLog.png", FALSE);
IF teximg # NIL THEN

	GL.GenTextures( 1, ADDRESSOF(testTextureID) );
	GL.BindTexture(GLC.GL_TEXTURE_2D, testTextureID);

	GL.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);
	GL.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);

	GL.TexImage2D( GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA8, teximg.width, teximg.height, 0,
	GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, teximg.adr );
ELSE
 	KernelLog.String("teximg= NIL"); KernelLog.Ln;
END;

teximg := NIL;
END loadTexture;

PROCEDURE CleanBuffers;
BEGIN
MakeCurrent();
   GL.DeleteTextures( 1, ADDRESSOF(testTextureID) );
    GL.DeleteTextures( 1, ADDRESSOF(dynamicTextureID) );

	GL.DeleteFramebuffersEXT( 1, ADDRESSOF(frameBuffer) );
	GL.DeleteRenderbuffersEXT( 1, ADDRESSOF(depthRenderBuffer) );
DeActivate;
END CleanBuffers;

PROCEDURE displayCB();
BEGIN
	(*
	 Bind the frame-buffer object and attach to it a render-buffer object
	 set up as a depth-buffer.
	*)

	GL.BindFramebufferEXT( GLC.GL_FRAMEBUFFER_EXT, frameBuffer );
	(*glBindRenderbufferEXT( GLC.GL_RENDERBUFFER_EXT, depthRenderBuffer );*)
	GL.FramebufferTexture2DEXT( GLC.GL_FRAMEBUFFER_EXT, GLC.GL_COLOR_ATTACHMENT0_EXT, GLC.GL_TEXTURE_2D, dynamicTextureID, 0 );
	GL.FramebufferRenderbufferEXT( GLC.GL_FRAMEBUFFER_EXT, GLC.GL_DEPTH_ATTACHMENT_EXT, GLC.GL_RENDERBUFFER_EXT, depthRenderBuffer );

	(*
	 Set up the frame-buffer object just like you would set up a window.
	*)

	GL.Viewport( 0, 0, renderBufferWidth, renderBufferHeight );
	GL.ClearColor( 1.0, 0.0, 0.0, 1.0 );

	GL.Clear( GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );

	(*
	 Let the user spin the cube about with the right mouse button, so our
	 dynamic texture will show motion.
	*)

	GL.MatrixMode( GLC.GL_MODELVIEW );
	GL.LoadIdentity();
	GL.Translatef( 0.0, 0.0, -5.0 );
	GL.Rotatef( spinYR, 1.0, 0.0, 0.0 );
	GL.Rotatef( spinXR, 0.0, 1.0, 0.0 );

	(*
	 Now, render the cube to the frame-buffer object just like you we would
	 have done with a regular window.
	*)

	GL.BindTexture( GLC.GL_TEXTURE_2D, testTextureID );
	GL.InterleavedArrays( GLC.GL_T2F_V3F, 0, ADDRESSOF(cubeVertices[0]) );
	GL.DrawArrays( GLC.GL_QUADS, 0, 24 );


	(* Unbind the frame-buffer and render-buffer objects.*)


	GL.BindFramebufferEXT( GLC.GL_FRAMEBUFFER_EXT, 0 );
	 GL.BindRenderbufferEXT(GLC. GL_RENDERBUFFER_EXT, 0 );

	(* ------------------------------------------------
	 Now, set up the regular window for rendering...
	-------------------------------------------------- *)

	GL.Viewport( 0, 0, GetWidth(), GetHeight() );
	GL.ClearColor( 0.0, 0.0, 0.0, 1.0 );
	GL.Clear( GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );

	(*Let the user spin the cube about with the left mouse button.*)
	GL.MatrixMode( GLC.GL_MODELVIEW );
	GL.LoadIdentity();
	GL.Translatef( 0.0, 0.0, -5.0 );
	GL.Rotatef( spinYL, 1.0, 0.0, 0.0 );
	GL.Rotatef( spinXL, 0.0, 1.0, 0.0 );


    (* Finally, we'll use the dynamic texture like a regular static texture.*)

	GL.BindTexture( GLC.GL_TEXTURE_2D, dynamicTextureID );
	GL.InterleavedArrays( GLC.GL_T2F_V3F, 0, ADDRESSOF(cubeVertices[0]));
	GL.DrawArrays( GLC.GL_QUADS, 0, 24 );
END displayCB;


BEGIN  { ACTIVE }
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		IF Kernel.Expired(timer) THEN
			UpdateImage();
			spinXR := spinXR + 1.0;
			Kernel.SetTimer(timer, waittime);
		END;
	END;
END GLWindow;

VAR
	nofWindows : LONGINT;


PROCEDURE FramebufferStatusToString(status: GL.Enum): Str256;
VAR s: Str256;
BEGIN
	CASE status OF
	GLC.GL_FRAMEBUFFER_COMPLETE_EXT: s := "FRAMEBUFFER_COMPLETE_EXT:   8CD5H";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT: s :=  "FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:  8CD6H";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT: s := "FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:  8CD7H";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT: s := "FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:  8CD9H";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT: s := "FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:  8CDAH";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT: s := "FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:   8CDBH";
	| GLC.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT: s := "FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:  8CDCH";
	| GLC.GL_FRAMEBUFFER_UNSUPPORTED_EXT: s := "FRAMEBUFFER_UNSUPPORTED_EXT:  8CDDH";
	ELSE
		s := "UNKNOWN STATUS";
	END;
    RETURN s;
END FramebufferStatusToString;

PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, 256, 256);
END Open;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows)
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows)
END DecCount;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN {EXCLUSIVE}
	NEW(die);
	msg.ext := die;
	msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0)
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup)
END WMGLDemo9.

System.Free  WMGLDemo9  ~

WMGLDemo9.Open ~
