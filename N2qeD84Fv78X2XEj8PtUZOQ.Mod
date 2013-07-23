MODULE N2qeD84Fv78X2XEj8PtUZOQ;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.cyl;
	v,vr: Voxel;
	conglomerate,sc,star:Voxel;
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
	NEW(ball,center,1/2);
	ball.cxf:=TRUE;
	NEW(cyl,q,qq,1/6);
	conglomerate.FRaster(ball,9);
	sc.FRaster(cyl,9);	
	star.FRaster(ball,9);	
	star.imposter:=conglomerate;
	FOR i := 0  TO 10 DO
		q:=Base.randPT();
		star.stroke(q,3,conglomerate,vr);
		q:=Base.randPT();
		star.stroke(q,3,sc,vr);	
	END;
	star.setcolor(0,0,0,10,0);
	star.copyonstroke:=TRUE;
	conglomerate.copyonstroke:=TRUE;	
(*	
	

	FOR i := 0  TO 100 DO
		Base.setPT(center,Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());
		NEW(ball,center,1/25);	
		ball.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());		
		star.FRaster(ball,128);			
	END;
*)


 END N2qeD84Fv78X2XEj8PtUZOQ. 