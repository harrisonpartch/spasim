MODULE  GLTest; (** AUTHOR "fnecati"; PURPOSE "Simple GL rendering with commands"; *)

IMPORT  GL := OpenGL, GLC := OpenGLConst, KernelLog,
			Math, Context:=GLContext, GLU, WMGraphics, Raster;

(* Note:
	Since GL is state machine, drawing with different commands may leave
	artifacts of previous commands.

	Rendered images are saved as *.bmp file to the disk
	Examples from OpenGL-redbook.
*)
CONST

	pi = Math.pi;
	degToRad = pi / 180.0;

TYPE

	Point = ARRAY 3 OF GL.Float;


VAR
	 w, h: LONGINT; (* size of window *)
	 ctx : Context.Context;  (* GL context *)
	 image: Raster.Image; (* for saving the rendered image *)

PROCEDURE Error;
BEGIN
 KernelLog.String("Run the OpenDisplay command"); KernelLog.Ln;
END Error;

PROCEDURE SaveToImage(fname: ARRAY OF CHAR);
VAR imres: LONGINT;

BEGIN
	ctx.RenderInto(image);
	WMGraphics.StoreImage(image, fname, imres);
	KernelLog.String(fname); KernelLog.String(" saved."); KernelLog.Ln;
END SaveToImage;

(* for Primitives commands *)
(* ******************* *)
PROCEDURE Points;
BEGIN
 GL.Begin(GLC.GL_POINTS);

   GL.Vertex3f( 0.0, 1.0,-1.0);(* a *)
   GL.Vertex3f(-1.0,-1.0, 0.0);(* b *)
   GL.Vertex3f( 1.0,-1.0, 0.0);(* c *)

  GL.End();
END Points;

PROCEDURE Line;
BEGIN
GL.Begin(GLC.GL_LINE_LOOP);

   GL.Vertex3f( 0.0, 1.0,-1.0);(* a *)
   GL.Vertex3f(-1.0,-1.0, 0.0);(* b *)
   GL.Vertex3f( 1.0,-1.0, 0.0);(* c *)

  GL.End();
END Line;

PROCEDURE Triangle;
BEGIN
GL.Begin(GLC.GL_POLYGON);

	GL.Vertex3f( 0.0, 1.0,-1.0); (* a *)
	GL.Vertex3f(-1.0,-1.0, 0.0); (* b *)
	GL.Vertex3f( 1.0,-1.0, 0.0); (* c *)

GL.End();
END Triangle;

PROCEDURE Square;
BEGIN
GL.Begin(GLC.GL_POLYGON);

	GL.Vertex3f(0.0,0.0 ,0.0);(* a *)
	GL.Vertex3f(1.0,0.0, 0.0);(* b *)
	GL.Vertex3f(1.0,0.0,-1.0);(* c *)
	GL.Vertex3f(0.0,0.0,-1.0);(* d *)

GL.End();
END Square;

PROCEDURE Esquare();
BEGIN

GL.Begin(GLC.GL_QUAD_STRIP);
    GL.Vertex3f(0.0,0.0 ,0.0);(* a0 *)
    GL.Vertex3f(0.0,1.0 ,0.0);(* a1 *)
    GL.Vertex3f(1.0,0.0, 0.0);(* b0 *)
    GL.Vertex3f(1.0,1.0, 0.0);(* b1 *)
    GL.Vertex3f(1.0,0.0,-1.0);(* c0 *)
    GL.Vertex3f(1.0,1.0,-1.0);(* c1 *)
    GL.Vertex3f(0.0,0.0,-1.0);(* d0 *)
    GL.Vertex3f(0.0,1.0,-1.0);(* d1 *)
    GL.Vertex3f(0.0,0.0 ,0.0);(* a0 *)
    GL.Vertex3f(0.0,1.0 ,0.0);(* a1 *)
GL.End();

  GL.Begin(GLC.GL_POLYGON);
	GL.Vertex3f(0.0,0.0 ,0.0);(* a0 *)
	GL.Vertex3f(1.0,0.0, 0.0);(* b0 *)
	GL.Vertex3f(1.0,0.0,-1.0);(* c0 *)
	GL.Vertex3f(0.0,0.0,-1.0);(* d0 *)
	GL.Vertex3f(0.0,1.0 ,0.0);(* a1 *)
	GL.Vertex3f(1.0,1.0, 0.0);(* b1 *)
	GL.Vertex3f(1.0,1.0,-1.0);(* c1 *)
	GL.Vertex3f(0.0,1.0,-1.0);(* d1 *)
  GL.End();

