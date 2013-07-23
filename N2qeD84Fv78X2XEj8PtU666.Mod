MODULE N2qeD84Fv78X2XEj8PtU666;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	reddot,bludot,sand,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	vu: Voxel;
	
PROCEDURE draw(VAR reddott: Voxel);
BEGIN
	reddott:=Base.VoxelFromName("NM3");
	Base.setPT(center,1/2,1/2,1/2);
	sand:=Base.VoxelFromName("NFLOOP");  
	NEW(ball,center,8/12);	
	ball.setvoxel(sand);		
	reddott.FRaster(ball,27);
	reddott.copyonstroke:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	draw(reddot);
	RETURN reddot
END thisvox;

END N2qeD84Fv78X2XEj8PtU666. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
