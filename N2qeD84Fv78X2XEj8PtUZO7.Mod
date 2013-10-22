MODULE N2qeD84Fv78X2XEj8PtUZO7;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, Out:=KernelLog;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	ball: FRep.sphere;
	dot,v,lobster: Voxel;
	center,p:  PT;
	i:LONGINT;
	
PROCEDURE draw(VAR dott: Voxel);
VAR
	fractaldot, greendot,reddot: Voxel;
BEGIN
	fractaldot:=Base.VoxelFromName("NM3"); 
	fractaldot.setcolor(0,0,100,100,0);	
	greendot:=Base.VoxelFromName("NM3"); 	
 	reddot:=Base.VoxelFromName("NM3"); 	
       lobster:=Base.VoxelFromName("NJOFc7qhMXMly3lot71bNUw");
      	fractaldot.copyonstroke:=TRUE;
      	greendot.copyonstroke:=TRUE;
      	reddot.copyonstroke:=TRUE;
	Base.setPT(center,1/2,1/2,1/2);
(*	NEW(ball,center,6/12);	
	ball.setvoxel(fractaldot);
	fractaldot.FRaster(ball,27);	
*)		
	NEW(ball,center,6/12);	
	ball.setcolor(0.91,0.16,0.1);
	reddot.FRaster(ball,32);
	ball.setvoxel(lobster);	
	greendot.FRaster(ball,32);
	FOR i:=0 TO 300 DO
		p:=Base.randPT();
		IF ball.in(p) THEN fractaldot.stroke(p,8,greendot,v) END;
	END;
	FOR i:=0 TO 200 DO
		p:=Base.randPT();
		fractaldot.stroke(p,8,reddot,v);
	END;
	dott:=fractaldot;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	draw(dot);
	RETURN dot
END thisvox;

 END N2qeD84Fv78X2XEj8PtUZO7. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZO7 ~
 
