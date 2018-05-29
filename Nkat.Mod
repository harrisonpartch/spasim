MODULE Nkat;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"galaxgranite.png");
	vox.tscale:=300;
END Nkat. 