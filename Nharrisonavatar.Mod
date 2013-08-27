MODULE Nharrisonavatar;
IMPORT Base, TexVox, XNXLRotaVox;
  
VAR 
	cv: TexVox.TexCubeVox;
	rv: XNXLRotaVox.RVox;
	up,right: Base.PT;
	sabot, vox,v: Base.Voxel;
	center: Base.PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN 
		sabot:=Base.VoxelFromName("NM3");	
		NEW(cv,"die");
		Base.setPT(center,1/2,1/2,1/2);
		sabot.stroke(center,1,cv,v);
		Base.setPT(up,0,0,1);	
		Base.setPT(right,1,0,0);
		NEW(rv,sabot,up, right, 3/10, 1/10)	
	END;
	vox:=rv;
	RETURN vox
END thisvox;

 END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavtar ~