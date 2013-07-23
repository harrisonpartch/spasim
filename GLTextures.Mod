MODULE GLTextures; (** AUTHOR "fnecati"; PURPOSE "opengl texture loading"; *)

IMPORT
	WMGraphics, Raster,   SYSTEM, Files, 
	KernelLog,	gl := OpenGL, GLC := OpenGLConst (*, glu := GLU*);

CONST 
	debug = FALSE;
	
CONST
	MAGIC_DDS = 20534444H;  (* "DDS "*)
	FOURCC_DXT1 =  31545844H;  (* Equivalent to "DXT1" in ASCII *)
	FOURCC_DXT3 =  33545844H;  (* Equivalent to "DXT3" in ASCII *)
	FOURCC_DXT5 =  35545844H;  (* Equivalent to "DXT5" in ASCII *)


(* Structures from Direct3D 9 *)
TYPE
	D3DPixelFormat = RECORD  (* DDPIXELFORMAT *)
		size: LONGINT;
		flags: LONGINT;
		fourCC: LONGINT;
		rgbBitCount: LONGINT;
		rBitMask, gBitMask, bBitMask: LONGINT;
		rgbAlphaBitMask: LONGINT;
	END 

TYPE D3DCaps2 = RECORD
	caps1: LONGINT;
	caps2: LONGINT;
	reserved:  ARRAY 2 OF LONGINT;
END;

TYPE
	 D3DSurfaceDesc2 = RECORD
		size: LONGINT;
		flags: LONGINT;
		height: LONGINT;
		width: LONGINT;
		pitchOrLinearSize: LONGINT;
		depth: LONGINT;
		mipMapCount: LONGINT;
		reserved1: ARRAY 11 OF LONGINT; 
		pixelFormat: D3DPixelFormat;
		caps: D3DCaps2;
		reserved2: LONGINT;
	END;

	DDSImage* = OBJECT
	VAR
		width*, height*, blockSize*,  mipMaps*: LONGINT;
		format*: LONGINT;
		pixels*: POINTER TO ARRAY OF CHAR;
		
	END DDSImage;
	
(**  This function loads an image file and return the OpenGL reference ID to use that texture *)
PROCEDURE LoadTexture* (CONST filename: ARRAY OF CHAR): LONGINT;
VAR 
	img0, img: Raster.Image;
	textureNumber: LONGINT;
BEGIN

	img0:= WMGraphics.LoadImage(filename, FALSE); (* loaded image format is BGRA8888 - > GL.GL_BGRA *)
	IF img0 = NIL THEN
		KernelLog.String(filename); KernelLog.String(" Not Loaded"); KernelLog.Ln;
		RETURN -1; (* Open the file for reading *)
	  END;

	img := TransposeImage(img0);

 	gl.GenTextures(1, ADDRESSOF(textureNumber));
	gl.BindTexture(GLC.GL_TEXTURE_2D, textureNumber);  (* Bind the ID texture specified by the 2nd parameter *)
 
	
	gl.TexEnvi(GLC.GL_TEXTURE_ENV, GLC.GL_TEXTURE_ENV_MODE, GLC.GL_MODULATE); (* Texture blends with object background *)
      (* gl.TexEnvi(GLC.GL_TEXTURE_ENV, GLC.GL_TEXTURE_ENV_MODE, GLC.GL_DECAL);  *) (* Texture does NOT blend with object background *)

  (* Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)   
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  *)
  
  	(* The next commands sets the texture parameters *)
	gl.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);  (*  only first two can be used *)
	gl.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);  (* all of the above can be used*)


	(* And create 2d mipmaps for the minifying function *)
(*	res := glu.Build2DMipmaps(GLC.GL_TEXTURE_2D, GLC.GL_RGBA, img.width, img.height, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr); *)
	
	 gl.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, img.width, img.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr); (* use when not wanting mipmaps to be built by openGL *) 

	img0 := NIL;
	img := NIL;
	RETURN textureNumber; (*  Returns the current texture OpenGL ID *)
END LoadTexture;

(**  This function loads an image file and return the OpenGL reference ID to use that texture *)
PROCEDURE LoadTextureRGB* (CONST filename: ARRAY OF CHAR): LONGINT;
VAR 
	img0, img: Raster.Image;
	textureNumber: LONGINT;
	mode: Raster.Mode;
BEGIN

	img0:= WMGraphics.LoadImage(filename, FALSE); (* loaded image format is BGRA8888 - > GL.GL_BGRA *)
	IF img0 = NIL THEN
		KernelLog.String(filename); KernelLog.String(" Not Loaded"); KernelLog.Ln;
		RETURN -1; (* Open the file for reading *)
	  END;
	NEW(img);
	Raster.Create(img, img0.width, img0.height, Raster.BGR888);
	Raster.InitMode(mode, Raster.srcCopy);
	Raster.Copy(img0, img, 0,0,img.width, img.height, 0,0, mode);
	img := TransposeImage(img0);

 	gl.GenTextures(1, ADDRESSOF(textureNumber));
	gl.BindTexture(GLC.GL_TEXTURE_2D, textureNumber);  (* Bind the ID texture specified by the 2nd parameter *)
 
	
