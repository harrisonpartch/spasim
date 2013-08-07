MODULE NxYQqSbWc7p4wTZbj9LvbUQ;

IMPORT Base, TexVox;

VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'dietwo.png')  END;
	RETURN vox
END thisvox;

 END NxYQqSbWc7p4wTZbj9LvbUQ. 