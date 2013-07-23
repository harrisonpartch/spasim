MODULE N2qeD84Fv78X2XEj8PtU667;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	reddot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw(VAR dot: Voxel);
BEGIN
	dot:=Base.VoxelFromName("NM3");
	dot.setcolor(0,0,0,250,0);
	bludot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7");	 	
	Base.setPT(center,1/2,1/2,1/2);
	tigerlily:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO1w");  
	NEW(ball,center,8/12);	
	ball.setcolor(0.9,0.9,1);			
	ball.setvoxel(tigerlily);
	dot.FRaster(ball,32);
	FOR i:=0 TO 100 DO
		p1:=Base.randPT();
		dot.stroke(p1,8,bludot,v);
	END;
	dot.copyonstroke:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(reddot);
	RETURN reddot
END thisvox;

BEGIN
END N2qeD84Fv78X2XEj8PtU667. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