(*	gl.TexEnvi(GLC.GL_TEXTURE_ENV, GLC.GL_TEXTURE_ENV_MODE, GLC.GL_MODULATE); (* Texture blends with object background *)*)
      (* gl.TexEnvi(GLC.GL_TEXTURE_ENV, GLC.GL_TEXTURE_ENV_MODE, GLC.GL_DECAL);  *) (* Texture does NOT blend with object background *)

  (* Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)   
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  *)
  
  	(* The next commands sets the texture parameters *)
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_S, GLC.GL_REPEAT);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_T, GLC.GL_REPEAT);  	
	gl.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);  (*  only first two can be used *)
	gl.TexParameterf(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);  (* all of the above can be used*)


	(* And create 2d mipmaps for the minifying function *)
(*	res := glu.Build2DMipmaps(GLC.GL_TEXTURE_2D, GLC.GL_RGB, img.width, img.height, GLC.GL_RGB, GLC.GL_UNSIGNED_BYTE, img.adr); *)
	
	 gl.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, img.width, img.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);  (* use when not wanting mipmaps to be built by openGL *) 

	img0 := NIL;
	img := NIL;
	RETURN textureNumber; (*  Returns the current texture OpenGL ID *)
END LoadTextureRGB;


PROCEDURE LoadTextureCustom* (CONST filename: ARRAY OF CHAR): LONGINT;
VAR 
	img0, img: Raster.Image;
	textureNumber: LONGINT;
BEGIN

	img0:= WMGraphics.LoadImage(filename, FALSE); (* loaded image format is BGRA8888 - > GL.GL_BGRA *)
	IF img0 = NIL THEN
		KernelLog.String(filename); KernelLog.String(" Not Loaded"); KernelLog.Ln;
		RETURN -1; (* Open the file for reading *)
	  END;

	img := img0;

 	gl.GenTextures(1, ADDRESSOF(textureNumber));
	gl.BindTexture(GLC.GL_TEXTURE_2D, textureNumber);  (* Bind the ID texture specified by the 2nd parameter *)
	 gl.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, img.width, img.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);
	
	(* ... nice trilinear filtering. *)
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_S, GLC.GL_REPEAT);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_T, GLC.GL_REPEAT);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR_MIPMAP_LINEAR); 
	gl.GenerateMipmap(GLC.GL_TEXTURE_2D);	
	
	img0 := NIL;
	img := NIL;
	RETURN textureNumber; (*  Returns the current texture OpenGL ID *)
END LoadTextureCustom;

PROCEDURE LoadTextureCustomFlipped* (CONST filename: ARRAY OF CHAR): LONGINT;
VAR 
	img0, img: Raster.Image;
	textureNumber: LONGINT;
BEGIN

	img0:= WMGraphics.LoadImage(filename, FALSE); (* loaded image format is BGRA8888 - > GL.GL_BGRA *)
	IF img0 = NIL THEN
		KernelLog.String(filename); KernelLog.String(" Not Loaded"); KernelLog.Ln;
		RETURN -1; (* Open the file for reading *)
	  END;

	img := TransposeImage(img0);

 	gl.GenTextures(1, ADDRESSOF(textureNumber));
	gl.BindTexture(GLC.GL_TEXTURE_2D, textureNumber);  (* Bind the ID texture specified by the 2nd parameter *)
	 gl.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, img.width, img.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, img.adr);
	
	(* ... nice trilinear filtering. *)
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_S, GLC.GL_REPEAT);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_WRAP_T, GLC.GL_REPEAT);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR_MIPMAP_LINEAR); 
	gl.GenerateMipmap(GLC.GL_TEXTURE_2D);	
	
	img0 := NIL;
	img := NIL;
	RETURN textureNumber; (*  Returns the current texture OpenGL ID *)
END LoadTextureCustomFlipped;

PROCEDURE LoadDDS*(CONST imagepath: ARRAY OF CHAR): LONGINT;
VAR

	file: Files.File;
	read: Files.Reader;
	cnt: LONGINT;
	textureID: gl.Uint;
	dumy, height, width: LONGINT;

	buffer: POINTER TO ARRAY OF CHAR;
	components, format: LONGINT;
	blockSize, offset, level, bufSize: LONGINT;
	
	header: ARRAY 124 OF CHAR;
	
	dds: D3DSurfaceDesc2;
