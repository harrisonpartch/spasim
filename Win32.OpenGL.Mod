MODULE OpenGL; (** AUTHOR "fnecati"; PURPOSE "OpenGL binding for WinAos"; *)

IMPORT SYSTEM, Kernel32, Modules,  WinApi, Strings, GLC := OpenGLConst, KernelLog;

(*
	Compiler.Compile OpenGLConst.Mod Win32.WinApi.Mod Win32.OpenGL.Mod  ~

==============================================================================
	OpenGL 4.5 - Header translation
	Date : 30.09.2016
	Works with : WinAos
==============================================================================
*)


VAR
	(* handle to library *)
 	libHandle-: Kernel32.HMODULE;

CONST
	debug = FALSE; (* used in ReadImplementationProperties, when extension is not available *)
	libName  = 'opengl32.dll';

TYPE

	AnsiChar* = POINTER TO ARRAY OF CHAR;
 	PAnsiChar* = ADDRESS;

	(* GL data types *)
	Enum* = LONGINT; 	(* 4 bytes *)
	Boolean* = UNSIGNED8; 	(*  *)
	Bitfield* = SET32; 	(* SET *)
	Byte* = SHORTINT; 		(* 1 byte signed *)
	Short* = INTEGER; 	(* 2 bytes signed *)
	Int* = LONGINT; 	(* 4 bytes signed *)
	Sizei* = LONGINT; 	(* 4 bytes signed	 SIZE ??? *)
	Ubyte* = UNSIGNED8; 		(* 1 byte unsigned *)
	Ushort* = UNSIGNED16;	(* 2 bytes unsigned *)
	Uint* = WORD;	(* 4 bytes unsigned *)
	Float* = REAL;		(* single precision real *)
	Clampf* = REAL;		(* single precision real in [0,1] *)
	Double* = LONGREAL;	(* double precision real *)
	Clampd* = LONGREAL;	(* double precision real in [0,1] *)
	Void* = ADDRESS;
	Int64* = HUGEINT;
	Uint64* = UNSIGNED64;

	PBoolean* = ADDRESS; 	(* POINTER TO ARRAY OF Boolean; *)
	PByte* = ADDRESS; 	(* POINTER TO ARRAY OF Byte; *)
	PShort* = ADDRESS; 	(* POINTER TO ARRAY OF Short; *)
	PInt* =  ADDRESS; 	(* POINTER TO ARRAY OF Int; *)
	PSizei* = ADDRESS; 	(* POINTER TO ARRAY OF Sizei; *)
	PUbyte* = ADDRESS; 	(* POINTER TO ARRAY OF Ubyte; *)
	PUshort* = ADDRESS; 	(* POINTER TO ARRAY OF Ushort; *)
	PUint* = ADDRESS; 	(* POINTER TO ARRAY OF Uint; *)
	PClampf* = ADDRESS; 	(* POINTER TO ARRAY OF Clampf; *)
	PFloat* =  ADDRESS; 	(* POINTER TO ARRAY OF Float; *)
	PDouble* = ADDRESS; 	(* POINTER TO ARRAY OF Double; *)
	PClampd* = ADDRESS; 	(* POINTER TO ARRAY OF Clampd; *)
	PEnum* =  ADDRESS; 	(* POINTER TO ARRAY OF Enum *);
	PVoid* = Void; 			(* POINTER TO ARRAY OF Void; *)
	PPVoid* = ADDRESS; 	(* POINTER TO ARRAY OF PVoid; *)
	PInt64* =  ADDRESS; 	(* POINTER TO ARRAY OF Int64; *)
	PUint64* = ADDRESS; 	(* POINTER TO ARRAY OF Uint64; *)

	(* GL_NV_half_float *)
	HalfNV* = Ushort;
	PHalfNV* = ADDRESS; (* POINTER TO ARRAY OF HalfNV; *)

	(* GL_ARB_shader_objects  *)
	PHandleARB* = ADDRESS ;
	CharARB* = AnsiChar;
	PCharARB* = PAnsiChar;
	PPCharARB* =  ADDRESS; (* POINTER TO ARRAY OF PCharARB; *)

	(* GL_VERSION_1_5 *)
	Intptr* = Int;
	Sizeiptr* = Sizei;
	PIntptr* = ADDRESS;

	(* GL_ARB_vertex_buffer_object *)
	IntptrARB* = Int;
	SizeiptrARB* = Sizei;

	(* GL_VERSION_2_0 *)
	Handle* = Uint;
	PChar* = PAnsiChar;
	PPChar* = ADDRESS; (* POINTER TO ARRAY OF PChar *)

	(* GL_EXT_timer_query *)
	Int64EXT* = Int64;
	PInt64EXT* = ADDRESS; (* POINTER TO ARRAY OF Int64EXT *)

	Uint64EXT* = Uint64;
	PUint64EXT* = ADDRESS; (* POINTER TO ARRAY OF Uint64EXT *)

	(* ARB_sync *)
	GLsync* = ADDRESS;

	(* GL_ARB_cl_event  *)
	(* These incomplete types let us declare types compatible with OpenCL's cl_context and cl_event *)
	cl_context* = ADDRESS;
	cl_event* = ADDRESS;

	(* GL_ARB_compute_variable_group_size *)
	TglDispatchComputeGroupSizeARB* = PROCEDURE{WINAPI}(num_groups_x: Uint; num_groups_y: Uint; num_groups_z: Uint; group_size_x: Uint; group_size_y: Uint; group_size_z: Uint);

	(* GL_ARB_debug_output  *)
	TglDebugProcARB* = PROCEDURE{WINAPI}(source: Enum; xtype: Enum; id: Uint; severity: Enum; length: Sizei;  xmessage: PChar; userParam: PVoid);

	(* GL_AMD_debug_output  *)
	TglDebugProcAMD* = PROCEDURE{WINAPI}(id: Uint; category: Enum; severity: Enum; length: Sizei; xmessage: PChar; userParam: PVoid);

	(*! (4.3) GL_KHR_debug  *)
	TglDebugProc* = PROCEDURE{WINAPI}(source : Enum; xtype : Enum; id : Uint; severity : Uint; length : Sizei; xmessage: PChar; userParam : PVoid);

	(* GL_NV_vdpau_interop  *)
	GLvdpauSurfaceNV* = Intptr;
	PGLvdpauSurfaceNV* =  ADDRESS; (*POINTER TO ARRAY OF GLvdpauSurfaceNV; *)

	(*! WGL - WINDOWS  *)
	HDC* = Kernel32.HANDLE;
	HGLRC* = Kernel32.HANDLE;

	TRect* = RECORD
		Left*, Top*, Right*, Bottom*: LONGINT;
	END;

	PGPU_DEVICE* = POINTER TO GPU_DEVICE;
	GPU_DEVICE* = RECORD
		cb*: Uint;
		DeviceName*: ARRAY 32 OF CHAR;
		DeviceString*: ARRAY 128 OF CHAR;
		Flags*: Uint;
		rcVirtualScreen*: TRect;
	END;
 	THandle * = Uint;

	(*  WGL_ARB_pbuffer *)
	HPBUFFERARB * = THandle;

	(* WGL_EXT_pbuffer*)
	HPBUFFEREXT * = THandle;

	(* WGL_NV_present_video *)
	PHVIDEOOUTPUTDEVICENV * = ADDRESS; (*POINTER TO ARRAY OF HVIDEOOUTPUTDEVICENV;*)
	HVIDEOOUTPUTDEVICENV * = THandle;

	(* WGL_NV_video_output*)
	HPVIDEODEV * = THandle;
	PHPVIDEODEV * =  ADDRESS; (*POINTER TO ARRAY OF HPVIDEODEV;*)
	HPGPUNV * = THandle;
	HGPUNV * = THandle;

	(* WGL_NV_gpu_affinity *)
	PHPGPUNV * = ADDRESS; (*POINTER TO ARRAY OF HPGPUNV;*)
	PHGPUNV * = ADDRESS; (*POINTER TO ARRAY OF HGPUNV;*)

	(* WGL_NV_video_capture *)
	HVIDEOINPUTDEVICENV * = THandle;
	PHVIDEOINPUTDEVICENV * = ADDRESS; (*POINTER TO ARRAY OF HVIDEOINPUTDEVICENV;*)

VAR
	GL_VERSION_1_0* ,
	GL_VERSION_1_1* ,
	GL_VERSION_1_2* ,
	GL_VERSION_1_3* ,
	GL_VERSION_1_4* ,
	GL_VERSION_1_5* ,
	GL_VERSION_2_0* ,
	GL_VERSION_2_1* ,
	GL_VERSION_3_0* ,
	GL_VERSION_3_1* ,
	GL_VERSION_3_2* ,
	GL_VERSION_3_3* ,
	GL_VERSION_4_0* ,
	GL_VERSION_4_1* ,
	GL_VERSION_4_2* ,
	GL_VERSION_4_3* ,
	GL_VERSION_4_4* ,
	GL_VERSION_4_5* ,

	GL_3DFX_multisample*,
	GL_3DFX_tbuffer*,
	GL_3DFX_texture_compression_FXT1*,
	GL_APPLE_client_storage*,
	GL_APPLE_element_array*,
	GL_APPLE_fence*,
	GL_APPLE_specular_vector*,
	GL_APPLE_transform_hint*,
	GL_APPLE_vertex_array_object*,
	GL_APPLE_vertex_array_range*,
	GL_APPLE_ycbcr_422*,
	GL_APPLE_texture_range*,
	GL_APPLE_float_pixels*,
	GL_APPLE_vertex_program_evaluators*,
	GL_APPLE_aux_depth_stencil*,
	GL_APPLE_object_purgeable*,
	GL_APPLE_row_bytes*,
	GL_APPLE_rgb_422*,
	GL_ARB_depth_texture*,
	GL_ARB_fragment_program*,
	GL_ARB_imaging*,
	GL_ARB_matrix_palette*,
	GL_ARB_multisample*,
	GL_ARB_multitexture*,
	GL_ARB_point_parameters*,
	GL_ARB_shadow*,
	GL_ARB_shadow_ambient*,
	GL_ARB_texture_border_clamp*,
	GL_ARB_texture_compression*,
	GL_ARB_texture_cube_map*,
	GL_ARB_texture_env_add*,
	GL_ARB_texture_env_combine*,
	GL_ARB_texture_env_crossbar*,
	GL_ARB_texture_env_dot3*,
	GL_ARB_texture_filter_minmax*,
	GL_ARB_texture_mirrored_repeat*,
	GL_ARB_transpose_matrix*,
	GL_ARB_vertex_blend*,
	GL_ARB_vertex_buffer_object*,
	GL_ARB_vertex_program*,
	GL_ARB_window_pos*,
	GL_ARB_shader_objects*,
	GL_ARB_vertex_shader*,
	GL_ARB_fragment_shader*,
	GL_ARB_fragment_shader_interlock*,
	GL_ARB_shading_language_100*,
	GL_ARB_occlusion_query*,
	GL_ARB_texture_non_power_of_two*,
	GL_ARB_point_sprite*,
	GL_ARB_fragment_program_shadow*,
	GL_ARB_draw_buffers*,
	GL_ARB_texture_rectangle*,
	GL_ARB_color_buffer_float*,
	GL_ARB_half_float_pixel*,
	GL_ARB_texture_float*,
	GL_ARB_pixel_buffer_object*,
	GL_ARB_depth_buffer_float*,
	GL_ARB_draw_instanced*,
	GL_ARB_framebuffer_object*,
	GL_ARB_framebuffer_sRGB*,
	GL_ARB_geometry_shader4*,
	GL_ARB_half_float_vertex*,
	GL_ARB_instanced_arrays*,
	GL_ARB_map_buffer_range*,
	GL_ARB_texture_buffer_object*,
	GL_ARB_texture_compression_rgtc*,
	GL_ARB_texture_rg*,
	GL_ARB_vertex_array_object*,
	GL_ARB_uniform_buffer_object*,
	GL_ARB_compatibility*,
	GL_ARB_copy_buffer*,
	GL_ARB_shader_texture_lod*,
	GL_ARB_shader_viewport_layer_array*,
	GL_ARB_depth_clamp*,
	GL_ARB_draw_elements_base_vertex*,
	GL_ARB_fragment_coord_conventions*,
	GL_ARB_provoking_vertex*,
	GL_ARB_seamless_cube_map*,
	GL_ARB_sync*,
	GL_ARB_texture_multisample*,
	GL_ARB_vertex_array_bgra*,
	GL_ARB_draw_buffers_blend*,
	GL_ARB_sample_shading*,
	GL_ARB_sample_locations*,
	GL_ARB_sparse_texture2*,
	GL_ARB_sparse_texture_clamp*,
	GL_ARB_texture_cube_map_array*,
	GL_ARB_texture_gather*,
	GL_ARB_texture_query_lod*,
	GL_ARB_shading_language_include*,
	GL_ARB_texture_compression_bptc*,
	GL_ARB_blend_func_extended*,
	GL_ARB_explicit_attrib_location*,
	GL_ARB_occlusion_query2*,
	GL_ARB_parallel_shader_compile*,
	GL_ARB_post_depth_coverage*,
	GL_ARB_sampler_objects*,
	GL_ARB_shader_bit_encoding*,
	GL_ARB_shader_clock*,
	GL_ARB_texture_rgb10_a2ui*,
	GL_ARB_texture_swizzle*,
	GL_ARB_timer_query*,
	GL_ARB_vertex_type_2_10_10_10_rev*,
	GL_ARB_draw_indirect*,
	GL_ARB_gpu_shader5*,
	GL_ARB_gpu_shader_fp64*,
	GL_ARB_gpu_shader_int64*,
	GL_ARB_shader_subroutine*,
	GL_ARB_tessellation_shader*,
	GL_ARB_texture_buffer_object_rgb32*,
	GL_ARB_transform_feedback2*,
	GL_ARB_transform_feedback3*,
	GL_ARB_ES2_compatibility*,
	GL_ARB_ES3_2_compatibility*,
	GL_ARB_get_program_binary*,
	GL_ARB_separate_shader_objects*,
	GL_ARB_shader_atomic_counter_ops*,
	GL_ARB_shader_precision*,
	GL_ARB_shader_ballot*,
	GL_ARB_vertex_attrib_64bit*,
	GL_ARB_viewport_array*,
	GL_KHR_no_error*,

	 (* GL 4.2 *)
	GL_ARB_base_instance*,
	GL_ARB_shading_language_420pack*,
	GL_ARB_transform_feedback_instanced*,
	GL_ARB_compressed_texture_pixel_storage*,
	GL_ARB_conservative_depth*,
	GL_ARB_internalformat_query*,
	GL_ARB_map_buffer_alignment*,
	GL_ARB_shader_atomic_counters*,
	GL_ARB_shader_image_load_store*,
	GL_ARB_shading_language_packing*,
	GL_ARB_texture_storage*,


	(* GL 4.3 *)
	GL_ARB_arrays_of_arrays*,
	GL_ARB_fragment_layer_viewport*,
	GL_ARB_shader_image_size*,
	GL_ARB_ES3_compatibility*,
	GL_ARB_clear_buffer_object*,
	GL_ARB_compute_shader*,
	GL_ARB_copy_image*,
	GL_KHR_debug*,
	GL_ARB_explicit_uniform_location*,
	GL_ARB_framebuffer_no_attachments*,
	GL_ARB_internalformat_query2*,
	GL_ARB_invalidate_subdata*,
	GL_ARB_multi_draw_indirect*,
	GL_ARB_program_interface_query*,
	GL_ARB_robust_buffer_access_behavior*,
	GL_ARB_shader_storage_buffer_object*,
	GL_ARB_stencil_texturing*,
	GL_ARB_texture_buffer_range*,
	GL_ARB_texture_query_levels*,
	GL_ARB_texture_storage_multisample*,
	GL_ARB_texture_view*,
	GL_ARB_vertex_attrib_binding*,
	GL_NV_path_rendering*,
	GL_AMD_pinned_memory*,
	GL_AMD_stencil_operation_extended*,
	GL_AMD_vertex_shader_viewport_index*,
	GL_AMD_vertex_shader_layer*,
	GL_NV_bindless_texture*,
	GL_NV_shader_atomic_float*,
	GL_AMD_query_buffer_object*,


	(* GL 4.4 *)
	GL_ARB_buffer_storage*,
	GL_ARB_clear_texture*,
	GL_ARB_enhanced_layouts*,
	GL_ARB_multi_bind*,
	GL_ARB_query_buffer_object*,
	GL_ARB_texture_mirror_clamp_to_edge*,
	GL_ARB_texture_stencil8*,
	GL_ARB_vertex_type_10f_11f_11f_rev*,
	GL_ARB_bindless_texture*,
	GL_ARB_sparse_texture*,

	(* GL 4.5 *)
	GL_ARB_clip_control*,
	GL_ARB_cull_distance*,
	GL_ARB_ES3_1_compatibility*,
	GL_ARB_conditional_render_inverted*,
	GL_KHR_context_flush_control*,
	GL_ARB_derivative_control*,
	GL_ARB_direct_state_access*,
	GL_ARB_get_texture_sub_image*,
	GL_KHR_robustness*,
	GL_KHR_blend_equation_advanced*,
	GL_KHR_blend_equation_advanced_coherent*,
	GL_KHR_robust_buffer_access_behavior*,
	GL_ARB_shader_texture_image_samples*,
	GL_ARB_texture_barrier*,

	GL_ARB_cl_event*,
	GL_ARB_compute_variable_group_size*,
	GL_ARB_debug_output*,
	GL_ARB_robustness*,
	GL_ARB_shader_stencil_export*,
	GL_ATI_draw_buffers*,
	GL_ATI_element_array*,
	GL_ATI_envmap_bumpmap*,
	GL_ATI_fragment_shader*,
	GL_ATI_map_object_buffer*,
	GL_ATI_pn_triangles*,
	GL_ATI_separate_stencil*,
	GL_ATI_text_fragment_shader*,
	GL_ATI_texture_env_combine3*,
	GL_ATI_texture_float*,
	GL_ATI_texture_mirror_once*,
	GL_ATI_vertex_array_object*,
	GL_ATI_vertex_attrib_array_object*,
	GL_ATI_vertex_streams*,
	GL_ATI_meminfo*,
	GL_AMD_performance_monitor*,
	GL_AMD_texture_texture4*,
	GL_AMD_vertex_shader_tesselator*,
	GL_AMD_draw_buffers_blend*,
	GL_AMD_shader_stencil_export*,
	GL_AMD_seamless_cubemap_per_texture*,
	GL_AMD_conservative_depth*,
	GL_AMD_name_gen_delete*,
	GL_AMD_debug_output*,
	GL_AMD_transform_feedback3_lines_triangles*,
	GL_AMD_depth_clamp_separate*,
	GL_EXT_422_pixels*,
	GL_EXT_abgr*,
	GL_EXT_bgra*,
	GL_EXT_blend_color*,
	GL_EXT_blend_func_separate*,
	GL_EXT_blend_logic_op*,
	GL_EXT_blend_minmax*,
	GL_EXT_blend_subtract*,
	GL_EXT_clip_volume_hint*,
	GL_EXT_cmyka*,
	GL_EXT_color_matrix*,
	GL_EXT_color_subtable*,
	GL_EXT_compiled_vertex_array*,
	GL_EXT_convolution*,
	GL_EXT_coordinate_frame*,
	GL_EXT_copy_texture*,
	GL_EXT_cull_vertex*,
	GL_EXT_draw_range_elements*,
	GL_EXT_fog_coord*,
	GL_EXT_framebuffer_object*,
	GL_EXT_histogram*,
	GL_EXT_index_array_formats*,
	GL_EXT_index_func*,
	GL_EXT_index_material*,
	GL_EXT_index_texture*,
	GL_EXT_light_texture*,
	GL_EXT_misc_attribute*,
	GL_EXT_multi_draw_arrays*,
	GL_EXT_multisample*,
	GL_EXT_packed_pixels*,
	GL_EXT_paletted_texture*,
	GL_EXT_pixel_transform*,
	GL_EXT_pixel_transform_color_table*,
	GL_EXT_point_parameters*,
	GL_EXT_polygon_offset*,
	GL_EXT_rescale_normal*,
	GL_EXT_secondary_color*,
	GL_EXT_separate_specular_color*,
	GL_EXT_shadow_funcs*,
	GL_EXT_shared_texture_palette*,
	GL_EXT_stencil_two_side*,
	GL_EXT_stencil_wrap*,
	GL_EXT_subtexture*,
	GL_EXT_texture*,
	GL_EXT_texture3D*,
	GL_EXT_texture_compression_s3tc*,
	GL_EXT_texture_cube_map*,
	GL_EXT_texture_edge_clamp*,
	GL_EXT_texture_env_add*,
	GL_EXT_texture_env_combine*,
	GL_EXT_texture_env_dot3*,
	GL_EXT_texture_filter_anisotropic*,
	GL_EXT_texture_lod_bias*,
	GL_EXT_texture_object*,
	GL_EXT_texture_perturb_normal*,
	GL_EXT_texture_rectangle*,
	GL_EXT_vertex_array*,
	GL_EXT_vertex_shader*,
	GL_EXT_vertex_weighting*,
	GL_EXT_depth_bounds_test*,
	GL_EXT_texture_mirror_clamp*,
	GL_EXT_blend_equation_separate*,
	GL_EXT_pixel_buffer_object*,
	GL_EXT_texture_compression_dxt1*,
	GL_EXT_stencil_clear_tag*,
	GL_EXT_packed_depth_stencil*,
	GL_EXT_texture_sRGB*,
	GL_EXT_framebuffer_blit*,
	GL_EXT_framebuffer_multisample*,
	GL_EXT_timer_query*,
	GL_EXT_gpu_program_parameters*,
	GL_EXT_bindable_uniform*,
	GL_EXT_draw_buffers2*,
	GL_EXT_draw_instanced*,
	GL_EXT_framebuffer_sRGB*,
	GL_EXT_geometry_shader4*,
	GL_EXT_gpu_shader4*,
	GL_EXT_packed_float*,
	GL_EXT_texture_array*,
	GL_EXT_texture_buffer_object*,
	GL_EXT_texture_compression_latc*,
	GL_EXT_texture_compression_rgtc*,
	GL_EXT_texture_integer*,
	GL_EXT_texture_shared_exponent*,
	GL_EXT_transform_feedback*,
	GL_EXT_direct_state_access*,
	GL_EXT_vertex_array_bgra*,
	GL_EXT_texture_swizzle*,
	GL_EXT_provoking_vertex*,
	GL_EXT_texture_snorm*,
	GL_EXT_separate_shader_objects*,
	GL_EXT_shader_image_load_store*,
	GL_EXT_vertex_attrib_64bit*,
	GL_EXT_texture_sRGB_decode*,
	GL_FfdMaskSGIX*,
	GL_HP_convolution_border_modes*,
	GL_HP_image_transform*,
	GL_HP_occlusion_test*,
	GL_HP_texture_lighting*,
	GL_IBM_cull_vertex*,
	GL_IBM_multimode_draw_arrays*,
	GL_IBM_rasterpos_clip*,
	GL_IBM_texture_mirrored_repeat*,
	GL_IBM_vertex_array_lists*,
	GL_INGR_blend_func_separate*,
	GL_INGR_color_clamp*,
	GL_INGR_interlace_read*,
	GL_INGR_palette_buffer*,
	GL_INTEL_framebuffer_CMAA*,
	GL_INTEL_parallel_arrays*,
	GL_INTEL_texture_scissor*,
	GL_MESA_resize_buffers*,
	GL_MESA_window_pos*,
	GL_NV_blend_square*,
	GL_NV_copy_depth_to_color*,
	GL_NV_depth_clamp*,
	GL_NV_evaluators*,
	GL_NV_fence*,
	GL_NV_float_buffer*,
	GL_NV_fog_distance*,
	GL_NV_fragment_program*,
	GL_NV_half_float*,
	GL_NV_light_max_exponent*,
	GL_NV_multisample_filter_hint*,
	GL_NV_occlusion_query*,
	GL_NV_packed_depth_stencil*,
	GL_NV_pixel_data_range*,
	GL_NV_point_sprite*,
	GL_NV_primitive_restart*,
	GL_NV_register_combiners*,
	GL_NV_register_combiners2*,
	GL_NV_texgen_emboss*,
	GL_NV_texgen_reflection*,
	GL_NV_texture_compression_vtc*,
	GL_NV_texture_env_combine4*,
	GL_NV_texture_expand_normal*,
	GL_NV_texture_rectangle*,
	GL_NV_texture_shader*,
	GL_NV_texture_shader2*,
	GL_NV_texture_shader3*,
	GL_NV_vertex_array_range*,
	GL_NV_vertex_array_range2*,
	GL_NV_vertex_program*,
	GL_NV_vertex_program1_1*,
	GL_NV_vertex_program2*,
	GL_NV_fragment_program_option*,
	GL_NV_fragment_program2*,
	GL_NV_vertex_program2_option*,
	GL_NV_vertex_program3*,
	GL_NV_depth_buffer_float*,
	GL_NV_fragment_program4*,
	GL_NV_framebuffer_multisample_coverage*,
	GL_NV_geometry_program4*,
	GL_NV_gpu_program4*,
	GL_NV_parameter_buffer_object*,
	GL_NV_transform_feedback*,
	GL_NV_vertex_program4*,
	GL_NV_conditional_render*,
	GL_NV_conservative_raster*,
	GL_NV_conservative_raster_dilate*,

	GL_NV_present_video*,
	GL_NV_explicit_multisample*,
	GL_NV_transform_feedback2*,
	GL_NV_video_capture*,
	GL_NV_copy_image*,
	GL_NV_parameter_buffer_object2*,
	GL_NV_shader_buffer_load*,
	GL_NV_vertex_buffer_unified_memory*,
	GL_NV_gpu_program5*,
	GL_NV_gpu_shader5*,
	GL_NV_shader_buffer_store*,
	GL_NV_tessellation_program5*,
	GL_NV_vertex_attrib_integer_64bit*,
	GL_NV_multisample_coverage*,
	GL_NV_vdpau_interop*,
	GL_NV_texture_barrier*,
	GL_OML_interlace*,
	GL_OML_resample*,
	GL_OML_subsample*,

	GL_OVR_multiview*,
	GL_OVR_multiview2*,

	GL_PGI_misc_hints*,
	GL_PGI_vertex_hints*,
	GL_REND_screen_coordinates*,
	GL_S3_s3tc*,
	GL_SGIS_detail_texture*,
	GL_SGIS_fog_function*,
	GL_SGIS_generate_mipmap*,
	GL_SGIS_multisample*,
	GL_SGIS_pixel_texture*,
	GL_SGIS_point_line_texgen*,
	GL_SGIS_point_parameters*,
	GL_SGIS_sharpen_texture*,
	GL_SGIS_texture4D*,
	GL_SGIS_texture_border_clamp*,
	GL_SGIS_texture_color_mask*,
	GL_SGIS_texture_edge_clamp*,
	GL_SGIS_texture_filter4*,
	GL_SGIS_texture_lod*,
	GL_SGIS_texture_select*,
	GL_SGIX_async*,
	GL_SGIX_async_histogram*,
	GL_SGIX_async_pixel*,
	GL_SGIX_blend_alpha_minmax*,
	GL_SGIX_calligraphic_fragment*,
	GL_SGIX_clipmap*,
	GL_SGIX_convolution_accuracy*,
	GL_SGIX_depth_pass_instrument*,
	GL_SGIX_depth_texture*,
	GL_SGIX_flush_raster*,
	GL_SGIX_fog_offset*,
	GL_SGIX_fog_scale*,
	GL_SGIX_fragment_lighting*,
	GL_SGIX_framezoom*,
	GL_SGIX_igloo_interface*,
	GL_SGIX_impact_pixel_texture*,
	GL_SGIX_instruments*,
	GL_SGIX_interlace*,
	GL_SGIX_ir_instrument1*,
	GL_SGIX_list_priority*,
	GL_SGIX_pixel_texture*,
	GL_SGIX_pixel_tiles*,
	GL_SGIX_polynomial_ffd*,
	GL_SGIX_reference_plane*,
	GL_SGIX_resample*,
	GL_SGIX_scalebias_hint*,
	GL_SGIX_shadow*,
	GL_SGIX_shadow_ambient*,
	GL_SGIX_sprite*,
	GL_SGIX_subsample*,
	GL_SGIX_tag_sample_buffer*,
	GL_SGIX_texture_add_env*,
	GL_SGIX_texture_coordinate_clamp*,
	GL_SGIX_texture_lod_bias*,
	GL_SGIX_texture_multi_buffer*,
	GL_SGIX_texture_scale_bias*,
	GL_SGIX_texture_select*,
	GL_SGIX_vertex_preclip*,
	GL_SGIX_ycrcb*,
	GL_SGIX_ycrcb_subsample*,
	GL_SGIX_ycrcba*,
	GL_SGI_color_matrix*,
	GL_SGI_color_table*,
	GL_SGI_depth_pass_instrument*,
	GL_SGI_texture_color_table*,
	GL_SUNX_constant_data*,
	GL_SUN_convolution_border_modes*,
	GL_SUN_global_alpha*,
	GL_SUN_mesh_array*,
	GL_SUN_slice_accum*,
	GL_SUN_triangle_list*,
	GL_SUN_vertex*,

	(* WGL *)
	GL_WIN_phong_shading*,
	GL_WIN_specular_fog*,
	WGL_3DFX_multisample*,
	WGL_ARB_buffer_region*,
	WGL_ARB_extensions_string*,
	WGL_ARB_make_current_read*,
	WGL_ARB_multisample*,
	WGL_ARB_pbuffer*,
	WGL_ARB_pixel_format*,
	WGL_ARB_pixel_format_float*,
	WGL_ARB_render_texture*,
	WGL_ARB_create_context*,
	WGL_ARB_create_context_profile*,
	WGL_ARB_framebuffer_sRGB*,
	WGL_ARB_create_context_robustness*,
	WGL_ATI_pixel_format_float*,
	WGL_AMD_gpu_association*,
	WGL_EXT_depth_float*,
	WGL_EXT_display_color_table*,
	WGL_EXT_extensions_string*,
	WGL_EXT_make_current_read*,
	WGL_EXT_multisample*,
	WGL_EXT_pbuffer*,
	WGL_EXT_pixel_format*,
	WGL_EXT_swap_control*,
	WGL_EXT_create_context_es2_profile*,
	WGL_I3D_digital_video_control*,
	WGL_I3D_gamma*,
	WGL_I3D_genlock*,
	WGL_I3D_image_buffer*,
	WGL_I3D_swap_frame_lock*,
	WGL_I3D_swap_frame_usage*,
	WGL_NV_float_buffer*,
	WGL_NV_render_depth_texture*,
	WGL_NV_render_texture_rectangle*,
	WGL_NV_vertex_array_range*,
	WGL_NV_present_video*,
	WGL_NV_video_output*,
	WGL_NV_swap_group*,
	WGL_NV_gpu_affinity*,
	WGL_NV_video_capture*,
	WGL_NV_copy_image*,
	WGL_NV_multisample_coverage*,
	WGL_NV_DX_interop*,
	WGL_OML_sync_control*,
	WGL_3DL_stereo_control*,
	WGL_ARB_context_flush_control*,
	WIN_draw_range_elements*,
	WIN_swap_hint* : BOOLEAN;


TYPE

	(*! GL_VERSION_1_0  *)
	TglCullFace* = PROCEDURE{WINAPI}(mode: Enum);
	TglFrontFace* = PROCEDURE{WINAPI}(mode: Enum);
	TglHint* = PROCEDURE{WINAPI}(target: Enum; mode: Enum);
	TglLineWidth* = PROCEDURE{WINAPI}(width: Float);
	TglPointSize* = PROCEDURE{WINAPI}(size: Float);
	TglPolygonMode* = PROCEDURE{WINAPI}(face: Enum; mode: Enum);
	TglScissor* = PROCEDURE{WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei);
	TglTexParameterf* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Float);
	TglTexParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglTexParameteri* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Int);
	TglTexParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglTexImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Int; width: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTexImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Int; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglDrawBuffer* = PROCEDURE{WINAPI}(mode: Enum);
	TglClear* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglClearColor* = PROCEDURE{WINAPI}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	TglClearStencil* = PROCEDURE{WINAPI}(s: Int);
	TglClearDepth* = PROCEDURE{WINAPI}(depth: Clampd);
	TglStencilMask* = PROCEDURE{WINAPI}(mask: Uint);
	TglColorMask* = PROCEDURE{WINAPI}(red: Boolean; green: Boolean; blue: Boolean; alpha: Boolean);
	TglDepthMask* = PROCEDURE{WINAPI}(flag: Boolean);
	TglDisable* = PROCEDURE{WINAPI}(cap: Enum);
	TglEnable* = PROCEDURE{WINAPI}(cap: Enum);
	TglFinish* = PROCEDURE{WINAPI}();
	TglFlush* = PROCEDURE{WINAPI}();
	TglBlendFunc* = PROCEDURE{WINAPI}(sfactor: Enum; dfactor: Enum);
	TglLogicOp* = PROCEDURE{WINAPI}(opcode: Enum);
	TglStencilFunc* = PROCEDURE{WINAPI}(func: Enum; ref: Int; mask: Uint);
	TglStencilOp* = PROCEDURE{WINAPI}(fail: Enum; zfail: Enum; zpass: Enum);
	TglDepthFunc* = PROCEDURE{WINAPI}(func: Enum);
	TglPixelStoref* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPixelStorei* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglReadBuffer* = PROCEDURE{WINAPI}(mode: Enum);
	TglReadPixels* = PROCEDURE{WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetBooleanv* = PROCEDURE{WINAPI}(pname: Enum; params: PBoolean);
	TglGetDoublev* = PROCEDURE{WINAPI}(pname: Enum; params: PDouble);
	TglGetError* = PROCEDURE{WINAPI}(): Enum;
	TglGetFloatv* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglGetIntegerv* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglGetString* = PROCEDURE{WINAPI}(name: Enum): ADDRESS;
	TglGetTexImage* = PROCEDURE{WINAPI}(target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetTexParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetTexParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetTexLevelParameterfv* = PROCEDURE{WINAPI}(target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetTexLevelParameteriv* = PROCEDURE{WINAPI}(target: Enum; level: Int; pname: Enum; params: PInt);
	TglIsEnabled* = PROCEDURE{WINAPI}(cap: Enum): Boolean;
	TglDepthRange* = PROCEDURE{WINAPI}(zNear: Clampd; zFar: Clampd);
	TglViewport* = PROCEDURE{WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei);
	(*! GL_VERSION_1_1  *)
	TglDrawArrays* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei);
	TglDrawElements* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: PVoid);
	TglGetPointerv* = PROCEDURE{WINAPI}(pname: Enum; params: PVoid);
	TglPolygonOffset* = PROCEDURE{WINAPI}(factor: Float; units: Float);
	TglCopyTexImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalFormat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTexImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalFormat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTexSubImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTexSubImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglTexSubImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglTexSubImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglBindTexture* = PROCEDURE{WINAPI}(target: Enum; texture: Uint);
	TglDeleteTextures* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint);
	TglGenTextures* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint);

	(*! ifdef DEPRECATED  *)
	TglAccum* = PROCEDURE{WINAPI}(op: Enum; value: Float);
	TglAlphaFunc* = PROCEDURE{WINAPI}(func: Enum; ref: Clampf);
	TglAreTexturesResident* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint; residences: PBoolean): Boolean;
	TglArrayElement* = PROCEDURE{WINAPI}(i: Int);
	TglBegin* = PROCEDURE{WINAPI}(mode: Enum);
	TglBitmap* = PROCEDURE{WINAPI}(width: Sizei; height: Sizei; xorig: Float; yorig: Float; xmove: Float; ymove: Float; bitmap: PUbyte);
	TglCallList* = PROCEDURE{WINAPI}(list: Uint);
	TglCallLists* = PROCEDURE{WINAPI}(n: Sizei; xtype: Enum; lists: PVoid);
	TglClearAccum* = PROCEDURE{WINAPI}(red: Float; green: Float; blue: Float; alpha: Float);
	TglClearIndex* = PROCEDURE{WINAPI}(c: Float);
	TglClipPlane* = PROCEDURE{WINAPI}(plane: Enum; equation: PDouble);
	TglColor3b* = PROCEDURE{WINAPI}(red: Byte; green: Byte; blue: Byte);
	TglColor3bv* = PROCEDURE{WINAPI}( v: PByte);
	TglColor3d* = PROCEDURE{WINAPI}(red: Double; green: Double; blue: Double);
	TglColor3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglColor3f* = PROCEDURE{WINAPI}(red: Float; green: Float; blue: Float);
	TglColor3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglColor3i* = PROCEDURE{WINAPI}(red: Int; green: Int; blue: Int);
	TglColor3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglColor3s* = PROCEDURE{WINAPI}(red: Short; green: Short; blue: Short);
	TglColor3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglColor3ub* = PROCEDURE{WINAPI}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglColor3ubv* = PROCEDURE{WINAPI}( v: PUbyte);
	TglColor3ui* = PROCEDURE{WINAPI}(red: Uint; green: Uint; blue: Uint);
	TglColor3uiv* = PROCEDURE{WINAPI}( v: PUint);
	TglColor3us* = PROCEDURE{WINAPI}(red: Ushort; green: Ushort; blue: Ushort);
	TglColor3usv* = PROCEDURE{WINAPI}( v: PUshort);
	TglColor4b* = PROCEDURE{WINAPI}(red: Byte; green: Byte; blue: Byte; alpha: Byte);
	TglColor4bv* = PROCEDURE{WINAPI}( v: PByte);
	TglColor4d* = PROCEDURE{WINAPI}(red: Double; green: Double; blue: Double; alpha: Double);
	TglColor4dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglColor4f* = PROCEDURE{WINAPI}(red: Float; green: Float; blue: Float; alpha: Float);
	TglColor4fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglColor4i* = PROCEDURE{WINAPI}(red: Int; green: Int; blue: Int; alpha: Int);
	TglColor4iv* = PROCEDURE{WINAPI}( v: PInt);
	TglColor4s* = PROCEDURE{WINAPI}(red: Short; green: Short; blue: Short; alpha: Short);
	TglColor4sv* = PROCEDURE{WINAPI}( v: PShort);
	TglColor4ub* = PROCEDURE{WINAPI}(red: Ubyte; green: Ubyte; blue: Ubyte; alpha: Ubyte);
	TglColor4ubv* = PROCEDURE{WINAPI}( v: PUbyte);
	TglColor4ui* = PROCEDURE{WINAPI}(red: Uint; green: Uint; blue: Uint; alpha: Uint);
	TglColor4uiv* = PROCEDURE{WINAPI}( v: PUint);
	TglColor4us* = PROCEDURE{WINAPI}(red: Ushort; green: Ushort; blue: Ushort; alpha: Ushort);
	TglColor4usv* = PROCEDURE{WINAPI}( v: PUshort);
	TglColorMaterial* = PROCEDURE{WINAPI}(face: Enum; mode: Enum);
	TglColorPointer* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglCopyPixels* = PROCEDURE{WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei; xtype: Enum);
	TglDeleteLists* = PROCEDURE{WINAPI}(list: Uint; range: Sizei);
	TglDisableClientState* = PROCEDURE{WINAPI}(xarray: Enum);
	TglDrawPixels* = PROCEDURE{WINAPI}(width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglEdgeFlag* = PROCEDURE{WINAPI}(flag: Boolean);
	TglEdgeFlagPointer* = PROCEDURE{WINAPI}(stride: Sizei; xpointer: PVoid);
	TglEdgeFlagv* = PROCEDURE{WINAPI}( flag: PBoolean);
	TglEnableClientState* = PROCEDURE{WINAPI}(xarray: Enum);
	TglEnd* = PROCEDURE{WINAPI}();
	TglEndList* = PROCEDURE{WINAPI}();
	TglEvalCoord1d* = PROCEDURE{WINAPI}(u: Double);
	TglEvalCoord1dv* = PROCEDURE{WINAPI}( u: PDouble);
	TglEvalCoord1f* = PROCEDURE{WINAPI}(u: Float);
	TglEvalCoord1fv* = PROCEDURE{WINAPI}( u: PFloat);
	TglEvalCoord2d* = PROCEDURE{WINAPI}(u: Double; v: Double);
	TglEvalCoord2dv* = PROCEDURE{WINAPI}( u: PDouble);
	TglEvalCoord2f* = PROCEDURE{WINAPI}(u: Float; v: Float);
	TglEvalCoord2fv* = PROCEDURE{WINAPI}( u: PFloat);
	TglEvalMesh1* = PROCEDURE{WINAPI}(mode: Enum; i1: Int; i2: Int);
	TglEvalMesh2* = PROCEDURE{WINAPI}(mode: Enum; i1: Int; i2: Int; j1: Int; j2: Int);
	TglEvalPoint1* = PROCEDURE{WINAPI}(i: Int);
	TglEvalPoint2* = PROCEDURE{WINAPI}(i: Int; j: Int);
	TglFeedbackBuffer* = PROCEDURE{WINAPI}(size: Sizei; xtype: Enum; buffer: PFloat);
	TglFogf* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglFogfv* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglFogi* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglFogiv* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglFrustum* = PROCEDURE{WINAPI}(left, right, bottom, top, zNear, zFar: Double);
	TglGenLists* = PROCEDURE{WINAPI}(range: Sizei): Uint;
	TglGetClipPlane* = PROCEDURE{WINAPI}(plane: Enum; equation: PDouble);
	TglGetLightfv* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PFloat);
	TglGetLightiv* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PInt);
	TglGetMapdv* = PROCEDURE{WINAPI}(target: Enum; query: Enum; v: PDouble);
	TglGetMapfv* = PROCEDURE{WINAPI}(target: Enum; query: Enum; v: PFloat);
	TglGetMapiv* = PROCEDURE{WINAPI}(target: Enum; query: Enum; v: PInt);
	TglGetMaterialfv* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PFloat);
	TglGetMaterialiv* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PInt);
	TglGetPixelMapfv* = PROCEDURE{WINAPI}(map: Enum; values: PFloat);
	TglGetPixelMapuiv* = PROCEDURE{WINAPI}(map: Enum; values: PUint);
	TglGetPixelMapusv* = PROCEDURE{WINAPI}(map: Enum; values: PUshort);
	TglGetPolygonStipple* = PROCEDURE{WINAPI}(mask: PUbyte);
	TglGetTexEnvfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetTexEnviv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetTexGendv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PDouble);
	TglGetTexGenfv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PFloat);
	TglGetTexGeniv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PInt);
	TglIndexMask* = PROCEDURE{WINAPI}(mask: Uint);
	TglIndexPointer* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglIndexd* = PROCEDURE{WINAPI}(c: Double);
	TglIndexdv* = PROCEDURE{WINAPI}( c: PDouble);
	TglIndexf* = PROCEDURE{WINAPI}(c: Float);
	TglIndexfv* = PROCEDURE{WINAPI}( c: PFloat);
	TglIndexi* = PROCEDURE{WINAPI}(c: Int);
	TglIndexiv* = PROCEDURE{WINAPI}( c: PInt);
	TglIndexs* = PROCEDURE{WINAPI}(c: Short);
	TglIndexsv* = PROCEDURE{WINAPI}( c: PShort);
	TglIndexub* = PROCEDURE{WINAPI}(c: Ubyte);
	TglIndexubv* = PROCEDURE{WINAPI}( c: PUbyte);
	TglInitNames* = PROCEDURE{WINAPI}();
	TglInterleavedArrays* = PROCEDURE{WINAPI}(format: Enum; stride: Sizei; xpointer: PVoid);
	TglIsList* = PROCEDURE{WINAPI}(list: Uint): BOOLEAN;
	TglIsTexture* = PROCEDURE{WINAPI}(texture: Uint): BOOLEAN;
	TglLightModelf* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglLightModelfv* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglLightModeli* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglLightModeliv* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglLightf* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; param: Float);
	TglLightfv* = PROCEDURE{WINAPI}(light: Enum; pname: Enum;  params: PFloat);
	TglLighti* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; param: Int);
	TglLightiv* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PInt);
	TglLineStipple* = PROCEDURE{WINAPI}(factor: Int; pattern: Ushort);
	TglListBase* = PROCEDURE{WINAPI}(base: Uint);
	TglLoadIdentity* = PROCEDURE{WINAPI}();
	TglLoadMatrixd* = PROCEDURE{WINAPI}( m: PDouble);
	TglLoadMatrixf* = PROCEDURE{WINAPI}( m: PFloat);
	TglLoadName* = PROCEDURE{WINAPI}(name: Uint);
	TglMap1d* = PROCEDURE{WINAPI}(target: Enum; u1: Double; u2: Double; stride: Int; order: Int; points: PDouble);
	TglMap1f* = PROCEDURE{WINAPI}(target: Enum; u1: Float; u2: Float; stride: Int; order: Int; points: PFloat);
	TglMap2d* = PROCEDURE{WINAPI}(target: Enum; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int; points: PDouble);
	TglMap2f* = PROCEDURE{WINAPI}(target: Enum; u1: Float; u2: Float; ustride: Int; uorder: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; points: PFloat);
	TglMapGrid1d* = PROCEDURE{WINAPI}(un: Int; u1: Double; u2: Double);
	TglMapGrid1f* = PROCEDURE{WINAPI}(un: Int; u1: Float; u2: Float);
	TglMapGrid2d* = PROCEDURE{WINAPI}(un: Int; u1: Double; u2: Double; vn: Int; v1: Double; v2: Double);
	TglMapGrid2f* = PROCEDURE{WINAPI}(un: Int; u1: Float; u2: Float; vn: Int; v1: Float; v2: Float);
	TglMaterialf* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; param: Float);
	TglMaterialfv* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PFloat);
	TglMateriali* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; param: Int);
	TglMaterialiv* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PInt);
	TglMatrixMode* = PROCEDURE{WINAPI}(mode: Enum);
	TglMultMatrixd* = PROCEDURE{WINAPI}( m: PDouble);
	TglMultMatrixf* = PROCEDURE{WINAPI}( m: PFloat);
	TglNewList* = PROCEDURE{WINAPI}(list: Uint; mode: Enum);
	TglNormal3b* = PROCEDURE{WINAPI}(nx: Byte; ny: Byte; nz: Byte);
	TglNormal3bv* = PROCEDURE{WINAPI}( v: PByte);
	TglNormal3d* = PROCEDURE{WINAPI}(nx: Double; ny: Double; nz: Double);
	TglNormal3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglNormal3f* = PROCEDURE{WINAPI}(nx: Float; ny: Float; nz: Float);
	TglNormal3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglNormal3i* = PROCEDURE{WINAPI}(nx: Int; ny: Int; nz: Int);
	TglNormal3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglNormal3s* = PROCEDURE{WINAPI}(nx: Short; ny: Short; nz: Short);
	TglNormal3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglNormalPointer* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglOrtho* = PROCEDURE{WINAPI}(left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglPassThrough* = PROCEDURE{WINAPI}(token: Float);
	TglPixelMapfv* = PROCEDURE{WINAPI}(map: Enum; mapsize: Sizei; values: PFloat);
	TglPixelMapuiv* = PROCEDURE{WINAPI}(map: Enum; mapsize: Sizei; values: PUint);
	TglPixelMapusv* = PROCEDURE{WINAPI}(map: Enum; mapsize: Sizei; values: PUshort);
	TglPixelTransferf* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPixelTransferi* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglPixelZoom* = PROCEDURE{WINAPI}(xfactor: Float; yfactor: Float);
	TglPolygonStipple* = PROCEDURE{WINAPI}( mask: PUbyte);
	TglPopAttrib* = PROCEDURE{WINAPI}();
	TglPopClientAttrib* = PROCEDURE{WINAPI}();
	TglPopMatrix* = PROCEDURE{WINAPI}();
	TglPopName* = PROCEDURE{WINAPI}();
	TglPrioritizeTextures* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint; priorities: PClampf);
	TglPushAttrib* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglPushClientAttrib* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglPushMatrix* = PROCEDURE{WINAPI}();
	TglPushName* = PROCEDURE{WINAPI}(name: Uint);
	TglRasterPos2d* = PROCEDURE{WINAPI}(x: Double; y: Double);
	TglRasterPos2dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglRasterPos2f* = PROCEDURE{WINAPI}(x: Float; y: Float);
	TglRasterPos2fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglRasterPos2i* = PROCEDURE{WINAPI}(x: Int; y: Int);
	TglRasterPos2iv* = PROCEDURE{WINAPI}( v: PInt);
	TglRasterPos2s* = PROCEDURE{WINAPI}(x: Short; y: Short);
	TglRasterPos2sv* = PROCEDURE{WINAPI}( v: PShort);
	TglRasterPos3d* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglRasterPos3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglRasterPos3f* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglRasterPos3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglRasterPos3i* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int);
	TglRasterPos3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglRasterPos3s* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short);
	TglRasterPos3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglRasterPos4d* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double; w: Double);
	TglRasterPos4dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglRasterPos4f* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float; w: Float);
	TglRasterPos4fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglRasterPos4i* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int; w: Int);
	TglRasterPos4iv* = PROCEDURE{WINAPI}( v: PInt);
	TglRasterPos4s* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short; w: Short);
	TglRasterPos4sv* = PROCEDURE{WINAPI}( v: PShort);
	TglRectd* = PROCEDURE{WINAPI}(x1: Double; y1: Double; x2: Double; y2: Double);
	TglRectdv* = PROCEDURE{WINAPI}( v1: PDouble; v2: PDouble);
	TglRectf* = PROCEDURE{WINAPI}(x1: Float; y1: Float; x2: Float; y2: Float);
	TglRectfv* = PROCEDURE{WINAPI}( v1: PFloat; v2: PFloat);
	TglRecti* = PROCEDURE{WINAPI}(x1: Int; y1: Int; x2: Int; y2: Int);
	TglRectiv* = PROCEDURE{WINAPI}( v1: PInt; v2: PInt);
	TglRects* = PROCEDURE{WINAPI}(x1: Short; y1: Short; x2: Short; y2: Short);
	TglRectsv* = PROCEDURE{WINAPI}( v1: PShort; v2: PShort);
	TglRenderMode* = PROCEDURE{WINAPI}(mode: Enum): Int;
	TglRotated* = PROCEDURE{WINAPI}(angle, x, y, z: Double);
	TglRotatef* = PROCEDURE{WINAPI}( angle, x, y, z: Float);
	TglScaled* = PROCEDURE{WINAPI}(x, y, z: Double);
	TglScalef* = PROCEDURE{WINAPI}(x, y, z: Float);
	TglSelectBuffer* = PROCEDURE{WINAPI}(size: Sizei; buffer: PUint);
	TglShadeModel* = PROCEDURE{WINAPI}(mode: Enum);
	TglTexCoord1d* = PROCEDURE{WINAPI}(s: Double);
	TglTexCoord1dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglTexCoord1f* = PROCEDURE{WINAPI}(s: Float);
	TglTexCoord1fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglTexCoord1i* = PROCEDURE{WINAPI}(s: Int);
	TglTexCoord1iv* = PROCEDURE{WINAPI}( v: PInt);
	TglTexCoord1s* = PROCEDURE{WINAPI}(s: Short);
	TglTexCoord1sv* = PROCEDURE{WINAPI}( v: PShort);
	TglTexCoord2d* = PROCEDURE{WINAPI}(s: Double; t: Double);
	TglTexCoord2dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglTexCoord2f* = PROCEDURE{WINAPI}(s: Float; t: Float);
	TglTexCoord2fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglTexCoord2i* = PROCEDURE{WINAPI}(s: Int; t: Int);
	TglTexCoord2iv* = PROCEDURE{WINAPI}( v: PInt);
	TglTexCoord2s* = PROCEDURE{WINAPI}(s: Short; t: Short);
	TglTexCoord2sv* = PROCEDURE{WINAPI}( v: PShort);
	TglTexCoord3d* = PROCEDURE{WINAPI}(s: Double; t: Double; r: Double);
	TglTexCoord3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglTexCoord3f* = PROCEDURE{WINAPI}(s: Float; t: Float; r: Float);
	TglTexCoord3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglTexCoord3i* = PROCEDURE{WINAPI}(s: Int; t: Int; r: Int);
	TglTexCoord3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglTexCoord3s* = PROCEDURE{WINAPI}(s: Short; t: Short; r: Short);
	TglTexCoord3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglTexCoord4d* = PROCEDURE{WINAPI}(s: Double; t: Double; r: Double; q: Double);
	TglTexCoord4dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglTexCoord4f* = PROCEDURE{WINAPI}(s: Float; t: Float; r: Float; q: Float);
	TglTexCoord4fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglTexCoord4i* = PROCEDURE{WINAPI}(s: Int; t: Int; r: Int; q: Int);
	TglTexCoord4iv* = PROCEDURE{WINAPI}( v: PInt);
	TglTexCoord4s* = PROCEDURE{WINAPI}(s: Short; t: Short; r: Short; q: Short);
	TglTexCoord4sv* = PROCEDURE{WINAPI}( v: PShort);
	TglTexCoordPointer* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglTexEnvf* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Float);
	TglTexEnvfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglTexEnvi* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Int);
	TglTexEnviv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglTexGend* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; param: Double);
	TglTexGendv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PDouble);
	TglTexGenf* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; param: Float);
	TglTexGenfv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PFloat);
	TglTexGeni* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; param: Int);
	TglTexGeniv* = PROCEDURE{WINAPI}(coord: Enum; pname: Enum; params: PInt);
	TglTranslated* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglTranslatef* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglVertex2d* = PROCEDURE{WINAPI}(x: Double; y: Double);
	TglVertex2dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglVertex2f* = PROCEDURE{WINAPI}(x: Float; y: Float);
	TglVertex2fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglVertex2i* = PROCEDURE{WINAPI}(x: Int; y: Int);
	TglVertex2iv* = PROCEDURE{WINAPI}( v: PInt);
	TglVertex2s* = PROCEDURE{WINAPI}(x: Short; y: Short);
	TglVertex2sv* = PROCEDURE{WINAPI}( v: PShort);
	TglVertex3d* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglVertex3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglVertex3f* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglVertex3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglVertex3i* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int);
	TglVertex3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglVertex3s* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short);
	TglVertex3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglVertex4d* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double; w: Double);
	TglVertex4dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglVertex4f* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float; w: Float);
	TglVertex4fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglVertex4i* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int; w: Int);
	TglVertex4iv* = PROCEDURE{WINAPI}( v: PInt);
	TglVertex4s* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short; w: Short);
	TglVertex4sv* = PROCEDURE{WINAPI}( v: PShort);
	TglVertexPointer* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	(*! endif  *)

	(*! GL_VERSION_1_2  *)
	TglBlendColor* = PROCEDURE{WINAPI}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	TglBlendEquation* = PROCEDURE{WINAPI}(mode: Enum);
	TglDrawRangeElements* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum; indices: PVoid);
	TglTexImage3D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Int; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTexSubImage3D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglCopyTexSubImage3D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);

	(*! ifdef DEPRECATED 1.2  *)
	TglColorTable* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum; table: PVoid);
	TglColorTableParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglColorTableParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglCopyColorTable* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglGetColorTable* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; table: PVoid);
	TglGetColorTableParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetColorTableParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglColorSubTable* = PROCEDURE{WINAPI}(target: Enum; start: Sizei; count: Sizei; format: Enum; xtype: Enum; data: PVoid);
	TglCopyColorSubTable* = PROCEDURE{WINAPI}(target: Enum; start: Sizei; x: Int; y: Int; width: Sizei);
	TglConvolutionFilter1D* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum; image: PVoid);
	TglConvolutionFilter2D* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum; image: PVoid);
	TglConvolutionParameterf* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: Float);
	TglConvolutionParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglConvolutionParameteri* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: Int);
	TglConvolutionParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglCopyConvolutionFilter1D* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglCopyConvolutionFilter2D* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetConvolutionFilter* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; image: PVoid);
	TglGetConvolutionParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetConvolutionParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetSeparableFilter* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; row: PVoid; column: PVoid; span: PVoid);
	TglSeparableFilter2D* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum; row: PVoid; column: PVoid);
	TglGetHistogram* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetHistogramParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetHistogramParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetMinmax* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetMinmaxParameterfv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetMinmaxParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglHistogram* = PROCEDURE{WINAPI}(target: Enum; width: Sizei; internalformat: Enum; sink: Boolean);
	TglMinmax* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; sink: Boolean);
	TglResetHistogram* = PROCEDURE{WINAPI}(target: Enum);
	TglResetMinmax* = PROCEDURE{WINAPI}(target: Enum);
	(*! endif  *)

	(*! GL_VERSION_1_3  *)
	TglActiveTexture* = PROCEDURE{WINAPI}(texture: Enum);
	TglSampleCoverage* = PROCEDURE{WINAPI}(value: Clampf; invert: Boolean);
	TglCompressedTexImage3D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage3D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage2D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage1D* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglGetCompressedTexImage* = PROCEDURE{WINAPI}(target: Enum; level: Int; img: PVoid);

	(*! ifdef DEPRECATED 1.3  *)
	TglClientActiveTexture* = PROCEDURE{WINAPI}(texture: Enum);
	TglMultiTexCoord1d* = PROCEDURE{WINAPI}(target: Enum; s: Double);
	TglMultiTexCoord1dv* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord1f* = PROCEDURE{WINAPI}(target: Enum; s: Float);
	TglMultiTexCoord1fv* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord1i* = PROCEDURE{WINAPI}(target: Enum; s: Int);
	TglMultiTexCoord1iv* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord1s* = PROCEDURE{WINAPI}(target: Enum; s: Short);
	TglMultiTexCoord1sv* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord2d* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double);
	TglMultiTexCoord2dv* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord2f* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float);
	TglMultiTexCoord2fv* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord2i* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int);
	TglMultiTexCoord2iv* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord2s* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short);
	TglMultiTexCoord2sv* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord3d* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double; r: Double);
	TglMultiTexCoord3dv* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord3f* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float; r: Float);
	TglMultiTexCoord3fv* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord3i* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int; r: Int);
	TglMultiTexCoord3iv* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord3s* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short; r: Short);
	TglMultiTexCoord3sv* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord4d* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double; r: Double; q: Double);
	TglMultiTexCoord4dv* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord4f* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float; r: Float; q: Float);
	TglMultiTexCoord4fv* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord4i* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int; r: Int; q: Int);
	TglMultiTexCoord4iv* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord4s* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short; r: Short; q: Short);
	TglMultiTexCoord4sv* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglLoadTransposeMatrixf* = PROCEDURE{WINAPI}( m: PFloat);
	TglLoadTransposeMatrixd* = PROCEDURE{WINAPI}( m: PDouble);
	TglMultTransposeMatrixf* = PROCEDURE{WINAPI}( m: PFloat);
	TglMultTransposeMatrixd* = PROCEDURE{WINAPI}( m: PDouble);
	(*! endif  *)

      (*! GL_VERSION_1_4  *)
	TglBlendFuncSeparate* = PROCEDURE{WINAPI}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);
	TglMultiDrawArrays* = PROCEDURE{WINAPI}(mode: Enum; first: PInt; count: PSizei; primcount: Sizei);
	TglMultiDrawElements* = PROCEDURE{WINAPI}(mode: Enum; count: PSizei; xtype: Enum; indices: PVoid; primcount: Sizei);
	TglPointParameterf* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPointParameterfv* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglPointParameteri* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglPointParameteriv* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);

	(*! ifdef DEPRECATED 1.4  *)
	TglFogCoordf* = PROCEDURE{WINAPI}(coord: Float);
	TglFogCoordfv* = PROCEDURE{WINAPI}( coord: PFloat);
	TglFogCoordd* = PROCEDURE{WINAPI}(coord: Double);
	TglFogCoorddv* = PROCEDURE{WINAPI}( coord: PDouble);
	TglFogCoordPointer* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglSecondaryColor3b* = PROCEDURE{WINAPI}(red: Byte; green: Byte; blue: Byte);
	TglSecondaryColor3bv* = PROCEDURE{WINAPI}( v: PByte);
	TglSecondaryColor3d* = PROCEDURE{WINAPI}(red: Double; green: Double; blue: Double);
	TglSecondaryColor3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglSecondaryColor3f* = PROCEDURE{WINAPI}(red: Float; green: Float; blue: Float);
	TglSecondaryColor3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglSecondaryColor3i* = PROCEDURE{WINAPI}(red: Int; green: Int; blue: Int);
	TglSecondaryColor3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglSecondaryColor3s* = PROCEDURE{WINAPI}(red: Short; green: Short; blue: Short);
	TglSecondaryColor3sv* = PROCEDURE{WINAPI}( v: PShort);
	TglSecondaryColor3ub* = PROCEDURE{WINAPI}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglSecondaryColor3ubv* = PROCEDURE{WINAPI}( v: PUbyte);
	TglSecondaryColor3ui* = PROCEDURE{WINAPI}(red: Uint; green: Uint; blue: Uint);
	TglSecondaryColor3uiv* = PROCEDURE{WINAPI}( v: PUint);
	TglSecondaryColor3us* = PROCEDURE{WINAPI}(red: Ushort; green: Ushort; blue: Ushort);
	TglSecondaryColor3usv* = PROCEDURE{WINAPI}( v: PUshort);
	TglSecondaryColorPointer* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglWindowPos2d* = PROCEDURE{WINAPI}(x: Double; y: Double);
	TglWindowPos2dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos2f* = PROCEDURE{WINAPI}(x: Float; y: Float);
	TglWindowPos2fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos2i* = PROCEDURE{WINAPI}(x: Int; y: Int);
	TglWindowPos2iv* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos2s* = PROCEDURE{WINAPI}(x: Short; y: Short);
	TglWindowPos2sv* = PROCEDURE{WINAPI}( v: PShort);
	TglWindowPos3d* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglWindowPos3dv* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos3f* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglWindowPos3fv* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos3i* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int);
	TglWindowPos3iv* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos3s* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short);
	TglWindowPos3sv* = PROCEDURE{WINAPI}( v: PShort);
	(*! endif  *)

	(*! GL_VERSION_1_5  *)
	TglGenQueries* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglDeleteQueries* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglIsQuery* = PROCEDURE{WINAPI}(id: Uint): BOOLEAN;
	TglBeginQuery* = PROCEDURE{WINAPI}(target: Enum; id: Uint);
	TglEndQuery* = PROCEDURE{WINAPI}(target: Enum);
	TglGetQueryiv* = PROCEDURE{WINAPI}(target, pname: Enum; params: PInt);
	TglGetQueryObjectiv* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt);
	TglGetQueryObjectuiv* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PUint);
	TglBindBuffer* = PROCEDURE{WINAPI}(target: Enum; buffer: Uint);
	TglDeleteBuffers* = PROCEDURE{WINAPI}(n: Sizei; buffers: PUint );
	TglGenBuffers* = PROCEDURE{WINAPI}(n: Sizei; buffers: PUint);
	TglIsBuffer* = PROCEDURE{WINAPI}(buffer: Uint): Boolean;
	TglBufferData* = PROCEDURE{WINAPI}(target: Enum; size: Sizei; data: ADDRESS; usage: Enum);
	TglBufferSubData* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglGetBufferSubData* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglMapBuffer* = PROCEDURE{WINAPI}(target: Enum; access: Enum): PVoid;
	TglUnmapBuffer* = PROCEDURE{WINAPI}(target: Enum): Boolean;
	TglGetBufferParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetBufferPointerv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PVoid);

	(*! GL_VERSION_2_0  *)
	TglBlendEquationSeparate* = PROCEDURE{WINAPI}(modeRGB: Enum; modeAlpha: Enum);
	TglDrawBuffers* = PROCEDURE{WINAPI}(n: Sizei; bufs: PEnum);
	TglStencilOpSeparate* = PROCEDURE{WINAPI}(face: Enum; sfail: Enum; dpfail: Enum; dppass: Enum);
	TglStencilFuncSeparate* = PROCEDURE{WINAPI}(frontfunc: Enum; backfunc: Enum; ref: Int; mask: Uint);
	TglStencilMaskSeparate* = PROCEDURE{WINAPI}(face: Enum; mask: Uint);
	TglAttachShader* = PROCEDURE{WINAPI}(programObj, shaderObj: Uint);
	TglBindAttribLocation* = PROCEDURE{WINAPI}(programObj: Uint; index: Uint; CONST name: ARRAY OF CHAR);
	TglCompileShader* = PROCEDURE{WINAPI}(shaderObj: Uint);
	TglCreateProgram* = PROCEDURE{WINAPI}(): Uint;
	TglCreateShader* = PROCEDURE{WINAPI}(shaderType: Enum): Uint;
	TglDeleteProgram* = PROCEDURE{WINAPI}(programObj: Uint);
	TglDeleteShader* = PROCEDURE{WINAPI}(shaderObj: Uint);
	TglDetachShader* = PROCEDURE{WINAPI}(programObj, shaderObj: Uint);
	TglDisableVertexAttribArray* = PROCEDURE{WINAPI}(index: Uint);
	TglEnableVertexAttribArray* = PROCEDURE{WINAPI}(index: Uint);
	TglGetActiveAttrib* = PROCEDURE{WINAPI}(programObj: Uint; index: Uint; maxlength: Sizei; VAR length: Int; VAR size: Int; VAR xtype: Enum; name: PChar);
	TglGetActiveUniform* = PROCEDURE{WINAPI}(programObj: Uint; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PChar);
	TglGetAttachedShaders* = PROCEDURE{WINAPI}(programObj: Uint; MaxCount: Sizei; VAR Count: Int; shaders: PInt);
	TglGetAttribLocation* = PROCEDURE{WINAPI}(programObj: Uint; CONST chars: ARRAY OF CHAR): Int;
	TglGetProgramiv* = PROCEDURE{WINAPI}(programObj: Uint; pname: Enum; params: PInt);
	TglGetProgramInfoLog* = PROCEDURE{WINAPI}(programObj: Uint; maxLength: Sizei; length: PSizei; infoLog: PChar);
	TglGetShaderiv* = PROCEDURE{WINAPI}(shaderObj: Uint; pname: Enum; params: PInt);
	TglGetShaderInfoLog* = PROCEDURE{WINAPI}(shaderObj: Uint; maxLength: Sizei; VAR length: Int; infoLog: PChar);
	TglGetShaderSource* = PROCEDURE{WINAPI}(shaderObj: Uint; maxlength: Sizei; VAR length: Sizei; source: PChar);
	TglGetUniformLocation* = PROCEDURE{WINAPI}(programObj: Uint; CONST chars: ARRAY OF CHAR): Int;
	TglGetUniformfv* = PROCEDURE{WINAPI}(programObj: Uint; location: Int; params: PFloat);
	TglGetUniformiv* = PROCEDURE{WINAPI}(programObj: Uint; location: Int; params: PInt);
	TglGetVertexAttribfv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribiv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribPointerv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgram* = PROCEDURE{WINAPI}(programObj: Uint) : Boolean;
	TglIsShader* = PROCEDURE{WINAPI}(shaderObj: Uint) : Boolean;
	TglLinkProgram* = PROCEDURE{WINAPI}(programObj: Uint);
	TglShaderSource* = PROCEDURE{WINAPI}(shaderObj: Uint; count: Sizei; xstring: PChar; lengths: PInt);
	TglUseProgram* = PROCEDURE{WINAPI}(programObj: Uint);
	TglUniform1f* = PROCEDURE{WINAPI}(location: Int; v0: Float);
	TglUniform2f* = PROCEDURE{WINAPI}(location: Int; v0, v1: Float);
	TglUniform3f* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2: Float);
	TglUniform4f* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2, v3: Float);
	TglUniform1i* = PROCEDURE{WINAPI}(location: Int; v0: Int);
	TglUniform2i* = PROCEDURE{WINAPI}(location: Int; v0, v1: Int);
	TglUniform3i* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2: Int);
	TglUniform4i* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2, v3: Int);
	TglUniform1fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform2fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform3fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform4fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform1iv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform2iv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform3iv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform4iv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniformMatrix2fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglValidateProgram* = PROCEDURE{WINAPI}(programObj: Uint);
	TglVertexAttrib1d* = PROCEDURE{WINAPI}(index: Uint; x: Double);
	TglVertexAttrib1dv* = PROCEDURE{WINAPI}(index: Uint;  v: PDouble);
	TglVertexAttrib1f* = PROCEDURE{WINAPI}(index: Uint; x: Float);
	TglVertexAttrib1fv* = PROCEDURE{WINAPI}(index: Uint;  v: PFloat);
	TglVertexAttrib1s* = PROCEDURE{WINAPI}(index: Uint; x: Short);
	TglVertexAttrib1sv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib2d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib2f* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fv* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib2s* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2sv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib3d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib3f* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fv* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib3s* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3sv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4Nbv* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttrib4Niv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttrib4Nsv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4Nub* = PROCEDURE{WINAPI}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4Nubv* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttrib4Nuiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttrib4Nusv* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglVertexAttrib4bv* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttrib4d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib4f* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fv* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib4iv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttrib4s* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4sv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4ubv* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttrib4uiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttrib4usv* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglVertexAttribPointer* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei; xpointer: PVoid);

	(*! GL_VERSION_2_1  *)
	TglUniformMatrix2x3fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3x2fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix2x4fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4x2fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3x4fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4x3fv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);

	(*! GL_VERSION_3_0  *)
	(* OpenGL 3.0 also reuses entry points from these extensions: *)
	(* ARB_framebuffer_object *)
	(* ARB_map_buffer_range *)
	(* ARB_vertex_array_object *)
	TglColorMaski* = PROCEDURE{WINAPI}(index: Uint; r: Boolean; g: Boolean; b: Boolean; a: Boolean);
	TglGetBooleani_v* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PBoolean);
	TglGetIntegeri_v* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PInt);
	TglEnablei* = PROCEDURE{WINAPI}(target: Enum; index: Uint);
	TglDisablei* = PROCEDURE{WINAPI}(target: Enum; index: Uint);
	TglIsEnabledi* = PROCEDURE{WINAPI}(target: Enum; index: Uint): Boolean;
	TglBeginTransformFeedback* = PROCEDURE{WINAPI}(primitiveMode: Enum);
	TglEndTransformFeedback* = PROCEDURE{WINAPI}();
	TglBindBufferRange* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint; offset: Sizei; size: Sizei);
	TglBindBufferBase* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryings* = PROCEDURE{WINAPI}(xprogram: Uint; count: Sizei; varyings: PPChar; bufferMode: Enum);
	TglGetTransformFeedbackVarying* = PROCEDURE{WINAPI}(xprogram: Uint; index: Uint; bufSize: Sizei; length: PSizei; size: PSizei; xtype: PSizei; name: PChar);
	TglClampColor* = PROCEDURE{WINAPI}(targe: Enum; clamp: Enum);
	TglBeginConditionalRender* = PROCEDURE{WINAPI}(id: Uint; mode: Enum);
	TglEndConditionalRender* = PROCEDURE{WINAPI}();
	TglVertexAttribIPointer* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei; pointer: PVoid);
	TglGetVertexAttribIiv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribIuiv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PUint);
	TglVertexAttribI1i* = PROCEDURE{WINAPI}(index: Uint; x: Int);
	TglVertexAttribI2i* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int);
	TglVertexAttribI3i* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int; z: Int);
	TglVertexAttribI4i* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglVertexAttribI1ui* = PROCEDURE{WINAPI}(index: Uint; x: Uint);
	TglVertexAttribI2ui* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint);
	TglVertexAttribI3ui* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint; z: Uint);
	TglVertexAttribI4ui* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglVertexAttribI1iv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI2iv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI3iv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI4iv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI1uiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI2uiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI3uiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI4uiv* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI4bv* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttribI4sv* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttribI4ubv* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttribI4usv* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglGetUniformuiv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; params: PUint);
	TglBindFragDataLocation* = PROCEDURE{WINAPI}(xprogram: Uint; color: Uint; CONST name: ARRAY OF CHAR);
	TglGetFragDataLocation* = PROCEDURE{WINAPI}(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
	TglUniform1ui* = PROCEDURE{WINAPI}(location: Int; v0: Uint);
	TglUniform2ui* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint);
	TglUniform3ui* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglUniform4ui* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglUniform1uiv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform2uiv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform3uiv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform4uiv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglTexParameterIiv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglTexParameterIuiv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PUint);
	TglGetTexParameterIiv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetTexParameterIuiv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PUint);
	TglClearBufferiv* = PROCEDURE{WINAPI}(buffer: Enum; drawbuffer: Int; value: PInt);
	TglClearBufferuiv* = PROCEDURE{WINAPI}(buffer: Enum; drawbuffer: Int; value: PUint);
	TglClearBufferfv* = PROCEDURE{WINAPI}(buffer: Enum; drawbuffer: Int; value: PFloat);
	TglClearBufferfi* = PROCEDURE{WINAPI}(buffer: Enum; drawbuffer: Int; depth: Float; stencil: Int);
	TglGetStringi* = PROCEDURE{WINAPI}(name: Enum; index: Uint): PUbyte;

	(* GL_VERSION_2_1 *)
	TglEnableVertexArrayEXT* = PROCEDURE{WINAPI}(vaobj: Uint; arrayx: Enum);
	TglEnableVertexArrayAttribEXT* = PROCEDURE{WINAPI}(vaobj: Uint; index: Uint);
	TglVertexArrayVertexAttribOffsetEXT* = PROCEDURE{WINAPI}(vaobj: Uint; buffer: Uint; index: Uint; size: Int; typex: Enum; normalized: Boolean; stride: Sizei; offset: Intptr);

	(*! GL_VERSION_3_1  *)
	(* OpenGL 3.1 also reuses entry points from these extensions: *)
	(* ARB_copy_buffer *)
	(* ARB_uniform_buffer_object *)
	TglDrawArraysInstanced* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstanced* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: PVoid; primcount: Sizei);
	TglTexBuffer* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; buffer: Uint);
	TglPrimitiveRestartIndex* = PROCEDURE{WINAPI}(index: Uint);

	(*! GL_VERSION_3_2  *)
	(* OpenGL 3.2 also reuses entry points from these extensions: *)
	(* ARB_draw_elements_base_vertex *)
	(* ARB_provoking_vertex *)
	(* ARB_sync *)
	(* ARB_texture_multisample *)
	TglGetInteger64i_v* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PInt64);
	TglGetBufferParameteri64v* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt64);
	TglFramebufferTexture* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	(* TglFramebufferTextureFace  = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum); *)

	(*! GL_VERSION_3_3  *)
	(* OpenGL 3.3 also reuses entry points from these extensions:  *)
	(* ARB_blend_func_extended  *)
	(* ARB_sampler_objects  *)
	(* ARB_explicit_attrib_location, but it has none  *)
	(* ARB_occlusion_query2 (no entry points)  *)
	(* ARB_shader_bit_encoding (no entry points)  *)
	(* ARB_texture_rgb10_a2ui (no entry points)  *)
	(* ARB_texture_swizzle (no entry points)  *)
	(* ARB_timer_query  *)
	(* ARB_vertex_type_2_10_10_10_rev  *)
	TglVertexAttribDivisor* = PROCEDURE{WINAPI}(index: Uint; divisor: Uint);

	(*! GL_VERSION_4_0  *)
	(* OpenGL 4.0 also reuses entry points from these extensions:  *)
	(* ARB_texture_query_lod (no entry points)  *)
	(* ARB_draw_indirect  *)
	(* ARB_gpu_shader5 (no entry points)  *)
	(* ARB_gpu_shader_fp64  *)
	(* ARB_shader_subroutine  *)
	(* ARB_tessellation_shader  *)
	(* ARB_texture_buffer_object_rgb32 (no entry points)  *)
	(* ARB_texture_cube_map_array (no entry points)  *)
	(* ARB_texture_gather (no entry points)  *)
	(* ARB_transform_feedback2  *)
	(* ARB_transform_feedback3  *)
	TglMinSampleShading* = PROCEDURE{WINAPI}(value: Clampf);
	TglBlendEquationi* = PROCEDURE{WINAPI}(buf: Uint; mode: Enum);
	TglBlendEquationSeparatei* = PROCEDURE{WINAPI}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	TglBlendFunci* = PROCEDURE{WINAPI}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparatei* = PROCEDURE{WINAPI}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);

	(*! GL_VERSION_4_1  *)
	(* OpenGL 4.1 also reuses entry points from these extensions:  *)
	(* ARB_ES2_compatibility  *)
	(* ARB_get_program_binary  *)
	(* ARB_separate_shader_objects  *)
	(* ARB_shader_precision (no entry points)  *)
	(* ARB_vertex_attrib_64bit  *)
	(* ARB_viewport_array  *)
	(* GL_3DFX_tbuffer  *)
	TglTbufferMask3DFX* = PROCEDURE{WINAPI}(mask: Uint);
	(* GL_APPLE_element_array  *)
	TglElementPointerAPPLE* = PROCEDURE{WINAPI}(xtype:  Enum; xpointer: PVoid);
	TglDrawElementArrayAPPLE* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei);
	TglDrawRangeElementArrayAPPLE* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; first: Int; count: Sizei);
	TglMultiDrawElementArrayAPPLE* = PROCEDURE{WINAPI}(mode: Enum; first: PInt; count: PSizei; primcount: Sizei);
	TglMultiDrawRangeElementArrayAPPLE* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; first: PInt; count: PSizei; primcount: Sizei);
	(* GL_APPLE_fence  *)
	TglGenFencesAPPLE* = PROCEDURE{WINAPI}(n: Sizei; fences: PUint);
	TglDeleteFencesAPPLE* = PROCEDURE{WINAPI}(n: Sizei; fences: PUint);
	TglSetFenceAPPLE* = PROCEDURE{WINAPI}(fence: Uint);
	TglIsFenceAPPLE* = PROCEDURE{WINAPI}(fence: Uint): Boolean;
	TglTestFenceAPPLE* = PROCEDURE{WINAPI}(fence: Uint): Boolean;
	TglFinishFenceAPPLE* = PROCEDURE{WINAPI}(fence: Uint);
	TglTestObjectAPPLE* = PROCEDURE{WINAPI}(xobject: Enum; name: Uint): Boolean;
	TglFinishObjectAPPLE* = PROCEDURE{WINAPI}(xobject: Enum; name: Int);
	(* GL_APPLE_vertex_array_object  *)
	TglBindVertexArrayAPPLE* = PROCEDURE{WINAPI}(xarray: Uint);
	TglDeleteVertexArraysAPPLE* = PROCEDURE{WINAPI}(n: Sizei; xarrays: PUint);
	TglGenVertexArraysAPPLE* = PROCEDURE{WINAPI}(n: Sizei; xarrays: PUint);
	TglIsVertexArrayAPPLE* = PROCEDURE{WINAPI}(narray: Uint): Boolean;
	(*  GL_APPLE_vertex_array_range  *)
	TglVertexArrayRangeAPPLE* = PROCEDURE{WINAPI}(length: Sizei; xpointer: PVoid);
	TglFlushVertexArrayRangeAPPLE* = PROCEDURE{WINAPI}(length: Sizei; xpointer: PVoid);
	TglVertexArrayParameteriAPPLE* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	(*  GL_APPLE_texture_range  *)
	TglTextureRangeAPPLE* = PROCEDURE{WINAPI}(target: Enum; xlength: Sizei; xpointer: PVoid);
	TglGetTexParameterPointervAPPLE* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PPVoid);
	(*  GL_APPLE_vertex_program_evaluators  *)
	TglEnableVertexAttribAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; pname: Enum);
	TglDisableVertexAttribAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; pname: Enum);
	TglIsVertexAttribEnabledAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; pname: Enum): Boolean;
	TglMapVertexAttrib1dAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; size: Uint; u1: Double; u2: Double; stride: Int; order: Int; points: PDouble);
	TglMapVertexAttrib1fAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; size: Uint; u1: Float; u2: Float; stride: Int; order: Int; points: PFloat);
	TglMapVertexAttrib2dAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; size: Uint; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int; points: PDouble);
	TglMapVertexAttrib2fAPPLE* = PROCEDURE{WINAPI}(indexx: Uint; size: Uint; u1: Float; u2: Float; ustride: Int; order: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; points: Float);
	(*  GL_APPLE_object_purgeable  *)
	TglObjectPurgeableAPPLE* = PROCEDURE{WINAPI}(objectType: Enum; name: Uint; option: Enum): Enum;
	TglObjectUnpurgeableAPPLE* = PROCEDURE{WINAPI}(objectType: Enum; name: Uint; option: Enum): Enum;
	TglGetObjectParameterivAPPLE* = PROCEDURE{WINAPI}(objectType: Enum; name: Uint; pname: Enum; params: PInt);
	(* GL_ARB_matrix_palette  *)
	TglCurrentPaletteMatrixARB* = PROCEDURE{WINAPI}(index: Int);
	TglMatrixIndexubvARB* = PROCEDURE{WINAPI}(size: Int; indices: PUbyte);
	TglMatrixIndexusvARB* = PROCEDURE{WINAPI}(size: Int; indices: PUshort);
	TglMatrixIndexuivARB* = PROCEDURE{WINAPI}(size: Int; indices: PUint);
	TglMatrixIndexPointerARB* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	(* GL_ARB_multisample  *)
	TglSampleCoverageARB* = PROCEDURE{WINAPI}(value: Clampf; invert: Boolean);
	(* GL_ARB_multitexture  *)
	TglActiveTextureARB* = PROCEDURE{WINAPI}(texture: Enum);
	TglClientActiveTextureARB* = PROCEDURE{WINAPI}(texture: Enum);
	TglMultiTexCoord1dARB* = PROCEDURE{WINAPI}(target: Enum; s: Double);
	TglMultiTexCoord1dvARB* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord1fARB* = PROCEDURE{WINAPI}(target: Enum; s: Float);
	TglMultiTexCoord1fvARB* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord1iARB* = PROCEDURE{WINAPI}(target: Enum; s: Int);
	TglMultiTexCoord1ivARB* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord1sARB* = PROCEDURE{WINAPI}(target: Enum; s: Short);
	TglMultiTexCoord1svARB* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord2dARB* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double);
	TglMultiTexCoord2dvARB* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord2fARB* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float);
	TglMultiTexCoord2fvARB* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord2iARB* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int);
	TglMultiTexCoord2ivARB* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord2sARB* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short);
	TglMultiTexCoord2svARB* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord3dARB* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double; r: Double);
	TglMultiTexCoord3dvARB* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord3fARB* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float; r: Float);
	TglMultiTexCoord3fvARB* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord3iARB* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int; r: Int);
	TglMultiTexCoord3ivARB* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord3sARB* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short; r: Short);
	TglMultiTexCoord3svARB* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	TglMultiTexCoord4dARB* = PROCEDURE{WINAPI}(target: Enum; s: Double; t: Double; r: Double; q: Double);
	TglMultiTexCoord4dvARB* = PROCEDURE{WINAPI}(target: Enum; v: PDouble);
	TglMultiTexCoord4fARB* = PROCEDURE{WINAPI}(target: Enum; s: Float; t: Float; r: Float; q: Float);
	TglMultiTexCoord4fvARB* = PROCEDURE{WINAPI}(target: Enum; v: PFloat);
	TglMultiTexCoord4iARB* = PROCEDURE{WINAPI}(target: Enum; s: Int; t: Int; r: Int; q: Int);
	TglMultiTexCoord4ivARB* = PROCEDURE{WINAPI}(target: Enum; v: PInt);
	TglMultiTexCoord4sARB* = PROCEDURE{WINAPI}(target: Enum; s: Short; t: Short; r: Short; q: Short);
	TglMultiTexCoord4svARB* = PROCEDURE{WINAPI}(target: Enum; v: PShort);
	(* GL_ARB_point_parameters  *)
	TglPointParameterfARB* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPointParameterfvARB* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	(* GL_ARB_texture_compression  *)
	TglCompressedTexImage3DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexImage2DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexImage1DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage3DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage2DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglCompressedTexSubImage1DARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei; data: PVoid);
	TglGetCompressedTexImageARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; img: PVoid);
	(* GL_ARB_transpose_matrix  *)
	TglLoadTransposeMatrixfARB* = PROCEDURE{WINAPI}( m: PFloat);
	TglLoadTransposeMatrixdARB* = PROCEDURE{WINAPI}( m: PDouble);
	TglMultTransposeMatrixfARB* = PROCEDURE{WINAPI}( m: PFloat);
	TglMultTransposeMatrixdARB* = PROCEDURE{WINAPI}( m: PDouble);
	(* GL_ARB_vertex_blend  *)
	TglWeightbvARB* = PROCEDURE{WINAPI}(size: Int; weights: PByte);
	TglWeightsvARB* = PROCEDURE{WINAPI}(size: Int; weights: PShort);
	TglWeightivARB* = PROCEDURE{WINAPI}(size: Int; weights: PInt);
	TglWeightfvARB* = PROCEDURE{WINAPI}(size: Int; weights: PFloat);
	TglWeightdvARB* = PROCEDURE{WINAPI}(size: Int; weights: PDouble);
	TglWeightubvARB* = PROCEDURE{WINAPI}(size: Int; weights: PUbyte);
	TglWeightusvARB* = PROCEDURE{WINAPI}(size: Int; weights: PUshort);
	TglWeightuivARB* = PROCEDURE{WINAPI}(size: Int; weights: PUint);
	TglWeightPointerARB* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglVertexBlendARB* = PROCEDURE{WINAPI}(count: Int);
	(* GL_ARB_vertex_buffer_object  *)
	TglBindBufferARB* = PROCEDURE{WINAPI}(target: Enum; buffer: Uint);
	TglDeleteBuffersARB* = PROCEDURE{WINAPI}(n: Sizei; buffers: PUint);
	TglGenBuffersARB* = PROCEDURE{WINAPI}(n: Sizei; buffers: PUint );
	TglIsBufferARB* = PROCEDURE{WINAPI}(buffer: Uint): Boolean;
	TglBufferDataARB* = PROCEDURE{WINAPI}(target: Enum; size: Sizei; data: PVoid; usage: Enum);
	TglBufferSubDataARB* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglGetBufferSubDataARB* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglMapBufferARB* = PROCEDURE{WINAPI}(target: Enum; access: Enum): PVoid;
	TglUnmapBufferARB* = PROCEDURE{WINAPI}( target: Enum): Boolean;
	TglGetBufferParameterivARB* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetBufferPointervARB* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PVoid);
	(* GL_ARB_vertex_program  *)
	TglVertexAttrib1dARB* = PROCEDURE{WINAPI}(index: Uint; x: Double);
	TglVertexAttrib1dvARB* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib1fARB* = PROCEDURE{WINAPI}(index: Uint; x: Float);
	TglVertexAttrib1fvARB* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib1sARB* = PROCEDURE{WINAPI}(index: Uint; x: Short);
	TglVertexAttrib1svARB* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib2dARB* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dvARB* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib2fARB* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fvARB* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib2sARB* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2svARB* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib3dARB* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dvARB* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib3fARB* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fvARB* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib3sARB* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3svARB* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4NbvARB* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttrib4NivARB* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttrib4NsvARB* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4NubARB* = PROCEDURE{WINAPI}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4NubvARB* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttrib4NuivARB* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttrib4NusvARB* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglVertexAttrib4bvARB* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttrib4dARB* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dvARB* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib4fARB* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fvARB* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib4ivARB* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttrib4sARB* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4svARB* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4ubvARB* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttrib4uivARB* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttrib4usvARB* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglVertexAttribPointerARB* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei; xpointer: PVoid);
	TglEnableVertexAttribArrayARB* = PROCEDURE{WINAPI}(index: Uint);
	TglDisableVertexAttribArrayARB* = PROCEDURE{WINAPI}(index: Uint);
	TglProgramStringARB* = PROCEDURE{WINAPI}(target: Enum; format: Enum; len: Sizei; xstring: PVoid);
	TglBindProgramARB* = PROCEDURE{WINAPI}(target: Enum; xprogram: Uint);
	TglDeleteProgramsARB* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint);
	TglGenProgramsARB* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint);
	TglProgramEnvParameter4dARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramEnvParameter4dvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PDouble);
	TglProgramEnvParameter4fARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramEnvParameter4fvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PFloat);
	TglProgramLocalParameter4dARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramLocalParameter4dvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PDouble);
	TglProgramLocalParameter4fARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramLocalParameter4fvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PFloat);
	TglGetProgramEnvParameterdvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PDouble);
	TglGetProgramEnvParameterfvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PFloat);
	TglGetProgramLocalParameterdvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PDouble);
	TglGetProgramLocalParameterfvARB* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PFloat);
	TglGetProgramivARB* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetProgramStringARB* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; xstring: PVoid);
	TglGetVertexAttribdvARB* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PDouble);
	TglGetVertexAttribfvARB* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribivARB* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribPointervARB* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgramARB* = PROCEDURE{WINAPI}(xprogram: Uint): Boolean;
	(* GL_ARB_window_pos  *)
	TglWindowPos2dARB* = PROCEDURE{WINAPI}(x: Double; y: Double);
	TglWindowPos2dvARB* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos2fARB* = PROCEDURE{WINAPI}(x: Float; y: Float);
	TglWindowPos2fvARB* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos2iARB* = PROCEDURE{WINAPI}(x: Int; y: Int);
	TglWindowPos2ivARB* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos2sARB* = PROCEDURE{WINAPI}(x: Short; y: Short);
	TglWindowPos2svARB* = PROCEDURE{WINAPI}( v: PShort);
	TglWindowPos3dARB* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglWindowPos3dvARB* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos3fARB* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglWindowPos3fvARB* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos3iARB* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int);
	TglWindowPos3ivARB* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos3sARB* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short);
	TglWindowPos3svARB* = PROCEDURE{WINAPI}( v: PShort);
	(* GL_ARB_draw_buffers  *)
	TglDrawBuffersARB* = PROCEDURE{WINAPI}(n: Sizei; bufs: PEnum);
	(* GL_ARB_color_buffer_float  *)
	TglClampColorARB* = PROCEDURE{WINAPI}(target: Enum; clamp: Enum);
	(* GL_ARB_vertex_shader  *)
	TglGetActiveAttribARB* = PROCEDURE{WINAPI}(programobj: Uint; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PCharARB);
	TglGetAttribLocationARB* = PROCEDURE{WINAPI}(programObj: Uint; CONST chars: ARRAY OF CHAR): Int;
	TglBindAttribLocationARB* = PROCEDURE{WINAPI}(programObj: Uint; index: Uint; CONST name: ARRAY OF CHAR);
	(* GL_ARB_shader_objects  *)
	TglDeleteObjectARB* = PROCEDURE{WINAPI}(Obj: Uint);
	TglGetHandleARB* = PROCEDURE{WINAPI}(pname: Enum): Uint;
	TglDetachObjectARB* = PROCEDURE{WINAPI}(container, attached: Uint);
	TglCreateShaderObjectARB* = PROCEDURE{WINAPI}(shaderType: Enum): Uint;
	TglShaderSourceARB* = PROCEDURE{WINAPI}(shaderObj: Uint; count: Sizei; xstring: PPCharARB; lengths: PInt);
	TglCompileShaderARB* = PROCEDURE{WINAPI}(shaderObj: Uint);
	TglCreateProgramObjectARB* = PROCEDURE{WINAPI}(): Uint;
	TglAttachObjectARB* = PROCEDURE{WINAPI}(programObj, shaderObj: Uint);
	TglLinkProgramARB* = PROCEDURE{WINAPI}(programObj: Uint);
	TglUseProgramObjectARB* = PROCEDURE{WINAPI}(programObj: Uint);
	TglValidateProgramARB* = PROCEDURE{WINAPI}(programObj: Uint);
	TglUniform1fARB* = PROCEDURE{WINAPI}(location: Int; v0: Float);
	TglUniform2fARB* = PROCEDURE{WINAPI}(location: Int; v0, v1: Float);
	TglUniform3fARB* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2: Float);
	TglUniform4fARB* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2, v3: Float);
	TglUniform1iARB* = PROCEDURE{WINAPI}(location: Int; v0: Int);
	TglUniform2iARB* = PROCEDURE{WINAPI}(location: Int; v0, v1: Int);
	TglUniform3iARB* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2: Int);
	TglUniform4iARB* = PROCEDURE{WINAPI}(location: Int; v0, v1, v2, v3: Int);
	TglUniform1fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform2fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform3fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform4fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PFloat);
	TglUniform1ivARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform2ivARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform3ivARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniform4ivARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt);
	TglUniformMatrix2fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4fvARB* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglGetObjectParameterfvARB* = PROCEDURE{WINAPI}(Obj: Uint; pname: Enum; params: PFloat);
	TglGetObjectParameterivARB* = PROCEDURE{WINAPI}(Obj: Uint; pname: Enum; params: PInt);
	TglGetInfoLogARB* = PROCEDURE{WINAPI}(shaderObj: Uint; maxLength: Sizei; VAR length: Int; infoLog: PCharARB);
	TglGetAttachedObjectsARB* = PROCEDURE{WINAPI}(programobj: Uint; maxCount: Sizei; VAR count: Sizei; objects: PHandleARB);
	TglGetUniformLocationARB* = PROCEDURE{WINAPI}(programObj: Uint; CONST chars: ARRAY OF CHAR): Int;
	TglGetActiveUniformARB* = PROCEDURE{WINAPI}(programobj: Uint; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PCharARB);
	TglGetUniformfvARB* = PROCEDURE{WINAPI}(programObj: Uint; location: Int; params: PFloat);
	TglGetUniformivARB* = PROCEDURE{WINAPI}(programObj: Uint; location: Int; params: PInt);
	TglGetShaderSourceARB* = PROCEDURE{WINAPI}(shader: Uint; maxLength: Sizei; VAR length: Sizei; source: PCharARB);
	(* GL_ARB_Occlusion_Query  *)
	TglGenQueriesARB* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglDeleteQueriesARB* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglIsQueryARB* = PROCEDURE{WINAPI}(id: Uint): BOOLEAN;
	TglBeginQueryARB* = PROCEDURE{WINAPI}(target: Enum; id: Uint);
	TglEndQueryARB* = PROCEDURE{WINAPI}(target: Enum);
	TglGetQueryivARB* = PROCEDURE{WINAPI}(target, pname: Enum; params: PInt);
	TglGetQueryObjectivARB* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt);
	TglGetQueryObjectuivARB* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PUint);
	(* GL_ARB_draw_instanced  *)
	TglDrawArraysInstancedARB* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstancedARB* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: PVoid; primcount: Sizei);
	(* GL_ARB_framebuffer_object  *)
	TglIsRenderbuffer* = PROCEDURE{WINAPI}(renderbuffer: Uint): Boolean;
	TglBindRenderbuffer* = PROCEDURE{WINAPI}(target: Enum; renderbuffer: Uint);
	TglDeleteRenderbuffers* = PROCEDURE{WINAPI}(n: Sizei; renderbuffers: PUint);
	TglGenRenderbuffers* = PROCEDURE{WINAPI}(n: Sizei; renderbuffers: PUint);
	TglRenderbufferStorage* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei);
	TglGetRenderbufferParameteriv* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglIsFramebuffer* = PROCEDURE{WINAPI}(framebuffer: Uint): Boolean;
	TglBindFramebuffer* = PROCEDURE{WINAPI}(target: Enum; framebuffer: Uint);
	TglDeleteFramebuffers* = PROCEDURE{WINAPI}(n: Sizei; framebuffers: PUint);
	TglGenFramebuffers* = PROCEDURE{WINAPI}(n: Sizei; framebuffers: PUint);
	TglCheckFramebufferStatus* = PROCEDURE{WINAPI}(target: Enum): Enum;
	TglFramebufferTexture1D* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture2D* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture3D* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglFramebufferRenderbuffer* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetFramebufferAttachmentParameteriv* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; pname: Enum; params: PInt);
	TglGenerateMipmap* = PROCEDURE{WINAPI}(target: Enum);
	TglBlitFramebuffer* = PROCEDURE{WINAPI}(srcX0: Int; srcY0: Int; srcX1: Int; srcY1: Int; dstX0: Int; dstY0: Int; dstX1: Int; dstY1: Int; mask: Bitfield; filter: Enum);
	TglRenderbufferStorageMultisample* = PROCEDURE{WINAPI}(target: Enum; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglFramebufferTextureLayer* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	(* GL_ARB_geometry_shader4  *)
	TglProgramParameteriARB* = PROCEDURE{WINAPI}(xprogram: Uint; pname: Enum; value: Int);
	TglFramebufferTextureARB* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	TglFramebufferTextureLayerARB* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	TglFramebufferTextureFaceARB* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum);
	(* GL_ARB_instanced_arrays  *)
	TglVertexAttribDivisorARB* = PROCEDURE{WINAPI}(index: Uint; divisor: Uint);
	(* GL_ARB_map_buffer_range  *)
	TglMapBufferRange* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; length: Sizei; access: Bitfield): PVoid;
	TglFlushMappedBufferRange* = PROCEDURE{WINAPI}(target: Enum; offset: Sizei; length: Sizei);

	(* GL_ARB_texture_buffer_object  *)
	TglTexBufferARB* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; buffer: Uint);

	(* GL_ARB_parallel_shader_compile *)
	TglMaxShaderCompilerThreadsARB* = PROCEDURE{WINAPI}(count: Uint);

	(* GL_ARB_vertex_array_object  *)
	TglBindVertexArray* = PROCEDURE{WINAPI}(xarray: Uint);
	TglDeleteVertexArrays* = PROCEDURE{WINAPI}(n: Sizei; arrays: PUint);
	TglGenVertexArrays* = PROCEDURE{WINAPI}(n: Sizei; arrays: PUint);
	TglIsVertexArray* = PROCEDURE{WINAPI}(xarray: Uint): Boolean;
	(* GL_ARB_uniform_buffer_object  *)
	TglGetUniformIndices* = PROCEDURE{WINAPI}(xprogram: Uint; uniformCount: Sizei; uniformNames: PPChar; uniformIndices: PUint);
	TglGetActiveUniformsiv* = PROCEDURE{WINAPI}(xprogram: Uint; uniformCount: Sizei; uniformIndices: PUint; pname: Enum; params: PInt);
	TglGetActiveUniformName* = PROCEDURE{WINAPI}(xprogram: Uint; uniformIndex: Uint; bufSize: Sizei; length: PSizei; uniformName: PChar);
	TglGetUniformBlockIndex* = PROCEDURE{WINAPI}(xprogram: Uint; CONST uniformBlockName: ARRAY OF CHAR): Uint;
	TglGetActiveUniformBlockiv* = PROCEDURE{WINAPI}(xprogram: Uint; uniformBlockIndex: Uint; pname: Enum; params: PInt);
	TglGetActiveUniformBlockName* = PROCEDURE{WINAPI}(xprogram: Uint; uniformBlockIndex: Uint; bufSize: Sizei; length: PSizei; uniformBlockName: PChar);
	TglUniformBlockBinding* = PROCEDURE{WINAPI}(xprogram: Uint; uniformBlockIndex: Uint; uniformBlockBinding: Uint);
	(* GL_ARB_copy_buffer  *)
	TglCopyBufferSubData* = PROCEDURE{WINAPI}(readTarget: Enum; writeTarget: Enum; readOffset: Int; writeOffset: Int; size: Sizei);
	(* GL_ARB_draw_elements_base_vertex  *)
	TglDrawElementsBaseVertex* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: PVoid; basevertex: Int);
	TglDrawRangeElementsBaseVertex* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum; indices: PVoid; basevertex: Int);
	TglDrawElementsInstancedBaseVertex* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: PVoid; primcount: Sizei; basevertex: Int);
	TglMultiDrawElementsBaseVertex* = PROCEDURE{WINAPI}(mode: Enum; count: PSizei; xtype: Enum; indices: PPVoid; primcount: Sizei; basevertex: PInt);
	(* GL_ARB_provoking_vertex  *)
	TglProvokingVertex* = PROCEDURE{WINAPI}(mode: Enum);
	(* GL_ARB_sync  *)
	TglFenceSync* = PROCEDURE{WINAPI}(condition: Enum; flags: Bitfield): GLsync;
	TglIsSync* = PROCEDURE{WINAPI}(sync: GLsync): Boolean;
	TglDeleteSync* = PROCEDURE{WINAPI}(sync: GLsync);
	TglClientWaitSync* = PROCEDURE{WINAPI}(sync: GLsync; flags: Bitfield; timeout: Uint64): Enum;
	TglWaitSync* = PROCEDURE{WINAPI}(sync: GLsync; flags: Bitfield; timeout: Uint64);
	TglGetInteger64v* = PROCEDURE{WINAPI}(pname: Enum; params: PInt64);
	TglGetSynciv* = PROCEDURE{WINAPI}(sync: GLsync; pname: Enum; butSize: Sizei; length: PSizei; values: PInt);
	(* GL_ARB_texture_multisample  *)
	TglTexImage2DMultisample* = PROCEDURE{WINAPI}(target: Enum; samples: Sizei; internalformat: Int; width: Sizei; height: Sizei; fixedsamplelocations: Boolean);
	TglTexImage3DMultisample* = PROCEDURE{WINAPI}(target: Enum; samples: Sizei; internalformat: Int; width: Sizei; height: Sizei; depth: Sizei; fixedsamplelocations: Boolean);
	TglGetMultisamplefv* = PROCEDURE{WINAPI}(pname: Enum; index: Uint; val: PFloat);
	TglSampleMaski* = PROCEDURE{WINAPI}(index: Uint; mask: Bitfield);
	(* GL_ARB_draw_buffers_blend  *)
	TglBlendEquationiARB* = PROCEDURE{WINAPI}(buf: Uint; mode: Enum);
	TglBlendEquationSeparateiARB* = PROCEDURE{WINAPI}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	TglBlendFunciARB* = PROCEDURE{WINAPI}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparateiARB* = PROCEDURE{WINAPI}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);
	(* GL_ARB_sample_shading  *)
	TglMinSampleShadingARB* = PROCEDURE{WINAPI}(value: Clampf);

	(*  GL_ARB_sample_locations *)
	TglFramebufferSampleLocationsfvARB* = PROCEDURE{WINAPI}(target : Enum; start : Uint; count : Sizei; v : PFloat);
	TglNamedFramebufferSampleLocationsfvARB* = PROCEDURE{WINAPI}(framebuffer : Uint; start : Uint; count : Sizei; v : PFloat);
	TglEvaluateDepthValuesARB* = PROCEDURE{WINAPI}();

	(*  GL_ARB_shading_language_include  *)
	TglNamedStringARB* = PROCEDURE{WINAPI}(xtype: Enum; namelen: Int; CONST name: ARRAY OF CHAR; stringlen: Int; CONST name: ARRAY OF CHAR);
	TglDeleteNamedStringARB* = PROCEDURE{WINAPI}(namelen: Int; CONST name: ARRAY OF CHAR);
	TglCompileShaderIncludeARB* = PROCEDURE{WINAPI}(shader: Uint; count: Sizei; path: PPChar; length: PInt);
	TglIsNamedStringARB* = PROCEDURE{WINAPI}(namelen: Int; CONST name: ARRAY OF CHAR): Boolean;
	TglGetNamedStringARB* = PROCEDURE{WINAPI}(namelen: Int; CONST name: ARRAY OF CHAR; bufSize: Sizei; stringlen: Int; xstring: PChar);
	TglGetNamedStringivARB* = PROCEDURE{WINAPI}(namelen: Int; CONST name: ARRAY OF CHAR; pname: Enum; params: PInt);
	(*  GL_ARB_blend_func_extended  *)
	TglBindFragDataLocationIndexed* = PROCEDURE{WINAPI}(xprogram: Uint; colorNumber: Uint; index: Uint; CONST name: ARRAY OF CHAR);
	TglGetFragDataIndex* = PROCEDURE{WINAPI}(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
	(*  GL_ARB_sampler_objects  *)
	TglGenSamplers* = PROCEDURE{WINAPI}(count: Sizei; samplers: PUint);
	TglDeleteSamplers* = PROCEDURE{WINAPI}(count: Sizei; samplers: PUint);
	TglIsSampler* = PROCEDURE{WINAPI}(sampler: Uint): Boolean;
	TglBindSampler* = PROCEDURE{WINAPI}(unit: Uint; sampler: Uint);
	TglSamplerParameteri* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: Int);
	TglSamplerParameteriv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: PInt);
	TglSamplerParameterf* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: Float);
	TglSamplerParameterfv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: PFloat);
	TglSamplerParameterIiv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: PInt);
	TglSamplerParameterIuiv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; param: PUint);
	TglGetSamplerParameteriv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; params: PInt);
	TglGetSamplerParameterIiv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; params: PInt);
	TglGetSamplerParameterfv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; params: PFloat);
	TglGetSamplerParameterIuiv* = PROCEDURE{WINAPI}(sampler: Uint; pname: Enum; params: PUint);
	(*  GL_ARB_timer_query  *)
	TglQueryCounter* = PROCEDURE{WINAPI}(id: Uint; target: Enum);
	TglGetQueryObjecti64v* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt64);
	TglGetQueryObjectui64v* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PUint64);
	(*  GL_ARB_vertex_type_2_10_10_10_rev  *)
	TglVertexP2ui* = PROCEDURE{WINAPI}(xtype: Enum; value: Uint);
	TglVertexP2uiv* = PROCEDURE{WINAPI}(xtype: Enum; value: PUint);
	TglVertexP3ui* = PROCEDURE{WINAPI}(xtype: Enum; value: Uint);
	TglVertexP3uiv* = PROCEDURE{WINAPI}(xtype: Enum; value: PUint);
	TglVertexP4ui* = PROCEDURE{WINAPI}(xtype: Enum; value: Uint);
	TglVertexP4uiv* = PROCEDURE{WINAPI}(xtype: Enum; value: PUint);
	TglTexCoordP1ui* = PROCEDURE{WINAPI}(xtype: Enum; coords: Uint);
	TglTexCoordP1uiv* = PROCEDURE{WINAPI}(xtype: Enum; coords: PUint);
	TglTexCoordP2ui* = PROCEDURE{WINAPI}(xtype: Enum; coords: Uint);
	TglTexCoordP2uiv* = PROCEDURE{WINAPI}(xtype: Enum; coords: PUint);
	TglTexCoordP3ui* = PROCEDURE{WINAPI}(xtype: Enum; coords: Uint);
	TglTexCoordP3uiv* = PROCEDURE{WINAPI}(xtype: Enum; coords: PUint);
	TglTexCoordP4ui* = PROCEDURE{WINAPI}(xtype: Enum; coords: Uint);
	TglTexCoordP4uiv* = PROCEDURE{WINAPI}(xtype: Enum; coords: PUint);
	TglMultiTexCoordP1ui* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP1uiv* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: PUint);
	TglMultiTexCoordP2ui* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP2uiv* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: PUint);
	TglMultiTexCoordP3ui* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP3uiv* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: PUint);
	TglMultiTexCoordP4ui* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP4uiv* = PROCEDURE{WINAPI}(texture: Enum; xtype: Enum; coords: PUint);
	TglNormalP3ui* = PROCEDURE{WINAPI}(xtype: Enum; coords: Uint);
	TglNormalP3uiv* = PROCEDURE{WINAPI}(xtype: Enum; coords: PUint);
	TglColorP3ui* = PROCEDURE{WINAPI}(xtype: Enum; color: Uint);
	TglColorP3uiv* = PROCEDURE{WINAPI}(xtype: Enum; color: PUint);
	TglColorP4ui* = PROCEDURE{WINAPI}(xtype: Enum; color: Uint);
	TglColorP4uiv* = PROCEDURE{WINAPI}(xtype: Enum; color: Uint);
	TglSecondaryColorP3ui* = PROCEDURE{WINAPI}(xtype: Enum; color: Uint);
	TglSecondaryColorP3uiv* = PROCEDURE{WINAPI}(xtype: Enum; color: PUint);
	TglVertexAttribP1ui* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP1uiv* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: PUint);
	TglVertexAttribP2ui* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP2uiv* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: PUint);
	TglVertexAttribP3ui* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP3uiv* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: PUint);
	TglVertexAttribP4ui* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP4uiv* = PROCEDURE{WINAPI}(index: Uint; xtype: Enum; normalized: Boolean; value: PUint);
	(*  GL_ARB_draw_indirect  *)
	TglDrawArraysIndirect* = PROCEDURE{WINAPI}(mode: Enum; indirect: PVoid);
	TglDrawElementsIndirect* = PROCEDURE{WINAPI}(mode: Enum; xtype: Enum; indirect: PVoid);
	(*  GL_ARB_gpu_shader_fp64  *)
	TglUniform1d* = PROCEDURE{WINAPI}(location: Int; x: Double);
	TglUniform2d* = PROCEDURE{WINAPI}(location: Int; x: Double; y: Double);
	TglUniform3d* = PROCEDURE{WINAPI}(location: Int; x: Double; y: Double; z: Double);
	TglUniform4d* = PROCEDURE{WINAPI}(location: Int; x: Double; y: Double; z: Double; w: Double);
	TglUniform1dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PDouble);
	TglUniform2dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PDouble);
	TglUniform3dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PDouble);
	TglUniform4dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PDouble);
	TglUniformMatrix2dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix3dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix4dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix2x3dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix2x4dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix3x2dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix3x4dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix4x2dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglUniformMatrix4x3dv* = PROCEDURE{WINAPI}(location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglGetUniformdv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; params: PDouble);

	(* GL_ARB_gpu_shader_int64 *)
	TglUniform1i64ARB* =PROCEDURE{WINAPI}(location: Int; x: Int64);
	TglUniform2i64ARB* =PROCEDURE{WINAPI}(location: Int; x: Int64; y: Int64);
	TglUniform3i64ARB* =PROCEDURE{WINAPI}(location: Int; x: Int64; y: Int64; z: Int64);
	TglUniform4i64ARB* =PROCEDURE{WINAPI}(location: Int; x: Int64; y: Int64; z: Int64; w: Int64);
	TglUniform1i64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei; value : PInt64);
	TglUniform2i64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei; value : PInt64);
	TglUniform3i64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei; value : PInt64);
	TglUniform4i64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei; value : PInt64);
	TglUniform1ui64ARB* =PROCEDURE{WINAPI}(location: Int; x : Uint64);
	TglUniform2ui64ARB* =PROCEDURE{WINAPI}(location: Int; x : Uint64; y : Uint64);
	TglUniform3ui64ARB* =PROCEDURE{WINAPI}(location: Int; x : Uint64; y : Uint64; z : Uint64);
	TglUniform4ui64ARB* =PROCEDURE{WINAPI}(location: Int; x : Uint64; y : Uint64; z : Uint64; w : Uint64);
	TglUniform1ui64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei;value : PUint64 );
	TglUniform2ui64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei;value : PUint64 );
	TglUniform3ui64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei;value : PUint64 );
	TglUniform4ui64vARB* =PROCEDURE{WINAPI}(location: Int; count: Sizei;value : PUint64 );
	TglGetUniformi64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; params : PInt64);
	TglGetUniformui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; params : PUint64);
	TglGetnUniformi64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; bufSize: Sizei; params : PInt64);
	TglGetnUniformui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; bufSize: Sizei; params : PUint64);
	TglProgramUniform1i64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x: Int64);
	TglProgramUniform2i64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x: Int64; y: Int64);
	TglProgramUniform3i64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x: Int64; y: Int64; z: Int64);
	TglProgramUniform4i64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x: Int64; y: Int64; z: Int64; w: Int64);
	TglProgramUniform1i64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PInt64);
	TglProgramUniform2i64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PInt64);
	TglProgramUniform3i64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PInt64);
	TglProgramUniform4i64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PInt64);
	TglProgramUniform1ui64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x : Uint64);
	TglProgramUniform2ui64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x : Uint64; y : Uint64);
	TglProgramUniform3ui64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x : Uint64; y : Uint64; z : Uint64);
	TglProgramUniform4ui64ARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; x : Uint64; y : Uint64; z : Uint64; w : Uint64);
	TglProgramUniform1ui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PUint64 );
	TglProgramUniform2ui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PUint64 );
	TglProgramUniform3ui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PUint64 );
	TglProgramUniform4ui64vARB* =PROCEDURE{WINAPI}(xprogram : Uint; location: Int; count: Sizei;value : PUint64 );


	(*  GL_ARB_shader_subroutine  *)
	TglGetSubroutineUniformLocation* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; CONST name: ARRAY OF CHAR): Int;
	TglGetSubroutineIndex* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; CONST name: ARRAY OF CHAR): Uint;
	TglGetActiveSubroutineUniformiv* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; index: Uint; pname: Enum; values: PInt);
	TglGetActiveSubroutineUniformName* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; index: Uint; bufsize: Sizei; length: PSizei; name: PChar);
	TglGetActiveSubroutineName* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; index: Uint; bufsize: Sizei; length: PSizei; name: PChar);
	TglUniformSubroutinesuiv* = PROCEDURE{WINAPI}(shadertype: Enum; count: Sizei; indices: PUint);
	TglGetUniformSubroutineuiv* = PROCEDURE{WINAPI}(shadertype: Enum; location: Int; params: PUint);
	TglGetProgramStageiv* = PROCEDURE{WINAPI}(xprogram: Uint; shadertype: Enum; pname: Enum; values: PInt);
	(*  GL_ARB_tessellation_shader  *)
	TglPatchParameteri* = PROCEDURE{WINAPI}(pname: Enum; value: Int);
	TglPatchParameterfv* = PROCEDURE{WINAPI}(pname: Enum; values: PFloat);
	(*  GL_ARB_transform_feedback2  *)
	TglBindTransformFeedback* = PROCEDURE{WINAPI}(target: Enum; id: Uint);
	TglDeleteTransformFeedbacks* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglGenTransformFeedbacks* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglIsTransformFeedback* = PROCEDURE{WINAPI}(id: Uint): Boolean;
	TglPauseTransformFeedback* = PROCEDURE{WINAPI}();
	TglResumeTransformFeedback* = PROCEDURE{WINAPI}();
	TglDrawTransformFeedback* = PROCEDURE{WINAPI}(mode: Enum; id: Uint);
	(*  GL_ARB_transform_feedback3  *)
	TglDrawTransformFeedbackStream* = PROCEDURE{WINAPI}(mode: Enum; id: Uint; stream: Uint);
	TglBeginQueryIndexed* = PROCEDURE{WINAPI}(target: Enum; index: Uint; id: Uint);
	TglEndQueryIndexed* = PROCEDURE{WINAPI}(target: Enum; index: Uint);
	TglGetQueryIndexediv* = PROCEDURE{WINAPI}(target: Enum; index: Uint; pname: Enum; params: PInt);
	(*  GL_ARB_ES2_compatibility  *)
	TglReleaseShaderCompiler* = PROCEDURE{WINAPI}();
	TglShaderBinary* = PROCEDURE{WINAPI}(count: Sizei; shaders: PUint; binaryformat: Enum; binary: PVoid; length: Sizei);
	TglGetShaderPrecisionFormat* = PROCEDURE{WINAPI}(shadertype: Enum; precisiontype: Enum; range: PInt; precision: PInt);
	TglDepthRangef* = PROCEDURE{WINAPI}(n: Clampf; f: Clampf);
	TglClearDepthf* = PROCEDURE{WINAPI}(d: Clampf);
	(* GL_ARB_get_program_binary  *)
	TglGetProgramBinary* = PROCEDURE{WINAPI}(xprogram: Uint; bufSize: Sizei; length: PSizei; binaryFormat: PEnum; binary: PVoid);
	TglProgramBinary* = PROCEDURE{WINAPI}(xprogram: Uint; binaryFormat: Enum; binary: PVoid; length: Sizei);
	TglProgramParameteri* = PROCEDURE{WINAPI}(xprogram: Uint; pname: Enum; value: Int);
	(* GL_ARB_separate_shader_objects *)
	TglUseProgramStages* = PROCEDURE{WINAPI}(pipeline: Uint; stages: Bitfield; xprogram: Uint);
	TglActiveShaderProgram* = PROCEDURE{WINAPI}(pipeline: Uint; xprogram: Uint);
	TglCreateShaderProgramv* = PROCEDURE{WINAPI}(xtype: Enum; count: Sizei; strings: PPChar): Uint;
	TglBindProgramPipeline* = PROCEDURE{WINAPI}(pipeline: Uint);
	TglDeleteProgramPipelines* = PROCEDURE{WINAPI}(n: Sizei; pipelines: PUint);
	TglGenProgramPipelines* = PROCEDURE{WINAPI}(n: Sizei; pipelines: PUint);
	TglIsProgramPipeline* = PROCEDURE{WINAPI}(pipeline: Uint): Boolean;
	TglGetProgramPipelineiv* = PROCEDURE{WINAPI}(pipeline: Uint; pname: Enum; params: PInt);
	TglProgramUniform1i* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int);
	TglProgramUniform1iv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform1f* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float);
	TglProgramUniform1fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform1d* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Double);
	TglProgramUniform1dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform1ui* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint);
	TglProgramUniform1uiv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform2i* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int);
	TglProgramUniform2iv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform2f* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float);
	TglProgramUniform2fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform2d* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Double; v1: Double);
	TglProgramUniform2dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform2ui* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint);
	TglProgramUniform2uiv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform3i* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int);
	TglProgramUniform3iv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform3f* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float);
	TglProgramUniform3fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform3d* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Double; v1: Double; v2: Double);
	TglProgramUniform3dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform3ui* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglProgramUniform3uiv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform4i* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int; v3: Int);
	TglProgramUniform4iv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform4f* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float; v3: Float);
	TglProgramUniform4fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform4d* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Double; v1: Double; v2: Double; v3: Double);
	TglProgramUniform4dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform4ui* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglProgramUniform4uiv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniformMatrix2fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix2dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix2x3fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3x2fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix2x4fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4x2fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3x4fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4x3fv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix2x3dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3x2dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix2x4dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4x2dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3x4dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4x3dv* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglValidateProgramPipeline* = PROCEDURE{WINAPI}(pipeline: Uint);
	TglGetProgramPipelineInfoLog* = PROCEDURE{WINAPI}(pipeline: Uint; bufSize: Sizei; length: PSizei; infoLog: PChar);
	(* GL_ARB_vertex_attrib_64bit  *)
	TglVertexAttribL1d* = PROCEDURE{WINAPI}(index: Uint; x: Double);
	TglVertexAttribL2d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double);
	TglVertexAttribL3d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttribL4d* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttribL1dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL2dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL3dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL4dv* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribLPointer* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei; pointer: PVoid);
	TglGetVertexAttribLdv* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PDouble);
	(* GL_ARB_viewport_array *)
	TglViewportArrayv* = PROCEDURE{WINAPI}(first: Uint; count: Sizei; v: PFloat);
	TglViewportIndexedf* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; w: Float; h: Float);
	TglViewportIndexedfv* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglScissorArrayv* = PROCEDURE{WINAPI}(first: Uint; count: Sizei; v: PInt);
	TglScissorIndexed* = PROCEDURE{WINAPI}(index: Uint; left: Int; bottom: Int; width: Sizei; height: Sizei);
	TglScissorIndexedv* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglDepthRangeArrayv* = PROCEDURE{WINAPI}(first: Uint; count: Sizei; v: PClampd);
	TglDepthRangeIndexed* = PROCEDURE{WINAPI}(index: Uint; n: Clampd; f: Clampd);
	TglGetFloati_v* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PFloat);
	TglGetDoublei_v* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PDouble);

	(*! GL 4.2  *)
	(*  GL_ARB_base_instance  *)
	TglDrawArraysInstancedBaseInstance* = PROCEDURE{WINAPI}(mode : Enum; first : Int; count :Sizei; primcount : Sizei; baseinstance : Uint);
	TglDrawElementsInstancedBaseInstance* = PROCEDURE{WINAPI}(mode : Enum; count : Sizei; xtype : Enum; indices : PVoid; primcount : Sizei; baseinstance : Uint);
	TglDrawElementsInstancedBaseVertexBaseInstance* = PROCEDURE{WINAPI}(mode : Enum; count : Sizei; xtype : Enum; indices : PVoid; primcount :Sizei; basevertex : Int; baseinstance : Uint);
	(*  GL_ARB_transform_feedback_instanced  *)
	TglDrawTransformFeedbackInstanced* = PROCEDURE{WINAPI}(mode : Enum; id : Uint; primcount : Sizei);
	TglDrawTransformFeedbackStreamInstanced* = PROCEDURE{WINAPI}(mode : Enum; id : Uint; stream : Uint; primcount : Sizei);
	(*  GL_ARB_internalformat_query  *)
	TglGetInternalformativ* = PROCEDURE{WINAPI}(target : Enum; internalformat : Enum; pname : Enum; bufSize : Sizei; params : PInt);
	(*  GL_ARB_shader_atomic_counters  *)
	TglGetActiveAtomicCounterBufferiv* = PROCEDURE{WINAPI}(xprogram : Uint; bufferIndex : Uint; pname : Enum; params : PInt);
	(*  GL_ARB_shader_image_load_store  *)
	TglBindImageTexture* = PROCEDURE{WINAPI}(xunit : Uint; texture : Uint; level :Int; layered : Boolean; layer : Int; access : Enum; format : Enum);
	TglMemoryBarrier* = PROCEDURE{WINAPI}(barriers : Bitfield);
	(*  GL_ARB_texture_storage  *)
	TglTexStorage1D* = PROCEDURE{WINAPI}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei);
	TglTexStorage2D* = PROCEDURE{WINAPI}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei);
	TglTexStorage3D* = PROCEDURE{WINAPI}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei);
	TglTextureStorage1DEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei);
	TglTextureStorage2DEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei);
	TglTextureStorage3DEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei);

	(*! GL 4.3  *)
	(* GL_KHR_debug  *)
	TglDebugMessageControl* = PROCEDURE{WINAPI}(source : Enum; xtype : Enum; severity : Enum; count : Sizei; ids : PUint; enabled : Boolean);
	TglDebugMessageInsert* = PROCEDURE{WINAPI}(source : Enum; xtype : Enum; id : Uint; sverity : Enum; length : Sizei; buf : PChar);
	TglDebugMessageCallback* = PROCEDURE{WINAPI}(callback : TglDebugProc; userParam : ADDRESS);
	TglGetDebugMessageLog* = PROCEDURE{WINAPI}(count : Uint; bufsize : Sizei; sources : PEnum; types : PEnum; ids : PUint; sverities : PEnum; lengths : PSizei; messagelog : PChar) : Uint;
	TglPushDebugGroup* = PROCEDURE{WINAPI}(source : Enum; id : Uint; length : Sizei; messagex : PChar);
	TglPopDebugGroup* = PROCEDURE{WINAPI}();
	TglObjectLabel* = PROCEDURE{WINAPI}(identifier : Enum; name : Uint; length : Sizei; labelx : PChar);
	TglGetObjectLabel* = PROCEDURE{WINAPI}(identifier : Enum; name : Uint; bufsize : Sizei; length : PSizei; label_ : PChar);
	TglObjectPtrLabel* = PROCEDURE{WINAPI}( ptr : ADDRESS; length : Sizei; labelx : PChar);
	TglGetObjectPtrLabel* = PROCEDURE{WINAPI}( ptr : ADDRESS; bufSize : Sizei; length : PSizei; labelx : PChar);
	(* GL_ARB_clear_buffer_object  *)
	TglClearBufferData* = PROCEDURE{WINAPI}(target : Enum; internalformat : Enum; format : Enum; xtype : Enum; data : ADDRESS);
	TglClearBufferSubData* = PROCEDURE{WINAPI}(target : Enum; internalformat : Enum; offset : Intptr; size : Sizeiptr; format : Enum; xtype : Enum; data : ADDRESS);
	TglClearNamedBufferDataEXT* = PROCEDURE{WINAPI}(buffer : Uint; internalformat : Enum; format : Enum; xtype : Enum; data : ADDRESS);
	TglClearNamedBufferSubDataEXT* = PROCEDURE{WINAPI}(buffer : Uint; internalformat : Enum; format : Enum; xtype : Enum; offset : Sizeiptr; size : Sizeiptr; data : ADDRESS);
	(* GL_ARB_compute_shader 1  *)
	TglDispatchCompute* = PROCEDURE{WINAPI}(num_groups_x : Uint; num_groups_y : Uint; num_groups_z : Uint);
	TglDispatchComputeIndirect* = PROCEDURE{WINAPI}(indirect : Intptr);
	(* GL_ARB_copy_image  *)
	TglCopyImageSubData* = PROCEDURE{WINAPI}(srcName : Uint; srcTarget : Enum; srcLevel : Int; srcX : Int; srcY : Int; srcZ : Int; dstName : Uint; dstTarget : Enum; dstLevel : Int; dstX : Int; dstY : Int; dstZ : Int; srcWidth : Sizei; srcHeight : Sizei; srcDepth : Sizei);
	(* GL_ARB_debug_group *)
	(* ARB_debug_group reuses entry points from KHR_debug *)
	(* GL_ARB_debug_label *)
	(* ARB_debug_label reuses entry points from KHR_debug *)
	(* GL_ARB_debug_output2 *)
	(* GL_ARB_ES3_2_compatibility *)
	TglPrimitiveBoundingBoxARB* = PROCEDURE {WINAPI}(minX : Float; minY : Float; minZ : Float; minW : Float; maxX : Float; maxY : Float; maxZ : Float; maxW : Float);
	(* GL_ARB_ES3_compatibility  *)
	(* GL_ARB_explicit_uniform_location  *)
	(* GL_ARB_fragment_layer_viewport  *)
	(* GL_ARB_framebuffer_no_attachments  *)
	TglFramebufferParameteri* = PROCEDURE{WINAPI}(target : Enum; pname : Enum; param : Int);
	TglGetFramebufferParameteriv* = PROCEDURE{WINAPI}(target : Enum; pname : Enum; params : PInt);
	TglNamedFramebufferParameteriEXT* = PROCEDURE{WINAPI}(framebuffer : Uint; pname : Enum; param : Int);
	TglGetNamedFramebufferParameterivEXT* = PROCEDURE{WINAPI}(framebuffer : Uint; pname : Enum; param : Int);
	(* GL_ARB_internalformat_query2  *)
	TglGetInternalformati64v* = PROCEDURE{WINAPI}(target : Enum; internalformat : Enum; pname : Enum; bufSize : Sizei; params : PInt64);
	(* GL_ARB_invalidate_subdata  *)
	TglInvalidateTexSubImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei);
	TglInvalidateTexImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int);
	TglInvalidateBufferSubData* = PROCEDURE{WINAPI}(buffer : Uint; offset : Intptr; length : Sizeiptr);
	TglInvalidateBufferData* = PROCEDURE{WINAPI}(buffer : Uint);
	TglInvalidateFramebuffer* = PROCEDURE{WINAPI}(target : Enum; numAttachments : Sizei; attachments : PEnum);
	TglInvalidateSubFramebuffer* = PROCEDURE{WINAPI}(target : Enum; numAttachments : Sizei; attachments : PEnum; x : Int; y : Int; width : Sizei; height : Sizei);
	(* GL_ARB_multi_draw_indirect  *)
	TglMultiDrawArraysIndirect* = PROCEDURE{WINAPI}(mode : Enum; indirect : ADDRESS; drawcount : Sizei; stride : Sizei);
	TglMultiDrawElementsIndirect* = PROCEDURE{WINAPI}(mode : Enum; xtype : Enum; indirect : ADDRESS; drawcount : Sizei; stride : Sizei);
	(* GL_ARB_program_interface_query  *)
	TglGetProgramInterfaceiv* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; pname : Enum; params : PInt);
	TglGetProgramResourceIndex* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; name : PChar) : Uint;
	TglGetProgramResourceName* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; index : Uint; bufSize : Sizei; length : PSizei; name : PChar);
	TglGetProgramResourceiv* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; index : Uint; propCount : Sizei; props : PEnum; bufSize : Sizei; length : PSizei; params : PInt);
	TglGetProgramResourceLocation* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; name : PChar) : Int;
	TglGetProgramResourceLocationIndex* = PROCEDURE{WINAPI}(programx : Uint; programInterface : Enum; name : PChar) : Int;
	(* GL_ARB_robust_buffer_access_behavior  *)
	(* GL_ARB_shader_image_size  *)
	(* GL_ARB_shader_storage_buffer_object  *)
	TglShaderStorageBlockBinding* = PROCEDURE{WINAPI}(programx : Uint; storageBlockIndex : Uint; storageBlockBinding : Uint);
	(* GL_ARB_stencil_texturing  *)
	(* GL_ARB_texture_buffer_range  *)
	TglTexBufferRange* = PROCEDURE{WINAPI}(target : Enum; internalformat : Enum; buffer : Uint; offset :Intptr; size : Sizeiptr);
	TglTextureBufferRangeEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; internalformat : Enum; buffer : Uint; offset : Intptr; size : Sizeiptr);
	(* GL_ARB_texture_query_levels  *)
	(* GL_ARB_texture_storage_multisample *)
	TglTexStorage2DMultisample* = PROCEDURE{WINAPI}(target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; fixedsamplelocations : Boolean);
	TglTexStorage3DMultisample* = PROCEDURE{WINAPI}(target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei; fixedsamplelocations : Boolean);
	TglTextureStorage2DMultisampleEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; fixedsamplelocations : Boolean);
	TglTextureStorage3DMultisampleEXT* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei; fixedsamplelocations : Boolean);


	(* GL 4.4 *)

	TglBufferStorage* = PROCEDURE{WINAPI}(target : Enum; size : PSizei;data : Void; flags : Bitfield);
	TglClearTexImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int; format : Enum; _type : Enum; data : Void);
	TglClearTexSubImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; format : Enum; _type : Enum; Data : Void);
	TglBindBuffersBase* = PROCEDURE{WINAPI}(target : Enum; first : Uint; count : Sizei; buffers : PUint);
	TglBindBuffersRange* = PROCEDURE{WINAPI}(target : Enum; first : Uint; count : Sizei; buffers : PUint; offsets : PInt; sizes : PSizei);
	TglBindTextures* = PROCEDURE{WINAPI}(first : Uint; count : Sizei; textures : PUint);
	TglBindSamplers* = PROCEDURE{WINAPI}(first : Uint; count : Sizei; samplers : PUint);
	TglBindImageTextures* = PROCEDURE{WINAPI}(first : Uint; count : Sizei; textures : PUint);
	TglBindVertexBuffers* = PROCEDURE{WINAPI}(first : Uint; count : Sizei; buffers : Uint; offsets : PInt; strides : PSizei);
	TglTexPageCommitmentARB* = PROCEDURE{WINAPI}(target : Enum; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; resident : Boolean);

	(* GL 4.5 *)
	TglClipControl* = PROCEDURE{WINAPI}(origin : Enum; depth : Enum);
	TglCreateTransformFeedbacks* = PROCEDURE{WINAPI}(n : Sizei; ids : PUint);
	TglTransformFeedbackBufferBase* = PROCEDURE{WINAPI}(xfb : Uint; index : Uint; buffer : Uint);
	TglTransformFeedbackBufferRange* = PROCEDURE{WINAPI}(xfb : Uint; index : Uint; buffer : Uint; offset : PInt; size : Sizei);
	TglGetTransformFeedbackiv* = PROCEDURE{WINAPI}(xfb : Uint; pname : Enum; param : PInt);
	TglGetTransformFeedbacki_v* = PROCEDURE{WINAPI}(xfb : Uint; pname : Enum; index : Uint; param : PInt);
	TglGetTransformFeedbacki64_v* = PROCEDURE{WINAPI}(xfb : Uint; pname : Enum; index : Uint; param : PInt64);
	TglCreateBuffers* = PROCEDURE{WINAPI}(n : Sizei; buffers : PUint);
	TglNamedBufferStorage* = PROCEDURE{WINAPI}(buffer : Uint; size : Sizei; data : PVoid; flags : Bitfield);
	TglNamedBufferData* = PROCEDURE{WINAPI}(buffer : Uint; size : Sizei; data : PVoid; usage : Enum);
	TglNamedBufferSubData* = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; size : Sizei; data : PVoid);
	TglCopyNamedBufferSubData* = PROCEDURE{WINAPI}(readBuffer : Uint; writeBuffer : Uint; readOffset : PInt; writeOffset : PInt; size : Sizei);
	TglClearNamedBufferData* = PROCEDURE{WINAPI}(buffer : Uint; internalformat : Enum; format : Enum; _type : Enum; data : PVoid);
	TglClearNamedBufferSubData* = PROCEDURE{WINAPI}(buffer : Uint; internalformat : Enum; offset : PInt; size : Sizei; format : Enum; _type : Enum; data : PVoid);
	TglMapNamedBuffer* = PROCEDURE{WINAPI}(buffer : Uint; access : Enum) : PVoid;
	TglMapNamedBufferRange* = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; length : Sizei; access : Bitfield) : PVoid;
	TglUnmapNamedBuffer* = PROCEDURE{WINAPI}(buffer : Uint) : Boolean;
	TglFlushMappedNamedBufferRange* = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; length : Sizei);
	TglGetNamedBufferParameteriv* = PROCEDURE{WINAPI}(buffer : Uint; pname : Enum; param : PInt);
	TglGetNamedBufferParameteri64v* = PROCEDURE{WINAPI}(buffer : Uint; pname : Enum; param : PInt64);
	TglGetNamedBufferPointerv* = PROCEDURE{WINAPI}(buffer : Uint; pname : Enum; params : PVoid);
	TglGetNamedBufferSubData* = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; size : Sizei; data : PVoid);
	TglCreateFramebuffers* = PROCEDURE{WINAPI}(n : Sizei; framebuffers : PUint);
	TglNamedFramebufferRenderbuffer* = PROCEDURE{WINAPI}(framebuffer : Uint; attachment : Enum ; renderbuffertarget : Enum; renderbuffer : Uint);
	TglNamedFramebufferParameteri* = PROCEDURE{WINAPI}(framebuffer : Uint; pname : Enum; param : Int);
	TglNamedFramebufferTexture* = PROCEDURE{WINAPI}(framebuffer : Uint; attachment : Enum; texture : Uint; level : Int);
	TglNamedFramebufferTextureLayer* = PROCEDURE{WINAPI}(framebuffer : Uint; attachment : Enum; texture : Uint; level : Int; layer : Int);
	TglNamedFramebufferDrawBuffer* = PROCEDURE{WINAPI}(framebuffer : Uint; buf : Enum);
	TglNamedFramebufferDrawBuffers* = PROCEDURE{WINAPI}(framebuffer : Uint; n : Sizei; bufs : PEnum);
	TglNamedFramebufferReadBuffer* = PROCEDURE{WINAPI}(framebuffer : Uint; src : Enum);
	TglInvalidateNamedFramebufferData* = PROCEDURE{WINAPI}(framebuffer : Uint; numAttachments : Sizei; attachments : PEnum);
	TglInvalidateNamedFramebufferSubData* = PROCEDURE{WINAPI}(framebuffer : Uint; numAttachments : Sizei; attachments : PEnum; x : Int; y : Int; width : Sizei; height : Sizei);
	TglClearNamedFramebufferiv* = PROCEDURE{WINAPI}(framebuffer : Uint; buffer : Enum; drawbuffer : Int; value : PInt);
	TglClearNamedFramebufferuiv* = PROCEDURE{WINAPI}(framebuffer : Uint; buffer : Enum; drawbuffer : Int; value : PInt);
	TglClearNamedFramebufferfv* = PROCEDURE{WINAPI}(framebuffer : Uint; buffer : Enum; drawbuffer : Int; value : PFloat);
	TglClearNamedFramebufferfi* = PROCEDURE{WINAPI}(framebuffer : Uint; buffer : Enum; depth : PFloat; stencil : Int);
	TglBlitNamedFramebuffer* = PROCEDURE{WINAPI}(readFramebuffer : Uint; drawFramebuffer : Uint; srcX0 : Int; srcY0 : Int; srcX1 : Int; srcY1 : Int; dstX0 : Int; dstY0 : Int; dstX1 : Int; dstY1 : Int ; mask : Bitfield; filter : Enum);
	TglCheckNamedFramebufferStatus* = PROCEDURE{WINAPI}(framebuffer : Uint; target : Enum) : Enum;
	TglGetNamedFramebufferParameteriv* = PROCEDURE{WINAPI}(framebuffer : Uint; pname : Enum; param : PInt);
	TglGetNamedFramebufferAttachmentParameteriv* = PROCEDURE{WINAPI}(framebuffer : Uint; attachment : Enum; pname : Enum; params : PInt);
	TglCreateRenderbuffers* = PROCEDURE{WINAPI}(n : Sizei; renderbuffers : PUint);
	TglNamedRenderbufferStorage* = PROCEDURE{WINAPI}(renderbuffer : Uint; internalformat : Enum ; width : Sizei; height : Sizei);
	TglNamedRenderbufferStorageMultisample* = PROCEDURE{WINAPI}(renderbuffer : Uint; samples : Sizei; internalformat : Enum ; width : Sizei; height : Sizei);
	TglGetNamedRenderbufferParameteriv* = PROCEDURE{WINAPI}(renderbuffer : Uint; pname : Enum; param : PInt);
	TglCreateTextures* = PROCEDURE{WINAPI}(target : Enum ; n : Sizei; textures : PUint);
	TglTextureBuffer* = PROCEDURE{WINAPI}(texture : Uint; internalformat : Enum; buffer : Uint);
	TglTextureBufferRange* = PROCEDURE{WINAPI}(texture : Uint; internalformat : Enum; buffer : Uint; offset : PInt; size : Sizei);
	TglTextureStorage1D* = PROCEDURE{WINAPI}(texture : Uint; levels : Sizei; internalformat : Enum; width : Sizei);
	TglTextureStorage2D* = PROCEDURE{WINAPI}(texture : Uint; levels : Sizei; internalformat : Enum; width : Sizei; height : Sizei);
	TglTextureStorage3D* = PROCEDURE{WINAPI}(texture : Uint; levels : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei);
	TglTextureStorage2DMultisample* = PROCEDURE{WINAPI}(texture : Uint; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; fixedsamplelocations : Boolean);
	TglTextureStorage3DMultisample* = PROCEDURE{WINAPI}(texture : Uint; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei; fixedsamplelocations : Boolean);
	TglTextureSubImage1D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; width : Sizei; format : Enum; _type : Enum; pixels : PVoid);
	TglTextureSubImage2D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; width : Sizei; height : Sizei; format : Enum; _type : Enum; pixels : PVoid);
	TglTextureSubImage3D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; format : Enum; _type : Enum; pixels : PVoid);
	TglCompressedTextureSubImage1D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; width : Sizei; format : Enum; imageSize : Sizei; data : PVoid);
	TglCompressedTextureSubImage2D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; width : Sizei; height : Sizei; format : Enum; mageSize : Sizei; data : PVoid);
	TglCompressedTextureSubImage3D* = PROCEDURE{WINAPI}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; format : Enum; imageSize : Sizei; data : PVoid);
	TglCopyTextureSubImage1D* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; xoffset : Int; x : Int; y : Int; width : Sizei);
	TglCopyTextureSubImage2D* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; xoffset : Int; yoffset : Int; x : Int; y : Int; width : Sizei; height : Sizei);
	TglCopyTextureSubImage3D* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; xoffset : Int; yoffset : Int; zoffset : Int; x : Int; y : Int; width : Sizei; height : Sizei);
	TglTextureParameterf* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; param : PFloat);
	TglTextureParameterfv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; param : PFloat);
	TglTextureParameteri* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; param : Int);
	TglTextureParameterIiv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PInt);
	TglTextureParameterIuiv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PUint);
	TglTextureParameteriv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; param : PInt);
	TglGenerateTextureMipmap* = PROCEDURE{WINAPI}(texture : Uint);
	TglBindTextureUnit* = PROCEDURE{WINAPI}(_unit : Uint; texture : Uint);
	TglGetTextureImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; format : Enum; _type : Enum; bufSize : Sizei; pixels : PVoid);
	TglGetCompressedTextureImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int; bufSize : Sizei; pixels : PVoid);
	TglGetTextureLevelParameterfv* = PROCEDURE{WINAPI}(texture : Uint; level : Int; pname : Enum; params : PFloat);
	TglGetTextureLevelParameteriv* = PROCEDURE{WINAPI}(texture : Uint; level : Int; pname : Enum; param : PInt);
	TglGetTextureParameterfv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PFloat);
	TglGetTextureParameterIiv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PInt);
	TglGetTextureParameterIuiv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PInt);
	TglGetTextureParameteriv* = PROCEDURE{WINAPI}(texture : Uint; pname : Enum; params : PInt);
	TglCreateVertexArrays* = PROCEDURE{WINAPI}(n : Sizei; arrays : PUint);
	TglDisableVertexArrayAttrib* = PROCEDURE{WINAPI}(vaobj : Uint; index : Uint);
	TglEnableVertexArrayAttrib* = PROCEDURE{WINAPI}(vaobj : Uint; index : Uint);
	TglVertexArrayElementBuffer* = PROCEDURE{WINAPI}(vaobj : Uint; buffer : Uint);
	TglVertexArrayVertexBuffer* = PROCEDURE{WINAPI}(vaobj : Uint; bindingindex : Uint; buffer : Uint; offset : PInt; stride : Sizei);
	TglVertexArrayVertexBuffers* = PROCEDURE{WINAPI}(vaobj : Uint; first : Uint; count : Sizei; buffers : PUint; offsets : PInt; strides : PSizei);
	TglVertexArrayAttribBinding* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; bindingindex : Uint);
	TglVertexArrayAttribFormat* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; _type : Enum; normalized : Boolean; relativeoffset : Uint);
	TglVertexArrayAttribIFormat* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; _type : Enum; relativeoffset : Uint);
	TglVertexArrayAttribLFormat* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; _type : Enum; relativeoffset : Uint);
	TglVertexArrayBindingDivisor* = PROCEDURE{WINAPI}(vaobj : Uint; bindingindex : Uint; divisor : Uint);
	TglGetVertexArrayiv* = PROCEDURE{WINAPI}(vaobj : Uint; pname : Enum; param : PInt);
	TglGetVertexArrayIndexediv* = PROCEDURE{WINAPI}(vaobj : Uint; index : Uint; pname : Enum; param : PInt);
	TglGetVertexArrayIndexed64iv* = PROCEDURE{WINAPI}(vaobj : Uint; index : Uint; pname : Enum; param : PInt64);
	TglCreateSamplers* = PROCEDURE{WINAPI}(n : Sizei; samplers : PUint);
	TglCreateProgramPipelines* = PROCEDURE{WINAPI}(n : Sizei; pipelines : PUint);
	TglCreateQueries* = PROCEDURE{WINAPI}(target : Enum; n : Sizei; ids : PUint);
	TglMemoryBarrierByRegion* = PROCEDURE{WINAPI}(barriers : Bitfield);
	TglGetTextureSubImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; format : Enum; _type : Enum; bufSize : Sizei; pixels : PVoid);
	TglGetCompressedTextureSubImage* = PROCEDURE{WINAPI}(texture : Uint; level : Int ; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei; bufSize : Sizei; pixels : PVoid);
	TglGetGraphicsResetStatus* = PROCEDURE{WINAPI}(): Enum;
	TglGetnCompressedTexImage* = PROCEDURE{WINAPI}(target : Enum; lod : Int; bufSize : Sizei; pixels : PVoid);
	TglGetnTexImage* = PROCEDURE{WINAPI}(target : Enum; level : Int; format : Enum; _type : Enum; bufSize : Sizei; pixels : PVoid);
	TglGetnUniformdv* = PROCEDURE{WINAPI}(_program : Uint; location : Int; bufSize : Sizei; params : PDouble);
	TglGetnUniformfv* = PROCEDURE{WINAPI}(_program : Uint; location : Int; bufSize : Sizei; params : PFloat);
	TglGetnUniformiv* = PROCEDURE{WINAPI}(_program : Uint; location : Int; bufSize : Sizei; params : PInt);
	TglGetnUniformuiv* = PROCEDURE{WINAPI}(_program : Uint; location : Int; bufSize : Sizei; params : PUint);
	TglReadnPixels* = PROCEDURE{WINAPI}(x : Int; y : Int; width : Sizei; height : Sizei; format : Enum; _type : Enum; bufSize : Sizei; data : PVoid);
	TglGetnMapdv* = PROCEDURE{WINAPI}(target : Enum; query : Enum; bufSize : Sizei; v : PDouble);
	TglGetnMapfv* = PROCEDURE{WINAPI}(target : Enum; query : Enum; bufSize : Sizei; v : PFloat);
	TglGetnMapiv* = PROCEDURE{WINAPI}(target : Enum; query : Enum; bufSize : Sizei; v : PInt);
	TglGetnPixelMapfv* = PROCEDURE{WINAPI}(map : Enum; bufSize : Sizei; values : PFloat);
	TglGetnPixelMapuiv* = PROCEDURE{WINAPI}(map : Enum; bufSize : Sizei; values : PUint);
	TglGetnPixelMapusv* = PROCEDURE{WINAPI}(map : Enum; bufSize : Sizei; values : PUshort);
	TglGetnPolygonStipple* = PROCEDURE{WINAPI}(bufSize : Sizei; pattern : PUbyte);
	TglGetnColorTable* = PROCEDURE{WINAPI}(target : Enum; format : Enum; _type : Enum; bufSize : Sizei; table : PVoid);
	TglGetnConvolutionFilter* = PROCEDURE{WINAPI}(target : Enum; format : Enum; _type : Enum; bufSize : Sizei; image : PVoid);
	TglGetnSeparableFilter* = PROCEDURE{WINAPI}(target : Enum; format : Enum; _type : Enum; rowBufSize : Sizei; row : PVoid; columnBufSize : Sizei; column : PVoid; span : PVoid);
	TglGetnHistogram* = PROCEDURE{WINAPI}(target : Enum; reset : Boolean; format : Enum; _type : Enum; bufSize : Sizei; values : PVoid);
	TglGetnMinmax* = PROCEDURE{WINAPI}(target : Enum; reset : Boolean; format : Enum; _type : Enum; bufSize : Sizei; values : PVoid);
	TglTextureBarrier* = PROCEDURE{WINAPI}();

	(* GL_ARB_sparse_buffer *)
	TglBufferPageCommitmentARB = PROCEDURE{WINAPI}(target : Enum; offset : PInt; size : Sizei; commit : Boolean);
	TglNamedBufferPageCommitmentEXT = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; size : Sizei; commit : Boolean);
	TglNamedBufferPageCommitmentARB = PROCEDURE{WINAPI}(buffer : Uint; offset : PInt; size : Sizei; commit : Boolean);

	(* GL_KHR_blend_equation_advanced *)
	TglBlendBarrierKHR = PROCEDURE{WINAPI}();


	(* GL_ARB_texture_view  *)
	TglTextureView* = PROCEDURE{WINAPI}(texture : Uint; target : Enum; origtexture : Uint; internalformat : Enum; minlevel : Uint; numlevels : Uint; minlayer : Uint; numlayers : Uint);
	(* GL_ARB_vertex_attrib_binding  *)
	TglBindVertexBuffer* = PROCEDURE{WINAPI}(bindingindex : Uint; buffer : Uint; offset : Intptr; stride : Sizei);
	TglVertexAttribFormat* = PROCEDURE{WINAPI}(attribindex : Uint; size : Int; xtype : Enum; normalized : Boolean; relativeoffset : Uint);
	TglVertexAttribIFormat* = PROCEDURE{WINAPI}(attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexAttribLFormat* = PROCEDURE{WINAPI}(attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexAttribBinding* = PROCEDURE{WINAPI}(attribindex : Uint; bindingindex : Uint);
	TglVertexBindingDivisor* = PROCEDURE{WINAPI}(bindingindex : Uint; divisor : Uint);
	TglVertexArrayBindVertexBufferEXT* = PROCEDURE{WINAPI}(vaobj : Uint; bindingindex : Uint; buffer : Uint; offset : Intptr; stride : Sizei);
	TglVertexArrayVertexAttribFormatEXT* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; normalized : Boolean; relativeoffset : Uint);
	TglVertexArrayVertexAttribIFormatEXT* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexArrayVertexAttribLFormatEXT* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexArrayVertexAttribBindingEXT* = PROCEDURE{WINAPI}(vaobj : Uint; attribindex : Uint; bindingindex : Uint);
	TglVertexArrayVertexBindingDivisorEXT* = PROCEDURE{WINAPI}(vaobj : Uint; bindingindex : Uint; divisor : Uint);
	(* GL_ARB_robustness_isolation  *)
	(* GL_ARB_cl_event  *)
	TglCreateSyncFromCLeventARB* = PROCEDURE{WINAPI}(context: cl_context; event: cl_event; flags: Bitfield): GLsync;
	(* GL_ARB_debug_output *)
	TglDebugMessageControlARB* = PROCEDURE{WINAPI}(source: Enum; xtype: Enum; severity: Enum; count: Sizei; ids: PUint; enabled: Boolean);
	TglDebugMessageInsertARB* = PROCEDURE{WINAPI}(source: Enum; xtype: Enum; id: Uint; severity: Enum; length: Sizei; buf: PChar);
	TglDebugMessageCallbackARB  = PROCEDURE{WINAPI}(callback: TglDebugProcARB; userParam: PVoid);
	TglGetDebugMessageLogARB* = PROCEDURE{WINAPI}(count: Uint; bufsize: Sizei; sources: PEnum; types: PEnum; ids: PUint; severities: PEnum; lengths: PSizei; messageLog: PChar): Uint;
	(* GL_ARB_robustness *)
	TglGetGraphicsResetStatusARB* = PROCEDURE{WINAPI}(): Enum;
	TglGetnMapdvARB* = PROCEDURE{WINAPI}(target: Enum; query: Enum; bufSize: Sizei; v: PDouble);
	TglGetnMapfvARB* = PROCEDURE{WINAPI}(target: Enum; query: Enum; bufSize: Sizei; v: PFloat);
	TglGetnMapivARB* = PROCEDURE{WINAPI}(target: Enum; query: Enum; bufSize: Sizei; v: PInt);
	TglGetnPixelMapfvARB* = PROCEDURE{WINAPI}(map: Enum; bufSize: Sizei; values: PFloat);
	TglGetnPixelMapuivARB* = PROCEDURE{WINAPI}(map: Enum; bufSize: Sizei; values: PUint);
	TglGetnPixelMapusvARB* = PROCEDURE{WINAPI}(map: Enum; bufSize: Sizei; values: PUshort);
	TglGetnPolygonStippleARB* = PROCEDURE{WINAPI}(bufSize: Sizei; pattern: PUbyte);
	TglGetnColorTableARB* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; bufSize: Sizei; table: PVoid);
	TglGetnConvolutionFilterARB* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; bufSize: Sizei; image: PVoid);
	TglGetnSeparableFilterARB* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; rowBufSize: Sizei; row: PVoid; columnBufSize: Sizei; column: PVoid; span: PVoid);
	TglGetnHistogramARB* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; bufSize: Sizei; values: PVoid);
	TglGetnMinmaxARB* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; bufSize: Sizei; values: PVoid);
	TglGetnTexImageARB* = PROCEDURE{WINAPI}(target: Enum; level: Int; format: Enum; xtype: Enum; bufSize: Sizei; img: PVoid);
	TglReadnPixelsARB* = PROCEDURE{WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; bufSize: Sizei; data: PVoid);
	TglGetnCompressedTexImageARB* = PROCEDURE{WINAPI}(target: Enum; lod: Int; bufSize: Sizei; img: PVoid);
	TglGetnUniformfvARB* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; bufSize: Sizei; params: PFloat);
	TglGetnUniformivARB* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; bufSize: Sizei; params: PInt);
	TglGetnUniformuivARB* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; bufSize: Sizei; params: PUint);
	TglGetnUniformdvARB* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; bufSize: Sizei; params: PDouble);
	(* GL_ATI_draw_buffers  *)
	TglDrawBuffersATI* = PROCEDURE{WINAPI}(n: Sizei; bufs: PEnum);
	(* GL_ATI_element_array  *)
	TglElementPointerATI* = PROCEDURE{WINAPI}(xtype: Enum; xpointer: PVoid);
	TglDrawElementArrayATI* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei);
	TglDrawRangeElementArrayATI* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; count: Sizei);
	(* GL_ATI_envmap_bumpmap  *)
	TglTexBumpParameterivATI* = PROCEDURE{WINAPI}(pname: Enum; param: PInt);
	TglTexBumpParameterfvATI* = PROCEDURE{WINAPI}(pname: Enum; param: PFloat);
	TglGetTexBumpParameterivATI* = PROCEDURE{WINAPI}(pname: Enum; param: PInt);
	TglGetTexBumpParameterfvATI* = PROCEDURE{WINAPI}(pname: Enum; param: PFloat);
	(* GL_ATI_fragment_shader  *)
	TglGenFragmentShadersATI* = PROCEDURE{WINAPI}(range: Uint): Uint;
	TglBindFragmentShaderATI* = PROCEDURE{WINAPI}(id: Uint);
	TglDeleteFragmentShaderATI* = PROCEDURE{WINAPI}(id: Uint);
	TglBeginFragmentShaderATI* = PROCEDURE{WINAPI}();
	TglEndFragmentShaderATI* = PROCEDURE{WINAPI}();
	TglPassTexCoordATI* = PROCEDURE{WINAPI}(dst: Uint; coord: Uint; swizzle: Enum);
	TglSampleMapATI* = PROCEDURE{WINAPI}(dst: Uint; interp: Uint; swizzle: Enum);
	TglColorFragmentOp1ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint);
	TglColorFragmentOp2ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint);
	TglColorFragmentOp3ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint; arg3: Uint; arg3Rep: Uint; arg3Mod: Uint);
	TglAlphaFragmentOp1ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint);
	TglAlphaFragmentOp2ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint);
	TglAlphaFragmentOp3ATI* = PROCEDURE{WINAPI}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint; arg3: Uint; arg3Rep: Uint; arg3Mod: Uint);
	TglSetFragmentShaderConstantATI* = PROCEDURE{WINAPI}(dst: Uint; value: PFloat);
	(* GL_ATI_map_object_buffer  *)
	TglMapObjectBufferATI* = PROCEDURE{WINAPI}(buffer: Uint): PVoid;
	TglUnmapObjectBufferATI* = PROCEDURE{WINAPI}(buffer: Uint);
	(* GL_ATI_pn_triangles  *)
	TglPNTrianglesiATI* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglPNTrianglesfATI* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	(* GL_ATI_separate_stencil  *)
	TglStencilOpSeparateATI* = PROCEDURE{WINAPI}(face: Enum; sfail: Enum; dpfail: Enum; dppass: Enum);
	TglStencilFuncSeparateATI* = PROCEDURE{WINAPI}(frontfunc: Enum; backfunc: Enum; ref: Int; mask: Uint);
	(* GL_ATI_vertex_array_object  *)
	TglNewObjectBufferATI* = PROCEDURE{WINAPI}(size: Sizei; xpointer: PVoid; usage: Enum): Uint;
	TglIsObjectBufferATI* = PROCEDURE{WINAPI}(buffer: Uint): Boolean;
	TglUpdateObjectBufferATI* = PROCEDURE{WINAPI}(buffer: Uint; offset: Uint; size: Sizei; xpointer: PVoid; preserve: Enum);
	TglGetObjectBufferfvATI* = PROCEDURE{WINAPI}(buffer: Uint; pname: Enum; params: PFloat);
	TglGetObjectBufferivATI* = PROCEDURE{WINAPI}(buffer: Uint; pname: Enum; params: PInt);
	TglFreeObjectBufferATI* = PROCEDURE{WINAPI}(buffer: Uint);
	TglArrayObjectATI* = PROCEDURE{WINAPI}(xarray: Enum; size: Int; xtype: Enum; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetArrayObjectfvATI* = PROCEDURE{WINAPI}(xarray: Enum; pname: Enum; params: PFloat);
	TglGetArrayObjectivATI* = PROCEDURE{WINAPI}(xarray: Enum; pname: Enum; params: PInt);
	TglVariantArrayObjectATI* = PROCEDURE{WINAPI}(id: Uint; xtype: Enum; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetVariantArrayObjectfvATI* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PFloat);
	TglGetVariantArrayObjectivATI* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt);
	(* GL_ATI_vertex_attrib_array_object  *)
	TglVertexAttribArrayObjectATI* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetVertexAttribArrayObjectfvATI* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribArrayObjectivATI* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	(* GL_ATI_vertex_streams  *)
	TglVertexStream1sATI* = PROCEDURE{WINAPI}(stream: Enum; x: Short);
	TglVertexStream1svATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PShort);
	TglVertexStream1iATI* = PROCEDURE{WINAPI}(stream: Enum; x: Int);
	TglVertexStream1ivATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PInt);
	TglVertexStream1fATI* = PROCEDURE{WINAPI}(stream: Enum; x: Float);
	TglVertexStream1fvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PFloat);
	TglVertexStream1dATI* = PROCEDURE{WINAPI}(stream: Enum; x: Double);
	TglVertexStream1dvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PDouble);
	TglVertexStream2sATI* = PROCEDURE{WINAPI}(stream: Enum; x: Short; y: Short);
	TglVertexStream2svATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PShort);
	TglVertexStream2iATI* = PROCEDURE{WINAPI}(stream: Enum; x: Int; y: Int);
	TglVertexStream2ivATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PInt);
	TglVertexStream2fATI* = PROCEDURE{WINAPI}(stream: Enum; x: Float; y: Float);
	TglVertexStream2fvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PFloat);
	TglVertexStream2dATI* = PROCEDURE{WINAPI}(stream: Enum; x: Double; y: Double);
	TglVertexStream2dvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PDouble);
	TglVertexStream3sATI* = PROCEDURE{WINAPI}(stream: Enum; x: Short; y: Short; z: Short);
	TglVertexStream3svATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PShort);
	TglVertexStream3iATI* = PROCEDURE{WINAPI}(stream: Enum; x: Int; y: Int; z: Int);
	TglVertexStream3ivATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PInt);
	TglVertexStream3fATI* = PROCEDURE{WINAPI}(stream: Enum; x: Float; y: Float; z: Float);
	TglVertexStream3fvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PFloat);
	TglVertexStream3dATI* = PROCEDURE{WINAPI}(stream: Enum; x: Double; y: Double; z: Double);
	TglVertexStream3dvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PDouble);
	TglVertexStream4sATI* = PROCEDURE{WINAPI}(stream: Enum; x: Short; y: Short; z: Short; w: Short);
	TglVertexStream4svATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PShort);
	TglVertexStream4iATI* = PROCEDURE{WINAPI}(stream: Enum; x: Int; y: Int; z: Int; w: Int);
	TglVertexStream4ivATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PInt);
	TglVertexStream4fATI* = PROCEDURE{WINAPI}(stream: Enum; x: Float; y: Float; z: Float; w: Float);
	TglVertexStream4fvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PFloat);
	TglVertexStream4dATI* = PROCEDURE{WINAPI}(stream: Enum; x: Double; y: Double; z: Double; w: Double);
	TglVertexStream4dvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PDouble);
	TglNormalStream3bATI* = PROCEDURE{WINAPI}(stream: Enum; nx: Byte; ny: Byte; nz: Byte);
	TglNormalStream3bvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PByte);
	TglNormalStream3sATI* = PROCEDURE{WINAPI}(stream: Enum; nx: Short; ny: Short; nz: Short);
	TglNormalStream3svATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PShort);
	TglNormalStream3iATI* = PROCEDURE{WINAPI}(stream: Enum; nx: Int; ny: Int; nz: Int);
	TglNormalStream3ivATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PInt);
	TglNormalStream3fATI* = PROCEDURE{WINAPI}(stream: Enum; nx: Float; ny: Float; nz: Float);
	TglNormalStream3fvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PFloat);
	TglNormalStream3dATI* = PROCEDURE{WINAPI}(stream: Enum; nx: Double; ny: Double; nz: Double);
	TglNormalStream3dvATI* = PROCEDURE{WINAPI}(stream: Enum; coords: PDouble);
	TglClientActiveVertexStreamATI* = PROCEDURE{WINAPI}(stream: Enum);
	TglVertexBlendEnviATI* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglVertexBlendEnvfATI* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	(* GL_AMD_performance_monitor  *)
	TglGetPerfMonitorGroupsAMD* = PROCEDURE{WINAPI}(numGroups: PInt; groupsSize: Sizei; groups: PUint);
	TglGetPerfMonitorCountersAMD* = PROCEDURE{WINAPI}(group: Uint; numCounters: PInt; maxActiveCouters: PInt; counterSize: Sizei; counters: PUint);
	TglGetPerfMonitorGroupStringAMD* = PROCEDURE{WINAPI}(group: Uint; bufSize: Sizei; length: PSizei; groupString: PChar);
	TglGetPerfMonitorCounterStringAMD* = PROCEDURE{WINAPI}(group: Uint; counter: Uint; bufSize: Sizei; length: PSizei; counterString: PChar);
	TglGetPerfMonitorCounterInfoAMD* = PROCEDURE{WINAPI}(group: Uint; counter: Uint; pname: Enum; data: ADDRESS);
	TglGenPerfMonitorsAMD* = PROCEDURE{WINAPI}(n: Sizei; monitors: PUint);
	TglDeletePerfMonitorsAMD* = PROCEDURE{WINAPI}(n: Sizei; monitors: PUint);
	TglSelectPerfMonitorCountersAMD* = PROCEDURE{WINAPI}(monitor: Uint; enable: Boolean; group: Uint; numCounters: Int; counterList: PUint);
	TglBeginPerfMonitorAMD* = PROCEDURE{WINAPI}(monitor: Uint);
	TglEndPerfMonitorAMD* = PROCEDURE{WINAPI}(monitor: Uint);
	TglGetPerfMonitorCounterDataAMD* = PROCEDURE{WINAPI}(monitor: Uint; pname: Enum; dataSize: Sizei; data: PUint; bytesWritten: PInt);
	(* GL_AMD_vertex_shader_tesselator  *)
	TglTessellationFactorAMD* = PROCEDURE{WINAPI}(factor: Float);
	TglTessellationModeAMD* = PROCEDURE{WINAPI}(mode: Enum);
	(* GL_AMD_draw_buffers_blend  *)
	TglBlendFuncIndexedAMD* = PROCEDURE{WINAPI}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparateIndexedAMD* = PROCEDURE{WINAPI}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);
	TglBlendEquationIndexedAMD* = PROCEDURE{WINAPI}(buf: Uint; mode: Enum);
	TglBlendEquationSeparateIndexedAMD* = PROCEDURE{WINAPI}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	(* GL_AMD_name_gen_delete  *)
	TglGenNamesAMD* = PROCEDURE{WINAPI}(identifier: Enum; num: Uint; names: PUint);
	TglDeleteNamesAMD* = PROCEDURE{WINAPI}(identifier: Enum; num: Uint; names: PUint);
	TglIsNameAMD* = PROCEDURE{WINAPI}(identifier: Enum; name: Uint): Boolean;
	(* GL_AMD_debug_output  *)
	TglDebugMessageEnableAMD* = PROCEDURE{WINAPI}(category: Enum; severity: Enum; count: Sizei; ids: PUint; enabled: Boolean);
	TglDebugMessageInsertAMD* = PROCEDURE{WINAPI}(category: Enum; severity: Enum; id: Uint; length: Sizei; buf: PChar);
	TglDebugMessageCallbackAMD  = PROCEDURE{WINAPI}(callback: TglDebugProcAMD; userParam: PVoid);
	TglGetDebugMessageLogAMD* = PROCEDURE{WINAPI}(count: Uint; bufsize: Sizei; categories: PEnum; severities: PUint; ids: PUint; lengths: PSizei; message: PChar): Uint;
	(* GL_EXT_blend_color  *)
	TglBlendColorEXT* = PROCEDURE{WINAPI}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	(* GL_EXT_blend_func_separate  *)
	TglBlendFuncSeparateEXT* = PROCEDURE{WINAPI}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);
	(* GL_EXT_blend_minmax  *)
	TglBlendEquationEXT* = PROCEDURE{WINAPI}(mode: Enum);
	(* GL_EXT_color_subtable  *)
	TglColorSubTableEXT* = PROCEDURE{WINAPI}(target: Enum; start: Sizei; count: Sizei; format: Enum; xtype: Enum; data: PVoid);
	TglCopyColorSubTableEXT* = PROCEDURE{WINAPI}(target: Enum; start: Sizei; x: Int; y: Int; width: Sizei);
	(* GL_EXT_compiled_vertex_array  *)
	TglLockArraysEXT* = PROCEDURE{WINAPI}(first: Int; count: Sizei);
	TglUnlockArraysEXT* = PROCEDURE{WINAPI}();
	(* GL_EXT_convolution  *)
	TglConvolutionFilter1DEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum; image: PVoid);
	TglConvolutionFilter2DEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum; image: PVoid);
	TglConvolutionParameterfEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: Float);
	TglConvolutionParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglConvolutionParameteriEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: Int);
	TglConvolutionParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglCopyConvolutionFilter1DEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglCopyConvolutionFilter2DEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetConvolutionFilterEXT* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; image: PVoid);
	TglGetConvolutionParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetConvolutionParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetSeparableFilterEXT* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; row: PVoid; column: PVoid; span: PVoid);
	TglSeparableFilter2DEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum; row: PVoid; column: PVoid);
	(* GL_EXT_coordinate_frame  *)
	TglTangent3bEXT* = PROCEDURE{WINAPI}(tx: Byte; ty: Byte; tz: Byte);
	TglTangent3bvEXT* = PROCEDURE{WINAPI}( v: PByte);
	TglTangent3dEXT* = PROCEDURE{WINAPI}(tx: Double; ty: Double; tz: Double);
	TglTangent3dvEXT* = PROCEDURE{WINAPI}( v: PDouble);
	TglTangent3fEXT* = PROCEDURE{WINAPI}(tx: Float; ty: Float; tz: Float);
	TglTangent3fvEXT* = PROCEDURE{WINAPI}( v: PFloat);
	TglTangent3iEXT* = PROCEDURE{WINAPI}(tx: Int; ty: Int; tz: Int);
	TglTangent3ivEXT* = PROCEDURE{WINAPI}( v: PInt);
	TglTangent3sEXT* = PROCEDURE{WINAPI}(tx: Short; ty: Short; tz: Short);
	TglTangent3svEXT* = PROCEDURE{WINAPI}( v: PShort);
	TglBinormal3bEXT* = PROCEDURE{WINAPI}(bx: Byte; by: Byte; bz: Byte);
	TglBinormal3bvEXT* = PROCEDURE{WINAPI}( v: PByte);
	TglBinormal3dEXT* = PROCEDURE{WINAPI}(bx: Double; by: Double; bz: Double);
	TglBinormal3dvEXT* = PROCEDURE{WINAPI}( v: PDouble);
	TglBinormal3fEXT* = PROCEDURE{WINAPI}(bx: Float; by: Float; bz: Float);
	TglBinormal3fvEXT* = PROCEDURE{WINAPI}( v: PFloat);
	TglBinormal3iEXT* = PROCEDURE{WINAPI}(bx: Int; by: Int; bz: Int);
	TglBinormal3ivEXT* = PROCEDURE{WINAPI}( v: PInt);
	TglBinormal3sEXT* = PROCEDURE{WINAPI}(bx: Short; by: Short; bz: Short);
	TglBinormal3svEXT* = PROCEDURE{WINAPI}( v: PShort);
	TglTangentPointerEXT* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglBinormalPointerEXT* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	(* GL_EXT_copy_texture  *)
	TglCopyTexImage1DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTexImage2DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTexSubImage1DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTexSubImage2DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglCopyTexSubImage3DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	(* GL_EXT_cull_vertex  *)
	TglCullParameterdvEXT* = PROCEDURE{WINAPI}(pname: Enum; params: PDouble);
	TglCullParameterfvEXT* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	(* GL_EXT_draw_range_elements  *)
	TglDrawRangeElementsEXT* = PROCEDURE{WINAPI}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum; indices: PVoid);
	(* GL_EXT_fog_coord  *)
	TglFogCoordfEXT* = PROCEDURE{WINAPI}(coord: Float);
	TglFogCoordfvEXT* = PROCEDURE{WINAPI}( coord: PFloat);
	TglFogCoorddEXT* = PROCEDURE{WINAPI}(coord: Double);
	TglFogCoorddvEXT* = PROCEDURE{WINAPI}( coord: PDouble);
	TglFogCoordPointerEXT* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	(* GL_EXT_framebuffer_object  *)
	TglIsRenderbufferEXT* = PROCEDURE{WINAPI}(renderbuffer: Uint): BOOLEAN;
	TglBindRenderbufferEXT* = PROCEDURE{WINAPI}(target: Enum; renderbuffer: Uint);
	TglDeleteRenderbuffersEXT* = PROCEDURE{WINAPI}(n: Sizei; renderbuffers: PUint);
	TglGenRenderbuffersEXT* = PROCEDURE{WINAPI}(n: Sizei; renderbuffers: PUint);
	TglRenderbufferStorageEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei);
	TglGetRenderbufferParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglIsFramebufferEXT* = PROCEDURE{WINAPI}(framebuffer: Uint): BOOLEAN;
	TglBindFramebufferEXT* = PROCEDURE{WINAPI}(target: Enum; framebuffer: Uint);
	TglDeleteFramebuffersEXT* = PROCEDURE{WINAPI}(n: Sizei; framebuffers: PUint);
	TglGenFramebuffersEXT* = PROCEDURE{WINAPI}(n: Sizei; framebuffers: PUint);
	TglCheckFramebufferStatusEXT* = PROCEDURE{WINAPI}(target: Enum): Enum;
	TglFramebufferTexture1DEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture2DEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture3DEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglFramebufferRenderbufferEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetFramebufferAttachmentParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; pname: Enum; params: PInt);
	TglGenerateMipmapEXT* = PROCEDURE{WINAPI}(target: Enum);
	(* GL_EXT_histogram  *)
	TglGetHistogramEXT* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetHistogramParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetHistogramParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetMinmaxEXT* = PROCEDURE{WINAPI}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetMinmaxParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetMinmaxParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglHistogramEXT* = PROCEDURE{WINAPI}(target: Enum; width: Sizei; internalformat: Enum; sink: Boolean);
	TglMinmaxEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; sink: Boolean);
	TglResetHistogramEXT* = PROCEDURE{WINAPI}(target: Enum);
	TglResetMinmaxEXT* = PROCEDURE{WINAPI}(target: Enum);
	(* GL_EXT_index_func  *)
	TglIndexFuncEXT* = PROCEDURE{WINAPI}(func: Enum; ref: Clampf);
	(* GL_EXT_index_material  *)
	TglIndexMaterialEXT* = PROCEDURE{WINAPI}(face: Enum; mode: Enum);
	(* GL_EXT_light_texture  *)
	TglApplyTextureEXT* = PROCEDURE{WINAPI}(mode: Enum);
	TglTextureLightEXT* = PROCEDURE{WINAPI}(pname: Enum);
	TglTextureMaterialEXT* = PROCEDURE{WINAPI}(face: Enum; mode: Enum);
	(* GL_EXT_multi_draw_arrays  *)
	TglMultiDrawArraysEXT* = PROCEDURE{WINAPI}(mode: Enum; first: PInt; count: PSizei; primcount: Sizei);
	TglMultiDrawElementsEXT* = PROCEDURE{WINAPI}(mode: Enum; count: PSizei; xtype: Enum; indices: PVoid; primcount: Sizei);
	(* GL_EXT_multisample  *)
	TglSampleMaskEXT* = PROCEDURE{WINAPI}(value: Clampf; invert: Boolean);
	TglSamplePatternEXT* = PROCEDURE{WINAPI}(pattern: Enum);
	(* GL_EXT_paletted_texture  *)
	TglColorTableEXT* = PROCEDURE{WINAPI}(target: Enum; internalFormat: Enum; width: Sizei; format: Enum; xtype: Enum; table: PVoid);
	TglGetColorTableEXT* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype: Enum; data: PVoid);
	TglGetColorTableParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetColorTableParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	(* GL_EXT_pixel_transform  *)
	TglPixelTransformParameteriEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Int);
	TglPixelTransformParameterfEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Float);
	TglPixelTransformParameterivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglPixelTransformParameterfvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	(* GL_EXT_point_parameters  *)
	TglPointParameterfEXT* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPointParameterfvEXT* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	(* GL_EXT_polygon_offset  *)
	TglPolygonOffsetEXT* = PROCEDURE{WINAPI}(factor: Float; bias: Float);
	(* GL_EXT_secondary_color  *)
	TglSecondaryColor3bEXT* = PROCEDURE{WINAPI}(red: Byte; green: Byte; blue: Byte);
	TglSecondaryColor3bvEXT* = PROCEDURE{WINAPI}( v: PByte);
	TglSecondaryColor3dEXT* = PROCEDURE{WINAPI}(red: Double; green: Double; blue: Double);
	TglSecondaryColor3dvEXT* = PROCEDURE{WINAPI}( v: PDouble);
	TglSecondaryColor3fEXT* = PROCEDURE{WINAPI}(red: Float; green: Float; blue: Float);
	TglSecondaryColor3fvEXT* = PROCEDURE{WINAPI}( v: PFloat);
	TglSecondaryColor3iEXT* = PROCEDURE{WINAPI}(red: Int; green: Int; blue: Int);
	TglSecondaryColor3ivEXT* = PROCEDURE{WINAPI}( v: PInt);
	TglSecondaryColor3sEXT* = PROCEDURE{WINAPI}(red: Short; green: Short; blue: Short);
	TglSecondaryColor3svEXT* = PROCEDURE{WINAPI}( v: PShort);
	TglSecondaryColor3ubEXT* = PROCEDURE{WINAPI}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglSecondaryColor3ubvEXT* = PROCEDURE{WINAPI}( v: PUbyte);
	TglSecondaryColor3uiEXT* = PROCEDURE{WINAPI}(red: Uint; green: Uint; blue: Uint);
	TglSecondaryColor3uivEXT* = PROCEDURE{WINAPI}( v: PUint);
	TglSecondaryColor3usEXT* = PROCEDURE{WINAPI}(red: Ushort; green: Ushort; blue: Ushort);
	TglSecondaryColor3usvEXT* = PROCEDURE{WINAPI}( v: PUshort);
	TglSecondaryColorPointerEXT* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	(* GL_EXT_stencil_two_side  *)
	TglActiveStencilFaceEXT* = PROCEDURE{WINAPI}(face: Enum);
	(* GL_EXT_subtexture  *)
	TglTexSubImage1DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglTexSubImage2DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	(* GL_EXT_texture3D  *)
	TglTexImage3DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTexSubImage3DEXT* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	(* GL_EXT_texture_object  *)
	TglAreTexturesResidentEXT* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint; residences: PBoolean): Boolean;
	TglBindTextureEXT* = PROCEDURE{WINAPI}(target: Enum; texture: Uint);
	TglDeleteTexturesEXT* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint);
	TglGenTexturesEXT* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint);
	TglIsTextureEXT* = PROCEDURE{WINAPI}(texture: Uint): Boolean;
	TglPrioritizeTexturesEXT* = PROCEDURE{WINAPI}(n: Sizei; textures: PUint; priorities: PClampf);
	(* GL_EXT_texture_perturb_normal  *)
	TglTextureNormalEXT* = PROCEDURE{WINAPI}(mode: Enum);
	(* GL_EXT_vertex_array  *)
	TglArrayElementEXT* = PROCEDURE{WINAPI}(i: Int);
	TglColorPointerEXT* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; count: Sizei; xpointer: PVoid);
	TglDrawArraysEXT* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei);
	TglEdgeFlagPointerEXT* = PROCEDURE{WINAPI}(stride: Sizei; count: Sizei; xpointer: PBoolean);
	TglGetPointervEXT* = PROCEDURE{WINAPI}(pname: Enum; params: PVoid);
	TglIndexPointerEXT* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; count: Sizei; xpointer: PVoid);
	TglNormalPointerEXT* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei; count: Sizei; xpointer: PVoid);
	TglTexCoordPointerEXT* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; count: Sizei; xpointer: PVoid);
	TglVertexPointerEXT* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei; count: Sizei; xpointer: PVoid);
	(* GL_EXT_vertex_shader  *)
	TglBeginVertexShaderEXT* = PROCEDURE{WINAPI}();
	TglEndVertexShaderEXT* = PROCEDURE{WINAPI}();
	TglBindVertexShaderEXT* = PROCEDURE{WINAPI}(id: Uint);
	TglGenVertexShadersEXT* = PROCEDURE{WINAPI}(range: Uint): Uint;
	TglDeleteVertexShaderEXT* = PROCEDURE{WINAPI}(id: Uint);
	TglShaderOp1EXT* = PROCEDURE{WINAPI}(op: Enum; res: Uint; arg1: Uint);
	TglShaderOp2EXT* = PROCEDURE{WINAPI}(op: Enum; res: Uint; arg1: Uint; arg2: Uint);
	TglShaderOp3EXT* = PROCEDURE{WINAPI}(op: Enum; res: Uint; arg1: Uint; arg2: Uint; arg3: Uint);
	TglSwizzleEXT* = PROCEDURE{WINAPI}(res: Uint; inVal: Uint; outX: Enum; outY: Enum; outZ: Enum; outW: Enum);
	TglWriteMaskEXT* = PROCEDURE{WINAPI}(res: Uint; inVal: Uint; outX: Enum; outY: Enum; outZ: Enum; outW: Enum);
	TglInsertComponentEXT* = PROCEDURE{WINAPI}(res: Uint; src: Uint; num: Uint);
	TglExtractComponentEXT* = PROCEDURE{WINAPI}(res: Uint; src: Uint; num: Uint);
	TglGenSymbolsEXT* = PROCEDURE{WINAPI}(datatype: Enum; storagetype: Enum; range: Enum; components: Uint): Uint;
	TglSetInvariantEXT* = PROCEDURE{WINAPI}(id: Uint; xtype: Enum; addr: PVoid);
	TglSetLocalConstantEXT* = PROCEDURE{WINAPI}(id: Uint; xtype: Enum; addr: PVoid);
	TglVariantbvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PByte);
	TglVariantsvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PShort);
	TglVariantivEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PInt);
	TglVariantfvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PFloat);
	TglVariantdvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PDouble);
	TglVariantubvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PUbyte);
	TglVariantusvEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PUshort);
	TglVariantuivEXT* = PROCEDURE{WINAPI}(id: Uint; addr: PUint);
	TglVariantPointerEXT* = PROCEDURE{WINAPI}(id: Uint; xtype: Enum; stride: Uint; addr: PVoid);
	TglEnableVariantClientStateEXT* = PROCEDURE{WINAPI}(id: Uint);
	TglDisableVariantClientStateEXT* = PROCEDURE{WINAPI}(id: Uint);
	TglBindLightParameterEXT* = PROCEDURE{WINAPI}(light: Enum; value: Enum): Uint;
	TglBindMaterialParameterEXT* = PROCEDURE{WINAPI}(face: Enum; value: Enum): Uint;
	TglBindTexGenParameterEXT* = PROCEDURE{WINAPI}(xunit: Enum; coord: Enum; value: Enum): Uint;
	TglBindTextureUnitParameterEXT* = PROCEDURE{WINAPI}( xunit: Enum; value: Enum): Uint;
	TglBindParameterEXT* = PROCEDURE{WINAPI}(value: Enum): Uint;
	TglIsVariantEnabledEXT* = PROCEDURE{WINAPI}(id: Uint; cap: Enum): Boolean;
	TglGetVariantBooleanvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PBoolean);
	TglGetVariantIntegervEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PInt);
	TglGetVariantFloatvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PFloat);
	TglGetVariantPointervEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PVoid);
	TglGetInvariantBooleanvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PBoolean);
	TglGetInvariantIntegervEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PInt);
	TglGetInvariantFloatvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PFloat);
	TglGetLocalConstantBooleanvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PBoolean);
	TglGetLocalConstantIntegervEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PInt);
	TglGetLocalConstantFloatvEXT* = PROCEDURE{WINAPI}(id: Uint; value: Enum; data: PFloat);
	(* GL_EXT_vertex_weighting  *)
	TglVertexWeightfEXT* = PROCEDURE{WINAPI}(weight: Float);
	TglVertexWeightfvEXT* = PROCEDURE{WINAPI}( weight: PFloat);
	TglVertexWeightPointerEXT* = PROCEDURE{WINAPI}(size: Sizei; xtype: Enum; stride: Sizei; xpointer: PVoid);
	(* GL_EXT_stencil_clear_tag  *)
	TglStencilClearTagEXT* = PROCEDURE{WINAPI}(stencilTagBits: Sizei; stencilClearTag: Uint);
	(* GL_EXT_framebuffer_blit  *)
	TglBlitFramebufferEXT* = PROCEDURE{WINAPI}(srcX0: Int; srcY0: Int; srcX1: Int; srcY1: Int; dstX0: Int; dstY0: Int; dstX1: Int; dstY1: Int; mask: Bitfield; filter: Enum);
	(* GL_EXT_framebuffer_multisample  *)
	TglRenderbufferStorageMultisampleEXT* = PROCEDURE{WINAPI}(target: Enum; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	(* GL_EXT_timer_query  *)
	TglGetQueryObjecti64vEXT* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt64EXT);
	TglGetQueryObjectui64vEXT* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PUint64EXT);
	(* GL_EXT_gpu_program_parameters  *)
	TglProgramEnvParameters4fvEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PFloat);
	TglProgramLocalParameters4fvEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PFloat);
	(* GL_EXT_bindable_uniform  *)
	TglUniformBufferEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; buffer: Uint);
	TglGetUniformBufferSizeEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int): Int;
	TglGetUniformOffsetEXT* = PROCEDURE{WINAPI}( xprogram: Uint; location: Int): PInt;
	(* GL_EXT_draw_buffers2  *)
	TglColorMaskIndexedEXT* = PROCEDURE{WINAPI}(buf: Uint; r: Boolean; g: Boolean; b: Boolean; a: Boolean);
	TglGetBooleanIndexedvEXT* = PROCEDURE{WINAPI}(value: Enum; index: Uint; data: PBoolean);
	TglGetIntegerIndexedvEXT* = PROCEDURE{WINAPI}(value: Enum; index: Uint; data: PInt);
	TglEnableIndexedEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint);
	TglDisableIndexedEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint);
	TglIsEnabledIndexedEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint): Boolean;
	(* GL_EXT_draw_instanced  *)
	TglDrawArraysInstancedEXT* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstancedEXT* = PROCEDURE{WINAPI}(mode: Enum; count: Sizei; xtype: Enum; indices: ADDRESS; primcount: Sizei);
	(* GL_EXT_geometry_shader4  *)
	TglProgramParameteriEXT* = PROCEDURE{WINAPI}(xprogram: Uint; pname: Enum; value: Int);
	TglFramebufferTextureEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	(*  TglFramebufferTextureLayerEXT  = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);  *)
	TglFramebufferTextureFaceEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum);
	(* GL_EXT_gpu_shader4  *)
	TglVertexAttribI1iEXT* = PROCEDURE{WINAPI}(index: Uint; x: Int);
	TglVertexAttribI2iEXT* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int);
	TglVertexAttribI3iEXT* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int; z: Int);
	TglVertexAttribI4iEXT* = PROCEDURE{WINAPI}(index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglVertexAttribI1uiEXT* = PROCEDURE{WINAPI}(index: Uint; x: Uint);
	TglVertexAttribI2uiEXT* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint);
	TglVertexAttribI3uiEXT* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint; z: Uint);
	TglVertexAttribI4uiEXT* = PROCEDURE{WINAPI}(index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglVertexAttribI1ivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI2ivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI3ivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI4ivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PInt);
	TglVertexAttribI1uivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI2uivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI3uivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI4uivEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUint);
	TglVertexAttribI4bvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PByte);
	TglVertexAttribI4svEXT* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttribI4ubvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttribI4usvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PUshort);
	TglVertexAttribIPointerEXT* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei; xpointer: ADDRESS);
	TglGetVertexAttribIivEXT* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribIuivEXT* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PUint);
	TglUniform1uiEXT* = PROCEDURE{WINAPI}(location: Int; v0: Uint);
	TglUniform2uiEXT* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint);
	TglUniform3uiEXT* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglUniform4uiEXT* = PROCEDURE{WINAPI}(location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglUniform1uivEXT* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform2uivEXT* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform3uivEXT* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglUniform4uivEXT* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint);
	TglGetUniformuivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; params: PUint);
	TglBindFragDataLocationEXT* = PROCEDURE{WINAPI}(xprogram: Uint; colorNumber: Uint; CONST name: ARRAY OF CHAR);
	TglGetFragDataLocationEXT* = PROCEDURE{WINAPI}(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
	(* GL_EXT_texture_array  *)
	TglFramebufferTextureLayerEXT* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	(* GL_EXT_texture_buffer_object  *)
	TglTexBufferEXT* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; buffer: Uint);
	(* GL_EXT_texture_integer  *)
	TglClearColorIiEXT* = PROCEDURE{WINAPI}(r: Int; g: Int; b: Int; a: Int);
	TglClearColorIuiEXT* = PROCEDURE{WINAPI}(r: Uint; g: Uint; b: Uint; a: Uint);
	TglTexParameterIivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglTexParameterIuivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PUint);
	TglGetTexParameterIivEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetTexParameterIiuvEXT* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PUint);
	(* GL_HP_image_transform  *)
	TglImageTransformParameteriHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Int);
	TglImageTransformParameterfHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; param: Float);
	TglImageTransformParameterivHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglImageTransformParameterfvHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetImageTransformParameterivHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetImageTransformParameterfvHP* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	(* GL_EXT_depth_bounds_test  *)
	TglDepthBoundsEXT* = PROCEDURE{WINAPI}(zmin: Clampd; zmax: Clampd);
	(* GL_EXT_blend_equation_separate  *)
	TglBlendEquationSeparateEXT* = PROCEDURE{WINAPI}(modeRGB: Enum; modeAlpha: Enum);
	(* GL_EXT_transform_feedback  *)
	TglBeginTransformFeedbackEXT* = PROCEDURE{WINAPI}(primitiveMode: Enum);
	TglEndTransformFeedbackEXT* = PROCEDURE{WINAPI}();
	TglBindBufferRangeEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint; offset: Sizei; size: Sizei);
	TglBindBufferOffsetEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint; offset: Sizei);
	TglBindBufferBaseEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryingsEXT* = PROCEDURE{WINAPI}(xprogram: Uint; count: Sizei; locations: PInt; bufferMode: Enum);
	TglGetTransformFeedbackVaryingEXT* = PROCEDURE{WINAPI}(xprogram: Uint; index: Uint; location: PInt);
	(* GL_EXT_direct_state_access  *)
	TglClientAttribDefaultEXT* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglPushClientAttribDefaultEXT* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglMatrixLoadfEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PFloat);
	TglMatrixLoaddEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PDouble);
	TglMatrixMultfEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PFloat);
	TglMatrixMultdEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PDouble);
	TglMatrixLoadIdentityEXT* = PROCEDURE{WINAPI}(mode: Enum);
	TglMatrixRotatefEXT* = PROCEDURE{WINAPI}(mode: Enum; angle: Float; x: Float; y: Float; z: Float);
	TglMatrixRotatedEXT* = PROCEDURE{WINAPI}(mode: Enum; angle: Double; x: Double; y: Double; z: Double);
	TglMatrixScalefEXT* = PROCEDURE{WINAPI}(mode: Enum; x: Float; y: Float; z: Float);
	TglMatrixScaledEXT* = PROCEDURE{WINAPI}(mode: Enum; x: Double; y: Double; z: Double);
	TglMatrixTranslatefEXT* = PROCEDURE{WINAPI}(mode: Enum; x: Float; y: Float; z: Float);
	TglMatrixTranslatedEXT* = PROCEDURE{WINAPI}(mode: Enum; x: Double; y: Double; z: Double);
	TglMatrixFrustumEXT* = PROCEDURE{WINAPI}(mode: Enum; left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglMatrixOrthoEXT* = PROCEDURE{WINAPI}(mode: Enum; left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglMatrixPopEXT* = PROCEDURE{WINAPI}(mode: Enum);
	TglMatrixPushEXT* = PROCEDURE{WINAPI}(mode: Enum);
	TglMatrixLoadTransposefEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PFloat);
	TglMatrixLoadTransposedEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PDouble);
	TglMatrixMultTransposefEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PFloat);
	TglMatrixMultTransposedEXT* = PROCEDURE{WINAPI}(mode: Enum; m: PDouble);
	TglTextureParameterfEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; param: Float);
	TglTextureParameterfvEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PFloat);
	TglTextureParameteriEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; param: Int);
	TglTextureParameterivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglTextureImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTextureImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTextureSubImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglTextureSubImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglCopyTextureImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTextureImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTextureSubImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTextureSubImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetTextureImageEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetTextureParameterfvEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PFloat);
	TglGetTextureParameterivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglGetTextureLevelParameterfvEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetTextureLevelParameterivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; pname: Enum; params: Int);
	TglTextureImage3DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglTextureSubImage3DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglCopyTextureSubImage3DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglMultiTexParameterfEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexParameterfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglMultiTexParameteriEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexParameterivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PInt);
	TglMultiTexImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglMultiTexImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglMultiTexSubImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglMultiTexSubImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglCopyMultiTexImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyMultiTexImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyMultiTexSubImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyMultiTexSubImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetMultiTexImageEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetMultiTexParameterfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexParameterivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PInt);
	TglGetMultiTexLevelParameterfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetMultiTexLevelParameterivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; pname: Enum; params: PInt);
	TglMultiTexImage3DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglMultiTexSubImage3DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum; pixels:PVoid);
	TglCopyMultiTexSubImage3DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglBindMultiTextureEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; texture: Uint);
	TglEnableClientStateIndexedEXT* = PROCEDURE{WINAPI}(xarray: Enum; index: Uint);
	TglDisableClientStateIndexedEXT* = PROCEDURE{WINAPI}(xarray: Enum; index: Uint);
	TglMultiTexCoordPointerEXT* = PROCEDURE{WINAPI}(texunit: Enum; size: Int; xtype: Enum; stride: Sizei; pointer: PVoid);
	TglMultiTexEnvfEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexEnvfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglMultiTexEnviEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexEnvivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PInt);
	TglMultiTexGendEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Double);
	TglMultiTexGendvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PDouble);
	TglMultiTexGenfEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexGenfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglMultiTexGeniEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexGenivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PInt);
	TglGetMultiTexEnvfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexEnvivEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; pname: Enum; params: PInt);
	TglGetMultiTexGendvEXT* = PROCEDURE{WINAPI}(texunit: Enum; coord: Enum; pname: Enum; params: PDouble);
	TglGetMultiTexGenfvEXT* = PROCEDURE{WINAPI}(texunit: Enum; coord: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexGenivEXT* = PROCEDURE{WINAPI}(texunit: Enum; coord: Enum; pname: Enum; params: PInt);
	TglGetFloatIndexedvEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PFloat);
	TglGetDoubleIndexedvEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PDouble);
	TglGetPointerIndexedvEXT* = PROCEDURE{WINAPI}(target: Enum; index: Uint; data: PPVoid);
	TglCompressedTextureImage3DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedTextureImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedTextureImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedTextureSubImage3DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglCompressedTextureSubImage2DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglCompressedTextureSubImage1DEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglGetCompressedTextureImageEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; lod: Int; img: PVoid);
	TglCompressedMultiTexImage3DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedMultiTexImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedMultiTexImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei; bits: PVoid);
	TglCompressedMultiTexSubImage3DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglCompressedMultiTexSubImage2DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglCompressedMultiTexSubImage1DEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei; bits: PVoid);
	TglGetCompressedMultiTexImageEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; lod: Int; img: PVoid);
	TglNamedProgramStringEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; format: Enum; len: Sizei; xstring: PVoid);
	TglNamedProgramLocalParameter4dEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglNamedProgramLocalParameter4dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PDouble);
	TglNamedProgramLocalParameter4fEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglNamedProgramLocalParameter4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PFloat);
	TglGetNamedProgramLocalParameterdvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PDouble);
	TglGetNamedProgramLocalParameterfvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PFloat);
	TglGetNamedProgramivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; pname: Enum; params: PInt);
	TglGetNamedProgramStringEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; pname: Enum; xstring: PVoid);
	TglNamedProgramLocalParameters4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; count: Sizei; params: PFloat);
	TglNamedProgramLocalParameterI4iEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglNamedProgramLocalParameterI4ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PInt);
	TglNamedProgramLocalParametersI4ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; count: Sizei; params: PInt);
	TglNamedProgramLocalParameterI4uiEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglNamedProgramLocalParameterI4uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PUint);
	TglNamedProgramLocalParametersI4uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; count: Sizei; params: PUint);
	TglGetNamedProgramLocalParameterIivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PInt);
	TglGetNamedProgramLocalParameterIuivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; target: Enum; index: Uint; params: PUint);
	TglTextureParameterIivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglTextureParameterIuivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PUint);
	TglGetTextureParameterIivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglGetTextureParameterIuivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PUint);
	TglMultiTexParameterIivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglMultiTexParameterIuivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PUint);
	TglGetMultiTexParameterIivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglGetMultiTexParameterIuivEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; pname: Enum; params: PUint);
	TglProgramUniform1fEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float);
	TglProgramUniform2fEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float);
	TglProgramUniform3fEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float);
	TglProgramUniform4fEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float; v3: Float);
	TglProgramUniform1iEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int);
	TglProgramUniform2iEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int);
	TglProgramUniform3iEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int);
	TglProgramUniform4iEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int; v3: Int);
	TglProgramUniform1fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform2fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform3fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PFloat);
	TglProgramUniform1ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform2ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform3ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniform4ivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt);
	TglProgramUniformMatrix2fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix2x3fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3x2fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix2x4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4x2fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix3x4fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniformMatrix4x3fvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglProgramUniform1uiEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint);
	TglProgramUniform2uiEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint);
	TglProgramUniform3uiEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglProgramUniform4uiEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglProgramUniform1uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform2uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform3uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglProgramUniform4uivEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint);
	TglNamedBufferDataEXT* = PROCEDURE{WINAPI}(buffer: Uint; size: Sizei; data: PVoid; usage: Enum);
	TglNamedBufferSubDataEXT* = PROCEDURE{WINAPI}(buffer: Uint; offset: Intptr; size: Sizeiptr; data: PVoid);
	TglMapNamedBufferEXT* = PROCEDURE{WINAPI}(buffer: Uint; access: Enum): PVoid;
	TglUnmapNamedBufferEXT* = PROCEDURE{WINAPI}(buffer: Uint): Boolean;
	TglMapNamedBufferRangeEXT* = PROCEDURE{WINAPI}(buffer: Uint; offset: Intptr; length: Sizeiptr; access: Bitfield): PVoid;
	TglFlushMappedNamedBufferRangeEXT* = PROCEDURE{WINAPI}(buffer: Uint; offset: Intptr; length: Sizeiptr);
	TglNamedCopyBufferSubDataEXT* = PROCEDURE{WINAPI}(readBuffer: Uint; writeBuffer: Uint; readOffset: Intptr; writeOffset: Intptr; size: Sizeiptr);
	TglGetNamedBufferParameterivEXT* = PROCEDURE{WINAPI}(buffer: Uint; pname: Enum; params: PInt);
	TglGetNamedBufferPointervEXT* = PROCEDURE{WINAPI}(buffer: Uint; pname: Enum; params: PPVoid);
	TglGetNamedBufferSubDataEXT* = PROCEDURE{WINAPI}(buffer: Uint; offset: Intptr; size: Sizeiptr; data: PVoid);
	TglTextureBufferEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; internalformat: Enum; buffer: Uint);
	TglMultiTexBufferEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; interformat: Enum; buffer: Uint);
	TglNamedRenderbufferStorageEXT* = PROCEDURE{WINAPI}(renderbuffer: Uint; interformat: Enum; width: Sizei; height: Sizei);
	TglGetNamedRenderbufferParameterivEXT* = PROCEDURE{WINAPI}(renderbuffer: Uint; pname: Enum; params: PInt);
	TglCheckNamedFramebufferStatusEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; target: Enum): Enum;
	TglNamedFramebufferTexture1DEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTexture2DEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTexture3DEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglNamedFramebufferRenderbufferEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetNamedFramebufferAttachmentParameterivEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; pname: Enum; params: PInt);
	TglGenerateTextureMipmapEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum);
	TglGenerateMultiTexMipmapEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum);
	TglFramebufferDrawBufferEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; mode: Enum);
	TglFramebufferDrawBuffersEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; n: Sizei; bufs: PEnum);
	TglFramebufferReadBufferEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; mode: Enum);
	TglGetFramebufferParameterivEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; pname: Enum; params: PInt);
	TglNamedRenderbufferStorageMultisampleEXT* = PROCEDURE{WINAPI}(renderbuffer: Uint; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglNamedRenderbufferStorageMultisampleCoverageEXT* = PROCEDURE{WINAPI}(renderbuffer: Uint; coverageSamples: Sizei; colorSamples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglNamedFramebufferTextureEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTextureLayerEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int; layer: Int);
	TglNamedFramebufferTextureFaceEXT* = PROCEDURE{WINAPI}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int; face: Enum);
	TglTextureRenderbufferEXT* = PROCEDURE{WINAPI}(texture: Uint; target: Enum; renderbuffer: Uint);
	TglMultiTexRenderbufferEXT* = PROCEDURE{WINAPI}(texunit: Enum; target: Enum; renderbuffer: Uint);
	TglProgramUniform1dEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Double);
	TglProgramUniform2dEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Double; y: Double);
	TglProgramUniform3dEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Double; y: Double; z: Double);
	TglProgramUniform4dEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Double; y: Double; z: Double; w: Double);
	TglProgramUniform1dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform2dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform3dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniform4dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PDouble);
	TglProgramUniformMatrix2dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix2x3dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix2x4dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3x2dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix3x4dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4x2dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	TglProgramUniformMatrix4x3dvEXT* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean; value: PDouble);
	(* GL_EXT_separate_shader_objects  *)
	TglUseShaderProgramEXT* = PROCEDURE{WINAPI}(xtype: Enum; xprogram: Uint);
	TglActiveProgramEXT* = PROCEDURE{WINAPI}(xprogram: Uint);
	TglCreateShaderProgramEXT* = PROCEDURE{WINAPI}(xtype: Enum; CONST xstring: ARRAY OF CHAR): Uint;
	(* GL_EXT_shader_image_load_store  *)
	TglBindImageTextureEXT* = PROCEDURE{WINAPI}(index: Uint; texture: Uint; level: Int; layered: Boolean; layer: Int; access: Enum; format: Int);
	TglMemoryBarrierEXT* = PROCEDURE{WINAPI}(barriers: Bitfield);
	(* GL_EXT_vertex_attrib_64bit  *)
	TglVertexAttribL1dEXT* = PROCEDURE{WINAPI}(index: Uint; x: Double);
	TglVertexAttribL2dEXT* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double);
	TglVertexAttribL3dEXT* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttribL4dEXT* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttribL1dvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL2dvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL3dvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribL4dvEXT* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttribLPointerEXT* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei; pointer: PVoid);
	TglGetVertexAttribLdvEXT* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PDouble);
	TglVertexArrayVertexAttribLOffsetEXT* = PROCEDURE{WINAPI}(vaobj: Uint; buffer: Uint; index: Uint; size: Int; xtype: Enum; stride: Sizei; offset: Intptr);
	(*  GL_IBM_multimode_draw_arrays  *)
	TglMultiModeDrawArraysIBM* = PROCEDURE{WINAPI}(mode: Enum; first: PInt; count: PSizei; primcount: Sizei; modestride: Int);
	TglMultiModeDrawElementsIBM* = PROCEDURE{WINAPI}(mode: PEnum; count: PSizei; xtype:  Enum; indices: PVoid; primcount: Sizei; modestride: Int);
	(*  GL_IBM_vertex_array_lists  *)
	TglColorPointerListIBM* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglSecondaryColorPointerListIBM* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglEdgeFlagPointerListIBM* = PROCEDURE{WINAPI}(stride: Int; xpointer: PBoolean; ptrstride: Int);
	TglFogCoordPointerListIBM* = PROCEDURE{WINAPI}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglIndexPointerListIBM* = PROCEDURE{WINAPI}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglNormalPointerListIBM* = PROCEDURE{WINAPI}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglTexCoordPointerListIBM* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglVertexPointerListIBM* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	(*  GL_INGR_blend_func_separate  *)
	TglBlendFuncSeparateINGR* = PROCEDURE{WINAPI}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);

	(* GL_INTEL_framebuffer_CMAA *)
	TglApplyFramebufferAttachmentCMAAINTEL* = PROCEDURE{WINAPI}();

	(*  GL_INTEL_parallel_arrays  *)
	TglVertexPointervINTEL* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; xpointer: PVoid);
	TglNormalPointervINTEL* = PROCEDURE{WINAPI}(xtype:  Enum; xpointer: PVoid);
	TglColorPointervINTEL* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; xpointer: PVoid);
	TglTexCoordPointervINTEL* = PROCEDURE{WINAPI}(size: Int; xtype:  Enum; xpointer: PVoid);
	(*  GL_MESA_resize_buffers  *)
	TglResizeBuffersMESA* = PROCEDURE{WINAPI}();
	(* GL_MESA_window_pos  *)
	TglWindowPos2dMESA* = PROCEDURE{WINAPI}(x: Double; y: Double);
	TglWindowPos2dvMESA* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos2fMESA* = PROCEDURE{WINAPI}(x: Float; y: Float);
	TglWindowPos2fvMESA* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos2iMESA* = PROCEDURE{WINAPI}(x: Int; y: Int);
	TglWindowPos2ivMESA* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos2sMESA* = PROCEDURE{WINAPI}(x: Short; y: Short);
	TglWindowPos2svMESA* = PROCEDURE{WINAPI}( v: PShort);
	TglWindowPos3dMESA* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double);
	TglWindowPos3dvMESA* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos3fMESA* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float);
	TglWindowPos3fvMESA* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos3iMESA* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int);
	TglWindowPos3ivMESA* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos3sMESA* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short);
	TglWindowPos3svMESA* = PROCEDURE{WINAPI}( v: PShort);
	TglWindowPos4dMESA* = PROCEDURE{WINAPI}(x: Double; y: Double; z: Double; w: Double);
	TglWindowPos4dvMESA* = PROCEDURE{WINAPI}( v: PDouble);
	TglWindowPos4fMESA* = PROCEDURE{WINAPI}(x: Float; y: Float; z: Float; w: Float);
	TglWindowPos4fvMESA* = PROCEDURE{WINAPI}( v: PFloat);
	TglWindowPos4iMESA* = PROCEDURE{WINAPI}(x: Int; y: Int; z: Int; w: Int);
	TglWindowPos4ivMESA* = PROCEDURE{WINAPI}( v: PInt);
	TglWindowPos4sMESA* = PROCEDURE{WINAPI}(x: Short; y: Short; z: Short; w: Short);
	TglWindowPos4svMESA* = PROCEDURE{WINAPI}( v: PShort);
	(* GL_NV_evaluators  *)
	TglMapControlPointsNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; xtype: Enum; ustride: Sizei; vstride: Sizei; uorder: Int; vorder: Int; packed: Boolean; points: PVoid);
	TglMapParameterivNV* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglMapParameterfvNV* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetMapControlPointsNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; xtype: Enum; ustride: Sizei; vstride: Sizei; packed: Boolean; points: PVoid);
	TglGetMapParameterivNV* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglGetMapParameterfvNV* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetMapAttribParameterivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; pname: Enum; params: PInt);
	TglGetMapAttribParameterfvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; pname: Enum; params: PFloat);
	TglEvalMapsNV* = PROCEDURE{WINAPI}(target: Enum; mode: Enum);
	(* GL_NV_fence  *)
	TglDeleteFencesNV* = PROCEDURE{WINAPI}(n: Sizei; fences: PUint);
	TglGenFencesNV* = PROCEDURE{WINAPI}(n: Sizei; fences: PUint);
	TglIsFenceNV* = PROCEDURE{WINAPI}(fence: Uint): Boolean;
	TglTestFenceNV* = PROCEDURE{WINAPI}(fence: Uint): Boolean;
	TglGetFenceivNV* = PROCEDURE{WINAPI}(fence: Uint; pname: Enum; params: PInt);
	TglFinishFenceNV* = PROCEDURE{WINAPI}(fence: Uint);
	TglSetFenceNV* = PROCEDURE{WINAPI}(fence: Uint; condition: Enum);
	(* GL_NV_fragment_program  *)
	TglProgramNamedParameter4fNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; x: Float; y: Float; z: Float; w: Float);
	TglProgramNamedParameter4dNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; x: Double; y: Double; z: Double; w: Double);
	TglProgramNamedParameter4fvNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; v: PFloat);
	TglProgramNamedParameter4dvNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; v: PDouble);
	TglGetProgramNamedParameterfvNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; params: PFloat);
	TglGetProgramNamedParameterdvNV* = PROCEDURE{WINAPI}(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; params: PDouble);
	(* GL_NV_half_float  *)
	TglVertex2hNV* = PROCEDURE{WINAPI}(x: HalfNV; y: HalfNV);
	TglVertex2hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglVertex3hNV* = PROCEDURE{WINAPI}(x: HalfNV; y: HalfNV; z: HalfNV);
	TglVertex3hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglVertex4hNV* = PROCEDURE{WINAPI}(x: HalfNV; y: HalfNV; z: HalfNV; w: HalfNV);
	TglVertex4hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglNormal3hNV* = PROCEDURE{WINAPI}(nx: HalfNV; ny: HalfNV; nz: HalfNV);
	TglNormal3hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglColor3hNV* = PROCEDURE{WINAPI}(red: HalfNV; green: HalfNV; blue: HalfNV);
	TglColor3hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglColor4hNV* = PROCEDURE{WINAPI}(red: HalfNV; green: HalfNV; blue: HalfNV; alpha: HalfNV);
	TglColor4hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglTexCoord1hNV* = PROCEDURE{WINAPI}(s: HalfNV);
	TglTexCoord1hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglTexCoord2hNV* = PROCEDURE{WINAPI}(s: HalfNV; t: HalfNV);
	TglTexCoord2hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglTexCoord3hNV* = PROCEDURE{WINAPI}(s: HalfNV; t: HalfNV; r: HalfNV);
	TglTexCoord3hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglTexCoord4hNV* = PROCEDURE{WINAPI}(s: HalfNV; t: HalfNV; r: HalfNV; q: HalfNV);
	TglTexCoord4hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglMultiTexCoord1hNV* = PROCEDURE{WINAPI}(target: Enum; s: HalfNV);
	TglMultiTexCoord1hvNV* = PROCEDURE{WINAPI}(target: Enum; v: PHalfNV);
	TglMultiTexCoord2hNV* = PROCEDURE{WINAPI}(target: Enum; s: HalfNV; t: HalfNV);
	TglMultiTexCoord2hvNV* = PROCEDURE{WINAPI}(target: Enum; v: PHalfNV);
	TglMultiTexCoord3hNV* = PROCEDURE{WINAPI}(target: Enum; s: HalfNV; t: HalfNV; r: HalfNV);
	TglMultiTexCoord3hvNV* = PROCEDURE{WINAPI}(target: Enum; v: PHalfNV);
	TglMultiTexCoord4hNV* = PROCEDURE{WINAPI}(target: Enum; s: HalfNV; t: HalfNV; r: HalfNV; q: HalfNV);
	TglMultiTexCoord4hvNV* = PROCEDURE{WINAPI}(target: Enum; v: PHalfNV);
	TglFogCoordhNV* = PROCEDURE{WINAPI}(fog: HalfNV);
	TglFogCoordhvNV* = PROCEDURE{WINAPI}( fog: PHalfNV);
	TglSecondaryColor3hNV* = PROCEDURE{WINAPI}(red: HalfNV; green: HalfNV; blue: HalfNV);
	TglSecondaryColor3hvNV* = PROCEDURE{WINAPI}( v: PHalfNV);
	TglVertexWeighthNV* = PROCEDURE{WINAPI}(weight: HalfNV);
	TglVertexWeighthvNV* = PROCEDURE{WINAPI}( weight: PHalfNV);
	TglVertexAttrib1hNV* = PROCEDURE{WINAPI}(index: Uint; x: HalfNV);
	TglVertexAttrib1hvNV* = PROCEDURE{WINAPI}(index: Uint; v: PHalfNV);
	TglVertexAttrib2hNV* = PROCEDURE{WINAPI}(index: Uint; x: HalfNV; y: HalfNV);
	TglVertexAttrib2hvNV* = PROCEDURE{WINAPI}(index: Uint; v: PHalfNV);
	TglVertexAttrib3hNV* = PROCEDURE{WINAPI}(index: Uint; x: HalfNV; y: HalfNV; z: HalfNV);
	TglVertexAttrib3hvNV* = PROCEDURE{WINAPI}(index: Uint; v: PHalfNV);
	TglVertexAttrib4hNV* = PROCEDURE{WINAPI}(index: Uint; x: HalfNV; y: HalfNV; z: HalfNV; w: HalfNV);
	TglVertexAttrib4hvNV* = PROCEDURE{WINAPI}(index: Uint; v: PHalfNV);
	TglVertexAttribs1hvNV* = PROCEDURE{WINAPI}(index: Uint; n: Sizei; v: PHalfNV);
	TglVertexAttribs2hvNV* = PROCEDURE{WINAPI}(index: Uint; n: Sizei; v: PHalfNV);
	TglVertexAttribs3hvNV* = PROCEDURE{WINAPI}(index: Uint; n: Sizei; v: PHalfNV);
	TglVertexAttribs4hvNV* = PROCEDURE{WINAPI}(index: Uint; n: Sizei; v: PHalfNV);
	(* GL_NV_occlusion_query  *)
	TglGenOcclusionQueriesNV* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglDeleteOcclusionQueriesNV* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglIsOcclusionQueryNV* = PROCEDURE{WINAPI}(id: Uint): Boolean;
	TglBeginOcclusionQueryNV* = PROCEDURE{WINAPI}(id: Uint);
	TglEndOcclusionQueryNV* = PROCEDURE{WINAPI}();
	TglGetOcclusionQueryivNV* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt);
	TglGetOcclusionQueryuivNV* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PUint);
	(* GL_NV_pixel_data_range  *)
	TglPixelDataRangeNV* = PROCEDURE{WINAPI}(target: Enum; length: Sizei; xpointer: PVoid);
	TglFlushPixelDataRangeNV* = PROCEDURE{WINAPI}(target: Enum);
	(* GL_NV_point_sprite  *)
	TglPointParameteriNV* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglPointParameterivNV* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	(* GL_NV_primitive_restart  *)
	TglPrimitiveRestartNV* = PROCEDURE{WINAPI}();
	TglPrimitiveRestartIndexNV* = PROCEDURE{WINAPI}(index: Uint);
	(* GL_NV_register_combiners  *)
	TglCombinerParameterfvNV* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglCombinerParameterfNV* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglCombinerParameterivNV* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglCombinerParameteriNV* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglCombinerInputNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; variable: Enum; input: Enum; mapping: Enum; componentUsage: Enum);
	TglCombinerOutputNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; abOutput: Enum; cdOutput: Enum; sumOutput: Enum; scale: Enum; bias: Enum; abDotProduct: Boolean; cdDotProduct: Boolean; muxSum: Boolean);
	TglFinalCombinerInputNV* = PROCEDURE{WINAPI}(variable: Enum; input: Enum; mapping: Enum; componentUsage: Enum);
	TglGetCombinerInputParameterfvNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; variable: Enum; pname: Enum; params: PFloat);
	TglGetCombinerInputParameterivNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; variable: Enum; pname: Enum; params: PInt);
	TglGetCombinerOutputParameterfvNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; pname: Enum; params: PFloat);
	TglGetCombinerOutputParameterivNV* = PROCEDURE{WINAPI}(stage: Enum; portion: Enum; pname: Enum; params: PInt);
	TglGetFinalCombinerInputParameterfvNV* = PROCEDURE{WINAPI}(variable: Enum; pname: Enum; params: PFloat);
	TglGetFinalCombinerInputParameterivNV* = PROCEDURE{WINAPI}(variable: Enum; pname: Enum; params: PInt);
	(* GL_NV_register_combiners2 *)
	TglCombinerStageParameterfvNV* = PROCEDURE{WINAPI}(stage: Enum; pname: Enum; params: PFloat);
	TglGetCombinerStageParameterfvNV* = PROCEDURE{WINAPI}(stage: Enum; pname: Enum; params: PFloat);
	(* GL_NV_vertex_array_range  *)
	TglFlushVertexArrayRangeNV* = PROCEDURE{WINAPI}();
	TglVertexArrayRangeNV* = PROCEDURE{WINAPI}(length: Sizei; xpointer: PVoid);
	(* GL_NV_vertex_program  *)
	TglAreProgramsResidentNV* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint; residences: PBoolean): Boolean;
	TglBindProgramNV* = PROCEDURE{WINAPI}(target: Enum; id: Uint);
	TglDeleteProgramsNV* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint);
	TglExecuteProgramNV* = PROCEDURE{WINAPI}(target: Enum; id: Uint; params: PFloat);
	TglGenProgramsNV* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint);
	TglGetProgramParameterdvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; pname: Enum; params: PDouble);
	TglGetProgramParameterfvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; pname: Enum; params: PFloat);
	TglGetProgramivNV* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; params: PInt);
	TglGetProgramStringNV* = PROCEDURE{WINAPI}(id: Uint; pname: Enum; xprogram: PUbyte);
	TglGetTrackMatrixivNV* = PROCEDURE{WINAPI}(target: Enum; address: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribdvNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PDouble);
	TglGetVertexAttribfvNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribivNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt);
	TglGetVertexAttribPointervNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgramNV* = PROCEDURE{WINAPI}(id: Uint): Boolean;
	TglLoadProgramNV* = PROCEDURE{WINAPI}(target: Enum; id: Uint; len: Sizei; xprogram: PUbyte);
	TglProgramParameter4dNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramParameter4dvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; v: PDouble);
	TglProgramParameter4fNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramParameter4fvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; v: PFloat);
	TglProgramParameters4dvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Uint; v: PDouble);
	TglProgramParameters4fvNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Uint; v: PFloat);
	TglRequestResidentProgramsNV* = PROCEDURE{WINAPI}(n: Sizei; programs: PUint);
	TglTrackMatrixNV* = PROCEDURE{WINAPI}(target: Enum; address: Uint; matrix: Enum; transform: Enum);
	TglVertexAttribPointerNV* = PROCEDURE{WINAPI}(index: Uint; fsize: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglVertexAttrib1dNV* = PROCEDURE{WINAPI}(index: Uint; x: Double);
	TglVertexAttrib1dvNV* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib1fNV* = PROCEDURE{WINAPI}(index: Uint; x: Float);
	TglVertexAttrib1fvNV* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib1sNV* = PROCEDURE{WINAPI}(index: Uint; x: Short);
	TglVertexAttrib1svNV* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib2dNV* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dvNV* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib2fNV* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fvNV* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib2sNV* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2svNV* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib3dNV* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dvNV* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib3fNV* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fvNV* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib3sNV* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3svNV* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4dNV* = PROCEDURE{WINAPI}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dvNV* = PROCEDURE{WINAPI}(index: Uint; v: PDouble);
	TglVertexAttrib4fNV* = PROCEDURE{WINAPI}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fvNV* = PROCEDURE{WINAPI}(index: Uint; v: PFloat);
	TglVertexAttrib4sNV* = PROCEDURE{WINAPI}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4svNV* = PROCEDURE{WINAPI}(index: Uint; v: PShort);
	TglVertexAttrib4ubNV* = PROCEDURE{WINAPI}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4ubvNV* = PROCEDURE{WINAPI}(index: Uint; v: PUbyte);
	TglVertexAttribs1dvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PDouble);
	TglVertexAttribs1fvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PFloat);
	TglVertexAttribs1svNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PShort);
	TglVertexAttribs2dvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PDouble);
	TglVertexAttribs2fvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PFloat);
	TglVertexAttribs2svNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PShort);
	TglVertexAttribs3dvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PDouble);
	TglVertexAttribs3fvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PFloat);
	TglVertexAttribs3svNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PShort);
	TglVertexAttribs4dvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PDouble);
	TglVertexAttribs4fvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PFloat);
	TglVertexAttribs4svNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PShort);
	TglVertexAttribs4ubvNV* = PROCEDURE{WINAPI}(index: Uint; count: Sizei; v: PUbyte);
	(* GL_NV_depth_buffer_float  *)
	TglDepthRangedNV* = PROCEDURE{WINAPI}(n: Double; f: Double);
	TglClearDepthdNV* = PROCEDURE{WINAPI}(d: Double);
	TglDepthBoundsdNV* = PROCEDURE{WINAPI}(zmin: Double; zmax: Double);
	(* GL_NV_framebuffer_multisample_coverage  *)
	TglRenderbufferStorageMultsampleCoverageNV* = PROCEDURE{WINAPI}(target: Enum; coverageSamples: Sizei; colorSamples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	(* GL_NV_geometry_program4  *)
	TglProgramVertexLimitNV* = PROCEDURE{WINAPI}(target: Enum; limit: Int);
	(* GL_NV_gpu_program4  *)
	TglProgramLocalParameterI4iNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglProgramLocalParameterI4ivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PInt);
	TglProgramLocalParametersI4ivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PInt);
	TglProgramLocalParameterI4uiNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglProgramLocalParameterI4uivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PUint);
	TglProgramLocalParametersI4uivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PUint);
	TglProgramEnvParameterI4iNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglProgramEnvParameterI4ivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PInt);
	TglProgramEnvParametersI4ivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PInt);
	TglProgramEnvParameterI4uiNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglProgramEnvParameterI4uivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PUint);
	TglProgramEnvParametersI4uivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; count: Sizei; params: PUint);
	TglGetProgramLocalParameterIivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PInt);
	TglGetProgramLocalParameterIuivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PUint);
	TglGetProgramEnvParameterIivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PInt);
	TglGetProgramEnvParameterIuivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; params: PUint);
	(* GL_NV_parameter_buffer_object  *)
	TglProgramBufferParametersfvNV* = PROCEDURE{WINAPI}(target: Enum; buffer: Uint; index: Uint; count: Sizei; params: PFloat);
	TglProgramBufferParametersIivNV* = PROCEDURE{WINAPI}(target: Enum; buffer: Uint; index: Uint; count: Sizei; params: Int);
	TglProgramBufferParametersIuivNV* = PROCEDURE{WINAPI}(target: Enum; buffer: Uint; index: Uint; count: Uint; params: PUint);
	(* GL_NV_transform_feedback  *)
	TglBeginTransformFeedbackNV* = PROCEDURE{WINAPI}(primitiveMode: Enum);
	TglEndTransformFeedbackNV* = PROCEDURE{WINAPI}();
	TglTransformFeedbackAttribsNV* = PROCEDURE{WINAPI}(count: Sizei; attribs: Int; bufferMode: Enum);
	TglBindBufferRangeNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint; offset: Int; size: Sizei);
	TglBindBufferOffsetNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint; offset: Int);
	TglBindBufferBaseNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryingsNV* = PROCEDURE{WINAPI}(xprogram: Uint; count: Sizei; varyings: PPChar; bufferMode: Enum);
	TglActiveVaryingNV* = PROCEDURE{WINAPI}(xprogram: Uint; CONST name: ARRAY OF CHAR);
	TglGetVaryingLocationNV* = PROCEDURE{WINAPI}(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
	TglGetActiveVaryingNV* = PROCEDURE{WINAPI}(xprogram: Uint; index: Uint; bufSize: Sizei; length: PSizei; size: PSizei; xtype: PEnum; name: PChar);
	TglGetTransformFeedbackVaryingNV* = PROCEDURE{WINAPI}(xprogram: Uint; index: Uint; location: PInt);
	TglTransformFeedbackStreamAttribsNV* = PROCEDURE{WINAPI}(count: Sizei; attribs: PInt; nbuffers: Sizei; bufstreams: PInt; bufferMode: Enum);
	(* GL_NV_conditional_render  *)
	TglBeginConditionalRenderNV* = PROCEDURE{WINAPI}(id: Uint; mode: Enum);
	TglEndConditionalRenderNV* = PROCEDURE{WINAPI}();

	(* GL_NV_conservative_raster *)
	TglSubpixelPrecisionBiasNV* = PROCEDURE{WINAPI}(xbits: Uint; ybits: Uint);

	(* GL_NV_conservative_raster_dilate *)
	TglConservativeRasterParameterfNV* = PROCEDURE{WINAPI}(pname: Enum; value: Float);

	(* GL_NV_present_video  *)
	TglPresentFrameKeyedNV* = PROCEDURE{WINAPI}(video_slot: Uint; minPresentTime: Uint64EXT; BeginPresentTimeId: Uint; presentDuratioId: Uint; xtype: Enum; target0: Enum; fill0: Uint; key0: Uint; target1: Enum; fill1: Uint; key1: Uint);
	TglPresentFrameDualFillNV* = PROCEDURE{WINAPI}(video_slot: Uint; minPresentTime: Uint64EXT; BeginPresentTimeId: Uint; presentDurationId: Uint; xtype: Enum; target0: Enum; fill0: Uint; target1: Enum; fill1: Uint; target2: Enum; fill2: Uint; target3: Enum; fill3: Uint);
	TglGetVideoivNV* = PROCEDURE{WINAPI}(video_slot: Uint; pname: Enum; params: PInt);
	TglGetVideouivNV* = PROCEDURE{WINAPI}(video_slot: Uint; pname: Enum; params: PUint);
	TglGetVideoi64vNV* = PROCEDURE{WINAPI}(video_slot: Uint; pname: Enum; params: PInt64EXT);
	TglGetVideoui64vNV* = PROCEDURE{WINAPI}(video_slot: Uint; pname: Enum; params: PUint64EXT);
	(*  TglVideoParameterivNV  = PROCEDURE{WINAPI}(video_slot: Uint; pname: Enum; params: PInt);  *)
	(* GL_NV_explicit_multisample  *)
	TglGetMultisamplefvNV* = PROCEDURE{WINAPI}(pname: Enum; index: Uint; val: PFloat);
	TglSampleMaskIndexedNV* = PROCEDURE{WINAPI}(index: Uint; mask: Bitfield);
	TglTexRenderbufferNV* = PROCEDURE{WINAPI}(target: Enum; renderbuffer: Uint);
	(* GL_NV_transform_feedback2  *)
	TglBindTransformFeedbackNV* = PROCEDURE{WINAPI}(target: Enum; id: Uint);
	TglDeleteTransformFeedbacksNV* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglGenTransformFeedbacksNV* = PROCEDURE{WINAPI}(n: Sizei; ids: PUint);
	TglIsTransformFeedbackNV* = PROCEDURE{WINAPI}(id: Uint): Boolean;
	TglPauseTransformFeedbackNV* = PROCEDURE{WINAPI}();
	TglResumeTransformFeedbackNV* = PROCEDURE{WINAPI}();
	TglDrawTransformFeedbackNV* = PROCEDURE{WINAPI}(mode: Enum; id: Uint);
	(* GL_NV_video_capture  *)
	TglBeginVideoCaptureNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint);
	TglBindVideoCaptureStreamBufferNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; frame_region: Enum; offset: Sizei);
	TglBindVideoCaptureStreamTextureNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; frame_region: Enum; target: Enum; texture: Uint);
	TglEndVideoCaptureNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint);
	TglGetVideoCaptureivNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; pname: Enum; params: PInt);
	TglGetVideoCaptureStreamivNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PInt);
	TglGetVideoCaptureStreamfvNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PFloat);
	TglGetVideoCaptureStreamdvNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PDouble);
	TglVideoCaptureNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; sequence_num: PUint; capture_time: PUint64EXT): Enum;
	TglVideoCaptureStreamParameterivNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PInt);
	TglVideoCaptureStreamParameterfvNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PFloat);
	TglVideoCaptureStreamParameterdvNV* = PROCEDURE{WINAPI}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PDouble);
	(* GL_NV_copy_image  *)
	TglCopyImageSubDataNV* = PROCEDURE{WINAPI}(srcName: Uint; srcTarget: Enum; srcLevel: Int; srcX: Int; srcY: Int; srcZ: Int; dstName: Uint; dstTarget: Enum; dstLevel: Int; dstX: Int; dstY: Int; dstZ: Int; width: Sizei; height: Sizei; depth: Sizei);
	(* GL_NV_shader_buffer_load  *)
	TglMakeBufferResidentNV* = PROCEDURE{WINAPI}(target: Enum; access: Enum);
	TglMakeBufferNonResidentNV* = PROCEDURE{WINAPI}(target: Enum);
	TglIsBufferResidentNV* = PROCEDURE{WINAPI}(target: Enum): Boolean;
	TglMakeNamedBufferResidentNV* = PROCEDURE{WINAPI}(buffer: Uint; access: Enum);
	TglMakeNamedBufferNonResidentNV* = PROCEDURE{WINAPI}(buffer: Uint);
	TglIsNamedBufferResidentNV* = PROCEDURE{WINAPI}(buffer: Uint): Boolean;
	TglGetBufferParameterui64vNV* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PUint64EXT);
	TglGetNamedBufferParameterui64vNV* = PROCEDURE{WINAPI}(buffer: Uint; pname: Enum; params: PUint64EXT);
	TglGetIntegerui64vNV* = PROCEDURE{WINAPI}(value: Enum; result: PUint64EXT);
	TglUniformui64NV* = PROCEDURE{WINAPI}(location: Int; value: Uint64EXT);
	TglUniformui64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint64EXT);
	TglGetUniformui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; params: PUint64EXT);
	TglProgramUniformui64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; value: Uint64EXT);
	TglProgramUniformui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint64EXT);
	(* GL_NV_vertex_buffer_unified_memory  *)
	TglBufferAddressRangeNV* = PROCEDURE{WINAPI}(pname: Enum; index: Uint; adress: Uint64EXT; length: Sizei);
	TglVertexFormatNV* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei);
	TglNormalFormatNV* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei);
	TglColorFormatNV* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei);
	TglIndexFormatNV* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei);
	TglTexCoordFormatNV* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei);
	TglEdgeFlagFormatNV* = PROCEDURE{WINAPI}(stride: Sizei);
	TglSecondaryColorFormatNV* = PROCEDURE{WINAPI}(size: Int; xtype: Enum; stride: Sizei);
	TglFogCoordFormatNV* = PROCEDURE{WINAPI}(xtype: Enum; stride: Sizei);
	TglVertexAttribFormatNV* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei);
	TglVertexAttribIFormatNV* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei);
	TglGetIntegerui64i_vNV* = PROCEDURE{WINAPI}(value: Enum; index: Uint; Result: PUint64EXT);
	(* GL_NV_gpu_program5  *)
	TglProgramSubroutineParametersuivNV* = PROCEDURE{WINAPI}(target: Enum; count: Sizei; params: PUint);
	TglGetProgramSubroutineParameteruivNV* = PROCEDURE{WINAPI}(target: Enum; index: Uint; param: PUint);
	(*  GL_NV_gpu_shader5  *)
	TglUniform1i64NV* = PROCEDURE{WINAPI}(location: Int; x: Int64EXT);
	TglUniform2i64NV* = PROCEDURE{WINAPI}(location: Int; x: Int64EXT; y: Int64EXT);
	TglUniform3i64NV* = PROCEDURE{WINAPI}(location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglUniform4i64NV* = PROCEDURE{WINAPI}(location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglUniform1i64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt64EXT);
	TglUniform2i64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt64EXT);
	TglUniform3i64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt64EXT);
	TglUniform4i64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PInt64EXT);
	TglUniform1ui64NV* = PROCEDURE{WINAPI}(location: Int; x: Uint64EXT);
	TglUniform2ui64NV* = PROCEDURE{WINAPI}(location: Int; x: Uint64EXT; y: Uint64EXT);
	TglUniform3ui64NV* = PROCEDURE{WINAPI}(location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglUniform4ui64NV* = PROCEDURE{WINAPI}(location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglUniform1ui64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint64EXT);
	TglUniform2ui64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint64EXT);
	TglUniform3ui64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint64EXT);
	TglUniform4ui64vNV* = PROCEDURE{WINAPI}(location: Int; count: Sizei; value: PUint64EXT);
	TglGetUniformi64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; params: PInt64EXT);
	TglProgramUniform1i64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Int64EXT);
	TglProgramUniform2i64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT);
	TglProgramUniform3i64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglProgramUniform4i64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglProgramUniform1i64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt64EXT);
	TglProgramUniform2i64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt64EXT);
	TglProgramUniform3i64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt64EXT);
	TglProgramUniform4i64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PInt64EXT);
	TglProgramUniform1ui64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Uint64EXT);
	TglProgramUniform2ui64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT);
	TglProgramUniform3ui64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglProgramUniform4ui64NV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglProgramUniform1ui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint64EXT);
	TglProgramUniform2ui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint64EXT);
	TglProgramUniform3ui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint64EXT);
	TglProgramUniform4ui64vNV* = PROCEDURE{WINAPI}(xprogram: Uint; location: Int; count: Sizei; value: PUint64EXT);
	(* GL_NV_vertex_attrib_integer_64bit  *)
	TglVertexAttribL1i64NV* = PROCEDURE{WINAPI}(index: Uint; x: Int64EXT);
	TglVertexAttribL2i64NV* = PROCEDURE{WINAPI}(index: Uint; x: Int64EXT; y: Int64EXT);
	TglVertexAttribL3i64NV* = PROCEDURE{WINAPI}(index: Uint; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglVertexAttribL4i64NV* = PROCEDURE{WINAPI}(index: Uint; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglVertexAttribL1i64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PInt64EXT);
	TglVertexAttribL2i64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PInt64EXT);
	TglVertexAttribL3i64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PInt64EXT);
	TglVertexAttribL4i64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PInt64EXT);
	TglVertexAttribL1ui64NV* = PROCEDURE{WINAPI}(index: Uint; x: Uint64EXT);
	TglVertexAttribL2ui64NV* = PROCEDURE{WINAPI}(index: Uint; x: Uint64EXT; y: Uint64EXT);
	TglVertexAttribL3ui64NV* = PROCEDURE{WINAPI}(index: Uint; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglVertexAttribL4ui64NV* = PROCEDURE{WINAPI}(index: Uint; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglVertexAttribL1ui64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PUint64EXT);
	TglVertexAttribL2ui64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PUint64EXT);
	TglVertexAttribL3ui64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PUint64EXT);
	TglVertexAttribL4ui64vNV* = PROCEDURE{WINAPI}(index: Uint; v: PUint64EXT);
	TglGetVertexAttribLi64vNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PInt64EXT);
	TglGetVertexAttribLui64vNV* = PROCEDURE{WINAPI}(index: Uint; pname: Enum; params: PUint64EXT);
	TglVertexAttribLFormatNV* = PROCEDURE{WINAPI}(index: Uint; size: Int; xtype: Enum; stride: Sizei);
	(* GL_NV_vdpau_interop  *)
	TglVDPAUInitNV* = PROCEDURE{WINAPI}( vdpDevice: PVoid; getProcAddress: PVoid);
	TglVDPAUFiniNV* = PROCEDURE{WINAPI};
	TglVDPAURegisterVideoSurfaceNV* = PROCEDURE{WINAPI}(vdpSurface: PVoid; target: Enum; numTextureNames: Sizei; textureNames: PUint): GLvdpauSurfaceNV;
	TglVDPAURegisterOutputSurfaceNV* = PROCEDURE{WINAPI}(vdpSurface: PVoid; target: Enum; numTextureNames: Sizei; textureNames: PUint): GLvdpauSurfaceNV;
	TglVDPAUIsSurfaceNV* = PROCEDURE{WINAPI}(surface: GLvdpauSurfaceNV);
	TglVDPAUUnregisterSurfaceNV* = PROCEDURE{WINAPI}(surface: GLvdpauSurfaceNV);
	TglVDPAUGetSurfaceivNV* = PROCEDURE{WINAPI}(surface: GLvdpauSurfaceNV; pname: Enum; bufSize: Sizei; length: PSizei; values: PInt);
	TglVDPAUSurfaceAccessNV* = PROCEDURE{WINAPI}(surface: GLvdpauSurfaceNV; access: Enum);
	TglVDPAUMapSurfacesNV* = PROCEDURE{WINAPI}(numSurfaces: Sizei; surfaces: PGLvdpauSurfaceNV);
	TglVDPAUUnmapSurfacesNV* = PROCEDURE{WINAPI}(numSurface: Sizei; surfaces: PGLvdpauSurfaceNV);
	(* GL_NV_texture_barrier  *)
	TglTextureBarrierNV* = PROCEDURE{WINAPI};
	(* (4.3)  *)
	(* GL_NV_path_rendering  *)
	TglGenPathsNV* = PROCEDURE{WINAPI}(range : Sizei) : Uint;
	TglDeletePathsNV* = PROCEDURE{WINAPI}(path : Uint; range : Sizei);
	TglIsPathNV* = PROCEDURE{WINAPI}(path : Uint) : Boolean;
	TglPathCommandsNV* = PROCEDURE{WINAPI}(path : Uint; numCommands : Sizei; commands : PUbyte; numCoords : Sizei; coordType : Enum; coords : PVoid);
	TglPathCoordsNV* = PROCEDURE{WINAPI}(path : Uint; numCoords : Sizei; coordType : Enum; coords : PVoid);
	TglPathSubCommandsNV* = PROCEDURE{WINAPI}(path : Uint; commandStart : Sizei; commandsToDelete : Sizei; numCommands : Sizei; commands : PUbyte; numCoords : Sizei; coordType : Enum; coords : PVoid);
	TglPathSubCoordsNV* = PROCEDURE{WINAPI}(path : Uint; coordStart : Sizei; numCoords : Sizei; coordType : Enum; coords : PVoid);
	TglPathStringNV* = PROCEDURE{WINAPI}(path : Uint; format : Enum; length : Sizei; pathString : PVoid);
	TglPathGlyphsNV* = PROCEDURE{WINAPI}(firstPathName : Uint; fontTarget : Enum; fontName : PVoid; fontStyle : Bitfield; numGlyphs : Sizei; type_ : Enum; charcodes : PVoid; handleMissingGlyphs : Enum; pathParameterTemplate : Uint; emScale : Float);
	TglPathGlyphRangeNV* = PROCEDURE{WINAPI}(firstPathName : Uint; fontTarget : Enum; fontName : PVoid; fontStyle : Bitfield; firstGlyph : Uint; numGlyphs : Sizei; handleMissingGlyphs : Enum; pathParameterTemplate : Uint; emScale : Float);
	TglWeightPathsNV* = PROCEDURE{WINAPI}(resultPath : Uint; numPaths : Sizei; paths : PUint; weights : PFloat);
	TglCopyPathNV* = PROCEDURE{WINAPI}(resultPath : Uint; srcPath : Uint);
	TglInterpolatePathsNV* = PROCEDURE{WINAPI}(resultPath : Uint; pathA : Uint; pathB : Uint; weight : Float);
	TglTransformPathNV* = PROCEDURE{WINAPI}(resultPath : Uint; srcPath : Uint; transformType : Enum; transformValues : PFloat);
	TglPathParameterivNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : PInt);
	TglPathParameteriNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : Int);
	TglPathParameterfvNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : PFloat);
	TglPathParameterfNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : Float);
	TglPathDashArrayNV* = PROCEDURE{WINAPI}(path : Uint; dashCount : Sizei; dashArray : PFloat);
	TglPathStencilFuncNV* = PROCEDURE{WINAPI}(func : Enum; ref : Int; mask : Uint);
	TglPathStencilDepthOffsetNV* = PROCEDURE{WINAPI}(factor : Float; units : Float);
	TglStencilFillPathNV* = PROCEDURE{WINAPI}(path : Uint; fillMode : Enum; mask : Uint);
	TglStencilStrokePathNV* = PROCEDURE{WINAPI}(path : Uint; reference : Int; mask : Uint);
	TglStencilFillPathInstancedNV* = PROCEDURE{WINAPI}(numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; fillMode : Enum; mask : Uint; transformType : Enum; transformValues : PFloat);
	TglStencilStrokePathInstancedNV* = PROCEDURE{WINAPI}(numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; reference : Int; mask : Uint; transformType : Enum; transformValues : PFloat);
	TglPathCoverDepthFuncNV* = PROCEDURE{WINAPI}(func : Enum);
	TglPathColorGenNV* = PROCEDURE{WINAPI}(color : Enum; genMode : Enum; colorFormat : Enum; coeffs : PFloat);
	TglPathTexGenNV* = PROCEDURE{WINAPI}(texCoordSet : Enum; genMode : Enum; components : Int; coeffs : PFloat);
	TglPathFogGenNV* = PROCEDURE{WINAPI}(genMode : Enum);
	TglCoverFillPathNV* = PROCEDURE{WINAPI}(path : Uint; coverMode : Enum);
	TglCoverStrokePathNV* = PROCEDURE{WINAPI}(path : Uint; coverMode : Enum);
	TglCoverFillPathInstancedNV* = PROCEDURE{WINAPI}(numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; coverMode : Enum; transformType : Enum; transformValues : PFloat);
	TglCoverStrokePathInstancedNV* = PROCEDURE{WINAPI}(numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; coverMode : Enum; transformType : Enum; transformValues : PFloat);
	TglGetPathParameterivNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : PInt);
	TglGetPathParameterfvNV* = PROCEDURE{WINAPI}(path : Uint; pname : Enum; value : PFloat);
	TglGetPathCommandsNV* = PROCEDURE{WINAPI}(path : Uint; commands : PUbyte);
	TglGetPathCoordsNV* = PROCEDURE{WINAPI}(path : Uint; coords : PFloat);
	TglGetPathDashArrayNV* = PROCEDURE{WINAPI}(path : Uint; dashArray : PFloat);
	TglGetPathMetricsNV* = PROCEDURE{WINAPI}(metricQueryMask : Bitfield; numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; stride : Sizei; metrics : PFloat);
	TglGetPathMetricRangeNV* = PROCEDURE{WINAPI}(metricQueryMask : Bitfield; firstPathName : Uint; numPaths : Sizei; stride : Sizei; metrics : PFloat);
	TglGetPathSpacingNV* = PROCEDURE{WINAPI}(pathListMode : Enum; numPaths : Sizei; pathNameType : Enum; paths : PVoid; pathBase : Uint; advanceScale : Float; kerningScale : Float; transformType : Enum; returnedSpacing : PFloat);
	TglGetPathColorGenivNV* = PROCEDURE{WINAPI}(color : Enum; pname : Enum; value : PInt);
	TglGetPathColorGenfvNV* = PROCEDURE{WINAPI}(color : Enum; pname : Enum; value : PFloat);
	TglGetPathTexGenivNV* = PROCEDURE{WINAPI}(texCoordSet : Enum; pname : Enum; value : PInt);
	TglGetPathTexGenfvNV* = PROCEDURE{WINAPI}(texCoordSet : Enum; pname : Enum; value : PFloat);
	TglIsPointInFillPathNV* = PROCEDURE{WINAPI}(path : Uint; mask : Uint; x : Float; y : Float) : Boolean;
	TglIsPointInStrokePathNV* = PROCEDURE  {WINAPI}(path : Uint; x : Float; y : Float) : Boolean;
	TglGetPathLengthNV* = PROCEDURE{WINAPI}(path : Uint; startSegment : Sizei; numSegments : Sizei) : Float;
	TglPointAlongPathNV* = PROCEDURE{WINAPI}(path : Uint; startSegment : Sizei; numSegments : Sizei; distance : Float; x : PFloat; y : PFloat; tangentX : PFloat; tangentY : PFloat) : Boolean;
	(* GL_AMD_pinned_memory  *)
	(* GL_AMD_stencil_operation_extended  *)
	TglStencilOpValueAMD* = PROCEDURE{WINAPI}(face : Enum; value : Uint);
	(* GL_AMD_vertex_shader_viewport_index  *)
	(* GL_AMD_vertex_shader_layer  *)
	(* GL_NV_bindless_texture  *)
	TglGetTextureHandleNV* = PROCEDURE{WINAPI}(texture: Uint ) : Uint64;
	TglGetTextureSamplerHandleNV* = PROCEDURE{WINAPI}(texture: Uint; sampler: Uint) : Uint64;
	TglMakeTextureHandleResidentNV* = PROCEDURE{WINAPI}(handle: Uint64);
	TglMakeTextureHandleNonResidentNV* = PROCEDURE{WINAPI}(handle: Uint64);
	TglGetImageHandleNV* = PROCEDURE{WINAPI}(texture: Uint; level: Int; layered: Boolean; layer: Int; format: Enum): Uint64;
	TglMakeImageHandleResidentNV* = PROCEDURE{WINAPI}(handle: Uint64; access : Enum);
	TglMakeImageHandleNonResidentNV* = PROCEDURE{WINAPI}(handle: Uint64);
	TglUniformHandleui64NV* = PROCEDURE{WINAPI}(location: Int; value : Uint64);
	TglUniformHandleui64vNV* = PROCEDURE{WINAPI}(location: Int; cowunt : Sizei; value : PUint64);
	TglProgramUniformHandleui64NV* = PROCEDURE{WINAPI}(program: Uint; location: Int; value: Uint64);
	TglProgramUniformHandleui64vNV* = PROCEDURE{WINAPI}(program: Uint; location: Int; count: Sizei; values: PUint64);
	TglIsTextureHandleResidentNV* = PROCEDURE{WINAPI}(handle: Uint64): Boolean;
	TglIsImageHandleResidentNV* = PROCEDURE{WINAPI}(handle: Uint64): Boolean;

	(* GL_ARB_bindless_texture *)
	TglGetTextureHandleARB* = PROCEDURE{WINAPI}(texture : Uint): Uint64;
	TglGetTextureSamplerHandleARB* = PROCEDURE{WINAPI}(texture : Uint; sampler : Uint) : Uint64;
	TglMakeTextureHandleResidentARB* = PROCEDURE{WINAPI}(handle : Uint64);
	TglMakeTextureHandleNonResidentARB* = PROCEDURE{WINAPI}(handle : Uint64);
	TglGetImageHandleARB* = PROCEDURE{WINAPI}(texture : Uint; level : Int; layered : Boolean; layer : Int; format : Enum) : Uint64;
	TglMakeImageHandleResidentARB* = PROCEDURE{WINAPI}(handle : Uint64; access : Enum);
	TglMakeImageHandleNonResidentARB* = PROCEDURE{WINAPI}(handle : Uint64);
	TglUniformHandleui64ARB* = PROCEDURE{WINAPI}(location : Int; value : Uint64);
	TglUniformHandleui64vARB* = PROCEDURE{WINAPI}(location : Int; count : Sizei; value : PUint64);
	TglProgramUniformHandleui64ARB* = PROCEDURE{WINAPI}(program_ : Uint; location : Int; value : Uint64);
	TglProgramUniformHandleui64vARB* = PROCEDURE{WINAPI}(program_ : Uint; location : Int; count : Sizei; values : PUint64);
	TglIsTextureHandleResidentARB* = PROCEDURE{WINAPI}(handle : Uint64) : Boolean;
	TglIsImageHandleResidentARB* = PROCEDURE{WINAPI}(handle : Uint64) : Boolean;
	TglVertexAttribL1ui64ARB* = PROCEDURE{WINAPI}(index : Uint; x : Uint64EXT);
	TglVertexAttribL1ui64vARB* = PROCEDURE{WINAPI}(index : Uint; v : PUint64EXT);
	TglGetVertexAttribLui64vARB* = PROCEDURE{WINAPI}(index : Uint; pname : Enum; params : PUint64EXT );


	(* GL_NV_shader_atomic_float*)
	(* GL_AMD_query_buffer_object*)
	(* GL_OVR_multiview *)
	TglFramebufferTextureMultiviewOVR* = PROCEDURE{WINAPI}(target: Enum; attachment: Enum; texture: Uint; level: Int; baseViewIndex: Int; numViews: Sizei);

	(*  GL_PGI_misc_hints  *)
	TglHintPGI* = PROCEDURE{WINAPI}(target: Enum; mode: Int);
	(*  GL_SGIS_detail_texture  *)
	TglDetailTexFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; n: Sizei; points: PFloat);
	TglGetDetailTexFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; points: PFloat);
	(*  GL_SGIS_fog_function  *)
	TglFogFuncSGIS* = PROCEDURE{WINAPI}(n: Sizei; points: PFloat);
	TglGetFogFuncSGIS* = PROCEDURE{WINAPI}(points: PFloat);
	(*  GL_SGIS_multisample  *)
	TglSampleMaskSGIS* = PROCEDURE{WINAPI}(value: Clampf; invert: Boolean);
	TglSamplePatternSGIS* = PROCEDURE{WINAPI}(pattern: Enum);
	(*  GL_SGIS_pixel_texture  *)
	TglPixelTexGenParameteriSGIS* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglPixelTexGenParameterivSGIS* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglPixelTexGenParameterfSGIS* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPixelTexGenParameterfvSGIS* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglGetPixelTexGenParameterivSGIS* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglGetPixelTexGenParameterfvSGIS* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	(*  GL_SGIS_point_parameters  *)
	TglPointParameterfSGIS* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglPointParameterfvSGIS* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	(*  GL_SGIS_sharpen_texture  *)
	TglSharpenTexFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; n: Sizei; points: PFloat);
	TglGetSharpenTexFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; points: PFloat);
	(*  GL_SGIS_texture4D  *)
	TglTexImage4DSGIS* = PROCEDURE{WINAPI}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; size4d: Sizei; border: Int; format: Enum; xtype:  Enum; pixels: PVoid);
	TglTexSubImage4DSGIS* = PROCEDURE{WINAPI}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; woffset: Int; width: Sizei; height: Sizei; depth: Sizei; size4d: Sizei; format: Enum; xtype:  Enum; pixels: PVoid);
	(*  GL_SGIS_texture_color_mask  *)
	TglTextureColorMaskSGIS* = PROCEDURE{WINAPI}(red: Boolean; green: Boolean; blue: Boolean; alpha: Boolean);
	(*  GL_SGIS_texture_filter4  *)
	TglGetTexFilterFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; filter: Enum; weights: PFloat);
	TglTexFilterFuncSGIS* = PROCEDURE{WINAPI}(target: Enum; filter: Enum; n: Sizei; weights: PFloat);
	(*  GL_SGIX_async  *)
	TglAsyncMarkerSGIX* = PROCEDURE{WINAPI}(marker: Uint);
	TglFinishAsyncSGIX* = PROCEDURE{WINAPI}(markerp: PUint): Int;
	TglPollAsyncSGIX* = PROCEDURE{WINAPI}(markerp: PUint): Int;
	TglGenAsyncMarkersSGIX* = PROCEDURE{WINAPI}(range: Sizei): Uint;
	TglDeleteAsyncMarkersSGIX* = PROCEDURE{WINAPI}(marker: Uint; range: Sizei);
	TglIsAsyncMarkerSGIX* = PROCEDURE{WINAPI}(marker: Uint): Boolean;
	(*  GL_SGIX_flush_raster  *)
	TglFlushRasterSGIX* = PROCEDURE{WINAPI}();
	(*  GL_SGIX_fragment_lighting  *)
	TglFragmentColorMaterialSGIX* = PROCEDURE{WINAPI}(face: Enum; mode: Enum);
	TglFragmentLightfSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; param: Float);
	TglFragmentLightfvSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PFloat);
	TglFragmentLightiSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; param: Int);
	TglFragmentLightivSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PInt);
	TglFragmentLightModelfSGIX* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglFragmentLightModelfvSGIX* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglFragmentLightModeliSGIX* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglFragmentLightModelivSGIX* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	TglFragmentMaterialfSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; param: Float);
	TglFragmentMaterialfvSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PFloat);
	TglFragmentMaterialiSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; param: Int);
	TglFragmentMaterialivSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PInt);
	TglGetFragmentLightfvSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PFloat);
	TglGetFragmentLightivSGIX* = PROCEDURE{WINAPI}(light: Enum; pname: Enum; params: PInt);
	TglGetFragmentMaterialfvSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PFloat);
	TglGetFragmentMaterialivSGIX* = PROCEDURE{WINAPI}(face: Enum; pname: Enum; params: PInt);
	TglLightEnviSGIX* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	(*  GL_SGIX_framezoom  *)
	TglFrameZoomSGIX* = PROCEDURE{WINAPI}(factor: Int);
	(*  GL_SGIX_igloo_interface  *)
	TglIglooInterfaceSGIX* = PROCEDURE{WINAPI}(pname: Enum; params: PVoid);
	(*  GL_SGIX_instruments  *)
	TglGetInstrumentsSGIX* = PROCEDURE{WINAPI}(): Int;
	TglInstrumentsBufferSGIX* = PROCEDURE{WINAPI}(size: Sizei; buffer: PInt);
	TglPollInstrumentsSGIX* = PROCEDURE{WINAPI}(marker_p: PInt): Int;
	TglReadInstrumentsSGIX* = PROCEDURE{WINAPI}(marker: Int);
	TglStartInstrumentsSGIX* = PROCEDURE{WINAPI}();
	TglStopInstrumentsSGIX* = PROCEDURE{WINAPI}(marker: Int);
	(*  GL_SGIX_list_priority  *)
	TglGetListParameterfvSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; params: PFloat);
	TglGetListParameterivSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; params: PInt);
	TglListParameterfSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; param: Float);
	TglListParameterfvSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; params: PFloat);
	TglListParameteriSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; param: Int);
	TglListParameterivSGIX* = PROCEDURE{WINAPI}(list: Uint; pname: Enum; params: PInt);
	(*  GL_SGIX_pixel_texture  *)
	TglPixelTexGenSGIX* = PROCEDURE{WINAPI}(mode: Enum);
	(*  GL_SGIX_polynomial_ffd  *)
	TglDeformationMap3dSGIX* = PROCEDURE{WINAPI}(target: Enum; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int; w1: Double; w2: Double; wstride: Int; worder: Int; points: PDouble);
	TglDeformationMap3fSGIX* = PROCEDURE{WINAPI}(target: Enum; u1: Float; u2: Float; ustride: Int; uorder: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; w1: Float; w2: Float; wstride: Int; worder: Int; points: PFloat);
	TglDeformSGIX* = PROCEDURE{WINAPI}(mask: Bitfield);
	TglLoadIdentityDeformationMapSGIX* = PROCEDURE{WINAPI}(mask: Bitfield);
	(*  GL_SGIX_reference_plane  *)
	TglReferencePlaneSGIX* = PROCEDURE{WINAPI}( equation: PDouble);
	(*  GL_SGIX_sprite  *)
	TglSpriteParameterfSGIX* = PROCEDURE{WINAPI}(pname: Enum; param: Float);
	TglSpriteParameterfvSGIX* = PROCEDURE{WINAPI}(pname: Enum; params: PFloat);
	TglSpriteParameteriSGIX* = PROCEDURE{WINAPI}(pname: Enum; param: Int);
	TglSpriteParameterivSGIX* = PROCEDURE{WINAPI}(pname: Enum; params: PInt);
	(*  GL_SGIX_tag_sample_buffer  *)
	TglTagSampleBufferSGIX* = PROCEDURE{WINAPI}();
	(*  GL_SGI_color_table  *)
	TglColorTableSGI* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype:  Enum; table: PVoid);
	TglColorTableParameterfvSGI* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglColorTableParameterivSGI* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	TglCopyColorTableSGI* = PROCEDURE{WINAPI}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglGetColorTableSGI* = PROCEDURE{WINAPI}(target: Enum; format: Enum; xtype:  Enum; table: PVoid);
	TglGetColorTableParameterfvSGI* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PFloat);
	TglGetColorTableParameterivSGI* = PROCEDURE{WINAPI}(target: Enum; pname: Enum; params: PInt);
	(*  GL_SUNX_constant_data  *)
	TglFinishTextureSUNX* = PROCEDURE{WINAPI}();
	(*  GL_SUN_global_alpha  *)
	TglGlobalAlphaFactorbSUN* = PROCEDURE{WINAPI}(factor: Byte);
	TglGlobalAlphaFactorsSUN* = PROCEDURE{WINAPI}(factor: Short);
	TglGlobalAlphaFactoriSUN* = PROCEDURE{WINAPI}(factor: Int);
	TglGlobalAlphaFactorfSUN* = PROCEDURE{WINAPI}(factor: Float);
	TglGlobalAlphaFactordSUN* = PROCEDURE{WINAPI}(factor: Double);
	TglGlobalAlphaFactorubSUN* = PROCEDURE{WINAPI}(factor: Ubyte);
	TglGlobalAlphaFactorusSUN* = PROCEDURE{WINAPI}(factor: Ushort);
	TglGlobalAlphaFactoruiSUN* = PROCEDURE{WINAPI}(factor: Uint);
	(*  GL_SUN_mesh_array  *)
	TglDrawMeshArraysSUN* = PROCEDURE{WINAPI}(mode: Enum; first: Int; count: Sizei; width: Sizei);
	(*  GL_SUN_triangle_list  *)
	TglReplacementCodeuiSUN* = PROCEDURE{WINAPI}(code: Uint);
	TglReplacementCodeusSUN* = PROCEDURE{WINAPI}(code: Ushort);
	TglReplacementCodeubSUN* = PROCEDURE{WINAPI}(code: Ubyte);
	TglReplacementCodeuivSUN* = PROCEDURE{WINAPI}( code: PUint);
	TglReplacementCodeusvSUN* = PROCEDURE{WINAPI}( code: PUshort);
	TglReplacementCodeubvSUN* = PROCEDURE{WINAPI}( code: PUbyte);
	TglReplacementCodePointerSUN* = PROCEDURE{WINAPI}(xtype:  Enum; stride: Sizei; xpointer: PVoid);
	(*  GL_SUN_vertex  *)
	TglColor4ubVertex2fSUN* = PROCEDURE{WINAPI}(r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float);
	TglColor4ubVertex2fvSUN* = PROCEDURE{WINAPI}( c: PUbyte; v: PFloat);
	TglColor4ubVertex3fSUN* = PROCEDURE{WINAPI}(r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglColor4ubVertex3fvSUN* = PROCEDURE{WINAPI}(c: PUbyte; v: PFloat);
	TglColor3fVertex3fSUN* = PROCEDURE{WINAPI}(r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglColor3fVertex3fvSUN* = PROCEDURE{WINAPI}(c: PFloat; v: PFloat);
	TglNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}(n: PFloat; v: PFloat);
	TglColor4fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglColor4fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}(c: PFloat; n: PFloat; v: PFloat);
	TglTexCoord2fVertex3fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fVertex3fvSUN* = PROCEDURE{WINAPI}(tc: PFloat; v: PFloat);
	TglTexCoord4fVertex4fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; p: Float; q: Float; x: Float; y: Float; z: Float; w: Float);
	TglTexCoord4fVertex4fvSUN* = PROCEDURE{WINAPI}(tc: PFloat; v: PFloat);
	TglTexCoord2fColor4ubVertex3fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglTexCoord2fColor4ubVertex3fvSUN* = PROCEDURE{WINAPI}(tc: PFloat; c: PUbyte; v: PFloat);
	TglTexCoord2fColor3fVertex3fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fColor3fVertex3fvSUN* = PROCEDURE{WINAPI}(tc: PFloat; c: PFloat; v: PFloat);
	TglTexCoord2fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( tc: PFloat; n: PFloat; v: PFloat);
	TglTexCoord2fColor4fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fColor4fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( tc: PFloat; c: PFloat; n: PFloat; v: PFloat);
	TglTexCoord4fColor4fNormal3fVertex4fSUN* = PROCEDURE{WINAPI}(s: Float; t: Float; p: Float; q: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float; w: Float);
	TglTexCoord4fColor4fNormal3fVertex4fvSUN* = PROCEDURE{WINAPI}( tc: PFloat; c: PFloat; n: PFloat; v: PFloat);
	TglReplacementCodeuiVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; x: Float; y: Float; z: Float);
	TglReplacementCodeuiVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; v: PFloat);
	TglReplacementCodeuiColor4ubVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor4ubVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; c: PUbyte; v: PFloat);
	TglReplacementCodeuiColor3fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor3fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; c: PFloat; v: PFloat);
	TglReplacementCodeuiNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; n: PFloat; v: PFloat);
	TglReplacementCodeuiColor4fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor4fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; c: PFloat; n: PFloat; v: PFloat);
	TglReplacementCodeuiTexCoord2fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; s: Float; t: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; tc: PFloat; v: PFloat);
	TglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; s: Float; t: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; tc: PFloat; n: PFloat; v: PFloat);
	TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN* = PROCEDURE{WINAPI}(rc: Uint; s: Float; t: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN* = PROCEDURE{WINAPI}( rc: PUint; tc: PFloat; c: PFloat; n: PFloat; v: PFloat);

	(* -------------------------------------------------  *)
	(*! window support functions for WINDOWS - WGL        *)
	(* -------------------------------------------------  *)

	TwglGetProcAddress* = PROCEDURE {WINAPI} (  CONST ProcName: ARRAY OF CHAR): ADDRESS;
	TwglCopyContext* = PROCEDURE {WINAPI} (p1: HGLRC; p2: HGLRC; p3: Uint): BOOLEAN;
	TwglCreateContext* = PROCEDURE {WINAPI} (DC: HDC): HGLRC;
	TwglCreateLayerContext* = PROCEDURE {WINAPI} (p1: HDC; p2: Int): HGLRC;
	TwglDeleteContext = PROCEDURE {WINAPI} (p1: HGLRC): BOOLEAN;
	TwglDescribeLayerPlane*  = PROCEDURE {WINAPI} (p1: HDC; p2, p3: LONGINT; p4: LONGINT; p5: WinApi.LayerPlaneDescriptor): BOOLEAN;
	TwglGetCurrentContext* = PROCEDURE {WINAPI}(): HGLRC;
	TwglGetCurrentDC* = PROCEDURE {WINAPI}(): HDC;
	TwglGetLayerPaletteEntries* = PROCEDURE {WINAPI} (p1: HDC; p2, p3, p4: Int; varpcr: ADDRESS): Int;
	TwglMakeCurrent* = PROCEDURE {WINAPI} (DC: HDC; p2: HGLRC): BOOLEAN;
	TwglRealizeLayerPalette*  = PROCEDURE {WINAPI} (p1: HDC; p2: Int; p3: BOOLEAN): BOOLEAN;
	TwglSetLayerPaletteEntries*  = PROCEDURE {WINAPI} (p1: HDC; p2, p3, p4: Int;  varpcr: ADDRESS): Int;
	TwglShareLists* = PROCEDURE {WINAPI} (p1, p2: HGLRC): BOOLEAN;
	TwglSwapLayerBuffers*  = PROCEDURE {WINAPI} (p1: HDC; p2: Uint): BOOLEAN;

	WGLSWAP* = RECORD
		hdc*: HDC;
	    	uiFlags*: Uint;
	END;
	PWGLSWAP* = POINTER TO ARRAY 16 OF WGLSWAP; (* WGL_SWAPMULTIPLE_MAX = 16 *)

	TwglSwapMultipleBuffers*  = PROCEDURE {WINAPI} (p1: Uint; p2: ADDRESS (* PWGLSWAP *)): Uint; (* undocumented!, IF WINVER >= 0x0500 *)
	TwglUseFontBitmapsA*  = PROCEDURE {WINAPI} (DC: HDC; p2, p3, p4: Uint): BOOLEAN;
	TwglUseFontBitmapsW*  = PROCEDURE {WINAPI} (DC: HDC; p2, p3, p4: Uint): BOOLEAN;
	TwglUseFontBitmaps*  = PROCEDURE {WINAPI} (DC: HDC; p2, p3, p4: Uint): BOOLEAN;

	TwglUseFontOutlinesA*  = PROCEDURE {WINAPI} (p1: HDC; p2, p3, p4: Uint; p5, p6: Float; p7: LONGINT; p8: ADDRESS (*GlyphMetricsFloat*) ): BOOLEAN;
	TwglUseFontOutlinesW*  = PROCEDURE {WINAPI} (p1: HDC; p2, p3, p4: Uint; p5, p6: Float; p7: LONGINT; p8: ADDRESS (*GlyphMetricsFloat*)): BOOLEAN;
	TwglUseFontOutlines*  = PROCEDURE {WINAPI} (p1: HDC; p2, p3, p4: Uint; p5, p6: Float; p7: LONGINT; p8: ADDRESS (*GlyphMetricsFloat*)): BOOLEAN;


	(* WGL_ARB_buffer_region *)
	TwglCreateBufferRegionARB*  = PROCEDURE {WINAPI} (hDC: HDC; iLayerPlane: Int; uType: Uint): THandle;
	TwglDeleteBufferRegionARB*  = PROCEDURE {WINAPI}(hRegion: THandle);
	TwglSaveBufferRegionARB*  = PROCEDURE {WINAPI} (hRegion: THandle; x: Int; y: Int; width: Int; height: Int): BOOLEAN;
	TwglRestoreBufferRegionARB*  = PROCEDURE {WINAPI} (hRegion: THandle; x: Int; y: Int; width: Int; height: Int; xSrc: Int; ySrc: Int): BOOLEAN;

	(* WGL_ARB_extensions_string *)
	TwglGetExtensionsStringARB* = PROCEDURE {WINAPI} (hdc: HDC): ADDRESS;


	(* WGL_ARB_make_current_read *)
	TwglMakeContextCurrentARB*  = PROCEDURE {WINAPI} (hDrawDC: HDC; hReadDC: HDC; hglrc: HGLRC): BOOLEAN;
	TwglGetCurrentReadDCARB*  = PROCEDURE {WINAPI} (): HDC;

	(* WGL_ARB_pbuffer *)
	TwglCreatePbufferARB*  = PROCEDURE {WINAPI} (hDC: HDC; iPixelFormat: Int; iWidth: Int; iHeight: Int;  piAttribList:  PInt): HPBUFFERARB;
	TwglGetPbufferDCARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB): HDC;
	TwglReleasePbufferDCARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; hDC: HDC): Int;
	TwglDestroyPbufferARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB): BOOLEAN;
	TwglQueryPbufferARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; iAttribute: Int;  piValue: ADDRESS (*Int*)): BOOLEAN;

	(* WGL_ARB_pixel_format *)
	TwglGetPixelFormatAttribivARB*  = PROCEDURE {WINAPI} (hdc: HDC; iPixelFormat: Int; iLayerPlane: Int; nAttributes: Uint; CONST piAttributes: PInt; piValues: PInt): BOOLEAN;
	TwglGetPixelFormatAttribfvARB*  = PROCEDURE {WINAPI} (hdc: HDC; iPixelFormat: Int; iLayerPlane: Int; nAttributes: Uint; CONST piAttributes: PInt; pfValues: Float): BOOLEAN;
	TwglChoosePixelFormatARB*  = PROCEDURE {WINAPI} (hdc: HDC;  piAttribIList: ADDRESS (*PInt*);  pfAttribFList: ADDRESS (* Float*); nMaxFormats: Uint; (*VAR*) piFormats: ADDRESS;(*Int; VAR*) nNumFormats: ADDRESS(*Uint*)): BOOLEAN;

	(* WGL_ARB_color_buffer_float *)
	TwglClampColorARB*  = PROCEDURE {WINAPI}(target: Enum; clamp: Enum);

	(* WGL_ARB_render_texture *)
	TwglBindTexImageARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; iBuffer: Int): BOOLEAN;
	TwglReleaseTexImageARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; iBuffer: Int): BOOLEAN;
	TwglSetPbufferAttribARB*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; CONST piAttribList: PInt): BOOLEAN;

	(* WGL_ARB_create_context *)
	TwglCreateContextAttribsARB*  = PROCEDURE {WINAPI} (hDC: HDC; hShareContext: HGLRC;  attribList: ADDRESS (*PInt*)): HGLRC;

	(* WGL_AMD_gpu_association *)
	TwglGetGPUIDsAMD*  = PROCEDURE {WINAPI} (maxCount: Uint; ids: PUint): Uint;
	TwglGetGPUInfoAMD*  = PROCEDURE {WINAPI} (id: Uint; property: Int; dataType: Enum; size: Uint; data: ADDRESS): Int;
	TwglGetContextGPUIDAMD*  = PROCEDURE {WINAPI} (hglrc: HGLRC): Uint;
	TwglCreateAssociatedContextAMD*  = PROCEDURE {WINAPI} (id: Uint): HGLRC;
	TwglCreateAssociatedContextAttribsAMD*  = PROCEDURE {WINAPI} (id: Uint; hShareContext: HGLRC; CONST attribList: PInt): HGLRC;
	TwglDeleteAssociatedContextAMD*  = PROCEDURE {WINAPI} (hglrc: HGLRC): BOOLEAN;
	TwglMakeAssociatedContextCurrentAMD*  = PROCEDURE {WINAPI} (hglrc: HGLRC): BOOLEAN;
	TwglGetCurrentAssociatedContextAMD*  = PROCEDURE {WINAPI} (): HGLRC;
	TwglBlitContextFramebufferAMD*  = PROCEDURE {WINAPI}(dstCtx: HGLRC; srcX0: Int; srcY0: Int; srcX1: Int; srcY1: Int; dstX0: Int; dstY0: Int; dstX1: Int; dstY1: Int; mask: Bitfield; filter: Enum);

	(* WGL_EXT_display_color_table *)
	TwglCreateDisplayColorTableEXT*  = PROCEDURE {WINAPI} (id: Ushort): Boolean;
	TwglLoadDisplayColorTableEXT*  = PROCEDURE {WINAPI} (table: PUshort; length: Uint): Boolean;
	TwglBindDisplayColorTableEXT*  = PROCEDURE {WINAPI} (id: Ushort): Boolean;
	TwglDestroyDisplayColorTableEXT*  = PROCEDURE {WINAPI}(id: Ushort);

	(* WGL_EXT_extensions_string *)
	TwglGetExtensionsStringEXT*  = PROCEDURE {WINAPI} (): ADDRESS;

	(* WGL_EXT_make_current_read *)
	TwglMakeContextCurrentEXT*  = PROCEDURE {WINAPI} (hDrawDC: HDC; hReadDC: HDC; hglrc: HGLRC): BOOLEAN;
	TwglGetCurrentReadDCEXT*  = PROCEDURE {WINAPI} (): HDC;

	(* WGL_EXT_pbuffer *)
	TwglCreatePbufferEXT*  = PROCEDURE {WINAPI} (hDC: HDC; iPixelFormat: Int; iWidth: Int; iHeight: Int; CONST piAttribList: PInt): HPBUFFEREXT;
	TwglGetPbufferDCEXT*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFEREXT): HDC;
	TwglReleasePbufferDCEXT*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFEREXT; hDC: HDC): Int;
	TwglDestroyPbufferEXT*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFEREXT): BOOLEAN;
	TwglQueryPbufferEXT*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFEREXT; iAttribute: Int; piValue: PInt): BOOLEAN;

	(* WGL_EXT_pixel_format *)
	TwglGetPixelFormatAttribivEXT*  = PROCEDURE {WINAPI} (hdc: HDC; iPixelFormat: Int; iLayerPlane: Int; nAttributes: Uint; piAttributes: PInt; piValues: PInt): BOOLEAN;
	TwglGetPixelFormatAttribfvEXT*  = PROCEDURE {WINAPI} (hdc: HDC; iPixelFormat: Int; iLayerPlane: Int; nAttributes: Uint; piAttributes: PInt; pfValues: Float): BOOLEAN;
	TwglChoosePixelFormatEXT*  = PROCEDURE {WINAPI} (hdc: HDC; CONST piAttribIList: PInt; CONST pfAttribFList: Float; nMaxFormats: Uint; piFormats: PInt; nNumFormats: PUint): BOOLEAN;

	(* WGL_EXT_swap_control *)
	TwglSwapIntervalEXT*  = PROCEDURE {WINAPI} (interval: Int): BOOLEAN;
	TwglGetSwapIntervalEXT*  = PROCEDURE {WINAPI} ( ): Int;

	(* WGL_I3D_digital_video_control *)
	TwglGetDigitalVideoParametersI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iAttribute: Int; piValue: PInt): BOOLEAN;
	TwglSetDigitalVideoParametersI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iAttribute: Int; CONST piValue: PInt): BOOLEAN;

	(* WGL_I3D_gamma *)
	TwglGetGammaTableParametersI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iAttribute: Int; piValue: PInt): BOOLEAN;
	TwglSetGammaTableParametersI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iAttribute: Int; CONST piValue: PInt): BOOLEAN;
	TwglGetGammaTableI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iEntries: Int; puRed: PUshort; puGreen: PUshort; puBlue: PUshort): BOOLEAN;
	TwglSetGammaTableI3D*  = PROCEDURE {WINAPI} (hDC: HDC; iEntries: Int; CONST puRed: PUshort; CONST puGreen: PUshort; CONST puBlue: PUshort): BOOLEAN;

	(* WGL_I3D_genlock *)
	TwglEnableGenlockI3D*  = PROCEDURE {WINAPI} (hDC: HDC): BOOLEAN;
	TwglDisableGenlockI3D*  = PROCEDURE {WINAPI} ( hDC: HDC): BOOLEAN;
	TwglIsEnabledGenlockI3D*  = PROCEDURE {WINAPI} (hDC: HDC; pFlag: BOOLEAN): BOOLEAN;
	TwglGenlockSourceI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uSource: Uint): BOOLEAN;
	TwglGetGenlockSourceI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uSource: PUint): BOOLEAN;
	TwglGenlockSourceEdgeI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uEdge: Uint): BOOLEAN;
	TwglGetGenlockSourceEdgeI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uEdge: PUint): BOOLEAN;
	TwglGenlockSampleRateI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uRate: Uint): BOOLEAN;
	TwglGetGenlockSampleRateI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uRate: PUint): BOOLEAN;
	TwglGenlockSourceDelayI3D*  = PROCEDURE {WINAPI} ( hDC: HDC; uDelay: Uint): BOOLEAN;
	TwglGetGenlockSourceDelayI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uDelay: PUint): BOOLEAN;
	TwglQueryGenlockMaxSourceDelayI3D*  = PROCEDURE {WINAPI} (hDC: HDC; uMaxLineDelay: PUint; uMaxPixelDelay: PUint): BOOLEAN;

	(* WGL_I3D_image_buffer *)
	TwglCreateImageBufferI3D*  = PROCEDURE {WINAPI} (hDC: HDC; dwSize: Uint; uFlags: Uint): Void;
	TwglDestroyImageBufferI3D*  = PROCEDURE {WINAPI} (hDC: HDC; pAddress: Void): BOOLEAN;
	TwglAssociateImageBufferEventsI3D*  = PROCEDURE {WINAPI} (hDC: HDC; CONST pEvent: THandle; CONST pAddress: PVoid; CONST pSize: PUint; count: Uint): BOOLEAN;
	TwglReleaseImageBufferEventsI3D*  = PROCEDURE {WINAPI} (hDC: HDC; CONST pAddress: PVoid; count: Uint): BOOLEAN;

	(* WGL_I3D_swap_frame_lock *)
	TwglEnableFrameLockI3D*  = PROCEDURE {WINAPI} ( ): BOOLEAN;
	TwglDisableFrameLockI3D*  = PROCEDURE {WINAPI} ( ): BOOLEAN;
	TwglIsEnabledFrameLockI3D*  = PROCEDURE {WINAPI} (pFlag: BOOLEAN): BOOLEAN;
	TwglQueryFrameLockMasterI3D*  = PROCEDURE {WINAPI} (pFlag: BOOLEAN): BOOLEAN;

	(* WGL_I3D_swap_frame_usage *)
	TwglGetFrameUsageI3D*  = PROCEDURE {WINAPI} (pUsage: Float): BOOLEAN;
	TwglBeginFrameTrackingI3D*  = PROCEDURE {WINAPI} ( ): BOOLEAN;
	TwglEndFrameTrackingI3D*  = PROCEDURE {WINAPI} (): BOOLEAN;
	TwglQueryFrameTrackingI3D*  = PROCEDURE {WINAPI} (pFrameCount: PUint; pMissedFrames: PUint; pLastMissedUsage: Float): BOOLEAN;

	(* WGL_NV_vertex_array_range *)
	TwglAllocateMemoryNV*  = PROCEDURE {WINAPI}(size: Sizei; readfreq: Float; writefreq: Float; priority: Float);
	TwglFreeMemoryNV*  = PROCEDURE {WINAPI}(pointer: ADDRESS);

	(* WGL_NV_present_video  *)
	TwglEnumerateVideoDevicesNV*  = PROCEDURE {WINAPI} (hdc: HDC; phDeviceList: PHVIDEOOUTPUTDEVICENV): Int;
	TwglBindVideoDeviceNV*  = PROCEDURE {WINAPI} (hd: HDC; uVideoSlot: Uint; hVideoDevice: HVIDEOOUTPUTDEVICENV; piAttribList: PInt): BOOLEAN;
	TwglQueryCurrentContextNV*  = PROCEDURE {WINAPI} (iAttribute: Int; piValue: PInt): BOOLEAN;

	(* WGL_NV_video_output *)
	TwglGetVideoDeviceNV*  = PROCEDURE {WINAPI} (hDC: HDC; numDevices: Int; hVideoDevice: PHPVIDEODEV): BOOLEAN;
	TwglReleaseVideoDeviceNV*  = PROCEDURE {WINAPI} (hVideoDevice: HPVIDEODEV): BOOLEAN;
	TwglBindVideoImageNV*  = PROCEDURE {WINAPI} (hVideoDevice: HPVIDEODEV; hPbuffer: HPBUFFERARB; iVideoBuffer: Int): BOOLEAN;
	TwglReleaseVideoImageNV*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; iVideoBuffer: Int): BOOLEAN;
	TwglSendPbufferToVideoNV*  = PROCEDURE {WINAPI} (hPbuffer: HPBUFFERARB; iBufferType: Int; pulCounterPbuffer: PUint; bBlock: BOOLEAN): BOOLEAN;
	TwglGetVideoInfoNV*  = PROCEDURE {WINAPI} (hpVideoDevice: HPVIDEODEV; pulCounterOutputPbuffer: PUint; pulCounterOutputVideo: PUint): BOOLEAN;

	(* WGL_NV_swap_group *)
	TwglJoinSwapGroupNV*  = PROCEDURE {WINAPI} (hDC: HDC; group: Uint): BOOLEAN;
	TwglBindSwapBarrierNV*  = PROCEDURE {WINAPI} (group: Uint; barrier: Uint): BOOLEAN;
	TwglQuerySwapGroupNV*  = PROCEDURE {WINAPI} (hDC: HDC; group: PUint; barrier: PUint): BOOLEAN;
	TwglQueryMaxSwapGroupsNV*  = PROCEDURE {WINAPI} (hDC: HDC; mxGroups: PUint; maxBarriers: PUint): BOOLEAN;
	TwglQueryFrameCountNV*  = PROCEDURE {WINAPI} (hDC: HDC; count: PUint): BOOLEAN;
	TwglResetFrameCountNV*  = PROCEDURE {WINAPI} (hDC: HDC): BOOLEAN;

	(* WGL_NV_gpu_affinity *)
	TwglEnumGpusNV*  = PROCEDURE {WINAPI} (iGpuIndex: Uint; phGpu: PHGPUNV): BOOLEAN;
	TwglEnumGpuDevicesNV*  = PROCEDURE {WINAPI} (hGpu: HGPUNV; iDeviceIndex: Uint; lpGpuDevice: PGPU_DEVICE): BOOLEAN;
	TwglCreateAffinityDCNV*  = PROCEDURE {WINAPI} ( CONST phGpuList: PHGPUNV): HDC;
	TwglEnumGpusFromAffinityDCNV*  = PROCEDURE {WINAPI} (hAffinityDC: HDC; iGpuIndex: Uint; hGpu: PHGPUNV): BOOLEAN;
	TwglDeleteDCNV*  = PROCEDURE {WINAPI} (hDC: HDC): BOOLEAN;

	(* WGL_NV_video_capture *)
	TwglBindVideoCaptureDeviceNV*  = PROCEDURE {WINAPI} (uVideoSlot: Uint; hDevice: HVIDEOINPUTDEVICENV): BOOLEAN;
	TwglEnumerateVideoCaptureDevicesNV*  = PROCEDURE {WINAPI} (hDc: HDC; phDeviceList: PHVIDEOINPUTDEVICENV): Uint;
	TwglLockVideoCaptureDeviceNV*  = PROCEDURE {WINAPI} (hDc: HDC; hDevice: HVIDEOINPUTDEVICENV): BOOLEAN;
	TwglQueryVideoCaptureDeviceNV*  = PROCEDURE {WINAPI} (hDc: HDC; hDevice: HVIDEOINPUTDEVICENV; iAttribute: Int; piValue: PInt): BOOLEAN;
	TwglReleaseVideoCaptureDeviceNV*  = PROCEDURE {WINAPI} (hDc: HDC; hDevice: HVIDEOINPUTDEVICENV): BOOLEAN;

	(* WGL_NV_copy_image *)
	TwglCopyImageSubDataNV*  = PROCEDURE {WINAPI} (hSrcRc: HGLRC; srcName: Uint; srcTarget: Enum; srcLevel: Int; srcX: Int; srcY: Int; srcZ: Int; hDstRC: HGLRC; dstName: Uint; dstTarget: Enum; dstLevel: Int; dstX: Int; dstY: Int; dstZ: Int; width: Sizei; height: Sizei; depth: Sizei): BOOLEAN;

	(* WGL_NV_DX_interop *)
	TwglDXSetResourceShareHandleNV* = PROCEDURE {WINAPI} (dxObject : PVoid; hareHandle : Uint) : BOOLEAN;
	TwglDXOpenDeviceNV* = PROCEDURE {WINAPI} (dxDevice : PVoid) : Uint;
	TwglDXCloseDeviceNV* = PROCEDURE {WINAPI} (hDevice : Uint) : BOOLEAN;
	TwglDXRegisterObjectNV* = PROCEDURE {WINAPI} (hDevice : Uint; dxObject : PVoid; name : Uint; _type : Enum; access : Enum) : Uint;
	TwglDXUnregisterObjectNV* = PROCEDURE {WINAPI} (hDevice : Uint; hObject : Uint) : BOOLEAN;
	TwglDXObjectAccessNV* = PROCEDURE {WINAPI} (hObject : Uint; access : Enum) :BOOLEAN;
	TwglDXLockObjectsNV* = PROCEDURE {WINAPI} (hDevice : Uint; count : Int; hObjects : PUint) : BOOLEAN;
	TwglDXUnlockObjectsNV* = PROCEDURE {WINAPI} (hDevice : Uint; count : Int; hObjects : PUint) : BOOLEAN;

	(* WGL_OML_sync_control *)
	TwglGetSyncValuesOML*  = PROCEDURE {WINAPI} (hdc: HDC; ust: PInt64; msc: PInt64; sbc: PInt64): BOOLEAN;
	TwglGetMscRateOML*  = PROCEDURE {WINAPI} (hdc: HDC; numerator: PInt; denominator: PInt): BOOLEAN;
	TwglSwapBuffersMscOML*  = PROCEDURE {WINAPI} (hdc: HDC; target_msc: Int64; divisor: Int64; remainder: Int64): Int64;
	TwglSwapLayerBuffersMscOML*  = PROCEDURE {WINAPI} (hdc: HDC; fuPlanes: Int; target_msc: Int64; divisor: Int64; remainder: Int64): Int64;
	TwglWaitForMscOML*  = PROCEDURE {WINAPI} (hdc: HDC; target_msc: Int64; divisor: Int64; remainder: Int64; ust: PInt64; msc: PInt64; sbc: PInt64): BOOLEAN;
	TwglWaitForSbcOML*  = PROCEDURE {WINAPI} (hdc: HDC; target_sbc: Int64; ust: PInt64; msc: PInt64; sbc: PInt64): BOOLEAN;


	(* WGL_3DL_stereo_control *)
	TwglSetStereoEmitterState3DL*  = PROCEDURE {WINAPI} (hDC: HDC; uState: Uint): BOOLEAN;

	(* WIN_draw_range_elements *)
	TglDrawRangeElementsWIN*  = PROCEDURE {WINAPI}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum; CONST indices: PVoid);

	(* WIN_swap_hint *)
	TglAddSwapHintRectWIN*  = PROCEDURE {WINAPI}(x: Int; y: Int; width: Sizei; height: Sizei);

  VAR

	(*! GL_VERSION_1_0 *)
	CullFace- : TglCullFace;
	FrontFace- : TglFrontFace;
	Hint- : TglHint;
	LineWidth- : TglLineWidth;
	PointSize- : TglPointSize;
	PolygonMode- : TglPolygonMode;
	Scissor- : TglScissor;
	TexParameterf- : TglTexParameterf;
	TexParameterfv- : TglTexParameterfv;
	TexParameteri- : TglTexParameteri;
	TexParameteriv- : TglTexParameteriv;
	TexImage1D- : TglTexImage1D;
	TexImage2D- : TglTexImage2D;
	DrawBuffer- : TglDrawBuffer;
	Clear- : TglClear;
	ClearColor- : TglClearColor;
	ClearStencil- : TglClearStencil;
	ClearDepth- : TglClearDepth;
	StencilMask- : TglStencilMask;
	ColorMask- : TglColorMask;
	DepthMask- : TglDepthMask;
	Disable- : TglDisable;
	Enable- : TglEnable;
	Finish- : TglFinish;
	Flush- : TglFlush;
	BlendFunc- : TglBlendFunc;
	LogicOp- : TglLogicOp;
	StencilFunc- : TglStencilFunc;
	StencilOp- : TglStencilOp;
	DepthFunc- : TglDepthFunc;
	PixelStoref- : TglPixelStoref;
	PixelStorei- : TglPixelStorei;
	ReadBuffer- : TglReadBuffer;
	ReadPixels- : TglReadPixels;
	GetBooleanv- : TglGetBooleanv;
	GetDoublev- : TglGetDoublev;
	GetError- : TglGetError;
	GetFloatv- : TglGetFloatv;
	GetIntegerv- : TglGetIntegerv;
	XglGetString- : TglGetString;
	GetTexImage- : TglGetTexImage;
	GetTexParameteriv- : TglGetTexParameteriv;
	GetTexParameterfv- : TglGetTexParameterfv;
	GetTexLevelParameterfv- : TglGetTexLevelParameterfv;
	GetTexLevelParameteriv- : TglGetTexLevelParameteriv;
	IsEnabled- : TglIsEnabled;
	DepthRange- : TglDepthRange;
	Viewport- : TglViewport;
	(*! GL_VERSION_1_1 *)
	DrawArrays- : TglDrawArrays;
	DrawElements- : TglDrawElements;
	GetPointerv- : TglGetPointerv;
	PolygonOffset- : TglPolygonOffset;
	CopyTexImage1D- : TglCopyTexImage1D;
	CopyTexImage2D- : TglCopyTexImage2D;
	CopyTexSubImage1D- : TglCopyTexSubImage1D;
	CopyTexSubImage2D- : TglCopyTexSubImage2D;
	TexSubImage1D- : TglTexSubImage1D;
	TexSubImage2D- : TglTexSubImage2D;
	BindTexture- : TglBindTexture;
	DeleteTextures- : TglDeleteTextures;
	GenTextures- : TglGenTextures;

	(*! ifdef DEPRECATED *)
	Accum- : TglAccum;
	AlphaFunc- : TglAlphaFunc;
	AreTexturesResident- : TglAreTexturesResident;
	ArrayElement- : TglArrayElement;
	Begin- : TglBegin;
	Bitmap- : TglBitmap;
	CallList- : TglCallList;
	CallLists- : TglCallLists;
	ClearAccum- : TglClearAccum;
	ClearIndex- : TglClearIndex;
	ClipPlane- : TglClipPlane;
	Color3b- : TglColor3b;
	Color3bv- : TglColor3bv;
	Color3d- : TglColor3d;
	XglColor3dv- : TglColor3dv;
	Color3f- : TglColor3f;
	XglColor3fv- : TglColor3fv;
	Color3i- : TglColor3i;
	Color3iv- : TglColor3iv;
	Color3s- : TglColor3s;
	Color3sv- : TglColor3sv;
	Color3ub- : TglColor3ub;
	Color3ubv- : TglColor3ubv;
	Color3ui- : TglColor3ui;
	Color3uiv- : TglColor3uiv;
	Color3us- : TglColor3us;
	Color3usv- : TglColor3usv;
	Color4b- : TglColor4b;
	Color4bv- : TglColor4bv;
	Color4d- : TglColor4d;
	Color4dv- : TglColor4dv;
	Color4f- : TglColor4f;
	Color4fv- : TglColor4fv;
	Color4i- : TglColor4i;
	Color4iv- : TglColor4iv;
	Color4s- : TglColor4s;
	Color4sv- : TglColor4sv;
	Color4ub- : TglColor4ub;
	Color4ubv- : TglColor4ubv;
	Color4ui- : TglColor4ui;
	Color4uiv- : TglColor4uiv;
	Color4us- : TglColor4us;
	Color4usv- : TglColor4usv;
	ColorMaterial- : TglColorMaterial;
	ColorPointer- : TglColorPointer;
	CopyPixels- : TglCopyPixels;
	DeleteLists- : TglDeleteLists;
	DisableClientState- : TglDisableClientState;
	DrawPixels- : TglDrawPixels;
	EdgeFlag- : TglEdgeFlag;
	EdgeFlagPointer- : TglEdgeFlagPointer;
	EdgeFlagv- : TglEdgeFlagv;
	EnableClientState- : TglEnableClientState;
	End- : TglEnd;
	EndList- : TglEndList;
	EvalCoord1d- : TglEvalCoord1d;
	EvalCoord1dv- : TglEvalCoord1dv;
	EvalCoord1f- : TglEvalCoord1f;
	EvalCoord1fv- : TglEvalCoord1fv;
	EvalCoord2d- : TglEvalCoord2d;
	EvalCoord2dv- : TglEvalCoord2dv;
	EvalCoord2f- : TglEvalCoord2f;
	EvalCoord2fv- : TglEvalCoord2fv;
	EvalMesh1- : TglEvalMesh1;
	EvalMesh2- : TglEvalMesh2;
	EvalPoint1- : TglEvalPoint1;
	EvalPoint2- : TglEvalPoint2;
	FeedbackBuffer- : TglFeedbackBuffer;
	Fogf- : TglFogf;
	Fogfv- : TglFogfv;
	Fogi- : TglFogi;
	Fogiv- : TglFogiv;
	Frustum- : TglFrustum;
	GenLists- : TglGenLists;
	GetClipPlane- : TglGetClipPlane;
	GetLightfv- : TglGetLightfv;
	GetLightiv- : TglGetLightiv;
	GetMapdv- : TglGetMapdv;
	GetMapfv- : TglGetMapfv;
	GetMapiv- : TglGetMapiv;
	GetMaterialfv- : TglGetMaterialfv;
	GetMaterialiv- : TglGetMaterialiv;
	GetPixelMapfv- : TglGetPixelMapfv;
	GetPixelMapuiv- : TglGetPixelMapuiv;
	GetPixelMapusv- : TglGetPixelMapusv;
	GetPolygonStipple- : TglGetPolygonStipple;
	GetTexEnvfv- : TglGetTexEnvfv;
	GetTexEnviv- : TglGetTexEnviv;
	GetTexGendv- : TglGetTexGendv;
	GetTexGenfv- : TglGetTexGenfv;
	GetTexGeniv- : TglGetTexGeniv;
	IndexMask- : TglIndexMask;
	IndexPointer- : TglIndexPointer;
	Indexd- : TglIndexd;
	Indexdv- : TglIndexdv;
	Indexf- : TglIndexf;
	Indexfv- : TglIndexfv;
	Indexi- : TglIndexi;
	Indexiv- : TglIndexiv;
	Indexs- : TglIndexs;
	Indexsv- : TglIndexsv;
	Indexub- : TglIndexub;
	Indexubv- : TglIndexubv;
	InitNames- : TglInitNames;
	InterleavedArrays- : TglInterleavedArrays;
	IsList- : TglIsList;
	IsTexture- : TglIsTexture;
	LightModelf- : TglLightModelf;
	XglLightModelfv- : TglLightModelfv;
	LightModeli- : TglLightModeli;
	LightModeliv- : TglLightModeliv;
	Lightf- : TglLightf;
	XglLightfv- : TglLightfv;
	Lighti- : TglLighti;
	Lightiv- : TglLightiv;
	LineStipple- : TglLineStipple;
	ListBase- : TglListBase;
	LoadIdentity- : TglLoadIdentity;
	LoadMatrixd- : TglLoadMatrixd;
	LoadMatrixf- : TglLoadMatrixf;
	LoadName- : TglLoadName;
	Map1d- : TglMap1d;
	Map1f- : TglMap1f;
	Map2d- : TglMap2d;
	Map2f- : TglMap2f;
	MapGrid1d- : TglMapGrid1d;
	MapGrid1f- : TglMapGrid1f;
	MapGrid2d- : TglMapGrid2d;
	MapGrid2f- : TglMapGrid2f;
	Materialf- : TglMaterialf;
	XglMaterialfv- : TglMaterialfv;
	Materiali- : TglMateriali;
	Materialiv- : TglMaterialiv;
	MatrixMode- : TglMatrixMode;
	MultMatrixd- : TglMultMatrixd;
	MultMatrixf- : TglMultMatrixf;
	NewList- : TglNewList;
	Normal3b- : TglNormal3b;
	Normal3bv- : TglNormal3bv;
	Normal3d- : TglNormal3d;
	XglNormal3dv- : TglNormal3dv;
	Normal3f- : TglNormal3f;
	XglNormal3fv- : TglNormal3fv;
	Normal3i- : TglNormal3i;
	Normal3iv- : TglNormal3iv;
	Normal3s- : TglNormal3s;
	Normal3sv- : TglNormal3sv;
	NormalPointer- : TglNormalPointer;
	Ortho- : TglOrtho;
	PassThrough- : TglPassThrough;
	PixelMapfv- : TglPixelMapfv;
	PixelMapuiv- : TglPixelMapuiv;
	PixelMapusv- : TglPixelMapusv;
	PixelTransferf- : TglPixelTransferf;
	PixelTransferi- : TglPixelTransferi;
	PixelZoom- : TglPixelZoom;
	PolygonStipple- : TglPolygonStipple;
	PopAttrib- : TglPopAttrib;
	PopClientAttrib- : TglPopClientAttrib;
	PopMatrix- : TglPopMatrix;
	PopName- : TglPopName;
	PrioritizeTextures- : TglPrioritizeTextures;
	PushAttrib- : TglPushAttrib;
	PushClientAttrib- : TglPushClientAttrib;
	PushMatrix- : TglPushMatrix;
	PushName- : TglPushName;
	RasterPos2d- : TglRasterPos2d;
	RasterPos2dv- : TglRasterPos2dv;
	RasterPos2f- : TglRasterPos2f;
	RasterPos2fv- : TglRasterPos2fv;
	RasterPos2i- : TglRasterPos2i;
	RasterPos2iv- : TglRasterPos2iv;
	RasterPos2s- : TglRasterPos2s;
	RasterPos2sv- : TglRasterPos2sv;
	RasterPos3d- : TglRasterPos3d;
	RasterPos3dv- : TglRasterPos3dv;
	RasterPos3f- : TglRasterPos3f;
	RasterPos3fv- : TglRasterPos3fv;
	RasterPos3i- : TglRasterPos3i;
	RasterPos3iv- : TglRasterPos3iv;
	RasterPos3s- : TglRasterPos3s;
	RasterPos3sv- : TglRasterPos3sv;
	RasterPos4d- : TglRasterPos4d;
	RasterPos4dv- : TglRasterPos4dv;
	RasterPos4f- : TglRasterPos4f;
	RasterPos4fv- : TglRasterPos4fv;
	RasterPos4i- : TglRasterPos4i;
	RasterPos4iv- : TglRasterPos4iv;
	RasterPos4s- : TglRasterPos4s;
	RasterPos4sv- : TglRasterPos4sv;
	Rectd- : TglRectd;
	Rectdv- : TglRectdv;
	Rectf- : TglRectf;
	Rectfv- : TglRectfv;
	Recti- : TglRecti;
	Rectiv- : TglRectiv;
	Rects- : TglRects;
	Rectsv- : TglRectsv;
	RenderMode- : TglRenderMode;
	Rotated- : TglRotated;
	Rotatef- : TglRotatef;
	Scaled- : TglScaled;
	Scalef- : TglScalef;
	SelectBuffer- : TglSelectBuffer;
	ShadeModel- : TglShadeModel;
	TexCoord1d- : TglTexCoord1d;
	TexCoord1dv- : TglTexCoord1dv;
	TexCoord1f- : TglTexCoord1f;
	TexCoord1fv- : TglTexCoord1fv;
	TexCoord1i- : TglTexCoord1i;
	TexCoord1iv- : TglTexCoord1iv;
	TexCoord1s- : TglTexCoord1s;
	TexCoord1sv- : TglTexCoord1sv;
	TexCoord2d- : TglTexCoord2d;
	TexCoord2dv- : TglTexCoord2dv;
	TexCoord2f- : TglTexCoord2f;
	TexCoord2fv- : TglTexCoord2fv;
	TexCoord2i- : TglTexCoord2i;
	TexCoord2iv- : TglTexCoord2iv;
	TexCoord2s- : TglTexCoord2s;
	TexCoord2sv- : TglTexCoord2sv;
	TexCoord3d- : TglTexCoord3d;
	TexCoord3dv- : TglTexCoord3dv;
	TexCoord3f- : TglTexCoord3f;
	TexCoord3fv- : TglTexCoord3fv;
	TexCoord3i- : TglTexCoord3i;
	TexCoord3iv- : TglTexCoord3iv;
	TexCoord3s- : TglTexCoord3s;
	TexCoord3sv- : TglTexCoord3sv;
	TexCoord4d- : TglTexCoord4d;
	TexCoord4dv- : TglTexCoord4dv;
	TexCoord4f- : TglTexCoord4f;
	TexCoord4fv- : TglTexCoord4fv;
	TexCoord4i- : TglTexCoord4i;
	TexCoord4iv- : TglTexCoord4iv;
	TexCoord4s- : TglTexCoord4s;
	TexCoord4sv- : TglTexCoord4sv;
	TexCoordPointer- : TglTexCoordPointer;
	TexEnvf- : TglTexEnvf;
	TexEnvfv- : TglTexEnvfv;
	TexEnvi- : TglTexEnvi;
	TexEnviv- : TglTexEnviv;
	TexGend- : TglTexGend;
	TexGendv- : TglTexGendv;
	TexGenf- : TglTexGenf;
	TexGenfv- : TglTexGenfv;
	TexGeni- : TglTexGeni;
	TexGeniv- : TglTexGeniv;
	Translated- : TglTranslated;
	Translatef- : TglTranslatef;
	Vertex2d- : TglVertex2d;
	Vertex2dv- : TglVertex2dv;
	Vertex2f- : TglVertex2f;
	Vertex2fv- : TglVertex2fv;
	Vertex2i- : TglVertex2i;
	Vertex2iv- : TglVertex2iv;
	Vertex2s- : TglVertex2s;
	Vertex2sv- : TglVertex2sv;
	Vertex3d- : TglVertex3d;
	XglVertex3dv- : TglVertex3dv;
	Vertex3f- : TglVertex3f;
	XglVertex3fv- : TglVertex3fv;
	Vertex3i- : TglVertex3i;
	Vertex3iv- : TglVertex3iv;
	Vertex3s- : TglVertex3s;
	Vertex3sv- : TglVertex3sv;
	Vertex4d- : TglVertex4d;
	Vertex4dv- : TglVertex4dv;
	Vertex4f- : TglVertex4f;
	Vertex4fv- : TglVertex4fv;
	Vertex4i- : TglVertex4i;
	Vertex4iv- : TglVertex4iv;
	Vertex4s- : TglVertex4s;
	Vertex4sv- : TglVertex4sv;
	VertexPointer- : TglVertexPointer;
	(*! endif  *)

	(*! GL_VERSION_1_2 *)
	BlendColor- : TglBlendColor;
	BlendEquation- : TglBlendEquation;
	DrawRangeElements- : TglDrawRangeElements;
	TexImage3D- : TglTexImage3D;
	TexSubImage3D- : TglTexSubImage3D;
	CopyTexSubImage3D- : TglCopyTexSubImage3D;

	(*! ifdef DEPRECATED *)
	ColorTable- : TglColorTable;
	ColorTableParameterfv- : TglColorTableParameterfv;
	ColorTableParameteriv- : TglColorTableParameteriv;
	CopyColorTable- : TglCopyColorTable;
	GetColorTable- : TglGetColorTable;
	GetColorTableParameterfv- : TglGetColorTableParameterfv;
	GetColorTableParameteriv- : TglGetColorTableParameteriv;
	ColorSubTable- : TglColorSubTable;
	CopyColorSubTable- : TglCopyColorSubTable;
	ConvolutionFilter1D- : TglConvolutionFilter1D;
	ConvolutionFilter2D- : TglConvolutionFilter2D;
	ConvolutionParameterf- : TglConvolutionParameterf;
	ConvolutionParameterfv- : TglConvolutionParameterfv;
	ConvolutionParameteri- : TglConvolutionParameteri;
	ConvolutionParameteriv- : TglConvolutionParameteriv;
	CopyConvolutionFilter1D- : TglCopyConvolutionFilter1D;
	CopyConvolutionFilter2D- : TglCopyConvolutionFilter2D;
	GetConvolutionFilter- : TglGetConvolutionFilter;
	GetConvolutionParameterfv- : TglGetConvolutionParameterfv;
	GetConvolutionParameteriv- : TglGetConvolutionParameteriv;
	GetSeparableFilter- : TglGetSeparableFilter;
	SeparableFilter2D- : TglSeparableFilter2D;
	GetHistogram- : TglGetHistogram;
	GetHistogramParameterfv- : TglGetHistogramParameterfv;
	GetHistogramParameteriv- : TglGetHistogramParameteriv;
	GetMinmax- : TglGetMinmax;
	GetMinmaxParameterfv- : TglGetMinmaxParameterfv;
	GetMinmaxParameteriv- : TglGetMinmaxParameteriv;
	Histogram- : TglHistogram;
	Minmax- : TglMinmax;
	ResetHistogram- : TglResetHistogram;
	ResetMinmax- : TglResetMinmax;
	(* $endif *)

	(*! GL_VERSION_1_3 *)
	ActiveTexture- : TglActiveTexture;
	SampleCoverage- : TglSampleCoverage;
	CompressedTexImage3D- : TglCompressedTexImage3D;
	CompressedTexImage2D- : TglCompressedTexImage2D;
	CompressedTexImage1D- : TglCompressedTexImage1D;
	CompressedTexSubImage3D- : TglCompressedTexSubImage3D;
	CompressedTexSubImage2D- : TglCompressedTexSubImage2D;
	CompressedTexSubImage1D- : TglCompressedTexSubImage1D;
	GetCompressedTexImage- : TglGetCompressedTexImage;

	(*!  ifdef DEPRECATED *)
	ClientActiveTexture- : TglClientActiveTexture;
	MultiTexCoord1d- : TglMultiTexCoord1d;
	MultiTexCoord1dv- : TglMultiTexCoord1dv;
	MultiTexCoord1f- : TglMultiTexCoord1f;
	MultiTexCoord1fv- : TglMultiTexCoord1fv;
	MultiTexCoord1i- : TglMultiTexCoord1i;
	MultiTexCoord1iv- : TglMultiTexCoord1iv;
	MultiTexCoord1s- : TglMultiTexCoord1s;
	MultiTexCoord1sv- : TglMultiTexCoord1sv;
	MultiTexCoord2d- : TglMultiTexCoord2d;
	MultiTexCoord2dv- : TglMultiTexCoord2dv;
	MultiTexCoord2f- : TglMultiTexCoord2f;
	MultiTexCoord2fv- : TglMultiTexCoord2fv;
	MultiTexCoord2i- : TglMultiTexCoord2i;
	MultiTexCoord2iv- : TglMultiTexCoord2iv;
	MultiTexCoord2s- : TglMultiTexCoord2s;
	MultiTexCoord2sv- : TglMultiTexCoord2sv;
	MultiTexCoord3d- : TglMultiTexCoord3d;
	MultiTexCoord3dv- : TglMultiTexCoord3dv;
	MultiTexCoord3f- : TglMultiTexCoord3f;
	MultiTexCoord3fv- : TglMultiTexCoord3fv;
	MultiTexCoord3i- : TglMultiTexCoord3i;
	MultiTexCoord3iv- : TglMultiTexCoord3iv;
	MultiTexCoord3s- : TglMultiTexCoord3s;
	MultiTexCoord3sv- : TglMultiTexCoord3sv;
	MultiTexCoord4d- : TglMultiTexCoord4d;
	MultiTexCoord4dv- : TglMultiTexCoord4dv;
	MultiTexCoord4f- : TglMultiTexCoord4f;
	MultiTexCoord4fv- : TglMultiTexCoord4fv;
	MultiTexCoord4i- : TglMultiTexCoord4i;
	MultiTexCoord4iv- : TglMultiTexCoord4iv;
	MultiTexCoord4s- : TglMultiTexCoord4s;
	MultiTexCoord4sv- : TglMultiTexCoord4sv;
	LoadTransposeMatrixf- : TglLoadTransposeMatrixf;
	LoadTransposeMatrixd- : TglLoadTransposeMatrixd;
	MultTransposeMatrixf- : TglMultTransposeMatrixf;
	MultTransposeMatrixd- : TglMultTransposeMatrixd;
	(*! endif  *)

	(*! GL_VERSION_1_4 *)
	BlendFuncSeparate- : TglBlendFuncSeparate;
	MultiDrawArrays- : TglMultiDrawArrays;
	MultiDrawElements- : TglMultiDrawElements;
	PointParameterf- : TglPointParameterf;
	PointParameterfv- : TglPointParameterfv;
	PointParameteri- : TglPointParameteri;
	PointParameteriv- : TglPointParameteriv;

	(*! ifdef DEPRECATED *)
	FogCoordf- : TglFogCoordf;
	FogCoordfv- : TglFogCoordfv;
	FogCoordd- : TglFogCoordd;
	FogCoorddv- : TglFogCoorddv;
	FogCoordPointer- : TglFogCoordPointer;
	SecondaryColor3b- : TglSecondaryColor3b;
	SecondaryColor3bv- : TglSecondaryColor3bv;
	SecondaryColor3d- : TglSecondaryColor3d;
	SecondaryColor3dv- : TglSecondaryColor3dv;
	SecondaryColor3f- : TglSecondaryColor3f;
	SecondaryColor3fv- : TglSecondaryColor3fv;
	SecondaryColor3i- : TglSecondaryColor3i;
	SecondaryColor3iv- : TglSecondaryColor3iv;
	SecondaryColor3s- : TglSecondaryColor3s;
	SecondaryColor3sv- : TglSecondaryColor3sv;
	SecondaryColor3ub- : TglSecondaryColor3ub;
	SecondaryColor3ubv- : TglSecondaryColor3ubv;
	SecondaryColor3ui- : TglSecondaryColor3ui;
	SecondaryColor3uiv- : TglSecondaryColor3uiv;
	SecondaryColor3us- : TglSecondaryColor3us;
	SecondaryColor3usv- : TglSecondaryColor3usv;
	SecondaryColorPointer- : TglSecondaryColorPointer;
	WindowPos2d- : TglWindowPos2d;
	WindowPos2dv- : TglWindowPos2dv;
	WindowPos2f- : TglWindowPos2f;
	WindowPos2fv- : TglWindowPos2fv;
	WindowPos2i- : TglWindowPos2i;
	WindowPos2iv- : TglWindowPos2iv;
	WindowPos2s- : TglWindowPos2s;
	WindowPos2sv- : TglWindowPos2sv;
	WindowPos3d- : TglWindowPos3d;
	WindowPos3dv- : TglWindowPos3dv;
	WindowPos3f- : TglWindowPos3f;
	WindowPos3fv- : TglWindowPos3fv;
	WindowPos3i- : TglWindowPos3i;
	WindowPos3iv- : TglWindowPos3iv;
	WindowPos3s- : TglWindowPos3s;
	WindowPos3sv- : TglWindowPos3sv;
	(*! endif  *)

	(*! GL_VERSION_1_5  *)
	GenQueries- : TglGenQueries;
	DeleteQueries- : TglDeleteQueries;
	IsQuery- : TglIsQuery;
	BeginQuery- : TglBeginQuery;
	EndQuery- : TglEndQuery;
	GetQueryiv- : TglGetQueryiv;
	GetQueryObjectiv- : TglGetQueryObjectiv;
	GetQueryObjectuiv- : TglGetQueryObjectuiv;
	BindBuffer- : TglBindBuffer;
	DeleteBuffers- : TglDeleteBuffers;
	GenBuffers- : TglGenBuffers;
	IsBuffer- : TglIsBuffer;
	BufferData- : TglBufferData;
	BufferSubData- : TglBufferSubData;
	GetBufferSubData- : TglGetBufferSubData;
	MapBuffer- : TglMapBuffer;
	UnmapBuffer- : TglUnmapBuffer;
	GetBufferParameteriv- : TglGetBufferParameteriv;
	GetBufferPointerv- : TglGetBufferPointerv;

	(*! GL_VERSION_2_0  *)
	BlendEquationSeparate- : TglBlendEquationSeparate;
	DrawBuffers- : TglDrawBuffers;
	StencilOpSeparate- : TglStencilOpSeparate;
	StencilFuncSeparate- : TglStencilFuncSeparate;
	StencilMaskSeparate- : TglStencilMaskSeparate;
	AttachShader- : TglAttachShader;
	BindAttribLocation- : TglBindAttribLocation;
	CompileShader- : TglCompileShader;
	CreateProgram- : TglCreateProgram;
	CreateShader- : TglCreateShader;
	DeleteProgram- : TglDeleteProgram;
	DeleteShader- : TglDeleteShader;
	DetachShader- : TglDetachShader;
	DisableVertexAttribArray- : TglDisableVertexAttribArray;
	EnableVertexAttribArray- : TglEnableVertexAttribArray;
	GetActiveAttrib- : TglGetActiveAttrib;
	GetActiveUniform- : TglGetActiveUniform;
	GetAttachedShaders- : TglGetAttachedShaders;
	GetAttribLocation- : TglGetAttribLocation;
	GetProgramiv- : TglGetProgramiv;
	GetProgramInfoLog- : TglGetProgramInfoLog;
	GetShaderiv- : TglGetShaderiv;
	GetShaderInfoLog- : TglGetShaderInfoLog;
	GetShaderSource- : TglGetShaderSource;
	GetUniformLocation- : TglGetUniformLocation;
	GetUniformfv- : TglGetUniformfv;
	GetUniformiv- : TglGetUniformiv;
	GetVertexAttribfv- : TglGetVertexAttribfv;
	GetVertexAttribiv- : TglGetVertexAttribiv;
	GetVertexAttribPointerv- : TglGetVertexAttribPointerv;
	IsProgram- : TglIsProgram;
	IsShader- : TglIsShader;
	LinkProgram- : TglLinkProgram;
	ShaderSource- : TglShaderSource;
	UseProgram- : TglUseProgram;
	Uniform1f- : TglUniform1f;
	Uniform2f- : TglUniform2f;
	Uniform3f- : TglUniform3f;
	Uniform4f- : TglUniform4f;
	Uniform1i- : TglUniform1i;
	Uniform2i- : TglUniform2i;
	Uniform3i- : TglUniform3i;
	Uniform4i- : TglUniform4i;
	Uniform1fv- : TglUniform1fv;
	Uniform2fv- : TglUniform2fv;
	Uniform3fv- : TglUniform3fv;
	Uniform4fv- : TglUniform4fv;
	Uniform1iv- : TglUniform1iv;
	Uniform2iv- : TglUniform2iv;
	Uniform3iv- : TglUniform3iv;
	Uniform4iv- : TglUniform4iv;
	UniformMatrix2fv- : TglUniformMatrix2fv;
	UniformMatrix3fv- : TglUniformMatrix3fv;
	UniformMatrix4fv- : TglUniformMatrix4fv;
	ValidateProgram- : TglValidateProgram;
	VertexAttrib1d- : TglVertexAttrib1d;
	VertexAttrib1dv- : TglVertexAttrib1dv;
	VertexAttrib1f- : TglVertexAttrib1f;
	VertexAttrib1fv- : TglVertexAttrib1fv;
	VertexAttrib1s- : TglVertexAttrib1s;
	VertexAttrib1sv- : TglVertexAttrib1sv;
	VertexAttrib2d- : TglVertexAttrib2d;
	VertexAttrib2dv- : TglVertexAttrib2dv;
	VertexAttrib2f- : TglVertexAttrib2f;
	VertexAttrib2fv- : TglVertexAttrib2fv;
	VertexAttrib2s- : TglVertexAttrib2s;
	VertexAttrib2sv- : TglVertexAttrib2sv;
	VertexAttrib3d- : TglVertexAttrib3d;
	VertexAttrib3dv- : TglVertexAttrib3dv;
	VertexAttrib3f- : TglVertexAttrib3f;
	VertexAttrib3fv- : TglVertexAttrib3fv;
	VertexAttrib3s- : TglVertexAttrib3s;
	VertexAttrib3sv- : TglVertexAttrib3sv;
	VertexAttrib4Nbv- : TglVertexAttrib4Nbv;
	VertexAttrib4Niv- : TglVertexAttrib4Niv;
	VertexAttrib4Nsv- : TglVertexAttrib4Nsv;
	VertexAttrib4Nub- : TglVertexAttrib4Nub;
	VertexAttrib4Nubv- : TglVertexAttrib4Nubv;
	VertexAttrib4Nuiv- : TglVertexAttrib4Nuiv;
	VertexAttrib4Nusv- : TglVertexAttrib4Nusv;
	VertexAttrib4bv- : TglVertexAttrib4bv;
	VertexAttrib4d- : TglVertexAttrib4d;
	VertexAttrib4dv- : TglVertexAttrib4dv;
	VertexAttrib4f- : TglVertexAttrib4f;
	VertexAttrib4fv- : TglVertexAttrib4fv;
	VertexAttrib4iv- : TglVertexAttrib4iv;
	VertexAttrib4s- : TglVertexAttrib4s;
	VertexAttrib4sv- : TglVertexAttrib4sv;
	VertexAttrib4ubv- : TglVertexAttrib4ubv;
	VertexAttrib4uiv- : TglVertexAttrib4uiv;
	VertexAttrib4usv- : TglVertexAttrib4usv;
	VertexAttribPointer- : TglVertexAttribPointer;

	(*! GL_VERSION_2_1 *)
	UniformMatrix2x3fv- : TglUniformMatrix2x3fv;
	UniformMatrix3x2fv- : TglUniformMatrix3x2fv;
	UniformMatrix2x4fv- : TglUniformMatrix2x4fv;
	UniformMatrix4x2fv- : TglUniformMatrix4x2fv;
	UniformMatrix3x4fv- : TglUniformMatrix3x4fv;
	UniformMatrix4x3fv- : TglUniformMatrix4x3fv;

	(*! GL_VERSION_3_0 *)
	ColorMaski- : TglColorMaski;
	GetBooleani_v- : TglGetBooleani_v;
	GetIntegeri_v- : TglGetIntegeri_v;
	Enablei- : TglEnablei;
	Disablei- : TglDisablei;
	IsEnabledi- : TglIsEnabledi;
	BeginTransformFeedback- : TglBeginTransformFeedback;
	EndTransformFeedback- : TglEndTransformFeedback;
	BindBufferRange- : TglBindBufferRange;
	BindBufferBase- : TglBindBufferBase;
	TransformFeedbackVaryings- : TglTransformFeedbackVaryings;
	GetTransformFeedbackVarying- : TglGetTransformFeedbackVarying;
	ClampColor- : TglClampColor;
	BeginConditionalRender- : TglBeginConditionalRender;
	EndConditionalRender- : TglEndConditionalRender;
	VertexAttribI1i- : TglVertexAttribI1i;
	VertexAttribI2i- : TglVertexAttribI2i;
	VertexAttribI3i- : TglVertexAttribI3i;
	VertexAttribI4i- : TglVertexAttribI4i;
	VertexAttribI1ui- : TglVertexAttribI1ui;
	VertexAttribI2ui- : TglVertexAttribI2ui;
	VertexAttribI3ui- : TglVertexAttribI3ui;
	VertexAttribI4ui- : TglVertexAttribI4ui;
	VertexAttribI1iv- : TglVertexAttribI1iv;
	VertexAttribI2iv- : TglVertexAttribI2iv;
	VertexAttribI3iv- : TglVertexAttribI3iv;
	VertexAttribI4iv- : TglVertexAttribI4iv;
	VertexAttribI1uiv- : TglVertexAttribI1uiv;
	VertexAttribI2uiv- : TglVertexAttribI2uiv;
	VertexAttribI3uiv- : TglVertexAttribI3uiv;
	VertexAttribI4uiv- : TglVertexAttribI4uiv;
	VertexAttribI4bv- : TglVertexAttribI4bv;
	VertexAttribI4sv- : TglVertexAttribI4sv;
	VertexAttribI4ubv- : TglVertexAttribI4ubv;
	VertexAttribI4usv- : TglVertexAttribI4usv;
	VertexAttribIPointer- : TglVertexAttribIPointer;
	GetVertexAttribIiv- : TglGetVertexAttribIiv;
	GetVertexAttribIuiv- : TglGetVertexAttribIuiv;
	GetUniformuiv- : TglGetUniformuiv;
	BindFragDataLocation- : TglBindFragDataLocation;
	GetFragDataLocation- : TglGetFragDataLocation;
	Uniform1ui- : TglUniform1ui;
	Uniform2ui- : TglUniform2ui;
	Uniform3ui- : TglUniform3ui;
	Uniform4ui- : TglUniform4ui;
	Uniform1uiv- : TglUniform1uiv;
	Uniform2uiv- : TglUniform2uiv;
	Uniform3uiv- : TglUniform3uiv;
	Uniform4uiv- : TglUniform4uiv;
	TexParameterIiv- : TglTexParameterIiv;
	TexParameterIuiv- : TglTexParameterIuiv;
	GetTexParameterIiv- : TglGetTexParameterIiv;
	GetTexParameterIuiv- : TglGetTexParameterIuiv;
	ClearBufferiv- : TglClearBufferiv;
	ClearBufferuiv- : TglClearBufferuiv;
	ClearBufferfv- : TglClearBufferfv;
	ClearBufferfi- : TglClearBufferfi;
	XglGetStringi- : TglGetStringi;

	(* GL_VERSION_2_1 *)
	EnableVertexArrayEXT- : TglEnableVertexArrayEXT;
	EnableVertexArrayAttribEXT- : TglEnableVertexArrayAttribEXT;
	VertexArrayVertexAttribOffsetEXT- : TglVertexArrayVertexAttribOffsetEXT;

	(*! GL_VERSION_3_1 *)
	DrawArraysInstanced- : TglDrawArraysInstanced;
	DrawElementsInstanced- : TglDrawElementsInstanced;
	TexBuffer- : TglTexBuffer;
	PrimitiveRestartIndex- : TglPrimitiveRestartIndex;

	(*! GL_VERSION_3_2 *)
	GetInteger64i_v- : TglGetInteger64i_v;
	GetBufferParameteri64v- : TglGetBufferParameteri64v;
	FramebufferTexture- : TglFramebufferTexture;

	(*! GL_VERSION_3_3  *)
	VertexAttribDivisor- : TglVertexAttribDivisor;

	(*! GL_VERSION_4_0  *)
	(* OpenGL 4.0 also reuses entry points from these extensions:  *)
	(* ARB_texture_query_lod (no entry points)  *)
	(* ARB_draw_indirect  *)
	(* ARB_gpu_shader5 (no entry points)  *)
	(* ARB_gpu_shader_fp64  *)
	(* ARB_shader_subroutine  *)
	(* ARB_tessellation_shader  *)
	(* ARB_texture_buffer_object_rgb32 (no entry points)  *)
	(* ARB_texture_cube_map_array (no entry points)  *)
	(* ARB_texture_gather (no entry points)  *)
	(* ARB_transform_feedback2  *)
	(* ARB_transform_feedback3  *)
	MinSampleShading- : TglMinSampleShading;
	BlendEquationi- : TglBlendEquationi;
	BlendEquationSeparatei- : TglBlendEquationSeparatei;
	BlendFunci- : TglBlendFunci;
	BlendFuncSeparatei- : TglBlendFuncSeparatei;
	(* GL_3DFX_tbuffer  *)
	TbufferMask3DFX- : TglTbufferMask3DFX;
	(* GL_APPLE_element_array  *)
	ElementPointerAPPLE- : TglElementPointerAPPLE;
	DrawElementArrayAPPLE- : TglDrawElementArrayAPPLE;
	DrawRangeElementArrayAPPLE- : TglDrawRangeElementArrayAPPLE;
	MultiDrawElementArrayAPPLE- : TglMultiDrawElementArrayAPPLE;
	MultiDrawRangeElementArrayAPPLE- : TglMultiDrawRangeElementArrayAPPLE;
	(*  GL_APPLE_fence  *)
	GenFencesAPPLE- : TglGenFencesAPPLE;
	DeleteFencesAPPLE- : TglDeleteFencesAPPLE;
	SetFenceAPPLE- : TglSetFenceAPPLE;
	IsFenceAPPLE- : TglIsFenceAPPLE;
	TestFenceAPPLE- : TglTestFenceAPPLE;
	FinishFenceAPPLE- : TglFinishFenceAPPLE;
	TestObjectAPPLE- : TglTestObjectAPPLE;
	FinishObjectAPPLE- : TglFinishObjectAPPLE;
	(*  GL_APPLE_vertex_array_object  *)
	BindVertexArrayAPPLE- : TglBindVertexArrayAPPLE;
	DeleteVertexArraysAPPLE- : TglDeleteVertexArraysAPPLE;
	GenVertexArraysAPPLE- : TglGenVertexArraysAPPLE;
	IsVertexArrayAPPLE- : TglIsVertexArrayAPPLE;
	(*  GL_APPLE_vertex_array_range  *)
	VertexArrayRangeAPPLE- : TglVertexArrayRangeAPPLE;
	FlushVertexArrayRangeAPPLE- : TglFlushVertexArrayRangeAPPLE;
	VertexArrayParameteriAPPLE- : TglVertexArrayParameteriAPPLE;
	(*  GL_APPLE_texture_range  *)
	TextureRangeAPPLE- : TglTextureRangeAPPLE;
	GetTexParameterPointervAPPLE- : TglGetTexParameterPointervAPPLE;
	(*  GL_APPLE_vertex_program_evaluators  *)
	EnableVertexAttribAPPLE- : TglEnableVertexAttribAPPLE;
	DisableVertexAttribAPPLE- : TglDisableVertexAttribAPPLE;
	IsVertexAttribEnabledAPPLE- : TglIsVertexAttribEnabledAPPLE;
	MapVertexAttrib1dAPPLE- : TglMapVertexAttrib1dAPPLE;
	MapVertexAttrib1fAPPLE- : TglMapVertexAttrib1fAPPLE;
	MapVertexAttrib2dAPPLE- : TglMapVertexAttrib2dAPPLE;
	MapVertexAttrib2fAPPLE- : TglMapVertexAttrib2fAPPLE;
	(*  GL_APPLE_object_purgeable  *)
	ObjectPurgeableAPPLE- : TglObjectPurgeableAPPLE;
	ObjectUnpurgeableAPPLE- : TglObjectUnpurgeableAPPLE;
	GetObjectParameterivAPPLE- : TglGetObjectParameterivAPPLE;
	(*  GL_ARB_matrix_palette  *)
	CurrentPaletteMatrixARB- : TglCurrentPaletteMatrixARB;
	MatrixIndexubvARB- : TglMatrixIndexubvARB;
	MatrixIndexusvARB- : TglMatrixIndexusvARB;
	MatrixIndexuivARB- : TglMatrixIndexuivARB;
	MatrixIndexPointerARB- : TglMatrixIndexPointerARB;
	(*  GL_ARB_multisample  *)
	SampleCoverageARB- : TglSampleCoverageARB;
	(*  GL_ARB_multitexture  *)
	ActiveTextureARB- : TglActiveTextureARB;
	ClientActiveTextureARB- : TglClientActiveTextureARB;
	MultiTexCoord1dARB- : TglMultiTexCoord1dARB;
	MultiTexCoord1dvARB- : TglMultiTexCoord1dvARB;
	MultiTexCoord1fARB- : TglMultiTexCoord1fARB;
	MultiTexCoord1fvARB- : TglMultiTexCoord1fvARB;
	MultiTexCoord1iARB- : TglMultiTexCoord1iARB;
	MultiTexCoord1ivARB- : TglMultiTexCoord1ivARB;
	MultiTexCoord1sARB- : TglMultiTexCoord1sARB;
	MultiTexCoord1svARB- : TglMultiTexCoord1svARB;
	MultiTexCoord2dARB- : TglMultiTexCoord2dARB;
	MultiTexCoord2dvARB- : TglMultiTexCoord2dvARB;
	MultiTexCoord2fARB- : TglMultiTexCoord2fARB;
	MultiTexCoord2fvARB- : TglMultiTexCoord2fvARB;
	MultiTexCoord2iARB- : TglMultiTexCoord2iARB;
	MultiTexCoord2ivARB- : TglMultiTexCoord2ivARB;
	MultiTexCoord2sARB- : TglMultiTexCoord2sARB;
	MultiTexCoord2svARB- : TglMultiTexCoord2svARB;
	MultiTexCoord3dARB- : TglMultiTexCoord3dARB;
	MultiTexCoord3dvARB- : TglMultiTexCoord3dvARB;
	MultiTexCoord3fARB- : TglMultiTexCoord3fARB;
	MultiTexCoord3fvARB- : TglMultiTexCoord3fvARB;
	MultiTexCoord3iARB- : TglMultiTexCoord3iARB;
	MultiTexCoord3ivARB- : TglMultiTexCoord3ivARB;
	MultiTexCoord3sARB- : TglMultiTexCoord3sARB;
	MultiTexCoord3svARB- : TglMultiTexCoord3svARB;
	MultiTexCoord4dARB- : TglMultiTexCoord4dARB;
	MultiTexCoord4dvARB- : TglMultiTexCoord4dvARB;
	MultiTexCoord4fARB- : TglMultiTexCoord4fARB;
	MultiTexCoord4fvARB- : TglMultiTexCoord4fvARB;
	MultiTexCoord4iARB- : TglMultiTexCoord4iARB;
	MultiTexCoord4ivARB- : TglMultiTexCoord4ivARB;
	MultiTexCoord4sARB- : TglMultiTexCoord4sARB;
	MultiTexCoord4svARB- : TglMultiTexCoord4svARB;
	(*  GL_ARB_point_parameters  *)
	PointParameterfARB- : TglPointParameterfARB;
	PointParameterfvARB- : TglPointParameterfvARB;
	(*  GL_ARB_texture_compression  *)
	CompressedTexImage3DARB- : TglCompressedTexImage3DARB;
	CompressedTexImage2DARB- : TglCompressedTexImage2DARB;
	CompressedTexImage1DARB- : TglCompressedTexImage1DARB;
	CompressedTexSubImage3DARB- : TglCompressedTexSubImage3DARB;
	CompressedTexSubImage2DARB- : TglCompressedTexSubImage2DARB;
	CompressedTexSubImage1DARB- : TglCompressedTexSubImage1DARB;
	GetCompressedTexImageARB- : TglGetCompressedTexImageARB;
	(*  GL_ARB_transpose_matrix  *)
	LoadTransposeMatrixfARB- : TglLoadTransposeMatrixfARB;
	LoadTransposeMatrixdARB- : TglLoadTransposeMatrixdARB;
	MultTransposeMatrixfARB- : TglMultTransposeMatrixfARB;
	MultTransposeMatrixdARB- : TglMultTransposeMatrixdARB;
	(*  GL_ARB_vertex_blend  *)
	WeightbvARB- : TglWeightbvARB;
	WeightsvARB- : TglWeightsvARB;
	WeightivARB- : TglWeightivARB;
	WeightfvARB- : TglWeightfvARB;
	WeightdvARB- : TglWeightdvARB;
	WeightubvARB- : TglWeightubvARB;
	WeightusvARB- : TglWeightusvARB;
	WeightuivARB- : TglWeightuivARB;
	WeightPointerARB- : TglWeightPointerARB;
	VertexBlendARB- : TglVertexBlendARB;
	(*  GL_ARB_vertex_buffer_object  *)
	BindBufferARB- : TglBindBufferARB;
	DeleteBuffersARB- : TglDeleteBuffersARB;
	GenBuffersARB- : TglGenBuffersARB;
	IsBufferARB- : TglIsBufferARB;
	BufferDataARB- : TglBufferDataARB;
	BufferSubDataARB- : TglBufferSubDataARB;
	GetBufferSubDataARB- : TglGetBufferSubDataARB;
	MapBufferARB- : TglMapBufferARB;
	UnmapBufferARB- : TglUnmapBufferARB;
	GetBufferParameterivARB- : TglGetBufferParameterivARB;
	GetBufferPointervARB- : TglGetBufferPointervARB;
	(*  GL_ARB_vertex_program  *)
	VertexAttrib1dARB- : TglVertexAttrib1dARB;
	VertexAttrib1dvARB- : TglVertexAttrib1dvARB;
	VertexAttrib1fARB- : TglVertexAttrib1fARB;
	VertexAttrib1fvARB- : TglVertexAttrib1fvARB;
	VertexAttrib1sARB- : TglVertexAttrib1sARB;
	VertexAttrib1svARB- : TglVertexAttrib1svARB;
	VertexAttrib2dARB- : TglVertexAttrib2dARB;
	VertexAttrib2dvARB- : TglVertexAttrib2dvARB;
	VertexAttrib2fARB- : TglVertexAttrib2fARB;
	VertexAttrib2fvARB- : TglVertexAttrib2fvARB;
	VertexAttrib2sARB- : TglVertexAttrib2sARB;
	VertexAttrib2svARB- : TglVertexAttrib2svARB;
	VertexAttrib3dARB- : TglVertexAttrib3dARB;
	VertexAttrib3dvARB- : TglVertexAttrib3dvARB;
	VertexAttrib3fARB- : TglVertexAttrib3fARB;
	VertexAttrib3fvARB- : TglVertexAttrib3fvARB;
	VertexAttrib3sARB- : TglVertexAttrib3sARB;
	VertexAttrib3svARB- : TglVertexAttrib3svARB;
	VertexAttrib4NbvARB- : TglVertexAttrib4NbvARB;
	VertexAttrib4NivARB- : TglVertexAttrib4NivARB;
	VertexAttrib4NsvARB- : TglVertexAttrib4NsvARB;
	VertexAttrib4NubARB- : TglVertexAttrib4NubARB;
	VertexAttrib4NubvARB- : TglVertexAttrib4NubvARB;
	VertexAttrib4NuivARB- : TglVertexAttrib4NuivARB;
	VertexAttrib4NusvARB- : TglVertexAttrib4NusvARB;
	VertexAttrib4bvARB- : TglVertexAttrib4bvARB;
	VertexAttrib4dARB- : TglVertexAttrib4dARB;
	VertexAttrib4dvARB- : TglVertexAttrib4dvARB;
	VertexAttrib4fARB- : TglVertexAttrib4fARB;
	VertexAttrib4fvARB- : TglVertexAttrib4fvARB;
	VertexAttrib4ivARB- : TglVertexAttrib4ivARB;
	VertexAttrib4sARB- : TglVertexAttrib4sARB;
	VertexAttrib4svARB- : TglVertexAttrib4svARB;
	VertexAttrib4ubvARB- : TglVertexAttrib4ubvARB;
	VertexAttrib4uivARB- : TglVertexAttrib4uivARB;
	VertexAttrib4usvARB- : TglVertexAttrib4usvARB;
	VertexAttribPointerARB- : TglVertexAttribPointerARB;
	EnableVertexAttribArrayARB- : TglEnableVertexAttribArrayARB;
	DisableVertexAttribArrayARB- : TglDisableVertexAttribArrayARB;
	ProgramStringARB- : TglProgramStringARB;
	BindProgramARB- : TglBindProgramARB;
	DeleteProgramsARB- : TglDeleteProgramsARB;
	GenProgramsARB- : TglGenProgramsARB;
	ProgramEnvParameter4dARB- : TglProgramEnvParameter4dARB;
	ProgramEnvParameter4dvARB- : TglProgramEnvParameter4dvARB;
	ProgramEnvParameter4fARB- : TglProgramEnvParameter4fARB;
	ProgramEnvParameter4fvARB- : TglProgramEnvParameter4fvARB;
	ProgramLocalParameter4dARB- : TglProgramLocalParameter4dARB;
	ProgramLocalParameter4dvARB- : TglProgramLocalParameter4dvARB;
	ProgramLocalParameter4fARB- : TglProgramLocalParameter4fARB;
	ProgramLocalParameter4fvARB- : TglProgramLocalParameter4fvARB;
	GetProgramEnvParameterdvARB- : TglGetProgramEnvParameterdvARB;
	GetProgramEnvParameterfvARB- : TglGetProgramEnvParameterfvARB;
	GetProgramLocalParameterdvARB- : TglGetProgramLocalParameterdvARB;
	GetProgramLocalParameterfvARB- : TglGetProgramLocalParameterfvARB;
	GetProgramivARB- : TglGetProgramivARB;
	GetProgramStringARB- : TglGetProgramStringARB;
	GetVertexAttribdvARB- : TglGetVertexAttribdvARB;
	GetVertexAttribfvARB- : TglGetVertexAttribfvARB;
	GetVertexAttribivARB- : TglGetVertexAttribivARB;
	GetVertexAttribPointervARB- : TglGetVertexAttribPointervARB;
	IsProgramARB- : TglIsProgramARB;
	(*  GL_ARB_window_pos  *)
	WindowPos2dARB- : TglWindowPos2dARB;
	WindowPos2dvARB- : TglWindowPos2dvARB;
	WindowPos2fARB- : TglWindowPos2fARB;
	WindowPos2fvARB- : TglWindowPos2fvARB;
	WindowPos2iARB- : TglWindowPos2iARB;
	WindowPos2ivARB- : TglWindowPos2ivARB;
	WindowPos2sARB- : TglWindowPos2sARB;
	WindowPos2svARB- : TglWindowPos2svARB;
	WindowPos3dARB- : TglWindowPos3dARB;
	WindowPos3dvARB- : TglWindowPos3dvARB;
	WindowPos3fARB- : TglWindowPos3fARB;
	WindowPos3fvARB- : TglWindowPos3fvARB;
	WindowPos3iARB- : TglWindowPos3iARB;
	WindowPos3ivARB- : TglWindowPos3ivARB;
	WindowPos3sARB- : TglWindowPos3sARB;
	WindowPos3svARB- : TglWindowPos3svARB;
	(*  GL_ARB_draw_buffers  *)
	DrawBuffersARB- : TglDrawBuffersARB;
	(*  GL_ARB_color_buffer_float  *)
	ClampColorARB- : TglClampColorARB;
	(*  GL_ARB_vertex_shader  *)
	GetActiveAttribARB- : TglGetActiveAttribARB;
	GetAttribLocationARB- : TglGetAttribLocationARB;
	BindAttribLocationARB- : TglBindAttribLocationARB;
	(*  GL_ARB_shader_objects  *)
	DeleteObjectARB- : TglDeleteObjectARB;
	GetHandleARB- : TglGetHandleARB;
	DetachObjectARB- : TglDetachObjectARB;
	CreateShaderObjectARB- : TglCreateShaderObjectARB;
	ShaderSourceARB- : TglShaderSourceARB;
	CompileShaderARB- : TglCompileShaderARB;
	CreateProgramObjectARB- : TglCreateProgramObjectARB;
	AttachObjectARB- : TglAttachObjectARB;
	LinkProgramARB- : TglLinkProgramARB;
	UseProgramObjectARB- : TglUseProgramObjectARB;
	ValidateProgramARB- : TglValidateProgramARB;
	Uniform1fARB- : TglUniform1fARB;
	Uniform2fARB- : TglUniform2fARB;
	Uniform3fARB- : TglUniform3fARB;
	Uniform4fARB- : TglUniform4fARB;
	Uniform1iARB- : TglUniform1iARB;
	Uniform2iARB- : TglUniform2iARB;
	Uniform3iARB- : TglUniform3iARB;
	Uniform4iARB- : TglUniform4iARB;
	Uniform1fvARB- : TglUniform1fvARB;
	Uniform2fvARB- : TglUniform2fvARB;
	Uniform3fvARB- : TglUniform3fvARB;
	Uniform4fvARB- : TglUniform4fvARB;
	Uniform1ivARB- : TglUniform1ivARB;
	Uniform2ivARB- : TglUniform2ivARB;
	Uniform3ivARB- : TglUniform3ivARB;
	Uniform4ivARB- : TglUniform4ivARB;
	UniformMatrix2fvARB- : TglUniformMatrix2fvARB;
	UniformMatrix3fvARB- : TglUniformMatrix3fvARB;
	UniformMatrix4fvARB- : TglUniformMatrix4fvARB;
	GetObjectParameterfvARB- : TglGetObjectParameterfvARB;
	GetObjectParameterivARB- : TglGetObjectParameterivARB;
	GetInfoLogARB- : TglGetInfoLogARB;
	GetAttachedObjectsARB- : TglGetAttachedObjectsARB;
	GetUniformLocationARB- : TglGetUniformLocationARB;
	GetActiveUniformARB- : TglGetActiveUniformARB;
	GetUniformfvARB- : TglGetUniformfvARB;
	GetUniformivARB- : TglGetUniformivARB;
	GetShaderSourceARB- : TglGetShaderSourceARB;
	(*  GL_ARB_Occlusion_Query  *)
	GenQueriesARB- : TglGenQueriesARB;
	DeleteQueriesARB- : TglDeleteQueriesARB;
	IsQueryARB- : TglIsQueryARB;
	BeginQueryARB- : TglBeginQueryARB;
	EndQueryARB- : TglEndQueryARB;
	GetQueryivARB- : TglGetQueryivARB;
	GetQueryObjectivARB- : TglGetQueryObjectivARB;
	GetQueryObjectuivARB- : TglGetQueryObjectuivARB;
	(*  GL_ARB_draw_instanced  *)
	DrawArraysInstancedARB- : TglDrawArraysInstancedARB;
	DrawElementsInstancedARB- : TglDrawElementsInstancedARB;
	(*  GL_ARB_framebuffer_object  *)
	IsRenderbuffer- : TglIsRenderbuffer;
	BindRenderbuffer- : TglBindRenderbuffer;
	DeleteRenderbuffers- : TglDeleteRenderbuffers;
	GenRenderbuffers- : TglGenRenderbuffers;
	RenderbufferStorage- : TglRenderbufferStorage;
	GetRenderbufferParameteriv- : TglGetRenderbufferParameteriv;
	IsFramebuffer- : TglIsFramebuffer;
	BindFramebuffer- : TglBindFramebuffer;
	DeleteFramebuffers- : TglDeleteFramebuffers;
	GenFramebuffers- : TglGenFramebuffers;
	CheckFramebufferStatus- : TglCheckFramebufferStatus;
	FramebufferTexture1D- : TglFramebufferTexture1D;
	FramebufferTexture2D- : TglFramebufferTexture2D;
	FramebufferTexture3D- : TglFramebufferTexture3D;
	FramebufferRenderbuffer- : TglFramebufferRenderbuffer;
	GetFramebufferAttachmentParameteriv- : TglGetFramebufferAttachmentParameteriv;
	GenerateMipmap- : TglGenerateMipmap;
	BlitFramebuffer- : TglBlitFramebuffer;
	RenderbufferStorageMultisample- : TglRenderbufferStorageMultisample;
	FramebufferTextureLayer- : TglFramebufferTextureLayer;
	(*  GL_ARB_geometry_shader4  *)
	ProgramParameteriARB- : TglProgramParameteriARB;
	FramebufferTextureARB- : TglFramebufferTextureARB;
	FramebufferTextureLayerARB- : TglFramebufferTextureLayerARB;
	FramebufferTextureFaceARB- : TglFramebufferTextureFaceARB;
	(*  GL_ARB_instanced_arrays  *)
	VertexAttribDivisorARB- : TglVertexAttribDivisorARB;
	(*  GL_ARB_map_buffer_range  *)
	MapBufferRange- : TglMapBufferRange;
	FlushMappedBufferRange- : TglFlushMappedBufferRange;
	(*  GL_ARB_texture_buffer_object  *)
	TexBufferARB- : TglTexBufferARB;
	(*  GL_ARB_vertex_array_object  *)
	BindVertexArray- : TglBindVertexArray;
	DeleteVertexArrays- : TglDeleteVertexArrays;
	GenVertexArrays- : TglGenVertexArrays;
	IsVertexArray- : TglIsVertexArray;
	(*  GL_ARB_uniform_buffer_object  *)
	GetUniformIndices- : TglGetUniformIndices;
	GetActiveUniformsiv- : TglGetActiveUniformsiv;
	GetActiveUniformName- : TglGetActiveUniformName;
	GetUniformBlockIndex- : TglGetUniformBlockIndex;
	GetActiveUniformBlockiv- : TglGetActiveUniformBlockiv;
	GetActiveUniformBlockName- : TglGetActiveUniformBlockName;
	UniformBlockBinding- : TglUniformBlockBinding;
	(*  GL_ARB_copy_buffer  *)
	CopyBufferSubData- : TglCopyBufferSubData;
	(*  GL_ARB_draw_elements_base_vertex  *)
	DrawElementsBaseVertex- : TglDrawElementsBaseVertex;
	DrawRangeElementsBaseVertex- : TglDrawRangeElementsBaseVertex;
	DrawElementsInstancedBaseVertex- : TglDrawElementsInstancedBaseVertex;
	MultiDrawElementsBaseVertex- : TglMultiDrawElementsBaseVertex;
	(*  GL_ARB_provoking_vertex  *)
	ProvokingVertex- : TglProvokingVertex;
	(*  GL_ARB_sync  *)
	FenceSync- : TglFenceSync;
	IsSync- : TglIsSync;
	DeleteSync- : TglDeleteSync;
	ClientWaitSync- : TglClientWaitSync;
	WaitSync- : TglWaitSync;
	GetInteger64v- : TglGetInteger64v;
	GetSynciv- : TglGetSynciv;
	(*  GL_ARB_texture_multisample  *)
	TexImage2DMultisample- : TglTexImage2DMultisample;
	TexImage3DMultisample- : TglTexImage3DMultisample;
	GetMultisamplefv- : TglGetMultisamplefv;
	SampleMaski- : TglSampleMaski;
	(*  GL_ARB_draw_buffers_blend  *)
	BlendEquationiARB- : TglBlendEquationiARB;
	BlendEquationSeparateiARB- : TglBlendEquationSeparateiARB;
	BlendFunciARB- : TglBlendFunciARB;
	BlendFuncSeparateiARB- : TglBlendFuncSeparateiARB;
	(*  GL_ARB_sample_shading  *)
	MinSampleShadingARB- : TglMinSampleShadingARB;

	(* GL_ARB_sample_locations *)
	FramebufferSampleLocationsfvARB- : TglFramebufferSampleLocationsfvARB;
	NamedFramebufferSampleLocationsfvARB- : TglNamedFramebufferSampleLocationsfvARB;
	EvaluateDepthValuesARB- : TglEvaluateDepthValuesARB;

	(*  GL_ARB_shading_language_include  *)
	NamedStringARB- : TglNamedStringARB;
	DeleteNamedStringARB- : TglDeleteNamedStringARB;
	CompileShaderIncludeARB- : TglCompileShaderIncludeARB;
	IsNamedStringARB- : TglIsNamedStringARB;
	GetNamedStringARB- : TglGetNamedStringARB;
	GetNamedStringivARB- : TglGetNamedStringivARB;
	(*  GL_ARB_blend_func_extended  *)
	BindFragDataLocationIndexed- : TglBindFragDataLocationIndexed;
	GetFragDataIndex- : TglGetFragDataIndex;
	(*  GL_ARB_sampler_objects  *)
	GenSamplers- : TglGenSamplers;
	DeleteSamplers- : TglDeleteSamplers;
	IsSampler- : TglIsSampler;
	BindSampler- : TglBindSampler;
	SamplerParameteri- : TglSamplerParameteri;
	SamplerParameteriv- : TglSamplerParameteriv;
	SamplerParameterf- : TglSamplerParameterf;
	SamplerParameterfv- : TglSamplerParameterfv;
	SamplerParameterIiv- : TglSamplerParameterIiv;
	SamplerParameterIuiv- : TglSamplerParameterIuiv;
	GetSamplerParameteriv- : TglGetSamplerParameteriv;
	GetSamplerParameterIiv- : TglGetSamplerParameterIiv;
	GetSamplerParameterfv- : TglGetSamplerParameterfv;
	GetSamplerParameterIuiv- : TglGetSamplerParameterIuiv;
	(*  GL_ARB_timer_query  *)
	QueryCounter- : TglQueryCounter;
	GetQueryObjecti64v- : TglGetQueryObjecti64v;
	GetQueryObjectui64v- : TglGetQueryObjectui64v;
	(*  GL_ARB_vertex_type_2_10_10_10_rev  *)
	VertexP2ui- : TglVertexP2ui;
	VertexP2uiv- : TglVertexP2uiv;
	VertexP3ui- : TglVertexP3ui;
	VertexP3uiv- : TglVertexP3uiv;
	VertexP4ui- : TglVertexP4ui;
	VertexP4uiv- : TglVertexP4uiv;
	TexCoordP1ui- : TglTexCoordP1ui;
	TexCoordP1uiv- : TglTexCoordP1uiv;
	TexCoordP2ui- : TglTexCoordP2ui;
	TexCoordP2uiv- : TglTexCoordP2uiv;
	TexCoordP3ui- : TglTexCoordP3ui;
	TexCoordP3uiv- : TglTexCoordP3uiv;
	TexCoordP4ui- : TglTexCoordP4ui;
	TexCoordP4uiv- : TglTexCoordP4uiv;
	MultiTexCoordP1ui- : TglMultiTexCoordP1ui;
	MultiTexCoordP1uiv- : TglMultiTexCoordP1uiv;
	MultiTexCoordP2ui- : TglMultiTexCoordP2ui;
	MultiTexCoordP2uiv- : TglMultiTexCoordP2uiv;
	MultiTexCoordP3ui- : TglMultiTexCoordP3ui;
	MultiTexCoordP3uiv- : TglMultiTexCoordP3uiv;
	MultiTexCoordP4ui- : TglMultiTexCoordP4ui;
	MultiTexCoordP4uiv- : TglMultiTexCoordP4uiv;
	NormalP3ui- : TglNormalP3ui;
	NormalP3uiv- : TglNormalP3uiv;
	ColorP3ui- : TglColorP3ui;
	ColorP3uiv- : TglColorP3uiv;
	ColorP4ui- : TglColorP4ui;
	ColorP4uiv- : TglColorP4uiv;
	SecondaryColorP3ui- : TglSecondaryColorP3ui;
	SecondaryColorP3uiv- : TglSecondaryColorP3uiv;
	VertexAttribP1ui- : TglVertexAttribP1ui;
	VertexAttribP1uiv- : TglVertexAttribP1uiv;
	VertexAttribP2ui- : TglVertexAttribP2ui;
	VertexAttribP2uiv- : TglVertexAttribP2uiv;
	VertexAttribP3ui- : TglVertexAttribP3ui;
	VertexAttribP3uiv- : TglVertexAttribP3uiv;
	VertexAttribP4ui- : TglVertexAttribP4ui;
	VertexAttribP4uiv- : TglVertexAttribP4uiv;
	(*  GL_ARB_draw_indirect  *)
	DrawArraysIndirect- : TglDrawArraysIndirect;
	DrawElementsIndirect- : TglDrawElementsIndirect;
	(*  GL_ARB_gpu_shader_fp64  *)
	Uniform1d- : TglUniform1d;
	Uniform2d- : TglUniform2d;
	Uniform3d- : TglUniform3d;
	Uniform4d- : TglUniform4d;
	Uniform1dv- : TglUniform1dv;
	Uniform2dv- : TglUniform2dv;
	Uniform3dv- : TglUniform3dv;
	Uniform4dv- : TglUniform4dv;
	UniformMatrix2dv- : TglUniformMatrix2dv;
	UniformMatrix3dv- : TglUniformMatrix3dv;
	UniformMatrix4dv- : TglUniformMatrix4dv;
	UniformMatrix2x3dv- : TglUniformMatrix2x3dv;
	UniformMatrix2x4dv- : TglUniformMatrix2x4dv;
	UniformMatrix3x2dv- : TglUniformMatrix3x2dv;
	UniformMatrix3x4dv- : TglUniformMatrix3x4dv;
	UniformMatrix4x2dv- : TglUniformMatrix4x2dv;
	UniformMatrix4x3dv- : TglUniformMatrix4x3dv;
	GetUniformdv- : TglGetUniformdv;

	(* GL_ARB_gpu_shader_int64 *)
 	Uniform1i64ARB- : TglUniform1i64ARB;
	Uniform2i64ARB- : TglUniform2i64ARB;
	Uniform3i64ARB- : TglUniform3i64ARB;
	Uniform4i64ARB- : TglUniform4i64ARB;
	Uniform1i64vARB- : TglUniform1i64vARB;
	Uniform2i64vARB- : TglUniform2i64vARB;
	Uniform3i64vARB- : TglUniform3i64vARB;
	Uniform4i64vARB- : TglUniform4i64vARB;
	Uniform1ui64ARB- : TglUniform1ui64ARB;
	Uniform2ui64ARB- : TglUniform2ui64ARB;
	Uniform3ui64ARB- : TglUniform3ui64ARB;
	Uniform4ui64ARB- : TglUniform4ui64ARB;
	Uniform1ui64vARB- : TglUniform1ui64vARB;
	Uniform2ui64vARB- : TglUniform2ui64vARB;
	Uniform3ui64vARB- : TglUniform3ui64vARB;
	Uniform4ui64vARB- : TglUniform4ui64vARB;
	GetUniformi64vARB- : TglGetUniformi64vARB;
	GetUniformui64vARB- : TglGetUniformui64vARB;
	GetnUniformi64vARB- : TglGetnUniformi64vARB;
	GetnUniformui64vARB- : TglGetnUniformui64vARB;
	ProgramUniform1i64ARB- : TglProgramUniform1i64ARB;
	ProgramUniform2i64ARB- : TglProgramUniform2i64ARB;
	ProgramUniform3i64ARB- : TglProgramUniform3i64ARB;
	ProgramUniform4i64ARB- : TglProgramUniform4i64ARB;
	ProgramUniform1i64vARB- : TglProgramUniform1i64vARB;
	ProgramUniform2i64vARB- : TglProgramUniform2i64vARB;
	ProgramUniform3i64vARB- : TglProgramUniform3i64vARB;
	ProgramUniform4i64vARB- : TglProgramUniform4i64vARB;
	ProgramUniform1ui64ARB- : TglProgramUniform1ui64ARB;
	ProgramUniform2ui64ARB- : TglProgramUniform2ui64ARB;
	ProgramUniform3ui64ARB- : TglProgramUniform3ui64ARB;
	ProgramUniform4ui64ARB- : TglProgramUniform4ui64ARB;
	ProgramUniform1ui64vARB- : TglProgramUniform1ui64vARB;
	ProgramUniform2ui64vARB- : TglProgramUniform2ui64vARB;
	ProgramUniform3ui64vARB- : TglProgramUniform3ui64vARB;
	ProgramUniform4ui64vARB- : TglProgramUniform4ui64vARB;


	(*  GL_ARB_shader_subroutine  *)
	GetSubroutineUniformLocation- : TglGetSubroutineUniformLocation;
	GetSubroutineIndex- : TglGetSubroutineIndex;
	GetActiveSubroutineUniformiv- : TglGetActiveSubroutineUniformiv;
	GetActiveSubroutineUniformName- : TglGetActiveSubroutineUniformName;
	GetActiveSubroutineName- : TglGetActiveSubroutineName;
	UniformSubroutinesuiv- : TglUniformSubroutinesuiv;
	GetUniformSubroutineuiv- : TglGetUniformSubroutineuiv;
	GetProgramStageiv- : TglGetProgramStageiv;
	(*  GL_ARB_tessellation_shader  *)
	PatchParameteri- : TglPatchParameteri;
	PatchParameterfv- : TglPatchParameterfv;
	(*  GL_ARB_transform_feedback2  *)
	BindTransformFeedback- : TglBindTransformFeedback;
	DeleteTransformFeedbacks- : TglDeleteTransformFeedbacks;
	GenTransformFeedbacks- : TglGenTransformFeedbacks;
	IsTransformFeedback- : TglIsTransformFeedback;
	PauseTransformFeedback- : TglPauseTransformFeedback;
	ResumeTransformFeedback- : TglResumeTransformFeedback;
	DrawTransformFeedback- : TglDrawTransformFeedback;
	(*  GL_ARB_transform_feedback3  *)
	DrawTransformFeedbackStream- : TglDrawTransformFeedbackStream;
	BeginQueryIndexed- : TglBeginQueryIndexed;
	EndQueryIndexed- : TglEndQueryIndexed;
	GetQueryIndexediv- : TglGetQueryIndexediv;
	(*  GL_ARB_ES2_compatibility  *)
	ReleaseShaderCompiler- : TglReleaseShaderCompiler;
	ShaderBinary- : TglShaderBinary;
	GetShaderPrecisionFormat- : TglGetShaderPrecisionFormat;
	DepthRangef- : TglDepthRangef;
	ClearDepthf- : TglClearDepthf;

	(* GL_ARB_ES3_2_compatibility *)
	PrimitiveBoundingBoxARB- : TglPrimitiveBoundingBoxARB;

	(* GL_ARB_parallel_shader_compile *)
	MaxShaderCompilerThreadsARB- : TglMaxShaderCompilerThreadsARB;

	(*  GL_ARB_get_program_binary  *)
	GetProgramBinary- : TglGetProgramBinary;
	ProgramBinary- : TglProgramBinary;
	ProgramParameteri- : TglProgramParameteri;
	(*  GL_ARB_separate_shader_objects  *)
	UseProgramStages- : TglUseProgramStages;
	ActiveShaderProgram- : TglActiveShaderProgram;
	CreateShaderProgramv- : TglCreateShaderProgramv;
	BindProgramPipeline- : TglBindProgramPipeline;
	DeleteProgramPipelines- : TglDeleteProgramPipelines;
	GenProgramPipelines- : TglGenProgramPipelines;
	IsProgramPipeline- : TglIsProgramPipeline;
	GetProgramPipelineiv- : TglGetProgramPipelineiv;
	ProgramUniform1i- : TglProgramUniform1i;
	ProgramUniform1iv- : TglProgramUniform1iv;
	ProgramUniform1f- : TglProgramUniform1f;
	ProgramUniform1fv- : TglProgramUniform1fv;
	ProgramUniform1d- : TglProgramUniform1d;
	ProgramUniform1dv- : TglProgramUniform1dv;
	ProgramUniform1ui- : TglProgramUniform1ui;
	ProgramUniform1uiv- : TglProgramUniform1uiv;
	ProgramUniform2i- : TglProgramUniform2i;
	ProgramUniform2iv- : TglProgramUniform2iv;
	ProgramUniform2f- : TglProgramUniform2f;
	ProgramUniform2fv- : TglProgramUniform2fv;
	ProgramUniform2d- : TglProgramUniform2d;
	ProgramUniform2dv- : TglProgramUniform2dv;
	ProgramUniform2ui- : TglProgramUniform2ui;
	ProgramUniform2uiv- : TglProgramUniform2uiv;
	ProgramUniform3i- : TglProgramUniform3i;
	ProgramUniform3iv- : TglProgramUniform3iv;
	ProgramUniform3f- : TglProgramUniform3f;
	ProgramUniform3fv- : TglProgramUniform3fv;
	ProgramUniform3d- : TglProgramUniform3d;
	ProgramUniform3dv- : TglProgramUniform3dv;
	ProgramUniform3ui- : TglProgramUniform3ui;
	ProgramUniform3uiv- : TglProgramUniform3uiv;
	ProgramUniform4i- : TglProgramUniform4i;
	ProgramUniform4iv- : TglProgramUniform4iv;
	ProgramUniform4f- : TglProgramUniform4f;
	ProgramUniform4fv- : TglProgramUniform4fv;
	ProgramUniform4d- : TglProgramUniform4d;
	ProgramUniform4dv- : TglProgramUniform4dv;
	ProgramUniform4ui- : TglProgramUniform4ui;
	ProgramUniform4uiv- : TglProgramUniform4uiv;
	ProgramUniformMatrix2fv- : TglProgramUniformMatrix2fv;
	ProgramUniformMatrix3fv- : TglProgramUniformMatrix3fv;
	ProgramUniformMatrix4fv- : TglProgramUniformMatrix4fv;
	ProgramUniformMatrix2dv- : TglProgramUniformMatrix2dv;
	ProgramUniformMatrix3dv- : TglProgramUniformMatrix3dv;
	ProgramUniformMatrix4dv- : TglProgramUniformMatrix4dv;
	ProgramUniformMatrix2x3fv- : TglProgramUniformMatrix2x3fv;
	ProgramUniformMatrix3x2fv- : TglProgramUniformMatrix3x2fv;
	ProgramUniformMatrix2x4fv- : TglProgramUniformMatrix2x4fv;
	ProgramUniformMatrix4x2fv- : TglProgramUniformMatrix4x2fv;
	ProgramUniformMatrix3x4fv- : TglProgramUniformMatrix3x4fv;
	ProgramUniformMatrix4x3fv- : TglProgramUniformMatrix4x3fv;
	ProgramUniformMatrix2x3dv- : TglProgramUniformMatrix2x3dv;
	ProgramUniformMatrix3x2dv- : TglProgramUniformMatrix3x2dv;
	ProgramUniformMatrix2x4dv- : TglProgramUniformMatrix2x4dv;
	ProgramUniformMatrix4x2dv- : TglProgramUniformMatrix4x2dv;
	ProgramUniformMatrix3x4dv- : TglProgramUniformMatrix3x4dv;
	ProgramUniformMatrix4x3dv- : TglProgramUniformMatrix4x3dv;
	ValidateProgramPipeline- : TglValidateProgramPipeline;
	GetProgramPipelineInfoLog- : TglGetProgramPipelineInfoLog;
	(*  GL_ARB_vertex_attrib_64bit  *)
	VertexAttribL1d- : TglVertexAttribL1d;
	VertexAttribL2d- : TglVertexAttribL2d;
	VertexAttribL3d- : TglVertexAttribL3d;
	VertexAttribL4d- : TglVertexAttribL4d;
	VertexAttribL1dv- : TglVertexAttribL1dv;
	VertexAttribL2dv- : TglVertexAttribL2dv;
	VertexAttribL3dv- : TglVertexAttribL3dv;
	VertexAttribL4dv- : TglVertexAttribL4dv;
	VertexAttribLPointer- : TglVertexAttribLPointer;
	GetVertexAttribLdv- : TglGetVertexAttribLdv;
	(*  GL_ARB_viewport_array  *)
	ViewportArrayv- : TglViewportArrayv;
	ViewportIndexedf- : TglViewportIndexedf;
	ViewportIndexedfv- : TglViewportIndexedfv;
	ScissorArrayv- : TglScissorArrayv;
	ScissorIndexed- : TglScissorIndexed;
	ScissorIndexedv- : TglScissorIndexedv;
	DepthRangeArrayv- : TglDepthRangeArrayv;
	DepthRangeIndexed- : TglDepthRangeIndexed;
	GetFloati_v- : TglGetFloati_v;
	GetDoublei_v- : TglGetDoublei_v;

	(*! GL 4.2  *)
	(* GL_ARB_base_instance  *)
	DrawArraysInstancedBaseInstance- : TglDrawArraysInstancedBaseInstance;
	DrawElementsInstancedBaseInstance- : TglDrawElementsInstancedBaseInstance;
	DrawElementsInstancedBaseVertexBaseInstance- : TglDrawElementsInstancedBaseVertexBaseInstance;
	(* GL_ARB_transform_feedback_instanced  *)
	DrawTransformFeedbackInstanced- : TglDrawTransformFeedbackInstanced;
	DrawTransformFeedbackStreamInstanced- : TglDrawTransformFeedbackStreamInstanced;
	(* GL_ARB_internalformat_query  *)
	GetInternalformativ- : TglGetInternalformativ;
	(* GL_ARB_shader_atomic_counters  *)
	GetActiveAtomicCounterBufferiv- : TglGetActiveAtomicCounterBufferiv;
	(* GL_ARB_shader_image_load_store  *)
	BindImageTexture- : TglBindImageTexture;
	MemoryBarrier- : TglMemoryBarrier;
	(* GL_ARB_texture_storage  *)
	TexStorage1D- : TglTexStorage1D;
	TexStorage2D- : TglTexStorage2D;
	TexStorage3D- : TglTexStorage3D;
	TextureStorage1DEXT- : TglTextureStorage1DEXT;
	TextureStorage2DEXT- : TglTextureStorage2DEXT;
	TextureStorage3DEXT- : TglTextureStorage3DEXT;

	(* GL 4.3 *)
	(* GL_KHR_debug *)
	DebugMessageControl- : TglDebugMessageControl;
	DebugMessageInsert- : TglDebugMessageInsert;
	DebugMessageCallback- : TglDebugMessageCallback;
	GetDebugMessageLog- : TglGetDebugMessageLog;
	PushDebugGroup- : TglPushDebugGroup;
	PopDebugGroup- : TglPopDebugGroup;
	ObjectLabel- : TglObjectLabel;
	GetObjectLabel- : TglGetObjectLabel;
	ObjectPtrLabel- : TglObjectPtrLabel;
	GetObjectPtrLabel- : TglGetObjectPtrLabel;
	(* GL_ARB_clear_buffer_object *)
	ClearBufferData- : TglClearBufferData;
	ClearBufferSubData- : TglClearBufferSubData;
	ClearNamedBufferDataEXT- : TglClearNamedBufferDataEXT;
	ClearNamedBufferSubDataEXT- : TglClearNamedBufferSubDataEXT;
	(* GL_ARB_compute_shader *)
	DispatchCompute- : TglDispatchCompute;
	DispatchComputeIndirect- : TglDispatchComputeIndirect;
	(* GL_ARB_copy_image *)
	CopyImageSubData- : TglCopyImageSubData;
	(* GL_ARB_framebuffer_no_attachments *)
	FramebufferParameteri- : TglFramebufferParameteri;
	GetFramebufferParameteriv- : TglGetFramebufferParameteriv;
	NamedFramebufferParameteriEXT- : TglNamedFramebufferParameteriEXT;
	GetNamedFramebufferParameterivEXT- : TglGetNamedFramebufferParameterivEXT;
	(* GL_ARB_internalformat_query2 *)
	GetInternalformati64v- : TglGetInternalformati64v;
	(* GL_ARB_invalidate_subdata *)
	InvalidateTexSubImage- : TglInvalidateTexSubImage;
	InvalidateTexImage- : TglInvalidateTexImage;
	InvalidateBufferSubData- : TglInvalidateBufferSubData;
	InvalidateBufferData- : TglInvalidateBufferData;
	InvalidateFramebuffer- : TglInvalidateFramebuffer;
	InvalidateSubFramebuffer- : TglInvalidateSubFramebuffer;
	(* GL_ARB_multi_draw_indirect *)
	MultiDrawArraysIndirect- : TglMultiDrawArraysIndirect;
	MultiDrawElementsIndirect- : TglMultiDrawElementsIndirect;
	(* GL_ARB_program_interface_query *)
	GetProgramInterfaceiv- : TglGetProgramInterfaceiv;
	GetProgramResourceIndex- : TglGetProgramResourceIndex;
	GetProgramResourceName- : TglGetProgramResourceName;
	GetProgramResourceiv- : TglGetProgramResourceiv;
	GetProgramResourceLocation- : TglGetProgramResourceLocation;
	GetProgramResourceLocationIndex- : TglGetProgramResourceLocationIndex;
	(* GL_ARB_shader_storage_buffer_object *)
	ShaderStorageBlockBinding- : TglShaderStorageBlockBinding;
	(* GL_ARB_texture_buffer_range *)
	TexBufferRange- : TglTexBufferRange;
	TextureBufferRangeEXT- : TglTextureBufferRangeEXT;
	(* GL_ARB_texture_storage_multisample *)
	TexStorage2DMultisample- : TglTexStorage2DMultisample;
	TexStorage3DMultisample- : TglTexStorage3DMultisample;
	TextureStorage2DMultisampleEXT- : TglTextureStorage2DMultisampleEXT;
	TextureStorage3DMultisampleEXT- : TglTextureStorage3DMultisampleEXT;
	(* GL_ARB_texture_view *)
	TextureView- : TglTextureView;
	(* GL_ARB_vertex_attrib_binding *)
	BindVertexBuffer- : TglBindVertexBuffer;
	VertexAttribFormat- : TglVertexAttribFormat;
	VertexAttribIFormat- : TglVertexAttribIFormat;
	VertexAttribLFormat- : TglVertexAttribLFormat;
	VertexAttribBinding- : TglVertexAttribBinding;
	VertexBindingDivisor- : TglVertexBindingDivisor;
	VertexArrayBindVertexBufferEXT- : TglVertexArrayBindVertexBufferEXT;
	VertexArrayVertexAttribFormatEXT- : TglVertexArrayVertexAttribFormatEXT;
	VertexArrayVertexAttribIFormatEXT- : TglVertexArrayVertexAttribIFormatEXT;
	VertexArrayVertexAttribLFormatEXT- : TglVertexArrayVertexAttribLFormatEXT;
	VertexArrayVertexAttribBindingEXT- : TglVertexArrayVertexAttribBindingEXT;
	VertexArrayVertexBindingDivisorEXT- : TglVertexArrayVertexBindingDivisorEXT;
	(* END GL 4.3 *)

	(* GL 4.4 *)
	BufferStorage- : TglBufferStorage;
	ClearTexImage- : TglClearTexImage;
	ClearTexSubImage- : TglClearTexSubImage;
	BindBuffersBase- : TglBindBuffersBase;
	BindBuffersRange- : TglBindBuffersRange;
	BindTextures- : TglBindTextures;
	BindSamplers- : TglBindSamplers;
	BindImageTextures- : TglBindImageTextures;
	BindVertexBuffers- : TglBindVertexBuffers;
	TexPageCommitmentARB- : TglTexPageCommitmentARB;
	(* END GL 4.4 *)

	(* GL 4_5 *)

	ClipControl- : TglClipControl;
	CreateTransformFeedbacks- : TglCreateTransformFeedbacks;
	TransformFeedbackBufferBase- : TglTransformFeedbackBufferBase;
	TransformFeedbackBufferRange- : TglTransformFeedbackBufferRange;
	GetTransformFeedbackiv- : TglGetTransformFeedbackiv;
	GetTransformFeedbacki_v- : TglGetTransformFeedbacki_v;
	GetTransformFeedbacki64_v- : TglGetTransformFeedbacki64_v;
	CreateBuffers- : TglCreateBuffers;
	NamedBufferStorage- : TglNamedBufferStorage;
	NamedBufferData- : TglNamedBufferData;
	NamedBufferSubData- : TglNamedBufferSubData;
	CopyNamedBufferSubData- : TglCopyNamedBufferSubData;
	ClearNamedBufferData- : TglClearNamedBufferData;
	ClearNamedBufferSubData- : TglClearNamedBufferSubData;
	MapNamedBuffer- : TglMapNamedBuffer;
	MapNamedBufferRange- : TglMapNamedBufferRange;
	UnmapNamedBuffer- : TglUnmapNamedBuffer;
	FlushMappedNamedBufferRange- : TglFlushMappedNamedBufferRange;
	GetNamedBufferParameteriv- : TglGetNamedBufferParameteriv;
	GetNamedBufferParameteri64v- : TglGetNamedBufferParameteri64v;
	GetNamedBufferPointerv- : TglGetNamedBufferPointerv;
	GetNamedBufferSubData- : TglGetNamedBufferSubData;
	CreateFramebuffers- : TglCreateFramebuffers;
	NamedFramebufferRenderbuffer- : TglNamedFramebufferRenderbuffer;
	NamedFramebufferParameteri- : TglNamedFramebufferParameteri;
	NamedFramebufferTexture- : TglNamedFramebufferTexture;
	NamedFramebufferTextureLayer- : TglNamedFramebufferTextureLayer;
	NamedFramebufferDrawBuffer- : TglNamedFramebufferDrawBuffer;
	NamedFramebufferDrawBuffers- : TglNamedFramebufferDrawBuffers;
	NamedFramebufferReadBuffer- : TglNamedFramebufferReadBuffer;
	InvalidateNamedFramebufferData- : TglInvalidateNamedFramebufferData;
	InvalidateNamedFramebufferSubData- : TglInvalidateNamedFramebufferSubData;
	ClearNamedFramebufferiv- : TglClearNamedFramebufferiv;
	ClearNamedFramebufferuiv- : TglClearNamedFramebufferuiv;
	ClearNamedFramebufferfv- : TglClearNamedFramebufferfv;
	ClearNamedFramebufferfi- : TglClearNamedFramebufferfi;
	BlitNamedFramebuffer- : TglBlitNamedFramebuffer;
	CheckNamedFramebufferStatus- : TglCheckNamedFramebufferStatus;
	GetNamedFramebufferParameteriv- : TglGetNamedFramebufferParameteriv;
	GetNamedFramebufferAttachmentParameteriv- : TglGetNamedFramebufferAttachmentParameteriv;
	CreateRenderbuffers- : TglCreateRenderbuffers;
	NamedRenderbufferStorage- : TglNamedRenderbufferStorage;
	NamedRenderbufferStorageMultisample- : TglNamedRenderbufferStorageMultisample;
	GetNamedRenderbufferParameteriv- : TglGetNamedRenderbufferParameteriv;
	CreateTextures- : TglCreateTextures;
	TextureBuffer- : TglTextureBuffer;
	TextureBufferRange- : TglTextureBufferRange;
	TextureStorage1D- : TglTextureStorage1D;
	TextureStorage2D- : TglTextureStorage2D;
	TextureStorage3D- : TglTextureStorage3D;
	TextureStorage2DMultisample- : TglTextureStorage2DMultisample;
	TextureStorage3DMultisample- : TglTextureStorage3DMultisample;
	TextureSubImage1D- : TglTextureSubImage1D;
	TextureSubImage2D- : TglTextureSubImage2D;
	TextureSubImage3D- : TglTextureSubImage3D;
	CompressedTextureSubImage1D- : TglCompressedTextureSubImage1D;
	CompressedTextureSubImage2D- : TglCompressedTextureSubImage2D;
	CompressedTextureSubImage3D- : TglCompressedTextureSubImage3D;
	CopyTextureSubImage1D- : TglCopyTextureSubImage1D;
	CopyTextureSubImage2D- : TglCopyTextureSubImage2D;
	CopyTextureSubImage3D- : TglCopyTextureSubImage3D;
	TextureParameterf- : TglTextureParameterf;
	TextureParameterfv- : TglTextureParameterfv;
	TextureParameteri- : TglTextureParameteri;
	TextureParameterIiv- : TglTextureParameterIiv;
	TextureParameterIuiv- : TglTextureParameterIuiv;
	TextureParameteriv- : TglTextureParameteriv;
	GenerateTextureMipmap- : TglGenerateTextureMipmap;
	BindTextureUnit- : TglBindTextureUnit;
	GetTextureImage- : TglGetTextureImage;
	GetCompressedTextureImage- : TglGetCompressedTextureImage;
	GetTextureLevelParameterfv- : TglGetTextureLevelParameterfv;
	GetTextureLevelParameteriv- : TglGetTextureLevelParameteriv;
	GetTextureParameterfv- : TglGetTextureParameterfv;
	GetTextureParameterIiv- : TglGetTextureParameterIiv;
	GetTextureParameterIuiv- : TglGetTextureParameterIuiv;
	GetTextureParameteriv- : TglGetTextureParameteriv;
	CreateVertexArrays- : TglCreateVertexArrays;
	DisableVertexArrayAttrib- : TglDisableVertexArrayAttrib;
	EnableVertexArrayAttrib- : TglEnableVertexArrayAttrib;
	VertexArrayElementBuffer- : TglVertexArrayElementBuffer;
	VertexArrayVertexBuffer- : TglVertexArrayVertexBuffer;
	VertexArrayVertexBuffers- : TglVertexArrayVertexBuffers;
	VertexArrayAttribBinding- : TglVertexArrayAttribBinding;
	VertexArrayAttribFormat- : TglVertexArrayAttribFormat;
	VertexArrayAttribIFormat- : TglVertexArrayAttribIFormat;
	VertexArrayAttribLFormat- : TglVertexArrayAttribLFormat;
	VertexArrayBindingDivisor- : TglVertexArrayBindingDivisor;
	GetVertexArrayiv- : TglGetVertexArrayiv;
	GetVertexArrayIndexediv- : TglGetVertexArrayIndexediv;
	GetVertexArrayIndexed64iv- : TglGetVertexArrayIndexed64iv;
	CreateSamplers- : TglCreateSamplers;
	CreateProgramPipelines- : TglCreateProgramPipelines;
	CreateQueries- : TglCreateQueries;
	MemoryBarrierByRegion- : TglMemoryBarrierByRegion;
	GetTextureSubImage- : TglGetTextureSubImage;
	GetCompressedTextureSubImage- : TglGetCompressedTextureSubImage;
	GetGraphicsResetStatus- : TglGetGraphicsResetStatus;
	GetnCompressedTexImage- : TglGetnCompressedTexImage;
	GetnTexImage- : TglGetnTexImage;
	GetnUniformdv- : TglGetnUniformdv;
	GetnUniformfv- : TglGetnUniformfv;
	GetnUniformiv- : TglGetnUniformiv;
	GetnUniformuiv- : TglGetnUniformuiv;
	ReadnPixels- : TglReadnPixels;
	GetnMapdv- : TglGetnMapdv;
	GetnMapfv- : TglGetnMapfv;
	GetnMapiv- : TglGetnMapiv;
	GetnPixelMapfv- : TglGetnPixelMapfv;
	GetnPixelMapuiv- : TglGetnPixelMapuiv;
	GetnPixelMapusv- : TglGetnPixelMapusv;
	GetnPolygonStipple- : TglGetnPolygonStipple;
	GetnColorTable- : TglGetnColorTable;
	GetnConvolutionFilter- : TglGetnConvolutionFilter;
	GetnSeparableFilter- : TglGetnSeparableFilter;
	GetnHistogram- : TglGetnHistogram;
	GetnMinmax- : TglGetnMinmax;
	TextureBarrier- : TglTextureBarrier;
	(* END GL 4_5 *)

	(* GL_ARB_sparse_buffer *)
	BufferPageCommitmentARB- : TglBufferPageCommitmentARB;
	NamedBufferPageCommitmentEXT- : TglNamedBufferPageCommitmentEXT;
	NamedBufferPageCommitmentARB- : TglNamedBufferPageCommitmentARB;

	(* GL_KHR_blend_equation_advanced *)
	BlendBarrierKHR- : TglBlendBarrierKHR;


	(* GL_ARB_cl_event  *)
	CreateSyncFromCLeventARB- : TglCreateSyncFromCLeventARB;

	(* GL_ARB_debug_output  *)
	DebugMessageControlARB- : TglDebugMessageControlARB;
	DebugMessageInsertARB- : TglDebugMessageInsertARB;
	DebugMessageCallbackARB- : TglDebugMessageCallbackARB;
	GetDebugMessageLogARB- : TglGetDebugMessageLogARB;

	(* GL_ARB_compute_variable_group_size *)
	DispatchComputeGroupSizeARB- : TglDispatchComputeGroupSizeARB;

	(*  GL_ARB_robustness  *)
	GetGraphicsResetStatusARB- : TglGetGraphicsResetStatusARB;
	GetnMapdvARB- : TglGetnMapdvARB;
	GetnMapfvARB- : TglGetnMapfvARB;
	GetnMapivARB- : TglGetnMapivARB;
	GetnPixelMapfvARB- : TglGetnPixelMapfvARB;
	GetnPixelMapuivARB- : TglGetnPixelMapuivARB;
	GetnPixelMapusvARB- : TglGetnPixelMapusvARB;
	GetnPolygonStippleARB- : TglGetnPolygonStippleARB;
	GetnColorTableARB- : TglGetnColorTableARB;
	GetnConvolutionFilterARB- : TglGetnConvolutionFilterARB;
	GetnSeparableFilterARB- : TglGetnSeparableFilterARB;
	GetnHistogramARB- : TglGetnHistogramARB;
	GetnMinmaxARB- : TglGetnMinmaxARB;
	GetnTexImageARB- : TglGetnTexImageARB;
	ReadnPixelsARB- : TglReadnPixelsARB;
	GetnCompressedTexImageARB- : TglGetnCompressedTexImageARB;
	GetnUniformfvARB- : TglGetnUniformfvARB;
	GetnUniformivARB- : TglGetnUniformivARB;
	GetnUniformuivARB- : TglGetnUniformuivARB;
	GetnUniformdvARB- : TglGetnUniformdvARB;
	(*  GL_ATI_draw_buffers  *)
	DrawBuffersATI- : TglDrawBuffersATI;
	(*  GL_ATI_element_array  *)
	ElementPointerATI- : TglElementPointerATI;
	DrawElementArrayATI- : TglDrawElementArrayATI;
	DrawRangeElementArrayATI- : TglDrawRangeElementArrayATI;
	(*  GL_ATI_envmap_bumpmap  *)
	TexBumpParameterivATI- : TglTexBumpParameterivATI;
	TexBumpParameterfvATI- : TglTexBumpParameterfvATI;
	GetTexBumpParameterivATI- : TglGetTexBumpParameterivATI;
	GetTexBumpParameterfvATI- : TglGetTexBumpParameterfvATI;
	(*  GL_ATI_fragment_shader  *)
	GenFragmentShadersATI- : TglGenFragmentShadersATI;
	BindFragmentShaderATI- : TglBindFragmentShaderATI;
	DeleteFragmentShaderATI- : TglDeleteFragmentShaderATI;
	BeginFragmentShaderATI- : TglBeginFragmentShaderATI;
	EndFragmentShaderATI- : TglEndFragmentShaderATI;
	PassTexCoordATI- : TglPassTexCoordATI;
	SampleMapATI- : TglSampleMapATI;
	ColorFragmentOp1ATI- : TglColorFragmentOp1ATI;
	ColorFragmentOp2ATI- : TglColorFragmentOp2ATI;
	ColorFragmentOp3ATI- : TglColorFragmentOp3ATI;
	AlphaFragmentOp1ATI- : TglAlphaFragmentOp1ATI;
	AlphaFragmentOp2ATI- : TglAlphaFragmentOp2ATI;
	AlphaFragmentOp3ATI- : TglAlphaFragmentOp3ATI;
	SetFragmentShaderConstantATI- : TglSetFragmentShaderConstantATI;
	(*  GL_ATI_map_object_buffer  *)
	MapObjectBufferATI- : TglMapObjectBufferATI;
	UnmapObjectBufferATI- : TglUnmapObjectBufferATI;
	(*  GL_ATI_pn_triangles  *)
	PNTrianglesiATI- : TglPNTrianglesiATI;
	PNTrianglesfATI- : TglPNTrianglesfATI;
	(*  GL_ATI_separate_stencil  *)
	StencilOpSeparateATI- : TglStencilOpSeparateATI;
	StencilFuncSeparateATI- : TglStencilFuncSeparateATI;
	(*  GL_ATI_vertex_array_object  *)
	NewObjectBufferATI- : TglNewObjectBufferATI;
	IsObjectBufferATI- : TglIsObjectBufferATI;
	UpdateObjectBufferATI- : TglUpdateObjectBufferATI;
	GetObjectBufferfvATI- : TglGetObjectBufferfvATI;
	GetObjectBufferivATI- : TglGetObjectBufferivATI;
	FreeObjectBufferATI- : TglFreeObjectBufferATI;
	ArrayObjectATI- : TglArrayObjectATI;
	GetArrayObjectfvATI- : TglGetArrayObjectfvATI;
	GetArrayObjectivATI- : TglGetArrayObjectivATI;
	VariantArrayObjectATI- : TglVariantArrayObjectATI;
	GetVariantArrayObjectfvATI- : TglGetVariantArrayObjectfvATI;
	GetVariantArrayObjectivATI- : TglGetVariantArrayObjectivATI;
	VertexAttribArrayObjectATI- : TglVertexAttribArrayObjectATI;
	GetVertexAttribArrayObjectfvATI- : TglGetVertexAttribArrayObjectfvATI;
	GetVertexAttribArrayObjectivATI- : TglGetVertexAttribArrayObjectivATI;
	(*  GL_ATI_vertex_streams  *)
	VertexStream1sATI- : TglVertexStream1sATI;
	VertexStream1svATI- : TglVertexStream1svATI;
	VertexStream1iATI- : TglVertexStream1iATI;
	VertexStream1ivATI- : TglVertexStream1ivATI;
	VertexStream1fATI- : TglVertexStream1fATI;
	VertexStream1fvATI- : TglVertexStream1fvATI;
	VertexStream1dATI- : TglVertexStream1dATI;
	VertexStream1dvATI- : TglVertexStream1dvATI;
	VertexStream2sATI- : TglVertexStream2sATI;
	VertexStream2svATI- : TglVertexStream2svATI;
	VertexStream2iATI- : TglVertexStream2iATI;
	VertexStream2ivATI- : TglVertexStream2ivATI;
	VertexStream2fATI- : TglVertexStream2fATI;
	VertexStream2fvATI- : TglVertexStream2fvATI;
	VertexStream2dATI- : TglVertexStream2dATI;
	VertexStream2dvATI- : TglVertexStream2dvATI;
	VertexStream3sATI- : TglVertexStream3sATI;
	VertexStream3svATI- : TglVertexStream3svATI;
	VertexStream3iATI- : TglVertexStream3iATI;
	VertexStream3ivATI- : TglVertexStream3ivATI;
	VertexStream3fATI- : TglVertexStream3fATI;
	VertexStream3fvATI- : TglVertexStream3fvATI;
	VertexStream3dATI- : TglVertexStream3dATI;
	VertexStream3dvATI- : TglVertexStream3dvATI;
	VertexStream4sATI- : TglVertexStream4sATI;
	VertexStream4svATI- : TglVertexStream4svATI;
	VertexStream4iATI- : TglVertexStream4iATI;
	VertexStream4ivATI- : TglVertexStream4ivATI;
	VertexStream4fATI- : TglVertexStream4fATI;
	VertexStream4fvATI- : TglVertexStream4fvATI;
	VertexStream4dATI- : TglVertexStream4dATI;
	VertexStream4dvATI- : TglVertexStream4dvATI;
	NormalStream3bATI- : TglNormalStream3bATI;
	NormalStream3bvATI- : TglNormalStream3bvATI;
	NormalStream3sATI- : TglNormalStream3sATI;
	NormalStream3svATI- : TglNormalStream3svATI;
	NormalStream3iATI- : TglNormalStream3iATI;
	NormalStream3ivATI- : TglNormalStream3ivATI;
	NormalStream3fATI- : TglNormalStream3fATI;
	NormalStream3fvATI- : TglNormalStream3fvATI;
	NormalStream3dATI- : TglNormalStream3dATI;
	NormalStream3dvATI- : TglNormalStream3dvATI;
	ClientActiveVertexStreamATI- : TglClientActiveVertexStreamATI;
	VertexBlendEnviATI- : TglVertexBlendEnviATI;
	VertexBlendEnvfATI- : TglVertexBlendEnvfATI;
	(*  GL_AMD_performance_monitor  *)
	GetPerfMonitorGroupsAMD- : TglGetPerfMonitorGroupsAMD;
	GetPerfMonitorCountersAMD- : TglGetPerfMonitorCountersAMD;
	GetPerfMonitorGroupStringAMD- : TglGetPerfMonitorGroupStringAMD;
	GetPerfMonitorCounterStringAMD- : TglGetPerfMonitorCounterStringAMD;
	GetPerfMonitorCounterInfoAMD- : TglGetPerfMonitorCounterInfoAMD;
	GenPerfMonitorsAMD- : TglGenPerfMonitorsAMD;
	DeletePerfMonitorsAMD- : TglDeletePerfMonitorsAMD;
	SelectPerfMonitorCountersAMD- : TglSelectPerfMonitorCountersAMD;
	BeginPerfMonitorAMD- : TglBeginPerfMonitorAMD;
	EndPerfMonitorAMD- : TglEndPerfMonitorAMD;
	GetPerfMonitorCounterDataAMD- : TglGetPerfMonitorCounterDataAMD;
	(*  GL_AMD_vertex_shader_tesselator  *)
	TessellationFactorAMD- : TglTessellationFactorAMD;
	TessellationModeAMD- : TglTessellationModeAMD;
	(*  GL_AMD_draw_buffers_blend  *)
	BlendFuncIndexedAMD- : TglBlendFuncIndexedAMD;
	BlendFuncSeparateIndexedAMD- : TglBlendFuncSeparateIndexedAMD;
	BlendEquationIndexedAMD- : TglBlendEquationIndexedAMD;
	BlendEquationSeparateIndexedAMD- : TglBlendEquationSeparateIndexedAMD;
	(*  GL_AMD_name_gen_delete  *)
	GenNamesAMD- : TglGenNamesAMD;
	DeleteNamesAMD- : TglDeleteNamesAMD;
	IsNameAMD- : TglIsNameAMD;
	(*  GL_AMD_debug_output  *)
	DebugMessageEnableAMD- : TglDebugMessageEnableAMD;
	DebugMessageInsertAMD- : TglDebugMessageInsertAMD;
	DebugMessageCallbackAMD- : TglDebugMessageCallbackAMD;
	GetDebugMessageLogAMD- : TglGetDebugMessageLogAMD;
	(*  GL_EXT_blend_color  *)
	BlendColorEXT- : TglBlendColorEXT;
	(*  GL_EXT_blend_func_separate  *)
	BlendFuncSeparateEXT- : TglBlendFuncSeparateEXT;
	(*  GL_EXT_blend_minmax  *)
	BlendEquationEXT- : TglBlendEquationEXT;
	(*  GL_EXT_color_subtable  *)
	ColorSubTableEXT- : TglColorSubTableEXT;
	CopyColorSubTableEXT- : TglCopyColorSubTableEXT;
	(*  GL_EXT_compiled_vertex_array  *)
	LockArraysEXT- : TglLockArraysEXT;
	UnlockArraysEXT- : TglUnlockArraysEXT;
	(*  GL_EXT_convolution  *)
	ConvolutionFilter1DEXT- : TglConvolutionFilter1DEXT;
	ConvolutionFilter2DEXT- : TglConvolutionFilter2DEXT;
	ConvolutionParameterfEXT- : TglConvolutionParameterfEXT;
	ConvolutionParameterfvEXT- : TglConvolutionParameterfvEXT;
	ConvolutionParameteriEXT- : TglConvolutionParameteriEXT;
	ConvolutionParameterivEXT- : TglConvolutionParameterivEXT;
	CopyConvolutionFilter1DEXT- : TglCopyConvolutionFilter1DEXT;
	CopyConvolutionFilter2DEXT- : TglCopyConvolutionFilter2DEXT;
	GetConvolutionFilterEXT- : TglGetConvolutionFilterEXT;
	GetConvolutionParameterfvEXT- : TglGetConvolutionParameterfvEXT;
	GetConvolutionParameterivEXT- : TglGetConvolutionParameterivEXT;
	GetSeparableFilterEXT- : TglGetSeparableFilterEXT;
	SeparableFilter2DEXT- : TglSeparableFilter2DEXT;
	(*  GL_EXT_coordinate_frame  *)
	Tangent3bEXT- : TglTangent3bEXT;
	Tangent3bvEXT- : TglTangent3bvEXT;
	Tangent3dEXT- : TglTangent3dEXT;
	Tangent3dvEXT- : TglTangent3dvEXT;
	Tangent3fEXT- : TglTangent3fEXT;
	Tangent3fvEXT- : TglTangent3fvEXT;
	Tangent3iEXT- : TglTangent3iEXT;
	Tangent3ivEXT- : TglTangent3ivEXT;
	Tangent3sEXT- : TglTangent3sEXT;
	Tangent3svEXT- : TglTangent3svEXT;
	Binormal3bEXT- : TglBinormal3bEXT;
	Binormal3bvEXT- : TglBinormal3bvEXT;
	Binormal3dEXT- : TglBinormal3dEXT;
	Binormal3dvEXT- : TglBinormal3dvEXT;
	Binormal3fEXT- : TglBinormal3fEXT;
	Binormal3fvEXT- : TglBinormal3fvEXT;
	Binormal3iEXT- : TglBinormal3iEXT;
	Binormal3ivEXT- : TglBinormal3ivEXT;
	Binormal3sEXT- : TglBinormal3sEXT;
	Binormal3svEXT- : TglBinormal3svEXT;
	TangentPointerEXT- : TglTangentPointerEXT;
	BinormalPointerEXT- : TglBinormalPointerEXT;
	(*  GL_EXT_copy_texture  *)
	CopyTexImage1DEXT- : TglCopyTexImage1DEXT;
	CopyTexImage2DEXT- : TglCopyTexImage2DEXT;
	CopyTexSubImage1DEXT- : TglCopyTexSubImage1DEXT;
	CopyTexSubImage2DEXT- : TglCopyTexSubImage2DEXT;
	CopyTexSubImage3DEXT- : TglCopyTexSubImage3DEXT;
	(*  GL_EXT_cull_vertex  *)
	CullParameterdvEXT- : TglCullParameterdvEXT;
	CullParameterfvEXT- : TglCullParameterfvEXT;
	(*  GL_EXT_draw_range_elements  *)
	DrawRangeElementsEXT- : TglDrawRangeElementsEXT;
	(*  GL_EXT_fog_coord  *)
	FogCoordfEXT- : TglFogCoordfEXT;
	FogCoordfvEXT- : TglFogCoordfvEXT;
	FogCoorddEXT- : TglFogCoorddEXT;
	FogCoorddvEXT- : TglFogCoorddvEXT;
	FogCoordPointerEXT- : TglFogCoordPointerEXT;
	(*  GL_EXT_framebuffer_object  *)
	IsRenderbufferEXT- : TglIsRenderbufferEXT;
	BindRenderbufferEXT- : TglBindRenderbufferEXT;
	DeleteRenderbuffersEXT- : TglDeleteRenderbuffersEXT;
	GenRenderbuffersEXT- : TglGenRenderbuffersEXT;
	RenderbufferStorageEXT- : TglRenderbufferStorageEXT;
	GetRenderbufferParameterivEXT- : TglGetRenderbufferParameterivEXT;
	IsFramebufferEXT- : TglIsFramebufferEXT;
	BindFramebufferEXT- : TglBindFramebufferEXT;
	DeleteFramebuffersEXT- : TglDeleteFramebuffersEXT;
	GenFramebuffersEXT- : TglGenFramebuffersEXT;
	CheckFramebufferStatusEXT- : TglCheckFramebufferStatusEXT;
	FramebufferTexture1DEXT- : TglFramebufferTexture1DEXT;
	FramebufferTexture2DEXT- : TglFramebufferTexture2DEXT;
	FramebufferTexture3DEXT- : TglFramebufferTexture3DEXT;
	FramebufferRenderbufferEXT- : TglFramebufferRenderbufferEXT;
	GetFramebufferAttachmentParameterivEXT- : TglGetFramebufferAttachmentParameterivEXT;
	GenerateMipmapEXT- : TglGenerateMipmapEXT;
	(*  GL_EXT_histogram  *)
	GetHistogramEXT- : TglGetHistogramEXT;
	GetHistogramParameterfvEXT- : TglGetHistogramParameterfvEXT;
	GetHistogramParameterivEXT- : TglGetHistogramParameterivEXT;
	GetMinmaxEXT- : TglGetMinmaxEXT;
	GetMinmaxParameterfvEXT- : TglGetMinmaxParameterfvEXT;
	GetMinmaxParameterivEXT- : TglGetMinmaxParameterivEXT;
	HistogramEXT- : TglHistogramEXT;
	MinmaxEXT- : TglMinmaxEXT;
	ResetHistogramEXT- : TglResetHistogramEXT;
	ResetMinmaxEXT- : TglResetMinmaxEXT;
	(*  GL_EXT_index_func  *)
	IndexFuncEXT- : TglIndexFuncEXT;
	(*  GL_EXT_index_material  *)
	IndexMaterialEXT- : TglIndexMaterialEXT;
	(*  GL_EXT_light_texture  *)
	ApplyTextureEXT- : TglApplyTextureEXT;
	TextureLightEXT- : TglTextureLightEXT;
	TextureMaterialEXT- : TglTextureMaterialEXT;
	(*  GL_EXT_multi_draw_arrays  *)
	MultiDrawArraysEXT- : TglMultiDrawArraysEXT;
	MultiDrawElementsEXT- : TglMultiDrawElementsEXT;
	(*  GL_EXT_multisample  *)
	SampleMaskEXT- : TglSampleMaskEXT;
	SamplePatternEXT- : TglSamplePatternEXT;
	(*  GL_EXT_paletted_texture  *)
	ColorTableEXT- : TglColorTableEXT;
	GetColorTableEXT- : TglGetColorTableEXT;
	GetColorTableParameterivEXT- : TglGetColorTableParameterivEXT;
	GetColorTableParameterfvEXT- : TglGetColorTableParameterfvEXT;
	(*  GL_EXT_pixel_transform  *)
	PixelTransformParameteriEXT- : TglPixelTransformParameteriEXT;
	PixelTransformParameterfEXT- : TglPixelTransformParameterfEXT;
	PixelTransformParameterivEXT- : TglPixelTransformParameterivEXT;
	PixelTransformParameterfvEXT- : TglPixelTransformParameterfvEXT;
	(*  GL_EXT_point_parameters  *)
	PointParameterfEXT- : TglPointParameterfEXT;
	PointParameterfvEXT- : TglPointParameterfvEXT;
	(*  GL_EXT_polygon_offset  *)
	PolygonOffsetEXT- : TglPolygonOffsetEXT;
	(*  GL_EXT_secondary_color  *)
	SecondaryColor3bEXT- : TglSecondaryColor3bEXT;
	SecondaryColor3bvEXT- : TglSecondaryColor3bvEXT;
	SecondaryColor3dEXT- : TglSecondaryColor3dEXT;
	SecondaryColor3dvEXT- : TglSecondaryColor3dvEXT;
	SecondaryColor3fEXT- : TglSecondaryColor3fEXT;
	SecondaryColor3fvEXT- : TglSecondaryColor3fvEXT;
	SecondaryColor3iEXT- : TglSecondaryColor3iEXT;
	SecondaryColor3ivEXT- : TglSecondaryColor3ivEXT;
	SecondaryColor3sEXT- : TglSecondaryColor3sEXT;
	SecondaryColor3svEXT- : TglSecondaryColor3svEXT;
	SecondaryColor3ubEXT- : TglSecondaryColor3ubEXT;
	SecondaryColor3ubvEXT- : TglSecondaryColor3ubvEXT;
	SecondaryColor3uiEXT- : TglSecondaryColor3uiEXT;
	SecondaryColor3uivEXT- : TglSecondaryColor3uivEXT;
	SecondaryColor3usEXT- : TglSecondaryColor3usEXT;
	SecondaryColor3usvEXT- : TglSecondaryColor3usvEXT;
	SecondaryColorPointerEXT- : TglSecondaryColorPointerEXT;
	(*  GL_EXT_stencil_two_side  *)
	ActiveStencilFaceEXT- : TglActiveStencilFaceEXT;
	(*  GL_EXT_subtexture  *)
	TexSubImage1DEXT- : TglTexSubImage1DEXT;
	TexSubImage2DEXT- : TglTexSubImage2DEXT;
	(*  GL_EXT_texture3D  *)
	TexImage3DEXT- : TglTexImage3DEXT;
	TexSubImage3DEXT- : TglTexSubImage3DEXT;
	(*  GL_EXT_texture_object  *)
	AreTexturesResidentEXT- : TglAreTexturesResidentEXT;
	BindTextureEXT- : TglBindTextureEXT;
	DeleteTexturesEXT- : TglDeleteTexturesEXT;
	GenTexturesEXT- : TglGenTexturesEXT;
	IsTextureEXT- : TglIsTextureEXT;
	PrioritizeTexturesEXT- : TglPrioritizeTexturesEXT;
	(*  GL_EXT_texture_perturb_normal  *)
	TextureNormalEXT- : TglTextureNormalEXT;
	(*  GL_EXT_vertex_array  *)
	ArrayElementEXT- : TglArrayElementEXT;
	ColorPointerEXT- : TglColorPointerEXT;
	DrawArraysEXT- : TglDrawArraysEXT;
	EdgeFlagPointerEXT- : TglEdgeFlagPointerEXT;
	GetPointervEXT- : TglGetPointervEXT;
	IndexPointerEXT- : TglIndexPointerEXT;
	NormalPointerEXT- : TglNormalPointerEXT;
	TexCoordPointerEXT- : TglTexCoordPointerEXT;
	VertexPointerEXT- : TglVertexPointerEXT;
	(*  GL_EXT_vertex_shader  *)
	BeginVertexShaderEXT- : TglBeginVertexShaderEXT;
	EndVertexShaderEXT- : TglEndVertexShaderEXT;
	BindVertexShaderEXT- : TglBindVertexShaderEXT;
	GenVertexShadersEXT- : TglGenVertexShadersEXT;
	DeleteVertexShaderEXT- : TglDeleteVertexShaderEXT;
	ShaderOp1EXT- : TglShaderOp1EXT;
	ShaderOp2EXT- : TglShaderOp2EXT;
	ShaderOp3EXT- : TglShaderOp3EXT;
	SwizzleEXT- : TglSwizzleEXT;
	WriteMaskEXT- : TglWriteMaskEXT;
	InsertComponentEXT- : TglInsertComponentEXT;
	ExtractComponentEXT- : TglExtractComponentEXT;
	GenSymbolsEXT- : TglGenSymbolsEXT;
	SetInvariantEXT- : TglSetInvariantEXT;
	SetLocalConstantEXT- : TglSetLocalConstantEXT;
	VariantbvEXT- : TglVariantbvEXT;
	VariantsvEXT- : TglVariantsvEXT;
	VariantivEXT- : TglVariantivEXT;
	VariantfvEXT- : TglVariantfvEXT;
	VariantdvEXT- : TglVariantdvEXT;
	VariantubvEXT- : TglVariantubvEXT;
	VariantusvEXT- : TglVariantusvEXT;
	VariantuivEXT- : TglVariantuivEXT;
	VariantPointerEXT- : TglVariantPointerEXT;
	EnableVariantClientStateEXT- : TglEnableVariantClientStateEXT;
	DisableVariantClientStateEXT- : TglDisableVariantClientStateEXT;
	BindLightParameterEXT- : TglBindLightParameterEXT;
	BindMaterialParameterEXT- : TglBindMaterialParameterEXT;
	BindTexGenParameterEXT- : TglBindTexGenParameterEXT;
	BindTextureUnitParameterEXT- : TglBindTextureUnitParameterEXT;
	BindParameterEXT- : TglBindParameterEXT;
	IsVariantEnabledEXT- : TglIsVariantEnabledEXT;
	GetVariantBooleanvEXT- : TglGetVariantBooleanvEXT;
	GetVariantIntegervEXT- : TglGetVariantIntegervEXT;
	GetVariantFloatvEXT- : TglGetVariantFloatvEXT;
	GetVariantPointervEXT- : TglGetVariantPointervEXT;
	GetInvariantBooleanvEXT- : TglGetInvariantBooleanvEXT;
	GetInvariantIntegervEXT- : TglGetInvariantIntegervEXT;
	GetInvariantFloatvEXT- : TglGetInvariantFloatvEXT;
	GetLocalConstantBooleanvEXT- : TglGetLocalConstantBooleanvEXT;
	GetLocalConstantIntegervEXT- : TglGetLocalConstantIntegervEXT;
	GetLocalConstantFloatvEXT- : TglGetLocalConstantFloatvEXT;
	(*  GL_EXT_vertex_weighting  *)
	VertexWeightfEXT- : TglVertexWeightfEXT;
	VertexWeightfvEXT- : TglVertexWeightfvEXT;
	VertexWeightPointerEXT- : TglVertexWeightPointerEXT;
	(*  GL_EXT_stencil_clear_tag  *)
	StencilClearTagEXT- : TglStencilClearTagEXT;
	(*  GL_EXT_framebuffer_blit  *)
	BlitFramebufferEXT- : TglBlitFramebufferEXT;
	(*  GL_EXT_framebuffer_multisample  *)
	RenderbufferStorageMultisampleEXT- : TglRenderbufferStorageMultisampleEXT;
	(*  GL_EXT_timer_query  *)
	GetQueryObjecti64vEXT- : TglGetQueryObjecti64vEXT;
	GetQueryObjectui64vEXT- : TglGetQueryObjectui64vEXT;
	(*  GL_EXT_gpu_program_parameters  *)
	ProgramEnvParameters4fvEXT- : TglProgramEnvParameters4fvEXT;
	ProgramLocalParameters4fvEXT- : TglProgramLocalParameters4fvEXT;
	(*  GL_EXT_bindable_uniform  *)
	UniformBufferEXT- : TglUniformBufferEXT;
	GetUniformBufferSizeEXT- : TglGetUniformBufferSizeEXT;
	GetUniformOffsetEXT- : TglGetUniformOffsetEXT;
	(*  GL_EXT_draw_buffers2  *)
	ColorMaskIndexedEXT- : TglColorMaskIndexedEXT;
	GetBooleanIndexedvEXT- : TglGetBooleanIndexedvEXT;
	GetIntegerIndexedvEXT- : TglGetIntegerIndexedvEXT;
	EnableIndexedEXT- : TglEnableIndexedEXT;
	DisableIndexedEXT- : TglDisableIndexedEXT;
	IsEnabledIndexedEXT- : TglIsEnabledIndexedEXT;
	(*  GL_EXT_draw_instanced  *)
	DrawArraysInstancedEXT- : TglDrawArraysInstancedEXT;
	DrawElementsInstancedEXT- : TglDrawElementsInstancedEXT;
	(*  GL_EXT_geometry_shader4  *)
	ProgramParameteriEXT- : TglProgramParameteriEXT;
	FramebufferTextureEXT- : TglFramebufferTextureEXT;
	(*   glFramebufferTextureLayerEXT- : TglFramebufferTextureLayerEXT; *)
	FramebufferTextureFaceEXT- : TglFramebufferTextureFaceEXT;
	(*  GL_EXT_gpu_shader4  *)
	VertexAttribI1iEXT- : TglVertexAttribI1iEXT;
	VertexAttribI2iEXT- : TglVertexAttribI2iEXT;
	VertexAttribI3iEXT- : TglVertexAttribI3iEXT;
	VertexAttribI4iEXT- : TglVertexAttribI4iEXT;
	VertexAttribI1uiEXT- : TglVertexAttribI1uiEXT;
	VertexAttribI2uiEXT- : TglVertexAttribI2uiEXT;
	VertexAttribI3uiEXT- : TglVertexAttribI3uiEXT;
	VertexAttribI4uiEXT- : TglVertexAttribI4uiEXT;
	VertexAttribI1ivEXT- : TglVertexAttribI1ivEXT;
	VertexAttribI2ivEXT- : TglVertexAttribI2ivEXT;
	VertexAttribI3ivEXT- : TglVertexAttribI3ivEXT;
	VertexAttribI4ivEXT- : TglVertexAttribI4ivEXT;
	VertexAttribI1uivEXT- : TglVertexAttribI1uivEXT;
	VertexAttribI2uivEXT- : TglVertexAttribI2uivEXT;
	VertexAttribI3uivEXT- : TglVertexAttribI3uivEXT;
	VertexAttribI4uivEXT- : TglVertexAttribI4uivEXT;
	VertexAttribI4bvEXT- : TglVertexAttribI4bvEXT;
	VertexAttribI4svEXT- : TglVertexAttribI4svEXT;
	VertexAttribI4ubvEXT- : TglVertexAttribI4ubvEXT;
	VertexAttribI4usvEXT- : TglVertexAttribI4usvEXT;
	VertexAttribIPointerEXT- : TglVertexAttribIPointerEXT;
	GetVertexAttribIivEXT- : TglGetVertexAttribIivEXT;
	GetVertexAttribIuivEXT- : TglGetVertexAttribIuivEXT;
	Uniform1uiEXT- : TglUniform1uiEXT;
	Uniform2uiEXT- : TglUniform2uiEXT;
	Uniform3uiEXT- : TglUniform3uiEXT;
	Uniform4uiEXT- : TglUniform4uiEXT;
	Uniform1uivEXT- : TglUniform1uivEXT;
	Uniform2uivEXT- : TglUniform2uivEXT;
	Uniform3uivEXT- : TglUniform3uivEXT;
	Uniform4uivEXT- : TglUniform4uivEXT;
	GetUniformuivEXT- : TglGetUniformuivEXT;
	BindFragDataLocationEXT- : TglBindFragDataLocationEXT;
	GetFragDataLocationEXT- : TglGetFragDataLocationEXT;
	(*  GL_EXT_texture_array  *)
	FramebufferTextureLayerEXT- : TglFramebufferTextureLayerEXT;
	(*  GL_EXT_texture_buffer_object  *)
	TexBufferEXT- : TglTexBufferEXT;
	(*  GL_EXT_texture_integer  *)
	ClearColorIiEXT- : TglClearColorIiEXT;
	ClearColorIuiEXT- : TglClearColorIuiEXT;
	TexParameterIivEXT- : TglTexParameterIivEXT;
	TexParameterIuivEXT- : TglTexParameterIuivEXT;
	GetTexParameterIivEXT- : TglGetTexParameterIivEXT;
	GetTexParameterIiuvEXT- : TglGetTexParameterIiuvEXT;
	(*  GL_EXT_transform_feedback  *)
	BeginTransformFeedbackEXT- : TglBeginTransformFeedbackEXT;
	EndTransformFeedbackEXT- : TglEndTransformFeedbackEXT;
	BindBufferRangeEXT- : TglBindBufferRangeEXT;
	BindBufferOffsetEXT- : TglBindBufferOffsetEXT;
	BindBufferBaseEXT- : TglBindBufferBaseEXT;
	TransformFeedbackVaryingsEXT- : TglTransformFeedbackVaryingsEXT;
	GetTransformFeedbackVaryingEXT- : TglGetTransformFeedbackVaryingEXT;
	(*  GL_EXT_direct_state_access  *)
	ClientAttribDefaultEXT- : TglClientAttribDefaultEXT;
	PushClientAttribDefaultEXT- : TglPushClientAttribDefaultEXT;
	MatrixLoadfEXT- : TglMatrixLoadfEXT;
	MatrixLoaddEXT- : TglMatrixLoaddEXT;
	MatrixMultfEXT- : TglMatrixMultfEXT;
	MatrixMultdEXT- : TglMatrixMultdEXT;
	MatrixLoadIdentityEXT- : TglMatrixLoadIdentityEXT;
	MatrixRotatefEXT- : TglMatrixRotatefEXT;
	MatrixRotatedEXT- : TglMatrixRotatedEXT;
	MatrixScalefEXT- : TglMatrixScalefEXT;
	MatrixScaledEXT- : TglMatrixScaledEXT;
	MatrixTranslatefEXT- : TglMatrixTranslatefEXT;
	MatrixTranslatedEXT- : TglMatrixTranslatedEXT;
	MatrixFrustumEXT- : TglMatrixFrustumEXT;
	MatrixOrthoEXT- : TglMatrixOrthoEXT;
	MatrixPopEXT- : TglMatrixPopEXT;
	MatrixPushEXT- : TglMatrixPushEXT;
	MatrixLoadTransposefEXT- : TglMatrixLoadTransposefEXT;
	MatrixLoadTransposedEXT- : TglMatrixLoadTransposedEXT;
	MatrixMultTransposefEXT- : TglMatrixMultTransposefEXT;
	MatrixMultTransposedEXT- : TglMatrixMultTransposedEXT;
	TextureParameterfEXT- : TglTextureParameterfEXT;
	TextureParameterfvEXT- : TglTextureParameterfvEXT;
	TextureParameteriEXT- : TglTextureParameteriEXT;
	TextureParameterivEXT- : TglTextureParameterivEXT;
	TextureImage1DEXT- : TglTextureImage1DEXT;
	TextureImage2DEXT- : TglTextureImage2DEXT;
	TextureSubImage1DEXT- : TglTextureSubImage1DEXT;
	TextureSubImage2DEXT- : TglTextureSubImage2DEXT;
	CopyTextureImage1DEXT- : TglCopyTextureImage1DEXT;
	CopyTextureImage2DEXT- : TglCopyTextureImage2DEXT;
	CopyTextureSubImage1DEXT- : TglCopyTextureSubImage1DEXT;
	CopyTextureSubImage2DEXT- : TglCopyTextureSubImage2DEXT;
	GetTextureImageEXT- : TglGetTextureImageEXT;
	GetTextureParameterfvEXT- : TglGetTextureParameterfvEXT;
	GetTextureParameterivEXT- : TglGetTextureParameterivEXT;
	GetTextureLevelParameterfvEXT- : TglGetTextureLevelParameterfvEXT;
	GetTextureLevelParameterivEXT- : TglGetTextureLevelParameterivEXT;
	TextureImage3DEXT- : TglTextureImage3DEXT;
	TextureSubImage3DEXT- : TglTextureSubImage3DEXT;
	CopyTextureSubImage3DEXT- : TglCopyTextureSubImage3DEXT;
	MultiTexParameterfEXT- : TglMultiTexParameterfEXT;
	MultiTexParameterfvEXT- : TglMultiTexParameterfvEXT;
	MultiTexParameteriEXT- : TglMultiTexParameteriEXT;
	MultiTexParameterivEXT- : TglMultiTexParameterivEXT;
	MultiTexImage1DEXT- : TglMultiTexImage1DEXT;
	MultiTexImage2DEXT- : TglMultiTexImage2DEXT;
	MultiTexSubImage1DEXT- : TglMultiTexSubImage1DEXT;
	MultiTexSubImage2DEXT- : TglMultiTexSubImage2DEXT;
	CopyMultiTexImage1DEXT- : TglCopyMultiTexImage1DEXT;
	CopyMultiTexImage2DEXT- : TglCopyMultiTexImage2DEXT;
	CopyMultiTexSubImage1DEXT- : TglCopyMultiTexSubImage1DEXT;
	CopyMultiTexSubImage2DEXT- : TglCopyMultiTexSubImage2DEXT;
	GetMultiTexImageEXT- : TglGetMultiTexImageEXT;
	GetMultiTexParameterfvEXT- : TglGetMultiTexParameterfvEXT;
	GetMultiTexParameterivEXT- : TglGetMultiTexParameterivEXT;
	GetMultiTexLevelParameterfvEXT- : TglGetMultiTexLevelParameterfvEXT;
	GetMultiTexLevelParameterivEXT- : TglGetMultiTexLevelParameterivEXT;
	MultiTexImage3DEXT- : TglMultiTexImage3DEXT;
	MultiTexSubImage3DEXT- : TglMultiTexSubImage3DEXT;
	CopyMultiTexSubImage3DEXT- : TglCopyMultiTexSubImage3DEXT;
	BindMultiTextureEXT- : TglBindMultiTextureEXT;
	EnableClientStateIndexedEXT- : TglEnableClientStateIndexedEXT;
	DisableClientStateIndexedEXT- : TglDisableClientStateIndexedEXT;
	MultiTexCoordPointerEXT- : TglMultiTexCoordPointerEXT;
	MultiTexEnvfEXT- : TglMultiTexEnvfEXT;
	MultiTexEnvfvEXT- : TglMultiTexEnvfvEXT;
	MultiTexEnviEXT- : TglMultiTexEnviEXT;
	MultiTexEnvivEXT- : TglMultiTexEnvivEXT;
	MultiTexGendEXT- : TglMultiTexGendEXT;
	MultiTexGendvEXT- : TglMultiTexGendvEXT;
	MultiTexGenfEXT- : TglMultiTexGenfEXT;
	MultiTexGenfvEXT- : TglMultiTexGenfvEXT;
	MultiTexGeniEXT- : TglMultiTexGeniEXT;
	MultiTexGenivEXT- : TglMultiTexGenivEXT;
	GetMultiTexEnvfvEXT- : TglGetMultiTexEnvfvEXT;
	GetMultiTexEnvivEXT- : TglGetMultiTexEnvivEXT;
	GetMultiTexGendvEXT- : TglGetMultiTexGendvEXT;
	GetMultiTexGenfvEXT- : TglGetMultiTexGenfvEXT;
	GetMultiTexGenivEXT- : TglGetMultiTexGenivEXT;
	GetFloatIndexedvEXT- : TglGetFloatIndexedvEXT;
	GetDoubleIndexedvEXT- : TglGetDoubleIndexedvEXT;
	GetPointerIndexedvEXT- : TglGetPointerIndexedvEXT;
	CompressedTextureImage3DEXT- : TglCompressedTextureImage3DEXT;
	CompressedTextureImage2DEXT- : TglCompressedTextureImage2DEXT;
	CompressedTextureImage1DEXT- : TglCompressedTextureImage1DEXT;
	CompressedTextureSubImage3DEXT- : TglCompressedTextureSubImage3DEXT;
	CompressedTextureSubImage2DEXT- : TglCompressedTextureSubImage2DEXT;
	CompressedTextureSubImage1DEXT- : TglCompressedTextureSubImage1DEXT;
	GetCompressedTextureImageEXT- : TglGetCompressedTextureImageEXT;
	CompressedMultiTexImage3DEXT- : TglCompressedMultiTexImage3DEXT;
	CompressedMultiTexImage2DEXT- : TglCompressedMultiTexImage2DEXT;
	CompressedMultiTexImage1DEXT- : TglCompressedMultiTexImage1DEXT;
	CompressedMultiTexSubImage3DEXT- : TglCompressedMultiTexSubImage3DEXT;
	CompressedMultiTexSubImage2DEXT- : TglCompressedMultiTexSubImage2DEXT;
	CompressedMultiTexSubImage1DEXT- : TglCompressedMultiTexSubImage1DEXT;
	GetCompressedMultiTexImageEXT- : TglGetCompressedMultiTexImageEXT;
	NamedProgramStringEXT- : TglNamedProgramStringEXT;
	NamedProgramLocalParameter4dEXT- : TglNamedProgramLocalParameter4dEXT;
	NamedProgramLocalParameter4dvEXT- : TglNamedProgramLocalParameter4dvEXT;
	NamedProgramLocalParameter4fEXT- : TglNamedProgramLocalParameter4fEXT;
	NamedProgramLocalParameter4fvEXT- : TglNamedProgramLocalParameter4fvEXT;
	GetNamedProgramLocalParameterdvEXT- : TglGetNamedProgramLocalParameterdvEXT;
	GetNamedProgramLocalParameterfvEXT- : TglGetNamedProgramLocalParameterfvEXT;
	GetNamedProgramivEXT- : TglGetNamedProgramivEXT;
	GetNamedProgramStringEXT- : TglGetNamedProgramStringEXT;
	NamedProgramLocalParameters4fvEXT- : TglNamedProgramLocalParameters4fvEXT;
	NamedProgramLocalParameterI4iEXT- : TglNamedProgramLocalParameterI4iEXT;
	NamedProgramLocalParameterI4ivEXT- : TglNamedProgramLocalParameterI4ivEXT;
	NamedProgramLocalParametersI4ivEXT- : TglNamedProgramLocalParametersI4ivEXT;
	NamedProgramLocalParameterI4uiEXT- : TglNamedProgramLocalParameterI4uiEXT;
	NamedProgramLocalParameterI4uivEXT- : TglNamedProgramLocalParameterI4uivEXT;
	NamedProgramLocalParametersI4uivEXT- : TglNamedProgramLocalParametersI4uivEXT;
	GetNamedProgramLocalParameterIivEXT- : TglGetNamedProgramLocalParameterIivEXT;
	GetNamedProgramLocalParameterIuivEXT- : TglGetNamedProgramLocalParameterIuivEXT;
	TextureParameterIivEXT- : TglTextureParameterIivEXT;
	TextureParameterIuivEXT- : TglTextureParameterIuivEXT;
	GetTextureParameterIivEXT- : TglGetTextureParameterIivEXT;
	GetTextureParameterIuivEXT- : TglGetTextureParameterIuivEXT;
	MultiTexParameterIivEXT- : TglMultiTexParameterIivEXT;
	MultiTexParameterIuivEXT- : TglMultiTexParameterIuivEXT;
	GetMultiTexParameterIivEXT- : TglGetMultiTexParameterIivEXT;
	GetMultiTexParameterIuivEXT- : TglGetMultiTexParameterIuivEXT;
	ProgramUniform1fEXT- : TglProgramUniform1fEXT;
	ProgramUniform2fEXT- : TglProgramUniform2fEXT;
	ProgramUniform3fEXT- : TglProgramUniform3fEXT;
	ProgramUniform4fEXT- : TglProgramUniform4fEXT;
	ProgramUniform1iEXT- : TglProgramUniform1iEXT;
	ProgramUniform2iEXT- : TglProgramUniform2iEXT;
	ProgramUniform3iEXT- : TglProgramUniform3iEXT;
	ProgramUniform4iEXT- : TglProgramUniform4iEXT;
	ProgramUniform1fvEXT- : TglProgramUniform1fvEXT;
	ProgramUniform2fvEXT- : TglProgramUniform2fvEXT;
	ProgramUniform3fvEXT- : TglProgramUniform3fvEXT;
	ProgramUniform4fvEXT- : TglProgramUniform4fvEXT;
	ProgramUniform1ivEXT- : TglProgramUniform1ivEXT;
	ProgramUniform2ivEXT- : TglProgramUniform2ivEXT;
	ProgramUniform3ivEXT- : TglProgramUniform3ivEXT;
	ProgramUniform4ivEXT- : TglProgramUniform4ivEXT;
	ProgramUniformMatrix2fvEXT- : TglProgramUniformMatrix2fvEXT;
	ProgramUniformMatrix3fvEXT- : TglProgramUniformMatrix3fvEXT;
	ProgramUniformMatrix4fvEXT- : TglProgramUniformMatrix4fvEXT;
	ProgramUniformMatrix2x3fvEXT- : TglProgramUniformMatrix2x3fvEXT;
	ProgramUniformMatrix3x2fvEXT- : TglProgramUniformMatrix3x2fvEXT;
	ProgramUniformMatrix2x4fvEXT- : TglProgramUniformMatrix2x4fvEXT;
	ProgramUniformMatrix4x2fvEXT- : TglProgramUniformMatrix4x2fvEXT;
	ProgramUniformMatrix3x4fvEXT- : TglProgramUniformMatrix3x4fvEXT;
	ProgramUniformMatrix4x3fvEXT- : TglProgramUniformMatrix4x3fvEXT;
	ProgramUniform1uiEXT- : TglProgramUniform1uiEXT;
	ProgramUniform2uiEXT- : TglProgramUniform2uiEXT;
	ProgramUniform3uiEXT- : TglProgramUniform3uiEXT;
	ProgramUniform4uiEXT- : TglProgramUniform4uiEXT;
	ProgramUniform1uivEXT- : TglProgramUniform1uivEXT;
	ProgramUniform2uivEXT- : TglProgramUniform2uivEXT;
	ProgramUniform3uivEXT- : TglProgramUniform3uivEXT;
	ProgramUniform4uivEXT- : TglProgramUniform4uivEXT;
	NamedBufferDataEXT- : TglNamedBufferDataEXT;
	NamedBufferSubDataEXT- : TglNamedBufferSubDataEXT;
	MapNamedBufferEXT- : TglMapNamedBufferEXT;
	UnmapNamedBufferEXT- : TglUnmapNamedBufferEXT;
	MapNamedBufferRangeEXT- : TglMapNamedBufferRangeEXT;
	FlushMappedNamedBufferRangeEXT- : TglFlushMappedNamedBufferRangeEXT;
	NamedCopyBufferSubDataEXT- : TglNamedCopyBufferSubDataEXT;
	GetNamedBufferParameterivEXT- : TglGetNamedBufferParameterivEXT;
	GetNamedBufferPointervEXT- : TglGetNamedBufferPointervEXT;
	GetNamedBufferSubDataEXT- : TglGetNamedBufferSubDataEXT;
	TextureBufferEXT- : TglTextureBufferEXT;
	MultiTexBufferEXT- : TglMultiTexBufferEXT;
	NamedRenderbufferStorageEXT- : TglNamedRenderbufferStorageEXT;
	GetNamedRenderbufferParameterivEXT- : TglGetNamedRenderbufferParameterivEXT;
	CheckNamedFramebufferStatusEXT- : TglCheckNamedFramebufferStatusEXT;
	NamedFramebufferTexture1DEXT- : TglNamedFramebufferTexture1DEXT;
	NamedFramebufferTexture2DEXT- : TglNamedFramebufferTexture2DEXT;
	NamedFramebufferTexture3DEXT- : TglNamedFramebufferTexture3DEXT;
	NamedFramebufferRenderbufferEXT- : TglNamedFramebufferRenderbufferEXT;
	GetNamedFramebufferAttachmentParameterivEXT- : TglGetNamedFramebufferAttachmentParameterivEXT;
	GenerateTextureMipmapEXT- : TglGenerateTextureMipmapEXT;
	GenerateMultiTexMipmapEXT- : TglGenerateMultiTexMipmapEXT;
	FramebufferDrawBufferEXT- : TglFramebufferDrawBufferEXT;
	FramebufferDrawBuffersEXT- : TglFramebufferDrawBuffersEXT;
	FramebufferReadBufferEXT- : TglFramebufferReadBufferEXT;
	GetFramebufferParameterivEXT- : TglGetFramebufferParameterivEXT;
	NamedRenderbufferStorageMultisampleEXT- : TglNamedRenderbufferStorageMultisampleEXT;
	NamedRenderbufferStorageMultisampleCoverageEXT- : TglNamedRenderbufferStorageMultisampleCoverageEXT;
	NamedFramebufferTextureEXT- : TglNamedFramebufferTextureEXT;
	NamedFramebufferTextureLayerEXT- : TglNamedFramebufferTextureLayerEXT;
	NamedFramebufferTextureFaceEXT- : TglNamedFramebufferTextureFaceEXT;
	TextureRenderbufferEXT- : TglTextureRenderbufferEXT;
	MultiTexRenderbufferEXT- : TglMultiTexRenderbufferEXT;
	ProgramUniform1dEXT- : TglProgramUniform1dEXT;
	ProgramUniform2dEXT- : TglProgramUniform2dEXT;
	ProgramUniform3dEXT- : TglProgramUniform3dEXT;
	ProgramUniform4dEXT- : TglProgramUniform4dEXT;
	ProgramUniform1dvEXT- : TglProgramUniform1dvEXT;
	ProgramUniform2dvEXT- : TglProgramUniform2dvEXT;
	ProgramUniform3dvEXT- : TglProgramUniform3dvEXT;
	ProgramUniform4dvEXT- : TglProgramUniform4dvEXT;
	ProgramUniformMatrix2dvEXT- : TglProgramUniformMatrix2dvEXT;
	ProgramUniformMatrix3dvEXT- : TglProgramUniformMatrix3dvEXT;
	ProgramUniformMatrix4dvEXT- : TglProgramUniformMatrix4dvEXT;
	ProgramUniformMatrix2x3dvEXT- : TglProgramUniformMatrix2x3dvEXT;
	ProgramUniformMatrix2x4dvEXT- : TglProgramUniformMatrix2x4dvEXT;
	ProgramUniformMatrix3x2dvEXT- : TglProgramUniformMatrix3x2dvEXT;
	ProgramUniformMatrix3x4dvEXT- : TglProgramUniformMatrix3x4dvEXT;
	ProgramUniformMatrix4x2dvEXT- : TglProgramUniformMatrix4x2dvEXT;
	ProgramUniformMatrix4x3dvEXT- : TglProgramUniformMatrix4x3dvEXT;
	(*  GL_EXT_separate_shader_objects  *)
	UseShaderProgramEXT- : TglUseShaderProgramEXT;
	ActiveProgramEXT- : TglActiveProgramEXT;
	CreateShaderProgramEXT- : TglCreateShaderProgramEXT;
	(*  GL_EXT_shader_image_load_store  *)
	BindImageTextureEXT- : TglBindImageTextureEXT;
	MemoryBarrierEXT- : TglMemoryBarrierEXT;
	(*  GL_EXT_vertex_attrib_64bit  *)
	VertexAttribL1dEXT- : TglVertexAttribL1dEXT;
	VertexAttribL2dEXT- : TglVertexAttribL2dEXT;
	VertexAttribL3dEXT- : TglVertexAttribL3dEXT;
	VertexAttribL4dEXT- : TglVertexAttribL4dEXT;
	VertexAttribL1dvEXT- : TglVertexAttribL1dvEXT;
	VertexAttribL2dvEXT- : TglVertexAttribL2dvEXT;
	VertexAttribL3dvEXT- : TglVertexAttribL3dvEXT;
	VertexAttribL4dvEXT- : TglVertexAttribL4dvEXT;
	VertexAttribLPointerEXT- : TglVertexAttribLPointerEXT;
	GetVertexAttribLdvEXT- : TglGetVertexAttribLdvEXT;
	VertexArrayVertexAttribLOffsetEXT- : TglVertexArrayVertexAttribLOffsetEXT;
	(*  GL_HP_image_transform  *)
	ImageTransformParameteriHP- : TglImageTransformParameteriHP;
	ImageTransformParameterfHP- : TglImageTransformParameterfHP;
	ImageTransformParameterivHP- : TglImageTransformParameterivHP;
	ImageTransformParameterfvHP- : TglImageTransformParameterfvHP;
	GetImageTransformParameterivHP- : TglGetImageTransformParameterivHP;
	GetImageTransformParameterfvHP- : TglGetImageTransformParameterfvHP;
	(*  GL_EXT_depth_bounds_test  *)
	DepthBoundsEXT- : TglDepthBoundsEXT;
	(*  GL_EXT_blend_equation_separate  *)
	BlendEquationSeparateEXT- : TglBlendEquationSeparateEXT;
	(*  GL_IBM_multimode_draw_arrays  *)
	MultiModeDrawArraysIBM- : TglMultiModeDrawArraysIBM;
	MultiModeDrawElementsIBM- : TglMultiModeDrawElementsIBM;
	(*  GL_IBM_vertex_array_lists  *)
	ColorPointerListIBM- : TglColorPointerListIBM;
	SecondaryColorPointerListIBM- : TglSecondaryColorPointerListIBM;
	EdgeFlagPointerListIBM- : TglEdgeFlagPointerListIBM;
	FogCoordPointerListIBM- : TglFogCoordPointerListIBM;
	IndexPointerListIBM- : TglIndexPointerListIBM;
	NormalPointerListIBM- : TglNormalPointerListIBM;
	TexCoordPointerListIBM- : TglTexCoordPointerListIBM;
	VertexPointerListIBM- : TglVertexPointerListIBM;
	(*  GL_INGR_blend_func_separate  *)
	BlendFuncSeparateINGR- : TglBlendFuncSeparateINGR;
	(* GL_INTEL_framebuffer_CMAA *)
	ApplyFramebufferAttachmentCMAAINTEL- : TglApplyFramebufferAttachmentCMAAINTEL;

	(*  GL_INTEL_parallel_arrays  *)
	VertexPointervINTEL- : TglVertexPointervINTEL;
	NormalPointervINTEL- : TglNormalPointervINTEL;
	ColorPointervINTEL- : TglColorPointervINTEL;
	TexCoordPointervINTEL- : TglTexCoordPointervINTEL;
	(*  GL_MESA_resize_buffers  *)
	ResizeBuffersMESA- : TglResizeBuffersMESA;
	(*  GL_MESA_window_pos  *)
	WindowPos2dMESA- : TglWindowPos2dMESA;
	WindowPos2dvMESA- : TglWindowPos2dvMESA;
	WindowPos2fMESA- : TglWindowPos2fMESA;
	WindowPos2fvMESA- : TglWindowPos2fvMESA;
	WindowPos2iMESA- : TglWindowPos2iMESA;
	WindowPos2ivMESA- : TglWindowPos2ivMESA;
	WindowPos2sMESA- : TglWindowPos2sMESA;
	WindowPos2svMESA- : TglWindowPos2svMESA;
	WindowPos3dMESA- : TglWindowPos3dMESA;
	WindowPos3dvMESA- : TglWindowPos3dvMESA;
	WindowPos3fMESA- : TglWindowPos3fMESA;
	WindowPos3fvMESA- : TglWindowPos3fvMESA;
	WindowPos3iMESA- : TglWindowPos3iMESA;
	WindowPos3ivMESA- : TglWindowPos3ivMESA;
	WindowPos3sMESA- : TglWindowPos3sMESA;
	WindowPos3svMESA- : TglWindowPos3svMESA;
	WindowPos4dMESA- : TglWindowPos4dMESA;
	WindowPos4dvMESA- : TglWindowPos4dvMESA;
	WindowPos4fMESA- : TglWindowPos4fMESA;
	WindowPos4fvMESA- : TglWindowPos4fvMESA;
	WindowPos4iMESA- : TglWindowPos4iMESA;
	WindowPos4ivMESA- : TglWindowPos4ivMESA;
	WindowPos4sMESA- : TglWindowPos4sMESA;
	WindowPos4svMESA- : TglWindowPos4svMESA;
	(*  GL_NV_evaluators  *)
	MapControlPointsNV- : TglMapControlPointsNV;
	MapParameterivNV- : TglMapParameterivNV;
	MapParameterfvNV- : TglMapParameterfvNV;
	GetMapControlPointsNV- : TglGetMapControlPointsNV;
	GetMapParameterivNV- : TglGetMapParameterivNV;
	GetMapParameterfvNV- : TglGetMapParameterfvNV;
	GetMapAttribParameterivNV- : TglGetMapAttribParameterivNV;
	GetMapAttribParameterfvNV- : TglGetMapAttribParameterfvNV;
	EvalMapsNV- : TglEvalMapsNV;
	(*  GL_NV_fence  *)
	DeleteFencesNV- : TglDeleteFencesNV;
	GenFencesNV- : TglGenFencesNV;
	IsFenceNV- : TglIsFenceNV;
	TestFenceNV- : TglTestFenceNV;
	GetFenceivNV- : TglGetFenceivNV;
	FinishFenceNV- : TglFinishFenceNV;
	SetFenceNV- : TglSetFenceNV;
	(*  GL_NV_fragment_program  *)
	ProgramNamedParameter4fNV- : TglProgramNamedParameter4fNV;
	ProgramNamedParameter4dNV- : TglProgramNamedParameter4dNV;
	ProgramNamedParameter4fvNV- : TglProgramNamedParameter4fvNV;
	ProgramNamedParameter4dvNV- : TglProgramNamedParameter4dvNV;
	GetProgramNamedParameterfvNV- : TglGetProgramNamedParameterfvNV;
	GetProgramNamedParameterdvNV- : TglGetProgramNamedParameterdvNV;
	(*  GL_NV_half_float  *)
	Vertex2hNV- : TglVertex2hNV;
	Vertex2hvNV- : TglVertex2hvNV;
	Vertex3hNV- : TglVertex3hNV;
	Vertex3hvNV- : TglVertex3hvNV;
	Vertex4hNV- : TglVertex4hNV;
	Vertex4hvNV- : TglVertex4hvNV;
	Normal3hNV- : TglNormal3hNV;
	Normal3hvNV- : TglNormal3hvNV;
	Color3hNV- : TglColor3hNV;
	Color3hvNV- : TglColor3hvNV;
	Color4hNV- : TglColor4hNV;
	Color4hvNV- : TglColor4hvNV;
	TexCoord1hNV- : TglTexCoord1hNV;
	TexCoord1hvNV- : TglTexCoord1hvNV;
	TexCoord2hNV- : TglTexCoord2hNV;
	TexCoord2hvNV- : TglTexCoord2hvNV;
	TexCoord3hNV- : TglTexCoord3hNV;
	TexCoord3hvNV- : TglTexCoord3hvNV;
	TexCoord4hNV- : TglTexCoord4hNV;
	TexCoord4hvNV- : TglTexCoord4hvNV;
	MultiTexCoord1hNV- : TglMultiTexCoord1hNV;
	MultiTexCoord1hvNV- : TglMultiTexCoord1hvNV;
	MultiTexCoord2hNV- : TglMultiTexCoord2hNV;
	MultiTexCoord2hvNV- : TglMultiTexCoord2hvNV;
	MultiTexCoord3hNV- : TglMultiTexCoord3hNV;
	MultiTexCoord3hvNV- : TglMultiTexCoord3hvNV;
	MultiTexCoord4hNV- : TglMultiTexCoord4hNV;
	MultiTexCoord4hvNV- : TglMultiTexCoord4hvNV;
	FogCoordhNV- : TglFogCoordhNV;
	FogCoordhvNV- : TglFogCoordhvNV;
	SecondaryColor3hNV- : TglSecondaryColor3hNV;
	SecondaryColor3hvNV- : TglSecondaryColor3hvNV;
	VertexWeighthNV- : TglVertexWeighthNV;
	VertexWeighthvNV- : TglVertexWeighthvNV;
	VertexAttrib1hNV- : TglVertexAttrib1hNV;
	VertexAttrib1hvNV- : TglVertexAttrib1hvNV;
	VertexAttrib2hNV- : TglVertexAttrib2hNV;
	VertexAttrib2hvNV- : TglVertexAttrib2hvNV;
	VertexAttrib3hNV- : TglVertexAttrib3hNV;
	VertexAttrib3hvNV- : TglVertexAttrib3hvNV;
	VertexAttrib4hNV- : TglVertexAttrib4hNV;
	VertexAttrib4hvNV- : TglVertexAttrib4hvNV;
	VertexAttribs1hvNV- : TglVertexAttribs1hvNV;
	VertexAttribs2hvNV- : TglVertexAttribs2hvNV;
	VertexAttribs3hvNV- : TglVertexAttribs3hvNV;
	VertexAttribs4hvNV- : TglVertexAttribs4hvNV;
	(*  GL_NV_occlusion_query  *)
	GenOcclusionQueriesNV- : TglGenOcclusionQueriesNV;
	DeleteOcclusionQueriesNV- : TglDeleteOcclusionQueriesNV;
	IsOcclusionQueryNV- : TglIsOcclusionQueryNV;
	BeginOcclusionQueryNV- : TglBeginOcclusionQueryNV;
	EndOcclusionQueryNV- : TglEndOcclusionQueryNV;
	GetOcclusionQueryivNV- : TglGetOcclusionQueryivNV;
	GetOcclusionQueryuivNV- : TglGetOcclusionQueryuivNV;
	(*  GL_NV_pixel_data_range  *)
	PixelDataRangeNV- : TglPixelDataRangeNV;
	FlushPixelDataRangeNV- : TglFlushPixelDataRangeNV;
	(*  GL_NV_point_sprite  *)
	PointParameteriNV- : TglPointParameteriNV;
	PointParameterivNV- : TglPointParameterivNV;
	(*  GL_NV_primitive_restart  *)
	PrimitiveRestartNV- : TglPrimitiveRestartNV;
	PrimitiveRestartIndexNV- : TglPrimitiveRestartIndexNV;
	(*  GL_NV_register_combiners  *)
	CombinerParameterfvNV- : TglCombinerParameterfvNV;
	CombinerParameterfNV- : TglCombinerParameterfNV;
	CombinerParameterivNV- : TglCombinerParameterivNV;
	CombinerParameteriNV- : TglCombinerParameteriNV;
	CombinerInputNV- : TglCombinerInputNV;
	CombinerOutputNV- : TglCombinerOutputNV;
	FinalCombinerInputNV- : TglFinalCombinerInputNV;
	GetCombinerInputParameterfvNV- : TglGetCombinerInputParameterfvNV;
	GetCombinerInputParameterivNV- : TglGetCombinerInputParameterivNV;
	GetCombinerOutputParameterfvNV- : TglGetCombinerOutputParameterfvNV;
	GetCombinerOutputParameterivNV- : TglGetCombinerOutputParameterivNV;
	GetFinalCombinerInputParameterfvNV- : TglGetFinalCombinerInputParameterfvNV;
	GetFinalCombinerInputParameterivNV- : TglGetFinalCombinerInputParameterivNV;
	(*  GL_NV_register_combiners2  *)
	CombinerStageParameterfvNV- : TglCombinerStageParameterfvNV;
	GetCombinerStageParameterfvNV- : TglGetCombinerStageParameterfvNV;
	(*  GL_NV_vertex_array_range  *)
	FlushVertexArrayRangeNV- : TglFlushVertexArrayRangeNV;
	VertexArrayRangeNV- : TglVertexArrayRangeNV;
	(*  GL_NV_vertex_program  *)
	AreProgramsResidentNV- : TglAreProgramsResidentNV;
	BindProgramNV- : TglBindProgramNV;
	DeleteProgramsNV- : TglDeleteProgramsNV;
	ExecuteProgramNV- : TglExecuteProgramNV;
	GenProgramsNV- : TglGenProgramsNV;
	GetProgramParameterdvNV- : TglGetProgramParameterdvNV;
	GetProgramParameterfvNV- : TglGetProgramParameterfvNV;
	GetProgramivNV- : TglGetProgramivNV;
	GetProgramStringNV- : TglGetProgramStringNV;
	GetTrackMatrixivNV- : TglGetTrackMatrixivNV;
	GetVertexAttribdvNV- : TglGetVertexAttribdvNV;
	GetVertexAttribfvNV- : TglGetVertexAttribfvNV;
	GetVertexAttribivNV- : TglGetVertexAttribivNV;
	GetVertexAttribPointervNV- : TglGetVertexAttribPointervNV;
	IsProgramNV- : TglIsProgramNV;
	LoadProgramNV- : TglLoadProgramNV;
	ProgramParameter4dNV- : TglProgramParameter4dNV;
	ProgramParameter4dvNV- : TglProgramParameter4dvNV;
	ProgramParameter4fNV- : TglProgramParameter4fNV;
	ProgramParameter4fvNV- : TglProgramParameter4fvNV;
	ProgramParameters4dvNV- : TglProgramParameters4dvNV;
	ProgramParameters4fvNV- : TglProgramParameters4fvNV;
	RequestResidentProgramsNV- : TglRequestResidentProgramsNV;
	TrackMatrixNV- : TglTrackMatrixNV;
	VertexAttribPointerNV- : TglVertexAttribPointerNV;
	VertexAttrib1dNV- : TglVertexAttrib1dNV;
	VertexAttrib1dvNV- : TglVertexAttrib1dvNV;
	VertexAttrib1fNV- : TglVertexAttrib1fNV;
	VertexAttrib1fvNV- : TglVertexAttrib1fvNV;
	VertexAttrib1sNV- : TglVertexAttrib1sNV;
	VertexAttrib1svNV- : TglVertexAttrib1svNV;
	VertexAttrib2dNV- : TglVertexAttrib2dNV;
	VertexAttrib2dvNV- : TglVertexAttrib2dvNV;
	VertexAttrib2fNV- : TglVertexAttrib2fNV;
	VertexAttrib2fvNV- : TglVertexAttrib2fvNV;
	VertexAttrib2sNV- : TglVertexAttrib2sNV;
	VertexAttrib2svNV- : TglVertexAttrib2svNV;
	VertexAttrib3dNV- : TglVertexAttrib3dNV;
	VertexAttrib3dvNV- : TglVertexAttrib3dvNV;
	VertexAttrib3fNV- : TglVertexAttrib3fNV;
	VertexAttrib3fvNV- : TglVertexAttrib3fvNV;
	VertexAttrib3sNV- : TglVertexAttrib3sNV;
	VertexAttrib3svNV- : TglVertexAttrib3svNV;
	VertexAttrib4dNV- : TglVertexAttrib4dNV;
	VertexAttrib4dvNV- : TglVertexAttrib4dvNV;
	VertexAttrib4fNV- : TglVertexAttrib4fNV;
	VertexAttrib4fvNV- : TglVertexAttrib4fvNV;
	VertexAttrib4sNV- : TglVertexAttrib4sNV;
	VertexAttrib4svNV- : TglVertexAttrib4svNV;
	VertexAttrib4ubNV- : TglVertexAttrib4ubNV;
	VertexAttrib4ubvNV- : TglVertexAttrib4ubvNV;
	VertexAttribs1dvNV- : TglVertexAttribs1dvNV;
	VertexAttribs1fvNV- : TglVertexAttribs1fvNV;
	VertexAttribs1svNV- : TglVertexAttribs1svNV;
	VertexAttribs2dvNV- : TglVertexAttribs2dvNV;
	VertexAttribs2fvNV- : TglVertexAttribs2fvNV;
	VertexAttribs2svNV- : TglVertexAttribs2svNV;
	VertexAttribs3dvNV- : TglVertexAttribs3dvNV;
	VertexAttribs3fvNV- : TglVertexAttribs3fvNV;
	VertexAttribs3svNV- : TglVertexAttribs3svNV;
	VertexAttribs4dvNV- : TglVertexAttribs4dvNV;
	VertexAttribs4fvNV- : TglVertexAttribs4fvNV;
	VertexAttribs4svNV- : TglVertexAttribs4svNV;
	VertexAttribs4ubvNV- : TglVertexAttribs4ubvNV;
	(*  GL_NV_depth_buffer_float  *)
	DepthRangedNV- : TglDepthRangedNV;
	ClearDepthdNV- : TglClearDepthdNV;
	DepthBoundsdNV- : TglDepthBoundsdNV;
	(*  GL_NV_framebuffer_multisample_coverage  *)
	RenderbufferStorageMultsampleCoverageNV- : TglRenderbufferStorageMultsampleCoverageNV;
	(*  GL_NV_geometry_program4  *)
	ProgramVertexLimitNV- : TglProgramVertexLimitNV;
	(*  GL_NV_gpu_program4  *)
	ProgramLocalParameterI4iNV- : TglProgramLocalParameterI4iNV;
	ProgramLocalParameterI4ivNV- : TglProgramLocalParameterI4ivNV;
	ProgramLocalParametersI4ivNV- : TglProgramLocalParametersI4ivNV;
	ProgramLocalParameterI4uiNV- : TglProgramLocalParameterI4uiNV;
	ProgramLocalParameterI4uivNV- : TglProgramLocalParameterI4uivNV;
	ProgramLocalParametersI4uivNV- : TglProgramLocalParametersI4uivNV;
	ProgramEnvParameterI4iNV- : TglProgramEnvParameterI4iNV;
	ProgramEnvParameterI4ivNV- : TglProgramEnvParameterI4ivNV;
	ProgramEnvParametersI4ivNV- : TglProgramEnvParametersI4ivNV;
	ProgramEnvParameterI4uiNV- : TglProgramEnvParameterI4uiNV;
	ProgramEnvParameterI4uivNV- : TglProgramEnvParameterI4uivNV;
	ProgramEnvParametersI4uivNV- : TglProgramEnvParametersI4uivNV;
	GetProgramLocalParameterIivNV- : TglGetProgramLocalParameterIivNV;
	GetProgramLocalParameterIuivNV- : TglGetProgramLocalParameterIuivNV;
	GetProgramEnvParameterIivNV- : TglGetProgramEnvParameterIivNV;
	GetProgramEnvParameterIuivNV- : TglGetProgramEnvParameterIuivNV;
	(*  GL_NV_parameter_buffer_object  *)
	ProgramBufferParametersfvNV- : TglProgramBufferParametersfvNV;
	ProgramBufferParametersIivNV- : TglProgramBufferParametersIivNV;
	ProgramBufferParametersIuivNV- : TglProgramBufferParametersIuivNV;
	(*  GL_NV_transform_feedback  *)
	BeginTransformFeedbackNV- : TglBeginTransformFeedbackNV;
	EndTransformFeedbackNV- : TglEndTransformFeedbackNV;
	TransformFeedbackAttribsNV- : TglTransformFeedbackAttribsNV;
	BindBufferRangeNV- : TglBindBufferRangeNV;
	BindBufferOffsetNV- : TglBindBufferOffsetNV;
	BindBufferBaseNV- : TglBindBufferBaseNV;
	TransformFeedbackVaryingsNV- : TglTransformFeedbackVaryingsNV;
	ActiveVaryingNV- : TglActiveVaryingNV;
	GetVaryingLocationNV- : TglGetVaryingLocationNV;
	GetActiveVaryingNV- : TglGetActiveVaryingNV;
	GetTransformFeedbackVaryingNV- : TglGetTransformFeedbackVaryingNV;
	TransformFeedbackStreamAttribsNV- : TglTransformFeedbackStreamAttribsNV;
	(*  GL_NV_conditional_render  *)
	BeginConditionalRenderNV- : TglBeginConditionalRenderNV;
	EndConditionalRenderNV- : TglEndConditionalRenderNV;
	(* GL_NV_conservative_raster *)
	SubpixelPrecisionBiasNV- : TglSubpixelPrecisionBiasNV;
	(* GL_NV_conservative_raster_dilate *)
	ConservativeRasterParameterfNV- : TglConservativeRasterParameterfNV;
	(*  GL_NV_present_video  *)
	PresentFrameKeyedNV- : TglPresentFrameKeyedNV;
	PresentFrameDualFillNV- : TglPresentFrameDualFillNV;
	GetVideoivNV- : TglGetVideoivNV;
	GetVideouivNV- : TglGetVideouivNV;
	GetVideoi64vNV- : TglGetVideoi64vNV;
	GetVideoui64vNV- : TglGetVideoui64vNV;
	(*   glVideoParameterivNV- : TglVideoParameterivNV; *)
	(*  GL_NV_explicit_multisample  *)
	GetMultisamplefvNV- : TglGetMultisamplefvNV;
	SampleMaskIndexedNV- : TglSampleMaskIndexedNV;
	TexRenderbufferNV- : TglTexRenderbufferNV;
	(*  GL_NV_transform_feedback2  *)
	BindTransformFeedbackNV- : TglBindTransformFeedbackNV;
	DeleteTransformFeedbacksNV- : TglDeleteTransformFeedbacksNV;
	GenTransformFeedbacksNV- : TglGenTransformFeedbacksNV;
	IsTransformFeedbackNV- : TglIsTransformFeedbackNV;
	PauseTransformFeedbackNV- : TglPauseTransformFeedbackNV;
	ResumeTransformFeedbackNV- : TglResumeTransformFeedbackNV;
	DrawTransformFeedbackNV- : TglDrawTransformFeedbackNV;
	(*  GL_NV_video_capture  *)
	BeginVideoCaptureNV- : TglBeginVideoCaptureNV;
	BindVideoCaptureStreamBufferNV- : TglBindVideoCaptureStreamBufferNV;
	BindVideoCaptureStreamTextureNV- : TglBindVideoCaptureStreamTextureNV;
	EndVideoCaptureNV- : TglEndVideoCaptureNV;
	GetVideoCaptureivNV- : TglGetVideoCaptureivNV;
	GetVideoCaptureStreamivNV- : TglGetVideoCaptureStreamivNV;
	GetVideoCaptureStreamfvNV- : TglGetVideoCaptureStreamfvNV;
	GetVideoCaptureStreamdvNV- : TglGetVideoCaptureStreamdvNV;
	VideoCaptureNV- : TglVideoCaptureNV;
	VideoCaptureStreamParameterivNV- : TglVideoCaptureStreamParameterivNV;
	VideoCaptureStreamParameterfvNV- : TglVideoCaptureStreamParameterfvNV;
	VideoCaptureStreamParameterdvNV- : TglVideoCaptureStreamParameterdvNV;
	(*  GL_NV_copy_image  *)
	CopyImageSubDataNV- : TglCopyImageSubDataNV;
	(*  GL_NV_shader_buffer_load  *)
	MakeBufferResidentNV- : TglMakeBufferResidentNV;
	MakeBufferNonResidentNV- : TglMakeBufferNonResidentNV;
	IsBufferResidentNV- : TglIsBufferResidentNV;
	MakeNamedBufferResidentNV- : TglMakeNamedBufferResidentNV;
	MakeNamedBufferNonResidentNV- : TglMakeNamedBufferNonResidentNV;
	IsNamedBufferResidentNV- : TglIsNamedBufferResidentNV;
	GetBufferParameterui64vNV- : TglGetBufferParameterui64vNV;
	GetNamedBufferParameterui64vNV- : TglGetNamedBufferParameterui64vNV;
	GetIntegerui64vNV- : TglGetIntegerui64vNV;
	Uniformui64NV- : TglUniformui64NV;
	Uniformui64vNV- : TglUniformui64vNV;
	GetUniformui64vNV- : TglGetUniformui64vNV;
	ProgramUniformui64NV- : TglProgramUniformui64NV;
	ProgramUniformui64vNV- : TglProgramUniformui64vNV;
	(*  GL_NV_vertex_buffer_unified_memory  *)
	BufferAddressRangeNV- : TglBufferAddressRangeNV;
	VertexFormatNV- : TglVertexFormatNV;
	NormalFormatNV- : TglNormalFormatNV;
	ColorFormatNV- : TglColorFormatNV;
	IndexFormatNV- : TglIndexFormatNV;
	TexCoordFormatNV- : TglTexCoordFormatNV;
	EdgeFlagFormatNV- : TglEdgeFlagFormatNV;
	SecondaryColorFormatNV- : TglSecondaryColorFormatNV;
	FogCoordFormatNV- : TglFogCoordFormatNV;
	VertexAttribFormatNV- : TglVertexAttribFormatNV;
	VertexAttribIFormatNV- : TglVertexAttribIFormatNV;
	GetIntegerui64i_vNV- : TglGetIntegerui64i_vNV;
	(*  GL_NV_gpu_program5  *)
	ProgramSubroutineParametersuivNV- : TglProgramSubroutineParametersuivNV;
	GetProgramSubroutineParameteruivNV- : TglGetProgramSubroutineParameteruivNV;
	(*  GL_NV_gpu_shader5  *)
	Uniform1i64NV- : TglUniform1i64NV;
	Uniform2i64NV- : TglUniform2i64NV;
	Uniform3i64NV- : TglUniform3i64NV;
	Uniform4i64NV- : TglUniform4i64NV;
	Uniform1i64vNV- : TglUniform1i64vNV;
	Uniform2i64vNV- : TglUniform2i64vNV;
	Uniform3i64vNV- : TglUniform3i64vNV;
	Uniform4i64vNV- : TglUniform4i64vNV;
	Uniform1ui64NV- : TglUniform1ui64NV;
	Uniform2ui64NV- : TglUniform2ui64NV;
	Uniform3ui64NV- : TglUniform3ui64NV;
	Uniform4ui64NV- : TglUniform4ui64NV;
	Uniform1ui64vNV- : TglUniform1ui64vNV;
	Uniform2ui64vNV- : TglUniform2ui64vNV;
	Uniform3ui64vNV- : TglUniform3ui64vNV;
	Uniform4ui64vNV- : TglUniform4ui64vNV;
	GetUniformi64vNV- : TglGetUniformi64vNV;
	ProgramUniform1i64NV- : TglProgramUniform1i64NV;
	ProgramUniform2i64NV- : TglProgramUniform2i64NV;
	ProgramUniform3i64NV- : TglProgramUniform3i64NV;
	ProgramUniform4i64NV- : TglProgramUniform4i64NV;
	ProgramUniform1i64vNV- : TglProgramUniform1i64vNV;
	ProgramUniform2i64vNV- : TglProgramUniform2i64vNV;
	ProgramUniform3i64vNV- : TglProgramUniform3i64vNV;
	ProgramUniform4i64vNV- : TglProgramUniform4i64vNV;
	ProgramUniform1ui64NV- : TglProgramUniform1ui64NV;
	ProgramUniform2ui64NV- : TglProgramUniform2ui64NV;
	ProgramUniform3ui64NV- : TglProgramUniform3ui64NV;
	ProgramUniform4ui64NV- : TglProgramUniform4ui64NV;
	ProgramUniform1ui64vNV- : TglProgramUniform1ui64vNV;
	ProgramUniform2ui64vNV- : TglProgramUniform2ui64vNV;
	ProgramUniform3ui64vNV- : TglProgramUniform3ui64vNV;
	ProgramUniform4ui64vNV- : TglProgramUniform4ui64vNV;
	(*  GL_NV_vertex_attrib_integer_64bit  *)
	VertexAttribL1i64NV- : TglVertexAttribL1i64NV;
	VertexAttribL2i64NV- : TglVertexAttribL2i64NV;
	VertexAttribL3i64NV- : TglVertexAttribL3i64NV;
	VertexAttribL4i64NV- : TglVertexAttribL4i64NV;
	VertexAttribL1i64vNV- : TglVertexAttribL1i64vNV;
	VertexAttribL2i64vNV- : TglVertexAttribL2i64vNV;
	VertexAttribL3i64vNV- : TglVertexAttribL3i64vNV;
	VertexAttribL4i64vNV- : TglVertexAttribL4i64vNV;
	VertexAttribL1ui64NV- : TglVertexAttribL1ui64NV;
	VertexAttribL2ui64NV- : TglVertexAttribL2ui64NV;
	VertexAttribL3ui64NV- : TglVertexAttribL3ui64NV;
	VertexAttribL4ui64NV- : TglVertexAttribL4ui64NV;
	VertexAttribL1ui64vNV- : TglVertexAttribL1ui64vNV;
	VertexAttribL2ui64vNV- : TglVertexAttribL2ui64vNV;
	VertexAttribL3ui64vNV- : TglVertexAttribL3ui64vNV;
	VertexAttribL4ui64vNV- : TglVertexAttribL4ui64vNV;
	GetVertexAttribLi64vNV- : TglGetVertexAttribLi64vNV;
	GetVertexAttribLui64vNV- : TglGetVertexAttribLui64vNV;
	VertexAttribLFormatNV- : TglVertexAttribLFormatNV;
	(*  GL_NV_vdpau_interop  *)
	VDPAUInitNV- : TglVDPAUInitNV;
	VDPAUFiniNV- : TglVDPAUFiniNV;
	VDPAURegisterVideoSurfaceNV- : TglVDPAURegisterVideoSurfaceNV;
	VDPAURegisterOutputSurfaceNV- : TglVDPAURegisterOutputSurfaceNV;
	VDPAUIsSurfaceNV- : TglVDPAUIsSurfaceNV;
	VDPAUUnregisterSurfaceNV- : TglVDPAUUnregisterSurfaceNV;
	VDPAUGetSurfaceivNV- : TglVDPAUGetSurfaceivNV;
	VDPAUSurfaceAccessNV- : TglVDPAUSurfaceAccessNV;
	VDPAUMapSurfacesNV- : TglVDPAUMapSurfacesNV;
	VDPAUUnmapSurfacesNV- : TglVDPAUUnmapSurfacesNV;
	(*  GL_NV_texture_barrier  *)
	TextureBarrierNV- : TglTextureBarrierNV;
	(* (4.3) GL_NV_path_rendering  *)
	GenPathsNV- : TglGenPathsNV;
	DeletePathsNV- : TglDeletePathsNV;
	IsPathNV- : TglIsPathNV;
	PathCommandsNV- : TglPathCommandsNV;
	PathCoordsNV- : TglPathCoordsNV;
	PathSubCommandsNV- : TglPathSubCommandsNV;
	PathSubCoordsNV- : TglPathSubCoordsNV;
	PathStringNV- : TglPathStringNV;
	PathGlyphsNV- : TglPathGlyphsNV;
	PathGlyphRangeNV- : TglPathGlyphRangeNV;
	WeightPathsNV- : TglWeightPathsNV;
	CopyPathNV- : TglCopyPathNV;
	InterpolatePathsNV- : TglInterpolatePathsNV;
	TransformPathNV- : TglTransformPathNV;
	PathParameterivNV- : TglPathParameterivNV;
	PathParameteriNV- : TglPathParameteriNV;
	PathParameterfvNV- : TglPathParameterfvNV;
	PathParameterfNV- : TglPathParameterfNV;
	PathDashArrayNV- : TglPathDashArrayNV;
	PathStencilFuncNV- : TglPathStencilFuncNV;
	PathStencilDepthOffsetNV- : TglPathStencilDepthOffsetNV;
	StencilFillPathNV- : TglStencilFillPathNV;
	StencilStrokePathNV- : TglStencilStrokePathNV;
	StencilFillPathInstancedNV- : TglStencilFillPathInstancedNV;
	StencilStrokePathInstancedNV- : TglStencilStrokePathInstancedNV;
	PathCoverDepthFuncNV- : TglPathCoverDepthFuncNV;
	PathColorGenNV- : TglPathColorGenNV;
	PathTexGenNV- : TglPathTexGenNV;
	PathFogGenNV- : TglPathFogGenNV;
	CoverFillPathNV- : TglCoverFillPathNV;
	CoverStrokePathNV- : TglCoverStrokePathNV;
	CoverFillPathInstancedNV- : TglCoverFillPathInstancedNV;
	CoverStrokePathInstancedNV- : TglCoverStrokePathInstancedNV;
	GetPathParameterivNV- : TglGetPathParameterivNV;
	GetPathParameterfvNV- : TglGetPathParameterfvNV;
	GetPathCommandsNV- : TglGetPathCommandsNV;
	GetPathCoordsNV- : TglGetPathCoordsNV;
	GetPathDashArrayNV- : TglGetPathDashArrayNV;
	GetPathMetricsNV- : TglGetPathMetricsNV;
	GetPathMetricRangeNV- : TglGetPathMetricRangeNV;
	GetPathSpacingNV- : TglGetPathSpacingNV;
	GetPathColorGenivNV- : TglGetPathColorGenivNV;
	GetPathColorGenfvNV- : TglGetPathColorGenfvNV;
	GetPathTexGenivNV- : TglGetPathTexGenivNV;
	GetPathTexGenfvNV- : TglGetPathTexGenfvNV;
	IsPointInFillPathNV- : TglIsPointInFillPathNV;
	IsPointInStrokePathNV- : TglIsPointInStrokePathNV;
	GetPathLengthNV- : TglGetPathLengthNV;
	PointAlongPathNV- : TglPointAlongPathNV;
	(* GL_AMD_pinned_memory  *)
	(* GL_AMD_stencil_operation_extended *)
	StencilOpValueAMD- : TglStencilOpValueAMD;
	(* GL_AMD_vertex_shader_viewport_index  *)
	(* GL_AMD_vertex_shader_layer  *)
	(* GL_NV_bindless_texture  *)
	GetTextureHandleNV- : TglGetTextureHandleNV;
	GetTextureSamplerHandleNV- : TglGetTextureSamplerHandleNV;
	MakeTextureHandleResidentNV- : TglMakeTextureHandleResidentNV;
	MakeTextureHandleNonResidentNV- : TglMakeTextureHandleNonResidentNV;
	GetImageHandleNV- : TglGetImageHandleNV;
	MakeImageHandleResidentNV- : TglMakeImageHandleResidentNV;
	MakeImageHandleNonResidentNV- : TglMakeImageHandleNonResidentNV;
	UniformHandleui64NV- : TglUniformHandleui64NV;
	UniformHandleui64vNV- : TglUniformHandleui64vNV;
	ProgramUniformHandleui64NV- : TglProgramUniformHandleui64NV;
	ProgramUniformHandleui64vNV- : TglProgramUniformHandleui64vNV;
	IsTextureHandleResidentNV- : TglIsTextureHandleResidentNV;
	IsImageHandleResidentNV- : TglIsImageHandleResidentNV;

	(* GL_ARB_bindless_texture *)
	GetTextureHandleARB- : TglGetTextureHandleARB;
	GetTextureSamplerHandleARB- : TglGetTextureSamplerHandleARB;
	MakeTextureHandleResidentARB- : TglMakeTextureHandleResidentARB;
	MakeTextureHandleNonResidentARB- : TglMakeTextureHandleNonResidentARB;
	GetImageHandleARB- : TglGetImageHandleARB;
	MakeImageHandleResidentARB- : TglMakeImageHandleResidentARB;
	MakeImageHandleNonResidentARB- : TglMakeImageHandleNonResidentARB;
	UniformHandleui64ARB- : TglUniformHandleui64ARB;
	UniformHandleui64vARB- : TglUniformHandleui64vARB;
	ProgramUniformHandleui64ARB- : TglProgramUniformHandleui64ARB;
	ProgramUniformHandleui64vARB- : TglProgramUniformHandleui64vARB;
	IsTextureHandleResidentARB- : TglIsTextureHandleResidentARB;
	IsImageHandleResidentARB- : TglIsImageHandleResidentARB;
	VertexAttribL1ui64ARB- : TglVertexAttribL1ui64ARB;
	VertexAttribL1ui64vARB- : TglVertexAttribL1ui64vARB;
	GetVertexAttribLui64vARB- : TglGetVertexAttribLui64vARB;

	(* GL_OVR_multiview *)
	FramebufferTextureMultiviewOVR- : TglFramebufferTextureMultiviewOVR;

	(*  GL_PGI_misc_hints  *)
	HintPGI- : TglHintPGI;
	(*  GL_SGIS_detail_texture  *)
	DetailTexFuncSGIS- : TglDetailTexFuncSGIS;
	GetDetailTexFuncSGIS- : TglGetDetailTexFuncSGIS;
	(*  GL_SGIS_fog_function  *)
	FogFuncSGIS- : TglFogFuncSGIS;
	GetFogFuncSGIS- : TglGetFogFuncSGIS;
	(*  GL_SGIS_multisample  *)
	SampleMaskSGIS- : TglSampleMaskSGIS;
	SamplePatternSGIS- : TglSamplePatternSGIS;
	(*  GL_SGIS_pixel_texture  *)
	PixelTexGenParameteriSGIS- : TglPixelTexGenParameteriSGIS;
	PixelTexGenParameterivSGIS- : TglPixelTexGenParameterivSGIS;
	PixelTexGenParameterfSGIS- : TglPixelTexGenParameterfSGIS;
	PixelTexGenParameterfvSGIS- : TglPixelTexGenParameterfvSGIS;
	GetPixelTexGenParameterivSGIS- : TglGetPixelTexGenParameterivSGIS;
	GetPixelTexGenParameterfvSGIS- : TglGetPixelTexGenParameterfvSGIS;
	(*  GL_SGIS_point_parameters  *)
	PointParameterfSGIS- : TglPointParameterfSGIS;
	PointParameterfvSGIS- : TglPointParameterfvSGIS;
	(*  GL_SGIS_sharpen_texture  *)
	SharpenTexFuncSGIS- : TglSharpenTexFuncSGIS;
	GetSharpenTexFuncSGIS- : TglGetSharpenTexFuncSGIS;
	(*  GL_SGIS_texture4D  *)
	TexImage4DSGIS- : TglTexImage4DSGIS;
	TexSubImage4DSGIS- : TglTexSubImage4DSGIS;
	(*  GL_SGIS_texture_color_mask  *)
	TextureColorMaskSGIS- : TglTextureColorMaskSGIS;
	(*  GL_SGIS_texture_filter4  *)
	GetTexFilterFuncSGIS- : TglGetTexFilterFuncSGIS;
	TexFilterFuncSGIS- : TglTexFilterFuncSGIS;
	(*  GL_SGIX_async  *)
	AsyncMarkerSGIX- : TglAsyncMarkerSGIX;
	FinishAsyncSGIX- : TglFinishAsyncSGIX;
	PollAsyncSGIX- : TglPollAsyncSGIX;
	GenAsyncMarkersSGIX- : TglGenAsyncMarkersSGIX;
	DeleteAsyncMarkersSGIX- : TglDeleteAsyncMarkersSGIX;
	IsAsyncMarkerSGIX- : TglIsAsyncMarkerSGIX;
	(*  GL_SGIX_flush_raster  *)
	FlushRasterSGIX- : TglFlushRasterSGIX;
	(*  GL_SGIX_fragment_lighting  *)
	FragmentColorMaterialSGIX- : TglFragmentColorMaterialSGIX;
	FragmentLightfSGIX- : TglFragmentLightfSGIX;
	FragmentLightfvSGIX- : TglFragmentLightfvSGIX;
	FragmentLightiSGIX- : TglFragmentLightiSGIX;
	FragmentLightivSGIX- : TglFragmentLightivSGIX;
	FragmentLightModelfSGIX- : TglFragmentLightModelfSGIX;
	FragmentLightModelfvSGIX- : TglFragmentLightModelfvSGIX;
	FragmentLightModeliSGIX- : TglFragmentLightModeliSGIX;
	FragmentLightModelivSGIX- : TglFragmentLightModelivSGIX;
	FragmentMaterialfSGIX- : TglFragmentMaterialfSGIX;
	FragmentMaterialfvSGIX- : TglFragmentMaterialfvSGIX;
	FragmentMaterialiSGIX- : TglFragmentMaterialiSGIX;
	FragmentMaterialivSGIX- : TglFragmentMaterialivSGIX;
	GetFragmentLightfvSGIX- : TglGetFragmentLightfvSGIX;
	GetFragmentLightivSGIX- : TglGetFragmentLightivSGIX;
	GetFragmentMaterialfvSGIX- : TglGetFragmentMaterialfvSGIX;
	GetFragmentMaterialivSGIX- : TglGetFragmentMaterialivSGIX;
	LightEnviSGIX- : TglLightEnviSGIX;
	(*  GL_SGIX_framezoom  *)
	FrameZoomSGIX- : TglFrameZoomSGIX;
	(*  GL_SGIX_igloo_interface  *)
	IglooInterfaceSGIX- : TglIglooInterfaceSGIX;
	(*  GL_SGIX_instruments  *)
	GetInstrumentsSGIX- : TglGetInstrumentsSGIX;
	InstrumentsBufferSGIX- : TglInstrumentsBufferSGIX;
	PollInstrumentsSGIX- : TglPollInstrumentsSGIX;
	ReadInstrumentsSGIX- : TglReadInstrumentsSGIX;
	StartInstrumentsSGIX- : TglStartInstrumentsSGIX;
	StopInstrumentsSGIX- : TglStopInstrumentsSGIX;
	(*  GL_SGIX_list_priority  *)
	GetListParameterfvSGIX- : TglGetListParameterfvSGIX;
	GetListParameterivSGIX- : TglGetListParameterivSGIX;
	ListParameterfSGIX- : TglListParameterfSGIX;
	ListParameterfvSGIX- : TglListParameterfvSGIX;
	ListParameteriSGIX- : TglListParameteriSGIX;
	ListParameterivSGIX- : TglListParameterivSGIX;
	(*  GL_SGIX_pixel_texture  *)
	PixelTexGenSGIX- : TglPixelTexGenSGIX;
	(*  GL_SGIX_polynomial_ffd  *)
	DeformationMap3dSGIX- : TglDeformationMap3dSGIX;
	DeformationMap3fSGIX- : TglDeformationMap3fSGIX;
	DeformSGIX- : TglDeformSGIX;
	LoadIdentityDeformationMapSGIX- : TglLoadIdentityDeformationMapSGIX;
	(*  GL_SGIX_reference_plane  *)
	ReferencePlaneSGIX- : TglReferencePlaneSGIX;
	(*  GL_SGIX_sprite  *)
	SpriteParameterfSGIX- : TglSpriteParameterfSGIX;
	SpriteParameterfvSGIX- : TglSpriteParameterfvSGIX;
	SpriteParameteriSGIX- : TglSpriteParameteriSGIX;
	SpriteParameterivSGIX- : TglSpriteParameterivSGIX;
	(*  GL_SGIX_tag_sample_buffer  *)
	TagSampleBufferSGIX- : TglTagSampleBufferSGIX;
	(*  GL_SGI_color_table  *)
	ColorTableSGI- : TglColorTableSGI;
	ColorTableParameterfvSGI- : TglColorTableParameterfvSGI;
	ColorTableParameterivSGI- : TglColorTableParameterivSGI;
	CopyColorTableSGI- : TglCopyColorTableSGI;
	GetColorTableSGI- : TglGetColorTableSGI;
	GetColorTableParameterfvSGI- : TglGetColorTableParameterfvSGI;
	GetColorTableParameterivSGI- : TglGetColorTableParameterivSGI;
	(*  GL_SUNX_constant_data  *)
	FinishTextureSUNX- : TglFinishTextureSUNX;
	(*  GL_SUN_global_alpha  *)
	GlobalAlphaFactorbSUN- : TglGlobalAlphaFactorbSUN;
	GlobalAlphaFactorsSUN- : TglGlobalAlphaFactorsSUN;
	GlobalAlphaFactoriSUN- : TglGlobalAlphaFactoriSUN;
	GlobalAlphaFactorfSUN- : TglGlobalAlphaFactorfSUN;
	GlobalAlphaFactordSUN- : TglGlobalAlphaFactordSUN;
	GlobalAlphaFactorubSUN- : TglGlobalAlphaFactorubSUN;
	GlobalAlphaFactorusSUN- : TglGlobalAlphaFactorusSUN;
	GlobalAlphaFactoruiSUN- : TglGlobalAlphaFactoruiSUN;
	(*  GL_SUN_mesh_array  *)
	DrawMeshArraysSUN- : TglDrawMeshArraysSUN;
	(*  GL_SUN_triangle_list  *)
	ReplacementCodeuiSUN- : TglReplacementCodeuiSUN;
	ReplacementCodeusSUN- : TglReplacementCodeusSUN;
	ReplacementCodeubSUN- : TglReplacementCodeubSUN;
	ReplacementCodeuivSUN- : TglReplacementCodeuivSUN;
	ReplacementCodeusvSUN- : TglReplacementCodeusvSUN;
	ReplacementCodeubvSUN- : TglReplacementCodeubvSUN;
	ReplacementCodePointerSUN- : TglReplacementCodePointerSUN;
	(*  GL_SUN_vertex  *)
	Color4ubVertex2fSUN- : TglColor4ubVertex2fSUN;
	Color4ubVertex2fvSUN- : TglColor4ubVertex2fvSUN;
	Color4ubVertex3fSUN- : TglColor4ubVertex3fSUN;
	Color4ubVertex3fvSUN- : TglColor4ubVertex3fvSUN;
	Color3fVertex3fSUN- : TglColor3fVertex3fSUN;
	Color3fVertex3fvSUN- : TglColor3fVertex3fvSUN;
	Normal3fVertex3fSUN- : TglNormal3fVertex3fSUN;
	Normal3fVertex3fvSUN- : TglNormal3fVertex3fvSUN;
	Color4fNormal3fVertex3fSUN- : TglColor4fNormal3fVertex3fSUN;
	Color4fNormal3fVertex3fvSUN- : TglColor4fNormal3fVertex3fvSUN;
	TexCoord2fVertex3fSUN- : TglTexCoord2fVertex3fSUN;
	TexCoord2fVertex3fvSUN- : TglTexCoord2fVertex3fvSUN;
	TexCoord4fVertex4fSUN- : TglTexCoord4fVertex4fSUN;
	TexCoord4fVertex4fvSUN- : TglTexCoord4fVertex4fvSUN;
	TexCoord2fColor4ubVertex3fSUN- : TglTexCoord2fColor4ubVertex3fSUN;
	TexCoord2fColor4ubVertex3fvSUN- : TglTexCoord2fColor4ubVertex3fvSUN;
	TexCoord2fColor3fVertex3fSUN- : TglTexCoord2fColor3fVertex3fSUN;
	TexCoord2fColor3fVertex3fvSUN- : TglTexCoord2fColor3fVertex3fvSUN;
	TexCoord2fNormal3fVertex3fSUN- : TglTexCoord2fNormal3fVertex3fSUN;
	TexCoord2fNormal3fVertex3fvSUN- : TglTexCoord2fNormal3fVertex3fvSUN;
	TexCoord2fColor4fNormal3fVertex3fSUN- : TglTexCoord2fColor4fNormal3fVertex3fSUN;
	TexCoord2fColor4fNormal3fVertex3fvSUN- : TglTexCoord2fColor4fNormal3fVertex3fvSUN;
	TexCoord4fColor4fNormal3fVertex4fSUN- : TglTexCoord4fColor4fNormal3fVertex4fSUN;
	TexCoord4fColor4fNormal3fVertex4fvSUN- : TglTexCoord4fColor4fNormal3fVertex4fvSUN;
	ReplacementCodeuiVertex3fSUN- : TglReplacementCodeuiVertex3fSUN;
	ReplacementCodeuiVertex3fvSUN- : TglReplacementCodeuiVertex3fvSUN;
	ReplacementCodeuiColor4ubVertex3fSUN- : TglReplacementCodeuiColor4ubVertex3fSUN;
	ReplacementCodeuiColor4ubVertex3fvSUN- : TglReplacementCodeuiColor4ubVertex3fvSUN;
	ReplacementCodeuiColor3fVertex3fSUN- : TglReplacementCodeuiColor3fVertex3fSUN;
	ReplacementCodeuiColor3fVertex3fvSUN- : TglReplacementCodeuiColor3fVertex3fvSUN;
	ReplacementCodeuiNormal3fVertex3fSUN- : TglReplacementCodeuiNormal3fVertex3fSUN;
	ReplacementCodeuiNormal3fVertex3fvSUN- : TglReplacementCodeuiNormal3fVertex3fvSUN;
	ReplacementCodeuiColor4fNormal3fVertex3fSUN- : TglReplacementCodeuiColor4fNormal3fVertex3fSUN;
	ReplacementCodeuiColor4fNormal3fVertex3fvSUN- : TglReplacementCodeuiColor4fNormal3fVertex3fvSUN;
	ReplacementCodeuiTexCoord2fVertex3fSUN- : TglReplacementCodeuiTexCoord2fVertex3fSUN;
	ReplacementCodeuiTexCoord2fVertex3fvSUN- : TglReplacementCodeuiTexCoord2fVertex3fvSUN;
	ReplacementCodeuiTexCoord2fNormal3fVertex3fSUN- : TglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN;
	ReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN- : TglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN;
	ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN- : TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN;
	ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN- : TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN;


	(* -------------------------------------------------  *)
	(*! WGL_WINDOWS *)
	wglGetProcAddress- : TwglGetProcAddress;
	wglCopyContext- : TwglCopyContext;
	wglCreateContext- : TwglCreateContext;
	wglCreateLayerContext- : TwglCreateLayerContext;
	wglDeleteContext- : TwglDeleteContext;
	wglDescribeLayerPlane- : TwglDescribeLayerPlane;
	wglGetCurrentContext- : TwglGetCurrentContext;
	wglGetCurrentDC- : TwglGetCurrentDC;
	wglGetLayerPaletteEntries- : TwglGetLayerPaletteEntries;
	wglMakeCurrent- : TwglMakeCurrent;
	wglRealizeLayerPalette- : TwglRealizeLayerPalette;
	wglSetLayerPaletteEntries- : TwglSetLayerPaletteEntries;
	wglShareLists- : TwglShareLists;
	wglSwapLayerBuffers- : TwglSwapLayerBuffers;
	wglSwapMultipleBuffers- : TwglSwapMultipleBuffers;
	wglUseFontBitmapsA- : TwglUseFontBitmapsA;
	wglUseFontOutlinesA- : TwglUseFontOutlinesA;
	wglUseFontBitmapsW- : TwglUseFontBitmapsW;
	wglUseFontOutlinesW- : TwglUseFontOutlinesW;
	wglUseFontBitmaps- : TwglUseFontBitmaps;
	wglUseFontOutlines- : TwglUseFontOutlines;

	  (* WGL_ARB_buffer_region *)
	wglCreateBufferRegionARB- : TwglCreateBufferRegionARB;
	wglDeleteBufferRegionARB- : TwglDeleteBufferRegionARB;
	wglSaveBufferRegionARB- : TwglSaveBufferRegionARB;
	wglRestoreBufferRegionARB- : TwglRestoreBufferRegionARB;

	(* WGL_ARB_extensions_string *)
	wglGetExtensionsStringARB- : TwglGetExtensionsStringARB;

	(* WGL_ARB_make_current_read *)
	wglMakeContextCurrentARB- : TwglMakeContextCurrentARB;
	wglGetCurrentReadDCARB- : TwglGetCurrentReadDCARB;

	(* WGL_ARB_pbuffer *)
	wglCreatePbufferARB- : TwglCreatePbufferARB;
	wglGetPbufferDCARB- : TwglGetPbufferDCARB;
	wglReleasePbufferDCARB- : TwglReleasePbufferDCARB;
	wglDestroyPbufferARB- : TwglDestroyPbufferARB;
	wglQueryPbufferARB- : TwglQueryPbufferARB;

	(* WGL_ARB_pixel_format *)
	wglGetPixelFormatAttribivARB- : TwglGetPixelFormatAttribivARB;
	wglGetPixelFormatAttribfvARB- : TwglGetPixelFormatAttribfvARB;
	wglChoosePixelFormatARB- : TwglChoosePixelFormatARB;
	(* WGL_ARB_color_buffer_float *)
	wglClampColorARB- : TwglClampColorARB;

	(* WGL_ARB_render_texture *)
	wglBindTexImageARB- : TwglBindTexImageARB;
	wglReleaseTexImageARB- : TwglReleaseTexImageARB;
	wglSetPbufferAttribARB- : TwglSetPbufferAttribARB;

	(* WGL_ARB_create_context *)
	wglCreateContextAttribsARB- : TwglCreateContextAttribsARB;

	(* WGL_AMD_gpu_association *)
	wglGetGPUIDsAMD- : TwglGetGPUIDsAMD;
	wglGetGPUInfoAMD- : TwglGetGPUInfoAMD;
	wglGetContextGPUIDAMD- : TwglGetContextGPUIDAMD;
	wglCreateAssociatedContextAMD- : TwglCreateAssociatedContextAMD;
	wglCreateAssociatedContextAttribsAMD- : TwglCreateAssociatedContextAttribsAMD;
	wglDeleteAssociatedContextAMD- : TwglDeleteAssociatedContextAMD;
	wglMakeAssociatedContextCurrentAMD- : TwglMakeAssociatedContextCurrentAMD;
	wglGetCurrentAssociatedContextAMD- : TwglGetCurrentAssociatedContextAMD;
	wglBlitContextFramebufferAMD- : TwglBlitContextFramebufferAMD;

	(* WGL_EXT_display_color_table *)
	wglCreateDisplayColorTableEXT- : TwglCreateDisplayColorTableEXT;
	wglLoadDisplayColorTableEXT- : TwglLoadDisplayColorTableEXT;
	wglBindDisplayColorTableEXT- : TwglBindDisplayColorTableEXT;
	wglDestroyDisplayColorTableEXT- : TwglDestroyDisplayColorTableEXT;

	(* WGL_EXT_extensions_string *)
	wglGetExtensionsStringEXT- : TwglGetExtensionsStringEXT;

	(* WGL_EXT_make_current_read *)
	wglMakeContextCurrentEXT- : TwglMakeContextCurrentEXT;
	wglGetCurrentReadDCEXT- : TwglGetCurrentReadDCEXT;

	(* WGL_EXT_pbuffer *)
	wglCreatePbufferEXT- : TwglCreatePbufferEXT;
	wglGetPbufferDCEXT- : TwglGetPbufferDCEXT;
	wglReleasePbufferDCEXT- : TwglReleasePbufferDCEXT;
	wglDestroyPbufferEXT- : TwglDestroyPbufferEXT;
	wglQueryPbufferEXT- : TwglQueryPbufferEXT;

	(* WGL_EXT_pixel_format *)
	wglGetPixelFormatAttribivEXT- : TwglGetPixelFormatAttribivEXT;
	wglGetPixelFormatAttribfvEXT- : TwglGetPixelFormatAttribfvEXT;
	wglChoosePixelFormatEXT- : TwglChoosePixelFormatEXT;

	(* WGL_EXT_swap_control *)
	wglSwapIntervalEXT- : TwglSwapIntervalEXT;
	wglGetSwapIntervalEXT- : TwglGetSwapIntervalEXT;

	(* WGL_I3D_digital_video_control *)
	wglGetDigitalVideoParametersI3D- : TwglGetDigitalVideoParametersI3D;
	wglSetDigitalVideoParametersI3D- : TwglSetDigitalVideoParametersI3D;

	(* WGL_I3D_gamma *)
	wglGetGammaTableParametersI3D- : TwglGetGammaTableParametersI3D;
	wglSetGammaTableParametersI3D- : TwglSetGammaTableParametersI3D;
	wglGetGammaTableI3D- : TwglGetGammaTableI3D;
	wglSetGammaTableI3D- : TwglSetGammaTableI3D;

	(* WGL_I3D_genlock *)
	wglEnableGenlockI3D- : TwglEnableGenlockI3D;
	wglDisableGenlockI3D- : TwglDisableGenlockI3D;
	wglIsEnabledGenlockI3D- : TwglIsEnabledGenlockI3D;
	wglGenlockSourceI3D- : TwglGenlockSourceI3D;
	wglGetGenlockSourceI3D- : TwglGetGenlockSourceI3D;
	wglGenlockSourceEdgeI3D- : TwglGenlockSourceEdgeI3D;
	wglGetGenlockSourceEdgeI3D- : TwglGetGenlockSourceEdgeI3D;
	wglGenlockSampleRateI3D- : TwglGenlockSampleRateI3D;
	wglGetGenlockSampleRateI3D- : TwglGetGenlockSampleRateI3D;
	wglGenlockSourceDelayI3D- : TwglGenlockSourceDelayI3D;
	wglGetGenlockSourceDelayI3D- : TwglGetGenlockSourceDelayI3D;
	wglQueryGenlockMaxSourceDelayI3D- : TwglQueryGenlockMaxSourceDelayI3D;

	(* WGL_I3D_image_buffer *)
	wglCreateImageBufferI3D- : TwglCreateImageBufferI3D;
	wglDestroyImageBufferI3D- : TwglDestroyImageBufferI3D;
	wglAssociateImageBufferEventsI3D- : TwglAssociateImageBufferEventsI3D;
	wglReleaseImageBufferEventsI3D- : TwglReleaseImageBufferEventsI3D;

	(* WGL_I3D_swap_frame_lock *)
	wglEnableFrameLockI3D- : TwglEnableFrameLockI3D;
	wglDisableFrameLockI3D- : TwglDisableFrameLockI3D;
	wglIsEnabledFrameLockI3D- : TwglIsEnabledFrameLockI3D;
	wglQueryFrameLockMasterI3D- : TwglQueryFrameLockMasterI3D;

	(* WGL_I3D_swap_frame_usage *)
	wglGetFrameUsageI3D- : TwglGetFrameUsageI3D;
	wglBeginFrameTrackingI3D- : TwglBeginFrameTrackingI3D;
	wglEndFrameTrackingI3D- : TwglEndFrameTrackingI3D;
	wglQueryFrameTrackingI3D- : TwglQueryFrameTrackingI3D;

	(* WGL_NV_vertex_array_range *)
	wglAllocateMemoryNV- : TwglAllocateMemoryNV;
	wglFreeMemoryNV- : TwglFreeMemoryNV;

	(* WGL_NV_present_video *)
	wglEnumerateVideoDevicesNV- : TwglEnumerateVideoDevicesNV;
	wglBindVideoDeviceNV- : TwglBindVideoDeviceNV;
	wglQueryCurrentContextNV- : TwglQueryCurrentContextNV;

	(* WGL_NV_video_output *)
	wglGetVideoDeviceNV- : TwglGetVideoDeviceNV;
	wglReleaseVideoDeviceNV- : TwglReleaseVideoDeviceNV;
	wglBindVideoImageNV- : TwglBindVideoImageNV;
	wglReleaseVideoImageNV- : TwglReleaseVideoImageNV;
	wglSendPbufferToVideoNV- : TwglSendPbufferToVideoNV;
	wglGetVideoInfoNV- : TwglGetVideoInfoNV;

	(* WGL_NV_swap_group *)
	wglJoinSwapGroupNV- : TwglJoinSwapGroupNV;
	wglBindSwapBarrierNV- : TwglBindSwapBarrierNV;
	wglQuerySwapGroupNV- : TwglQuerySwapGroupNV;
	wglQueryMaxSwapGroupsNV- : TwglQueryMaxSwapGroupsNV;
	wglQueryFrameCountNV- : TwglQueryFrameCountNV;
	wglResetFrameCountNV- : TwglResetFrameCountNV;

	(* WGL_NV_gpu_affinity *)
	wglEnumGpusNV- : TwglEnumGpusNV;
	wglEnumGpuDevicesNV- : TwglEnumGpuDevicesNV;
	wglCreateAffinityDCNV- : TwglCreateAffinityDCNV;
	wglEnumGpusFromAffinityDCNV- : TwglEnumGpusFromAffinityDCNV;
	wglDeleteDCNV- : TwglDeleteDCNV;

	(* WGL_NV_video_capture *)
	wglBindVideoCaptureDeviceNV- : TwglBindVideoCaptureDeviceNV;
	wglEnumerateVideoCaptureDevicesNV- : TwglEnumerateVideoCaptureDevicesNV;
	wglLockVideoCaptureDeviceNV- : TwglLockVideoCaptureDeviceNV;
	wglQueryVideoCaptureDeviceNV- : TwglQueryVideoCaptureDeviceNV;
	wglReleaseVideoCaptureDeviceNV- : TwglReleaseVideoCaptureDeviceNV;

	(* WGL_NV_copy_image *)
	wglCopyImageSubDataNV- : TwglCopyImageSubDataNV;

	(* WGL_NV_DX_interop*)
	wglDXSetResourceShareHandleNV : TwglDXSetResourceShareHandleNV;
	wglDXOpenDeviceNV : TwglDXOpenDeviceNV;
	wglDXCloseDeviceNV : TwglDXCloseDeviceNV;
	wglDXRegisterObjectNV : TwglDXRegisterObjectNV;
	wglDXUnregisterObjectNV : TwglDXUnregisterObjectNV;
	wglDXObjectAccessNV : TwglDXObjectAccessNV;
	wglDXLockObjectsNV : TwglDXLockObjectsNV;
	wglDXUnlockObjectsNV : TwglDXUnlockObjectsNV;

	(* WGL_OML_sync_control *)
	wglGetSyncValuesOML- : TwglGetSyncValuesOML;
	wglGetMscRateOML- : TwglGetMscRateOML;
	wglSwapBuffersMscOML- : TwglSwapBuffersMscOML;
	wglSwapLayerBuffersMscOML- : TwglSwapLayerBuffersMscOML;
	wglWaitForMscOML- : TwglWaitForMscOML;
	wglWaitForSbcOML- : TwglWaitForSbcOML;

	(* WGL_3DL_stereo_control *)
	wglSetStereoEmitterState3DL- : TwglSetStereoEmitterState3DL;

	(* WIN_draw_range_elements *)
	glDrawRangeElementsWIN- : TglDrawRangeElementsWIN;

	(* WIN_swap_hint *)
	glAddSwapHintRectWIN- : TglAddSwapHintRectWIN;
	(*ENDIF *)


(** wrapper procedure *)
PROCEDURE GetProcAddress*(CONST funcName: ARRAY OF CHAR; adr: ADDRESS);
VAR address: ADDRESS;
BEGIN
	Kernel32.GetProcAddress(libHandle, funcName, address);
	IF (address = 0) & (wglGetProcAddress # NIL) THEN
		address := wglGetProcAddress(funcName);
	END;
	SYSTEM.PUT(adr, address);
END GetProcAddress;

(*! --------------------------   *)

PROCEDURE InitOpenGL*;
BEGIN
	libHandle := Kernel32.LoadLibrary(libName);
	ASSERT(libHandle # 0,101);

	(* load GL functions*)
	Kernel32.GetProcAddress(libHandle, 'wglGetProcAddress', SYSTEM.VAL(ADDRESS, wglGetProcAddress));
	Kernel32.GetProcAddress(libHandle, 'wglCopyContext', SYSTEM.VAL(ADDRESS, wglCopyContext ));
	Kernel32.GetProcAddress(libHandle, 'wglCreateLayerContext', SYSTEM.VAL(ADDRESS, wglCreateLayerContext ));
	Kernel32.GetProcAddress(libHandle, 'wglCreateContext', SYSTEM.VAL(ADDRESS, wglCreateContext));
	Kernel32.GetProcAddress(libHandle, 'wglDeleteContext', SYSTEM.VAL(ADDRESS, wglDeleteContext ));
	Kernel32.GetProcAddress(libHandle, 'wglDescribeLayerPlane', SYSTEM.VAL(ADDRESS, wglDescribeLayerPlane ));
	Kernel32.GetProcAddress(libHandle, 'wglGetCurrentContext', SYSTEM.VAL(ADDRESS, wglGetCurrentContext));
	Kernel32.GetProcAddress(libHandle, 'wglGetCurrentDC', SYSTEM.VAL(ADDRESS, wglGetCurrentDC));
	Kernel32.GetProcAddress(libHandle, 'wglGetLayerPaletteEntries', SYSTEM.VAL(ADDRESS, wglGetLayerPaletteEntries));

	Kernel32.GetProcAddress(libHandle, 'wglMakeCurrent', SYSTEM.VAL(ADDRESS, wglMakeCurrent));
	Kernel32.GetProcAddress(libHandle, 'wglRealizeLayerPalette', SYSTEM.VAL(ADDRESS, wglRealizeLayerPalette));
	Kernel32.GetProcAddress(libHandle, 'wglSetLayerPaletteEntries', SYSTEM.VAL(ADDRESS, wglSetLayerPaletteEntries));
	Kernel32.GetProcAddress(libHandle, 'wglShareLists', SYSTEM.VAL(ADDRESS, wglShareLists));
	Kernel32.GetProcAddress(libHandle, 'wglSwapLayerBuffers', SYSTEM.VAL(ADDRESS, wglSwapLayerBuffers));

	Kernel32.GetProcAddress(libHandle, 'wglSwapMultipleBuffers', SYSTEM.VAL(ADDRESS, wglSwapMultipleBuffers));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontBitmapsA', SYSTEM.VAL(ADDRESS, wglUseFontBitmapsA));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontOutlinesA', SYSTEM.VAL(ADDRESS, wglUseFontOutlinesA));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontBitmapsW', SYSTEM.VAL(ADDRESS, wglUseFontBitmapsW));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontOutlinesW', SYSTEM.VAL(ADDRESS, wglUseFontOutlinesW));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontBitmapsA', SYSTEM.VAL(ADDRESS, wglUseFontBitmaps));
	Kernel32.GetProcAddress(libHandle, 'wglUseFontOutlinesA', SYSTEM.VAL(ADDRESS, wglUseFontOutlines));

	(*! GL_VERSION_1_0 *)

	GetProcAddress( 'glCullFace' , ADDRESSOF( CullFace ));
	GetProcAddress( 'glFrontFace' , ADDRESSOF( FrontFace ));
	GetProcAddress( 'glHint' , ADDRESSOF( Hint ));
	GetProcAddress( 'glLineWidth' , ADDRESSOF( LineWidth ));
	GetProcAddress( 'glPointSize' , ADDRESSOF( PointSize ));
	GetProcAddress( 'glPolygonMode' , ADDRESSOF( PolygonMode ));
	GetProcAddress( 'glScissor' , ADDRESSOF( Scissor ));
	GetProcAddress( 'glTexParameterf' , ADDRESSOF( TexParameterf ));
	GetProcAddress( 'glTexParameterfv' , ADDRESSOF( TexParameterfv ));
	GetProcAddress( 'glTexParameteri' , ADDRESSOF( TexParameteri ));
	GetProcAddress( 'glTexParameteriv' , ADDRESSOF( TexParameteriv ));
	GetProcAddress( 'glTexImage1D' , ADDRESSOF( TexImage1D ));
	GetProcAddress( 'glTexImage2D' , ADDRESSOF( TexImage2D ));
	GetProcAddress( 'glDrawBuffer' , ADDRESSOF( DrawBuffer ));
	GetProcAddress( 'glClear' , ADDRESSOF( Clear ));
	GetProcAddress( 'glClearColor' , ADDRESSOF( ClearColor ));
	GetProcAddress( 'glClearStencil' , ADDRESSOF( ClearStencil ));
	GetProcAddress( 'glClearDepth' , ADDRESSOF( ClearDepth ));
	GetProcAddress( 'glStencilMask' , ADDRESSOF( StencilMask ));
	GetProcAddress( 'glColorMask' , ADDRESSOF( ColorMask ));
	GetProcAddress( 'glDepthMask' , ADDRESSOF( DepthMask ));
	GetProcAddress( 'glDisable' , ADDRESSOF( Disable ));
	GetProcAddress( 'glEnable' , ADDRESSOF( Enable ));
	GetProcAddress( 'glFinish' , ADDRESSOF( Finish ));
	GetProcAddress( 'glFlush' , ADDRESSOF( Flush ));
	GetProcAddress( 'glBlendFunc' , ADDRESSOF( BlendFunc ));
	GetProcAddress( 'glLogicOp' , ADDRESSOF( LogicOp ));
	GetProcAddress( 'glStencilFunc' , ADDRESSOF( StencilFunc ));
	GetProcAddress( 'glStencilOp' , ADDRESSOF( StencilOp ));
	GetProcAddress( 'glDepthFunc' , ADDRESSOF( DepthFunc ));
	GetProcAddress( 'glPixelStoref' , ADDRESSOF( PixelStoref ));
	GetProcAddress( 'glPixelStorei' , ADDRESSOF( PixelStorei ));
	GetProcAddress( 'glReadBuffer' , ADDRESSOF( ReadBuffer ));
	GetProcAddress( 'glReadPixels' , ADDRESSOF( ReadPixels ));
	GetProcAddress( 'glGetBooleanv' , ADDRESSOF( GetBooleanv ));
	GetProcAddress( 'glGetDoublev' , ADDRESSOF( GetDoublev ));
	GetProcAddress( 'glGetError' , ADDRESSOF( GetError ));
	GetProcAddress( 'glGetFloatv' , ADDRESSOF( GetFloatv ));
	GetProcAddress( 'glGetIntegerv' , ADDRESSOF( GetIntegerv ));
	GetProcAddress( 'glGetString' , ADDRESSOF( XglGetString ));
	GetProcAddress( 'glGetTexImage' , ADDRESSOF( GetTexImage ));
	GetProcAddress( 'glGetTexParameteriv' , ADDRESSOF( GetTexParameteriv ));
	GetProcAddress( 'glGetTexParameterfv' , ADDRESSOF( GetTexParameterfv ));
	GetProcAddress( 'glGetTexLevelParameterfv' , ADDRESSOF( GetTexLevelParameterfv ));
	GetProcAddress( 'glGetTexLevelParameteriv' , ADDRESSOF( GetTexLevelParameteriv ));
	GetProcAddress( 'glIsEnabled' , ADDRESSOF( IsEnabled ));
	GetProcAddress( 'glDepthRange' , ADDRESSOF( DepthRange ));
	GetProcAddress( 'glViewport' , ADDRESSOF( Viewport ));
	(*  GL_VERSION_1_1 *)
	GetProcAddress( 'glDrawArrays' , ADDRESSOF( DrawArrays ));
	GetProcAddress( 'glDrawElements' , ADDRESSOF( DrawElements ));
	GetProcAddress( 'glGetPointerv' , ADDRESSOF( GetPointerv ));
	GetProcAddress( 'glPolygonOffset' , ADDRESSOF( PolygonOffset ));
	GetProcAddress( 'glCopyTexImage1D' , ADDRESSOF( CopyTexImage1D ));
	GetProcAddress( 'glCopyTexImage2D' , ADDRESSOF( CopyTexImage2D ));
	GetProcAddress( 'glCopyTexSubImage1D' , ADDRESSOF( CopyTexSubImage1D ));
	GetProcAddress( 'glCopyTexSubImage2D' , ADDRESSOF( CopyTexSubImage2D ));
	GetProcAddress( 'glTexSubImage1D' , ADDRESSOF( TexSubImage1D ));
	GetProcAddress( 'glTexSubImage2D' , ADDRESSOF( TexSubImage2D ));
	GetProcAddress( 'glBindTexture' , ADDRESSOF( BindTexture ));
	GetProcAddress( 'glDeleteTextures' , ADDRESSOF( DeleteTextures ));
	GetProcAddress( 'glGenTextures' , ADDRESSOF( GenTextures ));
	(* {$ifdef DGL_DEPRECATED} *)
	GetProcAddress( 'glAccum' , ADDRESSOF( Accum ));
	GetProcAddress( 'glAlphaFunc' , ADDRESSOF( AlphaFunc ));
	GetProcAddress( 'glAreTexturesResident' , ADDRESSOF( AreTexturesResident ));
	GetProcAddress( 'glArrayElement' , ADDRESSOF( ArrayElement ));
	GetProcAddress( 'glBegin' , ADDRESSOF( Begin ));
	GetProcAddress( 'glBitmap' , ADDRESSOF( Bitmap ));
	GetProcAddress( 'glCallList' , ADDRESSOF( CallList ));
	GetProcAddress( 'glCallLists' , ADDRESSOF( CallLists ));
	GetProcAddress( 'glClearAccum' , ADDRESSOF( ClearAccum ));
	GetProcAddress( 'glClearIndex' , ADDRESSOF( ClearIndex ));
	GetProcAddress( 'glClipPlane' , ADDRESSOF( ClipPlane ));
	GetProcAddress( 'glColor3b' , ADDRESSOF( Color3b ));
	GetProcAddress( 'glColor3bv' , ADDRESSOF( Color3bv ));
	GetProcAddress( 'glColor3d' , ADDRESSOF( Color3d ));
	GetProcAddress( 'glColor3dv' , ADDRESSOF( XglColor3dv ));
	GetProcAddress( 'glColor3f' , ADDRESSOF( Color3f ));
	GetProcAddress( 'glColor3fv' , ADDRESSOF( XglColor3fv ));
	GetProcAddress( 'glColor3i' , ADDRESSOF( Color3i ));
	GetProcAddress( 'glColor3iv' , ADDRESSOF( Color3iv ));
	GetProcAddress( 'glColor3s' , ADDRESSOF( Color3s ));
	GetProcAddress( 'glColor3sv' , ADDRESSOF( Color3sv ));
	GetProcAddress( 'glColor3ub' , ADDRESSOF( Color3ub ));
	GetProcAddress( 'glColor3ubv' , ADDRESSOF( Color3ubv ));
	GetProcAddress( 'glColor3ui' , ADDRESSOF( Color3ui ));
	GetProcAddress( 'glColor3uiv' , ADDRESSOF( Color3uiv ));
	GetProcAddress( 'glColor3us' , ADDRESSOF( Color3us ));
	GetProcAddress( 'glColor3usv' , ADDRESSOF( Color3usv ));
	GetProcAddress( 'glColor4b' , ADDRESSOF( Color4b ));
	GetProcAddress( 'glColor4bv' , ADDRESSOF( Color4bv ));
	GetProcAddress( 'glColor4d' , ADDRESSOF( Color4d ));
	GetProcAddress( 'glColor4dv' , ADDRESSOF( Color4dv ));
	GetProcAddress( 'glColor4f' , ADDRESSOF( Color4f ));
	GetProcAddress( 'glColor4fv' , ADDRESSOF( Color4fv ));
	GetProcAddress( 'glColor4i' , ADDRESSOF( Color4i ));
	GetProcAddress( 'glColor4iv' , ADDRESSOF( Color4iv ));
	GetProcAddress( 'glColor4s' , ADDRESSOF( Color4s ));
	GetProcAddress( 'glColor4sv' , ADDRESSOF( Color4sv ));
	GetProcAddress( 'glColor4ub' , ADDRESSOF( Color4ub ));
	GetProcAddress( 'glColor4ubv' , ADDRESSOF( Color4ubv ));
	GetProcAddress( 'glColor4ui' , ADDRESSOF( Color4ui ));
	GetProcAddress( 'glColor4uiv' , ADDRESSOF( Color4uiv ));
	GetProcAddress( 'glColor4us' , ADDRESSOF( Color4us ));
	GetProcAddress( 'glColor4usv' , ADDRESSOF( Color4usv ));
	GetProcAddress( 'glColorMaterial' , ADDRESSOF( ColorMaterial ));
	GetProcAddress( 'glColorPointer' , ADDRESSOF( ColorPointer ));
	GetProcAddress( 'glCopyPixels' , ADDRESSOF( CopyPixels ));
	GetProcAddress( 'glDeleteLists' , ADDRESSOF( DeleteLists ));
	GetProcAddress( 'glDisableClientState' , ADDRESSOF( DisableClientState ));
	GetProcAddress( 'glDrawPixels' , ADDRESSOF( DrawPixels ));
	GetProcAddress( 'glEdgeFlag' , ADDRESSOF( EdgeFlag ));
	GetProcAddress( 'glEdgeFlagPointer' , ADDRESSOF( EdgeFlagPointer ));
	GetProcAddress( 'glEdgeFlagv' , ADDRESSOF( EdgeFlagv ));
	GetProcAddress( 'glEnableClientState' , ADDRESSOF( EnableClientState ));
	GetProcAddress( 'glEnd' , ADDRESSOF( End ));
	GetProcAddress( 'glEndList' , ADDRESSOF( EndList ));
	GetProcAddress( 'glEvalCoord1d' , ADDRESSOF( EvalCoord1d ));
	GetProcAddress( 'glEvalCoord1dv' , ADDRESSOF( EvalCoord1dv ));
	GetProcAddress( 'glEvalCoord1f' , ADDRESSOF( EvalCoord1f ));
	GetProcAddress( 'glEvalCoord1fv' , ADDRESSOF( EvalCoord1fv ));
	GetProcAddress( 'glEvalCoord2d' , ADDRESSOF( EvalCoord2d ));
	GetProcAddress( 'glEvalCoord2dv' , ADDRESSOF( EvalCoord2dv ));
	GetProcAddress( 'glEvalCoord2f' , ADDRESSOF( EvalCoord2f ));
	GetProcAddress( 'glEvalCoord2fv' , ADDRESSOF( EvalCoord2fv ));
	GetProcAddress( 'glEvalMesh1' , ADDRESSOF( EvalMesh1 ));
	GetProcAddress( 'glEvalMesh2' , ADDRESSOF( EvalMesh2 ));
	GetProcAddress( 'glEvalPoint1' , ADDRESSOF( EvalPoint1 ));
	GetProcAddress( 'glEvalPoint2' , ADDRESSOF( EvalPoint2 ));
	GetProcAddress( 'glFeedbackBuffer' , ADDRESSOF( FeedbackBuffer ));
	GetProcAddress( 'glFogf' , ADDRESSOF( Fogf ));
	GetProcAddress( 'glFogfv' , ADDRESSOF( Fogfv ));
	GetProcAddress( 'glFogi' , ADDRESSOF( Fogi ));
	GetProcAddress( 'glFogiv' , ADDRESSOF( Fogiv ));
	GetProcAddress( 'glFrustum' , ADDRESSOF( Frustum ));
	GetProcAddress( 'glGenLists' , ADDRESSOF( GenLists ));
	GetProcAddress( 'glGetClipPlane' , ADDRESSOF( GetClipPlane ));
	GetProcAddress( 'glGetLightfv' , ADDRESSOF( GetLightfv ));
	GetProcAddress( 'glGetLightiv' , ADDRESSOF( GetLightiv ));
	GetProcAddress( 'glGetMapdv' , ADDRESSOF( GetMapdv ));
	GetProcAddress( 'glGetMapfv' , ADDRESSOF( GetMapfv ));
	GetProcAddress( 'glGetMapiv' , ADDRESSOF( GetMapiv ));
	GetProcAddress( 'glGetMaterialfv' , ADDRESSOF( GetMaterialfv ));
	GetProcAddress( 'glGetMaterialiv' , ADDRESSOF( GetMaterialiv ));
	GetProcAddress( 'glGetPixelMapfv' , ADDRESSOF( GetPixelMapfv ));
	GetProcAddress( 'glGetPixelMapuiv' , ADDRESSOF( GetPixelMapuiv ));
	GetProcAddress( 'glGetPixelMapusv' , ADDRESSOF( GetPixelMapusv ));
	GetProcAddress( 'glGetPolygonStipple' , ADDRESSOF( GetPolygonStipple ));
	GetProcAddress( 'glGetTexEnvfv' , ADDRESSOF( GetTexEnvfv ));
	GetProcAddress( 'glGetTexEnviv' , ADDRESSOF( GetTexEnviv ));
	GetProcAddress( 'glGetTexGendv' , ADDRESSOF( GetTexGendv ));
	GetProcAddress( 'glGetTexGenfv' , ADDRESSOF( GetTexGenfv ));
	GetProcAddress( 'glGetTexGeniv' , ADDRESSOF( GetTexGeniv ));
	GetProcAddress( 'glIndexMask' , ADDRESSOF( IndexMask ));
	GetProcAddress( 'glIndexPointer' , ADDRESSOF( IndexPointer ));
	GetProcAddress( 'glIndexd' , ADDRESSOF( Indexd ));
	GetProcAddress( 'glIndexdv' , ADDRESSOF( Indexdv ));
	GetProcAddress( 'glIndexf' , ADDRESSOF( Indexf ));
	GetProcAddress( 'glIndexfv' , ADDRESSOF( Indexfv ));
	GetProcAddress( 'glIndexi' , ADDRESSOF( Indexi ));
	GetProcAddress( 'glIndexiv' , ADDRESSOF( Indexiv ));
	GetProcAddress( 'glIndexs' , ADDRESSOF( Indexs ));
	GetProcAddress( 'glIndexsv' , ADDRESSOF( Indexsv ));
	GetProcAddress( 'glIndexub' , ADDRESSOF( Indexub ));
	GetProcAddress( 'glIndexubv' , ADDRESSOF( Indexubv ));
	GetProcAddress( 'glInitNames' , ADDRESSOF( InitNames ));
	GetProcAddress( 'glInterleavedArrays' , ADDRESSOF( InterleavedArrays ));
	GetProcAddress( 'glIsList' , ADDRESSOF( IsList ));
	GetProcAddress( 'glIsTexture' , ADDRESSOF( IsTexture ));
	GetProcAddress( 'glLightModelf' , ADDRESSOF( LightModelf ));
	GetProcAddress( 'glLightModelfv' , ADDRESSOF( XglLightModelfv ));
	GetProcAddress( 'glLightModeli' , ADDRESSOF( LightModeli ));
	GetProcAddress( 'glLightModeliv' , ADDRESSOF( LightModeliv ));
	GetProcAddress( 'glLightf' , ADDRESSOF( Lightf ));
	GetProcAddress( 'glLightfv' , ADDRESSOF( XglLightfv ));
	GetProcAddress( 'glLighti' , ADDRESSOF( Lighti ));
	GetProcAddress( 'glLightiv' , ADDRESSOF( Lightiv ));
	GetProcAddress( 'glLineStipple' , ADDRESSOF( LineStipple ));
	GetProcAddress( 'glListBase' , ADDRESSOF( ListBase ));
	GetProcAddress( 'glLoadIdentity' , ADDRESSOF( LoadIdentity ));
	GetProcAddress( 'glLoadMatrixd' , ADDRESSOF( LoadMatrixd ));
	GetProcAddress( 'glLoadMatrixf' , ADDRESSOF( LoadMatrixf ));
	GetProcAddress( 'glLoadName' , ADDRESSOF( LoadName ));
	GetProcAddress( 'glMap1d' , ADDRESSOF( Map1d ));
	GetProcAddress( 'glMap1f' , ADDRESSOF( Map1f ));
	GetProcAddress( 'glMap2d' , ADDRESSOF( Map2d ));
	GetProcAddress( 'glMap2f' , ADDRESSOF( Map2f ));
	GetProcAddress( 'glMapGrid1d' , ADDRESSOF( MapGrid1d ));
	GetProcAddress( 'glMapGrid1f' , ADDRESSOF( MapGrid1f ));
	GetProcAddress( 'glMapGrid2d' , ADDRESSOF( MapGrid2d ));
	GetProcAddress( 'glMapGrid2f' , ADDRESSOF( MapGrid2f ));
	GetProcAddress( 'glMaterialf' , ADDRESSOF( Materialf ));
	GetProcAddress( 'glMaterialfv' , ADDRESSOF( XglMaterialfv ));
	GetProcAddress( 'glMateriali' , ADDRESSOF( Materiali ));
	GetProcAddress( 'glMaterialiv' , ADDRESSOF( Materialiv ));
	GetProcAddress( 'glMatrixMode' , ADDRESSOF( MatrixMode ));
	GetProcAddress( 'glMultMatrixd' , ADDRESSOF( MultMatrixd ));
	GetProcAddress( 'glMultMatrixf' , ADDRESSOF( MultMatrixf ));
	GetProcAddress( 'glNewList' , ADDRESSOF( NewList ));
	GetProcAddress( 'glNormal3b' , ADDRESSOF( Normal3b ));
	GetProcAddress( 'glNormal3bv' , ADDRESSOF( Normal3bv ));
	GetProcAddress( 'glNormal3d' , ADDRESSOF( Normal3d ));
	GetProcAddress( 'glNormal3dv' , ADDRESSOF( XglNormal3dv ));
	GetProcAddress( 'glNormal3f' , ADDRESSOF( Normal3f ));
	GetProcAddress( 'glNormal3fv' , ADDRESSOF( XglNormal3fv ));
	GetProcAddress( 'glNormal3i' , ADDRESSOF( Normal3i ));
	GetProcAddress( 'glNormal3iv' , ADDRESSOF( Normal3iv ));
	GetProcAddress( 'glNormal3s' , ADDRESSOF( Normal3s ));
	GetProcAddress( 'glNormal3sv' , ADDRESSOF( Normal3sv ));
	GetProcAddress( 'glNormalPointer' , ADDRESSOF( NormalPointer ));
	GetProcAddress( 'glOrtho' , ADDRESSOF( Ortho ));
	GetProcAddress( 'glPassThrough' , ADDRESSOF( PassThrough ));
	GetProcAddress( 'glPixelMapfv' , ADDRESSOF( PixelMapfv ));
	GetProcAddress( 'glPixelMapuiv' , ADDRESSOF( PixelMapuiv ));
	GetProcAddress( 'glPixelMapusv' , ADDRESSOF( PixelMapusv ));
	GetProcAddress( 'glPixelTransferf' , ADDRESSOF( PixelTransferf ));
	GetProcAddress( 'glPixelTransferi' , ADDRESSOF( PixelTransferi ));
	GetProcAddress( 'glPixelZoom' , ADDRESSOF( PixelZoom ));
	GetProcAddress( 'glPolygonStipple' , ADDRESSOF( PolygonStipple ));
	GetProcAddress( 'glPopAttrib' , ADDRESSOF( PopAttrib ));
	GetProcAddress( 'glPopClientAttrib' , ADDRESSOF( PopClientAttrib ));
	GetProcAddress( 'glPopMatrix' , ADDRESSOF( PopMatrix ));
	GetProcAddress( 'glPopName' , ADDRESSOF( PopName ));
	GetProcAddress( 'glPrioritizeTextures' , ADDRESSOF( PrioritizeTextures ));
	GetProcAddress( 'glPushAttrib' , ADDRESSOF( PushAttrib ));
	GetProcAddress( 'glPushClientAttrib' , ADDRESSOF( PushClientAttrib ));
	GetProcAddress( 'glPushMatrix' , ADDRESSOF( PushMatrix ));
	GetProcAddress( 'glPushName' , ADDRESSOF( PushName ));
	GetProcAddress( 'glRasterPos2d' , ADDRESSOF( RasterPos2d ));
	GetProcAddress( 'glRasterPos2dv' , ADDRESSOF( RasterPos2dv ));
	GetProcAddress( 'glRasterPos2f' , ADDRESSOF( RasterPos2f ));
	GetProcAddress( 'glRasterPos2fv' , ADDRESSOF( RasterPos2fv ));
	GetProcAddress( 'glRasterPos2i' , ADDRESSOF( RasterPos2i ));
	GetProcAddress( 'glRasterPos2iv' , ADDRESSOF( RasterPos2iv ));
	GetProcAddress( 'glRasterPos2s' , ADDRESSOF( RasterPos2s ));
	GetProcAddress( 'glRasterPos2sv' , ADDRESSOF( RasterPos2sv ));
	GetProcAddress( 'glRasterPos3d' , ADDRESSOF( RasterPos3d ));
	GetProcAddress( 'glRasterPos3dv' , ADDRESSOF( RasterPos3dv ));
	GetProcAddress( 'glRasterPos3f' , ADDRESSOF( RasterPos3f ));
	GetProcAddress( 'glRasterPos3fv' , ADDRESSOF( RasterPos3fv ));
	GetProcAddress( 'glRasterPos3i' , ADDRESSOF( RasterPos3i ));
	GetProcAddress( 'glRasterPos3iv' , ADDRESSOF( RasterPos3iv ));
	GetProcAddress( 'glRasterPos3s' , ADDRESSOF( RasterPos3s ));
	GetProcAddress( 'glRasterPos3sv' , ADDRESSOF( RasterPos3sv ));
	GetProcAddress( 'glRasterPos4d' , ADDRESSOF( RasterPos4d ));
	GetProcAddress( 'glRasterPos4dv' , ADDRESSOF( RasterPos4dv ));
	GetProcAddress( 'glRasterPos4f' , ADDRESSOF( RasterPos4f ));
	GetProcAddress( 'glRasterPos4fv' , ADDRESSOF( RasterPos4fv ));
	GetProcAddress( 'glRasterPos4i' , ADDRESSOF( RasterPos4i ));
	GetProcAddress( 'glRasterPos4iv' , ADDRESSOF( RasterPos4iv ));
	GetProcAddress( 'glRasterPos4s' , ADDRESSOF( RasterPos4s ));
	GetProcAddress( 'glRasterPos4sv' , ADDRESSOF( RasterPos4sv ));
	GetProcAddress( 'glRectd' , ADDRESSOF( Rectd ));
	GetProcAddress( 'glRectdv' , ADDRESSOF( Rectdv ));
	GetProcAddress( 'glRectf' , ADDRESSOF( Rectf ));
	GetProcAddress( 'glRectfv' , ADDRESSOF( Rectfv ));
	GetProcAddress( 'glRecti' , ADDRESSOF( Recti ));
	GetProcAddress( 'glRectiv' , ADDRESSOF( Rectiv ));
	GetProcAddress( 'glRects' , ADDRESSOF( Rects ));
	GetProcAddress( 'glRectsv' , ADDRESSOF( Rectsv ));
	GetProcAddress( 'glRenderMode' , ADDRESSOF( RenderMode ));
	GetProcAddress( 'glRotated' , ADDRESSOF( Rotated ));
	GetProcAddress( 'glRotatef' , ADDRESSOF( Rotatef ));
	GetProcAddress( 'glScaled' , ADDRESSOF( Scaled ));
	GetProcAddress( 'glScalef' , ADDRESSOF( Scalef ));
	GetProcAddress( 'glSelectBuffer' , ADDRESSOF( SelectBuffer ));
	GetProcAddress( 'glShadeModel' , ADDRESSOF( ShadeModel ));
	GetProcAddress( 'glTexCoord1d' , ADDRESSOF( TexCoord1d ));
	GetProcAddress( 'glTexCoord1dv' , ADDRESSOF( TexCoord1dv ));
	GetProcAddress( 'glTexCoord1f' , ADDRESSOF( TexCoord1f ));
	GetProcAddress( 'glTexCoord1fv' , ADDRESSOF( TexCoord1fv ));
	GetProcAddress( 'glTexCoord1i' , ADDRESSOF( TexCoord1i ));
	GetProcAddress( 'glTexCoord1iv' , ADDRESSOF( TexCoord1iv ));
	GetProcAddress( 'glTexCoord1s' , ADDRESSOF( TexCoord1s ));
	GetProcAddress( 'glTexCoord1sv' , ADDRESSOF( TexCoord1sv ));
	GetProcAddress( 'glTexCoord2d' , ADDRESSOF( TexCoord2d ));
	GetProcAddress( 'glTexCoord2dv' , ADDRESSOF( TexCoord2dv ));
	GetProcAddress( 'glTexCoord2f' , ADDRESSOF( TexCoord2f ));
	GetProcAddress( 'glTexCoord2fv' , ADDRESSOF( TexCoord2fv ));
	GetProcAddress( 'glTexCoord2i' , ADDRESSOF( TexCoord2i ));
	GetProcAddress( 'glTexCoord2iv' , ADDRESSOF( TexCoord2iv ));
	GetProcAddress( 'glTexCoord2s' , ADDRESSOF( TexCoord2s ));
	GetProcAddress( 'glTexCoord2sv' , ADDRESSOF( TexCoord2sv ));
	GetProcAddress( 'glTexCoord3d' , ADDRESSOF( TexCoord3d ));
	GetProcAddress( 'glTexCoord3dv' , ADDRESSOF( TexCoord3dv ));
	GetProcAddress( 'glTexCoord3f' , ADDRESSOF( TexCoord3f ));
	GetProcAddress( 'glTexCoord3fv' , ADDRESSOF( TexCoord3fv ));
	GetProcAddress( 'glTexCoord3i' , ADDRESSOF( TexCoord3i ));
	GetProcAddress( 'glTexCoord3iv' , ADDRESSOF( TexCoord3iv ));
	GetProcAddress( 'glTexCoord3s' , ADDRESSOF( TexCoord3s ));
	GetProcAddress( 'glTexCoord3sv' , ADDRESSOF( TexCoord3sv ));
	GetProcAddress( 'glTexCoord4d' , ADDRESSOF( TexCoord4d ));
	GetProcAddress( 'glTexCoord4dv' , ADDRESSOF( TexCoord4dv ));
	GetProcAddress( 'glTexCoord4f' , ADDRESSOF( TexCoord4f ));
	GetProcAddress( 'glTexCoord4fv' , ADDRESSOF( TexCoord4fv ));
	GetProcAddress( 'glTexCoord4i' , ADDRESSOF( TexCoord4i ));
	GetProcAddress( 'glTexCoord4iv' , ADDRESSOF( TexCoord4iv ));
	GetProcAddress( 'glTexCoord4s' , ADDRESSOF( TexCoord4s ));
	GetProcAddress( 'glTexCoord4sv' , ADDRESSOF( TexCoord4sv ));
	GetProcAddress( 'glTexCoordPointer' , ADDRESSOF( TexCoordPointer ));
	GetProcAddress( 'glTexEnvf' , ADDRESSOF( TexEnvf ));
	GetProcAddress( 'glTexEnvfv' , ADDRESSOF( TexEnvfv ));
	GetProcAddress( 'glTexEnvi' , ADDRESSOF( TexEnvi ));
	GetProcAddress( 'glTexEnviv' , ADDRESSOF( TexEnviv ));
	GetProcAddress( 'glTexGend' , ADDRESSOF( TexGend ));
	GetProcAddress( 'glTexGendv' , ADDRESSOF( TexGendv ));
	GetProcAddress( 'glTexGenf' , ADDRESSOF( TexGenf ));
	GetProcAddress( 'glTexGenfv' , ADDRESSOF( TexGenfv ));
	GetProcAddress( 'glTexGeni' , ADDRESSOF( TexGeni ));
	GetProcAddress( 'glTexGeniv' , ADDRESSOF( TexGeniv ));
	GetProcAddress( 'glTranslated' , ADDRESSOF( Translated ));
	GetProcAddress( 'glTranslatef' , ADDRESSOF( Translatef ));
	GetProcAddress( 'glVertex2d' , ADDRESSOF( Vertex2d ));
	GetProcAddress( 'glVertex2dv' , ADDRESSOF( Vertex2dv ));
	GetProcAddress( 'glVertex2f' , ADDRESSOF( Vertex2f ));
	GetProcAddress( 'glVertex2fv' , ADDRESSOF( Vertex2fv ));
	GetProcAddress( 'glVertex2i' , ADDRESSOF( Vertex2i ));
	GetProcAddress( 'glVertex2iv' , ADDRESSOF( Vertex2iv ));
	GetProcAddress( 'glVertex2s' , ADDRESSOF( Vertex2s ));
	GetProcAddress( 'glVertex2sv' , ADDRESSOF( Vertex2sv ));
	GetProcAddress( 'glVertex3d' , ADDRESSOF( Vertex3d ));
	GetProcAddress( 'glVertex3dv' , ADDRESSOF( XglVertex3dv ));
	GetProcAddress( 'glVertex3f' , ADDRESSOF( Vertex3f ));
	GetProcAddress( 'glVertex3fv' , ADDRESSOF( XglVertex3fv ));
	GetProcAddress( 'glVertex3i' , ADDRESSOF( Vertex3i ));
	GetProcAddress( 'glVertex3iv' , ADDRESSOF( Vertex3iv ));
	GetProcAddress( 'glVertex3s' , ADDRESSOF( Vertex3s ));
	GetProcAddress( 'glVertex3sv' , ADDRESSOF( Vertex3sv ));
	GetProcAddress( 'glVertex4d' , ADDRESSOF( Vertex4d ));
	GetProcAddress( 'glVertex4dv' , ADDRESSOF( Vertex4dv ));
	GetProcAddress( 'glVertex4f' , ADDRESSOF( Vertex4f ));
	GetProcAddress( 'glVertex4fv' , ADDRESSOF( Vertex4fv ));
	GetProcAddress( 'glVertex4i' , ADDRESSOF( Vertex4i ));
	GetProcAddress( 'glVertex4iv' , ADDRESSOF( Vertex4iv ));
	GetProcAddress( 'glVertex4s' , ADDRESSOF( Vertex4s ));
	GetProcAddress( 'glVertex4sv' , ADDRESSOF( Vertex4sv ));
	GetProcAddress( 'glVertexPointer' , ADDRESSOF( VertexPointer ));
	(*! endif  *)
	KernelLog.String(libName ); KernelLog.String(" loaded.");  KernelLog.Ln;
END InitOpenGL;

PROCEDURE ReadOpenGLCore*;
BEGIN
	(*  GL_VERSION_1_2 *)
	GetProcAddress( 'glBlendColor' , ADDRESSOF( BlendColor ));
	GetProcAddress( 'glBlendEquation' , ADDRESSOF( BlendEquation ));
	GetProcAddress( 'glDrawRangeElements' , ADDRESSOF( DrawRangeElements ));
	GetProcAddress( 'glTexImage3D' , ADDRESSOF( TexImage3D ));
	GetProcAddress( 'glTexSubImage3D' , ADDRESSOF( TexSubImage3D ));
	GetProcAddress( 'glCopyTexSubImage3D' , ADDRESSOF( CopyTexSubImage3D ));
	(* {$ifdef DGL_DEPRECATED} *)
	GetProcAddress( 'glColorTable' , ADDRESSOF( ColorTable ));
	GetProcAddress( 'glColorTableParameterfv' , ADDRESSOF( ColorTableParameterfv ));
	GetProcAddress( 'glColorTableParameteriv' , ADDRESSOF( ColorTableParameteriv ));
	GetProcAddress( 'glCopyColorTable' , ADDRESSOF( CopyColorTable ));
	GetProcAddress( 'glGetColorTable' , ADDRESSOF( GetColorTable ));
	GetProcAddress( 'glGetColorTableParameterfv' , ADDRESSOF( GetColorTableParameterfv ));
	GetProcAddress( 'glGetColorTableParameteriv' , ADDRESSOF( GetColorTableParameteriv ));
	GetProcAddress( 'glColorSubTable' , ADDRESSOF( ColorSubTable ));
	GetProcAddress( 'glCopyColorSubTable' , ADDRESSOF( CopyColorSubTable ));
	GetProcAddress( 'glConvolutionFilter1D' , ADDRESSOF( ConvolutionFilter1D ));
	GetProcAddress( 'glConvolutionFilter2D' , ADDRESSOF( ConvolutionFilter2D ));
	GetProcAddress( 'glConvolutionParameterf' , ADDRESSOF( ConvolutionParameterf ));
	GetProcAddress( 'glConvolutionParameterfv' , ADDRESSOF( ConvolutionParameterfv ));
	GetProcAddress( 'glConvolutionParameteri' , ADDRESSOF( ConvolutionParameteri ));
	GetProcAddress( 'glConvolutionParameteriv' , ADDRESSOF( ConvolutionParameteriv ));
	GetProcAddress( 'glCopyConvolutionFilter1D' , ADDRESSOF( CopyConvolutionFilter1D ));
	GetProcAddress( 'glCopyConvolutionFilter2D' , ADDRESSOF( CopyConvolutionFilter2D ));
	GetProcAddress( 'glGetConvolutionFilter' , ADDRESSOF( GetConvolutionFilter ));
	GetProcAddress( 'glGetConvolutionParameterfv' , ADDRESSOF( GetConvolutionParameterfv ));
	GetProcAddress( 'glGetConvolutionParameteriv' , ADDRESSOF( GetConvolutionParameteriv ));
	GetProcAddress( 'glGetSeparableFilter' , ADDRESSOF( GetSeparableFilter ));
	GetProcAddress( 'glSeparableFilter2D' , ADDRESSOF( SeparableFilter2D ));
	GetProcAddress( 'glGetHistogram' , ADDRESSOF( GetHistogram ));
	GetProcAddress( 'glGetHistogramParameterfv' , ADDRESSOF( GetHistogramParameterfv ));
	GetProcAddress( 'glGetHistogramParameteriv' , ADDRESSOF( GetHistogramParameteriv ));
	GetProcAddress( 'glGetMinmax' , ADDRESSOF( GetMinmax ));
	GetProcAddress( 'glGetMinmaxParameterfv' , ADDRESSOF( GetMinmaxParameterfv ));
	GetProcAddress( 'glGetMinmaxParameteriv' , ADDRESSOF( GetMinmaxParameteriv ));
	GetProcAddress( 'glHistogram' , ADDRESSOF( Histogram ));
	GetProcAddress( 'glMinmax' , ADDRESSOF( Minmax ));
	GetProcAddress( 'glResetHistogram' , ADDRESSOF( ResetHistogram ));
	GetProcAddress( 'glResetMinmax' , ADDRESSOF( ResetMinmax ));
	(* {$endif} *)
	(*  GL_VERSION_1_3 *)
	GetProcAddress( 'glActiveTexture' , ADDRESSOF( ActiveTexture ));
	GetProcAddress( 'glSampleCoverage' , ADDRESSOF( SampleCoverage ));
	GetProcAddress( 'glCompressedTexImage3D' , ADDRESSOF( CompressedTexImage3D ));
	GetProcAddress( 'glCompressedTexImage2D' , ADDRESSOF( CompressedTexImage2D ));
	GetProcAddress( 'glCompressedTexImage1D' , ADDRESSOF( CompressedTexImage1D ));
	GetProcAddress( 'glCompressedTexSubImage3D' , ADDRESSOF( CompressedTexSubImage3D ));
	GetProcAddress( 'glCompressedTexSubImage2D' , ADDRESSOF( CompressedTexSubImage2D ));
	GetProcAddress( 'glCompressedTexSubImage1D' , ADDRESSOF( CompressedTexSubImage1D ));
	GetProcAddress( 'glGetCompressedTexImage' , ADDRESSOF( GetCompressedTexImage ));
	(* {$ifdef DGL_DEPRECATED} *)
	GetProcAddress( 'glClientActiveTexture' , ADDRESSOF( ClientActiveTexture ));
	GetProcAddress( 'glMultiTexCoord1d' , ADDRESSOF( MultiTexCoord1d ));
	GetProcAddress( 'glMultiTexCoord1dv' , ADDRESSOF( MultiTexCoord1dv ));
	GetProcAddress( 'glMultiTexCoord1f' , ADDRESSOF( MultiTexCoord1f ));
	GetProcAddress( 'glMultiTexCoord1fv' , ADDRESSOF( MultiTexCoord1fv ));
	GetProcAddress( 'glMultiTexCoord1i' , ADDRESSOF( MultiTexCoord1i ));
	GetProcAddress( 'glMultiTexCoord1iv' , ADDRESSOF( MultiTexCoord1iv ));
	GetProcAddress( 'glMultiTexCoord1s' , ADDRESSOF( MultiTexCoord1s ));
	GetProcAddress( 'glMultiTexCoord1sv' , ADDRESSOF( MultiTexCoord1sv ));
	GetProcAddress( 'glMultiTexCoord2d' , ADDRESSOF( MultiTexCoord2d ));
	GetProcAddress( 'glMultiTexCoord2dv' , ADDRESSOF( MultiTexCoord2dv ));
	GetProcAddress( 'glMultiTexCoord2f' , ADDRESSOF( MultiTexCoord2f ));
	GetProcAddress( 'glMultiTexCoord2fv' , ADDRESSOF( MultiTexCoord2fv ));
	GetProcAddress( 'glMultiTexCoord2i' , ADDRESSOF( MultiTexCoord2i ));
	GetProcAddress( 'glMultiTexCoord2iv' , ADDRESSOF( MultiTexCoord2iv ));
	GetProcAddress( 'glMultiTexCoord2s' , ADDRESSOF( MultiTexCoord2s ));
	GetProcAddress( 'glMultiTexCoord2sv' , ADDRESSOF( MultiTexCoord2sv ));
	GetProcAddress( 'glMultiTexCoord3d' , ADDRESSOF( MultiTexCoord3d ));
	GetProcAddress( 'glMultiTexCoord3dv' , ADDRESSOF( MultiTexCoord3dv ));
	GetProcAddress( 'glMultiTexCoord3f' , ADDRESSOF( MultiTexCoord3f ));
	GetProcAddress( 'glMultiTexCoord3fv' , ADDRESSOF( MultiTexCoord3fv ));
	GetProcAddress( 'glMultiTexCoord3i' , ADDRESSOF( MultiTexCoord3i ));
	GetProcAddress( 'glMultiTexCoord3iv' , ADDRESSOF( MultiTexCoord3iv ));
	GetProcAddress( 'glMultiTexCoord3s' , ADDRESSOF( MultiTexCoord3s ));
	GetProcAddress( 'glMultiTexCoord3sv' , ADDRESSOF( MultiTexCoord3sv ));
	GetProcAddress( 'glMultiTexCoord4d' , ADDRESSOF( MultiTexCoord4d ));
	GetProcAddress( 'glMultiTexCoord4dv' , ADDRESSOF( MultiTexCoord4dv ));
	GetProcAddress( 'glMultiTexCoord4f' , ADDRESSOF( MultiTexCoord4f ));
	GetProcAddress( 'glMultiTexCoord4fv' , ADDRESSOF( MultiTexCoord4fv ));
	GetProcAddress( 'glMultiTexCoord4i' , ADDRESSOF( MultiTexCoord4i ));
	GetProcAddress( 'glMultiTexCoord4iv' , ADDRESSOF( MultiTexCoord4iv ));
	GetProcAddress( 'glMultiTexCoord4s' , ADDRESSOF( MultiTexCoord4s ));
	GetProcAddress( 'glMultiTexCoord4sv' , ADDRESSOF( MultiTexCoord4sv ));
	GetProcAddress( 'glLoadTransposeMatrixf' , ADDRESSOF( LoadTransposeMatrixf ));
	GetProcAddress( 'glLoadTransposeMatrixd' , ADDRESSOF( LoadTransposeMatrixd ));
	GetProcAddress( 'glMultTransposeMatrixf' , ADDRESSOF( MultTransposeMatrixf ));
	GetProcAddress( 'glMultTransposeMatrixd' , ADDRESSOF( MultTransposeMatrixd ));
	(* {$endif} *)
	(*  GL_VERSION_1_4 *)
	GetProcAddress( 'glBlendFuncSeparate' , ADDRESSOF( BlendFuncSeparate ));
	GetProcAddress( 'glMultiDrawArrays' , ADDRESSOF( MultiDrawArrays ));
	GetProcAddress( 'glMultiDrawElements' , ADDRESSOF( MultiDrawElements ));
	GetProcAddress( 'glPointParameterf' , ADDRESSOF( PointParameterf ));
	GetProcAddress( 'glPointParameterfv' , ADDRESSOF( PointParameterfv ));
	GetProcAddress( 'glPointParameteri' , ADDRESSOF( PointParameteri ));
	GetProcAddress( 'glPointParameteriv' , ADDRESSOF( PointParameteriv ));
	(* {$ifdef DGL_DEPRECATED} *)
	GetProcAddress( 'glFogCoordf' , ADDRESSOF( FogCoordf ));
	GetProcAddress( 'glFogCoordfv' , ADDRESSOF( FogCoordfv ));
	GetProcAddress( 'glFogCoordd' , ADDRESSOF( FogCoordd ));
	GetProcAddress( 'glFogCoorddv' , ADDRESSOF( FogCoorddv ));
	GetProcAddress( 'glFogCoordPointer' , ADDRESSOF( FogCoordPointer ));
	GetProcAddress( 'glSecondaryColor3b' , ADDRESSOF( SecondaryColor3b ));
	GetProcAddress( 'glSecondaryColor3bv' , ADDRESSOF( SecondaryColor3bv ));
	GetProcAddress( 'glSecondaryColor3d' , ADDRESSOF( SecondaryColor3d ));
	GetProcAddress( 'glSecondaryColor3dv' , ADDRESSOF( SecondaryColor3dv ));
	GetProcAddress( 'glSecondaryColor3f' , ADDRESSOF( SecondaryColor3f ));
	GetProcAddress( 'glSecondaryColor3fv' , ADDRESSOF( SecondaryColor3fv ));
	GetProcAddress( 'glSecondaryColor3i' , ADDRESSOF( SecondaryColor3i ));
	GetProcAddress( 'glSecondaryColor3iv' , ADDRESSOF( SecondaryColor3iv ));
	GetProcAddress( 'glSecondaryColor3s' , ADDRESSOF( SecondaryColor3s ));
	GetProcAddress( 'glSecondaryColor3sv' , ADDRESSOF( SecondaryColor3sv ));
	GetProcAddress( 'glSecondaryColor3ub' , ADDRESSOF( SecondaryColor3ub ));
	GetProcAddress( 'glSecondaryColor3ubv' , ADDRESSOF( SecondaryColor3ubv ));
	GetProcAddress( 'glSecondaryColor3ui' , ADDRESSOF( SecondaryColor3ui ));
	GetProcAddress( 'glSecondaryColor3uiv' , ADDRESSOF( SecondaryColor3uiv ));
	GetProcAddress( 'glSecondaryColor3us' , ADDRESSOF( SecondaryColor3us ));
	GetProcAddress( 'glSecondaryColor3usv' , ADDRESSOF( SecondaryColor3usv ));
	GetProcAddress( 'glSecondaryColorPointer' , ADDRESSOF( SecondaryColorPointer ));
	GetProcAddress( 'glWindowPos2d' , ADDRESSOF( WindowPos2d ));
	GetProcAddress( 'glWindowPos2dv' , ADDRESSOF( WindowPos2dv ));
	GetProcAddress( 'glWindowPos2f' , ADDRESSOF( WindowPos2f ));
	GetProcAddress( 'glWindowPos2fv' , ADDRESSOF( WindowPos2fv ));
	GetProcAddress( 'glWindowPos2i' , ADDRESSOF( WindowPos2i ));
	GetProcAddress( 'glWindowPos2iv' , ADDRESSOF( WindowPos2iv ));
	GetProcAddress( 'glWindowPos2s' , ADDRESSOF( WindowPos2s ));
	GetProcAddress( 'glWindowPos2sv' , ADDRESSOF( WindowPos2sv ));
	GetProcAddress( 'glWindowPos3d' , ADDRESSOF( WindowPos3d ));
	GetProcAddress( 'glWindowPos3dv' , ADDRESSOF( WindowPos3dv ));
	GetProcAddress( 'glWindowPos3f' , ADDRESSOF( WindowPos3f ));
	GetProcAddress( 'glWindowPos3fv' , ADDRESSOF( WindowPos3fv ));
	GetProcAddress( 'glWindowPos3i' , ADDRESSOF( WindowPos3i ));
	GetProcAddress( 'glWindowPos3iv' , ADDRESSOF( WindowPos3iv ));
	GetProcAddress( 'glWindowPos3s' , ADDRESSOF( WindowPos3s ));
	GetProcAddress( 'glWindowPos3sv' , ADDRESSOF( WindowPos3sv ));
	(* {$endif} *)
	(*  GL_VERSION_1_5 *)
	GetProcAddress( 'glGenQueries' , ADDRESSOF( GenQueries ));
	GetProcAddress( 'glDeleteQueries' , ADDRESSOF( DeleteQueries ));
	GetProcAddress( 'glIsQuery' , ADDRESSOF( IsQuery ));
	GetProcAddress( 'glBeginQuery' , ADDRESSOF( BeginQuery ));
	GetProcAddress( 'glEndQuery' , ADDRESSOF( EndQuery ));
	GetProcAddress( 'glGetQueryiv' , ADDRESSOF( GetQueryiv ));
	GetProcAddress( 'glGetQueryObjectiv' , ADDRESSOF( GetQueryObjectiv ));
	GetProcAddress( 'glGetQueryObjectuiv' , ADDRESSOF( GetQueryObjectuiv ));
	GetProcAddress( 'glBindBuffer' , ADDRESSOF( BindBuffer ));
	GetProcAddress( 'glDeleteBuffers' , ADDRESSOF( DeleteBuffers ));
	GetProcAddress( 'glGenBuffers' , ADDRESSOF( GenBuffers ));
	GetProcAddress( 'glIsBuffer' , ADDRESSOF( IsBuffer ));
	GetProcAddress( 'glBufferData' , ADDRESSOF( BufferData ));
	GetProcAddress( 'glBufferSubData' , ADDRESSOF( BufferSubData ));
	GetProcAddress( 'glGetBufferSubData' , ADDRESSOF( GetBufferSubData ));
	GetProcAddress( 'glMapBuffer' , ADDRESSOF( MapBuffer ));
	GetProcAddress( 'glUnmapBuffer' , ADDRESSOF( UnmapBuffer ));
	GetProcAddress( 'glGetBufferParameteriv' , ADDRESSOF( GetBufferParameteriv ));
	GetProcAddress( 'glGetBufferPointerv' , ADDRESSOF( GetBufferPointerv ));
	(*  GL_VERSION_2_0 *)
	GetProcAddress( 'glBlendEquationSeparate' , ADDRESSOF( BlendEquationSeparate ));
	GetProcAddress( 'glDrawBuffers' , ADDRESSOF( DrawBuffers ));
	GetProcAddress( 'glStencilOpSeparate' , ADDRESSOF( StencilOpSeparate ));
	GetProcAddress( 'glStencilFuncSeparate' , ADDRESSOF( StencilFuncSeparate ));
	GetProcAddress( 'glStencilMaskSeparate' , ADDRESSOF( StencilMaskSeparate ));
	GetProcAddress( 'glAttachShader' , ADDRESSOF( AttachShader ));
	GetProcAddress( 'glBindAttribLocation' , ADDRESSOF( BindAttribLocation ));
	GetProcAddress( 'glCompileShader' , ADDRESSOF( CompileShader ));
	GetProcAddress( 'glCreateProgram' , ADDRESSOF( CreateProgram ));
	GetProcAddress( 'glCreateShader' , ADDRESSOF( CreateShader ));
	GetProcAddress( 'glDeleteProgram' , ADDRESSOF( DeleteProgram ));
	GetProcAddress( 'glDeleteShader' , ADDRESSOF( DeleteShader ));
	GetProcAddress( 'glDetachShader' , ADDRESSOF( DetachShader ));
	GetProcAddress( 'glDisableVertexAttribArray' , ADDRESSOF( DisableVertexAttribArray ));
	GetProcAddress( 'glEnableVertexAttribArray' , ADDRESSOF( EnableVertexAttribArray ));
	GetProcAddress( 'glGetActiveAttrib' , ADDRESSOF( GetActiveAttrib ));
	GetProcAddress( 'glGetActiveUniform' , ADDRESSOF( GetActiveUniform ));
	GetProcAddress( 'glGetAttachedShaders' , ADDRESSOF( GetAttachedShaders ));
	GetProcAddress( 'glGetAttribLocation' , ADDRESSOF( GetAttribLocation ));
	GetProcAddress( 'glGetProgramiv' , ADDRESSOF( GetProgramiv ));
	GetProcAddress( 'glGetProgramInfoLog' , ADDRESSOF( GetProgramInfoLog ));
	GetProcAddress( 'glGetShaderiv' , ADDRESSOF( GetShaderiv ));
	GetProcAddress( 'glGetShaderInfoLog' , ADDRESSOF( GetShaderInfoLog ));
	GetProcAddress( 'glGetShaderSource' , ADDRESSOF( GetShaderSource ));
	GetProcAddress( 'glGetUniformLocation' , ADDRESSOF( GetUniformLocation ));
	GetProcAddress( 'glGetUniformfv' , ADDRESSOF( GetUniformfv ));
	GetProcAddress( 'glGetUniformiv' , ADDRESSOF( GetUniformiv ));
	GetProcAddress( 'glGetVertexAttribfv' , ADDRESSOF( GetVertexAttribfv ));
	GetProcAddress( 'glGetVertexAttribiv' , ADDRESSOF( GetVertexAttribiv ));
	GetProcAddress( 'glGetVertexAttribPointerv' , ADDRESSOF( GetVertexAttribPointerv ));
	GetProcAddress( 'glIsProgram' , ADDRESSOF( IsProgram ));
	GetProcAddress( 'glIsShader' , ADDRESSOF( IsShader ));
	GetProcAddress( 'glLinkProgram' , ADDRESSOF( LinkProgram ));
	GetProcAddress( 'glShaderSource' , ADDRESSOF( ShaderSource ));
	GetProcAddress( 'glUseProgram' , ADDRESSOF( UseProgram ));
	GetProcAddress( 'glUniform1f' , ADDRESSOF( Uniform1f ));
	GetProcAddress( 'glUniform2f' , ADDRESSOF( Uniform2f ));
	GetProcAddress( 'glUniform3f' , ADDRESSOF( Uniform3f ));
	GetProcAddress( 'glUniform4f' , ADDRESSOF( Uniform4f ));
	GetProcAddress( 'glUniform1i' , ADDRESSOF( Uniform1i ));
	GetProcAddress( 'glUniform2i' , ADDRESSOF( Uniform2i ));
	GetProcAddress( 'glUniform3i' , ADDRESSOF( Uniform3i ));
	GetProcAddress( 'glUniform4i' , ADDRESSOF( Uniform4i ));
	GetProcAddress( 'glUniform1fv' , ADDRESSOF( Uniform1fv ));
	GetProcAddress( 'glUniform2fv' , ADDRESSOF( Uniform2fv ));
	GetProcAddress( 'glUniform3fv' , ADDRESSOF( Uniform3fv ));
	GetProcAddress( 'glUniform4fv' , ADDRESSOF( Uniform4fv ));
	GetProcAddress( 'glUniform1iv' , ADDRESSOF( Uniform1iv ));
	GetProcAddress( 'glUniform2iv' , ADDRESSOF( Uniform2iv ));
	GetProcAddress( 'glUniform3iv' , ADDRESSOF( Uniform3iv ));
	GetProcAddress( 'glUniform4iv' , ADDRESSOF( Uniform4iv ));
	GetProcAddress( 'glUniformMatrix2fv' , ADDRESSOF( UniformMatrix2fv ));
	GetProcAddress( 'glUniformMatrix3fv' , ADDRESSOF( UniformMatrix3fv ));
	GetProcAddress( 'glUniformMatrix4fv' , ADDRESSOF( UniformMatrix4fv ));
	GetProcAddress( 'glValidateProgram' , ADDRESSOF( ValidateProgram ));
	GetProcAddress( 'glVertexAttrib1d' , ADDRESSOF( VertexAttrib1d ));
	GetProcAddress( 'glVertexAttrib1dv' , ADDRESSOF( VertexAttrib1dv ));
	GetProcAddress( 'glVertexAttrib1f' , ADDRESSOF( VertexAttrib1f ));
	GetProcAddress( 'glVertexAttrib1fv' , ADDRESSOF( VertexAttrib1fv ));
	GetProcAddress( 'glVertexAttrib1s' , ADDRESSOF( VertexAttrib1s ));
	GetProcAddress( 'glVertexAttrib1sv' , ADDRESSOF( VertexAttrib1sv ));
	GetProcAddress( 'glVertexAttrib2d' , ADDRESSOF( VertexAttrib2d ));
	GetProcAddress( 'glVertexAttrib2dv' , ADDRESSOF( VertexAttrib2dv ));
	GetProcAddress( 'glVertexAttrib2f' , ADDRESSOF( VertexAttrib2f ));
	GetProcAddress( 'glVertexAttrib2fv' , ADDRESSOF( VertexAttrib2fv ));
	GetProcAddress( 'glVertexAttrib2s' , ADDRESSOF( VertexAttrib2s ));
	GetProcAddress( 'glVertexAttrib2sv' , ADDRESSOF( VertexAttrib2sv ));
	GetProcAddress( 'glVertexAttrib3d' , ADDRESSOF( VertexAttrib3d ));
	GetProcAddress( 'glVertexAttrib3dv' , ADDRESSOF( VertexAttrib3dv ));
	GetProcAddress( 'glVertexAttrib3f' , ADDRESSOF( VertexAttrib3f ));
	GetProcAddress( 'glVertexAttrib3fv' , ADDRESSOF( VertexAttrib3fv ));
	GetProcAddress( 'glVertexAttrib3s' , ADDRESSOF( VertexAttrib3s ));
	GetProcAddress( 'glVertexAttrib3sv' , ADDRESSOF( VertexAttrib3sv ));
	GetProcAddress( 'glVertexAttrib4Nbv' , ADDRESSOF( VertexAttrib4Nbv ));
	GetProcAddress( 'glVertexAttrib4Niv' , ADDRESSOF( VertexAttrib4Niv ));
	GetProcAddress( 'glVertexAttrib4Nsv' , ADDRESSOF( VertexAttrib4Nsv ));
	GetProcAddress( 'glVertexAttrib4Nub' , ADDRESSOF( VertexAttrib4Nub ));
	GetProcAddress( 'glVertexAttrib4Nubv' , ADDRESSOF( VertexAttrib4Nubv ));
	GetProcAddress( 'glVertexAttrib4Nuiv' , ADDRESSOF( VertexAttrib4Nuiv ));
	GetProcAddress( 'glVertexAttrib4Nusv' , ADDRESSOF( VertexAttrib4Nusv ));
	GetProcAddress( 'glVertexAttrib4bv' , ADDRESSOF( VertexAttrib4bv ));
	GetProcAddress( 'glVertexAttrib4d' , ADDRESSOF( VertexAttrib4d ));
	GetProcAddress( 'glVertexAttrib4dv' , ADDRESSOF( VertexAttrib4dv ));
	GetProcAddress( 'glVertexAttrib4f' , ADDRESSOF( VertexAttrib4f ));
	GetProcAddress( 'glVertexAttrib4fv' , ADDRESSOF( VertexAttrib4fv ));
	GetProcAddress( 'glVertexAttrib4iv' , ADDRESSOF( VertexAttrib4iv ));
	GetProcAddress( 'glVertexAttrib4s' , ADDRESSOF( VertexAttrib4s ));
	GetProcAddress( 'glVertexAttrib4sv' , ADDRESSOF( VertexAttrib4sv ));
	GetProcAddress( 'glVertexAttrib4ubv' , ADDRESSOF( VertexAttrib4ubv ));
	GetProcAddress( 'glVertexAttrib4uiv' , ADDRESSOF( VertexAttrib4uiv ));
	GetProcAddress( 'glVertexAttrib4usv' , ADDRESSOF( VertexAttrib4usv ));
	GetProcAddress( 'glVertexAttribPointer' , ADDRESSOF( VertexAttribPointer ));
	(*  GL_VERSION_2_1 *)
	GetProcAddress( 'glUniformMatrix2x3fv' , ADDRESSOF( UniformMatrix2x3fv ));
	GetProcAddress( 'glUniformMatrix3x2fv' , ADDRESSOF( UniformMatrix3x2fv ));
	GetProcAddress( 'glUniformMatrix2x4fv' , ADDRESSOF( UniformMatrix2x4fv ));
	GetProcAddress( 'glUniformMatrix4x2fv' , ADDRESSOF( UniformMatrix4x2fv ));
	GetProcAddress( 'glUniformMatrix3x4fv' , ADDRESSOF( UniformMatrix3x4fv ));
	GetProcAddress( 'glUniformMatrix4x3fv' , ADDRESSOF( UniformMatrix4x3fv ));
	(*  GL_VERSION_3_0 *)
	(* { OpenGL 3.0 also reuses entry points from these extensions: } *)
	Read_GL_ARB_framebuffer_object;
	Read_GL_ARB_map_buffer_range;
	Read_GL_ARB_vertex_array_object;
	GetProcAddress( 'glColorMaski' , ADDRESSOF( ColorMaski ));
	GetProcAddress( 'glGetBooleani_v' , ADDRESSOF( GetBooleani_v ));
	GetProcAddress( 'glGetIntegeri_v' , ADDRESSOF( GetIntegeri_v ));
	GetProcAddress( 'glEnablei' , ADDRESSOF( Enablei ));
	GetProcAddress( 'glDisablei' , ADDRESSOF( Disablei ));
	GetProcAddress( 'glIsEnabledi' , ADDRESSOF( IsEnabledi ));
	GetProcAddress( 'glBeginTransformFeedback' , ADDRESSOF( BeginTransformFeedback ));
	GetProcAddress( 'glEndTransformFeedback' , ADDRESSOF( EndTransformFeedback ));
	GetProcAddress( 'glBindBufferRange' , ADDRESSOF( BindBufferRange ));
	GetProcAddress( 'glBindBufferBase' , ADDRESSOF( BindBufferBase ));
	GetProcAddress( 'glTransformFeedbackVaryings' , ADDRESSOF( TransformFeedbackVaryings ));
	GetProcAddress( 'glGetTransformFeedbackVarying' , ADDRESSOF( GetTransformFeedbackVarying ));
	GetProcAddress( 'glClampColor' , ADDRESSOF( ClampColor ));
	GetProcAddress( 'glBeginConditionalRender' , ADDRESSOF( BeginConditionalRender ));
	GetProcAddress( 'glEndConditionalRender' , ADDRESSOF( EndConditionalRender ));
	GetProcAddress( 'glVertexAttribI1i' , ADDRESSOF( VertexAttribI1i ));
	GetProcAddress( 'glVertexAttribI2i' , ADDRESSOF( VertexAttribI2i ));
	GetProcAddress( 'glVertexAttribI3i' , ADDRESSOF( VertexAttribI3i ));
	GetProcAddress( 'glVertexAttribI4i' , ADDRESSOF( VertexAttribI4i ));
	GetProcAddress( 'glVertexAttribI1ui' , ADDRESSOF( VertexAttribI1ui ));
	GetProcAddress( 'glVertexAttribI2ui' , ADDRESSOF( VertexAttribI2ui ));
	GetProcAddress( 'glVertexAttribI3ui' , ADDRESSOF( VertexAttribI3ui ));
	GetProcAddress( 'glVertexAttribI4ui' , ADDRESSOF( VertexAttribI4ui ));
	GetProcAddress( 'glVertexAttribI1iv' , ADDRESSOF( VertexAttribI1iv ));
	GetProcAddress( 'glVertexAttribI2iv' , ADDRESSOF( VertexAttribI2iv ));
	GetProcAddress( 'glVertexAttribI3iv' , ADDRESSOF( VertexAttribI3iv ));
	GetProcAddress( 'glVertexAttribI4iv' , ADDRESSOF( VertexAttribI4iv ));
	GetProcAddress( 'glVertexAttribI1uiv' , ADDRESSOF( VertexAttribI1uiv ));
	GetProcAddress( 'glVertexAttribI2uiv' , ADDRESSOF( VertexAttribI2uiv ));
	GetProcAddress( 'glVertexAttribI3uiv' , ADDRESSOF( VertexAttribI3uiv ));
	GetProcAddress( 'glVertexAttribI4uiv' , ADDRESSOF( VertexAttribI4uiv ));
	GetProcAddress( 'glVertexAttribI4bv' , ADDRESSOF( VertexAttribI4bv ));
	GetProcAddress( 'glVertexAttribI4sv' , ADDRESSOF( VertexAttribI4sv ));
	GetProcAddress( 'glVertexAttribI4ubv' , ADDRESSOF( VertexAttribI4ubv ));
	GetProcAddress( 'glVertexAttribI4usv' , ADDRESSOF( VertexAttribI4usv ));
	GetProcAddress( 'glVertexAttribIPointer' , ADDRESSOF( VertexAttribIPointer ));
	GetProcAddress( 'glGetVertexAttribIiv' , ADDRESSOF( GetVertexAttribIiv ));
	GetProcAddress( 'glGetVertexAttribIuiv' , ADDRESSOF( GetVertexAttribIuiv ));
	GetProcAddress( 'glGetUniformuiv' , ADDRESSOF( GetUniformuiv ));
	GetProcAddress( 'glBindFragDataLocation' , ADDRESSOF( BindFragDataLocation ));
	GetProcAddress( 'glGetFragDataLocation' , ADDRESSOF( GetFragDataLocation ));
	GetProcAddress( 'glUniform1ui' , ADDRESSOF( Uniform1ui ));
	GetProcAddress( 'glUniform2ui' , ADDRESSOF( Uniform2ui ));
	GetProcAddress( 'glUniform3ui' , ADDRESSOF( Uniform3ui ));
	GetProcAddress( 'glUniform4ui' , ADDRESSOF( Uniform4ui ));
	GetProcAddress( 'glUniform1uiv' , ADDRESSOF( Uniform1uiv ));
	GetProcAddress( 'glUniform2uiv' , ADDRESSOF( Uniform2uiv ));
	GetProcAddress( 'glUniform3uiv' , ADDRESSOF( Uniform3uiv ));
	GetProcAddress( 'glUniform4uiv' , ADDRESSOF( Uniform4uiv ));
	GetProcAddress( 'glTexParameterIiv' , ADDRESSOF( TexParameterIiv ));
	GetProcAddress( 'glTexParameterIuiv' , ADDRESSOF( TexParameterIuiv ));
	GetProcAddress( 'glGetTexParameterIiv' , ADDRESSOF( GetTexParameterIiv ));
	GetProcAddress( 'glGetTexParameterIuiv' , ADDRESSOF( GetTexParameterIuiv ));
	GetProcAddress( 'glClearBufferiv' , ADDRESSOF( ClearBufferiv ));
	GetProcAddress( 'glClearBufferuiv' , ADDRESSOF( ClearBufferuiv ));
	GetProcAddress( 'glClearBufferfv' , ADDRESSOF( ClearBufferfv ));
	GetProcAddress( 'glClearBufferfi' , ADDRESSOF( ClearBufferfi ));
	GetProcAddress( 'glGetStringi' , ADDRESSOF( XglGetStringi ));
	(*  GL_VERSION_2_1 *)
	GetProcAddress( 'glEnableVertexArrayEXT' , ADDRESSOF( EnableVertexArrayEXT ));
	GetProcAddress( 'glEnableVertexArrayAttribEXT' , ADDRESSOF( EnableVertexArrayAttribEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribOffsetEXT' , ADDRESSOF( VertexArrayVertexAttribOffsetEXT ));
	(*  GL_VERSION_3_1 *)
	(* { OpenGL 3.1 also reuses entry points from these extensions: } *)
	Read_GL_ARB_copy_buffer;
	Read_GL_ARB_uniform_buffer_object;
	GetProcAddress( 'glDrawArraysInstanced' , ADDRESSOF( DrawArraysInstanced ));
	GetProcAddress( 'glDrawElementsInstanced' , ADDRESSOF( DrawElementsInstanced ));
	GetProcAddress( 'glTexBuffer' , ADDRESSOF( TexBuffer ));
	GetProcAddress( 'glPrimitiveRestartIndex' , ADDRESSOF( PrimitiveRestartIndex ));
	(*  GL_VERSION_3_2 *)
	(* { OpenGL 3.2 also reuses entry points from these extensions: } *)
	Read_GL_ARB_draw_elements_base_vertex;
	Read_GL_ARB_provoking_vertex;
	Read_GL_ARB_sync;
	Read_GL_ARB_texture_multisample;
	GetProcAddress( 'glGetInteger64i_v' , ADDRESSOF( GetInteger64i_v ));
	GetProcAddress( 'glGetBufferParameteri64v' , ADDRESSOF( GetBufferParameteri64v ));
	GetProcAddress( 'glFramebufferTexture' , ADDRESSOF( FramebufferTexture ));
(*	GetProcAddress( 'glFramebufferTextureFace' , ADDRESSOF( FramebufferTextureFace )); *)
	(*  GL_VERSION_3_3 *)
	(* { OpenGL 3.3 also reuses entry points from these extensions: } *)
	Read_GL_ARB_blend_func_extended;
	Read_GL_ARB_sampler_objects;
	(* { ARB_explicit_attrib_location, but it has none } *)
	(* { ARB_occlusion_query2 (no entry points) } *)
	(* { ARB_shader_bit_encoding (no entry points) } *)
	(* { ARB_texture_rgb10_a2ui (no entry points) } *)
	(* { ARB_texture_swizzle (no entry points) } *)
	Read_GL_ARB_timer_query;
	Read_GL_ARB_vertex_type_2_10_10_10_rev;
	GetProcAddress( 'glVertexAttribDivisor' , ADDRESSOF( VertexAttribDivisor ));
	(*  GL_VERSION_4_0 *)
	(* { OpenGL 4.0 also reuses entry points from these extensions: } *)
	(* { ARB_texture_query_lod (no entry points) } *)
	Read_GL_ARB_draw_indirect;
	(* { ARB_gpu_shader5 (no entry points) } *)
	Read_GL_ARB_gpu_shader_fp64;
	Read_GL_ARB_shader_subroutine;
	Read_GL_ARB_tessellation_shader;
	(* { ARB_texture_buffer_object_rgb32 (no entry points) } *)
	(* { ARB_texture_cube_map_array (no entry points) } *)
	(* { ARB_texture_gather (no entry points) } *)
	Read_GL_ARB_transform_feedback2;
	Read_GL_ARB_transform_feedback3;
	GetProcAddress( 'glMinSampleShading' , ADDRESSOF( MinSampleShading ));
	GetProcAddress( 'glBlendEquationi' , ADDRESSOF( BlendEquationi ));
	GetProcAddress( 'glBlendEquationSeparatei' , ADDRESSOF( BlendEquationSeparatei ));
	GetProcAddress( 'glBlendFunci' , ADDRESSOF( BlendFunci ));
	GetProcAddress( 'glBlendFuncSeparatei' , ADDRESSOF( BlendFuncSeparatei ));
	(*  GL_VERSION_4_1 *)
	(* { OpenGL 4.1 also reuses entry points from these extensions: } *)
	Read_GL_ARB_ES2_compatibility;
	Read_GL_ARB_get_program_binary;
	Read_GL_ARB_separate_shader_objects;
	(* { ARB_shader_precision (no entry points) } *)
	Read_GL_ARB_vertex_attrib_64bit;
	Read_GL_ARB_viewport_array;
	(*  GL_VERSION_4_2 *)
	(* { OpenGL 4.2 reuses entry points from these extensions: } *)
	Read_GL_ARB_base_instance;
	(* Read_GL_ARB_shading_language_420pack (no entry points) *)
	Read_GL_ARB_transform_feedback_instanced;
	(* Read_GL_ARB_compressed_texture_pixel_storage (no entry points) *)
	(* Read_GL_ARB_conservative_depth; *)
	Read_GL_ARB_internalformat_query;
	(* Read_GL_ARB_map_buffer_alignment; *)
	Read_GL_ARB_shader_atomic_counters;
	Read_GL_ARB_shader_image_load_store;
	(* Read_GL_ARB_shading_language_packing; *)
	Read_GL_ARB_texture_storage;
	(*  GL_VERSION_4_3 *)
	(*  OpenGL 4.3 reuses entry points from these extensions: *)
	(*  Read_GL_ARB_arrays_of_arrays (none, GLSL only) (no entry points) *)
	(*  Read_GL_ARB_fragment_layer_viewport (none, GLSL only) (no entry points) *)
	(*  Read_GL_ARB_shader_image_size (none, GLSL only) (no entry points) *)
	(*  Read_GL_ARB_ES3_compatibility (no entry points) *)
	Read_GL_ARB_clear_buffer_object;
	Read_GL_ARB_compute_shader;
	Read_GL_ARB_copy_image;
	Read_GL_KHR_debug;
	(*  Read_GL_ARB_explicit_uniform_location  (no entry points) *)
	Read_GL_ARB_framebuffer_no_attachments;
	Read_GL_ARB_internalformat_query2;
	Read_GL_ARB_invalidate_subdata;
	Read_GL_ARB_multi_draw_indirect;
	Read_GL_ARB_program_interface_query;
	(*  Read_GL_ARB_robust_buffer_access_behavior (none)  (no entry points) *)
	Read_GL_ARB_shader_storage_buffer_object;
	(*  Read_GL_ARB_stencil_texturing  (no entry points) *)
	Read_GL_ARB_texture_buffer_range;
	(*  Read_GL_ARB_texture_query_levels (none)  (no entry points) *)
	Read_GL_ARB_texture_storage_multisample;
	Read_GL_ARB_texture_view;
	Read_GL_ARB_vertex_attrib_binding;
	Read_GL_4_4;
	Read_GL_4_5;
END ReadOpenGLCore;

PROCEDURE Read_GL_3DFX_tbuffer*;
BEGIN
	GetProcAddress( 'glTbufferMask3DFX' , ADDRESSOF( TbufferMask3DFX ));
END Read_GL_3DFX_tbuffer;

PROCEDURE Read_GL_APPLE_element_array*;
BEGIN
	GetProcAddress( 'glElementPointerAPPLE' , ADDRESSOF( ElementPointerAPPLE ));
	GetProcAddress( 'glDrawElementArrayAPPLE' , ADDRESSOF( DrawElementArrayAPPLE ));
	GetProcAddress( 'glDrawRangeElementArrayAPPLE' , ADDRESSOF( DrawRangeElementArrayAPPLE ));
	GetProcAddress( 'glMultiDrawElementArrayAPPLE' , ADDRESSOF( MultiDrawElementArrayAPPLE ));
	GetProcAddress( 'glMultiDrawRangeElementArrayAPPLE' , ADDRESSOF( MultiDrawRangeElementArrayAPPLE ));
END Read_GL_APPLE_element_array;

PROCEDURE Read_GL_APPLE_fence*;
BEGIN
	GetProcAddress( 'glGenFencesAPPLE' , ADDRESSOF( GenFencesAPPLE ));
	GetProcAddress( 'glDeleteFencesAPPLE' , ADDRESSOF( DeleteFencesAPPLE ));
	GetProcAddress( 'glSetFenceAPPLE' , ADDRESSOF( SetFenceAPPLE ));
	GetProcAddress( 'glIsFenceAPPLE' , ADDRESSOF( IsFenceAPPLE ));
	GetProcAddress( 'glTestFenceAPPLE' , ADDRESSOF( TestFenceAPPLE ));
	GetProcAddress( 'glFinishFenceAPPLE' , ADDRESSOF( FinishFenceAPPLE ));
	GetProcAddress( 'glTestObjectAPPLE' , ADDRESSOF( TestObjectAPPLE ));
	GetProcAddress( 'glFinishObjectAPPLE' , ADDRESSOF( FinishObjectAPPLE ));
END Read_GL_APPLE_fence;

PROCEDURE Read_GL_APPLE_vertex_array_object*;
BEGIN
	GetProcAddress( 'glBindVertexArrayAPPLE' , ADDRESSOF( BindVertexArrayAPPLE ));
	GetProcAddress( 'glDeleteVertexArraysAPPLE' , ADDRESSOF( DeleteVertexArraysAPPLE ));
	GetProcAddress( 'glGenVertexArraysAPPLE' , ADDRESSOF( GenVertexArraysAPPLE ));
	GetProcAddress( 'glIsVertexArrayAPPLE' , ADDRESSOF( IsVertexArrayAPPLE ));
END Read_GL_APPLE_vertex_array_object;

PROCEDURE Read_GL_APPLE_vertex_array_range*;
BEGIN
	GetProcAddress( 'glVertexArrayRangeAPPLE' , ADDRESSOF( VertexArrayRangeAPPLE ));
	GetProcAddress( 'glFlushVertexArrayRangeAPPLE' , ADDRESSOF( FlushVertexArrayRangeAPPLE ));
	GetProcAddress( 'glVertexArrayParameteriAPPLE' , ADDRESSOF( VertexArrayParameteriAPPLE ));
END Read_GL_APPLE_vertex_array_range;

PROCEDURE Read_GL_APPLE_texture_range*;
BEGIN
	GetProcAddress( 'glTextureRangeAPPLE' , ADDRESSOF( TextureRangeAPPLE ));
	GetProcAddress( 'glGetTexParameterPointervAPPLE' , ADDRESSOF( GetTexParameterPointervAPPLE ));
END Read_GL_APPLE_texture_range;

PROCEDURE Read_GL_APPLE_vertex_program_evaluators*;
BEGIN
	GetProcAddress( 'glEnableVertexAttribAPPLE' , ADDRESSOF( EnableVertexAttribAPPLE ));
	GetProcAddress( 'glDisableVertexAttribAPPLE' , ADDRESSOF( DisableVertexAttribAPPLE ));
	GetProcAddress( 'glIsVertexAttribEnabledAPPLE' , ADDRESSOF( IsVertexAttribEnabledAPPLE ));
	GetProcAddress( 'glMapVertexAttrib1dAPPLE' , ADDRESSOF( MapVertexAttrib1dAPPLE ));
	GetProcAddress( 'glMapVertexAttrib1fAPPLE' , ADDRESSOF( MapVertexAttrib1fAPPLE ));
	GetProcAddress( 'glMapVertexAttrib2dAPPLE' , ADDRESSOF( MapVertexAttrib2dAPPLE ));
	GetProcAddress( 'glMapVertexAttrib2fAPPLE' , ADDRESSOF( MapVertexAttrib2fAPPLE ));
END Read_GL_APPLE_vertex_program_evaluators;

PROCEDURE Read_GL_APPLE_object_purgeable*;
BEGIN
	GetProcAddress( 'glObjectPurgeableAPPLE' , ADDRESSOF( ObjectPurgeableAPPLE ));
	GetProcAddress( 'glObjectUnpurgeableAPPLE' , ADDRESSOF( ObjectUnpurgeableAPPLE ));
	GetProcAddress( 'glGetObjectParameterivAPPLE' , ADDRESSOF( GetObjectParameterivAPPLE ));
END Read_GL_APPLE_object_purgeable;

PROCEDURE Read_GL_ARB_matrix_palette*;
BEGIN
	GetProcAddress( 'glCurrentPaletteMatrixARB' , ADDRESSOF( CurrentPaletteMatrixARB ));
	GetProcAddress( 'glMatrixIndexubvARB' , ADDRESSOF( MatrixIndexubvARB ));
	GetProcAddress( 'glMatrixIndexusvARB' , ADDRESSOF( MatrixIndexusvARB ));
	GetProcAddress( 'glMatrixIndexuivARB' , ADDRESSOF( MatrixIndexuivARB ));
	GetProcAddress( 'glMatrixIndexPointerARB' , ADDRESSOF( MatrixIndexPointerARB ));
END Read_GL_ARB_matrix_palette;

PROCEDURE Read_GL_ARB_multisample*;
BEGIN
	GetProcAddress( 'glSampleCoverageARB' , ADDRESSOF( SampleCoverageARB ));
END Read_GL_ARB_multisample;

PROCEDURE Read_GL_ARB_multitexture*;
BEGIN
	GetProcAddress( 'glActiveTextureARB' , ADDRESSOF( ActiveTextureARB ));
	GetProcAddress( 'glClientActiveTextureARB' , ADDRESSOF( ClientActiveTextureARB ));
	GetProcAddress( 'glMultiTexCoord1dARB' , ADDRESSOF( MultiTexCoord1dARB ));
	GetProcAddress( 'glMultiTexCoord1dvARB' , ADDRESSOF( MultiTexCoord1dvARB ));
	GetProcAddress( 'glMultiTexCoord1fARB' , ADDRESSOF( MultiTexCoord1fARB ));
	GetProcAddress( 'glMultiTexCoord1fvARB' , ADDRESSOF( MultiTexCoord1fvARB ));
	GetProcAddress( 'glMultiTexCoord1iARB' , ADDRESSOF( MultiTexCoord1iARB ));
	GetProcAddress( 'glMultiTexCoord1ivARB' , ADDRESSOF( MultiTexCoord1ivARB ));
	GetProcAddress( 'glMultiTexCoord1sARB' , ADDRESSOF( MultiTexCoord1sARB ));
	GetProcAddress( 'glMultiTexCoord1svARB' , ADDRESSOF( MultiTexCoord1svARB ));
	GetProcAddress( 'glMultiTexCoord2dARB' , ADDRESSOF( MultiTexCoord2dARB ));
	GetProcAddress( 'glMultiTexCoord2dvARB' , ADDRESSOF( MultiTexCoord2dvARB ));
	GetProcAddress( 'glMultiTexCoord2fARB' , ADDRESSOF( MultiTexCoord2fARB ));
	GetProcAddress( 'glMultiTexCoord2fvARB' , ADDRESSOF( MultiTexCoord2fvARB ));
	GetProcAddress( 'glMultiTexCoord2iARB' , ADDRESSOF( MultiTexCoord2iARB ));
	GetProcAddress( 'glMultiTexCoord2ivARB' , ADDRESSOF( MultiTexCoord2ivARB ));
	GetProcAddress( 'glMultiTexCoord2sARB' , ADDRESSOF( MultiTexCoord2sARB ));
	GetProcAddress( 'glMultiTexCoord2svARB' , ADDRESSOF( MultiTexCoord2svARB ));
	GetProcAddress( 'glMultiTexCoord3dARB' , ADDRESSOF( MultiTexCoord3dARB ));
	GetProcAddress( 'glMultiTexCoord3dvARB' , ADDRESSOF( MultiTexCoord3dvARB ));
	GetProcAddress( 'glMultiTexCoord3fARB' , ADDRESSOF( MultiTexCoord3fARB ));
	GetProcAddress( 'glMultiTexCoord3fvARB' , ADDRESSOF( MultiTexCoord3fvARB ));
	GetProcAddress( 'glMultiTexCoord3iARB' , ADDRESSOF( MultiTexCoord3iARB ));
	GetProcAddress( 'glMultiTexCoord3ivARB' , ADDRESSOF( MultiTexCoord3ivARB ));
	GetProcAddress( 'glMultiTexCoord3sARB' , ADDRESSOF( MultiTexCoord3sARB ));
	GetProcAddress( 'glMultiTexCoord3svARB' , ADDRESSOF( MultiTexCoord3svARB ));
	GetProcAddress( 'glMultiTexCoord4dARB' , ADDRESSOF( MultiTexCoord4dARB ));
	GetProcAddress( 'glMultiTexCoord4dvARB' , ADDRESSOF( MultiTexCoord4dvARB ));
	GetProcAddress( 'glMultiTexCoord4fARB' , ADDRESSOF( MultiTexCoord4fARB ));
	GetProcAddress( 'glMultiTexCoord4fvARB' , ADDRESSOF( MultiTexCoord4fvARB ));
	GetProcAddress( 'glMultiTexCoord4iARB' , ADDRESSOF( MultiTexCoord4iARB ));
	GetProcAddress( 'glMultiTexCoord4ivARB' , ADDRESSOF( MultiTexCoord4ivARB ));
	GetProcAddress( 'glMultiTexCoord4sARB' , ADDRESSOF( MultiTexCoord4sARB ));
	GetProcAddress( 'glMultiTexCoord4svARB' , ADDRESSOF( MultiTexCoord4svARB ));
END Read_GL_ARB_multitexture;

PROCEDURE Read_GL_ARB_point_parameters*;
BEGIN
	GetProcAddress( 'glPointParameterfARB' , ADDRESSOF( PointParameterfARB ));
	GetProcAddress( 'glPointParameterfvARB' , ADDRESSOF( PointParameterfvARB ));
END Read_GL_ARB_point_parameters;

PROCEDURE Read_GL_ARB_texture_compression*;
BEGIN
	GetProcAddress( 'glCompressedTexImage3DARB' , ADDRESSOF( CompressedTexImage3DARB ));
	GetProcAddress( 'glCompressedTexImage2DARB' , ADDRESSOF( CompressedTexImage2DARB ));
	GetProcAddress( 'glCompressedTexImage1DARB' , ADDRESSOF( CompressedTexImage1DARB ));
	GetProcAddress( 'glCompressedTexSubImage3DARB' , ADDRESSOF( CompressedTexSubImage3DARB ));
	GetProcAddress( 'glCompressedTexSubImage2DARB' , ADDRESSOF( CompressedTexSubImage2DARB ));
	GetProcAddress( 'glCompressedTexSubImage1DARB' , ADDRESSOF( CompressedTexSubImage1DARB ));
	GetProcAddress( 'glGetCompressedTexImageARB' , ADDRESSOF( GetCompressedTexImageARB ));
END Read_GL_ARB_texture_compression;

PROCEDURE Read_GL_ARB_transpose_matrix*;
BEGIN
	GetProcAddress( 'glLoadTransposeMatrixfARB' , ADDRESSOF( LoadTransposeMatrixfARB ));
	GetProcAddress( 'glLoadTransposeMatrixdARB' , ADDRESSOF( LoadTransposeMatrixdARB ));
	GetProcAddress( 'glMultTransposeMatrixfARB' , ADDRESSOF( MultTransposeMatrixfARB ));
	GetProcAddress( 'glMultTransposeMatrixdARB' , ADDRESSOF( MultTransposeMatrixdARB ));
END Read_GL_ARB_transpose_matrix;

PROCEDURE Read_GL_ARB_vertex_blend*;
BEGIN
	GetProcAddress( 'glWeightbvARB' , ADDRESSOF( WeightbvARB ));
	GetProcAddress( 'glWeightsvARB' , ADDRESSOF( WeightsvARB ));
	GetProcAddress( 'glWeightivARB' , ADDRESSOF( WeightivARB ));
	GetProcAddress( 'glWeightfvARB' , ADDRESSOF( WeightfvARB ));
	GetProcAddress( 'glWeightdvARB' , ADDRESSOF( WeightdvARB ));
	GetProcAddress( 'glWeightubvARB' , ADDRESSOF( WeightubvARB ));
	GetProcAddress( 'glWeightusvARB' , ADDRESSOF( WeightusvARB ));
	GetProcAddress( 'glWeightuivARB' , ADDRESSOF( WeightuivARB ));
	GetProcAddress( 'glWeightPointerARB' , ADDRESSOF( WeightPointerARB ));
	GetProcAddress( 'glVertexBlendARB' , ADDRESSOF( VertexBlendARB ));
END Read_GL_ARB_vertex_blend;

PROCEDURE Read_GL_ARB_vertex_buffer_object*;
BEGIN
	GetProcAddress( 'glBindBufferARB' , ADDRESSOF( BindBufferARB ));
	GetProcAddress( 'glDeleteBuffersARB' , ADDRESSOF( DeleteBuffersARB ));
	GetProcAddress( 'glGenBuffersARB' , ADDRESSOF( GenBuffersARB ));
	GetProcAddress( 'glIsBufferARB' , ADDRESSOF( IsBufferARB ));
	GetProcAddress( 'glBufferDataARB' , ADDRESSOF( BufferDataARB ));
	GetProcAddress( 'glBufferSubDataARB' , ADDRESSOF( BufferSubDataARB ));
	GetProcAddress( 'glGetBufferSubDataARB' , ADDRESSOF( GetBufferSubDataARB ));
	GetProcAddress( 'glMapBufferARB' , ADDRESSOF( MapBufferARB ));
	GetProcAddress( 'glUnmapBufferARB' , ADDRESSOF( UnmapBufferARB ));
	GetProcAddress( 'glGetBufferParameterivARB' , ADDRESSOF( GetBufferParameterivARB ));
	GetProcAddress( 'glGetBufferPointervARB' , ADDRESSOF( GetBufferPointervARB ));
END Read_GL_ARB_vertex_buffer_object;

PROCEDURE Read_GL_ARB_vertex_program*;
BEGIN
	GetProcAddress( 'glVertexAttrib1dARB' , ADDRESSOF( VertexAttrib1dARB ));
	GetProcAddress( 'glVertexAttrib1dvARB' , ADDRESSOF( VertexAttrib1dvARB ));
	GetProcAddress( 'glVertexAttrib1fARB' , ADDRESSOF( VertexAttrib1fARB ));
	GetProcAddress( 'glVertexAttrib1fvARB' , ADDRESSOF( VertexAttrib1fvARB ));
	GetProcAddress( 'glVertexAttrib1sARB' , ADDRESSOF( VertexAttrib1sARB ));
	GetProcAddress( 'glVertexAttrib1svARB' , ADDRESSOF( VertexAttrib1svARB ));
	GetProcAddress( 'glVertexAttrib2dARB' , ADDRESSOF( VertexAttrib2dARB ));
	GetProcAddress( 'glVertexAttrib2dvARB' , ADDRESSOF( VertexAttrib2dvARB ));
	GetProcAddress( 'glVertexAttrib2fARB' , ADDRESSOF( VertexAttrib2fARB ));
	GetProcAddress( 'glVertexAttrib2fvARB' , ADDRESSOF( VertexAttrib2fvARB ));
	GetProcAddress( 'glVertexAttrib2sARB' , ADDRESSOF( VertexAttrib2sARB ));
	GetProcAddress( 'glVertexAttrib2svARB' , ADDRESSOF( VertexAttrib2svARB ));
	GetProcAddress( 'glVertexAttrib3dARB' , ADDRESSOF( VertexAttrib3dARB ));
	GetProcAddress( 'glVertexAttrib3dvARB' , ADDRESSOF( VertexAttrib3dvARB ));
	GetProcAddress( 'glVertexAttrib3fARB' , ADDRESSOF( VertexAttrib3fARB ));
	GetProcAddress( 'glVertexAttrib3fvARB' , ADDRESSOF( VertexAttrib3fvARB ));
	GetProcAddress( 'glVertexAttrib3sARB' , ADDRESSOF( VertexAttrib3sARB ));
	GetProcAddress( 'glVertexAttrib3svARB' , ADDRESSOF( VertexAttrib3svARB ));
	GetProcAddress( 'glVertexAttrib4NbvARB' , ADDRESSOF( VertexAttrib4NbvARB ));
	GetProcAddress( 'glVertexAttrib4NivARB' , ADDRESSOF( VertexAttrib4NivARB ));
	GetProcAddress( 'glVertexAttrib4NsvARB' , ADDRESSOF( VertexAttrib4NsvARB ));
	GetProcAddress( 'glVertexAttrib4NubARB' , ADDRESSOF( VertexAttrib4NubARB ));
	GetProcAddress( 'glVertexAttrib4NubvARB' , ADDRESSOF( VertexAttrib4NubvARB ));
	GetProcAddress( 'glVertexAttrib4NuivARB' , ADDRESSOF( VertexAttrib4NuivARB ));
	GetProcAddress( 'glVertexAttrib4NusvARB' , ADDRESSOF( VertexAttrib4NusvARB ));
	GetProcAddress( 'glVertexAttrib4bvARB' , ADDRESSOF( VertexAttrib4bvARB ));
	GetProcAddress( 'glVertexAttrib4dARB' , ADDRESSOF( VertexAttrib4dARB ));
	GetProcAddress( 'glVertexAttrib4dvARB' , ADDRESSOF( VertexAttrib4dvARB ));
	GetProcAddress( 'glVertexAttrib4fARB' , ADDRESSOF( VertexAttrib4fARB ));
	GetProcAddress( 'glVertexAttrib4fvARB' , ADDRESSOF( VertexAttrib4fvARB ));
	GetProcAddress( 'glVertexAttrib4ivARB' , ADDRESSOF( VertexAttrib4ivARB ));
	GetProcAddress( 'glVertexAttrib4sARB' , ADDRESSOF( VertexAttrib4sARB ));
	GetProcAddress( 'glVertexAttrib4svARB' , ADDRESSOF( VertexAttrib4svARB ));
	GetProcAddress( 'glVertexAttrib4ubvARB' , ADDRESSOF( VertexAttrib4ubvARB ));
	GetProcAddress( 'glVertexAttrib4uivARB' , ADDRESSOF( VertexAttrib4uivARB ));
	GetProcAddress( 'glVertexAttrib4usvARB' , ADDRESSOF( VertexAttrib4usvARB ));
	GetProcAddress( 'glVertexAttribPointerARB' , ADDRESSOF( VertexAttribPointerARB ));
	GetProcAddress( 'glEnableVertexAttribArrayARB' , ADDRESSOF( EnableVertexAttribArrayARB ));
	GetProcAddress( 'glDisableVertexAttribArrayARB' , ADDRESSOF( DisableVertexAttribArrayARB ));
	GetProcAddress( 'glProgramStringARB' , ADDRESSOF( ProgramStringARB ));
	GetProcAddress( 'glBindProgramARB' , ADDRESSOF( BindProgramARB ));
	GetProcAddress( 'glDeleteProgramsARB' , ADDRESSOF( DeleteProgramsARB ));
	GetProcAddress( 'glGenProgramsARB' , ADDRESSOF( GenProgramsARB ));
	GetProcAddress( 'glProgramEnvParameter4dARB' , ADDRESSOF( ProgramEnvParameter4dARB ));
	GetProcAddress( 'glProgramEnvParameter4dvARB' , ADDRESSOF( ProgramEnvParameter4dvARB ));
	GetProcAddress( 'glProgramEnvParameter4fARB' , ADDRESSOF( ProgramEnvParameter4fARB ));
	GetProcAddress( 'glProgramEnvParameter4fvARB' , ADDRESSOF( ProgramEnvParameter4fvARB ));
	GetProcAddress( 'glProgramLocalParameter4dARB' , ADDRESSOF( ProgramLocalParameter4dARB ));
	GetProcAddress( 'glProgramLocalParameter4dvARB' , ADDRESSOF( ProgramLocalParameter4dvARB ));
	GetProcAddress( 'glProgramLocalParameter4fARB' , ADDRESSOF( ProgramLocalParameter4fARB ));
	GetProcAddress( 'glProgramLocalParameter4fvARB' , ADDRESSOF( ProgramLocalParameter4fvARB ));
	GetProcAddress( 'glGetProgramEnvParameterdvARB' , ADDRESSOF( GetProgramEnvParameterdvARB ));
	GetProcAddress( 'glGetProgramEnvParameterfvARB' , ADDRESSOF( GetProgramEnvParameterfvARB ));
	GetProcAddress( 'glGetProgramLocalParameterdvARB' , ADDRESSOF( GetProgramLocalParameterdvARB ));
	GetProcAddress( 'glGetProgramLocalParameterfvARB' , ADDRESSOF( GetProgramLocalParameterfvARB ));
	GetProcAddress( 'glGetProgramivARB' , ADDRESSOF( GetProgramivARB ));
	GetProcAddress( 'glGetProgramStringARB' , ADDRESSOF( GetProgramStringARB ));
	GetProcAddress( 'glGetVertexAttribdvARB' , ADDRESSOF( GetVertexAttribdvARB ));
	GetProcAddress( 'glGetVertexAttribfvARB' , ADDRESSOF( GetVertexAttribfvARB ));
	GetProcAddress( 'glGetVertexAttribivARB' , ADDRESSOF( GetVertexAttribivARB ));
	GetProcAddress( 'glGetVertexAttribPointervARB' , ADDRESSOF( GetVertexAttribPointervARB ));
	GetProcAddress( 'glIsProgramARB' , ADDRESSOF( IsProgramARB ));
END Read_GL_ARB_vertex_program;

PROCEDURE Read_GL_ARB_window_pos*;
BEGIN
	GetProcAddress( 'glWindowPos2dARB' , ADDRESSOF( WindowPos2dARB ));
	GetProcAddress( 'glWindowPos2dvARB' , ADDRESSOF( WindowPos2dvARB ));
	GetProcAddress( 'glWindowPos2fARB' , ADDRESSOF( WindowPos2fARB ));
	GetProcAddress( 'glWindowPos2fvARB' , ADDRESSOF( WindowPos2fvARB ));
	GetProcAddress( 'glWindowPos2iARB' , ADDRESSOF( WindowPos2iARB ));
	GetProcAddress( 'glWindowPos2ivARB' , ADDRESSOF( WindowPos2ivARB ));
	GetProcAddress( 'glWindowPos2sARB' , ADDRESSOF( WindowPos2sARB ));
	GetProcAddress( 'glWindowPos2svARB' , ADDRESSOF( WindowPos2svARB ));
	GetProcAddress( 'glWindowPos3dARB' , ADDRESSOF( WindowPos3dARB ));
	GetProcAddress( 'glWindowPos3dvARB' , ADDRESSOF( WindowPos3dvARB ));
	GetProcAddress( 'glWindowPos3fARB' , ADDRESSOF( WindowPos3fARB ));
	GetProcAddress( 'glWindowPos3fvARB' , ADDRESSOF( WindowPos3fvARB ));
	GetProcAddress( 'glWindowPos3iARB' , ADDRESSOF( WindowPos3iARB ));
	GetProcAddress( 'glWindowPos3ivARB' , ADDRESSOF( WindowPos3ivARB ));
	GetProcAddress( 'glWindowPos3sARB' , ADDRESSOF( WindowPos3sARB ));
	GetProcAddress( 'glWindowPos3svARB' , ADDRESSOF( WindowPos3svARB ));
END Read_GL_ARB_window_pos;

PROCEDURE Read_GL_ARB_draw_buffers*;
BEGIN
	GetProcAddress( 'glDrawBuffersARB' , ADDRESSOF( DrawBuffersARB ));
END Read_GL_ARB_draw_buffers;

PROCEDURE Read_GL_ARB_color_buffer_float*;
BEGIN
	GetProcAddress( 'glClampColorARB' , ADDRESSOF( ClampColorARB ));
END Read_GL_ARB_color_buffer_float;

PROCEDURE Read_GL_ARB_Shader_Objects*;
BEGIN
	(*  GL_ARB_Shader_Objects *)
	GetProcAddress( 'glCreateShaderObjectARB' , ADDRESSOF( CreateShaderObjectARB ));
	GetProcAddress( 'glShaderSourceARB' , ADDRESSOF( ShaderSourceARB ));
	GetProcAddress( 'glCompileShaderARB' , ADDRESSOF( CompileShaderARB ));
	GetProcAddress( 'glDeleteObjectARB' , ADDRESSOF( DeleteObjectARB ));
	GetProcAddress( 'glGetHandleARB' , ADDRESSOF( GetHandleARB ));
	GetProcAddress( 'glDetachObjectARB' , ADDRESSOF( DetachObjectARB ));
	GetProcAddress( 'glCreateProgramObjectARB' , ADDRESSOF( CreateProgramObjectARB ));
	GetProcAddress( 'glAttachObjectARB' , ADDRESSOF( AttachObjectARB ));
	GetProcAddress( 'glLinkProgramARB' , ADDRESSOF( LinkProgramARB ));
	GetProcAddress( 'glUseProgramObjectARB' , ADDRESSOF( UseProgramObjectARB ));
	GetProcAddress( 'glValidateProgramARB' , ADDRESSOF( ValidateProgramARB ));
	GetProcAddress( 'glGetObjectParameterfvARB' , ADDRESSOF( GetObjectParameterfvARB ));
	GetProcAddress( 'glGetObjectParameterivARB' , ADDRESSOF( GetObjectParameterivARB ));
	GetProcAddress( 'glGetActiveUniformARB' , ADDRESSOF( GetActiveUniformARB ));
	GetProcAddress( 'glGetAttachedObjectsARB' , ADDRESSOF( GetAttachedObjectsARB ));
	GetProcAddress( 'glGetShaderSourceARB' , ADDRESSOF( GetShaderSourceARB ));
	GetProcAddress( 'glGetUniformfvARB' , ADDRESSOF( GetUniformfvARB ));
	GetProcAddress( 'glGetUniformivARB' , ADDRESSOF( GetUniformivARB ));
	GetProcAddress( 'glGetUniformLocationARB' , ADDRESSOF( GetUniformLocationARB ));
	GetProcAddress( 'glGetInfoLogARB' , ADDRESSOF( GetInfoLogARB ));
	GetProcAddress( 'glUniform1fARB' , ADDRESSOF( Uniform1fARB ));
	GetProcAddress( 'glUniform2fARB' , ADDRESSOF( Uniform2fARB ));
	GetProcAddress( 'glUniform3fARB' , ADDRESSOF( Uniform3fARB ));
	GetProcAddress( 'glUniform4fARB' , ADDRESSOF( Uniform4fARB ));
	GetProcAddress( 'glUniform1iARB' , ADDRESSOF( Uniform1iARB ));
	GetProcAddress( 'glUniform2iARB' , ADDRESSOF( Uniform2iARB ));
	GetProcAddress( 'glUniform3iARB' , ADDRESSOF( Uniform3iARB ));
	GetProcAddress( 'glUniform4iARB' , ADDRESSOF( Uniform4iARB ));
	GetProcAddress( 'glUniform1fvARB' , ADDRESSOF( Uniform1fvARB ));
	GetProcAddress( 'glUniform2fvARB' , ADDRESSOF( Uniform2fvARB ));
	GetProcAddress( 'glUniform3fvARB' , ADDRESSOF( Uniform3fvARB ));
	GetProcAddress( 'glUniform4fvARB' , ADDRESSOF( Uniform4fvARB ));
	GetProcAddress( 'glUniform1ivARB' , ADDRESSOF( Uniform1ivARB ));
	GetProcAddress( 'glUniform2ivARB' , ADDRESSOF( Uniform2ivARB ));
	GetProcAddress( 'glUniform3ivARB' , ADDRESSOF( Uniform3ivARB ));
	GetProcAddress( 'glUniform4ivARB' , ADDRESSOF( Uniform4ivARB ));
	GetProcAddress( 'glUniformMatrix2fvARB' , ADDRESSOF( UniformMatrix2fvARB ));
	GetProcAddress( 'glUniformMatrix3fvARB' , ADDRESSOF( UniformMatrix3fvARB ));
	GetProcAddress( 'glUniformMatrix4fvARB' , ADDRESSOF( UniformMatrix4fvARB ));
	(*  GL_ARB_vertex_shader *)
	GetProcAddress( 'glGetActiveAttribARB' , ADDRESSOF( GetActiveAttribARB ));
	GetProcAddress( 'glGetAttribLocationARB' , ADDRESSOF( GetAttribLocationARB ));
	GetProcAddress( 'glBindAttribLocationARB' , ADDRESSOF( BindAttribLocationARB ));
	GetProcAddress( 'glGetVertexAttribPointervARB' , ADDRESSOF( GetVertexAttribPointervARB ));
END Read_GL_ARB_Shader_Objects;

PROCEDURE Read_GL_ARB_occlusion_query*;
BEGIN
	GetProcAddress( 'glGenQueriesARB' , ADDRESSOF( GenQueriesARB ));
	GetProcAddress( 'glDeleteQueriesARB' , ADDRESSOF( DeleteQueriesARB ));
	GetProcAddress( 'glIsQueryARB' , ADDRESSOF( IsQueryARB ));
	GetProcAddress( 'glBeginQueryARB' , ADDRESSOF( BeginQueryARB ));
	GetProcAddress( 'glEndQueryARB' , ADDRESSOF( EndQueryARB ));
	GetProcAddress( 'glGetQueryivARB' , ADDRESSOF( GetQueryivARB ));
	GetProcAddress( 'glGetQueryObjectivARB' , ADDRESSOF( GetQueryObjectivARB ));
	GetProcAddress( 'glGetQueryObjectuivARB' , ADDRESSOF( GetQueryObjectuivARB ));
END Read_GL_ARB_occlusion_query;

PROCEDURE Read_GL_ARB_draw_instanced*;
BEGIN
	GetProcAddress( 'glDrawArraysInstancedARB' , ADDRESSOF( DrawArraysInstancedARB ));
	GetProcAddress( 'glDrawElementsInstancedARB' , ADDRESSOF( DrawElementsInstancedARB ));
END Read_GL_ARB_draw_instanced;

PROCEDURE Read_GL_ARB_framebuffer_object*;
BEGIN
	GetProcAddress( 'glIsRenderbuffer' , ADDRESSOF( IsRenderbuffer ));
	GetProcAddress( 'glBindRenderbuffer' , ADDRESSOF( BindRenderbuffer ));
	GetProcAddress( 'glDeleteRenderbuffers' , ADDRESSOF( DeleteRenderbuffers ));
	GetProcAddress( 'glGenRenderbuffers' , ADDRESSOF( GenRenderbuffers ));
	GetProcAddress( 'glRenderbufferStorage' , ADDRESSOF( RenderbufferStorage ));
	GetProcAddress( 'glGetRenderbufferParameteriv' , ADDRESSOF( GetRenderbufferParameteriv ));
	GetProcAddress( 'glIsFramebuffer' , ADDRESSOF( IsFramebuffer ));
	GetProcAddress( 'glBindFramebuffer' , ADDRESSOF( BindFramebuffer ));
	GetProcAddress( 'glDeleteFramebuffers' , ADDRESSOF( DeleteFramebuffers ));
	GetProcAddress( 'glGenFramebuffers' , ADDRESSOF( GenFramebuffers ));
	GetProcAddress( 'glCheckFramebufferStatus' , ADDRESSOF( CheckFramebufferStatus ));
	GetProcAddress( 'glFramebufferTexture1D' , ADDRESSOF( FramebufferTexture1D ));
	GetProcAddress( 'glFramebufferTexture2D' , ADDRESSOF( FramebufferTexture2D ));
	GetProcAddress( 'glFramebufferTexture3D' , ADDRESSOF( FramebufferTexture3D ));
	GetProcAddress( 'glFramebufferRenderbuffer' , ADDRESSOF( FramebufferRenderbuffer ));
	GetProcAddress( 'glGetFramebufferAttachmentParameteriv' , ADDRESSOF( GetFramebufferAttachmentParameteriv ));
	GetProcAddress( 'glGenerateMipmap' , ADDRESSOF( GenerateMipmap ));
	GetProcAddress( 'glBlitFramebuffer' , ADDRESSOF( BlitFramebuffer ));
	GetProcAddress( 'glRenderbufferStorageMultisample' , ADDRESSOF( RenderbufferStorageMultisample ));
	GetProcAddress( 'glFramebufferTextureLayer' , ADDRESSOF( FramebufferTextureLayer ));
END Read_GL_ARB_framebuffer_object;

PROCEDURE Read_GL_ARB_geometry_shader4*;
BEGIN
	GetProcAddress( 'glProgramParameteriARB' , ADDRESSOF( ProgramParameteriARB ));
	GetProcAddress( 'glFramebufferTextureARB' , ADDRESSOF( FramebufferTextureARB ));
	GetProcAddress( 'glFramebufferTextureLayerARB' , ADDRESSOF( FramebufferTextureLayerARB ));
	GetProcAddress( 'glFramebufferTextureFaceARB' , ADDRESSOF( FramebufferTextureFaceARB ));
END Read_GL_ARB_geometry_shader4;

PROCEDURE Read_GL_ARB_instanced_arrays*;
BEGIN
	GetProcAddress( 'glVertexAttribDivisorARB' , ADDRESSOF( VertexAttribDivisorARB ));
END Read_GL_ARB_instanced_arrays;

PROCEDURE Read_GL_ARB_map_buffer_range*;
BEGIN
	GetProcAddress( 'glMapBufferRange' , ADDRESSOF( MapBufferRange ));
	GetProcAddress( 'glFlushMappedBufferRange' , ADDRESSOF( FlushMappedBufferRange ));
END Read_GL_ARB_map_buffer_range;

PROCEDURE Read_GL_ARB_texture_buffer_object*;
BEGIN
	GetProcAddress( 'glTexBufferARB' , ADDRESSOF( TexBufferARB ));
END Read_GL_ARB_texture_buffer_object;

PROCEDURE Read_GL_ARB_vertex_array_object*;
BEGIN
	GetProcAddress( 'glBindVertexArray' , ADDRESSOF( BindVertexArray ));
	GetProcAddress( 'glDeleteVertexArrays' , ADDRESSOF( DeleteVertexArrays ));
	GetProcAddress( 'glGenVertexArrays' , ADDRESSOF( GenVertexArrays ));
	GetProcAddress( 'glIsVertexArray' , ADDRESSOF( IsVertexArray ));
END Read_GL_ARB_vertex_array_object;

PROCEDURE Read_GL_ARB_uniform_buffer_object*;
BEGIN
	GetProcAddress( 'glGetUniformIndices' , ADDRESSOF( GetUniformIndices ));
	GetProcAddress( 'glGetActiveUniformsiv' , ADDRESSOF( GetActiveUniformsiv ));
	GetProcAddress( 'glGetActiveUniformName' , ADDRESSOF( GetActiveUniformName ));
	GetProcAddress( 'glGetUniformBlockIndex' , ADDRESSOF( GetUniformBlockIndex ));
	GetProcAddress( 'glGetActiveUniformBlockiv' , ADDRESSOF( GetActiveUniformBlockiv ));
	GetProcAddress( 'glGetActiveUniformBlockName' , ADDRESSOF( GetActiveUniformBlockName ));
	GetProcAddress( 'glUniformBlockBinding' , ADDRESSOF( UniformBlockBinding ));
END Read_GL_ARB_uniform_buffer_object;

PROCEDURE Read_GL_ARB_copy_buffer*;
BEGIN
	GetProcAddress( 'glCopyBufferSubData' , ADDRESSOF( CopyBufferSubData ));
END Read_GL_ARB_copy_buffer;

PROCEDURE Read_GL_ARB_draw_elements_base_vertex*;
BEGIN
	GetProcAddress( 'glDrawElementsBaseVertex' , ADDRESSOF( DrawElementsBaseVertex ));
	GetProcAddress( 'glDrawRangeElementsBaseVertex' , ADDRESSOF( DrawRangeElementsBaseVertex ));
	GetProcAddress( 'glDrawElementsInstancedBaseVertex' , ADDRESSOF( DrawElementsInstancedBaseVertex ));
	GetProcAddress( 'glMultiDrawElementsBaseVertex' , ADDRESSOF( MultiDrawElementsBaseVertex ));
END Read_GL_ARB_draw_elements_base_vertex;

PROCEDURE Read_GL_ARB_provoking_vertex*;
BEGIN
	GetProcAddress( 'glProvokingVertex' , ADDRESSOF( ProvokingVertex ));
END Read_GL_ARB_provoking_vertex;

PROCEDURE Read_GL_ARB_sync*;
BEGIN
	GetProcAddress( 'glFenceSync' , ADDRESSOF( FenceSync ));
	GetProcAddress( 'glIsSync' , ADDRESSOF( IsSync ));
	GetProcAddress( 'glDeleteSync' , ADDRESSOF( DeleteSync ));
	GetProcAddress( 'glClientWaitSync' , ADDRESSOF( ClientWaitSync ));
	GetProcAddress( 'glWaitSync' , ADDRESSOF( WaitSync ));
	GetProcAddress( 'glGetInteger64v' , ADDRESSOF( GetInteger64v ));
	GetProcAddress( 'glGetSynciv' , ADDRESSOF( GetSynciv ));
END Read_GL_ARB_sync;

PROCEDURE Read_GL_ARB_texture_multisample*;
BEGIN
	GetProcAddress( 'glTexImage2DMultisample' , ADDRESSOF( TexImage2DMultisample ));
	GetProcAddress( 'glTexImage3DMultisample' , ADDRESSOF( TexImage3DMultisample ));
	GetProcAddress( 'glGetMultisamplefv' , ADDRESSOF( GetMultisamplefv ));
	GetProcAddress( 'glSampleMaski' , ADDRESSOF( SampleMaski ));
END Read_GL_ARB_texture_multisample;

PROCEDURE Read_GL_ARB_draw_buffers_blend*;
BEGIN
	GetProcAddress( 'glBlendEquationiARB' , ADDRESSOF( BlendEquationiARB ));
	GetProcAddress( 'glBlendEquationSeparateiARB' , ADDRESSOF( BlendEquationSeparateiARB ));
	GetProcAddress( 'glBlendFunciARB' , ADDRESSOF( BlendFunciARB ));
	GetProcAddress( 'glBlendFuncSeparateiARB' , ADDRESSOF( BlendFuncSeparateiARB ));
END Read_GL_ARB_draw_buffers_blend;

PROCEDURE Read_GL_ARB_sample_shading*;
BEGIN
	GetProcAddress( 'glMinSampleShadingARB' , ADDRESSOF( MinSampleShadingARB ));
END Read_GL_ARB_sample_shading;

PROCEDURE Read_GL_ARB_sample_locations*;
BEGIN
	GetProcAddress( 'glFramebufferSampleLocationsfvARB' , ADDRESSOF( FramebufferSampleLocationsfvARB ));
	GetProcAddress( 'glNamedFramebufferSampleLocationsfvARB' , ADDRESSOF( NamedFramebufferSampleLocationsfvARB ));
	GetProcAddress( 'glEvaluateDepthValuesARB' , ADDRESSOF( EvaluateDepthValuesARB ));
END Read_GL_ARB_sample_locations;

PROCEDURE Read_GL_ARB_shading_language_include*;
BEGIN
	GetProcAddress( 'glNamedStringARB' , ADDRESSOF( NamedStringARB ));
	GetProcAddress( 'glDeleteNamedStringARB' , ADDRESSOF( DeleteNamedStringARB ));
	GetProcAddress( 'glCompileShaderIncludeARB' , ADDRESSOF( CompileShaderIncludeARB ));
	GetProcAddress( 'glIsNamedStringARB' , ADDRESSOF( IsNamedStringARB ));
	GetProcAddress( 'glGetNamedStringARB' , ADDRESSOF( GetNamedStringARB ));
	GetProcAddress( 'glGetNamedStringivARB' , ADDRESSOF( GetNamedStringivARB ));
END Read_GL_ARB_shading_language_include;

PROCEDURE Read_GL_ARB_sparse_texture*;
BEGIN
	GetProcAddress( 'glTexPageCommitmentARB' , ADDRESSOF( TexPageCommitmentARB ));
END Read_GL_ARB_sparse_texture;

PROCEDURE Read_GL_ARB_sparse_buffer*;
BEGIN
	GetProcAddress( 'glBufferPageCommitmentARB' , ADDRESSOF( BufferPageCommitmentARB ));
	GetProcAddress( 'glNamedBufferPageCommitmentEXT' , ADDRESSOF( NamedBufferPageCommitmentEXT ));
	GetProcAddress( 'glNamedBufferPageCommitmentARB' , ADDRESSOF( NamedBufferPageCommitmentARB ));
END Read_GL_ARB_sparse_buffer;

PROCEDURE Read_GL_KHR_blend_equation_advanced*;
BEGIN
	GetProcAddress( 'glBlendBarrierKHR' , ADDRESSOF( BlendBarrierKHR ));
END Read_GL_KHR_blend_equation_advanced;

PROCEDURE Read_GL_ARB_blend_func_extended*;
BEGIN
	GetProcAddress( 'glBindFragDataLocationIndexed' , ADDRESSOF( BindFragDataLocationIndexed ));
	GetProcAddress( 'glGetFragDataIndex' , ADDRESSOF( GetFragDataIndex ));
END Read_GL_ARB_blend_func_extended;

PROCEDURE Read_GL_ARB_sampler_objects*;
BEGIN
	GetProcAddress( 'glGenSamplers' , ADDRESSOF( GenSamplers ));
	GetProcAddress( 'glDeleteSamplers' , ADDRESSOF( DeleteSamplers ));
	GetProcAddress( 'glIsSampler' , ADDRESSOF( IsSampler ));
	GetProcAddress( 'glBindSampler' , ADDRESSOF( BindSampler ));
	GetProcAddress( 'glSamplerParameteri' , ADDRESSOF( SamplerParameteri ));
	GetProcAddress( 'glSamplerParameteriv' , ADDRESSOF( SamplerParameteriv ));
	GetProcAddress( 'glSamplerParameterf' , ADDRESSOF( SamplerParameterf ));
	GetProcAddress( 'glSamplerParameterfv' , ADDRESSOF( SamplerParameterfv ));
	GetProcAddress( 'glSamplerParameterIiv' , ADDRESSOF( SamplerParameterIiv ));
	GetProcAddress( 'glSamplerParameterIuiv' , ADDRESSOF( SamplerParameterIuiv ));
	GetProcAddress( 'glGetSamplerParameteriv' , ADDRESSOF( GetSamplerParameteriv ));
	GetProcAddress( 'glGetSamplerParameterIiv' , ADDRESSOF( GetSamplerParameterIiv ));
	GetProcAddress( 'glGetSamplerParameterfv' , ADDRESSOF( GetSamplerParameterfv ));
	GetProcAddress( 'glGetSamplerParameterIuiv' , ADDRESSOF( GetSamplerParameterIuiv ));
END Read_GL_ARB_sampler_objects;

PROCEDURE Read_GL_ARB_timer_query*;
BEGIN
	GetProcAddress( 'glQueryCounter' , ADDRESSOF( QueryCounter ));
	GetProcAddress( 'glGetQueryObjecti64v' , ADDRESSOF( GetQueryObjecti64v ));
	GetProcAddress( 'glGetQueryObjectui64v' , ADDRESSOF( GetQueryObjectui64v ));
END Read_GL_ARB_timer_query;

PROCEDURE Read_GL_ARB_vertex_type_2_10_10_10_rev*;
BEGIN
	GetProcAddress( 'glVertexP2ui' , ADDRESSOF( VertexP2ui ));
	GetProcAddress( 'glVertexP2uiv' , ADDRESSOF( VertexP2uiv ));
	GetProcAddress( 'glVertexP3ui' , ADDRESSOF( VertexP3ui ));
	GetProcAddress( 'glVertexP3uiv' , ADDRESSOF( VertexP3uiv ));
	GetProcAddress( 'glVertexP4ui' , ADDRESSOF( VertexP4ui ));
	GetProcAddress( 'glVertexP4uiv' , ADDRESSOF( VertexP4uiv ));
	GetProcAddress( 'glTexCoordP1ui' , ADDRESSOF( TexCoordP1ui ));
	GetProcAddress( 'glTexCoordP1uiv' , ADDRESSOF( TexCoordP1uiv ));
	GetProcAddress( 'glTexCoordP2ui' , ADDRESSOF( TexCoordP2ui ));
	GetProcAddress( 'glTexCoordP2uiv' , ADDRESSOF( TexCoordP2uiv ));
	GetProcAddress( 'glTexCoordP3ui' , ADDRESSOF( TexCoordP3ui ));
	GetProcAddress( 'glTexCoordP3uiv' , ADDRESSOF( TexCoordP3uiv ));
	GetProcAddress( 'glTexCoordP4ui' , ADDRESSOF( TexCoordP4ui ));
	GetProcAddress( 'glTexCoordP4uiv' , ADDRESSOF( TexCoordP4uiv ));
	GetProcAddress( 'glMultiTexCoordP1ui' , ADDRESSOF( MultiTexCoordP1ui ));
	GetProcAddress( 'glMultiTexCoordP1uiv' , ADDRESSOF( MultiTexCoordP1uiv ));
	GetProcAddress( 'glMultiTexCoordP2ui' , ADDRESSOF( MultiTexCoordP2ui ));
	GetProcAddress( 'glMultiTexCoordP2uiv' , ADDRESSOF( MultiTexCoordP2uiv ));
	GetProcAddress( 'glMultiTexCoordP3ui' , ADDRESSOF( MultiTexCoordP3ui ));
	GetProcAddress( 'glMultiTexCoordP3uiv' , ADDRESSOF( MultiTexCoordP3uiv ));
	GetProcAddress( 'glMultiTexCoordP4ui' , ADDRESSOF( MultiTexCoordP4ui ));
	GetProcAddress( 'glMultiTexCoordP4uiv' , ADDRESSOF( MultiTexCoordP4uiv ));
	GetProcAddress( 'glNormalP3ui' , ADDRESSOF( NormalP3ui ));
	GetProcAddress( 'glNormalP3uiv' , ADDRESSOF( NormalP3uiv ));
	GetProcAddress( 'glColorP3ui' , ADDRESSOF( ColorP3ui ));
	GetProcAddress( 'glColorP3uiv' , ADDRESSOF( ColorP3uiv ));
	GetProcAddress( 'glColorP4ui' , ADDRESSOF( ColorP4ui ));
	GetProcAddress( 'glColorP4uiv' , ADDRESSOF( ColorP4uiv ));
	GetProcAddress( 'glSecondaryColorP3ui' , ADDRESSOF( SecondaryColorP3ui ));
	GetProcAddress( 'glSecondaryColorP3uiv' , ADDRESSOF( SecondaryColorP3uiv ));
	GetProcAddress( 'glVertexAttribP1ui' , ADDRESSOF( VertexAttribP1ui ));
	GetProcAddress( 'glVertexAttribP1uiv' , ADDRESSOF( VertexAttribP1uiv ));
	GetProcAddress( 'glVertexAttribP2ui' , ADDRESSOF( VertexAttribP2ui ));
	GetProcAddress( 'glVertexAttribP2uiv' , ADDRESSOF( VertexAttribP2uiv ));
	GetProcAddress( 'glVertexAttribP3ui' , ADDRESSOF( VertexAttribP3ui ));
	GetProcAddress( 'glVertexAttribP3uiv' , ADDRESSOF( VertexAttribP3uiv ));
	GetProcAddress( 'glVertexAttribP4ui' , ADDRESSOF( VertexAttribP4ui ));
	GetProcAddress( 'glVertexAttribP4uiv' , ADDRESSOF( VertexAttribP4uiv ));
END Read_GL_ARB_vertex_type_2_10_10_10_rev;

PROCEDURE Read_GL_ARB_draw_indirect*;
BEGIN
	GetProcAddress( 'glDrawArraysIndirect' , ADDRESSOF( DrawArraysIndirect ));
	GetProcAddress( 'glDrawElementsIndirect' , ADDRESSOF( DrawElementsIndirect ));
END Read_GL_ARB_draw_indirect;

PROCEDURE Read_GL_ARB_gpu_shader_fp64*;
BEGIN
	GetProcAddress( 'glUniform1d' , ADDRESSOF( Uniform1d ));
	GetProcAddress( 'glUniform2d' , ADDRESSOF( Uniform2d ));
	GetProcAddress( 'glUniform3d' , ADDRESSOF( Uniform3d ));
	GetProcAddress( 'glUniform4d' , ADDRESSOF( Uniform4d ));
	GetProcAddress( 'glUniform1dv' , ADDRESSOF( Uniform1dv ));
	GetProcAddress( 'glUniform2dv' , ADDRESSOF( Uniform2dv ));
	GetProcAddress( 'glUniform3dv' , ADDRESSOF( Uniform3dv ));
	GetProcAddress( 'glUniform4dv' , ADDRESSOF( Uniform4dv ));
	GetProcAddress( 'glUniformMatrix2dv' , ADDRESSOF( UniformMatrix2dv ));
	GetProcAddress( 'glUniformMatrix3dv' , ADDRESSOF( UniformMatrix3dv ));
	GetProcAddress( 'glUniformMatrix4dv' , ADDRESSOF( UniformMatrix4dv ));
	GetProcAddress( 'glUniformMatrix2x3dv' , ADDRESSOF( UniformMatrix2x3dv ));
	GetProcAddress( 'glUniformMatrix2x4dv' , ADDRESSOF( UniformMatrix2x4dv ));
	GetProcAddress( 'glUniformMatrix3x2dv' , ADDRESSOF( UniformMatrix3x2dv ));
	GetProcAddress( 'glUniformMatrix3x4dv' , ADDRESSOF( UniformMatrix3x4dv ));
	GetProcAddress( 'glUniformMatrix4x2dv' , ADDRESSOF( UniformMatrix4x2dv ));
	GetProcAddress( 'glUniformMatrix4x3dv' , ADDRESSOF( UniformMatrix4x3dv ));
	GetProcAddress( 'glGetUniformdv' , ADDRESSOF( GetUniformdv ));
END Read_GL_ARB_gpu_shader_fp64;

PROCEDURE Read_GL_ARB_gpu_shader_int64*;
BEGIN
	GetProcAddress( 'glUniform1i64ARB' , ADDRESSOF( Uniform1i64ARB ));
	GetProcAddress( 'glUniform2i64ARB' , ADDRESSOF( Uniform2i64ARB ));
	GetProcAddress( 'glUniform3i64ARB' , ADDRESSOF( Uniform3i64ARB ));
	GetProcAddress( 'glUniform4i64ARB' , ADDRESSOF( Uniform4i64ARB ));
	GetProcAddress( 'glUniform1i64vARB' , ADDRESSOF( Uniform1i64vARB ));
	GetProcAddress( 'glUniform2i64vARB' , ADDRESSOF( Uniform2i64vARB ));
	GetProcAddress( 'glUniform3i64vARB' , ADDRESSOF( Uniform3i64vARB ));
	GetProcAddress( 'glUniform4i64vARB' , ADDRESSOF( Uniform4i64vARB ));
	GetProcAddress( 'glUniform1ui64ARB' , ADDRESSOF( Uniform1ui64ARB ));
	GetProcAddress( 'glUniform2ui64ARB' , ADDRESSOF( Uniform2ui64ARB ));
	GetProcAddress( 'glUniform3ui64ARB' , ADDRESSOF( Uniform3ui64ARB ));
	GetProcAddress( 'glUniform4ui64ARB' , ADDRESSOF( Uniform4ui64ARB ));
	GetProcAddress( 'glUniform1ui64vARB' , ADDRESSOF( Uniform1ui64vARB ));
	GetProcAddress( 'glUniform2ui64vARB' , ADDRESSOF( Uniform2ui64vARB ));
	GetProcAddress( 'glUniform3ui64vARB' , ADDRESSOF( Uniform3ui64vARB ));
	GetProcAddress( 'glUniform4ui64vARB' , ADDRESSOF( Uniform4ui64vARB ));
	GetProcAddress( 'glGetUniformi64vARB' , ADDRESSOF( GetUniformi64vARB ));
	GetProcAddress( 'glGetUniformui64vARB' , ADDRESSOF( GetUniformui64vARB ));
	GetProcAddress( 'glGetnUniformi64vARB' , ADDRESSOF( GetnUniformi64vARB ));
	GetProcAddress( 'glGetnUniformui64vARB' , ADDRESSOF( GetnUniformui64vARB ));
	GetProcAddress( 'glProgramUniform1i64ARB' , ADDRESSOF( ProgramUniform1i64ARB ));
	GetProcAddress( 'glProgramUniform2i64ARB' , ADDRESSOF( ProgramUniform2i64ARB ));
	GetProcAddress( 'glProgramUniform3i64ARB' , ADDRESSOF( ProgramUniform3i64ARB ));
	GetProcAddress( 'glProgramUniform4i64ARB' , ADDRESSOF( ProgramUniform4i64ARB ));
	GetProcAddress( 'glProgramUniform1i64vARB' , ADDRESSOF( ProgramUniform1i64vARB ));
	GetProcAddress( 'glProgramUniform2i64vARB' , ADDRESSOF( ProgramUniform2i64vARB ));
	GetProcAddress( 'glProgramUniform3i64vARB' , ADDRESSOF( ProgramUniform3i64vARB ));
	GetProcAddress( 'glProgramUniform4i64vARB' , ADDRESSOF( ProgramUniform4i64vARB ));
	GetProcAddress( 'glProgramUniform1ui64ARB' , ADDRESSOF( ProgramUniform1ui64ARB ));
	GetProcAddress( 'glProgramUniform2ui64ARB' , ADDRESSOF( ProgramUniform2ui64ARB ));
	GetProcAddress( 'glProgramUniform3ui64ARB' , ADDRESSOF( ProgramUniform3ui64ARB ));
	GetProcAddress( 'glProgramUniform4ui64ARB' , ADDRESSOF( ProgramUniform4ui64ARB ));
	GetProcAddress( 'glProgramUniform1ui64vARB' , ADDRESSOF( ProgramUniform1ui64vARB ));
	GetProcAddress( 'glProgramUniform2ui64vARB' , ADDRESSOF( ProgramUniform2ui64vARB ));
	GetProcAddress( 'glProgramUniform3ui64vARB' , ADDRESSOF( ProgramUniform3ui64vARB ));
	GetProcAddress( 'glProgramUniform4ui64vARB' , ADDRESSOF( ProgramUniform4ui64vARB ));
END Read_GL_ARB_gpu_shader_int64;

PROCEDURE Read_GL_ARB_shader_subroutine*;
BEGIN
	GetProcAddress( 'glGetSubroutineUniformLocation' , ADDRESSOF( GetSubroutineUniformLocation ));
	GetProcAddress( 'glGetSubroutineIndex' , ADDRESSOF( GetSubroutineIndex ));
	GetProcAddress( 'glGetActiveSubroutineUniformiv' , ADDRESSOF( GetActiveSubroutineUniformiv ));
	GetProcAddress( 'glGetActiveSubroutineUniformName' , ADDRESSOF( GetActiveSubroutineUniformName ));
	GetProcAddress( 'glGetActiveSubroutineName' , ADDRESSOF( GetActiveSubroutineName ));
	GetProcAddress( 'glUniformSubroutinesuiv' , ADDRESSOF( UniformSubroutinesuiv ));
	GetProcAddress( 'glGetUniformSubroutineuiv' , ADDRESSOF( GetUniformSubroutineuiv ));
	GetProcAddress( 'glGetProgramStageiv' , ADDRESSOF( GetProgramStageiv ));
END Read_GL_ARB_shader_subroutine;

PROCEDURE Read_GL_ARB_tessellation_shader*;
BEGIN
	GetProcAddress( 'glPatchParameteri' , ADDRESSOF( PatchParameteri ));
	GetProcAddress( 'glPatchParameterfv' , ADDRESSOF( PatchParameterfv ));
END Read_GL_ARB_tessellation_shader;

PROCEDURE Read_GL_ARB_transform_feedback2*;
BEGIN
	GetProcAddress( 'glBindTransformFeedback' , ADDRESSOF( BindTransformFeedback ));
	GetProcAddress( 'glDeleteTransformFeedbacks' , ADDRESSOF( DeleteTransformFeedbacks ));
	GetProcAddress( 'glGenTransformFeedbacks' , ADDRESSOF( GenTransformFeedbacks ));
	GetProcAddress( 'glIsTransformFeedback' , ADDRESSOF( IsTransformFeedback ));
	GetProcAddress( 'glPauseTransformFeedback' , ADDRESSOF( PauseTransformFeedback ));
	GetProcAddress( 'glResumeTransformFeedback' , ADDRESSOF( ResumeTransformFeedback ));
	GetProcAddress( 'glDrawTransformFeedback' , ADDRESSOF( DrawTransformFeedback ));
END Read_GL_ARB_transform_feedback2;

PROCEDURE Read_GL_ARB_transform_feedback3*;
BEGIN
	GetProcAddress( 'glDrawTransformFeedbackStream' , ADDRESSOF( DrawTransformFeedbackStream ));
	GetProcAddress( 'glBeginQueryIndexed' , ADDRESSOF( BeginQueryIndexed ));
	GetProcAddress( 'glEndQueryIndexed' , ADDRESSOF( EndQueryIndexed ));
	GetProcAddress( 'glGetQueryIndexediv' , ADDRESSOF( GetQueryIndexediv ));
END Read_GL_ARB_transform_feedback3;

PROCEDURE Read_GL_ARB_ES2_compatibility*;
BEGIN
	GetProcAddress( 'glReleaseShaderCompiler' , ADDRESSOF( ReleaseShaderCompiler ));
	GetProcAddress( 'glShaderBinary' , ADDRESSOF( ShaderBinary ));
	GetProcAddress( 'glGetShaderPrecisionFormat' , ADDRESSOF( GetShaderPrecisionFormat ));
	GetProcAddress( 'glDepthRangef' , ADDRESSOF( DepthRangef ));
	GetProcAddress( 'glClearDepthf' , ADDRESSOF( ClearDepthf ));
END Read_GL_ARB_ES2_compatibility;

PROCEDURE Read_GL_ARB_ES3_2_compatibility*;
BEGIN
	GetProcAddress( 'glPrimitiveBoundingBoxARB' , ADDRESSOF( PrimitiveBoundingBoxARB ));
END Read_GL_ARB_ES3_2_compatibility;

PROCEDURE Read_GL_ARB_parallel_shader_compile*;
BEGIN
	GetProcAddress( 'glMaxShaderCompilerThreadsARB' , ADDRESSOF( MaxShaderCompilerThreadsARB ));
END Read_GL_ARB_parallel_shader_compile;

PROCEDURE Read_GL_ARB_get_program_binary*;
BEGIN
	GetProcAddress( 'glGetProgramBinary' , ADDRESSOF( GetProgramBinary ));
	GetProcAddress( 'glProgramBinary' , ADDRESSOF( ProgramBinary ));
	GetProcAddress( 'glProgramParameteri' , ADDRESSOF( ProgramParameteri ));
END Read_GL_ARB_get_program_binary;

PROCEDURE Read_GL_ARB_separate_shader_objects*;
BEGIN
	GetProcAddress( 'glUseProgramStages' , ADDRESSOF( UseProgramStages ));
	GetProcAddress( 'glActiveShaderProgram' , ADDRESSOF( ActiveShaderProgram ));
	GetProcAddress( 'glCreateShaderProgramv' , ADDRESSOF( CreateShaderProgramv ));
	GetProcAddress( 'glBindProgramPipeline' , ADDRESSOF( BindProgramPipeline ));
	GetProcAddress( 'glDeleteProgramPipelines' , ADDRESSOF( DeleteProgramPipelines ));
	GetProcAddress( 'glGenProgramPipelines' , ADDRESSOF( GenProgramPipelines ));
	GetProcAddress( 'glIsProgramPipeline' , ADDRESSOF( IsProgramPipeline ));
	GetProcAddress( 'glGetProgramPipelineiv' , ADDRESSOF( GetProgramPipelineiv ));
	GetProcAddress( 'glProgramUniform1i' , ADDRESSOF( ProgramUniform1i ));
	GetProcAddress( 'glProgramUniform1iv' , ADDRESSOF( ProgramUniform1iv ));
	GetProcAddress( 'glProgramUniform1f' , ADDRESSOF( ProgramUniform1f ));
	GetProcAddress( 'glProgramUniform1fv' , ADDRESSOF( ProgramUniform1fv ));
	GetProcAddress( 'glProgramUniform1d' , ADDRESSOF( ProgramUniform1d ));
	GetProcAddress( 'glProgramUniform1dv' , ADDRESSOF( ProgramUniform1dv ));
	GetProcAddress( 'glProgramUniform1ui' , ADDRESSOF( ProgramUniform1ui ));
	GetProcAddress( 'glProgramUniform1uiv' , ADDRESSOF( ProgramUniform1uiv ));
	GetProcAddress( 'glProgramUniform2i' , ADDRESSOF( ProgramUniform2i ));
	GetProcAddress( 'glProgramUniform2iv' , ADDRESSOF( ProgramUniform2iv ));
	GetProcAddress( 'glProgramUniform2f' , ADDRESSOF( ProgramUniform2f ));
	GetProcAddress( 'glProgramUniform2fv' , ADDRESSOF( ProgramUniform2fv ));
	GetProcAddress( 'glProgramUniform2d' , ADDRESSOF( ProgramUniform2d ));
	GetProcAddress( 'glProgramUniform2dv' , ADDRESSOF( ProgramUniform2dv ));
	GetProcAddress( 'glProgramUniform2ui' , ADDRESSOF( ProgramUniform2ui ));
	GetProcAddress( 'glProgramUniform2uiv' , ADDRESSOF( ProgramUniform2uiv ));
	GetProcAddress( 'glProgramUniform3i' , ADDRESSOF( ProgramUniform3i ));
	GetProcAddress( 'glProgramUniform3iv' , ADDRESSOF( ProgramUniform3iv ));
	GetProcAddress( 'glProgramUniform3f' , ADDRESSOF( ProgramUniform3f ));
	GetProcAddress( 'glProgramUniform3fv' , ADDRESSOF( ProgramUniform3fv ));
	GetProcAddress( 'glProgramUniform3d' , ADDRESSOF( ProgramUniform3d ));
	GetProcAddress( 'glProgramUniform3dv' , ADDRESSOF( ProgramUniform3dv ));
	GetProcAddress( 'glProgramUniform3ui' , ADDRESSOF( ProgramUniform3ui ));
	GetProcAddress( 'glProgramUniform3uiv' , ADDRESSOF( ProgramUniform3uiv ));
	GetProcAddress( 'glProgramUniform4i' , ADDRESSOF( ProgramUniform4i ));
	GetProcAddress( 'glProgramUniform4iv' , ADDRESSOF( ProgramUniform4iv ));
	GetProcAddress( 'glProgramUniform4f' , ADDRESSOF( ProgramUniform4f ));
	GetProcAddress( 'glProgramUniform4fv' , ADDRESSOF( ProgramUniform4fv ));
	GetProcAddress( 'glProgramUniform4d' , ADDRESSOF( ProgramUniform4d ));
	GetProcAddress( 'glProgramUniform4dv' , ADDRESSOF( ProgramUniform4dv ));
	GetProcAddress( 'glProgramUniform4ui' , ADDRESSOF( ProgramUniform4ui ));
	GetProcAddress( 'glProgramUniform4uiv' , ADDRESSOF( ProgramUniform4uiv ));
	GetProcAddress( 'glProgramUniformMatrix2fv' , ADDRESSOF( ProgramUniformMatrix2fv ));
	GetProcAddress( 'glProgramUniformMatrix3fv' , ADDRESSOF( ProgramUniformMatrix3fv ));
	GetProcAddress( 'glProgramUniformMatrix4fv' , ADDRESSOF( ProgramUniformMatrix4fv ));
	GetProcAddress( 'glProgramUniformMatrix2dv' , ADDRESSOF( ProgramUniformMatrix2dv ));
	GetProcAddress( 'glProgramUniformMatrix3dv' , ADDRESSOF( ProgramUniformMatrix3dv ));
	GetProcAddress( 'glProgramUniformMatrix4dv' , ADDRESSOF( ProgramUniformMatrix4dv ));
	GetProcAddress( 'glProgramUniformMatrix2x3fv' , ADDRESSOF( ProgramUniformMatrix2x3fv ));
	GetProcAddress( 'glProgramUniformMatrix3x2fv' , ADDRESSOF( ProgramUniformMatrix3x2fv ));
	GetProcAddress( 'glProgramUniformMatrix2x4fv' , ADDRESSOF( ProgramUniformMatrix2x4fv ));
	GetProcAddress( 'glProgramUniformMatrix4x2fv' , ADDRESSOF( ProgramUniformMatrix4x2fv ));
	GetProcAddress( 'glProgramUniformMatrix3x4fv' , ADDRESSOF( ProgramUniformMatrix3x4fv ));
	GetProcAddress( 'glProgramUniformMatrix4x3fv' , ADDRESSOF( ProgramUniformMatrix4x3fv ));
	GetProcAddress( 'glProgramUniformMatrix2x3dv' , ADDRESSOF( ProgramUniformMatrix2x3dv ));
	GetProcAddress( 'glProgramUniformMatrix3x2dv' , ADDRESSOF( ProgramUniformMatrix3x2dv ));
	GetProcAddress( 'glProgramUniformMatrix2x4dv' , ADDRESSOF( ProgramUniformMatrix2x4dv ));
	GetProcAddress( 'glProgramUniformMatrix4x2dv' , ADDRESSOF( ProgramUniformMatrix4x2dv ));
	GetProcAddress( 'glProgramUniformMatrix3x4dv' , ADDRESSOF( ProgramUniformMatrix3x4dv ));
	GetProcAddress( 'glProgramUniformMatrix4x3dv' , ADDRESSOF( ProgramUniformMatrix4x3dv ));
	GetProcAddress( 'glValidateProgramPipeline' , ADDRESSOF( ValidateProgramPipeline ));
	GetProcAddress( 'glGetProgramPipelineInfoLog' , ADDRESSOF( GetProgramPipelineInfoLog ));
END Read_GL_ARB_separate_shader_objects;

PROCEDURE Read_GL_ARB_vertex_attrib_64bit*;
BEGIN
	GetProcAddress( 'glVertexAttribL1d' , ADDRESSOF( VertexAttribL1d ));
	GetProcAddress( 'glVertexAttribL2d' , ADDRESSOF( VertexAttribL2d ));
	GetProcAddress( 'glVertexAttribL3d' , ADDRESSOF( VertexAttribL3d ));
	GetProcAddress( 'glVertexAttribL4d' , ADDRESSOF( VertexAttribL4d ));
	GetProcAddress( 'glVertexAttribL1dv' , ADDRESSOF( VertexAttribL1dv ));
	GetProcAddress( 'glVertexAttribL2dv' , ADDRESSOF( VertexAttribL2dv ));
	GetProcAddress( 'glVertexAttribL3dv' , ADDRESSOF( VertexAttribL3dv ));
	GetProcAddress( 'glVertexAttribL4dv' , ADDRESSOF( VertexAttribL4dv ));
	GetProcAddress( 'glVertexAttribLPointer' , ADDRESSOF( VertexAttribLPointer ));
	GetProcAddress( 'glGetVertexAttribLdv' , ADDRESSOF( GetVertexAttribLdv ));
END Read_GL_ARB_vertex_attrib_64bit;

PROCEDURE Read_GL_ARB_viewport_array*;
BEGIN
	GetProcAddress( 'glViewportArrayv' , ADDRESSOF( ViewportArrayv ));
	GetProcAddress( 'glViewportIndexedf' , ADDRESSOF( ViewportIndexedf ));
	GetProcAddress( 'glViewportIndexedfv' , ADDRESSOF( ViewportIndexedfv ));
	GetProcAddress( 'glScissorArrayv' , ADDRESSOF( ScissorArrayv ));
	GetProcAddress( 'glScissorIndexed' , ADDRESSOF( ScissorIndexed ));
	GetProcAddress( 'glScissorIndexedv' , ADDRESSOF( ScissorIndexedv ));
	GetProcAddress( 'glDepthRangeArrayv' , ADDRESSOF( DepthRangeArrayv ));
	GetProcAddress( 'glDepthRangeIndexed' , ADDRESSOF( DepthRangeIndexed ));
	GetProcAddress( 'glGetFloati_v' , ADDRESSOF( GetFloati_v ));
	GetProcAddress( 'glGetDoublei_v' , ADDRESSOF( GetDoublei_v ));
END Read_GL_ARB_viewport_array;

PROCEDURE Read_GL_ARB_base_instance*;
BEGIN
	GetProcAddress( 'glDrawArraysInstancedBaseInstance' , ADDRESSOF( DrawArraysInstancedBaseInstance ));
	GetProcAddress( 'glDrawElementsInstancedBaseInstance' , ADDRESSOF( DrawElementsInstancedBaseInstance ));
	GetProcAddress( 'glDrawElementsInstancedBaseVertexBaseInstance' , ADDRESSOF( DrawElementsInstancedBaseVertexBaseInstance ));
END Read_GL_ARB_base_instance;

PROCEDURE Read_GL_ARB_transform_feedback_instanced*;
BEGIN
	GetProcAddress( 'glDrawTransformFeedbackInstanced' , ADDRESSOF( DrawTransformFeedbackInstanced ));
	GetProcAddress( 'glDrawTransformFeedbackStreamInstanced' , ADDRESSOF( DrawTransformFeedbackStreamInstanced ));
END Read_GL_ARB_transform_feedback_instanced;

PROCEDURE Read_GL_ARB_internalformat_query*;
BEGIN
	GetProcAddress( 'glGetInternalformativ' , ADDRESSOF( GetInternalformativ ));
END Read_GL_ARB_internalformat_query;

PROCEDURE Read_GL_ARB_shader_atomic_counters*;
BEGIN
	GetProcAddress( 'glGetActiveAtomicCounterBufferiv' , ADDRESSOF( GetActiveAtomicCounterBufferiv ));
END Read_GL_ARB_shader_atomic_counters;

PROCEDURE Read_GL_ARB_shader_image_load_store*;
BEGIN
	GetProcAddress( 'glBindImageTexture' , ADDRESSOF( BindImageTexture ));
	GetProcAddress( 'glMemoryBarrier' , ADDRESSOF( MemoryBarrier ));
END Read_GL_ARB_shader_image_load_store;

PROCEDURE Read_GL_ARB_texture_storage*;
BEGIN
	GetProcAddress( 'glTexStorage1D' , ADDRESSOF( TexStorage1D ));
	GetProcAddress( 'glTexStorage2D' , ADDRESSOF( TexStorage2D ));
	GetProcAddress( 'glTexStorage3D' , ADDRESSOF( TexStorage3D ));
	GetProcAddress( 'glTextureStorage1DEXT' , ADDRESSOF( TextureStorage1DEXT ));
	GetProcAddress( 'glTextureStorage2DEXT' , ADDRESSOF( TextureStorage2DEXT ));
	GetProcAddress( 'glTextureStorage3DEXT' , ADDRESSOF( TextureStorage3DEXT ));
END Read_GL_ARB_texture_storage;

PROCEDURE Read_GL_KHR_debug*;
BEGIN
	GetProcAddress( 'glDebugMessageControl' , ADDRESSOF( DebugMessageControl ));
	GetProcAddress( 'glDebugMessageInsert' , ADDRESSOF( DebugMessageInsert ));
	GetProcAddress( 'glDebugMessageCallback' , ADDRESSOF( DebugMessageCallback ));
	GetProcAddress( 'glGetDebugMessageLog' , ADDRESSOF( GetDebugMessageLog ));
	GetProcAddress( 'glPushDebugGroup' , ADDRESSOF( PushDebugGroup ));
	GetProcAddress( 'glPopDebugGroup' , ADDRESSOF( PopDebugGroup ));
	GetProcAddress( 'glObjectLabel' , ADDRESSOF( ObjectLabel ));
	GetProcAddress( 'glGetObjectLabel' , ADDRESSOF( GetObjectLabel ));
	GetProcAddress( 'glObjectPtrLabel' , ADDRESSOF( ObjectPtrLabel ));
	GetProcAddress( 'glGetObjectPtrLabel' , ADDRESSOF( GetObjectPtrLabel ));
END Read_GL_KHR_debug;

PROCEDURE Read_GL_ARB_clear_buffer_object*;
BEGIN
	GetProcAddress( 'glClearBufferData' , ADDRESSOF( ClearBufferData ));
	GetProcAddress( 'glClearBufferSubData' , ADDRESSOF( ClearBufferSubData ));
	GetProcAddress( 'glClearNamedBufferDataEXT' , ADDRESSOF( ClearNamedBufferDataEXT ));
	GetProcAddress( 'glClearNamedBufferSubDataEXT' , ADDRESSOF( ClearNamedBufferSubDataEXT ));
END Read_GL_ARB_clear_buffer_object;

PROCEDURE Read_GL_ARB_compute_shader*;
BEGIN
	GetProcAddress( 'glDispatchCompute' , ADDRESSOF( DispatchCompute ));
	GetProcAddress( 'glDispatchComputeIndirect' , ADDRESSOF( DispatchComputeIndirect ));
END Read_GL_ARB_compute_shader;

PROCEDURE Read_GL_ARB_copy_image*;
BEGIN
	GetProcAddress( 'glCopyImageSubData' , ADDRESSOF( CopyImageSubData ));
END Read_GL_ARB_copy_image;

PROCEDURE Read_GL_ARB_framebuffer_no_attachments*;
BEGIN
	GetProcAddress( 'glFramebufferParameteri' , ADDRESSOF( FramebufferParameteri ));
	GetProcAddress( 'glGetFramebufferParameteriv' , ADDRESSOF( GetFramebufferParameteriv ));
	GetProcAddress( 'glNamedFramebufferParameteriEXT' , ADDRESSOF( NamedFramebufferParameteriEXT ));
	GetProcAddress( 'glGetNamedFramebufferParameterivEXT' , ADDRESSOF( GetNamedFramebufferParameterivEXT ));
END Read_GL_ARB_framebuffer_no_attachments;

PROCEDURE Read_GL_ARB_internalformat_query2*;
BEGIN
	GetProcAddress( 'glGetInternalformati64v' , ADDRESSOF( GetInternalformati64v ));
END Read_GL_ARB_internalformat_query2;

PROCEDURE Read_GL_ARB_invalidate_subdata*;
BEGIN
	GetProcAddress( 'glInvalidateTexSubImage' , ADDRESSOF( InvalidateTexSubImage ));
	GetProcAddress( 'glInvalidateTexImage' , ADDRESSOF( InvalidateTexImage ));
	GetProcAddress( 'glInvalidateBufferSubData' , ADDRESSOF( InvalidateBufferSubData ));
	GetProcAddress( 'glInvalidateBufferData' , ADDRESSOF( InvalidateBufferData ));
	GetProcAddress( 'glInvalidateFramebuffer' , ADDRESSOF( InvalidateFramebuffer ));
	GetProcAddress( 'glInvalidateSubFramebuffer' , ADDRESSOF( InvalidateSubFramebuffer ));
END Read_GL_ARB_invalidate_subdata;

PROCEDURE Read_GL_ARB_multi_draw_indirect*;
BEGIN
	GetProcAddress( 'glMultiDrawArraysIndirect' , ADDRESSOF( MultiDrawArraysIndirect ));
	GetProcAddress( 'glMultiDrawElementsIndirect' , ADDRESSOF( MultiDrawElementsIndirect ));
END Read_GL_ARB_multi_draw_indirect;

PROCEDURE Read_GL_ARB_program_interface_query*;
BEGIN
	GetProcAddress( 'glGetProgramInterfaceiv' , ADDRESSOF( GetProgramInterfaceiv ));
	GetProcAddress( 'glGetProgramResourceIndex' , ADDRESSOF( GetProgramResourceIndex ));
	GetProcAddress( 'glGetProgramResourceName' , ADDRESSOF( GetProgramResourceName ));
	GetProcAddress( 'glGetProgramResourceiv' , ADDRESSOF( GetProgramResourceiv ));
	GetProcAddress( 'glGetProgramResourceLocation' , ADDRESSOF( GetProgramResourceLocation ));
	GetProcAddress( 'glGetProgramResourceLocationIndex' , ADDRESSOF( GetProgramResourceLocationIndex ));
END Read_GL_ARB_program_interface_query;

PROCEDURE Read_GL_ARB_shader_storage_buffer_object*;
BEGIN
	GetProcAddress( 'glShaderStorageBlockBinding' , ADDRESSOF( ShaderStorageBlockBinding ));
END Read_GL_ARB_shader_storage_buffer_object;

PROCEDURE Read_GL_ARB_texture_buffer_range*;
BEGIN
	GetProcAddress( 'glTexBufferRange' , ADDRESSOF( TexBufferRange ));
	GetProcAddress( 'glTextureBufferRangeEXT' , ADDRESSOF( TextureBufferRangeEXT ));
END Read_GL_ARB_texture_buffer_range;

PROCEDURE Read_GL_ARB_texture_storage_multisample*;
BEGIN
	GetProcAddress( 'glTexStorage2DMultisample' , ADDRESSOF( TexStorage2DMultisample ));
	GetProcAddress( 'glTexStorage3DMultisample' , ADDRESSOF( TexStorage3DMultisample ));
	GetProcAddress( 'glTextureStorage2DMultisampleEXT' , ADDRESSOF( TextureStorage2DMultisampleEXT ));
	GetProcAddress( 'glTextureStorage3DMultisampleEXT' , ADDRESSOF( TextureStorage3DMultisampleEXT ));
END Read_GL_ARB_texture_storage_multisample;

PROCEDURE Read_GL_ARB_texture_view*;
BEGIN
	GetProcAddress( 'glTextureView' , ADDRESSOF( TextureView ));
END Read_GL_ARB_texture_view;

PROCEDURE Read_GL_ARB_vertex_attrib_binding*;
BEGIN
	GetProcAddress( 'glBindVertexBuffer' , ADDRESSOF( BindVertexBuffer ));
	GetProcAddress( 'glVertexAttribFormat' , ADDRESSOF( VertexAttribFormat ));
	GetProcAddress( 'glVertexAttribIFormat' , ADDRESSOF( VertexAttribIFormat ));
	GetProcAddress( 'glVertexAttribLFormat' , ADDRESSOF( VertexAttribLFormat ));
	GetProcAddress( 'glVertexAttribBinding' , ADDRESSOF( VertexAttribBinding ));
	GetProcAddress( 'glVertexBindingDivisor' , ADDRESSOF( VertexBindingDivisor ));
	GetProcAddress( 'glVertexArrayBindVertexBufferEXT' , ADDRESSOF( VertexArrayBindVertexBufferEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribFormatEXT' , ADDRESSOF( VertexArrayVertexAttribFormatEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribIFormatEXT' , ADDRESSOF( VertexArrayVertexAttribIFormatEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribLFormatEXT' , ADDRESSOF( VertexArrayVertexAttribLFormatEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribBindingEXT' , ADDRESSOF( VertexArrayVertexAttribBindingEXT ));
	GetProcAddress( 'glVertexArrayVertexBindingDivisorEXT' , ADDRESSOF( VertexArrayVertexBindingDivisorEXT ));
END Read_GL_ARB_vertex_attrib_binding;

PROCEDURE Read_GL_4_4*;
BEGIN
	GetProcAddress( 'glBufferStorage' , ADDRESSOF( BufferStorage ));
	GetProcAddress( 'glClearTexImage' , ADDRESSOF( ClearTexImage ));
	GetProcAddress( 'glClearTexSubImage' , ADDRESSOF( ClearTexSubImage ));
	GetProcAddress( 'glBindBuffersBase' , ADDRESSOF( BindBuffersBase ));
	GetProcAddress( 'glBindBuffersRange' , ADDRESSOF( BindBuffersRange ));
	GetProcAddress( 'glBindTextures' , ADDRESSOF( BindTextures ));
	GetProcAddress( 'glBindSamplers' , ADDRESSOF( BindSamplers ));
	GetProcAddress( 'glBindImageTextures' , ADDRESSOF( BindImageTextures ));
	GetProcAddress( 'glBindVertexBuffers' , ADDRESSOF( BindVertexBuffers ));
END Read_GL_4_4;

PROCEDURE Read_GL_4_5*;
BEGIN
	GetProcAddress( 'glClipControl' , ADDRESSOF( ClipControl ));
	GetProcAddress( 'glCreateTransformFeedbacks' , ADDRESSOF( CreateTransformFeedbacks ));
	GetProcAddress( 'glTransformFeedbackBufferBase' , ADDRESSOF( TransformFeedbackBufferBase ));
	GetProcAddress( 'glTransformFeedbackBufferRange' , ADDRESSOF( TransformFeedbackBufferRange ));
	GetProcAddress( 'glGetTransformFeedbackiv' , ADDRESSOF( GetTransformFeedbackiv ));
	GetProcAddress( 'glGetTransformFeedbacki_v' , ADDRESSOF( GetTransformFeedbacki_v ));
	GetProcAddress( 'glGetTransformFeedbacki64_v' , ADDRESSOF( GetTransformFeedbacki64_v ));
	GetProcAddress( 'glCreateBuffers' , ADDRESSOF( CreateBuffers ));
	GetProcAddress( 'glNamedBufferStorage' , ADDRESSOF( NamedBufferStorage ));
	GetProcAddress( 'glNamedBufferData' , ADDRESSOF( NamedBufferData ));
	GetProcAddress( 'glNamedBufferSubData' , ADDRESSOF( NamedBufferSubData ));
	GetProcAddress( 'glCopyNamedBufferSubData' , ADDRESSOF( CopyNamedBufferSubData ));
	GetProcAddress( 'glClearNamedBufferData' , ADDRESSOF( ClearNamedBufferData ));
	GetProcAddress( 'glClearNamedBufferSubData' , ADDRESSOF( ClearNamedBufferSubData ));
	GetProcAddress( 'glMapNamedBuffer' , ADDRESSOF( MapNamedBuffer ));
	GetProcAddress( 'glMapNamedBufferRange' , ADDRESSOF( MapNamedBufferRange ));
	GetProcAddress( 'glUnmapNamedBuffer' , ADDRESSOF( UnmapNamedBuffer ));
	GetProcAddress( 'glFlushMappedNamedBufferRange' , ADDRESSOF( FlushMappedNamedBufferRange ));
	GetProcAddress( 'glGetNamedBufferParameteriv' , ADDRESSOF( GetNamedBufferParameteriv ));
	GetProcAddress( 'glGetNamedBufferParameteri64v' , ADDRESSOF( GetNamedBufferParameteri64v ));
	GetProcAddress( 'glGetNamedBufferPointerv' , ADDRESSOF( GetNamedBufferPointerv ));
	GetProcAddress( 'glGetNamedBufferSubData' , ADDRESSOF( GetNamedBufferSubData ));
	GetProcAddress( 'glCreateFramebuffers' , ADDRESSOF( CreateFramebuffers ));
	GetProcAddress( 'glNamedFramebufferRenderbuffer' , ADDRESSOF( NamedFramebufferRenderbuffer ));
	GetProcAddress( 'glNamedFramebufferParameteri' , ADDRESSOF( NamedFramebufferParameteri ));
	GetProcAddress( 'glNamedFramebufferTexture' , ADDRESSOF( NamedFramebufferTexture ));
	GetProcAddress( 'glNamedFramebufferTextureLayer' , ADDRESSOF( NamedFramebufferTextureLayer ));
	GetProcAddress( 'glNamedFramebufferDrawBuffer' , ADDRESSOF( NamedFramebufferDrawBuffer ));
	GetProcAddress( 'glNamedFramebufferDrawBuffers' , ADDRESSOF( NamedFramebufferDrawBuffers ));
	GetProcAddress( 'glNamedFramebufferReadBuffer' , ADDRESSOF( NamedFramebufferReadBuffer ));
	GetProcAddress( 'glInvalidateNamedFramebufferData' , ADDRESSOF( InvalidateNamedFramebufferData ));
	GetProcAddress( 'glInvalidateNamedFramebufferSubData' , ADDRESSOF( InvalidateNamedFramebufferSubData ));
	GetProcAddress( 'glClearNamedFramebufferiv' , ADDRESSOF( ClearNamedFramebufferiv ));
	GetProcAddress( 'glClearNamedFramebufferuiv' , ADDRESSOF( ClearNamedFramebufferuiv ));
	GetProcAddress( 'glClearNamedFramebufferfv' , ADDRESSOF( ClearNamedFramebufferfv ));
	GetProcAddress( 'glClearNamedFramebufferfi' , ADDRESSOF( ClearNamedFramebufferfi ));
	GetProcAddress( 'glBlitNamedFramebuffer' , ADDRESSOF( BlitNamedFramebuffer ));
	GetProcAddress( 'glCheckNamedFramebufferStatus' , ADDRESSOF( CheckNamedFramebufferStatus ));
	GetProcAddress( 'glGetNamedFramebufferParameteriv' , ADDRESSOF( GetNamedFramebufferParameteriv ));
	GetProcAddress( 'glGetNamedFramebufferAttachmentParameteriv' , ADDRESSOF( GetNamedFramebufferAttachmentParameteriv ));
	GetProcAddress( 'glCreateRenderbuffers' , ADDRESSOF( CreateRenderbuffers ));
	GetProcAddress( 'glNamedRenderbufferStorage' , ADDRESSOF( NamedRenderbufferStorage ));
	GetProcAddress( 'glNamedRenderbufferStorageMultisample' , ADDRESSOF( NamedRenderbufferStorageMultisample ));
	GetProcAddress( 'glGetNamedRenderbufferParameteriv' , ADDRESSOF( GetNamedRenderbufferParameteriv ));
	GetProcAddress( 'glCreateTextures' , ADDRESSOF( CreateTextures ));
	GetProcAddress( 'glTextureBuffer' , ADDRESSOF( TextureBuffer ));
	GetProcAddress( 'glTextureBufferRange' , ADDRESSOF( TextureBufferRange ));
	GetProcAddress( 'glTextureStorage1D' , ADDRESSOF( TextureStorage1D ));
	GetProcAddress( 'glTextureStorage2D' , ADDRESSOF( TextureStorage2D ));
	GetProcAddress( 'glTextureStorage3D' , ADDRESSOF( TextureStorage3D ));
	GetProcAddress( 'glTextureStorage2DMultisample' , ADDRESSOF( TextureStorage2DMultisample ));
	GetProcAddress( 'glTextureStorage3DMultisample' , ADDRESSOF( TextureStorage3DMultisample ));
	GetProcAddress( 'glTextureSubImage1D' , ADDRESSOF( TextureSubImage1D ));
	GetProcAddress( 'glTextureSubImage2D' , ADDRESSOF( TextureSubImage2D ));
	GetProcAddress( 'glTextureSubImage3D' , ADDRESSOF( TextureSubImage3D ));
	GetProcAddress( 'glCompressedTextureSubImage1D' , ADDRESSOF( CompressedTextureSubImage1D ));
	GetProcAddress( 'glCompressedTextureSubImage2D' , ADDRESSOF( CompressedTextureSubImage2D ));
	GetProcAddress( 'glCompressedTextureSubImage3D' , ADDRESSOF( CompressedTextureSubImage3D ));
	GetProcAddress( 'glCopyTextureSubImage1D' , ADDRESSOF( CopyTextureSubImage1D ));
	GetProcAddress( 'glCopyTextureSubImage2D' , ADDRESSOF( CopyTextureSubImage2D ));
	GetProcAddress( 'glCopyTextureSubImage3D' , ADDRESSOF( CopyTextureSubImage3D ));
	GetProcAddress( 'glTextureParameterf' , ADDRESSOF( TextureParameterf ));
	GetProcAddress( 'glTextureParameterfv' , ADDRESSOF( TextureParameterfv ));
	GetProcAddress( 'glTextureParameteri' , ADDRESSOF( TextureParameteri ));
	GetProcAddress( 'glTextureParameterIiv' , ADDRESSOF( TextureParameterIiv ));
	GetProcAddress( 'glTextureParameterIuiv' , ADDRESSOF( TextureParameterIuiv ));
	GetProcAddress( 'glTextureParameteriv' , ADDRESSOF( TextureParameteriv ));
	GetProcAddress( 'glGenerateTextureMipmap' , ADDRESSOF( GenerateTextureMipmap ));
	GetProcAddress( 'glBindTextureUnit' , ADDRESSOF( BindTextureUnit ));
	GetProcAddress( 'glGetTextureImage' , ADDRESSOF( GetTextureImage ));
	GetProcAddress( 'glGetCompressedTextureImage' , ADDRESSOF( GetCompressedTextureImage ));
	GetProcAddress( 'glGetTextureLevelParameterfv' , ADDRESSOF( GetTextureLevelParameterfv ));
	GetProcAddress( 'glGetTextureLevelParameteriv' , ADDRESSOF( GetTextureLevelParameteriv ));
	GetProcAddress( 'glGetTextureParameterfv' , ADDRESSOF( GetTextureParameterfv ));
	GetProcAddress( 'glGetTextureParameterIiv' , ADDRESSOF( GetTextureParameterIiv ));
	GetProcAddress( 'glGetTextureParameterIuiv' , ADDRESSOF( GetTextureParameterIuiv ));
	GetProcAddress( 'glGetTextureParameteriv' , ADDRESSOF( GetTextureParameteriv ));
	GetProcAddress( 'glCreateVertexArrays' , ADDRESSOF( CreateVertexArrays ));
	GetProcAddress( 'glDisableVertexArrayAttrib' , ADDRESSOF( DisableVertexArrayAttrib ));
	GetProcAddress( 'glEnableVertexArrayAttrib' , ADDRESSOF( EnableVertexArrayAttrib ));
	GetProcAddress( 'glVertexArrayElementBuffer' , ADDRESSOF( VertexArrayElementBuffer ));
	GetProcAddress( 'glVertexArrayVertexBuffer' , ADDRESSOF( VertexArrayVertexBuffer ));
	GetProcAddress( 'glVertexArrayVertexBuffers' , ADDRESSOF( VertexArrayVertexBuffers ));
	GetProcAddress( 'glVertexArrayAttribBinding' , ADDRESSOF( VertexArrayAttribBinding ));
	GetProcAddress( 'glVertexArrayAttribFormat' , ADDRESSOF( VertexArrayAttribFormat ));
	GetProcAddress( 'glVertexArrayAttribIFormat' , ADDRESSOF( VertexArrayAttribIFormat ));
	GetProcAddress( 'glVertexArrayAttribLFormat' , ADDRESSOF( VertexArrayAttribLFormat ));
	GetProcAddress( 'glVertexArrayBindingDivisor' , ADDRESSOF( VertexArrayBindingDivisor ));
	GetProcAddress( 'glGetVertexArrayiv' , ADDRESSOF( GetVertexArrayiv ));
	GetProcAddress( 'glGetVertexArrayIndexediv' , ADDRESSOF( GetVertexArrayIndexediv ));
	GetProcAddress( 'glGetVertexArrayIndexed64iv' , ADDRESSOF( GetVertexArrayIndexed64iv ));
	GetProcAddress( 'glCreateSamplers' , ADDRESSOF( CreateSamplers ));
	GetProcAddress( 'glCreateProgramPipelines' , ADDRESSOF( CreateProgramPipelines ));
	GetProcAddress( 'glCreateQueries' , ADDRESSOF( CreateQueries ));
	GetProcAddress( 'glMemoryBarrierByRegion' , ADDRESSOF( MemoryBarrierByRegion ));
	GetProcAddress( 'glGetTextureSubImage' , ADDRESSOF( GetTextureSubImage ));
	GetProcAddress( 'glGetCompressedTextureSubImage' , ADDRESSOF( GetCompressedTextureSubImage ));
	GetProcAddress( 'glGetGraphicsResetStatus' , ADDRESSOF( GetGraphicsResetStatus ));
	GetProcAddress( 'glGetnCompressedTexImage' , ADDRESSOF( GetnCompressedTexImage ));
	GetProcAddress( 'glGetnTexImage' , ADDRESSOF( GetnTexImage ));
	GetProcAddress( 'glGetnUniformdv' , ADDRESSOF( GetnUniformdv ));
	GetProcAddress( 'glGetnUniformfv' , ADDRESSOF( GetnUniformfv ));
	GetProcAddress( 'glGetnUniformiv' , ADDRESSOF( GetnUniformiv ));
	GetProcAddress( 'glGetnUniformuiv' , ADDRESSOF( GetnUniformuiv ));
	GetProcAddress( 'glReadnPixels' , ADDRESSOF( ReadnPixels ));
	GetProcAddress( 'glGetnMapdv' , ADDRESSOF( GetnMapdv ));
	GetProcAddress( 'glGetnMapfv' , ADDRESSOF( GetnMapfv ));
	GetProcAddress( 'glGetnMapiv' , ADDRESSOF( GetnMapiv ));
	GetProcAddress( 'glGetnPixelMapfv' , ADDRESSOF( GetnPixelMapfv ));
	GetProcAddress( 'glGetnPixelMapuiv' , ADDRESSOF( GetnPixelMapuiv ));
	GetProcAddress( 'glGetnPixelMapusv' , ADDRESSOF( GetnPixelMapusv ));
	GetProcAddress( 'glGetnPolygonStipple' , ADDRESSOF( GetnPolygonStipple ));
	GetProcAddress( 'glGetnColorTable' , ADDRESSOF( GetnColorTable ));
	GetProcAddress( 'glGetnConvolutionFilter' , ADDRESSOF( GetnConvolutionFilter ));
	GetProcAddress( 'glGetnSeparableFilter' , ADDRESSOF( GetnSeparableFilter ));
	GetProcAddress( 'glGetnHistogram' , ADDRESSOF( GetnHistogram ));
	GetProcAddress( 'glGetnMinmax' , ADDRESSOF( GetnMinmax ));
	GetProcAddress( 'glTextureBarrier' , ADDRESSOF( TextureBarrier ));
END Read_GL_4_5;

PROCEDURE Read_GL_NV_path_rendering*;
BEGIN
	GetProcAddress( 'glGenPathsNV' , ADDRESSOF( GenPathsNV ));
	GetProcAddress( 'glDeletePathsNV' , ADDRESSOF( DeletePathsNV ));
	GetProcAddress( 'glIsPathNV' , ADDRESSOF( IsPathNV ));
	GetProcAddress( 'glPathCommandsNV' , ADDRESSOF( PathCommandsNV ));
	GetProcAddress( 'glPathCoordsNV' , ADDRESSOF( PathCoordsNV ));
	GetProcAddress( 'glPathSubCommandsNV' , ADDRESSOF( PathSubCommandsNV ));
	GetProcAddress( 'glPathSubCoordsNV' , ADDRESSOF( PathSubCoordsNV ));
	GetProcAddress( 'glPathStringNV' , ADDRESSOF( PathStringNV ));
	GetProcAddress( 'glPathGlyphsNV' , ADDRESSOF( PathGlyphsNV ));
	GetProcAddress( 'glPathGlyphRangeNV' , ADDRESSOF( PathGlyphRangeNV ));
	GetProcAddress( 'glWeightPathsNV' , ADDRESSOF( WeightPathsNV ));
	GetProcAddress( 'glCopyPathNV' , ADDRESSOF( CopyPathNV ));
	GetProcAddress( 'glInterpolatePathsNV' , ADDRESSOF( InterpolatePathsNV ));
	GetProcAddress( 'glTransformPathNV' , ADDRESSOF( TransformPathNV ));
	GetProcAddress( 'glPathParameterivNV' , ADDRESSOF( PathParameterivNV ));
	GetProcAddress( 'glPathParameteriNV' , ADDRESSOF( PathParameteriNV ));
	GetProcAddress( 'glPathParameterfvNV' , ADDRESSOF( PathParameterfvNV ));
	GetProcAddress( 'glPathParameterfNV' , ADDRESSOF( PathParameterfNV ));
	GetProcAddress( 'glPathDashArrayNV' , ADDRESSOF( PathDashArrayNV ));
	GetProcAddress( 'glPathStencilFuncNV' , ADDRESSOF( PathStencilFuncNV ));
	GetProcAddress( 'glPathStencilDepthOffsetNV' , ADDRESSOF( PathStencilDepthOffsetNV ));
	GetProcAddress( 'glStencilFillPathNV' , ADDRESSOF( StencilFillPathNV ));
	GetProcAddress( 'glStencilStrokePathNV' , ADDRESSOF( StencilStrokePathNV ));
	GetProcAddress( 'glStencilFillPathInstancedNV' , ADDRESSOF( StencilFillPathInstancedNV ));
	GetProcAddress( 'glStencilStrokePathInstancedNV' , ADDRESSOF( StencilStrokePathInstancedNV ));
	GetProcAddress( 'glPathCoverDepthFuncNV' , ADDRESSOF( PathCoverDepthFuncNV ));
	GetProcAddress( 'glPathColorGenNV' , ADDRESSOF( PathColorGenNV ));
	GetProcAddress( 'glPathTexGenNV' , ADDRESSOF( PathTexGenNV ));
	GetProcAddress( 'glPathFogGenNV' , ADDRESSOF( PathFogGenNV ));
	GetProcAddress( 'glCoverFillPathNV' , ADDRESSOF( CoverFillPathNV ));
	GetProcAddress( 'glCoverStrokePathNV' , ADDRESSOF( CoverStrokePathNV ));
	GetProcAddress( 'glCoverFillPathInstancedNV' , ADDRESSOF( CoverFillPathInstancedNV ));
	GetProcAddress( 'glCoverStrokePathInstancedNV' , ADDRESSOF( CoverStrokePathInstancedNV ));
	GetProcAddress( 'glGetPathParameterivNV' , ADDRESSOF( GetPathParameterivNV ));
	GetProcAddress( 'glGetPathParameterfvNV' , ADDRESSOF( GetPathParameterfvNV ));
	GetProcAddress( 'glGetPathCommandsNV' , ADDRESSOF( GetPathCommandsNV ));
	GetProcAddress( 'glGetPathCoordsNV' , ADDRESSOF( GetPathCoordsNV ));
	GetProcAddress( 'glGetPathDashArrayNV' , ADDRESSOF( GetPathDashArrayNV ));
	GetProcAddress( 'glGetPathMetricsNV' , ADDRESSOF( GetPathMetricsNV ));
	GetProcAddress( 'glGetPathMetricRangeNV' , ADDRESSOF( GetPathMetricRangeNV ));
	GetProcAddress( 'glGetPathSpacingNV' , ADDRESSOF( GetPathSpacingNV ));
	GetProcAddress( 'glGetPathColorGenivNV' , ADDRESSOF( GetPathColorGenivNV ));
	GetProcAddress( 'glGetPathColorGenfvNV' , ADDRESSOF( GetPathColorGenfvNV ));
	GetProcAddress( 'glGetPathTexGenivNV' , ADDRESSOF( GetPathTexGenivNV ));
	GetProcAddress( 'glGetPathTexGenfvNV' , ADDRESSOF( GetPathTexGenfvNV ));
	GetProcAddress( 'glIsPointInFillPathNV' , ADDRESSOF( IsPointInFillPathNV ));
	GetProcAddress( 'glIsPointInStrokePathNV' , ADDRESSOF( IsPointInStrokePathNV ));
	GetProcAddress( 'glGetPathLengthNV' , ADDRESSOF( GetPathLengthNV ));
	GetProcAddress( 'glPointAlongPathNV' , ADDRESSOF( PointAlongPathNV ));
END Read_GL_NV_path_rendering;

PROCEDURE Read_GL_AMD_stencil_operation_extended*;
BEGIN
	GetProcAddress( 'glStencilOpValueAMD' , ADDRESSOF( StencilOpValueAMD ));
END Read_GL_AMD_stencil_operation_extended;

PROCEDURE Read_GL_NV_bindless_texture*;
BEGIN
	GetProcAddress( 'glGetTextureHandleNV' , ADDRESSOF( GetTextureHandleNV ));
	GetProcAddress( 'glGetTextureSamplerHandleNV' , ADDRESSOF( GetTextureSamplerHandleNV ));
	GetProcAddress( 'glMakeTextureHandleResidentNV' , ADDRESSOF( MakeTextureHandleResidentNV ));
	GetProcAddress( 'glMakeTextureHandleNonResidentNV' , ADDRESSOF( MakeTextureHandleNonResidentNV ));
	GetProcAddress( 'glGetImageHandleNV' , ADDRESSOF( GetImageHandleNV ));
	GetProcAddress( 'glMakeImageHandleResidentNV' , ADDRESSOF( MakeImageHandleResidentNV ));
	GetProcAddress( 'glMakeImageHandleNonResidentNV' , ADDRESSOF( MakeImageHandleNonResidentNV ));
	GetProcAddress( 'glUniformHandleui64NV' , ADDRESSOF( UniformHandleui64NV ));
	GetProcAddress( 'glUniformHandleui64vNV' , ADDRESSOF( UniformHandleui64vNV ));
	GetProcAddress( 'glProgramUniformHandleui64NV' , ADDRESSOF( ProgramUniformHandleui64NV ));
	GetProcAddress( 'glProgramUniformHandleui64vNV' , ADDRESSOF( ProgramUniformHandleui64vNV ));
	GetProcAddress( 'glIsTextureHandleResidentNV' , ADDRESSOF( IsTextureHandleResidentNV ));
	GetProcAddress( 'glIsImageHandleResidentNV' , ADDRESSOF( IsImageHandleResidentNV ));
END Read_GL_NV_bindless_texture;

PROCEDURE Read_GL_ARB_bindless_texture*;
BEGIN
	GetProcAddress( 'glGetTextureHandleARB' , ADDRESSOF( GetTextureHandleARB ));
	GetProcAddress( 'glGetTextureSamplerHandleARB' , ADDRESSOF( GetTextureSamplerHandleARB ));
	GetProcAddress( 'glMakeTextureHandleResidentARB' , ADDRESSOF( MakeTextureHandleResidentARB ));
	GetProcAddress( 'glMakeTextureHandleNonResidentARB' , ADDRESSOF( MakeTextureHandleNonResidentARB ));
	GetProcAddress( 'glGetImageHandleARB' , ADDRESSOF( GetImageHandleARB ));
	GetProcAddress( 'glMakeImageHandleResidentARB' , ADDRESSOF( MakeImageHandleResidentARB ));
	GetProcAddress( 'glMakeImageHandleNonResidentARB' , ADDRESSOF( MakeImageHandleNonResidentARB ));
	GetProcAddress( 'glUniformHandleui64ARB' , ADDRESSOF( UniformHandleui64ARB ));
	GetProcAddress( 'glUniformHandleui64vARB' , ADDRESSOF( UniformHandleui64vARB ));
	GetProcAddress( 'glProgramUniformHandleui64ARB' , ADDRESSOF( ProgramUniformHandleui64ARB ));
	GetProcAddress( 'glProgramUniformHandleui64vARB' , ADDRESSOF( ProgramUniformHandleui64vARB ));
	GetProcAddress( 'glIsTextureHandleResidentARB' , ADDRESSOF( IsTextureHandleResidentARB ));
	GetProcAddress( 'glIsImageHandleResidentARB' , ADDRESSOF( IsImageHandleResidentARB ));
	GetProcAddress( 'glVertexAttribL1ui64ARB' , ADDRESSOF( VertexAttribL1ui64ARB ));
	GetProcAddress( 'glVertexAttribL1ui64vARB' , ADDRESSOF( VertexAttribL1ui64vARB ));
	GetProcAddress( 'glGetVertexAttribLui64vARB' , ADDRESSOF( GetVertexAttribLui64vARB ));
END Read_GL_ARB_bindless_texture;

PROCEDURE Read_GL_ARB_cl_event*;
BEGIN
	GetProcAddress( 'glCreateSyncFromCLeventARB' , ADDRESSOF( CreateSyncFromCLeventARB ));
END Read_GL_ARB_cl_event;

PROCEDURE Read_GL_ARB_compute_variable_group_size*;
BEGIN
	GetProcAddress( 'glDispatchComputeGroupSizeARB' , ADDRESSOF( DispatchComputeGroupSizeARB ));
END Read_GL_ARB_compute_variable_group_size;

PROCEDURE Read_GL_ARB_debug_output*;
BEGIN
	GetProcAddress( 'glDebugMessageControlARB' , ADDRESSOF( DebugMessageControlARB ));
	GetProcAddress( 'glDebugMessageInsertARB' , ADDRESSOF( DebugMessageInsertARB ));
	GetProcAddress( 'glDebugMessageCallbackARB' , ADDRESSOF( DebugMessageCallbackARB ));
	GetProcAddress( 'glGetDebugMessageLogARB' , ADDRESSOF( GetDebugMessageLogARB ));
END Read_GL_ARB_debug_output;

PROCEDURE Read_GL_ARB_robustness*;
BEGIN
	GetProcAddress( 'glGetGraphicsResetStatusARB' , ADDRESSOF( GetGraphicsResetStatusARB ));
	GetProcAddress( 'glGetnMapdvARB' , ADDRESSOF( GetnMapdvARB ));
	GetProcAddress( 'glGetnMapfvARB' , ADDRESSOF( GetnMapfvARB ));
	GetProcAddress( 'glGetnMapivARB' , ADDRESSOF( GetnMapivARB ));
	GetProcAddress( 'glGetnPixelMapfvARB' , ADDRESSOF( GetnPixelMapfvARB ));
	GetProcAddress( 'glGetnPixelMapuivARB' , ADDRESSOF( GetnPixelMapuivARB ));
	GetProcAddress( 'glGetnPixelMapusvARB' , ADDRESSOF( GetnPixelMapusvARB ));
	GetProcAddress( 'glGetnPolygonStippleARB' , ADDRESSOF( GetnPolygonStippleARB ));
	GetProcAddress( 'glGetnColorTableARB' , ADDRESSOF( GetnColorTableARB ));
	GetProcAddress( 'glGetnConvolutionFilterARB' , ADDRESSOF( GetnConvolutionFilterARB ));
	GetProcAddress( 'glGetnSeparableFilterARB' , ADDRESSOF( GetnSeparableFilterARB ));
	GetProcAddress( 'glGetnHistogramARB' , ADDRESSOF( GetnHistogramARB ));
	GetProcAddress( 'glGetnMinmaxARB' , ADDRESSOF( GetnMinmaxARB ));
	GetProcAddress( 'glGetnTexImageARB' , ADDRESSOF( GetnTexImageARB ));
	GetProcAddress( 'glReadnPixelsARB' , ADDRESSOF( ReadnPixelsARB ));
	GetProcAddress( 'glGetnCompressedTexImageARB' , ADDRESSOF( GetnCompressedTexImageARB ));
	GetProcAddress( 'glGetnUniformfvARB' , ADDRESSOF( GetnUniformfvARB ));
	GetProcAddress( 'glGetnUniformivARB' , ADDRESSOF( GetnUniformivARB ));
	GetProcAddress( 'glGetnUniformuivARB' , ADDRESSOF( GetnUniformuivARB ));
	GetProcAddress( 'glGetnUniformdvARB' , ADDRESSOF( GetnUniformdvARB ));
END Read_GL_ARB_robustness;

PROCEDURE Read_GL_ATI_draw_buffers*;
BEGIN
	GetProcAddress( 'glDrawBuffersATI' , ADDRESSOF( DrawBuffersATI ));
END Read_GL_ATI_draw_buffers;

PROCEDURE Read_GL_ATI_element_array*;
BEGIN
	GetProcAddress( 'glElementPointerATI' , ADDRESSOF( ElementPointerATI ));
	GetProcAddress( 'glDrawElementArrayATI' , ADDRESSOF( DrawElementArrayATI ));
	GetProcAddress( 'glDrawRangeElementArrayATI' , ADDRESSOF( DrawRangeElementArrayATI ));
END Read_GL_ATI_element_array;

PROCEDURE Read_GL_ATI_envmap_bumpmap*;
BEGIN
	GetProcAddress( 'glTexBumpParameterivATI' , ADDRESSOF( TexBumpParameterivATI ));
	GetProcAddress( 'glTexBumpParameterfvATI' , ADDRESSOF( TexBumpParameterfvATI ));
	GetProcAddress( 'glGetTexBumpParameterivATI' , ADDRESSOF( GetTexBumpParameterivATI ));
	GetProcAddress( 'glGetTexBumpParameterfvATI' , ADDRESSOF( GetTexBumpParameterfvATI ));
END Read_GL_ATI_envmap_bumpmap;

PROCEDURE Read_GL_ATI_fragment_shader*;
BEGIN
	GetProcAddress( 'glGenFragmentShadersATI' , ADDRESSOF( GenFragmentShadersATI ));
	GetProcAddress( 'glBindFragmentShaderATI' , ADDRESSOF( BindFragmentShaderATI ));
	GetProcAddress( 'glDeleteFragmentShaderATI' , ADDRESSOF( DeleteFragmentShaderATI ));
	GetProcAddress( 'glBeginFragmentShaderATI' , ADDRESSOF( BeginFragmentShaderATI ));
	GetProcAddress( 'glEndFragmentShaderATI' , ADDRESSOF( EndFragmentShaderATI ));
	GetProcAddress( 'glPassTexCoordATI' , ADDRESSOF( PassTexCoordATI ));
	GetProcAddress( 'glSampleMapATI' , ADDRESSOF( SampleMapATI ));
	GetProcAddress( 'glColorFragmentOp1ATI' , ADDRESSOF( ColorFragmentOp1ATI ));
	GetProcAddress( 'glColorFragmentOp2ATI' , ADDRESSOF( ColorFragmentOp2ATI ));
	GetProcAddress( 'glColorFragmentOp3ATI' , ADDRESSOF( ColorFragmentOp3ATI ));
	GetProcAddress( 'glAlphaFragmentOp1ATI' , ADDRESSOF( AlphaFragmentOp1ATI ));
	GetProcAddress( 'glAlphaFragmentOp2ATI' , ADDRESSOF( AlphaFragmentOp2ATI ));
	GetProcAddress( 'glAlphaFragmentOp3ATI' , ADDRESSOF( AlphaFragmentOp3ATI ));
	GetProcAddress( 'glSetFragmentShaderConstantATI' , ADDRESSOF( SetFragmentShaderConstantATI ));
END Read_GL_ATI_fragment_shader;

PROCEDURE Read_GL_ATI_map_object_buffer*;
BEGIN
	GetProcAddress( 'glMapObjectBufferATI' , ADDRESSOF( MapObjectBufferATI ));
	GetProcAddress( 'glUnmapObjectBufferATI' , ADDRESSOF( UnmapObjectBufferATI ));
END Read_GL_ATI_map_object_buffer;

PROCEDURE Read_GL_ATI_pn_triangles*;
BEGIN
	GetProcAddress( 'glPNTrianglesiATI' , ADDRESSOF( PNTrianglesiATI ));
	GetProcAddress( 'glPNTrianglesfATI' , ADDRESSOF( PNTrianglesfATI ));
END Read_GL_ATI_pn_triangles;

PROCEDURE Read_GL_ATI_separate_stencil*;
BEGIN
	GetProcAddress( 'glStencilOpSeparateATI' , ADDRESSOF( StencilOpSeparateATI ));
	GetProcAddress( 'glStencilFuncSeparateATI' , ADDRESSOF( StencilFuncSeparateATI ));
END Read_GL_ATI_separate_stencil;

PROCEDURE Read_GL_ATI_vertex_array_object*;
BEGIN
	GetProcAddress( 'glNewObjectBufferATI' , ADDRESSOF( NewObjectBufferATI ));
	GetProcAddress( 'glIsObjectBufferATI' , ADDRESSOF( IsObjectBufferATI ));
	GetProcAddress( 'glUpdateObjectBufferATI' , ADDRESSOF( UpdateObjectBufferATI ));
	GetProcAddress( 'glGetObjectBufferfvATI' , ADDRESSOF( GetObjectBufferfvATI ));
	GetProcAddress( 'glGetObjectBufferivATI' , ADDRESSOF( GetObjectBufferivATI ));
	GetProcAddress( 'glFreeObjectBufferATI' , ADDRESSOF( FreeObjectBufferATI ));
	GetProcAddress( 'glArrayObjectATI' , ADDRESSOF( ArrayObjectATI ));
	GetProcAddress( 'glGetArrayObjectfvATI' , ADDRESSOF( GetArrayObjectfvATI ));
	GetProcAddress( 'glGetArrayObjectivATI' , ADDRESSOF( GetArrayObjectivATI ));
	GetProcAddress( 'glVariantArrayObjectATI' , ADDRESSOF( VariantArrayObjectATI ));
	GetProcAddress( 'glGetVariantArrayObjectfvATI' , ADDRESSOF( GetVariantArrayObjectfvATI ));
	GetProcAddress( 'glGetVariantArrayObjectivATI' , ADDRESSOF( GetVariantArrayObjectivATI ));
END Read_GL_ATI_vertex_array_object;

PROCEDURE Read_GL_ATI_vertex_attrib_array_object*;
BEGIN
	GetProcAddress( 'glVertexAttribArrayObjectATI' , ADDRESSOF( VertexAttribArrayObjectATI ));
	GetProcAddress( 'glGetVertexAttribArrayObjectfvATI' , ADDRESSOF( GetVertexAttribArrayObjectfvATI ));
	GetProcAddress( 'glGetVertexAttribArrayObjectivATI' , ADDRESSOF( GetVertexAttribArrayObjectivATI ));
END Read_GL_ATI_vertex_attrib_array_object;

PROCEDURE Read_GL_ATI_vertex_streams*;
BEGIN
	GetProcAddress( 'glVertexStream1sATI' , ADDRESSOF( VertexStream1sATI ));
	GetProcAddress( 'glVertexStream1svATI' , ADDRESSOF( VertexStream1svATI ));
	GetProcAddress( 'glVertexStream1iATI' , ADDRESSOF( VertexStream1iATI ));
	GetProcAddress( 'glVertexStream1ivATI' , ADDRESSOF( VertexStream1ivATI ));
	GetProcAddress( 'glVertexStream1fATI' , ADDRESSOF( VertexStream1fATI ));
	GetProcAddress( 'glVertexStream1fvATI' , ADDRESSOF( VertexStream1fvATI ));
	GetProcAddress( 'glVertexStream1dATI' , ADDRESSOF( VertexStream1dATI ));
	GetProcAddress( 'glVertexStream1dvATI' , ADDRESSOF( VertexStream1dvATI ));
	GetProcAddress( 'glVertexStream2sATI' , ADDRESSOF( VertexStream2sATI ));
	GetProcAddress( 'glVertexStream2svATI' , ADDRESSOF( VertexStream2svATI ));
	GetProcAddress( 'glVertexStream2iATI' , ADDRESSOF( VertexStream2iATI ));
	GetProcAddress( 'glVertexStream2ivATI' , ADDRESSOF( VertexStream2ivATI ));
	GetProcAddress( 'glVertexStream2fATI' , ADDRESSOF( VertexStream2fATI ));
	GetProcAddress( 'glVertexStream2fvATI' , ADDRESSOF( VertexStream2fvATI ));
	GetProcAddress( 'glVertexStream2dATI' , ADDRESSOF( VertexStream2dATI ));
	GetProcAddress( 'glVertexStream2dvATI' , ADDRESSOF( VertexStream2dvATI ));
	GetProcAddress( 'glVertexStream3sATI' , ADDRESSOF( VertexStream3sATI ));
	GetProcAddress( 'glVertexStream3svATI' , ADDRESSOF( VertexStream3svATI ));
	GetProcAddress( 'glVertexStream3iATI' , ADDRESSOF( VertexStream3iATI ));
	GetProcAddress( 'glVertexStream3ivATI' , ADDRESSOF( VertexStream3ivATI ));
	GetProcAddress( 'glVertexStream3fATI' , ADDRESSOF( VertexStream3fATI ));
	GetProcAddress( 'glVertexStream3fvATI' , ADDRESSOF( VertexStream3fvATI ));
	GetProcAddress( 'glVertexStream3dATI' , ADDRESSOF( VertexStream3dATI ));
	GetProcAddress( 'glVertexStream3dvATI' , ADDRESSOF( VertexStream3dvATI ));
	GetProcAddress( 'glVertexStream4sATI' , ADDRESSOF( VertexStream4sATI ));
	GetProcAddress( 'glVertexStream4svATI' , ADDRESSOF( VertexStream4svATI ));
	GetProcAddress( 'glVertexStream4iATI' , ADDRESSOF( VertexStream4iATI ));
	GetProcAddress( 'glVertexStream4ivATI' , ADDRESSOF( VertexStream4ivATI ));
	GetProcAddress( 'glVertexStream4fATI' , ADDRESSOF( VertexStream4fATI ));
	GetProcAddress( 'glVertexStream4fvATI' , ADDRESSOF( VertexStream4fvATI ));
	GetProcAddress( 'glVertexStream4dATI' , ADDRESSOF( VertexStream4dATI ));
	GetProcAddress( 'glVertexStream4dvATI' , ADDRESSOF( VertexStream4dvATI ));
	GetProcAddress( 'glNormalStream3bATI' , ADDRESSOF( NormalStream3bATI ));
	GetProcAddress( 'glNormalStream3bvATI' , ADDRESSOF( NormalStream3bvATI ));
	GetProcAddress( 'glNormalStream3sATI' , ADDRESSOF( NormalStream3sATI ));
	GetProcAddress( 'glNormalStream3svATI' , ADDRESSOF( NormalStream3svATI ));
	GetProcAddress( 'glNormalStream3iATI' , ADDRESSOF( NormalStream3iATI ));
	GetProcAddress( 'glNormalStream3ivATI' , ADDRESSOF( NormalStream3ivATI ));
	GetProcAddress( 'glNormalStream3fATI' , ADDRESSOF( NormalStream3fATI ));
	GetProcAddress( 'glNormalStream3fvATI' , ADDRESSOF( NormalStream3fvATI ));
	GetProcAddress( 'glNormalStream3dATI' , ADDRESSOF( NormalStream3dATI ));
	GetProcAddress( 'glNormalStream3dvATI' , ADDRESSOF( NormalStream3dvATI ));
	GetProcAddress( 'glClientActiveVertexStreamATI' , ADDRESSOF( ClientActiveVertexStreamATI ));
	GetProcAddress( 'glVertexBlendEnviATI' , ADDRESSOF( VertexBlendEnviATI ));
	GetProcAddress( 'glVertexBlendEnvfATI' , ADDRESSOF( VertexBlendEnvfATI ));
END Read_GL_ATI_vertex_streams;

PROCEDURE Read_GL_AMD_performance_monitor*;
BEGIN
	GetProcAddress( 'glGetPerfMonitorGroupsAMD' , ADDRESSOF( GetPerfMonitorGroupsAMD ));
	GetProcAddress( 'glGetPerfMonitorCountersAMD' , ADDRESSOF( GetPerfMonitorCountersAMD ));
	GetProcAddress( 'glGetPerfMonitorGroupStringAMD' , ADDRESSOF( GetPerfMonitorGroupStringAMD ));
	GetProcAddress( 'glGetPerfMonitorCounterStringAMD' , ADDRESSOF( GetPerfMonitorCounterStringAMD ));
	GetProcAddress( 'glGetPerfMonitorCounterInfoAMD' , ADDRESSOF( GetPerfMonitorCounterInfoAMD ));
	GetProcAddress( 'glGenPerfMonitorsAMD' , ADDRESSOF( GenPerfMonitorsAMD ));
	GetProcAddress( 'glDeletePerfMonitorsAMD' , ADDRESSOF( DeletePerfMonitorsAMD ));
	GetProcAddress( 'glSelectPerfMonitorCountersAMD' , ADDRESSOF( SelectPerfMonitorCountersAMD ));
	GetProcAddress( 'glBeginPerfMonitorAMD' , ADDRESSOF( BeginPerfMonitorAMD ));
	GetProcAddress( 'glEndPerfMonitorAMD' , ADDRESSOF( EndPerfMonitorAMD ));
	GetProcAddress( 'glGetPerfMonitorCounterDataAMD' , ADDRESSOF( GetPerfMonitorCounterDataAMD ));
END Read_GL_AMD_performance_monitor;

PROCEDURE Read_GL_AMD_vertex_shader_tesselator*;
BEGIN
	GetProcAddress( 'glTessellationFactorAMD' , ADDRESSOF( TessellationFactorAMD ));
	GetProcAddress( 'glTessellationModeAMD' , ADDRESSOF( TessellationModeAMD ));
END Read_GL_AMD_vertex_shader_tesselator;

PROCEDURE Read_GL_AMD_draw_buffers_blend*;
BEGIN
	GetProcAddress( 'glBlendFuncIndexedAMD' , ADDRESSOF( BlendFuncIndexedAMD ));
	GetProcAddress( 'glBlendFuncSeparateIndexedAMD' , ADDRESSOF( BlendFuncSeparateIndexedAMD ));
	GetProcAddress( 'glBlendEquationIndexedAMD' , ADDRESSOF( BlendEquationIndexedAMD ));
	GetProcAddress( 'glBlendEquationSeparateIndexedAMD' , ADDRESSOF( BlendEquationSeparateIndexedAMD ));
END Read_GL_AMD_draw_buffers_blend;

PROCEDURE Read_GL_AMD_name_gen_delete*;
BEGIN
	GetProcAddress( 'glGenNamesAMD' , ADDRESSOF( GenNamesAMD ));
	GetProcAddress( 'glDeleteNamesAMD' , ADDRESSOF( DeleteNamesAMD ));
	GetProcAddress( 'glIsNameAMD' , ADDRESSOF( IsNameAMD ));
END Read_GL_AMD_name_gen_delete;

PROCEDURE Read_GL_AMD_debug_output*;
BEGIN
	GetProcAddress( 'glDebugMessageEnableAMD' , ADDRESSOF( DebugMessageEnableAMD ));
	GetProcAddress( 'glDebugMessageInsertAMD' , ADDRESSOF( DebugMessageInsertAMD ));
	GetProcAddress( 'glDebugMessageCallbackAMD' , ADDRESSOF( DebugMessageCallbackAMD ));
	GetProcAddress( 'glGetDebugMessageLogAMD' , ADDRESSOF( GetDebugMessageLogAMD ));
END Read_GL_AMD_debug_output;

PROCEDURE Read_GL_EXT_blend_color*;
BEGIN
	GetProcAddress( 'glBlendColorEXT' , ADDRESSOF( BlendColorEXT ));
END Read_GL_EXT_blend_color;

PROCEDURE Read_GL_EXT_blend_func_separate*;
BEGIN
	GetProcAddress( 'glBlendFuncSeparateEXT' , ADDRESSOF( BlendFuncSeparateEXT ));
END Read_GL_EXT_blend_func_separate;

PROCEDURE Read_GL_EXT_blend_minmax*;
BEGIN
	GetProcAddress( 'glBlendEquationEXT' , ADDRESSOF( BlendEquationEXT ));
END Read_GL_EXT_blend_minmax;

PROCEDURE Read_GL_EXT_color_subtable*;
BEGIN
	GetProcAddress( 'glColorSubTableEXT' , ADDRESSOF( ColorSubTableEXT ));
	GetProcAddress( 'glCopyColorSubTableEXT' , ADDRESSOF( CopyColorSubTableEXT ));
END Read_GL_EXT_color_subtable;

PROCEDURE Read_GL_EXT_compiled_vertex_array*;
BEGIN
	GetProcAddress( 'glLockArraysEXT' , ADDRESSOF( LockArraysEXT ));
	GetProcAddress( 'glUnlockArraysEXT' , ADDRESSOF( UnlockArraysEXT ));
END Read_GL_EXT_compiled_vertex_array;

PROCEDURE Read_GL_EXT_convolution*;
BEGIN
	GetProcAddress( 'glConvolutionFilter1DEXT' , ADDRESSOF( ConvolutionFilter1DEXT ));
	GetProcAddress( 'glConvolutionFilter2DEXT' , ADDRESSOF( ConvolutionFilter2DEXT ));
	GetProcAddress( 'glConvolutionParameterfEXT' , ADDRESSOF( ConvolutionParameterfEXT ));
	GetProcAddress( 'glConvolutionParameterfvEXT' , ADDRESSOF( ConvolutionParameterfvEXT ));
	GetProcAddress( 'glConvolutionParameteriEXT' , ADDRESSOF( ConvolutionParameteriEXT ));
	GetProcAddress( 'glConvolutionParameterivEXT' , ADDRESSOF( ConvolutionParameterivEXT ));
	GetProcAddress( 'glCopyConvolutionFilter1DEXT' , ADDRESSOF( CopyConvolutionFilter1DEXT ));
	GetProcAddress( 'glCopyConvolutionFilter2DEXT' , ADDRESSOF( CopyConvolutionFilter2DEXT ));
	GetProcAddress( 'glGetConvolutionFilterEXT' , ADDRESSOF( GetConvolutionFilterEXT ));
	GetProcAddress( 'glGetConvolutionParameterfvEXT' , ADDRESSOF( GetConvolutionParameterfvEXT ));
	GetProcAddress( 'glGetConvolutionParameterivEXT' , ADDRESSOF( GetConvolutionParameterivEXT ));
	GetProcAddress( 'glGetSeparableFilterEXT' , ADDRESSOF( GetSeparableFilterEXT ));
	GetProcAddress( 'glSeparableFilter2DEXT' , ADDRESSOF( SeparableFilter2DEXT ));
END Read_GL_EXT_convolution;

PROCEDURE Read_GL_EXT_coordinate_frame*;
BEGIN
	GetProcAddress( 'glTangent3bEXT' , ADDRESSOF( Tangent3bEXT ));
	GetProcAddress( 'glTangent3bvEXT' , ADDRESSOF( Tangent3bvEXT ));
	GetProcAddress( 'glTangent3dEXT' , ADDRESSOF( Tangent3dEXT ));
	GetProcAddress( 'glTangent3dvEXT' , ADDRESSOF( Tangent3dvEXT ));
	GetProcAddress( 'glTangent3fEXT' , ADDRESSOF( Tangent3fEXT ));
	GetProcAddress( 'glTangent3fvEXT' , ADDRESSOF( Tangent3fvEXT ));
	GetProcAddress( 'glTangent3iEXT' , ADDRESSOF( Tangent3iEXT ));
	GetProcAddress( 'glTangent3ivEXT' , ADDRESSOF( Tangent3ivEXT ));
	GetProcAddress( 'glTangent3sEXT' , ADDRESSOF( Tangent3sEXT ));
	GetProcAddress( 'glTangent3svEXT' , ADDRESSOF( Tangent3svEXT ));
	GetProcAddress( 'glBinormal3bEXT' , ADDRESSOF( Binormal3bEXT ));
	GetProcAddress( 'glBinormal3bvEXT' , ADDRESSOF( Binormal3bvEXT ));
	GetProcAddress( 'glBinormal3dEXT' , ADDRESSOF( Binormal3dEXT ));
	GetProcAddress( 'glBinormal3dvEXT' , ADDRESSOF( Binormal3dvEXT ));
	GetProcAddress( 'glBinormal3fEXT' , ADDRESSOF( Binormal3fEXT ));
	GetProcAddress( 'glBinormal3fvEXT' , ADDRESSOF( Binormal3fvEXT ));
	GetProcAddress( 'glBinormal3iEXT' , ADDRESSOF( Binormal3iEXT ));
	GetProcAddress( 'glBinormal3ivEXT' , ADDRESSOF( Binormal3ivEXT ));
	GetProcAddress( 'glBinormal3sEXT' , ADDRESSOF( Binormal3sEXT ));
	GetProcAddress( 'glBinormal3svEXT' , ADDRESSOF( Binormal3svEXT ));
	GetProcAddress( 'glTangentPointerEXT' , ADDRESSOF( TangentPointerEXT ));
	GetProcAddress( 'glBinormalPointerEXT' , ADDRESSOF( BinormalPointerEXT ));
END Read_GL_EXT_coordinate_frame;

PROCEDURE Read_GL_EXT_copy_texture*;
BEGIN
	GetProcAddress( 'glCopyTexImage1DEXT' , ADDRESSOF( CopyTexImage1DEXT ));
	GetProcAddress( 'glCopyTexImage2DEXT' , ADDRESSOF( CopyTexImage2DEXT ));
	GetProcAddress( 'glCopyTexSubImage1DEXT' , ADDRESSOF( CopyTexSubImage1DEXT ));
	GetProcAddress( 'glCopyTexSubImage2DEXT' , ADDRESSOF( CopyTexSubImage2DEXT ));
	GetProcAddress( 'glCopyTexSubImage3DEXT' , ADDRESSOF( CopyTexSubImage3DEXT ));
END Read_GL_EXT_copy_texture;

PROCEDURE Read_GL_EXT_cull_vertex*;
BEGIN
	GetProcAddress( 'glCullParameterdvEXT' , ADDRESSOF( CullParameterdvEXT ));
	GetProcAddress( 'glCullParameterfvEXT' , ADDRESSOF( CullParameterfvEXT ));
END Read_GL_EXT_cull_vertex;

PROCEDURE Read_GL_EXT_draw_range_elements*;
BEGIN
	GetProcAddress( 'glDrawRangeElementsEXT' , ADDRESSOF( DrawRangeElementsEXT ));
END Read_GL_EXT_draw_range_elements;

PROCEDURE Read_GL_EXT_fog_coord*;
BEGIN
	GetProcAddress( 'glFogCoordfEXT' , ADDRESSOF( FogCoordfEXT ));
	GetProcAddress( 'glFogCoordfvEXT' , ADDRESSOF( FogCoordfvEXT ));
	GetProcAddress( 'glFogCoorddEXT' , ADDRESSOF( FogCoorddEXT ));
	GetProcAddress( 'glFogCoorddvEXT' , ADDRESSOF( FogCoorddvEXT ));
	GetProcAddress( 'glFogCoordPointerEXT' , ADDRESSOF( FogCoordPointerEXT ));
END Read_GL_EXT_fog_coord;

PROCEDURE Read_GL_EXT_framebuffer_object*;
BEGIN
	GetProcAddress( 'glIsRenderbufferEXT' , ADDRESSOF( IsRenderbufferEXT ));
	GetProcAddress( 'glBindRenderbufferEXT' , ADDRESSOF( BindRenderbufferEXT ));
	GetProcAddress( 'glDeleteRenderbuffersEXT' , ADDRESSOF( DeleteRenderbuffersEXT ));
	GetProcAddress( 'glGenRenderbuffersEXT' , ADDRESSOF( GenRenderbuffersEXT ));
	GetProcAddress( 'glRenderbufferStorageEXT' , ADDRESSOF( RenderbufferStorageEXT ));
	GetProcAddress( 'glGetRenderbufferParameterivEXT' , ADDRESSOF( GetRenderbufferParameterivEXT ));
	GetProcAddress( 'glIsFramebufferEXT' , ADDRESSOF( IsFramebufferEXT ));
	GetProcAddress( 'glBindFramebufferEXT' , ADDRESSOF( BindFramebufferEXT ));
	GetProcAddress( 'glDeleteFramebuffersEXT' , ADDRESSOF( DeleteFramebuffersEXT ));
	GetProcAddress( 'glGenFramebuffersEXT' , ADDRESSOF( GenFramebuffersEXT ));
	GetProcAddress( 'glCheckFramebufferStatusEXT' , ADDRESSOF( CheckFramebufferStatusEXT ));
	GetProcAddress( 'glFramebufferTexture1DEXT' , ADDRESSOF( FramebufferTexture1DEXT ));
	GetProcAddress( 'glFramebufferTexture2DEXT' , ADDRESSOF( FramebufferTexture2DEXT ));
	GetProcAddress( 'glFramebufferTexture3DEXT' , ADDRESSOF( FramebufferTexture3DEXT ));
	GetProcAddress( 'glFramebufferRenderbufferEXT' , ADDRESSOF( FramebufferRenderbufferEXT ));
	GetProcAddress( 'glGetFramebufferAttachmentParameterivEXT' , ADDRESSOF( GetFramebufferAttachmentParameterivEXT ));
	GetProcAddress( 'glGenerateMipmapEXT' , ADDRESSOF( GenerateMipmapEXT ));
END Read_GL_EXT_framebuffer_object;

PROCEDURE Read_GL_EXT_histogram*;
BEGIN
	GetProcAddress( 'glGetHistogramEXT' , ADDRESSOF( GetHistogramEXT ));
	GetProcAddress( 'glGetHistogramParameterfvEXT' , ADDRESSOF( GetHistogramParameterfvEXT ));
	GetProcAddress( 'glGetHistogramParameterivEXT' , ADDRESSOF( GetHistogramParameterivEXT ));
	GetProcAddress( 'glGetMinmaxEXT' , ADDRESSOF( GetMinmaxEXT ));
	GetProcAddress( 'glGetMinmaxParameterfvEXT' , ADDRESSOF( GetMinmaxParameterfvEXT ));
	GetProcAddress( 'glGetMinmaxParameterivEXT' , ADDRESSOF( GetMinmaxParameterivEXT ));
	GetProcAddress( 'glHistogramEXT' , ADDRESSOF( HistogramEXT ));
	GetProcAddress( 'glMinmaxEXT' , ADDRESSOF( MinmaxEXT ));
	GetProcAddress( 'glResetHistogramEXT' , ADDRESSOF( ResetHistogramEXT ));
	GetProcAddress( 'glResetMinmaxEXT' , ADDRESSOF( ResetMinmaxEXT ));
END Read_GL_EXT_histogram;

PROCEDURE Read_GL_EXT_index_func*;
BEGIN
	GetProcAddress( 'glIndexFuncEXT' , ADDRESSOF( IndexFuncEXT ));
END Read_GL_EXT_index_func;

PROCEDURE Read_GL_EXT_index_material*;
BEGIN
	GetProcAddress( 'glIndexMaterialEXT' , ADDRESSOF( IndexMaterialEXT ));
END Read_GL_EXT_index_material;

PROCEDURE Read_GL_EXT_light_texture*;
BEGIN
	GetProcAddress( 'glApplyTextureEXT' , ADDRESSOF( ApplyTextureEXT ));
	GetProcAddress( 'glTextureLightEXT' , ADDRESSOF( TextureLightEXT ));
	GetProcAddress( 'glTextureMaterialEXT' , ADDRESSOF( TextureMaterialEXT ));
END Read_GL_EXT_light_texture;

PROCEDURE Read_GL_EXT_multi_draw_arrays*;
BEGIN
	GetProcAddress( 'glMultiDrawArraysEXT' , ADDRESSOF( MultiDrawArraysEXT ));
	GetProcAddress( 'glMultiDrawElementsEXT' , ADDRESSOF( MultiDrawElementsEXT ));
END Read_GL_EXT_multi_draw_arrays;

PROCEDURE Read_GL_EXT_multisample*;
BEGIN
	GetProcAddress( 'glSampleMaskEXT' , ADDRESSOF( SampleMaskEXT ));
	GetProcAddress( 'glSamplePatternEXT' , ADDRESSOF( SamplePatternEXT ));
END Read_GL_EXT_multisample;

PROCEDURE Read_GL_EXT_paletted_texture*;
BEGIN
	GetProcAddress( 'glColorTableEXT' , ADDRESSOF( ColorTableEXT ));
	GetProcAddress( 'glGetColorTableEXT' , ADDRESSOF( GetColorTableEXT ));
	GetProcAddress( 'glGetColorTableParameterivEXT' , ADDRESSOF( GetColorTableParameterivEXT ));
	GetProcAddress( 'glGetColorTableParameterfvEXT' , ADDRESSOF( GetColorTableParameterfvEXT ));
END Read_GL_EXT_paletted_texture;

PROCEDURE Read_GL_EXT_pixel_transform*;
BEGIN
	GetProcAddress( 'glPixelTransformParameteriEXT' , ADDRESSOF( PixelTransformParameteriEXT ));
	GetProcAddress( 'glPixelTransformParameterfEXT' , ADDRESSOF( PixelTransformParameterfEXT ));
	GetProcAddress( 'glPixelTransformParameterivEXT' , ADDRESSOF( PixelTransformParameterivEXT ));
	GetProcAddress( 'glPixelTransformParameterfvEXT' , ADDRESSOF( PixelTransformParameterfvEXT ));
END Read_GL_EXT_pixel_transform;

PROCEDURE Read_GL_EXT_point_parameters*;
BEGIN
	GetProcAddress( 'glPointParameterfEXT' , ADDRESSOF( PointParameterfEXT ));
	GetProcAddress( 'glPointParameterfvEXT' , ADDRESSOF( PointParameterfvEXT ));
END Read_GL_EXT_point_parameters;

PROCEDURE Read_GL_EXT_polygon_offset*;
BEGIN
	GetProcAddress( 'glPolygonOffsetEXT' , ADDRESSOF( PolygonOffsetEXT ));
END Read_GL_EXT_polygon_offset;

PROCEDURE Read_GL_EXT_secondary_color*;
BEGIN
	GetProcAddress( 'glSecondaryColor3bEXT' , ADDRESSOF( SecondaryColor3bEXT ));
	GetProcAddress( 'glSecondaryColor3bvEXT' , ADDRESSOF( SecondaryColor3bvEXT ));
	GetProcAddress( 'glSecondaryColor3dEXT' , ADDRESSOF( SecondaryColor3dEXT ));
	GetProcAddress( 'glSecondaryColor3dvEXT' , ADDRESSOF( SecondaryColor3dvEXT ));
	GetProcAddress( 'glSecondaryColor3fEXT' , ADDRESSOF( SecondaryColor3fEXT ));
	GetProcAddress( 'glSecondaryColor3fvEXT' , ADDRESSOF( SecondaryColor3fvEXT ));
	GetProcAddress( 'glSecondaryColor3iEXT' , ADDRESSOF( SecondaryColor3iEXT ));
	GetProcAddress( 'glSecondaryColor3ivEXT' , ADDRESSOF( SecondaryColor3ivEXT ));
	GetProcAddress( 'glSecondaryColor3sEXT' , ADDRESSOF( SecondaryColor3sEXT ));
	GetProcAddress( 'glSecondaryColor3svEXT' , ADDRESSOF( SecondaryColor3svEXT ));
	GetProcAddress( 'glSecondaryColor3ubEXT' , ADDRESSOF( SecondaryColor3ubEXT ));
	GetProcAddress( 'glSecondaryColor3ubvEXT' , ADDRESSOF( SecondaryColor3ubvEXT ));
	GetProcAddress( 'glSecondaryColor3uiEXT' , ADDRESSOF( SecondaryColor3uiEXT ));
	GetProcAddress( 'glSecondaryColor3uivEXT' , ADDRESSOF( SecondaryColor3uivEXT ));
	GetProcAddress( 'glSecondaryColor3usEXT' , ADDRESSOF( SecondaryColor3usEXT ));
	GetProcAddress( 'glSecondaryColor3usvEXT' , ADDRESSOF( SecondaryColor3usvEXT ));
	GetProcAddress( 'glSecondaryColorPointerEXT' , ADDRESSOF( SecondaryColorPointerEXT ));
END Read_GL_EXT_secondary_color;

PROCEDURE Read_GL_EXT_stencil_two_side*;
BEGIN
	GetProcAddress( 'glActiveStencilFaceEXT' , ADDRESSOF( ActiveStencilFaceEXT ));
END Read_GL_EXT_stencil_two_side;

PROCEDURE Read_GL_EXT_subtexture*;
BEGIN
	GetProcAddress( 'glTexSubImage1DEXT' , ADDRESSOF( TexSubImage1DEXT ));
	GetProcAddress( 'glTexSubImage2DEXT' , ADDRESSOF( TexSubImage2DEXT ));
END Read_GL_EXT_subtexture;

PROCEDURE Read_GL_EXT_texture3D*;
BEGIN
	GetProcAddress( 'glTexImage3DEXT' , ADDRESSOF( TexImage3DEXT ));
	GetProcAddress( 'glTexSubImage3DEXT' , ADDRESSOF( TexSubImage3DEXT ));
END Read_GL_EXT_texture3D;

PROCEDURE Read_GL_EXT_texture_object*;
BEGIN
	GetProcAddress( 'glAreTexturesResidentEXT' , ADDRESSOF( AreTexturesResidentEXT ));
	GetProcAddress( 'glBindTextureEXT' , ADDRESSOF( BindTextureEXT ));
	GetProcAddress( 'glDeleteTexturesEXT' , ADDRESSOF( DeleteTexturesEXT ));
	GetProcAddress( 'glGenTexturesEXT' , ADDRESSOF( GenTexturesEXT ));
	GetProcAddress( 'glIsTextureEXT' , ADDRESSOF( IsTextureEXT ));
	GetProcAddress( 'glPrioritizeTexturesEXT' , ADDRESSOF( PrioritizeTexturesEXT ));
END Read_GL_EXT_texture_object;

PROCEDURE Read_GL_EXT_texture_perturb_normal*;
BEGIN
	GetProcAddress( 'glTextureNormalEXT' , ADDRESSOF( TextureNormalEXT ));
END Read_GL_EXT_texture_perturb_normal;

PROCEDURE Read_GL_EXT_vertex_array*;
BEGIN
	GetProcAddress( 'glArrayElementEXT' , ADDRESSOF( ArrayElementEXT ));
	GetProcAddress( 'glColorPointerEXT' , ADDRESSOF( ColorPointerEXT ));
	GetProcAddress( 'glDrawArraysEXT' , ADDRESSOF( DrawArraysEXT ));
	GetProcAddress( 'glEdgeFlagPointerEXT' , ADDRESSOF( EdgeFlagPointerEXT ));
	GetProcAddress( 'glGetPointervEXT' , ADDRESSOF( GetPointervEXT ));
	GetProcAddress( 'glIndexPointerEXT' , ADDRESSOF( IndexPointerEXT ));
	GetProcAddress( 'glNormalPointerEXT' , ADDRESSOF( NormalPointerEXT ));
	GetProcAddress( 'glTexCoordPointerEXT' , ADDRESSOF( TexCoordPointerEXT ));
	GetProcAddress( 'glVertexPointerEXT' , ADDRESSOF( VertexPointerEXT ));
END Read_GL_EXT_vertex_array;

PROCEDURE Read_GL_EXT_vertex_shader*;
BEGIN
	GetProcAddress( 'glBeginVertexShaderEXT' , ADDRESSOF( BeginVertexShaderEXT ));
	GetProcAddress( 'glEndVertexShaderEXT' , ADDRESSOF( EndVertexShaderEXT ));
	GetProcAddress( 'glBindVertexShaderEXT' , ADDRESSOF( BindVertexShaderEXT ));
	GetProcAddress( 'glGenVertexShadersEXT' , ADDRESSOF( GenVertexShadersEXT ));
	GetProcAddress( 'glDeleteVertexShaderEXT' , ADDRESSOF( DeleteVertexShaderEXT ));
	GetProcAddress( 'glShaderOp1EXT' , ADDRESSOF( ShaderOp1EXT ));
	GetProcAddress( 'glShaderOp2EXT' , ADDRESSOF( ShaderOp2EXT ));
	GetProcAddress( 'glShaderOp3EXT' , ADDRESSOF( ShaderOp3EXT ));
	GetProcAddress( 'glSwizzleEXT' , ADDRESSOF( SwizzleEXT ));
	GetProcAddress( 'glWriteMaskEXT' , ADDRESSOF( WriteMaskEXT ));
	GetProcAddress( 'glInsertComponentEXT' , ADDRESSOF( InsertComponentEXT ));
	GetProcAddress( 'glExtractComponentEXT' , ADDRESSOF( ExtractComponentEXT ));
	GetProcAddress( 'glGenSymbolsEXT' , ADDRESSOF( GenSymbolsEXT ));
	GetProcAddress( 'glSetInvariantEXT' , ADDRESSOF( SetInvariantEXT ));
	GetProcAddress( 'glSetLocalConstantEXT' , ADDRESSOF( SetLocalConstantEXT ));
	GetProcAddress( 'glVariantbvEXT' , ADDRESSOF( VariantbvEXT ));
	GetProcAddress( 'glVariantsvEXT' , ADDRESSOF( VariantsvEXT ));
	GetProcAddress( 'glVariantivEXT' , ADDRESSOF( VariantivEXT ));
	GetProcAddress( 'glVariantfvEXT' , ADDRESSOF( VariantfvEXT ));
	GetProcAddress( 'glVariantdvEXT' , ADDRESSOF( VariantdvEXT ));
	GetProcAddress( 'glVariantubvEXT' , ADDRESSOF( VariantubvEXT ));
	GetProcAddress( 'glVariantusvEXT' , ADDRESSOF( VariantusvEXT ));
	GetProcAddress( 'glVariantuivEXT' , ADDRESSOF( VariantuivEXT ));
	GetProcAddress( 'glVariantPointerEXT' , ADDRESSOF( VariantPointerEXT ));
	GetProcAddress( 'glEnableVariantClientStateEXT' , ADDRESSOF( EnableVariantClientStateEXT ));
	GetProcAddress( 'glDisableVariantClientStateEXT' , ADDRESSOF( DisableVariantClientStateEXT ));
	GetProcAddress( 'glBindLightParameterEXT' , ADDRESSOF( BindLightParameterEXT ));
	GetProcAddress( 'glBindMaterialParameterEXT' , ADDRESSOF( BindMaterialParameterEXT ));
	GetProcAddress( 'glBindTexGenParameterEXT' , ADDRESSOF( BindTexGenParameterEXT ));
	GetProcAddress( 'glBindTextureUnitParameterEXT' , ADDRESSOF( BindTextureUnitParameterEXT ));
	GetProcAddress( 'glBindParameterEXT' , ADDRESSOF( BindParameterEXT ));
	GetProcAddress( 'glIsVariantEnabledEXT' , ADDRESSOF( IsVariantEnabledEXT ));
	GetProcAddress( 'glGetVariantBooleanvEXT' , ADDRESSOF( GetVariantBooleanvEXT ));
	GetProcAddress( 'glGetVariantIntegervEXT' , ADDRESSOF( GetVariantIntegervEXT ));
	GetProcAddress( 'glGetVariantFloatvEXT' , ADDRESSOF( GetVariantFloatvEXT ));
	GetProcAddress( 'glGetVariantPointervEXT' , ADDRESSOF( GetVariantPointervEXT ));
	GetProcAddress( 'glGetInvariantBooleanvEXT' , ADDRESSOF( GetInvariantBooleanvEXT ));
	GetProcAddress( 'glGetInvariantIntegervEXT' , ADDRESSOF( GetInvariantIntegervEXT ));
	GetProcAddress( 'glGetInvariantFloatvEXT' , ADDRESSOF( GetInvariantFloatvEXT ));
	GetProcAddress( 'glGetLocalConstantBooleanvEXT' , ADDRESSOF( GetLocalConstantBooleanvEXT ));
	GetProcAddress( 'glGetLocalConstantIntegervEXT' , ADDRESSOF( GetLocalConstantIntegervEXT ));
	GetProcAddress( 'glGetLocalConstantFloatvEXT' , ADDRESSOF( GetLocalConstantFloatvEXT ));
END Read_GL_EXT_vertex_shader;

PROCEDURE Read_GL_EXT_vertex_weighting*;
BEGIN
	GetProcAddress( 'glVertexWeightfEXT' , ADDRESSOF( VertexWeightfEXT ));
	GetProcAddress( 'glVertexWeightfvEXT' , ADDRESSOF( VertexWeightfvEXT ));
	GetProcAddress( 'glVertexWeightPointerEXT' , ADDRESSOF( VertexWeightPointerEXT ));
END Read_GL_EXT_vertex_weighting;

PROCEDURE Read_GL_EXT_depth_bounds_test*;
BEGIN
	GetProcAddress( 'glImageTransformParameteriHP' , ADDRESSOF( ImageTransformParameteriHP ));
	GetProcAddress( 'glDepthBoundsEXT' , ADDRESSOF( DepthBoundsEXT ));
END Read_GL_EXT_depth_bounds_test;

PROCEDURE Read_GL_EXT_blend_equation_separate*;
BEGIN
	GetProcAddress( 'glBlendEquationSeparateEXT' , ADDRESSOF( BlendEquationSeparateEXT ));
END Read_GL_EXT_blend_equation_separate;

PROCEDURE Read_GL_EXT_stencil_clear_tag*;
BEGIN
	GetProcAddress( 'glStencilClearTagEXT' , ADDRESSOF( StencilClearTagEXT ));
END Read_GL_EXT_stencil_clear_tag;

PROCEDURE Read_GL_EXT_framebuffer_blit*;
BEGIN
	GetProcAddress( 'glBlitFramebufferEXT' , ADDRESSOF( BlitFramebufferEXT ));
END Read_GL_EXT_framebuffer_blit;

PROCEDURE Read_GL_EXT_framebuffer_multisample*;
BEGIN
	GetProcAddress( 'glRenderbufferStorageMultisampleEXT' , ADDRESSOF( RenderbufferStorageMultisampleEXT ));
END Read_GL_EXT_framebuffer_multisample;

PROCEDURE Read_GL_EXT_timer_query*;
BEGIN
	GetProcAddress( 'glGetQueryObjecti64vEXT' , ADDRESSOF( GetQueryObjecti64vEXT ));
	GetProcAddress( 'glGetQueryObjectui64vEXT' , ADDRESSOF( GetQueryObjectui64vEXT ));
END Read_GL_EXT_timer_query;

PROCEDURE Read_GL_EXT_gpu_program_parameters*;
BEGIN
	GetProcAddress( 'glProgramEnvParameters4fvEXT' , ADDRESSOF( ProgramEnvParameters4fvEXT ));
	GetProcAddress( 'glProgramLocalParameters4fvEXT' , ADDRESSOF( ProgramLocalParameters4fvEXT ));
END Read_GL_EXT_gpu_program_parameters;

PROCEDURE Read_GL_EXT_bindable_uniform*;
BEGIN
	GetProcAddress( 'glUniformBufferEXT' , ADDRESSOF( UniformBufferEXT ));
	GetProcAddress( 'glGetUniformBufferSizeEXT' , ADDRESSOF( GetUniformBufferSizeEXT ));
	GetProcAddress( 'glGetUniformOffsetEXT' , ADDRESSOF( GetUniformOffsetEXT ));
END Read_GL_EXT_bindable_uniform;

PROCEDURE Read_GL_EXT_draw_buffers2*;
BEGIN
	GetProcAddress( 'glColorMaskIndexedEXT' , ADDRESSOF( ColorMaskIndexedEXT ));
	GetProcAddress( 'glGetBooleanIndexedvEXT' , ADDRESSOF( GetBooleanIndexedvEXT ));
	GetProcAddress( 'glGetIntegerIndexedvEXT' , ADDRESSOF( GetIntegerIndexedvEXT ));
	GetProcAddress( 'glEnableIndexedEXT' , ADDRESSOF( EnableIndexedEXT ));
	GetProcAddress( 'glDisableIndexedEXT' , ADDRESSOF( DisableIndexedEXT ));
	GetProcAddress( 'glIsEnabledIndexedEXT' , ADDRESSOF( IsEnabledIndexedEXT ));
END Read_GL_EXT_draw_buffers2;

PROCEDURE Read_GL_EXT_draw_instanced*;
BEGIN
	GetProcAddress( 'glDrawArraysInstancedEXT' , ADDRESSOF( DrawArraysInstancedEXT ));
	GetProcAddress( 'glDrawElementsInstancedEXT' , ADDRESSOF( DrawElementsInstancedEXT ));
END Read_GL_EXT_draw_instanced;

PROCEDURE Read_GL_EXT_geometry_shader4*;
BEGIN
	GetProcAddress( 'glProgramParameteriEXT' , ADDRESSOF( ProgramParameteriEXT ));
	GetProcAddress( 'glFramebufferTextureEXT' , ADDRESSOF( FramebufferTextureEXT ));
(*	GetProcAddress( 'glFramebufferTextureLayerEXT' , ADDRESSOF( FramebufferTextureLayerEXT )); *)
	GetProcAddress( 'glFramebufferTextureFaceEXT' , ADDRESSOF( FramebufferTextureFaceEXT ));
END Read_GL_EXT_geometry_shader4;

PROCEDURE Read_GL_EXT_gpu_shader4*;
BEGIN
	GetProcAddress( 'glVertexAttribI1iEXT' , ADDRESSOF( VertexAttribI1iEXT ));
	GetProcAddress( 'glVertexAttribI2iEXT' , ADDRESSOF( VertexAttribI2iEXT ));
	GetProcAddress( 'glVertexAttribI3iEXT' , ADDRESSOF( VertexAttribI3iEXT ));
	GetProcAddress( 'glVertexAttribI4iEXT' , ADDRESSOF( VertexAttribI4iEXT ));
	GetProcAddress( 'glVertexAttribI1uiEXT' , ADDRESSOF( VertexAttribI1uiEXT ));
	GetProcAddress( 'glVertexAttribI2uiEXT' , ADDRESSOF( VertexAttribI2uiEXT ));
	GetProcAddress( 'glVertexAttribI3uiEXT' , ADDRESSOF( VertexAttribI3uiEXT ));
	GetProcAddress( 'glVertexAttribI4uiEXT' , ADDRESSOF( VertexAttribI4uiEXT ));
	GetProcAddress( 'glVertexAttribI1ivEXT' , ADDRESSOF( VertexAttribI1ivEXT ));
	GetProcAddress( 'glVertexAttribI2ivEXT' , ADDRESSOF( VertexAttribI2ivEXT ));
	GetProcAddress( 'glVertexAttribI3ivEXT' , ADDRESSOF( VertexAttribI3ivEXT ));
	GetProcAddress( 'glVertexAttribI4ivEXT' , ADDRESSOF( VertexAttribI4ivEXT ));
	GetProcAddress( 'glVertexAttribI1uivEXT' , ADDRESSOF( VertexAttribI1uivEXT ));
	GetProcAddress( 'glVertexAttribI2uivEXT' , ADDRESSOF( VertexAttribI2uivEXT ));
	GetProcAddress( 'glVertexAttribI3uivEXT' , ADDRESSOF( VertexAttribI3uivEXT ));
	GetProcAddress( 'glVertexAttribI4uivEXT' , ADDRESSOF( VertexAttribI4uivEXT ));
	GetProcAddress( 'glVertexAttribI4bvEXT' , ADDRESSOF( VertexAttribI4bvEXT ));
	GetProcAddress( 'glVertexAttribI4svEXT' , ADDRESSOF( VertexAttribI4svEXT ));
	GetProcAddress( 'glVertexAttribI4ubvEXT' , ADDRESSOF( VertexAttribI4ubvEXT ));
	GetProcAddress( 'glVertexAttribI4usvEXT' , ADDRESSOF( VertexAttribI4usvEXT ));
	GetProcAddress( 'glVertexAttribIPointerEXT' , ADDRESSOF( VertexAttribIPointerEXT ));
	GetProcAddress( 'glGetVertexAttribIivEXT' , ADDRESSOF( GetVertexAttribIivEXT ));
	GetProcAddress( 'glGetVertexAttribIuivEXT' , ADDRESSOF( GetVertexAttribIuivEXT ));
	GetProcAddress( 'glUniform1uiEXT' , ADDRESSOF( Uniform1uiEXT ));
	GetProcAddress( 'glUniform2uiEXT' , ADDRESSOF( Uniform2uiEXT ));
	GetProcAddress( 'glUniform3uiEXT' , ADDRESSOF( Uniform3uiEXT ));
	GetProcAddress( 'glUniform4uiEXT' , ADDRESSOF( Uniform4uiEXT ));
	GetProcAddress( 'glUniform1uivEXT' , ADDRESSOF( Uniform1uivEXT ));
	GetProcAddress( 'glUniform2uivEXT' , ADDRESSOF( Uniform2uivEXT ));
	GetProcAddress( 'glUniform3uivEXT' , ADDRESSOF( Uniform3uivEXT ));
	GetProcAddress( 'glUniform4uivEXT' , ADDRESSOF( Uniform4uivEXT ));
	GetProcAddress( 'glGetUniformuivEXT' , ADDRESSOF( GetUniformuivEXT ));
	GetProcAddress( 'glBindFragDataLocationEXT' , ADDRESSOF( BindFragDataLocationEXT ));
	GetProcAddress( 'glGetFragDataLocationEXT' , ADDRESSOF( GetFragDataLocationEXT ));
END Read_GL_EXT_gpu_shader4;

PROCEDURE Read_GL_EXT_texture_array*;
BEGIN
	GetProcAddress( 'glFramebufferTextureLayerEXT' , ADDRESSOF( FramebufferTextureLayerEXT ));
END Read_GL_EXT_texture_array;

PROCEDURE Read_GL_EXT_texture_buffer_object*;
BEGIN
	GetProcAddress( 'glTexBufferEXT' , ADDRESSOF( TexBufferEXT ));
END Read_GL_EXT_texture_buffer_object;

PROCEDURE Read_GL_EXT_texture_integer*;
BEGIN
	GetProcAddress( 'glClearColorIiEXT' , ADDRESSOF( ClearColorIiEXT ));
	GetProcAddress( 'glClearColorIuiEXT' , ADDRESSOF( ClearColorIuiEXT ));
	GetProcAddress( 'glTexParameterIivEXT' , ADDRESSOF( TexParameterIivEXT ));
	GetProcAddress( 'glTexParameterIuivEXT' , ADDRESSOF( TexParameterIuivEXT ));
	GetProcAddress( 'glGetTexParameterIivEXT' , ADDRESSOF( GetTexParameterIivEXT ));
	GetProcAddress( 'glGetTexParameterIiuvEXT' , ADDRESSOF( GetTexParameterIiuvEXT ));
END Read_GL_EXT_texture_integer;

PROCEDURE Read_GL_EXT_transform_feedback*;
BEGIN
	GetProcAddress( 'glBeginTransformFeedbackEXT' , ADDRESSOF( BeginTransformFeedbackEXT ));
	GetProcAddress( 'glEndTransformFeedbackEXT' , ADDRESSOF( EndTransformFeedbackEXT ));
	GetProcAddress( 'glBindBufferRangeEXT' , ADDRESSOF( BindBufferRangeEXT ));
	GetProcAddress( 'glBindBufferOffsetEXT' , ADDRESSOF( BindBufferOffsetEXT ));
	GetProcAddress( 'glBindBufferBaseEXT' , ADDRESSOF( BindBufferBaseEXT ));
	GetProcAddress( 'glTransformFeedbackVaryingsEXT' , ADDRESSOF( TransformFeedbackVaryingsEXT ));
	GetProcAddress( 'glGetTransformFeedbackVaryingEXT' , ADDRESSOF( GetTransformFeedbackVaryingEXT ));
END Read_GL_EXT_transform_feedback;

PROCEDURE Read_GL_EXT_direct_state_access*;
BEGIN
	GetProcAddress( 'glClientAttribDefaultEXT' , ADDRESSOF( ClientAttribDefaultEXT ));
	GetProcAddress( 'glPushClientAttribDefaultEXT' , ADDRESSOF( PushClientAttribDefaultEXT ));
	GetProcAddress( 'glMatrixLoadfEXT' , ADDRESSOF( MatrixLoadfEXT ));
	GetProcAddress( 'glMatrixLoaddEXT' , ADDRESSOF( MatrixLoaddEXT ));
	GetProcAddress( 'glMatrixMultfEXT' , ADDRESSOF( MatrixMultfEXT ));
	GetProcAddress( 'glMatrixMultdEXT' , ADDRESSOF( MatrixMultdEXT ));
	GetProcAddress( 'glMatrixLoadIdentityEXT' , ADDRESSOF( MatrixLoadIdentityEXT ));
	GetProcAddress( 'glMatrixRotatefEXT' , ADDRESSOF( MatrixRotatefEXT ));
	GetProcAddress( 'glMatrixRotatedEXT' , ADDRESSOF( MatrixRotatedEXT ));
	GetProcAddress( 'glMatrixScalefEXT' , ADDRESSOF( MatrixScalefEXT ));
	GetProcAddress( 'glMatrixScaledEXT' , ADDRESSOF( MatrixScaledEXT ));
	GetProcAddress( 'glMatrixTranslatefEXT' , ADDRESSOF( MatrixTranslatefEXT ));
	GetProcAddress( 'glMatrixTranslatedEXT' , ADDRESSOF( MatrixTranslatedEXT ));
	GetProcAddress( 'glMatrixFrustumEXT' , ADDRESSOF( MatrixFrustumEXT ));
	GetProcAddress( 'glMatrixOrthoEXT' , ADDRESSOF( MatrixOrthoEXT ));
	GetProcAddress( 'glMatrixPopEXT' , ADDRESSOF( MatrixPopEXT ));
	GetProcAddress( 'glMatrixPushEXT' , ADDRESSOF( MatrixPushEXT ));
	GetProcAddress( 'glMatrixLoadTransposefEXT' , ADDRESSOF( MatrixLoadTransposefEXT ));
	GetProcAddress( 'glMatrixLoadTransposedEXT' , ADDRESSOF( MatrixLoadTransposedEXT ));
	GetProcAddress( 'glMatrixMultTransposefEXT' , ADDRESSOF( MatrixMultTransposefEXT ));
	GetProcAddress( 'glMatrixMultTransposedEXT' , ADDRESSOF( MatrixMultTransposedEXT ));
	GetProcAddress( 'glTextureParameterfEXT' , ADDRESSOF( TextureParameterfEXT ));
	GetProcAddress( 'glTextureParameterfvEXT' , ADDRESSOF( TextureParameterfvEXT ));
	GetProcAddress( 'glTextureParameteriEXT' , ADDRESSOF( TextureParameteriEXT ));
	GetProcAddress( 'glTextureParameterivEXT' , ADDRESSOF( TextureParameterivEXT ));
	GetProcAddress( 'glTextureImage1DEXT' , ADDRESSOF( TextureImage1DEXT ));
	GetProcAddress( 'glTextureImage2DEXT' , ADDRESSOF( TextureImage2DEXT ));
	GetProcAddress( 'glTextureSubImage1DEXT' , ADDRESSOF( TextureSubImage1DEXT ));
	GetProcAddress( 'glTextureSubImage2DEXT' , ADDRESSOF( TextureSubImage2DEXT ));
	GetProcAddress( 'glCopyTextureImage1DEXT' , ADDRESSOF( CopyTextureImage1DEXT ));
	GetProcAddress( 'glCopyTextureImage2DEXT' , ADDRESSOF( CopyTextureImage2DEXT ));
	GetProcAddress( 'glCopyTextureSubImage1DEXT' , ADDRESSOF( CopyTextureSubImage1DEXT ));
	GetProcAddress( 'glCopyTextureSubImage2DEXT' , ADDRESSOF( CopyTextureSubImage2DEXT ));
	GetProcAddress( 'glGetTextureImageEXT' , ADDRESSOF( GetTextureImageEXT ));
	GetProcAddress( 'glGetTextureParameterfvEXT' , ADDRESSOF( GetTextureParameterfvEXT ));
	GetProcAddress( 'glGetTextureParameterivEXT' , ADDRESSOF( GetTextureParameterivEXT ));
	GetProcAddress( 'glGetTextureLevelParameterfvEXT' , ADDRESSOF( GetTextureLevelParameterfvEXT ));
	GetProcAddress( 'glGetTextureLevelParameterivEXT' , ADDRESSOF( GetTextureLevelParameterivEXT ));
	GetProcAddress( 'glTextureImage3DEXT' , ADDRESSOF( TextureImage3DEXT ));
	GetProcAddress( 'glTextureSubImage3DEXT' , ADDRESSOF( TextureSubImage3DEXT ));
	GetProcAddress( 'glCopyTextureSubImage3DEXT' , ADDRESSOF( CopyTextureSubImage3DEXT ));
	GetProcAddress( 'glMultiTexParameterfEXT' , ADDRESSOF( MultiTexParameterfEXT ));
	GetProcAddress( 'glMultiTexParameterfvEXT' , ADDRESSOF( MultiTexParameterfvEXT ));
	GetProcAddress( 'glMultiTexParameteriEXT' , ADDRESSOF( MultiTexParameteriEXT ));
	GetProcAddress( 'glMultiTexParameterivEXT' , ADDRESSOF( MultiTexParameterivEXT ));
	GetProcAddress( 'glMultiTexImage1DEXT' , ADDRESSOF( MultiTexImage1DEXT ));
	GetProcAddress( 'glMultiTexImage2DEXT' , ADDRESSOF( MultiTexImage2DEXT ));
	GetProcAddress( 'glMultiTexSubImage1DEXT' , ADDRESSOF( MultiTexSubImage1DEXT ));
	GetProcAddress( 'glMultiTexSubImage2DEXT' , ADDRESSOF( MultiTexSubImage2DEXT ));
	GetProcAddress( 'glCopyMultiTexImage1DEXT' , ADDRESSOF( CopyMultiTexImage1DEXT ));
	GetProcAddress( 'glCopyMultiTexImage2DEXT' , ADDRESSOF( CopyMultiTexImage2DEXT ));
	GetProcAddress( 'glCopyMultiTexSubImage1DEXT' , ADDRESSOF( CopyMultiTexSubImage1DEXT ));
	GetProcAddress( 'glCopyMultiTexSubImage2DEXT' , ADDRESSOF( CopyMultiTexSubImage2DEXT ));
	GetProcAddress( 'glGetMultiTexImageEXT' , ADDRESSOF( GetMultiTexImageEXT ));
	GetProcAddress( 'glGetMultiTexParameterfvEXT' , ADDRESSOF( GetMultiTexParameterfvEXT ));
	GetProcAddress( 'glGetMultiTexParameterivEXT' , ADDRESSOF( GetMultiTexParameterivEXT ));
	GetProcAddress( 'glGetMultiTexLevelParameterfvEXT' , ADDRESSOF( GetMultiTexLevelParameterfvEXT ));
	GetProcAddress( 'glGetMultiTexLevelParameterivEXT' , ADDRESSOF( GetMultiTexLevelParameterivEXT ));
	GetProcAddress( 'glMultiTexImage3DEXT' , ADDRESSOF( MultiTexImage3DEXT ));
	GetProcAddress( 'glMultiTexSubImage3DEXT' , ADDRESSOF( MultiTexSubImage3DEXT ));
	GetProcAddress( 'glCopyMultiTexSubImage3DEXT' , ADDRESSOF( CopyMultiTexSubImage3DEXT ));
	GetProcAddress( 'glBindMultiTextureEXT' , ADDRESSOF( BindMultiTextureEXT ));
	GetProcAddress( 'glEnableClientStateIndexedEXT' , ADDRESSOF( EnableClientStateIndexedEXT ));
	GetProcAddress( 'glDisableClientStateIndexedEXT' , ADDRESSOF( DisableClientStateIndexedEXT ));
	GetProcAddress( 'glMultiTexCoordPointerEXT' , ADDRESSOF( MultiTexCoordPointerEXT ));
	GetProcAddress( 'glMultiTexEnvfEXT' , ADDRESSOF( MultiTexEnvfEXT ));
	GetProcAddress( 'glMultiTexEnvfvEXT' , ADDRESSOF( MultiTexEnvfvEXT ));
	GetProcAddress( 'glMultiTexEnviEXT' , ADDRESSOF( MultiTexEnviEXT ));
	GetProcAddress( 'glMultiTexEnvivEXT' , ADDRESSOF( MultiTexEnvivEXT ));
	GetProcAddress( 'glMultiTexGendEXT' , ADDRESSOF( MultiTexGendEXT ));
	GetProcAddress( 'glMultiTexGendvEXT' , ADDRESSOF( MultiTexGendvEXT ));
	GetProcAddress( 'glMultiTexGenfEXT' , ADDRESSOF( MultiTexGenfEXT ));
	GetProcAddress( 'glMultiTexGenfvEXT' , ADDRESSOF( MultiTexGenfvEXT ));
	GetProcAddress( 'glMultiTexGeniEXT' , ADDRESSOF( MultiTexGeniEXT ));
	GetProcAddress( 'glMultiTexGenivEXT' , ADDRESSOF( MultiTexGenivEXT ));
	GetProcAddress( 'glGetMultiTexEnvfvEXT' , ADDRESSOF( GetMultiTexEnvfvEXT ));
	GetProcAddress( 'glGetMultiTexEnvivEXT' , ADDRESSOF( GetMultiTexEnvivEXT ));
	GetProcAddress( 'glGetMultiTexGendvEXT' , ADDRESSOF( GetMultiTexGendvEXT ));
	GetProcAddress( 'glGetMultiTexGenfvEXT' , ADDRESSOF( GetMultiTexGenfvEXT ));
	GetProcAddress( 'glGetMultiTexGenivEXT' , ADDRESSOF( GetMultiTexGenivEXT ));
	GetProcAddress( 'glGetFloatIndexedvEXT' , ADDRESSOF( GetFloatIndexedvEXT ));
	GetProcAddress( 'glGetDoubleIndexedvEXT' , ADDRESSOF( GetDoubleIndexedvEXT ));
	GetProcAddress( 'glGetPointerIndexedvEXT' , ADDRESSOF( GetPointerIndexedvEXT ));
	GetProcAddress( 'glCompressedTextureImage3DEXT' , ADDRESSOF( CompressedTextureImage3DEXT ));
	GetProcAddress( 'glCompressedTextureImage2DEXT' , ADDRESSOF( CompressedTextureImage2DEXT ));
	GetProcAddress( 'glCompressedTextureImage1DEXT' , ADDRESSOF( CompressedTextureImage1DEXT ));
	GetProcAddress( 'glCompressedTextureSubImage3DEXT' , ADDRESSOF( CompressedTextureSubImage3DEXT ));
	GetProcAddress( 'glCompressedTextureSubImage2DEXT' , ADDRESSOF( CompressedTextureSubImage2DEXT ));
	GetProcAddress( 'glCompressedTextureSubImage1DEXT' , ADDRESSOF( CompressedTextureSubImage1DEXT ));
	GetProcAddress( 'glGetCompressedTextureImageEXT' , ADDRESSOF( GetCompressedTextureImageEXT ));
	GetProcAddress( 'glCompressedMultiTexImage3DEXT' , ADDRESSOF( CompressedMultiTexImage3DEXT ));
	GetProcAddress( 'glCompressedMultiTexImage2DEXT' , ADDRESSOF( CompressedMultiTexImage2DEXT ));
	GetProcAddress( 'glCompressedMultiTexImage1DEXT' , ADDRESSOF( CompressedMultiTexImage1DEXT ));
	GetProcAddress( 'glCompressedMultiTexSubImage3DEXT' , ADDRESSOF( CompressedMultiTexSubImage3DEXT ));
	GetProcAddress( 'glCompressedMultiTexSubImage2DEXT' , ADDRESSOF( CompressedMultiTexSubImage2DEXT ));
	GetProcAddress( 'glCompressedMultiTexSubImage1DEXT' , ADDRESSOF( CompressedMultiTexSubImage1DEXT ));
	GetProcAddress( 'glGetCompressedMultiTexImageEXT' , ADDRESSOF( GetCompressedMultiTexImageEXT ));
	GetProcAddress( 'glNamedProgramStringEXT' , ADDRESSOF( NamedProgramStringEXT ));
	GetProcAddress( 'glNamedProgramLocalParameter4dEXT' , ADDRESSOF( NamedProgramLocalParameter4dEXT ));
	GetProcAddress( 'glNamedProgramLocalParameter4dvEXT' , ADDRESSOF( NamedProgramLocalParameter4dvEXT ));
	GetProcAddress( 'glNamedProgramLocalParameter4fEXT' , ADDRESSOF( NamedProgramLocalParameter4fEXT ));
	GetProcAddress( 'glNamedProgramLocalParameter4fvEXT' , ADDRESSOF( NamedProgramLocalParameter4fvEXT ));
	GetProcAddress( 'glGetNamedProgramLocalParameterdvEXT' , ADDRESSOF( GetNamedProgramLocalParameterdvEXT ));
	GetProcAddress( 'glGetNamedProgramLocalParameterfvEXT' , ADDRESSOF( GetNamedProgramLocalParameterfvEXT ));
	GetProcAddress( 'glGetNamedProgramivEXT' , ADDRESSOF( GetNamedProgramivEXT ));
	GetProcAddress( 'glGetNamedProgramStringEXT' , ADDRESSOF( GetNamedProgramStringEXT ));
	GetProcAddress( 'glNamedProgramLocalParameters4fvEXT' , ADDRESSOF( NamedProgramLocalParameters4fvEXT ));
	GetProcAddress( 'glNamedProgramLocalParameterI4iEXT' , ADDRESSOF( NamedProgramLocalParameterI4iEXT ));
	GetProcAddress( 'glNamedProgramLocalParameterI4ivEXT' , ADDRESSOF( NamedProgramLocalParameterI4ivEXT ));
	GetProcAddress( 'glNamedProgramLocalParametersI4ivEXT' , ADDRESSOF( NamedProgramLocalParametersI4ivEXT ));
	GetProcAddress( 'glNamedProgramLocalParameterI4uiEXT' , ADDRESSOF( NamedProgramLocalParameterI4uiEXT ));
	GetProcAddress( 'glNamedProgramLocalParameterI4uivEXT' , ADDRESSOF( NamedProgramLocalParameterI4uivEXT ));
	GetProcAddress( 'glNamedProgramLocalParametersI4uivEXT' , ADDRESSOF( NamedProgramLocalParametersI4uivEXT ));
	GetProcAddress( 'glGetNamedProgramLocalParameterIivEXT' , ADDRESSOF( GetNamedProgramLocalParameterIivEXT ));
	GetProcAddress( 'glGetNamedProgramLocalParameterIuivEXT' , ADDRESSOF( GetNamedProgramLocalParameterIuivEXT ));
	GetProcAddress( 'glTextureParameterIivEXT' , ADDRESSOF( TextureParameterIivEXT ));
	GetProcAddress( 'glTextureParameterIuivEXT' , ADDRESSOF( TextureParameterIuivEXT ));
	GetProcAddress( 'glGetTextureParameterIivEXT' , ADDRESSOF( GetTextureParameterIivEXT ));
	GetProcAddress( 'glGetTextureParameterIuivEXT' , ADDRESSOF( GetTextureParameterIuivEXT ));
	GetProcAddress( 'glMultiTexParameterIivEXT' , ADDRESSOF( MultiTexParameterIivEXT ));
	GetProcAddress( 'glMultiTexParameterIuivEXT' , ADDRESSOF( MultiTexParameterIuivEXT ));
	GetProcAddress( 'glGetMultiTexParameterIivEXT' , ADDRESSOF( GetMultiTexParameterIivEXT ));
	GetProcAddress( 'glGetMultiTexParameterIuivEXT' , ADDRESSOF( GetMultiTexParameterIuivEXT ));
	GetProcAddress( 'glProgramUniform1fEXT' , ADDRESSOF( ProgramUniform1fEXT ));
	GetProcAddress( 'glProgramUniform2fEXT' , ADDRESSOF( ProgramUniform2fEXT ));
	GetProcAddress( 'glProgramUniform3fEXT' , ADDRESSOF( ProgramUniform3fEXT ));
	GetProcAddress( 'glProgramUniform4fEXT' , ADDRESSOF( ProgramUniform4fEXT ));
	GetProcAddress( 'glProgramUniform1iEXT' , ADDRESSOF( ProgramUniform1iEXT ));
	GetProcAddress( 'glProgramUniform2iEXT' , ADDRESSOF( ProgramUniform2iEXT ));
	GetProcAddress( 'glProgramUniform3iEXT' , ADDRESSOF( ProgramUniform3iEXT ));
	GetProcAddress( 'glProgramUniform4iEXT' , ADDRESSOF( ProgramUniform4iEXT ));
	GetProcAddress( 'glProgramUniform1fvEXT' , ADDRESSOF( ProgramUniform1fvEXT ));
	GetProcAddress( 'glProgramUniform2fvEXT' , ADDRESSOF( ProgramUniform2fvEXT ));
	GetProcAddress( 'glProgramUniform3fvEXT' , ADDRESSOF( ProgramUniform3fvEXT ));
	GetProcAddress( 'glProgramUniform4fvEXT' , ADDRESSOF( ProgramUniform4fvEXT ));
	GetProcAddress( 'glProgramUniform1ivEXT' , ADDRESSOF( ProgramUniform1ivEXT ));
	GetProcAddress( 'glProgramUniform2ivEXT' , ADDRESSOF( ProgramUniform2ivEXT ));
	GetProcAddress( 'glProgramUniform3ivEXT' , ADDRESSOF( ProgramUniform3ivEXT ));
	GetProcAddress( 'glProgramUniform4ivEXT' , ADDRESSOF( ProgramUniform4ivEXT ));
	GetProcAddress( 'glProgramUniformMatrix2fvEXT' , ADDRESSOF( ProgramUniformMatrix2fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3fvEXT' , ADDRESSOF( ProgramUniformMatrix3fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4fvEXT' , ADDRESSOF( ProgramUniformMatrix4fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix2x3fvEXT' , ADDRESSOF( ProgramUniformMatrix2x3fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3x2fvEXT' , ADDRESSOF( ProgramUniformMatrix3x2fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix2x4fvEXT' , ADDRESSOF( ProgramUniformMatrix2x4fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4x2fvEXT' , ADDRESSOF( ProgramUniformMatrix4x2fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3x4fvEXT' , ADDRESSOF( ProgramUniformMatrix3x4fvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4x3fvEXT' , ADDRESSOF( ProgramUniformMatrix4x3fvEXT ));
	GetProcAddress( 'glProgramUniform1uiEXT' , ADDRESSOF( ProgramUniform1uiEXT ));
	GetProcAddress( 'glProgramUniform2uiEXT' , ADDRESSOF( ProgramUniform2uiEXT ));
	GetProcAddress( 'glProgramUniform3uiEXT' , ADDRESSOF( ProgramUniform3uiEXT ));
	GetProcAddress( 'glProgramUniform4uiEXT' , ADDRESSOF( ProgramUniform4uiEXT ));
	GetProcAddress( 'glProgramUniform1uivEXT' , ADDRESSOF( ProgramUniform1uivEXT ));
	GetProcAddress( 'glProgramUniform2uivEXT' , ADDRESSOF( ProgramUniform2uivEXT ));
	GetProcAddress( 'glProgramUniform3uivEXT' , ADDRESSOF( ProgramUniform3uivEXT ));
	GetProcAddress( 'glProgramUniform4uivEXT' , ADDRESSOF( ProgramUniform4uivEXT ));
	GetProcAddress( 'glNamedBufferDataEXT' , ADDRESSOF( NamedBufferDataEXT ));
	GetProcAddress( 'glNamedBufferSubDataEXT' , ADDRESSOF( NamedBufferSubDataEXT ));
	GetProcAddress( 'glMapNamedBufferEXT' , ADDRESSOF( MapNamedBufferEXT ));
	GetProcAddress( 'glUnmapNamedBufferEXT' , ADDRESSOF( UnmapNamedBufferEXT ));
	GetProcAddress( 'glMapNamedBufferRangeEXT' , ADDRESSOF( MapNamedBufferRangeEXT ));
	GetProcAddress( 'glFlushMappedNamedBufferRangeEXT' , ADDRESSOF( FlushMappedNamedBufferRangeEXT ));
	GetProcAddress( 'glNamedCopyBufferSubDataEXT' , ADDRESSOF( NamedCopyBufferSubDataEXT ));
	GetProcAddress( 'glGetNamedBufferParameterivEXT' , ADDRESSOF( GetNamedBufferParameterivEXT ));
	GetProcAddress( 'glGetNamedBufferPointervEXT' , ADDRESSOF( GetNamedBufferPointervEXT ));
	GetProcAddress( 'glGetNamedBufferSubDataEXT' , ADDRESSOF( GetNamedBufferSubDataEXT ));
	GetProcAddress( 'glTextureBufferEXT' , ADDRESSOF( TextureBufferEXT ));
	GetProcAddress( 'glMultiTexBufferEXT' , ADDRESSOF( MultiTexBufferEXT ));
	GetProcAddress( 'glNamedRenderbufferStorageEXT' , ADDRESSOF( NamedRenderbufferStorageEXT ));
	GetProcAddress( 'glGetNamedRenderbufferParameterivEXT' , ADDRESSOF( GetNamedRenderbufferParameterivEXT ));
	GetProcAddress( 'glCheckNamedFramebufferStatusEXT' , ADDRESSOF( CheckNamedFramebufferStatusEXT ));
	GetProcAddress( 'glNamedFramebufferTexture1DEXT' , ADDRESSOF( NamedFramebufferTexture1DEXT ));
	GetProcAddress( 'glNamedFramebufferTexture2DEXT' , ADDRESSOF( NamedFramebufferTexture2DEXT ));
	GetProcAddress( 'glNamedFramebufferTexture3DEXT' , ADDRESSOF( NamedFramebufferTexture3DEXT ));
	GetProcAddress( 'glNamedFramebufferRenderbufferEXT' , ADDRESSOF( NamedFramebufferRenderbufferEXT ));
	GetProcAddress( 'glGetNamedFramebufferAttachmentParameterivEXT' , ADDRESSOF( GetNamedFramebufferAttachmentParameterivEXT ));
	GetProcAddress( 'glGenerateTextureMipmapEXT' , ADDRESSOF( GenerateTextureMipmapEXT ));
	GetProcAddress( 'glGenerateMultiTexMipmapEXT' , ADDRESSOF( GenerateMultiTexMipmapEXT ));
	GetProcAddress( 'glFramebufferDrawBufferEXT' , ADDRESSOF( FramebufferDrawBufferEXT ));
	GetProcAddress( 'glFramebufferDrawBuffersEXT' , ADDRESSOF( FramebufferDrawBuffersEXT ));
	GetProcAddress( 'glFramebufferReadBufferEXT' , ADDRESSOF( FramebufferReadBufferEXT ));
	GetProcAddress( 'glGetFramebufferParameterivEXT' , ADDRESSOF( GetFramebufferParameterivEXT ));
	GetProcAddress( 'glNamedRenderbufferStorageMultisampleEXT' , ADDRESSOF( NamedRenderbufferStorageMultisampleEXT ));
	GetProcAddress( 'glNamedRenderbufferStorageMultisampleCoverageEXT' , ADDRESSOF( NamedRenderbufferStorageMultisampleCoverageEXT ));
	GetProcAddress( 'glNamedFramebufferTextureEXT' , ADDRESSOF( NamedFramebufferTextureEXT ));
	GetProcAddress( 'glNamedFramebufferTextureLayerEXT' , ADDRESSOF( NamedFramebufferTextureLayerEXT ));
	GetProcAddress( 'glNamedFramebufferTextureFaceEXT' , ADDRESSOF( NamedFramebufferTextureFaceEXT ));
	GetProcAddress( 'glTextureRenderbufferEXT' , ADDRESSOF( TextureRenderbufferEXT ));
	GetProcAddress( 'glMultiTexRenderbufferEXT' , ADDRESSOF( MultiTexRenderbufferEXT ));
	GetProcAddress( 'glProgramUniform1dEXT' , ADDRESSOF( ProgramUniform1dEXT ));
	GetProcAddress( 'glProgramUniform2dEXT' , ADDRESSOF( ProgramUniform2dEXT ));
	GetProcAddress( 'glProgramUniform3dEXT' , ADDRESSOF( ProgramUniform3dEXT ));
	GetProcAddress( 'glProgramUniform4dEXT' , ADDRESSOF( ProgramUniform4dEXT ));
	GetProcAddress( 'glProgramUniform1dvEXT' , ADDRESSOF( ProgramUniform1dvEXT ));
	GetProcAddress( 'glProgramUniform2dvEXT' , ADDRESSOF( ProgramUniform2dvEXT ));
	GetProcAddress( 'glProgramUniform3dvEXT' , ADDRESSOF( ProgramUniform3dvEXT ));
	GetProcAddress( 'glProgramUniform4dvEXT' , ADDRESSOF( ProgramUniform4dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix2dvEXT' , ADDRESSOF( ProgramUniformMatrix2dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3dvEXT' , ADDRESSOF( ProgramUniformMatrix3dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4dvEXT' , ADDRESSOF( ProgramUniformMatrix4dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix2x3dvEXT' , ADDRESSOF( ProgramUniformMatrix2x3dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix2x4dvEXT' , ADDRESSOF( ProgramUniformMatrix2x4dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3x2dvEXT' , ADDRESSOF( ProgramUniformMatrix3x2dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix3x4dvEXT' , ADDRESSOF( ProgramUniformMatrix3x4dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4x2dvEXT' , ADDRESSOF( ProgramUniformMatrix4x2dvEXT ));
	GetProcAddress( 'glProgramUniformMatrix4x3dvEXT' , ADDRESSOF( ProgramUniformMatrix4x3dvEXT ));
END Read_GL_EXT_direct_state_access;

PROCEDURE Read_GL_EXT_separate_shader_objects*;
BEGIN
	GetProcAddress( 'glUseShaderProgramEXT' , ADDRESSOF( UseShaderProgramEXT ));
	GetProcAddress( 'glActiveProgramEXT' , ADDRESSOF( ActiveProgramEXT ));
	GetProcAddress( 'glCreateShaderProgramEXT' , ADDRESSOF( CreateShaderProgramEXT ));
END Read_GL_EXT_separate_shader_objects;

PROCEDURE Read_GL_EXT_shader_image_load_store*;
BEGIN
	GetProcAddress( 'glBindImageTextureEXT' , ADDRESSOF( BindImageTextureEXT ));
	GetProcAddress( 'glMemoryBarrierEXT' , ADDRESSOF( MemoryBarrierEXT ));
END Read_GL_EXT_shader_image_load_store;

PROCEDURE Read_GL_EXT_vertex_attrib_64bit*;
BEGIN
	GetProcAddress( 'glVertexAttribL1dEXT' , ADDRESSOF( VertexAttribL1dEXT ));
	GetProcAddress( 'glVertexAttribL2dEXT' , ADDRESSOF( VertexAttribL2dEXT ));
	GetProcAddress( 'glVertexAttribL3dEXT' , ADDRESSOF( VertexAttribL3dEXT ));
	GetProcAddress( 'glVertexAttribL4dEXT' , ADDRESSOF( VertexAttribL4dEXT ));
	GetProcAddress( 'glVertexAttribL1dvEXT' , ADDRESSOF( VertexAttribL1dvEXT ));
	GetProcAddress( 'glVertexAttribL2dvEXT' , ADDRESSOF( VertexAttribL2dvEXT ));
	GetProcAddress( 'glVertexAttribL3dvEXT' , ADDRESSOF( VertexAttribL3dvEXT ));
	GetProcAddress( 'glVertexAttribL4dvEXT' , ADDRESSOF( VertexAttribL4dvEXT ));
	GetProcAddress( 'glVertexAttribLPointerEXT' , ADDRESSOF( VertexAttribLPointerEXT ));
	GetProcAddress( 'glGetVertexAttribLdvEXT' , ADDRESSOF( GetVertexAttribLdvEXT ));
	GetProcAddress( 'glVertexArrayVertexAttribLOffsetEXT' , ADDRESSOF( VertexArrayVertexAttribLOffsetEXT ));
END Read_GL_EXT_vertex_attrib_64bit;

PROCEDURE Read_GL_HP_image_transform*;
BEGIN
	GetProcAddress( 'glImageTransformParameteriHP' , ADDRESSOF( ImageTransformParameteriHP ));
	GetProcAddress( 'glImageTransformParameterfHP' , ADDRESSOF( ImageTransformParameterfHP ));
	GetProcAddress( 'glImageTransformParameterivHP' , ADDRESSOF( ImageTransformParameterivHP ));
	GetProcAddress( 'glImageTransformParameterfvHP' , ADDRESSOF( ImageTransformParameterfvHP ));
	GetProcAddress( 'glGetImageTransformParameterivHP' , ADDRESSOF( GetImageTransformParameterivHP ));
	GetProcAddress( 'glGetImageTransformParameterfvHP' , ADDRESSOF( GetImageTransformParameterfvHP ));
END Read_GL_HP_image_transform;

PROCEDURE Read_GL_IBM_multimode_draw_arrays*;
BEGIN
	GetProcAddress( 'glMultiModeDrawArraysIBM' , ADDRESSOF( MultiModeDrawArraysIBM ));
	GetProcAddress( 'glMultiModeDrawElementsIBM' , ADDRESSOF( MultiModeDrawElementsIBM ));
END Read_GL_IBM_multimode_draw_arrays;

PROCEDURE Read_GL_IBM_vertex_array_lists*;
BEGIN
	GetProcAddress( 'glColorPointerListIBM' , ADDRESSOF( ColorPointerListIBM ));
	GetProcAddress( 'glSecondaryColorPointerListIBM' , ADDRESSOF( SecondaryColorPointerListIBM ));
	GetProcAddress( 'glEdgeFlagPointerListIBM' , ADDRESSOF( EdgeFlagPointerListIBM ));
	GetProcAddress( 'glFogCoordPointerListIBM' , ADDRESSOF( FogCoordPointerListIBM ));
	GetProcAddress( 'glIndexPointerListIBM' , ADDRESSOF( IndexPointerListIBM ));
	GetProcAddress( 'glNormalPointerListIBM' , ADDRESSOF( NormalPointerListIBM ));
	GetProcAddress( 'glTexCoordPointerListIBM' , ADDRESSOF( TexCoordPointerListIBM ));
	GetProcAddress( 'glVertexPointerListIBM' , ADDRESSOF( VertexPointerListIBM ));
END Read_GL_IBM_vertex_array_lists;

PROCEDURE Read_GL_INGR_blend_func_separate*;
BEGIN
	GetProcAddress( 'glBlendFuncSeparateINGR' , ADDRESSOF( BlendFuncSeparateINGR ));
END Read_GL_INGR_blend_func_separate;

PROCEDURE Read_GL_INTEL_parallel_arrays*;
BEGIN
	GetProcAddress( 'glVertexPointervINTEL' , ADDRESSOF( VertexPointervINTEL ));
	GetProcAddress( 'glNormalPointervINTEL' , ADDRESSOF( NormalPointervINTEL ));
	GetProcAddress( 'glColorPointervINTEL' , ADDRESSOF( ColorPointervINTEL ));
	GetProcAddress( 'glTexCoordPointervINTEL' , ADDRESSOF( TexCoordPointervINTEL ));
END Read_GL_INTEL_parallel_arrays;

PROCEDURE Read_GL_INTEL_framebuffer_CMAA*;
BEGIN
	GetProcAddress( 'glApplyFramebufferAttachmentCMAAINTEL' , ADDRESSOF( ApplyFramebufferAttachmentCMAAINTEL ));
END Read_GL_INTEL_framebuffer_CMAA;

PROCEDURE Read_GL_MESA_resize_buffers*;
BEGIN
	GetProcAddress( 'glResizeBuffersMESA' , ADDRESSOF( ResizeBuffersMESA ));
END Read_GL_MESA_resize_buffers;

PROCEDURE Read_GL_MESA_window_pos*;
BEGIN
	GetProcAddress( 'glWindowPos2dMESA' , ADDRESSOF( WindowPos2dMESA ));
	GetProcAddress( 'glWindowPos2dvMESA' , ADDRESSOF( WindowPos2dvMESA ));
	GetProcAddress( 'glWindowPos2fMESA' , ADDRESSOF( WindowPos2fMESA ));
	GetProcAddress( 'glWindowPos2fvMESA' , ADDRESSOF( WindowPos2fvMESA ));
	GetProcAddress( 'glWindowPos2iMESA' , ADDRESSOF( WindowPos2iMESA ));
	GetProcAddress( 'glWindowPos2ivMESA' , ADDRESSOF( WindowPos2ivMESA ));
	GetProcAddress( 'glWindowPos2sMESA' , ADDRESSOF( WindowPos2sMESA ));
	GetProcAddress( 'glWindowPos2svMESA' , ADDRESSOF( WindowPos2svMESA ));
	GetProcAddress( 'glWindowPos3dMESA' , ADDRESSOF( WindowPos3dMESA ));
	GetProcAddress( 'glWindowPos3dvMESA' , ADDRESSOF( WindowPos3dvMESA ));
	GetProcAddress( 'glWindowPos3fMESA' , ADDRESSOF( WindowPos3fMESA ));
	GetProcAddress( 'glWindowPos3fvMESA' , ADDRESSOF( WindowPos3fvMESA ));
	GetProcAddress( 'glWindowPos3iMESA' , ADDRESSOF( WindowPos3iMESA ));
	GetProcAddress( 'glWindowPos3ivMESA' , ADDRESSOF( WindowPos3ivMESA ));
	GetProcAddress( 'glWindowPos3sMESA' , ADDRESSOF( WindowPos3sMESA ));
	GetProcAddress( 'glWindowPos3svMESA' , ADDRESSOF( WindowPos3svMESA ));
	GetProcAddress( 'glWindowPos4dMESA' , ADDRESSOF( WindowPos4dMESA ));
	GetProcAddress( 'glWindowPos4dvMESA' , ADDRESSOF( WindowPos4dvMESA ));
	GetProcAddress( 'glWindowPos4fMESA' , ADDRESSOF( WindowPos4fMESA ));
	GetProcAddress( 'glWindowPos4fvMESA' , ADDRESSOF( WindowPos4fvMESA ));
	GetProcAddress( 'glWindowPos4iMESA' , ADDRESSOF( WindowPos4iMESA ));
	GetProcAddress( 'glWindowPos4ivMESA' , ADDRESSOF( WindowPos4ivMESA ));
	GetProcAddress( 'glWindowPos4sMESA' , ADDRESSOF( WindowPos4sMESA ));
	GetProcAddress( 'glWindowPos4svMESA' , ADDRESSOF( WindowPos4svMESA ));
END Read_GL_MESA_window_pos;

PROCEDURE Read_GL_NV_evaluators*;
BEGIN
	GetProcAddress( 'glMapControlPointsNV' , ADDRESSOF( MapControlPointsNV ));
	GetProcAddress( 'glMapParameterivNV' , ADDRESSOF( MapParameterivNV ));
	GetProcAddress( 'glMapParameterfvNV' , ADDRESSOF( MapParameterfvNV ));
	GetProcAddress( 'glGetMapControlPointsNV' , ADDRESSOF( GetMapControlPointsNV ));
	GetProcAddress( 'glGetMapParameterivNV' , ADDRESSOF( GetMapParameterivNV ));
	GetProcAddress( 'glGetMapParameterfvNV' , ADDRESSOF( GetMapParameterfvNV ));
	GetProcAddress( 'glGetMapAttribParameterivNV' , ADDRESSOF( GetMapAttribParameterivNV ));
	GetProcAddress( 'glGetMapAttribParameterfvNV' , ADDRESSOF( GetMapAttribParameterfvNV ));
	GetProcAddress( 'glEvalMapsNV' , ADDRESSOF( EvalMapsNV ));
END Read_GL_NV_evaluators;

PROCEDURE Read_GL_NV_fence*;
BEGIN
	GetProcAddress( 'glDeleteFencesNV' , ADDRESSOF( DeleteFencesNV ));
	GetProcAddress( 'glGenFencesNV' , ADDRESSOF( GenFencesNV ));
	GetProcAddress( 'glIsFenceNV' , ADDRESSOF( IsFenceNV ));
	GetProcAddress( 'glTestFenceNV' , ADDRESSOF( TestFenceNV ));
	GetProcAddress( 'glGetFenceivNV' , ADDRESSOF( GetFenceivNV ));
	GetProcAddress( 'glFinishFenceNV' , ADDRESSOF( FinishFenceNV ));
	GetProcAddress( 'glSetFenceNV' , ADDRESSOF( SetFenceNV ));
END Read_GL_NV_fence;

PROCEDURE Read_GL_NV_fragment_program*;
BEGIN
	GetProcAddress( 'glProgramNamedParameter4fNV' , ADDRESSOF( ProgramNamedParameter4fNV ));
	GetProcAddress( 'glProgramNamedParameter4dNV' , ADDRESSOF( ProgramNamedParameter4dNV ));
	GetProcAddress( 'glProgramNamedParameter4fvNV' , ADDRESSOF( ProgramNamedParameter4fvNV ));
	GetProcAddress( 'glProgramNamedParameter4dvNV' , ADDRESSOF( ProgramNamedParameter4dvNV ));
	GetProcAddress( 'glGetProgramNamedParameterfvNV' , ADDRESSOF( GetProgramNamedParameterfvNV ));
	GetProcAddress( 'glGetProgramNamedParameterdvNV' , ADDRESSOF( GetProgramNamedParameterdvNV ));
END Read_GL_NV_fragment_program;

PROCEDURE Read_GL_NV_half_float*;
BEGIN
	GetProcAddress( 'glVertex2hNV' , ADDRESSOF( Vertex2hNV ));
	GetProcAddress( 'glVertex2hvNV' , ADDRESSOF( Vertex2hvNV ));
	GetProcAddress( 'glVertex3hNV' , ADDRESSOF( Vertex3hNV ));
	GetProcAddress( 'glVertex3hvNV' , ADDRESSOF( Vertex3hvNV ));
	GetProcAddress( 'glVertex4hNV' , ADDRESSOF( Vertex4hNV ));
	GetProcAddress( 'glVertex4hvNV' , ADDRESSOF( Vertex4hvNV ));
	GetProcAddress( 'glNormal3hNV' , ADDRESSOF( Normal3hNV ));
	GetProcAddress( 'glNormal3hvNV' , ADDRESSOF( Normal3hvNV ));
	GetProcAddress( 'glColor3hNV' , ADDRESSOF( Color3hNV ));
	GetProcAddress( 'glColor3hvNV' , ADDRESSOF( Color3hvNV ));
	GetProcAddress( 'glColor4hNV' , ADDRESSOF( Color4hNV ));
	GetProcAddress( 'glColor4hvNV' , ADDRESSOF( Color4hvNV ));
	GetProcAddress( 'glTexCoord1hNV' , ADDRESSOF( TexCoord1hNV ));
	GetProcAddress( 'glTexCoord1hvNV' , ADDRESSOF( TexCoord1hvNV ));
	GetProcAddress( 'glTexCoord2hNV' , ADDRESSOF( TexCoord2hNV ));
	GetProcAddress( 'glTexCoord2hvNV' , ADDRESSOF( TexCoord2hvNV ));
	GetProcAddress( 'glTexCoord3hNV' , ADDRESSOF( TexCoord3hNV ));
	GetProcAddress( 'glTexCoord3hvNV' , ADDRESSOF( TexCoord3hvNV ));
	GetProcAddress( 'glTexCoord4hNV' , ADDRESSOF( TexCoord4hNV ));
	GetProcAddress( 'glTexCoord4hvNV' , ADDRESSOF( TexCoord4hvNV ));
	GetProcAddress( 'glMultiTexCoord1hNV' , ADDRESSOF( MultiTexCoord1hNV ));
	GetProcAddress( 'glMultiTexCoord1hvNV' , ADDRESSOF( MultiTexCoord1hvNV ));
	GetProcAddress( 'glMultiTexCoord2hNV' , ADDRESSOF( MultiTexCoord2hNV ));
	GetProcAddress( 'glMultiTexCoord2hvNV' , ADDRESSOF( MultiTexCoord2hvNV ));
	GetProcAddress( 'glMultiTexCoord3hNV' , ADDRESSOF( MultiTexCoord3hNV ));
	GetProcAddress( 'glMultiTexCoord3hvNV' , ADDRESSOF( MultiTexCoord3hvNV ));
	GetProcAddress( 'glMultiTexCoord4hNV' , ADDRESSOF( MultiTexCoord4hNV ));
	GetProcAddress( 'glMultiTexCoord4hvNV' , ADDRESSOF( MultiTexCoord4hvNV ));
	GetProcAddress( 'glFogCoordhNV' , ADDRESSOF( FogCoordhNV ));
	GetProcAddress( 'glFogCoordhvNV' , ADDRESSOF( FogCoordhvNV ));
	GetProcAddress( 'glSecondaryColor3hNV' , ADDRESSOF( SecondaryColor3hNV ));
	GetProcAddress( 'glSecondaryColor3hvNV' , ADDRESSOF( SecondaryColor3hvNV ));
	GetProcAddress( 'glVertexWeighthNV' , ADDRESSOF( VertexWeighthNV ));
	GetProcAddress( 'glVertexWeighthvNV' , ADDRESSOF( VertexWeighthvNV ));
	GetProcAddress( 'glVertexAttrib1hNV' , ADDRESSOF( VertexAttrib1hNV ));
	GetProcAddress( 'glVertexAttrib1hvNV' , ADDRESSOF( VertexAttrib1hvNV ));
	GetProcAddress( 'glVertexAttrib2hNV' , ADDRESSOF( VertexAttrib2hNV ));
	GetProcAddress( 'glVertexAttrib2hvNV' , ADDRESSOF( VertexAttrib2hvNV ));
	GetProcAddress( 'glVertexAttrib3hNV' , ADDRESSOF( VertexAttrib3hNV ));
	GetProcAddress( 'glVertexAttrib3hvNV' , ADDRESSOF( VertexAttrib3hvNV ));
	GetProcAddress( 'glVertexAttrib4hNV' , ADDRESSOF( VertexAttrib4hNV ));
	GetProcAddress( 'glVertexAttrib4hvNV' , ADDRESSOF( VertexAttrib4hvNV ));
	GetProcAddress( 'glVertexAttribs1hvNV' , ADDRESSOF( VertexAttribs1hvNV ));
	GetProcAddress( 'glVertexAttribs2hvNV' , ADDRESSOF( VertexAttribs2hvNV ));
	GetProcAddress( 'glVertexAttribs3hvNV' , ADDRESSOF( VertexAttribs3hvNV ));
	GetProcAddress( 'glVertexAttribs4hvNV' , ADDRESSOF( VertexAttribs4hvNV ));
END Read_GL_NV_half_float;

PROCEDURE Read_GL_NV_occlusion_query*;
BEGIN
	GetProcAddress( 'glGenOcclusionQueriesNV' , ADDRESSOF( GenOcclusionQueriesNV ));
	GetProcAddress( 'glDeleteOcclusionQueriesNV' , ADDRESSOF( DeleteOcclusionQueriesNV ));
	GetProcAddress( 'glIsOcclusionQueryNV' , ADDRESSOF( IsOcclusionQueryNV ));
	GetProcAddress( 'glBeginOcclusionQueryNV' , ADDRESSOF( BeginOcclusionQueryNV ));
	GetProcAddress( 'glEndOcclusionQueryNV' , ADDRESSOF( EndOcclusionQueryNV ));
	GetProcAddress( 'glGetOcclusionQueryivNV' , ADDRESSOF( GetOcclusionQueryivNV ));
	GetProcAddress( 'glGetOcclusionQueryuivNV' , ADDRESSOF( GetOcclusionQueryuivNV ));
END Read_GL_NV_occlusion_query;

PROCEDURE Read_GL_NV_pixel_data_range*;
BEGIN
	GetProcAddress( 'glPixelDataRangeNV' , ADDRESSOF( PixelDataRangeNV ));
	GetProcAddress( 'glFlushPixelDataRangeNV' , ADDRESSOF( FlushPixelDataRangeNV ));
END Read_GL_NV_pixel_data_range;

PROCEDURE Read_GL_NV_point_sprite*;
BEGIN
	GetProcAddress( 'glPointParameteriNV' , ADDRESSOF( PointParameteriNV ));
	GetProcAddress( 'glPointParameterivNV' , ADDRESSOF( PointParameterivNV ));
END Read_GL_NV_point_sprite;

PROCEDURE Read_GL_NV_primitive_restart*;
BEGIN
	GetProcAddress( 'glPrimitiveRestartNV' , ADDRESSOF( PrimitiveRestartNV ));
	GetProcAddress( 'glPrimitiveRestartIndexNV' , ADDRESSOF( PrimitiveRestartIndexNV ));
END Read_GL_NV_primitive_restart;

PROCEDURE Read_GL_NV_register_combiners*;
BEGIN
	GetProcAddress( 'glCombinerParameterfvNV' , ADDRESSOF( CombinerParameterfvNV ));
	GetProcAddress( 'glCombinerParameterfNV' , ADDRESSOF( CombinerParameterfNV ));
	GetProcAddress( 'glCombinerParameterivNV' , ADDRESSOF( CombinerParameterivNV ));
	GetProcAddress( 'glCombinerParameteriNV' , ADDRESSOF( CombinerParameteriNV ));
	GetProcAddress( 'glCombinerInputNV' , ADDRESSOF( CombinerInputNV ));
	GetProcAddress( 'glCombinerOutputNV' , ADDRESSOF( CombinerOutputNV ));
	GetProcAddress( 'glFinalCombinerInputNV' , ADDRESSOF( FinalCombinerInputNV ));
	GetProcAddress( 'glGetCombinerInputParameterfvNV' , ADDRESSOF( GetCombinerInputParameterfvNV ));
	GetProcAddress( 'glGetCombinerInputParameterivNV' , ADDRESSOF( GetCombinerInputParameterivNV ));
	GetProcAddress( 'glGetCombinerOutputParameterfvNV' , ADDRESSOF( GetCombinerOutputParameterfvNV ));
	GetProcAddress( 'glGetCombinerOutputParameterivNV' , ADDRESSOF( GetCombinerOutputParameterivNV ));
	GetProcAddress( 'glGetFinalCombinerInputParameterfvNV' , ADDRESSOF( GetFinalCombinerInputParameterfvNV ));
	GetProcAddress( 'glGetFinalCombinerInputParameterivNV' , ADDRESSOF( GetFinalCombinerInputParameterivNV ));
END Read_GL_NV_register_combiners;

PROCEDURE Read_GL_NV_register_combiners2*;
BEGIN
	GetProcAddress( 'glCombinerStageParameterfvNV' , ADDRESSOF( CombinerStageParameterfvNV ));
	GetProcAddress( 'glGetCombinerStageParameterfvNV' , ADDRESSOF( GetCombinerStageParameterfvNV ));
END Read_GL_NV_register_combiners2;

PROCEDURE Read_GL_NV_vertex_array_range*;
BEGIN
	GetProcAddress( 'glFlushVertexArrayRangeNV' , ADDRESSOF( FlushVertexArrayRangeNV ));
	GetProcAddress( 'glVertexArrayRangeNV' , ADDRESSOF( VertexArrayRangeNV ));
END Read_GL_NV_vertex_array_range;

PROCEDURE Read_GL_NV_vertex_program*;
BEGIN
	GetProcAddress( 'glAreProgramsResidentNV' , ADDRESSOF( AreProgramsResidentNV ));
	GetProcAddress( 'glBindProgramNV' , ADDRESSOF( BindProgramNV ));
	GetProcAddress( 'glDeleteProgramsNV' , ADDRESSOF( DeleteProgramsNV ));
	GetProcAddress( 'glExecuteProgramNV' , ADDRESSOF( ExecuteProgramNV ));
	GetProcAddress( 'glGenProgramsNV' , ADDRESSOF( GenProgramsNV ));
	GetProcAddress( 'glGetProgramParameterdvNV' , ADDRESSOF( GetProgramParameterdvNV ));
	GetProcAddress( 'glGetProgramParameterfvNV' , ADDRESSOF( GetProgramParameterfvNV ));
	GetProcAddress( 'glGetProgramivNV' , ADDRESSOF( GetProgramivNV ));
	GetProcAddress( 'glGetProgramStringNV' , ADDRESSOF( GetProgramStringNV ));
	GetProcAddress( 'glGetTrackMatrixivNV' , ADDRESSOF( GetTrackMatrixivNV ));
	GetProcAddress( 'glGetVertexAttribdvNV' , ADDRESSOF( GetVertexAttribdvNV ));
	GetProcAddress( 'glGetVertexAttribfvNV' , ADDRESSOF( GetVertexAttribfvNV ));
	GetProcAddress( 'glGetVertexAttribivNV' , ADDRESSOF( GetVertexAttribivNV ));
	GetProcAddress( 'glGetVertexAttribPointervNV' , ADDRESSOF( GetVertexAttribPointervNV ));
	GetProcAddress( 'glIsProgramNV' , ADDRESSOF( IsProgramNV ));
	GetProcAddress( 'glLoadProgramNV' , ADDRESSOF( LoadProgramNV ));
	GetProcAddress( 'glProgramParameter4dNV' , ADDRESSOF( ProgramParameter4dNV ));
	GetProcAddress( 'glProgramParameter4dvNV' , ADDRESSOF( ProgramParameter4dvNV ));
	GetProcAddress( 'glProgramParameter4fNV' , ADDRESSOF( ProgramParameter4fNV ));
	GetProcAddress( 'glProgramParameter4fvNV' , ADDRESSOF( ProgramParameter4fvNV ));
	GetProcAddress( 'glProgramParameters4dvNV' , ADDRESSOF( ProgramParameters4dvNV ));
	GetProcAddress( 'glProgramParameters4fvNV' , ADDRESSOF( ProgramParameters4fvNV ));
	GetProcAddress( 'glRequestResidentProgramsNV' , ADDRESSOF( RequestResidentProgramsNV ));
	GetProcAddress( 'glTrackMatrixNV' , ADDRESSOF( TrackMatrixNV ));
	GetProcAddress( 'glVertexAttribPointerNV' , ADDRESSOF( VertexAttribPointerNV ));
	GetProcAddress( 'glVertexAttrib1dNV' , ADDRESSOF( VertexAttrib1dNV ));
	GetProcAddress( 'glVertexAttrib1dvNV' , ADDRESSOF( VertexAttrib1dvNV ));
	GetProcAddress( 'glVertexAttrib1fNV' , ADDRESSOF( VertexAttrib1fNV ));
	GetProcAddress( 'glVertexAttrib1fvNV' , ADDRESSOF( VertexAttrib1fvNV ));
	GetProcAddress( 'glVertexAttrib1sNV' , ADDRESSOF( VertexAttrib1sNV ));
	GetProcAddress( 'glVertexAttrib1svNV' , ADDRESSOF( VertexAttrib1svNV ));
	GetProcAddress( 'glVertexAttrib2dNV' , ADDRESSOF( VertexAttrib2dNV ));
	GetProcAddress( 'glVertexAttrib2dvNV' , ADDRESSOF( VertexAttrib2dvNV ));
	GetProcAddress( 'glVertexAttrib2fNV' , ADDRESSOF( VertexAttrib2fNV ));
	GetProcAddress( 'glVertexAttrib2fvNV' , ADDRESSOF( VertexAttrib2fvNV ));
	GetProcAddress( 'glVertexAttrib2sNV' , ADDRESSOF( VertexAttrib2sNV ));
	GetProcAddress( 'glVertexAttrib2svNV' , ADDRESSOF( VertexAttrib2svNV ));
	GetProcAddress( 'glVertexAttrib3dNV' , ADDRESSOF( VertexAttrib3dNV ));
	GetProcAddress( 'glVertexAttrib3dvNV' , ADDRESSOF( VertexAttrib3dvNV ));
	GetProcAddress( 'glVertexAttrib3fNV' , ADDRESSOF( VertexAttrib3fNV ));
	GetProcAddress( 'glVertexAttrib3fvNV' , ADDRESSOF( VertexAttrib3fvNV ));
	GetProcAddress( 'glVertexAttrib3sNV' , ADDRESSOF( VertexAttrib3sNV ));
	GetProcAddress( 'glVertexAttrib3svNV' , ADDRESSOF( VertexAttrib3svNV ));
	GetProcAddress( 'glVertexAttrib4dNV' , ADDRESSOF( VertexAttrib4dNV ));
	GetProcAddress( 'glVertexAttrib4dvNV' , ADDRESSOF( VertexAttrib4dvNV ));
	GetProcAddress( 'glVertexAttrib4fNV' , ADDRESSOF( VertexAttrib4fNV ));
	GetProcAddress( 'glVertexAttrib4fvNV' , ADDRESSOF( VertexAttrib4fvNV ));
	GetProcAddress( 'glVertexAttrib4sNV' , ADDRESSOF( VertexAttrib4sNV ));
	GetProcAddress( 'glVertexAttrib4svNV' , ADDRESSOF( VertexAttrib4svNV ));
	GetProcAddress( 'glVertexAttrib4ubNV' , ADDRESSOF( VertexAttrib4ubNV ));
	GetProcAddress( 'glVertexAttrib4ubvNV' , ADDRESSOF( VertexAttrib4ubvNV ));
	GetProcAddress( 'glVertexAttribs1dvNV' , ADDRESSOF( VertexAttribs1dvNV ));
	GetProcAddress( 'glVertexAttribs1fvNV' , ADDRESSOF( VertexAttribs1fvNV ));
	GetProcAddress( 'glVertexAttribs1svNV' , ADDRESSOF( VertexAttribs1svNV ));
	GetProcAddress( 'glVertexAttribs2dvNV' , ADDRESSOF( VertexAttribs2dvNV ));
	GetProcAddress( 'glVertexAttribs2fvNV' , ADDRESSOF( VertexAttribs2fvNV ));
	GetProcAddress( 'glVertexAttribs2svNV' , ADDRESSOF( VertexAttribs2svNV ));
	GetProcAddress( 'glVertexAttribs3dvNV' , ADDRESSOF( VertexAttribs3dvNV ));
	GetProcAddress( 'glVertexAttribs3fvNV' , ADDRESSOF( VertexAttribs3fvNV ));
	GetProcAddress( 'glVertexAttribs3svNV' , ADDRESSOF( VertexAttribs3svNV ));
	GetProcAddress( 'glVertexAttribs4dvNV' , ADDRESSOF( VertexAttribs4dvNV ));
	GetProcAddress( 'glVertexAttribs4fvNV' , ADDRESSOF( VertexAttribs4fvNV ));
	GetProcAddress( 'glVertexAttribs4svNV' , ADDRESSOF( VertexAttribs4svNV ));
	GetProcAddress( 'glVertexAttribs4ubvNV' , ADDRESSOF( VertexAttribs4ubvNV ));
END Read_GL_NV_vertex_program;

PROCEDURE Read_GL_NV_depth_buffer_float*;
BEGIN
	GetProcAddress( 'glDepthRangedNV' , ADDRESSOF( DepthRangedNV ));
	GetProcAddress( 'glClearDepthdNV' , ADDRESSOF( ClearDepthdNV ));
	GetProcAddress( 'glDepthBoundsdNV' , ADDRESSOF( DepthBoundsdNV ));
END Read_GL_NV_depth_buffer_float;

PROCEDURE Read_GL_NV_framebuffer_multisample_coverage*;
BEGIN
	GetProcAddress( 'glRenderbufferStorageMultsampleCoverageNV' , ADDRESSOF( RenderbufferStorageMultsampleCoverageNV ));
END Read_GL_NV_framebuffer_multisample_coverage;

PROCEDURE Read_GL_NV_geometry_program4*;
BEGIN
	GetProcAddress( 'glProgramVertexLimitNV' , ADDRESSOF( ProgramVertexLimitNV ));
END Read_GL_NV_geometry_program4;

PROCEDURE Read_GL_NV_gpu_program4*;
BEGIN
	GetProcAddress( 'glProgramLocalParameterI4iNV' , ADDRESSOF( ProgramLocalParameterI4iNV ));
	GetProcAddress( 'glProgramLocalParameterI4ivNV' , ADDRESSOF( ProgramLocalParameterI4ivNV ));
	GetProcAddress( 'glProgramLocalParametersI4ivNV' , ADDRESSOF( ProgramLocalParametersI4ivNV ));
	GetProcAddress( 'glProgramLocalParameterI4uiNV' , ADDRESSOF( ProgramLocalParameterI4uiNV ));
	GetProcAddress( 'glProgramLocalParameterI4uivNV' , ADDRESSOF( ProgramLocalParameterI4uivNV ));
	GetProcAddress( 'glProgramLocalParametersI4uivNV' , ADDRESSOF( ProgramLocalParametersI4uivNV ));
	GetProcAddress( 'glProgramEnvParameterI4iNV' , ADDRESSOF( ProgramEnvParameterI4iNV ));
	GetProcAddress( 'glProgramEnvParameterI4ivNV' , ADDRESSOF( ProgramEnvParameterI4ivNV ));
	GetProcAddress( 'glProgramEnvParametersI4ivNV' , ADDRESSOF( ProgramEnvParametersI4ivNV ));
	GetProcAddress( 'glProgramEnvParameterI4uiNV' , ADDRESSOF( ProgramEnvParameterI4uiNV ));
	GetProcAddress( 'glProgramEnvParameterI4uivNV' , ADDRESSOF( ProgramEnvParameterI4uivNV ));
	GetProcAddress( 'glProgramEnvParametersI4uivNV' , ADDRESSOF( ProgramEnvParametersI4uivNV ));
	GetProcAddress( 'glGetProgramLocalParameterIivNV' , ADDRESSOF( GetProgramLocalParameterIivNV ));
	GetProcAddress( 'glGetProgramLocalParameterIuivNV' , ADDRESSOF( GetProgramLocalParameterIuivNV ));
	GetProcAddress( 'glGetProgramEnvParameterIivNV' , ADDRESSOF( GetProgramEnvParameterIivNV ));
	GetProcAddress( 'glGetProgramEnvParameterIuivNV' , ADDRESSOF( GetProgramEnvParameterIuivNV ));
END Read_GL_NV_gpu_program4;

PROCEDURE Read_GL_NV_parameter_buffer_object*;
BEGIN
	GetProcAddress( 'glProgramBufferParametersfvNV' , ADDRESSOF( ProgramBufferParametersfvNV ));
	GetProcAddress( 'glProgramBufferParametersIivNV' , ADDRESSOF( ProgramBufferParametersIivNV ));
	GetProcAddress( 'glProgramBufferParametersIuivNV' , ADDRESSOF( ProgramBufferParametersIuivNV ));
END Read_GL_NV_parameter_buffer_object;

PROCEDURE Read_GL_NV_transform_feedback*;
BEGIN
	GetProcAddress( 'glBeginTransformFeedbackNV' , ADDRESSOF( BeginTransformFeedbackNV ));
	GetProcAddress( 'glEndTransformFeedbackNV' , ADDRESSOF( EndTransformFeedbackNV ));
	GetProcAddress( 'glTransformFeedbackAttribsNV' , ADDRESSOF( TransformFeedbackAttribsNV ));
	GetProcAddress( 'glBindBufferRangeNV' , ADDRESSOF( BindBufferRangeNV ));
	GetProcAddress( 'glBindBufferOffsetNV' , ADDRESSOF( BindBufferOffsetNV ));
	GetProcAddress( 'glBindBufferBaseNV' , ADDRESSOF( BindBufferBaseNV ));
	GetProcAddress( 'glTransformFeedbackVaryingsNV' , ADDRESSOF( TransformFeedbackVaryingsNV ));
	GetProcAddress( 'glActiveVaryingNV' , ADDRESSOF( ActiveVaryingNV ));
	GetProcAddress( 'glGetVaryingLocationNV' , ADDRESSOF( GetVaryingLocationNV ));
	GetProcAddress( 'glGetActiveVaryingNV' , ADDRESSOF( GetActiveVaryingNV ));
	GetProcAddress( 'glGetTransformFeedbackVaryingNV' , ADDRESSOF( GetTransformFeedbackVaryingNV ));
	GetProcAddress( 'glTransformFeedbackStreamAttribsNV' , ADDRESSOF( TransformFeedbackStreamAttribsNV ));
END Read_GL_NV_transform_feedback;

PROCEDURE Read_GL_NV_conditional_render*;
BEGIN
	GetProcAddress( 'glBeginConditionalRenderNV' , ADDRESSOF( BeginConditionalRenderNV ));
	GetProcAddress( 'glEndConditionalRenderNV' , ADDRESSOF( EndConditionalRenderNV ));
END Read_GL_NV_conditional_render;

PROCEDURE Read_GL_NV_conservative_raster*;
BEGIN
	GetProcAddress( 'glSubpixelPrecisionBiasNV' , ADDRESSOF( SubpixelPrecisionBiasNV ));
END Read_GL_NV_conservative_raster;

PROCEDURE Read_GL_NV_conservative_raster_dilate*;
BEGIN
	GetProcAddress( 'glConservativeRasterParameterfNV' , ADDRESSOF( ConservativeRasterParameterfNV ));
END Read_GL_NV_conservative_raster_dilate;

PROCEDURE Read_GL_NV_present_video*;
BEGIN
	GetProcAddress( 'glPresentFrameKeyedNV' , ADDRESSOF( PresentFrameKeyedNV ));
	GetProcAddress( 'glPresentFrameDualFillNV' , ADDRESSOF( PresentFrameDualFillNV ));
	GetProcAddress( 'glGetVideoivNV' , ADDRESSOF( GetVideoivNV ));
	GetProcAddress( 'glGetVideouivNV' , ADDRESSOF( GetVideouivNV ));
	GetProcAddress( 'glGetVideoi64vNV' , ADDRESSOF( GetVideoi64vNV ));
	GetProcAddress( 'glGetVideoui64vNV' , ADDRESSOF( GetVideoui64vNV ));
(*	GetProcAddress( 'glVideoParameterivNV' , ADDRESSOF( VideoParameterivNV )); *)
END Read_GL_NV_present_video;

PROCEDURE Read_GL_NV_explicit_multisample*;
BEGIN
	GetProcAddress( 'glGetMultisamplefvNV' , ADDRESSOF( GetMultisamplefvNV ));
	GetProcAddress( 'glSampleMaskIndexedNV' , ADDRESSOF( SampleMaskIndexedNV ));
	GetProcAddress( 'glTexRenderbufferNV' , ADDRESSOF( TexRenderbufferNV ));
END Read_GL_NV_explicit_multisample;

PROCEDURE Read_GL_NV_transform_feedback2*;
BEGIN
	GetProcAddress( 'glBindTransformFeedbackNV' , ADDRESSOF( BindTransformFeedbackNV ));
	GetProcAddress( 'glDeleteTransformFeedbacksNV' , ADDRESSOF( DeleteTransformFeedbacksNV ));
	GetProcAddress( 'glGenTransformFeedbacksNV' , ADDRESSOF( GenTransformFeedbacksNV ));
	GetProcAddress( 'glIsTransformFeedbackNV' , ADDRESSOF( IsTransformFeedbackNV ));
	GetProcAddress( 'glPauseTransformFeedbackNV' , ADDRESSOF( PauseTransformFeedbackNV ));
	GetProcAddress( 'glResumeTransformFeedbackNV' , ADDRESSOF( ResumeTransformFeedbackNV ));
	GetProcAddress( 'glDrawTransformFeedbackNV' , ADDRESSOF( DrawTransformFeedbackNV ));
END Read_GL_NV_transform_feedback2;

PROCEDURE Read_GL_NV_video_capture*;
BEGIN
	GetProcAddress( 'glBeginVideoCaptureNV' , ADDRESSOF( BeginVideoCaptureNV ));
	GetProcAddress( 'glBindVideoCaptureStreamBufferNV' , ADDRESSOF( BindVideoCaptureStreamBufferNV ));
	GetProcAddress( 'glBindVideoCaptureStreamTextureNV' , ADDRESSOF( BindVideoCaptureStreamTextureNV ));
	GetProcAddress( 'glEndVideoCaptureNV' , ADDRESSOF( EndVideoCaptureNV ));
	GetProcAddress( 'glGetVideoCaptureivNV' , ADDRESSOF( GetVideoCaptureivNV ));
	GetProcAddress( 'glGetVideoCaptureStreamivNV' , ADDRESSOF( GetVideoCaptureStreamivNV ));
	GetProcAddress( 'glGetVideoCaptureStreamfvNV' , ADDRESSOF( GetVideoCaptureStreamfvNV ));
	GetProcAddress( 'glGetVideoCaptureStreamdvNV' , ADDRESSOF( GetVideoCaptureStreamdvNV ));
	GetProcAddress( 'glVideoCaptureNV' , ADDRESSOF( VideoCaptureNV ));
	GetProcAddress( 'glVideoCaptureStreamParameterivNV' , ADDRESSOF( VideoCaptureStreamParameterivNV ));
	GetProcAddress( 'glVideoCaptureStreamParameterfvNV' , ADDRESSOF( VideoCaptureStreamParameterfvNV ));
	GetProcAddress( 'glVideoCaptureStreamParameterdvNV' , ADDRESSOF( VideoCaptureStreamParameterdvNV ));
END Read_GL_NV_video_capture;

PROCEDURE Read_GL_NV_copy_image*;
BEGIN
	GetProcAddress( 'glCopyImageSubDataNV' , ADDRESSOF( CopyImageSubDataNV ));
END Read_GL_NV_copy_image;

PROCEDURE Read_GL_NV_shader_buffer_load*;
BEGIN
	GetProcAddress( 'glMakeBufferResidentNV' , ADDRESSOF( MakeBufferResidentNV ));
	GetProcAddress( 'glMakeBufferNonResidentNV' , ADDRESSOF( MakeBufferNonResidentNV ));
	GetProcAddress( 'glIsBufferResidentNV' , ADDRESSOF( IsBufferResidentNV ));
	GetProcAddress( 'glMakeNamedBufferResidentNV' , ADDRESSOF( MakeNamedBufferResidentNV ));
	GetProcAddress( 'glMakeNamedBufferNonResidentNV' , ADDRESSOF( MakeNamedBufferNonResidentNV ));
	GetProcAddress( 'glIsNamedBufferResidentNV' , ADDRESSOF( IsNamedBufferResidentNV ));
	GetProcAddress( 'glGetBufferParameterui64vNV' , ADDRESSOF( GetBufferParameterui64vNV ));
	GetProcAddress( 'glGetNamedBufferParameterui64vNV' , ADDRESSOF( GetNamedBufferParameterui64vNV ));
	GetProcAddress( 'glGetIntegerui64vNV' , ADDRESSOF( GetIntegerui64vNV ));
	GetProcAddress( 'glUniformui64NV' , ADDRESSOF( Uniformui64NV ));
	GetProcAddress( 'glUniformui64vNV' , ADDRESSOF( Uniformui64vNV ));
	GetProcAddress( 'glGetUniformui64vNV' , ADDRESSOF( GetUniformui64vNV ));
	GetProcAddress( 'glProgramUniformui64NV' , ADDRESSOF( ProgramUniformui64NV ));
	GetProcAddress( 'glProgramUniformui64vNV' , ADDRESSOF( ProgramUniformui64vNV ));
END Read_GL_NV_shader_buffer_load;

PROCEDURE Read_GL_NV_vertex_buffer_unified_memory*;
BEGIN
	GetProcAddress( 'glBufferAddressRangeNV' , ADDRESSOF( BufferAddressRangeNV ));
	GetProcAddress( 'glVertexFormatNV' , ADDRESSOF( VertexFormatNV ));
	GetProcAddress( 'glNormalFormatNV' , ADDRESSOF( NormalFormatNV ));
	GetProcAddress( 'glColorFormatNV' , ADDRESSOF( ColorFormatNV ));
	GetProcAddress( 'glIndexFormatNV' , ADDRESSOF( IndexFormatNV ));
	GetProcAddress( 'glTexCoordFormatNV' , ADDRESSOF( TexCoordFormatNV ));
	GetProcAddress( 'glEdgeFlagFormatNV' , ADDRESSOF( EdgeFlagFormatNV ));
	GetProcAddress( 'glSecondaryColorFormatNV' , ADDRESSOF( SecondaryColorFormatNV ));
	GetProcAddress( 'glFogCoordFormatNV' , ADDRESSOF( FogCoordFormatNV ));
	GetProcAddress( 'glVertexAttribFormatNV' , ADDRESSOF( VertexAttribFormatNV ));
	GetProcAddress( 'glVertexAttribIFormatNV' , ADDRESSOF( VertexAttribIFormatNV ));
	GetProcAddress( 'glGetIntegerui64i_vNV' , ADDRESSOF( GetIntegerui64i_vNV ));
END Read_GL_NV_vertex_buffer_unified_memory;

PROCEDURE Read_GL_NV_gpu_program5*;
BEGIN
	GetProcAddress( 'glProgramSubroutineParametersuivNV' , ADDRESSOF( ProgramSubroutineParametersuivNV ));
	GetProcAddress( 'glGetProgramSubroutineParameteruivNV' , ADDRESSOF( GetProgramSubroutineParameteruivNV ));
END Read_GL_NV_gpu_program5;

PROCEDURE Read_GL_NV_gpu_shader5*;
BEGIN
	GetProcAddress( 'glUniform1i64NV' , ADDRESSOF( Uniform1i64NV ));
	GetProcAddress( 'glUniform2i64NV' , ADDRESSOF( Uniform2i64NV ));
	GetProcAddress( 'glUniform3i64NV' , ADDRESSOF( Uniform3i64NV ));
	GetProcAddress( 'glUniform4i64NV' , ADDRESSOF( Uniform4i64NV ));
	GetProcAddress( 'glUniform1i64vNV' , ADDRESSOF( Uniform1i64vNV ));
	GetProcAddress( 'glUniform2i64vNV' , ADDRESSOF( Uniform2i64vNV ));
	GetProcAddress( 'glUniform3i64vNV' , ADDRESSOF( Uniform3i64vNV ));
	GetProcAddress( 'glUniform4i64vNV' , ADDRESSOF( Uniform4i64vNV ));
	GetProcAddress( 'glUniform1ui64NV' , ADDRESSOF( Uniform1ui64NV ));
	GetProcAddress( 'glUniform2ui64NV' , ADDRESSOF( Uniform2ui64NV ));
	GetProcAddress( 'glUniform3ui64NV' , ADDRESSOF( Uniform3ui64NV ));
	GetProcAddress( 'glUniform4ui64NV' , ADDRESSOF( Uniform4ui64NV ));
	GetProcAddress( 'glUniform1ui64vNV' , ADDRESSOF( Uniform1ui64vNV ));
	GetProcAddress( 'glUniform2ui64vNV' , ADDRESSOF( Uniform2ui64vNV ));
	GetProcAddress( 'glUniform3ui64vNV' , ADDRESSOF( Uniform3ui64vNV ));
	GetProcAddress( 'glUniform4ui64vNV' , ADDRESSOF( Uniform4ui64vNV ));
	GetProcAddress( 'glGetUniformi64vNV' , ADDRESSOF( GetUniformi64vNV ));
	GetProcAddress( 'glProgramUniform1i64NV' , ADDRESSOF( ProgramUniform1i64NV ));
	GetProcAddress( 'glProgramUniform2i64NV' , ADDRESSOF( ProgramUniform2i64NV ));
	GetProcAddress( 'glProgramUniform3i64NV' , ADDRESSOF( ProgramUniform3i64NV ));
	GetProcAddress( 'glProgramUniform4i64NV' , ADDRESSOF( ProgramUniform4i64NV ));
	GetProcAddress( 'glProgramUniform1i64vNV' , ADDRESSOF( ProgramUniform1i64vNV ));
	GetProcAddress( 'glProgramUniform2i64vNV' , ADDRESSOF( ProgramUniform2i64vNV ));
	GetProcAddress( 'glProgramUniform3i64vNV' , ADDRESSOF( ProgramUniform3i64vNV ));
	GetProcAddress( 'glProgramUniform4i64vNV' , ADDRESSOF( ProgramUniform4i64vNV ));
	GetProcAddress( 'glProgramUniform1ui64NV' , ADDRESSOF( ProgramUniform1ui64NV ));
	GetProcAddress( 'glProgramUniform2ui64NV' , ADDRESSOF( ProgramUniform2ui64NV ));
	GetProcAddress( 'glProgramUniform3ui64NV' , ADDRESSOF( ProgramUniform3ui64NV ));
	GetProcAddress( 'glProgramUniform4ui64NV' , ADDRESSOF( ProgramUniform4ui64NV ));
	GetProcAddress( 'glProgramUniform1ui64vNV' , ADDRESSOF( ProgramUniform1ui64vNV ));
	GetProcAddress( 'glProgramUniform2ui64vNV' , ADDRESSOF( ProgramUniform2ui64vNV ));
	GetProcAddress( 'glProgramUniform3ui64vNV' , ADDRESSOF( ProgramUniform3ui64vNV ));
	GetProcAddress( 'glProgramUniform4ui64vNV' , ADDRESSOF( ProgramUniform4ui64vNV ));
END Read_GL_NV_gpu_shader5;

PROCEDURE Read_GL_NV_vertex_attrib_integer_64bit*;
BEGIN
	GetProcAddress( 'glVertexAttribL1i64NV' , ADDRESSOF( VertexAttribL1i64NV ));
	GetProcAddress( 'glVertexAttribL2i64NV' , ADDRESSOF( VertexAttribL2i64NV ));
	GetProcAddress( 'glVertexAttribL3i64NV' , ADDRESSOF( VertexAttribL3i64NV ));
	GetProcAddress( 'glVertexAttribL4i64NV' , ADDRESSOF( VertexAttribL4i64NV ));
	GetProcAddress( 'glVertexAttribL1i64vNV' , ADDRESSOF( VertexAttribL1i64vNV ));
	GetProcAddress( 'glVertexAttribL2i64vNV' , ADDRESSOF( VertexAttribL2i64vNV ));
	GetProcAddress( 'glVertexAttribL3i64vNV' , ADDRESSOF( VertexAttribL3i64vNV ));
	GetProcAddress( 'glVertexAttribL4i64vNV' , ADDRESSOF( VertexAttribL4i64vNV ));
	GetProcAddress( 'glVertexAttribL1ui64NV' , ADDRESSOF( VertexAttribL1ui64NV ));
	GetProcAddress( 'glVertexAttribL2ui64NV' , ADDRESSOF( VertexAttribL2ui64NV ));
	GetProcAddress( 'glVertexAttribL3ui64NV' , ADDRESSOF( VertexAttribL3ui64NV ));
	GetProcAddress( 'glVertexAttribL4ui64NV' , ADDRESSOF( VertexAttribL4ui64NV ));
	GetProcAddress( 'glVertexAttribL1ui64vNV' , ADDRESSOF( VertexAttribL1ui64vNV ));
	GetProcAddress( 'glVertexAttribL2ui64vNV' , ADDRESSOF( VertexAttribL2ui64vNV ));
	GetProcAddress( 'glVertexAttribL3ui64vNV' , ADDRESSOF( VertexAttribL3ui64vNV ));
	GetProcAddress( 'glVertexAttribL4ui64vNV' , ADDRESSOF( VertexAttribL4ui64vNV ));
	GetProcAddress( 'glGetVertexAttribLi64vNV' , ADDRESSOF( GetVertexAttribLi64vNV ));
	GetProcAddress( 'glGetVertexAttribLui64vNV' , ADDRESSOF( GetVertexAttribLui64vNV ));
	GetProcAddress( 'glVertexAttribLFormatNV' , ADDRESSOF( VertexAttribLFormatNV ));
END Read_GL_NV_vertex_attrib_integer_64bit;

PROCEDURE Read_GL_NV_vdpau_interop*;
BEGIN
	GetProcAddress( 'glVDPAUInitNV' , ADDRESSOF( VDPAUInitNV ));
	GetProcAddress( 'glVDPAUFiniNV' , ADDRESSOF( VDPAUFiniNV ));
	GetProcAddress( 'glVDPAURegisterVideoSurfaceNV' , ADDRESSOF( VDPAURegisterVideoSurfaceNV ));
	GetProcAddress( 'glVDPAURegisterOutputSurfaceNV' , ADDRESSOF( VDPAURegisterOutputSurfaceNV ));
	GetProcAddress( 'glVDPAUIsSurfaceNV' , ADDRESSOF( VDPAUIsSurfaceNV ));
	GetProcAddress( 'glVDPAUUnregisterSurfaceNV' , ADDRESSOF( VDPAUUnregisterSurfaceNV ));
	GetProcAddress( 'glVDPAUGetSurfaceivNV' , ADDRESSOF( VDPAUGetSurfaceivNV ));
	GetProcAddress( 'glVDPAUSurfaceAccessNV' , ADDRESSOF( VDPAUSurfaceAccessNV ));
	GetProcAddress( 'glVDPAUMapSurfacesNV' , ADDRESSOF( VDPAUMapSurfacesNV ));
	GetProcAddress( 'glVDPAUUnmapSurfacesNV' , ADDRESSOF( VDPAUUnmapSurfacesNV ));
END Read_GL_NV_vdpau_interop;

PROCEDURE Read_GL_NV_texture_barrier*;
BEGIN
	GetProcAddress( 'glTextureBarrierNV' , ADDRESSOF( TextureBarrierNV ));
END Read_GL_NV_texture_barrier;

PROCEDURE Read_GL_PGI_misc_hints*;
BEGIN
	GetProcAddress( 'glHintPGI' , ADDRESSOF( HintPGI ));
END Read_GL_PGI_misc_hints;

PROCEDURE Read_GL_OVR_multiview*;
BEGIN
	GetProcAddress( 'glFramebufferTextureMultiviewOVR' , ADDRESSOF( FramebufferTextureMultiviewOVR ));
END Read_GL_OVR_multiview;

PROCEDURE Read_GL_SGIS_detail_texture*;
BEGIN
	GetProcAddress( 'glDetailTexFuncSGIS' , ADDRESSOF( DetailTexFuncSGIS ));
	GetProcAddress( 'glGetDetailTexFuncSGIS' , ADDRESSOF( GetDetailTexFuncSGIS ));
END Read_GL_SGIS_detail_texture;

PROCEDURE Read_GL_SGIS_fog_function*;
BEGIN
	GetProcAddress( 'glFogFuncSGIS' , ADDRESSOF( FogFuncSGIS ));
	GetProcAddress( 'glGetFogFuncSGIS' , ADDRESSOF( GetFogFuncSGIS ));
END Read_GL_SGIS_fog_function;

PROCEDURE Read_GL_SGIS_multisample*;
BEGIN
	GetProcAddress( 'glSampleMaskSGIS' , ADDRESSOF( SampleMaskSGIS ));
	GetProcAddress( 'glSamplePatternSGIS' , ADDRESSOF( SamplePatternSGIS ));
END Read_GL_SGIS_multisample;

PROCEDURE Read_GL_SGIS_pixel_texture*;
BEGIN
	GetProcAddress( 'glPixelTexGenParameteriSGIS' , ADDRESSOF( PixelTexGenParameteriSGIS ));
	GetProcAddress( 'glPixelTexGenParameterivSGIS' , ADDRESSOF( PixelTexGenParameterivSGIS ));
	GetProcAddress( 'glPixelTexGenParameterfSGIS' , ADDRESSOF( PixelTexGenParameterfSGIS ));
	GetProcAddress( 'glPixelTexGenParameterfvSGIS' , ADDRESSOF( PixelTexGenParameterfvSGIS ));
	GetProcAddress( 'glGetPixelTexGenParameterivSGIS' , ADDRESSOF( GetPixelTexGenParameterivSGIS ));
	GetProcAddress( 'glGetPixelTexGenParameterfvSGIS' , ADDRESSOF( GetPixelTexGenParameterfvSGIS ));
END Read_GL_SGIS_pixel_texture;

PROCEDURE Read_GL_SGIS_point_parameters*;
BEGIN
	GetProcAddress( 'glPointParameterfSGIS' , ADDRESSOF( PointParameterfSGIS ));
	GetProcAddress( 'glPointParameterfvSGIS' , ADDRESSOF( PointParameterfvSGIS ));
END Read_GL_SGIS_point_parameters;

PROCEDURE Read_GL_SGIS_sharpen_texture*;
BEGIN
	GetProcAddress( 'glSharpenTexFuncSGIS' , ADDRESSOF( SharpenTexFuncSGIS ));
	GetProcAddress( 'glGetSharpenTexFuncSGIS' , ADDRESSOF( GetSharpenTexFuncSGIS ));
END Read_GL_SGIS_sharpen_texture;

PROCEDURE Read_GL_SGIS_texture4D*;
BEGIN
	GetProcAddress( 'glTexImage4DSGIS' , ADDRESSOF( TexImage4DSGIS ));
	GetProcAddress( 'glTexSubImage4DSGIS' , ADDRESSOF( TexSubImage4DSGIS ));
END Read_GL_SGIS_texture4D;

PROCEDURE Read_GL_SGIS_texture_color_mask*;
BEGIN
	GetProcAddress( 'glTextureColorMaskSGIS' , ADDRESSOF( TextureColorMaskSGIS ));
END Read_GL_SGIS_texture_color_mask;

PROCEDURE Read_GL_SGIS_texture_filter4*;
BEGIN
	GetProcAddress( 'glGetTexFilterFuncSGIS' , ADDRESSOF( GetTexFilterFuncSGIS ));
	GetProcAddress( 'glTexFilterFuncSGIS' , ADDRESSOF( TexFilterFuncSGIS ));
END Read_GL_SGIS_texture_filter4;

PROCEDURE Read_GL_SGIX_async*;
BEGIN
	GetProcAddress( 'glAsyncMarkerSGIX' , ADDRESSOF( AsyncMarkerSGIX ));
	GetProcAddress( 'glFinishAsyncSGIX' , ADDRESSOF( FinishAsyncSGIX ));
	GetProcAddress( 'glPollAsyncSGIX' , ADDRESSOF( PollAsyncSGIX ));
	GetProcAddress( 'glGenAsyncMarkersSGIX' , ADDRESSOF( GenAsyncMarkersSGIX ));
	GetProcAddress( 'glDeleteAsyncMarkersSGIX' , ADDRESSOF( DeleteAsyncMarkersSGIX ));
	GetProcAddress( 'glIsAsyncMarkerSGIX' , ADDRESSOF( IsAsyncMarkerSGIX ));
END Read_GL_SGIX_async;

PROCEDURE Read_GL_SGIX_flush_raster*;
BEGIN
	GetProcAddress( 'glFlushRasterSGIX' , ADDRESSOF( FlushRasterSGIX ));
END Read_GL_SGIX_flush_raster;

PROCEDURE Read_GL_SGIX_fragment_lighting*;
BEGIN
	GetProcAddress( 'glFragmentColorMaterialSGIX' , ADDRESSOF( FragmentColorMaterialSGIX ));
	GetProcAddress( 'glFragmentLightfSGIX' , ADDRESSOF( FragmentLightfSGIX ));
	GetProcAddress( 'glFragmentLightfvSGIX' , ADDRESSOF( FragmentLightfvSGIX ));
	GetProcAddress( 'glFragmentLightiSGIX' , ADDRESSOF( FragmentLightiSGIX ));
	GetProcAddress( 'glFragmentLightivSGIX' , ADDRESSOF( FragmentLightivSGIX ));
	GetProcAddress( 'glFragmentLightModelfSGIX' , ADDRESSOF( FragmentLightModelfSGIX ));
	GetProcAddress( 'glFragmentLightModelfvSGIX' , ADDRESSOF( FragmentLightModelfvSGIX ));
	GetProcAddress( 'glFragmentLightModeliSGIX' , ADDRESSOF( FragmentLightModeliSGIX ));
	GetProcAddress( 'glFragmentLightModelivSGIX' , ADDRESSOF( FragmentLightModelivSGIX ));
	GetProcAddress( 'glFragmentMaterialfSGIX' , ADDRESSOF( FragmentMaterialfSGIX ));
	GetProcAddress( 'glFragmentMaterialfvSGIX' , ADDRESSOF( FragmentMaterialfvSGIX ));
	GetProcAddress( 'glFragmentMaterialiSGIX' , ADDRESSOF( FragmentMaterialiSGIX ));
	GetProcAddress( 'glFragmentMaterialivSGIX' , ADDRESSOF( FragmentMaterialivSGIX ));
	GetProcAddress( 'glGetFragmentLightfvSGIX' , ADDRESSOF( GetFragmentLightfvSGIX ));
	GetProcAddress( 'glGetFragmentLightivSGIX' , ADDRESSOF( GetFragmentLightivSGIX ));
	GetProcAddress( 'glGetFragmentMaterialfvSGIX' , ADDRESSOF( GetFragmentMaterialfvSGIX ));
	GetProcAddress( 'glGetFragmentMaterialivSGIX' , ADDRESSOF( GetFragmentMaterialivSGIX ));
	GetProcAddress( 'glLightEnviSGIX' , ADDRESSOF( LightEnviSGIX ));
END Read_GL_SGIX_fragment_lighting;

PROCEDURE Read_GL_SGIX_framezoom*;
BEGIN
	GetProcAddress( 'glFrameZoomSGIX' , ADDRESSOF( FrameZoomSGIX ));
END Read_GL_SGIX_framezoom;

PROCEDURE Read_GL_SGIX_igloo_interface*;
BEGIN
	GetProcAddress( 'glIglooInterfaceSGIX' , ADDRESSOF( IglooInterfaceSGIX ));
END Read_GL_SGIX_igloo_interface;

PROCEDURE Read_GL_SGIX_instruments*;
BEGIN
	GetProcAddress( 'glGetInstrumentsSGIX' , ADDRESSOF( GetInstrumentsSGIX ));
	GetProcAddress( 'glInstrumentsBufferSGIX' , ADDRESSOF( InstrumentsBufferSGIX ));
	GetProcAddress( 'glPollInstrumentsSGIX' , ADDRESSOF( PollInstrumentsSGIX ));
	GetProcAddress( 'glReadInstrumentsSGIX' , ADDRESSOF( ReadInstrumentsSGIX ));
	GetProcAddress( 'glStartInstrumentsSGIX' , ADDRESSOF( StartInstrumentsSGIX ));
	GetProcAddress( 'glStopInstrumentsSGIX' , ADDRESSOF( StopInstrumentsSGIX ));
END Read_GL_SGIX_instruments;

PROCEDURE Read_GL_SGIX_list_priority*;
BEGIN
	GetProcAddress( 'glGetListParameterfvSGIX' , ADDRESSOF( GetListParameterfvSGIX ));
	GetProcAddress( 'glGetListParameterivSGIX' , ADDRESSOF( GetListParameterivSGIX ));
	GetProcAddress( 'glListParameterfSGIX' , ADDRESSOF( ListParameterfSGIX ));
	GetProcAddress( 'glListParameterfvSGIX' , ADDRESSOF( ListParameterfvSGIX ));
	GetProcAddress( 'glListParameteriSGIX' , ADDRESSOF( ListParameteriSGIX ));
	GetProcAddress( 'glListParameterivSGIX' , ADDRESSOF( ListParameterivSGIX ));
END Read_GL_SGIX_list_priority;

PROCEDURE Read_GL_SGIX_pixel_texture*;
BEGIN
	GetProcAddress( 'glPixelTexGenSGIX' , ADDRESSOF( PixelTexGenSGIX ));
END Read_GL_SGIX_pixel_texture;

PROCEDURE Read_GL_SGIX_polynomial_ffd*;
BEGIN
	GetProcAddress( 'glDeformationMap3dSGIX' , ADDRESSOF( DeformationMap3dSGIX ));
	GetProcAddress( 'glDeformationMap3fSGIX' , ADDRESSOF( DeformationMap3fSGIX ));
	GetProcAddress( 'glDeformSGIX' , ADDRESSOF( DeformSGIX ));
	GetProcAddress( 'glLoadIdentityDeformationMapSGIX' , ADDRESSOF( LoadIdentityDeformationMapSGIX ));
END Read_GL_SGIX_polynomial_ffd;

PROCEDURE Read_GL_SGIX_reference_plane*;
BEGIN
	GetProcAddress( 'glReferencePlaneSGIX' , ADDRESSOF( ReferencePlaneSGIX ));
END Read_GL_SGIX_reference_plane;

PROCEDURE Read_GL_SGIX_sprite*;
BEGIN
	GetProcAddress( 'glSpriteParameterfSGIX' , ADDRESSOF( SpriteParameterfSGIX ));
	GetProcAddress( 'glSpriteParameterfvSGIX' , ADDRESSOF( SpriteParameterfvSGIX ));
	GetProcAddress( 'glSpriteParameteriSGIX' , ADDRESSOF( SpriteParameteriSGIX ));
	GetProcAddress( 'glSpriteParameterivSGIX' , ADDRESSOF( SpriteParameterivSGIX ));
END Read_GL_SGIX_sprite;

PROCEDURE Read_GL_SGIX_tag_sample_buffer*;
BEGIN
	GetProcAddress( 'glTagSampleBufferSGIX' , ADDRESSOF( TagSampleBufferSGIX ));
END Read_GL_SGIX_tag_sample_buffer;

PROCEDURE Read_GL_SGI_color_table*;
BEGIN
	GetProcAddress( 'glColorTableSGI' , ADDRESSOF( ColorTableSGI ));
	GetProcAddress( 'glColorTableParameterfvSGI' , ADDRESSOF( ColorTableParameterfvSGI ));
	GetProcAddress( 'glColorTableParameterivSGI' , ADDRESSOF( ColorTableParameterivSGI ));
	GetProcAddress( 'glCopyColorTableSGI' , ADDRESSOF( CopyColorTableSGI ));
	GetProcAddress( 'glGetColorTableSGI' , ADDRESSOF( GetColorTableSGI ));
	GetProcAddress( 'glGetColorTableParameterfvSGI' , ADDRESSOF( GetColorTableParameterfvSGI ));
	GetProcAddress( 'glGetColorTableParameterivSGI' , ADDRESSOF( GetColorTableParameterivSGI ));
END Read_GL_SGI_color_table;

PROCEDURE Read_GL_SUNX_constant_data*;
BEGIN
	GetProcAddress( 'glFinishTextureSUNX' , ADDRESSOF( FinishTextureSUNX ));
END Read_GL_SUNX_constant_data;

PROCEDURE Read_GL_SUN_global_alpha*;
BEGIN
	GetProcAddress( 'glGlobalAlphaFactorbSUN' , ADDRESSOF( GlobalAlphaFactorbSUN ));
	GetProcAddress( 'glGlobalAlphaFactorsSUN' , ADDRESSOF( GlobalAlphaFactorsSUN ));
	GetProcAddress( 'glGlobalAlphaFactoriSUN' , ADDRESSOF( GlobalAlphaFactoriSUN ));
	GetProcAddress( 'glGlobalAlphaFactorfSUN' , ADDRESSOF( GlobalAlphaFactorfSUN ));
	GetProcAddress( 'glGlobalAlphaFactordSUN' , ADDRESSOF( GlobalAlphaFactordSUN ));
	GetProcAddress( 'glGlobalAlphaFactorubSUN' , ADDRESSOF( GlobalAlphaFactorubSUN ));
	GetProcAddress( 'glGlobalAlphaFactorusSUN' , ADDRESSOF( GlobalAlphaFactorusSUN ));
	GetProcAddress( 'glGlobalAlphaFactoruiSUN' , ADDRESSOF( GlobalAlphaFactoruiSUN ));
END Read_GL_SUN_global_alpha;

PROCEDURE Read_GL_SUN_mesh_array*;
BEGIN
	GetProcAddress( 'glDrawMeshArraysSUN' , ADDRESSOF( DrawMeshArraysSUN ));
END Read_GL_SUN_mesh_array;

PROCEDURE Read_GL_SUN_triangle_list*;
BEGIN
	GetProcAddress( 'glReplacementCodeuiSUN' , ADDRESSOF( ReplacementCodeuiSUN ));
	GetProcAddress( 'glReplacementCodeusSUN' , ADDRESSOF( ReplacementCodeusSUN ));
	GetProcAddress( 'glReplacementCodeubSUN' , ADDRESSOF( ReplacementCodeubSUN ));
	GetProcAddress( 'glReplacementCodeuivSUN' , ADDRESSOF( ReplacementCodeuivSUN ));
	GetProcAddress( 'glReplacementCodeusvSUN' , ADDRESSOF( ReplacementCodeusvSUN ));
	GetProcAddress( 'glReplacementCodeubvSUN' , ADDRESSOF( ReplacementCodeubvSUN ));
	GetProcAddress( 'glReplacementCodePointerSUN' , ADDRESSOF( ReplacementCodePointerSUN ));
END Read_GL_SUN_triangle_list;

PROCEDURE Read_GL_SUN_vertex*;
BEGIN
	GetProcAddress( 'glColor4ubVertex2fSUN' , ADDRESSOF( Color4ubVertex2fSUN ));
	GetProcAddress( 'glColor4ubVertex2fvSUN' , ADDRESSOF( Color4ubVertex2fvSUN ));
	GetProcAddress( 'glColor4ubVertex3fSUN' , ADDRESSOF( Color4ubVertex3fSUN ));
	GetProcAddress( 'glColor4ubVertex3fvSUN' , ADDRESSOF( Color4ubVertex3fvSUN ));
	GetProcAddress( 'glColor3fVertex3fSUN' , ADDRESSOF( Color3fVertex3fSUN ));
	GetProcAddress( 'glColor3fVertex3fvSUN' , ADDRESSOF( Color3fVertex3fvSUN ));
	GetProcAddress( 'glNormal3fVertex3fSUN' , ADDRESSOF( Normal3fVertex3fSUN ));
	GetProcAddress( 'glNormal3fVertex3fvSUN' , ADDRESSOF( Normal3fVertex3fvSUN ));
	GetProcAddress( 'glColor4fNormal3fVertex3fSUN' , ADDRESSOF( Color4fNormal3fVertex3fSUN ));
	GetProcAddress( 'glColor4fNormal3fVertex3fvSUN' , ADDRESSOF( Color4fNormal3fVertex3fvSUN ));
	GetProcAddress( 'glTexCoord2fVertex3fSUN' , ADDRESSOF( TexCoord2fVertex3fSUN ));
	GetProcAddress( 'glTexCoord2fVertex3fvSUN' , ADDRESSOF( TexCoord2fVertex3fvSUN ));
	GetProcAddress( 'glTexCoord4fVertex4fSUN' , ADDRESSOF( TexCoord4fVertex4fSUN ));
	GetProcAddress( 'glTexCoord4fVertex4fvSUN' , ADDRESSOF( TexCoord4fVertex4fvSUN ));
	GetProcAddress( 'glTexCoord2fColor4ubVertex3fSUN' , ADDRESSOF( TexCoord2fColor4ubVertex3fSUN ));
	GetProcAddress( 'glTexCoord2fColor4ubVertex3fvSUN' , ADDRESSOF( TexCoord2fColor4ubVertex3fvSUN ));
	GetProcAddress( 'glTexCoord2fColor3fVertex3fSUN' , ADDRESSOF( TexCoord2fColor3fVertex3fSUN ));
	GetProcAddress( 'glTexCoord2fColor3fVertex3fvSUN' , ADDRESSOF( TexCoord2fColor3fVertex3fvSUN ));
	GetProcAddress( 'glTexCoord2fNormal3fVertex3fSUN' , ADDRESSOF( TexCoord2fNormal3fVertex3fSUN ));
	GetProcAddress( 'glTexCoord2fNormal3fVertex3fvSUN' , ADDRESSOF( TexCoord2fNormal3fVertex3fvSUN ));
	GetProcAddress( 'glTexCoord2fColor4fNormal3fVertex3fSUN' , ADDRESSOF( TexCoord2fColor4fNormal3fVertex3fSUN ));
	GetProcAddress( 'glTexCoord2fColor4fNormal3fVertex3fvSUN' , ADDRESSOF( TexCoord2fColor4fNormal3fVertex3fvSUN ));
	GetProcAddress( 'glTexCoord4fColor4fNormal3fVertex4fSUN' , ADDRESSOF( TexCoord4fColor4fNormal3fVertex4fSUN ));
	GetProcAddress( 'glTexCoord4fColor4fNormal3fVertex4fvSUN' , ADDRESSOF( TexCoord4fColor4fNormal3fVertex4fvSUN ));
	GetProcAddress( 'glReplacementCodeuiVertex3fSUN' , ADDRESSOF( ReplacementCodeuiVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiColor4ubVertex3fSUN' , ADDRESSOF( ReplacementCodeuiColor4ubVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiColor4ubVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiColor4ubVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiColor3fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiColor3fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiColor3fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiColor3fVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiNormal3fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiNormal3fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiNormal3fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiNormal3fVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiColor4fNormal3fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiColor4fNormal3fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiColor4fNormal3fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiColor4fNormal3fVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fNormal3fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN ));
	GetProcAddress( 'glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN' , ADDRESSOF( ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN ));
END Read_GL_SUN_vertex;

(* WGL *)
PROCEDURE Read_WGL_ARB_buffer_region*;
BEGIN
	GetProcAddress( 'wglCreateBufferRegionARB' , ADDRESSOF( wglCreateBufferRegionARB ));
	GetProcAddress( 'wglDeleteBufferRegionARB' , ADDRESSOF( wglDeleteBufferRegionARB ));
	GetProcAddress( 'wglSaveBufferRegionARB' , ADDRESSOF( wglSaveBufferRegionARB ));
	GetProcAddress( 'wglRestoreBufferRegionARB' , ADDRESSOF( wglRestoreBufferRegionARB ));
END Read_WGL_ARB_buffer_region;

PROCEDURE Read_WGL_ARB_extensions_string*;
BEGIN
	GetProcAddress( 'wglGetExtensionsStringARB' , ADDRESSOF( wglGetExtensionsStringARB ));
END Read_WGL_ARB_extensions_string;

PROCEDURE Read_WGL_ARB_make_current_read*;
BEGIN
	GetProcAddress( 'wglMakeContextCurrentARB' , ADDRESSOF( wglMakeContextCurrentARB ));
	GetProcAddress( 'wglGetCurrentReadDCARB' , ADDRESSOF( wglGetCurrentReadDCARB ));
END Read_WGL_ARB_make_current_read;

PROCEDURE Read_WGL_ARB_pbuffer*;
BEGIN
	GetProcAddress( 'wglCreatePbufferARB' , ADDRESSOF( wglCreatePbufferARB ));
	GetProcAddress( 'wglGetPbufferDCARB' , ADDRESSOF( wglGetPbufferDCARB ));
	GetProcAddress( 'wglReleasePbufferDCARB' , ADDRESSOF( wglReleasePbufferDCARB ));
	GetProcAddress( 'wglDestroyPbufferARB' , ADDRESSOF( wglDestroyPbufferARB ));
	GetProcAddress( 'wglQueryPbufferARB' , ADDRESSOF( wglQueryPbufferARB ));
END Read_WGL_ARB_pbuffer;

PROCEDURE Read_WGL_ARB_pixel_format*;
BEGIN
	GetProcAddress( 'wglGetPixelFormatAttribivARB' , ADDRESSOF( wglGetPixelFormatAttribivARB ));
	GetProcAddress( 'wglGetPixelFormatAttribfvARB' , ADDRESSOF( wglGetPixelFormatAttribfvARB ));
	GetProcAddress( 'wglChoosePixelFormatARB' , ADDRESSOF( wglChoosePixelFormatARB ));
END Read_WGL_ARB_pixel_format;

PROCEDURE Read_WGL_ARB_pixel_format_float*;
BEGIN
	GetProcAddress( 'wglClampColorARB' , ADDRESSOF( wglClampColorARB ));
END Read_WGL_ARB_pixel_format_float;

PROCEDURE Read_WGL_ARB_render_texture*;
BEGIN
	GetProcAddress( 'wglBindTexImageARB' , ADDRESSOF( wglBindTexImageARB ));
	GetProcAddress( 'wglReleaseTexImageARB' , ADDRESSOF( wglReleaseTexImageARB ));
	GetProcAddress( 'wglSetPbufferAttribARB' , ADDRESSOF( wglSetPbufferAttribARB ));
END Read_WGL_ARB_render_texture;

PROCEDURE Read_WGL_ARB_create_context*;
BEGIN
	GetProcAddress( 'wglCreateContextAttribsARB' , ADDRESSOF( wglCreateContextAttribsARB ));
END Read_WGL_ARB_create_context;

PROCEDURE Read_WGL_AMD_gpu_association*;
BEGIN
	GetProcAddress( 'wglGetGPUIDsAMD' , ADDRESSOF( wglGetGPUIDsAMD ));
	GetProcAddress( 'wglGetGPUInfoAMD' , ADDRESSOF( wglGetGPUInfoAMD ));
	GetProcAddress( 'wglGetContextGPUIDAMD' , ADDRESSOF( wglGetContextGPUIDAMD ));
	GetProcAddress( 'wglCreateAssociatedContextAMD' , ADDRESSOF( wglCreateAssociatedContextAMD ));
	GetProcAddress( 'wglCreateAssociatedContextAttribsAMD' , ADDRESSOF( wglCreateAssociatedContextAttribsAMD ));
	GetProcAddress( 'wglDeleteAssociatedContextAMD' , ADDRESSOF( wglDeleteAssociatedContextAMD ));
	GetProcAddress( 'wglMakeAssociatedContextCurrentAMD' , ADDRESSOF( wglMakeAssociatedContextCurrentAMD ));
	GetProcAddress( 'wglGetCurrentAssociatedContextAMD' , ADDRESSOF( wglGetCurrentAssociatedContextAMD ));
	GetProcAddress( 'wglBlitContextFramebufferAMD' , ADDRESSOF( wglBlitContextFramebufferAMD ));
END Read_WGL_AMD_gpu_association;

PROCEDURE Read_WGL_EXT_display_color_table*;
BEGIN
	GetProcAddress( 'wglCreateDisplayColorTableEXT' , ADDRESSOF( wglCreateDisplayColorTableEXT ));
	GetProcAddress( 'wglLoadDisplayColorTableEXT' , ADDRESSOF( wglLoadDisplayColorTableEXT ));
	GetProcAddress( 'wglBindDisplayColorTableEXT' , ADDRESSOF( wglBindDisplayColorTableEXT ));
	GetProcAddress( 'wglDestroyDisplayColorTableEXT' , ADDRESSOF( wglDestroyDisplayColorTableEXT ));
END Read_WGL_EXT_display_color_table;

PROCEDURE Read_WGL_EXT_extensions_string*;
BEGIN
	GetProcAddress( 'wglGetExtensionsStringEXT' , ADDRESSOF( wglGetExtensionsStringEXT ));
END Read_WGL_EXT_extensions_string;

PROCEDURE Read_WGL_EXT_make_current_read*;
BEGIN
	GetProcAddress( 'wglMakeContextCurrentEXT' , ADDRESSOF( wglMakeContextCurrentEXT ));
	GetProcAddress( 'wglGetCurrentReadDCEXT' , ADDRESSOF( wglGetCurrentReadDCEXT ));
END Read_WGL_EXT_make_current_read;

PROCEDURE Read_WGL_EXT_pbuffer*;
BEGIN
	GetProcAddress( 'wglCreatePbufferEXT' , ADDRESSOF( wglCreatePbufferEXT ));
	GetProcAddress( 'wglGetPbufferDCEXT' , ADDRESSOF( wglGetPbufferDCEXT ));
	GetProcAddress( 'wglReleasePbufferDCEXT' , ADDRESSOF( wglReleasePbufferDCEXT ));
	GetProcAddress( 'wglDestroyPbufferEXT' , ADDRESSOF( wglDestroyPbufferEXT ));
	GetProcAddress( 'wglQueryPbufferEXT' , ADDRESSOF( wglQueryPbufferEXT ));
END Read_WGL_EXT_pbuffer;

PROCEDURE Read_WGL_EXT_pixel_format*;
BEGIN
	GetProcAddress( 'wglGetPixelFormatAttribivEXT' , ADDRESSOF( wglGetPixelFormatAttribivEXT ));
	GetProcAddress( 'wglGetPixelFormatAttribfvEXT' , ADDRESSOF( wglGetPixelFormatAttribfvEXT ));
	GetProcAddress( 'wglChoosePixelFormatEXT' , ADDRESSOF( wglChoosePixelFormatEXT ));
END Read_WGL_EXT_pixel_format;

PROCEDURE Read_WGL_EXT_swap_control*;
BEGIN
	GetProcAddress( 'wglSwapIntervalEXT' , ADDRESSOF( wglSwapIntervalEXT ));
	GetProcAddress( 'wglGetSwapIntervalEXT' , ADDRESSOF( wglGetSwapIntervalEXT ));
END Read_WGL_EXT_swap_control;

PROCEDURE Read_WGL_I3D_digital_video_control*;
BEGIN
	GetProcAddress( 'wglGetDigitalVideoParametersI3D' , ADDRESSOF( wglGetDigitalVideoParametersI3D ));
	GetProcAddress( 'wglSetDigitalVideoParametersI3D' , ADDRESSOF( wglSetDigitalVideoParametersI3D ));
END Read_WGL_I3D_digital_video_control;

PROCEDURE Read_WGL_I3D_gamma*;
BEGIN
	GetProcAddress( 'wglGetGammaTableParametersI3D' , ADDRESSOF( wglGetGammaTableParametersI3D ));
	GetProcAddress( 'wglSetGammaTableParametersI3D' , ADDRESSOF( wglSetGammaTableParametersI3D ));
	GetProcAddress( 'wglGetGammaTableI3D' , ADDRESSOF( wglGetGammaTableI3D ));
	GetProcAddress( 'wglSetGammaTableI3D' , ADDRESSOF( wglSetGammaTableI3D ));
END Read_WGL_I3D_gamma;

PROCEDURE Read_WGL_I3D_genlock*;
BEGIN
	GetProcAddress( 'wglEnableGenlockI3D' , ADDRESSOF( wglEnableGenlockI3D ));
	GetProcAddress( 'wglDisableGenlockI3D' , ADDRESSOF( wglDisableGenlockI3D ));
	GetProcAddress( 'wglIsEnabledGenlockI3D' , ADDRESSOF( wglIsEnabledGenlockI3D ));
	GetProcAddress( 'wglGenlockSourceI3D' , ADDRESSOF( wglGenlockSourceI3D ));
	GetProcAddress( 'wglGetGenlockSourceI3D' , ADDRESSOF( wglGetGenlockSourceI3D ));
	GetProcAddress( 'wglGenlockSourceEdgeI3D' , ADDRESSOF( wglGenlockSourceEdgeI3D ));
	GetProcAddress( 'wglGetGenlockSourceEdgeI3D' , ADDRESSOF( wglGetGenlockSourceEdgeI3D ));
	GetProcAddress( 'wglGenlockSampleRateI3D' , ADDRESSOF( wglGenlockSampleRateI3D ));
	GetProcAddress( 'wglGetGenlockSampleRateI3D' , ADDRESSOF( wglGetGenlockSampleRateI3D ));
	GetProcAddress( 'wglGenlockSourceDelayI3D' , ADDRESSOF( wglGenlockSourceDelayI3D ));
	GetProcAddress( 'wglGetGenlockSourceDelayI3D' , ADDRESSOF( wglGetGenlockSourceDelayI3D ));
	GetProcAddress( 'wglQueryGenlockMaxSourceDelayI3D' , ADDRESSOF( wglQueryGenlockMaxSourceDelayI3D ));
END Read_WGL_I3D_genlock;

PROCEDURE Read_WGL_I3D_image_buffer*;
BEGIN
	GetProcAddress( 'wglCreateImageBufferI3D' , ADDRESSOF( wglCreateImageBufferI3D ));
	GetProcAddress( 'wglDestroyImageBufferI3D' , ADDRESSOF( wglDestroyImageBufferI3D ));
	GetProcAddress( 'wglAssociateImageBufferEventsI3D' , ADDRESSOF( wglAssociateImageBufferEventsI3D ));
	GetProcAddress( 'wglReleaseImageBufferEventsI3D' , ADDRESSOF( wglReleaseImageBufferEventsI3D ));
END Read_WGL_I3D_image_buffer;

PROCEDURE Read_WGL_I3D_swap_frame_lock*;
BEGIN
	GetProcAddress( 'wglEnableFrameLockI3D' , ADDRESSOF( wglEnableFrameLockI3D ));
	GetProcAddress( 'wglDisableFrameLockI3D' , ADDRESSOF( wglDisableFrameLockI3D ));
	GetProcAddress( 'wglIsEnabledFrameLockI3D' , ADDRESSOF( wglIsEnabledFrameLockI3D ));
	GetProcAddress( 'wglQueryFrameLockMasterI3D' , ADDRESSOF( wglQueryFrameLockMasterI3D ));
END Read_WGL_I3D_swap_frame_lock;

PROCEDURE Read_WGL_I3D_swap_frame_usage*;
BEGIN
	GetProcAddress( 'wglGetFrameUsageI3D' , ADDRESSOF( wglGetFrameUsageI3D ));
	GetProcAddress( 'wglBeginFrameTrackingI3D' , ADDRESSOF( wglBeginFrameTrackingI3D ));
	GetProcAddress( 'wglEndFrameTrackingI3D' , ADDRESSOF( wglEndFrameTrackingI3D ));
	GetProcAddress( 'wglQueryFrameTrackingI3D' , ADDRESSOF( wglQueryFrameTrackingI3D ));
END Read_WGL_I3D_swap_frame_usage;

PROCEDURE Read_WGL_NV_vertex_array_range*;
BEGIN
	GetProcAddress( 'wglAllocateMemoryNV' , ADDRESSOF( wglAllocateMemoryNV ));
	GetProcAddress( 'wglFreeMemoryNV' , ADDRESSOF( wglFreeMemoryNV ));
END Read_WGL_NV_vertex_array_range;

PROCEDURE Read_WGL_NV_present_video*;
BEGIN
	GetProcAddress( 'wglEnumerateVideoDevicesNV' , ADDRESSOF( wglEnumerateVideoDevicesNV ));
	GetProcAddress( 'wglBindVideoDeviceNV' , ADDRESSOF( wglBindVideoDeviceNV ));
	GetProcAddress( 'wglQueryCurrentContextNV' , ADDRESSOF( wglQueryCurrentContextNV ));
END Read_WGL_NV_present_video;

PROCEDURE Read_WGL_NV_video_output*;
BEGIN
	GetProcAddress( 'wglGetVideoDeviceNV' , ADDRESSOF( wglGetVideoDeviceNV ));
	GetProcAddress( 'wglReleaseVideoDeviceNV' , ADDRESSOF( wglReleaseVideoDeviceNV ));
	GetProcAddress( 'wglBindVideoImageNV' , ADDRESSOF( wglBindVideoImageNV ));
	GetProcAddress( 'wglReleaseVideoImageNV' , ADDRESSOF( wglReleaseVideoImageNV ));
	GetProcAddress( 'wglSendPbufferToVideoNV' , ADDRESSOF( wglSendPbufferToVideoNV ));
	GetProcAddress( 'wglGetVideoInfoNV' , ADDRESSOF( wglGetVideoInfoNV ));
END Read_WGL_NV_video_output;

PROCEDURE Read_WGL_NV_swap_group*;
BEGIN
	GetProcAddress( 'wglJoinSwapGroupNV' , ADDRESSOF( wglJoinSwapGroupNV ));
	GetProcAddress( 'wglBindSwapBarrierNV' , ADDRESSOF( wglBindSwapBarrierNV ));
	GetProcAddress( 'wglQuerySwapGroupNV' , ADDRESSOF( wglQuerySwapGroupNV ));
	GetProcAddress( 'wglQueryMaxSwapGroupsNV' , ADDRESSOF( wglQueryMaxSwapGroupsNV ));
	GetProcAddress( 'wglQueryFrameCountNV' , ADDRESSOF( wglQueryFrameCountNV ));
	GetProcAddress( 'wglResetFrameCountNV' , ADDRESSOF( wglResetFrameCountNV ));
END Read_WGL_NV_swap_group;

PROCEDURE Read_WGL_NV_gpu_affinity*;
BEGIN
	GetProcAddress( 'wglEnumGpusNV' , ADDRESSOF( wglEnumGpusNV ));
	GetProcAddress( 'wglEnumGpuDevicesNV' , ADDRESSOF( wglEnumGpuDevicesNV ));
	GetProcAddress( 'wglCreateAffinityDCNV' , ADDRESSOF( wglCreateAffinityDCNV ));
	GetProcAddress( 'wglEnumGpusFromAffinityDCNV' , ADDRESSOF( wglEnumGpusFromAffinityDCNV ));
	GetProcAddress( 'wglDeleteDCNV' , ADDRESSOF( wglDeleteDCNV ));
END Read_WGL_NV_gpu_affinity;

PROCEDURE Read_WGL_NV_video_capture*;
BEGIN
	GetProcAddress( 'wglBindVideoCaptureDeviceNV' , ADDRESSOF( wglBindVideoCaptureDeviceNV ));
	GetProcAddress( 'wglEnumerateVideoCaptureDevicesNV' , ADDRESSOF( wglEnumerateVideoCaptureDevicesNV ));
	GetProcAddress( 'wglLockVideoCaptureDeviceNV' , ADDRESSOF( wglLockVideoCaptureDeviceNV ));
	GetProcAddress( 'wglQueryVideoCaptureDeviceNV' , ADDRESSOF( wglQueryVideoCaptureDeviceNV ));
	GetProcAddress( 'wglReleaseVideoCaptureDeviceNV' , ADDRESSOF( wglReleaseVideoCaptureDeviceNV ));
END Read_WGL_NV_video_capture;

PROCEDURE Read_WGL_NV_copy_image*;
BEGIN
	GetProcAddress( 'wglCopyImageSubDataNV' , ADDRESSOF( wglCopyImageSubDataNV ));
END Read_WGL_NV_copy_image;

PROCEDURE Read_WGL_NV_DX_interop*;
BEGIN
	GetProcAddress( 'wglDXSetResourceShareHandleNV' , ADDRESSOF( wglDXSetResourceShareHandleNV ));
	GetProcAddress( 'wglDXOpenDeviceNV' , ADDRESSOF( wglDXOpenDeviceNV ));
	GetProcAddress( 'wglDXCloseDeviceNV' , ADDRESSOF( wglDXCloseDeviceNV ));
	GetProcAddress( 'wglDXRegisterObjectNV' , ADDRESSOF( wglDXRegisterObjectNV ));
	GetProcAddress( 'wglDXUnregisterObjectNV' , ADDRESSOF( wglDXUnregisterObjectNV ));
	GetProcAddress( 'wglDXObjectAccessNV' , ADDRESSOF( wglDXObjectAccessNV ));
	GetProcAddress( 'wglDXLockObjectsNV' , ADDRESSOF( wglDXLockObjectsNV ));
	GetProcAddress( 'wglDXUnlockObjectsNV' , ADDRESSOF( wglDXUnlockObjectsNV ));
END Read_WGL_NV_DX_interop;

PROCEDURE Read_WGL_OML_sync_control*;
BEGIN
	GetProcAddress( 'wglGetSyncValuesOML' , ADDRESSOF( wglGetSyncValuesOML ));
	GetProcAddress( 'wglGetMscRateOML' , ADDRESSOF( wglGetMscRateOML ));
	GetProcAddress( 'wglSwapBuffersMscOML' , ADDRESSOF( wglSwapBuffersMscOML ));
	GetProcAddress( 'wglSwapLayerBuffersMscOML' , ADDRESSOF( wglSwapLayerBuffersMscOML ));
	GetProcAddress( 'wglWaitForMscOML' , ADDRESSOF( wglWaitForMscOML ));
	GetProcAddress( 'wglWaitForSbcOML' , ADDRESSOF( wglWaitForSbcOML ));
END Read_WGL_OML_sync_control;


PROCEDURE Read_WGL_3DL_stereo_control*;
BEGIN
	GetProcAddress('wglSetStereoEmitterState3DL' , ADDRESSOF( wglSetStereoEmitterState3DL ));
END Read_WGL_3DL_stereo_control;

PROCEDURE Read_WIN_draw_range_elements*;
BEGIN
	GetProcAddress( 'glDrawRangeElementsWIN' , ADDRESSOF( glDrawRangeElementsWIN ));
END Read_WIN_draw_range_elements;

PROCEDURE Read_WIN_swap_hint*;
BEGIN
	GetProcAddress( 'glAddSwapHintRectWIN' , ADDRESSOF( glAddSwapHintRectWIN ));
END Read_WIN_swap_hint;


(***********************)

PROCEDURE ReadExtensions*;
BEGIN
	(*ReadOpenGLCore;*)
	Read_GL_3DFX_tbuffer;
	Read_GL_APPLE_element_array;
	Read_GL_APPLE_fence;
	Read_GL_APPLE_vertex_array_object;
	Read_GL_APPLE_vertex_array_range;
	Read_GL_APPLE_texture_range;
	Read_GL_APPLE_vertex_program_evaluators;
	Read_GL_APPLE_object_purgeable;
	Read_GL_ARB_matrix_palette;
	Read_GL_ARB_multitexture;
	Read_GL_ARB_point_parameters;
	Read_GL_ARB_texture_compression;
	Read_GL_ARB_transpose_matrix;
	Read_GL_ARB_vertex_blend;
	Read_GL_ARB_vertex_buffer_object;
	Read_GL_ARB_vertex_program;
	Read_GL_ARB_window_pos;
	Read_GL_ARB_color_buffer_float;
	Read_GL_ARB_Shader_Objects;
	Read_GL_ARB_occlusion_query;
	Read_GL_ARB_draw_instanced;
	Read_GL_ARB_framebuffer_object;
	Read_GL_ARB_geometry_shader4;
	Read_GL_ARB_gpu_shader_int64;
	Read_GL_ARB_instanced_arrays;
	Read_GL_ARB_map_buffer_range;
	Read_GL_ARB_texture_buffer_object;
	Read_GL_ARB_vertex_array_object;
	Read_GL_ARB_uniform_buffer_object;
	Read_GL_ARB_copy_buffer;
	Read_GL_ARB_draw_elements_base_vertex;
	Read_GL_ARB_provoking_vertex;
	Read_GL_ARB_sync;
	Read_GL_ARB_texture_multisample;
	Read_GL_ARB_draw_buffers_blend;
	Read_GL_ARB_sample_shading;
	Read_GL_ARB_sample_locations;
	Read_GL_ARB_shading_language_include;
	Read_GL_ARB_sparse_texture;
	Read_GL_ARB_sparse_buffer;
	Read_GL_ARB_blend_func_extended;
	Read_GL_ARB_sampler_objects;
	Read_GL_ARB_timer_query;
	Read_GL_ARB_vertex_type_2_10_10_10_rev;
	Read_GL_ARB_draw_indirect;
	Read_GL_ARB_gpu_shader_fp64;
	Read_GL_ARB_shader_subroutine;
	Read_GL_ARB_tessellation_shader;
	Read_GL_ARB_transform_feedback2;
	Read_GL_ARB_transform_feedback3;
	Read_GL_ARB_get_program_binary;
	Read_GL_ARB_separate_shader_objects;
	Read_GL_ARB_vertex_attrib_64bit;
	Read_GL_ARB_viewport_array;
	Read_GL_ARB_cl_event;
	Read_GL_ARB_compute_variable_group_size;
	Read_GL_ARB_debug_output;
	Read_GL_ARB_robustness;
	Read_GL_ARB_ES2_compatibility;
	(* *)
	Read_GL_ATI_draw_buffers;
	Read_GL_ATI_element_array;
	Read_GL_ATI_envmap_bumpmap;
	Read_GL_ATI_fragment_shader;
	Read_GL_ATI_map_object_buffer;
	Read_GL_ATI_pn_triangles;
	Read_GL_ATI_separate_stencil;
	Read_GL_ATI_vertex_array_object;
	Read_GL_ATI_vertex_attrib_array_object;
	Read_GL_ATI_vertex_streams;
	Read_GL_AMD_performance_monitor;
	Read_GL_AMD_vertex_shader_tesselator;
	Read_GL_AMD_draw_buffers_blend;
	Read_GL_AMD_name_gen_delete;
	Read_GL_AMD_debug_output;
	Read_GL_AMD_stencil_operation_extended;
	Read_GL_EXT_blend_color;
	Read_GL_EXT_blend_func_separate;
	Read_GL_EXT_blend_minmax;
	Read_GL_EXT_color_subtable;
	Read_GL_EXT_compiled_vertex_array;
	Read_GL_EXT_convolution;
	Read_GL_EXT_coordinate_frame;
	Read_GL_EXT_copy_texture;
	Read_GL_EXT_cull_vertex;
	Read_GL_EXT_draw_range_elements;
	Read_GL_EXT_fog_coord;
	Read_GL_EXT_framebuffer_object;
	Read_GL_EXT_histogram;
	Read_GL_EXT_index_func;
	Read_GL_EXT_index_material;
	Read_GL_EXT_multi_draw_arrays;
	Read_GL_EXT_multisample;
	Read_GL_EXT_paletted_texture;
	Read_GL_EXT_pixel_transform;
	Read_GL_EXT_point_parameters;
	Read_GL_EXT_polygon_offset;
	Read_GL_EXT_secondary_color;
	Read_GL_EXT_stencil_two_side;
	Read_GL_EXT_subtexture;
	Read_GL_EXT_texture3D;
	Read_GL_EXT_texture_object;
	Read_GL_EXT_texture_perturb_normal;
	Read_GL_EXT_vertex_array;
	Read_GL_EXT_vertex_shader;
	Read_GL_EXT_vertex_weighting;
	Read_GL_EXT_depth_bounds_test;
	Read_GL_EXT_blend_equation_separate;
	Read_GL_EXT_stencil_clear_tag;
	Read_GL_EXT_framebuffer_blit;
	Read_GL_EXT_framebuffer_multisample;
	Read_GL_EXT_timer_query;
	Read_GL_EXT_gpu_program_parameters;
	Read_GL_EXT_bindable_uniform;
	Read_GL_EXT_draw_buffers2;
	Read_GL_EXT_draw_instanced;
	Read_GL_EXT_geometry_shader4;
	Read_GL_EXT_gpu_shader4;
	Read_GL_EXT_texture_array;
	Read_GL_EXT_texture_buffer_object;
	Read_GL_EXT_texture_integer;
	Read_GL_EXT_transform_feedback;
	Read_GL_EXT_direct_state_access;
	Read_GL_EXT_separate_shader_objects;
	Read_GL_EXT_shader_image_load_store;
	Read_GL_EXT_vertex_attrib_64bit;
	Read_GL_HP_image_transform;
	Read_GL_IBM_multimode_draw_arrays;
	Read_GL_IBM_vertex_array_lists;
	Read_GL_INGR_blend_func_separate;
	Read_GL_INTEL_parallel_arrays;
	Read_GL_INTEL_framebuffer_CMAA;
	Read_GL_KHR_blend_equation_advanced;
	Read_GL_MESA_resize_buffers;
	Read_GL_MESA_window_pos;
	Read_GL_NV_evaluators;
	Read_GL_NV_fence;
	Read_GL_NV_fragment_program;
	Read_GL_NV_half_float;
	Read_GL_NV_occlusion_query;
	Read_GL_NV_pixel_data_range;
	Read_GL_NV_point_sprite;
	Read_GL_NV_primitive_restart;
	Read_GL_NV_register_combiners;
	Read_GL_NV_register_combiners2;
	Read_GL_NV_vertex_array_range;
	Read_GL_NV_vertex_program;
	Read_GL_NV_depth_buffer_float;
	Read_GL_NV_framebuffer_multisample_coverage;
	Read_GL_NV_geometry_program4;
	Read_GL_NV_gpu_program4;
	Read_GL_NV_parameter_buffer_object;
	Read_GL_NV_transform_feedback;
	Read_GL_NV_conditional_render;
	Read_GL_NV_conservative_raster;
	Read_GL_NV_conservative_raster_dilate;
	Read_GL_NV_present_video;
	Read_GL_NV_explicit_multisample;
	Read_GL_NV_transform_feedback2;
	Read_GL_NV_video_capture;
	Read_GL_NV_copy_image;
	Read_GL_NV_shader_buffer_load;
	Read_GL_NV_vertex_buffer_unified_memory;
	Read_GL_NV_gpu_program5;
	Read_GL_NV_gpu_shader5;
	Read_GL_NV_vertex_attrib_integer_64bit;
	Read_GL_NV_vdpau_interop;
	Read_GL_NV_texture_barrier;
	Read_GL_NV_path_rendering;
	Read_GL_NV_bindless_texture;
	Read_GL_PGI_misc_hints;
	Read_GL_OVR_multiview;
	Read_GL_SGIS_detail_texture;
	Read_GL_SGIS_fog_function;
	Read_GL_SGIS_multisample;
	Read_GL_SGIS_pixel_texture;
	Read_GL_SGIS_point_parameters;
	Read_GL_SGIS_sharpen_texture;
	Read_GL_SGIS_texture4D;
	Read_GL_SGIS_texture_color_mask;
	Read_GL_SGIS_texture_filter4;
	Read_GL_SGIX_async;
	Read_GL_SGIX_flush_raster;
	Read_GL_SGIX_fragment_lighting;
	Read_GL_SGIX_framezoom;
	Read_GL_SGIX_igloo_interface;
	Read_GL_SGIX_instruments;
	Read_GL_SGIX_list_priority;
	Read_GL_SGIX_pixel_texture;
	Read_GL_SGIX_polynomial_ffd;
	Read_GL_SGIX_reference_plane;
	Read_GL_SGIX_sprite;
	Read_GL_SGIX_tag_sample_buffer;
	Read_GL_SGI_color_table;
	Read_GL_SUNX_constant_data;
	Read_GL_SUN_global_alpha;
	Read_GL_SUN_mesh_array;
	Read_GL_SUN_triangle_list;
	Read_GL_SUN_vertex;

	Read_GL_ARB_ES3_2_compatibility;
	Read_GL_ARB_parallel_shader_compile;

	(* WGL Windows*)
	Read_WGL_ARB_buffer_region;
	Read_WGL_ARB_extensions_string;
	Read_WGL_ARB_make_current_read;
	Read_WGL_ARB_pbuffer;
	Read_WGL_ARB_pixel_format;
	Read_WGL_ARB_pixel_format_float;
	Read_WGL_ARB_render_texture;
	Read_WGL_ARB_create_context;
	Read_WGL_AMD_gpu_association;
	Read_WGL_EXT_display_color_table;
	Read_WGL_EXT_extensions_string;
	Read_WGL_EXT_make_current_read;
	Read_WGL_EXT_pbuffer;
	Read_WGL_EXT_pixel_format;
	Read_WGL_EXT_swap_control;
	Read_WGL_I3D_digital_video_control;
	Read_WGL_I3D_gamma;
	Read_WGL_I3D_genlock;
	Read_WGL_I3D_image_buffer;
	Read_WGL_I3D_swap_frame_lock;
	Read_WGL_I3D_swap_frame_usage;
	Read_WGL_NV_vertex_array_range;
	Read_WGL_NV_present_video;
	Read_WGL_NV_video_output;
	Read_WGL_NV_swap_group;
	Read_WGL_NV_gpu_affinity;
	Read_WGL_NV_video_capture;
	Read_WGL_NV_copy_image;
	Read_WGL_NV_DX_interop;
	Read_WGL_OML_sync_control;
	Read_WGL_3DL_stereo_control;

	Read_WIN_draw_range_elements;
	Read_WIN_swap_hint;
	(* WGL Ends *)
END ReadExtensions;

(* utilities *)
(* Get string from address *)

(* Get string from address  *)
PROCEDURE GetStringFromAddr*(adr0: ADDRESS): Strings.String;
VAR s {UNTRACED}: POINTER {UNSAFE} TO ARRAY OF CHAR;
	str: Strings.String;
	size, pos: SIZE;
BEGIN

	s := adr0;
	pos := 0;
	IF adr0 # NIL THEN
		WHILE s[pos] # 0X DO
			INC(pos);
		END;
		size := pos + 1;
		NEW(str, size);
		pos := 0;
		WHILE s[pos] # 0X DO
			str[pos] := s[pos];
			INC(pos);
		END;

	ELSE NEW(str, 1);
	END;

	str[pos] := 0X;
	RETURN str;

END GetStringFromAddr;

(*
PROCEDURE GetStringFromAddr*(adr: ADDRESS): Strings.String;
VAR
	sadr, sadr1: ADDRESS;
	i, cnt: LONGINT;
	ch: CHAR;
	s: Strings.String;
BEGIN
	sadr := adr;

	(* find length *)
	cnt :=0;
	sadr1 := sadr;
	IF sadr1 # 0 THEN
		SYSTEM.GET(sadr1,ch);
		WHILE (ch # 0X) DO  INC(cnt); INC(sadr1); SYSTEM.GET(sadr1,ch); END;
	END;

	IF cnt = 0 THEN  (* empty string *)
		NEW(s,1); s[0]:=0X; RETURN s
	END;

	NEW(s, cnt+1);
	i:=0;
	sadr1 := sadr;
	SYSTEM.GET(sadr1,ch);
	WHILE (i< cnt) & (ch # 0X) DO
		s^[i] := ch; INC(i); INC(sadr1);
		SYSTEM.GET(sadr1,ch);
	END;
	RETURN s;
END GetStringFromAddr;
*)

(* wrapper procedures  *)
PROCEDURE GetString*(name: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := XglGetString(name);
	RETURN GetStringFromAddr(sadr);
END GetString;

PROCEDURE GetStringi*(name: Enum; index: Int): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := XglGetStringi(name, index);
	RETURN GetStringFromAddr(sadr);
END GetStringi;

PROCEDURE wglEXTStrings*(): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := wglGetExtensionsStringEXT();
	RETURN GetStringFromAddr(sadr);
END wglEXTStrings;

PROCEDURE wglARBStrings*(): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := wglGetExtensionsStringARB(wglGetCurrentDC());
	RETURN GetStringFromAddr(sadr);
END wglARBStrings;

PROCEDURE ReadCoreVersion*;
VAR
	Buffer: Strings.String;
	MajorVersion, MinorVersion: LONGINT;

	PROCEDURE isNumber(ch: CHAR): BOOLEAN;
	VAR
	      val: LONGINT;
	      res: BOOLEAN;
	BEGIN
		res := FALSE;
		val := ORD(ch);
		IF (val >= ORD("0")) & (val<=ORD("9")) THEN res := TRUE; END;
		RETURN res;
	END isNumber;


	PROCEDURE TrimAndSplitVersionString(CONST buffer: ARRAY OF CHAR; VAR Max, Min: LONGINT);
	VAR separator,i : LONGINT;
	BEGIN
		i := 0;
		separator := Strings.Pos('.', buffer);
		(* At least one number must be before and one after the dot.  *)
		IF (separator > 0) & (separator < Strings.Length(buffer)) & ((isNumber(buffer[separator - 1])) &
			isNumber(buffer[separator + 1])) THEN
			Min := ORD(buffer[separator + 1]) - ORD("0");
			Max := ORD(buffer[separator - 1]) - ORD("0");
		ELSE
			Max := 1;
			Min := 0;
		END;
	END TrimAndSplitVersionString;

BEGIN
	(* determine version of implementation *)
	IF XglGetString = NIL THEN
		Kernel32.GetProcAddress(libHandle,  "glGetString", SYSTEM.VAL(ADDRESS, XglGetString));
	END;
	Buffer := GetString(GLC.GL_VERSION );
	TrimAndSplitVersionString(Buffer^, MajorVersion, MinorVersion);

	GL_VERSION_1_0 := TRUE;
	IF MajorVersion = 1 THEN
		IF MinorVersion >= 1 THEN GL_VERSION_1_1 := TRUE; END;
		IF MinorVersion >= 2 THEN GL_VERSION_1_2 := TRUE; END;
		IF MinorVersion >= 3 THEN GL_VERSION_1_3 := TRUE; END;
		IF MinorVersion >= 4 THEN GL_VERSION_1_4 := TRUE; END;
		IF MinorVersion >= 5 THEN GL_VERSION_1_5 := TRUE; END;
	END;

	IF MajorVersion >= 2 THEN
		GL_VERSION_1_1 := TRUE;
		GL_VERSION_1_2 := TRUE;
		GL_VERSION_1_3 := TRUE;
		GL_VERSION_1_4 := TRUE;
		GL_VERSION_1_5 := TRUE;
		GL_VERSION_2_0 := TRUE;
		IF MinorVersion >= 1 THEN GL_VERSION_2_1 := TRUE; END;
	END;

	IF MajorVersion >= 3 THEN
		GL_VERSION_2_1 := TRUE;
		GL_VERSION_3_0 := TRUE;
		IF MinorVersion >= 1 THEN GL_VERSION_3_1 := TRUE; END;
		IF MinorVersion >= 2 THEN GL_VERSION_3_2 := TRUE; END;
		IF MinorVersion >= 3 THEN GL_VERSION_3_3 := TRUE; END;
	END;

	IF MajorVersion >= 4 THEN
		GL_VERSION_3_1 := TRUE;
		GL_VERSION_3_2 := TRUE;
		GL_VERSION_3_3 := TRUE;
		GL_VERSION_4_0 := TRUE;
		IF MinorVersion >= 1 THEN GL_VERSION_4_1 := TRUE; END;
		IF MinorVersion >= 2 THEN GL_VERSION_4_2 := TRUE; END;
		IF MinorVersion >= 3 THEN GL_VERSION_4_3 := TRUE; END;
		IF MinorVersion >= 4 THEN GL_VERSION_4_4 := TRUE; END;
		IF MinorVersion >= 5 THEN GL_VERSION_4_5 := TRUE; END;
	END;
END ReadCoreVersion;

PROCEDURE Int_GetExtensionString(): Strings.String;
VAR
	buffer0, buffer1, buffer2, es: Strings.String;
	len0, len1: LONGINT;
	i: LONGINT;
	extensionCount : LONGINT;
	strarray: Strings.StringArray;
BEGIN
	IF GL_VERSION_3_0 THEN
		IF GetIntegerv = NIL THEN GetProcAddress("glGetIntegerv", ADDRESSOF(GetIntegerv)); END;
		IF XglGetStringi = NIL THEN GetProcAddress("glGetStringi", ADDRESSOF(XglGetStringi)); END;
		IF (GetIntegerv # NIL) & (XglGetStringi # NIL) THEN
			GetIntegerv(GLC.GL_NUM_EXTENSIONS, ADDRESSOF(extensionCount));
			NEW(strarray, extensionCount);
			(*KernelLog.String("Extension Count: "); KernelLog.Int(extensionCount, 0); KernelLog.Ln;*)
			FOR i:=0 TO extensionCount-1 DO
				es := GetStringi(GLC.GL_EXTENSIONS, i);
				strarray[i] := es;
			END;
			buffer0 := Strings.Join(strarray, 0, extensionCount-1, " ");

		END;
	ELSE
		(* general extension string  *)
		IF XglGetString = NIL THEN GetProcAddress ("glGetString", ADDRESSOF( XglGetString)); END;

		IF XglGetString # NIL THEN buffer0 := GetString(GLC.GL_EXTENSIONS); END;
	END;

	len0 := Strings.Length(buffer0^);

	IF (libHandle # 0 ) THEN
		IF wglGetExtensionsStringARB = NIL THEN
			GetProcAddress('wglGetExtensionsStringARB' , ADDRESSOF(wglGetExtensionsStringARB));
		END;

		IF wglGetExtensionsStringARB # NIL THEN
			buffer1 :=  wglARBStrings();
			len1 := Strings.Length(buffer1^);
		END;
	END;

	NEW(buffer2, len0 + len1 + 6);
	Strings.Append(buffer2^, " ");
	Strings.Append(buffer2^, buffer0^); Strings.Append(buffer2^, " ");
	Strings.Append(buffer2^, buffer1^); Strings.Append(buffer2^, " ");
	RETURN buffer2;
END Int_GetExtensionString;

PROCEDURE Int_CheckExtension( allextensions: Strings.String; CONST thisextension: ARRAY OF CHAR): BOOLEAN;
VAR pos: LONGINT;
BEGIN
	pos := Strings.Pos(thisextension, allextensions^);
	IF debug & (pos = -1) THEN
		KernelLog.String(thisextension); KernelLog.String(": NOT AVAILABLE"); KernelLog.Ln;
	END;
	RETURN pos #-1;
END Int_CheckExtension;

PROCEDURE CheckExtension*(CONST extension: ARRAY OF CHAR): BOOLEAN;
VAR allextensions: Strings.String;
BEGIN
	allextensions := Int_GetExtensionString();
	RETURN Int_CheckExtension(allextensions, extension);
END CheckExtension;

PROCEDURE  ReadImplementationProperties*;
VAR
  Buffer: Strings.String;

BEGIN
	ReadCoreVersion;

	(* Check all extensions *)
	Buffer := Int_GetExtensionString();

	(* 3DFX *)
	GL_3DFX_multisample := Int_CheckExtension(Buffer, 'GL_3DFX_multisample');
	GL_3DFX_tbuffer := Int_CheckExtension(Buffer, 'GL_3DFX_tbuffer');
	GL_3DFX_texture_compression_FXT1 := Int_CheckExtension(Buffer, 'GL_3DFX_texture_compression_FXT1');

	(* APPLE *)
	GL_APPLE_client_storage := Int_CheckExtension(Buffer, 'GL_APPLE_client_storage');
	GL_APPLE_element_array := Int_CheckExtension(Buffer, 'GL_APPLE_element_array');
	GL_APPLE_fence := Int_CheckExtension(Buffer, 'GL_APPLE_fence');
	GL_APPLE_specular_vector := Int_CheckExtension(Buffer, 'GL_APPLE_specular_vector');
	GL_APPLE_transform_hint := Int_CheckExtension(Buffer, 'GL_APPLE_transform_hint');
	GL_APPLE_vertex_array_object := Int_CheckExtension(Buffer, 'GL_APPLE_vertex_array_object');
	GL_APPLE_vertex_array_range := Int_CheckExtension(Buffer, 'GL_APPLE_vertex_array_range');
	GL_APPLE_ycbcr_422 := Int_CheckExtension(Buffer, 'GL_APPLE_ycbcr_422');
	GL_APPLE_texture_range := Int_CheckExtension(Buffer, 'GL_APPLE_texture_range');
	GL_APPLE_float_pixels := Int_CheckExtension(Buffer, 'GL_APPLE_float_pixels');
	GL_APPLE_vertex_program_evaluators := Int_CheckExtension(Buffer, 'GL_APPLE_vertex_program_evaluators');
	GL_APPLE_aux_depth_stencil := Int_CheckExtension(Buffer, 'GL_APPLE_aux_depth_stencil');
	GL_APPLE_object_purgeable := Int_CheckExtension(Buffer, 'GL_APPLE_object_purgeable');
	GL_APPLE_row_bytes := Int_CheckExtension(Buffer, 'GL_APPLE_row_bytes');
	GL_APPLE_rgb_422 := Int_CheckExtension(Buffer, 'GL_APPLE_rgb_422');

	(* ARB *)
	GL_ARB_depth_texture := Int_CheckExtension(Buffer, 'GL_ARB_depth_texture');
	GL_ARB_fragment_program := Int_CheckExtension(Buffer, 'GL_ARB_fragment_program');
	GL_ARB_imaging := Int_CheckExtension(Buffer, 'GL_ARB_imaging');
	GL_ARB_matrix_palette := Int_CheckExtension(Buffer, 'GL_ARB_matrix_palette');
	GL_ARB_multisample := Int_CheckExtension(Buffer, 'GL_ARB_multisample');
	GL_ARB_multitexture := Int_CheckExtension(Buffer, 'GL_ARB_multitexture');
	GL_ARB_point_parameters := Int_CheckExtension(Buffer, 'GL_ARB_point_parameters');
	GL_ARB_shadow := Int_CheckExtension(Buffer, 'GL_ARB_shadow');
	GL_ARB_shadow_ambient := Int_CheckExtension(Buffer, 'GL_ARB_shadow_ambient');
	GL_ARB_sparse_texture := Int_CheckExtension(Buffer, 'GL_ARB_sparse_texture');
	GL_ARB_sparse_texture2 := Int_CheckExtension(Buffer, 'GL_ARB_sparse_texture2');
	GL_ARB_sparse_texture_clamp := Int_CheckExtension(Buffer, 'GL_ARB_sparse_texture_clamp');
	GL_ARB_texture_border_clamp := Int_CheckExtension(Buffer, 'GL_ARB_texture_border_clamp');
	GL_ARB_texture_compression := Int_CheckExtension(Buffer, 'GL_ARB_texture_compression');
	GL_ARB_texture_cube_map := Int_CheckExtension(Buffer, 'GL_ARB_texture_cube_map');
	GL_ARB_texture_env_add := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_add');
	GL_ARB_texture_env_combine := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_combine');
	GL_ARB_texture_env_crossbar := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_crossbar');
	GL_ARB_texture_env_dot3 := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_dot3');
	GL_ARB_texture_filter_minmax := Int_CheckExtension(Buffer, 'GL_ARB_texture_filter_minmax');
	GL_ARB_texture_mirrored_repeat := Int_CheckExtension(Buffer, 'GL_ARB_texture_mirrored_repeat');
	GL_ARB_transpose_matrix := Int_CheckExtension(Buffer, 'GL_ARB_transpose_matrix');
	GL_ARB_vertex_blend := Int_CheckExtension(Buffer, 'GL_ARB_vertex_blend');
	GL_ARB_vertex_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_vertex_buffer_object');
	GL_ARB_vertex_program := Int_CheckExtension(Buffer, 'GL_ARB_vertex_program');
	GL_ARB_window_pos := Int_CheckExtension(Buffer, 'GL_ARB_window_pos');
	GL_ARB_shader_objects := Int_CheckExtension(Buffer, 'GL_ARB_shader_objects');
	GL_ARB_vertex_shader := Int_CheckExtension(Buffer, 'GL_ARB_vertex_shader');
	GL_ARB_fragment_shader := Int_CheckExtension(Buffer, 'GL_ARB_fragment_shader');
	GL_ARB_fragment_shader_interlock := Int_CheckExtension(Buffer, 'GL_ARB_fragment_shader_interlock');
	GL_ARB_occlusion_query := Int_CheckExtension(Buffer, 'GL_ARB_occlusion_query');
	GL_ARB_shading_language_100 := Int_CheckExtension(Buffer, 'GL_ARB_shading_language_100');
	GL_ARB_point_sprite := Int_CheckExtension(Buffer, 'GL_ARB_point_sprite');
	GL_ARB_texture_non_power_of_two := Int_CheckExtension(Buffer, 'GL_ARB_texture_non_power_of_two');
	GL_ARB_fragment_program_shadow := Int_CheckExtension(Buffer, 'GL_ARB_fragment_program_shadow');
	GL_ARB_draw_buffers := Int_CheckExtension(Buffer, 'GL_ARB_draw_buffers');
	GL_ARB_texture_rectangle := Int_CheckExtension(Buffer, 'GL_ARB_texture_rectangle');
	GL_ARB_color_buffer_float := Int_CheckExtension(Buffer, 'GL_ARB_color_buffer_float');
	GL_ARB_half_float_pixel := Int_CheckExtension(Buffer, 'GL_ARB_half_float_pixel');
	GL_ARB_texture_float := Int_CheckExtension(Buffer, 'GL_ARB_texture_float');
	GL_ARB_pixel_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_pixel_buffer_object');
	GL_ARB_depth_buffer_float := Int_CheckExtension(Buffer, 'GL_ARB_depth_buffer_float');
	GL_ARB_draw_instanced := Int_CheckExtension(Buffer, 'GL_ARB_draw_instanced');
	GL_ARB_framebuffer_object := Int_CheckExtension(Buffer, 'GL_ARB_framebuffer_object');
	GL_ARB_framebuffer_sRGB := Int_CheckExtension(Buffer, 'GL_ARB_framebuffer_sRGB');
	GL_ARB_geometry_shader4 := Int_CheckExtension(Buffer, 'GL_ARB_geometry_shader4');
	GL_ARB_half_float_vertex := Int_CheckExtension(Buffer, 'GL_ARB_half_float_vertex');
	GL_ARB_instanced_arrays := Int_CheckExtension(Buffer, 'GL_ARB_instanced_arrays');
	GL_ARB_map_buffer_range := Int_CheckExtension(Buffer, 'GL_ARB_map_buffer_range');
	GL_ARB_texture_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_texture_buffer_object');
	GL_ARB_texture_compression_rgtc := Int_CheckExtension(Buffer, 'GL_ARB_texture_compression_rgtc');
	GL_ARB_texture_rg := Int_CheckExtension(Buffer, 'GL_ARB_texture_rg');
	GL_ARB_vertex_array_object := Int_CheckExtension(Buffer, 'GL_ARB_vertex_array_object');
	GL_ARB_uniform_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_uniform_buffer_object');
	GL_ARB_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_compatibility');
	GL_ARB_copy_buffer := Int_CheckExtension(Buffer, 'GL_ARB_copy_buffer');
	GL_ARB_shader_texture_lod := Int_CheckExtension(Buffer, 'GL_ARB_shader_texture_lod');
	GL_ARB_shader_viewport_layer_array := Int_CheckExtension(Buffer, 'GL_ARB_shader_viewport_layer_array');
	GL_ARB_depth_clamp := Int_CheckExtension(Buffer, 'GL_ARB_depth_clamp');
	GL_ARB_draw_elements_base_vertex := Int_CheckExtension(Buffer, 'GL_ARB_draw_elements_base_vertex');
	GL_ARB_fragment_coord_conventions := Int_CheckExtension(Buffer, 'GL_ARB_fragment_coord_conventions');
	GL_ARB_provoking_vertex := Int_CheckExtension(Buffer, 'GL_ARB_provoking_vertex');
	GL_ARB_seamless_cube_map := Int_CheckExtension(Buffer, 'GL_ARB_seamless_cube_map');
	GL_ARB_sync := Int_CheckExtension(Buffer, 'GL_ARB_sync');
	GL_ARB_texture_multisample := Int_CheckExtension(Buffer, 'GL_ARB_texture_multisample');
	GL_ARB_vertex_array_bgra := Int_CheckExtension(Buffer, 'GL_ARB_vertex_array_bgra');
	GL_ARB_draw_buffers_blend := Int_CheckExtension(Buffer, 'GL_ARB_draw_buffers_blend');
	GL_ARB_sample_shading := Int_CheckExtension(Buffer, 'GL_ARB_sample_shading');
	GL_ARB_texture_cube_map_array := Int_CheckExtension(Buffer, 'GL_ARB_texture_cube_map_array');
	GL_ARB_texture_gather := Int_CheckExtension(Buffer, 'GL_ARB_texture_gather');
	GL_ARB_texture_query_lod := Int_CheckExtension(Buffer, 'GL_ARB_texture_query_lod');
	GL_ARB_shading_language_include := Int_CheckExtension(Buffer, 'GL_ARB_shading_language_include');
	GL_ARB_texture_compression_bptc := Int_CheckExtension(Buffer, 'GL_ARB_texture_compression_bptc');
	GL_ARB_blend_func_extended := Int_CheckExtension(Buffer, 'GL_ARB_blend_func_extended');
	GL_ARB_explicit_attrib_location := Int_CheckExtension(Buffer, 'GL_ARB_explicit_attrib_location');
	GL_ARB_occlusion_query2 := Int_CheckExtension(Buffer, 'GL_ARB_occlusion_query2');
	GL_ARB_parallel_shader_compile := Int_CheckExtension(Buffer, 'GL_ARB_parallel_shader_compile');
	GL_ARB_post_depth_coverage := Int_CheckExtension(Buffer, 'GL_ARB_post_depth_coverage');
	GL_ARB_sampler_objects := Int_CheckExtension(Buffer, 'GL_ARB_sampler_objects');
	GL_ARB_shader_bit_encoding := Int_CheckExtension(Buffer, 'GL_ARB_shader_bit_encoding');
	GL_ARB_shader_clock := Int_CheckExtension(Buffer, 'GL_ARB_shader_clock');
	GL_ARB_texture_rgb10_a2ui := Int_CheckExtension(Buffer, 'GL_ARB_texture_rgb10_a2ui');
	GL_ARB_texture_swizzle := Int_CheckExtension(Buffer, 'GL_ARB_texture_swizzle');
	GL_ARB_timer_query := Int_CheckExtension(Buffer, 'GL_ARB_timer_query');
	GL_ARB_vertex_type_2_10_10_10_rev := Int_CheckExtension(Buffer, 'GL_ARB_vertex_type_2_10_10_10_rev');
	GL_ARB_draw_indirect := Int_CheckExtension(Buffer, 'GL_ARB_draw_indirect');
	GL_ARB_gpu_shader5 := Int_CheckExtension(Buffer, 'GL_ARB_gpu_shader5');
	GL_ARB_gpu_shader_fp64 := Int_CheckExtension(Buffer, 'GL_ARB_gpu_shader_fp64');
	GL_ARB_gpu_shader_int64 := Int_CheckExtension(Buffer, 'GL_ARB_gpu_shader_int64');
	GL_ARB_shader_subroutine := Int_CheckExtension(Buffer, 'GL_ARB_shader_subroutine');
	GL_ARB_tessellation_shader := Int_CheckExtension(Buffer, 'GL_ARB_tessellation_shader');
	GL_ARB_texture_buffer_object_rgb32 := Int_CheckExtension(Buffer, 'GL_ARB_texture_buffer_object_rgb32');
	GL_ARB_transform_feedback2 := Int_CheckExtension(Buffer, 'GL_ARB_transform_feedback2');
	GL_ARB_transform_feedback3 := Int_CheckExtension(Buffer, 'GL_ARB_transform_feedback3');
	GL_ARB_ES2_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_ES2_compatibility');
	GL_ARB_ES3_2_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_ES3_2_compatibility');
	GL_ARB_get_program_binary := Int_CheckExtension(Buffer, 'GL_ARB_get_program_binary');
	GL_ARB_separate_shader_objects := Int_CheckExtension(Buffer, 'GL_ARB_separate_shader_objects');
	GL_ARB_shader_atomic_counter_ops := Int_CheckExtension(Buffer, 'GL_ARB_shader_atomic_counter_ops');
	GL_ARB_shader_ballot := Int_CheckExtension(Buffer, 'GL_ARB_shader_ballot');
	GL_ARB_shader_precision := Int_CheckExtension(Buffer, 'GL_ARB_shader_precision');
	GL_ARB_vertex_attrib_64bit := Int_CheckExtension(Buffer, 'GL_ARB_vertex_attrib_64bit');
	GL_ARB_viewport_array := Int_CheckExtension(Buffer, 'GL_ARB_viewport_array');
	GL_ARB_compute_variable_group_size := Int_CheckExtension(Buffer, 'GL_ARB_compute_variable_group_size');

	(* GL 4.2 *)
	GL_ARB_base_instance := Int_CheckExtension(Buffer, 'GL_ARB_base_instance');
	GL_ARB_shading_language_420pack := Int_CheckExtension(Buffer, 'GL_ARB_shading_language_420pack');
	GL_ARB_transform_feedback_instanced := Int_CheckExtension(Buffer, 'GL_ARB_transform_feedback_instanced');
	GL_ARB_compressed_texture_pixel_storage := Int_CheckExtension(Buffer, 'GL_ARB_compressed_texture_pixel_storage');
	GL_ARB_conservative_depth := Int_CheckExtension(Buffer, 'GL_ARB_conservative_depth');
	GL_ARB_internalformat_query := Int_CheckExtension(Buffer, 'GL_ARB_internalformat_query');
	GL_ARB_map_buffer_alignment := Int_CheckExtension(Buffer, 'GL_ARB_map_buffer_alignment');
	GL_ARB_shader_atomic_counters := Int_CheckExtension(Buffer, 'GL_ARB_shader_atomic_counters');
	GL_ARB_shader_image_load_store := Int_CheckExtension(Buffer, 'GL_ARB_shader_image_load_store');
	GL_ARB_shading_language_packing := Int_CheckExtension(Buffer, 'GL_ARB_shading_language_packing');
	GL_ARB_texture_storage := Int_CheckExtension(Buffer, 'GL_ARB_texture_storage');

	(* GL 4.3 *)
	GL_ARB_arrays_of_arrays := Int_CheckExtension(Buffer, 'GL_ARB_arrays_of_arrays');
	GL_ARB_fragment_layer_viewport := Int_CheckExtension(Buffer, 'GL_ARB_fragment_layer_viewport');
	GL_ARB_shader_image_size := Int_CheckExtension(Buffer, 'GL_ARB_shader_image_size');
	GL_ARB_ES3_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_ES3_compatibility');
	GL_ARB_clear_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_clear_buffer_object');
	GL_ARB_compute_shader := Int_CheckExtension(Buffer, 'GL_ARB_compute_shader');
	GL_ARB_copy_image := Int_CheckExtension(Buffer, 'GL_ARB_copy_image');
	GL_KHR_debug := Int_CheckExtension(Buffer, 'GL_KHR_debug');
	GL_ARB_explicit_uniform_location := Int_CheckExtension(Buffer, 'GL_ARB_explicit_uniform_location');
	GL_ARB_framebuffer_no_attachments := Int_CheckExtension(Buffer, 'GL_ARB_framebuffer_no_attachments');
	GL_ARB_internalformat_query2 := Int_CheckExtension(Buffer, 'GL_ARB_internalformat_query2');
	GL_ARB_invalidate_subdata := Int_CheckExtension(Buffer, 'GL_ARB_invalidate_subdata');
	GL_ARB_multi_draw_indirect := Int_CheckExtension(Buffer, 'GL_ARB_multi_draw_indirect');
	GL_ARB_program_interface_query := Int_CheckExtension(Buffer, 'GL_ARB_program_interface_query');
	GL_ARB_robust_buffer_access_behavior := Int_CheckExtension(Buffer, 'GL_ARB_robust_buffer_access_behavior');
	GL_ARB_shader_storage_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_shader_storage_buffer_object');
	GL_ARB_stencil_texturing := Int_CheckExtension(Buffer, 'GL_ARB_stencil_texturing');
	GL_ARB_texture_buffer_range := Int_CheckExtension(Buffer, 'GL_ARB_texture_buffer_range');
	GL_ARB_texture_query_levels := Int_CheckExtension(Buffer, 'GL_ARB_texture_query_levels');
	GL_ARB_texture_storage_multisample := Int_CheckExtension(Buffer, 'GL_ARB_texture_storage_multisample');
	GL_ARB_texture_view := Int_CheckExtension(Buffer, 'GL_ARB_texture_view');
	GL_ARB_vertex_attrib_binding := Int_CheckExtension(Buffer, 'GL_ARB_vertex_attrib_binding');
	GL_ARB_cl_event := Int_CheckExtension(Buffer, 'GL_ARB_cl_event');
	GL_ARB_debug_output := Int_CheckExtension(Buffer, 'GL_ARB_debug_output');
	GL_ARB_robustness := Int_CheckExtension(Buffer, 'GL_ARB_robustness');
	GL_ARB_shader_stencil_export := Int_CheckExtension(Buffer, 'GL_ARB_shader_stencil_export');

	(* GL 4.4 *)
	GL_ARB_buffer_storage := Int_CheckExtension(Buffer, 'GL_ARB_buffer_storage');
	GL_ARB_clear_texture := Int_CheckExtension(Buffer, 'GL_ARB_clear_texture');
	GL_ARB_enhanced_layouts := Int_CheckExtension(Buffer, 'GL_ARB_enhanced_layouts');
	GL_ARB_multi_bind := Int_CheckExtension(Buffer, 'GL_ARB_multi_bind');
	GL_ARB_query_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_query_buffer_object');
	GL_ARB_texture_mirror_clamp_to_edge:= Int_CheckExtension(Buffer, 'GL_ARB_texture_mirror_clamp_to_edge');
	GL_ARB_texture_stencil8 := Int_CheckExtension(Buffer, 'GL_ARB_texture_stencil8');
	GL_ARB_vertex_type_10f_11f_11f_rev := Int_CheckExtension(Buffer, 'GL_ARB_vertex_type_10f_11f_11f_rev');
	GL_ARB_bindless_texture := Int_CheckExtension(Buffer, 'GL_ARB_bindless_texture');
	GL_ARB_sparse_texture	:= Int_CheckExtension(Buffer, 'GL_ARB_sparse_texture');

	(* GL 4.5 *)
	GL_ARB_clip_control := Int_CheckExtension(Buffer, 'GL_ARB_clip_control');
	GL_ARB_cull_distance := Int_CheckExtension(Buffer, 'GL_ARB_cull_distance');
	GL_ARB_ES3_1_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_ES3_1_compatibility');
	GL_ARB_conditional_render_inverted := Int_CheckExtension(Buffer, 'GL_ARB_conditional_render_inverted');
	GL_KHR_context_flush_control := Int_CheckExtension(Buffer, 'GL_KHR_context_flush_control');
	GL_ARB_derivative_control := Int_CheckExtension(Buffer, 'GL_ARB_derivative_control');
	GL_ARB_direct_state_access := Int_CheckExtension(Buffer, 'GL_ARB_direct_state_access');
	GL_ARB_get_texture_sub_image := Int_CheckExtension(Buffer, 'GL_ARB_get_texture_sub_image');
	GL_KHR_robustness := Int_CheckExtension(Buffer, 'GL_KHR_robustness');
	GL_ARB_shader_texture_image_samples := Int_CheckExtension(Buffer, 'GL_ARB_shader_texture_image_samples');
	GL_ARB_texture_barrier := Int_CheckExtension(Buffer, 'GL_ARB_texture_barrier');

	(* ATI/AMD *)
	GL_ATI_draw_buffers := Int_CheckExtension(Buffer, 'GL_ATI_draw_buffers');
	GL_ATI_element_array := Int_CheckExtension(Buffer, 'GL_ATI_element_array');
	GL_ATI_envmap_bumpmap := Int_CheckExtension(Buffer, 'GL_ATI_envmap_bumpmap');
	GL_ATI_fragment_shader := Int_CheckExtension(Buffer, 'GL_ATI_fragment_shader');
	GL_ATI_map_object_buffer := Int_CheckExtension(Buffer, 'GL_ATI_map_object_buffer');
	GL_ATI_pn_triangles := Int_CheckExtension(Buffer, 'GL_ATI_pn_triangles');
	GL_ATI_separate_stencil := Int_CheckExtension(Buffer, 'GL_ATI_separate_stencil');
	GL_ATI_text_fragment_shader := Int_CheckExtension(Buffer, 'GL_ATI_text_fragment_shader');
	GL_ATI_texture_env_combine3 := Int_CheckExtension(Buffer, 'GL_ATI_texture_env_combine3');
	GL_ATI_texture_float := Int_CheckExtension(Buffer, 'GL_ATI_texture_float');
	GL_ATI_texture_mirror_once := Int_CheckExtension(Buffer, 'GL_ATI_texture_mirror_once');
	GL_ATI_vertex_array_object := Int_CheckExtension(Buffer, 'GL_ATI_vertex_array_object');
	GL_ATI_vertex_attrib_array_object := Int_CheckExtension(Buffer, 'GL_ATI_vertex_attrib_array_object');
	GL_ATI_vertex_streams := Int_CheckExtension(Buffer, 'GL_ATI_vertex_streams');
	GL_ATI_meminfo := Int_CheckExtension(Buffer, 'GL_ATI_meminfo');
	GL_AMD_performance_monitor := Int_CheckExtension(Buffer, 'GL_AMD_performance_monitor');
	GL_AMD_texture_texture4 := Int_CheckExtension(Buffer, 'GL_AMD_texture_texture4');
	GL_AMD_vertex_shader_tesselator := Int_CheckExtension(Buffer, 'GL_AMD_vertex_shader_tesselator');
	GL_AMD_draw_buffers_blend := Int_CheckExtension(Buffer, 'GL_AMD_draw_buffers_blend');
	GL_AMD_shader_stencil_export := Int_CheckExtension(Buffer, 'GL_AMD_shader_stencil_export');
	GL_AMD_seamless_cubemap_per_texture := Int_CheckExtension(Buffer, 'GL_AMD_seamless_cubemap_per_texture');
	GL_AMD_conservative_depth := Int_CheckExtension(Buffer, 'GL_AMD_conservative_depth');
	GL_AMD_name_gen_delete := Int_CheckExtension(Buffer, 'GL_AMD_name_gen_delete');
	GL_AMD_debug_output := Int_CheckExtension(Buffer, 'GL_AMD_debug_output');
	GL_AMD_transform_feedback3_lines_triangles := Int_CheckExtension(Buffer, 'GL_AMD_transform_feedback3_lines_triangles');
	GL_AMD_depth_clamp_separate := Int_CheckExtension(Buffer, 'GL_AMD_depth_clamp_separate');
	(* 4.3 *)
	GL_AMD_pinned_memory := Int_CheckExtension(Buffer, 'GL_AMD_pinned_memory');
	GL_AMD_stencil_operation_extended := Int_CheckExtension(Buffer, 'GL_AMD_stencil_operation_extended');
	GL_AMD_vertex_shader_viewport_index := Int_CheckExtension(Buffer, 'GL_AMD_vertex_shader_viewport_index');
	GL_AMD_vertex_shader_layer := Int_CheckExtension(Buffer, 'GL_AMD_vertex_shader_layer');
	GL_AMD_query_buffer_object := Int_CheckExtension(Buffer, 'GL_AMD_query_buffer_object');

	(* EXT *)
	GL_EXT_422_pixels := Int_CheckExtension(Buffer, 'GL_EXT_422_pixels');
	GL_EXT_abgr := Int_CheckExtension(Buffer, 'GL_EXT_abgr');
	GL_EXT_bgra := Int_CheckExtension(Buffer, 'GL_EXT_bgra');
	GL_EXT_blend_color := Int_CheckExtension(Buffer, 'GL_EXT_blend_color');
	GL_EXT_blend_func_separate := Int_CheckExtension(Buffer, 'GL_EXT_blend_func_separate');
	GL_EXT_blend_logic_op := Int_CheckExtension(Buffer, 'GL_EXT_blend_logic_op');
	GL_EXT_blend_minmax := Int_CheckExtension(Buffer, 'GL_EXT_blend_minmax');
	GL_EXT_blend_subtract := Int_CheckExtension(Buffer, 'GL_EXT_blend_subtract');
	GL_EXT_clip_volume_hint := Int_CheckExtension(Buffer, 'GL_EXT_clip_volume_hint');
	GL_EXT_cmyka := Int_CheckExtension(Buffer, 'GL_EXT_cmyka');
	GL_EXT_color_matrix := Int_CheckExtension(Buffer, 'GL_EXT_color_matrix');
	GL_EXT_color_subtable := Int_CheckExtension(Buffer, 'GL_EXT_color_subtable');
	GL_EXT_compiled_vertex_array := Int_CheckExtension(Buffer, 'GL_EXT_compiled_vertex_array');
	GL_EXT_convolution := Int_CheckExtension(Buffer, 'GL_EXT_convolution');
	GL_EXT_coordinate_frame := Int_CheckExtension(Buffer, 'GL_EXT_coordinate_frame');
	GL_EXT_copy_texture := Int_CheckExtension(Buffer, 'GL_EXT_copy_texture');
	GL_EXT_cull_vertex := Int_CheckExtension(Buffer, 'GL_EXT_cull_vertex');
	GL_EXT_draw_range_elements := Int_CheckExtension(Buffer, 'GL_EXT_draw_range_elements');
	GL_EXT_fog_coord := Int_CheckExtension(Buffer, 'GL_EXT_fog_coord');
	GL_EXT_framebuffer_object := Int_CheckExtension(Buffer, 'GL_EXT_framebuffer_object');
	GL_EXT_histogram := Int_CheckExtension(Buffer, 'GL_EXT_histogram');
	GL_EXT_index_array_formats := Int_CheckExtension(Buffer, 'GL_EXT_index_array_formats');
	GL_EXT_index_func := Int_CheckExtension(Buffer, 'GL_EXT_index_func');
	GL_EXT_index_material := Int_CheckExtension(Buffer, 'GL_EXT_index_material');
	GL_EXT_index_texture := Int_CheckExtension(Buffer, 'GL_EXT_index_texture');
	GL_EXT_light_texture := Int_CheckExtension(Buffer, 'GL_EXT_light_texture');
	GL_EXT_misc_attribute := Int_CheckExtension(Buffer, 'GL_EXT_misc_attribute');
	GL_EXT_multi_draw_arrays := Int_CheckExtension(Buffer, 'GL_EXT_multi_draw_arrays');
	GL_EXT_multisample := Int_CheckExtension(Buffer, 'GL_EXT_multisample');
	GL_EXT_packed_pixels := Int_CheckExtension(Buffer, 'GL_EXT_packed_pixels');
	GL_EXT_paletted_texture := Int_CheckExtension(Buffer, 'GL_EXT_paletted_texture');
	GL_EXT_pixel_transform := Int_CheckExtension(Buffer, 'GL_EXT_pixel_transform');
	GL_EXT_pixel_transform_color_table := Int_CheckExtension(Buffer, 'GL_EXT_pixel_transform_color_table');
	GL_EXT_point_parameters := Int_CheckExtension(Buffer, 'GL_EXT_point_parameters');
	GL_EXT_polygon_offset := Int_CheckExtension(Buffer, 'GL_EXT_polygon_offset');
	GL_EXT_rescale_normal := Int_CheckExtension(Buffer, 'GL_EXT_rescale_normal');
	GL_EXT_secondary_color := Int_CheckExtension(Buffer, 'GL_EXT_secondary_color');
	GL_EXT_separate_specular_color := Int_CheckExtension(Buffer, 'GL_EXT_separate_specular_color');
	GL_EXT_shadow_funcs := Int_CheckExtension(Buffer, 'GL_EXT_shadow_funcs');
	GL_EXT_shared_texture_palette := Int_CheckExtension(Buffer, 'GL_EXT_shared_texture_palette');
	GL_EXT_stencil_two_side := Int_CheckExtension(Buffer, 'GL_EXT_stencil_two_side');
	GL_EXT_stencil_wrap := Int_CheckExtension(Buffer, 'GL_EXT_stencil_wrap');
	GL_EXT_subtexture := Int_CheckExtension(Buffer, 'GL_EXT_subtexture');
	GL_EXT_texture := Int_CheckExtension(Buffer, 'GL_EXT_texture');
	GL_EXT_texture3D := Int_CheckExtension(Buffer, 'GL_EXT_texture3D');
	GL_EXT_texture_compression_s3tc := Int_CheckExtension(Buffer, 'GL_EXT_texture_compression_s3tc');
	GL_EXT_texture_cube_map := Int_CheckExtension(Buffer, 'GL_EXT_texture_cube_map');
	GL_EXT_texture_edge_clamp := Int_CheckExtension(Buffer, 'GL_EXT_texture_edge_clamp');
	GL_EXT_texture_env_add := Int_CheckExtension(Buffer, 'GL_EXT_texture_env_add');
	GL_EXT_texture_env_combine := Int_CheckExtension(Buffer, 'GL_EXT_texture_env_combine');
	GL_EXT_texture_env_dot3 := Int_CheckExtension(Buffer, 'GL_EXT_texture_env_dot3');
	GL_EXT_texture_filter_anisotropic := Int_CheckExtension(Buffer, 'GL_EXT_texture_filter_anisotropic');
	GL_EXT_texture_lod_bias := Int_CheckExtension(Buffer, 'GL_EXT_texture_lod_bias');
	GL_EXT_texture_object := Int_CheckExtension(Buffer, 'GL_EXT_texture_object');
	GL_EXT_texture_perturb_normal := Int_CheckExtension(Buffer, 'GL_EXT_texture_perturb_normal');
	GL_EXT_texture_rectangle := Int_CheckExtension(Buffer, 'GL_EXT_texture_rectangle');
	GL_EXT_vertex_array := Int_CheckExtension(Buffer, 'GL_EXT_vertex_array');
	GL_EXT_vertex_shader := Int_CheckExtension(Buffer, 'GL_EXT_vertex_shader');
	GL_EXT_vertex_weighting := Int_CheckExtension(Buffer, 'GL_EXT_vertex_weighting');
	GL_EXT_depth_bounds_test := Int_CheckExtension(Buffer, 'GL_EXT_depth_bounds_test');
	GL_EXT_texture_mirror_clamp := Int_CheckExtension(Buffer, 'GL_EXT_texture_mirror_clamp');
	GL_EXT_blend_equation_separate := Int_CheckExtension(Buffer, 'GL_EXT_blend_equation_separate');
	GL_EXT_pixel_buffer_object := Int_CheckExtension(Buffer, 'GL_EXT_pixel_buffer_object');
	GL_EXT_texture_compression_dxt1 := Int_CheckExtension(Buffer, 'GL_EXT_texture_compression_dxt1');
	GL_EXT_stencil_clear_tag := Int_CheckExtension(Buffer, 'GL_EXT_stencil_clear_tag');
	GL_EXT_packed_depth_stencil := Int_CheckExtension(Buffer, 'GL_EXT_packed_depth_stencil');
	GL_EXT_texture_sRGB := Int_CheckExtension(Buffer, 'GL_EXT_texture_sRGB');
	GL_EXT_framebuffer_blit := Int_CheckExtension(Buffer, 'GL_EXT_framebuffer_blit');
	GL_EXT_framebuffer_multisample := Int_CheckExtension(Buffer, 'GL_EXT_framebuffer_multisample');
	GL_EXT_timer_query := Int_CheckExtension(Buffer, 'GL_EXT_timer_query');
	GL_EXT_gpu_program_parameters := Int_CheckExtension(Buffer, 'GL_EXT_gpu_program_parameters');
	GL_EXT_bindable_uniform := Int_CheckExtension(Buffer, 'GL_EXT_bindable_uniform');
	GL_EXT_draw_buffers2 := Int_CheckExtension(Buffer, 'GL_EXT_draw_buffers2');
	GL_EXT_draw_instanced := Int_CheckExtension(Buffer, 'GL_EXT_draw_instanced');
	GL_EXT_framebuffer_sRGB := Int_CheckExtension(Buffer, 'GL_EXT_framebuffer_sRGB');
	GL_EXT_geometry_shader4 := Int_CheckExtension(Buffer, 'GL_EXT_geometry_shader4');
	GL_EXT_gpu_shader4 := Int_CheckExtension(Buffer, 'GL_EXT_gpu_shader4');
	GL_EXT_packed_float := Int_CheckExtension(Buffer, 'GL_EXT_packed_float');
	GL_EXT_texture_array := Int_CheckExtension(Buffer, 'GL_EXT_texture_array');
	GL_EXT_texture_buffer_object := Int_CheckExtension(Buffer, 'GL_EXT_texture_buffer_object');
	GL_EXT_texture_compression_latc := Int_CheckExtension(Buffer, 'GL_EXT_texture_compression_latc');
	GL_EXT_texture_compression_rgtc := Int_CheckExtension(Buffer, 'GL_EXT_texture_compression_rgtc');
	GL_EXT_texture_integer := Int_CheckExtension(Buffer, 'GL_EXT_texture_integer');
	GL_EXT_texture_shared_exponent := Int_CheckExtension(Buffer, 'GL_EXT_texture_shared_exponent');
	GL_EXT_transform_feedback := Int_CheckExtension(Buffer, 'GL_EXT_transform_feedback');
	GL_EXT_direct_state_access := Int_CheckExtension(Buffer, 'GL_EXT_direct_state_access');
	GL_EXT_vertex_array_bgra := Int_CheckExtension(Buffer, 'GL_EXT_vertex_array_bgra');
	GL_EXT_texture_swizzle := Int_CheckExtension(Buffer, 'GL_EXT_texture_swizzle');
	GL_EXT_provoking_vertex := Int_CheckExtension(Buffer, 'GL_EXT_provoking_vertex');
	GL_EXT_texture_snorm := Int_CheckExtension(Buffer, 'GL_EXT_texture_snorm');
	GL_EXT_separate_shader_objects := Int_CheckExtension(Buffer, 'GL_EXT_separate_shader_objects');
	GL_EXT_shader_image_load_store := Int_CheckExtension(Buffer, 'GL_EXT_shader_image_load_store');
	GL_EXT_vertex_attrib_64bit := Int_CheckExtension(Buffer, 'GL_EXT_vertex_attrib_64bit');
	GL_EXT_texture_sRGB_decode := Int_CheckExtension(Buffer, 'GL_EXT_texture_sRGB_decode');

	(* HP *)
	GL_HP_convolution_border_modes := Int_CheckExtension(Buffer, 'GL_HP_convolution_border_modes');
	GL_HP_image_transform := Int_CheckExtension(Buffer, 'GL_HP_image_transform');
	GL_HP_occlusion_test := Int_CheckExtension(Buffer, 'GL_HP_occlusion_test');
	GL_HP_texture_lighting := Int_CheckExtension(Buffer, 'GL_HP_texture_lighting');

	(* IBM *)
	GL_IBM_cull_vertex := Int_CheckExtension(Buffer, 'GL_IBM_cull_vertex');
	GL_IBM_multimode_draw_arrays := Int_CheckExtension(Buffer, 'GL_IBM_multimode_draw_arrays');
	GL_IBM_rasterpos_clip := Int_CheckExtension(Buffer, 'GL_IBM_rasterpos_clip');
	GL_IBM_texture_mirrored_repeat := Int_CheckExtension(Buffer, 'GL_IBM_texture_mirrored_repeat');
	GL_IBM_vertex_array_lists := Int_CheckExtension(Buffer, 'GL_IBM_vertex_array_lists');

	(* INGR *)
	GL_INGR_blend_func_separate := Int_CheckExtension(Buffer, 'GL_INGR_blend_func_separate');
	GL_INGR_color_clamp := Int_CheckExtension(Buffer, 'GL_INGR_color_clamp');
	GL_INGR_interlace_read := Int_CheckExtension(Buffer, 'GL_INGR_interlace_read');
	GL_INGR_palette_buffer := Int_CheckExtension(Buffer, 'GL_INGR_palette_buffer');

	(* INTEL *)
	GL_INTEL_framebuffer_CMAA := Int_CheckExtension(Buffer, 'GL_INTEL_framebuffer_CMAA');
	GL_INTEL_parallel_arrays := Int_CheckExtension(Buffer, 'GL_INTEL_parallel_arrays');
	GL_INTEL_texture_scissor := Int_CheckExtension(Buffer, 'GL_INTEL_texture_scissor');

	(* MESA *)
	GL_MESA_resize_buffers := Int_CheckExtension(Buffer, 'GL_MESA_resize_buffers');
	GL_MESA_window_pos := Int_CheckExtension(Buffer, 'GL_MESA_window_pos');

	(* Khronos *)
	(* 4.5 *)
	GL_KHR_blend_equation_advanced := Int_CheckExtension(Buffer, 'GL_KHR_blend_equation_advanced');
	GL_KHR_blend_equation_advanced_coherent := Int_CheckExtension(Buffer, 'GL_KHR_blend_equation_advanced_coherent');
	GL_KHR_no_error := Int_CheckExtension(Buffer, 'GL_KHR_no_error');
	GL_KHR_robustness := Int_CheckExtension(Buffer, 'GL_KHR_robustness');
	GL_KHR_robust_buffer_access_behavior := Int_CheckExtension(Buffer, 'GL_KHR_robust_buffer_access_behavior');

	(* NVIDIA *)
	GL_NV_blend_square := Int_CheckExtension(Buffer, 'GL_NV_blend_square');
	GL_NV_copy_depth_to_color := Int_CheckExtension(Buffer, 'GL_NV_copy_depth_to_color');
	GL_NV_depth_clamp := Int_CheckExtension(Buffer, 'GL_NV_depth_clamp');
	GL_NV_evaluators := Int_CheckExtension(Buffer, 'GL_NV_evaluators');
	GL_NV_fence := Int_CheckExtension(Buffer, 'GL_NV_fence');
	GL_NV_float_buffer := Int_CheckExtension(Buffer, 'GL_NV_float_buffer');
	GL_NV_fog_distance := Int_CheckExtension(Buffer, 'GL_NV_fog_distance');
	GL_NV_fragment_program := Int_CheckExtension(Buffer, 'GL_NV_fragment_program');
	GL_NV_half_float := Int_CheckExtension(Buffer, 'GL_NV_half_float');
	GL_NV_light_max_exponent := Int_CheckExtension(Buffer, 'GL_NV_light_max_exponent');
	GL_NV_multisample_filter_hint := Int_CheckExtension(Buffer, 'GL_NV_multisample_filter_hint');
	GL_NV_occlusion_query := Int_CheckExtension(Buffer, 'GL_NV_occlusion_query');
	GL_NV_packed_depth_stencil := Int_CheckExtension(Buffer, 'GL_NV_packed_depth_stencil');
	GL_NV_pixel_data_range := Int_CheckExtension(Buffer, 'GL_NV_pixel_data_range');
	GL_NV_point_sprite := Int_CheckExtension(Buffer, 'GL_NV_point_sprite');
	GL_NV_primitive_restart := Int_CheckExtension(Buffer, 'GL_NV_primitive_restart');
	GL_NV_register_combiners := Int_CheckExtension(Buffer, 'GL_NV_register_combiners');
	GL_NV_register_combiners2 := Int_CheckExtension(Buffer, 'GL_NV_register_combiners2');
	GL_NV_texgen_emboss := Int_CheckExtension(Buffer, 'GL_NV_texgen_emboss');
	GL_NV_texgen_reflection := Int_CheckExtension(Buffer, 'GL_NV_texgen_reflection');
	GL_NV_texture_compression_vtc := Int_CheckExtension(Buffer, 'GL_NV_texture_compression_vtc');
	GL_NV_texture_env_combine4 := Int_CheckExtension(Buffer, 'GL_NV_texture_env_combine4');
	GL_NV_texture_expand_normal := Int_CheckExtension(Buffer, 'GL_NV_texture_expand_normal');
	GL_NV_texture_rectangle := Int_CheckExtension(Buffer, 'GL_NV_texture_rectangle');
	GL_NV_texture_shader := Int_CheckExtension(Buffer, 'GL_NV_texture_shader');
	GL_NV_texture_shader2 := Int_CheckExtension(Buffer, 'GL_NV_texture_shader2');
	GL_NV_texture_shader3 := Int_CheckExtension(Buffer, 'GL_NV_texture_shader3');
	GL_NV_vertex_array_range := Int_CheckExtension(Buffer, 'GL_NV_vertex_array_range');
	GL_NV_vertex_array_range2 := Int_CheckExtension(Buffer, 'GL_NV_vertex_array_range2');
	GL_NV_vertex_program := Int_CheckExtension(Buffer, 'GL_NV_vertex_program');
	GL_NV_vertex_program1_1 := Int_CheckExtension(Buffer, 'GL_NV_vertex_program1_1');
	GL_NV_vertex_program2 := Int_CheckExtension(Buffer, 'GL_NV_vertex_program2');
	GL_NV_fragment_program_option := Int_CheckExtension(Buffer, 'GL_NV_fragment_program_option');
	GL_NV_fragment_program2 := Int_CheckExtension(Buffer, 'GL_NV_fragment_program2');
	GL_NV_vertex_program2_option := Int_CheckExtension(Buffer, 'GL_NV_vertex_program2_option');
	GL_NV_vertex_program3 := Int_CheckExtension(Buffer, 'GL_NV_vertex_program3');
	GL_NV_depth_buffer_float := Int_CheckExtension(Buffer, 'GL_NV_depth_buffer_float');
	GL_NV_fragment_program4 := Int_CheckExtension(Buffer, 'GL_NV_fragment_program4');
	GL_NV_framebuffer_multisample_coverage := Int_CheckExtension(Buffer, 'GL_NV_framebuffer_multisample_coverage');
	GL_NV_geometry_program4 := Int_CheckExtension(Buffer, 'GL_NV_geometry_program4');
	GL_NV_gpu_program4 := Int_CheckExtension(Buffer, 'GL_NV_gpu_program4');
	GL_NV_parameter_buffer_object := Int_CheckExtension(Buffer, 'GL_NV_parameter_buffer_object');
	GL_NV_transform_feedback := Int_CheckExtension(Buffer, 'GL_NV_transform_feedback');
	GL_NV_vertex_program4 := Int_CheckExtension(Buffer, 'GL_NV_vertex_program4');
	GL_NV_conditional_render := Int_CheckExtension(Buffer, 'GL_NV_conditional_render');
	GL_NV_conservative_raster := Int_CheckExtension(Buffer, 'GL_NV_conservative_raster');
	GL_NV_conservative_raster_dilate := Int_CheckExtension(Buffer, 'GL_NV_conservative_raster_dilate');
	GL_NV_present_video := Int_CheckExtension(Buffer, 'GL_NV_present_video');
	GL_NV_explicit_multisample := Int_CheckExtension(Buffer, 'GL_NV_explicit_multisample');
	GL_NV_transform_feedback2 := Int_CheckExtension(Buffer, 'GL_NV_transform_feedback2');
	GL_NV_video_capture := Int_CheckExtension(Buffer, 'GL_NV_video_capture');
	GL_NV_copy_image := Int_CheckExtension(Buffer, 'GL_NV_copy_image');
	GL_NV_parameter_buffer_object2 := Int_CheckExtension(Buffer, 'GL_NV_parameter_buffer_object2');
	GL_NV_shader_buffer_load := Int_CheckExtension(Buffer, 'GL_NV_shader_buffer_load');
	GL_NV_vertex_buffer_unified_memory := Int_CheckExtension(Buffer, 'GL_NV_vertex_buffer_unified_memory');
	GL_NV_gpu_program5 := Int_CheckExtension(Buffer, 'GL_NV_gpu_program5');
	GL_NV_gpu_shader5 := Int_CheckExtension(Buffer, 'GL_NV_gpu_shader5');
	GL_NV_shader_buffer_store := Int_CheckExtension(Buffer, 'GL_NV_shader_buffer_store');
	GL_NV_tessellation_program5 := Int_CheckExtension(Buffer, 'GL_NV_tessellation_program5');
	GL_NV_vertex_attrib_integer_64bit := Int_CheckExtension(Buffer, 'GL_NV_vertex_attrib_integer_64bit');
	GL_NV_multisample_coverage := Int_CheckExtension(Buffer, 'GL_NV_multisample_coverage');
	GL_NV_vdpau_interop := Int_CheckExtension(Buffer, 'GL_NV_vdpau_interop');
	GL_NV_texture_barrier := Int_CheckExtension(Buffer, 'GL_NV_texture_barrier');
	(* 4.3 *)
	GL_NV_path_rendering := Int_CheckExtension(Buffer, 'GL_NV_path_rendering');
	GL_NV_bindless_texture := Int_CheckExtension(Buffer, 'GL_NV_bindless_texture');
	GL_NV_shader_atomic_float := Int_CheckExtension(Buffer, 'GL_NV_shader_atomic_float');

	(* OML *)
	GL_OML_interlace := Int_CheckExtension(Buffer, 'GL_OML_interlace');
	GL_OML_resample := Int_CheckExtension(Buffer, 'GL_OML_resample');
	GL_OML_subsample := Int_CheckExtension(Buffer, 'GL_OML_subsample');

	(* OVR *)
	GL_OVR_multiview := Int_CheckExtension(Buffer, 'GL_OVR_multiview');
	GL_OVR_multiview2 := Int_CheckExtension(Buffer, 'GL_OVR_multiview2');

	(* PGI *)
	GL_PGI_misc_hints := Int_CheckExtension(Buffer, 'GL_PGI_misc_hints');
	GL_PGI_vertex_hints := Int_CheckExtension(Buffer, 'GL_PGI_vertex_hints');

	(* REND *)
	GL_REND_screen_coordinates := Int_CheckExtension(Buffer, 'GL_REND_screen_coordinates');

	(* S3 *)
	GL_S3_s3tc := Int_CheckExtension(Buffer, 'GL_S3_s3tc');

	(* SGIS *)
	GL_SGIS_detail_texture := Int_CheckExtension(Buffer, 'GL_SGIS_detail_texture');
	GL_SGIS_fog_function := Int_CheckExtension(Buffer, 'GL_SGIS_fog_function');
	GL_SGIS_generate_mipmap := Int_CheckExtension(Buffer, 'GL_SGIS_generate_mipmap');
	GL_SGIS_multisample := Int_CheckExtension(Buffer, 'GL_SGIS_multisample');
	GL_SGIS_pixel_texture := Int_CheckExtension(Buffer, 'GL_SGIS_pixel_texture');
	GL_SGIS_point_line_texgen := Int_CheckExtension(Buffer, 'GL_SGIS_point_line_texgen');
	GL_SGIS_point_parameters := Int_CheckExtension(Buffer, 'GL_SGIS_point_parameters');
	GL_SGIS_sharpen_texture := Int_CheckExtension(Buffer, 'GL_SGIS_sharpen_texture');
	GL_SGIS_texture4D := Int_CheckExtension(Buffer, 'GL_SGIS_texture4D');
	GL_SGIS_texture_border_clamp := Int_CheckExtension(Buffer, 'GL_SGIS_texture_border_clamp');
	GL_SGIS_texture_color_mask := Int_CheckExtension(Buffer, 'GL_SGIS_texture_color_mask');
	GL_SGIS_texture_edge_clamp := Int_CheckExtension(Buffer, 'GL_SGIS_texture_edge_clamp');
	GL_SGIS_texture_filter4 := Int_CheckExtension(Buffer, 'GL_SGIS_texture_filter4');
	GL_SGIS_texture_lod := Int_CheckExtension(Buffer, 'GL_SGIS_texture_lod');
	GL_SGIS_texture_select := Int_CheckExtension(Buffer, 'GL_SGIS_texture_select');

	(* SGIX *)
	GL_FfdMaskSGIX := Int_CheckExtension(Buffer, 'GL_FfdMaskSGIX');
	GL_SGIX_async := Int_CheckExtension(Buffer, 'GL_SGIX_async');
	GL_SGIX_async_histogram := Int_CheckExtension(Buffer, 'GL_SGIX_async_histogram');
	GL_SGIX_async_pixel := Int_CheckExtension(Buffer, 'GL_SGIX_async_pixel');
	GL_SGIX_blend_alpha_minmax := Int_CheckExtension(Buffer, 'GL_SGIX_blend_alpha_minmax');
	GL_SGIX_calligraphic_fragment := Int_CheckExtension(Buffer, 'GL_SGIX_calligraphic_fragment');
	GL_SGIX_clipmap := Int_CheckExtension(Buffer, 'GL_SGIX_clipmap');
	GL_SGIX_convolution_accuracy := Int_CheckExtension(Buffer, 'GL_SGIX_convolution_accuracy');
	GL_SGIX_depth_pass_instrument := Int_CheckExtension(Buffer, 'GL_SGIX_depth_pass_instrument');
	GL_SGIX_depth_texture := Int_CheckExtension(Buffer, 'GL_SGIX_depth_texture');
	GL_SGIX_flush_raster := Int_CheckExtension(Buffer, 'GL_SGIX_flush_raster');
	GL_SGIX_fog_offset := Int_CheckExtension(Buffer, 'GL_SGIX_fog_offset');
	GL_SGIX_fog_scale := Int_CheckExtension(Buffer, 'GL_SGIX_fog_scale');
	GL_SGIX_fragment_lighting := Int_CheckExtension(Buffer, 'GL_SGIX_fragment_lighting');
	GL_SGIX_framezoom := Int_CheckExtension(Buffer, 'GL_SGIX_framezoom');
	GL_SGIX_igloo_interface := Int_CheckExtension(Buffer, 'GL_SGIX_igloo_interface');
	GL_SGIX_impact_pixel_texture := Int_CheckExtension(Buffer, 'GL_SGIX_impact_pixel_texture');
	GL_SGIX_instruments := Int_CheckExtension(Buffer, 'GL_SGIX_instruments');
	GL_SGIX_interlace := Int_CheckExtension(Buffer, 'GL_SGIX_interlace');
	GL_SGIX_ir_instrument1 := Int_CheckExtension(Buffer, 'GL_SGIX_ir_instrument1');
	GL_SGIX_list_priority := Int_CheckExtension(Buffer, 'GL_SGIX_list_priority');
	GL_SGIX_pixel_texture := Int_CheckExtension(Buffer, 'GL_SGIX_pixel_texture');
	GL_SGIX_pixel_tiles := Int_CheckExtension(Buffer, 'GL_SGIX_pixel_tiles');
	GL_SGIX_polynomial_ffd := Int_CheckExtension(Buffer, 'GL_SGIX_polynomial_ffd');
	GL_SGIX_reference_plane := Int_CheckExtension(Buffer, 'GL_SGIX_reference_plane');
	GL_SGIX_resample := Int_CheckExtension(Buffer, 'GL_SGIX_resample');
	GL_SGIX_scalebias_hint := Int_CheckExtension(Buffer, 'GL_SGIX_scalebias_hint');
	GL_SGIX_shadow := Int_CheckExtension(Buffer, 'GL_SGIX_shadow');
	GL_SGIX_shadow_ambient := Int_CheckExtension(Buffer, 'GL_SGIX_shadow_ambient');
	GL_SGIX_sprite := Int_CheckExtension(Buffer, 'GL_SGIX_sprite');
	GL_SGIX_subsample := Int_CheckExtension(Buffer, 'GL_SGIX_subsample');
	GL_SGIX_tag_sample_buffer := Int_CheckExtension(Buffer, 'GL_SGIX_tag_sample_buffer');
	GL_SGIX_texture_add_env := Int_CheckExtension(Buffer, 'GL_SGIX_texture_add_env');
	GL_SGIX_texture_coordinate_clamp := Int_CheckExtension(Buffer, 'GL_SGIX_texture_coordinate_clamp');
	GL_SGIX_texture_lod_bias := Int_CheckExtension(Buffer, 'GL_SGIX_texture_lod_bias');
	GL_SGIX_texture_multi_buffer := Int_CheckExtension(Buffer, 'GL_SGIX_texture_multi_buffer');
	GL_SGIX_texture_scale_bias := Int_CheckExtension(Buffer, 'GL_SGIX_texture_scale_bias');
	GL_SGIX_texture_select := Int_CheckExtension(Buffer, 'GL_SGIX_texture_select');
	GL_SGIX_vertex_preclip := Int_CheckExtension(Buffer, 'GL_SGIX_vertex_preclip');
	GL_SGIX_ycrcb := Int_CheckExtension(Buffer, 'GL_SGIX_ycrcb');
	GL_SGIX_ycrcb_subsample := Int_CheckExtension(Buffer, 'GL_SGIX_ycrcb_subsample');
	GL_SGIX_ycrcba := Int_CheckExtension(Buffer, 'GL_SGIX_ycrcba');

	(* SGI *)
	GL_SGI_color_matrix := Int_CheckExtension(Buffer, 'GL_SGI_color_matrix');
	GL_SGI_color_table := Int_CheckExtension(Buffer, 'GL_SGI_color_table');
	GL_SGI_depth_pass_instrument := Int_CheckExtension(Buffer, 'GL_SGI_depth_pass_instrument');
	GL_SGI_texture_color_table := Int_CheckExtension(Buffer, 'GL_SGI_texture_color_table');

	(* SUN *)
	GL_SUNX_constant_data := Int_CheckExtension(Buffer, 'GL_SUNX_constant_data');
	GL_SUN_convolution_border_modes := Int_CheckExtension(Buffer, 'GL_SUN_convolution_border_modes');
	GL_SUN_global_alpha := Int_CheckExtension(Buffer, 'GL_SUN_global_alpha');
	GL_SUN_mesh_array := Int_CheckExtension(Buffer, 'GL_SUN_mesh_array');
	GL_SUN_slice_accum := Int_CheckExtension(Buffer, 'GL_SUN_slice_accum');
	GL_SUN_triangle_list := Int_CheckExtension(Buffer, 'GL_SUN_triangle_list');
	GL_SUN_vertex := Int_CheckExtension(Buffer, 'GL_SUN_vertex');

	(* WIN *)
	GL_WIN_phong_shading := Int_CheckExtension(Buffer, 'GL_WIN_phong_shading');
	GL_WIN_specular_fog := Int_CheckExtension(Buffer, 'GL_WIN_specular_fog');

	(* WGL_WINDOWS *)
	(* === WGL ===================================================================== *)
	WGL_3DFX_multisample := Int_CheckExtension(Buffer, 'WGL_3DFX_multisample');
	WGL_ARB_buffer_region := Int_CheckExtension(Buffer, 'WGL_ARB_buffer_region');
	WGL_ARB_extensions_string := Int_CheckExtension(Buffer, 'WGL_ARB_extensions_string');
	WGL_ARB_make_current_read := Int_CheckExtension(Buffer, 'WGL_ARB_make_current_read');
	WGL_ARB_multisample := Int_CheckExtension(Buffer, 'WGL_ARB_multisample');
	WGL_ARB_pbuffer := Int_CheckExtension(Buffer, 'WGL_ARB_pbuffer');
	WGL_ARB_pixel_format := Int_CheckExtension(Buffer, 'WGL_ARB_pixel_format');
	WGL_ARB_pixel_format_float := Int_CheckExtension(Buffer, 'WGL_ARB_pixel_format_float');
	WGL_ARB_render_texture := Int_CheckExtension(Buffer, 'WGL_ARB_render_texture');
	WGL_ARB_create_context := Int_CheckExtension(Buffer, 'WGL_ARB_create_context');
	WGL_ARB_create_context_profile := Int_CheckExtension(Buffer, 'WGL_ARB_create_context_profile');
	WGL_ARB_framebuffer_sRGB := Int_CheckExtension(Buffer, 'WGL_ARB_framebuffer_sRGB');
	WGL_ARB_create_context_robustness := Int_CheckExtension(Buffer, 'WGL_ARB_create_context_robustness');
	WGL_ATI_pixel_format_float := Int_CheckExtension(Buffer, 'WGL_ATI_pixel_format_float');
	WGL_AMD_gpu_association := Int_CheckExtension(Buffer, 'WGL_AMD_gpu_association');
	WGL_EXT_depth_float := Int_CheckExtension(Buffer, 'WGL_EXT_depth_float');
	WGL_EXT_display_color_table := Int_CheckExtension(Buffer, 'WGL_EXT_display_color_table');
	WGL_EXT_extensions_string := Int_CheckExtension(Buffer, 'WGL_EXT_extensions_string');
	WGL_EXT_make_current_read := Int_CheckExtension(Buffer, 'WGL_EXT_make_current_read');
	WGL_EXT_multisample := Int_CheckExtension(Buffer, 'WGL_EXT_multisample');
	WGL_EXT_pbuffer := Int_CheckExtension(Buffer, 'WGL_EXT_pbuffer');
	WGL_EXT_pixel_format := Int_CheckExtension(Buffer, 'WGL_EXT_pixel_format');
	WGL_EXT_swap_control := Int_CheckExtension(Buffer, 'WGL_EXT_swap_control');
	WGL_EXT_create_context_es2_profile := Int_CheckExtension(Buffer, 'WGL_EXT_create_context_es2_profile');
	WGL_I3D_digital_video_control := Int_CheckExtension(Buffer, 'WGL_I3D_digital_video_control');
	WGL_I3D_gamma := Int_CheckExtension(Buffer, 'WGL_I3D_gamma');
	WGL_I3D_genlock := Int_CheckExtension(Buffer, 'WGL_I3D_genlock');
	WGL_I3D_image_buffer := Int_CheckExtension(Buffer, 'WGL_I3D_image_buffer');
	WGL_I3D_swap_frame_lock := Int_CheckExtension(Buffer, 'WGL_I3D_swap_frame_lock');
	WGL_I3D_swap_frame_usage := Int_CheckExtension(Buffer, 'WGL_I3D_swap_frame_usage');
	WGL_NV_float_buffer := Int_CheckExtension(Buffer, 'WGL_NV_float_buffer');
	WGL_NV_render_depth_texture := Int_CheckExtension(Buffer, 'WGL_NV_render_depth_texture');
	WGL_NV_render_texture_rectangle := Int_CheckExtension(Buffer, 'WGL_NV_render_texture_rectangle');
	WGL_NV_vertex_array_range := Int_CheckExtension(Buffer, 'WGL_NV_vertex_array_range');
	WGL_NV_present_video := Int_CheckExtension(Buffer, 'WGL_NV_present_video');
	WGL_NV_video_output := Int_CheckExtension(Buffer, 'WGL_NV_video_output');
	WGL_NV_swap_group := Int_CheckExtension(Buffer, 'WGL_NV_swap_group');
	WGL_NV_gpu_affinity := Int_CheckExtension(Buffer, 'WGL_NV_gpu_affinity');
	WGL_NV_video_capture := Int_CheckExtension(Buffer, 'WGL_NV_video_capture');
	WGL_NV_copy_image := Int_CheckExtension(Buffer, 'WGL_NV_copy_image');
	WGL_NV_multisample_coverage := Int_CheckExtension(Buffer, 'WGL_NV_multisample_coverage');
	WGL_NV_DX_interop := Int_CheckExtension(Buffer, 'WGL_NV_multisample_coverage');
	WGL_OML_sync_control := Int_CheckExtension(Buffer, 'WGL_OML_sync_control');
	WGL_3DL_stereo_control := Int_CheckExtension(Buffer, 'WGL_3DL_stereo_control');
	WGL_ARB_context_flush_control := Int_CheckExtension(Buffer, 'WGL_ARB_context_flush_control');
	WIN_draw_range_elements := Int_CheckExtension(Buffer, 'WIN_draw_range_elements');
	WIN_swap_hint := Int_CheckExtension(Buffer, 'WIN_swap_hint');

	(* ImplementationRead := TRUE; *)
END ReadImplementationProperties;


(* ------------------  *)
(*! wrapper procedures *)

PROCEDURE Materialfv*(face: Enum; pname: Enum;  CONST params:  ARRAY [4] OF Float);
BEGIN
	XglMaterialfv(face, pname, ADDRESSOF(params[0]));
END Materialfv;

PROCEDURE Lightfv*(light: Enum; pname: Enum;   CONST params: ARRAY [4] OF Float);
BEGIN
	XglLightfv(light, pname, ADDRESSOF(params[0]));
END Lightfv;

PROCEDURE Normal3fv*(CONST v: ARRAY [3] OF Float);
BEGIN
	XglNormal3fv(ADDRESSOF(v[0]));
END Normal3fv;

PROCEDURE Normal3dv*( CONST v: ARRAY [3] OF Double);
BEGIN
	XglNormal3dv(ADDRESSOF(v[0]));
END Normal3dv;

PROCEDURE Vertex3fv*( CONST v: ARRAY [3] OF Float);
BEGIN
	XglVertex3fv(ADDRESSOF(v[0]));
END Vertex3fv;

PROCEDURE Vertex3dv*( CONST v: ARRAY [3] OF Double);
BEGIN
	XglVertex3dv(ADDRESSOF(v[0]));
END Vertex3dv;

PROCEDURE LightModelfv*(pname: Enum;  CONST params: ARRAY [4] OF Float);
BEGIN
	XglLightModelfv(pname, ADDRESSOF(params[0]));
END LightModelfv;

PROCEDURE Color3fv*(CONST c: ARRAY [3] OF Float);
BEGIN
	XglColor3fv(ADDRESSOF(c[0]));
END Color3fv;

PROCEDURE Color3dv* (CONST c: ARRAY [3] OF Double);
BEGIN
	XglColor3dv(ADDRESSOF(c[0]));
END Color3dv;

(* ---------------------- *)
PROCEDURE OnClose;
VAR res: LONGINT;
BEGIN
	IF libHandle # Kernel32.NULL THEN
		res := Kernel32.FreeLibrary(libHandle);
		KernelLog.String(libName ); KernelLog.String(" unloaded."); KernelLog.Ln;
	END;
END OnClose;

BEGIN
	InitOpenGL;
	Modules.InstallTermHandler(OnClose);
	(*  ReadOpenGLCore(); *)
END OpenGL.

