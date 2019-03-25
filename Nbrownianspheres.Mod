MODULE Nbrownianspheres;

IMPORT Base, FRep, Out:=KernelLog;
TYPE 
	PT = Base.PT;
	Voxel = Base.Voxel;  

VAR 
	ball: FRep.sphere;
	cyl: FRep.hexgrid;
	wiggleball1, wiggleball2, wiggleball3, nark,  v: Voxel;
	center, p1, p2,n:  PT;
	i:LONGINT;
	
PROCEDURE draw;
VAR
	i: LONGINT;
BEGIN
	nark:=Base.VoxelFromName("Narchillect"); 
	Base.setPT(center,1/2,1/2,1/2);
	wiggleball1:=Base.VoxelFromName("NM3");
	NEW(ball,center,0.5);
	ball.setcolor(1,1,0,1/2);
	
	wiggleball1.FRaster(ball,32);
	wiggleball1.lock;
	wiggleball2:=Base.VoxelFromName("NM3");
	ball.setcolor(1,1,0,1/2);	
	wiggleball2.FRaster(ball,9);
	wiggleball2.lock;
	wiggleball3:=Base.VoxelFromName("NM3");	
	v:=Base.VoxelFromName("NM3");
	v.register;
	v.tick;
	Out.Char('v');
	v.setcolor(0,0,0,1000,1000,1000);
	FOR i:=0 TO 3000 DO
		v.stroke(Base.randPT(),16, wiggleball1);
	END;
	FOR i:=0 TO 100 DO
		v.stroke(Base.randPT(),8, v);
	END;	
END draw;

PROCEDURE tick;
BEGIN
	Out.Char('v');
	v.erase(center,1);
	v.stroke(center, Base.rand.Dice(5)+1, wiggleball1);
END tick;

PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN wiggleball1;
END thisvox;

BEGIN
	draw;
END Nbrownianspheres.