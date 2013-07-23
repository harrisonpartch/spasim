MODULE Serp;
IMPORT XNPSBase, Random,  XNPSE, Out:=DebugLog;

CONST POS = TRUE;
CONST NEG = FALSE;

TYPE PT= XNPSBase.PT;
TYPE Ray=XNPSBase.Ray;
TYPE Voxel = XNPSBase.Voxel;
TYPE COLOR = XNPSBase.COLOR;


TYPE Bloc3* = OBJECT(Voxel);
VAR
	blox*: ARRAY 3,3,3 OF Voxel;
	airred, airgreen, airblue, airblack: REAL;
	
PROCEDURE&Init;
BEGIN
	NEW(imposter);
END Init;
	
PROCEDURE bounds* (i, j, k: LONGINT; VAR out: BOOLEAN);
BEGIN
	IF (i < 0) OR (i > 2) OR (j < 0) OR (j > 2) OR (k < 0) OR (k > 2) THEN
		out := TRUE
	ELSE
		out := FALSE
	END
END bounds;

PROCEDURE flipx*;
VAR
	b: ARRAY 3,3,3 OF Voxel;
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		b[2-i,j,k] := blox[i,j,k];
	END END END;
		FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		blox[i,j,k] := b[i,j,k];
	END END END;
END flipx;

PROCEDURE flipy*;
VAR
	b: ARRAY 3,3,3 OF Voxel;
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		b[i,2-j,k] := blox[i,j,k];
	END END END;
		FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		blox[i,j,k] := b[i,j,k];
	END END END;
END flipy;

PROCEDURE flipz*;
VAR
	b: ARRAY 3,3,3 OF Voxel;
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		b[i,j,2-k] := blox[i,j,k];
	END END END;
		FOR i := 0 TO 2  DO FOR j := 0 TO 2 DO FOR k := 0 TO 2 DO 
		blox[i,j,k] := b[i,j,k];
	END END END;
END flipz;

PROCEDURE fill(v: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
FOR i:=0 TO 2 DO FOR j:=0 TO 2 DO FOR k:=0 TO 2 DO
	blox[i,j,k]:=v
END END END
END fill;

PROCEDURE fillSerp*(v,w: Voxel);
BEGIN
	fill(v);
	blox[1,1,0]:=w;
	blox[1,0,1]:=w;
	blox[0,1,1]:=w;
	blox[1,1,1]:=w;
	blox[1,1,2]:=w;
	blox[1,2,1]:=w;
	blox[2,1,1]:=w;
END fillSerp;

PROCEDURE tick;
VAR
	i, j, k, ii, jj, kk: LONGINT;
	m,n: LONGINT;
	v: Voxel;
BEGIN
	n := rand.Dice(3);
	FOR i := 0 TO n DO
		i := rand.Dice(3); 
		j := rand.Dice(3);
		k := rand.Dice(3);
		ii := rand.Dice(3); 
		jj := rand.Dice(3);
		kk := rand.Dice(3);
		v := blox[i, j, k];
		blox[i, j, k] := blox[ii, jj, kk];
		blox[ii, jj, kk] := v;
	END;
END tick;

PROCEDURE probe(x,y,z: REAL):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	XNPSBase.clamp3(x,y,z);
	X := x*3; Y := y*3; Z := z*3;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]=NIL THEN 
		RETURN(SELF)
	ELSE
		RETURN(blox[i,j,k].probe(X-i, Y-j, Z-k)) 
	END
END probe;

PROCEDURE passprobe(x,y,z: REAL):BOOLEAN;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	XNPSBase.clamp3(x,y,z);
	X := x*3; Y := y*3; Z := z*3;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]=NIL THEN 
		RETURN(passable)
	ELSE
		RETURN(blox[i,j,k].passprobe(X-i, Y-j, Z-k)) 
	END
END passprobe;

PROCEDURE Shade (VAR ray: Ray);
VAR
	oldxyz, newxyz: XNPSBase.PT;
	ijk: XNPSBase.IPT;
	drx, dry, drz, dr, vdepth,rr,gr,br,bl: REAL;
	iter, di, dj, dk: INTEGER;
	out, shadenil,done,A,B,C: BOOLEAN;
	v: Voxel;
	lx, ly, lz, distance: REAL;
