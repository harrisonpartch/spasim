MODULE OpenCL; (** AUTHOR "fnecati"; PURPOSE "OpenCL binding library  for LinuxAos"; *)
IMPORT S:=SYSTEM, Unix,  Modules, Trace;

(* ******************************************************************************
 * Copyright (c) 2008-2009 The Khronos Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and/or associated documentation files (the
 * "Materials"), to deal in the Materials without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Materials, and to
 * permit persons to whom the Materials are furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Materials.
 *
 * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
 ***************************************************************************** 

 ported to FPC by Dmitry 'skalogryz' Boyarintsev: 28th apr 2009
 due to name conflict with type names, some constants have been renamed
 
*)

CONST 
	libname="libOpenCL.so";  (* for ubuntu 10.04 LTS,  x64 *)

VAR
	 lib: LONGINT; (* handle to library *)
	 

CONST
  PLATFORM_NVIDIA*  = 3001H;  (* NVidia specific platform value *)

(* scalar types  *)

TYPE
  
  ADDRESS* = S.ADDRESS;
  PChar* = POINTER TO ARRAY OF CHAR;
  PPChar* = POINTER TO ARRAY OF PChar;
  csize_t* = LONGINT;  
  Pcsize_t* = POINTER TO ARRAY OF csize_t;
  
  intptr_t* = csize_t;
  
  cl_char*     = CHAR; (*-127..+128 *)   
  cl_uchar*    = CHAR;  (* 0..255 *)  
  cl_short*    = INTEGER; (* - 32767..+32768; *)  
  cl_ushort*   = INTEGER; (*  0..+65535; *)  
  cl_int*      = LONGINT; (*-2147483647..+2147483648;  *)
  cl_uint*     = LONGINT;  (* 0..4294967295;  *)  
  cl_long*     = HUGEINT; (* Int64;// 0..184467440773709551615;//-$8000000000000001..+$8000000000000000{9223372036854775808}; //typedef signed   __int64  cl_long; *)
  cl_ulong*    = HUGEINT;

  cl_half*     = INTEGER;
  cl_float*    = REAL;
  cl_double*   = LONGREAL;

  Pcl_char*     = POINTER TO ARRAY OF cl_char;
  Pcl_uchar*    = POINTER TO ARRAY OF cl_uchar;
  Pcl_short*    = POINTER TO ARRAY OF cl_short;
  Pcl_ushort*   = POINTER TO ARRAY OF cl_ushort;
  Pcl_int*      = POINTER TO ARRAY OF cl_int;
  Pcl_uint*     = POINTER TO ARRAY OF cl_uint;
  Pcl_long*     = POINTER TO ARRAY OF cl_long;
  Pcl_ulong*    = POINTER TO ARRAY OF cl_ulong;

  Pcl_half*     = POINTER TO ARRAY OF cl_half;
  Pcl_float*    = POINTER TO ARRAY OF cl_float;
  Pcl_double*   = POINTER TO ARRAY OF cl_double;


 CONST

      CHAR_BIT*       =  8;
      SCHAR_MAX*      =  127;
      SCHAR_MIN*      =  (-127-1);
      CHAR_MAX*       =   SCHAR_MAX;
      CHAR_MIN*       =   SCHAR_MIN;
      UCHAR_MAX*      =  255;
      SHRT_MAX*       =  32767;
      SHRT_MIN*       =  (-32767-1);
      USHRT_MAX*      =  65535;
      INT_MAX*        =  2147483647;
      INT_MIN*        =  (-2147483647-1);
      UINT_MAX*       =  0FFFFFFFFH;
      LONG_MAX*       =  7FFFFFFFFFFFFFFFH;
      LONG_MIN*       =  -(7FFFFFFFFFFFFFFFH) - 1;
	ULONG_MAX*      =  0FFFFFFFFFFFFFFFFH;
	 
      FLT_DIG*        =  6;
      FLT_MANT_DIG*   =  24;
      FLT_MAX_10_EXP* =  +38;
      FLT_MAX_EXP*    =  +128;
      FLT_MIN_10_EXP* =  -37;
      FLT_MIN_EXP*    =  -125;
      FLT_RADIX*      =  2;
(*     // FLT_MAX*        =  FLT_MAX;
     // FLT_MIN*        =  FLT_MIN;
     // FLT_EPSILON*    =  FLT_EPSILON;
*)
      DBL_DIG*        =  15;
      DBL_MANT_DIG*   =  53;
      DBL_MAX_10_EXP* =  +308;
      DBL_MAX_EXP*    =  +1024;
      DBL_MIN_10_EXP* =  -307;
      DBL_MIN_EXP*    =  -1021;
      DBL_RADIX*      =  2;
(*     // DBL_MAX*        =  DBL_MAX;
     // DBL_MIN*        =  DBL_MIN;
     // DBL_EPSILON*    =  DBL_EPSILON;
*)


(*
 * Vector types
 *
 *  Note:   OpenCL requires that all types be naturally aligned.
 *          This means that vector types must be naturally aligned.
 *          For example, a vector of four floats must be aligned to
 *          a 16 byte boundary (calculated as 4 * the natural 4-byte
 *          alignment of the float).  The alignment qualifiers here
 *          will only function properly if your compiler supports them
 *          and if you don't actively work to defeat them.  For example,
 *          in order for a cl_float4 to be 16 byte aligned in a struct,
 *          the start of the struct must itself be 16-byte aligned.
 *
 *          Maintaining proper alignment is the user's responsibility.
 *)


 
TYPE

  cl_char2*  = ARRAY 2 OF  cl_char;
  cl_char4*  = ARRAY 4 OF  cl_char;
  cl_char8*  = ARRAY 8 OF  cl_char;
  cl_char16* = ARRAY 16 OF  cl_char;

  cl_uchar2* = ARRAY 2 OF  cl_uchar;
  cl_uchar4* = ARRAY 4 OF  cl_uchar;
  cl_uchar8* = ARRAY 8 OF  cl_uchar;
  cl_uchar16* = ARRAY 16 OF  cl_uchar;

  cl_short2*  = ARRAY 2 OF  cl_short;
  cl_short4*  = ARRAY 4 OF  cl_short;
  cl_short8*  = ARRAY 8 OF  cl_short;
  cl_short16* = ARRAY 16 OF  cl_short;

  cl_ushort2*  = ARRAY 2 OF  cl_ushort;
  cl_ushort4*  = ARRAY 4 OF  cl_ushort;
  cl_ushort8*  = ARRAY 8 OF  cl_ushort;
  cl_ushort16* = ARRAY 16 OF  cl_ushort;

  cl_int2*  = ARRAY 2 OF  cl_int;
  cl_int4*  = ARRAY 4 OF  cl_int;
  cl_int8*  = ARRAY 8 OF  cl_int;
  cl_int16* = ARRAY 16 OF  cl_int;

  cl_uint2*  = ARRAY 2 OF  cl_uint;
  cl_uint4*  = ARRAY 4 OF  cl_uint;
  cl_uint8*  = ARRAY 8 OF  cl_uint;
  cl_uint16* = ARRAY 16 OF  cl_uint;

  cl_long2*  = ARRAY 2 OF  cl_long;
  cl_long4*  = ARRAY 4 OF  cl_long;
  cl_long8*  = ARRAY 8 OF  cl_long;
  cl_long16* = ARRAY 16 OF  cl_long;

  cl_ulong2*  = ARRAY 2 OF  cl_ulong;
  cl_ulong4*  = ARRAY 4 OF  cl_ulong;
  cl_ulong8*  = ARRAY 8 OF  cl_ulong;
  cl_ulong16* = ARRAY 16 OF  cl_ulong;

  cl_float2*  = ARRAY 2 OF  cl_float;
  cl_float4*  = ARRAY 4 OF  cl_float;
  cl_float8*  = ARRAY 8 OF  cl_float;
  cl_float16* = ARRAY 16 OF  cl_float;

  cl_double2*  = ARRAY 2 OF  cl_double;
  cl_double4*  = ARRAY 4 OF  cl_double;
  cl_double8*  = ARRAY 8 OF  cl_double;
  cl_double16* = ARRAY 16 OF  cl_double;


(* There are no vector types for half *)

(* **************************************************************************** *)


TYPE

  cl_platform_id*    =csize_t; 
  cl_device_id*      = csize_t; 
  cl_context*        = csize_t;
  cl_command_queue*  =  csize_t;
  cl_mem*            = csize_t;
  cl_program*        = csize_t;
  cl_kernel*         = csize_t;
  cl_event*          = csize_t;
  cl_sampler*        = csize_t;


  Pcl_platform_id*    = POINTER TO ARRAY OF cl_platform_id;
  Pcl_device_id*      = POINTER TO ARRAY OF cl_device_id;
  Pcl_context*        = POINTER TO ARRAY OF cl_context;
  Pcl_command_queue*  = POINTER TO ARRAY OF cl_command_queue;
  Pcl_mem*            = POINTER TO ARRAY OF cl_mem;
  Pcl_program*        = POINTER TO ARRAY OF cl_program;
  Pcl_kernel*         = POINTER TO ARRAY OF cl_kernel;
  Pcl_event*          = POINTER TO ARRAY OF cl_event;
  Pcl_sampler*        = POINTER TO ARRAY OF cl_sampler;

  cl_bool* = cl_uint; (*  WARNING!  Unlike cl_ types in cl_platform.h, cl_bool is not guaranteed to be the same size as the bool in kernels. *)
  cl_bitfield*                 = cl_ulong;
  cl_device_type*              = cl_bitfield;
  cl_platform_info*            = cl_uint;
  cl_device_info*              = cl_uint;
  cl_device_address_info*      = cl_bitfield;
  cl_device_fp_config*         = cl_bitfield;
  cl_device_mem_cache_type*    = cl_uint;
  cl_device_local_mem_type*    = cl_uint;
  cl_device_exec_capabilities* = cl_bitfield;
  cl_command_queue_properties* = cl_bitfield;

  cl_context_properties*   = cl_uint;
  cl_context_info*         = cl_uint;
  cl_command_queue_info*   = cl_uint;
  cl_channel_order*        = cl_uint;
  cl_channel_type*         = cl_uint;
  cl_mem_flags*            = cl_bitfield;
  cl_mem_object_type*      = cl_uint;
  cl_mem_info*             = cl_uint;
  cl_image_info*           = cl_uint;
  cl_addressing_mode*      = cl_uint;
  cl_filter_mode*          = cl_uint;
  cl_sampler_info*         = cl_uint;
  cl_map_flags*            = cl_bitfield;
  cl_program_info*         = cl_uint;
  cl_program_build_info*   = cl_uint;
  cl_build_status*         = cl_int;
  cl_kernel_info*            = cl_uint;
  cl_kernel_work_group_info* = cl_uint;
  cl_event_info*             = cl_uint;
  cl_command_type*           = cl_uint;
  cl_profiling_info*         = cl_uint;

  cl_image_format* =  RECORD 
    image_channel_order*     : cl_channel_order;
    image_channel_data_type* : cl_channel_type;
  END ;
  Pcl_image_format*        = POINTER TO ARRAY OF cl_image_format;
 
  Pcl_context_properties*  = POINTER TO ARRAY OF cl_context_properties;
 
CONST
(* Error Codes *)
   SUCCESS* 							=  0;
   DEVICE_NOT_FOUND*					= -1;
   DEVICE_NOT_AVAILABLE*				= -2;
   DEVICE_COMPILER_NOT_AVAILABLE*	= -3;
   MEM_OBJECT_ALLOCATION_FAILURE*	= -4;
   OUT_OF_RESOURCES*					= -5;
   OUT_OF_HOST_MEMORY*				= -6;
   PROFILING_INFO_NOT_AVAILABLE*		= -7;
   MEM_COPY_OVERLAP*					= -8;
   IMAGE_FORMAT_MISMATCH*			= -9;
   IMAGE_FORMAT_NOT_SUPPORTED* 	= -10;
   BUILD_PROGRAM_FAILURE*			= -11;
   MAP_FAILURE*						= -12;

   INVALID_VALUE*						= -30;
   INVALID_DEVICE_TYPE*					= -31;
   INVALID_PLATFORM*					= -32;
   INVALID_DEVICE*                           = -33;
   INVALID_CONTEXT*                          = -34;
   INVALID_QUEUE_PROPERTIES*                 = -35;
   INVALID_COMMAND_QUEUE*                    = -36;
   INVALID_HOST_PTR*                         = -37;
   INVALID_MEM_OBJECT*                       = -38;
  INVALID_IMAGE_FORMAT_DESCRIPTOR*          = -39; 
   INVALID_IMAGE_SIZE*                       = -40;
   INVALID_SAMPLER*                          = -41;
   INVALID_BINARY*                           = -42;
   INVALID_BUILD_OPTIONS*                    = -43;
   INVALID_PROGRAM*                          = -44;
   INVALID_PROGRAM_EXECUTABLE*               = -45;
   INVALID_KERNEL_NAME*                      = -46;
   INVALID_KERNEL_DEFINITION*                = -47;
   INVALID_KERNEL*                           = -48;
   INVALID_ARG_INDEX*                        = -49;
   INVALID_ARG_VALUE*                        = -50;
   INVALID_ARG_SIZE*                         = -51;
   INVALID_KERNEL_ARGS*                      = -52;
   INVALID_WORK_DIMENSION*                   = -53;
   INVALID_WORK_GROUP_SIZE*                  = -54;
   INVALID_WORK_ITEM_SIZE*                   = -55;
   INVALID_GLOBAL_OFFSET*                    = -56;
   INVALID_EVENT_WAIT_LIST*                  = -57;
   INVALID_EVENT*                            = -58;
   INVALID_OPERATION*                        = -59;
   INVALID_GL_OBJECT*                        = -60;
   INVALID_BUFFER_SIZE*                      = -61;
   INVALID_MIP_LEVEL*                        = -62;
   INVALID_GLOBAL_WORK_SIZE*       = -63;
   
(* OpenCL Version *)
   VERSION_1_0*                              = 1;

(* cl_bool *)
   CL_FALSE*                                    = 0;
   CL_TRUE*                                     = 1;

(* cl_platform_info*)
   PLATFORM_PROFILE*                         = 0900H;
   PLATFORM_VERSION*                         = 0901H;
   PLATFORM_NAME*                            = 0902H;
   PLATFORM_VENDOR*                          = 0903H;
   PLATFORM_EXTENSIONS*                      = 0904H;


(* cl_device_type - bitfield*)

CONST
   DEVICE_TYPE_DEFAULT*               = 0;
   DEVICE_TYPE_CPU*                       = 1;
   DEVICE_TYPE_GPU*                       = 2;
   DEVICE_TYPE_ACCELERATOR*      = 3;
   DEVICE_TYPE_ALL*                        = 0FFFFFFFFH;


(* cl_device_info *)
   DEVICE_TYPE*                         = 1000H;  
   DEVICE_VENDOR_ID*                         = 1001H;
   DEVICE_MAX_COMPUTE_UNITS*                 = 1002H;
  DEVICE_MAX_WORK_ITEM_DIMENSIONS*          = 1003H;
   DEVICE_MAX_WORK_GROUP_SIZE*               = 1004H;
   DEVICE_MAX_WORK_ITEM_SIZES*               = 1005H;
  DEVICE_PREFERRED_VECTOR_WIDTH_CHAR*       = 1006H;
  DEVICE_PREFERRED_VECTOR_WIDTH_SHORT*      = 1007H;
  DEVICE_PREFERRED_VECTOR_WIDTH_INT*        = 1008H;
  DEVICE_PREFERRED_VECTOR_WIDTH_LONG*       = 1009H;
  DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT*      = 100AH;
  DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE*     = 100BH;
   DEVICE_MAX_CLOCK_FREQUENCY*               = 100CH;
   DEVICE_ADDRESS_BITS*                      = 100DH;
   DEVICE_MAX_READ_IMAGE_ARGS *              = 100EH;
   DEVICE_MAX_WRITE_IMAGE_ARGS*              = 100FH;
   DEVICE_MAX_MEM_ALLOC_SIZE*                = 1010H;
   DEVICE_IMAGE2D_MAX_WIDTH*                 = 1011H;
   DEVICE_IMAGE2D_MAX_HEIGHT*                = 1012H;
   DEVICE_IMAGE3D_MAX_WIDTH*                 = 1013H;
   DEVICE_IMAGE3D_MAX_HEIGHT*                = 1014H;
   DEVICE_IMAGE3D_MAX_DEPTH*                 = 1015H;
   DEVICE_IMAGE_SUPPORT*                     = 1016H;
   DEVICE_MAX_PARAMETER_SIZE*                = 1017H;
   DEVICE_MAX_SAMPLERS*                      = 1018H;
   DEVICE_MEM_BASE_ADDR_ALIGN*               = 1019H;
  DEVICE_MIN_DATA_TYPE_ALIGN_SIZE*          = 101AH;
   DEVICE_SINGLE_FP_CONFIG*                  = 101BH;
   DEVICE_GLOBAL_MEM_CACHE_TYPE*             = 101CH;
  DEVICE_GLOBAL_MEM_CACHELINE_SIZE*         = 101DH;
   DEVICE_GLOBAL_MEM_CACHE_SIZE*             = 101EH;
   DEVICE_GLOBAL_MEM_SIZE*                   = 101FH;
  DEVICE_MAX_CONSTANT_BUFFER_SIZE*          = 1020H;
   DEVICE_MAX_CONSTANT_ARGS*                 = 1021H;
   DEVICE_LOCAL_MEM_TYPE*               = 1022H; 
   DEVICE_LOCAL_MEM_SIZE*                    = 1023H;
  DEVICE_ERROR_CORRECTION_SUPPORT*          = 1024H;
  DEVICE_PROFILING_TIMER_RESOLUTION*        = 1025H;
   DEVICE_ENDIAN_LITTLE*                     = 1026H;
   DEVICE_AVAILABLE*                         = 1027H;
   DEVICE_COMPILER_AVAILABLE*                = 1028H;
  DEVICE_EXECUTION_CAPABILITIES*            = 1029H;
   DEVICE_QUEUE_PROPERTIES*                  = 102AH;
   DEVICE_NAME*                              = 102BH;
   DEVICE_VENDOR*                            = 102CH;
   DRIVER_VERSION*                           = 102DH;
   DEVICE_PROFILE*                           = 102EH;
   DEVICE_VERSION*                           = 102FH;
   DEVICE_EXTENSIONS*                        = 1030H;
   DEVICE_PLATFORM*                          = 1031H;
   
   DEVICE_OPENCL_C_VERSION*		= 103DH; (* not defined in OpenCL 1.0 *)

(* cl_device_address_info - bitfield *)
   DEVICE_ADDRESS_32_BITS*          = 0;
   DEVICE_ADDRESS_64_BITS*           = 1;

(* cl_device_fp_config - bitfield *)
   FP_DENORM*                             = 0;
   FP_INF_NAN*                               = 1;
   FP_ROUND_TO_NEAREST*          = 2;
   FP_ROUND_TO_ZERO*                = 3;
   FP_ROUND_TO_INF*                    = 4;
   FP_FMA*                                      = 5;

(* cl_device_mem_cache_type *)
   NONE*                                     = 0H;
   READ_ONLY_CACHE *                         = 1H;
   READ_WRITE_CACHE*                         = 2H;

(* cl_device_local_mem_type *)
   LOCAL*                                    = 1H;
   GLOBAL*                                   = 2H;

(* cl_device_exec_capabilities - bitfield *)
   EXEC_KERNEL*                              = 0;
   EXEC_NATIVE_KERNEL*                       = 1;


(* cl_command_queue_properties - bitfield*)
   QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE*      = 0;
   QUEUE_PROFILING_ENABLE*                   = 1;


(* cl_context_info *)
   CONTEXT_REFERENCE_COUNT*                  = 1080H;
   CONTEXT_NUM_DEVICES*                      = 1081H;
   CONTEXT_DEVICES*                          = 1082H;
   CONTEXT_PROPERTIES*                  = 1083H;  
   CONTEXT_PLATFORM*                    = 1084H; 

(* cl_command_queue_info *)
   QUEUE_CONTEXT*                            = 1090H;
   QUEUE_DEVICE*                             = 1091H;
   QUEUE_REFERENCE_COUNT*                    = 1092H;
   QUEUE_PROPERTIES*                         = 1093H;

(* cl_mem_flags - bitfield*)
   MEM_READ_WRITE*                           = 0;
   MEM_WRITE_ONLY*                           = 1;
   MEM_READ_ONLY*                            = 2;
   MEM_USE_HOST_PTR*                         = 3;
   MEM_ALLOC_HOST_PTR*                       = 4;
   MEM_COPY_HOST_PTR*                        = 5;

(* cl_channel_order *)
   R*                                        = 10B0H;
   A*                                        = 10B1H;
   RG*                                       = 10B2H;
   RA*                                       = 10B3H;
   RGB*                                      = 10B4H;
   RGBA*                                     = 10B5H;
   BGRA*                                     = 10B6H;
   ARGB*                                     = 10B7H;
   INTENSITY*                                = 10B8H;
   LUMINANCE*                                = 10B9H;

(* cl_channel_type *)

   SNORM_INT8*                               = 10D0H;
   SNORM_INT16*                              = 10D1H;
   UNORM_INT8*                               = 10D2H;
   UNORM_INT16*                              = 10D3H;
   UNORM_SHORT_565*                          = 10D4H;
   UNORM_SHORT_555*                          = 10D5H;
   UNORM_INT_101010*                         = 10D6H;
   SIGNED_INT8*                              = 10D7H;
   SIGNED_INT16*                             = 10D8H;
   SIGNED_INT32*                             = 10D9H;
   UNSIGNED_INT8*                            = 10DAH;
   UNSIGNED_INT16*                           = 10DBH;
   UNSIGNED_INT32*                           = 10DCH;
   HALF_FLOAT*                               = 10DDH;
   FLOAT*                               = 10DEH; 

(* cl_mem_object_type *)
   MEM_OBJECT_BUFFER*                        = 10F0H;
   MEM_OBJECT_IMAGE2D*                       = 10F1H;
   MEM_OBJECT_IMAGE3D*                       = 10F2H;

(* cl_mem_info *)
   MEM_TYPE*                                 = 1100H;
   MEM_FLAGS*                           = 1101H; 
   MEM_SIZE*                                 = 1102H;
   MEM_HOST_PTR*                             = 1103H;
   MEM_MAP_COUNT*                            = 1104H;
   MEM_REFERENCE_COUNT*                      = 1105H;
   MEM_CONTEXT*                              = 1106H;

(* cl_image_info*)
   IMAGE_FORMAT*                        = 1110H; 
   IMAGE_ELEMENT_SIZE*                       = 1111H;
   IMAGE_ROW_PITCH*                          = 1112H;
   IMAGE_SLICE_PITCH*                        = 1113H;
   IMAGE_WIDTH*                              = 1114H;
   IMAGE_HEIGHT*                             = 1115H;
   IMAGE_DEPTH*                              = 1116H;

(* cl_addressing_mode *)
   ADDRESS_NONE*                             = 1130H;
   ADDRESS_CLAMP_TO_EDGE*                    = 1131H;
   ADDRESS_CLAMP*                            = 1132H;
   ADDRESS_REPEAT*                           = 1133H;

(* cl_filter_mode *)
   FILTER_NEAREST*                           = 1140H;
   FILTER_LINEAR*                            = 1141H;



(* cl_sampler_info *)
   SAMPLER_REFERENCE_COUNT*                  = 1150H;
   SAMPLER_CONTEXT*                          = 1151H;
   SAMPLER_NORMALIZED_COORDS*                = 1152H;
   SAMPLER_ADDRESSING_MODE*                  = 1153H;
   SAMPLER_FILTER_MODE*                      = 1154H;

(* cl_map_flags - bitfield *)
   MAP_READ*                                 = 0;
   MAP_WRITE*                                = 1;

(* cl_program_info *)
   PROGRAM_REFERENCE_COUNT*          = 1160H;
   PROGRAM_CONTEXT*                          = 1161H;
   PROGRAM_NUM_DEVICES*                   = 1162H;
   PROGRAM_DEVICES*                            = 1163H;
   PROGRAM_SOURCE*                            = 1164H;
   PROGRAM_BINARY_SIZES*                    = 1165H;
   PROGRAM_BINARIES*                           = 1166H;

(* cl_program_build_info*)
   PROGRAM_BUILD_STATUS*                    = 1181H;
   PROGRAM_BUILD_OPTIONS*                = 1182H;
   PROGRAM_BUILD_LOG*                        = 1183H;

(* cl_build_status *)
   BUILD_SUCCESS*                            = 0;
   BUILD_NONE*                               = -1;
   BUILD_ERROR*                              = -2;
   BUILD_IN_PROGRESS*                   = -3;

(* cl_kernel_info *)
   KERNEL_FUNCTION_NAME*                     = 1190H;
   KERNEL_NUM_ARGS*                          = 1191H;
   KERNEL_REFERENCE_COUNT*                   = 1192H;
   KERNEL_CONTEXT*                           = 1193H;
   KERNEL_PROGRAM*                           = 1194H;


(* cl_kernel_work_group_info *)
   KERNEL_WORK_GROUP_SIZE*                   = 11B0H;
   KERNEL_COMPILE_WORK_GROUP_SIZE*          = 11B1H;
   KERNEL_LOCAL_MEM_SIZE*                    = 11B2H;

(* cl_event_info *)
   EVENT_COMMAND_QUEUE*                      = 11D0H;
   EVENT_COMMAND_TYPE*                       = 11D1H;
   EVENT_REFERENCE_COUNT*                    = 11D2H;
   EVENT_COMMAND_EXECUTION_STATUS*           = 11D3H;

(* cl_command_type *)
   COMMAND_NDRANGE_KERNEL*                   = 11F0H;
   COMMAND_TASK*                             = 11F1H;
   COMMAND_NATIVE_KERNEL*                    = 11F2H;
   COMMAND_READ_BUFFER*                      = 11F3H;
   COMMAND_WRITE_BUFFER*                     = 11F4H;
   COMMAND_COPY_BUFFER*                      = 11F5H;
   COMMAND_READ_IMAGE*                       = 11F6H;
   COMMAND_WRITE_IMAGE*                      = 11F7H;
   COMMAND_COPY_IMAGE*                       = 11F8H;
   COMMAND_COPY_IMAGE_TO_BUFFER*             = 11F9H;
   COMMAND_COPY_BUFFER_TO_IMAGE*             = 11FAH;
   COMMAND_MAP_BUFFER*                       = 11FBH;
   COMMAND_MAP_IMAGE*                        = 11FCH;
   COMMAND_UNMAP_MEM_OBJECT*                 = 11FDH;
   COMMAND_MARKER*                           = 11FEH;
   COMMAND_WAIT_FOR_EVENTS*                  = 11FFH;
   COMMAND_BARRIER*                          = 1200H;
   COMMAND_ACQUIRE_GL_OBJECTS*               = 1201H;
   COMMAND_RELEASE_GL_OBJECTS*               = 1202H;

(* command execution status *)
   COMPLETE*                                 = 0H;
   RUNNING*                                  = 1H;
   SUBMITTED*                                = 2H;
   QUEUED*                                   = 3H;

(* cl_profiling_info *)
   PROFILING_COMMAND_QUEUED*                 = 1280H;
   PROFILING_COMMAND_SUBMIT*                 = 1281H;
   PROFILING_COMMAND_START*                  = 1282H;
   PROFILING_COMMAND_END*                    = 1283H;

(* ************************************************************************** *)
(* ************************************************************************** *)
 (* EXTENSIONS, cl_ext.h *)
 
(* cl_khr_fp64 extension - no extension #define since it has no functions  *)
CONST
	 DEVICE_DOUBLE_FP_CONFIG* =1032H;
	 
(* cl_khr_fp16 extension - no extension #define since it has no functions  *)
	DEVICE_HALF_FP_CONFIG* =          1033H;


(* cl_khr_icd extension *)
	cl_khr_icd* = 1;

(* cl_platform_info    *)
	PLATFORM_ICD_SUFFIX_KHR* =       0920H;

(* Additional Error Codes  *)
	PLATFORM_NOT_FOUND_KHR* =  -1001;

(* cl_nv_device_attribute_query extension - no extension #define since it has no functions *)
DEVICE_COMPUTE_CAPABILITY_MAJOR_NV* =  	     4000H;
DEVICE_COMPUTE_CAPABILITY_MINOR_NV* =        4001H;
DEVICE_REGISTERS_PER_BLOCK_NV* =       	      4002H;
DEVICE_WARP_SIZE_NV* =                 			      4003H;
DEVICE_GPU_OVERLAP_NV* =                		     4004H;
DEVICE_KERNEL_EXEC_TIMEOUT_NV* =        		4005H;
DEVICE_INTEGRATED_MEMORY_NV* =          	     4006H;

VAR

	clIcdGetPlatformIDsKHR-: PROCEDURE {C}  (num_entries: cl_uint ; platforms: cl_platform_id; num_platforms : ADDRESS): cl_int;

(* ************************************************************************** *)

(* ************************************************************************** *)


 VAR
 
  (* Platform APIs *)

clGetPlatformIDs- : PROCEDURE {C} (  num_entries   : cl_uint;     platforms     : ADDRESS;   num_platforms : ADDRESS): cl_int; 
clGetPlatformInfo- :  PROCEDURE {C} ( iplatform : cl_platform_id;  param_name : cl_platform_info;  value_size : csize_t;  value  : ADDRESS;  size_ret : ADDRESS (* csize_t *)  ): cl_int; 

(*  Device APIs *)
clGetDeviceIDs- : PROCEDURE {C} ( iplatform :  cl_platform_id ; device_type: cl_device_type; num_entries: cl_uint; devices : ADDRESS;    num_devices :  ADDRESS): cl_int; 
clGetDeviceInfo- : PROCEDURE {C} (device: cl_device_id; param_name: cl_device_info; value_size: csize_t; value: ADDRESS; size_ret : ADDRESS (* csize_t *)): cl_int;

(*  Context APIs *)
TYPE
  TContextNotify* = PROCEDURE {C} (name: PChar; data: ADDRESS; size: csize_t; data2: ADDRESS); 



VAR
clCreateContext- : PROCEDURE {C}(  properties : ADDRESS (*Pcl_context_properties*) ; num_devices  : cl_uint;  devices : ADDRESS;  notify : TContextNotify; user_data: ADDRESS; VAR errcode_ret :  cl_int): cl_context;

clCreateContextFromType- : PROCEDURE {C} (
  properties      : ADDRESS; (*Pcl_context_properties *)
  device_type     : cl_device_type;
  notify          : TContextNotify;
  user_data       : ADDRESS;
  VAR errcode_ret :  cl_int
  ): cl_context;

clRetainContext - : PROCEDURE {C} (context: cl_context): cl_int;

 clReleaseContext - : PROCEDURE {C} (context: cl_context): cl_int;

 clGetContextInfo- : PROCEDURE {C}(
  context       : cl_context;
  param_name    : cl_context_info;
  value_size    : csize_t;
  value         : ADDRESS;
  size_ret  : ADDRESS (* csize_t *)
  ): cl_int;

(*  Command Queue APIs *)
clCreateCommandQueue- : PROCEDURE {C}( context : cl_context;  device : cl_device_id;  properties : cl_command_queue_properties;  VAR errcode_ret:  cl_int ): cl_command_queue;

clRetainCommandQueue- : PROCEDURE {C} (command_queue : cl_command_queue): cl_int; 
clReleaseCommandQueue- : PROCEDURE {C} (command_queue : cl_command_queue): cl_int; 

clGetCommandQueueInfo- : PROCEDURE {C}(
  command_queue: cl_command_queue;
  param_name   : cl_command_queue_info;
  value_size   : csize_t;
  value        : ADDRESS;
  size_ret : ADDRESS (* csize_t *)
  ): cl_int;

clSetCommandQueueProperty- : PROCEDURE {C}(
  command_queue       : cl_command_queue;
  properties          : cl_command_queue_properties;
  enable              : cl_bool;
  VAR old_properties  : cl_command_queue_properties
  ): cl_int; 



(*  Memory Object APIs *)
 clCreateBuffer- : PROCEDURE {C}(context : cl_context;  flags : cl_mem_flags; size : csize_t; host_ptr : ADDRESS; VAR errcode_ret	: cl_int ): cl_mem; 

clCreateImage2D- : PROCEDURE {C}(
  context         : cl_context;
  flags   	      : cl_mem_flags;
  CONST image_format    : cl_image_format; 
  image_width     : csize_t;
  image_height    : csize_t;
  image_row_pitch : csize_t;
  host_ptr        : ADDRESS;
   VAR errcode_ret		: cl_int 
  ): cl_mem; 

clCreateImage3D- : PROCEDURE {C}(
  context 			    : cl_context;
  flags 			      : cl_mem_flags;
  CONST image_format      : cl_image_format;
  image_width 	    : csize_t;
  image_height      : csize_t;
  image_depth 	    : csize_t;
  image_row_pitch 	: csize_t;
  image_slice_pitch : csize_t;
  host_ptr 		      : ADDRESS;
   VAR errcode_ret		: cl_int 
  ): cl_mem;

clRetainMemObject- : PROCEDURE {C} (memobj: cl_mem): cl_int; 

clReleaseMemObject- : PROCEDURE {C} (memobj: cl_mem): cl_int; 

clGetSupportedImageFormats- : PROCEDURE {C}(
  context		    	: cl_context;
  flags 			    : cl_mem_flags;
  image_type 		  : cl_mem_object_type;
  num_entries 		: cl_uint;
  image_formats   : ADDRESS; (* Pcl_image_format *)
   num_formats : ADDRESS
  ): cl_int;

 clGetMemObjectInfo- : PROCEDURE {C} (
  memobj      	: cl_mem;
  param_name    : cl_mem_info;
  value_size    : csize_t;
  value     	  : ADDRESS;
   size_ret  : ADDRESS (* csize_t *)
  ): cl_int;

clGetImageInfo- : PROCEDURE {C}(
  image         : cl_mem;
  param_name    : cl_image_info;
  value_size    : csize_t;
  value         : ADDRESS;
   size_ret  : ADDRESS (* csize_t *)
  ): cl_int; 

(*  Sampler APIs *)
clCreateSampler- : PROCEDURE {C} (
  context         : cl_context;
  is_norm_coords  : cl_bool;
  addr_mode       : cl_addressing_mode;
  filter_mode     : cl_filter_mode;
   VAR errcode_ret :  cl_int
  ): cl_sampler; 

clRetainSampler- : PROCEDURE {C} (sampler: cl_sampler): cl_int;

 clReleaseSampler- : PROCEDURE {C} (sampler: cl_sampler): cl_int;

 clGetSamplerInfo- : PROCEDURE {C}(
  sampler      : cl_sampler;
  param_name   : cl_sampler_info;
  value_size   : csize_t;
  value        : ADDRESS;
   size_ret : ADDRESS (* csize_t *)
  ): cl_int;


(*  Program Object APIs *)
clCreateProgramWithSource- : PROCEDURE {C}( context  : cl_context;  count  : cl_uint; strings : ADDRESS; lengths  : ADDRESS (*Pcsize_t*);   VAR errcode_ret :  cl_int  ): cl_program; 

TYPE
  PByte = POINTER TO ARRAY OF CHAR;
  PPByte* = POINTER TO ARRAY OF PByte; (* ^PByte; *)

VAR

clCreateProgramWithBinary- : PROCEDURE {C} (
  context     : cl_context;
  num_devices : cl_uint;
  device_list : ADDRESS; (*Pcl_device_id *)
  lengths     : ADDRESS; (*Pcsize_t *)
  binaries    : ADDRESS; (*PPByte *)
  binary_status: ADDRESS; (* cl_int *)
  VAR errcode_ret: cl_int
  ): cl_program;

clRetainProgram- : PROCEDURE {C} (iprogram: cl_program): cl_int;

clReleaseProgram- : PROCEDURE {C} (iprogram: cl_program): cl_int; 

TYPE
  TProgramNotify* =  PROCEDURE {C} (iprogram: cl_program; user_data: ADDRESS);

(* extern   cl_int *)

VAR

clBuildProgram- : PROCEDURE {C} (iprogram: cl_program; num_devices:  cl_uint; CONST device_list: Pcl_device_id; CONST options: ARRAY OF CHAR; notify: ADDRESS (*TProgramNotify*);  user_data: ADDRESS ): cl_int;


clUnloadCompiler- : PROCEDURE {C}(): cl_int;

clGetProgramInfo- : PROCEDURE {C} (
  iprogram : cl_program; 
  param_name: cl_program_info; 
  value_size: csize_t;
  value         : ADDRESS;
   size_ret  : ADDRESS (* csize_t *)
  ): cl_int;

clGetProgramBuildInfo- : PROCEDURE {C} (
  iprogram      : cl_program;
  device        : cl_device_id;
  param_name    : cl_program_build_info;
  value_size    : csize_t;
  value         : ADDRESS;
   size_ret  : ADDRESS (* csize_t *)
  ): cl_int; 

(*  Kernel Object APIs *)
clCreateKernel- : PROCEDURE {C}(iprogram: cl_program;   CONST kernel_name: ARRAY OF CHAR;   VAR  errcode_ret: cl_int ): cl_kernel; 

clCreateKernelsInProgram- : PROCEDURE {C} (
  iprogram      : cl_program;
  num_kernels   : cl_uint;
  kernels       : ADDRESS; (*Pcl_kernel *)
  num_ret   : ADDRESS (* cl_uint *)
  ): cl_int; 

 clRetainKernel- : PROCEDURE {C} (kernel: cl_kernel): cl_int;

clReleaseKernel- : PROCEDURE {C} (kernel: cl_kernel): cl_int;

 clSetKernelArg- : PROCEDURE {C} (
  kernel    : cl_kernel;
  arg_index : cl_uint;
  arg_size  : csize_t;
  arg_value : ADDRESS
  ): cl_int;

clGetKernelInfo- : PROCEDURE {C} (
  kernel        : cl_kernel;
  param_name    : cl_kernel_info;
  value_size    : csize_t;
  value         : ADDRESS;
  size_ret  : ADDRESS (* csize_t *)
  ): cl_int;

clGetKernelWorkGroupInfo- : PROCEDURE {C}(kernel: cl_kernel; device: cl_device_id; param_name: cl_kernel_work_group_info; value_size: csize_t; value: ADDRESS; size_ret : ADDRESS ): cl_int; 

(*  Event Object APIs *)
clWaitForEvents- : PROCEDURE {C} (
  num_events  : cl_uint;
  event_list  : ADDRESS
  ): cl_int; 

 clGetEventInfo- : PROCEDURE {C} (
  event         : cl_event;
  param_name    : cl_event_info;
  value_size    : csize_t;
  value         : ADDRESS;
  size_ret  : ADDRESS (* csize_t *)
  ): cl_int; 

clRetainEvent- : PROCEDURE {C} (event: cl_event): cl_int; 

clReleaseEvent- : PROCEDURE {C} (event: cl_event): cl_int;

(*  Profiling APIs *)
clGetEventProfilingInfo - : PROCEDURE {C} (
  event         : cl_event;
  param_name    : cl_profiling_info;
  value_size    : csize_t;
  value         : ADDRESS;
  size_ret  : ADDRESS (* csize_t *)
  ): cl_int; 

(*  Flush and Finish APIs *)
 clFlush - : PROCEDURE {C} (command_queue: cl_command_queue): cl_int;

 clFinish- : PROCEDURE {C} (command_queue: cl_command_queue): cl_int; 

  (*  Enqueued Commands APIs *)
clEnqueueReadBuffer- : PROCEDURE {C} (
  command_queue : cl_command_queue;
  buffer        : cl_mem;
  blocking_read : cl_bool;
  offset        : csize_t;
  cb            : csize_t;
  ptr           : ADDRESS;
  num_events    : cl_uint;
  events_list   :ADDRESS ;
  event         : ADDRESS
  ): cl_int; 

clEnqueueWriteBuffer - : PROCEDURE {C} ( command_queue: cl_command_queue; buffer : cl_mem;  blocking_write : cl_bool; offset : csize_t;
  cb              : csize_t;
  ptr             : ADDRESS;
  num_events      : cl_uint;
  events_list     : ADDRESS;
  event           : ADDRESS
  ): cl_int;

clEnqueueCopyBuffer- : PROCEDURE {C} (
  command_queue : cl_command_queue;
  src_buffer    : cl_mem;
  dst_buffer    : cl_mem;
  src_offset    : csize_t;
  dst_offset    : csize_t;
  cb            : csize_t;
  num_events    : cl_uint;
  events_list   : ADDRESS; (*Pcl_event*)
  event         : ADDRESS (*Pcl_event *)
  ): cl_int;

clEnqueueReadImage - : PROCEDURE {C} (
  command_queue : cl_command_queue;
  image         : cl_mem;
  blocking_read : cl_bool;
  origin        : ADDRESS;
  region        : ADDRESS;
  row_pitch     : csize_t;
  slice_pitch   : csize_t;
  ptr           : ADDRESS;
  num_events    : cl_uint;
  events_list   : ADDRESS; (*Pcl_event; *)
  event         : ADDRESS (*Pcl_event*)
  ): cl_int; 

clEnqueueWriteImage - : PROCEDURE {C} (
  command_queue   : cl_command_queue;
  image           : cl_mem;
  blocking_write  : cl_bool;
  origin          : ADDRESS;
  region          : ADDRESS;
  row_pitch       : csize_t;
  slice_pitch     : csize_t;
  ptr             : ADDRESS;
  num_events      : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
  ): cl_int; 

clEnqueueCopyImage- : PROCEDURE {C} (
  command_queue : cl_command_queue;
  src_image     : cl_mem;
  dst_image     : cl_mem;
  src_origin    : ADDRESS;
  dst_origin    : ADDRESS;
  region        : ADDRESS;
  num_events    : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
  ): cl_int;

clEnqueueCopyImageToBuffer- : PROCEDURE {C} (
  command_queue : cl_command_queue;
  src_image     : cl_mem;
  dst_buffre    : cl_mem;
  src_origin    : ADDRESS;
  region        : ADDRESS;
  dst_offset    : csize_t;
  num_events    : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
  ): cl_int; 

clEnqueueCopyBufferToImage- : PROCEDURE {C}(
 command_queue : cl_command_queue;
  src_buffer    : cl_mem;
  dst_image     : cl_mem;
  src_offset    : csize_t;
  dst_origin    : ADDRESS;
  region        : ADDRESS;
  num_events    : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
  ): cl_int;

clEnqueueMapBuffer- : PROCEDURE {C}(
  command_queue   : cl_command_queue;
  buffer          : cl_mem;
  blocking_map    : cl_bool;
  map_flags       : cl_map_flags;
  offset          : csize_t;
  cb              : csize_t;
  num_events      : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS; (*Pcl_event*)
   VAR errcode_ret		: cl_int 
  ): ADDRESS;

clEnqueueMapImage- : PROCEDURE {C}(
  command_queue   : cl_command_queue;
  image           : cl_mem;
  blocking_map    : cl_bool;
  map_flags       : cl_map_flags;
  origin          : ADDRESS;
  region          : ADDRESS;
  row_pitch       : csize_t;
  slice_pitch     : csize_t;
  num_events      : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS; (*Pcl_event*)
   VAR errcode_ret		: cl_int 
  ): ADDRESS; 

clEnqueueUnmapMemObject- : PROCEDURE {C}(
  command_queue : cl_command_queue;
  memobj        : cl_mem;
  mapped_ptr    : ADDRESS;
  num_events    : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
   ): cl_int; 

clEnqueueNDRangeKernel- : PROCEDURE {C}(
  command_queue : cl_command_queue;
  kernel        : cl_kernel;
  work_dim      : cl_uint;
  global_offset,
  global_size,
  local_size    : ADDRESS;
  num_events    : cl_uint;
  events_list   : ADDRESS;
  event         : ADDRESS
  ): cl_int;

clEnqueueTask- : PROCEDURE {C}(
  command_queue : cl_command_queue;
  kernel        : cl_kernel;
  num_events    : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
  ): cl_int; 

TYPE
  TEnqueueUserProc* =  PROCEDURE {C} (userdata: ADDRESS);

VAR
 clEnqueueNativeKernel- : PROCEDURE {C} (
  command_queue   : cl_command_queue;
  user_func       : TEnqueueUserProc;
  args            : ADDRESS;
  cb_args         : csize_t;
  num_mem_objects : cl_uint;
  mem_list        : ADDRESS; (*Pcl_mem *)
  args_mem_loc    : ADDRESS;
  num_events      : cl_uint;
  events_list     : ADDRESS; (*Pcl_event;*)
  event           : ADDRESS (*Pcl_event*)
   ): cl_int;

clEnqueueMarker- : PROCEDURE {C} (command_queue: cl_command_queue; event: ADDRESS ): cl_int;
clEnqueueWaitForEvents- : PROCEDURE {C} (command_queue: cl_command_queue; num_events: cl_uint; event_list: ADDRESS ): cl_int;
clEnqueueBarrier- : PROCEDURE {C} (command_queue: cl_command_queue): cl_int;


PROCEDURE InitLibrary;
BEGIN {EXCLUSIVE}
		(* load the DLL *)	
	lib := Unix.Dlopen(libname,2);
	ASSERT(lib # 0, 100);

				(* Platform APIs *)
				Unix.Dlsym(lib, "clGetPlatformIDs", S.VAL(ADDRESS, clGetPlatformIDs));
				Unix.Dlsym(lib, "clGetPlatformInfo", S.VAL(ADDRESS, clGetPlatformInfo));
				
				(*  Device APIs *)								
				Unix.Dlsym(lib, "clGetDeviceIDs", S.VAL(ADDRESS, clGetDeviceIDs));
				Unix.Dlsym(lib, "clGetDeviceInfo", S.VAL(ADDRESS, clGetDeviceInfo));
				
				(*  Context APIs *)
				Unix.Dlsym(lib, "clCreateContext", S.VAL(ADDRESS, clCreateContext));
				Unix.Dlsym(lib, "clCreateContextFromType", S.VAL(ADDRESS, clCreateContextFromType));
				Unix.Dlsym(lib, "clRetainContext", S.VAL(ADDRESS, clRetainContext));
				Unix.Dlsym(lib, "clReleaseContext", S.VAL(ADDRESS, clReleaseContext));
				Unix.Dlsym(lib, "clGetContextInfo", S.VAL(ADDRESS, clGetContextInfo));
				
				(*  Command Queue APIs *)
				Unix.Dlsym(lib, "clCreateCommandQueue", S.VAL(ADDRESS, clCreateCommandQueue));
				Unix.Dlsym(lib, "clRetainCommandQueue", S.VAL(ADDRESS, clRetainCommandQueue));
				Unix.Dlsym(lib, "clReleaseCommandQueue", S.VAL(ADDRESS, clReleaseCommandQueue));
				Unix.Dlsym(lib, "clGetCommandQueueInfo", S.VAL(ADDRESS, clGetCommandQueueInfo));
				Unix.Dlsym(lib, "clSetCommandQueueProperty", S.VAL(ADDRESS, clSetCommandQueueProperty));
				
				(*  Memory Object APIs *)
				Unix.Dlsym(lib, "clCreateBuffer", S.VAL(ADDRESS, clCreateBuffer));
				Unix.Dlsym(lib, "clCreateImage2D", S.VAL(ADDRESS, clCreateImage2D));
				Unix.Dlsym(lib, "clCreateImage3D", S.VAL(ADDRESS, clCreateImage3D));
				Unix.Dlsym(lib, "clRetainMemObject", S.VAL(ADDRESS, clRetainMemObject));
				Unix.Dlsym(lib, "clReleaseMemObject", S.VAL(ADDRESS, clReleaseMemObject));
				Unix.Dlsym(lib, "clGetSupportedImageFormats", S.VAL(ADDRESS, clGetSupportedImageFormats));
				Unix.Dlsym(lib, "clGetMemObjectInfo", S.VAL(ADDRESS, clGetMemObjectInfo));
				Unix.Dlsym(lib, "clGetImageInfo", S.VAL(ADDRESS, clGetImageInfo));
				
				(*  Sampler APIs *)
				Unix.Dlsym(lib, "clCreateSampler", S.VAL(ADDRESS, clCreateSampler));
				Unix.Dlsym(lib, "clRetainSampler", S.VAL(ADDRESS, clRetainSampler));
				Unix.Dlsym(lib, "clReleaseSampler", S.VAL(ADDRESS, clReleaseSampler));
				Unix.Dlsym(lib, "clGetSamplerInfo", S.VAL(ADDRESS, clGetSamplerInfo));
				
				(*  Program Object APIs *)
				Unix.Dlsym(lib, "clCreateProgramWithSource", S.VAL(ADDRESS, clCreateProgramWithSource));
				Unix.Dlsym(lib, "clCreateProgramWithBinary", S.VAL(ADDRESS, clCreateProgramWithBinary));
				Unix.Dlsym(lib, "clRetainProgram", S.VAL(ADDRESS, clRetainProgram));
				Unix.Dlsym(lib, "clReleaseProgram", S.VAL(ADDRESS, clReleaseProgram));
				Unix.Dlsym(lib, "clBuildProgram", S.VAL(ADDRESS, clBuildProgram));
				Unix.Dlsym(lib, "clUnloadCompiler", S.VAL(ADDRESS, clUnloadCompiler));
				Unix.Dlsym(lib, "clGetProgramInfo", S.VAL(ADDRESS, clGetProgramInfo));
				Unix.Dlsym(lib, "clGetProgramBuildInfo", S.VAL(ADDRESS, clGetProgramBuildInfo));
				
				(*  Kernel Object APIs *)
				Unix.Dlsym(lib, "clCreateKernel", S.VAL(ADDRESS, clCreateKernel));
				Unix.Dlsym(lib, "clCreateKernelsInProgram", S.VAL(ADDRESS, clCreateKernelsInProgram));
				Unix.Dlsym(lib, "clRetainKernel", S.VAL(ADDRESS, clRetainKernel));
				Unix.Dlsym(lib, "clReleaseKernel", S.VAL(ADDRESS, clReleaseKernel));
				Unix.Dlsym(lib, "clSetKernelArg", S.VAL(ADDRESS, clSetKernelArg));
				Unix.Dlsym(lib, "clGetKernelInfo", S.VAL(ADDRESS, clGetKernelInfo));
				Unix.Dlsym(lib, "clGetKernelWorkGroupInfo", S.VAL(ADDRESS, clGetKernelWorkGroupInfo));
				
				(*  Event Object APIs *)
				Unix.Dlsym(lib, "clWaitForEvents", S.VAL(ADDRESS, clWaitForEvents));
				Unix.Dlsym(lib, "clGetEventInfo", S.VAL(ADDRESS, clGetEventInfo));	
				Unix.Dlsym(lib, "clRetainEvent", S.VAL(ADDRESS, clRetainEvent));
				Unix.Dlsym(lib, "clReleaseEvent", S.VAL(ADDRESS, clReleaseEvent));
				
				(*  Profiling APIs *)
				Unix.Dlsym(lib, "clGetEventProfilingInfo", S.VAL(ADDRESS, clGetEventProfilingInfo));
				
				(*  Flush and Finish APIs *)
				Unix.Dlsym(lib, "clFlush", S.VAL(ADDRESS, clFlush));
				Unix.Dlsym(lib, "clFinish", S.VAL(ADDRESS, clFinish));
				
				 (*  Enqueued Commands APIs *)
  				Unix.Dlsym(lib, "clEnqueueReadBuffer", S.VAL(ADDRESS, clEnqueueReadBuffer));
				Unix.Dlsym(lib, "clEnqueueWriteBuffer", S.VAL(ADDRESS, clEnqueueWriteBuffer));
				Unix.Dlsym(lib, "clEnqueueCopyBuffer", S.VAL(ADDRESS, clEnqueueCopyBuffer));
				Unix.Dlsym(lib, "clEnqueueReadImage", S.VAL(ADDRESS, clEnqueueReadImage));
				Unix.Dlsym(lib, "clEnqueueWriteImage", S.VAL(ADDRESS, clEnqueueWriteImage));	
				Unix.Dlsym(lib, "clEnqueueCopyImage", S.VAL(ADDRESS, clEnqueueCopyImage));
				Unix.Dlsym(lib, "clEnqueueCopyImageToBuffer", S.VAL(ADDRESS, clEnqueueCopyImageToBuffer));
				Unix.Dlsym(lib, "clEnqueueCopyBufferToImage", S.VAL(ADDRESS, clEnqueueCopyBufferToImage));
				Unix.Dlsym(lib, "clEnqueueMapBuffer", S.VAL(ADDRESS, clEnqueueMapBuffer));
				Unix.Dlsym(lib, "clEnqueueMapImage", S.VAL(ADDRESS, clEnqueueMapImage));
				Unix.Dlsym(lib, "clEnqueueUnmapMemObject", S.VAL(ADDRESS, clEnqueueUnmapMemObject));
				Unix.Dlsym(lib, "clEnqueueNDRangeKernel", S.VAL(ADDRESS, clEnqueueNDRangeKernel));	
				Unix.Dlsym(lib, "clEnqueueTask", S.VAL(ADDRESS, clEnqueueTask));
				Unix.Dlsym(lib, "clEnqueueNativeKernel", S.VAL(ADDRESS, clEnqueueNativeKernel));
				Unix.Dlsym(lib, "clEnqueueMarker", S.VAL(ADDRESS, clEnqueueMarker));
				Unix.Dlsym(lib, "clEnqueueWaitForEvents", S.VAL(ADDRESS, clEnqueueWaitForEvents));
				Unix.Dlsym(lib, "clEnqueueBarrier", S.VAL(ADDRESS, clEnqueueBarrier));			
				
				Trace.String(libname); Trace.StringLn(" loaded."); 
END InitLibrary;

PROCEDURE OnClose;
BEGIN 
 IF lib # 0 THEN
       Unix.Dlclose(lib);
       Trace.String(libname); Trace.StringLn(" unloaded."); 
END;	 
END OnClose;

BEGIN
  InitLibrary;
 Modules.InstallTermHandler(OnClose)  

END OpenCL.

