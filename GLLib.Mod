MODULE  GLLib;

(*  (C)  E. Pokora, 1999.  This module is part of the Ogl subsystem - a binding of OpenGL for BlackBox Component Pascal.*)
(*  Procedures to draw the famous teapot and some 3d geometric primitives:
	cube, cone, sphere, torus, tetrahedron, octahedron, dodecahedron, icosahedron.

	uses GLU library.
*)

IMPORT  Math, gl := OpenGL, glc := OpenGLConst, glu := GLU,
		KernelLog;

CONST
	pi = 3.14159265358979323846;
	t = 1.73205080756887729;
	x = 0.525731112119133606;
	z = 0.850650808352039932;

VAR
	quadObj: glu.Quadric;
	tData: ARRAY [4, 3] OF gl.Float;
	tIndex: ARRAY [4, 3] OF gl.Int;
	iData: ARRAY [12, 3] OF gl.Float;
	iIndex: ARRAY [20,3] OF gl.Int;
	oData: ARRAY [6, 3] OF gl.Float;
	oIndex: ARRAY[8, 3] OF gl.Int;
	dodec: ARRAY [20,3]  OF gl.Float;

	(* Teapot data *)
	patchData: ARRAY [10, 16] OF gl.Int;
	cpData: ARRAY [127, 3] OF gl.Float;
	tex: ARRAY [2, 2, 2] OF gl.Float;


