MODULE Nlady;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVoxNoMirror;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

PROCEDURE tick;
BEGIN
	vox.tscale:= 26 + Base.rand.Uniform()*5;
END tick;

BEGIN
	NEW(vox,"waterdrops.png");
	vox.tscale:=0;  
	vox.passable:=TRUE;
	vox.register;
END Nlady. 