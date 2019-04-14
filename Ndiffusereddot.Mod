MODULE Ndiffusereddot;
IMPORT Base, TexVox,  Noise;
TYPE 
	Voxel=Base.Voxel;
	Ray=Base.Ray;
	
TYPE ColoredVox* = OBJECT(Voxel);
VAR
	r, g, b: REAL;
PROCEDURE setcolor* (red, green, blue, rbl, gbl, bbl: REAL);
BEGIN
	r :=red ;
	g := green;
	b := blue;
END setcolor;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	ray.clr.r := ray.clr.r + r*ray.clr.ra;
	ray.clr.g := ray.clr.g + g*ray.clr.ga;
	ray.clr.b := ray.clr.b + b*ray.clr.ba;
	ray.terminate := TRUE;
END Shade;
END ColoredVox;

TYPE NoiseVox* =OBJECT(ColoredVox)
PROCEDURE Shade (VAR ray: Ray);
VAR
	lx,ly,lz,dot: REAL;
	rr:REAL;
	inside: BOOLEAN;
BEGIN
	lx := ray.lxyz.x;
	ly := ray.lxyz.y;
	lz := ray.lxyz.z;
	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	rr:=	Noise.noise3dperlinabs(lx,lz,ly, 666,4,2);
	ray.clr.r := ray.clr.r + (rr*dot)*ray.clr.ra;
	ray.clr.g := ray.clr.g + (rr*dot)*ray.clr.ga;
	ray.clr.b := ray.clr.b + (rr*dot)*ray.clr.ba;
	ray.terminate := TRUE;	
END Shade;
END NoiseVox;

VAR v: NoiseVox; 
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(v); 
	RETURN v
END thisvox;
END Ndiffusereddot. 

reddot.png