END Esquare;

PROCEDURE Park;
VAR i: LONGINT;
    p: REAL;
    x, y: REAL;
BEGIN
 GL.Begin(GLC.GL_TRIANGLE_FAN);
   GL.Vertex3f(0,0,0.0 );
   FOR i:=0 TO 390 BY 30 DO
   	p := i*3.14/180;
   	x := Math.sin(p); y := Math.cos(p);
    	  GL.Vertex3f(x, y, 0.0 );
   END;
  GL.End();
END Park;

PROCEDURE Pillar;
VAR i : LONGINT;
    p: REAL;
    x, y: REAL;
BEGIN
GL.Begin(GLC.GL_QUAD_STRIP);
   FOR i := 0 TO 390 BY 30 DO
   	p :=i*3.14/180;
   	x := Math.sin(p)/2.0; y := Math.cos(p)/2.0;

	GL.Vertex3f(x, y,1.0 );
	GL.Vertex3f(x, y,0.0 );

   END;
 GL.End();
END Pillar;
(* ******************* *)


PROCEDURE Primitives*;

BEGIN
IF ctx = NIL THEN Error; RETURN END;

	(* Resize *)
	ctx.MakeCurrent();
	GL.Viewport(0, 0, w, h);

	(* Restore *)
	GL.ClearColor (0, 0, 0, 0);
	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;

	GL.Ortho(-2.0, 2.0, -2.0 , 2.0, -4.0, 4.0);

	GL.Clear (GLC.GL_COLOR_BUFFER_BIT+ GLC.GL_DEPTH_BUFFER_BIT);


	GL.PushMatrix();
	GL.Translatef(-0.3, 0.3, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Points();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Color3f (0.0, 1.0, 1.0);
	GL.Translatef(0.3, 0.3, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Line();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Color3f (1.0, 0.0, 1.0);
	GL.Rotatef(45, 0, 0, 1);
	GL.Translatef(0.3, 0.5, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Triangle();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Color3f (0.0, 1.0, 1.0);
	GL.Translatef(-0.3, -0.3, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Square();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Translatef(-0.3, 0.3, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Esquare();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Translatef(0.6, 0.6, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Park();
	GL.PopMatrix();

	GL.PushMatrix();
	GL.Color3f (1.0, 1.0, 1.0);
	GL.Translatef(0.6, -0.6, 0);
	GL.Scalef(0.4, 0.4, 0.5);
	Pillar();
	GL.PopMatrix();


(* ctx.SwapBuffers *);
SaveToImage("glprimitives.bmp");
ctx.DeActivate;
END Primitives;


PROCEDURE  MakeGear (innerRadius, outerRadius, width: REAL; teeth: LONGINT;  toothDepth: REAL);
VAR  r0, r1, r2 , angle, da, u, v, len: REAL;
		i: LONGINT;
BEGIN

	r0 := innerRadius;
	r1 := outerRadius - toothDepth / 2.0;
	r2 := outerRadius + toothDepth / 2.0;

	da := 2.0 * Math.pi / teeth / 4.0;


	GL.ShadeModel(GLC.GL_FLAT);

	GL.Normal3f(0.0, 0.0, 1.0);

	(* draw front face *)
	GL.Begin(GLC.GL_QUAD_STRIP);

		FOR  i := 0 TO teeth DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
		END;
	GL.End;

	(* draw front sides of teeth *)
	GL.Begin(GLC.GL_QUADS);
		da := 2.0 * Math.pi / teeth / 4.0;
		FOR  i := 0 TO teeth - 1 DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
		END;
	GL.End;

	GL.Normal3f(0.0, 0.0, -1.0);

	(* draw back face *)
	GL.Begin(GLC.GL_QUAD_STRIP);
	 FOR i := 0 TO teeth DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
	END;
	GL.End;

	(* draw back sides of teeth *)
	GL.Begin(GLC.GL_QUADS);
		da := 2.0 * Math.pi / teeth / 4.0;
		FOR i := 0 TO teeth - 1 DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), -width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), -width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
	END;
	GL.End;

	(* draw outward faces of teeth *)
	GL.Begin(GLC.GL_QUAD_STRIP);
		FOR i := 0 TO teeth - 1 DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle), r1 * Math.sin(angle), -width * 0.5);
			u := r2 * Math.cos(angle + da) - r1 * Math.cos(angle);
			v := r2 * Math.sin(angle + da) - r1 * Math.sin(angle);
			len := Math.sqrt(u * u + v * v);
			u := u / len;  v := v / len;
			GL.Normal3f(v, -u, 0.0);
			GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + da), r2 * Math.sin(angle + da), -width * 0.5);
			GL.Normal3f(Math.cos(angle), Math.sin(angle), 0.0);
			GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), width * 0.5);
			GL.Vertex3f(r2 * Math.cos(angle + 2 * da), r2 * Math.sin(angle + 2 * da), -width * 0.5);
			u := r1 * Math.cos(angle + 3 * da) - r2 * Math.cos(angle + 2 * da);
			v := r1 * Math.sin(angle + 3 * da) - r2 * Math.sin(angle + 2 * da);
			GL.Normal3f(v, -u, 0.0);
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), width * 0.5);
			GL.Vertex3f(r1 * Math.cos(angle + 3 * da), r1 * Math.sin(angle + 3 * da), -width * 0.5);
			GL.Normal3f(Math.cos(angle), Math.sin(angle), 0.0);
	END;

	GL.Vertex3f(r1 * Math.cos(0), r1 * Math.sin(0), width * 0.5);
	GL.Vertex3f(r1 * Math.cos(0), r1 * Math.sin(0), -width * 0.5);

	GL.End;

	GL.ShadeModel(GLC.GL_SMOOTH);

	(* draw inside radius cylinder *)
	GL.Begin(GLC.GL_QUAD_STRIP);
	FOR i := 0 TO teeth DO
			angle := i * 2.0 * Math.pi / teeth;
			GL.Normal3f(-Math.cos(angle), -Math.sin(angle), 0.0);
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), -width * 0.5);
			GL.Vertex3f(r0 * Math.cos(angle), r0 * Math.sin(angle), width * 0.5);
	END;
	GL.End;

