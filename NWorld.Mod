MODULE NWorld;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	w3,z3,z2,v,tigerlily,sky: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	w3:=Base.VoxelFromName("NM3");	 
	z3:=Base.VoxelFromName("NM4");	
	z2:=Base.VoxelFromName("NM2");
	z3.setcolor(1,0,0,1,1);
	z2.setcolor(0,18,0,30,3);	
	sky:=Base.VoxelFromName("Ndiffuseblue"); 
	Base.setPT(center,1/2,1/2,1/2);
	w3.fill(sky);
	w3.stroke(center,3,z3,v);
	Base.setPT(center,1/2,1/2,1/2);
	z3.stroke(center,0,z2,v);
	NEW(ball,center,0.5);
	ball.setcolor(0.9, 0.7,0.7);
	ball.setvoxel(sky);
	z3.FRaster(ball,27);
	NEW(noise);		
	noise.seed:=123666;		
	noise.a:=2;
	noise.b:=1;
	noise.c:=1;		
	noise.persistence:=3.2;
	noise.octaves:=4;	
	tigerlily:=Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw");  
	noise.setvoxel(tigerlily);
	noise.persistence:=4;
	z2.FRaster(noise,64);
	sky.lockTF:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN z3
END thisvox;

BEGIN
	draw
END NWorld. 
 
XNXLMarsh.Rez NWorld ~
 
