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
	NEW(cv,"harrisonavatar.png");
	cv.passable:=TRUE;
	cv.tscale:=0;	
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavtar ~