MODULE N2qeD84Fv78X2XEj8PtU668;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	dot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	dot:=Base.VoxelFromName("NM3");
	dot.setcolor(120,100,0,150,150,150);
	bludot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7");	 	
	Base.setPT(center,1/2,1/2,1/2);
	tigerlily:=Base.VoxelFromName("NUzl1lqmBmaKyswkc70kO1w");  
	NEW(ball,center,8/12);	
	ball.setcolor(0.9,0.9,1,1);			
	ball.setvoxel(tigerlily);
	dot.FRaster(ball,32);
	dot.DTL:=1000;
	FOR i:=0 TO 1000 DO
		p1:=Base.randPT();
		dot.stroke(p1,32,bludot);
	END;
	dot.copyonstroke:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU668. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtU668~
 
