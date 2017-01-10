MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog, NM3;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	Path= Base.Path;
VAR 
	core,cloud,reddot: Voxel;
	conglo: NM3.cell;
	ball: FRep.sphere;
	plane: FRep.plane;
	center,p,n:  PT;
	radius:REAL;
	i,j,k:INTEGER;
	path: Path;
PROCEDURE draw;
BEGIN	
	NEW(conglo); 
	core:=Base.VoxelFromName("NM3"); 
	reddot:=Base.VoxelFromName("Nreddot"); 
	conglo.setcolor(10,100,10,100,1);	
	conglo.copyonstroke:=TRUE;
	NEW(ball,center,6/12);	
		Base.setPT(center,1/2,1/2,1/2);
		radius:=1/2;
		ball.reset(center, radius);
		ball.setcolor(1,1,0,1/2);	
		core.FRasterSolid(ball,27);	
		cloud:=Base.VoxelFromName("NM2"); 	
		ball.setcolor(1,0,1,1/2);			
		cloud.FRasterSolid(ball,32);		
		FOR i:=0 TO 2 BY 2 DO
			FOR j:=0 TO 2 BY 2 DO
				FOR k:=0 TO 2 BY 2  DO
					conglo.blox[i,j,k]:=cloud
				END
			END
		END;
		conglo.blox[0,1,1]:=conglo;
		conglo.blox[1,0,1]:=reddot;		
		conglo.blox[1,1,0]:=conglo;
		conglo.blox[2,1,1]:=reddot;
		conglo.blox[1,2,1]:=core;		
		conglo.blox[1,1,2]:=conglo;
		conglo.blox[1,1,1]:=core;
		cloud.imposter:=reddot;
		conglo.lockTF:=TRUE
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN conglo
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
