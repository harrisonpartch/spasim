MODULE Nharrisonavatar;
IMPORT Base, TexVox, XNXLRotaVox;
  
VAR 
	cv: TexVox.TexVox;
	rv: XNXLRotaVox.RVox;
	up,right: Base.PT;
	sabot, vox,v: Base.Voxel;
	center: Base.PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN 
		sabot:=Base.VoxelFromName("NM3");	
		NEW(cv,"harrisonavatar.png");
		Base.setPT(center,1/2,1/2,1/2);
		sabot.stroke(center,3,cv,v);
		Base.setPT(up,0,0,1);	
		Base.setPT(right,1,0,0);
		NEW(rv,sabot,up, right, 1/30, 0)	
	END;
	vox:=cv;
	RETURN vox
END thisvox;

 END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavtar ~