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
	vu: Voxel;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	Base.setPT(center,1/2,1/2,1/2);
	NEW(ball,center,7.5/12);
	ball.setcolor(0.8,0.8,0,1/2);	
	yellow:=Base.VoxelFromName("NM3");
	yellow.setcolor(0,1,0,20,4);
	yellow.FRaster(ball,9);
	NEW(ball,center,7/12);	
	yellow.copyonstroke:=FALSE;
	cage:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU341");	
	FOR i:=0 TO 100 DO
		Base.randsphPT(p1,p2,center,8/12);
		cage.stroke(p1,9,yellow)
	END;
(*	yellow.copyprime;	
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
 
