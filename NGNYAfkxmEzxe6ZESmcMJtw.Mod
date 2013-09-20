MODULE NGNYAfkxmEzxe6ZESmcMJtw;
IMPORT Base, TexVox;
 VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'blacksun2.png')  END;
	vox.texscale:=10;
	RETURN vox
END thisvox;

 END NGNYAfkxmEzxe6ZESmcMJtw. 