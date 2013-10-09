MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	reddot,v,cage: Voxel;
	center:  PT;
	i:LONGINT;
	
PROCEDURE draw(VAR reddott: Voxel);
BEGIN
	reddott:=Base.VoxelFromName("NM3"); 	
	reddott.copyonstroke:=TRUE;
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6/11);	
	ball.setcolor(1,0.3,0);	
(*	ball.setvoxel(cage);	*)
	reddott.FRasterSolid(ball,9);
	reddot.DTL:=2500;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(reddot);
	RETURN reddot
END thisvox;

 END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
