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
	RETURN blueball
END thisvox;

BEGIN
	redball:=Base.VoxelFromName("NM3"); 	
	blueball:=Base.VoxelFromName("NM3"); 
	yellowball:=Base.VoxelFromName("NM3"); 
	redball.setcolor(1/7,0,0,1/7,1/7,1/7);	
	blueball.setcolor(0,0,0,1/50,1/50,1/50);	
	yellowball.setcolor(0,0,0,1/13,1/13,1/13);	
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,4/12);
	ball.setcolor(0.09,0.1,0.1,0.1,0);
	redball.FRaster(ball,3);
	ball.setcolor(0.2,0.1,1,1,0);
	blueball.FRaster(ball,9);
	ball.setcolor(0.8,0.8,0.1,0.1,0);
	yellowball.FRaster(ball,9);
	NEW(ball,center,4.5/12);
	ball.setvoxel(blueball);
	redball.FRaster(ball,9);
	NEW(ball,center,5/12);
	ball.setvoxel(redball);
	yellowball.FRaster(ball,9);		
	NEW(rp);
	rp.setvoxel(redball);
	yellowball.FRaster(rp,16);
	blueball.lock;

END NnviGAernhjFK40xASZZVoR. 