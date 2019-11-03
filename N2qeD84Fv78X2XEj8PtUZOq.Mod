MODULE N2qeD84Fv78X2XEj8PtUZOq;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, TexVox;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	dot,v: Voxel;
	center:  PT;
	i: INTEGER;
	avatar: TexVox.TexVox;
	
PROCEDURE draw;
BEGIN
	dot:=Base.VoxelFromName("NM3"); 	
	NEW(avatar,"harrisonavatar.0.png");
	avatar.copyonstroke:=TRUE;
	avatar.tscale:=1729; 
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,1/2);	
	ball.setvoxel(avatar);		
	dot.FRaster(ball,9);
	dot.copyonstroke:=TRUE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZOq. 
~
 
