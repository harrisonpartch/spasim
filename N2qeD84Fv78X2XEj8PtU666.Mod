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
	i:INTEGER;
	rand: Random.Generator;
	c:Base.Color;
	vu: Voxel;
	
PROCEDURE draw;
VAR
	i: INTEGER;
BEGIN
	NEW(rand);
	Base.setPT(center,1/2,1/2,1/2);
	cage:=Base.VoxelFromName("NM2");
	cage.setcolor(0,1/2,0,1/3,1/3,1/3);
(*	FOR i:=0 TO 1000 DO 
		NEW(ball,Base.randPT(), rand.Uniform()/15);
		c:=Base.randColor();
		ball.setcolor(c.red,c.green,c.blue,1);
		cage.FRaster(ball,27)
	END;	
*)	NEW(ball,center,0.5);
	ball.setcolor(1,0,0,1/2,0);	
	yellow:=Base.VoxelFromName("NM2");
	yellow.setcolor(0,1,0,1,1,1);
	yellow.FRaster(ball,16);
	yellow.copyonstroke:=TRUE;
	FOR i:=0 TO 25000  DO 
		p1:=Base.randPT();
		cage.stroke(p1,8,yellow)
	END;	
	NEW(ball,center,0.5);
	ball.setcolor(0,1,0,1/2,0);	
	yellow:=Base.VoxelFromName("NM2");
	yellow.FRaster(ball,16);
	yellow.copyonstroke:=TRUE;
	FOR i:=0 TO 2000  DO 
		p1:=Base.randPT();
		cage.stroke(p1,8,yellow)
	END;	
	NEW(ball,center,0.5);
	ball.setcolor(0,0,1,1/2,0);	
	yellow:=Base.VoxelFromName("NM2");
	yellow.FRaster(ball,16);
	yellow.copyonstroke:=TRUE;
	FOR i:=0 TO 2000  DO 
		p1:=Base.randPT();
		cage.stroke(p1,8,yellow)
	END;	
	cage.copyonstroke:=TRUE;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN yellow
END thisvox;

BEGIN 
	draw
END N2qeD84Fv78X2XEj8PtU666. 
 
Marsh.Rez  N2qeD84Fv78X2XEj8PtU666~

