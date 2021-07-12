MODULE Nlachlan;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

PROCEDURE tick;
BEGIN
	vox.tscale:= 26 + Base.rand.Uniform()*5;
END tick;

BEGIN
	NEW(vox,"lachlan.png");
	vox.tscale:=1000;  
	vox.passable:=FALSE;
	vox.register;
END Nlachlan. 