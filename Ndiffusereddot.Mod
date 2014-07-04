MODULE Ndiffusereddot;
IMPORT Base, TexVox,  Noise;
TYPE 
	Voxel=Base.Voxel;
	Ray=Base.Ray;
	
TYPE ColoredVox* = OBJECT(Voxel);
VAR
	r, g, b: REAL;
PROCEDURE setcolor* (red, green, blue, black, alpha: REAL);
BEGIN
	r :=red ;
	g := green;
	b := blue;
END setcolor;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	ray.r := ray.r + r*ray.ra;
	ray.g := ray.g + g*ray.ga;
	ray.b := ray.b + b*ray.ba;
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
	ray.r := ray.r + (rr*dot)*ray.ra;
	ray.g := ray.g + (rr*dot)*ray.ga;
	ray.b := ray.b + (rr*dot)*ray.ba;
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