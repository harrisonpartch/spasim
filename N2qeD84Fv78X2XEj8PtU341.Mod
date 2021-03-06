MODULE N2qeD84Fv78X2XEj8PtU341;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 	
	cage: OutlineVox;

TYPE OutlineVox*=OBJECT(Voxel);
VAR
	or, og, ob,oa: REAL;
	nx, ny, nz: INTEGER;
	dot: REAL;
	inside: BOOLEAN;
	X:REAL;
	innard: Voxel;
	
PROCEDURE&init*;
BEGIN
	setoutline(0,0,0,1/2);
	innard:=Base.VoxelFromName("NM3");	
	innard.setcolor(0,1/33,0,1/12,1/12,1/12);
	passable:=TRUE;
	copyonstroke:=FALSE;
END init;	

PROCEDURE setoutline* (red, green, blue,alpha: REAL);
BEGIN
	or := red ;
	og := green ;
	ob := blue;
	oa:=alpha;
END setoutline;
PROCEDURE Shade (VAR ray: Ray);
VAR
	nx, ny, nz: INTEGER;
	e: REAL;
	inside: BOOLEAN;
	ecount:INTEGER;
	a: REAL;
	exit:PT;
BEGIN
	IF (ray.lxyz.x< 0.011) OR (ray.lxyz.x > 0.989) THEN INC(ecount) END;
	IF (ray.lxyz.y <0.011) OR (ray.lxyz.y > 0.989) THEN INC(ecount) END;
	IF (ray.lxyz.z < 0.011) OR (ray.lxyz.z > 0.989) THEN INC(ecount) END;
	IF (ecount > 1) THEN
		ray.clr.r := ray.clr.r + or * ray.clr.ra*oa;
		ray.clr.g := ray.clr.g + og * ray.clr.ga*oa;
		ray.clr.b := ray.clr.b + ob * ray.clr.ba*oa;
		ray.clr.ra:= ray.clr.ra - oa;
		ray.clr.ga:=ray.clr.ga-oa;
		ray.clr.ba:=ray.clr.ba-oa;
	END;
	exit:= Base.Exit(ray);
	innard.Shade(ray);
	IF ~ray.terminate THEN
		ecount:=0;
		IF (exit.x< 0.011) OR (exit.x > 0.989) THEN INC(ecount) END;
		IF (exit.y <0.011) OR (exit.y > 0.989) THEN INC(ecount) END;
		IF (exit.z < 0.011) OR (exit.z > 0.989) THEN INC(ecount) END;
		IF (ecount > 1) THEN
			a:=1/2;
			ray.clr.r := ray.clr.r + or * ray.clr.ra*a;
			ray.clr.g := ray.clr.g + og * ray.clr.ga*a;
			ray.clr.b := ray.clr.b + ob * ray.clr.ba*a;
			a:=1-a;
			ray.clr.ra:= ray.clr.ra - a;
			ray.clr.ga:=ray.clr.ga-a;
			ray.clr.ba:=ray.clr.ba-a;
		END
	END;
END Shade;

PROCEDURE stroke*(p:PT; resolution: INTEGER; voxel:Voxel);
BEGIN
	innard.stroke(p,resolution,voxel);
END stroke;

PROCEDURE deepcopy*():Voxel;
VAR v: OutlineVox;
BEGIN
	NEW(v);
	v.innard:=SELF.innard.deepcopy();
	RETURN(v)
END deepcopy;


END OutlineVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(cage);
	cage.setoutline(0,0,0,1);
	RETURN cage
END thisvox;

	
END N2qeD84Fv78X2XEj8PtU341. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
