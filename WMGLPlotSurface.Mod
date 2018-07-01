MODULE WMGLPlotSurface; (** AUTHOR "fnecati"; PURPOSE "a test for 3D function plotting with light"; *)

IMPORT
	WMRectangles, Strings, Math:=MathL, Inputs, Modules,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL := WMGLWindow;

CONST
	Nx = 50; (* number of samples in X, Y directions *)
	Ny = 50;
	Ymin = -1.0; Xmin = -1.0;
	Ymax = 1.0;  Xmax = 1.0;
	dx = (Xmax - Xmin)/Nx;
	dy = (Ymax - Ymin)/Ny;

	(* Angle to rotate when the user presses an arrow key *)
	angle = 5.0;

	(* Amount to scale when the user presses PgUp or PgDn *)
	scalefactor = 0.8;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	TVector3d = ARRAY [3] OF LONGREAL;

	GLWindow =  OBJECT(WMGL.Window)
	VAR

		ambientLight,  diffuseLight, specularLight,
		(* Position the light somewhere close over the top of the figure*)
	  	position: ARRAY [4] OF GL.Float;
		drawMode: LONGINT;
		funcplane: GL.Uint;

	PROCEDURE &New(w, h: LONGINT);
	BEGIN
		Init(w, h, FALSE); (* use alpha, for 32bpp img *)
		WM.DefaultAddWindow(SELF);
		SetTitle(Strings.NewString("WMGLPlotSurface: Sinc Function "));

		initGL;
		Reshape(w, h);
		UpdateImage;
		IncCount
	END New;


	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	BEGIN
		CASE CHR(ucs) OF
			 "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
			| "q" :		Close;
		ELSE

			IF  keysym = Inputs.KsLeft  THEN   MakeCurrent();  GL.Rotated ( angle, 0.0, 0.0, 1.0 ) ;   DeActivate(); UpdateImage; (* Cursor Left *)
			ELSIF keysym = Inputs.KsRight THEN  MakeCurrent();  GL.Rotated ( -angle, 0.0, 0.0, 1.0 ) ;   DeActivate(); UpdateImage; (* Cursor Right *)
			ELSIF keysym = Inputs.KsDown THEN  MakeCurrent();  GL.Rotated ( -angle, 0.0, 1.0, 0.0 );   DeActivate(); UpdateImage; (* Cursor Down *)
			ELSIF keysym = Inputs.KsUp THEN   MakeCurrent();  GL.Rotated ( angle, 0.0, 1.0, 0.0 );   DeActivate(); UpdateImage; (* Cursor Up *)
			ELSIF keysym = Inputs.KsPageDown THEN   MakeCurrent(); GL.Scaled ( scalefactor, scalefactor, scalefactor ) ;   DeActivate(); UpdateImage;  (* Page Down *)
			ELSIF keysym = Inputs.KsPageUp THEN  MakeCurrent();  GL.Scaled ( 1.0 / scalefactor, 1.0 / scalefactor, 1.0 / scalefactor ) ;   DeActivate(); UpdateImage; (* Page Up *)
			ELSE
			END;
		END;
	END KeyEvent;

	PROCEDURE WheelMove(dz : LONGINT);
	BEGIN
		IF dz < 0 THEN
			MakeCurrent();
			  GL.Scaled ( scalefactor, scalefactor, scalefactor ) ;
			DeActivate();
			UpdateImage;
		ELSE
			MakeCurrent();
			  GL.Scaled ( 1.0 / scalefactor, 1.0 / scalefactor, 1.0 / scalefactor ) ;
			 DeActivate();
			 UpdateImage;
		END;
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
			Display;
		SwapGLBuffer();
		DeActivate();
		Swap();
		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

	(* from W3dVectors.Mod *)
	PROCEDURE Cross(CONST a, b: TVector3d): TVector3d;
	VAR result : TVector3d;
	BEGIN
		result[0]:=a[1]*b[2]-a[2]*b[1];
		result[1]:=a[2]*b[0]-a[0]*b[2];
		result[2]:=a[0]*b[1]-a[1]*b[0];
		RETURN result
	END Cross;

	PROCEDURE Sqr(x: LONGREAL):LONGREAL;
	BEGIN
		RETURN x * x
	END Sqr;

	PROCEDURE VLength3(CONST a0: TVector3d):LONGREAL;
	VAR t: LONGREAL;
		a: TVector3d;
	BEGIN
		a := a0;
		a[0] := ABS(a[0]); a[1]:= ABS(a[1]); a[2]:=ABS(a[2]);
		IF a[0] > a[1] THEN t := a[0]; a[0] := a[1]; a[1]:=t END;
		IF a[1] > a[2] THEN t := a[1]; a[1] := a[2]; a[2]:=t END;
		(* a.z >= a.y, a.z >= a.x *)
		IF a[2] = 0 THEN RETURN 0
		ELSE RETURN a[2] * Math.sqrt(1 + Sqr(a[0]/a[2]) + Sqr(a[1]/a[2]))
		END
	END VLength3;

	PROCEDURE VScaled3(CONST a: TVector3d; factor: LONGREAL):TVector3d;
	VAR result : TVector3d;
	BEGIN
	       result := factor*a;
		RETURN result
	END VScaled3;

	PROCEDURE VNormed3(CONST a: TVector3d):TVector3d;
	BEGIN
		RETURN VScaled3(a, 1/VLength3(a))
	END VNormed3;