BEGIN
 
	(* try to open the file *) 
	file := Files.Old(imagepath); 
	IF file = NIL THEN 
		RETURN 0; 
      END;
      Files.OpenReader(read, file, 0);
      
	(* verify the type of file *)
	read.RawLInt(dumy);
	IF dumy # MAGIC_DDS THEN
		KernelLog.String(" not a DDS file "); KernelLog.Ln; 
		RETURN 0;
	END;
	
	read.Bytes(header, 0,124, cnt);
	
	dds := SYSTEM.VAL(D3DSurfaceDesc2, header);

	(* 124 bytes read till now + 4 bytes for DDS*)
	
	IF dds.pixelFormat.fourCC = FOURCC_DXT1 THEN components  := 3 ELSE  components  := 4 END;

	IF  dds.pixelFormat.fourCC =  FOURCC_DXT1 THEN
		format := GLC.GL_COMPRESSED_RGBA_S3TC_DXT1_EXT; 
	ELSIF   dds.pixelFormat.fourCC = FOURCC_DXT3 THEN
		format := GLC.GL_COMPRESSED_RGBA_S3TC_DXT3_EXT; 
	ELSIF  dds.pixelFormat.fourCC =FOURCC_DXT5 THEN
		format := GLC.GL_COMPRESSED_RGBA_S3TC_DXT5_EXT; 
	ELSE 
		RETURN 0; 
	END;
	
	IF format = GLC.GL_COMPRESSED_RGBA_S3TC_DXT1_EXT THEN
		blockSize := 8 
	ELSE
		blockSize := 16;
	END;
	
	IF debug THEN		
		KernelLog.String("size= "); KernelLog.Int(dds.size, 0); KernelLog.Ln; 
		KernelLog.String("height= "); KernelLog.Int(dds.height, 0); KernelLog.Ln; 
		KernelLog.String("width= "); KernelLog.Int(dds.width, 0); KernelLog.Ln; 
		KernelLog.String("pitchOrLinearSize= "); KernelLog.Int(dds.pitchOrLinearSize, 0); KernelLog.Ln; 
		KernelLog.String("mipMapCount= "); KernelLog.Int(dds.mipMapCount, 0); KernelLog.Ln;  
		KernelLog.String("dds.pixelFormat.fourCC= "); KernelLog.Int(dds.pixelFormat.fourCC, 0);  KernelLog.Ln; 
		KernelLog.String("components= "); KernelLog.Int(components, 0); KernelLog.Ln; 
		KernelLog.String("format= "); KernelLog.Int(format, 0); KernelLog.Ln; 
		KernelLog.String("blockSize= "); KernelLog.Int(blockSize, 0); KernelLog.Ln; 			
	END;

	width := dds.width;
	height := dds.height;
	level := 0;
	bufSize :=0;	
	
	(* How big is it going to be including all mipmaps? *)
	WHILE (level < dds.mipMapCount) & ((width # 0) OR (height # 0)) DO
		bufSize := bufSize + ((width+3) DIV 4)*((height+3) DIV 4)*blockSize;
		width  := width DIV 2; (* IF width = 0 THEN width := 1; END;*)
		height := height DIV 2; (* IF height = 0 THEN height := 1; END;*)
		INC(level);
	END;
	
	IF debug THEN KernelLog.String("bufSize (bytes)= "); KernelLog.Int(bufSize, 0); KernelLog.Ln; END;
		
	(* alocate pixels memory *)
	NEW(buffer, bufSize);
	
	read.Bytes(buffer^, 0, bufSize, cnt);
	IF debug THEN KernelLog.String("read.Bytes cnt= "); KernelLog.Int(cnt, 0); KernelLog.Ln; END;
	
	(* upload the texture *)

	(* Create one OpenGL texture *)
	gl.GenTextures(1, ADDRESSOF(textureID));

	(* "Bind" the newly created texture : all future texture functions will modify this texture *)
	gl.BindTexture(GLC.GL_TEXTURE_2D, textureID);

	(* missing mipmaps won't be a problem anymore. *)
	gl.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAX_LEVEL, dds.mipMapCount - 1);

	(* Upload each mipmaps *)
	width := dds.width;
	height := dds.height;
	offset := 0;	
	level := 0;
	WHILE (level < dds.mipMapCount) & ((width # 0) OR (height # 0)) DO		
		bufSize := ((width+3) DIV 4)*((height+3) DIV 4)*blockSize; 		
		gl.CompressedTexImage2D(GLC.GL_TEXTURE_2D, level, format, width, height,  0, bufSize,   ADDRESSOF(buffer[offset ]) );		
		offset := offset + bufSize; 
				
		width  := width DIV 2;  (* IF width = 0 THEN width := 1; END; *)
		height := height DIV 2; (* IF height = 0 THEN height := 1; END; *)
		INC(level);
	END;

	RETURN textureID;
END LoadDDS;


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
	

END GLTextures.
