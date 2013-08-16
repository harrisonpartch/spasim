MODULE NnviGAernhjFK40xASZZVoQ;(*anonymous module created by saboteur*)
  
IMPORT Base,  XNXLFRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: XNXLFRep.sphere;
	n3ball, bb,v:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	n3ball:=Base.VoxelFromName("NM3"); 
	bb:=Base.VoxelFromName("NM3"); 	
	v:=Base.VoxelFromName("NtL0zWGLy4MVijnDVIbPcqA"); 	
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,6/12);
	ball.setcolor(0.65,0.6,0.62);
	n3ball.FRaster(ball,27);
	ball.setcolor(0.5,0.5,0.962);
	bb.FRaster(ball,27);	
	NEW(ball,center,5/12);	
	ball.vox:=bb;  
	n3ball.FRaster(ball,27);	
	n3ball.DTL:=1000;
	bb.copyonstroke:=TRUE;
	n3ball.copyonstroke:=TRUE;
	RETURN n3ball
END thisvox;

BEGIN

END NnviGAernhjFK40xASZZVoQ. 