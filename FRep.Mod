MODULE FRep;

IMPORT Math, Random, SPSMMath, Base, Raster, Graphics:=WMGraphics, Noise;
	
CONST
	twopi = 2*Math.pi;
TYPE 
	PT=Base.PT;
	Color=Base.Color;
	Voxel=Base.Voxel;
	Name = Base.Name;
	FR=Base.FR;
	NCube=Base.NCube; 

TYPE rprism= OBJECT(FR)

PROCEDURE&init*(c1,c2:PT);
BEGIN
	IF c1.x<c2.x THEN bbc1.x:=c1.x; bbc2.x:=c2.x ELSE bbc1.x:=c2.x; bbc2.x:=c1.x END;
	IF c1.y<c2.y THEN bbc1.y:=c1.y; bbc2.y:=c2.y ELSE bbc1.y:=c2.y; bbc2.y:=c1.y END;
	IF c1.z<c2.z THEN bbc1.z:=c1.z; bbc2.z:=c2.z ELSE bbc1.z:=c2.z; bbc2.z:=c1.z END;	
END init;

PROCEDURE in*(p:PT):BOOLEAN;
VAR
	a,b,c: BOOLEAN;
BEGIN
	a:= ((bbc1.x<p.x)&(p.x<bbc2.x))OR((bbc1.x>p.x)&(p.x>bbc2.x)) ;
	b:= ((bbc1.y<p.y)&(p.y<bbc2.y))OR((bbc1.y>p.y)&(p.y>bbc2.y)) ;
	c:= ((bbc1.x<p.z)&(p.z<bbc2.z))OR((bbc1.z>p.z)&(p.z>bbc2.z)) ;
	RETURN(a&b&c);
END in;
		
END rprism;

TYPE randpoints*= OBJECT(FR)
VAR 
	radius*, rsquared*: REAL;
	center*:PT;
	cxf*:BOOLEAN;
	rand*:Random.Sequence;
		
PROCEDURE &init*;

BEGIN
	NEW(rand);
END init;

PROCEDURE color*(p:PT):Color;
VAR
	c: Color;
BEGIN
	c.red:=cxolor.red+(rand.Uniform()*0.06);
	c.green:=cxolor.green+(rand.Uniform()*0.06);
	c.blue:=cxolor.blue+(rand.Uniform()*0.06);
	Base.clamp3(c.red,c.green,c.blue);
	RETURN c
END color;

PROCEDURE in*(p:PT):BOOLEAN;
BEGIN
	RETURN TRUE
END in;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	IF rand.Uniform()<0.3 THEN 
		RETURN(0.001)
	ELSE
		RETURN(0.5)
	END
END d2s;
	
END randpoints;


TYPE sphere*= OBJECT(FR)
VAR 
	radius*, rsquared*: REAL;
	center*:PT;
	cxf*:BOOLEAN;
	rand*:Random.Sequence;
		
PROCEDURE &init*(c:PT; r: REAL);

