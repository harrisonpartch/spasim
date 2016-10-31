MODULE N2qeD84Fv78X2XEj8PtUZOx;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.cyl;
	v: Voxel;
	conglomerate,sc,star: Voxel;
	center,q,qq:  PT;
	p:ARRAY 7 OF PT;
	i,j,k:INTEGER;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN star
END thisvox;

BEGIN
	v:=Base.VoxelFromName("NnTJ6nDktAth4WTAUdr8HYQ"); 	
	conglomerate:=Base.VoxelFromName("NM3"); 	
	sc:=Base.VoxelFromName("NM3"); 	
	star:=Base.VoxelFromName("NM3"); 
	conglomerate.imposter:=sc;
	conglomerate.setcolor(0,0,0,100,0);
	Base.setPT(center,1/2,1/2,1/2);
	Base.setPT(q,1/2,1/2,0);
	Base.setPT(qq,1/2,1/2,1);
	NEW(ball,center,2/3);
	ball.setcolor(1,1,1,1);
	conglomerate.FRaster(ball,9);
	NEW(star);
	star.setcolor(0,0,0,100,0);
	ball.setcolor(1,0,1,1);
	star.FRaster(ball,9);	
	NEW(ball,center,1/2);	
	ball.setvoxel(conglomerate);
	star.FRaster(ball,9);	
	star.imposter:=conglomerate;
	star.copyonstroke:=TRUE;
	conglomerate.copyonstroke:=TRUE;	


 END N2qeD84Fv78X2XEj8PtUZOx. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOx ~
 
