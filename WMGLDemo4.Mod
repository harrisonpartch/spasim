MODULE WMGLDemo4; (** AUTHOR "fnecati"; PURPOSE "opengl triangle using vertex arrays"; *)

IMPORT
	WMRectangles, Strings, Kernel, KernelLog, Modules,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL := WMGLWindow;

CONST waittime=20;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	Vertex=RECORD
		x, y, z: REAL;	(* vertex *)
		nx, ny, nz: REAL; (* normal *)
		s0, t0: REAL; (* Texcoord0 *)
	END;

	MyVertex = POINTER TO ARRAY OF Vertex;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		timer: Kernel.MilliTimer;
		alive,  animated: BOOLEAN;

		angle: REAL;
		drawMode: LONGINT;
		vertexVBOID, indexVBOID, vaoID: GL.Uint;
		pindices : ARRAY [3] OF INTEGER;
		pvertex : MyVertex;
	 	lookatz: LONGREAL;

		PROCEDURE &New(w, h: LONGINT);
		BEGIN

			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			manager := WM.GetDefaultManager();
			WM.DefaultAddWindow(SELF);
			SetTitle(Strings.NewString("WMGLDemo4: VertexArrays"));

			lookatz := 3.0;
			angle := 0.0;
			drawMode:= 0;
			animated := FALSE;
			alive := TRUE;
			IF ~ initGL() THEN Close; END;
			DrawMode(0);
			UpdateImage;
			IncCount
		END New;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			CASE CHR(ucs) OF
				"a", "A": BEGIN {EXCLUSIVE} animated := ~ animated; END;
				| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
				| "-" : angle := angle - 1.0; UpdateImage;
				| "+" : angle := angle + 1.0; UpdateImage;
				| "q" : Close;
			ELSE

			END;
		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			lookatz := lookatz + dz;
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

		(** *)
		PROCEDURE DeleteBuffers;
		BEGIN
			MakeCurrent();
				GL.DeleteBuffersARB(1, ADDRESSOF(vertexVBOID));
				GL.DeleteBuffersARB(1, ADDRESSOF(indexVBOID));
				GL.DeleteBuffersARB(1, ADDRESSOF(vaoID));
			DeActivate();
		END DeleteBuffers;

		PROCEDURE Close;
		BEGIN
			BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE END;
			DeleteBuffers;
			Close^;
			DecCount
		END Close;


		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				displayCB;
				SwapGLBuffer();
			DeActivate();
			Swap();
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

	PROCEDURE DrawMode(dm: LONGINT);
	VAR drawMode: LONGINT;
	BEGIN
		drawMode := dm;
		MakeCurrent();
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

	PROCEDURE initGL(): BOOLEAN;
	VAR offset: LONGINT;
	BEGIN
			MakeCurrent();

			GL.ReadImplementationProperties;

		IF ~ (GL.GL_ARB_vertex_buffer_object & GL.GL_ARB_vertex_array_object) THEN
			KernelLog.String("GL_ARB_vertex_buffer_object and GL_ARB_vertex_array_object extesions are not supported" ); KernelLog.Ln;
			RETURN FALSE;
		END;

		GL.Read_GL_ARB_vertex_buffer_object(); (* read these extensions *)
		GL.Read_GL_ARB_vertex_array_object();

		NEW(pvertex,3);
		(* VERTEX 0 *)
		pvertex[0].x := 0.0;
		pvertex[0].y := 0.0;
		pvertex[0].z := 0.0;
		pvertex[0].nx := 0.0;
		pvertex[0].ny := 0.0;
		pvertex[0].nz := 1.0;
		pvertex[0].s0 := 0.0;
		pvertex[0].t0 := 0.0;
		(* VERTEX 1*)
		pvertex[1].x := 1.0;
		pvertex[1].y := 0.0;
		pvertex[1].z := 0.0;
		pvertex[1].nx := 0.0;
		pvertex[1].ny := 0.0;
		pvertex[1].nz := 1.0;
		pvertex[1].s0 := 1.0;
		pvertex[1].t0 := 0.0;
		(* VERTEX 2 *)
		pvertex[2].x := 0.0;
		pvertex[2].y := 1.0;
		pvertex[2].z := 0.0;
		pvertex[2].nx := 0.0;
		pvertex[2].ny := 0.0;
		pvertex[2].nz := 1.0;
		pvertex[2].s0 := 0.0;
		pvertex[2].t0 := 1.0;

		pindices[0] := 0;  pindices[1] := 1; pindices[2] := 2;


		GL.ClearColor(0.9, 0.9, 0.9, 1.0);
		GL.Color3f(0.2, 0.8, 0.5);

		GL.GenVertexArrays(1, ADDRESSOF(vaoID));
		GL.BindVertexArray(vaoID);
		GL.GenBuffers(1, ADDRESSOF(vertexVBOID));
		GL.BindBuffer(GLC.GL_ARRAY_BUFFER, vertexVBOID);
		GL.BufferData(GLC.GL_ARRAY_BUFFER, LEN(pvertex,0)*8*4, ADDRESSOF(pvertex[0].x), GLC.GL_STATIC_DRAW);

		GL.EnableVertexAttribArray(0);
		offset := 0;
		GL.VertexAttribPointer(0, 3, GLC.GL_FLOAT, GLC.GL_FALSE, 8*4, offset);

		GL.EnableVertexAttribArray(1);
		offset := 12;
		GL.VertexAttribPointer(1, 3, GLC.GL_FLOAT, GLC.GL_FALSE, 8*4, offset);

		GL.GenBuffers(1, ADDRESSOF(indexVBOID));
		GL.BindBuffer(GLC.GL_ELEMENT_ARRAY_BUFFER, indexVBOID);
		GL.BufferData(GLC.GL_ELEMENT_ARRAY_BUFFER, 3*2, ADDRESSOF(pindices[0]), GLC.GL_STATIC_DRAW);

		DeActivate();
		RETURN TRUE;
	END initGL;

	PROCEDURE displayCB();
	BEGIN
		(* clear buffer *)
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );
		GL.PushMatrix();

			GL.Rotatef(angle, 0.0, 0.0, 1.0);

		(*The starting point of the IBO *)
		GL.DrawElements(GLC.GL_TRIANGLES, 3, GLC.GL_UNSIGNED_SHORT, 0);
		GL.PopMatrix();
	END displayCB;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		MakeCurrent();
		GL.Viewport(0 , 0, w, h);

			GL.MatrixMode(GLC.GL_PROJECTION);
			GL.LoadIdentity();
			GLU.Perspective(45.0, 1.0, 0.1, 100.0);

			GL.MatrixMode(GLC.GL_MODELVIEW);
			GL.LoadIdentity();
			GLU.LookAt(0.0, 0.0, lookatz,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0); (* eye(x,y,z), focal(x,y,z), up(x,y,z) *)

		DeActivate();
	END Reshape;

BEGIN  {ACTIVE}
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		 IF Kernel.Expired(timer) THEN
		 	 UpdateImage();
		 	  angle := angle + 1.0;
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
END WMGLDemo4.

System.Free  WMGLDemo4   ~

WMGLDemo4.Open ~