BEGIN
	NEW(rand);
	radius:=ABS(r);
	rsquared:=r*r;
	r:=r*1.00001; (* don't want the sphere to quite touch the box *)
	bbc1.x:=c.x-r;
	bbc1.y:=c.y-r;
	bbc1.z:=c.z-r;	
	bbc2.x:=c.x+r;
	bbc2.y:=c.y+r;
	bbc2.z:=c.z+r;	
	center:=c;	
	mir:=0.0;
END init;

PROCEDURE color*(p:PT):Color;
VAR
	c: Color;
BEGIN
	c.red:=cxolor.red+(rand.Uniform()*0.06);
	c.green:=cxolor.green+(rand.Uniform()*0.06);
	c.blue:=cxolor.blue+(rand.Uniform()*0.06);
	Base.clamp3(c.red,c.green,c.blue);
	RETURN c
END color;

PROCEDURE reset*(c:PT; r: REAL);
BEGIN
	radius:=ABS(r);
	rsquared:=r*r;
	r:=r*1.00001; (* don't want the sphere to quite touch the box *)
	bbc1.x:=c.x-r;
	bbc1.y:=c.y-r;
	bbc1.z:=c.z-r;	
	bbc2.x:=c.x+r;
	bbc2.y:=c.y+r;
	bbc2.z:=c.z+r;	
	center:=c;	
END reset;

PROCEDURE setcenter*(x,y,z: REAL);
BEGIN
	center.x:=x; center.y:=y; center.z:=z
END setcenter;

PROCEDURE in*(p:PT):BOOLEAN;
BEGIN
	RETURN Base.distance(center,p)<radius
END in;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	norml.x:= center.x-p.x; 
	norml.y:= center.y-p.y; 	
	norml.z:= center.z-p.z; 
	RETURN(rsquared-(norml.x*norml.x+norml.y*norml.y+norml.z*norml.z))
END d2s;

PROCEDURE normal*(p:PT):PT;
BEGIN
	Base.normalizePT(norml);	(* norml is often calculated in d2s but not normalized there *)
	RETURN norml					(* this is the normal for the most recent point handed to d2s *)
END normal;

PROCEDURE normaltf*(p:PT):BOOLEAN;
BEGIN	
	RETURN TRUE			
END normaltf;

PROCEDURE mirror*(p:PT):REAL;
BEGIN
	RETURN mir
END mirror;
	
END sphere;

TYPE twosphere*= OBJECT(sphere);
VAR
	vox2: Voxel;
	cxolor2: Color;
	
PROCEDURE setcolor2*(r,g,b,a: REAL);  
BEGIN
	cxolor2.red:=r; cxolor2.green:=g; cxolor2.blue:=b; cxolor2.alpha:=a;
END setcolor2;

PROCEDURE setvoxel2*(CONST a:Voxel);
BEGIN
	vox2:=a;
END setvoxel2;

PROCEDURE color*(p:PT):Color;
VAR
	c: Color;
BEGIN
	IF rand.Uniform()>1/2 THEN
		c.red:=cxolor.red+(rand.Uniform()*0.06);
		c.green:=cxolor.green+(rand.Uniform()*0.06);
		c.blue:=cxolor.blue+(rand.Uniform()*0.06);
		Base.clamp3(c.red,c.green,c.blue);
	ELSE
		c.red:=cxolor2.red+(rand.Uniform()*0.06);
		c.green:=cxolor2.green+(rand.Uniform()*0.06);
		c.blue:=cxolor2.blue+(rand.Uniform()*0.06);
		Base.clamp3(c.red,c.green,c.blue);
	END;
	RETURN c
END color;


PROCEDURE voxel*(p:PT):Voxel;
BEGIN
	IF rand.Uniform() > 1/2 THEN 
		RETURN vox 
	ELSE 
		RETURN vox2
	END
END voxel;

END twosphere;


TYPE benice*= OBJECT(FR);
VAR 
	D,A,B,C: REAL;
	P,Q,R:INTEGER;
	center*:PT;
	rand*:Random.Sequence;
	
PROCEDURE pow(x: REAL; p: INTEGER): REAL;
VAR
	i: INTEGER;
	r: REAL;
BEGIN
	r:=1;
	FOR i:=1 TO p DO
		r:=r*x
	END;
	RETURN r
END pow;
	
PROCEDURE &init*(cen:PT; d,a,b,c: REAL; p,q,r: INTEGER);
BEGIN
	NEW(rand);
	center:=cen;	
	D:=d; A:=a; B:=b; C:=c; P:=p; Q:=q;
END init;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	x,y,z: REAL;
BEGIN
	x:= ABS(center.x - p.x)-A;
	y:= ABS(center.y - p.y)-B;
	z:= ABS(center.z - p.z)-C;
	IF x>0 THEN x:=pow(x,P) ELSE x:=0 END;
	IF y>0 THEN y:=pow(y,Q) ELSE y:=0 END;
	IF z>0 THEN z:=pow(z,R) ELSE z:=0 END;		
	RETURN(D-(x+y+z))	
END d2s;

END benice;

TYPE tilednoise*= OBJECT(FR)
VAR
	seed*:LONGINT;
	octaves*:INTEGER;
	persistence*:LONGREAL;
	a*,b*,c*: REAL;
	va*: ARRAY 6 OF Voxel;
	
PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	RETURN(Noise.noise3dperlin(a*p.x,b*p.y,c*p.z, seed,octaves,persistence)/500 - 1/1000)	
END d2s;

PROCEDURE voxel*(p:PT):Voxel;
BEGIN
	RETURN va[(ENTIER(117*Math.sqrt((1/2-p.x)*(1/2-p.x)*(1/2-p.y)*(1/2-p.y)*(1/2-p.z)*(1/2-p.z)))MOD 223)MOD 6] 
END voxel;

END tilednoise;

TYPE noise*= OBJECT(FR)
VAR
	seed*:LONGINT;
	octaves*:INTEGER;
	persistence*:LONGREAL;
	a*,b*,c*: REAL;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR 
	n,d:REAL;
BEGIN
	RETURN(Noise.noise3dperlin(a*p.x,b*p.y,c*p.z, seed,octaves,persistence)/1000 - 1/2000)	
END d2s;

PROCEDURE color*(p:PT):Color;
BEGIN	
	RETURN Base.randColor()		
END color;

PROCEDURE normal*(p:PT):PT;
BEGIN
	RETURN Base.randPT	()
END normal;
END noise;

TYPE twonoise*= OBJECT(FR)
VAR
	noise1*, noise2*: noise;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR 
	n,d:REAL;
BEGIN
	RETURN((noise1.d2s(p)+noise2.d2s(p))/2)	
END d2s;

END twonoise;

TYPE ellipsoid*= OBJECT(FR)
VAR 
	radius: REAL;
	center0,center1,norml0,norml1:PT;	
	
PROCEDURE &init*(a,b:PT; m: REAL);

BEGIN
	center0:=a;	
	center1:=b;
	radius:=m;		
END init;

PROCEDURE setcenter*(x,y,z,a,b,c: REAL);
BEGIN
	center0.x:=x; center0.y:=y; center0.z:=z;
	center1.x:=x; center1.y:=y; center1.z:=z
END setcenter;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	d,e:REAL;
BEGIN
	norml0.x:= center0.x-p.x; 
	norml0.y:= center0.y-p.y; 	
	norml0.z:= center0.z-p.z; 
	norml1.x:= center1.x-p.x; 
	norml1.y:= center1.y-p.y; 	
	norml1.z:= center1.z-p.z; 
	d:= Math.sqrt(norml0.x*norml0.x+norml0.y*norml0.y+norml0.z*norml0.z);
	e:= Math.sqrt(norml1.x*norml1.x+norml1.y*norml1.y+norml1.z*norml1.z);
	norml.x:=(norml0.x+norml1.x)/2;
	norml.y:=(norml0.y+norml1.y)/2;
	norml.y:=(norml0.z+norml1.z)/2;
	RETURN((d+e)-radius)
END d2s;	
END ellipsoid;

TYPE cyl*= OBJECT(FR)
VAR 
	rsquared,lensq: REAL;
	p1,p2,d:PT;
	
PROCEDURE &init*(a,b:PT; r: REAL);

BEGIN
	rsquared:=r*r;
	p1:=a; p2:=b;
	d.x:=p2.x-p1.x; 
	d.y:=p2.y-p1.y;
	d.z:=p2.z-p1.z;
	lensq:=d.x*d.x+d.y*d.y+d.z*d.z;
	Base.setPT(norml,1,0,0)
END init;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	dot,dsq,a,b,c: REAL;
	pd:PT;
BEGIN
	pd.x:=p.x-p1.x; 
	pd.y:=p.y-p1.y;
	pd.z:=p.z-p1.z;
	dot:=pd.x*d.x+pd.y*d.y+pd.z*d.z;
	dsq:=(pd.x*pd.x+pd.y*pd.y+pd.z*pd.z)-dot*dot/lensq;
	RETURN ABS(dsq-rsquared);	
END d2s;

END cyl;

TYPE texturedcone*= OBJECT(FR)	
VAR 
	rsquared,r2squared,lensq: REAL;
	p1,p2,d:PT;
	img: Raster.Image;
	fmt: Raster.Format;
	copy : Raster.Mode;
	W,H, bpr,adr: LONGINT;	

PROCEDURE &init*(a,b:PT; r,r2: REAL; n: Name);
BEGIN
	rsquared:=r*r;
	r2squared:=r2*r2;
	p1:=a; p2:=b;
	d.x:=p2.x-p1.x; 
	d.y:=p2.y-p1.y;
	d.z:=p2.z-p1.z;
	lensq:=d.x*d.x+d.y*d.y+d.z*d.z;
	Base.setPT(norml,1,0,0);
	Raster.InitMode(copy, Raster.srcCopy);
	img :=Graphics.LoadImage(n, TRUE);
	IF img#NIL THEN W := img.width-1; H:= img.height-1; END;
END init;

PROCEDURE getcolor*(p:PT):Color;
VAR
	a:Color;
	r,b,g: REAL;
	tx,ty: LONGINT;
	pixel:Raster.Pixel;
BEGIN
	IF img#NIL THEN
		tx:=ENTIER(p.z*W); 
		ty:=ENTIER(p.y*H); 	
		Raster.Get(img,tx,ty,pixel,copy);
		r := ORD(pixel[2])/255; g := ORD(pixel[1])/255; b := ORD(pixel[0])/255;	
		a.red:=r;
		a.green:=g;
		a.blue:=b;
	ELSE
		a:=cxolor
	END;
	RETURN a
END getcolor;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	dot,dsq,a,b,c: REAL;
	pd:PT;
BEGIN
	pd.x:=p.x-p1.x; 
	pd.y:=p.y-p1.y;
	pd.z:=p.z-p1.z;
	dot:=pd.x*d.x+pd.y*d.y+pd.z*d.z;
	dsq:=(pd.x*pd.x+pd.y*pd.y+pd.z*pd.z)-dot*dot/lensq;
	RETURN(dsq-rsquared);	
END d2s;
		
END texturedcone;

TYPE plane*= OBJECT(FR)
VAR 
	d: REAL;
	p,cp:PT;
		
PROCEDURE &init*(a,b:PT); 
BEGIN
	p:=a;   norml:=b;
	norml.x:= norml.x + (Base.rand.Uniform()-1/2)/20;
	norml.y:= norml.y + (Base.rand.Uniform()-1/2)/20;
	norml.z:= norml.z + (Base.rand.Uniform()-1/2)/20;
	Base.normalizePT(norml);
	d:= -norml.x*p.x - norml.y*p.y - norml.z*p.z;
END init;

PROCEDURE getcolor*(p:PT):Color;
VAR
	a:Color;
BEGIN
	a.red:=(p.x+cxolor.red)/2;
	a.green:=(p.y*cxolor.green)/2;
	a.blue:=(p.z+cxolor.blue)/2;	
	RETURN a
END getcolor;

PROCEDURE mirror*(p:PT):REAL;
BEGIN
	IF FALSE THEN
		RETURN(1/2)
	ELSE
		RETURN(0)
	END 
END mirror;

PROCEDURE d2s*(m:PT):REAL;  (* distance to surface *)
BEGIN
	RETURN (m.x*norml.x+m.y*norml.y+m.z*norml.z+d);
END d2s;

PROCEDURE normal*(p:PT):PT;
BEGIN
	RETURN norml					
END normal;
		
END plane;


TYPE halfspace*= OBJECT(FR)
VAR 
	d: REAL;
	p,cp:PT;
		
PROCEDURE &init*(a,b:PT); 
BEGIN
	p:=a;   norml:=b;
	Base.normalizePT(norml);
	d:= -norml.x*p.x - norml.y*p.y - norml.z*p.z;
END init;

PROCEDURE getcolor*(p:PT):Color;
VAR
	a:Color;
BEGIN
	a.red:=(p.x+cxolor.red)/2;
	a.green:=(p.y*cxolor.green)/2;
	a.blue:=(p.z+cxolor.blue)/2;	
	RETURN a
END getcolor;

PROCEDURE mirror*(p:PT):REAL;
BEGIN
	IF FALSE THEN
		RETURN(1/2)
	ELSE
		RETURN(0)
	END 
END mirror;

PROCEDURE d2s*(m:PT):REAL;  (* distance to surface *)
VAR
	distance: REAL;
BEGIN
	
	distance:=m.x*norml.x+m.y*norml.y+m.z*norml.z+d;
	IF distance<0 THEN distance:=0 END;
	RETURN distance;
END d2s;

PROCEDURE normal*(p:PT):PT;
BEGIN
	RETURN norml					
END normal;
		
END halfspace;

TYPE landscape*= OBJECT(FR)
VAR 
	d: REAL;
	pt*,cp:PT;
	heightimage, colorimage: Raster.Image;
	fmt: Raster.Format;
	copy : Raster.Mode;
	heightW, heightH, colorW, colorH, bpr,adr: LONGINT;
	rarevox*:Voxel;
	z: REAL;
		
PROCEDURE &init*(a,b:PT; heightmap, colormap: Name); 
BEGIN
	pt:=a;   norml:=b;
	Base.normalizePT(norml);
	d:= -norml.x*pt.x - norml.y*pt.y - norml.z*pt.z;
	Raster.InitMode(copy, Raster.srcCopy);
	heightimage :=Graphics.LoadImage(heightmap, TRUE);
	colorimage :=Graphics.LoadImage(colormap, TRUE);
	IF heightimage#NIL THEN heightW := heightimage.width-1; heightH:= heightimage.height-1; END;
	IF colorimage#NIL THEN heightW := heightimage.width-1; heightH:= heightimage.height-1; END;
	z:=1
END init;

PROCEDURE getcolor*(p:PT):Color;
VAR
	a:Color;
	r,b,g: REAL;
	tx,ty: LONGINT;
	pixel:Raster.Pixel;
BEGIN
	IF  FALSE (* colorimage#NIL *) THEN
		tx:=ENTIER(p.z*colorW); 
		ty:=ENTIER(p.y*colorH); 	
		Raster.Get(colorimage,tx,ty,pixel,copy);
		r := ORD(pixel[2])/255; g := ORD(pixel[1])/255; b := ORD(pixel[0])/255;	
		a.red:=r;
		a.green:=g;
		a.blue:=b;
	ELSE
		a:=cxolor
	END;
	RETURN a
END getcolor;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	r,b,g: REAL;
	tx,ty: LONGINT;
	pixel:Raster.Pixel;
BEGIN
	IF  heightimage#NIL THEN
		tx:=ENTIER(p.x*heightW); 
		ty:=ENTIER(p.y*heightH); 	
		Raster.Get(heightimage,tx,ty,pixel,copy);
		r := ORD(pixel[2])/255; g := ORD(pixel[1])/255; b := ORD(pixel[0])/255;	
		z:=(1-p.z)-(r+g+b)/30;
		cp.z:=z;
		norml.x:=0; norml.y:=0;norml.z:=-1;
	END;
	RETURN z
END d2s;

PROCEDURE closestPT*(p:PT):PT;  (* returns the closest point found in last d2s *)
BEGIN
	cp.x := p.x;
	cp.y := p.y;
	RETURN cp
END closestPT;

PROCEDURE normal*(p:PT):PT;
BEGIN
	RETURN norml					
END normal;

PROCEDURE voxel*(p:PT):Voxel;
BEGIN
	IF Base.rand.Uniform()<0.01 THEN 
		RETURN rarevox
	ELSE	
		RETURN vox
	END
END voxel;
		
END landscape;


TYPE hexgrid*= OBJECT(FR)  (*accidentally created from cyl *)
VAR 
	radius, rsquared,lensq: REAL;
	p1,p2,d:PT;
	
PROCEDURE &init*(a,b:PT; r: REAL);

BEGIN
	rsquared:=r*r;
	p1:=a; p2:=b;
	d.x:=p2.x-p1.x; 
	d.y:=p2.y-p1.y;
	d.z:=p2.z-p1.z;
	lensq:=d.x*d.x+d.y*d.y+d.z*d.z;
END init;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
VAR
	dot,dsq,a,b,c: REAL;
	pd:PT;
BEGIN
	pd.x:=p.x-p1.x; 
	pd.y:=p.y-p1.y;
	pd.z:=p.z-p1.z;
	dot:=pd.x*p.x+pd.y*p.y+pd.z*p.z;
	Base.normalizePT(pd);
	norml:=pd;
	dsq:=(pd.x*pd.x+pd.y*pd.y+pd.z*pd.z)-dot*dot/lensq;
	RETURN(dsq-rsquared);	
END d2s;
		
END hexgrid;

TYPE bifr*=OBJECT(FR)
VAR
	fr1,fr2: FR;	

PROCEDURE&init*(a,b: FR);
BEGIN
	IF a# NIL THEN fr1:=a ELSE NEW(fr1) END;
	IF b# NIL THEN fr2:=b ELSE NEW(fr2) END
END init;

PROCEDURE color(p:PT):Color;
VAR
	a,b,c: Color;
BEGIN
	RETURN Base.avgcolor(fr1.color(p),fr2.color(p));
END color;

PROCEDURE d2s*(p:PT):REAL;  (* distance to surface *)
BEGIN
	RETURN (fr1.d2s(p)+fr2.d2s(p))/2
END d2s;

PROCEDURE voxel(p:PT):Voxel;
BEGIN
	RETURN fr1.vox
END voxel;

PROCEDURE normal*(p:PT):PT;
BEGIN
	Base.normalizePT(fr1.norml);		(* norml is often calculated in d2s but not normalized there *)
	RETURN fr1.norml					(* this is the normal for the most recent point handed to d2s *)
END normal;
		
END bifr;


END FRep.