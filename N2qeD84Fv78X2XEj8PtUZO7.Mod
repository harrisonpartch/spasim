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
	i:LONGINT;
	path: Path;
PROCEDURE draw;
BEGIN
	conglo:=Base.VoxelFromName("NM4"); 	
	conglo.copyonstroke:=TRUE;
	NEW(ball,center,6/12);	
	FOR i:=0 TO 100 DO
		ball.reset(Base.randPT(), Base.rand.Uniform()/18);
		ball.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());	
		conglo.FRaster(ball,16);
		NEW(plane,Base.randPT(), Base.randPT());
		plane.setcolor(Base.rand.Uniform(),Base.rand.Uniform(),Base.rand.Uniform());
		conglo.FRaster(plane,16);
	END
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglo
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
