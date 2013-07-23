MODULE GLPolyStipple; (** AUTHOR "fnecati"; PURPOSE ""; *)
 (* uses glPolyStipple, from OpenGL redbook pdf *)
IMPORT
	WMRectangles, WMGraphics, Strings, Kernel, S := SYSTEM, KernelLog,
	WM := WMWindowManager,  WMMessages, WMDialogs,
	GL := OpenGL, GLC := OpenGLConst, GLContext;

CONST 
	waittime=10;

TYPE Stipples = ARRAY [*] OF CHAR;
	
TYPE
	KillerMsg = OBJECT
	END KillerMsg;
	
	GLWindow* =  OBJECT(WM.BufferWindow)
	VAR
		 timer: Kernel.MilliTimer; 
		alive, animated: BOOLEAN;
		context : GLContext.Context;
		width, height: LONGINT;

		anglez: REAL;
		fly, halftone: Stipples;
				
		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			width := w; height := h;
			Init(w, h, TRUE); (* use alpha, for 32bpp img *)
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});

			SetTitle(Strings.NewString("GLPolyStipple Demo"));
						
			animated := FALSE;
			NEW(context);
			context.Init(w, h, "MyGLWindow", FALSE);
			anglez := 30.0;	
   			GLinit;	 			
			Reshape;			
			UpdateImage;

			alive := TRUE;
		END New; 

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);	     
		BEGIN

		CASE CHR(ucs) OF
			"a", "A": animated := ~ animated;   UpdateImage;
			| "-" : anglez := anglez - 5.0; UpdateImage;
			| "+" : anglez := anglez + 5.0; UpdateImage;
			| "p": PrintVals;
			| "s": SaveImage;
			| "q" : Close;
		ELSE	

		END;	
		END KeyEvent;

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Close*;
		BEGIN
			alive := FALSE;	
			Close^;			
			 context.Close;
			 context := NIL;				
		END Close;

		PROCEDURE UpdateImage;
		BEGIN {EXCLUSIVE}
			context.MakeCurrent();
				DrawStripple; 
			context.RenderInto(img); 
			context.DeActivate();
			
			Invalidate(WMRectangles.MakeRect(0, 0, width, height));		
		END UpdateImage;

		PROCEDURE SaveImage;
		VAR res: LONGINT;
			fname: ARRAY 128 OF CHAR;
		BEGIN
		
		fname:="glstippletest.bmp";
		IF WMDialogs.QueryString(" Save File name: ",fname)=WMDialogs.ResOk THEN
				WMGraphics.StoreImage(img, fname,res);
		END;
		
		END SaveImage;

		(* print  stipples bits, 32x32 bits *)
		PROCEDURE PrintVals;
		VAR i: LONGINT;
		BEGIN
			KernelLog.Ln; 
			KernelLog.String("--------- fly bits----------------");
			FOR i:=0 TO LEN(fly,0)-1 DO
				IF (i MOD 4) = 0 THEN KernelLog.Ln; END; 
				KernelLog.Bits(S.VAL(SET, fly[i]),0, 8);
			END;
			KernelLog.Ln; KernelLog.Ln; 
			
			KernelLog.String("--------- halftone bits------------"); 
			
			FOR i:=0 TO LEN(fly,0)-1 DO
				IF (i MOD 4) = 0 THEN KernelLog.Ln; END;
				KernelLog.Bits(S.VAL(SET, halftone[i]),0, 8);
			END;
			KernelLog.Ln; 
			KernelLog.String("----------------------------");	KernelLog.Ln; 			
		END PrintVals;
		
		PROCEDURE GLinit;
		BEGIN
			
			fly := [ 0X,  0X,  0X,  0X,  0X,  0X,  0X,  0X,
				03X,  80X,  01X,  0C0X,  06X,  0C0X,  03X,  60X, 
 				04X,  60X,  06X,  20X,  04X,  30X,  0CX,  20X, 
 				04X,  18X,  18X,  20X,  04X,  0CX,  30X,  20X,
 				04X,  06X,  60X,  20X,  44X,  03X,  0C0X,  22X, 
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X, 
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X,
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X, 
 				66X,  01X,  80X,  66X,  33X,  01X,  80X,  0CCX, 
 				19X,  81X,  81X,  98X,  0CX,  0C1X,  83X,  30X,
 				07X,  0E1X,  87X,  0E0X,  03X,  3FX,  0FCX,  0C0X, 
 				03X,  31X,  8CX,  0C0X,  03X,  33X,  0CCX,  0C0X, 
				06X,  64X,  26X,  60X,  0CX,  0CCX,  33X,  30X,
 				18X,  0CCX,  33X,  18X,  10X,  0C4X,  23X,  08X, 
 				10X,  63X,  0C6X,  08X,  10X,  30X,  0CX,  08X, 
 				10X,  18X,  18X,  08X,  10X,  00X,  00X,  08X];

			 halftone := [   0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
 				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X];
         
			context.MakeCurrent();		
			GL.glClearColor (0.0, 0.0, 0.0, 0.0); (*  clear the background and set it to black *)
   			GL.glShadeModel (GLC.GL_FLAT);  (* set the shading model to FLAT *)
			context.DeActivate;	 		
		END GLinit;

		PROCEDURE Reshape;
		BEGIN 
		context.MakeCurrent();
			GL.glViewport(0, 0, width, height);
			GL.glMatrixMode(GLC.GL_PROJECTION);
			GL.glLoadIdentity();
			GL.SetFCR();	
				 GL.glOrtho(-2.0, 2.0, -2.0 , 2.0, -2.0, 2.0);
			GL.DelFCR();
		context.DeActivate;
		END Reshape;

		(* create unit size square object *)
		PROCEDURE Square;
		BEGIN
		GL.SetFCR();
			GL.glBegin(GLC.GL_POLYGON);
			GL.glVertex3f(0.0,0.0 ,0.0);(* a *)
			GL.glVertex3f(1.0,0.0, 0.0);(* b *)
			GL.glVertex3f(1.0,1.0,0.0);(* c *)
			GL.glVertex3f(0.0,1.0,0.0);(* d *)
			GL.glEnd();
		GL.DelFCR();
		END Square;

		PROCEDURE DrawStripple; 
		VAR ianglez : REAL;
		BEGIN
			ianglez := -anglez;
			GL.glClear (GLC.GL_COLOR_BUFFER_BIT); 
			(* draw a solid unstippled red square *)
			GL.glColor3f (1.0, 0.0, 0.0);
			Square();
	

			(* draw a stippled with fly, green square *)
			GL.glEnable (GLC.GL_POLYGON_STIPPLE);	(* enable POLYGON_STIPPLE *)
			GL.glPolygonStipple (S.ADR(fly[0])); (* pass the fly stipple array *)
			GL.glPushMatrix();
				GL.glColor3f (0.0, 1.0, 0.0);
				GL.glTranslatef(0.5, 0.0, 0);
				Square();
			GL.glPopMatrix();	
	
			(* draw a stippled with halftone, blue square *)
			GL.glPolygonStipple (S.ADR(halftone[0]));
			GL.glPushMatrix();	
				GL.glColor3f (0.0, 0.0, 1.0);				
				GL.glTranslatef(1.0, 0.0, 0.0);
					GL.glPushMatrix();	
						 GL.SetFCR(); 
							GL.glRotatef(ianglez, 0.0, 0.0, 1.0);
						 GL.DelFCR();				
						
						Square();
					GL.glPopMatrix();		
			GL.glPopMatrix();	
	
			(* draw a stippled with fly, rotating cyan square *)
			GL.glColor3f (0.0, 1.0, 1.0);
			GL.glPolygonStipple (S.ADR(fly[0]));
			GL.glPushMatrix();	
				 GL.SetFCR(); 
					GL.glRotatef(anglez, 0.0, 0.0, 1.0);
				 GL.DelFCR();				
			    	GL.glRectd (-1.9, 1.9, -0.1, 0.1);			
			GL.glPopMatrix();
		
			GL.glDisable (GLC.GL_POLYGON_STIPPLE);    (* disable POLYGON STIPPLE *)
		END DrawStripple; 

BEGIN {ACTIVE} 
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
			 IF Kernel.Expired(timer) THEN  
			 	 UpdateImage();
 			 	 anglez := anglez + 5;
				Kernel.SetTimer(timer, waittime);
			END;	
	END;
END GLWindow;

PROCEDURE Open*;
VAR 
	window: GLWindow;
BEGIN
	NEW(window, 400, 400);
END Open;

BEGIN

END GLPolyStipple.

SystemTools.Free  GLPolyStipple  GLContext~ ~

GLPolyStipple.Open ~

