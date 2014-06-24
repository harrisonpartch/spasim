MODULE N2qeD84Fv78X2XEj8PtUZOq;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, TexVox;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	dot,v: Voxel;
	center:  PT;
	i:LONGINT;
	avatar: TexVox.TexVox;
	
PROCEDURE draw;
BEGIN
	dot:=Base.VoxelFromName("NM3"); 	
	NEW(avatar,"shellyduvall.png");
	avatar.tscale:=0;
	dot.copyonstroke:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,1/2);	
	ball.setvoxel(avatar);		
	dot.FRaster(ball,9);
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN avatar
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZOq. 
~
 
