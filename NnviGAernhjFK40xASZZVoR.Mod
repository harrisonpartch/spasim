MODULE NnviGAernhjFK40xASZZVoR;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	n3ball, v:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN n3ball
END thisvox;

BEGIN
	n3ball:=Base.VoxelFromName("NM3"); 	
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6.5/12);
	ball.setcolor(0.9,0.4,0.2,1);
	n3ball.FRaster(ball,9);
	n3ball.DTL:=10000;
	n3ball.frozen:=TRUE 
END NnviGAernhjFK40xASZZVoR. 