END MakeGear;


PROCEDURE  Do*;
VAR
	i: LONGINT;
	r, g, b: ARRAY 3 OF GL.Float;
BEGIN
	IF ctx = NIL THEN Error; RETURN END;

	r[0] := 1;  g[0] := 0;  b[0] := 0;
	r[1] := 0;  g[1] := 1;  b[1] := 0;
	r[2] := 0;  g[2] := 0;  b[2] := 1;



	(* Resize *)
	ctx.MakeCurrent();
	GL.Viewport(0, 0, w, h);

	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;

	GL.Ortho(0, 1, 0, 1, -1, 1);

	(* Restore, Draw *)
	GL.ClearColor (0.6, 0.6, 0.6, 0);
	GL.Clear (GLC.GL_COLOR_BUFFER_BIT);

	GL.Begin(GLC.GL_TRIANGLES);
		i := 0;
		GL.Color3f (r[i], g[i], b[i]);
		GL.Vertex3f (0.25, 0.25, 0.0);

		i := (i + 1) MOD 3;
		GL.Color3f (r[i], g[i], b[i]);
		GL.Vertex3f (0.75, 0.25, 0.0);

		i := (i + 1) MOD 3;
		GL.Color3f (r[i], g[i], b[i]);
		GL.Vertex3f (0.5, 0.75, 0.0);
	GL.End;


(* ctx.SwapBuffers *);
SaveToImage("gldo.bmp");
ctx.DeActivate;
END Do;

PROCEDURE  Do1*;
BEGIN
IF ctx = NIL THEN Error; RETURN END;


	(* intialize *)
ctx.MakeCurrent();
	GL.Viewport(0, 0, w, h);

	GL.ClearColor (0, 0, 0, 0);
	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.Ortho(0, 1, 0, 1, -1, 1);

	(* draw *)
	GL.Clear (GLC.GL_COLOR_BUFFER_BIT);
	GL.Color3d (1.0, 1.0, 1.0);
	GL.Begin(GLC.GL_POLYGON);
		GL.Color3d (1.0, 0.0, 0.0);
		GL.Vertex3d (0.25, 0.25, 0.0);
		GL.Color3d (0.0, 1.0, 0.0);
		GL.Vertex3d (0.75, 0.25, 0.0);
		GL.Color3d (0.0, 0.0, 1.0);
		GL.Vertex3d (0.75, 0.75, 0.0);
		GL.Color3d (1.0, 1.0, 0.0);
		GL.Vertex3d (0.25, 0.75, 0.0);
	GL.End;

	(* ctx.SwapBuffers *);
	SaveToImage("gldo1.bmp");
	ctx.DeActivate;
END Do1;

PROCEDURE  Gears*;
VAR

	gear1, gear2, gear3: GL.Uint;
	rotx, roty, rotz, angle, angle1, angle2: GL.Float;
	red, green, blue, lightPos: ARRAY [4] OF GL.Float;

