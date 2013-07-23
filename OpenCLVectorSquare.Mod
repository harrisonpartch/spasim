MODULE OpenCLVectorSquare; (** AUTHOR "fnecati"; PURPOSE "Square of vectors using OpenCL"; *)
IMPORT CL := OpenCL, S:=SYSTEM, KernelLog, Streams, Utils:=OpenCLUtils;

CONST DATA_SIZE=32768;

TYPE
	RVector = POINTER TO ARRAY OF REAL;
	
VAR 
	wr: Streams.Writer;

	
PROCEDURE Test*;
VAR
	err     : LONGINT; (* error code returned from api calls*)
 
	data    : RVector; (* original data set given to device *)
	results : RVector; (* results returned from device *)

	global  : CL.csize_t;  (* global domain size for our calculation *)
	local   : CL.csize_t;  (* local domain size for our calculation *)
    
	platformids  : CL.cl_platform_id;
	deviceids : CL.cl_device_id;
	context : CL.cl_context;
	commands : CL.cl_command_queue;  
	
	prog      : CL.cl_program;       (* compute program *)
	kernel    : CL.cl_kernel;         (* compute kernel *)
	input   : CL.cl_mem;  (* device memory used for the input array *)
	output  : CL.cl_mem;  (* device memory used for the output array *)

	kernelsource: CL.PChar; 	
	
	i, count : LONGINT;
	correct: LONGINT;
	tmpd: REAL;
   
	buf:  ARRAY 1024 OF  CHAR;
	bufwritten: LONGINT;
	dumy: LONGINT;
  
