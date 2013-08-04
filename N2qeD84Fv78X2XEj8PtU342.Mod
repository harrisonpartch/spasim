MODULE N2qeD84Fv78X2XEj8PtU342;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  XNXLFRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 	
	cage: OutlineVox;

TYPE OutlineVox*=OBJECT(Voxel);
VAR
	or, og, ob: REAL;
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
	X:REAL;
PROCEDURE&init*;
BEGIN
	setoutline(0,0,0);
	passable:=TRUE
END init;	
PROCEDURE setoutline* (red, green, blue: REAL);
BEGIN
	or := red ;
	og := green ;
	ob := blue;
END setoutline;
PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	dot, e: REAL;
	inside: BOOLEAN;
	ecount:INTEGER;
BEGIN
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	IF (ray.lxyz.x< 0.1) OR (ray.lxyz.x > 0.9) THEN INC(ecount) END;
	IF (ray.lxyz.y <0.1) OR (ray.lxyz.y > 0.9) THEN INC(ecount) END;
	IF (ray.lxyz.z < 0.1) OR (ray.lxyz.z > 0.9) THEN INC(ecount) END;
	IF (ecount > 1) THEN
		ray.r := ray.r + or * ray.ra*dot;
		ray.g := ray.g + og * ray.ga*dot;
		ray.b := ray.b + ob * ray.ba*dot;
		ray.terminate := TRUE;
	END
END Shade;
END OutlineVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cage
END thisvox;

BEGIN
	NEW(cage);
END N2qeD84Fv78X2XEj8PtU342. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtU342 ~
 