BEGIN
	IF ctx = NIL THEN Error; RETURN END;

	rotx := 20;  roty := 30;  rotz := 0;  angle := 20;

	(* Init view *)

(*	lightPos := [ 5.0, 5.0, 10.0, 0.0];
	red := [ 0.8, 0.1, 0.0, 1.0];
	green := [ 0.0, 0.8, 0.2, 1.0];
	blue := [ 0.2, 0.2, 1.0, 1.0];
*)
	lightPos[0] := 1.0;  	lightPos[1] := 1.0;	lightPos[2] := 1.0;	lightPos[3] := 0.0; (* directional *)

	red[0] := 0.8; 		red[1] := 0.1;		red[2] := 0.0;		red[3] := 1.0;
	green[0] := 0.0;	green[1] := 0.8;	green[2] := 0.2;	green[3] := 1.0;
	blue[0] := 0.2;		blue[1] := 0.2;		blue[2] := 1.0;		blue[3] := 1.0;


ctx.MakeCurrent();
	GL.Enable(GLC.GL_LIGHTING);
	GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, lightPos);
	GL.Enable(GLC.GL_LIGHT0);
	GL.Enable(GLC.GL_CULL_FACE);
	GL.Enable(GLC.GL_DEPTH_TEST);

	(* make the gears *)
	gear1 := GL.GenLists(1);
	GL.NewList(gear1, GLC.GL_COMPILE);
	GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, red);
	MakeGear( 1.0, 4.0, 1.0, 20, 0.7);
	GL.EndList;

	gear2 := GL.GenLists(1);
	GL.NewList(gear2, GLC.GL_COMPILE);
	GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, green);
	MakeGear( 0.5, 2.0, 2.0, 10, 0.7);
	GL.EndList;

	gear3 := GL.GenLists(1);
	GL.NewList(gear3, GLC.GL_COMPILE);
	GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT_AND_DIFFUSE, blue);
	MakeGear(1.3, 2.0, 0.5, 10, 0.7);
	GL.EndList;


	(* ********** projection matrices  *********** *)
	GL.ClearColor (0.0, 0.0, 0.0, 0);
	GL.Viewport(0, 0, w, h);
	GL.MatrixMode (GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.Frustum(-1.0, 1.0, -1, 1, 5.0, 60.0);

	GL.MatrixMode (GLC.GL_MODELVIEW);
	GL.LoadIdentity;

	GL.Translatef(0.0, 0.0, -40.0);


	(* ********** Draw ********** *)
	angle1 := -2.0 * angle - 9.0;
	angle2 := -2.0 * angle - 25.0;


	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);

	GL.PushMatrix;

	GL.Rotatef(rotx, 1.0, 0.0, 0.0);
	GL.Rotatef(roty, 0.0, 1.0, 0.0);
	GL.Rotatef(rotz, 0.0, 0.0, 1.0);

	GL.PushMatrix;
	GL.Translatef(-3.0, -2.0, 0.0);
	GL.Rotatef(angle, 0.0, 0.0, 1.0);
	GL.CallList(gear1);
	GL.PopMatrix;

	GL.PushMatrix;
	GL.Translatef(3.1, -2.0, 0.0);
	GL.Rotatef(angle1, 0.0, 0.0, 1.0);
	GL.CallList(gear2);
	GL.PopMatrix;

	GL.PushMatrix;
	GL.Translatef(-3.1, 4.2, 0.0);
	GL.Rotatef(angle2, 0.0, 0.0, 1.0);
	GL.CallList(gear3);
	GL.PopMatrix;

	GL.PopMatrix;

	(* ctx.SwapBuffers *);
	SaveToImage("glgears.bmp");
	ctx.DeActivate;
END Gears;

PROCEDURE  SetP (VAR a: ARRAY OF GL.Float;  a0, a1, a2: LONGREAL);
BEGIN
	a[0] := SHORT(a0);  a[1] := SHORT(a1);  a[2] := SHORT(a2)
END SetP;

PROCEDURE  BezSurf*;
VAR
	 i, j : LONGINT;
	ctrlPoints: ARRAY 4, 4 OF Point;
