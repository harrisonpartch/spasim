MODULE NUDjmgXk2BBrW9roFylvaLQ;
IMPORT Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'diezero.png')  END;
	RETURN vox
END thisvox;

 END NUDjmgXk2BBrW9roFylvaLQ. 