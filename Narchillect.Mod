MODULE Narchillect;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"earthebolachan.png") END;
	vox.passable:=FALSE;
	vox.tscale:=0;
	RETURN vox
END thisvox;

END Narchillect. 