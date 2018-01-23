MODULE N2qeD84Fv78X2XEj8PtU666;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	yellow,bludot,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	vu: Voxel;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,7.5/12);
	ball.setcolor(0.8,0.8,0,1/2);	
	v:=Base.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g");
	ball.setvoxel(v); 	
	yellow:=Base.VoxelFromName("NM2");
	yellow.localcolor:=TRUE;
	yellow.FRaster(ball,8);
	yellow.copyprime;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN yellow
END thisvox;

BEGIN 
	draw
END N2qeD84Fv78X2XEj8PtU666. 
 
Marsh.Rez  N2qeD84Fv78X2XEj8PtU666~
 
