MODULE WMGLSLBricks; (** AUTHOR "fnecati"; PURPOSE "opengl GLSL bricks shading example from OrangeBook"; *)

IMPORT
	WMRectangles, Strings,  Inputs, Modules,
	WM := WMWindowManager,  WMMessages, KernelLog,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL := WMGLWindow,
	GLLib, GLSUtil := GLShaderUtils;

TYPE

	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		color: LONGINT;

		(* Movement variables *)
		fXDiff,  fYDiff, fZDiff: REAL;
		xLastIncr, yLastIncr: LONGINT;
		fXInertia, fYInertia, fScale, ftime: REAL;
		xLast, yLast : LONGINT;
		rotate: BOOLEAN;
		RotL : REAL;

		brickProg: GL.Uint;  (* shader program *)

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);

			SetTitle(Strings.NewString("WMGLSLBricks: Bricks"));
			color := 0;

			fXDiff := 206;  fYDiff := 16; fZDiff := 10;
			xLastIncr := 0; yLastIncr := 0;
			fXInertia := -0.5; fYInertia := 0.0;
			fScale := 1.0; ftime := 0.0;
			xLast := -1; yLast := -1;

			rotate := TRUE;
			RotL := 1 * 3.14 / 180;

			IF ~initGL() THEN Close; RETURN; END;
			Reshape(w, h);
			UpdateImage;
			IncCount
		END New;

		PROCEDURE initGL(): BOOLEAN;
		BEGIN
			MakeCurrent();
				GL.DepthFunc(GLC.GL_LESS);
				GL.Enable(GLC.GL_DEPTH_TEST);

				GL.ReadImplementationProperties;

 				IF ~ (GL.GL_ARB_vertex_shader & GL.GL_ARB_fragment_shader) THEN
					KernelLog.String("GL_ARB_vertex_shader and GL_ARB_fragment_shader are not supported"); KernelLog.Ln;
					RETURN FALSE;
				END;

				GL.Read_GL_ARB_Shader_Objects();

				IF ~ InstallBrickShaders() THEN
					KernelLog.String("GLSLBrick shaders is not installed"); KernelLog.Ln;
					RETURN FALSE;
				END;
			DeActivate();
			RETURN TRUE;
		END initGL;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
		CASE CHR(ucs) OF
			| "b": NextClearColor(); UpdateImage;
			| "-" : fScale := fScale - 0.05; UpdateImage;
			| "+" :  fScale := fScale + 0.05; UpdateImage;
			| "q" : Close;
		ELSE
			CASE keysym OF
				Inputs.KsHome:  fXDiff := 0; fYDiff := 35; fZDiff := 0;
			            xLastIncr := 0; yLastIncr := 0; fXInertia := -0.5; fYInertia := 0;
			            fScale := 1.0; UpdateImage;
			|	Inputs.KsLeft : fXDiff := fXDiff - 1.0 ; UpdateImage;
			|	Inputs.KsRight: fXDiff := fXDiff + 1.0; UpdateImage;
			|	Inputs.KsUp: fYDiff := fYDiff - 1.0; UpdateImage;
			|	Inputs.KsDown: fYDiff := fYDiff + 1.0; UpdateImage;

			ELSE
			END;
		END;
		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			fScale := fScale + dz*0.5*0.2;
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
			Close^;
			DecCount
		END Close;

		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				Display();
			SwapGLBuffer();
			DeActivate();
			Swap();

			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

		PROCEDURE DrawCube();
		VAR size, scale, delta: REAL;
			A, B, C, D, E, F, G, H, I, K, L, M, N, O: ARRAY [3] OF REAL;
		BEGIN

			size := 1.0;  scale := 0.2; delta := 0.1;
			A := [ size,  size,  size * scale + delta ];
			B := [ size,  size, -size * scale + delta ];
			C := [ size, -size, -size * scale ];
			D := [ size, -size,  size * scale ];
			E := [-size,  size,  size * scale + delta ];
			F := [-size,  size, -size * scale + delta ];
			G := [-size, -size, -size * scale ];
			H := [-size, -size,  size * scale ];
			I := [ 1.0,  0.0,  0.0];
			K := [-1.0,  0.0,  0.0];
			L := [ 0.0,  0.0, -1.0];
			M := [ 0.0,  0.0,  1.0];
			N := [ 0.0,  1.0,  0.0];
			O := [ 0.0, -1.0,  0.0];


			GL.Begin(GLC.GL_QUADS);
				GL.Normal3fv(I);

				GL.TexCoord2f(1,1);
				GL.Vertex3fv(D);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(C);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(B);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(A);

				GL.Normal3fv(K);

				GL.TexCoord2f(1,1);
 				GL.Vertex3fv(G);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(H);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(E);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(F);

				GL.Normal3fv(L);

				GL.TexCoord2f(1,1);
				GL.Vertex3fv(C);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(G);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(F);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(B);

				GL.Normal3fv(M);

				GL.TexCoord2f(1,1);
				GL.Vertex3fv(H);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(D);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(A);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(E);

				GL.Normal3fv(N);

				GL.TexCoord2f(1,1);
				GL.Vertex3fv(E);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(A);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(B);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(F);

				GL.Normal3fv(O);

				GL.TexCoord2f(1,1);
				GL.Vertex3fv(G);
				GL.TexCoord2f(0,1);
				GL.Vertex3fv(C);
				GL.TexCoord2f(0,0);
				GL.Vertex3fv(D);
				GL.TexCoord2f(1,0);
				GL.Vertex3fv(H);

			GL.End();

		END DrawCube;

		PROCEDURE Display();
		BEGIN
			GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
			GL.LoadIdentity();

				GL.Translatef(0.0, 0.0, -5.0);
				GL.Rotatef(fYDiff, 1,0,0);
				GL.Rotatef(fXDiff, 0,1,0);
				GL.Rotatef(fZDiff, 0,0,1);
				GL.Scalef(fScale, fScale, fScale);

			(*GL.UseProgram(brickProg);*)
			GL.Uniform3f(getUniLoc(brickProg, "MortarColor"), 0.85, 0.86, 0.84);
			GL.Uniform3f(getUniLoc(brickProg, "LightPosition"), 0.0, 0.0, 4.0);
			DrawCube();


			GL.LoadIdentity();

				GL.Translatef(0.0, 0.0, -5.0);
				GL.Rotatef(fYDiff, 1,0,0);
				GL.Rotatef(fXDiff + 90.0, 0,1,0);
				GL.Rotatef(fZDiff, 0,0,1);
				GL.Scalef(fScale, fScale, fScale);

			GL.Uniform3f(getUniLoc(brickProg, "MortarColor"), 0.1, 1.0, 0.2);
			GL.Uniform3f(getUniLoc(brickProg, "LightPosition"), 2.0, 0.0, 2.0);
			GLLib.SolidTeapot(0.8);
