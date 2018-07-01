MODULE WMGLDemo1; (** AUTHOR "fnecati"; PURPOSE "a demo for Vertex Arrays, and lightining"; *)

IMPORT
	WMRectangles, Strings, Kernel, KernelLog, Modules,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL := WMGLWindow;

CONST waittime=50;
TYPE
	KillerMsg = OBJECT
	END KillerMsg;

TYPE
	GLWindow =  OBJECT(WMGL.Window)
	VAR
		timer: Kernel.MilliTimer;

		alive, animated: BOOLEAN;

		eyeposz: LONGREAL;
		drawMode:LONGINT; (* fill, lines, points *)
		light : BOOLEAN;
		angle: REAL;
		vboId, colorId, normalId : GL.Uint;     (* ID of VBO for vertex arrays*)
		lightKa, lightKd, lightKs, lightPos : ARRAY [4] OF GL.Float;
		vertices, normals, colors: ARRAY [*] OF REAL ;

	PROCEDURE &New(w, h: LONGINT);
	BEGIN
		Init(w, h, FALSE); (* use alpha, for 32bpp img *)
		WM.DefaultAddWindow(SELF);
		SetTitle(Strings.NewString("WMGLDemo1: VertexArrays + Light"));

		animated := FALSE;
		angle := 30.0;
		eyeposz := 1.0;
		drawMode := 0;
		light := TRUE;

		IF ~ initGL() THEN Close; RETURN END;
		Reshape(w, h);
		DrawMode(0);
		UpdateImage;
		alive := TRUE;
		IncCount
	END New;

	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	BEGIN
		CASE CHR(ucs) OF
			 "a", "A":  BEGIN{EXCLUSIVE} animated := ~ animated; END;
			| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
			| "l": light := ~ light;
					MakeCurrent();
					IF light THEN GL.Enable(GLC.GL_LIGHTING ); ELSE  GL.Disable(GLC.GL_LIGHTING ); END;
					DeActivate();
					UpdateImage;
			| "-" : angle := angle - 5.0; UpdateImage;
			| "+" : angle := angle+ 5.0; UpdateImage;
			| "q" : Close;
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
		BEGIN{EXCLUSIVE} alive := FALSE; animated := FALSE END;
		Close^;
		DecCount
	END Close;

	PROCEDURE UpdateImage;
	BEGIN
		MakeCurrent();
			displayCB();
		     SwapGLBuffer();
		DeActivate();
		Swap;
		 Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

	PROCEDURE Reshape(w,h: LONGINT);
	BEGIN
		MakeCurrent();
		GL.Viewport(0,0, w, h);

		GL.MatrixMode(GLC.GL_PROJECTION);
		GL.LoadIdentity();
		GLU.Perspective(45, 1, 1, 1000);

		GL.MatrixMode(GLC.GL_MODELVIEW);
		GL.LoadIdentity();
		GLU.LookAt(5, 5, eyeposz,   0, 0, 0,   0, 1, 0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *)

		  DeActivate();
	END Reshape;


	PROCEDURE initLights();
	BEGIN
		(* set up light colors (ambient, diffuse, specular) *)

		lightKa := [0.2, 0.2, 0.2, 1.0];  (* ambient light*)
		lightKd := [0.7, 0.7, 0.7, 1.0];  (* diffuse light *)
		lightKs := [1.0, 1.0, 1.0, 1.0];  (* specular light *)
		lightPos := [1.0, 1.0, 1.0, 0.0]; (* positional light *)

		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_AMBIENT, lightKa);
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_DIFFUSE, lightKd);
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_SPECULAR, lightKs);

		(* position the light*)
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, lightPos);

		GL.Enable(GLC.GL_LIGHT0);       (* MUST enable each light source after configuration*)
		GL.Enable(GLC.GL_LIGHTING);
	END initLights;

	PROCEDURE initGL(): BOOLEAN;
	BEGIN
		MakeCurrent();
		GL.ReadImplementationProperties;
		IF ~ GL.GL_ARB_vertex_buffer_object THEN
			KernelLog.String("GL_ARB_vertex_buffer_object extesion not supported" ); KernelLog.Ln;
			RETURN FALSE;
		END;

		GL.Read_GL_ARB_vertex_buffer_object(); (* read this extension *)


	(* cube
	    v6------ v5
	   /|             /|
	  v1------v0 |
	  | |            |  |
	  | |v7-----|-|v4
	  |/            | /
	  v2------v3
	*)

	(* vertex coords array*)
		 vertices := [1.0,1.0,1.0,  -1.0,1.0,1.0,  -1.0,-1.0, 1.0 ,  1.0,-1.0,1.0,        (* v0-v1-v2-v3 *)
	                      1.0,1.0,1.0,  1.0,-1.0,1.0,  1.0,-1.0,-1.0,  1.0,1.0,-1.0,        (* v0-v3-v4-v5 *)
	                      1.0,1.0,1.0,  1.0,1.0,-1.0,  -1.0,1.0,-1.0,  -1.0,1.0,1.0,        (* v0-v5-v6-v1*)
	                      -1.0,1.0,1.0,  -1.0,1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,-1.0,1.0,    (* v1-v6-v7-v2 *)
	                      -1.0,-1.0,-1.0,  1.0,-1.0,-1.0,  1.0,-1.0,1.0,  -1.0,-1.0,1.0,    (* v7-v4-v3-v2 *)
	                      1.0,-1.0,-1.0,  -1.0,-1.0,-1.0,  -1.0,1.0,-1.0,  1.0,1.0,-1.0];   (* v4-v7-v6-v5 *)

	(* normal array *)
		normals := [0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0 ,  0.0, 0.0, 1.0,             (* v0-v1-v2-v3 *)
	                     1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0, 1.0, 0.0, 0.0,              (* v0-v3-v4-v5 *)
	                     0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0, 0.0, 1.0, 0.0,              (* v0-v5-v6-v1*)
	                     -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,          (* v1-v6-v7-v2 *)
	                     0.0, -1.0, 0.0,  0.0, -1.0, 0.0,  0.0, -1.0, 0.0,  0.0, -1.0, 0.0,         (* v7-v4-v3-v2 *)
	                     0.0, 0.0, -1.0,  0.0, 0.0, -1.0,  0.0, 0.0, -1.0,  0.0, 0.0, -1.0];        (* v4-v7-v6-v5 *)

	(* color array *)
		 colors := [1.0,1.0,1.0,  1.0,1.0,0.0,  1.0,0.0,0.0,  1.0,0.0,1.0 ,              (* v0-v1-v2-v3 *)
	                    1.0,1.0,1.0,  1.0,0.0,1.0,  0.0,0.0,1.0,  0.0,1.0,1.0,              (* v0-v3-v4-v5 *)
	                    1.0,1.0,1.0,  0.0,1.0,1.0,  0.0,1.0,0.0,  1.0,1.0,0.0,              (* v0-v5-v6-v1 *)
	                    1.0,1.0,0.0,  0.0,1.0,0.0,  0.0,0.0,0.0,  1.0,0.0,0.0,              (* v1-v6-v7-v2 *)
	                    0.0,0.0,0.0,  0.0,0.0,1.0,  1.0,0.0,1.0,  1.0,0.0,0.0,              (* v7-v4-v3-v2 *)
	                    0.0,0.0,1.0,  0.0,0.0,0.0,  0.0,1.0,0.0,  0.0,1.0,1.0];             (* v4-v7-v6-v5 *)



		(* create buffers *)
		GL.GenBuffersARB(1, ADDRESSOF(vboId));
		GL.GenBuffersARB(1, ADDRESSOF(colorId));
		GL.GenBuffersARB(1, ADDRESSOF(normalId));

		GL.BindBufferARB(GLC.GL_ARRAY_BUFFER, vboId);
		GL.BufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(vertices,0)*4, ADDRESSOF(vertices[0]), GLC.GL_STATIC_DRAW);
		GL.VertexPointer(3, GLC.GL_FLOAT, 0, 0);

		GL.BindBufferARB(GLC.GL_ARRAY_BUFFER, colorId);
		GL.BufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(colors,0)*4, ADDRESSOF(colors[0]), GLC.GL_STATIC_DRAW);
		GL.ColorPointer(3, GLC.GL_FLOAT, 0, 0);

		GL.BindBufferARB(GLC.GL_ARRAY_BUFFER, normalId);
		GL.BufferDataARB(GLC.GL_ARRAY_BUFFER, LEN(normals,0)*4, ADDRESSOF(normals[0]), GLC.GL_STATIC_DRAW);
		GL.NormalPointer(GLC.GL_FLOAT, 0, 0);

		GL.ClearColor(0.2, 0.1, 0.4, 1.0);                   (*  background color *)
		GL.ClearStencil(0);                          (* clear stencil buffer *)
		GL.ClearDepth(1.0);                         (*  0 is near, 1 is far *)
		GL.DepthFunc(GLC.GL_LEQUAL);
		initLights();

		GL.ShadeModel(GLC.GL_SMOOTH);                    (* shading mathod: GL_SMOOTH or GL_FLAT*)
		GL.PixelStorei(GLC.GL_UNPACK_ALIGNMENT, 4);     (* 4-byte pixel alignment *)

		(* enable /disable features *)
		GL.Hint(GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST);
		(* GL.Hint(GLC.GL_LINE_SMOOTH_HINT, GLC.GL_NICEST);*)
		(* GL.Hint(GLC.GL_POLYGON_SMOOTH_HINT, GLC.GL_NICEST); *)
		GL.Enable(GLC.GL_DEPTH_TEST);
		GL.Enable(GLC.GL_LIGHTING);
		GL.Enable(GLC.GL_TEXTURE_2D);
		GL.Enable(GLC.GL_CULL_FACE);

		(* track material ambient and diffuse from surface color, call it before glEnable(GL_COLOR_MATERIAL) *)
		GL.ColorMaterial(GLC.GL_FRONT_AND_BACK, GLC.GL_AMBIENT_AND_DIFFUSE);
		GL.Enable(GLC.GL_COLOR_MATERIAL);

	(*	GL.MatrixMode(GLC.GL_PROJECTION);
		GL.LoadIdentity();
		GLU.Perspective(45, 1, 1, 1000);

		GL.MatrixMode(GLC.GL_MODELVIEW);
		GL.LoadIdentity();


			GLU.LookAt(5, 5, eyeposz,   0, 0, 0,   0, 1, 0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *)
		*)
		RETURN TRUE;
	END initGL;

	PROCEDURE DrawMode(dm: LONGINT);
	VAR drawMode: LONGINT;
	BEGIN
		MakeCurrent();

		drawMode := dm;
	        IF drawMode = 0 THEN       (* fill mode*)
	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
	            GL.Enable(GLC.GL_DEPTH_TEST);
	            GL.Enable(GLC.GL_CULL_FACE);
	        ELSIF drawMode = 1 THEN  (* wireframe mode *)
	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
	            GL.Disable(GLC.GL_DEPTH_TEST);
	            GL.Disable(GLC.GL_CULL_FACE);
	        ELSE                    (* point mode *)
	            GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
	            GL.Disable(GLC.GL_DEPTH_TEST);
	            GL.Disable(GLC.GL_CULL_FACE);
		  END;
		DeActivate();
	END DrawMode;

	PROCEDURE displayCB();
	BEGIN
		(* clear buffer *)
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );

		(* draw a cube using vertex array method *)
		(* notice that only difference between VBO and VA is binding buffers and offsets *)

		(* enable vertex arrays *)
		GL.EnableClientState(GLC.GL_VERTEX_ARRAY);
		GL.EnableClientState(GLC.GL_COLOR_ARRAY);
		GL.EnableClientState(GLC.GL_NORMAL_ARRAY);

		GL.PushMatrix();
			GL.Rotatef(angle, 0,0,1);
			GL.DrawArrays(GLC.GL_QUADS, 0, 24);
		GL.PopMatrix();

		GL.DisableClientState(GLC.GL_NORMAL_ARRAY);
		GL.DisableClientState(GLC.GL_COLOR_ARRAY);
		GL.DisableClientState(GLC.GL_VERTEX_ARRAY);  (* disable vertex arrays *)
	END displayCB;

BEGIN { ACTIVE }
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN{EXCLUSIVE} AWAIT(animated) END;
		 IF Kernel.Expired(timer) THEN
		 	 UpdateImage();
		 	  angle := angle + 5.0;
			Kernel.SetTimer(timer, waittime);
		END;
	END;
END GLWindow;

VAR
	nofWindows : LONGINT;

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
END WMGLDemo1.

System.Free  WMGLDemo1~

WMGLDemo1.Open ~
