MODULE NXWCxXWLIcD2LegvoGXXBiQ;

IMPORT Base:=XNXLBase;

TYPE PT = Base.PT;
	Ray = Base.Ray;
	Voxel = Base.Voxel;  
	
TYPE AlphaVox* = OBJECT(Voxel);
VAR
	r, g, b : REAL;
PROCEDURE setcolor* (red, green, blue, black,alpha : REAL);
BEGIN
	r := red * alpha;
	g := green * alpha;
	b := blue * alpha;
END setcolor;
PROCEDURE Shade(VAR ray: Ray);
VAR 
	dr, dg, db: REAL;
BEGIN
	dr :=  r*ray.ra;
	dg :=  g*ray.ga;
	db :=  b*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.ra := ray.ra - (dg+db)/2;
	ray.ga := ray.ga - (dr+db)/2;
	ray.ba := ray.ba - (dr+dg)/2;
	ray.bla := ray.bla -(dr+dg+db)/3;
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
END Shade;

PROCEDURE deepcopy*():Voxel;
VAR	v:AlphaVox;
BEGIN
	NEW(v);
	v.setcolor(r,g,b,0,1);
	RETURN(v)
END deepcopy;
END AlphaVox; 

VAR 
	serp,beatrix,lobster: Voxel;
	blue: AlphaVox;
	v: Voxel;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	beatrix:=Base.VoxelFromName("NwPicBWw4NfcserX4ELaQ3A"); 
	lobster:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	serp:=Base.VoxelFromName("NM3"); 	
	NEW(blue);
	blue.setcolor(1,0,0,1,0);
	blue.passable:=TRUE;
	serp.lockTF:=TRUE; 
	serp.frozen:=TRUE;
	serp.probelock:=TRUE;
	serp.DTL:=30;
	serp.fill(blue);
	serp.stroke(Base.mkPT(1/2,1/2,1/4),3,beatrix,v);
	serp.stroke(Base.mkPT(1/2,1/2,3/4),3,beatrix,v);
	serp.stroke(Base.mkPT(1/4,1/2,1/2),3,beatrix,v);
	serp.stroke(Base.mkPT(3/4,1/2,1/2),3,beatrix,v);
	serp.stroke(Base.mkPT(1/2,1/4,1/2),3,beatrix,v);
	serp.stroke(Base.mkPT(1/2,3/4,1/2),3,beatrix,v);
	serp.stroke(Base.mkPT(1/2,1/2,1/2),3,beatrix,v);			
	serp.imposter:=lobster;

	RETURN beatrix
END thisvox;
 END NXWCxXWLIcD2LegvoGXXBiQ. 