MODULE NnviGAernhjFK40xASZZVoR;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	ball2: FRep.twosphere;
	rp: FRep.randpoints;
	redball, blueball, v:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN redball
END thisvox;

BEGIN
	redball:=Base.VoxelFromName("NM2"); 	
	blueball:=Base.VoxelFromName("NM2"); 		
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,3.25/12);
	ball.setcolor(0.9,0.1,0.1,1);
	redball.FRaster(ball,4);
	ball.setcolor(0.2,0.1,0.9,1);
	blueball.FRaster(ball,8);
	NEW(ball2,center,7.15/12);
	ball2.setvoxel(redball);
	ball2.setvoxel2(blueball);	
	redball.FRaster(ball2,4);	
(*	NEW(rp);
	rp.setcolor(0.0,0.8,0.2,1);
	redball.FRaster(rp,32);
*)	redball.copyonstroke:=TRUE;

END NnviGAernhjFK40xASZZVoR. 