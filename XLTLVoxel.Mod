MODULE XLTLVoxel;
IMPORT XLTLBase, XLTLGL, Raster, Graphics:=WMGraphics, GL:=OpenGL, GLC := OpenGLConst,  
		XLTLgeomobj, Out:=KernelLog, SYSTEM;

TYPE 	PT=XLTLBase.PT;
		Ray = XLTLBase.Ray;
		Voxel = XLTLBase.Voxel;
		Name = XLTLBase.Name;
		Texture = XLTLBase.Texture;

TYPE TVox* = OBJECT(Voxel);
VAR
	texture*: Texture; 

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
	XLTLGL.push(ray.corner,ray.scale, texture,ray.far);
	ray.terminate:=TRUE
END Shade;

PROCEDURE load*(n: Name); 
VAR
	i: INTEGER;
	img: Raster.Image;
BEGIN
	img :=Graphics.LoadImage(n, TRUE); (* img format is BGRA8888 *)
	IF img=NIL THEN 
		Out.String("unable to load image ");
		Out.String(n);
		Out.Ln;
	ELSE
		Out.String(n);
		Out.Ln;
		GL.SetFCR;
		GL.glGenTextures(1, SYSTEM.ADR(texture[0]) );
		GL.glBindTexture( GLC.GL_TEXTURE_2D, texture[0]); 
		GL.glTexImage2D( GLC.GL_TEXTURE_2D, 0, 4, img.width, img.height, 0,GLC. GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);
		GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
    	 	GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST ); 
    	 	GL.DelFCR;
	END;
	passable:=FALSE;
	Out.String("loaded image ");
	Out.Ln;
END load;

PROCEDURE clone():Voxel;
VAR
	tv: TVox;
BEGIN
	NEW(tv);
	tv.texture:=texture;
END clone;

END TVox; 

TYPE fleetingTVox* = OBJECT(TVox);  (* fleeting means: not persistent. Thus it must only be drawn for one frame when a ray hits it*)

PROCEDURE push(p:PT; scale:LONGINT; texture:Texture);
BEGIN
	XLTLGL.fleetingpush(p,scale,texture);
END push;

END fleetingTVox; 

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
	pc: XLTLgeomobj.psphere;
	rot: REAL;
	
PROCEDURE &init*;
VAR
	i:LONGINT
BEGIN
	NEW(pc);
	passable:=TRUE;
(*	register *)
END init;

PROCEDURE tick;
BEGIN
	rot:=rot+10.3;
END tick;

PROCEDURE Shade (VAR ray: Ray);
VAR
	xov,yov,zov:REAL;
BEGIN
	xov:=(ray.ddxyz.x+1/2-ray.lxyz.x)/ray.scale;
	yov:=(ray.ddxyz.y+1/2-ray.lxyz.y)/ray.scale;			
	zov:=(ray.ddxyz.z+1/2-ray.lxyz.z)/ray.scale;			
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale+1/(2*ray.scale);
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	XLTLGL.dlpush(ray.corner,ray.scale, rot, pc.dlist); 
END Shade;

END PtVox;


TYPE TPtVox* = OBJECT(TVox);
VAR
	pc: XLTLgeomobj.sphere;
	rot: REAL;
	
PROCEDURE &init*;
VAR
	i:LONGINT
BEGIN
	NEW(pc);
	passable:=TRUE;
	register
END init;

PROCEDURE tick;
BEGIN
	rot:=rot+10.3;
END tick;

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
	XLTLGL.push(ray.corner,ray.scale, texture, ray.far);
	ray.terminate:=TRUE;
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale+1/(2*ray.scale);
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	XLTLGL.dlpush(ray.corner,ray.scale, rot, pc.dlist); 
END Shade;

END TPtVox;

TYPE BiVox*=OBJECT(Voxel);
VAR
	v1,v2: Voxel;

PROCEDURE load*(a,b: Voxel);
BEGIN
	v1:=a;
	v2:=b;
END load;

PROCEDURE Shade (VAR ray: Ray);
BEGIN
	IF v1#NIL THEN v1.Shade(ray) END;
	IF v2#NIL THEN v2.Shade(ray) END;
END Shade;

END BiVox;

TYPE SphVox* = OBJECT(Voxel);
VAR
	rot: REAL;
	sph: XLTLgeomobj.sphere;
	
PROCEDURE &init*;
VAR
	i:LONGINT
BEGIN
	NEW(sph);
	register
END init;

PROCEDURE tick;
BEGIN
(*	rot:=rot+10.3;*)
END tick;

PROCEDURE Shade (VAR ray: Ray);
VAR
	xov,yov,zov:REAL;
BEGIN
	xov:=(ray.ddxyz.x+1/2-ray.lxyz.x)/ray.scale;
	yov:=(ray.ddxyz.y+1/2-ray.lxyz.y)/ray.scale;			
	zov:=(ray.ddxyz.z+1/2-ray.lxyz.z)/ray.scale;			
	ray.corner.x:= (ENTIER((ray.xyz.x+xov)*ray.scale))/ray.scale+1/(2*ray.scale);
	ray.corner.y:= (ENTIER((ray.xyz.y+yov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	ray.corner.z:= (ENTIER((ray.xyz.z+zov)*ray.scale))/ray.scale+1/(2*ray.scale);		
	XLTLGL.dlpush(ray.corner,ray.scale, rot, sph.dlist); 
END Shade;

END SphVox;



END XLTLVoxel.