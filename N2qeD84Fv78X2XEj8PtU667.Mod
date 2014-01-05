MODULE N2qeD84Fv78X2XEj8PtU667;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	
TYPE animvox=OBJECT(Voxel)

PROCEDURE tick*;
VAR 
	i: LONGINT;
BEGIN
	free;
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
	reddot,bludot,tigerlily,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	
PROCEDURE draw(VAR dot: Voxel);
BEGIN
	bludot:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtUZO7");	 
	NEW(av);
	dot:=Base.VoxelFromName("NM2");
	dot.setcolor(10,0,0,10,0);	
	Base.setPT(center,1/2,1/2,1/2);
	tigerlily:=Base.VoxelFromName("NCjgzkmiTyecI5x6eOgYqpQ");  
	NEW(ball,center,5/12);	
	ball.setcolor(0.01,0.99,0.0);			
	dot.FRaster(ball,128);
	FOR i:=0 TO 10 DO
		p1:=Base.randPT();
		p1.x:=(p1.x+1/2)/2;
		p1.y:=(p1.y+1/2)/2;
		p1.z:=(p1.z+1/2)/2;
		dot.stroke(p1,4,dot,v);
	END;	
	dot.lockTF:=TRUE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(reddot);
	RETURN reddot
END thisvox;

BEGIN
END N2qeD84Fv78X2XEj8PtU667. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
