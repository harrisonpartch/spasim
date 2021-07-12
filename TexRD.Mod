MODULE TexRD;
IMPORT Base, Files,SPSMMath, Noise, Raster, Graphics := WMGraphics, Random, Math:=MathL,Out := KernelLog;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
 	Texture=Base.Texture;
	TexCube= Base.TexCube;

(* pseudosolid texture *)

TYPE TexVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	name*: Name;
PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=0;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: SIZE;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j,face: INTEGER;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2,color3: Base.Color;
	raycolor: Base.ray_color;
	txcube: TexCube;
	rlf: REAL;
	rlm: BOOLEAN;
	lxyz,exit,mid: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: SIZE;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
	ai,ainv, middy:REAL;
BEGIN
	IF ray.length>0 THEN
		IF tscale>1 THEN
			xx:=ray.xyz.x;
			yy:=ray.xyz.y;
			zz:=ray.xyz.z;
			xx:=ABS(xx*tscale-ENTIER(xx*tscale));
			yy:=ABS(yy*tscale-ENTIER(yy*tscale));
			zz:=ABS(zz*tscale-ENTIER(zz*tscale));
			xxx:=ABS(1/2-xx);
			yyy:=ABS(1/2-yy);
			zzz:=ABS(1/2-zz);
			IF xxx>yyy THEN
				IF xxx>zzz THEN
					(* yz pyramid *)  				(*  faces come in pairs: (0,3),(2,5),(1,4) *)
					lx:=yy; ly:=zz;
					lx1:=tscale*ray.lxyz.x/ray.scale;
					CASE ray.face OF
						0:
						|1: lx:=lx+lx1;
						|2:  ly:=ly+lx1;
						|3:
						|4: lx:=lx+lx1-1;
						|5: ly:=ly+lx1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			ELSE
				IF yyy>zzz THEN
					(* xz pyramid *)
					lx:=xx; ly:=zz;
					ly1:=tscale*ray.lxyz.y/ray.scale;
					CASE ray.face OF
						 0: lx:= lx+ly1;
						|1:
						|2: ly:=ly+ly1;
						|3: lx:= lx+ly1-1;
						|4:
						|5:ly:=ly+ly1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			END;
			CASE ray.face OF
				 0: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|1: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|2: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
				|3: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|4: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|5: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
			END
		ELSE
			CASE ray.face OF
				 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|5: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|6: lx := ray.lxyz.x; ly := ray.lxyz.y; lz:=ray.lxyz.z; (* 6 means inside *)
			END;
			ly:=1-ly;
		END;
 		mip:=ray.length*Base.texdetail;
		IF mip>12 THEN
			color:=texcube.side[ray.face].pixelmip_zero(lx,ly); 
		ELSIF mip>3 THEN
			color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		ELSIF mip>1 THEN
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);
		ELSE
			color:=texcube.side[ray.face].pixel(lx,ly); 
		END; 
		IF   color.alpha<0.99 THEN
		 	IF color.alpha>0.9 THEN
				mirror(ray,0);
			ELSE
				dot2:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
				dot1:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
				mix:=ray.length*ray.scale*0.00005;
				IF mix>1 THEN mix:=1 END;
				dot:=mix*dot1+(1-mix)*dot2;		
				dr:=color.alpha*color.red*dot*ray.clr.ra;
				dg:=color.alpha*color.green*dot*ray.clr.ga;
				db:=color.alpha*color.blue*dot*ray.clr.ba;
				ray.clr.r := ray.clr.r + dr;
				ray.clr.g := ray.clr.g + dg;
				ray.clr.b := ray.clr.b + db;
				ray.clr.ra:=ray.clr.ra-dr;
				ray.clr.ga:=ray.clr.ga-dg;			
				ray.clr.ba:=ray.clr.ba-db;			
				IF (ray.clr.ra<0.1) OR (ray.clr.ga<0.1) OR (ray.clr.ba<0.1) THEN 
					ray.terminate:=TRUE 
				END;	
			END
		ELSE
			dot:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
(*			dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
			mix:=ray.length*ray.scale*0.5;
			IF mix>1 THEN mix:=1 END;
			dot:=mix*dot1+(1-mix)*dot2;		
	*)		dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot;
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;
			ray.terminate:=TRUE
		END
	ELSE
	  (* camera is inside textured cube *)
	  
	END;
END Shade;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE mirror(VAR ray: Ray; CONST mix: REAL);
VAR
	a:REAL;
BEGIN
	ray.clr.alpha:= ray.clr.alpha - 0.1;
	IF ray.clr.alpha<0.1 THEN
		ray.terminate:=TRUE
	ELSE	
		ray.clr.ra:= ray.clr.ra - 0.21;
		ray.clr.ga := ray.clr.ga - 0.21;
		ray.clr.ba := ray.clr.ba - 0.21;	
		reflect(ray.dxyz, ray.normal);
		IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
		IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
		IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
		ray.xyz.x:=ray.xyz.x+ray.dxyz.x/(1000*ray.scale);
		ray.xyz.y:=ray.xyz.y+ray.dxyz.y/(1000*ray.scale);	
		ray.xyz.z:=ray.xyz.z+ray.dxyz.z/(1000*ray.scale);	
	END;
