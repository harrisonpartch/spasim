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

PROCEDURE trace;
VAR
	i,j,ii,jj,reversej: LONGINT;
	noise, theta,phi,dtheta,dphi,dtl: REAL;
	xyz,lxyz,oxyz: PT;
	pixel: Raster.Pixel;
BEGIN
(*	dtheta := aperture.width/Base.W;
	dphi := aperture.height/Base.H;
	theta := -aperture.width/2-x*dtheta;
	FOR i := 0 TO TS-1 DO
		phi:= -aperture.height/2+y*dphi;
		FOR reversej:=0 TO TS-1 DO	
			j:=reversej;
			angletoray(rays[x+i, y+j],theta,phi);
			XNXLMath.orrot(rays[x+i, y+j].dxyz, UP, cameraphi);  	
		   	XNXLMath.orrot(rays[x+i, y+j].dxyz, rward, cameratheta);  			  	  								  	  		
			IF rays[x+i, y+j].dxyz.x < 0 THEN rays[x+i, y+j].di := FALSE  ELSE rays[x+i, y+j].di := TRUE END; 
			IF rays[x+i, y+j].dxyz.y < 0 THEN rays[x+i, y+j].dj := FALSE  ELSE rays[x+i, y+j].dj := TRUE END;
			IF rays[x+i, y+j].dxyz.z < 0 THEN rays[x+i, y+j].dk := FALSE  ELSE rays[x+i, y+j].dk := TRUE END;		
			rays[x+i, y+j].lxyz := Base.cameraPT;
			rays[x+i, y+j].xyz := Base.cameraPT;
			rays[x+i, y+j].oxyz:=rays[x+i, y+j].xyz;
			rays[x+i, y+j].dtl:= Base.DTL; 
			phi := phi + dphi;
		END;	
		theta := theta +dtheta;
	END;	
*)	FOR ii := 0 TO TS-1 DO
		FOR jj :=  0 TO TS-1 DO	
			i:=x+ii;
			j:=y+jj;
			Base.world.Shade(rays[i,j]); 
			IF ~rays[i,j].terminate THEN
				(* noise:=0.2*XNXLNoise.noise3dperlin(rays[i,j].xyz.x,rays[i,j].xyz.y,rays[i,j].xyz.z,666,3,3.5);	*)
				noise := 1/2;
				rays[i,j].b:= rays[i,j].b + rays[i,j].ba;
				rays[i,j].r:= rays[i,j].r + noise*rays[i,j].ra;
				rays[i,j].g:= rays[i,j].g + noise*rays[i,j].ga;
			END;
			Raster.SetRGB(pixel,ENTIER(rays[i,j].r*255),ENTIER(rays[i,j].g*255),ENTIER(rays[i,j].b*255));
			Raster.Put(image,i,j,pixel,copy);
		END
	END;	
END trace;

BEGIN{ACTIVE, PRIORITY(Objects.Normal)
	 }REPEAT
		BEGIN{EXCLUSIVE}
			AWAIT(GO);
		END;
		trace;		
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
	BEGIN{EXCLUSIVE} 
		gotiles;
		AWAIT((tilesdone=TW*TH) OR FRAMEBOORT)
	END
END go;

PROCEDURE gosinglecore*;
VAR
	i,j: INTEGER;
BEGIN
	FOR i:= 0 TO TW-1  DO
		FOR j:= 0 TO TH-1 DO
			tile[i,j].trace
		END
	END
END gosinglecore;

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
