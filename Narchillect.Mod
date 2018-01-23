MODULE Narchillect;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"wubble.png") END;
	vox.passable:=FALSE;
	RETURN vox
END thisvox;

END Narchillect. 