MODULE NnKyXYNiHwdxuM6wHrbxwuQ;
 IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
NEW(vox,'rahowacat.png');
vox.tscale:=256; 
END NnKyXYNiHwdxuM6wHrbxwuQ. 