END mirror;

END TexVox;


TYPE TexVoxNoMirror* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	name*: Name;
PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=0;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: SIZE;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j,face: INTEGER;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2,color3: Base.Color;
	raycolor: Base.ray_color;
	txcube: TexCube;
	rlf: REAL;
	rlm: BOOLEAN;
	lxyz,exit,mid: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: SIZE;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
	ai,ainv, middy:REAL;
BEGIN
	IF ray.length>0 THEN
		IF tscale>1 THEN
			xx:=ray.xyz.x;
			yy:=ray.xyz.y;
			zz:=ray.xyz.z;
			xx:=ABS(xx*tscale-ENTIER(xx*tscale));
			yy:=ABS(yy*tscale-ENTIER(yy*tscale));
			zz:=ABS(zz*tscale-ENTIER(zz*tscale));
			xxx:=ABS(1/2-xx);
			yyy:=ABS(1/2-yy);
			zzz:=ABS(1/2-zz);
			IF xxx>yyy THEN
				IF xxx>zzz THEN
					(* yz pyramid *)  				(*  faces come in pairs: (0,3),(2,5),(1,4) *)
					lx:=yy; ly:=zz;
					lx1:=tscale*ray.lxyz.x/ray.scale;
					CASE ray.face OF
						0:
						|1: lx:=lx+lx1;
						|2:  ly:=ly+lx1;
						|3:
						|4: lx:=lx+lx1-1;
						|5: ly:=ly+lx1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			ELSE
				IF yyy>zzz THEN
					(* xz pyramid *)
					lx:=xx; ly:=zz;
					ly1:=tscale*ray.lxyz.y/ray.scale;
					CASE ray.face OF
						 0: lx:= lx+ly1;
						|1:
						|2: ly:=ly+ly1;
						|3: lx:= lx+ly1-1;
						|4:
						|5:ly:=ly+ly1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			END;
			CASE ray.face OF
				 0: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|1: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|2: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
				|3: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|4: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|5: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
			END
		ELSE
			CASE ray.face OF
				 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|5: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|6: lx := ray.lxyz.x; ly := ray.lxyz.y; lz:=ray.lxyz.z; (* 6 means inside *)
			END;
			ly:=1-ly;
		END;
 		mip:=ray.length*Base.texdetail;
		IF mip>12 THEN
			color:=texcube.side[ray.face].pixelmip_zero(lx,ly); 
		ELSIF mip>3 THEN
			color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		ELSIF mip>1 THEN
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);
		ELSE
			color:=texcube.side[ray.face].pixel(lx,ly); 
		END; 
		IF  TRUE THEN
		 	IF FALSE THEN
				ELSE
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
				dr:=color.red*dot;
				dg:=color.green*dot;
				db:=color.blue*dot;
				ray.clr.r := ray.clr.r + dr*ray.clr.ra;
				ray.clr.g := ray.clr.g + dg*ray.clr.ga;
				ray.clr.b := ray.clr.b + db*ray.clr.ba;
				ray.clr.ra:=ray.clr.ra - color.alpha;
				ray.clr.ga:=ray.clr.ga - color.alpha;			
				ray.clr.ba:=ray.clr.ba - color.alpha;			
				IF (ray.clr.ra<0.1) OR (ray.clr.ga<0.1) OR (ray.clr.ba<0.1) THEN 
					ray.terminate:=TRUE 
				END;	
			END
		ELSE
			dot:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
			dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot*middy;
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;
			ray.terminate:=TRUE
		END
	ELSE
	  (* camera is inside textured cube *)
	  
	END;
END Shade;

END TexVoxNoMirror;

TYPE BillboardNoMirror* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	name*: Name;
PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=0;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: SIZE;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j,face: INTEGER;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2,color3: Base.Color;
	raycolor: Base.ray_color;
	txcube: TexCube;
	rlf: REAL;
	rlm: BOOLEAN;
	lxyz,exit,mid: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: SIZE;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
	ai,ainv, middy:REAL;
