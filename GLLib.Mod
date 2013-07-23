MODULE  GLLib;

(*  (C)  E. Pokora, 1999.  This module is part of the Ogl subsystem - a binding of OpenGL for BlackBox Component Pascal.*)
(*  Procedures to draw the famous teapot and some 3d geometric primitives:
	cube, cone, sphere, torus, tetrahedron, octahedron, dodecahedron, icosahedron.

	All surfaces are no tested.
	uses GLU library.
*)

IMPORT  Math:=MathL,  GL := OpenGL, GLC := OpenGLConst, GLU,
		SYSTEM, Streams, KernelLog;

CONST
	pi = 3.14159265358979323846;
	t = 1.73205080756887729;
	x = 0.525731112119133606;
	z = 0.850650808352039932;

TYPE
	Vector16f = ARRAY [16] OF GL.Float; (* 4x4 Float Matrix *)
(*	Vec = ARRAY [3] OF GL.Double; *)
	Array3i = ARRAY [3] OF GL.Int;
	Array16i = ARRAY [16] OF GL.Int;
	Vec3d = ARRAY [3] OF GL.Double;
	Vec4i = ARRAY [4] OF GL.Int;
VAR
	quadObj: GLU.QuadricObj;
	tData: ARRAY [4] OF Vec3d;
	tIndex: ARRAY [4] OF Array3i;
	iData: ARRAY [12] OF Vec3d;
	iIndex: ARRAY [20] OF Array3i;
	oData: ARRAY [6] OF Vec3d;
	oIndex: ARRAY[8] OF Array3i;
	dodec: ARRAY [20]  OF Vec3d;

	(* Teapot data *)
	patchData: ARRAY [10] OF Array16i;
	cpData: ARRAY [127, 3] OF GL.Float;
	tex: ARRAY [2, 2, 2] OF GL.Float;

	wr: Streams.Writer;

(* write projection matrix *)
PROCEDURE WriteProjMatrix*(CONST title: ARRAY OF CHAR);
VAR i: LONGINT;
       v: Vector16f;
BEGIN
GL.GetFloatv(GLC.GL_PROJECTION_MATRIX, ADDRESSOF(v[0]));
wr.String("-----------------"); wr.Ln;
wr.String("PROJECTION_MATRIX: "); wr.String(title); wr.Ln;
	FOR i:=0 TO 15 DO
		wr.FloatFix(v[i], 10,4,0);
	END;
wr.Ln; wr.Update;
END WriteProjMatrix;

(* write modelview matrix *)
PROCEDURE WriteModelViewMatrix*(CONST title: ARRAY OF CHAR);
VAR i : LONGINT;
       v: Vector16f;
BEGIN
GL.GetFloatv(GLC.GL_MODELVIEW_MATRIX, ADDRESSOF(v[0]));
wr.String("-----------------"); wr.Ln;
wr.String("GL_MODELVIEW_MATRIX: ");wr.String(title); wr.Ln;
	FOR i:=0 TO 15 DO
		wr.FloatFix(v[i], 10,4,0);
	END;
wr.Ln; wr.Update;
END WriteModelViewMatrix;

PROCEDURE  InitQuadObj;
BEGIN
	IF quadObj = 0 THEN quadObj := GLU.NewQuadric() END;
	ASSERT(quadObj # 0, 60)
END InitQuadObj;

PROCEDURE  Set2f (VAR a: ARRAY OF GL.Float;  a0, a1: LONGREAL);
BEGIN
	a[0] := SHORT(a0);  a[1] := SHORT(a1)
END Set2f;

PROCEDURE  Set3f (VAR a: ARRAY OF GL.Float;  a0, a1, a2: LONGREAL);
BEGIN
	a[0] := SHORT(a0);  a[1] := SHORT(a1);  a[2] := SHORT(a2)
END Set3f;

PROCEDURE  Set3i (VAR a: ARRAY OF LONGINT;  a0, a1, a2: LONGINT);
BEGIN
	a[0] := a0;  a[1] := a1;  a[2] := a2
END Set3i;

PROCEDURE  Set16i (VAR a: ARRAY OF GL.Int;
							a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15: LONGINT);
BEGIN
	a[0] := a0;  a[1] := a1;  a[2] := a2;  a[3] := a3;
	a[4] := a4;  a[5] := a5;  a[6] := a6;  a[7] := a7;
	a[8] := a8;  a[9] := a9;  a[10] := a10;  a[11] := a11;
	a[12] := a12;  a[13] := a13;  a[14] := a14;  a[15] := a15
END Set16i;

PROCEDURE  Len (CONST a: Vec3d): LONGREAL;
BEGIN
	RETURN  Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2])
