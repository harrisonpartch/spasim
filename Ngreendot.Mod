MODULE Ngreendot;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;
BEGIN
	NEW(vox,'greendot.png');
	vox.tscale:=100
END Ngreendot. 