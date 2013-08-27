MODULE NnKyXYNiHwdxuM6wHrbxwuQ;
 IMPORT Base, TexVox;
  
VAR vox: TexVox.TexCubeVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'die')  END;
	RETURN vox
END thisvox;

 END NnKyXYNiHwdxuM6wHrbxwuQ. 