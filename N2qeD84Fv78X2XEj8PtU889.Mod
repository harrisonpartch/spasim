MODULE N2qeD84Fv78X2XEj8PtU889;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;

	
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	dot,reddot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	dot:=Base.VoxelFromName("NM3");
	Base.setPT(center,1/2,1/2,1/2);  
	NEW(ball,center,5/12);	
	ball.setcolor(0.51,0.66,0.5,1,0);			
	dot.FRaster(ball,9);
	dot.copyonstroke:=TRUE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU889. 
 
Marsh.Rez N2qeD84Fv78X2XEj8PtU889 ~
 
