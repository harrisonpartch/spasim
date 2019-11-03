MODULE N2qeD84Fv78X2XEj8PtU889;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;

	
VAR 
	sqube: FRep.sqube;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	dot,reddot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	dot:=Base.VoxelFromName("NM20");
	Base.setPT(center,1/2,1/2,1/2);  
	NEW(sqube,center,0.1,3,3,3,1,0.5,2);
	sqube.setcolor(0.051,0.99,0.2,1,0);	
	sqube.setsidecolor(0.81,0.66,0.5,1,0);			
	dot.FRaster(sqube,20);
	NEW(sqube,center,0.15,2,2,3,1,2,2);
	sqube.setcolor(0.951,0.09,0.6,1,0);	
	sqube.setsidecolor(0.11,0.96,0.5,1,0);	
	dot.FRaster(sqube,20);
	dot.copyonstroke:=FALSE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU889. 
 
Marsh.Rez N2qeD84Fv78X2XEj8PtU889 ~
 
