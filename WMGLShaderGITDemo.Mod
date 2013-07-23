MODULE WMGLShaderGITDemo; (** AUTHOR "fnecati"; PURPOSE "Gauss-blurring by shaders"; *)

IMPORT
	WMRectangles, Strings, GLSL := GLShaderUtils,  KernelLog, GLTextures,
	WM := WMWindowManager, WMGraphics, WMDialogs,
	gl := OpenGL, glc := OpenGLConst, WMGL := WMGLWindow;

CONST 
	width =512;
	height = 512;
		
TYPE
	Float = gl.Float;
	Uint = gl.Uint;
    	Int = gl.Int;
    	Ushort = gl.Ushort;
    	
TYPE
	GLWindow* =  OBJECT(WMGL.Window)
	VAR
		positionLocation, texcoordsLocation: Uint;
	
		passthroughProgram, boxBlurProgram, negativeProgram,
		gaussianBlurProgram, grayscaleProgram, edgeDetectionProgram,
		toonShadingProgram,  vintageProgram, brightnessProgram,
		sharpenProgram, unsharpMaskProgram,
		nightVisionProgram,
		weirdProgram: Uint;
		progname: ARRAY 32 OF CHAR;
		
	PROCEDURE &New(w, h: LONGINT);
	BEGIN		
		Init(w, h, FALSE);
				
		WM.DefaultAddWindow(SELF);
		SetTitle(Strings.NewString("Image Processing"));
		IF ~InitGL() THEN Close; RETURN END;
		Reshape(w, h);			
		UpdateImage;
	END New;

	PROCEDURE InitShader(CONST vertexShaderPath, fragmentShaderPath: ARRAY OF CHAR): Uint;
	VAR program: Uint;
		location: Int;
		w, h: REAL;
	BEGIN
		program := GLSL.LoadShaders(vertexShaderPath, fragmentShaderPath);
		gl.UseProgram(program);

		location := gl.GetUniformLocation(program, "u_image");
		IF location # -1 THEN gl.Uniform1i(location, 0); END;

		location := gl.GetUniformLocation(program, "u_step") ;
		w :=1.0/width; h := 1.0/height;
		IF location # -1 THEN gl.Uniform2f(location, w, h);  END;

		RETURN program;
	END InitShader;

	PROCEDURE InitVAO();
	VAR
		vertices, texcoords: ARRAY [8] OF Float;
		indices: ARRAY [6] OF Ushort;
		vao:  Uint;
		vertexBufferObjID: ARRAY [3] OF Uint;
		
	BEGIN
		vertices := [
	 			-1.0, -1.0,
	 			1.0, -1.0,
	 			1.0, 1.0,
				-1.0, 1.0
					];

		texcoords := [
				1.0, 1.0,
				 0.0, 1.0,
				 0.0, 0.0,
				1.0, 0.0
					];

		indices := [ 0, 1, 3, 3, 1, 2 ];


		gl.GenVertexArrays(1, ADDRESSOF(vao));
		gl.BindVertexArray(vao);

		gl.GenBuffers(3, ADDRESSOF(vertexBufferObjID[0]));

		gl.BindBuffer(glc.GL_ARRAY_BUFFER, vertexBufferObjID[0]);
		gl.BufferData(glc.GL_ARRAY_BUFFER, LEN(vertices,0)*SIZEOF(Float), ADDRESSOF(vertices[0]), glc.GL_STATIC_DRAW);
		gl.VertexAttribPointer(positionLocation, 2, glc.GL_FLOAT, glc.GL_FALSE, 0, 0);
		gl.EnableVertexAttribArray(positionLocation);

		gl.BindBuffer(glc.GL_ARRAY_BUFFER, vertexBufferObjID[1]);
		gl.BufferData(glc.GL_ARRAY_BUFFER, LEN(texcoords,0)*SIZEOF(Float), ADDRESSOF(texcoords[0]), glc.GL_STATIC_DRAW);
		gl.VertexAttribPointer(texcoordsLocation, 2, glc.GL_FLOAT, glc.GL_FALSE, 0, 0);
		gl.EnableVertexAttribArray(texcoordsLocation);

		gl.BindBuffer(glc.GL_ELEMENT_ARRAY_BUFFER, vertexBufferObjID[2]);
		gl.BufferData(glc.GL_ELEMENT_ARRAY_BUFFER, LEN(indices,0)*SIZEOF(Ushort), ADDRESSOF(indices[0]), glc.GL_STATIC_DRAW);

	END InitVAO;

	PROCEDURE InitTextures();
	VAR image: Uint;
	BEGIN
		image := GLTextures.LoadTextureCustom("Lenna.png");
	(*	gl.BindTexture(glc.GL_TEXTURE_2D, image);*)
	(*	gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MAG_FILTER, glc.GL_NEAREST);
		gl.TexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MIN_FILTER, glc.GL_NEAREST); *)
		GLSL.PrintOpenGLError("Init Textures-N");	
	END InitTextures;

	PROCEDURE  InitGL(): BOOLEAN;
 	BEGIN	
		
 		MakeCurrent();
		gl.ReadExtensions();

 		gl.ReadCoreVersion;
 		IF ~gl.GL_VERSION_3_3 THEN
 			KernelLog.String("Error: your graphic card does not support OpenGL 3.3"); KernelLog.Ln; 
		 	RETURN FALSE;
		 END;

		positionLocation := 0;
		texcoordsLocation := 1;
		progname:="boxBlurProgram";
		
		InitVAO();
		InitTextures();

		passthroughProgram := InitShader("passthroughVS.glsl", "passthroughFS.glsl");
		boxBlurProgram := InitShader("passthroughVS.glsl", "boxBlurFS.glsl");
		negativeProgram := InitShader("passthroughVS.glsl", "negativeFS.glsl");
		gaussianBlurProgram := InitShader("passthroughVS.glsl", "gaussianBlurFS.glsl");
		grayscaleProgram := InitShader("passthroughVS.glsl", "grayscaleFS.glsl");
		edgeDetectionProgram := InitShader("passthroughVS.glsl", "edgeDetectionFS.glsl");
		toonShadingProgram := InitShader("passthroughVS.glsl", "toonShadingFS.glsl");
		vintageProgram := InitShader("passthroughVS.glsl", "vintageFS.glsl");
		brightnessProgram := InitShader("passthroughVS.glsl", "brightnessFS.glsl");
		unsharpMaskProgram := InitShader("passthroughVS.glsl", "unsharpMaskFS.glsl");
		sharpenProgram := InitShader("passthroughVS.glsl", "sharpenFS.glsl");
		nightVisionProgram := InitShader("passthroughVS.glsl", "nightVisionFS.glsl");
		weirdProgram := InitShader("weirdVS.glsl", "passthroughFS.glsl");
				
		gl.UseProgram(boxBlurProgram);
	(*	gl.ActiveTexture(glc.GL_TEXTURE0); *)
		
		DeActivate;
		RETURN TRUE;
	END InitGL;
		
		
	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	VAR
		t: BOOLEAN;
	BEGIN
		MakeCurrent();
		CASE CHR(ucs) OF
			 "x" : Close; RETURN;
			| "s" : SaveImage; RETURN;
			| "i" :	t:=InitGL();
			| "1" :	gl.UseProgram(passthroughProgram); progname:="passthroughProgram";
			| "2" :	gl.UseProgram(boxBlurProgram); progname:="boxBlurProgram";
			| "3" :	gl.UseProgram(negativeProgram); progname:="negativeProgram";
			| "4" :	gl.UseProgram(gaussianBlurProgram); progname:="gaussianBlurProgram";
			| "5" :	gl.UseProgram(grayscaleProgram); progname:="grayscaleProgram";
			| "6" :	gl.UseProgram(edgeDetectionProgram); progname:="edgeDetectionProgram";
			| "7" :	gl.UseProgram(toonShadingProgram); progname:="toonShadingProgram";
			| "8" :	gl.UseProgram(vintageProgram); progname:="vintageProgram";
			| "9" :	gl.UseProgram(brightnessProgram); progname:="brightnessProgram";
			| "0" :	gl.UseProgram(unsharpMaskProgram); progname:="unsharpMaskProgram";
			| "-" :	gl.UseProgram(sharpenProgram); progname:="sharpenProgram";
			| "q" :	gl.UseProgram(nightVisionProgram); progname:="nightVisionProgram";
			| "w" :	gl.UseProgram(weirdProgram); progname:="weirdProgram";

		ELSE	
		END;
		DeActivate();
		UpdateImage();
	END KeyEvent;

	PROCEDURE SaveImage;
	VAR res: LONGINT;
		fname: ARRAY 128 OF CHAR;
	BEGIN
		fname:="mywmgltest.bmp";
		IF WMDialogs.QueryString(" Save File name: ",fname)=WMDialogs.ResOk THEN
				WMGraphics.StoreImage(img, fname,res);
		END;
	END SaveImage;
	
	PROCEDURE Close*;
	BEGIN
		MakeCurrent();
		gl.DeleteProgram(passthroughProgram);
		gl.DeleteProgram(boxBlurProgram);
		gl.DeleteProgram(negativeProgram);
		gl.DeleteProgram(gaussianBlurProgram);
		gl.DeleteProgram(grayscaleProgram);
		gl.DeleteProgram(edgeDetectionProgram);
		gl.DeleteProgram(toonShadingProgram);
		gl.DeleteProgram(vintageProgram);
		gl.DeleteProgram(brightnessProgram);
		gl.DeleteProgram(sharpenProgram);
		gl.DeleteProgram(unsharpMaskProgram);
		gl.DeleteProgram(nightVisionProgram);
		gl.DeleteProgram(weirdProgram);
		
		Close^;
	END Close;
		
	PROCEDURE Display();
	BEGIN
		gl.Clear(glc.GL_COLOR_BUFFER_BIT);	

		(* VAO, shader program, and texture already bound *)
		gl.DrawElements(glc.GL_TRIANGLES, 6, glc.GL_UNSIGNED_SHORT, 0);
	END Display;

	PROCEDURE UpdateImage;
	VAR dw, dh: LONGINT;
	BEGIN
		MakeCurrent();
		Display();				
		SwapGLBuffer();
		DeActivate();
		canvas.SetColor(WMGraphics.White);
		canvas.GetFont().GetStringSize(progname, dw, dh);
		canvas.DrawString(GetWidth() DIV 2- dw DIV 2 , 20, progname);
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

PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, width, height);
END Open;

BEGIN

END WMGLShaderGITDemo.

SystemTools.Free  WMGLShaderGITDemo  WMGLWindow ~

SystemTools.FreeDownTo OpenGL ~ 


WMGLShaderGITDemo.Open ~
