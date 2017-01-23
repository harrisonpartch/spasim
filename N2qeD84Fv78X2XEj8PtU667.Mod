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
	reddot:=Base.VoxelFromName("NM3");

	NEW(ball,center,0.57);

	ball.setvoxel(NIL);	
	ball.setcolor(1,1,1,1);
	reddot.FRaster(ball,64);	
	reddot.texture:=rdot;


END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN reddot
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU667. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