BEGIN
	IF TRUE THEN
		IF tscale>1 THEN
			xx:=ray.xyz.x;
			yy:=ray.xyz.y;
			zz:=ray.xyz.z;
			xx:=ABS(xx*tscale-ENTIER(xx*tscale));
			yy:=ABS(yy*tscale-ENTIER(yy*tscale));
			zz:=ABS(zz*tscale-ENTIER(zz*tscale));
			xxx:=ABS(1/2-xx);
			yyy:=ABS(1/2-yy);
			zzz:=ABS(1/2-zz);
			IF xxx>yyy THEN
				IF xxx>zzz THEN
					(* yz pyramid *)  				(*  faces come in pairs: (0,3),(2,5),(1,4) *)
					lx:=yy; ly:=zz;
					lx1:=tscale*ray.lxyz.x/ray.scale;
					CASE ray.face OF
						0:
						|1: lx:=lx+lx1;
						|2:  ly:=ly+lx1;
						|3:
						|4: lx:=lx+lx1-1;
						|5: ly:=ly+lx1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			ELSE
				IF yyy>zzz THEN
					(* xz pyramid *)
					lx:=xx; ly:=zz;
					ly1:=tscale*ray.lxyz.y/ray.scale;
					CASE ray.face OF
						 0: lx:= lx+ly1;
						|1:
						|2: ly:=ly+ly1;
						|3: lx:= lx+ly1-1;
						|4:
						|5:ly:=ly+ly1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2:
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			END;
			CASE ray.face OF
				 0: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|1: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|2: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
				|3: lx2 := ray.lxyz.y; ly2 := 1-ray.lxyz.z;
				|4: lx2 := ray.lxyz.x; ly2 := 1-ray.lxyz.z;
				|5: lx2 := ray.lxyz.x; ly2 := ray.lxyz.y;
			END
		ELSE
			CASE ray.face OF
				 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
				|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
				|5: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|6: lx := ray.lxyz.x; ly := ray.lxyz.y; lz:=ray.lxyz.z; (* 6 means inside *)
			END;
			ly:=1-ly;
		END;
 		mip:=ray.length*Base.texdetail;
		IF mip>12 THEN
			color:=texcube.side[ray.face].pixelmip_zero(lx,ly); 
		ELSIF mip>3 THEN
			color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		ELSIF mip>1 THEN
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);
		ELSE
			color:=texcube.side[ray.face].pixel(lx,ly); 
		END; 
		IF TRUE THEN
		 	IF FALSE THEN
				ELSE
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y + ray.fnormal.z*ray.dxyz.z);
				dr:=color.red*dot;
				dg:=color.green*dot;
				db:=color.blue*dot;
				ray.clr.r := ray.clr.r + dr*ray.clr.ra;
				ray.clr.g := ray.clr.g + dg*ray.clr.ga;
				ray.clr.b := ray.clr.b + db*ray.clr.ba;
				ray.clr.ra:=ray.clr.ra - color.alpha;
				ray.clr.ga:=ray.clr.ga - color.alpha;			
				ray.clr.ba:=ray.clr.ba - color.alpha;			
				IF (ray.clr.ra<0.1) OR (ray.clr.ga<0.1) OR (ray.clr.ba<0.1) THEN 
					ray.terminate:=TRUE 
				END;	
			END
		ELSE
			Base.normalizePT(ray.normal);
			dot:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
(*			dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
			mix:=ray.length*ray.scale*0.5;
			IF mix>1 THEN mix:=1 END;
			dot:=mix*dot1+(1-mix)*dot2;		
	*)		dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot;
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;
			ray.terminate:=TRUE
		END
	ELSE
	  (* camera is inside textured cube *)
	  
	END;
END Shade;

END BillboardNoMirror;


TYPE TexCubeVox* = OBJECT(TexVox);

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,TRUE);
	name:=n;
END init;

END TexCubeVox;

TYPE NoiseVox* = OBJECT(Voxel);
VAR
	seed:SIZE;
	octaves:INTEGER;
	aa,bb,cc,persistence: REAL;
	tscale: REAL;

PROCEDURE&init*(s:SIZE;o:INTEGER; a,b,c,p:REAL);
BEGIN
	seed:=s; octaves:=SHORT(o); persistence:=p;
	aa:=a; bb:=b; cc:=c;
	tscale:=243;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	r,g,b,a: REAL;
	dr,dg,db:REAL;
	bb,c, x, y, z,tq: REAL;
	i,j: INTEGER;
	bpdx,bpdy: REAL;
	dot:REAL;
	xov,yov,zov:REAL;
	color,color1,color2: Base.Color;
BEGIN
	x:= ray.xyz.x; y:=ray.xyz.y; z:=ray.xyz.z;
	x:= x; y:=y; z:=z;
	c:=SHORT(Noise.noise3dperlinabs(x,y,z, 6985, 4,3.5));
	color.red:=c;
	color.green:=c;
	color.blue:=c;
	Base.clampColor(color);
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)*0.7+0.4;
	dr:=color.red*dot*ray.clr.ra;
	dg:=color.green*dot*ray.clr.ga;
	db:=color.blue*dot*ray.clr.ba;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db;
	ray.terminate:=TRUE
END Shade;

END NoiseVox;

PROCEDURE nshade(CONST nc: NCube; VAR ray: Ray);
VAR
	mix,dot,dot1,dot2: REAL;
BEGIN
	dot1 := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	dot2:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
	dot1:=dot1*0.7+0.3;
	dot2:=dot2*0.7+0.3;
	IF ray.length*ray.scale<75 THEN mix:=1-(ray.length*ray.scale/75) ELSE mix:=0 END;
	dot:=mix*dot2+(1-mix)*dot1;
	ray.clr.r := ray.clr.r + nc.color.red * ray.clr.ra*dot;
	ray.clr.g := ray.clr.g + nc.color.green * ray.clr.ga*dot;
	ray.clr.b := ray.clr.b + nc.color.blue * ray.clr.ba*dot;
	ray.terminate:=TRUE
END nshade;

END TexRD.
