MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	Path= Base.Path;
VAR 
	conglo: Voxel;
	ball: FRep.sphere;
	plane: FRep.plane;
	center,p,n:  PT;
	radius:REAL;
	i:LONGINT;
	path: Path;
PROCEDURE draw;
BEGIN
	conglo:=Base.VoxelFromName("NM3"); 
	conglo.setcolor(10,100,10,100,1);	
	conglo.copyonstroke:=TRUE;
	NEW(ball,center,6/12);	
	FOR i:=0 TO 200 DO
		center:=Base.randPT();
		radius:=Base.rand.Uniform()/28;
		ball.reset(center, radius);
		ball.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform(),1/2);	
		conglo.FRaster(ball,27);	
(*		NEW(plane,Base.randPT(), Base.randPT());
		plane.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform(),1);
		conglo.FRaster(plane,16);
*)	END
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglo
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
