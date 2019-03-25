MODULE Retina;
IMPORT  Base, Objects, Kernel, Out:=KernelLog, Noise,
Math, SPSMMath, Raster, Graphics:=WMGraphics, WMRasterScale,  Rect := WMRectangles;

TYPE
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	T=3;        
	TS=12*8;  (*  TS MUST BE {size of unit tile} MULTIPLIED BY 2**T *)
	TW=16;
	TH=9;
	W*=TS*TW;
	H*=TS*TH;
	CX=W DIV 2;
	CY=H DIV 2;
	GAMMA=250; 

TYPE Camera= RECORD			(* solid angle *)
	dtheta, dphi, theta, phi,rphi:REAL;
	imx,imy,size: INTEGER;
END;

TYPE Tile=OBJECT
VAR
	GO: BOOLEAN;
	cam: Camera;
	dtl: REAL;
	
PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE
END go;

PROCEDURE angletoray(VAR ray: Ray; theta,phi: REAL);
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
	ray.downxyz:=Base.dward;
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
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
	ray.dtl:=dtl;
	ray.texdtl:=1;	
END angletoray;

PROCEDURE interpray(CONST ra,rb: Ray; mix: REAL): Ray;
VAR
	r: Ray;
	mixi: REAL;
BEGIN
	r.lxyz:=Base.cameraPT;
	r.xyz:= Base.cameraPT;
	r.oxyz:= Base.cameraPT;	
	r.clr.ra := 1;
	r.clr.ga := 1;
	r.clr.ba := 1;
	r.clr.alpha:=1;
	r.scale := 1; 
	r.tscale:=1;
	r.dtl:=Base.DTL;
	r.texdtl:=1;	
	mixi:=1-mix;
	r.dxyz.x:= ra.dxyz.x*mixi + rb.dxyz.x*mix;
	r.dxyz.y:= ra.dxyz.y*mixi + rb.dxyz.y*mix;
	r.dxyz.z := ra.dxyz.z*mixi+ rb.dxyz.z*mix;	
	IF r.dxyz.x < 0 THEN r.di := FALSE  ELSE r.di := TRUE END; 
	IF r.dxyz.y < 0 THEN r.dj := FALSE  ELSE r.dj := TRUE END;
	IF r.dxyz.z < 0 THEN r.dk := FALSE  ELSE r.dk := TRUE END;		
	RETURN r;
END interpray;

PROCEDURE interpclr(CONST ra,rb: Base.Color): Base.Color;
VAR
	r: Base.Color;
BEGIN
	r.red:= (ra.red+rb.red)/2;
	r.green:= (ra.green+rb.green)/2;
	r.blue:= (ra.blue+rb.blue)/2;				
	RETURN r;
END interpclr;

PROCEDURE tessa12(cam:Camera);	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 12,12 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[0,11],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[11,0],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[11,11],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	FOR i := 1 TO 10 DO
		rays[i,0]:= interpray(rays[0,0],rays[11,0],i/11);
		rays[i,11]:= interpray(rays[0,11],rays[11,11],i/11);
	END;	
	FOR i := 0 TO 11 DO
		FOR j:= 1 TO 10 DO
			rays[i,j]:= interpray(rays[i,0],rays[i,11],j/11);
		END
	END;		
	FOR i:= 0 TO 11 DO
		FOR j := 0 TO 11 DO 
			rays[i,j].dtl:=Base.DTL;
			Base.world.Shade(rays[i,j]);	
			IF rays[i,j].terminate THEN
				r:=rays[i,j].clr.r;
				g:=rays[i,j].clr.g;
				b:=rays[i,j].clr.b; 
			ELSE
				r:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				g:= rays[i,j].clr.g + rays[i,j].clr.ga/2;
				b:= rays[i,j].clr.b + rays[i,j].clr.ba 
			END;
			Base.clamp3(r,g,b); 
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			Raster.Put(image,cam.imx+j,cam.imy+i,pixel,copy);
		END
	END;		
END tessa12;

PROCEDURE tessa6(cam:Camera);	
VAR
	i,j,k: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 12,12 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[0,11],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[11,0],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[11,11],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	FOR i := 1 TO 10 DO
		rays[i,0]:= interpray(rays[0,0],rays[11,0],i/12);
		rays[i,11]:= interpray(rays[0,11],rays[11,11],i/12);
	END;	
	FOR i := 0 TO 11 DO
		FOR j:= 1 TO 10 DO
			rays[i,j]:= interpray(rays[i,0],rays[i,11],j/12);
		END
	END;		
	FOR i:= 0 TO 11 BY 2 DO
		FOR j := 0 TO 11 BY 2 DO 
		  	rays[i,j].dtl:=Base.DTL;
			Base.world.Shade(rays[i,j]);	
			IF rays[i,j].terminate THEN
				r:=rays[i,j].clr.r;
				g:=rays[i,j].clr.g;
				b:=rays[i,j].clr.b; 
			ELSE
				r:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				g:= rays[i,j].clr.g + rays[i,j].clr.ga/2.5;
				b:= rays[i,j].clr.b + rays[i,j].clr.ba 
			END;
			Base.clamp3(r,g,b); 
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			Raster.Put(image,cam.imx+j,cam.imy+i,pixel,copy);
			Raster.Put(image,cam.imx+j+1,cam.imy+i,pixel,copy);
			Raster.Put(image,cam.imx+j,cam.imy+i+1,pixel,copy);
			Raster.Put(image,cam.imx+j+1,cam.imy+i+1,pixel,copy);
		END
	END;		
END tessa6;

PROCEDURE tessa4(cam:Camera);	
VAR
	i,j,ia,ja: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	rays: ARRAY 12,12 OF Base.Ray;
	pixel: Raster.Pixel;
	r,b,g: REAL;
