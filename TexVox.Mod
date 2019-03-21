MODULE TexVox;
IMPORT Base, Files,SPSMMath, Noise, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog;

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

TYPE AvaVox* = OBJECT(Voxel);
VAR
	texcube*: TexCube;
	name: Name;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	dr,dg,db,a: REAL;
	dot1,dot2,mix: REAL;
	lx,ly: REAL;
	i,j,face: INTEGER;
	dot: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color: Color;
	raycolor: Base.ray_color;
	exit:PT;
	xx,yy,zz,ai,ainv: REAL;
BEGIN
	IF ray.length>0.00001 THEN
		xx:=ray.xyz.x;
		yy:=ray.xyz.y;
		zz:=ray.xyz.z;
		ray.lxyz.x:=xx*tscale-ENTIER(xx*tscale);
		ray.lxyz.y:=yy*tscale-ENTIER(yy*tscale);
		ray.lxyz.z:=zz*tscale-ENTIER(zz*tscale);
		CASE ray.face OF
			 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
			|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
			|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
			|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
			|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
			|5: lx := ray.lxyz.x; ly := ray.lxyz.y;
		END;
		color:=texcube.side[ray.face].pixelmip_zero(lx,ly);
		dot:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
		dr:=color.red*color.alpha*dot;
		dg:=color.green*color.alpha*dot;
		db:=color.blue*color.alpha*dot;
		(*
		0<alpha<1/2 is interpreted as alpha on (0,1)
		1/2<alpha<1 is mirror+texture mixed
		*)
		IF color.alpha<0.99 THEN
			IF color.alpha>0.5 THEN
				ai:=(2*color.alpha)/2;
				ainv:=(1-ai)/2;
				ai:=ai/2;
				raycolor:=ray.clr;
				mirror(ray,0);
				raycolor.r := raycolor.r + dr*raycolor.ra;
				raycolor.g := raycolor.g + dg*raycolor.ga;
				raycolor.b := raycolor.b + db*raycolor.ba;
				ray.clr.r := (ray.clr.r*ai + raycolor.r*ainv);
				ray.clr.g := (ray.clr.g*ai + raycolor.g*ainv) ;
				ray.clr.b := (ray.clr.b*ai + raycolor.b*ainv);
			ELSE
				dot:=ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
(*				dot2:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
				mix:=ray.length*ray.scale;
				IF mix>1 THEN mix:=1 END;
				dot:=mix*dot1+(1-mix)*dot2;
*)				dr:=color.red*color.alpha*dot;
				dg:=color.green*color.alpha*dot;
				db:=color.blue*color.alpha*dot;
				ray.clr.r := ray.clr.r + dr*ray.clr.ra;
				ray.clr.g := ray.clr.g + dg*ray.clr.ga;
				ray.clr.b := ray.clr.b + db*ray.clr.ba;
				ray.clr.ra:= ray.clr.ra-dr;
				ray.clr.ga:= ray.clr.ga-dg;
				ray.clr.ba:= ray.clr.ba-db;
				IF (ray.clr.ra<0.01) OR  (ray.clr.ga<0.01) OR (ray.clr.ba<0.01) THEN ray.terminate:=TRUE END
			END
		ELSE
			dot:= ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
			dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot;
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;
			ray.clr.alpha:=0;
			ray.terminate:=TRUE;
		END
	ELSE
	  (* camera is inside textured cube *)
	END
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
	n: PT;
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;
	ray.clr.ra:= ray.clr.ra + 0.2;
	ray.clr.ga := ray.clr.ga + 0.2;
	ray.clr.ba := ray.clr.ba + 0.2;
	ray.clr.alpha:= ray.clr.alpha - 0.2;
	IF ray.clr.alpha < 0.1 THEN ray.terminate:=TRUE END;
	reflect(ray.dxyz, ray.normal);
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
	Base.world.Shade(ray);
END mirror;

END AvaVox;


TYPE BilbVox* = OBJECT(Voxel);
VAR
	texture*: Texture;
	name*: Name;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texture,n);
	name:=n;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	cp: PT;
	x,y,z: REAL;
	color: Base.Color;
