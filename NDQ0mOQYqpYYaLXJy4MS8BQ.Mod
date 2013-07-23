MODULE NDQ0mOQYqpYYaLXJy4MS8BQ;
IMPORT Base, TexVox;
VAR
	vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'leaves.png') END;
	RETURN vox
END thisvox;
 END NDQ0mOQYqpYYaLXJy4MS8BQ. 