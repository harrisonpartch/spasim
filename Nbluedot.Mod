MODULE Nbluedot;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVoxNoMirror;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;
BEGIN
	NEW(vox,'B.png')
END Nbluedot. 