BEGIN
	IF ray.length>0 THEN
		(* find the closest point on the ray to the center of the hit cube *)
		cp:=Base.midPT(ray.lxyz,Base.Exit(ray));
		(* first approx: dirty: throw out the smallest of x y z *)
		x:= cp.x; y:= cp.y; z:=cp.z;
		IF z>y THEN y:=z ELSIF z>x THEN  x:=z END;
		color:=texture.pixel(x,-y);
		ray.clr.r := ray.clr.r + color.red*ray.clr.ra;
		ray.clr.g := ray.clr.g + color.green*ray.clr.ga;
		ray.clr.b := ray.clr.b + color.blue*ray.clr.ba;
		ray.clr.alpha:=0;
		ray.terminate:=TRUE;
	END
END Shade;

END BilbVox;

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
	x,y,xi,yj: LONGINT;
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
	lxyz,exit: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: LONGINT;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
	ai,ainv:REAL;
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
			END;
			ly:=1-ly;
		END;
 		mip:=ray.length*ray.scale;
(*		IF mip>20 THEN
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);
		ELSE
			color:=texcube.side[ray.face].pixel(lx,ly);
		END;
*)		color:=texcube.side[ray.face].pixel(lx,ly);
		IF color.alpha<0.99 THEN
			IF color.alpha>0.8 THEN
				mirror(ray,0);
			ELSE
(*				color.alpha:=color.alpha+0.2;
				dr:=color.red*color.alpha*ray.clr.ra;
				dg:=color.green*color.alpha*ray.clr.ga;
				db:=color.blue*color.alpha*ray.clr.b;
				ray.clr.r := ray.clr.r + dr;
				ray.clr.g := ray.clr.g + dg;
				ray.clr.b := ray.clr.b + db;
				ray.clr.ra:= (ray.clr.ra-dr)-0.1;
				ray.clr.ga:= (ray.clr.ga-dg)-0.1;
				ray.clr.ba:= (ray.clr.ba-db)-0.1;
				IF (ray.clr.ra<0.1) OR  (ray.clr.ga<0.1) OR (ray.clr.ba<0.1) THEN ray.terminate:=TRUE END;
*)			END
		ELSE
			dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
			dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot;
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;
			ray.terminate:=TRUE;
		END
	ELSE
	  (* camera is inside textured cube *)
	END;
END Shade;
(*
texture patch rays: diverge by dtheta, dphi: so distance between them at the hit is approximately
sin(dtheta)*ray.length -- screw it. this should be handled in the mspace shader!
X X X

X x X
X X X

*)

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
		ray.hitmirrorTF := TRUE;
		ray.hitxyz:=ray.xyz;
		ray.changed := TRUE;
		ray.mirrortf:=TRUE;
		ray.clr.ra:= ray.clr.ra + 0.1;
		ray.clr.ga := ray.clr.ga + 0.1;
		ray.clr.ba := ray.clr.ba + 0.1;	reflect(ray.dxyz, ray.normal);
		IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
		IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
		IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
		ray.xyz.x:=ray.xyz.x+ray.dxyz.x/10000000 ;
		ray.xyz.y:=ray.xyz.y+ray.dxyz.y/10000000 ;	
		ray.xyz.z:=ray.xyz.z+ray.dxyz.z/10000000 ;	
		Base.world.Shade(ray);
	END;
END mirror;

PROCEDURE play*();
BEGIN
(*	SPSMAudio.LoadWav("test.wav");
	SPSMAudio.Play

	ALUT.Play(Base.texsound);	*)
END play;

END TexVox;

TYPE TexCubeVox* = OBJECT(TexVox);

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=1;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j,face: INTEGER;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2: Base.Color;
	txcube: TexCube;
	rlf: REAL;
	lxyz: Base.PT;
	lsp: Base.SPT;
	dtl: LONGINT;
	mip,mipverse: REAL;
