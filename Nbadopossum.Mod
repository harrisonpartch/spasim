MODULE Nbadopossum;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"elfstar.png")  END;
	vox.tscale:=27;
	RETURN vox
END thisvox;

 END Nbadopossum. 
 
 Marsh.Rez Nbadopossum ~