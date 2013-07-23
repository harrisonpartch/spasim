MODULE NhYOBdcESgNhNEXS2S3OXsw;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'etile1.png')  END;
	RETURN vox
END thisvox;

 END NhYOBdcESgNhNEXS2S3OXsw. 