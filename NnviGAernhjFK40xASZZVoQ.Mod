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
	n3ball:=Base.VoxelFromName("NM3"); 
	bb:=Base.VoxelFromName("NM3"); 	
	v:=Base.VoxelFromName("Ndiffuseblue"); 	
	w:=Base.VoxelFromName("N5a2g4M6HYjPJxYSNQvYyv7"); 	
	v.setcolor(0.7,0,0.3,0,0);
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6/12);
	ball.vox:=w;
	bb.FRaster(ball,27);
(*	NEW(ball,center,7/12);	
	ball.vox:=v;
	bb.FRaster(ball,9);
	NEW(ball,center,6/12);
	ball.vox:=bb;	
	n3ball.FRaster(ball,9);	
	n3ball.DTL:=30000;
*)	RETURN bb
END thisvox;

BEGIN

END NnviGAernhjFK40xASZZVoQ. 