MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	Path= Base.Path;
VAR 
	ball: FRep.sphere;
	dot,v,lobster: Voxel;
	center,p,n:  PT;
	i:LONGINT;
	path: Path;
PROCEDURE draw;
VAR
	fractaldot, greendot,reddot: Voxel;
BEGIN
	fractaldot:=Base.VoxelFromName("NM2"); 
	fractaldot.setcolor(0,0,1000,1000,0);	
	greendot:=Base.VoxelFromName("NM2"); 	
 	reddot:=Base.VoxelFromName("NM2"); 	
       lobster:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw");
      	fractaldot.copyonstroke:=TRUE;
      	greendot.copyonstroke:=TRUE;
      	reddot.copyonstroke:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);
	
	NEW(ball,center,6/12);	
	ball.setcolor(0.91,0.06,0.1);
	reddot.FRaster(ball,32);
	ball.setcolor(0.01,0.06,0.91);
	greendot.FRaster(ball,32);
	FOR i:=0 TO 300 DO
		Base.randsphPT(p,n,center,7/12);
		fractaldot.stroke(p,32,path,greendot,v)
	END;
	FOR i:=0 TO 200 DO
		Base.randsphPT(p,n,center,7/12);
		fractaldot.stroke(p,32,path,reddot,v);
	END;
	dot:=fractaldot;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN dot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
