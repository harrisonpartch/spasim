MODULE NnKyXYNiHwdxuM6wHrbxwuQ;
 IMPORT Base:=XNXLBase, XNXLTexVox;
  
VAR vox: XNXLTexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'axolotl.png')  END;
	RETURN vox
END thisvox;

 END NnKyXYNiHwdxuM6wHrbxwuQ. 