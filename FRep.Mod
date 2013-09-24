MODULE FRep;

IMPORT Math, XNXLMath, Base, XNXLVoxel, Raster, Graphics:=WMGraphics, Noise:=XNXLNoise;
	
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

TYPE sphere*= OBJECT(FR)
CONST
	N=30;
	NMO=N-1
VAR 
	radius*, rsquared*: REAL;
	center*:PT;
	cxf*:BOOLEAN;
	NC: ARRAY N,N OF NCube;

PROCEDURE &init*(c:PT; r: REAL);
VAR
	i,j: INTEGER;
	theta, phi: REAL;
	normal: PT;
	color: Color;
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
	mir:=0.8;
	FOR i:=0 TO NMO DO 
		theta := twopi*i/N;
		FOR j:=0 TO NMO DO
			phi := twopi*j/N;
			normal.x := Math.cos(theta)*Math.sin(phi);
			normal.y := Math.sin(theta)*Math.sin(phi);
			normal.z := Math.cos(theta);
		END
	END				
END init;

PROCEDURE color*(p:PT):Color;
VAR
	c: Color;
BEGIN
(*	c.red:=0.5;
	c.green:=p.y;	
	c.blue:=p.z;	
	IF ~cxf THEN RETURN cxolor ELSE  RETURN c END; 
	*)
	cxolor.alpha:=1/2;
	RETURN cxolor
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
	RETURN((norml.x*norml.x+norml.y*norml.y+norml.z*norml.z)-rsquared)
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

END noise;

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

TYPE cube*= OBJECT(FR)
VAR
	white:XNXLVoxel.DiffuseVox;

PROCEDURE getcolor*(p:PT):Color;
VAR
	c:Color;
BEGIN
	c.red:=p.x; c.blue:=p.y; c.red:=p.z;
	RETURN c
END getcolor;

BEGIN
	NEW(white);
	white.setcolor(1,1,1,0,0);
	vox:=white;
END cube;

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


END FRep.