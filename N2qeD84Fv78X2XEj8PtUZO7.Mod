MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, NM3;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	Path= Base.Path;
VAR 
	core,cloud,reddot,conglo: Voxel;
	ball: FRep.sphere;
	plane: FRep.plane;
	center,p,n:  PT;
	radius:REAL;
	i,j,k:INTEGER;
	path: Path;
PROCEDURE draw;
BEGIN	
	conglo:=Base.VoxelFromName("NM3"); 
	reddot:=Base.VoxelFromName("Nreddot"); 
	conglo.setcolor(0,0,0,1,1,1);	
	NEW(ball,center,6/12);	
		Base.setPT(center,1/2,1/2,1/2);
		radius:=1/2;
		ball.reset(center, radius);
		ball.setcolor(1,1,0,1/2);	
		ball.setcolor(1,0,1,1/2);	
		FOR i:= 0 TO 30 DO
			center:=Base.randPT();
			radius:=Base.rand.Uniform()/3;
			ball.reset(center,radius);
			ball.setcolor(i/10, Base.rand.Uniform(),1-i/10,0);
			conglo.FRaster(ball,27)
		END;	
		conglo.copyonstroke:= TRUE;		
		conglo.passable:= TRUE;						
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglo
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO7. 
 
Marsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
