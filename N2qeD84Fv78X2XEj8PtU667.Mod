MODULE N2qeD84Fv78X2XEj8PtU667;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  FRep, RotaVox, Out:=KernelLog, Random;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
	Path=Base.Path;
	
TYPE anim=OBJECT(Base.V)
VAR
	target: Voxel;
	i: LONGINT;

PROCEDURE tick;
VAR 
	i: LONGINT;
BEGIN
	FOR i:=0 TO 10 DO
		p1:=Base.randPT();
		target.strokephemeral(p1,8,greendot,v);
	END;	
END tick;

BEGIN
	register;
END anim
	
VAR 
	ball: FRep.sphere;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	tblue: Voxel;
	dot,bdot,rdot,gdot,reddot,bluedot,greendot, tigerlily,v: Voxel;
	center, p,p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	shell: RotaVox.RVox;
	an: anim;
	path: Path;
PROCEDURE draw;
BEGIN	 
	bluedot:=Base.VoxelFromName("NM2");
	reddot:=Base.VoxelFromName("NM4");
	greendot:=Base.VoxelFromName("NM3");
	Base.setPT(center,1/2,1/2,1/2);
	rdot:=Base.VoxelFromName("Nreddot");  
	bdot:=Base.VoxelFromName("Nbluedot");
	gdot:=Base.VoxelFromName("Ngreendot");	
	tblue:=Base.VoxelFromName("Ntblue");	
	NEW(ball,center,0.45);	
	ball.setvoxel(tblue);	
(*	reddot.FRaster(ball,16);	*)
	NEW(ball,center,0.33);
	ball.setvoxel(bdot);	
	bluedot.FRaster(ball,16);
	ball.setvoxel(NIL);	
	ball.setcolor(1,1,1,1);
	reddot.FRaster(ball,64);	
	ball.setvoxel(NIL);	
	ball.setcolor(1,1,1/2,1);	
	greendot.FRaster(ball,64);	
	NEW(shell,reddot,Base.mkPT(0,1,0),Base.mkPT(0,0,1),0.03,0.01);
	FOR i:=0 TO 1 DO
		Base.randsphPT(p,n,center,0.45);
		reddot.stroke(p,16,path,greendot,v);
		Base.randsphPT(p,n,center,0.45);
		reddot.stroke(p,16,path,shell,v);
	END;	
	reddot.copyonstroke:=TRUE;
	greendot.lockTF:=TRUE;
	greendot.DTL:=1000;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN greendot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU667. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
