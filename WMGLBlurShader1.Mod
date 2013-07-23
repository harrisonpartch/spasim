MODULE WMGLBlurShader1; (** AUTHOR "fnecati"; PURPOSE "Gauss-blurring by shaders"; *)

IMPORT
	WMRectangles, Strings, GLSL := GLShaderUtils,  KernelLog, 
	WM := WMWindowManager, Raster, WMGraphics,
	gl := OpenGL, glc := OpenGLConst, WMGL := WMGLWindow;


(*	Created on: Sep 6, 2010
      Author: aqnuep
      
      adopted to A2-opengloberon
*)      

TYPE
	Float = gl.Float;
	Uint = gl.Uint;
    
TYPE
	GLWindow* =  OBJECT(WMGL.Window)
	VAR
		prog: ARRAY 5 OF Uint;
		fbo, fbtex: ARRAY 2 OF Uint;
		vbo : Uint;
		texture: Uint;
		mode, iterations: LONGINT;
		
	PROCEDURE &New(w, h: LONGINT);
	BEGIN		
		Init(w, h, FALSE);
		WM.DefaultAddWindow(SELF);
		SetTitle(Strings.NewString("WMGLBlurShader"));
			
		IF ~InitGL() THEN Close; RETURN END;

		Reshape(w, h);			
		UpdateImage;
	END New;


	PROCEDURE  InitGL(): BOOLEAN;
	VAR
		quad: ARRAY 12 OF Float;
 	BEGIN	

		mode := 0; iterations := 1;
   
 		MakeCurrent();

 		gl.ReadCoreVersion;
 		IF ~gl.GL_VERSION_3_0 THEN
 			KernelLog.String("Error: your graphic card does not support OpenGL 3.0"); KernelLog.Ln; 
		 	RETURN FALSE;
		 END;
 	
		gl.ReadExtensions();
 
 		 (* create full-screen quad mesh *)
 		  quad := [ 1.0, 1.0, -1.0, 1.0, -1.0,-1.0,
					  -1.0,-1.0,  1.0,-1.0,  1.0, 1.0 ];
		gl.GenBuffers(1, ADDRESSOF(vbo));
		gl.BindBuffer(glc.GL_ARRAY_BUFFER, vbo);
		gl.BufferData(glc.GL_ARRAY_BUFFER, 2*6*SIZEOF(Float), ADDRESSOF(quad[0]), glc.GL_STATIC_DRAW);
		gl.EnableVertexAttribArray(0);
		gl.VertexAttribPointer(0, 2, glc.GL_FLOAT, glc.GL_FALSE, SIZEOF(Float)*2, 0);

		
		prog[0] :=  GLSL.LoadShaders("passthrough.vs", "passthrough.fs");
		prog[1] :=  GLSL.LoadShaders("passthrough.vs", "discrete_vert.fs");
		prog[2] :=  GLSL.LoadShaders("passthrough.vs", "linear_vert.fs");
		prog[3] :=  GLSL.LoadShaders("passthrough.vs", "discrete_horiz.fs");
		prog[4] :=  GLSL.LoadShaders("passthrough.vs", "linear_horiz.fs");

	(* create temporary framebuffer *)
	IF ~CreateFramebuffer(fbo[0], fbtex[0]) THEN RETURN FALSE; END;
	IF ~CreateFramebuffer(fbo[1], fbtex[1]) THEN RETURN FALSE; END;
	gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, 0);


	(* load texture, 1024x1024 *)
	texture := LoadTexture("mule.png");
	
		DeActivate;
		RETURN TRUE;
	END InitGL;
	
	PROCEDURE reload;
	BEGIN
		prog[0] :=  GLSL.LoadShaders("passthrough.vs", "passthrough.fs");
		prog[1] :=  GLSL.LoadShaders("passthrough.vs", "discrete_vert.fs");
		prog[2] :=  GLSL.LoadShaders("passthrough.vs", "linear_vert.fs");
		prog[3] :=  GLSL.LoadShaders("passthrough.vs", "discrete_horiz.fs");
		prog[4] :=  GLSL.LoadShaders("passthrough.vs", "linear_horiz.fs");
	END reload;
		
		
	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	VAR
		t:BOOLEAN;
	BEGIN
		CASE CHR(ucs) OF
			 "q" : Close; RETURN;
			| " ": mode := (mode+1) MOD 3; 
				  IF mode =0 THEN KernelLog.String( "No Gaussian filter"); KernelLog.Ln; UpdateImage()
				  ELSIF mode =1 THEN KernelLog.String( "Gaussian filter with discrete sampling"); KernelLog.Ln; 
				  ELSIF mode =2 THEN KernelLog.String( "Gaussian filter with linear sampling"); KernelLog.Ln;
				  ELSE
				  END;
			| "+": INC(iterations); IF iterations > 9 THEN iterations := 1; END;
			| "-" : DEC(iterations);IF iterations <1 THEN iterations := 1; END;
			| "i" : reload; UpdateImage
		ELSE	
		END;
		UpdateImage();
	END KeyEvent;

	PROCEDURE Close*;
	VAR i: LONGINT;
	BEGIN
		MakeCurrent();
		gl.DeleteTextures(1, ADDRESSOF(texture));
		FOR i := 0 TO 4 DO
			gl.DeleteProgram(prog[0]);
		END;
		
		gl.DeleteTextures(2, ADDRESSOF(fbtex[0]));
		gl.DeleteFramebuffers(2, ADDRESSOF(fbo[0]));
		
		Close^;
	END Close;
		
	PROCEDURE Display();
	VAR i: LONGINT;
	BEGIN

		gl.BindTexture(glc.GL_TEXTURE_2D, texture); 
		
		IF mode # 0 THEN
		gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, fbo[0]);

			gl.UseProgram(prog[mode+2]);
			gl.DrawArrays(glc.GL_TRIANGLES, 0, 6);
			
			FOR i:=1 TO iterations-1 DO
				gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, fbo[1]);
				gl.BindTexture(glc.GL_TEXTURE_2D, fbtex[0]);

				gl.UseProgram(prog[mode]);
				gl.DrawArrays(glc.GL_TRIANGLES, 0, 6);

				gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, fbo[0]);
				gl.BindTexture(glc.GL_TEXTURE_2D, fbtex[1]);

				gl.UseProgram(prog[mode+2]);
				gl.DrawArrays(glc.GL_TRIANGLES, 0, 6);			
			
			END;
			gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, 0);

			gl.BindTexture(glc.GL_TEXTURE_2D, fbtex[0]);			
		END;
		gl.UseProgram(prog[mode]);
		gl.DrawArrays(glc.GL_TRIANGLES, 0, 6);
				
	END Display;

	PROCEDURE UpdateImage;
	BEGIN
		MakeCurrent();
		Display();				
		SwapGLBuffer();
		DeActivate();
		Swap();
		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
	 MakeCurrent();
	 	gl.Viewport(0, 0, w, h);
	DeActivate;
	END Reshape;

