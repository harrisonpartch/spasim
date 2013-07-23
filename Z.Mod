MODULE MyWMGLWindow2; (** AUTHOR "fnecati"; PURPOSE ""; *)
 (* axolotl-felix GL implemetation in Oberon
 	http://code.google.com/p/axolotl-felix/
 	 *)
 	 
IMPORT
	Raster, WMRectangles, WMGraphics, Strings, Streams,
	WM := WMWindowManager,  WMMessages, KernelLog, WMDialogs,
	SYSTEM, GL := OpenGL, GLC := OpenGLConst, GLContext;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow* =  OBJECT(WM.BufferWindow)
	VAR
		 
		 dead: BOOLEAN;
		context : GLContext.Context;
		width, height: LONGINT;
		drawMode:LONGINT; (* fill, lines, points *)
		texture: ARRAY [3] OF GL.GLuint;  (* Storage For 3 Textures  *)
		LightAmbient, LightDiffuse, LightPosition: ARRAY [4] OF GL.GLfloat;
		xrot, yrot: REAL;  (* X, Y  rotation *)
		z : REAL; (* depth into the screen *)
		xspeed, yspeed: REAL;
		light, blend: BOOLEAN; (* Whether or not lighting is on,  Whether or not blending is on *)
		filter: LONGINT; (* type of filter *)			
				
		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			width := w; height := h;
			Init(w, h, TRUE); (* use alpha, for 32bpp img *)
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});

			SetTitle(Strings.NewString("MyGLWindow: "));
			InitContext;				
		  END New;
		  
		  PROCEDURE InitContext;
		  BEGIN
			NEW(context);
			context.Init(width, height, "MyGLWindow", FALSE);
			context.MakeCurrent();
				InitGL;
				LoadGLTextures;
			context.DeActivate();
			
		 	Reshape;
			UpdateImage;

		END InitContext;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);	     
		BEGIN

		CASE CHR(ucs) OF
			 "t" : Testspeed;
			| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
			| "f": filter := (filter +1) MOD 3; 	UpdateImage;	
			| "x" : xrot := xrot - 5.0; UpdateImage;
			| "X" : xrot := xrot+ 5.0; UpdateImage;
			| "y" : yrot := yrot - 5.0; UpdateImage;
			| "Y" : yrot := yrot+ 5.0; UpdateImage;
			
			| "l": light := ~ light; 
					context.MakeCurrent();
					IF light THEN GL.glEnable(GLC.GL_LIGHTING ); ELSE  GL.glDisable(GLC.GL_LIGHTING ); END;
					context.DeActivate();
					UpdateImage;
						
			| "b": blend := ~blend; 
					context.MakeCurrent();
					IF blend THEN
				          GL.glEnable( GLC.GL_BLEND );
						GL.glDisable( GLC.GL_DEPTH_TEST ); 
					ELSE
						GL.glDisable( GLC.GL_BLEND );
						GL.glEnable( GLC.GL_DEPTH_TEST );					
					END;
					context.DeActivate();
					UpdateImage;
			
			| "s": SaveImage;
			| "q" : Close;
		ELSE	

		END;	
		END KeyEvent;

		PROCEDURE WheelMove*(dz : LONGINT);
		BEGIN
			z := z + dz;
			UpdateImage;
		END WheelMove;		

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;


		PROCEDURE Close*;
		BEGIN
			Close^;	
			 context.Close;
			 context := NIL;					
		END Close;

		PROCEDURE UpdateImage;		
		BEGIN {EXCLUSIVE}
			context.MakeCurrent();
			Drawing;
			context.RenderInto(img); 
			context.DeActivate();
			
			Invalidate(WMRectangles.MakeRect(0, 0, width, height));
		END UpdateImage;

		PROCEDURE SaveImage;
		VAR res: LONGINT;
			fname: ARRAY 128 OF CHAR;
		BEGIN
		
		fname:="mywmgltest.bmp";
		IF WMDialogs.QueryString(" Save File name: ",fname)=WMDialogs.ResOk THEN
				WMGraphics.StoreImage(img, fname,res);
		END;
		
		END SaveImage;

(* function to load in bitmap as a GL texture *)
PROCEDURE LoadGLTextures( );
VAR teximg: Raster.Image;
	 res: GL.GLint;
