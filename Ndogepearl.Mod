MODULE Ndogepearl;
IMPORT Base, TexVox, RotaVox;
  
VAR 
	cv: TexVox.TexVox;
	rv: RotaVox.RVox;
	up,right: Base.PT;
	sabot, vox,v,sphere: Base.Voxel;
	center: Base.PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN
		NEW(cv,"swastika2.jpg");
		vox:=cv;
		vox.passable:=FALSE
	END;
	RETURN vox
END thisvox;

 END Ndogepearl. 
 
 XNXLMarsh.Rez Ndogepearl~