BEGIN 
END GLWindow;

PROCEDURE CreateFramebuffer ( VAR fbo, fbtex: Uint): BOOLEAN;
VAR status: gl.Enum;
BEGIN
	gl.GenTextures(1, ADDRESSOF(fbtex));
	gl.BindTexture(glc.GL_TEXTURE_2D, fbtex);
	gl.TexImage2D(glc.GL_TEXTURE_2D, 0, glc.GL_RGB8, 1024, 1024, 0, glc.GL_BGR, glc.GL_UNSIGNED_BYTE, 0);
	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_S, glc.GL_CLAMP_TO_EDGE);
	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_T, glc.GL_CLAMP_TO_EDGE);
	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MAG_FILTER, glc.GL_LINEAR);
	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MIN_FILTER, glc.GL_LINEAR);
	gl.GenFramebuffers(1, ADDRESSOF(fbo));
	gl.BindFramebuffer(glc.GL_DRAW_FRAMEBUFFER, fbo);
	gl.FramebufferTexture2D(glc.GL_DRAW_FRAMEBUFFER, glc.GL_COLOR_ATTACHMENT0, glc.GL_TEXTURE_2D, fbtex, 0);
	
		status := gl.CheckFramebufferStatus(glc.GL_DRAW_FRAMEBUFFER);
		IF status # glc.GL_FRAMEBUFFER_COMPLETE THEN
			IF status = glc.GL_FRAMEBUFFER_UNSUPPORTED THEN
				KernelLog.String("Error: unsupported framebuffer format"); KernelLog.Ln; 

			ELSE
				KernelLog.String("Error: invalid framebuffer config"); KernelLog.Ln;
			END;
			RETURN FALSE;
		END;
		RETURN TRUE;
END CreateFramebuffer;

	PROCEDURE LoadTexture(CONST fname: ARRAY OF CHAR): Uint;
	VAR teximg, img0: Raster.Image;
		tex: Uint;
	BEGIN
		img0 := WMGraphics.LoadImage(fname, FALSE);
		ASSERT(img0 # NIL, 220 );
		teximg := TransposeImage(img0);
		
	 	gl.GenTextures(1, ADDRESSOF(tex));
	 	gl.BindTexture(glc.GL_TEXTURE_2D, tex);
	 	gl.TexImage2D(glc.GL_TEXTURE_2D, 0, glc.GL_RGBA, teximg.width, teximg.height, 0, glc.GL_BGRA, glc.GL_UNSIGNED_BYTE, teximg.adr);
	 	
	 	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_S, glc.GL_CLAMP_TO_EDGE);
		gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_T, glc.GL_CLAMP_TO_EDGE);
	 	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MAG_FILTER, glc.GL_LINEAR);
	 	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MIN_FILTER, glc.GL_LINEAR);
	 
		 	
	 	RETURN tex;
	END LoadTexture;

PROCEDURE TransposeImage(im: Raster.Image): Raster.Image;
VAR i, j: LONGINT;
	tim: Raster.Image;
	pix: Raster.Pixel;
	mode: Raster.Mode;
BEGIN
	Raster.InitMode(mode, Raster.srcCopy);
	NEW(tim);
	Raster.Create(tim, im.width, im.height, im.fmt);

	FOR j :=0 TO im.height-1 DO
		FOR i:=0 TO im.width-1 DO
		 	Raster.Get(im,i, j, pix, mode);
			 Raster.Put(tim, i, im.height-j-1, pix, mode); (* flip vertical  *)
		END;
	END;
 	RETURN tim;
END TransposeImage;
	
PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, 1024, 1024);
END Open;

BEGIN

END WMGLBlurShader1.

SystemTools.Free  WMGLBlurShader1  WMGLWindow ~

SystemTools.FreeDownTo OpenGL ~ 


WMGLBlurShader1.Open ~
