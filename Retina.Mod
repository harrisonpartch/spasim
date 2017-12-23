MODULE Retina;
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics, WMRasterScale,  Rect := WMRectangles;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=5;        
	TS=3*32;  (*  TS MUST BE 3 MULTIPLIED BY 2**T *)
	TW=16;
	TH=9;
	W*=TS*TW;
	H*=TS*TH;
	CX=W DIV 2;
	CY=H DIV 2;
	GAMMA=255; 

TYPE Camera= RECORD			(* solid angle *)
	dtheta, dphi, theta, phi,rphi:REAL;
	imx,imy,size: INTEGER;
END;

TYPE Tile2=OBJECT
VAR
	GO: BOOLEAN;
	cam: Camera;

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE
END go;

PROCEDURE tessa;
VAR i,j: LONGINT;
BEGIN
	FOR i:=0 TO TW-1 DO
		FOR j:=0 TO TH-1 DO
			
		END
	END
END tessa;

BEGIN{ACTIVE, PRIORITY(Objects.Low)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		tessa; 
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
		incTD; 
		END;
		UNTIL ~Base.worldalive; 
END Tile2;

TYPE Tile=OBJECT
VAR
	GO: BOOLEAN;
	cam: Camera;

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE
END go;

PROCEDURE tessad3(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	dtheta:=cam.dtheta/2;
	dphi:=cam.dphi/2;
	theta:=cam.theta;
	FOR i:= 0 TO 2 DO
		phi:=cam.phi;
		FOR j := 0 TO 2 DO 
			ray.clr.ra := 1;
			ray.clr.ga := 1;
			ray.clr.ba := 1;
			ray.clr.alpha:=1;
			ray.scale := 1; 
			ray.tscale:=1;
			ray.dtl:=D2;	
			angletoray(ray,theta,phi);
			Base.world.Shade(ray);	
			IF ray.terminate THEN
				r:=ray.clr.r;
				g:=ray.clr.g;
				b:=ray.clr.b; 
			ELSE
				b:= ray.clr.b + ray.clr.ba;
				r:= ray.clr.r + ray.clr.ra/3;
				g:= ray.clr.g + ray.clr.ga/3 
			END;
			Base.clamp3(r,g,b);
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
			phi:=phi+dphi;
		END;
		theta:=theta+dtheta;
	END;
END tessad3;

PROCEDURE tessa(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(ray,cam.theta+cam.dtheta/2, cam.phi+cam.dphi/2);
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=D2;	
	Base.world.Shade(ray);
	IF ray.terminate THEN
		r:=ray.clr.r;
		g:=ray.clr.g;
		b:=ray.clr.b; 
	ELSE
		b:= ray.clr.b + ray.clr.ba;
		r:= ray.clr.r + ray.clr.ra/3;
		g:= ray.clr.g + ray.clr.ga/3
	END;
	Base.clamp3(r,g,b);	
	Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
	FOR i := 0 TO 2 DO
		FOR j := 0 TO 2 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END		
END tessa;

PROCEDURE ztraceu(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			tessa(a);
			tessa(b);
			tessa(c);
			tessa(d);
	ELSE
		l:=level-1;
		ztraceu(a,l);
		ztraceu(b,l);
		ztraceu(c,l);
		ztraceu(d,l) 	
	END;
END ztraceu;

PROCEDURE ztracef(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			x:=a.imx - W/2;
			y:=a.imy-H/2;		
			IF (~saccade)&((x*x+y*y)<FV) THEN	
				tessad3(a); 
			ELSE
				tessa(a); 
			END;
			x:=b.imx - W/2;
			y:=b.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN	
				tessad3(b); 
			ELSE
				tessa(b); 			
			END;			
			x:=c.imx - W/2;
			y:=c.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN		
				tessad3(c); 
			ELSE
				tessa(c); 
			END;
			x:=d.imx - W/2;
			y:=d.imy-H/2;		
			IF  (~saccade)&((x*x+y*y)<FV) THEN	
				tessad3(d); 
			ELSE
				tessa(d); 
			END; 
	ELSE
		l:=level-1;
		ztracef(a,l);
		ztracef(b,l);
		ztracef(c,l);
		ztracef(d,l) 	
	END;
END ztracef;

PROCEDURE ztraced(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			tessad3(a); 
			tessad3(b); 
			tessad3(c); 
			tessad3(d); 
	ELSE
		l:=level-1;
		ztraced(a,l);
		ztraced(b,l);
		ztraced(c,l);
		ztraced(d,l) 	
	END;
END ztraced;

BEGIN{ACTIVE, PRIORITY(Objects.Low)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		CASE TESSA OF
			  0: ztracef(cam,T); 
			| 1: ztraced(cam,T) 
			| 2: ztraceu(cam,T) 
		ELSE
		END;
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
		incTD; 
		END;
		UNTIL ~Base.worldalive; 
END Tile;

VAR
	tile: ARRAY TW,TH OF Tile;
	TESSA: INTEGER;
	frameasteps*,framebsteps*:LONGINT;
	a,b: LONGINT;
	tilesdone:INTEGER;
	EDGE*: REAL;
	AFTER*: INTEGER;
	FAST*:INTEGER;
	lsense,ls2:REAL;
	FGUAARD,FRAMEBOORT:BOOLEAN;
	saccade*,SACCADE1*,DTLRAYS*:BOOLEAN;
	cameratheta*,cameraphi*:REAL;
	aperture*: Base.Aperture;
	image*,fimage*: Raster.Image;
	rtheta,rphi: REAL; (* camera pitch,roll. global variables because they are the same for all rays in a frame *)
	fward*, dward*, rward*,camrward*: PT;  
	foveaparameter:INTEGER;
	FV: REAL;
	copy: Raster.Mode;
	PATCH*:BOOLEAN;
	DETAIL,D2: REAL;
	
PROCEDURE Res*;
BEGIN
	INC(TESSA);
	TESSA:=TESSA MOD 3;
END Res;

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
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;
	
PROCEDURE angletoray(VAR ray: Base.Ray; theta,phi: REAL);
VAR 
	d: REAL;
BEGIN
	ray.dxyz.x:= Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y:= Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d;	
(*	ray.dtheta:=dtheta;
	ray.dphi:=dphi;
*)	ray.downxyz:=Base.dward;
	ray.rightxyz:=Base.rward;
	SPSMMath.orrot(ray.dxyz, Base.dward, rtheta);  
	SPSMMath.orrot(ray.dxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.downxyz, Base.rward, rphi);  
	SPSMMath.orrot(ray.rightxyz, Base.dward, rphi);  	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.lxyz:=Base.cameraPT;
	ray.xyz:= Base.cameraPT;
	ray.oxyz:= Base.cameraPT;
	ray.dtl:=Base.DTL*ray.dtl;
	ray.texdtl:=1;	
END angletoray;

PROCEDURE splitcam(cam: Camera; VAR a,b,c,d: Camera);
VAR
	dt,dp:REAL;
	dimx, dimy,s: INTEGER;
BEGIN
	dt:=cam.dtheta/2;
	dp:=cam.dphi/2;
	s:=cam.size DIV 2;

	a.dtheta:=dt;
	a.dphi:=dp;
	a.theta:=cam.theta;
	a.phi:=cam.phi+dp;
	a.imx:=cam.imx;
	a.imy:=cam.imy+s;
	a.size:=s;	

	b.dtheta:=dt;
	b.dphi:=dp;
	b.theta:=cam.theta+dt;
	b.phi:=cam.phi+dp;
	b.imx:=cam.imx+s;
	b.imy:=cam.imy+s;
	b.size:=s;		
	
	c.dtheta:=dt;
	c.dphi:=dp;
	c.theta:=cam.theta;
	c.phi:=cam.phi;
	c.imx:=cam.imx;
	c.imy:=cam.imy;
	c.size:=s;			
	
	d.dtheta:=dt;
	d.dphi:=dp;
	d.theta:=cam.theta+dt;
	d.phi:=cam.phi;
	d.imx:=cam.imx+s;
	d.imy:=cam.imy;
	d.size:=s;			
	
END splitcam;

PROCEDURE moredetail*;
BEGIN
	foveaparameter:=ABS(foveaparameter-3);
	FV:=W*W/foveaparameter;
END moredetail;

PROCEDURE lessdetail*;
BEGIN
	foveaparameter:=(foveaparameter+3);
	IF foveaparameter>250 THEN foveaparameter:=250 END;
	FV:=W*W/foveaparameter	;
END lessdetail;

PROCEDURE decdetail*;
BEGIN
	DETAIL:=DETAIL*2/3;
	D2:=DETAIL*3/2;
END decdetail;

PROCEDURE incdetail*;
BEGIN
	DETAIL:=DETAIL*3/2;
	D2:=DETAIL*3/2;
END incdetail;

PROCEDURE incTD;
BEGIN{EXCLUSIVE}
	INC(tilesdone);
END incTD;

PROCEDURE zeroTD;
BEGIN{EXCLUSIVE}
	tilesdone:=0;
END zeroTD;

PROCEDURE gotiles;
VAR
	i,j: INTEGER;
BEGIN
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			tile[i,j].go;
		END
	END
END gotiles;

PROCEDURE go*(theta,phi,apw,aph: REAL);
VAR
	i,j: INTEGER;
	ctheta,cphi,dtheta,dphi: REAL;
	pixel: Raster.Pixel;
	sr: Ray;
	r14,r11: Rect.Rectangle;
BEGIN
	zeroTD;
	frameasteps:=0;
	framebsteps:=0;
	dtheta:=apw/TW;
	dphi:=aph/TH;
	ctheta:=-apw/2;	
	FOR i:= 0 TO TW-1  DO	
		cphi:=-aph/2;
		FOR j:= 0 TO TH-1 DO
			tile[i,j].cam.theta:=ctheta;
			tile[i,j].cam.phi:=cphi;
			tile[i,j].cam.dtheta:=dtheta;
			tile[i,j].cam.dphi:=dphi;
			tile[i,j].cam.imx:=i*TS;
			tile[i,j].cam.imy:=j*TS;
			tile[i,j].cam.size:=TS;			
			cphi:=cphi+dphi;		
		END;
		ctheta:=ctheta+dtheta;
	END;
	dward:= Base.dward;
	fward:= Base.fward;
	rward:=Base.rward;
	rtheta:=phi;
	rphi:=theta;	
	SPSMMath.orrot(fward, Base.dward,rtheta);   
	SPSMMath.orrot(rward, Base.dward,rtheta);   		
	SPSMMath.orrot(fward, Base.rward,rphi);  	
	SPSMMath.orrot(dward, Base.rward,rphi);  
	sr:=Base.blankray;
	sr.clr.ra := 1;
	sr.clr.ga := 1;
	sr.clr.ba := 1;
	sr.clr.alpha:=1;
	sr.scale := 1; 
	angletoray(sr,0,0);	
	Base.sniperay:=sr;
	BEGIN{EXCLUSIVE}
		gotiles;
		AWAIT((tilesdone=TW*TH) OR FRAMEBOORT)
	END;
	Raster.SetRGB(pixel,255,255,255);
	Raster.Put(image,CX+2,CY+2,pixel,copy);	
	Raster.Put(image,CX-2,CY+2,pixel,copy);	
	Raster.Put(image,CX-2,CY-2,pixel,copy);	
	Raster.Put(image,CX+2,CY-2,pixel,copy);
	Raster.SetRGB(pixel,0,0,0);
	Raster.Put(image,CX+1,CY+1,pixel,copy);	
	Raster.Put(image,CX-1,CY+1,pixel,copy);	
	Raster.Put(image,CX-1,CY-1,pixel,copy);	
	Raster.Put(image,CX+1,CY-1,pixel,copy);	
END go;

PROCEDURE lsu*;
BEGIN
	EDGE:=0
END lsu;

PROCEDURE lsd*;
BEGIN
	EDGE:=0.01
END lsd;

BEGIN
	Out.String("Retina loading...");
	Raster.InitMode(copy,Raster.srcCopy);	
	image := Graphics.LoadImage("granite.jpg", FALSE);
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b]);
		END
	END;	
	EDGE:=0.001;
	AFTER:=2;
 	FAST:=3;
 	DETAIL:=100;
 	D2:=150;
 	lsense:=0.2;
 	aperture.width:=1;
 	aperture.height:=1;
 	foveaparameter:=50;
 	Out.String("loaded...");	
END Retina.