PROCEDURE  InitQuadObj;
BEGIN
	IF quadObj = 0 THEN quadObj := glu.NewQuadric() END;
	ASSERT(quadObj # 0, 60)
END InitQuadObj;

PROCEDURE  Set2f (VAR a: ARRAY [2] OF gl.Float;  a0, a1: REAL);
BEGIN
	a[0] := a0;  a[1] := a1
END Set2f;

PROCEDURE  Set3f (VAR a: ARRAY [3] OF gl.Float;  a0, a1, a2: REAL);
BEGIN
	a[0] := a0;  a[1] := a1;  a[2] := a2
END Set3f;

PROCEDURE  Set16i (VAR a: ARRAY [16] OF gl.Int;
							a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15: LONGINT);
BEGIN
	a[0] := a0;  a[1] := a1;  a[2] := a2;  a[3] := a3;
	a[4] := a4;  a[5] := a5;  a[6] := a6;  a[7] := a7;
	a[8] := a8;  a[9] := a9;  a[10] := a10;  a[11] := a11;
	a[12] := a12;  a[13] := a13;  a[14] := a14;  a[15] := a15
END Set16i;

PROCEDURE Cross (CONST a, b: ARRAY [3] OF gl.Float;  VAR c: ARRAY [3] OF gl.Float);
BEGIN
	c[0] := a[1] * b[2] - a[2] * b[1];
	c[1] := a[2] * b[0] - a[0] * b[2];
	c[2] := a[0] * b[1] - a[1] * b[0]
END Cross;

PROCEDURE NormalizeV (VAR v: ARRAY [3] OF gl.Float);
	VAR d: gl.Float;
BEGIN
	d := Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
	IF d # 0 THEN
		d := 1.0 / d;
		v[0] := d * v[0];  v[1] := d * v[1];  v[2] := d * v[2]
	ELSE
		KernelLog.String("GLLib: attempt to normalize zero length vector"); KernelLog.Ln;
		v[0] := 1
	END
END NormalizeV;

PROCEDURE  DrawBox (size: gl.Float;  type: gl.Enum);
VAR  n: ARRAY [6,3] OF gl.Float;  faces: ARRAY [6,4] OF gl.Int;
	v: ARRAY [8,3] OF gl.Float;
	i: LONGINT;  s: gl.Float;
BEGIN
	n := [ 	[ -1.0, 0.0, 0.0], [ 0.0, 1.0, 0.0], [ 1.0, 0.0, 0.0],
			[ 0.0, -1.0, 0.0],	[ 0.0, 0.0, 1.0], 	[ 0.0, 0.0, -1.0]	];

	faces := [ [ 0, 1, 2, 3], [ 3, 2, 6, 7], [ 7, 6, 5, 4],
			[ 4, 5, 1, 0],	[ 5, 6, 2, 1], 	[ 7, 4, 0, 3]	];

	s := size / 2.0;
	v := [ [ -s, -s, -s ],  [ -s, -s, s], [ -s, s, s], [ -s, s, -s ],
		[  s, -s, -s ],  [  s, -s,  s ], [  s, s, s ], [  s, s, -s ]];

	FOR  i := 5 TO 0 BY -1 DO
		gl.Begin(type);
			gl.Normal3fv(n[i]);
			gl.Vertex3fv( v[ faces[i, 0] ]);
			gl.Vertex3fv( v[faces[i, 1] ]);
			gl.Vertex3fv( v[faces[i, 2] ]);
			gl.Vertex3fv( v[faces[i, 3] ]);
		gl.End
	END;
END DrawBox;

PROCEDURE  WireCube* (size: REAL);
BEGIN
	DrawBox(size, glc.GL_LINE_LOOP)
END WireCube;

PROCEDURE  SolidCube* (size: REAL);
BEGIN
	DrawBox(size, glc.GL_QUADS)
END SolidCube;

PROCEDURE  WireSphere* (radius: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_LINE);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Sphere(quadObj, radius, slices, stacks)
END WireSphere;

PROCEDURE SolidSphere* (radius: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_FILL);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Sphere(quadObj, radius, slices, stacks)
END SolidSphere;


(** baseradius at z=0, topradius at x=height *)
PROCEDURE WireCylinder* (baseradius, topradius, height: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_LINE);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Cylinder(quadObj, baseradius, topradius, height, slices, stacks)
END WireCylinder;

(** baseradius at z=0, topradius at x=height *)
PROCEDURE SolidCylinder* (baseradius, topradius, height: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_FILL);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Cylinder(quadObj, baseradius, topradius, height, slices, stacks)
END SolidCylinder;

PROCEDURE WireCone* (base, height: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_LINE);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Cylinder(quadObj, base, 0.0, height, slices, stacks);
END WireCone;

PROCEDURE  SolidCone* (base, height: REAL;  slices, stacks: LONGINT);
BEGIN
	InitQuadObj;
	glu.QuadricDrawStyle(quadObj, glu.GLU_FILL);
	glu.QuadricNormals(quadObj, glu.GLU_SMOOTH);
	glu.Cylinder(quadObj, base, 0.0, height, slices, stacks);
END SolidCone;

PROCEDURE Torus (r, R: REAL;  nsides, rings: LONGINT);
VAR  i, j: LONGINT;
	theta, phi, theta1, cosPhi, sinPhi, dist, cosTheta, sinTheta,
	cosTheta1, sinTheta1, ringDelta, sideDelta: REAL;
BEGIN
	ringDelta := 2.0 * pi / rings;  sideDelta := 2.0 * pi / nsides;
	theta := 0.0;  cosTheta := 1.0;  sinTheta := 0.0;

	FOR i := rings - 1 TO 0 BY -1 DO
		theta1 := theta + ringDelta;
		cosTheta1 := Math.cos(theta1);   sinTheta1 := Math.sin(theta1);
		gl.Begin(glc.GL_QUAD_STRIP);
			phi := 0.0;
			FOR  j := nsides TO 0 BY -1 DO
				phi := phi + sideDelta;
				cosPhi := Math.cos(phi);  sinPhi := Math.sin(phi);
				dist := R + r * cosPhi;

				gl.Normal3f(cosTheta1 * cosPhi, -sinTheta1 * cosPhi, sinPhi);
				gl.Vertex3f(cosTheta1 * dist, -sinTheta1 * dist, r * sinPhi);
				gl.Normal3f(cosTheta * cosPhi, -sinTheta * cosPhi, sinPhi);
				gl.Vertex3f(cosTheta * dist, -sinTheta * dist,  r * sinPhi);
			END;
		gl.End;
		theta := theta1;
		cosTheta := cosTheta1;  sinTheta := sinTheta1;
	END
END Torus;

PROCEDURE  WireTorus* (innerRadius, outerRadius: REAL;  nsides, rings: LONGINT);
BEGIN
	gl.PushAttrib(glc.GL_POLYGON_BIT);
	gl.PolygonMode(glc.GL_FRONT_AND_BACK, glc.GL_LINE);
	Torus(innerRadius, outerRadius, nsides, rings);
	gl.PopAttrib
END WireTorus;

PROCEDURE  SolidTorus* (innerRadius, outerRadius: REAL;  nsides, rings: LONGINT);
BEGIN
	Torus(innerRadius, outerRadius, nsides, rings)
END SolidTorus;

PROCEDURE RecordItem (VAR n1, n2, n3: ARRAY [3] OF gl.Float;  shadeType: gl.Enum);
VAR  q0, q1: ARRAY [3] OF gl.Float;
BEGIN
	q0 := n1 -n2;
	q1 := n2 -n3;
	Cross(q0, q1, q1);  NormalizeV(q1);

	gl.Begin(shadeType);
		gl.Normal3fv(q1);
		gl.Vertex3fv(n1);
		gl.Vertex3fv(n2);
		gl.Vertex3fv(n3);
	gl.End
END RecordItem;

PROCEDURE  Subdivide (CONST v0, v1, v2: ARRAY [3] OF gl.Float;  shadeType: gl.Enum);
VAR  depth, i, j, k, n: LONGINT;
	w0, w1, w2: ARRAY [3] OF gl.Float;
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

PROCEDURE DrawTriangle (i: LONGINT; VAR data: ARRAY [*,3] OF gl.Float;  VAR ndx: ARRAY [*,3] OF gl.Int; shadeType: gl.Enum);
BEGIN
	Subdivide(data[ndx[i, 0]], data[ndx[i, 1]], data[ndx[i, 2]], shadeType)
END DrawTriangle;

PROCEDURE  DrawTetrahedron (shadeType: gl.Enum);
	VAR  i: LONGINT;
BEGIN
	FOR  i := 3 TO 0 BY -1 DO
		DrawTriangle(i, tData, tIndex, shadeType)
	END
END DrawTetrahedron;

PROCEDURE  WireTetrahedron*;
BEGIN
	DrawTetrahedron(glc.GL_LINE_LOOP)
END WireTetrahedron;

PROCEDURE  SolidTetrahedron*;
BEGIN
	DrawTetrahedron(glc.GL_TRIANGLES)
END SolidTetrahedron;

PROCEDURE DrawIcosahedron (shadeType: gl.Enum);
VAR  i: LONGINT;
BEGIN
	FOR  i := 19 TO 0 BY -1 DO
		DrawTriangle(i, iData, iIndex, shadeType)
	END
END DrawIcosahedron;

PROCEDURE  WireIcosahedron* ;
BEGIN
	DrawIcosahedron(glc.GL_LINE_LOOP)
END WireIcosahedron;

PROCEDURE  SolidIcosahedron* ;
BEGIN
	DrawIcosahedron(glc.GL_TRIANGLES)
END SolidIcosahedron;

PROCEDURE  DrawTeapot (grid: gl.Int;  scale: gl.Float;  type: gl.Enum);
VAR  i, j, k, l: LONGINT;  p, q, r, s: ARRAY [4, 4, 3] OF gl.Float;
BEGIN
	gl.PushAttrib(glc.GL_ENABLE_BIT + glc.GL_EVAL_BIT);
	gl.Enable(glc.GL_AUTO_NORMAL);
	gl.Enable(glc.GL_NORMALIZE);
	gl.Enable(glc.GL_MAP2_VERTEX_3);
	gl.Enable(glc.GL_MAP2_TEXTURE_COORD_2);
	gl.PushMatrix;

	gl.Rotatef(270.0, 1.0, 0.0, 0.0);
	gl.Scalef(0.5 * scale, 0.5 * scale, 0.5 * scale);
	gl.Translatef(0.0, 0.0, -1.5);

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

		gl.Map2f(glc.GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, ADDRESSOF(tex[0, 0, 0]));
		gl.Map2f(glc.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(p[0, 0, 0]));
		gl.MapGrid2f(grid, 0, 1, grid, 0, 1);
		gl.EvalMesh2(type, 0, grid, 0, grid);
		gl.Map2f(glc.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(q[0, 0, 0]));
		gl.EvalMesh2(type, 0, grid, 0, grid);
		IF  i < 6 THEN
			gl.Map2f(glc.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(r[0, 0, 0]));
			gl.EvalMesh2(type, 0, grid, 0, grid);
			gl.Map2f(glc.GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, ADDRESSOF(s[0, 0, 0]));
			gl.EvalMesh2(type, 0, grid, 0, grid)
		END
	END;

	gl.PopMatrix;
	gl.PopAttrib
END DrawTeapot;


PROCEDURE  SolidTeapot* (scale: REAL);
BEGIN
	DrawTeapot(14, scale, glc.GL_FILL)
END SolidTeapot;

PROCEDURE  WireTeapot* (scale: REAL);
BEGIN
	DrawTeapot(10, scale, glc.GL_LINE)
END WireTeapot;

PROCEDURE DrawOctahedron (shadeType: gl.Enum);
VAR  i: LONGINT;
BEGIN
	FOR  i := 7 TO 0 BY -1 DO
		DrawTriangle(i, oData, oIndex, shadeType)
	END
END DrawOctahedron;

PROCEDURE  WireOctahedron* ;
BEGIN
	DrawOctahedron(glc.GL_LINE_LOOP)
END WireOctahedron;

PROCEDURE  SolidOctahedron* ;
BEGIN
	DrawOctahedron(glc.GL_TRIANGLES)
END SolidOctahedron;

PROCEDURE  DrawPentagon (a, b, c, d, e: LONGINT;  shadeType: gl.Enum);
VAR  n, d1, d2: ARRAY [3] OF gl.Float;
BEGIN
	d1 := dodec[a] - dodec[b];
	d2 := dodec[b] - dodec[c];
	Cross(d1, d2, n);  NormalizeV(n);

	gl.Begin(shadeType);
		gl.Normal3fv( n);
		gl.Vertex3fv( dodec[a]);
		gl.Vertex3fv( dodec[b]);
		gl.Vertex3fv( dodec[c]);
		gl.Vertex3fv( dodec[d]);
		gl.Vertex3fv(dodec[e]);
	gl.End
END DrawPentagon;

PROCEDURE  DrawDodecahedron (type: gl.Enum);
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
	DrawDodecahedron(glc.GL_LINE_LOOP)
END WireDodecahedron;

PROCEDURE  SolidDodecahedron* ;
BEGIN
	DrawDodecahedron(glc.GL_TRIANGLE_FAN)
END SolidDodecahedron;

PROCEDURE  InitDodecahedron;
VAR  alpha, beta: REAL;
BEGIN
	alpha := Math.sqrt(2.0 / (3.0 + Math.sqrt(5.0)));
	beta := 1.0 + Math.sqrt(6.0 / (3.0 + Math.sqrt(5.0)) -
			  2.0 + 2.0 * Math.sqrt(2.0 / (3.0 + Math.sqrt(5.0))));

	dodec := [ [ -alpha, 0, beta], [ alpha, 0, beta], [ -1.0, -1, -1],
	[ -1.0, -1, 1], [ -1.0, 1, -1],	[ -1.0, 1, 1 ],
	[ 1.0, -1, -1 ], [ 1.0, -1, 1 ], 	[ 1.0, 1, -1 ],
	 [ 1.0, 1, 1 ], [ beta, alpha, 0 ], [ beta, -alpha, 0 ],
	[ -beta, alpha, 0 ], [ -beta, -alpha, 0 ], [ -alpha, 0, -beta ],
	[ alpha, 0, -beta], [ 0, beta, alpha ], [ 0, beta, -alpha],
	[ 0, -beta, alpha ], [0, -beta, -alpha ]  ];
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

	tData := [ [ t,  t,   t ], [  t, -t, -t], [ -t,  t, -t], [ -t, -t,  t] ];
	tIndex := [ [0, 1, 3], [2, 1, 0], [3, 2, 0], [1, 2, 3] ];

	(* Icosaheron data;  radius = 1.0 *)
	iData := 	[ [ -x, 0, z],  [ x, 0, z],  [ -x, 0, -z],
				[ x, 0, -z], [ 0, z, x], [ 0, z, -x],
				[ 0, -z, x], [ 0, -z, -x], [ z, x, 0],
				[ -z, x, 0], [ z, -x, 0], [ -z, -x, 0]];

	iIndex := [ 	[ 0, 4, 1], [0, 9, 4], [ 9, 5, 4], [4, 5, 8],
				[4, 8, 1], [8, 10, 1], [8, 3, 10], [ 5, 3, 8],
				[5, 2, 3], [2, 7, 3], [7, 10, 3], [7, 6, 10],
				[7, 11, 6], [11, 0, 6], [0, 1, 6], [ 6, 1, 10],
				[9, 0, 11], [9, 11, 2], [9, 2, 5], [7, 2, 11] ];

	(* octahedron data: The octahedron produced is *)
	(* centered at the origin and has radius 1.0 *)
	oData := [ 	[ 1.0, 0.0, 0.0], [ -1.0, 0.0, 0.0],
				[ 0.0, 1.0, 0.0], [ 0.0, -1.0, 0.0],
				[ 0.0, 0.0, 1.0], [ 0.0, 0.0, -1.0] ];

	oIndex := [	[0, 4, 2], [1, 2, 4], [ 0, 3, 4], [1, 4, 3],
				[0, 2, 5], [1, 5, 2], [0, 5, 3], [1, 3, 5] ];

	InitDodecahedron;

	(* Teapot data *)
	InitTeapot;

END GLLib.