END Len;


PROCEDURE Cross (a, b: Vec3d;  VAR c: Vec3d);
BEGIN
	c[0] := a[1] * b[2] - a[2] * b[1];
	c[1] := a[2] * b[0] - a[0] * b[2];
	c[2] := a[0] * b[1] - a[1] * b[0]
END Cross;

PROCEDURE NormalizeV (VAR v: Vec3d);
	VAR d: GL.Double;
BEGIN
	d := Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	IF d # 0 THEN
		d := 1.0 / d;
		v[0] := d * v[0];  v[1] := d * v[1];  v[2] := d * v[2]
	ELSE
		wr.String("GLLib: attempt to normalize zero length vector"); wr.Ln; wr.Update;
		v[0] := 1
	END
END NormalizeV;

PROCEDURE  DrawBox (size: GL.Double;  type: GL.Enum);
	VAR  n: ARRAY [6] OF Vec3d;  faces: ARRAY [6] OF Vec4i;
			v: ARRAY [8] OF Vec3d;
			i: LONGINT;  s: GL.Double;
BEGIN
	n[0] := [ -1.0, 0.0, 0.0];
	n[1] := [ 0.0, 1.0, 0.0];
	n[2] := [ 1.0, 0.0, 0.0];
	n[3] := [ 0.0, -1.0, 0.0];
	n[4] := [ 0.0, 0.0, 1.0];
	n[5] := [ 0.0, 0.0, -1.0];

	faces[0] := [ 0, 1, 2, 3];
	faces[1] := [ 3, 2, 6, 7];
	faces[2] := [ 7, 6, 5, 4];
	faces[3] := [ 4, 5, 1, 0];
	faces[4] := [ 5, 6, 2, 1];
	faces[5] := [ 7, 4, 0, 3];

	s := size / 2.0;
	v[0] := [ -s, -s, -s ];  v[1] := [ -s, -s, s];  v[2] := [ -s, s, s];  v[3] := [ -s, s, -s ];
	v[4] := [  s, -s, -s ];  v[5] := [  s, -s,  s ];  v[6] := [  s, s, s ];  v[7] := [  s, s, -s ];


	FOR  i := 5 TO 0 BY -1 DO
		GL.Begin(type);
			GL.Normal3dv(n[i]);
			GL.Vertex3dv( v[ faces[i, 0] ]);
			GL.Vertex3dv( v[faces[i, 1] ]);
			GL.Vertex3dv( v[faces[i, 2] ]);
			GL.Vertex3dv( v[faces[i, 3] ]);
		GL.End
	END;

END DrawBox;

PROCEDURE  WireCube* (size: LONGREAL);
BEGIN
	DrawBox(SHORT(size), GLC.GL_LINE_LOOP)
END WireCube;

PROCEDURE  SolidCube* (size: LONGREAL);
BEGIN
	DrawBox(size, GLC.GL_QUADS)
END SolidCube;

