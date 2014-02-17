MODULE NWorld;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random,Debugging;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	w3,z3,z2,v,tigerlily,sky,serp: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	w3:=Base.VoxelFromName("NM3");	 
	z3:=Base.VoxelFromName("NM3");	
	z2:=Base.VoxelFromName("NM3");
	z3.setcolor(0,10,0,10,10);
	z2.setcolor(10,10,0,0,10);	
	sky:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"); 
	serp:=Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"); 	
	Base.setPT(center,1/2,1/2,1/2);
	w3.fill(sky);
	w3.stroke(center,1,z3,v);
	Base.setPT(center,1/2,1/2,1/2);
	z3.stroke(center,1,z2,v);
(*	NEW(ball,center,0.5);
	ball.setcolor(0.9, 0.7,0.7);
	ball.setvoxel(sky); 
	z3.FRaster(ball,81);
*)	NEW(noise);		
	noise.seed:=123666;		
	noise.a:=1;
	noise.b:=1;
	noise.c:=1;		
	noise.persistence:=3.1;
	noise.octaves:=4;	
	noise.setvoxel(Base.VoxelFromName("NXWCxXWLIcD2LegvoGXXBiQ"));
	z3.FRaster(noise,27);
	sky.lockTF:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN z3
END thisvox;

BEGIN
	Debugging.DisableGC; 
	draw;
	Debugging.EnableGC; 
END NWorld. 
 
XNXLMarsh.Rez NWorld ~
 
