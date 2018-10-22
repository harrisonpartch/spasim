MODULE N2qeD84Fv78X2XEj8PtU666;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	yellow,cage,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	c:Base.Color;
	vu: Voxel;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	NEW(rand);
	Base.setPT(center,1/2,1/2,1/2);
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");
	FOR i:=0 TO 10000 DO 
		NEW(ball,Base.randPT(), rand.Uniform()/5);
		c:=Base.randColor();
		ball.setcolor(c.red,c.green,c.blue,1);
		p1:=Base.randPT();
		cage.FRaster(ball,27)
	END;	
	NEW(ball,center,0.4);
	ball.setcolor(1,0,0,1/2);	
	yellow:=Base.VoxelFromName("NM3");
	yellow.FRaster(ball,9);
	yellow.copyonstroke:=TRUE;

	FOR i:=0 TO 10000  DO 
		p1:=Base.randPT();
		cage.stroke(p1,27,yellow)
	END;	
(*	NEW(ball,center,0.1);
	NEW(ball,center,0.6);
	ball.setcolor(1,1,0,1/2);	
	ball.setvoxel(Base.VoxelFromName("NBsHFiBKkSckXBAd46ZbEQw"));		
	yellow:=Base.VoxelFromName("NM3");
	yellow.FRaster(ball,9);
	yellow.copyonstroke:=TRUE;	
*)
	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN cage
END thisvox;

BEGIN 
	draw
END N2qeD84Fv78X2XEj8PtU666. 
 
Marsh.Rez  N2qeD84Fv78X2XEj8PtU666~
 
