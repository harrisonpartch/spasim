MODULE NGNYAfkxmEzxe6ZESmcMJtw;
IMPORT Base, TexVox;
 VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'sfish.png')  END;
	RETURN vox
END thisvox;

 END NGNYAfkxmEzxe6ZESmcMJtw. 