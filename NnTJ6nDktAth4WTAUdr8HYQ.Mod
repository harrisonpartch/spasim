MODULE NnTJ6nDktAth4WTAUdr8HYQ;
IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"sand.png") END;
	vox.pstscale:= 100;
	RETURN vox
END thisvox;

 END NnTJ6nDktAth4WTAUdr8HYQ. 