BEGIN
	angletoray(rays[0,0],cam.theta,cam.phi);
	angletoray(rays[0,11],cam.theta+cam.dtheta,cam.phi);
	angletoray(rays[11,0],cam.theta,cam.phi+cam.dphi);
	angletoray(rays[11,11],cam.theta+cam.dtheta,cam.phi+cam.dphi);	
	FOR i := 0 TO 11 BY 3 DO 
		rays[i,0]:= interpray(rays[0,0],rays[11,0],i/11);
		rays[i,11]:= interpray(rays[0,11],rays[11,11],i/11);
	END;	
	FOR i := 0 TO 11 BY 3 DO
		FOR j:= 0 TO 11 BY 3 DO 
			rays[i,j]:= interpray(rays[i,0],rays[i,11],j/11);
		END
	END;		
	FOR i:= 0 TO 11 BY 3 DO
		FOR j := 0 TO 11 BY 3 DO 
			rays[i,j].dtl:=Base.DTL2;
			Base.world.Shade(rays[i,j]);	
			IF rays[i,j].terminate THEN
				r:=rays[i,j].clr.r;
				g:=rays[i,j].clr.g;
				b:=rays[i,j].clr.b; 
			ELSE
				r:= rays[i,j].clr.r + rays[i,j].clr.ra/3;
				g:= rays[i,j].clr.g + rays[i,j].clr.ga/3;
				b:= rays[i,j].clr.b + rays[i,j].clr.ba 
			END;
			Base.clamp3(r,g,b); 
			Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 
			FOR ia:=0 TO 2 DO
				FOR ja:=0 TO 2 DO
					Raster.Put(image,cam.imx+j+ja,cam.imy+i+ia,pixel,copy);
				END
			END
		END
	END;		
END tessa4;

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
	ray.dtl:=Base.DTL;	
	Base.world.Shade(ray);
	IF ray.terminate THEN
		r:=ray.clr.r;
		g:=ray.clr.g;
		b:=ray.clr.b; 
	ELSE
		r:= ray.clr.r + ray.clr.ra;
		g:= ray.clr.g + ray.clr.ga/3;
		b:= ray.clr.b + ray.clr.ba/3;
	END;
	Base.clamp3(r,g,b);
	Raster.SetRGB(pixel,ENTIER(r*GAMMA),ENTIER(g*GAMMA),ENTIER(b*GAMMA)); 	
	FOR i:=0 TO 11 DO 
		FOR j:= 0 TO 11 DO
			Raster.Put(image,cam.imx+i,cam.imy+j,pixel,copy);
		END
	END 
END tessa;

PROCEDURE atrace(cam: Camera);
VAR

BEGIN

END atrace;

PROCEDURE ztraceu(cam: Camera; level: INTEGER);
VAR
	a,b,c,d: Camera;
	l: INTEGER;
	x,y: REAL;
BEGIN
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			dtl:=Base.DTL/10;
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
	x,y,D: REAL;
	FVV:REAL;
BEGIN
	FVV:=10*FV*FV;
	splitcam(cam,a,b,c,d);
	IF level<2 THEN
			x:=a.imx-W/2;
			y:=a.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa12(a); 
			ELSE
				tessa4(a); 
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN
				tessa12(b); 
			ELSE 
				tessa4(b);
			END;
			x:=c.imx-W/2;
			y:=c.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa12(c); 
			ELSE
				tessa4(c)
			END;
 			x:=b.imx-W/2;
			y:=b.imy-H/2;		
			D:=(x*x+y*y);	
			IF D<FVV THEN	
				tessa12(d); 
			ELSE
				tessa4(d); 
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
			dtl:=Base.DTL;
			tessa12(a); 
			tessa12(b); 
			tessa12(c); 
			tessa12(d); 
	ELSE
		l:=level-1;
		ztraced(a,l);
		ztraced(b,l);
		ztraced(c,l);
		ztraced(d,l) 	
	END;
END ztraced;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)}
	REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		CASE TESSA OF
			  0: ztraceu(cam,T); 
			| 1: IF ~saccade THEN ztraced(cam,T) ELSE ztracef(cam,T) END;
			| 2: IF ~saccade THEN ztracef(cam,T) ELSE ztraceu(cam,T) END;
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
	DETAIL: REAL;
	
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
	ray.clr.ra := 1;
	ray.clr.ga := 1;
	ray.clr.ba := 1;
	ray.clr.alpha:=1;
	ray.scale := 1; 
	ray.tscale:=1;
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

PROCEDURE moredetail*;
BEGIN
	foveaparameter:=foveaparameter-1;
	IF foveaparameter<11 THEN foveaparameter:=11 END;
(*	Out.Int(foveaparameter,4); *)
	FV:=W/foveaparameter;
END moredetail;

PROCEDURE lessdetail*;
BEGIN
	foveaparameter:=(foveaparameter+1);
	IF foveaparameter>50 THEN foveaparameter:=50 END;
	FV:=W/foveaparameter;
END lessdetail;

PROCEDURE decdetail*;
BEGIN
	DETAIL:=DETAIL*2/3;
	Base.DTL:=Base.DTL*2/3;
	Base.DTL2:=Base.DTL2*2/3;	
END decdetail;

PROCEDURE incdetail*;
BEGIN
	DETAIL:=DETAIL*3/2;
	Base.DTL:=Base.DTL*3/2;
	Base.DTL2:=Base.DTL2*3/2;		
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
 	DETAIL:=2000;
 	lsense:=0.2;
 	aperture.width:=1;
 	aperture.height:=1;
 	foveaparameter:=13;
 	Out.String("loaded...");	
END Retina.
