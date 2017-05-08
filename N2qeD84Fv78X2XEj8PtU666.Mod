MODULE N2qeD84Fv78X2XEj8PtU666;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	yellow,bludot,MCUBE,v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	vu: Voxel;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	yellow:=Base.VoxelFromName("NM3");
	yellow.setcolor(1,1,0,0,1);
   	MCUBE:=Base.VoxelFromName("Nr3kPtbyEYLFK3AN2UUVrqg");
	FOR i:=0 TO 100 DO
		yellow.stroke(Base.randPT(),9,MCUBE);
	END;
	yellow.copyonstroke:=TRUE;	
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN yellow
END thisvox;

BEGIN 
	draw
END N2qeD84Fv78X2XEj8PtU666. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