BEGIN
	(*Fill our data set with float values *)
	count := DATA_SIZE;
	NEW(data, count);
	NEW(results, count);
	
	FOR i:=0 TO count - 1 DO data[i]:=1.0*i; END;

	err := CL.clGetPlatformIDs( 1, S.ADR(platformids), 0 ); 
	wr.String("clGetPlatformIDs : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Cannot get platforms!'); wr.Ln; wr.Update;
		RETURN
	END;
    
	(*  Devices  *)  
	err := CL.clGetDeviceIDs(platformids, CL.DEVICE_TYPE_ALL, 1, S.ADR(deviceids), 0);
	wr.String("clGetDeviceIDs : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Cannot get devices!'); wr.Ln; wr.Update;
		RETURN
	END;     
	
	context := CL.clCreateContext(0, 1, S.ADR(deviceids), NIL , 0, err);
	wr.String("clContext : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update; 
	IF context = 0 THEN 
		wr.String('Error: Cannot create context!'); wr.Ln; wr.Update;
		RETURN
	END;
   
	commands := CL.clCreateCommandQueue(context, deviceids, 0, err);
	wr.String("clCommandQueue: "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;  
	IF commands = 0 THEN 
		wr.String("commands NIL: "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;  
		RETURN 
	END;
 
	kernelsource := Utils.LoadProgramSource("vectorsquare.cl", "");
	IF kernelsource = NIL THEN
		wr.String(" File Load Error"); wr.Ln; wr.Update; wr.Ln;
	END;  

    (* Create the compute program from the source buffer *)
	prog := CL.clCreateProgramWithSource(context, 1, S.ADR(kernelsource), 0, err);
	wr.String("clCreateProgramWithSource : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;  wr.Update;
	IF prog = 0 THEN 
		wr.String("prog NIL: "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;  
		RETURN 
	END;

	err := CL.clGetProgramInfo(prog, CL.PROGRAM_SOURCE, LEN(buf), S.ADR(buf), bufwritten);
	wr.String("clGetProgramInfo : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: clGetProgramInfo!'); wr.Ln; wr.Update;
		RETURN
	END;
	wr.String("bufwritten= "); wr.Int(bufwritten, 0); wr.Ln;  
	wr.String("Prog Source: "); wr.Ln;
	wr.String(buf); wr.Ln; wr.Update;
  
	err := CL.clGetProgramInfo(prog, CL.PROGRAM_NUM_DEVICES, S.SIZEOF(LONGINT), S.ADR(dumy), 0);
	wr.String("clGetProgramInfo : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;	
	IF (err # CL.SUCCESS) THEN
		wr.String("clGetProgramInfo Error: "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
		wr.String('Error: clGetProgramInfo!'); wr.Ln; wr.Update;
		RETURN
	END;
	wr.String("numdevices dumy= "); wr.Int(dumy, 0); wr.Ln; 
   
	(* Build the program executable *)
	err := CL.clBuildProgram(prog, 0, NIL, "", 0, 0);
	wr.String("clBuildProgram : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;  wr.Update;
	IF err # CL.SUCCESS THEN
		wr.String('Error: Failed to build program executable!'); wr.Ln; wr.Update; 
	END;
 
	err := CL.clGetProgramBuildInfo(prog, deviceids,CL.PROGRAM_BUILD_LOG, LEN(buf), S.ADR(buf[0]), 0);
	wr.String("clGetProgramBuildInfo : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: clGetProgramBuildInfo!'); wr.Ln; wr.Update;
		RETURN
	END;
	wr.String("bufwritten= "); wr.Int(bufwritten, 0); wr.Ln;  
	wr.String("Prog Build Info: "); wr.String(buf); wr.Ln; wr.Update;
  
	 (* Create the compute kernel in the program we wish to run *)
	kernel := CL.clCreateKernel(prog, "square", err); 
	wr.String("clCreateKernel : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;  wr.Update;
	IF kernel=0 THEN 
		wr.String("kernel NIL: "); wr.String(Utils.ErrorToStr(err)); wr.Ln; wr.Update;  
		RETURN 
	END;

	err := CL.clGetKernelWorkGroupInfo(kernel, deviceids,  CL.KERNEL_WORK_GROUP_SIZE, S.SIZEOF(LONGINT), S.ADR(local), 0);
	wr.String("clGetKernelWorkGroupInfo : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: clGetKernelWorkGroupInfo!'); wr.Ln; wr.Update;
		RETURN
	END;   

	(* Create the input and output arrays in device memory for our calculation *)
	input := CL.clCreateBuffer(context,  CL.MEM_READ_ONLY,  S.SIZEOF(REAL) * count, 0, err);
	wr.String("clCreateBuffer input  : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	
	output := CL.clCreateBuffer(context, CL.MEM_WRITE_ONLY, S.SIZEOF(REAL) * count, 0, err);
	wr.String("clCreateBuffer output  : "); wr.String(Utils.ErrorToStr(err)); wr.Ln;
	
	IF (input = 0) OR   (output = 0) THEN
		wr.String("Failed to allocate device memory!  : "); wr.Ln; wr.Update;
		RETURN
	END;

	(* Write our data set into the input array in device memory *)
	err := CL.clEnqueueWriteBuffer(commands, input, CL.CL_TRUE, 0, S.SIZEOF(REAL) * count, S.ADR(data[0]), 0, 0, 0);
	wr.String("clEnqueueWriteBuffer : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Failed to write source array!'); wr.Ln; wr.Update;
		RETURN
	END;

	(* Set the arguments to our compute kernel *)	
	err := CL.clSetKernelArg(kernel, 0, S.SIZEOF(CL.cl_mem), S.ADR(input));
	wr.String("clSetKernelArg-0 : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	
	err := CL.clSetKernelArg(kernel, 1, S.SIZEOF(CL.cl_mem), S.ADR(output));
	wr.String("clSetKernelArg-1 : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	

	err := CL.clSetKernelArg(kernel, 2, S.SIZEOF(CL.cl_uint), S.ADR(count));
	wr.String("clSetKernelArg-2 : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Failed to set kernel arguments!!'); wr.Ln; wr.Update;
		RETURN
	END;
       
	(* Get the maximum work group size for executing the kernel on the device *)
	err := CL.clGetKernelWorkGroupInfo(kernel, deviceids,  CL.KERNEL_WORK_GROUP_SIZE, S.SIZEOF(LONGINT), S.ADR(local), 0);
	wr.String("clGetKernelWorkGroupInfo : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Failed to retrieve kernel work group info!'); wr.Ln; wr.Update;
		RETURN
	END;   
            
	(* Execute the kernel over the entire range of our 1d input data set
		using the maximum number of work group items for this device *)
	global := count;
	err := CL.clEnqueueNDRangeKernel(commands, kernel, 1, 0 , S.ADR(global), S.ADR(local), 0, 0, 0);
	wr.String("clEnqueueNDRangeKernel : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Failed to execute kernel!'); wr.Ln; wr.Update;
		RETURN
	END;   
       
	(* Wait for the command commands to get serviced before reading back results*)
	err := CL.clFinish(commands);
	wr.String("clFinish : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 
  
	(* Read back the results from the device to verify the output *)
	err := CL.clEnqueueReadBuffer( commands, output, CL.CL_TRUE, 0, S.SIZEOF(REAL) * count, S.ADR(results[0]), 0, 0, 0);
	wr.String("EnqueueReadBuffer : "); wr.String(Utils.ErrorToStr(err)); wr.Ln; 	
	IF (err # CL.SUCCESS) THEN
		wr.String('Error: Failed to read output array! '); wr.Ln; wr.Update;
		RETURN
	END;    
 
	(* Validate our results *)
	correct := 0;
	FOR i:= 0 TO count - 1 DO
		(* FPU warning:
			the following check (as in original C sample)
			if results[i] = data[i] * data[i] then
    
			return the incorrect result (FP accuracy?),
			must store the result to single type variable first,
			and then compare: *)
		tmpd := data[i] * data[i];
		IF results[i] = tmpd THEN INC(correct); END;
	END;

	(* Print a brief summary detailing the results *)
	wr.String('Computed '); wr.Int(correct,0); wr.String('/'); wr.Int(count,0); wr.String(' correct values!'); wr.Ln; wr.Update;

	wr.String("data [1..10 ]"); wr.Ln;
	FOR i:=0 TO 10 DO   wr.FloatFix(data[i],10,1,0);  END;    wr.Ln;
	wr.String("results [1..10 ]"); wr.Ln;  
	FOR i:=0 TO 10 DO   wr.FloatFix(results[i],10,1,0);  END;   wr.Ln;     
  
	(* Free resources *)
	err := CL.clReleaseMemObject(input);
	err := CL.clReleaseMemObject(output);
	err := CL.clReleaseProgram(prog);
	err := CL.clReleaseKernel(kernel);
	err := CL.clReleaseCommandQueue(commands);
	err := CL.clReleaseContext(context);
 
	wr.String("******************************************"); wr.Ln;
	wr.Update;
END Test;

BEGIN

Streams.OpenWriter(wr, KernelLog.Send);
END OpenCLVectorSquare.

SystemTools.Free OpenCLVectorSquare ~


OpenCLVectorSquare.Test ~ 
