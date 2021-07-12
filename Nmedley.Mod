MODULE Nmedley;
IMPORT Base, NM10, FRep;

VAR 
	medley: NM10.cell;
	sqube: FRep.sqube;
	ball: FRep.sphere;
	med1: Base.Voxel;
	center: Base.PT;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN medley
END thisvox;

BEGIN
	Base.setPT(center,1/2,1/2,9/10);
	NEW(medley);
	med1:=Base.VoxelFromName("NM10");
	medley.setcolor(0.06,0,0,0.1,0.1,0.1);
	NEW(sqube,center,0.1,3,3,3,1,0.5,2);
	sqube.setcolor(0.99,0.31,0.991,1,0);
	sqube.setsidecolor(0,0.5,0.5,1,0);	
	medley.FRaster(sqube,10);
	NEW(ball,center,0.495);	
	ball.setcolor(0.81,0.831,0.1,1,0);
	ball.setsidecolor(0.15,0.09,0.1,1,0.5);		
	med1.FRaster(ball,10);	
	medley.FRaster(ball,10);			
	NEW(ball,center,0.55);	
	ball.setcolor(0.1,0.831,0.1,1,0);
	ball.setsidecolor(0.95,0.09,0.1,1,0.5);	
	med1.FRaster(ball,10);	
	NEW(ball,center,0.55);	
	ball.setvoxel(med1);	
	medley.FRaster(ball,10);	
END Nmedley.