BEGIN	
	IF ray.length*ray.scale>125 THEN
		imposter.Shade(ray)
	ELSE
		ray.scale := ray.scale*3;
		oldxyz := ray.xyz;
		ray.xyz.x := ray.lxyz.x * 3  - ray.dxyz.x / 1000000 ;
		ray.xyz.y := ray.lxyz.y * 3  - ray.dxyz.y / 1000000 ;		
		ray.xyz.z := ray.lxyz.z * 3  - ray.dxyz.z / 1000000 ; 
		XNPSE.E(ray.xyz,ijk);
		bounds(ijk.i,ijk.j,ijk.k, out);
		ray.changed:=FALSE;
		IF ~out THEN
			v := blox[ijk.i,ijk.j,ijk.k];
			IF  v # NIL THEN
				ray.lxyz.x := ABS(ray.xyz.x - ijk.i);
				ray.lxyz.y := ABS(ray.xyz.y - ijk.j);
				ray.lxyz.z := ABS(ray.xyz.z - ijk.k);
				v.Shade(ray);
			ELSE
				shadenil:=TRUE
			END
		END;
		IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;	
		IF ~ray.terminate & ~ray.changed THEN REPEAT
			ray.changed := FALSE;
			IF ray.dxyz.x < 0 THEN di := - 1  ELSE di := 1 END;
			IF ray.dxyz.y < 0 THEN dj := - 1  ELSE dj := 1 END;
			IF ray.dxyz.z< 0 THEN dk := - 1  ELSE dk := 1 END;
			REPEAT
				IF di > 0 THEN
					drx := ( (ijk.i + 1) - ray.xyz.x) / ray.dxyz.x
				ELSE
					drx :=  (ijk.i -  ray.xyz.x) / ray.dxyz.x
				END;
				IF dj > 0 THEN
					dry := ( (ijk.j + 1) - ray.xyz.y) / ray.dxyz.y
				ELSE
					dry :=  (ijk.j - ray.xyz.y) / ray.dxyz.y
				END;
				IF dk > 0 THEN
					drz := ( (ijk.k + 1) - ray.xyz.z) / ray.dxyz.z
				ELSE
					drz :=  (ijk.k - ray.xyz.z) / ray.dxyz.z
				END;
				A:=drx<dry; B:=drx<drz; C:=dry<drz;	
								IF A&B THEN
					dr := drx;
					INC(ijk.i, di);
					IF di > 0 THEN 
						ray.face := 1; ray.normal:= XNPSBase.Face[0] 
					ELSE 
						ray.face := 4; ray.normal:= XNPSBase.Face[3] 
					END;
					newxyz.x := ray.xyz.x + drx * ray.dxyz.x; newxyz.y := ray.xyz.y + drx * ray.dxyz.y; newxyz.z  := ray.xyz.z + drx * ray.dxyz.z	
				ELSIF A&~B THEN
					dr := drz;
					INC(ijk.k, dk);
					IF dk > 0 THEN 
						ray.face := 3; ray.normal:= XNPSBase.Face[2] 
					ELSE
						ray.face := 6; ray.normal:= XNPSBase.Face[5]
					END;
					newxyz.x := ray.xyz.x + drz * ray.dxyz.x; newxyz.y := ray.xyz.y + drz * ray.dxyz.y; newxyz.z  := ray.xyz.z + drz * ray.dxyz.z
				ELSIF C THEN
					dr := dry;
					INC(ijk.j, dj);
					IF dj > 0 THEN 
						ray.face := 2; ray.normal:= XNPSBase.Face[1] 
					ELSE 
						ray.face := 5; ray.normal:= XNPSBase.Face[4] 
					END;
					newxyz.x := ray.xyz.x + dry * ray.dxyz.x; newxyz.y := ray.xyz.y + dry * ray.dxyz.y; newxyz.z  := ray.xyz.z+ dry * ray.dxyz.z
				ELSE
					dr := drz;
					INC(ijk.k, dk);
					IF dk > 0 THEN 
						ray.face := 3; ray.normal:= XNPSBase.Face[2] 
					ELSE
						ray.face := 6; ray.normal:= XNPSBase.Face[5]
					END;
					newxyz.x := ray.xyz.x + drz * ray.dxyz.x; newxyz.y := ray.xyz.y + drz * ray.dxyz.y; newxyz.z  := ray.xyz.z + drz * ray.dxyz.z
				END;					
				vdepth:=XNPSBase.distance(newxyz,ray.xyz);
				ray.length:=ray.length+vdepth/ray.scale;
				ray.xyz:=newxyz;
				IF shadenil THEN
					rr := ray.ra*airred*vdepth; gr := ray.ga*airgreen*vdepth; br := ray.ba*airblue*vdepth; bl:=airblack*vdepth;
	 				ray.r := ray.r + rr;
					ray.g:= ray.g + gr;
					ray.b := ray.b + br;
					ray.ra := ray.ra -rr - bl;
					ray.ga := ray.ga -gr -bl;
					ray.ba := ray.ba -br -bl;
					shadenil:=FALSE
				END;
				bounds(ijk.i,ijk.j,ijk.k, out);
				IF ~out THEN
					v := blox[ijk.i,ijk.j,ijk.k];
					IF v # NIL THEN 
						ray.lxyz.x := ABS(ray.xyz.x - ijk.i);
						ray.lxyz.y := ABS(ray.xyz.y - ijk.j);
						ray.lxyz.z := ABS(ray.xyz.z - ijk.k);
						v.Shade(ray);
					ELSE
						shadenil:=TRUE
					END
				END;
				IF (ray.ra<0.01)OR(ray.ga<0.01)OR(ray.ba<0.01) THEN ray.terminate:=TRUE END;				
			UNTIL   ray.terminate OR out OR ray.changed;
		UNTIL  ray.terminate OR out;		
	END END;
	ray.scale := ray.scale/3;
	ray.xyz := oldxyz;
END Shade;

END Bloc3;

VAR
	rand: Random.Generator;

PROCEDURE pdiv(VAR p:PT; d:REAL);
BEGIN
	p.x:=p.x*d;
	p.y:=p.y*d;
	p.z:=p.z*d;
END pdiv;
	
	
BEGIN
	NEW(rand);
END Serp.




