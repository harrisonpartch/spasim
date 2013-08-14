MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT Base,  XNXLFRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball, v:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	n3ball:=Base.VoxelFromName("NM3"); 	
	v:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 	
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6.5/12);
	ball.setcolor(0.1,0.6,0.2);
	ball.vox:=v; 
	n3ball.copyonstroke:=TRUE;
	n3ball.FRaster(ball,9);
	n3ball.DTL:=10000;
	
END NnviGAernhjFK40xASZZVoQ. 