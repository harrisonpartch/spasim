MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT Base,  XNXLFRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball, bb,v,w:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	n3ball:=Base.VoxelFromName("NM3"); 
	bb:=Base.VoxelFromName("NM3"); 	
	v:=Base.VoxelFromName("Ndiffuseblue"); 	
	w:=Base.VoxelFromName("NIqy3HQ4ZK8iRwAXelYYnsQ"); 	
	v.setcolor(0.7,0,0.3,0,0);
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6/12);
	ball.vox:=w;
	bb.FRaster(ball,9);
	NEW(ball,center,7/12);	
	ball.vox:=v;
	bb.FRaster(ball,9);
	NEW(ball,center,6/12);
	ball.vox:=bb;	
	n3ball.FRaster(ball,9);	
	n3ball.DTL:=30000;
	RETURN n3ball
END thisvox;

BEGIN

END NnviGAernhjFK40xASZZVoQ. 