BEGIN
  (* Create storage space for the texture *)
  teximg := WMGraphics.LoadImage("axolotl.bmp", FALSE);
  IF teximg = NIL THEN
    KernelLog.String("Can not load texture file"); KernelLog.Ln;  
  END;
  ASSERT(teximg # NIL, 333);
  
  (*? image needs to be flipped vertically *)
  
(* context.MakeCurrent(); *)

  (* Create The Texture *)
    GL.glGenTextures( 3, SYSTEM.ADR(texture[0]) );

  (* Typical Texture Generation Using Data From The Bitmap *)
  GL.glBindTexture( GLC.GL_TEXTURE_2D, texture[0] );

    (* Generate The Texture *)
  GL.glTexImage2D( GLC.GL_TEXTURE_2D, 0, 4, teximg.width, teximg.height, 0,GLC. GL_RGBA,
    GLC.GL_UNSIGNED_BYTE, teximg.adr );

  (* Linear Filtering *)
  GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
    GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST );

  GL.glBindTexture(GLC. GL_TEXTURE_2D, texture[1] );

  (* Linear Filtering *)
    GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR );
    GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR );

    (* Generate The Texture *)
  GL.glTexImage2D( GLC.GL_TEXTURE_2D, 0, 4, teximg.width,
    teximg.height, 0, GLC.GL_RGBA, GLC.GL_UNSIGNED_BYTE, teximg.adr );

  GL.glBindTexture( GLC.GL_TEXTURE_2D, texture[2] );

  (* Linear Filtering *)
    GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR_MIPMAP_NEAREST );
    GL.glTexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR_MIPMAP_NEAREST );

  (* Generate The MipMapped Texture  *)
 (* res := GL.gluBuild2DMipmaps(GLC.GL_TEXTURE_2D, 4, teximg.width, teximg.height,
    GLC.GL_RGBA, GLC.GL_UNSIGNED_BYTE, teximg.adr); *)

  (* Free up any memory we may have used *)
    teximg := NIL;
END LoadGLTextures;

PROCEDURE Reshape;
BEGIN	
context.MakeCurrent();
GL.SetFCR();
	GL.glMatrixMode(GLC.GL_PROJECTION);
	GL.glLoadIdentity();
	GL.gluPerspective(45.0, 1.0, 0.1, 100.0);
	
	GL.glMatrixMode(GLC.GL_MODELVIEW);
	GL.glLoadIdentity();
	
	 GL.gluLookAt(0.0, 0.0, 2.0, 0., 0., 0., 0., 1., 0.);	
GL.DelFCR();
context.DeActivate();

END Reshape;


PROCEDURE InitGL;
BEGIN
	light := FALSE; blend := FALSE;
	xrot := 30.0; yrot := 30.0; z := -10.0;	
	xspeed := 0.0; yspeed := 0.0;
	
	filter := 0;
				
(*	LightAmbient :=  [0.5, 0.5, 0.5, 1.0];
	LightDiffuse  := [1.0, 1.0, 1.0, 1.0];
	LightPosition := [0.0, 0.0, 2.0, 1.0];
*)

LightAmbient[0] := 0.5; LightAmbient[1] := 0.5; LightAmbient[2] := 0.5; LightAmbient[3] := 1.0;
LightDiffuse[0] := 1.0; LightDiffuse[1] := 1.0; LightDiffuse[2] := 1.0; LightDiffuse[3] := 1.0;
LightPosition[0]:= 0.0; LightPosition[1]:= 0.0; LightPosition[2]:= 0.2; LightPosition[3]:= 1.0;

(* context.MakeCurrent(); *)
GL.SetFCR();

  (* Enable Texture Mapping ( NEW ) *)
  GL.glEnable( GLC.GL_TEXTURE_2D );

  (* Enable smooth shading *)
  GL.glShadeModel( GLC.GL_SMOOTH );

  (* Set the background black *)
  GL.glClearColor( 0.0, 1.0, 1.0, 0.0 );

  (* Depth buffer setup *)
  GL.glClearDepth( 1.0 );

  (* Enables Depth Testing *)
  GL.glEnable( GLC.GL_DEPTH_TEST );

  (* The Type Of Depth Test To Do *)
  GL.glDepthFunc( GLC.GL_LEQUAL );

  (* Really Nice Perspective Calculations *)
  GL.glHint( GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST );

  (* Setup The Ambient Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_AMBIENT, SYSTEM.ADR(LightAmbient[0]) );

  (* Setup The Diffuse Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_DIFFUSE, SYSTEM.ADR(LightDiffuse[0]) );

  (* Position The Light *)
  GL.glLightfv( GLC.GL_LIGHT1, GLC.GL_POSITION, SYSTEM.ADR(LightPosition[0]) );

  (* Enable Light One *)
  GL.glEnable( GLC.GL_LIGHT1 );

  (* Full Brightness, 50% Alpha ( NEW ) *)
  GL.glColor4f( 1.0, 1.0, 1.0, 0.5);

  (* Blending Function For Translucency Based On Source Alpha Value  *)
  GL.glBlendFunc( GLC.GL_SRC_ALPHA, GLC.GL_ONE );
