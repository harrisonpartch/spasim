MODULE Ndiffuseblue;(*anonymous module created by saboteur*)
  
IMPORT Base,  XNXLFRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;

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

TYPE DiffuseVox* = OBJECT(ColoredVox)

PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	ray.r := ray.r + (r*dot)*ray.ra;
	ray.g := ray.g + (g*dot)*ray.ga;
	ray.b := ray.b + (b*dot)*ray.ba;
	ray.terminate := TRUE;	
END Shade;
END DiffuseVox;	

VAR 
	ball: XNXLFRep.sphere;
	n3ball, bb,v:Voxel;
	blue:DiffuseVox;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(blue);
	blue.setcolor(0.3,0.3,0.9,0,0);
	RETURN blue
END thisvox;

BEGIN

END Ndiffuseblue. 