BEGIN
	IF ctx = NIL THEN Error; RETURN END;

	SetP(ctrlPoints[0, 0], -1.5, -1.5, 4.0);
	SetP(ctrlPoints[0, 1], -0.5, -1.5, 2.0);
	SetP(ctrlPoints[0, 2], 0.5, -1.5, -1.0);
	SetP(ctrlPoints[0, 3], 1.5, -1.5, 2.0);

	SetP(ctrlPoints[1, 0], -1.5, -0.5, 1.0);
	SetP(ctrlPoints[1, 1], -0.5, -0.5, 3.0);
	SetP(ctrlPoints[1, 2], 0.5, -0.5, 0.0);
	SetP(ctrlPoints[1, 3], 1.5, -0.5, -1.0);

	SetP(ctrlPoints[2, 0], -1.5, 0.5, 4.0);
	SetP(ctrlPoints[2, 1], -0.5, 0.5, 0.0);
	SetP(ctrlPoints[2, 2], 0.5, 0.5, 3.0);
	SetP(ctrlPoints[2, 3], 1.5, 0.5, 4.0);

	SetP(ctrlPoints[2, 0], -1.5, 1.5, -2.0);
	SetP(ctrlPoints[2, 1], -0.5, 1.5, -2.0);
	SetP(ctrlPoints[2, 2], 0.5, 1.5, 0.0);
	SetP(ctrlPoints[2, 3], 1.5, 1.5, -1.0);




	(* Init View *)
	ctx.MakeCurrent();

	GL.Map2f(GLC.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(ctrlPoints[0, 0, 0]));
	GL.Enable(GLC.GL_MAP2_VERTEX_3);
	GL.MapGrid2f(20, 0, 1, 20, 0, 1);
	GL.Enable(GLC.GL_DEPTH_TEST);
	GL.ShadeModel(GLC.GL_FLAT);

	(* intialize *)
	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.Ortho(-4.0, 4.0, -4.0 , 4.0, -4.0, 4.0);
	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity;


	(*  draw *)
	GL.ClearColor (0.0, 0, 0, 0);
	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
	GL.Color3d(1.0, 1.0, 0.0);
	GL.PushMatrix ();
	GL.Rotatef(85, 1, 1, 1);
	FOR  j := 0 TO 8 DO
		GL.Begin(GLC.GL_LINE_STRIP);
			FOR  i := 0 TO 30 DO
				GL.EvalCoord2d( i / 30.0,  j / 8.0)
			END;
		GL.End;
		GL.Begin(GLC.GL_LINE_STRIP);
			FOR  i := 0 TO 30 DO
				GL.EvalCoord2d( j / 8.0, i / 30.0)
			END;
		GL.End
	END;
	GL.PopMatrix ();
	GL.Finish();

	(* ctx.SwapBuffers *);
	SaveToImage("glpbeziersurf.bmp");

	ctx.DeActivate;
END BezSurf;


PROCEDURE  Accum*;
VAR
	thing1, thing2: GL.Uint;
BEGIN
IF ctx = NIL THEN Error; RETURN END;

ctx.MakeCurrent();

	thing1 := GL.GenLists(1);
	GL.NewList(thing1, GLC.GL_COMPILE);
	GL.Color3f(1, 0, 0);
	GL.Rectf(-1, -1, 1, 0);
	GL.EndList;

	thing2 := GL.GenLists(1);
	GL.NewList(thing2, GLC.GL_COMPILE);
	GL.Color3f(0.0, 1.0, 0.0);
	GL.Rectf(0.0, -1.0, 1.0, 1.0);
	GL.EndList;


	(* initialize *)
	GL.ClearColor(0.6, 0.6, 0.6, 0);
	GL.ClearAccum(0.0, 0.0, 0, 0.0);

	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity;

	(* draw *)
	GL.Clear(GLC.GL_COLOR_BUFFER_BIT);
	GL.CallList(thing1);
	GL.Accum(GLC.GL_LOAD, 0.5);

	GL.Clear(GLC.GL_COLOR_BUFFER_BIT);
	GL.CallList(thing2);
	GL.Accum(GLC.GL_ACCUM, 0.5);

	GL.Accum(GLC.GL_RETURN, 1);

	GL.Finish();

	(* ctx.SwapBuffers *);
	SaveToImage("glaccumulation.bmp");
	ctx.DeActivate;
END Accum;



PROCEDURE  MakeBall ():GL.Uint;
CONST  da = 18;  db = 18;  r = 1.0;
VAR  list: GL.Uint;  color: BOOLEAN;
		a, b: LONGINT;
		x, y, z: LONGREAL;