PROCEDURE  WireSphere* (radius: LONGREAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	GLU.QuadricDrawStyle(quadObj, GLU.GLU_LINE);
	GLU.QuadricNormals(quadObj, GLU.GLU_SMOOTH);
	GLU.Sphere(quadObj, radius, slices, stacks)
END WireSphere;

PROCEDURE  SolidSphere* (radius: LONGREAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	GLU.QuadricDrawStyle(quadObj, GLU.GLU_FILL);
	GLU.QuadricNormals(quadObj, GLU.GLU_SMOOTH);
	GLU.Sphere(quadObj, radius, slices, stacks)
END SolidSphere;

PROCEDURE  WireCone* (base, height: LONGREAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	GLU.QuadricDrawStyle(quadObj, GLU.GLU_LINE);
	GLU.QuadricNormals(quadObj, GLU.GLU_SMOOTH);
	GLU.Cylinder(quadObj, base, 0.0, height, slices, stacks);
END WireCone;

PROCEDURE  SolidCone* (base, height: LONGREAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	GLU.QuadricDrawStyle(quadObj, GLU.GLU_FILL);
	GLU.QuadricNormals(quadObj, GLU.GLU_SMOOTH);
	GLU.Cylinder(quadObj, base, 0.0, height, slices, stacks);
END SolidCone;

PROCEDURE Torus (r, R: LONGREAL;  nsides, rings: LONGINT);
	VAR  i, j: LONGINT;
			theta, phi, theta1, cosPhi, sinPhi, dist, cosTheta, sinTheta,
			cosTheta1, sinTheta1, ringDelta, sideDelta: LONGREAL;
BEGIN
	ringDelta := 2.0 * pi / rings;  sideDelta := 2.0 * pi / nsides;
	theta := 0.0;  cosTheta := 1.0;  sinTheta := 0.0;

	FOR i := rings - 1 TO 0 BY -1 DO
		theta1 := theta + ringDelta;
		cosTheta1 := Math.cos(theta1);   sinTheta1 := Math.sin(theta1);
		GL.Begin(GLC.GL_QUAD_STRIP);
			phi := 0.0;
			FOR  j := nsides TO 0 BY -1 DO
				phi := phi + sideDelta;
				cosPhi := Math.cos(phi);  sinPhi := Math.sin(phi);
				dist := R + r * cosPhi;

				GL.Normal3d(cosTheta1 * cosPhi, -sinTheta1 * cosPhi, sinPhi);
				GL.Vertex3d(cosTheta1 * dist, -sinTheta1 * dist, r * sinPhi);
				GL.Normal3d(cosTheta * cosPhi, -sinTheta * cosPhi, sinPhi);
				GL.Vertex3d(cosTheta * dist, -sinTheta * dist,  r * sinPhi);
			END;
		GL.End;
		theta := theta1;
		cosTheta := cosTheta1;  sinTheta := sinTheta1;
	END
END Torus;

PROCEDURE  WireTorus* (innerRadius, outerRadius: LONGREAL;  nsides, rings: LONGINT);
BEGIN
	GL.PushAttrib(GLC.GL_POLYGON_BIT);
	GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
	Torus(innerRadius, outerRadius, nsides, rings);
	GL.PopAttrib
END WireTorus;

PROCEDURE  SolidTorus* (innerRadius, outerRadius: LONGREAL;  nsides, rings: LONGINT);
BEGIN
	Torus(innerRadius, outerRadius, nsides, rings)
END SolidTorus;


PROCEDURE RecordItem (VAR n1, n2, n3: Vec3d;  shadeType: GL.Enum);
	VAR  q0, q1: Vec3d;
BEGIN
(*	SubV(n1, n2, q0);  SubV(n2, n3, q1);*)
	q0 := n1 -n2;
	q1 := n2 -n3;
	Cross(q0, q1, q1);  NormalizeV(q1);

	GL.Begin(shadeType);
		GL.Normal3dv(q1);
		GL.Vertex3dv(n1);
		GL.Vertex3dv(n2);
		GL.Vertex3dv(n3);
	GL.End
END RecordItem;

PROCEDURE  Subdivide (CONST v0, v1, v2: Vec3d;  shadeType: GL.Enum);
	VAR  depth, i, j, k, n: LONGINT;  l: LONGREAL;
			w0, w1, w2: Vec3d;
BEGIN
	depth := 1;
	FOR  i := 0 TO depth - 1 DO
		FOR  j := 0 TO depth - i - 1 DO
			k := depth - i - j;
			FOR  n := 0 TO 2 DO
				w0[n] := (i * v0[n] + j * v1[n] + k * v2[n]) / depth;
				w1[n] := ((i + 1) * v0[n] + j * v1[n] + (k - 1) * v2[n]) / depth;
				w2[n] := (i * v0[n] + (j + 1) * v1[n] + (k - 1) * v2[n]) / depth
			END;
			NormalizeV(w0);  NormalizeV(w1);  NormalizeV(w2);
			RecordItem(w1, w0, w2, shadeType);
		END
	END
END Subdivide;

PROCEDURE DrawTriangle (i: LONGINT; VAR data: ARRAY [*] OF Vec3d;  VAR ndx: ARRAY [*] OF Array3i; shadeType: GL.Enum);
VAR  x0, x1, x2:  Vec3d;
BEGIN
	x0 := data[ndx[i, 0]];
	x1 := data[ndx[i, 1]];
	x2 := data[ndx[i, 2]];
	Subdivide(x0, x1, x2, shadeType)
END DrawTriangle;

PROCEDURE  DrawTetrahedron (shadeType: GL.Enum);
	VAR  i: LONGINT;
BEGIN
	FOR  i := 3 TO 0 BY -1 DO
		DrawTriangle(i, tData, tIndex, shadeType)
	END
END DrawTetrahedron;


PROCEDURE  WireTetrahedron*;
BEGIN
	DrawTetrahedron(GLC.GL_LINE_LOOP)
END WireTetrahedron;

PROCEDURE  SolidTetrahedron*;
BEGIN
	DrawTetrahedron(GLC.GL_TRIANGLES)
END SolidTetrahedron;

PROCEDURE DrawIcosahedron (shadeType: GL.Enum);
	VAR  i: LONGINT;
BEGIN
	FOR  i := 19 TO 0 BY -1 DO
		DrawTriangle(i, iData, iIndex, shadeType)
	END
END DrawIcosahedron;

PROCEDURE  WireIcosahedron* ;
BEGIN
	DrawIcosahedron(GLC.GL_LINE_LOOP)
END WireIcosahedron;

PROCEDURE  SolidIcosahedron* ;
BEGIN
	DrawIcosahedron(GLC.GL_TRIANGLES)
END SolidIcosahedron;

PROCEDURE  DrawTeapot (grid: GL.Int;  scale: GL.Double;  type: GL.Enum);
	VAR  i, j, k, l: LONGINT;  p, q, r, s: ARRAY 4, 4, 3 OF GL.Float;
BEGIN
	GL.PushAttrib(GLC.GL_ENABLE_BIT + GLC.GL_EVAL_BIT);
	GL.Enable(GLC.GL_AUTO_NORMAL);
	GL.Enable(GLC.GL_NORMALIZE);
	GL.Enable(GLC.GL_MAP2_VERTEX_3);
	GL.Enable(GLC.GL_MAP2_TEXTURE_COORD_2);
	GL.PushMatrix;

	GL.Rotated(270.0, 1.0, 0.0, 0.0);
	GL.Scaled(0.5 * scale, 0.5 * scale, 0.5 * scale);
	GL.Translated(0.0, 0.0, -1.5);

	FOR  i := 0 TO 9 DO

		FOR  j := 0 TO 3 DO
			FOR k := 0 TO 3 DO
				FOR  l := 0 TO 2 DO
					p[j, k, l] := cpData[ patchData[i, j * 4 + k],  l];
					q[j, k, l] := cpData[ patchData[i, j * 4 + (3 - k)],  l];
					IF  l = 1 THEN  q[j, k, l] := -q[j, k, l]  END;
					IF  i < 6 THEN
						r[j, k, l] := cpData[ patchData[i, j * 4 + (3 - k)],  l];
						IF l = 0 THEN  r[j, k, l] := -r[j, k, l]  END;
						s[j, k, l] := cpData[ patchData[i, j * 4 + k],  l];
						IF  l < 2 THEN  s[j, k, l] := -s[j, k, l]  END
					END
				END
			END
		END;

		GL.Map2f(GLC.GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, ADDRESSOF(tex[0, 0, 0]));
		GL.Map2f(GLC.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(p[0, 0, 0]));
		GL.MapGrid2f(grid, 0, 1, grid, 0, 1);
		GL.EvalMesh2(type, 0, grid, 0, grid);
		GL.Map2f(GLC.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(q[0, 0, 0]));
		GL.EvalMesh2(type, 0, grid, 0, grid);
		IF  i < 6 THEN
			GL.Map2f(GLC.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(r[0, 0, 0]));
			GL.EvalMesh2(type, 0, grid, 0, grid);
			GL.Map2f(GLC.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(s[0, 0, 0]));
			GL.EvalMesh2(type, 0, grid, 0, grid)
		END
	END;

	GL.PopMatrix;
	GL.PopAttrib
END DrawTeapot;


PROCEDURE  SolidTeapot* (scale: LONGREAL);
BEGIN
	DrawTeapot(14, scale, GLC.GL_FILL)
END SolidTeapot;

PROCEDURE  WireTeapot* (scale: LONGREAL);
BEGIN
	DrawTeapot(10, scale, GLC.GL_LINE)
END WireTeapot;


PROCEDURE DrawOctahedron (shadeType: GL.Enum);
	VAR  i: LONGINT;
BEGIN
	FOR  i := 7 TO 0 BY -1 DO
		DrawTriangle(i, oData, oIndex, shadeType)
	END
END DrawOctahedron;

PROCEDURE  WireOctahedron* ;
BEGIN
	DrawOctahedron(GLC.GL_LINE_LOOP)
END WireOctahedron;

PROCEDURE  SolidOctahedron* ;
BEGIN
	DrawOctahedron(GLC.GL_TRIANGLES)
END SolidOctahedron;

PROCEDURE  DrawPentagon (a, b, c, d, e: LONGINT;  shadeType: GL.Enum);
	VAR  n, d1, d2: Vec3d;
BEGIN
(*	SubV(dodec[a], dodec[b], d1);  SubV(dodec[b], dodec[c], d2); *)
	d1 := dodec[a] - dodec[b];
	d2 := dodec[b] - dodec[c];
	Cross(d1, d2, n);  NormalizeV(n);

	GL.Begin(shadeType);
		GL.Normal3dv( n);
		GL.Vertex3dv( dodec[a]);
		GL.Vertex3dv( dodec[b]);
		GL.Vertex3dv( dodec[c]);
		GL.Vertex3dv( dodec[d]);
		GL.Vertex3dv(dodec[e]);
	GL.End
END DrawPentagon;

PROCEDURE  DrawDodecahedron (type: GL.Enum);
BEGIN
	DrawPentagon(0, 1, 9, 16, 5, type);
	DrawPentagon(1, 0, 3, 18, 7, type);
	DrawPentagon(1, 7, 11, 10, 9, type);
	DrawPentagon(11, 7, 18, 19, 6, type);
	DrawPentagon(8, 17, 16, 9, 10, type);
	DrawPentagon(2, 14, 15, 6, 19, type);
	DrawPentagon(2, 13, 12, 4, 14, type);
	DrawPentagon(2, 19, 18, 3, 13, type);
	DrawPentagon(3, 0, 5, 12, 13, type);
	DrawPentagon(6, 15, 8, 10, 11, type);
	DrawPentagon(4, 17, 8, 15, 14, type);
	DrawPentagon(4, 12, 5, 16, 17, type)
END DrawDodecahedron;

PROCEDURE  WireDodecahedron* ;
BEGIN
	DrawDodecahedron(GLC.GL_LINE_LOOP)
END WireDodecahedron;


PROCEDURE  SolidDodecahedron* ;
BEGIN
	DrawDodecahedron(GLC.GL_TRIANGLE_FAN)
END SolidDodecahedron;


PROCEDURE  InitDodecahedron;
	VAR  alpha, beta: LONGREAL;
BEGIN
	alpha := Math.sqrt(2.0 / (3.0 + Math.sqrt(5.0)));
	beta := 1.0 + Math.sqrt(6.0 / (3.0 + Math.sqrt(5.0)) -
			  2.0 + 2.0 * Math.sqrt(2.0 / (3.0 + Math.sqrt(5.0))));

	dodec[0] := [ -alpha, 0, beta];
	dodec[1] := [ alpha, 0, beta];
	dodec[2] := [ -1, -1, -1];
	dodec[3] := [ -1, -1, 1];
	dodec[4] := [ -1, 1, -1];
	dodec[5] := [ -1, 1, 1 ];
	dodec[6] := [ 1, -1, -1 ];
	dodec[7] := [ 1, -1, 1 ];
	dodec[8] := [ 1, 1, -1 ];
	dodec[9] := [ 1, 1, 1 ];
	dodec[10] := [ beta, alpha, 0 ];
	dodec[11] := [ beta, -alpha, 0 ];
	dodec[12] := [ -beta, alpha, 0 ];
	dodec[13] := [ -beta, -alpha, 0 ];
	dodec[14] := [ -alpha, 0, -beta ];
	dodec[15] := [ alpha, 0, -beta];
	dodec[16] := [ 0, beta, alpha ];
	dodec[17] := [ 0, beta, -alpha];
	dodec[18] := [ 0, -beta, alpha ];
	dodec[19] := [0, -beta, -alpha ];
END InitDodecahedron;

PROCEDURE  InitTeapot;
	VAR  i: LONGINT;
BEGIN
	i := 0;
	(* rim *)
	Set16i(patchData[i], 102, 103, 104, 105, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);  INC(i);
	(* body *)
	Set16i(patchData[i], 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);  INC(i);
	Set16i(patchData[i], 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40);  INC(i);
	(* lid *)
	Set16i(patchData[i], 96, 96, 96, 96, 97, 98, 99, 100, 101, 101, 101, 101, 0, 1, 2, 3);  INC(i);
	Set16i(patchData[i], 0, 1, 2, 3, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117);  INC(i);
	(* bottom *)
	Set16i(patchData[i], 118, 118, 118, 118, 124, 122, 119, 121, 123, 126, 125, 120, 40, 39, 38, 37);  INC(i);
	(* handle *)
	Set16i(patchData[i], 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56);  INC(i);
	Set16i(patchData[i], 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 28, 65, 66, 67);  INC(i);
	(* spout *)
	Set16i(patchData[i], 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83);  INC(i);
	Set16i(patchData[i], 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95);

	i := 0;
	Set3f(cpData[i], 0.2, 0, 2.7);  INC(i);
	Set3f(cpData[i], 0.2, -0.112, 2.7);  INC(i);
	Set3f(cpData[i], 0.112, -0.2, 2.7);  INC(i);
	Set3f(cpData[i], 0,  -0.2, 2.7);  INC(i);
	Set3f(cpData[i], 1.3375, 0, 2.53125);  INC(i);
	Set3f(cpData[i], 1.3375, -0.749, 2.53125);  INC(i);
	Set3f(cpData[i], 0.749, -1.3375, 2.53125);  INC(i);
	Set3f(cpData[i], 0, -1.3375, 2.53125);  INC(i);
	Set3f(cpData[i], 1.4375, 0, 2.53125);  INC(i);
	Set3f(cpData[i], 1.4375, -0.805, 2.53125);  INC(i);
	Set3f(cpData[i], 0.805, -1.4375, 2.53125);  INC(i);
	Set3f(cpData[i], 0, -1.4375, 2.53125);  INC(i);
	Set3f(cpData[i], 1.5, 0, 2.4);  INC(i);
	Set3f(cpData[i], 1.5, -0.84, 2.4);  INC(i);
	Set3f(cpData[i], 0.84, -1.5, 2.4);  INC(i);
	Set3f(cpData[i], 0, -1.5, 2.4);  INC(i);
	Set3f(cpData[i], 1.75, 0, 1.875);  INC(i);
	Set3f(cpData[i], 1.75, -0.98, 1.875);  INC(i);
	Set3f(cpData[i], 0.98, -1.75, 1.875);  INC(i);
	Set3f(cpData[i], 0, -1.75, 1.875);  INC(i);
	Set3f(cpData[i], 2, 0, 1.35);  INC(i);
	Set3f(cpData[i], 2, -1.12, 1.35);  INC(i);
	Set3f(cpData[i], 1.12, -2, 1.35);  INC(i);
	Set3f(cpData[i], 0, -2, 1.35);  INC(i);
	Set3f(cpData[i], 2, 0, 0.9);  INC(i);
	Set3f(cpData[i], 2, -1.12, 0.9);  INC(i);
	Set3f(cpData[i], 1.12, -2, 0.9);  INC(i);
	Set3f(cpData[i], 0, -2, 0.9);  INC(i);
	Set3f(cpData[i], -2, 0, 0.9);  INC(i);
	Set3f(cpData[i], 2, 0, 0.45);  INC(i);
	Set3f(cpData[i], 2, -1.12, 0.45);  INC(i);
	Set3f(cpData[i], 1.12, -2, 0.45);  INC(i);
	Set3f(cpData[i], 0, -2, 0.45);  INC(i);
	Set3f(cpData[i], 1.5, 0, 0.225);  INC(i);
	Set3f(cpData[i], 1.5, -0.84, 0.225);  INC(i);
	Set3f(cpData[i], 0.84, -1.5, 0.225);  INC(i);
	Set3f(cpData[i], 0, -1.5, 0.225);  INC(i);
	Set3f(cpData[i], 1.5, 0, 0.15);  INC(i);
	Set3f(cpData[i], 1.5, -0.84, 0.15);  INC(i);
	Set3f(cpData[i], 0.84, -1.5, 0.15);  INC(i);
	Set3f(cpData[i], 0, -1.5, 0.15);  INC(i);
	Set3f(cpData[i], -1.6, 0, 2.025);  INC(i);
	Set3f(cpData[i], -1.6, -0.3, 2.025);  INC(i);
	Set3f(cpData[i], -1.5, -0.3, 2.25);  INC(i);
	Set3f(cpData[i], -1.5, 0, 2.25);  INC(i);
	Set3f(cpData[i], -2.3, 0, 2.025);  INC(i);
	Set3f(cpData[i], -2.3, -0.3, 2.025);  INC(i);
	Set3f(cpData[i], -2.5, -0.3, 2.25);  INC(i);
	Set3f(cpData[i], -2.5, 0, 2.25);  INC(i);
	Set3f(cpData[i], -2.7, 0, 2.025);  INC(i);
	Set3f(cpData[i], -2.7, -0.3, 2.025);  INC(i);
	Set3f(cpData[i], -3, -0.3, 2.25);  INC(i);
	Set3f(cpData[i], -3, 0, 2.25);  INC(i);
	Set3f(cpData[i], -2.7, 0, 1.8);  INC(i);
	Set3f(cpData[i], -2.7, -0.3, 1.8);  INC(i);
	Set3f(cpData[i], -3, -0.3, 1.8);  INC(i);
	Set3f(cpData[i], -3, 0, 1.8);  INC(i);
	Set3f(cpData[i], -2.7, 0, 1.575);  INC(i);
	Set3f(cpData[i], -2.7, -0.3, 1.575);  INC(i);
	Set3f(cpData[i], -3, -0.3, 1.35);  INC(i);
	Set3f(cpData[i], -3, 0, 1.35);  INC(i);
	Set3f(cpData[i], -2.5, 0, 1.125);  INC(i);
	Set3f(cpData[i], -2.5, -0.3, 1.125);  INC(i);
	Set3f(cpData[i], -2.65, -0.3, 0.9375);  INC(i);
	Set3f(cpData[i], -2.65, 0, 0.9375);  INC(i);
	Set3f(cpData[i], -2, -0.3, 0.9);  INC(i);
	Set3f(cpData[i], -1.9, -0.3, 0.6);  INC(i);
	Set3f(cpData[i], -1.9, 0, 0.6);  INC(i);
	Set3f(cpData[i], 1.7, 0, 1.425);  INC(i);
	Set3f(cpData[i], 1.7, -0.66, 1.425);  INC(i);
	Set3f(cpData[i], 1.7, -0.66, 0.6);  INC(i);
	Set3f(cpData[i], 1.7, 0, 0.6);  INC(i);
	Set3f(cpData[i], 2.6, 0, 1.425);  INC(i);
	Set3f(cpData[i], 2.6, -0.66, 1.425);  INC(i);
	Set3f(cpData[i], 3.1, -0.66, 0.825);  INC(i);
	Set3f(cpData[i], 3.1, 0, 0.825);  INC(i);
	Set3f(cpData[i], 2.3, 0, 2.1);  INC(i);
	Set3f(cpData[i], 2.3, -0.25, 2.1);  INC(i);
	Set3f(cpData[i], 2.4, -0.25, 2.025);  INC(i);
	Set3f(cpData[i], 2.4, 0, 2.025);  INC(i);
	Set3f(cpData[i], 2.7, 0, 2.4);  INC(i);
	Set3f(cpData[i], 2.7, -0.25, 2.4);  INC(i);
	Set3f(cpData[i], 3.3, -0.25, 2.4);  INC(i);
	Set3f(cpData[i], 3.3, 0, 2.4);  INC(i);
	Set3f(cpData[i], 2.8, 0, 2.475);  INC(i);
	Set3f(cpData[i], 2.8, -0.25, 2.475);  INC(i);
	Set3f(cpData[i], 3.525, -0.25, 2.49375);  INC(i);
	Set3f(cpData[i], 3.525, 0, 2.49375);  INC(i);
	Set3f(cpData[i], 2.9, 0, 2.475);  INC(i);
	Set3f(cpData[i], 2.9, -0.15, 2.475);  INC(i);
	Set3f(cpData[i], 3.45, -0.15, 2.5125);  INC(i);
	Set3f(cpData[i], 3.45, 0, 2.5125);  INC(i);
	Set3f(cpData[i], 2.8, 0, 2.4);  INC(i);
	Set3f(cpData[i], 2.8, -0.15, 2.4);  INC(i);
	Set3f(cpData[i], 3.2, -0.15, 2.4);  INC(i);
	Set3f(cpData[i], 3.2, 0, 2.4);  INC(i);
	Set3f(cpData[i], 0, 0, 3.15);  INC(i);
	Set3f(cpData[i], 0.8, 0, 3.15);  INC(i);
	Set3f(cpData[i], 0.8, -0.45, 3.15);  INC(i);
	Set3f(cpData[i], 0.45, -0.8, 3.15);  INC(i);
	Set3f(cpData[i], 0, -0.8, 3.15);  INC(i);
	Set3f(cpData[i], 0, 0, 2.85);  INC(i);
	Set3f(cpData[i], 1.4, 0, 2.4);  INC(i);
	Set3f(cpData[i], 1.4, -0.784, 2.4);  INC(i);
	Set3f(cpData[i], 0.784, -1.4, 2.4);  INC(i);
	Set3f(cpData[i], 0, -1.4, 2.4);  INC(i);
	Set3f(cpData[i], 0.4, 0, 2.55);  INC(i);
	Set3f(cpData[i], 0.4, -0.224, 2.55);  INC(i);
	Set3f(cpData[i], 0.224, -0.4, 2.55);  INC(i);
	Set3f(cpData[i], 0, -0.4, 2.55);  INC(i);
	Set3f(cpData[i], 1.3, 0, 2.55);  INC(i);
	Set3f(cpData[i], 1.3, -0.728, 2.55);  INC(i);
	Set3f(cpData[i], 0.728, -1.3, 2.55);  INC(i);
	Set3f(cpData[i], 0, -1.3, 2.55);  INC(i);
	Set3f(cpData[i], 1.3, 0, 2.4);  INC(i);
	Set3f(cpData[i], 1.3, -0.728, 2.4);  INC(i);
	Set3f(cpData[i], 0.728, -1.3, 2.4);  INC(i);
	Set3f(cpData[i], 0, -1.3, 2.4);  INC(i);
	Set3f(cpData[i], 0, 0, 0);  INC(i);
	Set3f(cpData[i], 1.425, -0.798, 0);  INC(i);
	Set3f(cpData[i], 1.5, 0, 0.075);  INC(i);
	Set3f(cpData[i], 1.425, 0, 0);  INC(i);
	Set3f(cpData[i], 0.798, -1.425, 0);  INC(i);
	Set3f(cpData[i], 0, -1.5, 0.075);  INC(i);
	Set3f(cpData[i], 0, -1.425, 0);  INC(i);
	Set3f(cpData[i], 1.5, -0.84, 0.075);  INC(i);
	Set3f(cpData[i], 0.84, -1.5, 0.075);

	Set2f(tex[0, 0], 0, 0);  Set2f(tex[0, 1], 1, 0);
	Set2f(tex[1, 0], 0, 1);  Set2f(tex[1, 1], 1, 1)
END InitTeapot;

BEGIN
	(* Tetraheron data *)
	tData[0] := [ t,  t,   t ];  tData[1] := [  t, -t, -t];
	tData[2] := [ -t,  t, -t];  tData[3] :=[ -t, -t,  t];

	Set3i(tIndex[0], 0, 1, 3);  Set3i(tIndex[1], 2, 1, 0);
	Set3i(tIndex[2], 3, 2, 0);  Set3i(tIndex[3], 1, 2, 3);

	(* Icosaheron data;  radius = 1.0 *)
	iData[0] := [ -x, 0, z];  iData[1] := [ x, 0, z];  iData[2] := [ -x, 0, -z];
	iData[3] := [ x, 0, -z];  iData[4] := [ 0, z, x];  iData[5] := [ 0, z, -x];
	iData[6] := [ 0, -z, x];  iData[7] := [ 0, -z, -x];  iData[8] := [ z, x, 0];
	iData[9]:= [ -z, x, 0];  iData[10] := [ z, -x, 0];  iData[11] := [ -z, -x, 0];

	Set3i(iIndex[0], 0, 4, 1);  Set3i(iIndex[1], 0, 9, 4);  Set3i(iIndex[2], 9, 5, 4);  Set3i(iIndex[3], 4, 5, 8);
	Set3i(iIndex[4], 4, 8, 1);  Set3i(iIndex[5], 8, 10, 1);  Set3i(iIndex[6], 8, 3, 10);  Set3i(iIndex[7], 5, 3, 8);
	Set3i(iIndex[8], 5, 2, 3);  Set3i(iIndex[9], 2, 7, 3);  Set3i(iIndex[10], 7, 10, 3);  Set3i(iIndex[11], 7, 6, 10);
	Set3i(iIndex[12], 7, 11, 6);  Set3i(iIndex[13], 11, 0, 6);  Set3i(iIndex[14], 0, 1, 6);  Set3i(iIndex[15], 6, 1, 10);
	Set3i(iIndex[16], 9, 0, 11);  Set3i(iIndex[17], 9, 11, 2);  Set3i(iIndex[18], 9, 2, 5);  Set3i(iIndex[19], 7, 2, 11);

	(* octahedron data: The octahedron produced is *)
	(* centered at the origin and has radius 1.0 *)
	oData[0] := [ 1.0, 0.0, 0.0];  oData[1] := [ -1.0, 0.0, 0.0];
	oData[2] := [ 0.0, 1.0, 0.0];  oData[3] := [ 0.0, -1.0, 0.0];
	oData[4] := [ 0.0, 0.0, 1.0];  oData[5] := [ 0.0, 0.0, -1.0];

	Set3i(oIndex[0], 0, 4, 2);  Set3i(oIndex[1], 1, 2, 4);
	Set3i(oIndex[2], 0, 3, 4);  Set3i(oIndex[3], 1, 4, 3);
	Set3i(oIndex[4], 0, 2, 5);  Set3i(oIndex[5], 1, 5, 2);
	Set3i(oIndex[6], 0, 5, 3);  Set3i(oIndex[7], 1, 3, 5);

	InitDodecahedron;

	(* Teapot data *)
	InitTeapot;

	Streams.OpenWriter(wr, KernelLog.Send);
END GLLib.

Compiler.Compile --findPC=GLLib.DrawTriangle:91 openglduzelt/GLLib.Mod ~


