MODULE N2qeD84Fv78X2XEj8PtUZO8;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.ellipsoid;
	reddot,v: Voxel;
	center1,center2:  PT;
	i:LONGINT;
	
PROCEDURE draw(VAR reddott: Voxel);
BEGIN
	reddott:=Base.VoxelFromName("NM3"); 	
	reddott.copyonstroke:=TRUE;
	Base.setPT(center1,1/2,4/12,1/2);
	Base.setPT(center2,1/2,7/12,1/2);
	NEW(ball,center1,center2,2/3);	
	ball.setcolor(0,0,1);		
	reddott.FRaster(ball,9);
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(reddot);
	RETURN reddot
END thisvox;

 END N2qeD84Fv78X2XEj8PtUZO8. 
 
Marsh.Rez N2qeD84Fv78X2XEj8PtUZO8 ~
 
