MODULE Nugandaknuckles;
IMPORT Base:=Base, TexVox;
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
	NEW(vox,"ugandaknucklesmosaic.png");
	vox.tscale:=0;  
	vox.passable:=TRUE;
	vox.register;
END Nugandaknuckles. 