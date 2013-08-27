MODULE Nrdvolvox;

IMPORT Base, XNXLE, XNXLFRep;

CONST	
	M=20;
	A = 80;
	B = 20;
	C = 0.03;

TYPE
	PT=Base.PT;
	Voxel=Base.Voxel;
	Ray=Base.Ray;
	
TYPE RDVolVox*=OBJECT(Base.Voxel);
VAR
	m1*,m2,n1,n2: ARRAY M,M,M OF REAL;
	gen: INTEGER;
	i:LONGINT;
	tock*: INTEGER;
	BLUE: Voxel;
	RED: Voxel;
	YELLOW: Voxel;
	frame: LONGINT;

PROCEDURE &init*(red,blue,yellow: Voxel);
BEGIN
	RED := red;
	BLUE := blue;
	YELLOW:= yellow;
	IF RED=NIL THEN NEW(RED) END;
	IF BLUE=NIL THEN NEW(BLUE) END;	
	IF YELLOW=NIL THEN NEW(YELLOW) END;
	clere;
	seed;
	register; 
	tock := 1;
END init;
			
PROCEDURE clere*;
VAR
	i,j,k:LONGINT;
BEGIN								
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			FOR k := 0 TO M - 1 DO
				m1[i, j,k] := 0;
				m2[i, j,k] := 0;
				n1[i, j,k] := 0;
				n2[i, j,k] := 0
			END
		END
	END;
	gen := 0;
END clere;

PROCEDURE seed*;
VAR
	i,j,k:LONGINT;
BEGIN								
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			FOR k := 0 TO M - 1 DO
				IF (i*j+k)MOD 43= 0 THEN m1[i, j,k] := 0.3  END 
			END
		END
	END;
END seed;

PROCEDURE bounds (i, j, k: LONGINT; VAR out: BOOLEAN);
BEGIN
	IF (i < 0) OR (i > M-1) OR (j < 0) OR (j > M-1) OR (k < 0) OR (k > M-1) THEN
		out := TRUE
	ELSE
		out := FALSE
	END
END bounds;

PROCEDURE tick;
VAR
		i, j,k: LONGINT;
		nx1, nx2: REAL;
		A1, B1, C1, D1: REAL;
BEGIN
	INC(frame);
	FOR i := 0 TO M-1 DO
		FOR j := 0 TO M-1   DO
			FOR k := 0 TO M-1  DO
				n1[i, j,k] :=  m1[(i - 1)MOD M, j, k] +  m1[(i + 1)MOD M, j, k] + m1[i, (j - 1)MOD M, k] + m1[i, (j + 1)MOD M, k]
				 + m1[i,j, (k-1)MOD M] +  m1[i, j, (k+1)MOD M];
			END
		END
	END;
	C1 := C;
	D1 := 1;
	IF D1 < 0 THEN D1 := 0 END;
	A1 := A;
	B1 := B;
	FOR i := 0 TO M-1 DO
		A1 := A + i/10;
		B1 := B; 
		FOR j := 0 TO M-1 DO
			B1 := B1 + 0.08;
			FOR k := 0 TO M-1 DO
				(*  HERE ARE THE DIFFERENCE RULES! *)
				m1[i, j, k] := m1[i, j, k] + (n1[i, j, k] /A1 - m2[i, j, k])*D1;  
				m2[i, j, k] := m2[i, j, k] +  (m1[i, j, k] /B1 - C1);
				IF m1[i, j, k] < 0 THEN m1[i, j, k] := 0 END;
				IF m2[i, j, k] < 0 THEN m2[i, j, k] := 0 END;
				IF m1[i, j, k] > 1 THEN m1[i, j, k] := 1 END;
				IF m2[i, j, k] > 1 THEN m2[i, j, k] := 1 END;
			END
		END;
	END;
 END tick;

