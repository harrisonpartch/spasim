MODULE Nr3kPtbyEYLFK3AN2UUVrqg;
IMPORT Base, TexVox;  
TYPE 	PT=Base.PT;
		Ray = Base.Ray;
		Voxel = Base.Voxel;
		
TYPE DiffuseMVox* = OBJECT(Voxel);
VAR
	r, g, b, mf, a: REAL;
PROCEDURE Shade (VAR ray: Ray);
VAR 
	nx, ny, nz: INTEGER;
	dot,d: REAL;
	inside: BOOLEAN;
BEGIN
	d := (nx*ray.dxyz.x + ny*ray.dxyz.y+ nz*ray.dxyz.z); 
	ray.clr.ra := ray.clr.ra- 0.1; 
	ray.clr.ga := ray.clr.ga- 0.1; 
	ray.clr.ba := ray.clr.ba- 0.1; 	
	mirror(ray);
END Shade;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;	
	INC(ray.mirrors);
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;

END DiffuseMVox; 

VAR
	vox:  DiffuseMVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox) 
END Nr3kPtbyEYLFK3AN2UUVrqg. 