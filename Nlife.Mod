MODULE Nlife;

IMPORT Base, FRep, Raster;

CONST
	N = 500;
	M = 500;
	V= 50;
	A = 80;
	B = 20;
	C = 0.03;

TYPE
	PT=Base.PT;
	Voxel=Base.Voxel;
	Ray=Base.Ray;
	
TYPE LifeVox*= OBJECT(Voxel);
VAR
	m : ARRAY M,N OF BOOLEAN;
	n: ARRAY M,N OF INTEGER;
	gen: INTEGER;
	i:LONGINT;
			
PROCEDURE &init;
BEGIN
	seed;
	 register; 
END init;
			
PROCEDURE seed;
VAR
	i,j:LONGINT;
BEGIN								
	FOR i := 1 TO M - 2 DO
		FOR j := 1 TO N - 2 DO
			IF Base.rand.Dice(5) = 0 THEN m[i, j] := TRUE ELSE m[i, j] := FALSE END;
		END
	END;
END seed;

PROCEDURE touch;
BEGIN
	seed
END touch; 
			
PROCEDURE tick;
VAR
	i, j: LONGINT;
BEGIN	
	IF Base.rand.Dice(100) = 0 THEN seed END;	
	FOR i := 1 TO M - 2 DO
		FOR j := 1 TO N - 2 DO
			n[i,j] := 0;
			IF m[i-1,j-1] THEN INC(n[i,j]) END;
			IF m[i-1,j] THEN INC(n[i,j]) END;
			IF m[i-1,j+1] THEN INC(n[i,j]) END;
			IF m[i,j-1] THEN INC(n[i,j]) END;
			IF m[i,j+1] THEN INC(n[i,j]) END;
			IF m[i+1,j-1] THEN INC(n[i,j]) END;
			IF m[i+1,j] THEN INC(n[i,j]) END;
			IF m[i+1,j+1] THEN INC(n[i,j]) END;
		END
	END;
	FOR i := 1 TO M - 2 DO
		FOR j := 1 TO N - 2 DO
			IF m[i,j] THEN IF (n[i,j]=2) OR (n[i,j]=3) THEN ELSE m[i,j] := FALSE END;
			ELSIF n[i,j]=3 THEN m[i,j] := TRUE END;
		END
	END					 
END tick;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y: LONGINT;
	lx, ly, d: REAL;
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
BEGIN
	CASE ray.face OF
		0: nx := -1
		|1: ny := -1
		|2: nz := -1
		|3: nx := 1
		|4: ny := 1
		|5: nz := 1
	ELSE
		inside := TRUE
	END;
	CASE ray.face OF
		0: lx := ray.lxyz.y; ly :=  ray.lxyz.z;
		| 1:  lx := ray.lxyz.x; ly := ray.lxyz.z;
		| 2: lx := ray.lxyz.x; ly := ray.lxyz.y;
		| 3: lx := ray.lxyz.y; ly := ray.lxyz.z;
		| 4: lx := ray.lxyz.x; ly := ray.lxyz.z;
		| 5: lx := ray.lxyz.x; ly := ray.lxyz.y;
	ELSE
	END; 
	lx := lx*M; ly := ly*N;
	x :=  ENTIER(lx); y :=  ENTIER(ly);  
	IF x > (M-1) THEN x := M-1 END;
	IF y > (N-1) THEN y := N-1 END;
	IF inside THEN dot := 1 ELSE dot := ABS(nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z) END;
	IF m[x,y] THEN
		lx :=  (x+1/2)-lx; 
		lx := lx*lx;
		ly :=(y+1/2)-ly;
		ly := ly*ly;
	IF (lx+ly)< 0.70 THEN 
			CASE ray.face OF
				0: nx := -1
				|1: ny := -1
				|2: nz := -1
				|3: nx := 1
				|4: ny := 1
				|5: nz := 1
			ELSE	
			END;
			CASE ray.face OF
				0: 	 ray.dxyz.x:= -ray.dxyz.x; 
				|1:	ray.dxyz.y:= -ray.dxyz.y;
				|2:	ray.dxyz.z:= -ray.dxyz.z;
				|3: 	ray.dxyz.x:= -ray.dxyz.x; 
				|4:	ray.dxyz.y:= -ray.dxyz.y;
				|5:	ray.dxyz.z:= -ray.dxyz.z;
			ELSE
			END;
			ray.terminate := TRUE; 
			ray.r:=0;
			ray.g:=0;
			ray.b :=0;		
		ELSE
			ray.r := ray.r + ray.bla*dot;
			ray.g := ray.g + ray.bla*dot;
			ray.b := ray.b + ray.bla*dot; 
			ray.terminate:=TRUE;
		END 
	ELSE 
		ray.r := ray.r + ray.bla*dot;
		ray.g := ray.g + ray.bla*dot;
		ray.b := ray.b + ray.bla*dot; 
		ray.terminate:=TRUE;
	END;
END Shade;
END LifeVox;

VAR
	vox: LifeVox; 
	r,b,y: Base.Voxel;
	center: Base.PT;
	ball: FRep.sphere;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN vox
END thisvox;

BEGIN
	NEW(vox);
	vox.lock;
END Nlife. 