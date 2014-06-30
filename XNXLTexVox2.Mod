MODULE XNXLTexVox;
IMPORT Base:=XNXLBase, XNXLAudio, XNXLMath, Noise:=XNXLNoise, XNXLFilmLoop, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog; 

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
	TexCube= Base.TexCube;

TYPE TexVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	pstscale*: INTEGER;
	texscale*:LONGINT;
	name: Name;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	pstscale:=100;
	texscale:=1000;
END init;

PROCEDURE deepcopy*():Voxel;
VAR
	v: TexVox;
BEGIN
	NEW(v,"fake");
	v.texcube:=texcube;
	v.tscale:=tscale;	
	RETURN v
END deepcopy;

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
	xx:=ray.xyz.x;
	yy:=ray.xyz.y;
	zz:=ray.xyz.z;
	xx:=xx*pstscale-ENTIER(xx*pstscale);
	yy:=yy*pstscale-ENTIER(yy*pstscale);
	zz:=zz*pstscale-ENTIER(zz*pstscale);
	lx:=xx+zz/3 - ENTIER(xx+zz/3);
	ly:=yy+zz/3 - ENTIER(yy+zz/3);
	color:=texcube.side[ray.face].pixel(lx,ly);
	lx:=lx*10-ENTIER(lx*10);
	ly:=ly*10-ENTIER(ly*10);	
	color1:=texcube.side[ray.face].pixel(lx,ly);	
	mip:=ray.length*100;
	mip:=1/2;
	IF mip>1 THEN mip:=1 END; 
	mipverse:=1-mip;
	color.red:=(color1.red*mipverse+mip*color.red);
	color.green:=(color1.green*mipverse+mip*color.green);
	color.blue:=(color1.blue*mipverse+mip*color.blue);

	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z); 
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ra;
	db:=color.blue*dot*ray.ra;	
	IF color.alpha<0.9 THEN
		IF color.alpha>0.7 THEN
			ray.ra:=ray.ra-0.1;
			ray.ga:=ray.ga-0.1;
			ray.ba:=ray.ba-0.1;
			mirror(ray)
		ELSE
			ray.r := ray.r + dr*color.alpha;
			ray.ra:=ray.ra-dr*color.alpha-0.4;	
			ray.g := ray.g + dg*color.alpha;
			ray.ga:=ray.ga-dg*color.alpha-0.4;
			ray.b := ray.b + db*color.alpha;
			ray.ba:=ray.ba-db*color.alpha-0.4;
		END			
	ELSE
		ray.r := ray.r + dr;
		ray.g := ray.g + dg;
		ray.b := ray.b + db;	
		ray.terminate:=TRUE
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

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.hitdxyz:=ray.dxyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;	
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;

PROCEDURE play*();
BEGIN
(*	XNXLAudio.LoadWav("test.wav");
	XNXLAudio.Play **)
END play;

END TexVox;

TYPE TexCubeVox* = OBJECT(TexVox);

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,TRUE);
	name:=n;
	pstscale:=128;
	texscale:=128;
END init;

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

END TexCubeVox;

TYPE FloopVox* = OBJECT(Voxel);
VAR
	fl: XNXLFilmLoop.floop;
	pstscale: REAL;

PROCEDURE&init*(fname: Name);
BEGIN
	NEW(fl,fname);
	pstscale:=81;
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
	xx:=xx*pstscale-ENTIER(xx*pstscale);
	yy:=yy*pstscale-ENTIER(yy*pstscale);
	zz:=zz*pstscale-ENTIER(zz*pstscale);
	xxx:=ABS(1/2-xx);
	yyy:=ABS(1/2-yy);
	zzz:=ABS(1/2-zz);	
	IF xxx>yyy THEN
		IF xxx>zzz THEN
			(* yz pyramid *)  				(*  faces come in pairs: (0,3),(2,5),(1,4) *)
			lx:=yy; ly:=zz;
			lx1:=pstscale*ray.lxyz.x/ray.scale;
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
			lz1:=pstscale*ray.lxyz.z/ray.scale;
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
			ly1:=pstscale*ray.lxyz.y/ray.scale;	
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
			lz1:=pstscale*ray.lxyz.z/ray.scale;
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
	lx1:=lx*3-ENTIER(lx*3);
	ly1:=ly*3-ENTIER(ly*3);
	lx2:=lx*79-ENTIER(lx*79);
	ly2:=ly*79-ENTIER(ly*79);
	fl.shade(lx1,ly1,color1);
	fl.shade(lx1,ly1,color2);
	tq:=ray.length*ray.scale/3;
	Base.clamp(tq);	
	color.red:=(color1.red*tq+color2.red*(1-tq));
	color.green:=(color1.green*tq+color2.green*(1-tq));
	color.blue:=(color1.blue*tq+color2.blue*(1-tq));
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z); 	
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ga;
	db:=color.blue*dot*ray.ba;	
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.terminate:=TRUE;
END Shade;

END FloopVox;

TYPE NoiseVox* = OBJECT(Voxel);
VAR
	seed:LONGINT;
	octaves:INTEGER;
	aa,bb,cc,persistence: REAL;
	pstscale: REAL;
	
PROCEDURE&init*(s:LONGINT;o:INTEGER; a,b,c,p:REAL);
BEGIN
	seed:=s; octaves:=SHORT(o); persistence:=p;
	aa:=a; bb:=b; cc:=c;
	pstscale:=243;
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
	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z)*0.7+0.4; 
	dr:=color.red*dot*ray.ra;
	dg:=color.green*dot*ray.ga;
	db:=color.blue*dot*ray.ba;
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;
	ray.terminate:=TRUE
END Shade;

END NoiseVox;

PROCEDURE nshade(CONST nc: NCube; VAR ray: Ray);
VAR
	mix,dot,dot1,dot2: REAL;	
BEGIN
	dot1 := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z); 
	dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	dot1:=dot1*0.7+0.3;
	dot2:=dot2*0.7+0.3;
	IF ray.length*ray.scale<75 THEN mix:=1-(ray.length*ray.scale/75) ELSE mix:=0 END;
	dot:=mix*dot2+(1-mix)*dot1;
	ray.r := ray.r + nc.color.red * ray.ra*dot;
	ray.g := ray.g + nc.color.green * ray.ga*dot;
	ray.b := ray.b + nc.color.blue * ray.ba*dot; 		
	ray.terminate:=TRUE
END nshade;



END XNXLTexVox.
