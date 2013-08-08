MODULE NnKyXYNiHwdxuM6wHrbxwuQ;
 IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'die.0.png')  END;
	RETURN vox
END thisvox;

 END NnKyXYNiHwdxuM6wHrbxwuQ. 