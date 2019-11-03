MODULE N2qeD84Fv78X2XEj8PtUZO6;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base:=Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	dot,v: Voxel;
	center:  PT;
	i:INTEGER;

PROCEDURE draw;
BEGIN
	v:=Base.VoxelFromName("NVY1hEGnyr7z8DtULRMOZIQ"); 
	dot:=Base.VoxelFromName("NM3"); 		
	dot.copyonstroke:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,1/2);	
	ball.setcolor(1,0,0,1,0);		
(*		ball.setvoxel(v); *)
	dot.FRaster(ball,9);
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO6. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