BEGIN
	IF tscale>0 THEN
		xx:=ray.lxyz.x;
		yy:=ray.lxyz.y;
		zz:=ray.lxyz.z;
		xx:=xx*tscale-ENTIER(xx*tscale);
		yy:=yy*tscale-ENTIER(yy*tscale);
		zz:=zz*tscale-ENTIER(zz*tscale);
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
		END
	ELSE
		CASE ray.face OF
			 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
			|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
			|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
			|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z;
			|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z;
			|5: lx := ray.lxyz.x; ly := ray.lxyz.y;
		END
	END;
	color:=texcube.side[ray.face].pixel(lx,ly);
	IF color.alpha<0.99 THEN
			IF color.alpha>0.75 THEN
				mirror(ray,dot)
			ELSE
				dr:=color.red*ray.clr.ra;
				dg:=color.green*ray.clr.ra;
				db:=color.blue*ray.clr.ra;
				ray.clr.r := ray.clr.r + dr*color.alpha;
				ray.clr.ra:=ray.clr.ra-(dr*color.alpha);
				ray.clr.g := ray.clr.g + dg*color.alpha;
				ray.clr.ga:=ray.clr.ga-(dg*color.alpha);
				ray.clr.b := ray.clr.b + db*color.alpha;
				ray.clr.ba:=ray.clr.ba-(db*color.alpha);
			(*	Base.ExitF(ray,lxyz,face);			 (* trace to the back side of the cube *)
				CASE face OF
					 0: lx := lxyz.y; ly := 1-lxyz.z;
					|1: lx := lxyz.x; ly := 1-lxyz.z;
					|2: lx := lxyz.x; ly := lxyz.y;
					|3: lx := lxyz.y; ly := 1-lxyz.z;
					|4: lx := lxyz.x; ly := 1-lxyz.z;
					|5: lx := lxyz.x; ly := lxyz.y;
				END;
				color2:=texcube.side[ray.face].pixel(lx,ly);
				IF color2.alpha<0.99 THEN
					IF color2.alpha>0.75 THEN
						mirror(ray,dot)
					ELSE
						dr:=color2.red*ray.clr.ra;
						dg:=color2.green*ray.clr.ra;
						db:=color2.blue*ray.clr.ra;
						ray.clr.r := ray.clr.r + dr*color.alpha;
						ray.clr.ra:=ray.clr.ra-(dr*color.alpha)-0.1;
						ray.clr.g := ray.clr.g + dg*color.alpha;
						ray.clr.ga:=ray.clr.ga-(dg*color.alpha)-0.1;
						ray.clr.b := ray.clr.b + db*color.alpha;
						ray.clr.ba:=ray.clr.ba-(db*color.alpha)-0.1;
					END;
				ELSE
					dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z)
					dr:=color2.red*dot*ray.clr.ra;
					dg:=color2.green*dot*ray.clr.ra;
					db:=color2.blue*dot*ray.clr.ra;
				END	*)
			END
	ELSE
		dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
		dr:=color.red*dot*ray.clr.ra;
		dg:=color.green*dot*ray.clr.ra;
		db:=color.blue*dot*ray.clr.ra;
		ray.clr.r := ray.clr.r + dr;
		ray.clr.g := ray.clr.g + dg;
		ray.clr.b := ray.clr.b + db;
		ray.terminate:=TRUE;
	END
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
	n: PT;
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;
	ray.clr.ra:= ray.clr.ra + 0.1;
	ray.clr.ga := ray.clr.ga + 0.1;
	ray.clr.ba := ray.clr.ba + 0.1;
	ray.clr.alpha:= ray.clr.alpha - 0.1;
	IF ray.clr.alpha < 0.1 THEN ray.terminate:=TRUE END;
	n.x:=(ray.normal.x*mix+ray.normal.x*(1-mix));
	n.y:=(ray.normal.y*mix+ray.normal.y*(1-mix));
	n.z:=(ray.normal.z*mix+ray.normal.z*(1-mix));
	reflect(ray.dxyz, n);
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
END mirror;

END TexCubeVox;

