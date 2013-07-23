MODULE MyImageRotateCL; (** AUTHOR "fnecati"; PURPOSE "A demo for image rotation using OpenCL"; *)
(* 
	kernel program adapted from:
	JOCL - Java bindings for OpenCL
	Copyright 2010 Marco Hutter - http://www.jocl.org/

  A simple example demonstrating image handling between OpenCLOberon
  and Aos WM. It shows an animation of a rotating image,
  which is rotated using an OpenCL kernel involving some
  basic image operations.
 *)
 
IMPORT
	Raster, WMRectangles, WMGraphics, Modules, Strings, Kernel, Commands,
	WM := WMWindowManager,  WMMessages, KernelLog, WMDialogs, Streams,
	S:=SYSTEM, CL := OpenCL, Utils := OpenCLUtils;

TYPE 
	IVector = ARRAY [*] OF LONGINT;

	KillerMsg = OBJECT
	END KillerMsg;

	Window* =  OBJECT(WM.BufferWindow)
	VAR
		timer: Kernel.MilliTimer;
		alive, dead, animated: BOOLEAN;
		 		
		PROCEDURE &New();
		BEGIN
			Init(sizeX, sizeY, FALSE);
			manager := WM.GetDefaultManager();
			manager.Add(100, 100, SELF, {WM.FlagFrame, WM.FlagClose, WM.FlagNoResizing});
			SetTitle(Strings.NewString("SimpleImageCL: "));				
			animated := FALSE;
			dead := FALSE;
			RotateImage;
		END New;

		PROCEDURE KeyEvent* (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			CASE CHR(ucs) OF
			 "r" : angle  := angle + 0.1;
			| "l": angle := angle - 0.1;
			| "A" : animated := ~animated;
			| "S": SaveImage;
			ELSE
			
			END;
			IF inited THEN
				RotateImage;
			END
		END KeyEvent;
	
		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Draw*(canvas : WMGraphics.Canvas; w, h, q : LONGINT);
		BEGIN
			Draw^(canvas, w, h, 0)
		END Draw;

		PROCEDURE Close*;
		BEGIN
			alive := FALSE;
			BEGIN {EXCLUSIVE} AWAIT(dead); END;
			Close^;
			window := NIL;
		END Close;

		PROCEDURE RotateImage;
		VAR err: LONGINT;	
			elapsed: LONGINT;
			str1, str2 : ARRAY 128 OF CHAR;
			
		BEGIN
			IF inited THEN	
				 Kernel.SetTimer(timer,0);
				 IF animated THEN
					angle := angle + 0.01;
					IF angle>1000.0 THEN angle :=0.0; END;			 
				 END;
	     		err := CL.clSetKernelArg(kernel, 0, S.SIZEOF(CL.cl_mem), S.ADR(inputImageMem));
	     		IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clSetKernelArg-0: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
				END;	
	     		err := CL.clSetKernelArg(kernel, 1, S.SIZEOF(CL.cl_mem), S.ADR(outputImageMem));
	     		IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clSetKernelArg-1: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
				END;	

	     		err := CL.clSetKernelArg(kernel, 2, S.SIZEOF(CL.cl_float),  S.ADR(angle));
	     		IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clSetKernelArg-2: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
				END;	

        			err := CL.clEnqueueNDRangeKernel(commands, kernel, 2, 0, S.ADR(globalWorkSize[0]), 0, 0, 0, 0);
	     		IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clEnqueueNDRangeKernel: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
				END;	

        			(* Read the pixel data into the output image *)
        			origin[0] := 0; origin[1] := 0; origin[2] := 0;
        			region[0] := sizeX; region[1] := sizeY; region [2] := 1;
        			
				err := CL.clEnqueueReadImage(commands, outputImageMem, CL.CL_TRUE, S.ADR(origin[0]), S.ADR(region[0]),  sizeX * S.SIZEOF(CL.cl_uint), 0, outputImage.adr, 0, 0, 0);
				IF err # CL.SUCCESS THEN
					KernelLog.String("ERROR clEnqueueReadImage: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					RETURN
				END;	

				(*  write timing info  *)						
				str1:= "SimpleImageCL:  ";			
				elapsed := Kernel.Elapsed(timer);
				Strings.IntToStr(elapsed, str2);
				Strings.Append(str1, str2);
				Strings.Append(str1, " ms.");				
				SetTitle(Strings.NewString(str1));
				
				Raster.Copy(outputImage,img, 0,0, sizeX, sizeY, 0, 0, mode);
				Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
			END;
		END RotateImage;

		PROCEDURE SaveImage;
		VAR res: LONGINT;
			fname: ARRAY 128 OF CHAR;
		BEGIN
		fname:="simpleimage0.bmp";
		IF WMDialogs.QueryString(" Save File name: ",fname)=WMDialogs.ResOk THEN
				WMGraphics.StoreImage(img,fname,res);
		END;
		END SaveImage;
		
	BEGIN  {ACTIVE}
	alive := TRUE;
	WHILE alive DO
		IF animated THEN
			RotateImage;
		END
	END;
	BEGIN {EXCLUSIVE} dead := TRUE; END;	

	END Window;

VAR

     		inputImage: Raster.Image; (* input image *)
     		outputImage: Raster.Image; (* output image *)
		mode: Raster.Mode;
     	
		platformids: CL.cl_platform_id;
		deviceids : CL.cl_device_id;
		context : CL.cl_context;
		commands : CL.cl_command_queue;  
		prog      : CL.cl_program;       (* compute program *)
		kernel    : CL.cl_kernel;         (* compute kernel *)
		
		inputImageMem   : CL.cl_mem;  (* device memory used for the input image *)
		outputImageMem: CL.cl_mem;  (* device memory used for the output image *)

		kernelsource: CL.PChar;  
	
		angle : REAL;
		inited : BOOLEAN;
		
		globalWorkSize: IVector;
		sizeX, sizeY: LONGINT; (* size of image *)
		origin, region: CL.Pcsize_t;
		
	    		
PROCEDURE InitCL;
VAR 
		err: LONGINT;
		imageSupport: LONGINT;
		properties: HUGEINT; (* CL.bit_field *)
		(*bufwritten: LONGINT;*)
		buf: ARRAY 4096 OF CHAR; 
		
		BEGIN
			inited := FALSE;
			angle := 0.0;
			NEW(origin,3); 	NEW(region,3);
			sizeX := inputImage.width; 
			sizeY := inputImage.height; 
				
			globalWorkSize := [sizeX, sizeY];
			
			err := CL.clGetPlatformIDs( 1, S.ADR(platformids), 0 ); 
			err := CL.clGetDeviceIDs(platformids, CL.DEVICE_TYPE_ALL, 1, S.ADR(deviceids), 0);
			
			err := CL.clGetDeviceInfo(deviceids, CL.DEVICE_IMAGE_SUPPORT, S.SIZEOF(CL.cl_int), S.ADR(imageSupport), 0);
			IF err = CL.SUCCESS THEN			
					IF imageSupport = 0 THEN
					 inited := FALSE;
					 KernelLog.String("No Image Support"); KernelLog.Ln; 
					 RETURN;
					 END;
			ELSE
					 KernelLog.String("ERROR clGetDeviceInfo: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
			END;
			
			context := CL.clCreateContext(0, 1, S.ADR(deviceids), NIL , 0, err);
			IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clCreateContext: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
			END;
			
			(* with event profile *)
			properties := S.VAL(HUGEINT, {CL.QUEUE_PROFILING_ENABLE, CL.QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE});
			commands := CL.clCreateCommandQueue(context, deviceids, properties , err);
			IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clCreateCommandQueue: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
			END;			
			
			kernelsource := MyProgramSource();
			prog := CL.clCreateProgramWithSource(context, 1, S.ADR(kernelsource), 0, err);
			IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clCreateProgramWithSource: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
			END;

	(*		err := CL.clGetProgramInfo(prog, CL.PROGRAM_SOURCE, LEN(buf), S.ADR(buf[0]), 0);
			KernelLog.String("clGetProgramInfoSource= "); KernelLog.String(buf); KernelLog.Ln; 
	*)									
			err := CL.clBuildProgram(prog, 0, NIL, "", 0, 0);
			IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clBuildProgram: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					err := CL.clGetProgramBuildInfo(prog, deviceids,CL.PROGRAM_BUILD_LOG, LEN(buf), S.ADR(buf[0]), 0);
					KernelLog.String("Build Log : "); KernelLog.Ln; 
					KernelLog.String(buf); KernelLog.Ln; 					 
					 RETURN
			END;		
		
			kernel := CL.clCreateKernel(prog, "rotateImage", err); 
			IF err # CL.SUCCESS THEN
					 KernelLog.String("ERROR clCreateKernel: ");  KernelLog.String(Utils.ErrorToStr(err)); KernelLog.Ln; 
					 RETURN
			END;					
			inited := (context # 0) & (commands # 0) & (prog # 0)  & (kernel # 0) & (err=0);
END InitCL;

 PROCEDURE initImageMem();
 VAR imageFormat, imfmt: CL.cl_image_format;
 	  	
 	err, ret: LONGINT;
 	tmp: LONGINT;
 BEGIN
        (* Create the memory object for the input- and output image *)
		IF ~ inited THEN RETURN END;

		
        imageFormat.image_channel_order := CL.RGBA;
        imageFormat.image_channel_data_type := CL.UNSIGNED_INT8;

        inputImageMem := CL.clCreateImage2D(
            context, S.VAL(HUGEINT, {CL.MEM_READ_ONLY, CL.MEM_USE_HOST_PTR}),
            imageFormat, sizeX, sizeY,
            sizeX * S.SIZEOF(CL.cl_uint), inputImage.adr, err);
	   IF err # CL.SUCCESS THEN
		  KernelLog.String("ERROR inputImageMem clCreateImage2D: ");  KernelLog.String(Utils.ErrorToStr(err)); 
		  KernelLog.Ln;   
	   END;	
        outputImageMem := CL.clCreateImage2D(
            context, CL.MEM_WRITE_ONLY,
            imageFormat, sizeX, sizeY, 0, 0, err);
 	   IF err # CL.SUCCESS THEN
		  KernelLog.String("ERROR outputImageMem clCreateImage2D: ");  KernelLog.String(Utils.ErrorToStr(err)); 
		  KernelLog.Ln;   
	   END;
END initImageMem;

PROCEDURE Open*(ctx: Commands.Context);
VAR fname: ARRAY 128 OF CHAR;
	  im: Raster.Image; 
BEGIN
  IF ~ ctx.arg.GetString(fname) THEN RETURN END;
  im:= WMGraphics.LoadImage(fname, FALSE);
  IF im = NIL THEN
  	KernelLog.String(fname); KernelLog.String(" Not Loaded"); KernelLog.Ln; 
  RETURN
  END;
  NEW(inputImage);
  Raster.Create(inputImage, im.width, im.height, Raster.BGRA8888);
  Raster.Copy(im, inputImage, 0,0,im.width, im.height,0,0, mode);
  KernelLog.String(fname); KernelLog.String("  loaded.."); KernelLog.Ln; 
 
   NEW(outputImage);
  Raster.Create(outputImage, im.width, im.height, Raster.BGRA8888);

  InitCL;
  initImageMem();
END Open;


PROCEDURE Cleanup;
VAR 
	 err: LONGINT;
	 
BEGIN {EXCLUSIVE}
	IF inited THEN
		err := CL.clReleaseMemObject(inputImageMem);
		err := CL.clReleaseMemObject(outputImageMem);
		err := CL.clReleaseKernel(kernel);
		err := CL.clReleaseProgram(prog);
		err := CL.clReleaseCommandQueue(commands);
		err := CL.clReleaseContext(context);	
	END;	
END Cleanup;


PROCEDURE MyProgramSource(): CL.PChar;
VAR sw: Streams.StringWriter;
      buf: CL.PChar;
BEGIN
NEW(sw,1024);
	   sw.Ln;	
        sw.String("const sampler_t samplerIn =") ; sw.Ln;
        sw.String("    CLK_NORMALIZED_COORDS_FALSE |"); sw.Ln;
        sw.String("    CLK_ADDRESS_CLAMP |"); sw.Ln;
        sw.String("    CLK_FILTER_NEAREST; "); sw.Ln;
        sw.Ln;
        sw.String("const sampler_t samplerOut =") ; sw.Ln;
        sw.String("    CLK_NORMALIZED_COORDS_FALSE |"); sw.Ln;
        sw.String("    CLK_ADDRESS_CLAMP |"); sw.Ln;
        sw.String("    CLK_FILTER_NEAREST;") ; sw.Ln;
         sw.Ln;
        sw.String("__kernel void rotateImage("); sw.Ln;
        sw.String("    __read_only  image2d_t sourceImage, "); sw.Ln;
        sw.String("    __write_only image2d_t targetImage, "); sw.Ln;
        sw.String("    float angle)"); sw.Ln;
        sw.String("{"); sw.Ln;
        sw.String("    int gidX = get_global_id(0);"); sw.Ln;
        sw.String("    int gidY = get_global_id(1);"); sw.Ln;
        sw.String("    int w = get_image_width(sourceImage);"); sw.Ln;
        sw.String("    int h = get_image_height(sourceImage);"); sw.Ln;
        sw.String("    int cx = w/2;"); sw.Ln;
        sw.String("    int cy = h/2;"); sw.Ln;
        sw.String("    int dx = gidX-cx;"); sw.Ln;
        sw.String("    int dy = gidY-cy;"); sw.Ln;
        sw.String("    float ca = cos(angle);"); sw.Ln;
        sw.String("    float sa = sin(angle);"); sw.Ln;
        sw.String("    int inX = (int)(cx+ca*dx-sa*dy);"); sw.Ln;
        sw.String("    int inY = (int)(cy+sa*dx+ca*dy);"); sw.Ln;
        sw.String("    int2 posIn = {inX, inY};"); sw.Ln;
        sw.String("    int2 posOut = {gidX, gidY};"); sw.Ln;
        sw.String("    uint4 pixel = read_imageui(sourceImage, samplerIn, posIn);"); sw.Ln;
        sw.String("    write_imageui(targetImage, posOut, pixel);") ; sw.Ln;
        sw.String("}"); sw.Ln;
 NEW(buf, sw.Pos());
 sw.Get(buf^);
 RETURN S.VAL(CL.PChar, S.ADR(buf[0]));
 	
END MyProgramSource;

BEGIN
	Modules.InstallTermHandler(Cleanup);
	Raster.InitMode(mode, Raster.srcCopy);
END MyImageRotateCL.

SystemTools.Free  MyImageRotateCL~ 

MyImageRotateCL.Open "mars.png" ~

MyImageRotateCL.Open "BluebottlePic0.png" ~

MyImageRotateCL.Open "test.bmp" ~

