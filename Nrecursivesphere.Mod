MODULE Nrecursivesphere;

IMPORT Base, FRep;
TYPE 
	PT = Base.PT;
	Voxel = Base.Voxel;  

VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	u,w,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	Base.setPT(center,1/2,1/2,1/2);
	u:=Base.VoxelFromName("NM3");
	u.setcolor(0,150,150,150,0);
	NEW(ball,center,0.5);
	ball.setcolor(1,0,0,1/2);	
	u.FRaster(ball,9);
	u.copyonstroke:=TRUE;	
	w:=Base.VoxelFromName("NM3");
	w.setcolor(450,0,0,450,0);
	NEW(ball,center,0.5);
	ball.setvoxel(u);
	w.FRaster(ball,16);
	w.copyonstroke:=TRUE;
	v:=Base.VoxelFromName("NM3");	
	v.setcolor(0,1500,0,1500,0);
	ball.setvoxel(w);
	ball.setimposter(w);	
	v.FRaster(ball,9);
	v.copyonstroke:=TRUE;	
	v.imposter:=w;
END draw;


PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	draw;
	RETURN v
END thisvox;

END Nrecursivesphere.