GL.DelFCR();
 
END InitGL;

PROCEDURE DrawMode(dm: LONGINT);
VAR drawMode: LONGINT;
BEGIN
	drawMode := dm;
	context.MakeCurrent();
	  	
        IF drawMode = 0 THEN       (* fill mode*)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
            GL.glEnable(GLC.GL_DEPTH_TEST);
            GL.glEnable(GLC.GL_CULL_FACE);
        ELSIF drawMode = 1 THEN  (* wireframe mode *)
            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
        ELSE                    (* point mode *)

            GL.glPolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
            GL.glDisable(GLC.GL_DEPTH_TEST);
            GL.glDisable(GLC.GL_CULL_FACE);
	  END;
	  context.DeActivate();
END DrawMode;

PROCEDURE Drawing;
VAR zz: REAL;
BEGIN
 zz := z + 2.0;
 (*context.MakeCurrent(); *)
 
 GL.SetFCR();
 GL.glClear( GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );
  GL.glLoadIdentity( );
  GL.glTranslatef( 0.0, 0.0, z );
  GL.glRotatef( xrot, 1.0, 0.0, 0.0); 
  GL.glRotatef( yrot, 0.0, 1.0, 0.0); 
  GL.glBindTexture( GLC.GL_TEXTURE_2D, texture[filter] );
 GL.DelFCR(); 
  Cube();
 GL.SetFCR(); 
  GL.glLoadIdentity( );
  GL.glTranslatef( 1.5, -1.5, zz);
  GL.glRotatef( yrot, 1.0, 0.0, 0.0);
  GL.glRotatef( xrot, 0.0, 1.0, 0.0); 
 GL.DelFCR(); 
  Cube(); 
 GL.SetFCR(); 
  GL.glLoadIdentity( );
  GL.glTranslatef( 1.5, 1.5, z );
  GL.glRotatef( yrot, 1.0, 1.0, 0.0);
  GL.glRotatef( xrot, 0.0, 1.0, 0.0); 
  GL.DelFCR();
  Cube(); 
  
END Drawing;

PROCEDURE Cube();
VAR
	i,j,k: INTEGER;
BEGIN
(* context.MakeCurrent(); *)
GL.SetFCR();
  GL.glBegin( GLC.GL_QUADS );
    GL.glNormal3f( 0.0, 0.0, 1.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( -1.0, -1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0, -1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( -1.0,  1.0,  1.0 );

    GL.glNormal3f( 0.0, 0.0, -1.0);
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( -1.0, -1.0, -1.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( -1.0,  1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, -1.0, -1.0 );

    GL.glNormal3f( 0.0, 1.0, 0.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( -1.0,  1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( -1.0,  1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, -1.0 );

    GL.glNormal3f( 0.0, -1.0, 0.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( -1.0, -1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0, -1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, -1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( -1.0, -1.0,  1.0 );

    GL.glNormal3f( 1.0, 0.0, 0.0);
  
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 1.0, -1.0, -1.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 1.0,  1.0, -1.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 1.0,  1.0,  1.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 1.0, -1.0,  1.0 );

    GL.glNormal3f( -1.0, 0.0, 0.0 );
    GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( -1.0, -1.0, -1.0 );
    GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( -1.0, -1.0,  1.0 );
    GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( -1.0,  1.0,  1.0 );
    GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( -1.0,  1.0, -1.0 );
    
     GL.glEnd();
  
 GL.DelFCR(); 
END Cube;

PROCEDURE Testspeed;
VAR i: LONGINT;
BEGIN
FOR i:=1 TO 360 DO 
	xrot := xrot + 2;
	UpdateImage;
END;	
END Testspeed;

BEGIN

END GLWindow;
	    		
     
PROCEDURE Open*;
VAR 
	window : GLWindow;
BEGIN	
	NEW(window, 512, 512);
END Open;

BEGIN
END MyWMGLWindow2.

SystemTools.Free  MyWMGLWindow2  GLContext ~

MyWMGLWindow2.Open ~
