MODULE Retina;
IMPORT  XNXL, Base, Objects, Kernel, Out:=KernelLog,GL:=OpenGL, GLC := OpenGLConst, XNXLNoise, 
Math, XNXLMath, Raster, Graphics:=WMGraphics;

TYPE 
	Ray=Base.Ray;
	PT=Base.PT;
CONST
	TS=50;
	DTS=100;
	TW=Base.W DIV TS;
	TH=Base.H DIV TS;
	DTW=Base.W DIV DTS;
	DTH=Base.H DIV DTS;	
	
TYPE Tile=OBJECT
VAR
	GO: BOOLEAN;
	x,y: LONGINT;		(*position of tile in Base.rays*)
	rays: Base.RAYS;
	red,green,blue,work: ARRAY TS,TS OF REAL;
	copy: Raster.Mode;
	
PROCEDURE & init(a,b: LONGINT);
BEGIN
	x:=a; y:=b;
	rays:=Base.rays;
	Raster.InitMode(copy,Raster.srcCopy);
END init;

PROCEDURE go;
BEGIN{EXCLUSIVE}
     GO:=TRUE;
END go;

PROCEDURE tessa(cam: Base.Camera; imx, imy: INTEGER);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
BEGIN
	theta:=cam.theta; 
	phi:=cam.phi;
	
	ray:=Base.blankray;
	angletoray(ray,theta+cam.dtheta/5,phi+cam.dphi/5);
	Base.world.Shade(ray); 
	IF ~ray.terminate THEN
		ray.b:= ray.b + ray.ba;
		ray.r:= ray.r + 0.5*ray.ra;
		ray.g:= ray.g + 0.5*ray.ga;
	END;
	Raster.SetRGB(pixel,ENTIER(ray.r*255),ENTIER(ray.g*255),ENTIER(ray.b*255));
	Raster.Put(image,imx,imy,pixel,copy);
	Raster.Put(image,imx+1,imy,pixel,copy);	  
	Raster.Put(image,imx,imy+1,pixel,copy);
	Raster.Put(image,imx+1,imy+1,pixel,copy);	
	Raster.Put(image,imx+2,imy,pixel,copy);

	ray:=Base.blankray;
	angletoray(ray,theta+cam.dtheta/5,phi+3*cam.dphi/5);
	Base.world.Shade(ray); 
	IF ~ray.terminate THEN
		ray.b:= ray.b + ray.ba;
		ray.r:= ray.r + 0.5*ray.ra;
		ray.g:= ray.g + 0.5*ray.ga;
	END;
	Raster.SetRGB(pixel,ENTIER(ray.r*255),ENTIER(ray.g*255),ENTIER(ray.b*255));
	Raster.Put(image,imx,imy+3,pixel,copy);
	Raster.Put(image,imx+1,imy+3,pixel,copy);	  
	Raster.Put(image,imx,imy+4,pixel,copy);
	Raster.Put(image,imx+1,imy+4,pixel,copy);	
	Raster.Put(image,imx,imy+2,pixel,copy);	

END tessa;

PROCEDURE tessad(cam: Base.Camera; imx, imy: INTEGER);
VAR
	i,j: LONGINT;
	theta,phi,dtheta,dphi: REAL;
	ray: Base.Ray;
	pixel: Raster.Pixel;
BEGIN
	theta:=cam.theta; 
	phi:=cam.phi;
	dtheta:=cam.dtheta/5;
	dphi:=cam.dphi/5;
	FOR i := 0 TO 4 DO
		FOR j :=  0 TO 4 DO	
			ray:=Base.blankray;
			angletoray(ray,theta,phi);
			Base.world.Shade(ray); 
			IF ~ray.terminate THEN
				ray.b:= ray.b + ray.ba;
				ray.r:= ray.r + 0.5*ray.ra;
				ray.g:= ray.g + 0.5*ray.ga;
			END;
			Raster.SetRGB(pixel,ENTIER(ray.r*255),ENTIER(ray.g*255),ENTIER(ray.b*255));
			Raster.Put(image,imx+i,imy+j,pixel,copy);
			theta:=theta+dtheta;
			phi:=phi+dphi;
		END
	END;	
END tessad;

PROCEDURE ztrace;
VAR
	i,j,ii,jj,reversej: LONGINT;
	noise, theta,phi,dtheta,dphi,dtl: REAL;
	xyz,lxyz,oxyz: PT;
	pixel: Raster.Pixel;
BEGIN
	(*from dxyz at corners calculate interpolation steps*)
	(*then *)
END ztrace;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)
	 }REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
	(*	trace;	*)	
		BEGIN{EXCLUSIVE}
			GO:=FALSE;
			incTD;
		END;		
		UNTIL ~Base.worldalive;
END Tile;

TYPE antimalice=OBJECT
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

VAR
	tile: ARRAY TW,TH OF Tile;
	a,b: LONGINT;
	tilesdone:INTEGER;
	EDGE*: REAL;
	AFTER*: INTEGER;
	FAST*:INTEGER;
	lsense,ls2:REAL;
	FGUAARD,FRAMEBOORT:BOOLEAN;
	SACCADE*,SACCADE1*,DTLRAYS*:BOOLEAN;
	rward*,UP*:PT;
	cameratheta*,cameraphi*:REAL;
	aperture*: Base.Aperture;
	image*: Raster.Image;
		
PROCEDURE angletoray(VAR ray: Base.Ray; theta,phi: REAL);
VAR d: REAL;
BEGIN
	ray:=Base.blankray;
	ray.dxyz.x := Math.cos(theta) * Math.cos(phi);
	ray.dxyz.y := Math.sin(theta) * Math.cos(phi);
	ray.dxyz.z := Math.sin(phi);
	d := Math.sqrt(ray.dxyz.x*ray.dxyz.x + ray.dxyz.y* ray.dxyz.y+ray.dxyz.z*ray.dxyz.z);  (* Norma! Liza! Ray! Front and center, oh dark thirty!*)
	ray.dxyz.x := ray.dxyz.x/d;
	ray.dxyz.y := ray.dxyz.y/d;
	ray.dxyz.z := ray.dxyz.z/d;
END angletoray; 
			
PROCEDURE colorquad(r,g,b,x,y,s: REAL);
BEGIN{EXCLUSIVE}
(*	GL.Color3f(r,g,b);
	GL.Vertex2f(x,y);
	GL.Vertex2f(x,y+s);
	GL.Vertex2f(x+s,y+s);
	GL.Vertex2f(x+s,y); *)
END colorquad;

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

PROCEDURE go*;
VAR
	i,j,t: INTEGER;
BEGIN
	zeroTD;
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			(*divide aperture by TW and TH *)
			(*generate corner ray.dxyz etc for each tile*)
		END
	END;	
	BEGIN{EXCLUSIVE} 
		gotiles;
		AWAIT((tilesdone=TW*TH) OR FRAMEBOORT)
	END
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
	image := Graphics.LoadImage("Lenna.png", FALSE);
	FOR a:= 0 TO TW-1  DO
		FOR b:= 0 TO TH-1 DO
			NEW(tile[a,b],a*TS,b*TS);
		END
	END;
	EDGE:=0.001;
	AFTER:=2;
 	FAST:=3;
 	lsense:=0.2;
 	aperture.width:=3;
 	aperture.height:=3;
 	Out.String("loaded...");
END Retina.
