MODULE Nugandaknuckles;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"foxbreadmirror.png"); 
	vox.passable:=FALSE;
END Nugandaknuckles. 