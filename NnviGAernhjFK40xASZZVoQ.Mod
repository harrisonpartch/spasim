MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT XNXLBase,  XNXLFRep;

TYPE Ray = XNXLBase.Ray;
	Voxel = XNXLBase.Voxel;  
	PT =XNXLBase.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball, v:Voxel;
	center:  PT;
PROCEDURE thisvox*():XNXLBase.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	v:=XNXLBase.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g"); 
	n3ball:=XNXLBase.VoxelFromName("NM3"); 	
	XNXLBase.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6.5/12);
	ball.setcolor(0,1,0.2);
	ball.setvoxel(v); 
	n3ball.code:="NnviGAernhjFK40xASZZVoQ";
	n3ball.FRaster(ball,9);
	n3ball.DTL:=10000;
	n3ball.frozen:=TRUE 
END NnviGAernhjFK40xASZZVoQ. 