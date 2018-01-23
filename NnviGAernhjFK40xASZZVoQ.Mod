MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT Base, FRep, NM3;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	n3ball, bb,v,w:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
RETURN n3ball
END thisvox;

BEGIN
	n3ball:=Base.VoxelFromName("NM3"); 
	v:=Base.VoxelFromName("Nreddot"); 
	v.setcolor(0.7,0,0.3,0,0);
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6/12);
	ball.vox:=v;
	n3ball.FRaster(ball,27);
END NnviGAernhjFK40xASZZVoQ. 

Marsh.Rez NnviGAernhjFK40xASZZVoQ ~
