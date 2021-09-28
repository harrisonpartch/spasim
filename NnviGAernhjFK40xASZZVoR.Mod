MODULE NnviGAernhjFK40xASZZVoR;(*anonymous module created by saboteur*)
  
IMPORT Base,  FRep;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	ball2: FRep.twosphere;
	rp: FRep.randpoints;
	redball, blueball, yellowball, v:Voxel;
	center:  PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN redball
END thisvox;

BEGIN
	redball:=Base.VoxelFromName("NM3"); 	
	blueball:=Base.VoxelFromName("NM3"); 
	yellowball:=Base.VoxelFromName("NM3"); 
	redball.setcolor(1/3,0,0,1/2,1/2,1/2);	
	blueball.setcolor(0,1/5,0,1,1,1);	
	yellowball.setcolor(1/2,1/2,0,1,1,1);		
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,5/12);
	ball.setcolor(0.9,0.1,0.1,1,0);
	redball.FRaster(ball,9);
	ball.setcolor(0.2,0.1,0.9,1,0);
	blueball.FRaster(ball,9);
	ball.setcolor(0.8,0.8,0.1,1,0);
	yellowball.FRaster(ball,9);
	NEW(ball,center,6.5/12);
	ball.setvoxel(blueball);
	redball.FRaster(ball,3);
	NEW(ball,center,7.5/12);
	ball.setvoxel(yellowball);
	redball.FRaster(ball,3);		
(*	NEW(rp);
	rp.setcolor(0.0,0.8,0.2,1);
	redball.FRaster(rp,32);
*)	redball.lock;

END NnviGAernhjFK40xASZZVoR. 