MODULE N2qeD84Fv78X2XEj8PtU888;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
TYPE animvox=OBJECT(Voxel)

PROCEDURE tick*;
VAR 
	i: LONGINT;
BEGIN
	FOR i:=0 TO 100 DO
		p1:=Base.randPT();
		strokephemeral(p1,9,bludot,v);
	END;	
END tick;

END animvox;
	
VAR 
	ball: FRep.sphere;
	av: animvox;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	dot,reddot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw;
BEGIN
	bludot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7");	 
	NEW(av);
	dot:=Base.VoxelFromName("NM3");
	dot.setcolor(0.8,0,0.4,3,0);	
	Base.setPT(center,1/2,1/2,1/2);
	tigerlily:=Base.VoxelFromName("NmOgKSH5ZXYP3DODELOkO7g");  
	NEW(ball,center,5/12);	
	ball.setcolor(0.01,0.66,0.0);		
(*	ball.setvoxel(tigerlily);	*)
	dot.FRasterSolid(ball,64);
	dot.copyonstroke:=TRUE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU888. 
 
Marsh.Rez N2qeD84Fv78X2XEj8PtU888 ~
 
