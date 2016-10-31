MODULE Retina;
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=5;        
	TS=3*32;  (*  TS MUST BE 5 (or 9, 16, etc, depending on tessa version) MULTIPLIED BY 2**T *)
	TW=6;
	TH=4;
	W*=TS*TW;
	H*=TS*TH;

TYPE Camera= RECORD			(* solid angle *)
	dtheta, dphi, theta, phi,rphi:REAL;
	imx,imy,size: INTEGER;
END;

TYPE Tile=OBJECT
VAR
	GO: BOOLEAN;
	cam: Camera;

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE;
END go;

PROCEDURE tessad3(cam: Camera);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
BEGIN
	theta:=cam.theta;
	dtheta:=cam.dtheta/3;
	dphi:=cam.dphi/3;
	FOR i:= 0 TO 2 DO
		phi:=cam.phi;
		FOR j :=  0 TO 2 DO 
			ray:=Base.blankray;
			ray.dtl:=10;
			angletoray(ray,theta,phi);
			Base.world.Shade(ray);
			IF ~ray.terminate THEN
				ray.b:= ray.b + ray.ba;
				ray.r:= ray.r + ray.ra/2;
				ray.g:= ray.g + ray.ga/2;	
			END;	
			Base.clamp3(ray.r,ray.g,ray.b);
			Raster.SetRGB(pixel,ENTIER(ray.r*255),ENTIER(ray.g*255),ENTIER(ray.b*255)); 
(*			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy); *)
			Raster.Fill(image,cam.imx*2+i*2,cam.imy*2+j*2,cam.imx*2+i*2+2,cam.imy*2+j*2+2,pixel,copy);
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
BEGIN
	ray:=Base.blankray;
	ray.dtl:=3;
	angletoray(ray,cam.theta+cam.dtheta/2,cam.phi+cam.dphi/2);
	Base.world.Shade(ray);
	IF ~ray.terminate THEN
			ray.b:= ray.b + ray.ba;
			ray.r:= ray.r + ray.ra/2;
			ray.g:= ray.g + ray.ga/2;	
	END;
	Base.clamp3(ray.r,ray.g,ray.b);
	Raster.SetRGB(pixel,ENTIER(ray.r*255),ENTIER(ray.g*255),ENTIER(ray.b*255)); 
	Raster.Fill(image,cam.imx*2,cam.imy*2,cam.imx*2+6,cam.imy*2+6,pixel,copy);
END tessa;

PROCEDURE ztrace(cam: Camera; level: INTEGER);
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
			IF (~saccade)&((x*x+y*y)<FV) THEN	
				tessad3(b); 
			ELSE
				tessa(b); 			
			END;			
			x:=c.imx - W/2;
			y:=c.imy-H/2;		
			IF (~saccade)&((x*x+y*y)<FV) THEN		
				tessad3(c); 
			ELSE
				tessa(c); 
			END;
			x:=d.imx - W/2;
			y:=d.imy-H/2;		
			IF (~saccade)&((x*x+y*y)<FV) THEN	
				tessad3(d); 
			ELSE
				tessa(d); 
			END; 
	ELSE
		l:=level-1;
		ztrace(a,l);
		ztrace(b,l);
		ztrace(c,l);
		ztrace(d,l) 	
	END;
END ztrace;

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

BEGIN{ACTIVE, PRIORITY(Objects.Normal)
	 }REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		ztrace(cam,T);	
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
			incTD;
		END;
		UNTIL ~Base.worldalive;
END Tile;

(*TYPE antimalice=OBJECT
VAR
	timer: Kernel.Timer;
PROCEDURE frameguaard;
VAR
	i:LONGINT;
BEGIN
	i:=0;
	BEGIN{EXCLUSIVE} FRAMEBOORT:=FALSE END;
	timer.Sleep(200);
	BEGIN{EXCLUSIVE} FRAMEBOORT:=TRUE END
END frameguaard;

BEGIN{ACTIVE, PRIORITY(Objects.High)}
	NEW(timer);
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(FGUAARD);
		END;
		frameguaard;
		BEGIN{EXCLUSIVE}
			FGUAARD:=FALSE;
		END;
	UNTIL ~Base.worldalive;
END antimalice;
*)
VAR
	tile: ARRAY TW,TH OF Tile;
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
	image*: Raster.Image;
	rtheta,rphi: REAL; (* camera pitch,roll. global variables because they are the same for all rays in a frame *)
	fward*, dward*, rward*,camrward*: PT;  
	foveaparameter:INTEGER;
	FV: REAL;
	copy: Raster.Mode;

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
VAR d: REAL;
BEGIN
	ray:=Base.blankray;
	ray.dxyz.x:= Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y:= Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d;	
	SPSMMath.orrot(ray.dxyz, Base.dward, rtheta);  
	SPSMMath.orrot(ray.dxyz, rward, rphi);  
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.lxyz:=Base.cameraPT;
	ray.xyz:=Base.cameraPT;
	ray.oxyz:=Base.cameraPT;
	ray.dtl:=Base.DTL;
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

PROCEDURE lessdetail*;
BEGIN
	IF foveaparameter<50 THEN foveaparameter:=foveaparameter+1  END;
	FV:=W*W/foveaparameter;
END lessdetail;

PROCEDURE moredetail*;
BEGIN
	foveaparameter:=ABS(foveaparameter-1);
	FV:=W*W/foveaparameter	;
END moredetail;

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

PROCEDURE stitchtiles;
BEGIN

END stitchtiles;

PROCEDURE go*(theta,phi,apw,aph: REAL);
VAR
	i,j: INTEGER;
	ctheta,cphi,dtheta,dphi: REAL;
	pixel: Raster.Pixel;
BEGIN
	zeroTD;
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
	angletoray(Base.sniperay,0,0);	
	BEGIN{EXCLUSIVE}
		gotiles;
		AWAIT((tilesdone=TW*TH) OR FRAMEBOORT)
	END;
	Raster.SetRGB(pixel,255,255,255);
	Raster.Put(image,W+2,H+2,pixel,copy);	
	Raster.Put(image,W-2,H+2,pixel,copy);	
	Raster.Put(image,W-2,H-2,pixel,copy);	
	Raster.Put(image,W+2,H-2,pixel,copy);
	Raster.SetRGB(pixel,0,0,0);
	Raster.Put(image,W+1,H+1,pixel,copy);	
	Raster.Put(image,W-1,H+1,pixel,copy);	
	Raster.Put(image,W-1,H-1,pixel,copy);	
	Raster.Put(image,W+1,H-1,pixel,copy);			
	Base.tick
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
 	lsense:=0.2;
 	aperture.width:=1;
 	aperture.height:=1;
 	foveaparameter:=23;
 	Out.String("loaded...");
END Retina.