(*
TYPE FilmVox=OBJECT(Voxel);
VAR
	e: Files.Enumerator;
	name: ARRAY 256 OF CHAR;
	flags: SET;
	time,date,size: LONGINT;
	go:BOOLEAN;

PROCEDURE  & new(n: Name);
BEGIN
     NEW(e);
     e.Open("ngs/*.png",{});
     register;
END new;

PROCEDURE tick;
	BEGIN
(*	Out.Char("Z"); *)
	IF e.HasMoreEntries() THEN
		IF e.GetEntry(name,flags,time,date,size) THEN
			NEW(texcube,name,FALSE)
		END;
	ELSE
		Out.Char("Y");
		NEW(e);
     	e.Open("ngs/*.png",{});
	END;
END tick;

END FilmVox;

TYPE FloopVox* = OBJECT(Voxel);
VAR
	fl: FilmLoop.floop;
	tscale*: REAL;

PROCEDURE&init*(fname: Name; fnumber: LONGINT);
BEGIN
	NEW(fl,fname,fnumber);
	fl.register;
	tscale:=243;
	lock;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lx1,ly1, lz1,lx2,ly2,xx,yy,zz,xxx,yyy,zzz,dtl,tq :REAL;
	i,j: INTEGER;
	bpdx,bpdy: REAL;
	dot:REAL;
	xov,yov,zov:REAL;
	color, color1, color2: Base.Color;
BEGIN
	xx:=ray.xyz.x;
	yy:=ray.xyz.y;
	zz:=ray.xyz.z;
	xx:=xx*tscale-ENTIER(xx*tscale);
	yy:=yy*tscale-ENTIER(yy*tscale);
	zz:=zz*tscale-ENTIER(zz*tscale);
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
				|4: lx:=lx+lx1;
				|5: ly:=ly+lx1;
			END
		ELSE
			(* xy pyramid *)
			lx:=xx; ly:=yy;
			lz1:=tscale*ray.lxyz.z/ray.scale;
			CASE ray.face OF
				 0: lx:=lx+lz1;
				|1:  ly:=ly+lz1;
				|2:
				|3: lx:=lx+lz1;
				|4: ly:=ly+lz1;
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
				|3: lx:= lx+ly1;
				|4:
				|5:ly:=ly+ly1;
			END

		ELSE
			(* xy pyramid *)
			lx:=xx; ly:=yy;
			lz1:=tscale*ray.lxyz.z/ray.scale;
			CASE ray.face OF
				 0: lx:=lx+lz1;
				|1:  ly:=ly+lz1;
				|2:
				|3: lx:=lx+lz1;
				|4: ly:=ly+lz1;
				|5:
			END
		END
	END;
	fl.shade(lx,ly,color);
	IF ((color.green>0.20) & ((color.red+color.blue)<0.2)) THEN
		mirror(ray)
	ELSE
		dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
		dr:=color.red*dot*ray.clr.ra;
		dg:=color.green*dot*ray.clr.ga;
		db:=color.blue*dot*ray.clr.ba;
		ray.clr.r := ray.clr.r + dr;
		ray.clr.g := ray.clr.g+dg;
		ray.clr.b := ray.clr.b + db;
	END;
	ray.terminate:=TRUE;
END Shade;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE mirror(VAR ray: Ray);
VAR
	n: PT;
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;
	ray.clr.ra:= ray.clr.ra + 0.2;
	ray.clr.ga := ray.clr.ga + 0.2;
	ray.clr.ba := ray.clr.ba + 0.2;
	ray.clr.alpha:= ray.clr.alpha - 0.2;
	IF ray.clr.alpha < 0.1 THEN ray.terminate:=TRUE END;
	reflect(ray.dxyz, ray.normal);
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
END mirror;

END FloopVox;

*)

TYPE NoiseVox* = OBJECT(Voxel);
VAR
	seed:LONGINT;
	octaves:INTEGER;
	aa,bb,cc,persistence: REAL;
	tscale: REAL;

PROCEDURE&init*(s:LONGINT;o:INTEGER; a,b,c,p:REAL);
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
	c:=Noise.noise3dperlinabs(x,y,z, 6985, 4,3.5);
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

END TexVox.