(*			GLLib.SolidSphere(0.8, 50,40); *)
(*			GLLib.SolidDodecahedron;*)
			GLLib.SolidTorus(0.2, 0.9, 10, 40);

		END Display;

		PROCEDURE NextClearColor ();
		BEGIN
			MakeCurrent();
			INC(color);
			CASE color OF
			0:  GL.ClearColor(0.0, 0.0, 0.0, 1.0);
			|1:  GL.ClearColor(0.2, 0.2, 0.3, 1.0);
			ELSE
				GL.ClearColor(0.7, 0.7, 0.7, 1.0);
				color := 0;
			END;
			DeActivate();
		END NextClearColor;

		PROCEDURE Reshape(w,  h: LONGINT);
		BEGIN
			MakeCurrent;

			GL.Viewport(0, 0, w, h);
			GL.MatrixMode(GLC.GL_PROJECTION);
			GL.LoadIdentity();
			GLU.Perspective(45, 1, 0.1, 100);

			GL.MatrixMode(GLC.GL_MODELVIEW);
			GL.LoadIdentity();
			GL.Translatef(0.0, 0.0, -5.0);
			DeActivate();
		END Reshape;

		(* Get the location of a uniform variable *)
		PROCEDURE getUniLoc(program: GL.Uint; CONST name: ARRAY OF CHAR): GL.Int;
		VAR loc: GL.Int;
		BEGIN
			loc := GL.GetUniformLocation(program, name);
			IF loc = -1 THEN
				KernelLog.String("No such uniform named "); KernelLog.String(name); KernelLog.Ln;
    			END;
    			GLSUtil.PrintOpenGLError("getUniloc: ");  (* Check for OpenGL errors *)
			RETURN loc;
		END getUniLoc;

		PROCEDURE InstallBrickShaders(): BOOLEAN;

		BEGIN
		    (* Create a vertex shader object and a fragment shader object,
		    	install program object as part of current state *)
			brickProg :=  GLSUtil.LoadShadersFromFile("opengloberon/brick.vert", "opengloberon/brick.frag" );
			IF brickProg = 0 THEN
				KernelLog.String("LoadShader Error"); KernelLog.Ln;
				RETURN FALSE;
			END;

			GL.UseProgram(brickProg);

    			(* Set up initial uniform values *)
    			GL.Uniform3f(getUniLoc(brickProg, "BrickColor"), 1.0, 0.3, 0.2);
    			GL.Uniform3f(getUniLoc(brickProg, "MortarColor"), 0.85, 0.86, 0.84);
    			GL.Uniform2f(getUniLoc(brickProg, "BrickSize"), 0.30, 0.15);
    			GL.Uniform2f(getUniLoc(brickProg, "BrickPct"), 0.90, 0.85);
    			GL.Uniform3f(getUniLoc(brickProg, "LightPosition"), 0.0, 0.0, 4.0);

    			RETURN TRUE;
		END InstallBrickShaders;

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
END WMGLSLBricks.

System.Free  WMGLSLBricks ~

WMGLSLBricks.Open ~

System.FreeDownTo OpenGL ~

