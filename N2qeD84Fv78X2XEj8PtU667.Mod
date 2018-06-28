MODULE N2qeD84Fv78X2XEj8PtU667;(*anonymous module created by saboteur*)
  
IMPORT Objects, Base,  TexVox, FRep, RotaVox, Out:=KernelLog, Random;

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
	vox: TexVox.TexVox;
	ball: FRep.sphere;
	noise: FRep.noise;
	cyl: FRep.hexgrid;
	tblue: Voxel;
	dot,bdot,rdot,gdot,reddot,bluedot,greendot, bottlepossum,v: Voxel;
	center, pole ,p1, p2,n:  PT;
	i:LONGINT;
	rand: Random.Generator;
	shell: RotaVox.RVox;
	an: anim;
	path: Path;
PROCEDURE draw;
BEGIN	 
	center:=Base.mkPT(1/2,1/2,1/2);
	pole:=Base.mkPT(1/2,1/2,1);	
	NEW(vox,"axolotl.png");
	vox.tscale:=4050;
	reddot:=Base.VoxelFromName("NM3");
	bottlepossum:=Base.VoxelFromName("Nbottlepossum"); 
	NEW(ball,center,0.33);
	ball.setcolor(0.7,0.6,0.6,1);
	reddot.FRaster(ball,9);	
	reddot.copyonstroke:=TRUE;
	NEW(shell,vox,center,pole,0.1,0.1);
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	reddot.copyonstroke:=TRUE;
	RETURN vox
END thisvox;

BEGIN
	draw
END N2qeD84Fv78X2XEj8PtU667. 
 
XNXLMarsh.Rez N2qeD84Fv78X2XEj8PtUZOQ ~
 