(*	PROCEDURE MyFunc ( x, y: LONGREAL): LONGREAL;
	VAR z: LONGREAL;
	BEGIN
		 z := 2*Math.exp(- (x*x + y*y));
		 RETURN z;
	END MyFunc;

*)
	PROCEDURE MyFunc ( x, y: LONGREAL): LONGREAL;
	VAR z, r: LONGREAL;
	BEGIN
		r :=10* (x*x + y*y);
		IF r # 0.0  THEN
			z := Math.sin(r)/r;
		ELSE
			z := 1.0;
		END;
		RETURN z;
	END MyFunc;

	PROCEDURE Grid;
	VAR x: LONGREAL;
	BEGIN
		GL.LineWidth(1.0);
		GL.Color3d(1.0,1.0,1.0);
		GL.Begin(GLC.GL_LINES);
		x := -1.2;
		WHILE x <=1.2 DO

			GL.Vertex3d(-1.0, 0.0, x);
			GL.Vertex3d(1.0, 0.0, x);
			GL.Vertex3d(x, 0.0,-1.0);
			GL.Vertex3d(x, 0.0, 1.0);

			x := x + 0.2;
		END;
		GL.End();
	END Grid;
(*
	PROCEDURE render;
	VAR i, j: LONGINT;
		x, y: LONGREAL;
	BEGIN
		FOR i:=0 TO Nx-1 DO
			FOR j:=0 TO Ny-1 DO
				x := Xmin + i*dx;
				y := Ymin + j*dy;
				GL.Begin (GLC.GL_QUADS);
					GL.Vertex3d(x, MyFunc(x,y), y);
					GL.Vertex3d(x+dx, MyFunc(x+dx, y), y);
					GL.Vertex3d(x+dx, MyFunc(x+dx,y+dy), y+dy);
					GL.Vertex3d(x, MyFunc(x,y+dy), y+dy);
				GL.End();
			END;
		END;
	END render;
*)
	PROCEDURE render;
	VAR i, j: LONGINT;
		x, y: LONGREAL;
		p1, p2, p3, norm, v1, v2: TVector3d;
	BEGIN
		FOR i:=0 TO Nx-1 DO
			FOR j:=0 TO Ny-1 DO
				x := Xmin + i*dx;
				y := Ymin + j*dy;
				GL.Begin (GLC.GL_TRIANGLES);
					p1[0] := x;  p1[1] := MyFunc(x,y); p1[2] := y;
					p2[0] := x+dx;  p2[1] := MyFunc(x+dx, y); p2[2] := y;
					p3[0] := x; p3[1] := MyFunc(x,y+dy); p3[2] := y + dy;
					v1 := p2-p1; v2 := p3-p1;
					norm := VNormed3(Cross(v1, v2));
					GL.Normal3d(norm[0], norm[1], norm[2]);
					GL.Vertex3d(p1[0], p1[1], p1[2]);
					GL.Vertex3d(p2[0], p2[1], p2[2]);
					GL.Vertex3d(p3[0], p3[1], p3[2]);


					p1[0] := x+dx;  p1[1] := MyFunc(x+dx,y); p1[2] := y;
					p2[0] := x+dx;  p2[1] := MyFunc(x+dx, y+dy); p2[2] := y+dy;
					p3[0] := x; p3[1] := MyFunc(x,y+dy); p3[2] := y + dy;
					v1 := p2-p1; v2 := p3-p1;
					norm := VNormed3(Cross(v1, v2));
					GL.Normal3d(norm[0], norm[1], norm[2]);
					GL.Vertex3d(p1[0], p1[1], p1[2]);
					GL.Vertex3d(p2[0], p2[1], p2[2]);
					GL.Vertex3d(p3[0], p3[1], p3[2]);
				GL.End();
			END;
		 END;
	END render;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		MakeCurrent();
		GL.Viewport (0, 0, w, h);

		GL.MatrixMode (GLC.GL_PROJECTION);
		GL.LoadIdentity ();
		GLU.Perspective (30, 1.0, 1.0, 100.0);

		GL.MatrixMode (GLC.GL_MODELVIEW);
		GL.LoadIdentity();
		GLU.LookAt (5.0, 5.0, 7.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0);
		DeActivate;
	END Reshape;

	PROCEDURE DrawMode(dm: LONGINT);
	VAR drawMode: LONGINT;
	BEGIN
		drawMode := dm;
		MakeCurrent();

		IF drawMode = 0 THEN       (* fill mode*)
			GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
			GL.Enable(GLC.GL_DEPTH_TEST);
			(*GL.Enable(GLC.GL_CULL_FACE);*)
		ELSIF drawMode = 1 THEN  (* wireframe mode *)
			GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
			GL.Disable(GLC.GL_DEPTH_TEST);
			(*GL.Disable(GLC.GL_CULL_FACE);*)
		ELSE                    (* point mode *)
			GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
			GL.Disable(GLC.GL_DEPTH_TEST);
			(*GL.Disable(GLC.GL_CULL_FACE);*)
		END;
		DeActivate();
	END DrawMode;

	PROCEDURE initGL;
	BEGIN
		MakeCurrent();

		(* Setup the lighting *)
		ambientLight := [1.0, 1.0, 1.0, 1.0];
		diffuseLight := [1.0, 0.9, 0.8, 1.0];
		specularLight := [ 0.0, 1.0,  0.0, 1.0];
		(* Position the light somewhere close over the top of the figure*)
		position := [1.0, 1.0, 1.0,  1.0];

		(* Call the actual options for light0 *)
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_AMBIENT, ambientLight);
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_DIFFUSE, diffuseLight);
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_SPECULAR, specularLight);
		GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, position);

		GL.Enable (GLC.GL_DEPTH_TEST);
		GL.Enable (GLC.GL_LIGHTING);
		GL.Enable (GLC.GL_LIGHT0);
		(* GL.ShadeModel (GLC.GL_FLAT);*)  (* can be GL_SMOOTH if you dont want to see edges *)
		GL.ShadeModel (GLC.GL_SMOOTH);
		(* GL.Enable(GLC.GL_CULL_FACE);*)
		GL.ClearColor (0.0,0.0,0.0,1.0);

		(* make the plane *)
		funcplane := GL.GenLists(1);
		GL.NewList(funcplane, GLC.GL_COMPILE);
			render;
		GL.EndList;
		DeActivate;
	END initGL;


	PROCEDURE Display;
	BEGIN
		GL.Clear (GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
(*		  Grid(); *)
		(*  render(); *)
		GL.CallList(funcplane);
	END Display;

BEGIN
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
END WMGLPlotSurface.

System.Free  WMGLPlotSurface ~

WMGLPlotSurface.Open ~
