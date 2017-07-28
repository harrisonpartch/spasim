MODULE Nharrisonavatar;
IMPORT Base, TexVox, RotaVox;
  
VAR 
	cv: TexVox.TexVox;
	sabot, vox,v,sphere: Base.Voxel;
	center: Base.PT;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"harrisonavatar.0.png");
	cv.passable:=FALSE;
	cv.tscale:=1000;	
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavatar ~
 
	NEW(cv,"seahorse.png"); 	