BEGIN
ctx.MakeCurrent();
	list := GL.GenLists(1);
	GL.NewList(list, GLC.GL_COMPILE);
	color := FALSE;
	FOR  a := -90 TO 90 - da BY da DO
		GL.Begin(GLC.GL_QUAD_STRIP);
			FOR  b := 0 TO 360 BY db DO
				IF color THEN GL.Color3d(1, 0, 0); ELSE GL.Color3d(1, 1, 1); END;
				x := Math.cos(b * degToRad) * Math.cos(a * degToRad);
				y := Math.sin(b * degToRad) * Math.cos(a * degToRad);
				z := Math.sin(a * degToRad);
				  GL.Vertex3d(x, y, z);

				x := r * Math.cos(b * degToRad) * Math.cos((a + da) * degToRad);
				y := Math.sin(b * degToRad) * Math.cos((a + da) * degToRad);
				z := Math.sin((a + da) * degToRad);

				 	GL.Vertex3d(x, y, z);
				color := ~color
			END;
		GL.End
	END;

	GL.EndList;

	ctx.DeActivate();
	KernelLog.String("MakeBall. Ok"); KernelLog.Ln;
	RETURN list;

END MakeBall;

PROCEDURE  MakeLines ():GL.Uint;
	VAR  list: GL.Uint;  i: LONGINT;
		  x: REAL;
BEGIN
ctx.MakeCurrent();
	list := GL.GenLists(1);
	GL.NewList(list, GLC.GL_COMPILE);

	GL.Begin(GLC.GL_LINES);
		GL.Color3f(0.0, 1.0, 1.0);
		FOR  i := -5 TO 5 DO
			 	GL.Vertex2i(i, -5);  GL.Vertex2i(i, 5);
		END;
		FOR  i := -5 TO 5 DO
			 	GL.Vertex2i(-5, i);  GL.Vertex2i(5, i);
		END;
		FOR  i := -5 TO 5 DO
			x := i*1.15;
			 	GL.Vertex2i(i, -5);  GL.Vertex2f(x, -5.9);
		END;

		GL.Vertex2f(-5.3, -5.35);
		GL.Vertex2f(5.3, -5.35);
		GL.Vertex2f(-5.75, -5.9);
		GL.Vertex2f(5.75, -5.9);

	GL.End;

	GL.EndList;
	ctx.DeActivate();
	KernelLog.String("MakeLines. Ok"); KernelLog.Ln;
	RETURN list
END MakeLines;

PROCEDURE  Bounce*;
VAR

	ball, lines: GL.Uint;
	x, y: REAL;
	vx, vy: REAL;
	zRot, dRot: LONGINT;

BEGIN
IF ctx = NIL THEN Error; RETURN END;

	x := 0.0;  y := 1.0;  zRot := 0;  dRot := 6;
	vx := 0.2;  vy := 0.0;

(* Initview *)

  	lines := MakeLines();
  	ball := MakeBall();


