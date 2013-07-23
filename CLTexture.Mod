MODULE CLTexture; (** AUTHOR "fnecati"; PURPOSE ""; *)
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
	Raster,  Modules, Strings, Kernel, Commands,
	Out:=KernelLog, Streams,
	S:=SYSTEM, CL := OpenCL, Utils := OpenCLUtils;

TYPE 
	IVector = ARRAY [*] OF LONGINT;
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
					 Out.String("No Image Support"); Out.Ln; 
					 RETURN;
					 END;
			ELSE
					 Out.String("ERROR clGetDeviceInfo: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					 RETURN
			END;
			
			context := CL.clCreateContext(0, 1, S.ADR(deviceids), NIL , 0, err);
			IF err # CL.SUCCESS THEN
					 Out.String("ERROR clCreateContext: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					 RETURN
			END;
			
			(* with event profile *)
			properties := S.VAL(HUGEINT, {CL.QUEUE_PROFILING_ENABLE, CL.QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE});
			commands := CL.clCreateCommandQueue(context, deviceids, properties , err);
			IF err # CL.SUCCESS THEN
					 Out.String("ERROR clCreateCommandQueue: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					 RETURN
			END;			
			
			kernelsource := MyProgramSource();
			prog := CL.clCreateProgramWithSource(context, 1, S.ADR(kernelsource), 0, err);
			IF err # CL.SUCCESS THEN
					 Out.String("ERROR clCreateProgramWithSource: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					 RETURN
			END;

					
			err := CL.clBuildProgram(prog, 0, NIL, "", 0, 0);
			IF err # CL.SUCCESS THEN
					 Out.String("ERROR clBuildProgram: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					err := CL.clGetProgramBuildInfo(prog, deviceids,CL.PROGRAM_BUILD_LOG, LEN(buf), S.ADR(buf[0]), 0);
					Out.String("Build Log : "); Out.Ln; 
					Out.String(buf); Out.Ln; 					 
					 RETURN
			END;		
		
			kernel := CL.clCreateKernel(prog, "rotateImage", err); 
			IF err # CL.SUCCESS THEN
					 Out.String("ERROR clCreateKernel: ");  Out.String(Utils.ErrorToStr(err)); Out.Ln; 
					 RETURN
			END;					
			inited := (context # 0) & (commands # 0) & (prog # 0)  & (kernel # 0) & (err=0);
			IF inited THEN Out.String("WOOHOO!") ELSE Out.String("NOT WOOHOO") END;
END InitCL;

 PROCEDURE initImageMem*(image: Raster.Image):CL.cl_mem;
 VAR imageFormat, imfmt: CL.cl_image_format;	  	
 	err, ret: LONGINT;
 	tmp: LONGINT;
 BEGIN
        (* Create the memory object for the input- and output image *)
       inputImageMem:=0;
	IF ~inited THEN RETURN inputImageMem END;		
        imageFormat.image_channel_order := CL.RGBA;
        imageFormat.image_channel_data_type := CL.UNSIGNED_INT8;
        inputImageMem := CL.clCreateImage2D(
            context, S.VAL(HUGEINT, {CL.MEM_READ_ONLY, CL.MEM_USE_HOST_PTR}),
            imageFormat, sizeX, sizeY,
            sizeX * S.SIZEOF(CL.cl_uint), inputImage.adr, err);
	   IF err # CL.SUCCESS THEN
		  Out.String("ERROR inputImageMem clCreateImage2D: ");  Out.String(Utils.ErrorToStr(err)); 
		  Out.Ln;   
	   ELSE
	   	 Out.String("NO ERROR inputImageMem clCreateImage2D: ");  
		  Out.Ln;  
	   END;	
	   RETURN inputImageMem
END initImageMem;

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
(*	InitCL *)  (* a. not in use and b. traps out *)
END CLTexture.

SystemTools.FreeDownTo CLTexture~ 

MyImageRotateCL.Open "mars.png" ~

MyImageRotateCL.Open "BluebottlePic0.png" ~

MyImageRotateCL.Open "test.bmp" ~

