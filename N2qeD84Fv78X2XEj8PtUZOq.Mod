MODULE N2qeD84Fv78X2XEj8PtUZOq;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, TexVox;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	reddot,v: Voxel;
	center:  PT;
	i:LONGINT;
	avatar: TexVox.TexVox;
	
PROCEDURE draw(VAR reddott: Voxel);
BEGIN
	reddott:=Base.VoxelFromName("NM3"); 	
	NEW(avatar,"shellyduvall.png");
	avatar.tscale:=0;
	reddott.copyonstroke:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,1/2);	
	ball.setvoxel(avatar);		
	reddott.FRaster(ball,9);
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(reddot);
	RETURN avatar
END thisvox;

 END N2qeD84Fv78X2XEj8PtUZOq. 
~
 
