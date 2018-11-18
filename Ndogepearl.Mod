MODULE Ndogepearl;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"dogepearl.png")  END;
	vox.passable:=TRUE;
	vox.tscale:=27;
	RETURN vox
END thisvox;

 END Ndogepearl. 
 
 Marsh.Rez Ndogepearl ~