PROCEDURE Shade (VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: Base.PT;
	ijk: Base.IPT;
	drx, dry, drz, dr,rr,gr,br,blr,bla: REAL;
	scaleInv:REAL; 
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth: REAL;
	last:BOOLEAN;
	dtl:REAL;	
	color: LONGINT;
BEGIN
	ray.scale := ray.scale*M;
	scaleInv := 1/ray.scale;
	xyz.x := ABS(ray.lxyz.x-offset.x) * M  - ray.ddxyz.x;  
	xyz.y := ABS(ray.lxyz.y-offset.y) * M  - ray.ddxyz.y;		
	xyz.z := ABS(ray.lxyz.z-offset.z)* M  - ray.ddxyz.z;	
	pushxyz:=xyz;	
	IF (ray.length*ray.scale>ray.dtl) THEN
		IF imposter#NIL THEN
			imposter.Shade(ray)
		END	
	ELSE	
	XNXLE.E(xyz,ijk);
	bounds(ijk.i,ijk.j,ijk.k,out);
	IF ~out THEN
		ray.lxyz.x := ABS(xyz.x - ijk.i);
		ray.lxyz.y := ABS(xyz.y - ijk.j);
		ray.lxyz.z := ABS(xyz.z - ijk.k);
		ray.popdelta := Base.Origin; 
		color := ENTIER(10*m1[ijk.i,ijk.j,ijk.k]);
		CASE color OF
			0: RED.Shade(ray)
			|1: RED.Shade(ray)
			|2: RED.Shade(ray)
			|3: YELLOW.Shade(ray)
			|4: BLUE.Shade(ray)
			|5: YELLOW.Shade(ray)
			|6: BLUE.Shade(ray)
			|7: YELLOW.Shade(ray)
			|8: BLUE.Shade(ray)
			|9: YELLOW.Shade(ray)
		ELSE
			RED.Shade(ray)
		END;
		xyz.x := xyz.x + ray.popdelta.x;    
		xyz.y := xyz.y + ray.popdelta.y;
		xyz.z := xyz.z + ray.popdelta.z;
	END;	 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;	
	IF ~ray.terminate THEN
		REPEAT
			IF ray.di  THEN
				drx := ( (ijk.i + 1) - xyz.x) / ray.dxyz.x
			ELSE
				drx :=  (ijk.i -  xyz.x) / ray.dxyz.x
			END;
			IF ray.dj THEN
				dry := ( (ijk.j + 1) - xyz.y) / ray.dxyz.y
			ELSE
				dry :=  (ijk.j - xyz.y) / ray.dxyz.y
			END;
			IF ray.dk  THEN
				drz := ( (ijk.k + 1) - xyz.z) / ray.dxyz.z
			ELSE
				drz :=  (ijk.k - xyz.z) / ray.dxyz.z
			END;
			A:=drx<dry; B:=drx<drz; C:=dry<drz;	
			IF A&B THEN
				dr := drx;
				IF ray.di THEN 
					INC(ijk.i, 1);
					ray.face := 0; ray.fnormal:= Base.Face[0] 
				ELSE 
					INC(ijk.i, -1);
					ray.face := 3; ray.fnormal:= Base.Face[3] 
				END;
				newxyz.x := xyz.x + drx * ray.dxyz.x; newxyz.y := xyz.y + drx * ray.dxyz.y; newxyz.z  := xyz.z + drx * ray.dxyz.z	
			ELSIF A&~B THEN
				dr := drz;
				IF ray.dk THEN 
					INC(ijk.k, 1);
					ray.face := 2; ray.fnormal:= Base.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 5; ray.fnormal:= Base.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			ELSIF C THEN
				dr := dry;
				IF ray.dj THEN 
					INC(ijk.j, 1);
					ray.face := 1; ray.fnormal:= Base.Face[1] 
				ELSE 
					INC(ijk.j, -1);
					ray.face := 4; ray.fnormal:= Base.Face[4] 
				END;
				newxyz.x := xyz.x + dry * ray.dxyz.x; newxyz.y := xyz.y + dry * ray.dxyz.y; newxyz.z  := xyz.z+ dry * ray.dxyz.z
			ELSE
				dr := drz;		
				IF ray.dk  THEN 
					INC(ijk.k, 1);
					ray.face := 2; ray.fnormal:= Base.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 5; ray.fnormal:= Base.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			END;
			ray.len.x:=ray.len.x+ABS(newxyz.x-xyz.x)*scaleInv;
			ray.len.y:=ray.len.y+ABS(newxyz.y-xyz.y)*scaleInv;
			ray.len.z:=ray.len.z+ABS(newxyz.z-xyz.z)*scaleInv;		
			vdepth:=Base.distance(newxyz,xyz)*scaleInv; 
			ray.xyz.x:=ray.xyz.x +((newxyz.x-xyz.x)+ray.ddxyz.x)*scaleInv;
			ray.xyz.y:=ray.xyz.y +((newxyz.y-xyz.y)+ray.ddxyz.y)*scaleInv;			
			ray.xyz.z:=ray.xyz.z +((newxyz.z-xyz.z)+ray.ddxyz.z)*scaleInv;			
			xyz:=newxyz;
			ray.length:=ray.length+vdepth;
			rr := red*vdepth*ray.ra; gr := green*vdepth*ray.ga; br := blue*vdepth*ray.ba; blr:=black*vdepth; bla:=alpha*vdepth;
			ray.r := ray.r+rr;
			ray.g:= ray.g+gr;
			ray.b := ray.b+br; 
			ray.ra := (ray.ra-rr)-blr;
			ray.ga := (ray.ga-gr)-blr;
			ray.ba := (ray.ba-br)-blr; 	
			ray.bla := ray.bla-bla; 		
			bounds(ijk.i,ijk.j,ijk.k, out);
			IF ~out THEN
				ray.lxyz.x := ABS(xyz.x - ijk.i);
				ray.lxyz.y := ABS(xyz.y - ijk.j);
				ray.lxyz.z := ABS(xyz.z - ijk.k);
				ray.popdelta := Base.Origin; 
				color := ENTIER(10*m1[ijk.i,ijk.j,ijk.k]);
				CASE color OF
					0: RED.Shade(ray)
					|1: RED.Shade(ray)
					|2: RED.Shade(ray)
					|3: YELLOW.Shade(ray)
					|4: BLUE.Shade(ray)
					|5: YELLOW.Shade(ray)
					|6: BLUE.Shade(ray)
					|7: YELLOW.Shade(ray)
					|8: BLUE.Shade(ray)
					|9: YELLOW.Shade(ray)
				ELSE
					RED.Shade(ray)
				END;
				xyz.x := xyz.x + ray.popdelta.x;    
				xyz.y := xyz.y + ray.popdelta.y;
				xyz.z := xyz.z + ray.popdelta.z;
			END;		
		IF (ray.bla<0.1)OR((ray.ra<0.01)OR(ray.ga<0.01)OR(ray.ba<0.01))THEN ray.terminate:=TRUE END;
		UNTIL  out OR ray.terminate;
	END 	
	END;
			ray.popdelta.x := (xyz.x-pushxyz.x)/M;
			ray.popdelta.y := (xyz.y-pushxyz.y)/M;
			ray.popdelta.z := (xyz.z-pushxyz.z)/M; 
			ray.scale := ray.scale/M;
END Shade;

END RDVolVox;

VAR
	vox: RDVolVox; 
	r,b,y: Base.Voxel;
	center: Base.PT;
	ball: XNXLFRep.sphere;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN vox
END thisvox;

BEGIN
	r:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU342"); 	
	b:=Base.VoxelFromName("NIXARXB2vH6ieKZmsc6mODh");
	y:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ");
	NEW(vox,r,NIL,b);
	vox.passable:=TRUE
END Nrdvolvox. 