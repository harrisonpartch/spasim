MODULE Nacidcats;

IMPORT Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,"acidcats.png")  END;
	vox.tscale:=10;
	RETURN vox
END thisvox;

 END Nacidcats. 
 
 Marsh.Rez Nacidcats ~