ctx.MakeCurrent();
  	GL.ClearColor(0, 0.0, 0.0, 0);
	GL.ShadeModel (GLC.GL_FLAT);
	GL.Enable(GLC.GL_CULL_FACE);
	GL.CullFace(GLC.GL_BACK);
  (****************)

	GL.MatrixMode (GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.Ortho(-6.0, 6.0, -6.0, 6.0 , -6.0, 6.0);

	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity;

	GL.Clear (GLC.GL_COLOR_BUFFER_BIT);

	GL.CallList(lines);

	GL.PushMatrix;
	GL.Translatef(x, y, 0.0);
	GL.Scalef(2, 2, 2);
	GL.Rotatef(8, 0, 0, 1);
	GL.Rotatef(90, 1, 0, 0);
	GL.Rotatef(zRot, 0, 0, 1);

	GL.CallList(ball);

	GL.PopMatrix;


	(* ctx.SwapBuffers *);
	SaveToImage("glbounce.bmp");
	ctx.DeActivate;
END Bounce;

PROCEDURE  Cube*;
BEGIN
IF ctx = NIL THEN Error; RETURN END;
ctx.MakeCurrent();

	GL.ClearColor(0.0, 0.0, 0.0, 0.0);

	GL.MatrixMode(GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GLU.Perspective(45, 1, 1, 100);

	GL.MatrixMode(GLC.GL_MODELVIEW);
	GL.LoadIdentity;
	GL.Translatef(0.0, 0.0, -10.0);
	GL.Rotatef(45, 1.0, 1.0, 0.0);

	(* draw *)
	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);

GL.Begin(GLC.GL_POLYGON); (* top face oriented toward y *)
	GL.Color3f(0.0,0.0,1.0);
	GL.Vertex3f(-1.0, 1.0, 1.0);
	GL.Vertex3f(1.0, 1.0, 1.0);
	GL.Vertex3f(1.0, 1.0, -1.0);
	GL.Vertex3f(-1.0, 1.0, -1.0);
GL.End();

GL.Begin(GLC.GL_POLYGON); (* back face oriented toward -z *)
	GL.Color3f(0.0,1.0,0.0);
	GL.Vertex3f(-1.0, 1.0, -1.0);
	GL.Vertex3f(1.0, 1.0, -1.0);
	GL.Vertex3f(1.0, -1.0, -1.0);
	GL.Vertex3f(-1.0, -1.0, -1.0);
GL.End();

GL.Begin(GLC.GL_POLYGON); (* right face oriented toward x *)
	GL.Color3f(1.0,0.0,0.0);
	GL.Vertex3f(1.0, 1.0, 1.0);
	GL.Vertex3f(1.0, -1.0, 1.0);
	GL.Vertex3f(1.0, -1.0, -1.0);
	GL.Vertex3f(1.0, 1.0, -1.0);
GL.End();

GL.Begin(GLC.GL_POLYGON); (* left face oriented toward -x *)
	GL.Color3f(1.0,0.0,0.0);
	GL.Vertex3f(-1.0, -1.0, 1.0);
	GL.Vertex3f(-1.0, 1.0, 1.0);
	GL.Vertex3f(-1.0, 1.0, -1.0);
	GL.Vertex3f(-1.0, -1.0, -1.0);
GL.End();

GL.Begin(GLC.GL_POLYGON); (* bottom face oriented toward -y *)
	GL.Color3f(0.0,0.0,1.0);
	GL.Vertex3f(-1.0, -1.0, 1.0);
	GL.Vertex3f(-1.0, -1.0, -1.0);
	GL.Vertex3f(1.0, -1.0, -1.0);
	GL.Vertex3f(1.0, -1.0, 1.0);
GL.End();

GL.Begin(GLC.GL_POLYGON); (* front face oriented toward z*)
	GL.Color3f(0.0,1.0,0.0);
	GL.Vertex3f(1.0, 1.0, 1.0);
	GL.Vertex3f(-1.0, 1.0, 1.0);
	GL.Vertex3f(-1.0, -1.0, 1.0);
	GL.Vertex3f(1.0, -1.0, 1.0);
GL.End();
GL.Finish();



(* ctx.SwapBuffers *);
SaveToImage("glcube.bmp");
ctx.DeActivate;
END Cube;

(*
PROCEDURE {C} MyErrorCallback (err: GL.Enum);
VAR s: Strings.String;
BEGIN
	KernelLog.String("cb err #: "); KernelLog.Int(err, 0);
	s := GLU.ErrorString(err);
	KernelLog.String(",  ERROR: "); KernelLog.String(s^); KernelLog.Ln;
END MyErrorCallback;
*)

PROCEDURE  Quadric*;
VAR
	matAmbient, matSpecular, lightPosition, modelAmbient: ARRAY [4] OF GL.Float;
	matShininess: GL.Float;
	qObj: GLU.Quadric;
	startList: GL.Uint;
BEGIN
IF ctx = NIL THEN Error; RETURN END;
(*	matAmbient := [ 0.5, 0.5, 0.5, 1.0];
	matSpecular := [ 1.0, 1.0, 1.0, 1.0];
	matShininess := 50.0;
	lightPosition := [ 1.0, 1.0, 1.0, 0.0];
	modelAmbient := [ 0.5, 0.5, 0.5, 1.0];
*)

matAmbient[0] := 0.5;	matAmbient[1] :=  0.5;	matAmbient[2] := 0.5; 	matAmbient[3] := 1.0;
matSpecular[0] := 1.0;	matSpecular[1] := 1.0;	matSpecular[2] := 1.0;	matSpecular[3] := 1.0;
matShininess := 50.0;
lightPosition[0] := 1.0; 	lightPosition[1] := 1.0;		lightPosition[2] := 1.0;		lightPosition[3] := 0.0;
modelAmbient[0] := 0.5;	modelAmbient[1] := 0.5;	modelAmbient[2] := 0.5;	modelAmbient[3] := 1.0;

ctx.MakeCurrent();
	GL.ClearColor(0.0, 0.0, 0.0, 0.0);

	GL.Materialfv(GLC.GL_FRONT, GLC.GL_AMBIENT, matAmbient);
	GL.Materialfv(GLC.GL_FRONT, GLC.GL_SPECULAR, matSpecular);
	GL.Materialf(GLC.GL_FRONT, GLC.GL_SHININESS, matShininess);
	GL.Lightfv(GLC.GL_LIGHT0, GLC.GL_POSITION, lightPosition);
	GL.LightModelfv(GLC.GL_LIGHT_MODEL_AMBIENT, modelAmbient);

	GL.Enable(GLC.GL_LIGHTING);
	GL.Enable(GLC.GL_LIGHT0);
	GL.Enable(GLC.GL_DEPTH_TEST);


(*  Create 4 display lists, each with a different quadric object.
 *  Different drawing styles and surface normal specifications
 *  are demonstrated.
 *)
	startList := GL.GenLists(4);
	qObj := GLU.NewQuadric();
(*	GLU.QuadricCallback(qObj, GLU.GLU_ERROR, MyErrorCallback );*)

	GLU.QuadricDrawStyle(qObj, GLU.GLU_FILL); (* smooth shaded *)
	GLU.QuadricNormals(qObj, GLU.GLU_SMOOTH);
	GL.NewList(startList, GLC.GL_COMPILE);
		GLU.Sphere(qObj, 0.75, 15, 10);
	GL.EndList();

	GLU.QuadricDrawStyle(qObj, GLU.GLU_FILL); (* flat shaded *)
	GLU.QuadricNormals(qObj, GLU.GLU_FLAT);
	GL.NewList(startList+1, GLC.GL_COMPILE);
		GLU.Cylinder(qObj, 0.5, 0.3, 1.0, 15, 5);
	GL.EndList();

	GLU.QuadricDrawStyle(qObj, GLU.GLU_LINE); (* all polygons wireframe *)
	GLU.QuadricNormals(qObj, GLU.GLU_NONE);
	GL.NewList(startList+2, GLC.GL_COMPILE);
		GLU.Disk(qObj, 0.25, 1.0, 20, 4);
	GL.EndList();

	GLU.QuadricDrawStyle(qObj, GLU.GLU_SILHOUETTE); (* boundary only  *)
	GLU.QuadricNormals(qObj, GLU.GLU_NONE);
	GL.NewList(startList+3, GLC.GL_COMPILE);
		GLU.PartialDisk(qObj, 0.0, 1.0, 20, 4, 0.0, 225.0);
	GL.EndList;

	(* Resize *)
	GL.Viewport(0, 0, w, h);

	GL.MatrixMode (GLC.GL_PROJECTION);
	GL.LoadIdentity;
	GL.Ortho(-2.5, 2.5, -2.5 , 2.5 , -10.0, 10.0);

	GL.MatrixMode (GLC.GL_MODELVIEW);
	GL.LoadIdentity;

	(* draw *)

	GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);
	GL.PushMatrix;

	GL.Enable(GLC.GL_LIGHTING);
	GL.ShadeModel (GLC.GL_SMOOTH);
	GL.Translated(-1.0, -1.0, 0.0);

	GL.CallList(startList);

	GL.ShadeModel (GLC.GL_FLAT);
	GL.Translated(0.0, 2.0, 0.0);
	GL.PushMatrix;
	GL.Rotated(300.0, 1.0, 0.0, 0.0);
	GL.CallList(startList+1);
	GL.PopMatrix;

	GL.Disable(GLC.GL_LIGHTING);
	GL.Color3d(0.0, 1.0, 1.0);
	GL.Translated(2.0, -2.0, 0.0);
	GL.CallList(startList+2);

	GL.Color3d(1.0, 1.0, 0.0);
	GL.Translated(0.0, 2.0, 0.0);
	GL.CallList(startList+3);

	GL.PopMatrix;
	GL.Finish();

	GLU.DeleteQuadric(qObj);


	SaveToImage("glquadric.bmp");
	ctx.DeActivate;
END Quadric;

PROCEDURE OpenContext*;
BEGIN
	w := 512; h := 512;
	IF ctx = NIL THEN
		NEW(ctx);
		ctx.Init(w , h);
		NEW(image);
		Raster.Create(image, w, h, Raster.BGRA8888);
	END;
END OpenContext;

(** *)
PROCEDURE CloseContext*;
BEGIN
	IF ctx # NIL THEN ctx.Close; ctx := NIL; END;
END CloseContext;

BEGIN

END  GLTest.


GLTest.OpenContext ~ 			GLTest.CloseContext ~


GLTest.Primitives ~     GLTest.Do ~     GLTest.Do1 ~   GLTest.Gears ~

GLTest.BezSurf ~         GLTest.Accum ~    GLTest.Bounce ~ GLTest.Cube ~

GLTest.Quadric ~

System.Free GLTest  GLContext  ~

System.FreeDownTo OpenGLConst ~

