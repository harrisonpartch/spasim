MODULE XLTLVoxel;
IMPORT XLTLBase, XLTLGL, Raster, Graphics:=WMGraphics, GL:=OpenGL, GLC := OpenGLConst,  
		XLTLptcloud, Out:=KernelLog, SYSTEM;

TYPE 	PT=XLTLBase.PT;
		Ray = XLTLBase.Ray;
		Voxel = XLTLBase.Voxel;
		Name = XLTLBase.Name;

TYPE TVox* = OBJECT(Voxel);
VAR
	texture*: XLTLBase.Texture; 

PROCEDURE Shade (VAR ray: Ray);
VAR
	xov,yov,zov:REAL;
BEGIN
	xov:=(ray.ddxyz.x+1/2-ray.lxyz.x)/ray.scale;
	yov:=(ray.ddxyz.y+1/2-ray.lxyz.y)/ray.scale;			
	zov:=(ray.ddxyz.z+1/2-ray.lxyz.z)/ray.scale;			
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale;
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale;		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale;	
	XLTLGL.push(ray.corner,ray.scale, texture);
	ray.terminate:=TRUE
END Shade;

PROCEDURE load*(n: Name); 
VAR
	i: INTEGER;
	img: Raster.Image;
BEGIN
	img :=Graphics.LoadImage(n, TRUE);
	IF img=NIL THEN 
		Out.String("unable to load image ");
		Out.String(n);
		Out.Ln;
	ELSE
		GL.SetFCR;
		GL.glGenTextures(1, SYSTEM.ADR(texture[0]) );
		GL.glBindTexture( GLC.GL_TEXTURE_2D, texture[0]); 
		GL.glTexImage2D( GLC.GL_TEXTURE_2D, 0, 4, img.width, img.height, 0,GLC. GL_RGBA, GLC.GL_UNSIGNED_BYTE, img.adr);
		GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
    	 	GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST );
    	 	GL.DelFCR;
	END;
	passable:=FALSE;
END load;

PROCEDURE clone():Voxel;
VAR
	tv: TVox;
BEGIN
	NEW(tv);
	tv.texture:=texture;
END clone;

END TVox; 

TYPE NTVox* = OBJECT(TVox);
PROCEDURE Shade (VAR ray: Ray);
VAR
	xov,yov,zov:REAL;
BEGIN
	xov:=(ray.ddxyz.x+1/2-ray.lxyz.x)/ray.scale;
	yov:=(ray.ddxyz.y+1/2-ray.lxyz.y)/ray.scale;			
	zov:=(ray.ddxyz.z+1/2-ray.lxyz.z)/ray.scale;			
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale;
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale;		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale;	
	XLTLGL.npush(ray.corner,ray.scale, ray.bloxnorm, texture);
	ray.terminate:=TRUE
END Shade;
END NTVox;

TYPE PtVox* = OBJECT(Voxel);
VAR
	pc: XLTLptcloud.sphere;
	rot: REAL;
	
PROCEDURE &init*;
VAR
	i:LONGINT
BEGIN
	NEW(pc);
	passable:=TRUE
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	xov,yov,zov:REAL;
BEGIN
	xov:=(ray.ddxyz.x+1/2-ray.lxyz.x)/ray.scale;
	yov:=(ray.ddxyz.y+1/2-ray.lxyz.y)/ray.scale;			
	zov:=(ray.ddxyz.z+1/2-ray.lxyz.z)/ray.scale;			
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale;
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale;		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale;	
(*	XLTLGL.dlpush(ray.corner,ray.scale, pc.dlist); *)
END Shade;

END PtVox;


END XLTLVoxel.