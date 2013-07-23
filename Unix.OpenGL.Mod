MODULE OpenGL; (** AUTHOR "fnecati"; PURPOSE "OpenGL binding for UnixAos";  *)

IMPORT SYSTEM, Unix, Modules, X11Api, Strings, GLC := OpenGLConst, KernelLog;

(*
	Compiler.Compile OpenGLConst.Mod Unix.OpenGL.Mod Unix.GLU.Mod ~

 ==============================================================================
        OpenGL 4.3 - Headertranslation
        Version 4.3
        Date : 22.11.2012
        Works with : LinuxAos
 ==============================================================================
  *)

VAR
	(* handle to library  *)
	GL_LibHandle: LONGINT;

	libraryPaths: ARRAY 8 OF ARRAY 64 OF CHAR;

CONST
	debug = FALSE; (* used in ReadImplementationProperties, when extension is not available  *)
	GL_LibName = 'libGL.so.1';

TYPE

	AnsiChar* = POINTER TO ARRAY OF CHAR;
	PAnsiChar* = ADDRESS;
	THandle* = LONGINT;
	XID* = X11Api.XID;

	(* GL data types *)
	Enum* = LONGINT;  	(* 4 bytes *)
	Boolean* = LONGINT; 	(*  *)
	Bitfield* = LONGINT; 	(* SET *)
	Byte* = CHAR; 		(* 1 byte signed *)
	Short* = INTEGER;  	(* 2 bytes signed *)
	Int* = LONGINT; 	(* 4 bytes signed *)
	Sizei* = LONGINT;  	(* 4 bytes signed *)
	Ubyte* = CHAR; 		(* 1 byte unsigned *)
	Ushort* = INTEGER;	(* 2 bytes unsigned *)
	Uint* = LONGINT;	(* 4 bytes unsigned *)
	Float* = REAL;		(* single precision real *)
	Clampf* = REAL;		(* single precision real in [0,1] *)
	Double* = LONGREAL;	(* double precision real *)
	Clampd* = LONGREAL;	(* double precision real in [0,1] *)
	Void* = LONGINT;
	Int64* = HUGEINT;
	Uint64* = HUGEINT;

	Pointer* = ADDRESS;
	PPointer* = ADDRESS;
	WORD* = INTEGER;
	DWORD* = LONGINT;

	PBoolean* = ADDRESS; 	(* POINTER TO ARRAY OF Boolean; *)
	PByte* = ADDRESS; 	(* POINTER TO ARRAY OF Byte; *)
	PShort* = ADDRESS; 	(* POINTER TO ARRAY OF Short; *)
	Pint* =  ADDRESS; 	(* POINTER TO ARRAY OF Int; *)
	PSizei* = ADDRESS; 	(* POINTER TO ARRAY OF Sizei; *)
	PUbyte* = ADDRESS; 	(* POINTER TO ARRAY OF Ubyte; *)
	PUshort* = ADDRESS; 	(* POINTER TO ARRAY OF Ushort; *)
	PInt* = ADDRESS; 	(* POINTER TO ARRAY OF Uint; *)
	PClampf* = ADDRESS; 	(* POINTER TO ARRAY OF Clampf; *)
	PFloat* =  ADDRESS; 	(* POINTER TO ARRAY OF Float; *)
	PDouble* = ADDRESS; 	(* POINTER TO ARRAY OF Double; *)
	PClampd* = ADDRESS; 	(* POINTER TO ARRAY OF Clampd; *)
	PEnum* =  ADDRESS; 	(* POINTER TO ARRAY OF Enum *);
	PVoid* = ADDRESS; 	(* Void *);
	PPVoid* = ADDRESS; 	(* POINTER TO ARRAY OF PVoid; *)
	Pint64* =  ADDRESS; 	(* POINTER TO ARRAY OF Int64; *)
	PInt64* = ADDRESS; 	(* POINTER TO ARRAY OF Uint64; *)

	(* GL_NV_half_float *)
	HalfNV* = WORD;
	PHalfNV* = ADDRESS; (* POINTER TO ARRAY OF HalfNV; *)

	(* GL_ARB_shader_objects  *)
	PHandleARB* = ADDRESS ;
	HandleARB* = ADDRESS;
	CharARB* = AnsiChar;
	PCharARB* = PAnsiChar;
	PPCharARB* =  ADDRESS; (* POINTER TO ARRAY OF PCharARB; *)

	(* GL_VERSION_1_5 *)
	Intptr* = Int;
	Sizeiptr* = Sizei;

	(* GL_ARB_vertex_buffer_object *)
	IntptrARB* = Int;
	SizeiptrARB* = Sizei;

	(* GL_VERSION_2_0 *)
	Handle* = Uint;
	PChar* = PAnsiChar;
	PPChar* = ADDRESS; (* POINTER TO ARRAY OF PChar *)

	(* GL_EXT_timer_query *)
	Int64EXT* = Int64;
	Pint64EXT* = ADDRESS; (* POINTER TO ARRAY OF Int64EXT *)


	Uint64EXT* = Uint64;
	PInt64EXT* = ADDRESS; (* POINTER TO ARRAY OF Uint64EXT *)

	(* ARB_sync *)
	GLsync* = Pointer;

	(* GL_ARB_cl_event *)
	(* These incomplete types let us declare types compatible with OpenCL's cl_context and cl_event *)
	_cl_context = LONGINT;
	_cl_event = LONGINT;
	p_cl_context = ADDRESS; (* POINTER TO ARRAY OF _cl_context *)
	p_cl_event = ADDRESS; (* POINTER TO ARRAY OF _cl_event *)

	(* GL_ARB_debug_output *)
	TglDebugProcARB  = PROCEDURE{C}(source: Enum; xtype: Enum; id: Uint; severity: Enum; length: Sizei;  xmessage: PChar; userParam: PVoid);

	(* GL_AMD_debug_output *)
	TglDebugProcAMD  = PROCEDURE{C}(id: Uint; category: Enum; severity: Enum; length: Sizei; xmessage: PChar; userParam: PVoid);

	(*! (4.3) GL_KHR_debug *)
	TglDebugProc  = PROCEDURE{C}(source : Enum; xtype : Enum; id : Uint; severity : Uint; length : Sizei; xmessage: PChar; userParam : PVoid);


	(* GL_NV_vdpau_interop  *)
	GLvdpauSurfaceNV = Intptr;
	PGLvdpauSurfaceNV =  ADDRESS; (* POINTER TO ARRAY OF GLvdpauSurfaceNV; *)

	(*! GLX - LINUX  *)

	DisplayPtr* = X11Api.DisplayPtr;
	VisualInfoPtr* = X11Api.VisualInfoPtr;

	GLXContext* = XID;
	GLXContextID* = XID;
	GLXDrawable* = XID;
	GLXFBConfig* = XID;
	GLXPbuffer* = XID;
	GLXPixmap* = XID;
	GLXWindow* = XID;

	Window* = XID;
	Colormap* = XID;
	Pixmap* = XID;
	Font* = XID;

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
	GL_3DFX_multisample* ,
	GL_3DFX_tbuffer* ,
	GL_3DFX_texture_compression_FXT1* ,
	GL_APPLE_client_storage* ,
	GL_APPLE_element_array* ,
	GL_APPLE_fence* ,
	GL_APPLE_specular_vector* ,
	GL_APPLE_transform_hint* ,
	GL_APPLE_vertex_array_object* ,
	GL_APPLE_vertex_array_range* ,
	GL_APPLE_ycbcr_422* ,
	GL_APPLE_texture_range* ,
	GL_APPLE_float_pixels* ,
	GL_APPLE_vertex_program_evaluators* ,
	GL_APPLE_aux_depth_stencil* ,
	GL_APPLE_object_purgeable* ,
	GL_APPLE_row_bytes* ,
	GL_APPLE_rgb_422* ,
	GL_ARB_depth_texture* ,
	GL_ARB_fragment_program* ,
	GL_ARB_imaging* ,
	GL_ARB_matrix_palette* ,
	GL_ARB_multisample* ,
	GL_ARB_multitexture* ,
	GL_ARB_point_parameters* ,
	GL_ARB_shadow* ,
	GL_ARB_shadow_ambient* ,
	GL_ARB_texture_border_clamp* ,
	GL_ARB_texture_compression* ,
	GL_ARB_texture_cube_map* ,
	GL_ARB_texture_env_add* ,
	GL_ARB_texture_env_combine* ,
	GL_ARB_texture_env_crossbar* ,
	GL_ARB_texture_env_dot3* ,
	GL_ARB_texture_mirrored_repeat* ,
	GL_ARB_transpose_matrix* ,
	GL_ARB_vertex_blend* ,
	GL_ARB_vertex_buffer_object* ,
	GL_ARB_vertex_program* ,
	GL_ARB_window_pos* ,
	GL_ARB_shader_objects* ,
	GL_ARB_vertex_shader* ,
	GL_ARB_fragment_shader* ,
	GL_ARB_shading_language_100* ,
	GL_ARB_occlusion_query* ,
	GL_ARB_texture_non_power_of_two* ,
	GL_ARB_point_sprite* ,
	GL_ARB_fragment_program_shadow* ,
	GL_ARB_draw_buffers* ,
	GL_ARB_texture_rectangle* ,
	GL_ARB_color_buffer_float* ,
	GL_ARB_half_float_pixel* ,
	GL_ARB_texture_float* ,
	GL_ARB_pixel_buffer_object* ,
	GL_ARB_depth_buffer_float* ,
	GL_ARB_draw_instanced* ,
	GL_ARB_framebuffer_object* ,
	GL_ARB_framebuffer_sRGB* ,
	GL_ARB_geometry_shader4* ,
	GL_ARB_half_float_vertex* ,
	GL_ARB_instanced_arrays* ,
	GL_ARB_map_buffer_range* ,
	GL_ARB_texture_buffer_object* ,
	GL_ARB_texture_compression_rgtc* ,
	GL_ARB_texture_rg* ,
	GL_ARB_vertex_array_object* ,
	GL_ARB_uniform_buffer_object* ,
	GL_ARB_compatibility* ,
	GL_ARB_copy_buffer* ,
	GL_ARB_shader_texture_lod* ,
	GL_ARB_depth_clamp* ,
	GL_ARB_draw_elements_base_vertex* ,
	GL_ARB_fragment_coord_conventions* ,
	GL_ARB_provoking_vertex* ,
	GL_ARB_seamless_cube_map* ,
	GL_ARB_sync* ,
	GL_ARB_texture_multisample* ,
	GL_ARB_vertex_array_bgra* ,
	GL_ARB_draw_buffers_blend* ,
	GL_ARB_sample_shading* ,
	GL_ARB_texture_cube_map_array* ,
	GL_ARB_texture_gather* ,
	GL_ARB_texture_query_lod* ,
	GL_ARB_shading_language_include* ,
	GL_ARB_texture_compression_bptc* ,
	GL_ARB_blend_func_extended* ,
	GL_ARB_explicit_attrib_location* ,
	GL_ARB_occlusion_query2* ,
	GL_ARB_sampler_objects* ,
	GL_ARB_shader_bit_encoding* ,
	GL_ARB_texture_rgb10_a2ui* ,
	GL_ARB_texture_swizzle* ,
	GL_ARB_timer_query* ,
	GL_ARB_vertex_type_2_10_10_10_rev* ,
	GL_ARB_draw_indirect* ,
	GL_ARB_gpu_shader5* ,
	GL_ARB_gpu_shader_fp64* ,
	GL_ARB_shader_subroutine* ,
	GL_ARB_tessellation_shader* ,
	GL_ARB_texture_buffer_object_rgb32* ,
	GL_ARB_transform_feedback2* ,
	GL_ARB_transform_feedback3* ,
	GL_ARB_ES2_compatibility* ,
	GL_ARB_get_program_binary* ,
	GL_ARB_separate_shader_objects* ,
	GL_ARB_shader_precision* ,
	GL_ARB_vertex_attrib_64bit* ,
	GL_ARB_viewport_array* ,

	(* GL 4.2  *)
	GL_ARB_base_instance* ,
	GL_ARB_shading_language_420pack* ,
	GL_ARB_transform_feedback_instanced* ,
	GL_ARB_compressed_texture_pixel_storage* ,
	GL_ARB_conservative_depth* ,
	GL_ARB_internalformat_query* ,
	GL_ARB_map_buffer_alignment* ,
	GL_ARB_shader_atomic_counters* ,
	GL_ARB_shader_image_load_store* ,
	GL_ARB_shading_language_packing* ,
	GL_ARB_texture_storage* ,

	(* GL 4.3  *)
	GL_ARB_arrays_of_arrays* ,
	GL_ARB_fragment_layer_viewport* ,
	GL_ARB_shader_image_size* ,
	GL_ARB_ES3_compatibility* ,
	GL_ARB_clear_buffer_object* ,
	GL_ARB_compute_shader* ,
	GL_ARB_copy_image* ,
	GL_KHR_debug* ,
	GL_ARB_explicit_uniform_location* ,
	GL_ARB_framebuffer_no_attachments* ,
	GL_ARB_internalformat_query2* ,
	GL_ARB_invalidate_subdata* ,
	GL_ARB_multi_draw_indirect* ,
	GL_ARB_program_interface_query* ,
	GL_ARB_robust_buffer_access_behavior* ,
	GL_ARB_shader_storage_buffer_object* ,
	GL_ARB_stencil_texturing* ,
	GL_ARB_texture_buffer_range* ,
	GL_ARB_texture_query_levels* ,
	GL_ARB_texture_storage_multisample* ,
	GL_ARB_texture_view* ,
	GL_ARB_vertex_attrib_binding* ,

	(* GL 4.3 vendor specific  *)
	GL_NV_path_rendering* ,
	GL_AMD_pinned_memory* ,
	GL_AMD_stencil_operation_extended* ,
	GL_AMD_vertex_shader_viewport_index* ,
	GL_AMD_vertex_shader_layer* ,
	GL_NV_bindless_texture* ,
	GL_NV_shader_atomic_float* ,
	GL_AMD_query_buffer_object* ,

	(* *  *)
	GL_ARB_cl_event* ,
	GL_ARB_debug_output* ,
	GL_ARB_robustness* ,
	GL_ARB_shader_stencil_export* ,
	GL_ATI_draw_buffers* ,
	GL_ATI_element_array* ,
	GL_ATI_envmap_bumpmap* ,
	GL_ATI_fragment_shader* ,
	GL_ATI_map_object_buffer* ,
	GL_ATI_pn_triangles* ,
	GL_ATI_separate_stencil* ,
	GL_ATI_text_fragment_shader* ,
	GL_ATI_texture_env_combine3* ,
	GL_ATI_texture_float* ,
	GL_ATI_texture_mirror_once* ,
	GL_ATI_vertex_array_object* ,
	GL_ATI_vertex_attrib_array_object* ,
	GL_ATI_vertex_streams* ,
	GL_ATI_meminfo* ,
	GL_AMD_performance_monitor* ,
	GL_AMD_texture_texture4* ,
	GL_AMD_vertex_shader_tesselator* ,
	GL_AMD_draw_buffers_blend* ,
	GL_AMD_shader_stencil_export* ,
	GL_AMD_seamless_cubemap_per_texture* ,
	GL_AMD_conservative_depth* ,
	GL_AMD_name_gen_delete* ,
	GL_AMD_debug_output* ,
	GL_AMD_transform_feedback3_lines_triangles* ,
	GL_AMD_depth_clamp_separate* ,
	GL_EXT_422_pixels* ,
	GL_EXT_abgr* ,
	GL_EXT_bgra* ,
	GL_EXT_blend_color* ,
	GL_EXT_blend_func_separate* ,
	GL_EXT_blend_logic_op* ,
	GL_EXT_blend_minmax* ,
	GL_EXT_blend_subtract* ,
	GL_EXT_clip_volume_hint* ,
	GL_EXT_cmyka* ,
	GL_EXT_color_matrix* ,
	GL_EXT_color_subtable* ,
	GL_EXT_compiled_vertex_array* ,
	GL_EXT_convolution* ,
	GL_EXT_coordinate_frame* ,
	GL_EXT_copy_texture* ,
	GL_EXT_cull_vertex* ,
	GL_EXT_draw_range_elements* ,
	GL_EXT_fog_coord* ,
	GL_EXT_framebuffer_object* ,
	GL_EXT_histogram* ,
	GL_EXT_index_array_formats* ,
	GL_EXT_index_func* ,
	GL_EXT_index_material* ,
	GL_EXT_index_texture* ,
	GL_EXT_light_texture* ,
	GL_EXT_misc_attribute* ,
	GL_EXT_multi_draw_arrays* ,
	GL_EXT_multisample* ,
	GL_EXT_packed_pixels* ,
	GL_EXT_paletted_texture* ,
	GL_EXT_pixel_transform* ,
	GL_EXT_pixel_transform_color_table* ,
	GL_EXT_point_parameters* ,
	GL_EXT_polygon_offset* ,
	GL_EXT_rescale_normal* ,
	GL_EXT_secondary_color* ,
	GL_EXT_separate_specular_color* ,
	GL_EXT_shadow_funcs* ,
	GL_EXT_shared_texture_palette* ,
	GL_EXT_stencil_two_side* ,
	GL_EXT_stencil_wrap* ,
	GL_EXT_subtexture* ,
	GL_EXT_texture* ,
	GL_EXT_texture3D* ,
	GL_EXT_texture_compression_s3tc* ,
	GL_EXT_texture_cube_map* ,
	GL_EXT_texture_edge_clamp* ,
	GL_EXT_texture_env_add* ,
	GL_EXT_texture_env_combine* ,
	GL_EXT_texture_env_dot3* ,
	GL_EXT_texture_filter_anisotropic* ,
	GL_EXT_texture_lod_bias* ,
	GL_EXT_texture_object* ,
	GL_EXT_texture_perturb_normal* ,
	GL_EXT_texture_rectangle* ,
	GL_EXT_vertex_array* ,
	GL_EXT_vertex_shader* ,
	GL_EXT_vertex_weighting* ,
	GL_EXT_depth_bounds_test* ,
	GL_EXT_texture_mirror_clamp* ,
	GL_EXT_blend_equation_separate* ,
	GL_EXT_pixel_buffer_object* ,
	GL_EXT_texture_compression_dxt1* ,
	GL_EXT_stencil_clear_tag* ,
	GL_EXT_packed_depth_stencil* ,
	GL_EXT_texture_sRGB* ,
	GL_EXT_framebuffer_blit* ,
	GL_EXT_framebuffer_multisample* ,
	GL_EXT_timer_query* ,
	GL_EXT_gpu_program_parameters* ,
	GL_EXT_bindable_uniform* ,
	GL_EXT_draw_buffers2* ,
	GL_EXT_draw_instanced* ,
	GL_EXT_framebuffer_sRGB* ,
	GL_EXT_geometry_shader4* ,
	GL_EXT_gpu_shader4* ,
	GL_EXT_packed_float* ,
	GL_EXT_texture_array* ,
	GL_EXT_texture_buffer_object* ,
	GL_EXT_texture_compression_latc* ,
	GL_EXT_texture_compression_rgtc* ,
	GL_EXT_texture_integer* ,
	GL_EXT_texture_shared_exponent* ,
	GL_EXT_transform_feedback* ,
	GL_EXT_direct_state_access* ,
	GL_EXT_vertex_array_bgra* ,
	GL_EXT_texture_swizzle* ,
	GL_EXT_provoking_vertex* ,
	GL_EXT_texture_snorm* ,
	GL_EXT_separate_shader_objects* ,
	GL_EXT_shader_image_load_store* ,
	GL_EXT_vertex_attrib_64bit* ,
	GL_EXT_texture_sRGB_decode* ,
	GL_FfdMaskSGIX* ,
	GL_HP_convolution_border_modes* ,
	GL_HP_image_transform* ,
	GL_HP_occlusion_test* ,
	GL_HP_texture_lighting* ,
	GL_IBM_cull_vertex* ,
	GL_IBM_multimode_draw_arrays* ,
	GL_IBM_rasterpos_clip* ,
	GL_IBM_texture_mirrored_repeat* ,
	GL_IBM_vertex_array_lists* ,
	GL_INGR_blend_func_separate* ,
	GL_INGR_color_clamp* ,
	GL_INGR_interlace_read* ,
	GL_INGR_palette_buffer* ,
	GL_INTEL_parallel_arrays* ,
	GL_INTEL_texture_scissor* ,
	GL_MESA_resize_buffers* ,
	GL_MESA_window_pos* ,
	GL_NV_blend_square* ,
	GL_NV_copy_depth_to_color* ,
	GL_NV_depth_clamp* ,
	GL_NV_evaluators* ,
	GL_NV_fence* ,
	GL_NV_float_buffer* ,
	GL_NV_fog_distance* ,
	GL_NV_fragment_program* ,
	GL_NV_half_float* ,
	GL_NV_light_max_exponent* ,
	GL_NV_multisample_filter_hint* ,
	GL_NV_occlusion_query* ,
	GL_NV_packed_depth_stencil* ,
	GL_NV_pixel_data_range* ,
	GL_NV_point_sprite* ,
	GL_NV_primitive_restart* ,
	GL_NV_register_combiners* ,
	GL_NV_register_combiners2* ,
	GL_NV_texgen_emboss* ,
	GL_NV_texgen_reflection* ,
	GL_NV_texture_compression_vtc* ,
	GL_NV_texture_env_combine4* ,
	GL_NV_texture_expand_normal* ,
	GL_NV_texture_rectangle* ,
	GL_NV_texture_shader* ,
	GL_NV_texture_shader2* ,
	GL_NV_texture_shader3* ,
	GL_NV_vertex_array_range* ,
	GL_NV_vertex_array_range2* ,
	GL_NV_vertex_program* ,
	GL_NV_vertex_program1_1* ,
	GL_NV_vertex_program2* ,
	GL_NV_fragment_program_option* ,
	GL_NV_fragment_program2* ,
	GL_NV_vertex_program2_option* ,
	GL_NV_vertex_program3* ,
	GL_NV_depth_buffer_float* ,
	GL_NV_fragment_program4* ,
	GL_NV_framebuffer_multisample_coverage* ,
	GL_NV_geometry_program4* ,
	GL_NV_gpu_program4* ,
	GL_NV_parameter_buffer_object* ,
	GL_NV_transform_feedback* ,
	GL_NV_vertex_program4* ,
	GL_NV_conditional_render* ,
	GL_NV_present_video* ,
	GL_NV_explicit_multisample* ,
	GL_NV_transform_feedback2* ,
	GL_NV_video_capture* ,
	GL_NV_copy_image* ,
	GL_NV_parameter_buffer_object2* ,
	GL_NV_shader_buffer_load* ,
	GL_NV_vertex_buffer_unified_memory* ,
	GL_NV_gpu_program5* ,
	GL_NV_gpu_shader5* ,
	GL_NV_shader_buffer_store* ,
	GL_NV_tessellation_program5* ,
	GL_NV_vertex_attrib_integer_64bit* ,
	GL_NV_multisample_coverage* ,
	GL_NV_vdpau_interop* ,
	GL_NV_texture_barrier* ,
	GL_OML_interlace* ,
	GL_OML_resample* ,
	GL_OML_subsample* ,
	GL_PGI_misc_hints* ,
	GL_PGI_vertex_hints* ,
	GL_REND_screen_coordinates* ,
	GL_S3_s3tc* ,
	GL_SGIS_detail_texture* ,
	GL_SGIS_fog_function* ,
	GL_SGIS_generate_mipmap* ,
	GL_SGIS_multisample* ,
	GL_SGIS_pixel_texture* ,
	GL_SGIS_point_line_texgen* ,
	GL_SGIS_point_parameters* ,
	GL_SGIS_sharpen_texture* ,
	GL_SGIS_texture4D* ,
	GL_SGIS_texture_border_clamp* ,
	GL_SGIS_texture_color_mask* ,
	GL_SGIS_texture_edge_clamp* ,
	GL_SGIS_texture_filter4* ,
	GL_SGIS_texture_lod* ,
	GL_SGIS_texture_select* ,
	GL_SGIX_async* ,
	GL_SGIX_async_histogram* ,
	GL_SGIX_async_pixel* ,
	GL_SGIX_blend_alpha_minmax* ,
	GL_SGIX_calligraphic_fragment* ,
	GL_SGIX_clipmap* ,
	GL_SGIX_convolution_accuracy* ,
	GL_SGIX_depth_pass_instrument* ,
	GL_SGIX_depth_texture* ,
	GL_SGIX_flush_raster* ,
	GL_SGIX_fog_offset* ,
	GL_SGIX_fog_scale* ,
	GL_SGIX_fragment_lighting* ,
	GL_SGIX_framezoom* ,
	GL_SGIX_igloo_interface* ,
	GL_SGIX_impact_pixel_texture* ,
	GL_SGIX_instruments* ,
	GL_SGIX_interlace* ,
	GL_SGIX_ir_instrument1* ,
	GL_SGIX_list_priority* ,
	GL_SGIX_pixel_texture* ,
	GL_SGIX_pixel_tiles* ,
	GL_SGIX_polynomial_ffd* ,
	GL_SGIX_reference_plane* ,
	GL_SGIX_resample* ,
	GL_SGIX_scalebias_hint* ,
	GL_SGIX_shadow* ,
	GL_SGIX_shadow_ambient* ,
	GL_SGIX_sprite* ,
	GL_SGIX_subsample* ,
	GL_SGIX_tag_sample_buffer* ,
	GL_SGIX_texture_add_env* ,
	GL_SGIX_texture_coordinate_clamp* ,
	GL_SGIX_texture_lod_bias* ,
	GL_SGIX_texture_multi_buffer* ,
	GL_SGIX_texture_scale_bias* ,
	GL_SGIX_texture_select* ,
	GL_SGIX_vertex_preclip* ,
	GL_SGIX_ycrcb* ,
	GL_SGIX_ycrcb_subsample* ,
	GL_SGIX_ycrcba* ,
	GL_SGI_color_matrix* ,
	GL_SGI_color_table* ,
	GL_SGI_depth_pass_instrument* ,
	GL_SGI_texture_color_table* ,
	GL_SUNX_constant_data* ,
	GL_SUN_convolution_border_modes* ,
	GL_SUN_global_alpha* ,
	GL_SUN_mesh_array* ,
	GL_SUN_slice_accum* ,
	GL_SUN_triangle_list* ,
	GL_SUN_vertex* ,

	GL_WIN_phong_shading* ,
	GL_WIN_specular_fog* ,

	(*!  GLX_VERSION_1_0* ,  *)
	GLX_VERSION_1_3* ,
	GLX_VERSION_1_4* ,
	GLX_ARB_multisample* ,
	GLX_ARB_fbconfig_float* ,
	GLX_ARB_get_proc_address* ,
	GLX_ARB_create_context* ,
	GLX_ARB_create_context_profile* ,
	GLX_ARB_vertex_buffer_object* ,
	GLX_ARB_framebuffer_sRGB* ,
	GLX_ARB_create_context_robustness* ,
	GLX_EXT_visual_info* ,
	GLX_EXT_visual_rating* ,
	GLX_EXT_import_context* ,
	GLX_EXT_fbconfig_packed_float* ,
	GLX_EXT_framebuffer_sRGB* ,
	GLX_EXT_texture_from_pixmap* ,
	GLX_EXT_swap_control* ,
	GLX_EXT_create_context_es2_profile : BOOLEAN;

TYPE

	(*! GL_VERSION_1_0  *)
	TglCullFace* = PROCEDURE{C}(mode: Enum);
	TglFrontFace* = PROCEDURE{C}(mode: Enum);
	TglHint* = PROCEDURE{C}(target: Enum; mode: Enum);
	TglLineWidth* = PROCEDURE{C}(width: Float);
	TglPointSize* = PROCEDURE{C}(size: Float);
	TglPolygonMode* = PROCEDURE{C}(face: Enum; mode: Enum);
	TglScissor* = PROCEDURE{C}(x: Int; y: Int; width: Sizei; height: Sizei);
	TglTexParameterf* = PROCEDURE{C}(target: Enum; pname: Enum; param: Float);
	TglTexParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglTexParameteri* = PROCEDURE{C}(target: Enum; pname: Enum; param: Int);
	TglTexParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglTexImage1D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Int; width: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTexImage2D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Int; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglDrawBuffer* = PROCEDURE{C}(mode: Enum);
	TglClear* = PROCEDURE{C}(mask: Bitfield);
	TglClearColor* = PROCEDURE{C}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	TglClearStencil* = PROCEDURE{C}(s: Int);
	TglClearDepth* = PROCEDURE{C}(depth: Clampd);
	TglStencilMask* = PROCEDURE{C}(mask: Uint);
	TglColorMask* = PROCEDURE{C}(red: Boolean; green: Boolean; blue: Boolean; alpha: Boolean);
	TglDepthMask* = PROCEDURE{C}(flag: Boolean);
	TglDisable* = PROCEDURE{C}(cap: Enum);
	TglEnable* = PROCEDURE{C}(cap: Enum);
	TglFinish* = PROCEDURE{C}();
	TglFlush* = PROCEDURE{C}();
	TglBlendFunc* = PROCEDURE{C}(sfactor: Enum; dfactor: Enum);
	TglLogicOp* = PROCEDURE{C}(opcode: Enum);
	TglStencilFunc* = PROCEDURE{C}(func: Enum; ref: Int; mask: Uint);
	TglStencilOp* = PROCEDURE{C}(fail: Enum; zfail: Enum; zpass: Enum);
	TglDepthFunc* = PROCEDURE{C}(func: Enum);
	TglPixelStoref* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPixelStorei* = PROCEDURE{C}(pname: Enum; param: Int);
	TglReadBuffer* = PROCEDURE{C}(mode: Enum);
	TglReadPixels* = PROCEDURE{C}(x: Int; y: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetBooleanv* = PROCEDURE{C}(pname: Enum; params: PBoolean);
	TglGetDoublev* = PROCEDURE{C}(pname: Enum; params: PDouble);
	TglGetError* = PROCEDURE{C}(): Enum;
	TglGetFloatv* = PROCEDURE{C}(pname: Enum; params: PFloat);
	TglGetIntegerv* = PROCEDURE{C}(pname: Enum; params: Pint);
	TglGetString* = PROCEDURE{C}(name: Enum): ADDRESS;
	TglGetTexImage* = PROCEDURE{C}(target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetTexParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetTexParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetTexLevelParameterfv* = PROCEDURE{C}(target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetTexLevelParameteriv* = PROCEDURE{C}(target: Enum; level: Int; pname: Enum; params: Pint);
	TglIsEnabled* = PROCEDURE{C}(cap: Enum): Boolean;
	TglDepthRange* = PROCEDURE{C}(zNear: Clampd; zFar: Clampd);
	TglViewport* = PROCEDURE{C}(x: Int; y: Int; width: Sizei; height: Sizei);
	(*! GL_VERSION_1_1  *)
	TglDrawArrays* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei);
	TglDrawElements* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: PVoid);
	TglGetPointerv* = PROCEDURE{C}(pname: Enum; params: PVoid);
	TglPolygonOffset* = PROCEDURE{C}(factor: Float; units: Float);
	TglCopyTexImage1D* = PROCEDURE{C}(target: Enum; level: Int; internalFormat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTexImage2D* = PROCEDURE{C}(target: Enum; level: Int; internalFormat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTexSubImage1D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTexSubImage2D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglTexSubImage1D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTexSubImage2D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglBindTexture* = PROCEDURE{C}(target: Enum; texture: Uint);
	TglDeleteTextures* = PROCEDURE{C}(n: Sizei;  textures: PInt);
	TglGenTextures* = PROCEDURE{C}(n: Sizei; textures: PInt);

	(*! ifdef DEPRECATED  *)
	TglAccum* = PROCEDURE{C}(op: Enum; value: Float);
	TglAlphaFunc* = PROCEDURE{C}(func: Enum; ref: Clampf);
	TglAreTexturesResident* = PROCEDURE{C}(n: Sizei;  textures: PInt; residences: PBoolean): Boolean;
	TglArrayElement* = PROCEDURE{C}(i: Int);
	TglBegin* = PROCEDURE{C}(mode: Enum);
	TglBitmap* = PROCEDURE{C}(width: Sizei; height: Sizei; xorig: Float; yorig: Float; xmove: Float; ymove: Float;  bitmap: PUbyte);
	TglCallList* = PROCEDURE{C}(list: Uint);
	TglCallLists* = PROCEDURE{C}(n: Sizei; xtype: Enum;  lists: PVoid);
	TglClearAccum* = PROCEDURE{C}(red: Float; green: Float; blue: Float; alpha: Float);
	TglClearIndex* = PROCEDURE{C}(c: Float);
	TglClipPlane* = PROCEDURE{C}(plane: Enum;  equation: PDouble);
	TglColor3b* = PROCEDURE{C}(red: Byte; green: Byte; blue: Byte);
	TglColor3bv* = PROCEDURE{C}( v: PByte);
	TglColor3d* = PROCEDURE{C}(red: Double; green: Double; blue: Double);
	TglColor3dv* = PROCEDURE{C}( v: PDouble);
	TglColor3f* = PROCEDURE{C}(red: Float; green: Float; blue: Float);
	TglColor3fv* = PROCEDURE{C}( v: PFloat);
	TglColor3i* = PROCEDURE{C}(red: Int; green: Int; blue: Int);
	TglColor3iv* = PROCEDURE{C}( v: Pint);
	TglColor3s* = PROCEDURE{C}(red: Short; green: Short; blue: Short);
	TglColor3sv* = PROCEDURE{C}( v: PShort);
	TglColor3ub* = PROCEDURE{C}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglColor3ubv* = PROCEDURE{C}( v: PUbyte);
	TglColor3ui* = PROCEDURE{C}(red: Uint; green: Uint; blue: Uint);
	TglColor3uiv* = PROCEDURE{C}( v: PInt);
	TglColor3us* = PROCEDURE{C}(red: Ushort; green: Ushort; blue: Ushort);
	TglColor3usv* = PROCEDURE{C}( v: PUshort);
	TglColor4b* = PROCEDURE{C}(red: Byte; green: Byte; blue: Byte; alpha: Byte);
	TglColor4bv* = PROCEDURE{C}( v: PByte);
	TglColor4d* = PROCEDURE{C}(red: Double; green: Double; blue: Double; alpha: Double);
	TglColor4dv* = PROCEDURE{C}( v: PDouble);
	TglColor4f* = PROCEDURE{C}(red: Float; green: Float; blue: Float; alpha: Float);
	TglColor4fv* = PROCEDURE{C}( v: PFloat);
	TglColor4i* = PROCEDURE{C}(red: Int; green: Int; blue: Int; alpha: Int);
	TglColor4iv* = PROCEDURE{C}( v: Pint);
	TglColor4s* = PROCEDURE{C}(red: Short; green: Short; blue: Short; alpha: Short);
	TglColor4sv* = PROCEDURE{C}( v: PShort);
	TglColor4ub* = PROCEDURE{C}(red: Ubyte; green: Ubyte; blue: Ubyte; alpha: Ubyte);
	TglColor4ubv* = PROCEDURE{C}( v: PUbyte);
	TglColor4ui* = PROCEDURE{C}(red: Uint; green: Uint; blue: Uint; alpha: Uint);
	TglColor4uiv* = PROCEDURE{C}( v: PInt);
	TglColor4us* = PROCEDURE{C}(red: Ushort; green: Ushort; blue: Ushort; alpha: Ushort);
	TglColor4usv* = PROCEDURE{C}( v: PUshort);
	TglColorMaterial* = PROCEDURE{C}(face: Enum; mode: Enum);
	TglColorPointer* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglCopyPixels* = PROCEDURE{C}(x: Int; y: Int; width: Sizei; height: Sizei; xtype: Enum);
	TglDeleteLists* = PROCEDURE{C}(list: Uint; range: Sizei);
	TglDisableClientState* = PROCEDURE{C}(xarray: Enum);
	TglDrawPixels* = PROCEDURE{C}(width: Sizei; height: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglEdgeFlag* = PROCEDURE{C}(flag: Boolean);
	TglEdgeFlagPointer* = PROCEDURE{C}(stride: Sizei; xpointer: PVoid);
	TglEdgeFlagv* = PROCEDURE{C}( flag: PBoolean);
	TglEnableClientState* = PROCEDURE{C}(xarray: Enum);
	TglEnd* = PROCEDURE{C}();
	TglEndList* = PROCEDURE{C}();
	TglEvalCoord1d* = PROCEDURE{C}(u: Double);
	TglEvalCoord1dv* = PROCEDURE{C}( u: PDouble);
	TglEvalCoord1f* = PROCEDURE{C}(u: Float);
	TglEvalCoord1fv* = PROCEDURE{C}( u: PFloat);
	TglEvalCoord2d* = PROCEDURE{C}(u: Double; v: Double);
	TglEvalCoord2dv* = PROCEDURE{C}( u: PDouble);
	TglEvalCoord2f* = PROCEDURE{C}(u: Float; v: Float);
	TglEvalCoord2fv* = PROCEDURE{C}( u: PFloat);
	TglEvalMesh1* = PROCEDURE{C}(mode: Enum; i1: Int; i2: Int);
	TglEvalMesh2* = PROCEDURE{C}(mode: Enum; i1: Int; i2: Int; j1: Int; j2: Int);
	TglEvalPoint1* = PROCEDURE{C}(i: Int);
	TglEvalPoint2* = PROCEDURE{C}(i: Int; j: Int);
	TglFeedbackBuffer* = PROCEDURE{C}(size: Sizei; xtype: Enum; buffer: PFloat);
	TglFogf* = PROCEDURE{C}(pname: Enum; param: Float);
	TglFogfv* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	TglFogi* = PROCEDURE{C}(pname: Enum; param: Int);
	TglFogiv* = PROCEDURE{C}(pname: Enum;  params: Pint);
	TglFrustum* = PROCEDURE{C}(left, right, bottom, top, zNear, zFar: Double);
	TglGenLists* = PROCEDURE{C}(range: Sizei): Uint;
	TglGetClipPlane* = PROCEDURE{C}(plane: Enum; equation: PDouble);
	TglGetLightfv* = PROCEDURE{C}(light: Enum; pname: Enum; params: PFloat);
	TglGetLightiv* = PROCEDURE{C}(light: Enum; pname: Enum; params: Pint);
	TglGetMapdv* = PROCEDURE{C}(target: Enum; query: Enum; v: PDouble);
	TglGetMapfv* = PROCEDURE{C}(target: Enum; query: Enum; v: PFloat);
	TglGetMapiv* = PROCEDURE{C}(target: Enum; query: Enum; v: Pint);
	TglGetMaterialfv* = PROCEDURE{C}(face: Enum; pname: Enum; params: PFloat);
	TglGetMaterialiv* = PROCEDURE{C}(face: Enum; pname: Enum; params: Pint);
	TglGetPixelMapfv* = PROCEDURE{C}(map: Enum; values: PFloat);
	TglGetPixelMapuiv* = PROCEDURE{C}(map: Enum; values: PInt);
	TglGetPixelMapusv* = PROCEDURE{C}(map: Enum; values: PUshort);
	TglGetPolygonStipple* = PROCEDURE{C}(mask: PUbyte);
	TglGetTexEnvfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetTexEnviv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetTexGendv* = PROCEDURE{C}(coord: Enum; pname: Enum; params: PDouble);
	TglGetTexGenfv* = PROCEDURE{C}(coord: Enum; pname: Enum; params: PFloat);
	TglGetTexGeniv* = PROCEDURE{C}(coord: Enum; pname: Enum; params: Pint);
	TglIndexMask* = PROCEDURE{C}(mask: Uint);
	TglIndexPointer* = PROCEDURE{C}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglIndexd* = PROCEDURE{C}(c: Double);
	TglIndexdv* = PROCEDURE{C}( c: PDouble);
	TglIndexf* = PROCEDURE{C}(c: Float);
	TglIndexfv* = PROCEDURE{C}( c: PFloat);
	TglIndexi* = PROCEDURE{C}(c: Int);
	TglIndexiv* = PROCEDURE{C}( c: Pint);
	TglIndexs* = PROCEDURE{C}(c: Short);
	TglIndexsv* = PROCEDURE{C}( c: PShort);
	TglIndexub* = PROCEDURE{C}(c: Ubyte);
	TglIndexubv* = PROCEDURE{C}( c: PUbyte);
	TglInitNames* = PROCEDURE{C}();
	TglInterleavedArrays* = PROCEDURE{C}(format: Enum; stride: Sizei;  xpointer: PVoid);
	TglIsList* = PROCEDURE{C}(list: Uint): BOOLEAN;
	TglIsTexture* = PROCEDURE{C}(texture: Uint): BOOLEAN;
	TglLightModelf* = PROCEDURE{C}(pname: Enum; param: Float);
	TglLightModelfv* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	TglLightModeli* = PROCEDURE{C}(pname: Enum; param: Int);
	TglLightModeliv* = PROCEDURE{C}(pname: Enum;  params: Pint);
	TglLightf* = PROCEDURE{C}(light: Enum; pname: Enum; param: Float);
	TglLightfv* = PROCEDURE{C}(light: Enum; pname: Enum;   params: PFloat);
	TglLighti* = PROCEDURE{C}(light: Enum; pname: Enum; param: Int);
	TglLightiv* = PROCEDURE{C}(light: Enum; pname: Enum;  params: Pint);
	TglLineStipple* = PROCEDURE{C}(factor: Int; pattern: Ushort);
	TglListBase* = PROCEDURE{C}(base: Uint);
	TglLoadIdentity* = PROCEDURE{C}();
	TglLoadMatrixd* = PROCEDURE{C}( m: PDouble);
	TglLoadMatrixf* = PROCEDURE{C}( m: PFloat);
	TglLoadName* = PROCEDURE{C}(name: Uint);
	TglMap1d* = PROCEDURE{C}(target: Enum; u1: Double; u2: Double; stride: Int; order: Int;  points: PDouble);
	TglMap1f* = PROCEDURE{C}(target: Enum; u1: Float; u2: Float; stride: Int; order: Int;  points: PFloat);
	TglMap2d* = PROCEDURE{C}(target: Enum; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int;  points: PDouble);
	TglMap2f* = PROCEDURE{C}(target: Enum; u1: Float; u2: Float; ustride: Int; uorder: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; points: PFloat);
	TglMapGrid1d* = PROCEDURE{C}(un: Int; u1: Double; u2: Double);
	TglMapGrid1f* = PROCEDURE{C}(un: Int; u1: Float; u2: Float);
	TglMapGrid2d* = PROCEDURE{C}(un: Int; u1: Double; u2: Double; vn: Int; v1: Double; v2: Double);
	TglMapGrid2f* = PROCEDURE{C}(un: Int; u1: Float; u2: Float; vn: Int; v1: Float; v2: Float);
	TglMaterialf* = PROCEDURE{C}(face: Enum; pname: Enum; param: Float);
	TglMaterialfv* = PROCEDURE{C}(face: Enum; pname: Enum;  params: PFloat);
	TglMateriali* = PROCEDURE{C}(face: Enum; pname: Enum; param: Int);
	TglMaterialiv* = PROCEDURE{C}(face: Enum; pname: Enum;  params: Pint);
	TglMatrixMode* = PROCEDURE{C}(mode: Enum);
	TglMultMatrixd* = PROCEDURE{C}( m: PDouble);
	TglMultMatrixf* = PROCEDURE{C}( m: PFloat);
	TglNewList* = PROCEDURE{C}(list: Uint; mode: Enum);
	TglNormal3b* = PROCEDURE{C}(nx: Byte; ny: Byte; nz: Byte);
	TglNormal3bv* = PROCEDURE{C}( v: PByte);
	TglNormal3d* = PROCEDURE{C}(nx: Double; ny: Double; nz: Double);
	TglNormal3dv* = PROCEDURE{C}( v: PDouble);
	TglNormal3f* = PROCEDURE{C}(nx: Float; ny: Float; nz: Float);
	TglNormal3fv* = PROCEDURE{C}( v: PFloat);
	TglNormal3i* = PROCEDURE{C}(nx: Int; ny: Int; nz: Int);
	TglNormal3iv* = PROCEDURE{C}( v: Pint);
	TglNormal3s* = PROCEDURE{C}(nx: Short; ny: Short; nz: Short);
	TglNormal3sv* = PROCEDURE{C}( v: PShort);
	TglNormalPointer* = PROCEDURE{C}(xtype: Enum; stride: Sizei;  xpointer: PVoid);
	TglOrtho* = PROCEDURE{C}(left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglPassThrough* = PROCEDURE{C}(token: Float);
	TglPixelMapfv* = PROCEDURE{C}(map: Enum; mapsize: Sizei;  values: PFloat);
	TglPixelMapuiv* = PROCEDURE{C}(map: Enum; mapsize: Sizei;  values: PInt);
	TglPixelMapusv* = PROCEDURE{C}(map: Enum; mapsize: Sizei;  values: PUshort);
	TglPixelTransferf* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPixelTransferi* = PROCEDURE{C}(pname: Enum; param: Int);
	TglPixelZoom* = PROCEDURE{C}(xfactor: Float; yfactor: Float);
	TglPolygonStipple* = PROCEDURE{C}( mask: PUbyte);
	TglPopAttrib* = PROCEDURE{C}();
	TglPopClientAttrib* = PROCEDURE{C}();
	TglPopMatrix* = PROCEDURE{C}();
	TglPopName* = PROCEDURE{C}();
	TglPrioritizeTextures* = PROCEDURE{C}(n: Sizei;  textures: PInt;  priorities: PClampf);
	TglPushAttrib* = PROCEDURE{C}(mask: Bitfield);
	TglPushClientAttrib* = PROCEDURE{C}(mask: Bitfield);
	TglPushMatrix* = PROCEDURE{C}();
	TglPushName* = PROCEDURE{C}(name: Uint);
	TglRasterPos2d* = PROCEDURE{C}(x: Double; y: Double);
	TglRasterPos2dv* = PROCEDURE{C}( v: PDouble);
	TglRasterPos2f* = PROCEDURE{C}(x: Float; y: Float);
	TglRasterPos2fv* = PROCEDURE{C}( v: PFloat);
	TglRasterPos2i* = PROCEDURE{C}(x: Int; y: Int);
	TglRasterPos2iv* = PROCEDURE{C}( v: Pint);
	TglRasterPos2s* = PROCEDURE{C}(x: Short; y: Short);
	TglRasterPos2sv* = PROCEDURE{C}( v: PShort);
	TglRasterPos3d* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglRasterPos3dv* = PROCEDURE{C}( v: PDouble);
	TglRasterPos3f* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglRasterPos3fv* = PROCEDURE{C}( v: PFloat);
	TglRasterPos3i* = PROCEDURE{C}(x: Int; y: Int; z: Int);
	TglRasterPos3iv* = PROCEDURE{C}( v: Pint);
	TglRasterPos3s* = PROCEDURE{C}(x: Short; y: Short; z: Short);
	TglRasterPos3sv* = PROCEDURE{C}( v: PShort);
	TglRasterPos4d* = PROCEDURE{C}(x: Double; y: Double; z: Double; w: Double);
	TglRasterPos4dv* = PROCEDURE{C}( v: PDouble);
	TglRasterPos4f* = PROCEDURE{C}(x: Float; y: Float; z: Float; w: Float);
	TglRasterPos4fv* = PROCEDURE{C}( v: PFloat);
	TglRasterPos4i* = PROCEDURE{C}(x: Int; y: Int; z: Int; w: Int);
	TglRasterPos4iv* = PROCEDURE{C}( v: Pint);
	TglRasterPos4s* = PROCEDURE{C}(x: Short; y: Short; z: Short; w: Short);
	TglRasterPos4sv* = PROCEDURE{C}( v: PShort);
	TglRectd* = PROCEDURE{C}(x1: Double; y1: Double; x2: Double; y2: Double);
	TglRectdv* = PROCEDURE{C}( v1: PDouble;  v2: PDouble);
	TglRectf* = PROCEDURE{C}(x1: Float; y1: Float; x2: Float; y2: Float);
	TglRectfv* = PROCEDURE{C}( v1: PFloat;  v2: PFloat);
	TglRecti* = PROCEDURE{C}(x1: Int; y1: Int; x2: Int; y2: Int);
	TglRectiv* = PROCEDURE{C}( v1: Pint;  v2: Pint);
	TglRects* = PROCEDURE{C}(x1: Short; y1: Short; x2: Short; y2: Short);
	TglRectsv* = PROCEDURE{C}( v1: PShort;  v2: PShort);
	TglRenderMode* = PROCEDURE{C}(mode: Enum): Int;
	TglRotated* = PROCEDURE{C}(angle, x, y, z: Double);
	TglRotatef* = PROCEDURE{C}( angle, x, y, z: Float);
	TglScaled* = PROCEDURE{C}(x, y, z: Double);
	TglScalef* = PROCEDURE{C}(x, y, z: Float);
	TglSelectBuffer* = PROCEDURE{C}(size: Sizei; buffer: PInt);
	TglShadeModel* = PROCEDURE{C}(mode: Enum);
	TglTexCoord1d* = PROCEDURE{C}(s: Double);
	TglTexCoord1dv* = PROCEDURE{C}( v: PDouble);
	TglTexCoord1f* = PROCEDURE{C}(s: Float);
	TglTexCoord1fv* = PROCEDURE{C}( v: PFloat);
	TglTexCoord1i* = PROCEDURE{C}(s: Int);
	TglTexCoord1iv* = PROCEDURE{C}( v: Pint);
	TglTexCoord1s* = PROCEDURE{C}(s: Short);
	TglTexCoord1sv* = PROCEDURE{C}( v: PShort);
	TglTexCoord2d* = PROCEDURE{C}(s: Double; t: Double);
	TglTexCoord2dv* = PROCEDURE{C}( v: PDouble);
	TglTexCoord2f* = PROCEDURE{C}(s: Float; t: Float);
	TglTexCoord2fv* = PROCEDURE{C}( v: PFloat);
	TglTexCoord2i* = PROCEDURE{C}(s: Int; t: Int);
	TglTexCoord2iv* = PROCEDURE{C}( v: Pint);
	TglTexCoord2s* = PROCEDURE{C}(s: Short; t: Short);
	TglTexCoord2sv* = PROCEDURE{C}( v: PShort);
	TglTexCoord3d* = PROCEDURE{C}(s: Double; t: Double; r: Double);
	TglTexCoord3dv* = PROCEDURE{C}( v: PDouble);
	TglTexCoord3f* = PROCEDURE{C}(s: Float; t: Float; r: Float);
	TglTexCoord3fv* = PROCEDURE{C}( v: PFloat);
	TglTexCoord3i* = PROCEDURE{C}(s: Int; t: Int; r: Int);
	TglTexCoord3iv* = PROCEDURE{C}( v: Pint);
	TglTexCoord3s* = PROCEDURE{C}(s: Short; t: Short; r: Short);
	TglTexCoord3sv* = PROCEDURE{C}( v: PShort);
	TglTexCoord4d* = PROCEDURE{C}(s: Double; t: Double; r: Double; q: Double);
	TglTexCoord4dv* = PROCEDURE{C}( v: PDouble);
	TglTexCoord4f* = PROCEDURE{C}(s: Float; t: Float; r: Float; q: Float);
	TglTexCoord4fv* = PROCEDURE{C}( v: PFloat);
	TglTexCoord4i* = PROCEDURE{C}(s: Int; t: Int; r: Int; q: Int);
	TglTexCoord4iv* = PROCEDURE{C}( v: Pint);
	TglTexCoord4s* = PROCEDURE{C}(s: Short; t: Short; r: Short; q: Short);
	TglTexCoord4sv* = PROCEDURE{C}( v: PShort);
	TglTexCoordPointer* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglTexEnvf* = PROCEDURE{C}(target: Enum; pname: Enum; param: Float);
	TglTexEnvfv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglTexEnvi* = PROCEDURE{C}(target: Enum; pname: Enum; param: Int);
	TglTexEnviv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglTexGend* = PROCEDURE{C}(coord: Enum; pname: Enum; param: Double);
	TglTexGendv* = PROCEDURE{C}(coord: Enum; pname: Enum;  params: PDouble);
	TglTexGenf* = PROCEDURE{C}(coord: Enum; pname: Enum; param: Float);
	TglTexGenfv* = PROCEDURE{C}(coord: Enum; pname: Enum;  params: PFloat);
	TglTexGeni* = PROCEDURE{C}(coord: Enum; pname: Enum; param: Int);
	TglTexGeniv* = PROCEDURE{C}(coord: Enum; pname: Enum;  params: Pint);
	TglTranslated* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglTranslatef* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglVertex2d* = PROCEDURE{C}(x: Double; y: Double);
	TglVertex2dv* = PROCEDURE{C}( v: PDouble);
	TglVertex2f* = PROCEDURE{C}(x: Float; y: Float);
	TglVertex2fv* = PROCEDURE{C}( v: PFloat);
	TglVertex2i* = PROCEDURE{C}(x: Int; y: Int);
	TglVertex2iv* = PROCEDURE{C}( v: Pint);
	TglVertex2s* = PROCEDURE{C}(x: Short; y: Short);
	TglVertex2sv* = PROCEDURE{C}( v: PShort);
	TglVertex3d* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglVertex3dv* = PROCEDURE{C}( v: PDouble);
	TglVertex3f* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglVertex3fv* = PROCEDURE{C}( v: PFloat);
	TglVertex3i* = PROCEDURE{C}(x: Int; y: Int; z: Int);
	TglVertex3iv* = PROCEDURE{C}( v: Pint);
	TglVertex3s* = PROCEDURE{C}(x: Short; y: Short; z: Short);
	TglVertex3sv* = PROCEDURE{C}( v: PShort);
	TglVertex4d* = PROCEDURE{C}(x: Double; y: Double; z: Double; w: Double);
	TglVertex4dv* = PROCEDURE{C}( v: PDouble);
	TglVertex4f* = PROCEDURE{C}(x: Float; y: Float; z: Float; w: Float);
	TglVertex4fv* = PROCEDURE{C}( v: PFloat);
	TglVertex4i* = PROCEDURE{C}(x: Int; y: Int; z: Int; w: Int);
	TglVertex4iv* = PROCEDURE{C}( v: Pint);
	TglVertex4s* = PROCEDURE{C}(x: Short; y: Short; z: Short; w: Short);
	TglVertex4sv* = PROCEDURE{C}( v: PShort);
	TglVertexPointer* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(*! endif  *)

	(*! GL_VERSION_1_2  *)
	TglBlendColor* = PROCEDURE{C}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	TglBlendEquation* = PROCEDURE{C}(mode: Enum);
	TglDrawRangeElements* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum;  indices: PVoid);
	TglTexImage3D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Int; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTexSubImage3D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglCopyTexSubImage3D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);

	(*! ifdef DEPRECATED 1.2  *)
	TglColorTable* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum;  table: PVoid);
	TglColorTableParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglColorTableParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglCopyColorTable* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglGetColorTable* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; table: PVoid);
	TglGetColorTableParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetColorTableParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglColorSubTable* = PROCEDURE{C}(target: Enum; start: Sizei; count: Sizei; format: Enum; xtype: Enum;  data: PVoid);
	TglCopyColorSubTable* = PROCEDURE{C}(target: Enum; start: Sizei; x: Int; y: Int; width: Sizei);
	TglConvolutionFilter1D* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum;  image: PVoid);
	TglConvolutionFilter2D* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  image: PVoid);
	TglConvolutionParameterf* = PROCEDURE{C}(target: Enum; pname: Enum; params: Float);
	TglConvolutionParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglConvolutionParameteri* = PROCEDURE{C}(target: Enum; pname: Enum; params: Int);
	TglConvolutionParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglCopyConvolutionFilter1D* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglCopyConvolutionFilter2D* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetConvolutionFilter* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; image: PVoid);
	TglGetConvolutionParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetConvolutionParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetSeparableFilter* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; row: PVoid; column: PVoid; span: PVoid);
	TglSeparableFilter2D* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  row: PVoid;  column: PVoid);
	TglGetHistogram* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetHistogramParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetHistogramParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetMinmax* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetMinmaxParameterfv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetMinmaxParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglHistogram* = PROCEDURE{C}(target: Enum; width: Sizei; internalformat: Enum; sink: Boolean);
	TglMinmax* = PROCEDURE{C}(target: Enum; internalformat: Enum; sink: Boolean);
	TglResetHistogram* = PROCEDURE{C}(target: Enum);
	TglResetMinmax* = PROCEDURE{C}(target: Enum);
	(*! endif  *)

	(*! GL_VERSION_1_3  *)
	TglActiveTexture* = PROCEDURE{C}(texture: Enum);
	TglSampleCoverage* = PROCEDURE{C}(value: Clampf; invert: Boolean);
	TglCompressedTexImage3D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexImage2D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexImage1D* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage3D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage2D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage1D* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglGetCompressedTexImage* = PROCEDURE{C}(target: Enum; level: Int; img: PVoid);

	(*! ifdef DEPRECATED 1.3  *)
	TglClientActiveTexture* = PROCEDURE{C}(texture: Enum);
	TglMultiTexCoord1d* = PROCEDURE{C}(target: Enum; s: Double);
	TglMultiTexCoord1dv* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord1f* = PROCEDURE{C}(target: Enum; s: Float);
	TglMultiTexCoord1fv* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord1i* = PROCEDURE{C}(target: Enum; s: Int);
	TglMultiTexCoord1iv* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord1s* = PROCEDURE{C}(target: Enum; s: Short);
	TglMultiTexCoord1sv* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord2d* = PROCEDURE{C}(target: Enum; s: Double; t: Double);
	TglMultiTexCoord2dv* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord2f* = PROCEDURE{C}(target: Enum; s: Float; t: Float);
	TglMultiTexCoord2fv* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord2i* = PROCEDURE{C}(target: Enum; s: Int; t: Int);
	TglMultiTexCoord2iv* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord2s* = PROCEDURE{C}(target: Enum; s: Short; t: Short);
	TglMultiTexCoord2sv* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord3d* = PROCEDURE{C}(target: Enum; s: Double; t: Double; r: Double);
	TglMultiTexCoord3dv* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord3f* = PROCEDURE{C}(target: Enum; s: Float; t: Float; r: Float);
	TglMultiTexCoord3fv* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord3i* = PROCEDURE{C}(target: Enum; s: Int; t: Int; r: Int);
	TglMultiTexCoord3iv* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord3s* = PROCEDURE{C}(target: Enum; s: Short; t: Short; r: Short);
	TglMultiTexCoord3sv* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord4d* = PROCEDURE{C}(target: Enum; s: Double; t: Double; r: Double; q: Double);
	TglMultiTexCoord4dv* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord4f* = PROCEDURE{C}(target: Enum; s: Float; t: Float; r: Float; q: Float);
	TglMultiTexCoord4fv* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord4i* = PROCEDURE{C}(target: Enum; s: Int; t: Int; r: Int; q: Int);
	TglMultiTexCoord4iv* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord4s* = PROCEDURE{C}(target: Enum; s: Short; t: Short; r: Short; q: Short);
	TglMultiTexCoord4sv* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglLoadTransposeMatrixf* = PROCEDURE{C}( m: PFloat);
	TglLoadTransposeMatrixd* = PROCEDURE{C}( m: PDouble);
	TglMultTransposeMatrixf* = PROCEDURE{C}( m: PFloat);
	TglMultTransposeMatrixd* = PROCEDURE{C}( m: PDouble);
	(*! endif  *)

      (*! GL_VERSION_1_4  *)
	TglBlendFuncSeparate* = PROCEDURE{C}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);
	TglMultiDrawArrays* = PROCEDURE{C}(mode: Enum; first: Pint; count: PSizei; primcount: Sizei);
	TglMultiDrawElements* = PROCEDURE{C}(mode: Enum;  count: PSizei; xtype: Enum;  indices: PVoid; primcount: Sizei);
	TglPointParameterf* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPointParameterfv* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	TglPointParameteri* = PROCEDURE{C}(pname: Enum; param: Int);
	TglPointParameteriv* = PROCEDURE{C}(pname: Enum;  params: Pint);

	(*! ifdef DEPRECATED 1.4  *)
	TglFogCoordf* = PROCEDURE{C}(coord: Float);
	TglFogCoordfv* = PROCEDURE{C}( coord: PFloat);
	TglFogCoordd* = PROCEDURE{C}(coord: Double);
	TglFogCoorddv* = PROCEDURE{C}( coord: PDouble);
	TglFogCoordPointer* = PROCEDURE{C}(xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglSecondaryColor3b* = PROCEDURE{C}(red: Byte; green: Byte; blue: Byte);
	TglSecondaryColor3bv* = PROCEDURE{C}( v: PByte);
	TglSecondaryColor3d* = PROCEDURE{C}(red: Double; green: Double; blue: Double);
	TglSecondaryColor3dv* = PROCEDURE{C}( v: PDouble);
	TglSecondaryColor3f* = PROCEDURE{C}(red: Float; green: Float; blue: Float);
	TglSecondaryColor3fv* = PROCEDURE{C}( v: PFloat);
	TglSecondaryColor3i* = PROCEDURE{C}(red: Int; green: Int; blue: Int);
	TglSecondaryColor3iv* = PROCEDURE{C}( v: Pint);
	TglSecondaryColor3s* = PROCEDURE{C}(red: Short; green: Short; blue: Short);
	TglSecondaryColor3sv* = PROCEDURE{C}( v: PShort);
	TglSecondaryColor3ub* = PROCEDURE{C}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglSecondaryColor3ubv* = PROCEDURE{C}( v: PUbyte);
	TglSecondaryColor3ui* = PROCEDURE{C}(red: Uint; green: Uint; blue: Uint);
	TglSecondaryColor3uiv* = PROCEDURE{C}( v: PInt);
	TglSecondaryColor3us* = PROCEDURE{C}(red: Ushort; green: Ushort; blue: Ushort);
	TglSecondaryColor3usv* = PROCEDURE{C}( v: PUshort);
	TglSecondaryColorPointer* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglWindowPos2d* = PROCEDURE{C}(x: Double; y: Double);
	TglWindowPos2dv* = PROCEDURE{C}( v: PDouble);
	TglWindowPos2f* = PROCEDURE{C}(x: Float; y: Float);
	TglWindowPos2fv* = PROCEDURE{C}( v: PFloat);
	TglWindowPos2i* = PROCEDURE{C}(x: Int; y: Int);
	TglWindowPos2iv* = PROCEDURE{C}( v: Pint);
	TglWindowPos2s* = PROCEDURE{C}(x: Short; y: Short);
	TglWindowPos2sv* = PROCEDURE{C}( v: PShort);
	TglWindowPos3d* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglWindowPos3dv* = PROCEDURE{C}( v: PDouble);
	TglWindowPos3f* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglWindowPos3fv* = PROCEDURE{C}( v: PFloat);
	TglWindowPos3i* = PROCEDURE{C}(x: Int; y: Int; z: Int);
	TglWindowPos3iv* = PROCEDURE{C}( v: Pint);
	TglWindowPos3s* = PROCEDURE{C}(x: Short; y: Short; z: Short);
	TglWindowPos3sv* = PROCEDURE{C}( v: PShort);
	(*! endif  *)

	(*! GL_VERSION_1_5  *)
	TglGenQueries* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglDeleteQueries* = PROCEDURE{C}(n: Sizei;  ids: PInt);
	TglIsQuery* = PROCEDURE{C}(id: Uint): BOOLEAN;
	TglBeginQuery* = PROCEDURE{C}(target: Enum; id: Uint);
	TglEndQuery* = PROCEDURE{C}(target: Enum);
	TglGetQueryiv* = PROCEDURE{C}(target, pname: Enum; params: Pint);
	TglGetQueryObjectiv* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint);
	TglGetQueryObjectuiv* = PROCEDURE{C}(id: Uint; pname: Enum; params: PInt);
	TglBindBuffer* = PROCEDURE{C}(target: Enum; buffer: Uint);
	TglDeleteBuffers* = PROCEDURE{C}(n: Sizei;  buffers: PInt );
	TglGenBuffers* = PROCEDURE{C}(n: Sizei;  buffers: PInt);
	TglIsBuffer* = PROCEDURE{C}(buffer: Uint): Boolean;
	TglBufferData* = PROCEDURE{C}(target: Enum; size: Sizei;  data: ADDRESS; usage: Enum);
	TglBufferSubData* = PROCEDURE{C}(target: Enum; offset: Sizei; size: Sizei;  data: PVoid);
	TglGetBufferSubData* = PROCEDURE{C}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglMapBuffer* = PROCEDURE{C}(target: Enum; access: Enum): PVoid;
	TglUnmapBuffer* = PROCEDURE{C}(target: Enum): Boolean;
	TglGetBufferParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetBufferPointerv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PVoid);

	(*! GL_VERSION_2_0  *)
	TglBlendEquationSeparate* = PROCEDURE{C}(modeRGB: Enum; modeAlpha: Enum);
	TglDrawBuffers* = PROCEDURE{C}(n: Sizei;  bufs: PEnum);
	TglStencilOpSeparate* = PROCEDURE{C}(face: Enum; sfail: Enum; dpfail: Enum; dppass: Enum);
	TglStencilFuncSeparate* = PROCEDURE{C}(frontfunc: Enum; backfunc: Enum; ref: Int; mask: Uint);
	TglStencilMaskSeparate* = PROCEDURE{C}(face: Enum; mask: Uint);
	TglAttachShader* = PROCEDURE{C}(programObj, shaderObj: Handle);
	TglBindAttribLocation* = PROCEDURE{C}(programObj: Handle; index: Uint;  name: ADDRESS);
	TglCompileShader* = PROCEDURE{C}(shaderObj: Handle);
	TglCreateProgram* = PROCEDURE{C}(): Handle;
	TglCreateShader* = PROCEDURE{C}(shaderType: Enum): Handle;
	TglDeleteProgram* = PROCEDURE{C}(programObj: Handle);
	TglDeleteShader* = PROCEDURE{C}(shaderObj: Handle);
	TglDetachShader* = PROCEDURE{C}(programObj, shaderObj: Handle);
	TglDisableVertexAttribArray* = PROCEDURE{C}(index: Uint);
	TglEnableVertexAttribArray* = PROCEDURE{C}(index: Uint);
	TglGetActiveAttrib* = PROCEDURE{C}(programObj: Handle; index: Uint; maxlength: Sizei; VAR length: Int; VAR size: Int; VAR xtype: Enum; name: PChar);
	TglGetActiveUniform* = PROCEDURE{C}(programObj: Handle; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PChar);
	TglGetAttachedShaders* = PROCEDURE{C}(programObj: Handle; MaxCount: Sizei; VAR Count: Int; shaders: PInt);
	TglGetAttribLocation* = PROCEDURE{C}(programObj: Handle;  chars: ADDRESS): Int;
	TglGetProgramiv* = PROCEDURE{C}(programObj: Handle; pname: Enum; params: Pint);
	TglGetProgramInfoLog* = PROCEDURE{C}(programObj: Handle; maxLength: Sizei; VAR length: Int; infoLog: PChar);
	TglGetShaderiv* = PROCEDURE{C}(shaderObj: Handle; pname: Enum; params: Pint);
	TglGetShaderInfoLog* = PROCEDURE{C}(shaderObj: Handle; maxLength: Sizei; VAR length: Int; infoLog: PChar);
	TglGetShaderSource* = PROCEDURE{C}(shaderObj: Handle; maxlength: Sizei; VAR length: Sizei; source: PChar);
	TglGetUniformLocation* = PROCEDURE{C}(programObj: Handle;  chars: ADDRESS): Int;
	TglGetUniformfv* = PROCEDURE{C}(programObj: Handle; location: Int; params: PFloat);
	TglGetUniformiv* = PROCEDURE{C}(programObj: Handle; location: Int; params: Pint);
	TglGetVertexAttribfv* = PROCEDURE{C}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribiv* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribPointerv* = PROCEDURE{C}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgram* = PROCEDURE{C}(programObj: Handle) : Boolean;
	TglIsShader* = PROCEDURE{C}(shaderObj: Handle) : Boolean;
	TglLinkProgram* = PROCEDURE{C}(programObj: Handle);
	TglShaderSource* = PROCEDURE{C}(shaderObj: Handle; count: Sizei; xstring: PChar; lengths: Pint);
	TglUseProgram* = PROCEDURE{C}(programObj: Handle);
	TglUniform1f* = PROCEDURE{C}(location: Int; v0: Float);
	TglUniform2f* = PROCEDURE{C}(location: Int; v0, v1: Float);
	TglUniform3f* = PROCEDURE{C}(location: Int; v0, v1, v2: Float);
	TglUniform4f* = PROCEDURE{C}(location: Int; v0, v1, v2, v3: Float);
	TglUniform1i* = PROCEDURE{C}(location: Int; v0: Int);
	TglUniform2i* = PROCEDURE{C}(location: Int; v0, v1: Int);
	TglUniform3i* = PROCEDURE{C}(location: Int; v0, v1, v2: Int);
	TglUniform4i* = PROCEDURE{C}(location: Int; v0, v1, v2, v3: Int);
	TglUniform1fv* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform2fv* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform3fv* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform4fv* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform1iv* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform2iv* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform3iv* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform4iv* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniformMatrix2fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglValidateProgram* = PROCEDURE{C}(programObj: Handle);
	TglVertexAttrib1d* = PROCEDURE{C}(index: Uint; x: Double);
	TglVertexAttrib1dv* = PROCEDURE{C}(index: Uint;   v: PDouble);
	TglVertexAttrib1f* = PROCEDURE{C}(index: Uint; x: Float);
	TglVertexAttrib1fv* = PROCEDURE{C}(index: Uint;   v: PFloat);
	TglVertexAttrib1s* = PROCEDURE{C}(index: Uint; x: Short);
	TglVertexAttrib1sv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib2d* = PROCEDURE{C}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib2f* = PROCEDURE{C}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fv* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib2s* = PROCEDURE{C}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2sv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib3d* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib3f* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fv* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib3s* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3sv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4Nbv* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttrib4Niv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttrib4Nsv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4Nub* = PROCEDURE{C}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4Nubv* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttrib4Nuiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttrib4Nusv* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglVertexAttrib4bv* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttrib4d* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib4f* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fv* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib4iv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttrib4s* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4sv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4ubv* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttrib4uiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttrib4usv* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglVertexAttribPointer* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei;  xpointer: PVoid);

	(*! GL_VERSION_2_1  *)
	TglUniformMatrix2x3fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3x2fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix2x4fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4x2fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3x4fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4x3fv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);

	(*! GL_VERSION_3_0  *)
	(* OpenGL 3.0 also reuses entry points from these extensions: *)
	(* ARB_framebuffer_object *)
	(* ARB_map_buffer_range *)
	(* ARB_vertex_array_object *)
	TglColorMaski* = PROCEDURE{C}(index: Uint; r: Boolean; g: Boolean; b: Boolean; a: Boolean);
	TglGetBooleani_v* = PROCEDURE{C}(target: Enum; index: Uint; data: PBoolean);
	TglGetIntegeri_v* = PROCEDURE{C}(target: Enum; index: Uint; data: Pint);
	TglEnablei* = PROCEDURE{C}(target: Enum; index: Uint);
	TglDisablei* = PROCEDURE{C}(target: Enum; index: Uint);
	TglIsEnabledi* = PROCEDURE{C}(target: Enum; index: Uint): Boolean;
	TglBeginTransformFeedback* = PROCEDURE{C}(primitiveMode: Enum);
	TglEndTransformFeedback* = PROCEDURE{C}();
	TglBindBufferRange* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint; offset: Sizei; size: Sizei);
	TglBindBufferBase* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryings* = PROCEDURE{C}(xprogram: Uint; count: Sizei;  varyings: PPChar; bufferMode: Enum);
	TglGetTransformFeedbackVarying* = PROCEDURE{C}(xprogram: Uint; index: Uint; bufSize: Sizei; length: PSizei; size: PSizei; xtype: PSizei; name: PChar);
	TglClampColor* = PROCEDURE{C}(targe: Enum; clamp: Enum);
	TglBeginConditionalRender* = PROCEDURE{C}(id: Uint; mode: Enum);
	TglEndConditionalRender* = PROCEDURE{C}();
	TglVertexAttribIPointer* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei;  pointer: PVoid);
	TglGetVertexAttribIiv* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribIuiv* = PROCEDURE{C}(index: Uint; pname: Enum; params: PInt);
	TglVertexAttribI1i* = PROCEDURE{C}(index: Uint; x: Int);
	TglVertexAttribI2i* = PROCEDURE{C}(index: Uint; x: Int; y: Int);
	TglVertexAttribI3i* = PROCEDURE{C}(index: Uint; x: Int; y: Int; z: Int);
	TglVertexAttribI4i* = PROCEDURE{C}(index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglVertexAttribI1ui* = PROCEDURE{C}(index: Uint; x: Uint);
	TglVertexAttribI2ui* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint);
	TglVertexAttribI3ui* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint; z: Uint);
	TglVertexAttribI4ui* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglVertexAttribI1iv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI2iv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI3iv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI4iv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI1uiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI2uiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI3uiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI4uiv* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI4bv* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttribI4sv* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttribI4ubv* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttribI4usv* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglGetUniformuiv* = PROCEDURE{C}(xprogram: Uint; location: Int; params: PInt);
	TglBindFragDataLocation* = PROCEDURE{C}(xprogram: Uint; color: Uint;  name: ADDRESS);
	TglGetFragDataLocation* = PROCEDURE{C}(xprogram: Uint;  name: ADDRESS): Int;
	TglUniform1ui* = PROCEDURE{C}(location: Int; v0: Uint);
	TglUniform2ui* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint);
	TglUniform3ui* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglUniform4ui* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglUniform1uiv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform2uiv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform3uiv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform4uiv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglTexParameterIiv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglTexParameterIuiv* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PInt);
	TglGetTexParameterIiv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetTexParameterIuiv* = PROCEDURE{C}(target: Enum; pname: Enum; params: PInt);
	TglClearBufferiv* = PROCEDURE{C}(buffer: Enum; drawbuffer: Int;  value: Pint);
	TglClearBufferuiv* = PROCEDURE{C}(buffer: Enum; drawbuffer: Int;  value: PInt);
	TglClearBufferfv* = PROCEDURE{C}(buffer: Enum; drawbuffer: Int;  value: PFloat);
	TglClearBufferfi* = PROCEDURE{C}(buffer: Enum; drawbuffer: Int; depth: Float; stencil: Int);
	TglGetStringi* = PROCEDURE{C}(name: Enum; index: Uint): PUbyte;

	(*! GL_VERSION_3_1  *)
	(* OpenGL 3.1 also reuses entry points from these extensions: *)
	(* ARB_copy_buffer *)
	(* ARB_uniform_buffer_object *)
	TglDrawArraysInstanced* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstanced* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: PVoid; primcount: Sizei);
	TglTexBuffer* = PROCEDURE{C}(target: Enum; internalformat: Enum; buffer: Uint);
	TglPrimitiveRestartIndex* = PROCEDURE{C}(index: Uint);

	(*! GL_VERSION_3_2  *)
	(* OpenGL 3.2 also reuses entry points from these extensions: *)
	(* ARB_draw_elements_base_vertex *)
	(* ARB_provoking_vertex *)
	(* ARB_sync *)
	(* ARB_texture_multisample *)
	TglGetInteger64i_v* = PROCEDURE{C}(target: Enum; index: Uint; data: Pint64);
	TglGetBufferParameteri64v* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint64);
	TglFramebufferTexture* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	(* TglFramebufferTextureFace  = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum);  *)

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
	TglVertexAttribDivisor* = PROCEDURE{C}(index: Uint; divisor: Uint);

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
	TglMinSampleShading* = PROCEDURE{C}(value: Clampf);
	TglBlendEquationi* = PROCEDURE{C}(buf: Uint; mode: Enum);
	TglBlendEquationSeparatei* = PROCEDURE{C}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	TglBlendFunci* = PROCEDURE{C}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparatei* = PROCEDURE{C}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);

	(*! GL_VERSION_4_1  *)
	(* OpenGL 4.1 also reuses entry points from these extensions:  *)
	(* ARB_ES2_compatibility  *)
	(* ARB_get_program_binary  *)
	(* ARB_separate_shader_objects  *)
	(* ARB_shader_precision (no entry points)  *)
	(* ARB_vertex_attrib_64bit  *)
	(* ARB_viewport_array  *)
	(* GL_3DFX_tbuffer  *)
	TglTbufferMask3DFX* = PROCEDURE{C}(mask: Uint);
	(* GL_APPLE_element_array  *)
	TglElementPointerAPPLE* = PROCEDURE{C}(xtype:  Enum; xpointer: PVoid);
	TglDrawElementArrayAPPLE* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei);
	TglDrawRangeElementArrayAPPLE* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint; first: Int; count: Sizei);
	TglMultiDrawElementArrayAPPLE* = PROCEDURE{C}(mode: Enum;  first: Pint;  count: PSizei; primcount: Sizei);
	TglMultiDrawRangeElementArrayAPPLE* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint;  first: Pint; count: PSizei; primcount: Sizei);
	(* GL_APPLE_fence  *)
	TglGenFencesAPPLE* = PROCEDURE{C}(n: Sizei; fences: PInt);
	TglDeleteFencesAPPLE* = PROCEDURE{C}(n: Sizei; fences: PInt);
	TglSetFenceAPPLE* = PROCEDURE{C}(fence: Uint);
	TglIsFenceAPPLE* = PROCEDURE{C}(fence: Uint): Boolean;
	TglTestFenceAPPLE* = PROCEDURE{C}(fence: Uint): Boolean;
	TglFinishFenceAPPLE* = PROCEDURE{C}(fence: Uint);
	TglTestObjectAPPLE* = PROCEDURE{C}(xobject: Enum; name: Uint): Boolean;
	TglFinishObjectAPPLE* = PROCEDURE{C}(xobject: Enum; name: Int);
	(* GL_APPLE_vertex_array_object  *)
	TglBindVertexArrayAPPLE* = PROCEDURE{C}(xarray: Uint);
	TglDeleteVertexArraysAPPLE* = PROCEDURE{C}(n: Sizei; xarrays: PInt);
	TglGenVertexArraysAPPLE* = PROCEDURE{C}(n: Sizei; xarrays: PInt);
	TglIsVertexArrayAPPLE* = PROCEDURE{C}(narray: Uint): Boolean;
	(*  GL_APPLE_vertex_array_range  *)
	TglVertexArrayRangeAPPLE* = PROCEDURE{C}(length: Sizei; xpointer: PVoid);
	TglFlushVertexArrayRangeAPPLE* = PROCEDURE{C}(length: Sizei; xpointer: PVoid);
	TglVertexArrayParameteriAPPLE* = PROCEDURE{C}(pname: Enum; param: Int);
	(*  GL_APPLE_texture_range  *)
	TglTextureRangeAPPLE* = PROCEDURE{C}(target: Enum; xlength: Sizei; xpointer: PVoid);
	TglGetTexParameterPointervAPPLE* = PROCEDURE{C}(target: Enum; pname: Enum; params: PPVoid);
	(*  GL_APPLE_vertex_program_evaluators  *)
	TglEnableVertexAttribAPPLE* = PROCEDURE{C}(indexx: Uint; pname: Enum);
	TglDisableVertexAttribAPPLE* = PROCEDURE{C}(indexx: Uint; pname: Enum);
	TglIsVertexAttribEnabledAPPLE* = PROCEDURE{C}(indexx: Uint; pname: Enum): Boolean;
	TglMapVertexAttrib1dAPPLE* = PROCEDURE{C}(indexx: Uint; size: Uint; u1: Double; u2: Double; stride: Int; order: Int; points: PDouble);
	TglMapVertexAttrib1fAPPLE* = PROCEDURE{C}(indexx: Uint; size: Uint; u1: Float; u2: Float; stride: Int; order: Int; points: PFloat);
	TglMapVertexAttrib2dAPPLE* = PROCEDURE{C}(indexx: Uint; size: Uint; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int; points: PDouble);
	TglMapVertexAttrib2fAPPLE* = PROCEDURE{C}(indexx: Uint; size: Uint; u1: Float; u2: Float; ustride: Int; order: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; points: Float);
	(*  GL_APPLE_object_purgeable  *)
	TglObjectPurgeableAPPLE* = PROCEDURE{C}(objectType: Enum; name: Uint; option: Enum): Enum;
	TglObjectUnpurgeableAPPLE* = PROCEDURE{C}(objectType: Enum; name: Uint; option: Enum): Enum;
	TglGetObjectParameterivAPPLE* = PROCEDURE{C}(objectType: Enum; name: Uint; pname: Enum; params: Pint);
	(* GL_ARB_matrix_palette  *)
	TglCurrentPaletteMatrixARB* = PROCEDURE{C}(index: Int);
	TglMatrixIndexubvARB* = PROCEDURE{C}(size: Int;  indices: PUbyte);
	TglMatrixIndexusvARB* = PROCEDURE{C}(size: Int;  indices: PUshort);
	TglMatrixIndexuivARB* = PROCEDURE{C}(size: Int;  indices: PInt);
	TglMatrixIndexPointerARB* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(* GL_ARB_multisample  *)
	TglSampleCoverageARB* = PROCEDURE{C}(value: Clampf; invert: Boolean);
	(* GL_ARB_multitexture  *)
	TglActiveTextureARB* = PROCEDURE{C}(texture: Enum);
	TglClientActiveTextureARB* = PROCEDURE{C}(texture: Enum);
	TglMultiTexCoord1dARB* = PROCEDURE{C}(target: Enum; s: Double);
	TglMultiTexCoord1dvARB* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord1fARB* = PROCEDURE{C}(target: Enum; s: Float);
	TglMultiTexCoord1fvARB* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord1iARB* = PROCEDURE{C}(target: Enum; s: Int);
	TglMultiTexCoord1ivARB* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord1sARB* = PROCEDURE{C}(target: Enum; s: Short);
	TglMultiTexCoord1svARB* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord2dARB* = PROCEDURE{C}(target: Enum; s: Double; t: Double);
	TglMultiTexCoord2dvARB* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord2fARB* = PROCEDURE{C}(target: Enum; s: Float; t: Float);
	TglMultiTexCoord2fvARB* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord2iARB* = PROCEDURE{C}(target: Enum; s: Int; t: Int);
	TglMultiTexCoord2ivARB* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord2sARB* = PROCEDURE{C}(target: Enum; s: Short; t: Short);
	TglMultiTexCoord2svARB* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord3dARB* = PROCEDURE{C}(target: Enum; s: Double; t: Double; r: Double);
	TglMultiTexCoord3dvARB* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord3fARB* = PROCEDURE{C}(target: Enum; s: Float; t: Float; r: Float);
	TglMultiTexCoord3fvARB* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord3iARB* = PROCEDURE{C}(target: Enum; s: Int; t: Int; r: Int);
	TglMultiTexCoord3ivARB* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord3sARB* = PROCEDURE{C}(target: Enum; s: Short; t: Short; r: Short);
	TglMultiTexCoord3svARB* = PROCEDURE{C}(target: Enum;  v: PShort);
	TglMultiTexCoord4dARB* = PROCEDURE{C}(target: Enum; s: Double; t: Double; r: Double; q: Double);
	TglMultiTexCoord4dvARB* = PROCEDURE{C}(target: Enum;  v: PDouble);
	TglMultiTexCoord4fARB* = PROCEDURE{C}(target: Enum; s: Float; t: Float; r: Float; q: Float);
	TglMultiTexCoord4fvARB* = PROCEDURE{C}(target: Enum;  v: PFloat);
	TglMultiTexCoord4iARB* = PROCEDURE{C}(target: Enum; s: Int; t: Int; r: Int; q: Int);
	TglMultiTexCoord4ivARB* = PROCEDURE{C}(target: Enum;  v: Pint);
	TglMultiTexCoord4sARB* = PROCEDURE{C}(target: Enum; s: Short; t: Short; r: Short; q: Short);
	TglMultiTexCoord4svARB* = PROCEDURE{C}(target: Enum;  v: PShort);
	(* GL_ARB_point_parameters  *)
	TglPointParameterfARB* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPointParameterfvARB* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	(* GL_ARB_texture_compression  *)
	TglCompressedTexImage3DARB* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexImage2DARB* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexImage1DARB* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage3DARB* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage2DARB* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglCompressedTexSubImage1DARB* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei;  data: PVoid);
	TglGetCompressedTexImageARB* = PROCEDURE{C}(target: Enum; level: Int; img: PVoid);
	(* GL_ARB_transpose_matrix  *)
	TglLoadTransposeMatrixfARB* = PROCEDURE{C}( m: PFloat);
	TglLoadTransposeMatrixdARB* = PROCEDURE{C}( m: PDouble);
	TglMultTransposeMatrixfARB* = PROCEDURE{C}( m: PFloat);
	TglMultTransposeMatrixdARB* = PROCEDURE{C}( m: PDouble);
	(* GL_ARB_vertex_blend  *)
	TglWeightbvARB* = PROCEDURE{C}(size: Int;  weights: PByte);
	TglWeightsvARB* = PROCEDURE{C}(size: Int;  weights: PShort);
	TglWeightivARB* = PROCEDURE{C}(size: Int;  weights: Pint);
	TglWeightfvARB* = PROCEDURE{C}(size: Int;  weights: PFloat);
	TglWeightdvARB* = PROCEDURE{C}(size: Int;  weights: PDouble);
	TglWeightubvARB* = PROCEDURE{C}(size: Int;  weights: PUbyte);
	TglWeightusvARB* = PROCEDURE{C}(size: Int;  weights: PUshort);
	TglWeightuivARB* = PROCEDURE{C}(size: Int;  weights: PInt);
	TglWeightPointerARB* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; xpointer: PVoid);
	TglVertexBlendARB* = PROCEDURE{C}(count: Int);
	(* GL_ARB_vertex_buffer_object  *)
	TglBindBufferARB* = PROCEDURE{C}(target: Enum; buffer: Uint);
	TglDeleteBuffersARB* = PROCEDURE{C}(n: Sizei;  buffers: PInt);
	TglGenBuffersARB* = PROCEDURE{C}(n: Sizei; buffers: PInt );
	TglIsBufferARB* = PROCEDURE{C}(buffer: Uint): Boolean;
	TglBufferDataARB* = PROCEDURE{C}(target: Enum; size: Sizei;  data: PVoid; usage: Enum);
	TglBufferSubDataARB* = PROCEDURE{C}(target: Enum; offset: Sizei; size: Sizei;  data: PVoid);
	TglGetBufferSubDataARB* = PROCEDURE{C}(target: Enum; offset: Sizei; size: Sizei; data: PVoid);
	TglMapBufferARB* = PROCEDURE{C}(target: Enum; access: Enum): PVoid;
	TglUnmapBufferARB* = PROCEDURE{C}( target: Enum): Boolean;
	TglGetBufferParameterivARB* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetBufferPointervARB* = PROCEDURE{C}(target: Enum; pname: Enum; params: PVoid);
	(* GL_ARB_vertex_program  *)
	TglVertexAttrib1dARB* = PROCEDURE{C}(index: Uint; x: Double);
	TglVertexAttrib1dvARB* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib1fARB* = PROCEDURE{C}(index: Uint; x: Float);
	TglVertexAttrib1fvARB* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib1sARB* = PROCEDURE{C}(index: Uint; x: Short);
	TglVertexAttrib1svARB* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib2dARB* = PROCEDURE{C}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dvARB* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib2fARB* = PROCEDURE{C}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fvARB* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib2sARB* = PROCEDURE{C}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2svARB* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib3dARB* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dvARB* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib3fARB* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fvARB* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib3sARB* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3svARB* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4NbvARB* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttrib4NivARB* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttrib4NsvARB* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4NubARB* = PROCEDURE{C}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4NubvARB* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttrib4NuivARB* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttrib4NusvARB* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglVertexAttrib4bvARB* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttrib4dARB* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dvARB* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib4fARB* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fvARB* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib4ivARB* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttrib4sARB* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4svARB* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4ubvARB* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttrib4uivARB* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttrib4usvARB* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglVertexAttribPointerARB* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei; xpointer: PVoid);
	TglEnableVertexAttribArrayARB* = PROCEDURE{C}(index: Uint);
	TglDisableVertexAttribArrayARB* = PROCEDURE{C}(index: Uint);
	TglProgramStringARB* = PROCEDURE{C}(target: Enum; format: Enum; len: Sizei;  xstring: PVoid);
	TglBindProgramARB* = PROCEDURE{C}(target: Enum; xprogram: Uint);
	TglDeleteProgramsARB* = PROCEDURE{C}(n: Sizei;  programs: PInt);
	TglGenProgramsARB* = PROCEDURE{C}(n: Sizei; programs: PInt);
	TglProgramEnvParameter4dARB* = PROCEDURE{C}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramEnvParameter4dvARB* = PROCEDURE{C}(target: Enum; index: Uint;  params: PDouble);
	TglProgramEnvParameter4fARB* = PROCEDURE{C}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramEnvParameter4fvARB* = PROCEDURE{C}(target: Enum; index: Uint;  params: PFloat);
	TglProgramLocalParameter4dARB* = PROCEDURE{C}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramLocalParameter4dvARB* = PROCEDURE{C}(target: Enum; index: Uint;  params: PDouble);
	TglProgramLocalParameter4fARB* = PROCEDURE{C}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramLocalParameter4fvARB* = PROCEDURE{C}(target: Enum; index: Uint;  params: PFloat);
	TglGetProgramEnvParameterdvARB* = PROCEDURE{C}(target: Enum; index: Uint; params: PDouble);
	TglGetProgramEnvParameterfvARB* = PROCEDURE{C}(target: Enum; index: Uint; params: PFloat);
	TglGetProgramLocalParameterdvARB* = PROCEDURE{C}(target: Enum; index: Uint; params: PDouble);
	TglGetProgramLocalParameterfvARB* = PROCEDURE{C}(target: Enum; index: Uint; params: PFloat);
	TglGetProgramivARB* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetProgramStringARB* = PROCEDURE{C}(target: Enum; pname: Enum; xstring: PVoid);
	TglGetVertexAttribdvARB* = PROCEDURE{C}(index: Uint; pname: Enum; params: PDouble);
	TglGetVertexAttribfvARB* = PROCEDURE{C}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribivARB* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribPointervARB* = PROCEDURE{C}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgramARB* = PROCEDURE{C}(xprogram: Uint): Boolean;
	(* GL_ARB_window_pos  *)
	TglWindowPos2dARB* = PROCEDURE{C}(x: Double; y: Double);
	TglWindowPos2dvARB* = PROCEDURE{C}( v: PDouble);
	TglWindowPos2fARB* = PROCEDURE{C}(x: Float; y: Float);
	TglWindowPos2fvARB* = PROCEDURE{C}( v: PFloat);
	TglWindowPos2iARB* = PROCEDURE{C}(x: Int; y: Int);
	TglWindowPos2ivARB* = PROCEDURE{C}( v: Pint);
	TglWindowPos2sARB* = PROCEDURE{C}(x: Short; y: Short);
	TglWindowPos2svARB* = PROCEDURE{C}( v: PShort);
	TglWindowPos3dARB* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglWindowPos3dvARB* = PROCEDURE{C}( v: PDouble);
	TglWindowPos3fARB* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglWindowPos3fvARB* = PROCEDURE{C}( v: PFloat);
	TglWindowPos3iARB* = PROCEDURE{C}(x: Int; y: Int; z: Int);
	TglWindowPos3ivARB* = PROCEDURE{C}( v: Pint);
	TglWindowPos3sARB* = PROCEDURE{C}(x: Short; y: Short; z: Short);
	TglWindowPos3svARB* = PROCEDURE{C}( v: PShort);
	(* GL_ARB_draw_buffers  *)
	TglDrawBuffersARB* = PROCEDURE{C}(n: Sizei; bufs: PEnum);
	(* GL_ARB_color_buffer_float  *)
	TglClampColorARB* = PROCEDURE{C}(target: Enum; clamp: Enum);
	(* GL_ARB_vertex_shader  *)
	TglGetActiveAttribARB* = PROCEDURE{C}(programobj: HandleARB; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PCharARB);
	TglGetAttribLocationARB* = PROCEDURE{C}(programObj: HandleARB; chars: ADDRESS): Int;
	TglBindAttribLocationARB* = PROCEDURE{C}(programObj: HandleARB; index: Uint; name: ADDRESS);
	(* GL_ARB_shader_objects  *)
	TglDeleteObjectARB* = PROCEDURE{C}(Obj: HandleARB);
	TglGetHandleARB* = PROCEDURE{C}(pname: Enum): HandleARB;
	TglDetachObjectARB* = PROCEDURE{C}(container, attached: HandleARB);
	TglCreateShaderObjectARB* = PROCEDURE{C}(shaderType: Enum): HandleARB;
	TglShaderSourceARB* = PROCEDURE{C}(shaderObj: HandleARB; count: Sizei; xstring: PPCharARB; lengths: Pint);
	TglCompileShaderARB* = PROCEDURE{C}(shaderObj: HandleARB);
	TglCreateProgramObjectARB* = PROCEDURE{C}(): HandleARB;
	TglAttachObjectARB* = PROCEDURE{C}(programObj, shaderObj: HandleARB);
	TglLinkProgramARB* = PROCEDURE{C}(programObj: HandleARB);
	TglUseProgramObjectARB* = PROCEDURE{C}(programObj: HandleARB);
	TglValidateProgramARB* = PROCEDURE{C}(programObj: HandleARB);
	TglUniform1fARB* = PROCEDURE{C}(location: Int; v0: Float);
	TglUniform2fARB* = PROCEDURE{C}(location: Int; v0, v1: Float);
	TglUniform3fARB* = PROCEDURE{C}(location: Int; v0, v1, v2: Float);
	TglUniform4fARB* = PROCEDURE{C}(location: Int; v0, v1, v2, v3: Float);
	TglUniform1iARB* = PROCEDURE{C}(location: Int; v0: Int);
	TglUniform2iARB* = PROCEDURE{C}(location: Int; v0, v1: Int);
	TglUniform3iARB* = PROCEDURE{C}(location: Int; v0, v1, v2: Int);
	TglUniform4iARB* = PROCEDURE{C}(location: Int; v0, v1, v2, v3: Int);
	TglUniform1fvARB* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform2fvARB* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform3fvARB* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform4fvARB* = PROCEDURE{C}(location: Int; count: Sizei; value: PFloat);
	TglUniform1ivARB* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform2ivARB* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform3ivARB* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniform4ivARB* = PROCEDURE{C}(location: Int; count: Sizei; value: Pint);
	TglUniformMatrix2fvARB* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix3fvARB* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglUniformMatrix4fvARB* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean; value: PFloat);
	TglGetObjectParameterfvARB* = PROCEDURE{C}(Obj: HandleARB; pname: Enum; params: PFloat);
	TglGetObjectParameterivARB* = PROCEDURE{C}(Obj: HandleARB; pname: Enum; params: Pint);
	TglGetInfoLogARB* = PROCEDURE{C}(shaderObj: HandleARB; maxLength: Sizei; VAR length: Int; infoLog: PCharARB);
	TglGetAttachedObjectsARB* = PROCEDURE{C}(programobj: HandleARB; maxCount: Sizei; VAR count: Sizei; objects: PHandleARB);
	TglGetUniformLocationARB* = PROCEDURE{C}(programObj: HandleARB; chars: ADDRESS): Int;
	TglGetActiveUniformARB* = PROCEDURE{C}(programobj: HandleARB; index: Uint; maxLength: Sizei; VAR length: Sizei; VAR size: Int; VAR xtype: Enum; name: PCharARB);
	TglGetUniformfvARB* = PROCEDURE{C}(programObj: HandleARB; location: Int; params: PFloat);
	TglGetUniformivARB* = PROCEDURE{C}(programObj: HandleARB; location: Int; params: Pint);
	TglGetShaderSourceARB* = PROCEDURE{C}(shader: HandleARB; maxLength: Sizei; VAR length: Sizei; source: PCharARB);
	(* GL_ARB_Occlusion_Query  *)
	TglGenQueriesARB* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglDeleteQueriesARB* = PROCEDURE{C}(n: Sizei;  ids: PInt);
	TglIsQueryARB* = PROCEDURE{C}(id: Uint): BOOLEAN;
	TglBeginQueryARB* = PROCEDURE{C}(target: Enum; id: Uint);
	TglEndQueryARB* = PROCEDURE{C}(target: Enum);
	TglGetQueryivARB* = PROCEDURE{C}(target, pname: Enum; params: Pint);
	TglGetQueryObjectivARB* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint);
	TglGetQueryObjectuivARB* = PROCEDURE{C}(id: Uint; pname: Enum; params: PInt);
	(* GL_ARB_draw_instanced  *)
	TglDrawArraysInstancedARB* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstancedARB* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: PVoid; primcount: Sizei);
	(* GL_ARB_framebuffer_object  *)
	TglIsRenderbuffer* = PROCEDURE{C}(renderbuffer: Uint): Boolean;
	TglBindRenderbuffer* = PROCEDURE{C}(target: Enum; renderbuffer: Uint);
	TglDeleteRenderbuffers* = PROCEDURE{C}(n: Sizei;  renderbuffers: PInt);
	TglGenRenderbuffers* = PROCEDURE{C}(n: Sizei; renderbuffers: PInt);
	TglRenderbufferStorage* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei);
	TglGetRenderbufferParameteriv* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglIsFramebuffer* = PROCEDURE{C}(framebuffer: Uint): Boolean;
	TglBindFramebuffer* = PROCEDURE{C}(target: Enum; framebuffer: Uint);
	TglDeleteFramebuffers* = PROCEDURE{C}(n: Sizei;  framebuffers: PInt);
	TglGenFramebuffers* = PROCEDURE{C}(n: Sizei; framebuffers: PInt);
	TglCheckFramebufferStatus* = PROCEDURE{C}(target: Enum): Enum;
	TglFramebufferTexture1D* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture2D* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture3D* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglFramebufferRenderbuffer* = PROCEDURE{C}(target: Enum; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetFramebufferAttachmentParameteriv* = PROCEDURE{C}(target: Enum; attachment: Enum; pname: Enum; params: Pint);
	TglGenerateMipmap* = PROCEDURE{C}(target: Enum);
	TglBlitFramebuffer* = PROCEDURE{C}(srcX0: Int; srcY0: Int; srcX1: Int; srcY1: Int; dstX0: Int; dstY0: Int; dstX1: Int; dstY1: Int; mask: Bitfield; filter: Enum);
	TglRenderbufferStorageMultisample* = PROCEDURE{C}(target: Enum; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglFramebufferTextureLayer* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	(* GL_ARB_geometry_shader4  *)
	TglProgramParameteriARB* = PROCEDURE{C}(xprogram: Uint; pname: Enum; value: Int);
	TglFramebufferTextureARB* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	TglFramebufferTextureLayerARB* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	TglFramebufferTextureFaceARB* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum);
	(* GL_ARB_instanced_arrays  *)
	TglVertexAttribDivisorARB* = PROCEDURE{C}(index: Uint; divisor: Uint);
	(* GL_ARB_map_buffer_range  *)
	TglMapBufferRange* = PROCEDURE{C}(target: Enum; offset: Sizei; length: Sizei; access: Bitfield): PVoid;
	TglFlushMappedBufferRange* = PROCEDURE{C}(target: Enum; offset: Sizei; length: Sizei);
	(* GL_ARB_texture_buffer_object  *)
	TglTexBufferARB* = PROCEDURE{C}(target: Enum; internalformat: Enum; buffer: Uint);
	(* GL_ARB_vertex_array_object  *)
	TglBindVertexArray* = PROCEDURE{C}(xarray: Uint);
	TglDeleteVertexArrays* = PROCEDURE{C}(n: Sizei;  arrays: PInt);
	TglGenVertexArrays* = PROCEDURE{C}(n: Sizei; arrays: PInt);
	TglIsVertexArray* = PROCEDURE{C}(xarray: Uint): Boolean;
	(* GL_ARB_uniform_buffer_object  *)
	TglGetUniformIndices* = PROCEDURE{C}(xprogram: Uint; uniformCount: Sizei;  uniformNames: PPChar; uniformIndices: PInt);
	TglGetActiveUniformsiv* = PROCEDURE{C}(xprogram: Uint; uniformCount: Sizei;  uniformIndices: PInt; pname: Enum; params: Pint);
	TglGetActiveUniformName* = PROCEDURE{C}(xprogram: Uint; uniformIndex: Uint; bufSize: Sizei; length: PSizei; uniformName: PChar);
	TglGetUniformBlockIndex* = PROCEDURE{C}(xprogram: Uint;  uniformBlockName: ADDRESS): Uint;
	TglGetActiveUniformBlockiv* = PROCEDURE{C}(xprogram: Uint; uniformBlockIndex: Uint; pname: Enum; params: Pint);
	TglGetActiveUniformBlockName* = PROCEDURE{C}(xprogram: Uint; uniformBlockIndex: Uint; bufSize: Sizei; length: PSizei; uniformBlockName: PChar);
	TglUniformBlockBinding* = PROCEDURE{C}(xprogram: Uint; uniformBlockIndex: Uint; uniformBlockBinding: Uint);
	(* GL_ARB_copy_buffer  *)
	TglCopyBufferSubData* = PROCEDURE{C}(readTarget: Enum; writeTarget: Enum; readOffset: Int; writeOffset: Int; size: Sizei);
	(* GL_ARB_draw_elements_base_vertex  *)
	TglDrawElementsBaseVertex* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: PVoid; basevertex: Int);
	TglDrawRangeElementsBaseVertex* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum;  indices: PVoid; basevertex: Int);
	TglDrawElementsInstancedBaseVertex* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: PVoid; primcount: Sizei; basevertex: Int);
	TglMultiDrawElementsBaseVertex* = PROCEDURE{C}(mode: Enum;  count: PSizei; xtype: Enum;  indices: PPVoid; primcount: Sizei;  basevertex: Pint);
	(* GL_ARB_provoking_vertex  *)
	TglProvokingVertex* = PROCEDURE{C}(mode: Enum);
	(* GL_ARB_sync  *)
	TglFenceSync* = PROCEDURE{C}(condition: Enum; flags: Bitfield): GLsync;
	TglIsSync* = PROCEDURE{C}(sync: GLsync): Boolean;
	TglDeleteSync* = PROCEDURE{C}(sync: GLsync);
	TglClientWaitSync* = PROCEDURE{C}(sync: GLsync; flags: Bitfield; timeout: Uint64): Enum;
	TglWaitSync* = PROCEDURE{C}(sync: GLsync; flags: Bitfield; timeout: Uint64);
	TglGetInteger64v* = PROCEDURE{C}(pname: Enum; params: Pint64);
	TglGetSynciv* = PROCEDURE{C}(sync: GLsync; pname: Enum; butSize: Sizei; length: PSizei; values: Pint);
	(* GL_ARB_texture_multisample  *)
	TglTexImage2DMultisample* = PROCEDURE{C}(target: Enum; samples: Sizei; internalformat: Int; width: Sizei; height: Sizei; fixedsamplelocations: Boolean);
	TglTexImage3DMultisample* = PROCEDURE{C}(target: Enum; samples: Sizei; internalformat: Int; width: Sizei; height: Sizei; depth: Sizei; fixedsamplelocations: Boolean);
	TglGetMultisamplefv* = PROCEDURE{C}(pname: Enum; index: Uint; val: PFloat);
	TglSampleMaski* = PROCEDURE{C}(index: Uint; mask: Bitfield);
	(* GL_ARB_draw_buffers_blend  *)
	TglBlendEquationiARB* = PROCEDURE{C}(buf: Uint; mode: Enum);
	TglBlendEquationSeparateiARB* = PROCEDURE{C}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	TglBlendFunciARB* = PROCEDURE{C}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparateiARB* = PROCEDURE{C}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);
	(* GL_ARB_sample_shading  *)
	TglMinSampleShadingARB* = PROCEDURE{C}(value: Clampf);
	(*  GL_ARB_shading_language_include  *)
	TglNamedStringARB* = PROCEDURE{C}(xtype: Enum; namelen: Int;  name: ADDRESS; stringlen: Int;  xstring: ADDRESS);
	TglDeleteNamedStringARB* = PROCEDURE{C}(namelen: Int;  name: ADDRESS);
	TglCompileShaderIncludeARB* = PROCEDURE{C}(shader: Uint; count: Sizei;  path: PPChar;  length: Pint);
	TglIsNamedStringARB* = PROCEDURE{C}(namelen: Int;  name: ADDRESS): Boolean;
	TglGetNamedStringARB* = PROCEDURE{C}(namelen: Int;  name: ADDRESS; bufSize: Sizei; stringlen: Int; xstring: PChar);
	TglGetNamedStringivARB* = PROCEDURE{C}(namelen: Int;  name: ADDRESS; pname: Enum; params: Pint);
	(*  GL_ARB_blend_func_extended  *)
	TglBindFragDataLocationIndexed* = PROCEDURE{C}(xprogram: Uint; colorNumber: Uint; index: Uint;  name: ADDRESS);
	TglGetFragDataIndex* = PROCEDURE{C}(xprogram: Uint;  name: ADDRESS): Int;
	(*  GL_ARB_sampler_objects  *)
	TglGenSamplers* = PROCEDURE{C}(count: Sizei; samplers: PInt);
	TglDeleteSamplers* = PROCEDURE{C}(count: Sizei;  samplers: PInt);
	TglIsSampler* = PROCEDURE{C}(sampler: Uint): Boolean;
	TglBindSampler* = PROCEDURE{C}(unit: Uint; sampler: Uint);
	TglSamplerParameteri* = PROCEDURE{C}(sampler: Uint; pname: Enum; param: Int);
	TglSamplerParameteriv* = PROCEDURE{C}(sampler: Uint; pname: Enum;  param: Pint);
	TglSamplerParameterf* = PROCEDURE{C}(sampler: Uint; pname: Enum; param: Float);
	TglSamplerParameterfv* = PROCEDURE{C}(sampler: Uint; pname: Enum;  param: PFloat);
	TglSamplerParameterIiv* = PROCEDURE{C}(sampler: Uint; pname: Enum;  param: Pint);
	TglSamplerParameterIuiv* = PROCEDURE{C}(sampler: Uint; pname: Enum;  param: PInt);
	TglGetSamplerParameteriv* = PROCEDURE{C}(sampler: Uint; pname: Enum; params: Pint);
	TglGetSamplerParameterIiv* = PROCEDURE{C}(sampler: Uint; pname: Enum; params: Pint);
	TglGetSamplerParameterfv* = PROCEDURE{C}(sampler: Uint; pname: Enum; params: PFloat);
	TglGetSamplerParameterIuiv* = PROCEDURE{C}(sampler: Uint; pname: Enum; params: PInt);
	(*  GL_ARB_timer_query  *)
	TglQueryCounter* = PROCEDURE{C}(id: Uint; target: Enum);
	TglGetQueryObjecti64v* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint64);
	TglGetQueryObjectui64v* = PROCEDURE{C}(id: Uint; pname: Enum; params: PInt64);
	(*  GL_ARB_vertex_type_2_10_10_10_rev  *)
	TglVertexP2ui* = PROCEDURE{C}(xtype: Enum; value: Uint);
	TglVertexP2uiv* = PROCEDURE{C}(xtype: Enum;  value: PInt);
	TglVertexP3ui* = PROCEDURE{C}(xtype: Enum; value: Uint);
	TglVertexP3uiv* = PROCEDURE{C}(xtype: Enum;  value: PInt);
	TglVertexP4ui* = PROCEDURE{C}(xtype: Enum; value: Uint);
	TglVertexP4uiv* = PROCEDURE{C}(xtype: Enum;  value: PInt);
	TglTexCoordP1ui* = PROCEDURE{C}(xtype: Enum; coords: Uint);
	TglTexCoordP1uiv* = PROCEDURE{C}(xtype: Enum;  coords: PInt);
	TglTexCoordP2ui* = PROCEDURE{C}(xtype: Enum; coords: Uint);
	TglTexCoordP2uiv* = PROCEDURE{C}(xtype: Enum;  coords: PInt);
	TglTexCoordP3ui* = PROCEDURE{C}(xtype: Enum; coords: Uint);
	TglTexCoordP3uiv* = PROCEDURE{C}(xtype: Enum;  coords: PInt);
	TglTexCoordP4ui* = PROCEDURE{C}(xtype: Enum; coords: Uint);
	TglTexCoordP4uiv* = PROCEDURE{C}(xtype: Enum;  coords: PInt);
	TglMultiTexCoordP1ui* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP1uiv* = PROCEDURE{C}(texture: Enum; xtype: Enum;  coords: PInt);
	TglMultiTexCoordP2ui* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP2uiv* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: PInt);
	TglMultiTexCoordP3ui* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP3uiv* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: PInt);
	TglMultiTexCoordP4ui* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: Uint);
	TglMultiTexCoordP4uiv* = PROCEDURE{C}(texture: Enum; xtype: Enum; coords: PInt);
	TglNormalP3ui* = PROCEDURE{C}(xtype: Enum; coords: Uint);
	TglNormalP3uiv* = PROCEDURE{C}(xtype: Enum;  coords: PInt);
	TglColorP3ui* = PROCEDURE{C}(xtype: Enum; color: Uint);
	TglColorP3uiv* = PROCEDURE{C}(xtype: Enum;  color: PInt);
	TglColorP4ui* = PROCEDURE{C}(xtype: Enum; color: Uint);
	TglColorP4uiv* = PROCEDURE{C}(xtype: Enum;  color: Uint);
	TglSecondaryColorP3ui* = PROCEDURE{C}(xtype: Enum; color: Uint);
	TglSecondaryColorP3uiv* = PROCEDURE{C}(xtype: Enum;  color: PInt);
	TglVertexAttribP1ui* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP1uiv* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean;  value: PInt);
	TglVertexAttribP2ui* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP2uiv* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean;  value: PInt);
	TglVertexAttribP3ui* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP3uiv* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean;  value: PInt);
	TglVertexAttribP4ui* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean; value: Uint);
	TglVertexAttribP4uiv* = PROCEDURE{C}(index: Uint; xtype: Enum; normalized: Boolean;  value: PInt);
	(*  GL_ARB_draw_indirect  *)
	TglDrawArraysIndirect* = PROCEDURE{C}(mode: Enum;  indirect: PVoid);
	TglDrawElementsIndirect* = PROCEDURE{C}(mode: Enum; xtype: Enum;  indirect: PVoid);
	(*  GL_ARB_gpu_shader_fp64  *)
	TglUniform1d* = PROCEDURE{C}(location: Int; x: Double);
	TglUniform2d* = PROCEDURE{C}(location: Int; x: Double; y: Double);
	TglUniform3d* = PROCEDURE{C}(location: Int; x: Double; y: Double; z: Double);
	TglUniform4d* = PROCEDURE{C}(location: Int; x: Double; y: Double; z: Double; w: Double);
	TglUniform1dv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PDouble);
	TglUniform2dv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PDouble);
	TglUniform3dv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PDouble);
	TglUniform4dv* = PROCEDURE{C}(location: Int; count: Sizei;  value: PDouble);
	TglUniformMatrix2dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix3dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix4dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix2x3dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix2x4dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix3x2dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix3x4dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix4x2dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglUniformMatrix4x3dv* = PROCEDURE{C}(location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglGetUniformdv* = PROCEDURE{C}(xprogram: Uint; location: Int; params: PDouble);
	(*  GL_ARB_shader_subroutine  *)
	TglGetSubroutineUniformLocation* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum;  name: ADDRESS): Int;
	TglGetSubroutineIndex* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum;  name: ADDRESS): Uint;
	TglGetActiveSubroutineUniformiv* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum; index: Uint; pname: Enum; values: Pint);
	TglGetActiveSubroutineUniformName* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum; index: Uint; bufsize: Sizei; length: PSizei; name: PChar);
	TglGetActiveSubroutineName* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum; index: Uint; bufsize: Sizei; length: PSizei; name: PChar);
	TglUniformSubroutinesuiv* = PROCEDURE{C}(shadertype: Enum; count: Sizei;  indices: PInt);
	TglGetUniformSubroutineuiv* = PROCEDURE{C}(shadertype: Enum; location: Int; params: PInt);
	TglGetProgramStageiv* = PROCEDURE{C}(xprogram: Uint; shadertype: Enum; pname: Enum; values: Pint);
	(*  GL_ARB_tessellation_shader  *)
	TglPatchParameteri* = PROCEDURE{C}(pname: Enum; value: Int);
	TglPatchParameterfv* = PROCEDURE{C}(pname: Enum;  values: PFloat);
	(*  GL_ARB_transform_feedback2  *)
	TglBindTransformFeedback* = PROCEDURE{C}(target: Enum; id: Uint);
	TglDeleteTransformFeedbacks* = PROCEDURE{C}(n: Sizei;  ids: PInt);
	TglGenTransformFeedbacks* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglIsTransformFeedback* = PROCEDURE{C}(id: Uint): Boolean;
	TglPauseTransformFeedback* = PROCEDURE{C}();
	TglResumeTransformFeedback* = PROCEDURE{C}();
	TglDrawTransformFeedback* = PROCEDURE{C}(mode: Enum; id: Uint);
	(*  GL_ARB_transform_feedback3  *)
	TglDrawTransformFeedbackStream* = PROCEDURE{C}(mode: Enum; id: Uint; stream: Uint);
	TglBeginQueryIndexed* = PROCEDURE{C}(target: Enum; index: Uint; id: Uint);
	TglEndQueryIndexed* = PROCEDURE{C}(target: Enum; index: Uint);
	TglGetQueryIndexediv* = PROCEDURE{C}(target: Enum; index: Uint; pname: Enum; params: Pint);
	(*  GL_ARB_ES2_compatibility  *)
	TglReleaseShaderCompiler* = PROCEDURE{C}();
	TglShaderBinary* = PROCEDURE{C}(count: Sizei;  shaders: PInt; binaryformat: Enum;  binary: PVoid; length: Sizei);
	TglGetShaderPrecisionFormat* = PROCEDURE{C}(shadertype: Enum; precisiontype: Enum; range: Pint; precision: Pint);
	TglDepthRangef* = PROCEDURE{C}(n: Clampf; f: Clampf);
	TglClearDepthf* = PROCEDURE{C}(d: Clampf);
	(* GL_ARB_get_program_binary  *)
	TglGetProgramBinary* = PROCEDURE{C}(xprogram: Uint; bufSize: Sizei; length: PSizei; binaryFormat: PEnum; binary: PVoid);
	TglProgramBinary* = PROCEDURE{C}(xprogram: Uint; binaryFormat: Enum;  binary: PVoid; length: Sizei);
	TglProgramParameteri* = PROCEDURE{C}(xprogram: Uint; pname: Enum; value: Int);
	(* GL_ARB_separate_shader_objects *)
	TglUseProgramStages* = PROCEDURE{C}(pipeline: Uint; stages: Bitfield; xprogram: Uint);
	TglActiveShaderProgram* = PROCEDURE{C}(pipeline: Uint; xprogram: Uint);
	TglCreateShaderProgramv* = PROCEDURE{C}(xtype: Enum; count: Sizei;  strings: PPChar): Uint;
	TglBindProgramPipeline* = PROCEDURE{C}(pipeline: Uint);
	TglDeleteProgramPipelines* = PROCEDURE{C}(n: Sizei;  pipelines: PInt);
	TglGenProgramPipelines* = PROCEDURE{C}(n: Sizei; pipelines: PInt);
	TglIsProgramPipeline* = PROCEDURE{C}(pipeline: Uint): Boolean;
	TglGetProgramPipelineiv* = PROCEDURE{C}(pipeline: Uint; pname: Enum; params: Pint);
	TglProgramUniform1i* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int);
	TglProgramUniform1iv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform1f* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float);
	TglProgramUniform1fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform1d* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Double);
	TglProgramUniform1dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform1ui* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint);
	TglProgramUniform1uiv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform2i* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int);
	TglProgramUniform2iv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform2f* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float);
	TglProgramUniform2fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform2d* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Double; v1: Double);
	TglProgramUniform2dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform2ui* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint);
	TglProgramUniform2uiv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform3i* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int);
	TglProgramUniform3iv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform3f* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float);
	TglProgramUniform3fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform3d* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Double; v1: Double; v2: Double);
	TglProgramUniform3dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform3ui* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglProgramUniform3uiv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform4i* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int; v3: Int);
	TglProgramUniform4iv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform4f* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float; v3: Float);
	TglProgramUniform4fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform4d* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Double; v1: Double; v2: Double; v3: Double);
	TglProgramUniform4dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform4ui* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglProgramUniform4uiv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniformMatrix2fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix2dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix2x3fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3x2fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix2x4fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4x2fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3x4fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4x3fv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix2x3dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3x2dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix2x4dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4x2dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3x4dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4x3dv* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglValidateProgramPipeline* = PROCEDURE{C}(pipeline: Uint);
	TglGetProgramPipelineInfoLog* = PROCEDURE{C}(pipeline: Uint; bufSize: Sizei; length: PSizei; infoLog: PChar);
	(* GL_ARB_vertex_attrib_64bit  *)
	TglVertexAttribL1d* = PROCEDURE{C}(index: Uint; x: Double);
	TglVertexAttribL2d* = PROCEDURE{C}(index: Uint; x: Double; y: Double);
	TglVertexAttribL3d* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttribL4d* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttribL1dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL2dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL3dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL4dv* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribLPointer* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei;  pointer: PVoid);
	TglGetVertexAttribLdv* = PROCEDURE{C}(index: Uint; pname: Enum; params: PDouble);
	(* GL_ARB_viewport_array *)
	TglViewportArrayv* = PROCEDURE{C}(first: Uint; count: Sizei;  v: PFloat);
	TglViewportIndexedf* = PROCEDURE{C}(index: Uint; x: Float; y: Float; w: Float; h: Float);
	TglViewportIndexedfv* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglScissorArrayv* = PROCEDURE{C}(first: Uint; count: Sizei;  v: Pint);
	TglScissorIndexed* = PROCEDURE{C}(index: Uint; left: Int; bottom: Int; width: Sizei; height: Sizei);
	TglScissorIndexedv* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglDepthRangeArrayv* = PROCEDURE{C}(first: Uint; count: Sizei;  v: PClampd);
	TglDepthRangeIndexed* = PROCEDURE{C}(index: Uint; n: Clampd; f: Clampd);
	TglGetFloati_v* = PROCEDURE{C}(target: Enum; index: Uint; data: PFloat);
	TglGetDoublei_v* = PROCEDURE{C}(target: Enum; index: Uint; data: PDouble);

	(*! GL 4.2  *)
	(*  GL_ARB_base_instance  *)
	TglDrawArraysInstancedBaseInstance* = PROCEDURE{C}(mode : Enum; first : Int; count :Sizei; primcount : Sizei; baseinstance : Uint);
	TglDrawElementsInstancedBaseInstance* = PROCEDURE{C}(mode : Enum; count : Sizei; xtype : Enum; indices : PVoid; primcount : Sizei; baseinstance : Uint);
	TglDrawElementsInstancedBaseVertexBaseInstance* = PROCEDURE{C}(mode : Enum; count : Sizei; xtype : Enum; indices : PVoid; primcount :Sizei; basevertex : Int; baseinstance : Uint);
	(*  GL_ARB_transform_feedback_instanced  *)
	TglDrawTransformFeedbackInstanced* = PROCEDURE{C}(mode : Enum; id : Uint; primcount : Sizei);
	TglDrawTransformFeedbackStreamInstanced* = PROCEDURE{C}(mode : Enum; id : Uint; stream : Uint; primcount : Sizei);
	(*  GL_ARB_internalformat_query  *)
	TglGetInternalformativ* = PROCEDURE{C}(target : Enum; internalformat : Enum; pname : Enum; bufSize : Sizei; params : Pint);
	(*  GL_ARB_shader_atomic_counters  *)
	TglGetActiveAtomicCounterBufferiv* = PROCEDURE{C}(xprogram : Uint; bufferIndex : Uint; pname : Enum; params : Pint);
	(*  GL_ARB_shader_image_load_store  *)
	TglBindImageTexture* = PROCEDURE{C}(xunit : Uint; texture : Uint; level :Int; layered : Boolean; layer : Int; access : Enum; format : Enum);
	TglMemoryBarrier* = PROCEDURE{C}(barriers : Bitfield);
	(*  GL_ARB_texture_storage  *)
	TglTexStorage1D* = PROCEDURE{C}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei);
	TglTexStorage2D* = PROCEDURE{C}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei);
	TglTexStorage3D* = PROCEDURE{C}(target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei);
	TglTextureStorage1DEXT* = PROCEDURE{C}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei);
	TglTextureStorage2DEXT* = PROCEDURE{C}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei);
	TglTextureStorage3DEXT* = PROCEDURE{C}(texture : Uint; target : Enum; levels :Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei);

	(*! GL 4.3  *)
	(* GL_KHR_debug  *)
	TglDebugMessageControl* = PROCEDURE{C}(source : Enum; xtype : Enum; severity : Enum; count : Sizei;  ids : PInt; enabled : Boolean);
	TglDebugMessageInsert* = PROCEDURE{C}(source : Enum;  xtype : Enum; id : Uint; sverity : Enum; length : Sizei;  buf : PChar);
	TglDebugMessageCallback* = PROCEDURE{C}(callback : Pointer (*TGLDEBUGPROC *);  userParam : Pointer);
	TglGetDebugMessageLog* = PROCEDURE{C}(count : Uint; bufsize : Sizei; sources : PEnum; types : PEnum; ids : PInt; sverities : PEnum; lengths : PSizei; messagelog : PChar) : Uint;
	TglPushDebugGroup* = PROCEDURE{C}(source : Enum; id : Uint; length : Sizei;  messagex : PChar);
	TglPopDebugGroup* = PROCEDURE{C}();
	TglObjectLabel* = PROCEDURE{C}(identifier : Enum; name : Uint; length : Sizei;  labelx : PChar);
	TglGetObjectLabel* = PROCEDURE{C}(identifier : Enum; name : Uint; bufsize : Sizei; length : PSizei; label_ : PChar);
	TglObjectPtrLabel* = PROCEDURE{C}( ptr : Pointer; length : Sizei;  labelx : PChar);
	TglGetObjectPtrLabel* = PROCEDURE{C}( ptr : Pointer; bufSize : Sizei; length : PSizei; labelx : PChar);
	(* GL_ARB_clear_buffer_object  *)
	TglClearBufferData* = PROCEDURE{C}(target : Enum; internalformat : Enum; format : Enum; xtype : Enum;  data : Pointer);
	TglClearBufferSubData* = PROCEDURE{C}(target : Enum; internalformat : Enum; offset : Intptr; size : Sizeiptr; format : Enum; xtype : Enum;  data : Pointer);
	TglClearNamedBufferDataEXT* = PROCEDURE{C}(buffer : Uint; internalformat : Enum; format : Enum; xtype : Enum;  data : Pointer);
	TglClearNamedBufferSubDataEXT* = PROCEDURE{C}(buffer : Uint; internalformat : Enum; format : Enum; xtype : Enum; offset : Sizeiptr; size : Sizeiptr;  data : Pointer);
	(* GL_ARB_compute_shader 1  *)
	TglDispatchCompute* = PROCEDURE{C}(num_groups_x : Uint; num_groups_y : Uint; num_groups_z : Uint);
	TglDispatchComputeIndirect* = PROCEDURE{C}(indirect : Intptr);
	(* GL_ARB_copy_image  *)
	TglCopyImageSubData* = PROCEDURE{C}(srcName : Uint; srcTarget : Enum; srcLevel : Int; srcX : Int; srcY : Int; srcZ : Int; dstName : Uint; dstTarget : Enum; dstLevel : Int; dstX : Int; dstY : Int; dstZ : Int; srcWidth : Sizei; srcHeight : Sizei; srcDepth : Sizei);
	(* GL_ARB_debug_group  *)
	(* ARB_debug_group reuses entry points from KHR_debug  *)
	(* GL_ARB_debug_label  *)
	(* ARB_debug_label reuses entry points from KHR_debug  *)
	(* GL_ARB_debug_output2  *)
	(* GL_ARB_ES3_compatibility  *)
	(* GL_ARB_explicit_uniform_location  *)
	(* GL_ARB_fragment_layer_viewport  *)
	(* GL_ARB_framebuffer_no_attachments  *)
	TglFramebufferParameteri* = PROCEDURE{C}(target : Enum; pname : Enum; param : Int);
	TglGetFramebufferParameteriv* = PROCEDURE{C}(target : Enum; pname : Enum; params : Pint);
	TglNamedFramebufferParameteriEXT* = PROCEDURE{C}(framebuffer : Uint; pname : Enum; param : Int);
	TglGetNamedFramebufferParameterivEXT* = PROCEDURE{C}(framebuffer : Uint; pname : Enum; param : Int);
	(* GL_ARB_internalformat_query2  *)
	TglGetInternalformati64v* = PROCEDURE{C}(target : Enum; internalformat : Enum; pname : Enum; bufSize : Sizei; params : Pint64);
	(* GL_ARB_invalidate_subdata  *)
	TglInvalidateTexSubImage* = PROCEDURE{C}(texture : Uint; level : Int; xoffset : Int; yoffset : Int; zoffset : Int; width : Sizei; height : Sizei; depth : Sizei);
	TglInvalidateTexImage* = PROCEDURE{C}(texture : Uint; level : Int);
	TglInvalidateBufferSubData* = PROCEDURE{C}(buffer : Uint; offset : Intptr; length : Sizeiptr);
	TglInvalidateBufferData* = PROCEDURE{C}(buffer : Uint);
	TglInvalidateFramebuffer* = PROCEDURE{C}(target : Enum; numAttachments : Sizei;  attachments : PEnum);
	TglInvalidateSubFramebuffer* = PROCEDURE{C}(target : Enum; numAttachments : Sizei;  attachments : PEnum; x : Int; y : Int; width : Sizei; height : Sizei);
	(* GL_ARB_multi_draw_indirect  *)
	TglMultiDrawArraysIndirect* = PROCEDURE{C}(mode : Enum;  indirect : Pointer; drawcount : Sizei; stride : Sizei);
	TglMultiDrawElementsIndirect* = PROCEDURE{C}(mode : Enum; xtype : Enum;  indirect : Pointer; drawcount : Sizei; stride : Sizei);
	(* GL_ARB_program_interface_query  *)
	TglGetProgramInterfaceiv* = PROCEDURE{C}(programx : Uint; programInterface : Enum; pname : Enum; params : Pint);
	TglGetProgramResourceIndex* = PROCEDURE{C}(programx : Uint; programInterface : Enum;  name : PChar) : Uint;
	TglGetProgramResourceName* = PROCEDURE{C}(programx : Uint; programInterface : Enum; index : Uint; bufSize : Sizei; length : PSizei; name : PChar);
	TglGetProgramResourceiv* = PROCEDURE{C}(programx : Uint; programInterface : Enum; index : Uint; propCount : Sizei;  props : PEnum; bufSize : Sizei; length : PSizei; params : Pint);
	TglGetProgramResourceLocation* = PROCEDURE{C}(programx : Uint; programInterface : Enum;  name : PChar) : Int;
	TglGetProgramResourceLocationIndex* = PROCEDURE{C}(programx : Uint; programInterface : Enum;  name : PChar) : Int;
	(* GL_ARB_robust_buffer_access_behavior  *)
	(* GL_ARB_shader_image_size  *)
	(* GL_ARB_shader_storage_buffer_object  *)
	TglShaderStorageBlockBinding* = PROCEDURE{C}(programx : Uint; storageBlockIndex : Uint; storageBlockBinding : Uint);
	(* GL_ARB_stencil_texturing  *)
	(* GL_ARB_texture_buffer_range  *)
	TglTexBufferRange* = PROCEDURE{C}(target : Enum; internalformat : Enum; buffer : Uint; offset :Intptr; size : Sizeiptr);
	TglTextureBufferRangeEXT* = PROCEDURE{C}(texture : Uint; target : Enum; internalformat : Enum; buffer : Uint; offset : Intptr; size : Sizeiptr);
	(* GL_ARB_texture_query_levels  *)
	(* GL_ARB_texture_storage_multisample *)
	TglTexStorage2DMultisample* = PROCEDURE{C}(target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; fixedsamplelocations : Boolean);
	TglTexStorage3DMultisample* = PROCEDURE{C}(target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei; fixedsamplelocations : Boolean);
	TglTextureStorage2DMultisampleEXT* = PROCEDURE{C}(texture : Uint; target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; fixedsamplelocations : Boolean);
	TglTextureStorage3DMultisampleEXT* = PROCEDURE{C}(texture : Uint; target : Enum; samples : Sizei; internalformat : Enum; width : Sizei; height : Sizei; depth : Sizei; fixedsamplelocations : Boolean);
	(* GL_ARB_texture_view  *)
	TglTextureView* = PROCEDURE{C}(texture : Uint; target : Enum; origtexture : Uint; internalformat : Enum; minlevel : Uint; numlevels : Uint; minlayer : Uint; numlayers : Uint);
	(* GL_ARB_vertex_attrib_binding  *)
	TglBindVertexBuffer* = PROCEDURE{C}(bindingindex : Uint; buffer : Uint; offset : Intptr; stride : Sizei);
	TglVertexAttribFormat* = PROCEDURE{C}(attribindex : Uint; size : Int; xtype : Enum; normalized : Boolean; relativeoffset : Uint);
	TglVertexAttribIFormat* = PROCEDURE{C}(attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexAttribLFormat* = PROCEDURE{C}(attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexAttribBinding* = PROCEDURE{C}(attribindex : Uint; bindingindex : Uint);
	TglVertexBindingDivisor* = PROCEDURE{C}(bindingindex : Uint; divisor : Uint);
	TglVertexArrayBindVertexBufferEXT* = PROCEDURE{C}(vaobj : Uint; bindingindex : Uint; buffer : Uint; offset : Intptr; stride : Sizei);
	TglVertexArrayVertexAttribFormatEXT* = PROCEDURE{C}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; normalized : Boolean; relativeoffset : Uint);
	TglVertexArrayVertexAttribIFormatEXT* = PROCEDURE{C}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexArrayVertexAttribLFormatEXT* = PROCEDURE{C}(vaobj : Uint; attribindex : Uint; size : Int; xtype : Enum; relativeoffset : Uint);
	TglVertexArrayVertexAttribBindingEXT* = PROCEDURE{C}(vaobj : Uint; attribindex : Uint; bindingindex : Uint);
	TglVertexArrayVertexBindingDivisorEXT* = PROCEDURE{C}(vaobj : Uint; bindingindex : Uint; divisor : Uint);
	(* GL_ARB_robustness_isolation  *)
	(* GL_ARB_cl_event  *)
	TglCreateSyncFromCLeventARB* = PROCEDURE{C}(context: p_cl_context; event: p_cl_event; flags: Bitfield): GLsync;
	(* GL_ARB_debug_output *)
	TglDebugMessageControlARB* = PROCEDURE{C}(source: Enum; xtype: Enum; severity: Enum; count: Sizei;  ids: PInt; enabled: Boolean);
	TglDebugMessageInsertARB* = PROCEDURE{C}(source: Enum; xtype: Enum; id: Uint; severity: Enum; length: Sizei;  buf: PChar);
	(* TglDebugMessageCallbackARB  = PROCEDURE{C}(callback: TglDebugProcARB;  userParam: PVoid);  *)
	TglGetDebugMessageLogARB* = PROCEDURE{C}(count: Uint; bufsize: Sizei; sources: PEnum; types: PEnum; ids: PInt; severities: PEnum; lengths: PSizei; messageLog: PChar): Uint;
	(* GL_ARB_robustness *)
	TglGetGraphicsResetStatusARB* = PROCEDURE{C}(): Enum;
	TglGetnMapdvARB* = PROCEDURE{C}(target: Enum; query: Enum; bufSize: Sizei; v: PDouble);
	TglGetnMapfvARB* = PROCEDURE{C}(target: Enum; query: Enum; bufSize: Sizei; v: PFloat);
	TglGetnMapivARB* = PROCEDURE{C}(target: Enum; query: Enum; bufSize: Sizei; v: Pint);
	TglGetnPixelMapfvARB* = PROCEDURE{C}(map: Enum; bufSize: Sizei; values: PFloat);
	TglGetnPixelMapuivARB* = PROCEDURE{C}(map: Enum; bufSize: Sizei; values: PInt);
	TglGetnPixelMapusvARB* = PROCEDURE{C}(map: Enum; bufSize: Sizei; values: PUshort);
	TglGetnPolygonStippleARB* = PROCEDURE{C}(bufSize: Sizei; pattern: PUbyte);
	TglGetnColorTableARB* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; bufSize: Sizei; table: PVoid);
	TglGetnConvolutionFilterARB* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; bufSize: Sizei; image: PVoid);
	TglGetnSeparableFilterARB* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; rowBufSize: Sizei; row: PVoid; columnBufSize: Sizei; column: PVoid; span: PVoid);
	TglGetnHistogramARB* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; bufSize: Sizei; values: PVoid);
	TglGetnMinmaxARB* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; bufSize: Sizei; values: PVoid);
	TglGetnTexImageARB* = PROCEDURE{C}(target: Enum; level: Int; format: Enum; xtype: Enum; bufSize: Sizei; img: PVoid);
	TglReadnPixelsARB* = PROCEDURE{C}(x: Int; y: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum; bufSize: Sizei; data: PVoid);
	TglGetnCompressedTexImageARB* = PROCEDURE{C}(target: Enum; lod: Int; bufSize: Sizei; img: PVoid);
	TglGetnUniformfvARB* = PROCEDURE{C}(xprogram: Uint; location: Int; bufSize: Sizei; params: PFloat);
	TglGetnUniformivARB* = PROCEDURE{C}(xprogram: Uint; location: Int; bufSize: Sizei; params: Pint);
	TglGetnUniformuivARB* = PROCEDURE{C}(xprogram: Uint; location: Int; bufSize: Sizei; params: PInt);
	TglGetnUniformdvARB* = PROCEDURE{C}(xprogram: Uint; location: Int; bufSize: Sizei; params: PDouble);
	(* GL_ATI_draw_buffers  *)
	TglDrawBuffersATI* = PROCEDURE{C}(n: Sizei;  bufs: PEnum);
	(* GL_ATI_element_array  *)
	TglElementPointerATI* = PROCEDURE{C}(xtype: Enum;  xpointer: PVoid);
	TglDrawElementArrayATI* = PROCEDURE{C}(mode: Enum; count: Sizei);
	TglDrawRangeElementArrayATI* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint; count: Sizei);
	(* GL_ATI_envmap_bumpmap  *)
	TglTexBumpParameterivATI* = PROCEDURE{C}(pname: Enum;  param: Pint);
	TglTexBumpParameterfvATI* = PROCEDURE{C}(pname: Enum;  param: PFloat);
	TglGetTexBumpParameterivATI* = PROCEDURE{C}(pname: Enum; param: Pint);
	TglGetTexBumpParameterfvATI* = PROCEDURE{C}(pname: Enum; param: PFloat);
	(* GL_ATI_fragment_shader  *)
	TglGenFragmentShadersATI* = PROCEDURE{C}(range: Uint): Uint;
	TglBindFragmentShaderATI* = PROCEDURE{C}(id: Uint);
	TglDeleteFragmentShaderATI* = PROCEDURE{C}(id: Uint);
	TglBeginFragmentShaderATI* = PROCEDURE{C}();
	TglEndFragmentShaderATI* = PROCEDURE{C}();
	TglPassTexCoordATI* = PROCEDURE{C}(dst: Uint; coord: Uint; swizzle: Enum);
	TglSampleMapATI* = PROCEDURE{C}(dst: Uint; interp: Uint; swizzle: Enum);
	TglColorFragmentOp1ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint);
	TglColorFragmentOp2ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint);
	TglColorFragmentOp3ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMask: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint; arg3: Uint; arg3Rep: Uint; arg3Mod: Uint);
	TglAlphaFragmentOp1ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint);
	TglAlphaFragmentOp2ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint);
	TglAlphaFragmentOp3ATI* = PROCEDURE{C}(op: Enum; dst: Uint; dstMod: Uint; arg1: Uint; arg1Rep: Uint; arg1Mod: Uint; arg2: Uint; arg2Rep: Uint; arg2Mod: Uint; arg3: Uint; arg3Rep: Uint; arg3Mod: Uint);
	TglSetFragmentShaderConstantATI* = PROCEDURE{C}(dst: Uint;  value: PFloat);
	(* GL_ATI_map_object_buffer  *)
	TglMapObjectBufferATI* = PROCEDURE{C}(buffer: Uint): PVoid;
	TglUnmapObjectBufferATI* = PROCEDURE{C}(buffer: Uint);
	(* GL_ATI_pn_triangles  *)
	TglPNTrianglesiATI* = PROCEDURE{C}(pname: Enum; param: Int);
	TglPNTrianglesfATI* = PROCEDURE{C}(pname: Enum; param: Float);
	(* GL_ATI_separate_stencil  *)
	TglStencilOpSeparateATI* = PROCEDURE{C}(face: Enum; sfail: Enum; dpfail: Enum; dppass: Enum);
	TglStencilFuncSeparateATI* = PROCEDURE{C}(frontfunc: Enum; backfunc: Enum; ref: Int; mask: Uint);
	(* GL_ATI_vertex_array_object  *)
	TglNewObjectBufferATI* = PROCEDURE{C}(size: Sizei;  xpointer: PVoid; usage: Enum): Uint;
	TglIsObjectBufferATI* = PROCEDURE{C}(buffer: Uint): Boolean;
	TglUpdateObjectBufferATI* = PROCEDURE{C}(buffer: Uint; offset: Uint; size: Sizei;  xpointer: PVoid; preserve: Enum);
	TglGetObjectBufferfvATI* = PROCEDURE{C}(buffer: Uint; pname: Enum; params: PFloat);
	TglGetObjectBufferivATI* = PROCEDURE{C}(buffer: Uint; pname: Enum; params: Pint);
	TglFreeObjectBufferATI* = PROCEDURE{C}(buffer: Uint);
	TglArrayObjectATI* = PROCEDURE{C}(xarray: Enum; size: Int; xtype: Enum; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetArrayObjectfvATI* = PROCEDURE{C}(xarray: Enum; pname: Enum; params: PFloat);
	TglGetArrayObjectivATI* = PROCEDURE{C}(xarray: Enum; pname: Enum; params: Pint);
	TglVariantArrayObjectATI* = PROCEDURE{C}(id: Uint; xtype: Enum; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetVariantArrayObjectfvATI* = PROCEDURE{C}(id: Uint; pname: Enum; params: PFloat);
	TglGetVariantArrayObjectivATI* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint);
	(* GL_ATI_vertex_attrib_array_object  *)
	TglVertexAttribArrayObjectATI* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei; buffer: Uint; offset: Uint);
	TglGetVertexAttribArrayObjectfvATI* = PROCEDURE{C}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribArrayObjectivATI* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	(* GL_ATI_vertex_streams  *)
	TglVertexStream1sATI* = PROCEDURE{C}(stream: Enum; x: Short);
	TglVertexStream1svATI* = PROCEDURE{C}(stream: Enum;  coords: PShort);
	TglVertexStream1iATI* = PROCEDURE{C}(stream: Enum; x: Int);
	TglVertexStream1ivATI* = PROCEDURE{C}(stream: Enum;  coords: Pint);
	TglVertexStream1fATI* = PROCEDURE{C}(stream: Enum; x: Float);
	TglVertexStream1fvATI* = PROCEDURE{C}(stream: Enum;  coords: PFloat);
	TglVertexStream1dATI* = PROCEDURE{C}(stream: Enum; x: Double);
	TglVertexStream1dvATI* = PROCEDURE{C}(stream: Enum;  coords: PDouble);
	TglVertexStream2sATI* = PROCEDURE{C}(stream: Enum; x: Short; y: Short);
	TglVertexStream2svATI* = PROCEDURE{C}(stream: Enum;  coords: PShort);
	TglVertexStream2iATI* = PROCEDURE{C}(stream: Enum; x: Int; y: Int);
	TglVertexStream2ivATI* = PROCEDURE{C}(stream: Enum;  coords: Pint);
	TglVertexStream2fATI* = PROCEDURE{C}(stream: Enum; x: Float; y: Float);
	TglVertexStream2fvATI* = PROCEDURE{C}(stream: Enum;  coords: PFloat);
	TglVertexStream2dATI* = PROCEDURE{C}(stream: Enum; x: Double; y: Double);
	TglVertexStream2dvATI* = PROCEDURE{C}(stream: Enum;  coords: PDouble);
	TglVertexStream3sATI* = PROCEDURE{C}(stream: Enum; x: Short; y: Short; z: Short);
	TglVertexStream3svATI* = PROCEDURE{C}(stream: Enum;  coords: PShort);
	TglVertexStream3iATI* = PROCEDURE{C}(stream: Enum; x: Int; y: Int; z: Int);
	TglVertexStream3ivATI* = PROCEDURE{C}(stream: Enum;  coords: Pint);
	TglVertexStream3fATI* = PROCEDURE{C}(stream: Enum; x: Float; y: Float; z: Float);
	TglVertexStream3fvATI* = PROCEDURE{C}(stream: Enum;  coords: PFloat);
	TglVertexStream3dATI* = PROCEDURE{C}(stream: Enum; x: Double; y: Double; z: Double);
	TglVertexStream3dvATI* = PROCEDURE{C}(stream: Enum;  coords: PDouble);
	TglVertexStream4sATI* = PROCEDURE{C}(stream: Enum; x: Short; y: Short; z: Short; w: Short);
	TglVertexStream4svATI* = PROCEDURE{C}(stream: Enum;  coords: PShort);
	TglVertexStream4iATI* = PROCEDURE{C}(stream: Enum; x: Int; y: Int; z: Int; w: Int);
	TglVertexStream4ivATI* = PROCEDURE{C}(stream: Enum;  coords: Pint);
	TglVertexStream4fATI* = PROCEDURE{C}(stream: Enum; x: Float; y: Float; z: Float; w: Float);
	TglVertexStream4fvATI* = PROCEDURE{C}(stream: Enum;  coords: PFloat);
	TglVertexStream4dATI* = PROCEDURE{C}(stream: Enum; x: Double; y: Double; z: Double; w: Double);
	TglVertexStream4dvATI* = PROCEDURE{C}(stream: Enum;  coords: PDouble);
	TglNormalStream3bATI* = PROCEDURE{C}(stream: Enum; nx: Byte; ny: Byte; nz: Byte);
	TglNormalStream3bvATI* = PROCEDURE{C}(stream: Enum;  coords: PByte);
	TglNormalStream3sATI* = PROCEDURE{C}(stream: Enum; nx: Short; ny: Short; nz: Short);
	TglNormalStream3svATI* = PROCEDURE{C}(stream: Enum;  coords: PShort);
	TglNormalStream3iATI* = PROCEDURE{C}(stream: Enum; nx: Int; ny: Int; nz: Int);
	TglNormalStream3ivATI* = PROCEDURE{C}(stream: Enum;  coords: Pint);
	TglNormalStream3fATI* = PROCEDURE{C}(stream: Enum; nx: Float; ny: Float; nz: Float);
	TglNormalStream3fvATI* = PROCEDURE{C}(stream: Enum;  coords: PFloat);
	TglNormalStream3dATI* = PROCEDURE{C}(stream: Enum; nx: Double; ny: Double; nz: Double);
	TglNormalStream3dvATI* = PROCEDURE{C}(stream: Enum;  coords: PDouble);
	TglClientActiveVertexStreamATI* = PROCEDURE{C}(stream: Enum);
	TglVertexBlendEnviATI* = PROCEDURE{C}(pname: Enum; param: Int);
	TglVertexBlendEnvfATI* = PROCEDURE{C}(pname: Enum; param: Float);
	(* GL_AMD_performance_monitor  *)
	TglGetPerfMonitorGroupsAMD* = PROCEDURE{C}(numGroups: Pint; groupsSize: Sizei; groups: PInt);
	TglGetPerfMonitorCountersAMD* = PROCEDURE{C}(group: Uint; numCounters: Pint; maxActiveCouters: Pint; counterSize: Sizei; counters: PInt);
	TglGetPerfMonitorGroupStringAMD* = PROCEDURE{C}(group: Uint; bufSize: Sizei; length: PSizei; groupString: PChar);
	TglGetPerfMonitorCounterStringAMD* = PROCEDURE{C}(group: Uint; counter: Uint; bufSize: Sizei; length: PSizei; counterString: PChar);
	TglGetPerfMonitorCounterInfoAMD* = PROCEDURE{C}(group: Uint; counter: Uint; pname: Enum; data: Pointer);
	TglGenPerfMonitorsAMD* = PROCEDURE{C}(n: Sizei; monitors: PInt);
	TglDeletePerfMonitorsAMD* = PROCEDURE{C}(n: Sizei; monitors: PInt);
	TglSelectPerfMonitorCountersAMD* = PROCEDURE{C}(monitor: Uint; enable: Boolean; group: Uint; numCounters: Int; counterList: PInt);
	TglBeginPerfMonitorAMD* = PROCEDURE{C}(monitor: Uint);
	TglEndPerfMonitorAMD* = PROCEDURE{C}(monitor: Uint);
	TglGetPerfMonitorCounterDataAMD* = PROCEDURE{C}(monitor: Uint; pname: Enum; dataSize: Sizei; data: PInt; bytesWritten: Pint);
	(* GL_AMD_vertex_shader_tesselator  *)
	TglTessellationFactorAMD* = PROCEDURE{C}(factor: Float);
	TglTessellationModeAMD* = PROCEDURE{C}(mode: Enum);
	(* GL_AMD_draw_buffers_blend  *)
	TglBlendFuncIndexedAMD* = PROCEDURE{C}(buf: Uint; src: Enum; dst: Enum);
	TglBlendFuncSeparateIndexedAMD* = PROCEDURE{C}(buf: Uint; srcRGB: Enum; dstRGB: Enum; srcAlpha: Enum; dstAlpha: Enum);
	TglBlendEquationIndexedAMD* = PROCEDURE{C}(buf: Uint; mode: Enum);
	TglBlendEquationSeparateIndexedAMD* = PROCEDURE{C}(buf: Uint; modeRGB: Enum; modeAlpha: Enum);
	(* GL_AMD_name_gen_delete  *)
	TglGenNamesAMD* = PROCEDURE{C}(identifier: Enum; num: Uint; names: PInt);
	TglDeleteNamesAMD* = PROCEDURE{C}(identifier: Enum; num: Uint;  names: PInt);
	TglIsNameAMD* = PROCEDURE{C}(identifier: Enum; name: Uint): Boolean;
	(* GL_AMD_debug_output  *)
	TglDebugMessageEnableAMD* = PROCEDURE{C}(category: Enum; severity: Enum; count: Sizei;  ids: PInt; enabled: Boolean);
	TglDebugMessageInsertAMD* = PROCEDURE{C}(category: Enum; severity: Enum; id: Uint; length: Sizei;  buf: PChar);
	(* TglDebugMessageCallbackAMD  = PROCEDURE{C}(callback: TGLDebugProcAMD; userParam: PVoid);   *)
	TglGetDebugMessageLogAMD* = PROCEDURE{C}(count: Uint; bufsize: Sizei; categories: PEnum; severities: PInt; ids: PInt; lengths: PSizei; message: PChar): Uint;
	(* GL_EXT_blend_color  *)
	TglBlendColorEXT* = PROCEDURE{C}(red: Clampf; green: Clampf; blue: Clampf; alpha: Clampf);
	(* GL_EXT_blend_func_separate  *)
	TglBlendFuncSeparateEXT* = PROCEDURE{C}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);
	(* GL_EXT_blend_minmax  *)
	TglBlendEquationEXT* = PROCEDURE{C}(mode: Enum);
	(* GL_EXT_color_subtable  *)
	TglColorSubTableEXT* = PROCEDURE{C}(target: Enum; start: Sizei; count: Sizei; format: Enum; xtype: Enum;  data: PVoid);
	TglCopyColorSubTableEXT* = PROCEDURE{C}(target: Enum; start: Sizei; x: Int; y: Int; width: Sizei);
	(* GL_EXT_compiled_vertex_array  *)
	TglLockArraysEXT* = PROCEDURE{C}(first: Int; count: Sizei);
	TglUnlockArraysEXT* = PROCEDURE{C}();
	(* GL_EXT_convolution  *)
	TglConvolutionFilter1DEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype: Enum; image: PVoid);
	TglConvolutionFilter2DEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  image: PVoid);
	TglConvolutionParameterfEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Float);
	TglConvolutionParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglConvolutionParameteriEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Int);
	TglConvolutionParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglCopyConvolutionFilter1DEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglCopyConvolutionFilter2DEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetConvolutionFilterEXT* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; image: PVoid);
	TglGetConvolutionParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetConvolutionParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetSeparableFilterEXT* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; row: PVoid; column: PVoid; span: PVoid);
	TglSeparableFilter2DEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  row: PVoid;  column: PVoid);
	(* GL_EXT_coordinate_frame  *)
	TglTangent3bEXT* = PROCEDURE{C}(tx: Byte; ty: Byte; tz: Byte);
	TglTangent3bvEXT* = PROCEDURE{C}( v: PByte);
	TglTangent3dEXT* = PROCEDURE{C}(tx: Double; ty: Double; tz: Double);
	TglTangent3dvEXT* = PROCEDURE{C}( v: PDouble);
	TglTangent3fEXT* = PROCEDURE{C}(tx: Float; ty: Float; tz: Float);
	TglTangent3fvEXT* = PROCEDURE{C}( v: PFloat);
	TglTangent3iEXT* = PROCEDURE{C}(tx: Int; ty: Int; tz: Int);
	TglTangent3ivEXT* = PROCEDURE{C}( v: Pint);
	TglTangent3sEXT* = PROCEDURE{C}(tx: Short; ty: Short; tz: Short);
	TglTangent3svEXT* = PROCEDURE{C}( v: PShort);
	TglBinormal3bEXT* = PROCEDURE{C}(bx: Byte; by: Byte; bz: Byte);
	TglBinormal3bvEXT* = PROCEDURE{C}( v: PByte);
	TglBinormal3dEXT* = PROCEDURE{C}(bx: Double; by: Double; bz: Double);
	TglBinormal3dvEXT* = PROCEDURE{C}( v: PDouble);
	TglBinormal3fEXT* = PROCEDURE{C}(bx: Float; by: Float; bz: Float);
	TglBinormal3fvEXT* = PROCEDURE{C}( v: PFloat);
	TglBinormal3iEXT* = PROCEDURE{C}(bx: Int; by: Int; bz: Int);
	TglBinormal3ivEXT* = PROCEDURE{C}( v: Pint);
	TglBinormal3sEXT* = PROCEDURE{C}(bx: Short; by: Short; bz: Short);
	TglBinormal3svEXT* = PROCEDURE{C}( v: PShort);
	TglTangentPointerEXT* = PROCEDURE{C}(xtype: Enum; stride: Sizei;  xpointer: PVoid);
	TglBinormalPointerEXT* = PROCEDURE{C}(xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(* GL_EXT_copy_texture  *)
	TglCopyTexImage1DEXT* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTexImage2DEXT* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTexSubImage1DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTexSubImage2DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglCopyTexSubImage3DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	(* GL_EXT_cull_vertex  *)
	TglCullParameterdvEXT* = PROCEDURE{C}(pname: Enum; params: PDouble);
	TglCullParameterfvEXT* = PROCEDURE{C}(pname: Enum; params: PFloat);
	(* GL_EXT_draw_range_elements  *)
	TglDrawRangeElementsEXT* = PROCEDURE{C}(mode: Enum; start: Uint; xend: Uint; count: Sizei; xtype: Enum;  indices: PVoid);
	(* GL_EXT_fog_coord  *)
	TglFogCoordfEXT* = PROCEDURE{C}(coord: Float);
	TglFogCoordfvEXT* = PROCEDURE{C}( coord: PFloat);
	TglFogCoorddEXT* = PROCEDURE{C}(coord: Double);
	TglFogCoorddvEXT* = PROCEDURE{C}( coord: PDouble);
	TglFogCoordPointerEXT* = PROCEDURE{C}(xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(* GL_EXT_framebuffer_object  *)
	TglIsRenderbufferEXT* = PROCEDURE{C}(renderbuffer: Uint): BOOLEAN;
	TglBindRenderbufferEXT* = PROCEDURE{C}(target: Enum; renderbuffer: Uint);
	TglDeleteRenderbuffersEXT* = PROCEDURE{C}(n: Sizei;  renderbuffers: PInt);
	TglGenRenderbuffersEXT* = PROCEDURE{C}(n: Sizei; renderbuffers: PInt);
	TglRenderbufferStorageEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; height: Sizei);
	TglGetRenderbufferParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglIsFramebufferEXT* = PROCEDURE{C}(framebuffer: Uint): BOOLEAN;
	TglBindFramebufferEXT* = PROCEDURE{C}(target: Enum; framebuffer: Uint);
	TglDeleteFramebuffersEXT* = PROCEDURE{C}(n: Sizei;  framebuffers: PInt);
	TglGenFramebuffersEXT* = PROCEDURE{C}(n: Sizei; framebuffers: PInt);
	TglCheckFramebufferStatusEXT* = PROCEDURE{C}(target: Enum): Enum;
	TglFramebufferTexture1DEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture2DEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglFramebufferTexture3DEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglFramebufferRenderbufferEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetFramebufferAttachmentParameterivEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; pname: Enum; params: Pint);
	TglGenerateMipmapEXT* = PROCEDURE{C}(target: Enum);
	(* GL_EXT_histogram  *)
	TglGetHistogramEXT* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetHistogramParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetHistogramParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetMinmaxEXT* = PROCEDURE{C}(target: Enum; reset: Boolean; format: Enum; xtype: Enum; values: PVoid);
	TglGetMinmaxParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetMinmaxParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglHistogramEXT* = PROCEDURE{C}(target: Enum; width: Sizei; internalformat: Enum; sink: Boolean);
	TglMinmaxEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; sink: Boolean);
	TglResetHistogramEXT* = PROCEDURE{C}(target: Enum);
	TglResetMinmaxEXT* = PROCEDURE{C}(target: Enum);
	(* GL_EXT_index_func  *)
	TglIndexFuncEXT* = PROCEDURE{C}(func: Enum; ref: Clampf);
	(* GL_EXT_index_material  *)
	TglIndexMaterialEXT* = PROCEDURE{C}(face: Enum; mode: Enum);
	(* GL_EXT_light_texture  *)
	TglApplyTextureEXT* = PROCEDURE{C}(mode: Enum);
	TglTextureLightEXT* = PROCEDURE{C}(pname: Enum);
	TglTextureMaterialEXT* = PROCEDURE{C}(face: Enum; mode: Enum);
	(* GL_EXT_multi_draw_arrays  *)
	TglMultiDrawArraysEXT* = PROCEDURE{C}(mode: Enum; first: Pint; count: PSizei; primcount: Sizei);
	TglMultiDrawElementsEXT* = PROCEDURE{C}(mode: Enum;  count: PSizei; xtype: Enum;  indices: PVoid; primcount: Sizei);
	(* GL_EXT_multisample  *)
	TglSampleMaskEXT* = PROCEDURE{C}(value: Clampf; invert: Boolean);
	TglSamplePatternEXT* = PROCEDURE{C}(pattern: Enum);
	(* GL_EXT_paletted_texture  *)
	TglColorTableEXT* = PROCEDURE{C}(target: Enum; internalFormat: Enum; width: Sizei; format: Enum; xtype: Enum;  table: PVoid);
	TglGetColorTableEXT* = PROCEDURE{C}(target: Enum; format: Enum; xtype: Enum; data: PVoid);
	TglGetColorTableParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetColorTableParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	(* GL_EXT_pixel_transform  *)
	TglPixelTransformParameteriEXT* = PROCEDURE{C}(target: Enum; pname: Enum; param: Int);
	TglPixelTransformParameterfEXT* = PROCEDURE{C}(target: Enum; pname: Enum; param: Float);
	TglPixelTransformParameterivEXT* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglPixelTransformParameterfvEXT* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	(* GL_EXT_point_parameters  *)
	TglPointParameterfEXT* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPointParameterfvEXT* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	(* GL_EXT_polygon_offset  *)
	TglPolygonOffsetEXT* = PROCEDURE{C}(factor: Float; bias: Float);
	(* GL_EXT_secondary_color  *)
	TglSecondaryColor3bEXT* = PROCEDURE{C}(red: Byte; green: Byte; blue: Byte);
	TglSecondaryColor3bvEXT* = PROCEDURE{C}( v: PByte);
	TglSecondaryColor3dEXT* = PROCEDURE{C}(red: Double; green: Double; blue: Double);
	TglSecondaryColor3dvEXT* = PROCEDURE{C}( v: PDouble);
	TglSecondaryColor3fEXT* = PROCEDURE{C}(red: Float; green: Float; blue: Float);
	TglSecondaryColor3fvEXT* = PROCEDURE{C}( v: PFloat);
	TglSecondaryColor3iEXT* = PROCEDURE{C}(red: Int; green: Int; blue: Int);
	TglSecondaryColor3ivEXT* = PROCEDURE{C}( v: Pint);
	TglSecondaryColor3sEXT* = PROCEDURE{C}(red: Short; green: Short; blue: Short);
	TglSecondaryColor3svEXT* = PROCEDURE{C}( v: PShort);
	TglSecondaryColor3ubEXT* = PROCEDURE{C}(red: Ubyte; green: Ubyte; blue: Ubyte);
	TglSecondaryColor3ubvEXT* = PROCEDURE{C}( v: PUbyte);
	TglSecondaryColor3uiEXT* = PROCEDURE{C}(red: Uint; green: Uint; blue: Uint);
	TglSecondaryColor3uivEXT* = PROCEDURE{C}( v: PInt);
	TglSecondaryColor3usEXT* = PROCEDURE{C}(red: Ushort; green: Ushort; blue: Ushort);
	TglSecondaryColor3usvEXT* = PROCEDURE{C}( v: PUshort);
	TglSecondaryColorPointerEXT* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(* GL_EXT_stencil_two_side  *)
	TglActiveStencilFaceEXT* = PROCEDURE{C}(face: Enum);
	(* GL_EXT_subtexture  *)
	TglTexSubImage1DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTexSubImage2DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	(* GL_EXT_texture3D  *)
	TglTexImage3DEXT* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTexSubImage3DEXT* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	(* GL_EXT_texture_object  *)
	TglAreTexturesResidentEXT* = PROCEDURE{C}(n: Sizei;  textures: PInt; residences: PBoolean): Boolean;
	TglBindTextureEXT* = PROCEDURE{C}(target: Enum; texture: Uint);
	TglDeleteTexturesEXT* = PROCEDURE{C}(n: Sizei;  textures: PInt);
	TglGenTexturesEXT* = PROCEDURE{C}(n: Sizei; textures: PInt);
	TglIsTextureEXT* = PROCEDURE{C}(texture: Uint): Boolean;
	TglPrioritizeTexturesEXT* = PROCEDURE{C}(n: Sizei;  textures: PInt;  priorities: PClampf);
	(* GL_EXT_texture_perturb_normal  *)
	TglTextureNormalEXT* = PROCEDURE{C}(mode: Enum);
	(* GL_EXT_vertex_array  *)
	TglArrayElementEXT* = PROCEDURE{C}(i: Int);
	TglColorPointerEXT* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; count: Sizei;  xpointer: PVoid);
	TglDrawArraysEXT* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei);
	TglEdgeFlagPointerEXT* = PROCEDURE{C}(stride: Sizei; count: Sizei;  xpointer: PBoolean);
	TglGetPointervEXT* = PROCEDURE{C}(pname: Enum; params: PVoid);
	TglIndexPointerEXT* = PROCEDURE{C}(xtype: Enum; stride: Sizei; count: Sizei;  xpointer: PVoid);
	TglNormalPointerEXT* = PROCEDURE{C}(xtype: Enum; stride: Sizei; count: Sizei;  xpointer: PVoid);
	TglTexCoordPointerEXT* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; count: Sizei;  xpointer: PVoid);
	TglVertexPointerEXT* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei; count: Sizei;  xpointer: PVoid);
	(* GL_EXT_vertex_shader  *)
	TglBeginVertexShaderEXT* = PROCEDURE{C}();
	TglEndVertexShaderEXT* = PROCEDURE{C}();
	TglBindVertexShaderEXT* = PROCEDURE{C}(id: Uint);
	TglGenVertexShadersEXT* = PROCEDURE{C}(range: Uint): Uint;
	TglDeleteVertexShaderEXT* = PROCEDURE{C}(id: Uint);
	TglShaderOp1EXT* = PROCEDURE{C}(op: Enum; res: Uint; arg1: Uint);
	TglShaderOp2EXT* = PROCEDURE{C}(op: Enum; res: Uint; arg1: Uint; arg2: Uint);
	TglShaderOp3EXT* = PROCEDURE{C}(op: Enum; res: Uint; arg1: Uint; arg2: Uint; arg3: Uint);
	TglSwizzleEXT* = PROCEDURE{C}(res: Uint; inVal: Uint; outX: Enum; outY: Enum; outZ: Enum; outW: Enum);
	TglWriteMaskEXT* = PROCEDURE{C}(res: Uint; inVal: Uint; outX: Enum; outY: Enum; outZ: Enum; outW: Enum);
	TglInsertComponentEXT* = PROCEDURE{C}(res: Uint; src: Uint; num: Uint);
	TglExtractComponentEXT* = PROCEDURE{C}(res: Uint; src: Uint; num: Uint);
	TglGenSymbolsEXT* = PROCEDURE{C}(datatype: Enum; storagetype: Enum; range: Enum; components: Uint): Uint;
	TglSetInvariantEXT* = PROCEDURE{C}(id: Uint; xtype: Enum;  addr: PVoid);
	TglSetLocalConstantEXT* = PROCEDURE{C}(id: Uint; xtype: Enum;  addr: PVoid);
	TglVariantbvEXT* = PROCEDURE{C}(id: Uint;  addr: PByte);
	TglVariantsvEXT* = PROCEDURE{C}(id: Uint;  addr: PShort);
	TglVariantivEXT* = PROCEDURE{C}(id: Uint;  addr: Pint);
	TglVariantfvEXT* = PROCEDURE{C}(id: Uint;  addr: PFloat);
	TglVariantdvEXT* = PROCEDURE{C}(id: Uint;  addr: PDouble);
	TglVariantubvEXT* = PROCEDURE{C}(id: Uint;  addr: PUbyte);
	TglVariantusvEXT* = PROCEDURE{C}(id: Uint;  addr: PUshort);
	TglVariantuivEXT* = PROCEDURE{C}(id: Uint;  addr: PInt);
	TglVariantPointerEXT* = PROCEDURE{C}(id: Uint; xtype: Enum; stride: Uint;  addr: PVoid);
	TglEnableVariantClientStateEXT* = PROCEDURE{C}(id: Uint);
	TglDisableVariantClientStateEXT* = PROCEDURE{C}(id: Uint);
	TglBindLightParameterEXT* = PROCEDURE{C}(light: Enum; value: Enum): Uint;
	TglBindMaterialParameterEXT* = PROCEDURE{C}(face: Enum; value: Enum): Uint;
	TglBindTexGenParameterEXT* = PROCEDURE{C}(xunit: Enum; coord: Enum; value: Enum): Uint;
	TglBindTextureUnitParameterEXT* = PROCEDURE{C}( xunit: Enum; value: Enum): Uint;
	TglBindParameterEXT* = PROCEDURE{C}(value: Enum): Uint;
	TglIsVariantEnabledEXT* = PROCEDURE{C}(id: Uint; cap: Enum): Boolean;
	TglGetVariantBooleanvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PBoolean);
	TglGetVariantIntegervEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: Pint);
	TglGetVariantFloatvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PFloat);
	TglGetVariantPointervEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PVoid);
	TglGetInvariantBooleanvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PBoolean);
	TglGetInvariantIntegervEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: Pint);
	TglGetInvariantFloatvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PFloat);
	TglGetLocalConstantBooleanvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PBoolean);
	TglGetLocalConstantIntegervEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: Pint);
	TglGetLocalConstantFloatvEXT* = PROCEDURE{C}(id: Uint; value: Enum; data: PFloat);
	(* GL_EXT_vertex_weighting  *)
	TglVertexWeightfEXT* = PROCEDURE{C}(weight: Float);
	TglVertexWeightfvEXT* = PROCEDURE{C}( weight: PFloat);
	TglVertexWeightPointerEXT* = PROCEDURE{C}(size: Sizei; xtype: Enum; stride: Sizei;  xpointer: PVoid);
	(* GL_EXT_stencil_clear_tag  *)
	TglStencilClearTagEXT* = PROCEDURE{C}(stencilTagBits: Sizei; stencilClearTag: Uint);
	(* GL_EXT_framebuffer_blit  *)
	TglBlitFramebufferEXT* = PROCEDURE{C}(srcX0: Int; srcY0: Int; srcX1: Int; srcY1: Int; dstX0: Int; dstY0: Int; dstX1: Int; dstY1: Int; mask: Bitfield; filter: Enum);
	(* GL_EXT_framebuffer_multisample  *)
	TglRenderbufferStorageMultisampleEXT* = PROCEDURE{C}(target: Enum; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	(* GL_EXT_timer_query  *)
	TglGetQueryObjecti64vEXT* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint64EXT);
	TglGetQueryObjectui64vEXT* = PROCEDURE{C}(id: Uint; pname: Enum; params: PInt64EXT);
	(* GL_EXT_gpu_program_parameters  *)
	TglProgramEnvParameters4fvEXT* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: PFloat);
	TglProgramLocalParameters4fvEXT* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: PFloat);
	(* GL_EXT_bindable_uniform  *)
	TglUniformBufferEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; buffer: Uint);
	TglGetUniformBufferSizeEXT* = PROCEDURE{C}(xprogram: Uint; location: Int): Int;
	TglGetUniformOffsetEXT* = PROCEDURE{C}( xprogram: Uint; location: Int): Pint;
	(* GL_EXT_draw_buffers2  *)
	TglColorMaskIndexedEXT* = PROCEDURE{C}(buf: Uint; r: Boolean; g: Boolean; b: Boolean; a: Boolean);
	TglGetBooleanIndexedvEXT* = PROCEDURE{C}(value: Enum; index: Uint; data: PBoolean);
	TglGetIntegerIndexedvEXT* = PROCEDURE{C}(value: Enum; index: Uint; data: Pint);
	TglEnableIndexedEXT* = PROCEDURE{C}(target: Enum; index: Uint);
	TglDisableIndexedEXT* = PROCEDURE{C}(target: Enum; index: Uint);
	TglIsEnabledIndexedEXT* = PROCEDURE{C}(target: Enum; index: Uint): Boolean;
	(* GL_EXT_draw_instanced  *)
	TglDrawArraysInstancedEXT* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei; primcount: Sizei);
	TglDrawElementsInstancedEXT* = PROCEDURE{C}(mode: Enum; count: Sizei; xtype: Enum;  indices: Pointer; primcount: Sizei);
	(* GL_EXT_geometry_shader4  *)
	TglProgramParameteriEXT* = PROCEDURE{C}(xprogram: Uint; pname: Enum; value: Int);
	TglFramebufferTextureEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int);
	(*  TglFramebufferTextureLayerEXT  = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);   *)
	TglFramebufferTextureFaceEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; face: Enum);
	(* GL_EXT_gpu_shader4  *)
	TglVertexAttribI1iEXT* = PROCEDURE{C}(index: Uint; x: Int);
	TglVertexAttribI2iEXT* = PROCEDURE{C}(index: Uint; x: Int; y: Int);
	TglVertexAttribI3iEXT* = PROCEDURE{C}(index: Uint; x: Int; y: Int; z: Int);
	TglVertexAttribI4iEXT* = PROCEDURE{C}(index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglVertexAttribI1uiEXT* = PROCEDURE{C}(index: Uint; x: Uint);
	TglVertexAttribI2uiEXT* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint);
	TglVertexAttribI3uiEXT* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint; z: Uint);
	TglVertexAttribI4uiEXT* = PROCEDURE{C}(index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglVertexAttribI1ivEXT* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI2ivEXT* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI3ivEXT* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI4ivEXT* = PROCEDURE{C}(index: Uint;  v: Pint);
	TglVertexAttribI1uivEXT* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI2uivEXT* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI3uivEXT* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI4uivEXT* = PROCEDURE{C}(index: Uint;  v: PInt);
	TglVertexAttribI4bvEXT* = PROCEDURE{C}(index: Uint;  v: PByte);
	TglVertexAttribI4svEXT* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttribI4ubvEXT* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttribI4usvEXT* = PROCEDURE{C}(index: Uint;  v: PUshort);
	TglVertexAttribIPointerEXT* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei;  xpointer: Pointer);
	TglGetVertexAttribIivEXT* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribIuivEXT* = PROCEDURE{C}(index: Uint; pname: Enum; params: PInt);
	TglUniform1uiEXT* = PROCEDURE{C}(location: Int; v0: Uint);
	TglUniform2uiEXT* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint);
	TglUniform3uiEXT* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglUniform4uiEXT* = PROCEDURE{C}(location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglUniform1uivEXT* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform2uivEXT* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform3uivEXT* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglUniform4uivEXT* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt);
	TglGetUniformuivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; params: PInt);
	TglBindFragDataLocationEXT* = PROCEDURE{C}(xprogram: Uint; colorNumber: Uint; name: ADDRESS);
	TglGetFragDataLocationEXT* = PROCEDURE{C}(xprogram: Uint; name: ADDRESS): Int;
	(* GL_EXT_texture_array  *)
	TglFramebufferTextureLayerEXT* = PROCEDURE{C}(target: Enum; attachment: Enum; texture: Uint; level: Int; layer: Int);
	(* GL_EXT_texture_buffer_object  *)
	TglTexBufferEXT* = PROCEDURE{C}(target: Enum; internalformat: Enum; buffer: Uint);
	(* GL_EXT_texture_integer  *)
	TglClearColorIiEXT* = PROCEDURE{C}(r: Int; g: Int; b: Int; a: Int);
	TglClearColorIuiEXT* = PROCEDURE{C}(r: Uint; g: Uint; b: Uint; a: Uint);
	TglTexParameterIivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglTexParameterIuivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PInt);
	TglGetTexParameterIivEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetTexParameterIiuvEXT* = PROCEDURE{C}(target: Enum; pname: Enum; params: PInt);
	(* GL_HP_image_transform  *)
	TglImageTransformParameteriHP* = PROCEDURE{C}(target: Enum; pname: Enum; param: Int);
	TglImageTransformParameterfHP* = PROCEDURE{C}(target: Enum; pname: Enum; param: Float);
	TglImageTransformParameterivHP* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglImageTransformParameterfvHP* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglGetImageTransformParameterivHP* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetImageTransformParameterfvHP* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	(* GL_EXT_depth_bounds_test  *)
	TglDepthBoundsEXT* = PROCEDURE{C}(zmin: Clampd; zmax: Clampd);
	(* GL_EXT_blend_equation_separate  *)
	TglBlendEquationSeparateEXT* = PROCEDURE{C}(modeRGB: Enum; modeAlpha: Enum);
	(* GL_EXT_transform_feedback  *)
	TglBeginTransformFeedbackEXT* = PROCEDURE{C}(primitiveMode: Enum);
	TglEndTransformFeedbackEXT* = PROCEDURE{C}();
	TglBindBufferRangeEXT* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint; offset: Sizei; size: Sizei);
	TglBindBufferOffsetEXT* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint; offset: Sizei);
	TglBindBufferBaseEXT* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryingsEXT* = PROCEDURE{C}(xprogram: Uint; count: Sizei;  locations: Pint; bufferMode: Enum);
	TglGetTransformFeedbackVaryingEXT* = PROCEDURE{C}(xprogram: Uint; index: Uint; location: Pint);
	(* GL_EXT_direct_state_access  *)
	TglClientAttribDefaultEXT* = PROCEDURE{C}(mask: Bitfield);
	TglPushClientAttribDefaultEXT* = PROCEDURE{C}(mask: Bitfield);
	TglMatrixLoadfEXT* = PROCEDURE{C}(mode: Enum;  m: PFloat);
	TglMatrixLoaddEXT* = PROCEDURE{C}(mode: Enum;  m: PDouble);
	TglMatrixMultfEXT* = PROCEDURE{C}(mode: Enum;  m: PFloat);
	TglMatrixMultdEXT* = PROCEDURE{C}(mode: Enum;  m: PDouble);
	TglMatrixLoadIdentityEXT* = PROCEDURE{C}(mode: Enum);
	TglMatrixRotatefEXT* = PROCEDURE{C}(mode: Enum; angle: Float; x: Float; y: Float; z: Float);
	TglMatrixRotatedEXT* = PROCEDURE{C}(mode: Enum; angle: Double; x: Double; y: Double; z: Double);
	TglMatrixScalefEXT* = PROCEDURE{C}(mode: Enum; x: Float; y: Float; z: Float);
	TglMatrixScaledEXT* = PROCEDURE{C}(mode: Enum; x: Double; y: Double; z: Double);
	TglMatrixTranslatefEXT* = PROCEDURE{C}(mode: Enum; x: Float; y: Float; z: Float);
	TglMatrixTranslatedEXT* = PROCEDURE{C}(mode: Enum; x: Double; y: Double; z: Double);
	TglMatrixFrustumEXT* = PROCEDURE{C}(mode: Enum; left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglMatrixOrthoEXT* = PROCEDURE{C}(mode: Enum; left: Double; right: Double; bottom: Double; top: Double; zNear: Double; zFar: Double);
	TglMatrixPopEXT* = PROCEDURE{C}(mode: Enum);
	TglMatrixPushEXT* = PROCEDURE{C}(mode: Enum);
	TglMatrixLoadTransposefEXT* = PROCEDURE{C}(mode: Enum;  m: PFloat);
	TglMatrixLoadTransposedEXT* = PROCEDURE{C}(mode: Enum;  m: PDouble);
	TglMatrixMultTransposefEXT* = PROCEDURE{C}(mode: Enum;  m: PFloat);
	TglMatrixMultTransposedEXT* = PROCEDURE{C}(mode: Enum;  m: PDouble);
	TglTextureParameterfEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; param: Float);
	TglTextureParameterfvEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: PFloat);
	TglTextureParameteriEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; param: Int);
	TglTextureParameterivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: Pint);
	TglTextureImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTextureImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTextureSubImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTextureSubImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglCopyTextureImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyTextureImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyTextureSubImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyTextureSubImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetTextureImageEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetTextureParameterfvEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: PFloat);
	TglGetTextureParameterivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: Pint);
	TglGetTextureLevelParameterfvEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetTextureLevelParameterivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; pname: Enum; params: Int);
	TglTextureImage3DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglTextureSubImage3DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglCopyTextureSubImage3DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglMultiTexParameterfEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexParameterfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: PFloat);
	TglMultiTexParameteriEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexParameterivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: Pint);
	TglMultiTexImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglMultiTexImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglMultiTexSubImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglMultiTexSubImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; xtype: Enum;  pixels: PVoid);
	TglCopyMultiTexImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; border: Int);
	TglCopyMultiTexImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; x: Int; y: Int; width: Sizei; height: Sizei; border: Int);
	TglCopyMultiTexSubImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; x: Int; y: Int; width: Sizei);
	TglCopyMultiTexSubImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglGetMultiTexImageEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; format: Enum; xtype: Enum; pixels: PVoid);
	TglGetMultiTexParameterfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexParameterivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; params: Pint);
	TglGetMultiTexLevelParameterfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; pname: Enum; params: PFloat);
	TglGetMultiTexLevelParameterivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; pname: Enum; params: Pint);
	TglMultiTexImage3DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; format: Enum; xtype: Enum;  pixels: PVoid);
	TglMultiTexSubImage3DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; xtype: Enum;  pixels:PVoid);
	TglCopyMultiTexSubImage3DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; x: Int; y: Int; width: Sizei; height: Sizei);
	TglBindMultiTextureEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; texture: Uint);
	TglEnableClientStateIndexedEXT* = PROCEDURE{C}(xarray: Enum; index: Uint);
	TglDisableClientStateIndexedEXT* = PROCEDURE{C}(xarray: Enum; index: Uint);
	TglMultiTexCoordPointerEXT* = PROCEDURE{C}(texunit: Enum; size: Int; xtype: Enum; stride: Sizei;  pointer: PVoid);
	TglMultiTexEnvfEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexEnvfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: PFloat);
	TglMultiTexEnviEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexEnvivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: Pint);
	TglMultiTexGendEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Double);
	TglMultiTexGendvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: PDouble);
	TglMultiTexGenfEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Float);
	TglMultiTexGenfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: PFloat);
	TglMultiTexGeniEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; param: Int);
	TglMultiTexGenivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum;  params: Pint);
	TglGetMultiTexEnvfvEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexEnvivEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; pname: Enum; params: Pint);
	TglGetMultiTexGendvEXT* = PROCEDURE{C}(texunit: Enum; coord: Enum; pname: Enum; params: PDouble);
	TglGetMultiTexGenfvEXT* = PROCEDURE{C}(texunit: Enum; coord: Enum; pname: Enum; params: PFloat);
	TglGetMultiTexGenivEXT* = PROCEDURE{C}(texunit: Enum; coord: Enum; pname: Enum; params: Pint);
	TglGetFloatIndexedvEXT* = PROCEDURE{C}(target: Enum; index: Uint; data: PFloat);
	TglGetDoubleIndexedvEXT* = PROCEDURE{C}(target: Enum; index: Uint; data: PDouble);
	TglGetPointerIndexedvEXT* = PROCEDURE{C}(target: Enum; index: Uint; data: PPVoid);
	TglCompressedTextureImage3DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedTextureImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedTextureImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedTextureSubImage3DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglCompressedTextureSubImage2DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglCompressedTextureSubImage1DEXT* = PROCEDURE{C}(texture: Uint; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglGetCompressedTextureImageEXT* = PROCEDURE{C}(texture: Uint; target: Enum; lod: Int; img: PVoid);
	TglCompressedMultiTexImage3DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedMultiTexImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedMultiTexImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; internalformat: Enum; width: Sizei; border: Int; imageSize: Sizei;  bits: PVoid);
	TglCompressedMultiTexSubImage3DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; width: Sizei; height: Sizei; depth: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglCompressedMultiTexSubImage2DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; yoffset: Int; width: Sizei; height: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglCompressedMultiTexSubImage1DEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; level: Int; xoffset: Int; width: Sizei; format: Enum; imageSize: Sizei;  bits: PVoid);
	TglGetCompressedMultiTexImageEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; lod: Int; img: PVoid);
	TglNamedProgramStringEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; format: Enum; len: Sizei;  xstring: PVoid);
	TglNamedProgramLocalParameter4dEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglNamedProgramLocalParameter4dvEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint;  params: PDouble);
	TglNamedProgramLocalParameter4fEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglNamedProgramLocalParameter4fvEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint;  params: PFloat);
	TglGetNamedProgramLocalParameterdvEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; params: PDouble);
	TglGetNamedProgramLocalParameterfvEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; params: PFloat);
	TglGetNamedProgramivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; pname: Enum; params: Pint);
	TglGetNamedProgramStringEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; pname: Enum; xstring: PVoid);
	TglNamedProgramLocalParameters4fvEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; count: Sizei;  params: PFloat);
	TglNamedProgramLocalParameterI4iEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglNamedProgramLocalParameterI4ivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint;  params: Pint);
	TglNamedProgramLocalParametersI4ivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; count: Sizei;  params: Pint);
	TglNamedProgramLocalParameterI4uiEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglNamedProgramLocalParameterI4uivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint;  params: PInt);
	TglNamedProgramLocalParametersI4uivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; count: Sizei;  params: PInt);
	TglGetNamedProgramLocalParameterIivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; params: Pint);
	TglGetNamedProgramLocalParameterIuivEXT* = PROCEDURE{C}(xprogram: Uint; target: Enum; index: Uint; params: PInt);
	TglTextureParameterIivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: Pint);
	TglTextureParameterIuivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: PInt);
	TglGetTextureParameterIivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: Pint);
	TglGetTextureParameterIuivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglMultiTexParameterIivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: Pint);
	TglMultiTexParameterIuivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum;  params: PInt);
	TglGetMultiTexParameterIivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: Pint);
	TglGetMultiTexParameterIuivEXT* = PROCEDURE{C}(texture: Uint; target: Enum; pname: Enum; params: PInt);
	TglProgramUniform1fEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float);
	TglProgramUniform2fEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float);
	TglProgramUniform3fEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float);
	TglProgramUniform4fEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Float; v1: Float; v2: Float; v3: Float);
	TglProgramUniform1iEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int);
	TglProgramUniform2iEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int);
	TglProgramUniform3iEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int);
	TglProgramUniform4iEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Int; v1: Int; v2: Int; v3: Int);
	TglProgramUniform1fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform2fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform3fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform4fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PFloat);
	TglProgramUniform1ivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform2ivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform3ivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniform4ivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint);
	TglProgramUniformMatrix2fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix2x3fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3x2fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix2x4fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4x2fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix3x4fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniformMatrix4x3fvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PFloat);
	TglProgramUniform1uiEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint);
	TglProgramUniform2uiEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint);
	TglProgramUniform3uiEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint);
	TglProgramUniform4uiEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; v0: Uint; v1: Uint; v2: Uint; v3: Uint);
	TglProgramUniform1uivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform2uivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform3uivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglProgramUniform4uivEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt);
	TglNamedBufferDataEXT* = PROCEDURE{C}(buffer: Uint; size: Sizei;  data: PVoid; usage: Enum);
	TglNamedBufferSubDataEXT* = PROCEDURE{C}(buffer: Uint; offset: Intptr; size: Sizeiptr;  data: PVoid);
	TglMapNamedBufferEXT* = PROCEDURE{C}(buffer: Uint; access: Enum): PVoid;
	TglUnmapNamedBufferEXT* = PROCEDURE{C}(buffer: Uint): Boolean;
	TglMapNamedBufferRangeEXT* = PROCEDURE{C}(buffer: Uint; offset: Intptr; length: Sizeiptr; access: Bitfield): PVoid;
	TglFlushMappedNamedBufferRangeEXT* = PROCEDURE{C}(buffer: Uint; offset: Intptr; length: Sizeiptr);
	TglNamedCopyBufferSubDataEXT* = PROCEDURE{C}(readBuffer: Uint; writeBuffer: Uint; readOffset: Intptr; writeOffset: Intptr; size: Sizeiptr);
	TglGetNamedBufferParameterivEXT* = PROCEDURE{C}(buffer: Uint; pname: Enum; params: Pint);
	TglGetNamedBufferPointervEXT* = PROCEDURE{C}(buffer: Uint; pname: Enum; params: PPVoid);
	TglGetNamedBufferSubDataEXT* = PROCEDURE{C}(buffer: Uint; offset: Intptr; size: Sizeiptr; data: PVoid);
	TglTextureBufferEXT* = PROCEDURE{C}(texture: Uint; target: Enum; internalformat: Enum; buffer: Uint);
	TglMultiTexBufferEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; interformat: Enum; buffer: Uint);
	TglNamedRenderbufferStorageEXT* = PROCEDURE{C}(renderbuffer: Uint; interformat: Enum; width: Sizei; height: Sizei);
	TglGetNamedRenderbufferParameterivEXT* = PROCEDURE{C}(renderbuffer: Uint; pname: Enum; params: Pint);
	TglCheckNamedFramebufferStatusEXT* = PROCEDURE{C}(framebuffer: Uint; target: Enum): Enum;
	TglNamedFramebufferTexture1DEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTexture2DEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTexture3DEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; textarget: Enum; texture: Uint; level: Int; zoffset: Int);
	TglNamedFramebufferRenderbufferEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; renderbuffertarget: Enum; renderbuffer: Uint);
	TglGetNamedFramebufferAttachmentParameterivEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; pname: Enum; params: Pint);
	TglGenerateTextureMipmapEXT* = PROCEDURE{C}(texture: Uint; target: Enum);
	TglGenerateMultiTexMipmapEXT* = PROCEDURE{C}(texunit: Enum; target: Enum);
	TglFramebufferDrawBufferEXT* = PROCEDURE{C}(framebuffer: Uint; mode: Enum);
	TglFramebufferDrawBuffersEXT* = PROCEDURE{C}(framebuffer: Uint; n: Sizei;  bufs: PEnum);
	TglFramebufferReadBufferEXT* = PROCEDURE{C}(framebuffer: Uint; mode: Enum);
	TglGetFramebufferParameterivEXT* = PROCEDURE{C}(framebuffer: Uint; pname: Enum; params: Pint);
	TglNamedRenderbufferStorageMultisampleEXT* = PROCEDURE{C}(renderbuffer: Uint; samples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglNamedRenderbufferStorageMultisampleCoverageEXT* = PROCEDURE{C}(renderbuffer: Uint; coverageSamples: Sizei; colorSamples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	TglNamedFramebufferTextureEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int);
	TglNamedFramebufferTextureLayerEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int; layer: Int);
	TglNamedFramebufferTextureFaceEXT* = PROCEDURE{C}(framebuffer: Uint; attachment: Enum; texture: Uint; level: Int; face: Enum);
	TglTextureRenderbufferEXT* = PROCEDURE{C}(texture: Uint; target: Enum; renderbuffer: Uint);
	TglMultiTexRenderbufferEXT* = PROCEDURE{C}(texunit: Enum; target: Enum; renderbuffer: Uint);
	TglProgramUniform1dEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Double);
	TglProgramUniform2dEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Double; y: Double);
	TglProgramUniform3dEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Double; y: Double; z: Double);
	TglProgramUniform4dEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Double; y: Double; z: Double; w: Double);
	TglProgramUniform1dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform2dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform3dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniform4dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PDouble);
	TglProgramUniformMatrix2dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix2x3dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix2x4dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3x2dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix3x4dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4x2dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	TglProgramUniformMatrix4x3dvEXT* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei; transpose: Boolean;  value: PDouble);
	(* GL_EXT_separate_shader_objects  *)
	TglUseShaderProgramEXT* = PROCEDURE{C}(xtype: Enum; xprogram: Uint);
	TglActiveProgramEXT* = PROCEDURE{C}(xprogram: Uint);
	TglCreateShaderProgramEXT* = PROCEDURE{C}(xtype: Enum; xstring: ADDRESS): Uint;
	(* GL_EXT_shader_image_load_store  *)
	TglBindImageTextureEXT* = PROCEDURE{C}(index: Uint; texture: Uint; level: Int; layered: Boolean; layer: Int; access: Enum; format: Int);
	TglMemoryBarrierEXT* = PROCEDURE{C}(barriers: Bitfield);
	(* GL_EXT_vertex_attrib_64bit  *)
	TglVertexAttribL1dEXT* = PROCEDURE{C}(index: Uint; x: Double);
	TglVertexAttribL2dEXT* = PROCEDURE{C}(index: Uint; x: Double; y: Double);
	TglVertexAttribL3dEXT* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttribL4dEXT* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttribL1dvEXT* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL2dvEXT* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL3dvEXT* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribL4dvEXT* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttribLPointerEXT* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei;  pointer: PVoid);
	TglGetVertexAttribLdvEXT* = PROCEDURE{C}(index: Uint; pname: Enum; params: PDouble);
	TglVertexArrayVertexAttribLOffsetEXT* = PROCEDURE{C}(vaobj: Uint; buffer: Uint; index: Uint; size: Int; xtype: Enum; stride: Sizei; offset: Intptr);
	(*  GL_IBM_multimode_draw_arrays  *)
	TglMultiModeDrawArraysIBM* = PROCEDURE{C}(mode: Enum; first: Pint; count: PSizei; primcount: Sizei; modestride: Int);
	TglMultiModeDrawElementsIBM* = PROCEDURE{C}(mode: PEnum; count: PSizei; xtype:  Enum; indices: PVoid; primcount: Sizei; modestride: Int);
	(*  GL_IBM_vertex_array_lists  *)
	TglColorPointerListIBM* = PROCEDURE{C}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglSecondaryColorPointerListIBM* = PROCEDURE{C}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglEdgeFlagPointerListIBM* = PROCEDURE{C}(stride: Int; xpointer: PBoolean; ptrstride: Int);
	TglFogCoordPointerListIBM* = PROCEDURE{C}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglIndexPointerListIBM* = PROCEDURE{C}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglNormalPointerListIBM* = PROCEDURE{C}(xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglTexCoordPointerListIBM* = PROCEDURE{C}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	TglVertexPointerListIBM* = PROCEDURE{C}(size: Int; xtype:  Enum; stride: Int; xpointer: PVoid; ptrstride: Int);
	(*  GL_INGR_blend_func_separate  *)
	TglBlendFuncSeparateINGR* = PROCEDURE{C}(sfactorRGB: Enum; dfactorRGB: Enum; sfactorAlpha: Enum; dfactorAlpha: Enum);
	(*  GL_INTEL_parallel_arrays  *)
	TglVertexPointervINTEL* = PROCEDURE{C}(size: Int; xtype:  Enum; xpointer: PVoid);
	TglNormalPointervINTEL* = PROCEDURE{C}(xtype:  Enum; xpointer: PVoid);
	TglColorPointervINTEL* = PROCEDURE{C}(size: Int; xtype:  Enum; xpointer: PVoid);
	TglTexCoordPointervINTEL* = PROCEDURE{C}(size: Int; xtype:  Enum; xpointer: PVoid);
	(*  GL_MESA_resize_buffers  *)
	TglResizeBuffersMESA* = PROCEDURE{C}();
	(* GL_MESA_window_pos  *)
	TglWindowPos2dMESA* = PROCEDURE{C}(x: Double; y: Double);
	TglWindowPos2dvMESA* = PROCEDURE{C}( v: PDouble);
	TglWindowPos2fMESA* = PROCEDURE{C}(x: Float; y: Float);
	TglWindowPos2fvMESA* = PROCEDURE{C}( v: PFloat);
	TglWindowPos2iMESA* = PROCEDURE{C}(x: Int; y: Int);
	TglWindowPos2ivMESA* = PROCEDURE{C}( v: Pint);
	TglWindowPos2sMESA* = PROCEDURE{C}(x: Short; y: Short);
	TglWindowPos2svMESA* = PROCEDURE{C}( v: PShort);
	TglWindowPos3dMESA* = PROCEDURE{C}(x: Double; y: Double; z: Double);
	TglWindowPos3dvMESA* = PROCEDURE{C}( v: PDouble);
	TglWindowPos3fMESA* = PROCEDURE{C}(x: Float; y: Float; z: Float);
	TglWindowPos3fvMESA* = PROCEDURE{C}( v: PFloat);
	TglWindowPos3iMESA* = PROCEDURE{C}(x: Int; y: Int; z: Int);
	TglWindowPos3ivMESA* = PROCEDURE{C}( v: Pint);
	TglWindowPos3sMESA* = PROCEDURE{C}(x: Short; y: Short; z: Short);
	TglWindowPos3svMESA* = PROCEDURE{C}( v: PShort);
	TglWindowPos4dMESA* = PROCEDURE{C}(x: Double; y: Double; z: Double; w: Double);
	TglWindowPos4dvMESA* = PROCEDURE{C}( v: PDouble);
	TglWindowPos4fMESA* = PROCEDURE{C}(x: Float; y: Float; z: Float; w: Float);
	TglWindowPos4fvMESA* = PROCEDURE{C}( v: PFloat);
	TglWindowPos4iMESA* = PROCEDURE{C}(x: Int; y: Int; z: Int; w: Int);
	TglWindowPos4ivMESA* = PROCEDURE{C}( v: Pint);
	TglWindowPos4sMESA* = PROCEDURE{C}(x: Short; y: Short; z: Short; w: Short);
	TglWindowPos4svMESA* = PROCEDURE{C}( v: PShort);
	(* GL_NV_evaluators  *)
	TglMapControlPointsNV* = PROCEDURE{C}(target: Enum; index: Uint; xtype: Enum; ustride: Sizei; vstride: Sizei; uorder: Int; vorder: Int; packed: Boolean;  points: PVoid);
	TglMapParameterivNV* = PROCEDURE{C}(target: Enum; pname: Enum;  params: Pint);
	TglMapParameterfvNV* = PROCEDURE{C}(target: Enum; pname: Enum;  params: PFloat);
	TglGetMapControlPointsNV* = PROCEDURE{C}(target: Enum; index: Uint; xtype: Enum; ustride: Sizei; vstride: Sizei; packed: Boolean; points: PVoid);
	TglGetMapParameterivNV* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglGetMapParameterfvNV* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetMapAttribParameterivNV* = PROCEDURE{C}(target: Enum; index: Uint; pname: Enum; params: Pint);
	TglGetMapAttribParameterfvNV* = PROCEDURE{C}(target: Enum; index: Uint; pname: Enum; params: PFloat);
	TglEvalMapsNV* = PROCEDURE{C}(target: Enum; mode: Enum);
	(* GL_NV_fence  *)
	TglDeleteFencesNV* = PROCEDURE{C}(n: Sizei;  fences: PInt);
	TglGenFencesNV* = PROCEDURE{C}(n: Sizei; fences: PInt);
	TglIsFenceNV* = PROCEDURE{C}(fence: Uint): Boolean;
	TglTestFenceNV* = PROCEDURE{C}(fence: Uint): Boolean;
	TglGetFenceivNV* = PROCEDURE{C}(fence: Uint; pname: Enum; params: Pint);
	TglFinishFenceNV* = PROCEDURE{C}(fence: Uint);
	TglSetFenceNV* = PROCEDURE{C}(fence: Uint; condition: Enum);
	(* GL_NV_fragment_program  *)
	TglProgramNamedParameter4fNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS; x: Float; y: Float; z: Float; w: Float);
	TglProgramNamedParameter4dNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS; x: Double; y: Double; z: Double; w: Double);
	TglProgramNamedParameter4fvNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS;  v: PFloat);
	TglProgramNamedParameter4dvNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS;  v: PDouble);
	TglGetProgramNamedParameterfvNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS; params: PFloat);
	TglGetProgramNamedParameterdvNV* = PROCEDURE{C}(id: Uint; len: Sizei;  name: ADDRESS; params: PDouble);
	(* GL_NV_half_float  *)
	TglVertex2hNV* = PROCEDURE{C}(x: HalfNV; y: HalfNV);
	TglVertex2hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglVertex3hNV* = PROCEDURE{C}(x: HalfNV; y: HalfNV; z: HalfNV);
	TglVertex3hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglVertex4hNV* = PROCEDURE{C}(x: HalfNV; y: HalfNV; z: HalfNV; w: HalfNV);
	TglVertex4hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglNormal3hNV* = PROCEDURE{C}(nx: HalfNV; ny: HalfNV; nz: HalfNV);
	TglNormal3hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglColor3hNV* = PROCEDURE{C}(red: HalfNV; green: HalfNV; blue: HalfNV);
	TglColor3hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglColor4hNV* = PROCEDURE{C}(red: HalfNV; green: HalfNV; blue: HalfNV; alpha: HalfNV);
	TglColor4hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglTexCoord1hNV* = PROCEDURE{C}(s: HalfNV);
	TglTexCoord1hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglTexCoord2hNV* = PROCEDURE{C}(s: HalfNV; t: HalfNV);
	TglTexCoord2hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglTexCoord3hNV* = PROCEDURE{C}(s: HalfNV; t: HalfNV; r: HalfNV);
	TglTexCoord3hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglTexCoord4hNV* = PROCEDURE{C}(s: HalfNV; t: HalfNV; r: HalfNV; q: HalfNV);
	TglTexCoord4hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglMultiTexCoord1hNV* = PROCEDURE{C}(target: Enum; s: HalfNV);
	TglMultiTexCoord1hvNV* = PROCEDURE{C}(target: Enum;  v: PHalfNV);
	TglMultiTexCoord2hNV* = PROCEDURE{C}(target: Enum; s: HalfNV; t: HalfNV);
	TglMultiTexCoord2hvNV* = PROCEDURE{C}(target: Enum;  v: PHalfNV);
	TglMultiTexCoord3hNV* = PROCEDURE{C}(target: Enum; s: HalfNV; t: HalfNV; r: HalfNV);
	TglMultiTexCoord3hvNV* = PROCEDURE{C}(target: Enum;  v: PHalfNV);
	TglMultiTexCoord4hNV* = PROCEDURE{C}(target: Enum; s: HalfNV; t: HalfNV; r: HalfNV; q: HalfNV);
	TglMultiTexCoord4hvNV* = PROCEDURE{C}(target: Enum;  v: PHalfNV);
	TglFogCoordhNV* = PROCEDURE{C}(fog: HalfNV);
	TglFogCoordhvNV* = PROCEDURE{C}( fog: PHalfNV);
	TglSecondaryColor3hNV* = PROCEDURE{C}(red: HalfNV; green: HalfNV; blue: HalfNV);
	TglSecondaryColor3hvNV* = PROCEDURE{C}( v: PHalfNV);
	TglVertexWeighthNV* = PROCEDURE{C}(weight: HalfNV);
	TglVertexWeighthvNV* = PROCEDURE{C}( weight: PHalfNV);
	TglVertexAttrib1hNV* = PROCEDURE{C}(index: Uint; x: HalfNV);
	TglVertexAttrib1hvNV* = PROCEDURE{C}(index: Uint;  v: PHalfNV);
	TglVertexAttrib2hNV* = PROCEDURE{C}(index: Uint; x: HalfNV; y: HalfNV);
	TglVertexAttrib2hvNV* = PROCEDURE{C}(index: Uint;  v: PHalfNV);
	TglVertexAttrib3hNV* = PROCEDURE{C}(index: Uint; x: HalfNV; y: HalfNV; z: HalfNV);
	TglVertexAttrib3hvNV* = PROCEDURE{C}(index: Uint;  v: PHalfNV);
	TglVertexAttrib4hNV* = PROCEDURE{C}(index: Uint; x: HalfNV; y: HalfNV; z: HalfNV; w: HalfNV);
	TglVertexAttrib4hvNV* = PROCEDURE{C}(index: Uint;  v: PHalfNV);
	TglVertexAttribs1hvNV* = PROCEDURE{C}(index: Uint; n: Sizei;  v: PHalfNV);
	TglVertexAttribs2hvNV* = PROCEDURE{C}(index: Uint; n: Sizei;  v: PHalfNV);
	TglVertexAttribs3hvNV* = PROCEDURE{C}(index: Uint; n: Sizei;  v: PHalfNV);
	TglVertexAttribs4hvNV* = PROCEDURE{C}(index: Uint; n: Sizei;  v: PHalfNV);
	(* GL_NV_occlusion_query  *)
	TglGenOcclusionQueriesNV* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglDeleteOcclusionQueriesNV* = PROCEDURE{C}(n: Sizei;  ids: PInt);
	TglIsOcclusionQueryNV* = PROCEDURE{C}(id: Uint): Boolean;
	TglBeginOcclusionQueryNV* = PROCEDURE{C}(id: Uint);
	TglEndOcclusionQueryNV* = PROCEDURE{C}();
	TglGetOcclusionQueryivNV* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint);
	TglGetOcclusionQueryuivNV* = PROCEDURE{C}(id: Uint; pname: Enum; params: PInt);
	(* GL_NV_pixel_data_range  *)
	TglPixelDataRangeNV* = PROCEDURE{C}(target: Enum; length: Sizei; xpointer: PVoid);
	TglFlushPixelDataRangeNV* = PROCEDURE{C}(target: Enum);
	(* GL_NV_point_sprite  *)
	TglPointParameteriNV* = PROCEDURE{C}(pname: Enum; param: Int);
	TglPointParameterivNV* = PROCEDURE{C}(pname: Enum;  params: Pint);
	(* GL_NV_primitive_restart  *)
	TglPrimitiveRestartNV* = PROCEDURE{C}();
	TglPrimitiveRestartIndexNV* = PROCEDURE{C}(index: Uint);
	(* GL_NV_register_combiners  *)
	TglCombinerParameterfvNV* = PROCEDURE{C}(pname: Enum;  params: PFloat);
	TglCombinerParameterfNV* = PROCEDURE{C}(pname: Enum; param: Float);
	TglCombinerParameterivNV* = PROCEDURE{C}(pname: Enum;  params: Pint);
	TglCombinerParameteriNV* = PROCEDURE{C}(pname: Enum; param: Int);
	TglCombinerInputNV* = PROCEDURE{C}(stage: Enum; portion: Enum; variable: Enum; input: Enum; mapping: Enum; componentUsage: Enum);
	TglCombinerOutputNV* = PROCEDURE{C}(stage: Enum; portion: Enum; abOutput: Enum; cdOutput: Enum; sumOutput: Enum; scale: Enum; bias: Enum; abDotProduct: Boolean; cdDotProduct: Boolean; muxSum: Boolean);
	TglFinalCombinerInputNV* = PROCEDURE{C}(variable: Enum; input: Enum; mapping: Enum; componentUsage: Enum);
	TglGetCombinerInputParameterfvNV* = PROCEDURE{C}(stage: Enum; portion: Enum; variable: Enum; pname: Enum; params: PFloat);
	TglGetCombinerInputParameterivNV* = PROCEDURE{C}(stage: Enum; portion: Enum; variable: Enum; pname: Enum; params: Pint);
	TglGetCombinerOutputParameterfvNV* = PROCEDURE{C}(stage: Enum; portion: Enum; pname: Enum; params: PFloat);
	TglGetCombinerOutputParameterivNV* = PROCEDURE{C}(stage: Enum; portion: Enum; pname: Enum; params: Pint);
	TglGetFinalCombinerInputParameterfvNV* = PROCEDURE{C}(variable: Enum; pname: Enum; params: PFloat);
	TglGetFinalCombinerInputParameterivNV* = PROCEDURE{C}(variable: Enum; pname: Enum; params: Pint);
	(* GL_NV_register_combiners2 *)
	TglCombinerStageParameterfvNV* = PROCEDURE{C}(stage: Enum; pname: Enum;  params: PFloat);
	TglGetCombinerStageParameterfvNV* = PROCEDURE{C}(stage: Enum; pname: Enum; params: PFloat);
	(* GL_NV_vertex_array_range  *)
	TglFlushVertexArrayRangeNV* = PROCEDURE{C}();
	TglVertexArrayRangeNV* = PROCEDURE{C}(length: Sizei;  xpointer: PVoid);
	(* GL_NV_vertex_program  *)
	TglAreProgramsResidentNV* = PROCEDURE{C}(n: Sizei;  programs: PInt; residences: PBoolean): Boolean;
	TglBindProgramNV* = PROCEDURE{C}(target: Enum; id: Uint);
	TglDeleteProgramsNV* = PROCEDURE{C}(n: Sizei;  programs: PInt);
	TglExecuteProgramNV* = PROCEDURE{C}(target: Enum; id: Uint;  params: PFloat);
	TglGenProgramsNV* = PROCEDURE{C}(n: Sizei; programs: PInt);
	TglGetProgramParameterdvNV* = PROCEDURE{C}(target: Enum; index: Uint; pname: Enum; params: PDouble);
	TglGetProgramParameterfvNV* = PROCEDURE{C}(target: Enum; index: Uint; pname: Enum; params: PFloat);
	TglGetProgramivNV* = PROCEDURE{C}(id: Uint; pname: Enum; params: Pint);
	TglGetProgramStringNV* = PROCEDURE{C}(id: Uint; pname: Enum; xprogram: PUbyte);
	TglGetTrackMatrixivNV* = PROCEDURE{C}(target: Enum; address: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribdvNV* = PROCEDURE{C}(index: Uint; pname: Enum; params: PDouble);
	TglGetVertexAttribfvNV* = PROCEDURE{C}(index: Uint; pname: Enum; params: PFloat);
	TglGetVertexAttribivNV* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint);
	TglGetVertexAttribPointervNV* = PROCEDURE{C}(index: Uint; pname: Enum; xpointer: PVoid);
	TglIsProgramNV* = PROCEDURE{C}(id: Uint): Boolean;
	TglLoadProgramNV* = PROCEDURE{C}(target: Enum; id: Uint; len: Sizei;  xprogram: PUbyte);
	TglProgramParameter4dNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglProgramParameter4dvNV* = PROCEDURE{C}(target: Enum; index: Uint;  v: PDouble);
	TglProgramParameter4fNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglProgramParameter4fvNV* = PROCEDURE{C}(target: Enum; index: Uint;  v: PFloat);
	TglProgramParameters4dvNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Uint;  v: PDouble);
	TglProgramParameters4fvNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Uint;  v: PFloat);
	TglRequestResidentProgramsNV* = PROCEDURE{C}(n: Sizei;  programs: PInt);
	TglTrackMatrixNV* = PROCEDURE{C}(target: Enum; address: Uint; matrix: Enum; transform: Enum);
	TglVertexAttribPointerNV* = PROCEDURE{C}(index: Uint; fsize: Int; xtype: Enum; stride: Sizei;  xpointer: PVoid);
	TglVertexAttrib1dNV* = PROCEDURE{C}(index: Uint; x: Double);
	TglVertexAttrib1dvNV* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib1fNV* = PROCEDURE{C}(index: Uint; x: Float);
	TglVertexAttrib1fvNV* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib1sNV* = PROCEDURE{C}(index: Uint; x: Short);
	TglVertexAttrib1svNV* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib2dNV* = PROCEDURE{C}(index: Uint; x: Double; y: Double);
	TglVertexAttrib2dvNV* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib2fNV* = PROCEDURE{C}(index: Uint; x: Float; y: Float);
	TglVertexAttrib2fvNV* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib2sNV* = PROCEDURE{C}(index: Uint; x: Short; y: Short);
	TglVertexAttrib2svNV* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib3dNV* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double);
	TglVertexAttrib3dvNV* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib3fNV* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float);
	TglVertexAttrib3fvNV* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib3sNV* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short);
	TglVertexAttrib3svNV* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4dNV* = PROCEDURE{C}(index: Uint; x: Double; y: Double; z: Double; w: Double);
	TglVertexAttrib4dvNV* = PROCEDURE{C}(index: Uint;  v: PDouble);
	TglVertexAttrib4fNV* = PROCEDURE{C}(index: Uint; x: Float; y: Float; z: Float; w: Float);
	TglVertexAttrib4fvNV* = PROCEDURE{C}(index: Uint;  v: PFloat);
	TglVertexAttrib4sNV* = PROCEDURE{C}(index: Uint; x: Short; y: Short; z: Short; w: Short);
	TglVertexAttrib4svNV* = PROCEDURE{C}(index: Uint;  v: PShort);
	TglVertexAttrib4ubNV* = PROCEDURE{C}(index: Uint; x: Ubyte; y: Ubyte; z: Ubyte; w: Ubyte);
	TglVertexAttrib4ubvNV* = PROCEDURE{C}(index: Uint;  v: PUbyte);
	TglVertexAttribs1dvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PDouble);
	TglVertexAttribs1fvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PFloat);
	TglVertexAttribs1svNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PShort);
	TglVertexAttribs2dvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PDouble);
	TglVertexAttribs2fvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PFloat);
	TglVertexAttribs2svNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PShort);
	TglVertexAttribs3dvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PDouble);
	TglVertexAttribs3fvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PFloat);
	TglVertexAttribs3svNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PShort);
	TglVertexAttribs4dvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PDouble);
	TglVertexAttribs4fvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PFloat);
	TglVertexAttribs4svNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PShort);
	TglVertexAttribs4ubvNV* = PROCEDURE{C}(index: Uint; count: Sizei;  v: PUbyte);
	(* GL_NV_depth_buffer_float  *)
	TglDepthRangedNV* = PROCEDURE{C}(n: Double; f: Double);
	TglClearDepthdNV* = PROCEDURE{C}(d: Double);
	TglDepthBoundsdNV* = PROCEDURE{C}(zmin: Double; zmax: Double);
	(* GL_NV_framebuffer_multisample_coverage  *)
	TglRenderbufferStorageMultsampleCoverageNV* = PROCEDURE{C}(target: Enum; coverageSamples: Sizei; colorSamples: Sizei; internalformat: Enum; width: Sizei; height: Sizei);
	(* GL_NV_geometry_program4  *)
	TglProgramVertexLimitNV* = PROCEDURE{C}(target: Enum; limit: Int);
	(* GL_NV_gpu_program4  *)
	TglProgramLocalParameterI4iNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglProgramLocalParameterI4ivNV* = PROCEDURE{C}(target: Enum; index: Uint;  params: Pint);
	TglProgramLocalParametersI4ivNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: Pint);
	TglProgramLocalParameterI4uiNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglProgramLocalParameterI4uivNV* = PROCEDURE{C}(target: Enum; index: Uint;  params: PInt);
	TglProgramLocalParametersI4uivNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: PInt);
	TglProgramEnvParameterI4iNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Int; y: Int; z: Int; w: Int);
	TglProgramEnvParameterI4ivNV* = PROCEDURE{C}(target: Enum; index: Uint;  params: Pint);
	TglProgramEnvParametersI4ivNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: Pint);
	TglProgramEnvParameterI4uiNV* = PROCEDURE{C}(target: Enum; index: Uint; x: Uint; y: Uint; z: Uint; w: Uint);
	TglProgramEnvParameterI4uivNV* = PROCEDURE{C}(target: Enum; index: Uint;  params: PInt);
	TglProgramEnvParametersI4uivNV* = PROCEDURE{C}(target: Enum; index: Uint; count: Sizei;  params: PInt);
	TglGetProgramLocalParameterIivNV* = PROCEDURE{C}(target: Enum; index: Uint; params: Pint);
	TglGetProgramLocalParameterIuivNV* = PROCEDURE{C}(target: Enum; index: Uint; params: PInt);
	TglGetProgramEnvParameterIivNV* = PROCEDURE{C}(target: Enum; index: Uint; params: Pint);
	TglGetProgramEnvParameterIuivNV* = PROCEDURE{C}(target: Enum; index: Uint; params: PInt);
	(* GL_NV_parameter_buffer_object  *)
	TglProgramBufferParametersfvNV* = PROCEDURE{C}(target: Enum; buffer: Uint; index: Uint; count: Sizei;  params: PFloat);
	TglProgramBufferParametersIivNV* = PROCEDURE{C}(target: Enum; buffer: Uint; index: Uint; count: Sizei;  params: Int);
	TglProgramBufferParametersIuivNV* = PROCEDURE{C}(target: Enum; buffer: Uint; index: Uint; count: Uint;  params: PInt);
	(* GL_NV_transform_feedback  *)
	TglBeginTransformFeedbackNV* = PROCEDURE{C}(primitiveMode: Enum);
	TglEndTransformFeedbackNV* = PROCEDURE{C}();
	TglTransformFeedbackAttribsNV* = PROCEDURE{C}(count: Sizei;  attribs: Int; bufferMode: Enum);
	TglBindBufferRangeNV* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint; offset: Int; size: Sizei);
	TglBindBufferOffsetNV* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint; offset: Int);
	TglBindBufferBaseNV* = PROCEDURE{C}(target: Enum; index: Uint; buffer: Uint);
	TglTransformFeedbackVaryingsNV* = PROCEDURE{C}(xprogram: Uint; count: Sizei;  varyings: PPChar; bufferMode: Enum);
	TglActiveVaryingNV* = PROCEDURE{C}(xprogram: Uint;  name: ADDRESS);
	TglGetVaryingLocationNV* = PROCEDURE{C}(xprogram: Uint;  name: ADDRESS): Int;
	TglGetActiveVaryingNV* = PROCEDURE{C}(xprogram: Uint; index: Uint; bufSize: Sizei; length: PSizei; size: PSizei; xtype: PEnum; name: PChar);
	TglGetTransformFeedbackVaryingNV* = PROCEDURE{C}(xprogram: Uint; index: Uint; location: Pint);
	TglTransformFeedbackStreamAttribsNV* = PROCEDURE{C}(count: Sizei;  attribs: Pint; nbuffers: Sizei;  bufstreams: Pint; bufferMode: Enum);
	(* GL_NV_conditional_render  *)
	TglBeginConditionalRenderNV* = PROCEDURE{C}(id: Uint; mode: Enum);
	TglEndConditionalRenderNV* = PROCEDURE{C}();
	(* GL_NV_present_video  *)
	TglPresentFrameKeyedNV* = PROCEDURE{C}(video_slot: Uint; minPresentTime: Uint64EXT; BeginPresentTimeId: Uint; presentDuratioId: Uint; xtype: Enum; target0: Enum; fill0: Uint; key0: Uint; target1: Enum; fill1: Uint; key1: Uint);
	TglPresentFrameDualFillNV* = PROCEDURE{C}(video_slot: Uint; minPresentTime: Uint64EXT; BeginPresentTimeId: Uint; presentDurationId: Uint; xtype: Enum; target0: Enum; fill0: Uint; target1: Enum; fill1: Uint; target2: Enum; fill2: Uint; target3: Enum; fill3: Uint);
	TglGetVideoivNV* = PROCEDURE{C}(video_slot: Uint; pname: Enum; params: Pint);
	TglGetVideouivNV* = PROCEDURE{C}(video_slot: Uint; pname: Enum; params: PInt);
	TglGetVideoi64vNV* = PROCEDURE{C}(video_slot: Uint; pname: Enum; params: Pint64EXT);
	TglGetVideoui64vNV* = PROCEDURE{C}(video_slot: Uint; pname: Enum; params: PInt64EXT);
	(*  TglVideoParameterivNV  = PROCEDURE{C}(video_slot: Uint; pname: Enum;  params: Pint);   *)
	(* GL_NV_explicit_multisample  *)
	TglGetMultisamplefvNV* = PROCEDURE{C}(pname: Enum; index: Uint; val: PFloat);
	TglSampleMaskIndexedNV* = PROCEDURE{C}(index: Uint; mask: Bitfield);
	TglTexRenderbufferNV* = PROCEDURE{C}(target: Enum; renderbuffer: Uint);
	(* GL_NV_transform_feedback2  *)
	TglBindTransformFeedbackNV* = PROCEDURE{C}(target: Enum; id: Uint);
	TglDeleteTransformFeedbacksNV* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglGenTransformFeedbacksNV* = PROCEDURE{C}(n: Sizei; ids: PInt);
	TglIsTransformFeedbackNV* = PROCEDURE{C}(id: Uint): Boolean;
	TglPauseTransformFeedbackNV* = PROCEDURE{C}();
	TglResumeTransformFeedbackNV* = PROCEDURE{C}();
	TglDrawTransformFeedbackNV* = PROCEDURE{C}(mode: Enum; id: Uint);
	(* GL_NV_video_capture  *)
	TglBeginVideoCaptureNV* = PROCEDURE{C}(video_capture_slot: Uint);
	TglBindVideoCaptureStreamBufferNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; frame_region: Enum; offset: Sizei);
	TglBindVideoCaptureStreamTextureNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; frame_region: Enum; target: Enum; texture: Uint);
	TglEndVideoCaptureNV* = PROCEDURE{C}(video_capture_slot: Uint);
	TglGetVideoCaptureivNV* = PROCEDURE{C}(video_capture_slot: Uint; pname: Enum; params: Pint);
	TglGetVideoCaptureStreamivNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: Pint);
	TglGetVideoCaptureStreamfvNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PFloat);
	TglGetVideoCaptureStreamdvNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum; params: PDouble);
	TglVideoCaptureNV* = PROCEDURE{C}(video_capture_slot: Uint; sequence_num: PInt; capture_time: PInt64EXT): Enum;
	TglVideoCaptureStreamParameterivNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum;  params: Pint);
	TglVideoCaptureStreamParameterfvNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum;  params: PFloat);
	TglVideoCaptureStreamParameterdvNV* = PROCEDURE{C}(video_capture_slot: Uint; stream: Uint; pname: Enum;  params: PDouble);
	(* GL_NV_copy_image  *)
	TglCopyImageSubDataNV* = PROCEDURE{C}(srcName: Uint; srcTarget: Enum; srcLevel: Int; srcX: Int; srcY: Int; srcZ: Int; dstName: Uint; dstTarget: Enum; dstLevel: Int; dstX: Int; dstY: Int; dstZ: Int; width: Sizei; height: Sizei; depth: Sizei);
	(* GL_NV_shader_buffer_load  *)
	TglMakeBufferResidentNV* = PROCEDURE{C}(target: Enum; access: Enum);
	TglMakeBufferNonResidentNV* = PROCEDURE{C}(target: Enum);
	TglIsBufferResidentNV* = PROCEDURE{C}(target: Enum): Boolean;
	TglMakeNamedBufferResidentNV* = PROCEDURE{C}(buffer: Uint; access: Enum);
	TglMakeNamedBufferNonResidentNV* = PROCEDURE{C}(buffer: Uint);
	TglIsNamedBufferResidentNV* = PROCEDURE{C}(buffer: Uint): Boolean;
	TglGetBufferParameterui64vNV* = PROCEDURE{C}(target: Enum; pname: Enum; params: PInt64EXT);
	TglGetNamedBufferParameterui64vNV* = PROCEDURE{C}(buffer: Uint; pname: Enum; params: PInt64EXT);
	TglGetIntegerui64vNV* = PROCEDURE{C}(value: Enum; result: PInt64EXT);
	TglUniformui64NV* = PROCEDURE{C}(location: Int; value: Uint64EXT);
	TglUniformui64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt64EXT);
	TglGetUniformui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; params: PInt64EXT);
	TglProgramUniformui64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; value: Uint64EXT);
	TglProgramUniformui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt64EXT);
	(* GL_NV_vertex_buffer_unified_memory  *)
	TglBufferAddressRangeNV* = PROCEDURE{C}(pname: Enum; index: Uint; adress: Uint64EXT; length: Sizei);
	TglVertexFormatNV* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei);
	TglNormalFormatNV* = PROCEDURE{C}(xtype: Enum; stride: Sizei);
	TglColorFormatNV* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei);
	TglIndexFormatNV* = PROCEDURE{C}(xtype: Enum; stride: Sizei);
	TglTexCoordFormatNV* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei);
	TglEdgeFlagFormatNV* = PROCEDURE{C}(stride: Sizei);
	TglSecondaryColorFormatNV* = PROCEDURE{C}(size: Int; xtype: Enum; stride: Sizei);
	TglFogCoordFormatNV* = PROCEDURE{C}(xtype: Enum; stride: Sizei);
	TglVertexAttribFormatNV* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; normalized: Boolean; stride: Sizei);
	TglVertexAttribIFormatNV* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei);
	TglGetIntegerui64i_vNV* = PROCEDURE{C}(value: Enum; index: Uint; Result: PInt64EXT);
	(* GL_NV_gpu_program5  *)
	TglProgramSubroutineParametersuivNV* = PROCEDURE{C}(target: Enum; count: Sizei;  params: PInt);
	TglGetProgramSubroutineParameteruivNV* = PROCEDURE{C}(target: Enum; index: Uint; param: PInt);
	(*  GL_NV_gpu_shader5  *)
	TglUniform1i64NV* = PROCEDURE{C}(location: Int; x: Int64EXT);
	TglUniform2i64NV* = PROCEDURE{C}(location: Int; x: Int64EXT; y: Int64EXT);
	TglUniform3i64NV* = PROCEDURE{C}(location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglUniform4i64NV* = PROCEDURE{C}(location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglUniform1i64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: Pint64EXT);
	TglUniform2i64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: Pint64EXT);
	TglUniform3i64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: Pint64EXT);
	TglUniform4i64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: Pint64EXT);
	TglUniform1ui64NV* = PROCEDURE{C}(location: Int; x: Uint64EXT);
	TglUniform2ui64NV* = PROCEDURE{C}(location: Int; x: Uint64EXT; y: Uint64EXT);
	TglUniform3ui64NV* = PROCEDURE{C}(location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglUniform4ui64NV* = PROCEDURE{C}(location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglUniform1ui64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt64EXT);
	TglUniform2ui64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt64EXT);
	TglUniform3ui64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt64EXT);
	TglUniform4ui64vNV* = PROCEDURE{C}(location: Int; count: Sizei;  value: PInt64EXT);
	TglGetUniformi64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; params: Pint64EXT);
	TglProgramUniform1i64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Int64EXT);
	TglProgramUniform2i64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT);
	TglProgramUniform3i64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglProgramUniform4i64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglProgramUniform1i64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint64EXT);
	TglProgramUniform2i64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint64EXT);
	TglProgramUniform3i64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint64EXT);
	TglProgramUniform4i64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: Pint64EXT);
	TglProgramUniform1ui64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Uint64EXT);
	TglProgramUniform2ui64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT);
	TglProgramUniform3ui64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglProgramUniform4ui64NV* = PROCEDURE{C}(xprogram: Uint; location: Int; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglProgramUniform1ui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt64EXT);
	TglProgramUniform2ui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt64EXT);
	TglProgramUniform3ui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt64EXT);
	TglProgramUniform4ui64vNV* = PROCEDURE{C}(xprogram: Uint; location: Int; count: Sizei;  value: PInt64EXT);
	(* GL_NV_vertex_attrib_integer_64bit  *)
	TglVertexAttribL1i64NV* = PROCEDURE{C}(index: Uint; x: Int64EXT);
	TglVertexAttribL2i64NV* = PROCEDURE{C}(index: Uint; x: Int64EXT; y: Int64EXT);
	TglVertexAttribL3i64NV* = PROCEDURE{C}(index: Uint; x: Int64EXT; y: Int64EXT; z: Int64EXT);
	TglVertexAttribL4i64NV* = PROCEDURE{C}(index: Uint; x: Int64EXT; y: Int64EXT; z: Int64EXT; w: Int64EXT);
	TglVertexAttribL1i64vNV* = PROCEDURE{C}(index: Uint;  v: Pint64EXT);
	TglVertexAttribL2i64vNV* = PROCEDURE{C}(index: Uint;  v: Pint64EXT);
	TglVertexAttribL3i64vNV* = PROCEDURE{C}(index: Uint;  v: Pint64EXT);
	TglVertexAttribL4i64vNV* = PROCEDURE{C}(index: Uint;  v: Pint64EXT);
	TglVertexAttribL1ui64NV* = PROCEDURE{C}(index: Uint; x: Uint64EXT);
	TglVertexAttribL2ui64NV* = PROCEDURE{C}(index: Uint; x: Uint64EXT; y: Uint64EXT);
	TglVertexAttribL3ui64NV* = PROCEDURE{C}(index: Uint; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT);
	TglVertexAttribL4ui64NV* = PROCEDURE{C}(index: Uint; x: Uint64EXT; y: Uint64EXT; z: Uint64EXT; w: Uint64EXT);
	TglVertexAttribL1ui64vNV* = PROCEDURE{C}(index: Uint;  v: PInt64EXT);
	TglVertexAttribL2ui64vNV* = PROCEDURE{C}(index: Uint;  v: PInt64EXT);
	TglVertexAttribL3ui64vNV* = PROCEDURE{C}(index: Uint;  v: PInt64EXT);
	TglVertexAttribL4ui64vNV* = PROCEDURE{C}(index: Uint;  v: PInt64EXT);
	TglGetVertexAttribLi64vNV* = PROCEDURE{C}(index: Uint; pname: Enum; params: Pint64EXT);
	TglGetVertexAttribLui64vNV* = PROCEDURE{C}(index: Uint; pname: Enum; params: PInt64EXT);
	TglVertexAttribLFormatNV* = PROCEDURE{C}(index: Uint; size: Int; xtype: Enum; stride: Sizei);
	(* GL_NV_vdpau_interop  *)
	TglVDPAUInitNV* = PROCEDURE{C}( vdpDevice: PVoid;  getProcAddress: PVoid);
	TglVDPAUFiniNV* = PROCEDURE{C};
	TglVDPAURegisterVideoSurfaceNV* = PROCEDURE{C}(vdpSurface: PVoid; target: Enum; numTextureNames: Sizei;  textureNames: PInt): GLvdpauSurfaceNV;
	TglVDPAURegisterOutputSurfaceNV* = PROCEDURE{C}(vdpSurface: PVoid; target: Enum; numTextureNames: Sizei;  textureNames: PInt): GLvdpauSurfaceNV;
	TglVDPAUIsSurfaceNV* = PROCEDURE{C}(surface: GLvdpauSurfaceNV);
	TglVDPAUUnregisterSurfaceNV* = PROCEDURE{C}(surface: GLvdpauSurfaceNV);
	TglVDPAUGetSurfaceivNV* = PROCEDURE{C}(surface: GLvdpauSurfaceNV; pname: Enum; bufSize: Sizei; length: PSizei; values: Pint);
	TglVDPAUSurfaceAccessNV* = PROCEDURE{C}(surface: GLvdpauSurfaceNV; access: Enum);
	TglVDPAUMapSurfacesNV* = PROCEDURE{C}(numSurfaces: Sizei;  surfaces: PGLvdpauSurfaceNV);
	TglVDPAUUnmapSurfacesNV* = PROCEDURE{C}(numSurface: Sizei;  surfaces: PGLvdpauSurfaceNV);
	(* GL_NV_texture_barrier  *)
	TglTextureBarrierNV* = PROCEDURE{C};
	(* (4.3)  *)
	(* GL_NV_path_rendering  *)
	TglGenPathsNV* = PROCEDURE{C}(range : Sizei) : Uint;
	TglDeletePathsNV* = PROCEDURE{C}(path : Uint; range : Sizei);
	TglIsPathNV* = PROCEDURE{C}(path : Uint) : Boolean;
	TglPathCommandsNV* = PROCEDURE{C}(path : Uint; numCommands : Sizei;  commands : PUbyte; numCoords : Sizei; coordType : Enum;  coords : PVoid);
	TglPathCoordsNV* = PROCEDURE{C}(path : Uint; numCoords : Sizei; coordType : Enum;  coords : PVoid);
	TglPathSubCommandsNV* = PROCEDURE{C}(path : Uint; commandStart : Sizei; commandsToDelete : Sizei; numCommands : Sizei;  commands : PUbyte; numCoords : Sizei; coordType : Enum;  coords : PVoid);
	TglPathSubCoordsNV* = PROCEDURE{C}(path : Uint; coordStart : Sizei; numCoords : Sizei; coordType : Enum;  coords : PVoid);
	TglPathStringNV* = PROCEDURE{C}(path : Uint; format : Enum; length : Sizei;  pathString : PVoid);
	TglPathGlyphsNV* = PROCEDURE{C}(firstPathName : Uint; fontTarget : Enum;  fontName : PVoid; fontStyle : Bitfield; numGlyphs : Sizei; type_ : Enum;  charcodes : PVoid; handleMissingGlyphs : Enum; pathParameterTemplate : Uint; emScale : Float);
	TglPathGlyphRangeNV* = PROCEDURE{C}(firstPathName : Uint; fontTarget : Enum;  fontName : PVoid; fontStyle : Bitfield; firstGlyph : Uint; numGlyphs : Sizei; handleMissingGlyphs : Enum; pathParameterTemplate : Uint; emScale : Float);
	TglWeightPathsNV* = PROCEDURE{C}(resultPath : Uint; numPaths : Sizei;  paths : PInt;  weights : PFloat);
	TglCopyPathNV* = PROCEDURE{C}(resultPath : Uint; srcPath : Uint);
	TglInterpolatePathsNV* = PROCEDURE{C}(resultPath : Uint; pathA : Uint; pathB : Uint; weight : Float);
	TglTransformPathNV* = PROCEDURE{C}(resultPath : Uint; srcPath : Uint; transformType : Enum;  transformValues : PFloat);
	TglPathParameterivNV* = PROCEDURE{C}(path : Uint; pname : Enum;  value : Pint);
	TglPathParameteriNV* = PROCEDURE{C}(path : Uint; pname : Enum; value : Int);
	TglPathParameterfvNV* = PROCEDURE{C}(path : Uint; pname : Enum;  value : PFloat);
	TglPathParameterfNV* = PROCEDURE{C}(path : Uint; pname : Enum; value : Float);
	TglPathDashArrayNV* = PROCEDURE{C}(path : Uint; dashCount : Sizei;  dashArray : PFloat);
	TglPathStencilFuncNV* = PROCEDURE{C}(func : Enum; ref : Int; mask : Uint);
	TglPathStencilDepthOffsetNV* = PROCEDURE{C}(factor : Float; units : Float);
	TglStencilFillPathNV* = PROCEDURE{C}(path : Uint; fillMode : Enum; mask : Uint);
	TglStencilStrokePathNV* = PROCEDURE{C}(path : Uint; reference : Int; mask : Uint);
	TglStencilFillPathInstancedNV* = PROCEDURE{C}(numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; fillMode : Enum; mask : Uint; transformType : Enum;  transformValues : PFloat);
	TglStencilStrokePathInstancedNV* = PROCEDURE{C}(numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; reference : Int; mask : Uint; transformType : Enum;  transformValues : PFloat);
	TglPathCoverDepthFuncNV* = PROCEDURE{C}(func : Enum);
	TglPathColorGenNV* = PROCEDURE{C}(color : Enum; genMode : Enum; colorFormat : Enum;  coeffs : PFloat);
	TglPathTexGenNV* = PROCEDURE{C}(texCoordSet : Enum; genMode : Enum; components : Int;  coeffs : PFloat);
	TglPathFogGenNV* = PROCEDURE{C}(genMode : Enum);
	TglCoverFillPathNV* = PROCEDURE{C}(path : Uint; coverMode : Enum);
	TglCoverStrokePathNV* = PROCEDURE{C}(path : Uint; coverMode : Enum);
	TglCoverFillPathInstancedNV* = PROCEDURE{C}(numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; coverMode : Enum; transformType : Enum;  transformValues : PFloat);
	TglCoverStrokePathInstancedNV* = PROCEDURE{C}(numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; coverMode : Enum; transformType : Enum;  transformValues : PFloat);
	TglGetPathParameterivNV* = PROCEDURE{C}(path : Uint; pname : Enum; value : Pint);
	TglGetPathParameterfvNV* = PROCEDURE{C}(path : Uint; pname : Enum; value : PFloat);
	TglGetPathCommandsNV* = PROCEDURE{C}(path : Uint; commands : PUbyte);
	TglGetPathCoordsNV* = PROCEDURE{C}(path : Uint; coords : PFloat);
	TglGetPathDashArrayNV* = PROCEDURE{C}(path : Uint; dashArray : PFloat);
	TglGetPathMetricsNV* = PROCEDURE{C}(metricQueryMask : Bitfield; numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; stride : Sizei; metrics : PFloat);
	TglGetPathMetricRangeNV* = PROCEDURE{C}(metricQueryMask : Bitfield; firstPathName : Uint; numPaths : Sizei; stride : Sizei; metrics : PFloat);
	TglGetPathSpacingNV* = PROCEDURE{C}(pathListMode : Enum; numPaths : Sizei; pathNameType : Enum;  paths : PVoid; pathBase : Uint; advanceScale : Float; kerningScale : Float; transformType : Enum; returnedSpacing : PFloat);
	TglGetPathColorGenivNV* = PROCEDURE{C}(color : Enum; pname : Enum; value : Pint);
	TglGetPathColorGenfvNV* = PROCEDURE{C}(color : Enum; pname : Enum; value : PFloat);
	TglGetPathTexGenivNV* = PROCEDURE{C}(texCoordSet : Enum; pname : Enum; value : Pint);
	TglGetPathTexGenfvNV* = PROCEDURE{C}(texCoordSet : Enum; pname : Enum; value : PFloat);
	TglIsPointInFillPathNV* = PROCEDURE{C}(path : Uint; mask : Uint; x : Float; y : Float) : Boolean;
	TglIsPointInStrokePathNV* = PROCEDURE  {C}(path : Uint; x : Float; y : Float) : Boolean;
	TglGetPathLengthNV* = PROCEDURE{C}(path : Uint; startSegment : Sizei; numSegments : Sizei) : Float;
	TglPointAlongPathNV* = PROCEDURE{C}(path : Uint; startSegment : Sizei; numSegments : Sizei; distance : Float; x : PFloat; y : PFloat; tangentX : PFloat; tangentY : PFloat) : Boolean;
	(* GL_AMD_pinned_memory  *)
	(* GL_AMD_stencil_operation_extended  *)
	TglStencilOpValueAMD* = PROCEDURE{C}(face : Enum; value : Uint);
	(* GL_AMD_vertex_shader_viewport_index  *)
	(* GL_AMD_vertex_shader_layer  *)
	(* GL_NV_bindless_texture  *)
	TglGetTextureHandleNV* = PROCEDURE{C}(texture : Uint ) : Uint64;
	TglGetTextureSamplerHandleNV* = PROCEDURE{C}(texture : Uint; sampler : Uint) : Uint64;
	TglMakeTextureHandleResidentNV* = PROCEDURE{C}(handle : Uint64);
	TglMakeTextureHandleNonResidentNV* = PROCEDURE{C}(handle : Uint64);
	TglGetImageHandleNV* = PROCEDURE{C}(texture : Uint; level : Int; layered : Boolean; layer : Int; format : Enum) : Uint64;
	TglMakeImageHandleResidentNV* = PROCEDURE{C}(handle : Uint64; access : Enum);
	TglMakeImageHandleNonResidentNV* = PROCEDURE{C}(handle : Uint64);
	TglUniformHandleui64NV* = PROCEDURE{C}(location : Int; value : Uint64);
	TglUniformHandleui64vNV* = PROCEDURE{C}(location : Int; cowunt : Sizei;  value : PInt64);
	TglProgramUniformHandleui64NV* = PROCEDURE{C}(program_ : Uint; location : Int; value : Uint64);
	TglProgramUniformHandleui64vNV* = PROCEDURE{C}(program_ : Uint; location : Int; count : Sizei;  values : PInt64);
	TglIsTextureHandleResidentNV* = PROCEDURE{C}(handle : Uint64) : Boolean;
	TglIsImageHandleResidentNV* = PROCEDURE{C}(handle : Uint64) : Boolean;
	(* GL_NV_shader_atomic_float  *)
	(* GL_AMD_query_buffer_object  *)
	(*  *)
	(*  GL_PGI_misc_hints  *)
	TglHintPGI* = PROCEDURE{C}(target: Enum; mode: Int);
	(*  GL_SGIS_detail_texture  *)
	TglDetailTexFuncSGIS* = PROCEDURE{C}(target: Enum; n: Sizei; points: PFloat);
	TglGetDetailTexFuncSGIS* = PROCEDURE{C}(target: Enum; points: PFloat);
	(*  GL_SGIS_fog_function  *)
	TglFogFuncSGIS* = PROCEDURE{C}(n: Sizei; points: PFloat);
	TglGetFogFuncSGIS* = PROCEDURE{C}(points: PFloat);
	(*  GL_SGIS_multisample  *)
	TglSampleMaskSGIS* = PROCEDURE{C}(value: Clampf; invert: Boolean);
	TglSamplePatternSGIS* = PROCEDURE{C}(pattern: Enum);
	(*  GL_SGIS_pixel_texture  *)
	TglPixelTexGenParameteriSGIS* = PROCEDURE{C}(pname: Enum; param: Int);
	TglPixelTexGenParameterivSGIS* = PROCEDURE{C}(pname: Enum; params: Pint);
	TglPixelTexGenParameterfSGIS* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPixelTexGenParameterfvSGIS* = PROCEDURE{C}(pname: Enum; params: PFloat);
	TglGetPixelTexGenParameterivSGIS* = PROCEDURE{C}(pname: Enum; params: Pint);
	TglGetPixelTexGenParameterfvSGIS* = PROCEDURE{C}(pname: Enum; params: PFloat);
	(*  GL_SGIS_point_parameters  *)
	TglPointParameterfSGIS* = PROCEDURE{C}(pname: Enum; param: Float);
	TglPointParameterfvSGIS* = PROCEDURE{C}(pname: Enum; params: PFloat);
	(*  GL_SGIS_sharpen_texture  *)
	TglSharpenTexFuncSGIS* = PROCEDURE{C}(target: Enum; n: Sizei; points: PFloat);
	TglGetSharpenTexFuncSGIS* = PROCEDURE{C}(target: Enum; points: PFloat);
	(*  GL_SGIS_texture4D  *)
	TglTexImage4DSGIS* = PROCEDURE{C}(target: Enum; level: Int; internalformat: Enum; width: Sizei; height: Sizei; depth: Sizei; size4d: Sizei; border: Int; format: Enum; xtype:  Enum; pixels: PVoid);
	TglTexSubImage4DSGIS* = PROCEDURE{C}(target: Enum; level: Int; xoffset: Int; yoffset: Int; zoffset: Int; woffset: Int; width: Sizei; height: Sizei; depth: Sizei; size4d: Sizei; format: Enum; xtype:  Enum; pixels: PVoid);
	(*  GL_SGIS_texture_color_mask  *)
	TglTextureColorMaskSGIS* = PROCEDURE{C}(red: Boolean; green: Boolean; blue: Boolean; alpha: Boolean);
	(*  GL_SGIS_texture_filter4  *)
	TglGetTexFilterFuncSGIS* = PROCEDURE{C}(target: Enum; filter: Enum; weights: PFloat);
	TglTexFilterFuncSGIS* = PROCEDURE{C}(target: Enum; filter: Enum; n: Sizei; weights: PFloat);
	(*  GL_SGIX_async  *)
	TglAsyncMarkerSGIX* = PROCEDURE{C}(marker: Uint);
	TglFinishAsyncSGIX* = PROCEDURE{C}(markerp: PInt): Int;
	TglPollAsyncSGIX* = PROCEDURE{C}(markerp: PInt): Int;
	TglGenAsyncMarkersSGIX* = PROCEDURE{C}(range: Sizei): Uint;
	TglDeleteAsyncMarkersSGIX* = PROCEDURE{C}(marker: Uint; range: Sizei);
	TglIsAsyncMarkerSGIX* = PROCEDURE{C}(marker: Uint): Boolean;
	(*  GL_SGIX_flush_raster  *)
	TglFlushRasterSGIX* = PROCEDURE{C}();
	(*  GL_SGIX_fragment_lighting  *)
	TglFragmentColorMaterialSGIX* = PROCEDURE{C}(face: Enum; mode: Enum);
	TglFragmentLightfSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; param: Float);
	TglFragmentLightfvSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; params: PFloat);
	TglFragmentLightiSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; param: Int);
	TglFragmentLightivSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; params: Pint);
	TglFragmentLightModelfSGIX* = PROCEDURE{C}(pname: Enum; param: Float);
	TglFragmentLightModelfvSGIX* = PROCEDURE{C}(pname: Enum; params: PFloat);
	TglFragmentLightModeliSGIX* = PROCEDURE{C}(pname: Enum; param: Int);
	TglFragmentLightModelivSGIX* = PROCEDURE{C}(pname: Enum; params: Pint);
	TglFragmentMaterialfSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; param: Float);
	TglFragmentMaterialfvSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; params: PFloat);
	TglFragmentMaterialiSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; param: Int);
	TglFragmentMaterialivSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; params: Pint);
	TglGetFragmentLightfvSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; params: PFloat);
	TglGetFragmentLightivSGIX* = PROCEDURE{C}(light: Enum; pname: Enum; params: Pint);
	TglGetFragmentMaterialfvSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; params: PFloat);
	TglGetFragmentMaterialivSGIX* = PROCEDURE{C}(face: Enum; pname: Enum; params: Pint);
	TglLightEnviSGIX* = PROCEDURE{C}(pname: Enum; param: Int);
	(*  GL_SGIX_framezoom  *)
	TglFrameZoomSGIX* = PROCEDURE{C}(factor: Int);
	(*  GL_SGIX_igloo_interface  *)
	TglIglooInterfaceSGIX* = PROCEDURE{C}(pname: Enum; params: PVoid);
	(*  GL_SGIX_instruments  *)
	TglGetInstrumentsSGIX* = PROCEDURE{C}(): Int;
	TglInstrumentsBufferSGIX* = PROCEDURE{C}(size: Sizei; buffer: Pint);
	TglPollInstrumentsSGIX* = PROCEDURE{C}(marker_p: Pint): Int;
	TglReadInstrumentsSGIX* = PROCEDURE{C}(marker: Int);
	TglStartInstrumentsSGIX* = PROCEDURE{C}();
	TglStopInstrumentsSGIX* = PROCEDURE{C}(marker: Int);
	(*  GL_SGIX_list_priority  *)
	TglGetListParameterfvSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; params: PFloat);
	TglGetListParameterivSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; params: Pint);
	TglListParameterfSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; param: Float);
	TglListParameterfvSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; params: PFloat);
	TglListParameteriSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; param: Int);
	TglListParameterivSGIX* = PROCEDURE{C}(list: Uint; pname: Enum; params: Pint);
	(*  GL_SGIX_pixel_texture  *)
	TglPixelTexGenSGIX* = PROCEDURE{C}(mode: Enum);
	(*  GL_SGIX_polynomial_ffd  *)
	TglDeformationMap3dSGIX* = PROCEDURE{C}(target: Enum; u1: Double; u2: Double; ustride: Int; uorder: Int; v1: Double; v2: Double; vstride: Int; vorder: Int; w1: Double; w2: Double; wstride: Int; worder: Int; points: PDouble);
	TglDeformationMap3fSGIX* = PROCEDURE{C}(target: Enum; u1: Float; u2: Float; ustride: Int; uorder: Int; v1: Float; v2: Float; vstride: Int; vorder: Int; w1: Float; w2: Float; wstride: Int; worder: Int; points: PFloat);
	TglDeformSGIX* = PROCEDURE{C}(mask: Bitfield);
	TglLoadIdentityDeformationMapSGIX* = PROCEDURE{C}(mask: Bitfield);
	(*  GL_SGIX_reference_plane  *)
	TglReferencePlaneSGIX* = PROCEDURE{C}( equation: PDouble);
	(*  GL_SGIX_sprite  *)
	TglSpriteParameterfSGIX* = PROCEDURE{C}(pname: Enum; param: Float);
	TglSpriteParameterfvSGIX* = PROCEDURE{C}(pname: Enum; params: PFloat);
	TglSpriteParameteriSGIX* = PROCEDURE{C}(pname: Enum; param: Int);
	TglSpriteParameterivSGIX* = PROCEDURE{C}(pname: Enum; params: Pint);
	(*  GL_SGIX_tag_sample_buffer  *)
	TglTagSampleBufferSGIX* = PROCEDURE{C}();
	(*  GL_SGI_color_table  *)
	TglColorTableSGI* = PROCEDURE{C}(target: Enum; internalformat: Enum; width: Sizei; format: Enum; xtype:  Enum; table: PVoid);
	TglColorTableParameterfvSGI* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglColorTableParameterivSGI* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	TglCopyColorTableSGI* = PROCEDURE{C}(target: Enum; internalformat: Enum; x: Int; y: Int; width: Sizei);
	TglGetColorTableSGI* = PROCEDURE{C}(target: Enum; format: Enum; xtype:  Enum; table: PVoid);
	TglGetColorTableParameterfvSGI* = PROCEDURE{C}(target: Enum; pname: Enum; params: PFloat);
	TglGetColorTableParameterivSGI* = PROCEDURE{C}(target: Enum; pname: Enum; params: Pint);
	(*  GL_SUNX_constant_data  *)
	TglFinishTextureSUNX* = PROCEDURE{C}();
	(*  GL_SUN_global_alpha  *)
	TglGlobalAlphaFactorbSUN* = PROCEDURE{C}(factor: Byte);
	TglGlobalAlphaFactorsSUN* = PROCEDURE{C}(factor: Short);
	TglGlobalAlphaFactoriSUN* = PROCEDURE{C}(factor: Int);
	TglGlobalAlphaFactorfSUN* = PROCEDURE{C}(factor: Float);
	TglGlobalAlphaFactordSUN* = PROCEDURE{C}(factor: Double);
	TglGlobalAlphaFactorubSUN* = PROCEDURE{C}(factor: Ubyte);
	TglGlobalAlphaFactorusSUN* = PROCEDURE{C}(factor: Ushort);
	TglGlobalAlphaFactoruiSUN* = PROCEDURE{C}(factor: Uint);
	(*  GL_SUN_mesh_array  *)
	TglDrawMeshArraysSUN* = PROCEDURE{C}(mode: Enum; first: Int; count: Sizei; width: Sizei);
	(*  GL_SUN_triangle_list  *)
	TglReplacementCodeuiSUN* = PROCEDURE{C}(code: Uint);
	TglReplacementCodeusSUN* = PROCEDURE{C}(code: Ushort);
	TglReplacementCodeubSUN* = PROCEDURE{C}(code: Ubyte);
	TglReplacementCodeuivSUN* = PROCEDURE{C}( code: PInt);
	TglReplacementCodeusvSUN* = PROCEDURE{C}( code: PUshort);
	TglReplacementCodeubvSUN* = PROCEDURE{C}( code: PUbyte);
	TglReplacementCodePointerSUN* = PROCEDURE{C}(xtype:  Enum; stride: Sizei; xpointer: PVoid);
	(*  GL_SUN_vertex  *)
	TglColor4ubVertex2fSUN* = PROCEDURE{C}(r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float);
	TglColor4ubVertex2fvSUN* = PROCEDURE{C}( c: PUbyte;  v: PFloat);
	TglColor4ubVertex3fSUN* = PROCEDURE{C}(r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglColor4ubVertex3fvSUN* = PROCEDURE{C}(c: PUbyte; v: PFloat);
	TglColor3fVertex3fSUN* = PROCEDURE{C}(r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglColor3fVertex3fvSUN* = PROCEDURE{C}(c: PFloat; v: PFloat);
	TglNormal3fVertex3fSUN* = PROCEDURE{C}(nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglNormal3fVertex3fvSUN* = PROCEDURE{C}(n: PFloat; v: PFloat);
	TglColor4fNormal3fVertex3fSUN* = PROCEDURE{C}(r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglColor4fNormal3fVertex3fvSUN* = PROCEDURE{C}(c: PFloat; n: PFloat; v: PFloat);
	TglTexCoord2fVertex3fSUN* = PROCEDURE{C}(s: Float; t: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fVertex3fvSUN* = PROCEDURE{C}(tc: PFloat; v: PFloat);
	TglTexCoord4fVertex4fSUN* = PROCEDURE{C}(s: Float; t: Float; p: Float; q: Float; x: Float; y: Float; z: Float; w: Float);
	TglTexCoord4fVertex4fvSUN* = PROCEDURE{C}(tc: PFloat; v: PFloat);
	TglTexCoord2fColor4ubVertex3fSUN* = PROCEDURE{C}(s: Float; t: Float; r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglTexCoord2fColor4ubVertex3fvSUN* = PROCEDURE{C}(tc: PFloat; c: PUbyte; v: PFloat);
	TglTexCoord2fColor3fVertex3fSUN* = PROCEDURE{C}(s: Float; t: Float; r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fColor3fVertex3fvSUN* = PROCEDURE{C}(tc: PFloat; c: PFloat; v: PFloat);
	TglTexCoord2fNormal3fVertex3fSUN* = PROCEDURE{C}(s: Float; t: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fNormal3fVertex3fvSUN* = PROCEDURE{C}( tc: PFloat;  n: PFloat; v: PFloat);
	TglTexCoord2fColor4fNormal3fVertex3fSUN* = PROCEDURE{C}(s: Float; t: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglTexCoord2fColor4fNormal3fVertex3fvSUN* = PROCEDURE{C}( tc: PFloat;  c: PFloat;  n: PFloat;  v: PFloat);
	TglTexCoord4fColor4fNormal3fVertex4fSUN* = PROCEDURE{C}(s: Float; t: Float; p: Float; q: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float; w: Float);
	TglTexCoord4fColor4fNormal3fVertex4fvSUN* = PROCEDURE{C}( tc: PFloat;  c: PFloat;  n: PFloat;  v: PFloat);
	TglReplacementCodeuiVertex3fSUN* = PROCEDURE{C}(rc: Uint; x: Float; y: Float; z: Float);
	TglReplacementCodeuiVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  v: PFloat);
	TglReplacementCodeuiColor4ubVertex3fSUN* = PROCEDURE{C}(rc: Uint; r: Ubyte; g: Ubyte; b: Ubyte; a: Ubyte; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor4ubVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  c: PUbyte;  v: PFloat);
	TglReplacementCodeuiColor3fVertex3fSUN* = PROCEDURE{C}(rc: Uint; r: Float; g: Float; b: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor3fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  c: PFloat;  v: PFloat);
	TglReplacementCodeuiNormal3fVertex3fSUN* = PROCEDURE{C}(rc: Uint; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiNormal3fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  n: PFloat;  v: PFloat);
	TglReplacementCodeuiColor4fNormal3fVertex3fSUN* = PROCEDURE{C}(rc: Uint; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiColor4fNormal3fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  c: PFloat;  n: PFloat;  v: PFloat);
	TglReplacementCodeuiTexCoord2fVertex3fSUN* = PROCEDURE{C}(rc: Uint; s: Float; t: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  tc: PFloat;  v: PFloat);
	TglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN* = PROCEDURE{C}(rc: Uint; s: Float; t: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  tc: PFloat;  n: PFloat;  v: PFloat);
	TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN* = PROCEDURE{C}(rc: Uint; s: Float; t: Float; r: Float; g: Float; b: Float; a: Float; nx: Float; ny: Float; nz: Float; x: Float; y: Float; z: Float);
	TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN* = PROCEDURE{C}( rc: PInt;  tc: PFloat;  c: PFloat;  n: PFloat;  v: PFloat);

	(* -------------------------------------------------  *)
	(*! window support functions for Linux - GLX  *)
	(* -------------------------------------------------  *)
	TglXChooseVisual* = PROCEDURE{C}(dpy: DisplayPtr; screen: Int; attribList: Pint): VisualInfoPtr;
	TglXCopyContext* = PROCEDURE{C}(dpy: DisplayPtr; src: GLXContext; dst: GLXContext; mask: Uint);
	TglXCreateContext* = PROCEDURE{C}(dpy: DisplayPtr; vis: VisualInfoPtr; shareList: GLXContext; direct: Boolean): GLXContext;
	TglXCreateGLXPixmap* = PROCEDURE{C}(dpy: DisplayPtr; vis: VisualInfoPtr; pixmap: Pixmap): GLXPixmap;
	TglXDestroyContext* = PROCEDURE{C}(dpy: DisplayPtr; ctx: GLXContext);
	TglXDestroyGLXPixmap* = PROCEDURE{C}(dpy : DisplayPtr; pix: GLXPixmap);
	TglXGetConfig* = PROCEDURE{C}(dpy : DisplayPtr; vis: VisualInfoPtr; attrib: Int; VAR value: Int): Int;
	TglXGetCurrentContext* = PROCEDURE{C}(): GLXContext;
	TglXGetCurrentDrawable* = PROCEDURE{C}(): GLXDrawable ;
	TglXIsDirect* = PROCEDURE{C}(dpy: DisplayPtr; ctx: GLXContext): Boolean;
	TglXMakeCurrent* = PROCEDURE{C}(dpy: DisplayPtr; drawable: GLXDrawable; ctx: GLXContext): Boolean;
	TglXQueryExtension* = PROCEDURE{C}(dpy: DisplayPtr;  VAR errorBase: Int; VAR eventBase: Int): Boolean;
	TglXQueryVersion* = PROCEDURE{C}(dpy: DisplayPtr; VAR major: Int; VAR minor: Int): Boolean;
	TglXSwapBuffers* = PROCEDURE{C}(dpy: DisplayPtr; drawable: GLXDrawable);
	TglXUseXFont* = PROCEDURE{C}(font: Font; first: Int; count: Int; listBase: Int);
	TglXWaitGL* = PROCEDURE{C};
	TglXWaitX* = PROCEDURE{C};
	TglXGetClientString* = PROCEDURE{C}( dpy: DisplayPtr; name: Int): PChar;
	TglXQueryServerString* = PROCEDURE{C}(dpy: DisplayPtr; screen: Int; name: Int): PChar;
	TglXQueryExtensionsString* = PROCEDURE{C}(dpy: DisplayPtr; screen: Int): PChar;

	(* GLX_VERSION_1_3  *)
	TglXGetFBConfigs* = PROCEDURE{C}(dpy: DisplayPtr; screen: Int; nelements: Pint): GLXFBConfig;
	TglXChooseFBConfig* = PROCEDURE{C}(dpy: DisplayPtr; screen: Int; attriblist: Pint; VAR nelements: Int): GLXFBConfig;
	TglXGetFBConfigAttrib* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; attribute: Int; value: Pint): Int;
	TglXGetVisualFromFBConfig* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig) : VisualInfoPtr;
	TglXCreateWindow* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; win: Window; attriblist: Pint): GLXWindow;
	TglXDestroyWindow* = PROCEDURE{C}(dpy: DisplayPtr; win: GLXWindow);
	TglXCreatePixmap* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; pixmap: Pixmap; attriblist: Pint): GLXPixmap;
	TglXDestroyPixmap* = PROCEDURE{C}(dpy: DisplayPtr; pixmap: GLXPixmap);
	TglXCreatePbuffer* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; attriblist: Pint): GLXPbuffer;
	TglXDestroyPbuffer* = PROCEDURE{C}(dpy: DisplayPtr; pbuf: GLXPbuffer);
	TglXQueryDrawable* = PROCEDURE{C}(dpy: DisplayPtr; draw: GLXDrawable; attribute: Int; value: PInt);
	TglXCreateNewContext* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; renderxtype:  Int; sharelist: GLXContext; direct: Boolean): GLXContext ;
	TglXMakeContextCurrent* = PROCEDURE{C}( display: DisplayPtr; draw: GLXDrawable; readx: GLXDrawable; ctx: GLXContext): Boolean;
	TglXGetCurrentReadDrawable* = PROCEDURE{C}(): GLXDrawable;
	TglXGetCurrentDisplay* = PROCEDURE{C}(): DisplayPtr;
	TglXQueryContext* = PROCEDURE{C}(dpy: DisplayPtr; ctx: GLXContext; attribute: Int; VAR value: Int): Int;
	TglXSelectEvent* = PROCEDURE{C}(dpy: DisplayPtr; draw: GLXDrawable; eventmask: Uint);
	TglXGetSelectedEvent* = PROCEDURE{C}(dpy: DisplayPtr; draw: GLXDrawable; VAR eventmask: Uint);

	(* GLX_VERSION_1_4  *)
	TglXGetProcAddress* = PROCEDURE{C}( name: ADDRESS): Pointer;
	(* GLX_ARB_get_proc_address  *)
	TglXGetProcAddressARB* = PROCEDURE{C}( name: ADDRESS): Pointer;
	(* GLX_ARB_create_context  *)
	TglXCreateContextAttribsARB* = PROCEDURE{C}(dpy: DisplayPtr; config: GLXFBConfig; sharecontext: GLXContext; direct: Boolean;  attriblist: Pint): GLXContext;
	(* GLX_EXT_import_context  *)
	TglXGetCurrentDisplayEXT* = PROCEDURE{C}(): DisplayPtr;
	TglXQueryContextInfoEXT* = PROCEDURE{C}(dpy: DisplayPtr; context: GLXContext; attribute: Int; VAR value: Int): Int;
	TglXGetContextIDEXT* = PROCEDURE{C}( context: GLXContext): GLXContextID;
	TglXImportContextEXT* = PROCEDURE{C}(dpy: DisplayPtr; contextID: GLXContextID): GLXContext;
	TglXFreeContextEXT* = PROCEDURE{C}(dpy: DisplayPtr; context: GLXContext);
	(* GLX_EXT_texture_from_pixmap  *)
	TglXBindTexImageEXT* = PROCEDURE{C}(dpy: DisplayPtr; drawable: GLXDrawable; buffer: Int;  attriblist: Pint);
	TglXReleaseTexImageEXT* = PROCEDURE{C}(dpy: DisplayPtr; drawable: GLXDrawable; buffer: Int);

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
	XglBindAttribLocation- : TglBindAttribLocation;
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
	XglGetAttribLocation- : TglGetAttribLocation;
	GetProgramiv- : TglGetProgramiv;
	GetProgramInfoLog- : TglGetProgramInfoLog;
	GetShaderiv- : TglGetShaderiv;
	GetShaderInfoLog- : TglGetShaderInfoLog;
	GetShaderSource- : TglGetShaderSource;
	XglGetUniformLocation- : TglGetUniformLocation;
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
	XglBindFragDataLocation- : TglBindFragDataLocation;
	XglGetFragDataLocation- : TglGetFragDataLocation;
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
	GetStringi- : TglGetStringi;

	(*! GL_VERSION_3_1 *)
	DrawArraysInstanced- : TglDrawArraysInstanced;
	DrawElementsInstanced- : TglDrawElementsInstanced;
	TexBuffer- : TglTexBuffer;
	PrimitiveRestartIndex- : TglPrimitiveRestartIndex;

	(*! GL_VERSION_3_2 *)
	(* OpenGL 3.2 also reuses entry points from these extensions- : *)
	(*  ARB_draw_elements_base_vertex *)
	(*  ARB_provoking_vertex *)
	(*  ARB_sync *)
	(*  ARB_texture_multisample *)
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
	XglGetAttribLocationARB- : TglGetAttribLocationARB;
	XglBindAttribLocationARB- : TglBindAttribLocationARB;
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
	XglGetUniformLocationARB- : TglGetUniformLocationARB;
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
	XglGetUniformBlockIndex- : TglGetUniformBlockIndex;
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
	(*  GL_ARB_shading_language_include  *)
	XglNamedStringARB- : TglNamedStringARB;
	XglDeleteNamedStringARB- : TglDeleteNamedStringARB;
	CompileShaderIncludeARB- : TglCompileShaderIncludeARB;
	XglIsNamedStringARB- : TglIsNamedStringARB;
	XglGetNamedStringARB- : TglGetNamedStringARB;
	XglGetNamedStringivARB- : TglGetNamedStringivARB;
	(*  GL_ARB_blend_func_extended  *)
	XglBindFragDataLocationIndexed- : TglBindFragDataLocationIndexed;
	XglGetFragDataIndex- : TglGetFragDataIndex;
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
	(*  GL_ARB_shader_subroutine  *)
	XglGetSubroutineUniformLocation- : TglGetSubroutineUniformLocation;
	XglGetSubroutineIndex- : TglGetSubroutineIndex;
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

	(*! GL 4.3  *)
	(* GL_KHR_debug  *)
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
	(* GL_ARB_clear_buffer_object  *)
	ClearBufferData- : TglClearBufferData;
	ClearBufferSubData- : TglClearBufferSubData;
	ClearNamedBufferDataEXT- : TglClearNamedBufferDataEXT;
	ClearNamedBufferSubDataEXT- : TglClearNamedBufferSubDataEXT;
	(* GL_ARB_compute_shader  *)
	DispatchCompute- : TglDispatchCompute;
	DispatchComputeIndirect- : TglDispatchComputeIndirect;
	(* GL_ARB_copy_image  *)
	CopyImageSubData- : TglCopyImageSubData;
	(* GL_ARB_framebuffer_no_attachments  *)
	FramebufferParameteri- : TglFramebufferParameteri;
	GetFramebufferParameteriv- : TglGetFramebufferParameteriv;
	NamedFramebufferParameteriEXT- : TglNamedFramebufferParameteriEXT;
	GetNamedFramebufferParameterivEXT- : TglGetNamedFramebufferParameterivEXT;
	(* GL_ARB_internalformat_query2  *)
	GetInternalformati64v- : TglGetInternalformati64v;
	(* GL_ARB_invalidate_subdata  *)
	InvalidateTexSubImage- : TglInvalidateTexSubImage;
	InvalidateTexImage- : TglInvalidateTexImage;
	InvalidateBufferSubData- : TglInvalidateBufferSubData;
	InvalidateBufferData- : TglInvalidateBufferData;
	InvalidateFramebuffer- : TglInvalidateFramebuffer;
	InvalidateSubFramebuffer- : TglInvalidateSubFramebuffer;
	(* GL_ARB_multi_draw_indirect  *)
	MultiDrawArraysIndirect- : TglMultiDrawArraysIndirect;
	MultiDrawElementsIndirect- : TglMultiDrawElementsIndirect;
	(* GL_ARB_program_interface_query  *)
	GetProgramInterfaceiv- : TglGetProgramInterfaceiv;
	GetProgramResourceIndex- : TglGetProgramResourceIndex;
	GetProgramResourceName- : TglGetProgramResourceName;
	GetProgramResourceiv- : TglGetProgramResourceiv;
	GetProgramResourceLocation- : TglGetProgramResourceLocation;
	GetProgramResourceLocationIndex- : TglGetProgramResourceLocationIndex;
	(* GL_ARB_shader_storage_buffer_object  *)
	ShaderStorageBlockBinding- : TglShaderStorageBlockBinding;
	(* GL_ARB_texture_buffer_range  *)
	TexBufferRange- : TglTexBufferRange;
	TextureBufferRangeEXT- : TglTextureBufferRangeEXT;
	(* GL_ARB_texture_storage_multisample  *)
	TexStorage2DMultisample- : TglTexStorage2DMultisample;
	TexStorage3DMultisample- : TglTexStorage3DMultisample;
	TextureStorage2DMultisampleEXT- : TglTextureStorage2DMultisampleEXT;
	TextureStorage3DMultisampleEXT- : TglTextureStorage3DMultisampleEXT;
	(* GL_ARB_texture_view  *)
	TextureView- : TglTextureView;
	(* GL_ARB_vertex_attrib_binding  *)
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
	(*  GL_ARB_cl_event  *)
	CreateSyncFromCLeventARB- : TglCreateSyncFromCLeventARB;
	(*  GL_ARB_debug_output  *)
	DebugMessageControlARB- : TglDebugMessageControlARB;
	DebugMessageInsertARB- : TglDebugMessageInsertARB;
	(*  glDebugMessageCallbackARB- : TglDebugMessageCallbackARB; *)
	GetDebugMessageLogARB- : TglGetDebugMessageLogARB;
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
	(*glDebugMessageCallbackAMD- : TglDebugMessageCallbackAMD; *)
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
	(*   glFramebufferTextureLayerEXT- : TglFramebufferTextureLayerEXT;  *)
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
	XglBindFragDataLocationEXT- : TglBindFragDataLocationEXT;
	XglGetFragDataLocationEXT- : TglGetFragDataLocationEXT;
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
	XglCreateShaderProgramEXT- : TglCreateShaderProgramEXT;
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
	XglProgramNamedParameter4fNV- : TglProgramNamedParameter4fNV;
	XglProgramNamedParameter4dNV- : TglProgramNamedParameter4dNV;
	XglProgramNamedParameter4fvNV- : TglProgramNamedParameter4fvNV;
	XglProgramNamedParameter4dvNV- : TglProgramNamedParameter4dvNV;
	XglGetProgramNamedParameterfvNV- : TglGetProgramNamedParameterfvNV;
	XglGetProgramNamedParameterdvNV- : TglGetProgramNamedParameterdvNV;
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
	XglActiveVaryingNV- : TglActiveVaryingNV;
	XglGetVaryingLocationNV- : TglGetVaryingLocationNV;
	GetActiveVaryingNV- : TglGetActiveVaryingNV;
	GetTransformFeedbackVaryingNV- : TglGetTransformFeedbackVaryingNV;
	TransformFeedbackStreamAttribsNV- : TglTransformFeedbackStreamAttribsNV;
	(*  GL_NV_conditional_render  *)
	BeginConditionalRenderNV- : TglBeginConditionalRenderNV;
	EndConditionalRenderNV- : TglEndConditionalRenderNV;
	(*  GL_NV_present_video  *)
	PresentFrameKeyedNV- : TglPresentFrameKeyedNV;
	PresentFrameDualFillNV- : TglPresentFrameDualFillNV;
	GetVideoivNV- : TglGetVideoivNV;
	GetVideouivNV- : TglGetVideouivNV;
	GetVideoi64vNV- : TglGetVideoi64vNV;
	GetVideoui64vNV- : TglGetVideoui64vNV;
	(*   glVideoParameterivNV- : TglVideoParameterivNV;  *)
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
	(*! GLX_LINUX   *)
	glXChooseVisual- : TglXChooseVisual;
	glXCopyContext- : TglXCopyContext;
	glXCreateContext- : TglXCreateContext;
	glXCreateGLXPixmap- : TglXCreateGLXPixmap;
	glXDestroyContext- : TglXDestroyContext;
	glXDestroyGLXPixmap- : TglXDestroyGLXPixmap;
	glXGetConfig- : TglXGetConfig;
	glXGetCurrentContext- : TglXGetCurrentContext;
	glXGetCurrentDrawable- : TglXGetCurrentDrawable;
	glXIsDirect- : TglXIsDirect;
	glXMakeCurrent- : TglXMakeCurrent;
	glXQueryExtension- : TglXQueryExtension;
	glXQueryVersion- : TglXQueryVersion;
	glXSwapBuffers- : TglXSwapBuffers;
	glXUseXFont- : TglXUseXFont;
	glXWaitGL- : TglXWaitGL;
	glXWaitX- : TglXWaitX;
	glXGetClientString- : TglXGetClientString;
	glXQueryServerString- : TglXQueryServerString;
	glXQueryExtensionsString- : TglXQueryExtensionsString;

	(*! GLX_VERSION_1_3  *)
	glXGetFBConfigs- : TglXGetFBConfigs;
	glXChooseFBConfig- : TglXChooseFBConfig;
	glXGetFBConfigAttrib- : TglXGetFBConfigAttrib;
	glXGetVisualFromFBConfig- : TglXGetVisualFromFBConfig;
	glXCreateWindow- : TglXCreateWindow;
	glXDestroyWindow- : TglXDestroyWindow;
	glXCreatePixmap- : TglXCreatePixmap;
	glXDestroyPixmap- : TglXDestroyPixmap;
	glXCreatePbuffer- : TglXCreatePbuffer;
	glXDestroyPbuffer- : TglXDestroyPbuffer;
	glXQueryDrawable- : TglXQueryDrawable;
	glXCreateNewContext- : TglXCreateNewContext;
	glXMakeContextCurrent- : TglXMakeContextCurrent;
	glXGetCurrentReadDrawable- : TglXGetCurrentReadDrawable;
	glXGetCurrentDisplay- : TglXGetCurrentDisplay;
	glXQueryContext- : TglXQueryContext;
	glXSelectEvent- : TglXSelectEvent;
	glXGetSelectedEvent- : TglXGetSelectedEvent;

	(*! GLX_VERSION_1_4  *)
	glXGetProcAddress- : TglXGetProcAddress;
	(*  GLX_ARB_get_proc_address  *)
	glXGetProcAddressARB- : TglXGetProcAddressARB;
	(* GLX_ARB_create_context  *)
	glXCreateContextAttribsARB- : TglXCreateContextAttribsARB;
	(*  GLX_EXT_import_context  *)
	glXGetCurrentDisplayEXT- : TglXGetCurrentDisplayEXT;
	glXQueryContextInfoEXT- : TglXQueryContextInfoEXT;
	glXGetContextIDEXT- : TglXGetContextIDEXT;
	glXImportContextEXT- : TglXImportContextEXT;
	glXFreeContextEXT- : TglXFreeContextEXT;
	(* GLX_EXT_texture_from_pixmap  *)
	glXBindTexImageEXT- : TglXBindTexImageEXT;
	glXReleaseTexImageEXT- : TglXReleaseTexImageEXT;

(** wrapper procedure  *)
PROCEDURE GetProcAddress*(CONST funcName: ARRAY OF CHAR): ADDRESS;
VAR address: ADDRESS;
BEGIN
	address := 0;
	IF glXGetProcAddress # NIL THEN
	  	address := glXGetProcAddress(ADDRESSOF(funcName[0]));
	ELSIF glXGetProcAddressARB # NIL THEN
		address := glXGetProcAddressARB(ADDRESSOF(funcName[0]));
	END;

	IF debug THEN
		KernelLog.String(funcName);
		IF address = 0 THEN KernelLog.String(":  NIL"); ELSE KernelLog.String(":  # NIL"); END;
		KernelLog.Ln;
	END;
	RETURN address;
END GetProcAddress;


(*! --------------------------   *)
(* from Linux.Unix.Mod *)
PROCEDURE Dlopen*( CONST libname: ARRAY OF CHAR;  mode: LONGINT ): ADDRESS;
VAR h: ADDRESS;  i, j, k: INTEGER;
	p: ARRAY 256 OF CHAR;
BEGIN
	(* first, find the library in the search parth of A2*)
	 h := Unix.Dlopen(libname, mode );
	 IF h = 0 THEN (* else search in libraryPaths *)
		i := 0;  h := 0;
		WHILE (h = 0) & (i <= 7) DO
			COPY( libraryPaths[i], p );  j := 0;
			WHILE p[j] # 0X DO  INC( j )  END;
			p[j] := '/';  k := 0;
			REPEAT  INC( j );  p[j] := libname[k];  INC( k )  UNTIL p[j] = 0X;
			h := Unix.Dlopen( p , mode );  INC( i )
		END
	END;
	RETURN h
END Dlopen;

PROCEDURE InitOpenGL*;
BEGIN
	GL_LibHandle := Dlopen(GL_LibName, 2);
  	ASSERT(GL_LibHandle # 0,101);

		(* load GL functions *)
		(* GLX_VERSION_1_4 (needs to be first) *)
		Unix.Dlsym(GL_LibHandle, 'glXGetProcAddress', ADDRESSOF( glXGetProcAddress));

		(* GLX_ARB_get_proc_address  (also needs to be first)  *)
		glXGetProcAddressARB := SYSTEM.VAL(TglXGetProcAddressARB , GetProcAddress("glXGetProcAddressARB"));
		(*   Unix.Dlsym(GL_LibHandle, 'glXGetProcAddressARB', ADDRESSOF( glXGetProcAddressARB));  *)

		 glXChooseVisual := SYSTEM.VAL(TglXChooseVisual , GetProcAddress("glXChooseVisual"));
		 glXCopyContext := SYSTEM.VAL(TglXCopyContext , GetProcAddress("glXCopyContext"));
		 glXCreateContext := SYSTEM.VAL(TglXCreateContext , GetProcAddress("glXCreateContext"));
		 glXCreateGLXPixmap := SYSTEM.VAL(TglXCreateGLXPixmap , GetProcAddress("glXCreateGLXPixmap"));
		 glXDestroyContext := SYSTEM.VAL(TglXDestroyContext , GetProcAddress("glXDestroyContext"));
		 glXDestroyGLXPixmap := SYSTEM.VAL(TglXDestroyGLXPixmap , GetProcAddress("glXDestroyGLXPixmap"));
		 glXGetConfig := SYSTEM.VAL(TglXGetConfig , GetProcAddress("glXGetConfig"));
		 glXGetCurrentContext := SYSTEM.VAL(TglXGetCurrentContext , GetProcAddress("glXGetCurrentContext"));
		 glXGetCurrentDrawable := SYSTEM.VAL(TglXGetCurrentDrawable , GetProcAddress("glXGetCurrentDrawable"));
		 glXIsDirect := SYSTEM.VAL(TglXIsDirect , GetProcAddress("glXIsDirect"));

		glXMakeCurrent := SYSTEM.VAL(TglXMakeCurrent , GetProcAddress("glXMakeCurrent"));
		glXQueryExtension := SYSTEM.VAL(TglXQueryExtension , GetProcAddress("glXQueryExtension"));
		glXQueryVersion := SYSTEM.VAL(TglXQueryVersion , GetProcAddress("glXQueryVersion"));
		glXSwapBuffers := SYSTEM.VAL(TglXSwapBuffers , GetProcAddress("glXSwapBuffers"));
		glXUseXFont := SYSTEM.VAL(TglXUseXFont , GetProcAddress("glXUseXFont"));
		glXWaitGL := SYSTEM.VAL(TglXWaitGL , GetProcAddress("glXWaitGL"));
		glXWaitX := SYSTEM.VAL(TglXWaitX , GetProcAddress("glXWaitX"));
		glXGetClientString := SYSTEM.VAL(TglXGetClientString , GetProcAddress("glXGetClientString"));
		glXQueryServerString := SYSTEM.VAL(TglXQueryServerString , GetProcAddress("glXQueryServerString"));
		glXQueryExtensionsString := SYSTEM.VAL(TglXQueryExtensionsString , GetProcAddress("glXQueryExtensionsString"));

		(* GLX_VERSION_1_3  *)
		glXGetFBConfigs := SYSTEM.VAL(TglXGetFBConfigs , GetProcAddress("glXGetFBConfigs"));
		glXChooseFBConfig := SYSTEM.VAL(TglXChooseFBConfig , GetProcAddress("glXChooseFBConfig"));
		glXGetFBConfigAttrib := SYSTEM.VAL(TglXGetFBConfigAttrib , GetProcAddress("glXGetFBConfigAttrib"));
		glXGetVisualFromFBConfig := SYSTEM.VAL(TglXGetVisualFromFBConfig , GetProcAddress("glXGetVisualFromFBConfig"));
		glXCreateWindow := SYSTEM.VAL(TglXCreateWindow , GetProcAddress("glXCreateWindow"));
		glXDestroyWindow := SYSTEM.VAL(TglXDestroyWindow , GetProcAddress("glXDestroyWindow"));
		glXCreatePixmap := SYSTEM.VAL(TglXCreatePixmap , GetProcAddress("glXCreatePixmap"));

		glXDestroyPixmap := SYSTEM.VAL(TglXDestroyPixmap , GetProcAddress("glXDestroyPixmap"));
		glXCreatePbuffer := SYSTEM.VAL(TglXCreatePbuffer , GetProcAddress("glXCreatePbuffer"));
		glXDestroyPbuffer := SYSTEM.VAL(TglXDestroyPbuffer , GetProcAddress("glXDestroyPbuffer"));
		glXQueryDrawable := SYSTEM.VAL(TglXQueryDrawable , GetProcAddress("glXQueryDrawable"));
		glXCreateNewContext := SYSTEM.VAL(TglXCreateNewContext , GetProcAddress("glXCreateNewContext"));
		glXMakeContextCurrent := SYSTEM.VAL(TglXMakeContextCurrent , GetProcAddress("glXMakeContextCurrent"));
		glXGetCurrentReadDrawable := SYSTEM.VAL(TglXGetCurrentReadDrawable , GetProcAddress("glXGetCurrentReadDrawable"));
		glXGetCurrentDisplay := SYSTEM.VAL(TglXGetCurrentDisplay , GetProcAddress("glXGetCurrentDisplay"));

		glXQueryContext := SYSTEM.VAL(TglXQueryContext , GetProcAddress("glXQueryContext"));
		glXSelectEvent := SYSTEM.VAL(TglXSelectEvent , GetProcAddress("glXSelectEvent"));
		glXGetSelectedEvent := SYSTEM.VAL(TglXGetSelectedEvent , GetProcAddress("glXGetSelectedEvent"));

		(* GLX_ARB_create_context  *)
		glXCreateContextAttribsARB := SYSTEM.VAL(TglXCreateContextAttribsARB , GetProcAddress("glXCreateContextAttribsARB"));

		(* GLX_EXT_import_context  *)
		glXGetCurrentDisplayEXT := SYSTEM.VAL(TglXGetCurrentDisplayEXT , GetProcAddress("glXGetCurrentDisplayEXT"));
		glXQueryContextInfoEXT := SYSTEM.VAL(TglXQueryContextInfoEXT , GetProcAddress("glXQueryContextInfoEXT"));
		glXGetContextIDEXT := SYSTEM.VAL(TglXGetContextIDEXT , GetProcAddress("glXGetContextIDEXT"));
		glXImportContextEXT := SYSTEM.VAL(TglXImportContextEXT , GetProcAddress("glXImportContextEXT"));
		glXFreeContextEXT := SYSTEM.VAL(TglXFreeContextEXT , GetProcAddress("glXFreeContextEXT"));

		(* GLX_EXT_texture_from_pixmap  *)
		glXBindTexImageEXT := SYSTEM.VAL(TglXBindTexImageEXT , GetProcAddress("glXBindTexImageEXT"));
		glXReleaseTexImageEXT := SYSTEM.VAL(TglXReleaseTexImageEXT , GetProcAddress("glXReleaseTexImageEXT"));

		KernelLog.String(GL_LibName); KernelLog.String(" loaded."); KernelLog.Ln;
END InitOpenGL;

PROCEDURE ReadOpenGLCore*;
BEGIN
	(*! GL_VERSION_1_0 *)
	CullFace := SYSTEM.VAL(TglCullFace, GetProcAddress('glCullFace'));
	FrontFace := SYSTEM.VAL(TglFrontFace, GetProcAddress('glFrontFace'));
	Hint := SYSTEM.VAL(TglHint, GetProcAddress('glHint'));
	LineWidth := SYSTEM.VAL(TglLineWidth, GetProcAddress('glLineWidth'));
	PointSize := SYSTEM.VAL(TglPointSize, GetProcAddress('glPointSize'));
	PolygonMode := SYSTEM.VAL(TglPolygonMode, GetProcAddress('glPolygonMode'));
	Scissor := SYSTEM.VAL(TglScissor, GetProcAddress('glScissor'));
	TexParameterf := SYSTEM.VAL(TglTexParameterf, GetProcAddress('glTexParameterf'));
	TexParameterfv := SYSTEM.VAL(TglTexParameterfv, GetProcAddress('glTexParameterfv'));
	TexParameteri := SYSTEM.VAL(TglTexParameteri, GetProcAddress('glTexParameteri'));
	TexParameteriv := SYSTEM.VAL(TglTexParameteriv, GetProcAddress('glTexParameteriv'));
	TexImage1D := SYSTEM.VAL(TglTexImage1D, GetProcAddress('glTexImage1D'));
	TexImage2D := SYSTEM.VAL(TglTexImage2D, GetProcAddress('glTexImage2D'));
	DrawBuffer := SYSTEM.VAL(TglDrawBuffer, GetProcAddress('glDrawBuffer'));
	Clear := SYSTEM.VAL(TglClear, GetProcAddress('glClear'));
	ClearColor := SYSTEM.VAL(TglClearColor, GetProcAddress('glClearColor'));
	ClearStencil := SYSTEM.VAL(TglClearStencil, GetProcAddress('glClearStencil'));
	ClearDepth := SYSTEM.VAL(TglClearDepth, GetProcAddress('glClearDepth'));
	StencilMask := SYSTEM.VAL(TglStencilMask, GetProcAddress('glStencilMask'));
	ColorMask := SYSTEM.VAL(TglColorMask, GetProcAddress('glColorMask'));
	DepthMask := SYSTEM.VAL(TglDepthMask, GetProcAddress('glDepthMask'));
	Disable := SYSTEM.VAL(TglDisable, GetProcAddress('glDisable'));
	Enable := SYSTEM.VAL(TglEnable, GetProcAddress('glEnable'));
	Finish := SYSTEM.VAL(TglFinish, GetProcAddress('glFinish'));
	Flush := SYSTEM.VAL(TglFlush, GetProcAddress('glFlush'));
	BlendFunc := SYSTEM.VAL(TglBlendFunc, GetProcAddress('glBlendFunc'));
	LogicOp := SYSTEM.VAL(TglLogicOp, GetProcAddress('glLogicOp'));
	StencilFunc := SYSTEM.VAL(TglStencilFunc, GetProcAddress('glStencilFunc'));
	StencilOp := SYSTEM.VAL(TglStencilOp, GetProcAddress('glStencilOp'));
	DepthFunc := SYSTEM.VAL(TglDepthFunc, GetProcAddress('glDepthFunc'));
	PixelStoref := SYSTEM.VAL(TglPixelStoref, GetProcAddress('glPixelStoref'));
	PixelStorei := SYSTEM.VAL(TglPixelStorei, GetProcAddress('glPixelStorei'));
	ReadBuffer := SYSTEM.VAL(TglReadBuffer, GetProcAddress('glReadBuffer'));
	ReadPixels := SYSTEM.VAL(TglReadPixels, GetProcAddress('glReadPixels'));
	GetBooleanv := SYSTEM.VAL(TglGetBooleanv, GetProcAddress('glGetBooleanv'));
	GetDoublev := SYSTEM.VAL(TglGetDoublev, GetProcAddress('glGetDoublev'));
	GetError := SYSTEM.VAL(TglGetError, GetProcAddress('glGetError'));
	GetFloatv := SYSTEM.VAL(TglGetFloatv, GetProcAddress('glGetFloatv'));
	GetIntegerv := SYSTEM.VAL(TglGetIntegerv, GetProcAddress('glGetIntegerv'));
	XglGetString := SYSTEM.VAL(TglGetString, GetProcAddress('glGetString'));
	GetTexImage := SYSTEM.VAL(TglGetTexImage, GetProcAddress('glGetTexImage'));
	GetTexParameteriv := SYSTEM.VAL(TglGetTexParameteriv, GetProcAddress('glGetTexParameteriv'));
	GetTexParameterfv := SYSTEM.VAL(TglGetTexParameterfv, GetProcAddress('glGetTexParameterfv'));
	GetTexLevelParameterfv := SYSTEM.VAL(TglGetTexLevelParameterfv, GetProcAddress('glGetTexLevelParameterfv'));
	GetTexLevelParameteriv := SYSTEM.VAL(TglGetTexLevelParameteriv, GetProcAddress('glGetTexLevelParameteriv'));
	IsEnabled := SYSTEM.VAL(TglIsEnabled, GetProcAddress('glIsEnabled'));
	DepthRange := SYSTEM.VAL(TglDepthRange, GetProcAddress('glDepthRange'));
	Viewport := SYSTEM.VAL(TglViewport, GetProcAddress('glViewport'));
	(*! GL_VERSION_1_1 *)
	DrawArrays := SYSTEM.VAL(TglDrawArrays, GetProcAddress('glDrawArrays'));
	DrawElements := SYSTEM.VAL(TglDrawElements, GetProcAddress('glDrawElements'));
	GetPointerv := SYSTEM.VAL(TglGetPointerv, GetProcAddress('glGetPointerv'));
	PolygonOffset := SYSTEM.VAL(TglPolygonOffset, GetProcAddress('glPolygonOffset'));
	CopyTexImage1D := SYSTEM.VAL(TglCopyTexImage1D, GetProcAddress('glCopyTexImage1D'));
	CopyTexImage2D := SYSTEM.VAL(TglCopyTexImage2D, GetProcAddress('glCopyTexImage2D'));
	CopyTexSubImage1D := SYSTEM.VAL(TglCopyTexSubImage1D, GetProcAddress('glCopyTexSubImage1D'));
	CopyTexSubImage2D := SYSTEM.VAL(TglCopyTexSubImage2D, GetProcAddress('glCopyTexSubImage2D'));
	TexSubImage1D := SYSTEM.VAL(TglTexSubImage1D, GetProcAddress('glTexSubImage1D'));
	TexSubImage2D := SYSTEM.VAL(TglTexSubImage2D, GetProcAddress('glTexSubImage2D'));
	BindTexture := SYSTEM.VAL(TglBindTexture, GetProcAddress('glBindTexture'));
	DeleteTextures := SYSTEM.VAL(TglDeleteTextures, GetProcAddress('glDeleteTextures'));
	GenTextures := SYSTEM.VAL(TglGenTextures, GetProcAddress('glGenTextures'));
	(*! ifdef DEPRECATED  *)
	Accum := SYSTEM.VAL(TglAccum, GetProcAddress('glAccum'));
	AlphaFunc := SYSTEM.VAL(TglAlphaFunc, GetProcAddress('glAlphaFunc'));
	AreTexturesResident := SYSTEM.VAL(TglAreTexturesResident, GetProcAddress('glAreTexturesResident'));
	ArrayElement := SYSTEM.VAL(TglArrayElement, GetProcAddress('glArrayElement'));
	Begin := SYSTEM.VAL(TglBegin, GetProcAddress('glBegin'));
	Bitmap := SYSTEM.VAL(TglBitmap, GetProcAddress('glBitmap'));
	CallList := SYSTEM.VAL(TglCallList, GetProcAddress('glCallList'));
	CallLists := SYSTEM.VAL(TglCallLists, GetProcAddress('glCallLists'));
	ClearAccum := SYSTEM.VAL(TglClearAccum, GetProcAddress('glClearAccum'));
	ClearIndex := SYSTEM.VAL(TglClearIndex, GetProcAddress('glClearIndex'));
	ClipPlane := SYSTEM.VAL(TglClipPlane, GetProcAddress('glClipPlane'));
	Color3b := SYSTEM.VAL(TglColor3b, GetProcAddress('glColor3b'));
	Color3bv := SYSTEM.VAL(TglColor3bv, GetProcAddress('glColor3bv'));
	Color3d := SYSTEM.VAL(TglColor3d, GetProcAddress('glColor3d'));
	XglColor3dv := SYSTEM.VAL(TglColor3dv, GetProcAddress('glColor3dv'));
	Color3f := SYSTEM.VAL(TglColor3f, GetProcAddress('glColor3f'));
	XglColor3fv := SYSTEM.VAL(TglColor3fv, GetProcAddress('glColor3fv'));
	Color3i := SYSTEM.VAL(TglColor3i, GetProcAddress('glColor3i'));
	Color3iv := SYSTEM.VAL(TglColor3iv, GetProcAddress('glColor3iv'));
	Color3s := SYSTEM.VAL(TglColor3s, GetProcAddress('glColor3s'));
	Color3sv := SYSTEM.VAL(TglColor3sv, GetProcAddress('glColor3sv'));
	Color3ub := SYSTEM.VAL(TglColor3ub, GetProcAddress('glColor3ub'));
	Color3ubv := SYSTEM.VAL(TglColor3ubv, GetProcAddress('glColor3ubv'));
	Color3ui := SYSTEM.VAL(TglColor3ui, GetProcAddress('glColor3ui'));
	Color3uiv := SYSTEM.VAL(TglColor3uiv, GetProcAddress('glColor3uiv'));
	Color3us := SYSTEM.VAL(TglColor3us, GetProcAddress('glColor3us'));
	Color3usv := SYSTEM.VAL(TglColor3usv, GetProcAddress('glColor3usv'));
	Color4b := SYSTEM.VAL(TglColor4b, GetProcAddress('glColor4b'));
	Color4bv := SYSTEM.VAL(TglColor4bv, GetProcAddress('glColor4bv'));
	Color4d := SYSTEM.VAL(TglColor4d, GetProcAddress('glColor4d'));
	Color4dv := SYSTEM.VAL(TglColor4dv, GetProcAddress('glColor4dv'));
	Color4f := SYSTEM.VAL(TglColor4f, GetProcAddress('glColor4f'));
	Color4fv := SYSTEM.VAL(TglColor4fv, GetProcAddress('glColor4fv'));
	Color4i := SYSTEM.VAL(TglColor4i, GetProcAddress('glColor4i'));
	Color4iv := SYSTEM.VAL(TglColor4iv, GetProcAddress('glColor4iv'));
	Color4s := SYSTEM.VAL(TglColor4s, GetProcAddress('glColor4s'));
	Color4sv := SYSTEM.VAL(TglColor4sv, GetProcAddress('glColor4sv'));
	Color4ub := SYSTEM.VAL(TglColor4ub, GetProcAddress('glColor4ub'));
	Color4ubv := SYSTEM.VAL(TglColor4ubv, GetProcAddress('glColor4ubv'));
	Color4ui := SYSTEM.VAL(TglColor4ui, GetProcAddress('glColor4ui'));
	Color4uiv := SYSTEM.VAL(TglColor4uiv, GetProcAddress('glColor4uiv'));
	Color4us := SYSTEM.VAL(TglColor4us, GetProcAddress('glColor4us'));
	Color4usv := SYSTEM.VAL(TglColor4usv, GetProcAddress('glColor4usv'));
	ColorMaterial := SYSTEM.VAL(TglColorMaterial, GetProcAddress('glColorMaterial'));
	ColorPointer := SYSTEM.VAL(TglColorPointer, GetProcAddress('glColorPointer'));
	CopyPixels := SYSTEM.VAL(TglCopyPixels, GetProcAddress('glCopyPixels'));
	DeleteLists := SYSTEM.VAL(TglDeleteLists, GetProcAddress('glDeleteLists'));
	DisableClientState := SYSTEM.VAL(TglDisableClientState, GetProcAddress('glDisableClientState'));
	DrawPixels := SYSTEM.VAL(TglDrawPixels, GetProcAddress('glDrawPixels'));
	EdgeFlag := SYSTEM.VAL(TglEdgeFlag, GetProcAddress('glEdgeFlag'));
	EdgeFlagPointer := SYSTEM.VAL(TglEdgeFlagPointer, GetProcAddress('glEdgeFlagPointer'));
	EdgeFlagv := SYSTEM.VAL(TglEdgeFlagv, GetProcAddress('glEdgeFlagv'));
	EnableClientState := SYSTEM.VAL(TglEnableClientState, GetProcAddress('glEnableClientState'));
	End := SYSTEM.VAL(TglEnd, GetProcAddress('glEnd'));
	EndList := SYSTEM.VAL(TglEndList, GetProcAddress('glEndList'));
	EvalCoord1d := SYSTEM.VAL(TglEvalCoord1d, GetProcAddress('glEvalCoord1d'));
	EvalCoord1dv := SYSTEM.VAL(TglEvalCoord1dv, GetProcAddress('glEvalCoord1dv'));
	EvalCoord1f := SYSTEM.VAL(TglEvalCoord1f, GetProcAddress('glEvalCoord1f'));
	EvalCoord1fv := SYSTEM.VAL(TglEvalCoord1fv, GetProcAddress('glEvalCoord1fv'));
	EvalCoord2d := SYSTEM.VAL(TglEvalCoord2d, GetProcAddress('glEvalCoord2d'));
	EvalCoord2dv := SYSTEM.VAL(TglEvalCoord2dv, GetProcAddress('glEvalCoord2dv'));
	EvalCoord2f := SYSTEM.VAL(TglEvalCoord2f, GetProcAddress('glEvalCoord2f'));
	EvalCoord2fv := SYSTEM.VAL(TglEvalCoord2fv, GetProcAddress('glEvalCoord2fv'));
	EvalMesh1 := SYSTEM.VAL(TglEvalMesh1, GetProcAddress('glEvalMesh1'));
	EvalMesh2 := SYSTEM.VAL(TglEvalMesh2, GetProcAddress('glEvalMesh2'));
	EvalPoint1 := SYSTEM.VAL(TglEvalPoint1, GetProcAddress('glEvalPoint1'));
	EvalPoint2 := SYSTEM.VAL(TglEvalPoint2, GetProcAddress('glEvalPoint2'));
	FeedbackBuffer := SYSTEM.VAL(TglFeedbackBuffer, GetProcAddress('glFeedbackBuffer'));
	Fogf := SYSTEM.VAL(TglFogf, GetProcAddress('glFogf'));
	Fogfv := SYSTEM.VAL(TglFogfv, GetProcAddress('glFogfv'));
	Fogi := SYSTEM.VAL(TglFogi, GetProcAddress('glFogi'));
	Fogiv := SYSTEM.VAL(TglFogiv, GetProcAddress('glFogiv'));
	Frustum := SYSTEM.VAL(TglFrustum, GetProcAddress('glFrustum'));
	GenLists := SYSTEM.VAL(TglGenLists, GetProcAddress('glGenLists'));
	GetClipPlane := SYSTEM.VAL(TglGetClipPlane, GetProcAddress('glGetClipPlane'));
	GetLightfv := SYSTEM.VAL(TglGetLightfv, GetProcAddress('glGetLightfv'));
	GetLightiv := SYSTEM.VAL(TglGetLightiv, GetProcAddress('glGetLightiv'));
	GetMapdv := SYSTEM.VAL(TglGetMapdv, GetProcAddress('glGetMapdv'));
	GetMapfv := SYSTEM.VAL(TglGetMapfv, GetProcAddress('glGetMapfv'));
	GetMapiv := SYSTEM.VAL(TglGetMapiv, GetProcAddress('glGetMapiv'));
	GetMaterialfv := SYSTEM.VAL(TglGetMaterialfv, GetProcAddress('glGetMaterialfv'));
	GetMaterialiv := SYSTEM.VAL(TglGetMaterialiv, GetProcAddress('glGetMaterialiv'));
	GetPixelMapfv := SYSTEM.VAL(TglGetPixelMapfv, GetProcAddress('glGetPixelMapfv'));
	GetPixelMapuiv := SYSTEM.VAL(TglGetPixelMapuiv, GetProcAddress('glGetPixelMapuiv'));
	GetPixelMapusv := SYSTEM.VAL(TglGetPixelMapusv, GetProcAddress('glGetPixelMapusv'));
	GetPolygonStipple := SYSTEM.VAL(TglGetPolygonStipple, GetProcAddress('glGetPolygonStipple'));
	GetTexEnvfv := SYSTEM.VAL(TglGetTexEnvfv, GetProcAddress('glGetTexEnvfv'));
	GetTexEnviv := SYSTEM.VAL(TglGetTexEnviv, GetProcAddress('glGetTexEnviv'));
	GetTexGendv := SYSTEM.VAL(TglGetTexGendv, GetProcAddress('glGetTexGendv'));
	GetTexGenfv := SYSTEM.VAL(TglGetTexGenfv, GetProcAddress('glGetTexGenfv'));
	GetTexGeniv := SYSTEM.VAL(TglGetTexGeniv, GetProcAddress('glGetTexGeniv'));
	IndexMask := SYSTEM.VAL(TglIndexMask, GetProcAddress('glIndexMask'));
	IndexPointer := SYSTEM.VAL(TglIndexPointer, GetProcAddress('glIndexPointer'));
	Indexd := SYSTEM.VAL(TglIndexd, GetProcAddress('glIndexd'));
	Indexdv := SYSTEM.VAL(TglIndexdv, GetProcAddress('glIndexdv'));
	Indexf := SYSTEM.VAL(TglIndexf, GetProcAddress('glIndexf'));
	Indexfv := SYSTEM.VAL(TglIndexfv, GetProcAddress('glIndexfv'));
	Indexi := SYSTEM.VAL(TglIndexi, GetProcAddress('glIndexi'));
	Indexiv := SYSTEM.VAL(TglIndexiv, GetProcAddress('glIndexiv'));
	Indexs := SYSTEM.VAL(TglIndexs, GetProcAddress('glIndexs'));
	Indexsv := SYSTEM.VAL(TglIndexsv, GetProcAddress('glIndexsv'));
	Indexub := SYSTEM.VAL(TglIndexub, GetProcAddress('glIndexub'));
	Indexubv := SYSTEM.VAL(TglIndexubv, GetProcAddress('glIndexubv'));
	InitNames := SYSTEM.VAL(TglInitNames, GetProcAddress('glInitNames'));
	InterleavedArrays := SYSTEM.VAL(TglInterleavedArrays, GetProcAddress('glInterleavedArrays'));
	IsList := SYSTEM.VAL(TglIsList, GetProcAddress('glIsList'));
	IsTexture := SYSTEM.VAL(TglIsTexture, GetProcAddress('glIsTexture'));
	LightModelf := SYSTEM.VAL(TglLightModelf, GetProcAddress('glLightModelf'));
	XglLightModelfv := SYSTEM.VAL(TglLightModelfv, GetProcAddress('glLightModelfv'));
	LightModeli := SYSTEM.VAL(TglLightModeli, GetProcAddress('glLightModeli'));
	LightModeliv := SYSTEM.VAL(TglLightModeliv, GetProcAddress('glLightModeliv'));
	Lightf := SYSTEM.VAL(TglLightf, GetProcAddress('glLightf'));
	XglLightfv := SYSTEM.VAL(TglLightfv, GetProcAddress('glLightfv'));
	Lighti := SYSTEM.VAL(TglLighti, GetProcAddress('glLighti'));
	Lightiv := SYSTEM.VAL(TglLightiv, GetProcAddress('glLightiv'));
	LineStipple := SYSTEM.VAL(TglLineStipple, GetProcAddress('glLineStipple'));
	ListBase := SYSTEM.VAL(TglListBase, GetProcAddress('glListBase'));
	LoadIdentity := SYSTEM.VAL(TglLoadIdentity, GetProcAddress('glLoadIdentity'));
	LoadMatrixd := SYSTEM.VAL(TglLoadMatrixd, GetProcAddress('glLoadMatrixd'));
	LoadMatrixf := SYSTEM.VAL(TglLoadMatrixf, GetProcAddress('glLoadMatrixf'));
	LoadName := SYSTEM.VAL(TglLoadName, GetProcAddress('glLoadName'));
	Map1d := SYSTEM.VAL(TglMap1d, GetProcAddress('glMap1d'));
	Map1f := SYSTEM.VAL(TglMap1f, GetProcAddress('glMap1f'));
	Map2d := SYSTEM.VAL(TglMap2d, GetProcAddress('glMap2d'));
	Map2f := SYSTEM.VAL(TglMap2f, GetProcAddress('glMap2f'));
	MapGrid1d := SYSTEM.VAL(TglMapGrid1d, GetProcAddress('glMapGrid1d'));
	MapGrid1f := SYSTEM.VAL(TglMapGrid1f, GetProcAddress('glMapGrid1f'));
	MapGrid2d := SYSTEM.VAL(TglMapGrid2d, GetProcAddress('glMapGrid2d'));
	MapGrid2f := SYSTEM.VAL(TglMapGrid2f, GetProcAddress('glMapGrid2f'));
	Materialf := SYSTEM.VAL(TglMaterialf, GetProcAddress('glMaterialf'));
	XglMaterialfv := SYSTEM.VAL(TglMaterialfv, GetProcAddress('glMaterialfv'));
	Materiali := SYSTEM.VAL(TglMateriali, GetProcAddress('glMateriali'));
	Materialiv := SYSTEM.VAL(TglMaterialiv, GetProcAddress('glMaterialiv'));
	MatrixMode := SYSTEM.VAL(TglMatrixMode, GetProcAddress('glMatrixMode'));
	MultMatrixd := SYSTEM.VAL(TglMultMatrixd, GetProcAddress('glMultMatrixd'));
	MultMatrixf := SYSTEM.VAL(TglMultMatrixf, GetProcAddress('glMultMatrixf'));
	NewList := SYSTEM.VAL(TglNewList, GetProcAddress('glNewList'));
	Normal3b := SYSTEM.VAL(TglNormal3b, GetProcAddress('glNormal3b'));
	Normal3bv := SYSTEM.VAL(TglNormal3bv, GetProcAddress('glNormal3bv'));
	Normal3d := SYSTEM.VAL(TglNormal3d, GetProcAddress('glNormal3d'));
	XglNormal3dv := SYSTEM.VAL(TglNormal3dv, GetProcAddress('glNormal3dv'));
	Normal3f := SYSTEM.VAL(TglNormal3f, GetProcAddress('glNormal3f'));
	XglNormal3fv := SYSTEM.VAL(TglNormal3fv, GetProcAddress('glNormal3fv'));
	Normal3i := SYSTEM.VAL(TglNormal3i, GetProcAddress('glNormal3i'));
	Normal3iv := SYSTEM.VAL(TglNormal3iv, GetProcAddress('glNormal3iv'));
	Normal3s := SYSTEM.VAL(TglNormal3s, GetProcAddress('glNormal3s'));
	Normal3sv := SYSTEM.VAL(TglNormal3sv, GetProcAddress('glNormal3sv'));
	NormalPointer := SYSTEM.VAL(TglNormalPointer, GetProcAddress('glNormalPointer'));
	Ortho := SYSTEM.VAL(TglOrtho, GetProcAddress('glOrtho'));
	PassThrough := SYSTEM.VAL(TglPassThrough, GetProcAddress('glPassThrough'));
	PixelMapfv := SYSTEM.VAL(TglPixelMapfv, GetProcAddress('glPixelMapfv'));
	PixelMapuiv := SYSTEM.VAL(TglPixelMapuiv, GetProcAddress('glPixelMapuiv'));
	PixelMapusv := SYSTEM.VAL(TglPixelMapusv, GetProcAddress('glPixelMapusv'));
	PixelTransferf := SYSTEM.VAL(TglPixelTransferf, GetProcAddress('glPixelTransferf'));
	PixelTransferi := SYSTEM.VAL(TglPixelTransferi, GetProcAddress('glPixelTransferi'));
	PixelZoom := SYSTEM.VAL(TglPixelZoom, GetProcAddress('glPixelZoom'));
	PolygonStipple := SYSTEM.VAL(TglPolygonStipple, GetProcAddress('glPolygonStipple'));
	PopAttrib := SYSTEM.VAL(TglPopAttrib, GetProcAddress('glPopAttrib'));
	PopClientAttrib := SYSTEM.VAL(TglPopClientAttrib, GetProcAddress('glPopClientAttrib'));
	PopMatrix := SYSTEM.VAL(TglPopMatrix, GetProcAddress('glPopMatrix'));
	PopName := SYSTEM.VAL(TglPopName, GetProcAddress('glPopName'));
	PrioritizeTextures := SYSTEM.VAL(TglPrioritizeTextures, GetProcAddress('glPrioritizeTextures'));
	PushAttrib := SYSTEM.VAL(TglPushAttrib, GetProcAddress('glPushAttrib'));
	PushClientAttrib := SYSTEM.VAL(TglPushClientAttrib, GetProcAddress('glPushClientAttrib'));
	PushMatrix := SYSTEM.VAL(TglPushMatrix, GetProcAddress('glPushMatrix'));
	PushName := SYSTEM.VAL(TglPushName, GetProcAddress('glPushName'));
	RasterPos2d := SYSTEM.VAL(TglRasterPos2d, GetProcAddress('glRasterPos2d'));
	RasterPos2dv := SYSTEM.VAL(TglRasterPos2dv, GetProcAddress('glRasterPos2dv'));
	RasterPos2f := SYSTEM.VAL(TglRasterPos2f, GetProcAddress('glRasterPos2f'));
	RasterPos2fv := SYSTEM.VAL(TglRasterPos2fv, GetProcAddress('glRasterPos2fv'));
	RasterPos2i := SYSTEM.VAL(TglRasterPos2i, GetProcAddress('glRasterPos2i'));
	RasterPos2iv := SYSTEM.VAL(TglRasterPos2iv, GetProcAddress('glRasterPos2iv'));
	RasterPos2s := SYSTEM.VAL(TglRasterPos2s, GetProcAddress('glRasterPos2s'));
	RasterPos2sv := SYSTEM.VAL(TglRasterPos2sv, GetProcAddress('glRasterPos2sv'));
	RasterPos3d := SYSTEM.VAL(TglRasterPos3d, GetProcAddress('glRasterPos3d'));
	RasterPos3dv := SYSTEM.VAL(TglRasterPos3dv, GetProcAddress('glRasterPos3dv'));
	RasterPos3f := SYSTEM.VAL(TglRasterPos3f, GetProcAddress('glRasterPos3f'));
	RasterPos3fv := SYSTEM.VAL(TglRasterPos3fv, GetProcAddress('glRasterPos3fv'));
	RasterPos3i := SYSTEM.VAL(TglRasterPos3i, GetProcAddress('glRasterPos3i'));
	RasterPos3iv := SYSTEM.VAL(TglRasterPos3iv, GetProcAddress('glRasterPos3iv'));
	RasterPos3s := SYSTEM.VAL(TglRasterPos3s, GetProcAddress('glRasterPos3s'));
	RasterPos3sv := SYSTEM.VAL(TglRasterPos3sv, GetProcAddress('glRasterPos3sv'));
	RasterPos4d := SYSTEM.VAL(TglRasterPos4d, GetProcAddress('glRasterPos4d'));
	RasterPos4dv := SYSTEM.VAL(TglRasterPos4dv, GetProcAddress('glRasterPos4dv'));
	RasterPos4f := SYSTEM.VAL(TglRasterPos4f, GetProcAddress('glRasterPos4f'));
	RasterPos4fv := SYSTEM.VAL(TglRasterPos4fv, GetProcAddress('glRasterPos4fv'));
	RasterPos4i := SYSTEM.VAL(TglRasterPos4i, GetProcAddress('glRasterPos4i'));
	RasterPos4iv := SYSTEM.VAL(TglRasterPos4iv, GetProcAddress('glRasterPos4iv'));
	RasterPos4s := SYSTEM.VAL(TglRasterPos4s, GetProcAddress('glRasterPos4s'));
	RasterPos4sv := SYSTEM.VAL(TglRasterPos4sv, GetProcAddress('glRasterPos4sv'));
	Rectd := SYSTEM.VAL(TglRectd, GetProcAddress('glRectd'));
	Rectdv := SYSTEM.VAL(TglRectdv, GetProcAddress('glRectdv'));
	Rectf := SYSTEM.VAL(TglRectf, GetProcAddress('glRectf'));
	Rectfv := SYSTEM.VAL(TglRectfv, GetProcAddress('glRectfv'));
	Recti := SYSTEM.VAL(TglRecti, GetProcAddress('glRecti'));
	Rectiv := SYSTEM.VAL(TglRectiv, GetProcAddress('glRectiv'));
	Rects := SYSTEM.VAL(TglRects, GetProcAddress('glRects'));
	Rectsv := SYSTEM.VAL(TglRectsv, GetProcAddress('glRectsv'));
	RenderMode := SYSTEM.VAL(TglRenderMode, GetProcAddress('glRenderMode'));
	Rotated := SYSTEM.VAL(TglRotated, GetProcAddress('glRotated'));
	Rotatef := SYSTEM.VAL(TglRotatef, GetProcAddress('glRotatef'));
	Scaled := SYSTEM.VAL(TglScaled, GetProcAddress('glScaled'));
	Scalef := SYSTEM.VAL(TglScalef, GetProcAddress('glScalef'));
	SelectBuffer := SYSTEM.VAL(TglSelectBuffer, GetProcAddress('glSelectBuffer'));
	ShadeModel := SYSTEM.VAL(TglShadeModel, GetProcAddress('glShadeModel'));
	TexCoord1d := SYSTEM.VAL(TglTexCoord1d, GetProcAddress('glTexCoord1d'));
	TexCoord1dv := SYSTEM.VAL(TglTexCoord1dv, GetProcAddress('glTexCoord1dv'));
	TexCoord1f := SYSTEM.VAL(TglTexCoord1f, GetProcAddress('glTexCoord1f'));
	TexCoord1fv := SYSTEM.VAL(TglTexCoord1fv, GetProcAddress('glTexCoord1fv'));
	TexCoord1i := SYSTEM.VAL(TglTexCoord1i, GetProcAddress('glTexCoord1i'));
	TexCoord1iv := SYSTEM.VAL(TglTexCoord1iv, GetProcAddress('glTexCoord1iv'));
	TexCoord1s := SYSTEM.VAL(TglTexCoord1s, GetProcAddress('glTexCoord1s'));
	TexCoord1sv := SYSTEM.VAL(TglTexCoord1sv, GetProcAddress('glTexCoord1sv'));
	TexCoord2d := SYSTEM.VAL(TglTexCoord2d, GetProcAddress('glTexCoord2d'));
	TexCoord2dv := SYSTEM.VAL(TglTexCoord2dv, GetProcAddress('glTexCoord2dv'));
	TexCoord2f := SYSTEM.VAL(TglTexCoord2f, GetProcAddress('glTexCoord2f'));
	TexCoord2fv := SYSTEM.VAL(TglTexCoord2fv, GetProcAddress('glTexCoord2fv'));
	TexCoord2i := SYSTEM.VAL(TglTexCoord2i, GetProcAddress('glTexCoord2i'));
	TexCoord2iv := SYSTEM.VAL(TglTexCoord2iv, GetProcAddress('glTexCoord2iv'));
	TexCoord2s := SYSTEM.VAL(TglTexCoord2s, GetProcAddress('glTexCoord2s'));
	TexCoord2sv := SYSTEM.VAL(TglTexCoord2sv, GetProcAddress('glTexCoord2sv'));
	TexCoord3d := SYSTEM.VAL(TglTexCoord3d, GetProcAddress('glTexCoord3d'));
	TexCoord3dv := SYSTEM.VAL(TglTexCoord3dv, GetProcAddress('glTexCoord3dv'));
	TexCoord3f := SYSTEM.VAL(TglTexCoord3f, GetProcAddress('glTexCoord3f'));
	TexCoord3fv := SYSTEM.VAL(TglTexCoord3fv, GetProcAddress('glTexCoord3fv'));
	TexCoord3i := SYSTEM.VAL(TglTexCoord3i, GetProcAddress('glTexCoord3i'));
	TexCoord3iv := SYSTEM.VAL(TglTexCoord3iv, GetProcAddress('glTexCoord3iv'));
	TexCoord3s := SYSTEM.VAL(TglTexCoord3s, GetProcAddress('glTexCoord3s'));
	TexCoord3sv := SYSTEM.VAL(TglTexCoord3sv, GetProcAddress('glTexCoord3sv'));
	TexCoord4d := SYSTEM.VAL(TglTexCoord4d, GetProcAddress('glTexCoord4d'));
	TexCoord4dv := SYSTEM.VAL(TglTexCoord4dv, GetProcAddress('glTexCoord4dv'));
	TexCoord4f := SYSTEM.VAL(TglTexCoord4f, GetProcAddress('glTexCoord4f'));
	TexCoord4fv := SYSTEM.VAL(TglTexCoord4fv, GetProcAddress('glTexCoord4fv'));
	TexCoord4i := SYSTEM.VAL(TglTexCoord4i, GetProcAddress('glTexCoord4i'));
	TexCoord4iv := SYSTEM.VAL(TglTexCoord4iv, GetProcAddress('glTexCoord4iv'));
	TexCoord4s := SYSTEM.VAL(TglTexCoord4s, GetProcAddress('glTexCoord4s'));
	TexCoord4sv := SYSTEM.VAL(TglTexCoord4sv, GetProcAddress('glTexCoord4sv'));
	TexCoordPointer := SYSTEM.VAL(TglTexCoordPointer, GetProcAddress('glTexCoordPointer'));
	TexEnvf := SYSTEM.VAL(TglTexEnvf, GetProcAddress('glTexEnvf'));
	TexEnvfv := SYSTEM.VAL(TglTexEnvfv, GetProcAddress('glTexEnvfv'));
	TexEnvi := SYSTEM.VAL(TglTexEnvi, GetProcAddress('glTexEnvi'));
	TexEnviv := SYSTEM.VAL(TglTexEnviv, GetProcAddress('glTexEnviv'));
	TexGend := SYSTEM.VAL(TglTexGend, GetProcAddress('glTexGend'));
	TexGendv := SYSTEM.VAL(TglTexGendv, GetProcAddress('glTexGendv'));
	TexGenf := SYSTEM.VAL(TglTexGenf, GetProcAddress('glTexGenf'));
	TexGenfv := SYSTEM.VAL(TglTexGenfv, GetProcAddress('glTexGenfv'));
	TexGeni := SYSTEM.VAL(TglTexGeni, GetProcAddress('glTexGeni'));
	TexGeniv := SYSTEM.VAL(TglTexGeniv, GetProcAddress('glTexGeniv'));
	Translated := SYSTEM.VAL(TglTranslated, GetProcAddress('glTranslated'));
	Translatef := SYSTEM.VAL(TglTranslatef, GetProcAddress('glTranslatef'));
	Vertex2d := SYSTEM.VAL(TglVertex2d, GetProcAddress('glVertex2d'));
	Vertex2dv := SYSTEM.VAL(TglVertex2dv, GetProcAddress('glVertex2dv'));
	Vertex2f := SYSTEM.VAL(TglVertex2f, GetProcAddress('glVertex2f'));
	Vertex2fv := SYSTEM.VAL(TglVertex2fv, GetProcAddress('glVertex2fv'));
	Vertex2i := SYSTEM.VAL(TglVertex2i, GetProcAddress('glVertex2i'));
	Vertex2iv := SYSTEM.VAL(TglVertex2iv, GetProcAddress('glVertex2iv'));
	Vertex2s := SYSTEM.VAL(TglVertex2s, GetProcAddress('glVertex2s'));
	Vertex2sv := SYSTEM.VAL(TglVertex2sv, GetProcAddress('glVertex2sv'));
	Vertex3d := SYSTEM.VAL(TglVertex3d, GetProcAddress('glVertex3d'));
	XglVertex3dv := SYSTEM.VAL(TglVertex3dv, GetProcAddress('glVertex3dv'));
	Vertex3f := SYSTEM.VAL(TglVertex3f, GetProcAddress('glVertex3f'));
	XglVertex3fv := SYSTEM.VAL(TglVertex3fv, GetProcAddress('glVertex3fv'));
	Vertex3i := SYSTEM.VAL(TglVertex3i, GetProcAddress('glVertex3i'));
	Vertex3iv := SYSTEM.VAL(TglVertex3iv, GetProcAddress('glVertex3iv'));
	Vertex3s := SYSTEM.VAL(TglVertex3s, GetProcAddress('glVertex3s'));
	Vertex3sv := SYSTEM.VAL(TglVertex3sv, GetProcAddress('glVertex3sv'));
	Vertex4d := SYSTEM.VAL(TglVertex4d, GetProcAddress('glVertex4d'));
	Vertex4dv := SYSTEM.VAL(TglVertex4dv, GetProcAddress('glVertex4dv'));
	Vertex4f := SYSTEM.VAL(TglVertex4f, GetProcAddress('glVertex4f'));
	Vertex4fv := SYSTEM.VAL(TglVertex4fv, GetProcAddress('glVertex4fv'));
	Vertex4i := SYSTEM.VAL(TglVertex4i, GetProcAddress('glVertex4i'));
	Vertex4iv := SYSTEM.VAL(TglVertex4iv, GetProcAddress('glVertex4iv'));
	Vertex4s := SYSTEM.VAL(TglVertex4s, GetProcAddress('glVertex4s'));
	Vertex4sv := SYSTEM.VAL(TglVertex4sv, GetProcAddress('glVertex4sv'));
	VertexPointer := SYSTEM.VAL(TglVertexPointer, GetProcAddress('glVertexPointer'));
	(*! endif  *)
	(* GL_VERSION_1_2  *)
	BlendColor := SYSTEM.VAL(TglBlendColor, GetProcAddress('glBlendColor'));
	BlendEquation := SYSTEM.VAL(TglBlendEquation, GetProcAddress('glBlendEquation'));
	DrawRangeElements := SYSTEM.VAL(TglDrawRangeElements, GetProcAddress('glDrawRangeElements'));
	TexImage3D := SYSTEM.VAL(TglTexImage3D, GetProcAddress('glTexImage3D'));
	TexSubImage3D := SYSTEM.VAL(TglTexSubImage3D, GetProcAddress('glTexSubImage3D'));
	CopyTexSubImage3D := SYSTEM.VAL(TglCopyTexSubImage3D, GetProcAddress('glCopyTexSubImage3D'));
	(* GL_VERSION_1_3  *)
	ActiveTexture := SYSTEM.VAL(TglActiveTexture, GetProcAddress('glActiveTexture'));
	SampleCoverage := SYSTEM.VAL(TglSampleCoverage, GetProcAddress('glSampleCoverage'));
	CompressedTexImage3D := SYSTEM.VAL(TglCompressedTexImage3D, GetProcAddress('glCompressedTexImage3D'));
	CompressedTexImage2D := SYSTEM.VAL(TglCompressedTexImage2D, GetProcAddress('glCompressedTexImage2D'));
	CompressedTexImage1D := SYSTEM.VAL(TglCompressedTexImage1D, GetProcAddress('glCompressedTexImage1D'));
	CompressedTexSubImage3D := SYSTEM.VAL(TglCompressedTexSubImage3D, GetProcAddress('glCompressedTexSubImage3D'));
	CompressedTexSubImage2D := SYSTEM.VAL(TglCompressedTexSubImage2D, GetProcAddress('glCompressedTexSubImage2D'));
	CompressedTexSubImage1D := SYSTEM.VAL(TglCompressedTexSubImage1D, GetProcAddress('glCompressedTexSubImage1D'));
	GetCompressedTexImage := SYSTEM.VAL(TglGetCompressedTexImage, GetProcAddress('glGetCompressedTexImage'));
	(* GL_VERSION_1_4  *)
	BlendFuncSeparate := SYSTEM.VAL(TglBlendFuncSeparate, GetProcAddress('glBlendFuncSeparate'));
	MultiDrawArrays := SYSTEM.VAL(TglMultiDrawArrays, GetProcAddress('glMultiDrawArrays'));
	MultiDrawElements := SYSTEM.VAL(TglMultiDrawElements, GetProcAddress('glMultiDrawElements'));
	PointParameterf := SYSTEM.VAL(TglPointParameterf, GetProcAddress('glPointParameterf'));
	PointParameterfv := SYSTEM.VAL(TglPointParameterfv, GetProcAddress('glPointParameterfv'));
	PointParameteri := SYSTEM.VAL(TglPointParameteri, GetProcAddress('glPointParameteri'));
	PointParameteriv := SYSTEM.VAL(TglPointParameteriv, GetProcAddress('glPointParameteriv'));
	(* GL_VERSION_1_5  *)
	GenQueries := SYSTEM.VAL(TglGenQueries, GetProcAddress('glGenQueries'));
	DeleteQueries := SYSTEM.VAL(TglDeleteQueries, GetProcAddress('glDeleteQueries'));
	IsQuery := SYSTEM.VAL(TglIsQuery, GetProcAddress('glIsQuery'));
	BeginQuery := SYSTEM.VAL(TglBeginQuery, GetProcAddress('glBeginQuery'));
	EndQuery := SYSTEM.VAL(TglEndQuery, GetProcAddress('glEndQuery'));
	GetQueryiv := SYSTEM.VAL(TglGetQueryiv, GetProcAddress('glGetQueryiv'));
	GetQueryObjectiv := SYSTEM.VAL(TglGetQueryObjectiv, GetProcAddress('glGetQueryObjectiv'));
	GetQueryObjectuiv := SYSTEM.VAL(TglGetQueryObjectuiv, GetProcAddress('glGetQueryObjectuiv'));
	BindBuffer := SYSTEM.VAL(TglBindBuffer, GetProcAddress('glBindBuffer'));
	DeleteBuffers := SYSTEM.VAL(TglDeleteBuffers, GetProcAddress('glDeleteBuffers'));
	GenBuffers := SYSTEM.VAL(TglGenBuffers, GetProcAddress('glGenBuffers'));
	IsBuffer := SYSTEM.VAL(TglIsBuffer, GetProcAddress('glIsBuffer'));
	BufferData := SYSTEM.VAL(TglBufferData, GetProcAddress('glBufferData'));
	BufferSubData := SYSTEM.VAL(TglBufferSubData, GetProcAddress('glBufferSubData'));
	GetBufferSubData := SYSTEM.VAL(TglGetBufferSubData, GetProcAddress('glGetBufferSubData'));
	MapBuffer := SYSTEM.VAL(TglMapBuffer, GetProcAddress('glMapBuffer'));
	UnmapBuffer := SYSTEM.VAL(TglUnmapBuffer, GetProcAddress('glUnmapBuffer'));
	GetBufferParameteriv := SYSTEM.VAL(TglGetBufferParameteriv, GetProcAddress('glGetBufferParameteriv'));
	GetBufferPointerv := SYSTEM.VAL(TglGetBufferPointerv, GetProcAddress('glGetBufferPointerv'));
	(* GL_VERSION_2_0  *)
	BlendEquationSeparate := SYSTEM.VAL(TglBlendEquationSeparate, GetProcAddress('glBlendEquationSeparate'));
	DrawBuffers := SYSTEM.VAL(TglDrawBuffers, GetProcAddress('glDrawBuffers'));
	StencilOpSeparate := SYSTEM.VAL(TglStencilOpSeparate, GetProcAddress('glStencilOpSeparate'));
	StencilFuncSeparate := SYSTEM.VAL(TglStencilFuncSeparate, GetProcAddress('glStencilFuncSeparate'));
	StencilMaskSeparate := SYSTEM.VAL(TglStencilMaskSeparate, GetProcAddress('glStencilMaskSeparate'));
	AttachShader := SYSTEM.VAL(TglAttachShader, GetProcAddress('glAttachShader'));
	XglBindAttribLocation := SYSTEM.VAL(TglBindAttribLocation, GetProcAddress('glBindAttribLocation'));
	CompileShader := SYSTEM.VAL(TglCompileShader, GetProcAddress('glCompileShader'));
	CreateProgram := SYSTEM.VAL(TglCreateProgram, GetProcAddress('glCreateProgram'));
	CreateShader := SYSTEM.VAL(TglCreateShader, GetProcAddress('glCreateShader'));
	DeleteProgram := SYSTEM.VAL(TglDeleteProgram, GetProcAddress('glDeleteProgram'));
	DeleteShader := SYSTEM.VAL(TglDeleteShader, GetProcAddress('glDeleteShader'));
	DetachShader := SYSTEM.VAL(TglDetachShader, GetProcAddress('glDetachShader'));
	DisableVertexAttribArray := SYSTEM.VAL(TglDisableVertexAttribArray, GetProcAddress('glDisableVertexAttribArray'));
	EnableVertexAttribArray := SYSTEM.VAL(TglEnableVertexAttribArray, GetProcAddress('glEnableVertexAttribArray'));
	GetActiveAttrib := SYSTEM.VAL(TglGetActiveAttrib, GetProcAddress('glGetActiveAttrib'));
	GetActiveUniform := SYSTEM.VAL(TglGetActiveUniform, GetProcAddress('glGetActiveUniform'));
	GetAttachedShaders := SYSTEM.VAL(TglGetAttachedShaders, GetProcAddress('glGetAttachedShaders'));
	XglGetAttribLocation := SYSTEM.VAL(TglGetAttribLocation, GetProcAddress('glGetAttribLocation'));
	GetProgramiv := SYSTEM.VAL(TglGetProgramiv, GetProcAddress('glGetProgramiv'));
	GetProgramInfoLog := SYSTEM.VAL(TglGetProgramInfoLog, GetProcAddress('glGetProgramInfoLog'));
	GetShaderiv := SYSTEM.VAL(TglGetShaderiv, GetProcAddress('glGetShaderiv'));
	GetShaderInfoLog := SYSTEM.VAL(TglGetShaderInfoLog, GetProcAddress('glGetShaderInfoLog'));
	GetShaderSource := SYSTEM.VAL(TglGetShaderSource, GetProcAddress('glGetShaderSource'));
	XglGetUniformLocation := SYSTEM.VAL(TglGetUniformLocation, GetProcAddress('glGetUniformLocation'));
	GetUniformfv := SYSTEM.VAL(TglGetUniformfv, GetProcAddress('glGetUniformfv'));
	GetUniformiv := SYSTEM.VAL(TglGetUniformiv, GetProcAddress('glGetUniformiv'));
	GetVertexAttribfv := SYSTEM.VAL(TglGetVertexAttribfv, GetProcAddress('glGetVertexAttribfv'));
	GetVertexAttribiv := SYSTEM.VAL(TglGetVertexAttribiv, GetProcAddress('glGetVertexAttribiv'));
	GetVertexAttribPointerv := SYSTEM.VAL(TglGetVertexAttribPointerv, GetProcAddress('glGetVertexAttribPointerv'));
	IsProgram := SYSTEM.VAL(TglIsProgram, GetProcAddress('glIsProgram'));
	IsShader := SYSTEM.VAL(TglIsShader, GetProcAddress('glIsShader'));
	LinkProgram := SYSTEM.VAL(TglLinkProgram, GetProcAddress('glLinkProgram'));
	ShaderSource := SYSTEM.VAL(TglShaderSource, GetProcAddress('glShaderSource'));
	UseProgram := SYSTEM.VAL(TglUseProgram, GetProcAddress('glUseProgram'));
	Uniform1f := SYSTEM.VAL(TglUniform1f, GetProcAddress('glUniform1f'));
	Uniform2f := SYSTEM.VAL(TglUniform2f, GetProcAddress('glUniform2f'));
	Uniform3f := SYSTEM.VAL(TglUniform3f, GetProcAddress('glUniform3f'));
	Uniform4f := SYSTEM.VAL(TglUniform4f, GetProcAddress('glUniform4f'));
	Uniform1i := SYSTEM.VAL(TglUniform1i, GetProcAddress('glUniform1i'));
	Uniform2i := SYSTEM.VAL(TglUniform2i, GetProcAddress('glUniform2i'));
	Uniform3i := SYSTEM.VAL(TglUniform3i, GetProcAddress('glUniform3i'));
	Uniform4i := SYSTEM.VAL(TglUniform4i, GetProcAddress('glUniform4i'));
	Uniform1fv := SYSTEM.VAL(TglUniform1fv, GetProcAddress('glUniform1fv'));
	Uniform2fv := SYSTEM.VAL(TglUniform2fv, GetProcAddress('glUniform2fv'));
	Uniform3fv := SYSTEM.VAL(TglUniform3fv, GetProcAddress('glUniform3fv'));
	Uniform4fv := SYSTEM.VAL(TglUniform4fv, GetProcAddress('glUniform4fv'));
	Uniform1iv := SYSTEM.VAL(TglUniform1iv, GetProcAddress('glUniform1iv'));
	Uniform2iv := SYSTEM.VAL(TglUniform2iv, GetProcAddress('glUniform2iv'));
	Uniform3iv := SYSTEM.VAL(TglUniform3iv, GetProcAddress('glUniform3iv'));
	Uniform4iv := SYSTEM.VAL(TglUniform4iv, GetProcAddress('glUniform4iv'));
	UniformMatrix2fv := SYSTEM.VAL(TglUniformMatrix2fv, GetProcAddress('glUniformMatrix2fv'));
	UniformMatrix3fv := SYSTEM.VAL(TglUniformMatrix3fv, GetProcAddress('glUniformMatrix3fv'));
	UniformMatrix4fv := SYSTEM.VAL(TglUniformMatrix4fv, GetProcAddress('glUniformMatrix4fv'));
	ValidateProgram := SYSTEM.VAL(TglValidateProgram, GetProcAddress('glValidateProgram'));
	VertexAttrib1d := SYSTEM.VAL(TglVertexAttrib1d, GetProcAddress('glVertexAttrib1d'));
	VertexAttrib1dv := SYSTEM.VAL(TglVertexAttrib1dv, GetProcAddress('glVertexAttrib1dv'));
	VertexAttrib1f := SYSTEM.VAL(TglVertexAttrib1f, GetProcAddress('glVertexAttrib1f'));
	VertexAttrib1fv := SYSTEM.VAL(TglVertexAttrib1fv, GetProcAddress('glVertexAttrib1fv'));
	VertexAttrib1s := SYSTEM.VAL(TglVertexAttrib1s, GetProcAddress('glVertexAttrib1s'));
	VertexAttrib1sv := SYSTEM.VAL(TglVertexAttrib1sv, GetProcAddress('glVertexAttrib1sv'));
	VertexAttrib2d := SYSTEM.VAL(TglVertexAttrib2d, GetProcAddress('glVertexAttrib2d'));
	VertexAttrib2dv := SYSTEM.VAL(TglVertexAttrib2dv, GetProcAddress('glVertexAttrib2dv'));
	VertexAttrib2f := SYSTEM.VAL(TglVertexAttrib2f, GetProcAddress('glVertexAttrib2f'));
	VertexAttrib2fv := SYSTEM.VAL(TglVertexAttrib2fv, GetProcAddress('glVertexAttrib2fv'));
	VertexAttrib2s := SYSTEM.VAL(TglVertexAttrib2s, GetProcAddress('glVertexAttrib2s'));
	VertexAttrib2sv := SYSTEM.VAL(TglVertexAttrib2sv, GetProcAddress('glVertexAttrib2sv'));
	VertexAttrib3d := SYSTEM.VAL(TglVertexAttrib3d, GetProcAddress('glVertexAttrib3d'));
	VertexAttrib3dv := SYSTEM.VAL(TglVertexAttrib3dv, GetProcAddress('glVertexAttrib3dv'));
	VertexAttrib3f := SYSTEM.VAL(TglVertexAttrib3f, GetProcAddress('glVertexAttrib3f'));
	VertexAttrib3fv := SYSTEM.VAL(TglVertexAttrib3fv, GetProcAddress('glVertexAttrib3fv'));
	VertexAttrib3s := SYSTEM.VAL(TglVertexAttrib3s, GetProcAddress('glVertexAttrib3s'));
	VertexAttrib3sv := SYSTEM.VAL(TglVertexAttrib3sv, GetProcAddress('glVertexAttrib3sv'));
	VertexAttrib4Nbv := SYSTEM.VAL(TglVertexAttrib4Nbv, GetProcAddress('glVertexAttrib4Nbv'));
	VertexAttrib4Niv := SYSTEM.VAL(TglVertexAttrib4Niv, GetProcAddress('glVertexAttrib4Niv'));
	VertexAttrib4Nsv := SYSTEM.VAL(TglVertexAttrib4Nsv, GetProcAddress('glVertexAttrib4Nsv'));
	VertexAttrib4Nub := SYSTEM.VAL(TglVertexAttrib4Nub, GetProcAddress('glVertexAttrib4Nub'));
	VertexAttrib4Nubv := SYSTEM.VAL(TglVertexAttrib4Nubv, GetProcAddress('glVertexAttrib4Nubv'));
	VertexAttrib4Nuiv := SYSTEM.VAL(TglVertexAttrib4Nuiv, GetProcAddress('glVertexAttrib4Nuiv'));
	VertexAttrib4Nusv := SYSTEM.VAL(TglVertexAttrib4Nusv, GetProcAddress('glVertexAttrib4Nusv'));
	VertexAttrib4bv := SYSTEM.VAL(TglVertexAttrib4bv, GetProcAddress('glVertexAttrib4bv'));
	VertexAttrib4d := SYSTEM.VAL(TglVertexAttrib4d, GetProcAddress('glVertexAttrib4d'));
	VertexAttrib4dv := SYSTEM.VAL(TglVertexAttrib4dv, GetProcAddress('glVertexAttrib4dv'));
	VertexAttrib4f := SYSTEM.VAL(TglVertexAttrib4f, GetProcAddress('glVertexAttrib4f'));
	VertexAttrib4fv := SYSTEM.VAL(TglVertexAttrib4fv, GetProcAddress('glVertexAttrib4fv'));
	VertexAttrib4iv := SYSTEM.VAL(TglVertexAttrib4iv, GetProcAddress('glVertexAttrib4iv'));
	VertexAttrib4s := SYSTEM.VAL(TglVertexAttrib4s, GetProcAddress('glVertexAttrib4s'));
	VertexAttrib4sv := SYSTEM.VAL(TglVertexAttrib4sv, GetProcAddress('glVertexAttrib4sv'));
	VertexAttrib4ubv := SYSTEM.VAL(TglVertexAttrib4ubv, GetProcAddress('glVertexAttrib4ubv'));
	VertexAttrib4uiv := SYSTEM.VAL(TglVertexAttrib4uiv, GetProcAddress('glVertexAttrib4uiv'));
	VertexAttrib4usv := SYSTEM.VAL(TglVertexAttrib4usv, GetProcAddress('glVertexAttrib4usv'));
	VertexAttribPointer := SYSTEM.VAL(TglVertexAttribPointer, GetProcAddress('glVertexAttribPointer'));
	(* GL_VERSION_2_1  *)
	UniformMatrix2x3fv := SYSTEM.VAL(TglUniformMatrix2x3fv, GetProcAddress('glUniformMatrix2x3fv'));
	UniformMatrix3x2fv := SYSTEM.VAL(TglUniformMatrix3x2fv, GetProcAddress('glUniformMatrix3x2fv'));
	UniformMatrix2x4fv := SYSTEM.VAL(TglUniformMatrix2x4fv, GetProcAddress('glUniformMatrix2x4fv'));
	UniformMatrix4x2fv := SYSTEM.VAL(TglUniformMatrix4x2fv, GetProcAddress('glUniformMatrix4x2fv'));
	UniformMatrix3x4fv := SYSTEM.VAL(TglUniformMatrix3x4fv, GetProcAddress('glUniformMatrix3x4fv'));
	UniformMatrix4x3fv := SYSTEM.VAL(TglUniformMatrix4x3fv, GetProcAddress('glUniformMatrix4x3fv'));
	(* GL_VERSION_3_0  *)
	(* OpenGL 3.0 also reuses entry points from these extensions:  *)
	ColorMaski := SYSTEM.VAL(TglColorMaski, GetProcAddress('glColorMaski'));
	GetBooleani_v := SYSTEM.VAL(TglGetBooleani_v, GetProcAddress('glGetBooleani_v'));
	GetIntegeri_v := SYSTEM.VAL(TglGetIntegeri_v, GetProcAddress('glGetIntegeri_v'));
	Enablei := SYSTEM.VAL(TglEnablei, GetProcAddress('glEnablei'));
	Disablei := SYSTEM.VAL(TglDisablei, GetProcAddress('glDisablei'));
	IsEnabledi := SYSTEM.VAL(TglIsEnabledi, GetProcAddress('glIsEnabledi'));
	BeginTransformFeedback := SYSTEM.VAL(TglBeginTransformFeedback, GetProcAddress('glBeginTransformFeedback'));
	EndTransformFeedback := SYSTEM.VAL(TglEndTransformFeedback, GetProcAddress('glEndTransformFeedback'));
	BindBufferRange := SYSTEM.VAL(TglBindBufferRange, GetProcAddress('glBindBufferRange'));
	BindBufferBase := SYSTEM.VAL(TglBindBufferBase, GetProcAddress('glBindBufferBase'));
	TransformFeedbackVaryings := SYSTEM.VAL(TglTransformFeedbackVaryings, GetProcAddress('glTransformFeedbackVaryings'));
	GetTransformFeedbackVarying := SYSTEM.VAL(TglGetTransformFeedbackVarying, GetProcAddress('glGetTransformFeedbackVarying'));
	ClampColor := SYSTEM.VAL(TglClampColor, GetProcAddress('glClampColor'));
	BeginConditionalRender := SYSTEM.VAL(TglBeginConditionalRender, GetProcAddress('glBeginConditionalRender'));
	EndConditionalRender := SYSTEM.VAL(TglEndConditionalRender, GetProcAddress('glEndConditionalRender'));
	VertexAttribI1i := SYSTEM.VAL(TglVertexAttribI1i, GetProcAddress('glVertexAttribI1i'));
	VertexAttribI2i := SYSTEM.VAL(TglVertexAttribI2i, GetProcAddress('glVertexAttribI2i'));
	VertexAttribI3i := SYSTEM.VAL(TglVertexAttribI3i, GetProcAddress('glVertexAttribI3i'));
	VertexAttribI4i := SYSTEM.VAL(TglVertexAttribI4i, GetProcAddress('glVertexAttribI4i'));
	VertexAttribI1ui := SYSTEM.VAL(TglVertexAttribI1ui, GetProcAddress('glVertexAttribI1ui'));
	VertexAttribI2ui := SYSTEM.VAL(TglVertexAttribI2ui, GetProcAddress('glVertexAttribI2ui'));
	VertexAttribI3ui := SYSTEM.VAL(TglVertexAttribI3ui, GetProcAddress('glVertexAttribI3ui'));
	VertexAttribI4ui := SYSTEM.VAL(TglVertexAttribI4ui, GetProcAddress('glVertexAttribI4ui'));
	VertexAttribI1iv := SYSTEM.VAL(TglVertexAttribI1iv, GetProcAddress('glVertexAttribI1iv'));
	VertexAttribI2iv := SYSTEM.VAL(TglVertexAttribI2iv, GetProcAddress('glVertexAttribI2iv'));
	VertexAttribI3iv := SYSTEM.VAL(TglVertexAttribI3iv, GetProcAddress('glVertexAttribI3iv'));
	VertexAttribI4iv := SYSTEM.VAL(TglVertexAttribI4iv, GetProcAddress('glVertexAttribI4iv'));
	VertexAttribI1uiv := SYSTEM.VAL(TglVertexAttribI1uiv, GetProcAddress('glVertexAttribI1uiv'));
	VertexAttribI2uiv := SYSTEM.VAL(TglVertexAttribI2uiv, GetProcAddress('glVertexAttribI2uiv'));
	VertexAttribI3uiv := SYSTEM.VAL(TglVertexAttribI3uiv, GetProcAddress('glVertexAttribI3uiv'));
	VertexAttribI4uiv := SYSTEM.VAL(TglVertexAttribI4uiv, GetProcAddress('glVertexAttribI4uiv'));
	VertexAttribI4bv := SYSTEM.VAL(TglVertexAttribI4bv, GetProcAddress('glVertexAttribI4bv'));
	VertexAttribI4sv := SYSTEM.VAL(TglVertexAttribI4sv, GetProcAddress('glVertexAttribI4sv'));
	VertexAttribI4ubv := SYSTEM.VAL(TglVertexAttribI4ubv, GetProcAddress('glVertexAttribI4ubv'));
	VertexAttribI4usv := SYSTEM.VAL(TglVertexAttribI4usv, GetProcAddress('glVertexAttribI4usv'));
	VertexAttribIPointer := SYSTEM.VAL(TglVertexAttribIPointer, GetProcAddress('glVertexAttribIPointer'));
	GetVertexAttribIiv := SYSTEM.VAL(TglGetVertexAttribIiv, GetProcAddress('glGetVertexAttribIiv'));
	GetVertexAttribIuiv := SYSTEM.VAL(TglGetVertexAttribIuiv, GetProcAddress('glGetVertexAttribIuiv'));
	GetUniformuiv := SYSTEM.VAL(TglGetUniformuiv, GetProcAddress('glGetUniformuiv'));
	XglBindFragDataLocation := SYSTEM.VAL(TglBindFragDataLocation, GetProcAddress('glBindFragDataLocation'));
	XglGetFragDataLocation := SYSTEM.VAL(TglGetFragDataLocation, GetProcAddress('glGetFragDataLocation'));
	Uniform1ui := SYSTEM.VAL(TglUniform1ui, GetProcAddress('glUniform1ui'));
	Uniform2ui := SYSTEM.VAL(TglUniform2ui, GetProcAddress('glUniform2ui'));
	Uniform3ui := SYSTEM.VAL(TglUniform3ui, GetProcAddress('glUniform3ui'));
	Uniform4ui := SYSTEM.VAL(TglUniform4ui, GetProcAddress('glUniform4ui'));
	Uniform1uiv := SYSTEM.VAL(TglUniform1uiv, GetProcAddress('glUniform1uiv'));
	Uniform2uiv := SYSTEM.VAL(TglUniform2uiv, GetProcAddress('glUniform2uiv'));
	Uniform3uiv := SYSTEM.VAL(TglUniform3uiv, GetProcAddress('glUniform3uiv'));
	Uniform4uiv := SYSTEM.VAL(TglUniform4uiv, GetProcAddress('glUniform4uiv'));
	TexParameterIiv := SYSTEM.VAL(TglTexParameterIiv, GetProcAddress('glTexParameterIiv'));
	TexParameterIuiv := SYSTEM.VAL(TglTexParameterIuiv, GetProcAddress('glTexParameterIuiv'));
	GetTexParameterIiv := SYSTEM.VAL(TglGetTexParameterIiv, GetProcAddress('glGetTexParameterIiv'));
	GetTexParameterIuiv := SYSTEM.VAL(TglGetTexParameterIuiv, GetProcAddress('glGetTexParameterIuiv'));
	ClearBufferiv := SYSTEM.VAL(TglClearBufferiv, GetProcAddress('glClearBufferiv'));
	ClearBufferuiv := SYSTEM.VAL(TglClearBufferuiv, GetProcAddress('glClearBufferuiv'));
	ClearBufferfv := SYSTEM.VAL(TglClearBufferfv, GetProcAddress('glClearBufferfv'));
	ClearBufferfi := SYSTEM.VAL(TglClearBufferfi, GetProcAddress('glClearBufferfi'));
	GetStringi := SYSTEM.VAL(TglGetStringi, GetProcAddress('glGetStringi'));

  (* OpenGL 3.1 also reuses entry points from these extensions: *)
  Read_GL_ARB_copy_buffer;
  Read_GL_ARB_uniform_buffer_object;

  DrawArraysInstanced := SYSTEM.VAL(TglDrawArraysInstanced, GetProcAddress('glDrawArraysInstanced'));
  DrawElementsInstanced :=  SYSTEM.VAL(TglDrawElementsInstanced, GetProcAddress('glDrawElementsInstanced'));
  TexBuffer :=  SYSTEM.VAL(TglTexBuffer, GetProcAddress('glTexBuffer'));
  PrimitiveRestartIndex :=  SYSTEM.VAL(TglPrimitiveRestartIndex, GetProcAddress('glPrimitiveRestartIndex'));

  (* GL_VERSION_3_2 *)
  (* OpenGL 3.2 also reuses entry points from these extensions: *)
  Read_GL_ARB_draw_elements_base_vertex;
  Read_GL_ARB_provoking_vertex;
  Read_GL_ARB_sync;
  Read_GL_ARB_texture_multisample;

  GetInteger64i_v :=  SYSTEM.VAL(TglGetInteger64i_v,  GetProcAddress('glGetInteger64i_v'));
  GetBufferParameteri64v :=  SYSTEM.VAL(TglGetBufferParameteri64v, GetProcAddress('glGetBufferParameteri64v'));
  FramebufferTexture :=  SYSTEM.VAL(TglFramebufferTexture, GetProcAddress('glFramebufferTexture'));
(*  FramebufferTextureFace := SYSTEM.VAL(TglFramebufferTextureFace, GetProcAddress('glFramebufferTextureFace')); *)

  (* GL_VERSION_3_3 *)
  (* OpenGL 3.3 also reuses entry points from these extensions: *)
  Read_GL_ARB_blend_func_extended;
  Read_GL_ARB_sampler_objects;
  (* ARB_explicit_attrib_location, but it has none *)
  (* ARB_occlusion_query2 (no entry points) *)
  (* ARB_shader_bit_encoding (no entry points) *)
  (* ARB_texture_rgb10_a2ui (no entry points) *)
  (* ARB_texture_swizzle (no entry points) *)
  Read_GL_ARB_timer_query;
  Read_GL_ARB_vertex_type_2_10_10_10_rev;

  VertexAttribDivisor :=  SYSTEM.VAL(TglVertexAttribDivisor, GetProcAddress('glVertexAttribDivisor'));

  (* GL_VERSION_4_0 *)
  (* OpenGL 4.0 also reuses entry points from these extensions: *)
  (* ARB_texture_query_lod (no entry points) *)
  Read_GL_ARB_draw_indirect;
  (* ARB_gpu_shader5 (no entry points) *)
  Read_GL_ARB_gpu_shader_fp64;
  Read_GL_ARB_shader_subroutine;
  Read_GL_ARB_tessellation_shader;
  (* ARB_texture_buffer_object_rgb32 (no entry points) *)
  (* ARB_texture_cube_map_array (no entry points) *)
  (* ARB_texture_gather (no entry points) *)
  Read_GL_ARB_transform_feedback2;
  Read_GL_ARB_transform_feedback3;

  MinSampleShading :=  SYSTEM.VAL(TglMinSampleShading, GetProcAddress('glMinSampleShading'));
  BlendEquationi :=  SYSTEM.VAL(TglBlendEquationi, GetProcAddress('glBlendEquationi'));
  BlendEquationSeparatei :=  SYSTEM.VAL(TglBlendEquationSeparatei, GetProcAddress('glBlendEquationSeparatei'));
  BlendFunci :=  SYSTEM.VAL(TglBlendFunci, GetProcAddress('glBlendFunci'));
  BlendFuncSeparatei :=  SYSTEM.VAL(TglBlendFuncSeparatei, GetProcAddress('glBlendFuncSeparatei'));

  (*  GL_VERSION_4_1 *)
  (*  OpenGL 4.1 also reuses entry points from these extensions: *)
  Read_GL_ARB_ES2_compatibility;
  Read_GL_ARB_get_program_binary;
  Read_GL_ARB_separate_shader_objects;
  (* ARB_shader_precision (no entry points) *)
  Read_GL_ARB_vertex_attrib_64bit;
  Read_GL_ARB_viewport_array;

  (* GL_VERSION_4_2 *)
  (* OpenGL 4.2 reuses entry points from these extensions: *)
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

   (* GL_VERSION_4_3 *)
   (* OpenGL 4.3 reuses entry points from these extensions: *)
   (* Read_GL_ARB_arrays_of_arrays (none, GLSL only) (no entry points) *)
   (* Read_GL_ARB_fragment_layer_viewport (none, GLSL only) (no entry points) *)
   (* Read_GL_ARB_shader_image_size (none, GLSL only) (no entry points) *)
  (* Read_GL_ARB_ES3_compatibility (no entry points) *)
  Read_GL_ARB_clear_buffer_object;
  Read_GL_ARB_compute_shader;
  Read_GL_ARB_copy_image;
  Read_GL_KHR_debug;
  (* Read_GL_ARB_explicit_uniform_location  (no entry points) *)
  Read_GL_ARB_framebuffer_no_attachments;
  Read_GL_ARB_internalformat_query2;
  Read_GL_ARB_invalidate_subdata;
  Read_GL_ARB_multi_draw_indirect;
  Read_GL_ARB_program_interface_query;
  (* Read_GL_ARB_robust_buffer_access_behavior (none)  (no entry points) *)
  Read_GL_ARB_shader_storage_buffer_object;
  (* Read_GL_ARB_stencil_texturing  (no entry points) *)
  Read_GL_ARB_texture_buffer_range;
  (* Read_GL_ARB_texture_query_levels (none)  (no entry points) *)
  Read_GL_ARB_texture_storage_multisample;
  Read_GL_ARB_texture_view;
  Read_GL_ARB_vertex_attrib_binding;

END ReadOpenGLCore;

PROCEDURE Read_GL_3DFX_tbuffer*;
BEGIN
	TbufferMask3DFX := SYSTEM.VAL(TglTbufferMask3DFX, GetProcAddress('glTbufferMask3DFX'));
END Read_GL_3DFX_tbuffer;

PROCEDURE Read_GL_APPLE_element_array*;
BEGIN
	ElementPointerAPPLE := SYSTEM.VAL(TglElementPointerAPPLE, GetProcAddress('glElementPointerAPPLE'));
	DrawElementArrayAPPLE := SYSTEM.VAL(TglDrawElementArrayAPPLE, GetProcAddress('glDrawElementArrayAPPLE'));
	DrawRangeElementArrayAPPLE := SYSTEM.VAL(TglDrawRangeElementArrayAPPLE, GetProcAddress('glDrawRangeElementArrayAPPLE'));
	MultiDrawElementArrayAPPLE := SYSTEM.VAL(TglMultiDrawElementArrayAPPLE, GetProcAddress('glMultiDrawElementArrayAPPLE'));
	MultiDrawRangeElementArrayAPPLE := SYSTEM.VAL(TglMultiDrawRangeElementArrayAPPLE, GetProcAddress('glMultiDrawRangeElementArrayAPPLE'));
END Read_GL_APPLE_element_array;

PROCEDURE Read_GL_APPLE_fence*;
BEGIN
	GenFencesAPPLE := SYSTEM.VAL(TglGenFencesAPPLE, GetProcAddress('glGenFencesAPPLE'));
	DeleteFencesAPPLE := SYSTEM.VAL(TglDeleteFencesAPPLE, GetProcAddress('glDeleteFencesAPPLE'));
	SetFenceAPPLE := SYSTEM.VAL(TglSetFenceAPPLE, GetProcAddress('glSetFenceAPPLE'));
	IsFenceAPPLE := SYSTEM.VAL(TglIsFenceAPPLE, GetProcAddress('glIsFenceAPPLE'));
	TestFenceAPPLE := SYSTEM.VAL(TglTestFenceAPPLE, GetProcAddress('glTestFenceAPPLE'));
	FinishFenceAPPLE := SYSTEM.VAL(TglFinishFenceAPPLE, GetProcAddress('glFinishFenceAPPLE'));
	TestObjectAPPLE := SYSTEM.VAL(TglTestObjectAPPLE, GetProcAddress('glTestObjectAPPLE'));
	FinishObjectAPPLE := SYSTEM.VAL(TglFinishObjectAPPLE, GetProcAddress('glFinishObjectAPPLE'));
END Read_GL_APPLE_fence;

PROCEDURE Read_GL_APPLE_vertex_array_object*;
BEGIN
	BindVertexArrayAPPLE := SYSTEM.VAL(TglBindVertexArrayAPPLE, GetProcAddress('glBindVertexArrayAPPLE'));
	DeleteVertexArraysAPPLE := SYSTEM.VAL(TglDeleteVertexArraysAPPLE, GetProcAddress('glDeleteVertexArraysAPPLE'));
	GenVertexArraysAPPLE := SYSTEM.VAL(TglGenVertexArraysAPPLE, GetProcAddress('glGenVertexArraysAPPLE'));
	IsVertexArrayAPPLE := SYSTEM.VAL(TglIsVertexArrayAPPLE, GetProcAddress('glIsVertexArrayAPPLE'));
END Read_GL_APPLE_vertex_array_object;

PROCEDURE Read_GL_APPLE_vertex_array_range*;
BEGIN
	VertexArrayRangeAPPLE := SYSTEM.VAL(TglVertexArrayRangeAPPLE, GetProcAddress('glVertexArrayRangeAPPLE'));
	FlushVertexArrayRangeAPPLE := SYSTEM.VAL(TglFlushVertexArrayRangeAPPLE, GetProcAddress('glFlushVertexArrayRangeAPPLE'));
	VertexArrayParameteriAPPLE := SYSTEM.VAL(TglVertexArrayParameteriAPPLE, GetProcAddress('glVertexArrayParameteriAPPLE'));
END Read_GL_APPLE_vertex_array_range;

PROCEDURE Read_GL_APPLE_texture_range*;
BEGIN
	TextureRangeAPPLE := SYSTEM.VAL(TglTextureRangeAPPLE, GetProcAddress('glTextureRangeAPPLE'));
	GetTexParameterPointervAPPLE := SYSTEM.VAL(TglGetTexParameterPointervAPPLE, GetProcAddress('glGetTexParameterPointervAPPLE'));
END Read_GL_APPLE_texture_range;

PROCEDURE Read_GL_APPLE_vertex_program_evaluators*;
BEGIN
	EnableVertexAttribAPPLE := SYSTEM.VAL(TglEnableVertexAttribAPPLE, GetProcAddress('glEnableVertexAttribAPPLE'));
	DisableVertexAttribAPPLE := SYSTEM.VAL(TglDisableVertexAttribAPPLE, GetProcAddress('glDisableVertexAttribAPPLE'));
	IsVertexAttribEnabledAPPLE := SYSTEM.VAL(TglIsVertexAttribEnabledAPPLE, GetProcAddress('glIsVertexAttribEnabledAPPLE'));
	MapVertexAttrib1dAPPLE := SYSTEM.VAL(TglMapVertexAttrib1dAPPLE, GetProcAddress('glMapVertexAttrib1dAPPLE'));
	MapVertexAttrib1fAPPLE := SYSTEM.VAL(TglMapVertexAttrib1fAPPLE, GetProcAddress('glMapVertexAttrib1fAPPLE'));
	MapVertexAttrib2dAPPLE := SYSTEM.VAL(TglMapVertexAttrib2dAPPLE, GetProcAddress('glMapVertexAttrib2dAPPLE'));
	MapVertexAttrib2fAPPLE := SYSTEM.VAL(TglMapVertexAttrib2fAPPLE, GetProcAddress('glMapVertexAttrib2fAPPLE'));
END Read_GL_APPLE_vertex_program_evaluators;

PROCEDURE Read_GL_APPLE_object_purgeable*;
BEGIN
	ObjectPurgeableAPPLE := SYSTEM.VAL(TglObjectPurgeableAPPLE, GetProcAddress('glObjectPurgeableAPPLE'));
	ObjectUnpurgeableAPPLE := SYSTEM.VAL(TglObjectUnpurgeableAPPLE, GetProcAddress('glObjectUnpurgeableAPPLE'));
	GetObjectParameterivAPPLE := SYSTEM.VAL(TglGetObjectParameterivAPPLE, GetProcAddress('glGetObjectParameterivAPPLE'));
END Read_GL_APPLE_object_purgeable;

PROCEDURE Read_GL_ARB_matrix_palette*;
BEGIN
	CurrentPaletteMatrixARB := SYSTEM.VAL(TglCurrentPaletteMatrixARB, GetProcAddress('glCurrentPaletteMatrixARB'));
	MatrixIndexubvARB := SYSTEM.VAL(TglMatrixIndexubvARB, GetProcAddress('glMatrixIndexubvARB'));
	MatrixIndexusvARB := SYSTEM.VAL(TglMatrixIndexusvARB, GetProcAddress('glMatrixIndexusvARB'));
	MatrixIndexuivARB := SYSTEM.VAL(TglMatrixIndexuivARB, GetProcAddress('glMatrixIndexuivARB'));
	MatrixIndexPointerARB := SYSTEM.VAL(TglMatrixIndexPointerARB, GetProcAddress('glMatrixIndexPointerARB'));
END Read_GL_ARB_matrix_palette;

PROCEDURE Read_GL_ARB_multisample*;
BEGIN
	SampleCoverageARB := SYSTEM.VAL(TglSampleCoverageARB, GetProcAddress('glSampleCoverageARB'));
END Read_GL_ARB_multisample;

PROCEDURE Read_GL_ARB_multitexture*;
BEGIN
	ActiveTextureARB := SYSTEM.VAL(TglActiveTextureARB, GetProcAddress('glActiveTextureARB'));
	ClientActiveTextureARB := SYSTEM.VAL(TglClientActiveTextureARB, GetProcAddress('glClientActiveTextureARB'));
	MultiTexCoord1dARB := SYSTEM.VAL(TglMultiTexCoord1dARB, GetProcAddress('glMultiTexCoord1dARB'));
	MultiTexCoord1dvARB := SYSTEM.VAL(TglMultiTexCoord1dvARB, GetProcAddress('glMultiTexCoord1dvARB'));
	MultiTexCoord1fARB := SYSTEM.VAL(TglMultiTexCoord1fARB, GetProcAddress('glMultiTexCoord1fARB'));
	MultiTexCoord1fvARB := SYSTEM.VAL(TglMultiTexCoord1fvARB, GetProcAddress('glMultiTexCoord1fvARB'));
	MultiTexCoord1iARB := SYSTEM.VAL(TglMultiTexCoord1iARB, GetProcAddress('glMultiTexCoord1iARB'));
	MultiTexCoord1ivARB := SYSTEM.VAL(TglMultiTexCoord1ivARB, GetProcAddress('glMultiTexCoord1ivARB'));
	MultiTexCoord1sARB := SYSTEM.VAL(TglMultiTexCoord1sARB, GetProcAddress('glMultiTexCoord1sARB'));
	MultiTexCoord1svARB := SYSTEM.VAL(TglMultiTexCoord1svARB, GetProcAddress('glMultiTexCoord1svARB'));
	MultiTexCoord2dARB := SYSTEM.VAL(TglMultiTexCoord2dARB, GetProcAddress('glMultiTexCoord2dARB'));
	MultiTexCoord2dvARB := SYSTEM.VAL(TglMultiTexCoord2dvARB, GetProcAddress('glMultiTexCoord2dvARB'));
	MultiTexCoord2fARB := SYSTEM.VAL(TglMultiTexCoord2fARB, GetProcAddress('glMultiTexCoord2fARB'));
	MultiTexCoord2fvARB := SYSTEM.VAL(TglMultiTexCoord2fvARB, GetProcAddress('glMultiTexCoord2fvARB'));
	MultiTexCoord2iARB := SYSTEM.VAL(TglMultiTexCoord2iARB, GetProcAddress('glMultiTexCoord2iARB'));
	MultiTexCoord2ivARB := SYSTEM.VAL(TglMultiTexCoord2ivARB, GetProcAddress('glMultiTexCoord2ivARB'));
	MultiTexCoord2sARB := SYSTEM.VAL(TglMultiTexCoord2sARB, GetProcAddress('glMultiTexCoord2sARB'));
	MultiTexCoord2svARB := SYSTEM.VAL(TglMultiTexCoord2svARB, GetProcAddress('glMultiTexCoord2svARB'));
	MultiTexCoord3dARB := SYSTEM.VAL(TglMultiTexCoord3dARB, GetProcAddress('glMultiTexCoord3dARB'));
	MultiTexCoord3dvARB := SYSTEM.VAL(TglMultiTexCoord3dvARB, GetProcAddress('glMultiTexCoord3dvARB'));
	MultiTexCoord3fARB := SYSTEM.VAL(TglMultiTexCoord3fARB, GetProcAddress('glMultiTexCoord3fARB'));
	MultiTexCoord3fvARB := SYSTEM.VAL(TglMultiTexCoord3fvARB, GetProcAddress('glMultiTexCoord3fvARB'));
	MultiTexCoord3iARB := SYSTEM.VAL(TglMultiTexCoord3iARB, GetProcAddress('glMultiTexCoord3iARB'));
	MultiTexCoord3ivARB := SYSTEM.VAL(TglMultiTexCoord3ivARB, GetProcAddress('glMultiTexCoord3ivARB'));
	MultiTexCoord3sARB := SYSTEM.VAL(TglMultiTexCoord3sARB, GetProcAddress('glMultiTexCoord3sARB'));
	MultiTexCoord3svARB := SYSTEM.VAL(TglMultiTexCoord3svARB, GetProcAddress('glMultiTexCoord3svARB'));
	MultiTexCoord4dARB := SYSTEM.VAL(TglMultiTexCoord4dARB, GetProcAddress('glMultiTexCoord4dARB'));
	MultiTexCoord4dvARB := SYSTEM.VAL(TglMultiTexCoord4dvARB, GetProcAddress('glMultiTexCoord4dvARB'));
	MultiTexCoord4fARB := SYSTEM.VAL(TglMultiTexCoord4fARB, GetProcAddress('glMultiTexCoord4fARB'));
	MultiTexCoord4fvARB := SYSTEM.VAL(TglMultiTexCoord4fvARB, GetProcAddress('glMultiTexCoord4fvARB'));
	MultiTexCoord4iARB := SYSTEM.VAL(TglMultiTexCoord4iARB, GetProcAddress('glMultiTexCoord4iARB'));
	MultiTexCoord4ivARB := SYSTEM.VAL(TglMultiTexCoord4ivARB, GetProcAddress('glMultiTexCoord4ivARB'));
	MultiTexCoord4sARB := SYSTEM.VAL(TglMultiTexCoord4sARB, GetProcAddress('glMultiTexCoord4sARB'));
	MultiTexCoord4svARB := SYSTEM.VAL(TglMultiTexCoord4svARB, GetProcAddress('glMultiTexCoord4svARB'));
END Read_GL_ARB_multitexture;

PROCEDURE Read_GL_ARB_point_parameters*;
BEGIN
	PointParameterfARB := SYSTEM.VAL(TglPointParameterfARB, GetProcAddress('glPointParameterfARB'));
	PointParameterfvARB := SYSTEM.VAL(TglPointParameterfvARB, GetProcAddress('glPointParameterfvARB'));
END Read_GL_ARB_point_parameters;

PROCEDURE Read_GL_ARB_texture_compression*;
BEGIN
	CompressedTexImage3DARB := SYSTEM.VAL(TglCompressedTexImage3DARB, GetProcAddress('glCompressedTexImage3DARB'));
	CompressedTexImage2DARB := SYSTEM.VAL(TglCompressedTexImage2DARB, GetProcAddress('glCompressedTexImage2DARB'));
	CompressedTexImage1DARB := SYSTEM.VAL(TglCompressedTexImage1DARB, GetProcAddress('glCompressedTexImage1DARB'));
	CompressedTexSubImage3DARB := SYSTEM.VAL(TglCompressedTexSubImage3DARB, GetProcAddress('glCompressedTexSubImage3DARB'));
	CompressedTexSubImage2DARB := SYSTEM.VAL(TglCompressedTexSubImage2DARB, GetProcAddress('glCompressedTexSubImage2DARB'));
	CompressedTexSubImage1DARB := SYSTEM.VAL(TglCompressedTexSubImage1DARB, GetProcAddress('glCompressedTexSubImage1DARB'));
	GetCompressedTexImageARB := SYSTEM.VAL(TglGetCompressedTexImageARB, GetProcAddress('glGetCompressedTexImageARB'));
END Read_GL_ARB_texture_compression;

PROCEDURE Read_GL_ARB_transpose_matrix*;
BEGIN
	LoadTransposeMatrixfARB := SYSTEM.VAL(TglLoadTransposeMatrixfARB, GetProcAddress('glLoadTransposeMatrixfARB'));
	LoadTransposeMatrixdARB := SYSTEM.VAL(TglLoadTransposeMatrixdARB, GetProcAddress('glLoadTransposeMatrixdARB'));
	MultTransposeMatrixfARB := SYSTEM.VAL(TglMultTransposeMatrixfARB, GetProcAddress('glMultTransposeMatrixfARB'));
	MultTransposeMatrixdARB := SYSTEM.VAL(TglMultTransposeMatrixdARB, GetProcAddress('glMultTransposeMatrixdARB'));
END Read_GL_ARB_transpose_matrix;

PROCEDURE Read_GL_ARB_vertex_blend*;
BEGIN
	WeightbvARB := SYSTEM.VAL(TglWeightbvARB, GetProcAddress('glWeightbvARB'));
	WeightsvARB := SYSTEM.VAL(TglWeightsvARB, GetProcAddress('glWeightsvARB'));
	WeightivARB := SYSTEM.VAL(TglWeightivARB, GetProcAddress('glWeightivARB'));
	WeightfvARB := SYSTEM.VAL(TglWeightfvARB, GetProcAddress('glWeightfvARB'));
	WeightdvARB := SYSTEM.VAL(TglWeightdvARB, GetProcAddress('glWeightdvARB'));
	WeightubvARB := SYSTEM.VAL(TglWeightubvARB, GetProcAddress('glWeightubvARB'));
	WeightusvARB := SYSTEM.VAL(TglWeightusvARB, GetProcAddress('glWeightusvARB'));
	WeightuivARB := SYSTEM.VAL(TglWeightuivARB, GetProcAddress('glWeightuivARB'));
	WeightPointerARB := SYSTEM.VAL(TglWeightPointerARB, GetProcAddress('glWeightPointerARB'));
	VertexBlendARB := SYSTEM.VAL(TglVertexBlendARB, GetProcAddress('glVertexBlendARB'));
END Read_GL_ARB_vertex_blend;

PROCEDURE Read_GL_ARB_vertex_buffer_object*;
BEGIN
	BindBufferARB := SYSTEM.VAL(TglBindBufferARB, GetProcAddress('glBindBufferARB'));
	DeleteBuffersARB := SYSTEM.VAL(TglDeleteBuffersARB, GetProcAddress('glDeleteBuffersARB'));
	GenBuffersARB := SYSTEM.VAL(TglGenBuffersARB, GetProcAddress('glGenBuffersARB'));
	IsBufferARB := SYSTEM.VAL(TglIsBufferARB, GetProcAddress('glIsBufferARB'));
	BufferDataARB := SYSTEM.VAL(TglBufferDataARB, GetProcAddress('glBufferDataARB'));
	BufferSubDataARB := SYSTEM.VAL(TglBufferSubDataARB, GetProcAddress('glBufferSubDataARB'));
	GetBufferSubDataARB := SYSTEM.VAL(TglGetBufferSubDataARB, GetProcAddress('glGetBufferSubDataARB'));
	MapBufferARB := SYSTEM.VAL(TglMapBufferARB, GetProcAddress('glMapBufferARB'));
	UnmapBufferARB := SYSTEM.VAL(TglUnmapBufferARB, GetProcAddress('glUnmapBufferARB'));
	GetBufferParameterivARB := SYSTEM.VAL(TglGetBufferParameterivARB, GetProcAddress('glGetBufferParameterivARB'));
	GetBufferPointervARB := SYSTEM.VAL(TglGetBufferPointervARB, GetProcAddress('glGetBufferPointervARB'));
END Read_GL_ARB_vertex_buffer_object;

PROCEDURE Read_GL_ARB_vertex_program*;
BEGIN
	VertexAttrib1dARB := SYSTEM.VAL(TglVertexAttrib1dARB, GetProcAddress('glVertexAttrib1dARB'));
	VertexAttrib1dvARB := SYSTEM.VAL(TglVertexAttrib1dvARB, GetProcAddress('glVertexAttrib1dvARB'));
	VertexAttrib1fARB := SYSTEM.VAL(TglVertexAttrib1fARB, GetProcAddress('glVertexAttrib1fARB'));
	VertexAttrib1fvARB := SYSTEM.VAL(TglVertexAttrib1fvARB, GetProcAddress('glVertexAttrib1fvARB'));
	VertexAttrib1sARB := SYSTEM.VAL(TglVertexAttrib1sARB, GetProcAddress('glVertexAttrib1sARB'));
	VertexAttrib1svARB := SYSTEM.VAL(TglVertexAttrib1svARB, GetProcAddress('glVertexAttrib1svARB'));
	VertexAttrib2dARB := SYSTEM.VAL(TglVertexAttrib2dARB, GetProcAddress('glVertexAttrib2dARB'));
	VertexAttrib2dvARB := SYSTEM.VAL(TglVertexAttrib2dvARB, GetProcAddress('glVertexAttrib2dvARB'));
	VertexAttrib2fARB := SYSTEM.VAL(TglVertexAttrib2fARB, GetProcAddress('glVertexAttrib2fARB'));
	VertexAttrib2fvARB := SYSTEM.VAL(TglVertexAttrib2fvARB, GetProcAddress('glVertexAttrib2fvARB'));
	VertexAttrib2sARB := SYSTEM.VAL(TglVertexAttrib2sARB, GetProcAddress('glVertexAttrib2sARB'));
	VertexAttrib2svARB := SYSTEM.VAL(TglVertexAttrib2svARB, GetProcAddress('glVertexAttrib2svARB'));
	VertexAttrib3dARB := SYSTEM.VAL(TglVertexAttrib3dARB, GetProcAddress('glVertexAttrib3dARB'));
	VertexAttrib3dvARB := SYSTEM.VAL(TglVertexAttrib3dvARB, GetProcAddress('glVertexAttrib3dvARB'));
	VertexAttrib3fARB := SYSTEM.VAL(TglVertexAttrib3fARB, GetProcAddress('glVertexAttrib3fARB'));
	VertexAttrib3fvARB := SYSTEM.VAL(TglVertexAttrib3fvARB, GetProcAddress('glVertexAttrib3fvARB'));
	VertexAttrib3sARB := SYSTEM.VAL(TglVertexAttrib3sARB, GetProcAddress('glVertexAttrib3sARB'));
	VertexAttrib3svARB := SYSTEM.VAL(TglVertexAttrib3svARB, GetProcAddress('glVertexAttrib3svARB'));
	VertexAttrib4NbvARB := SYSTEM.VAL(TglVertexAttrib4NbvARB, GetProcAddress('glVertexAttrib4NbvARB'));
	VertexAttrib4NivARB := SYSTEM.VAL(TglVertexAttrib4NivARB, GetProcAddress('glVertexAttrib4NivARB'));
	VertexAttrib4NsvARB := SYSTEM.VAL(TglVertexAttrib4NsvARB, GetProcAddress('glVertexAttrib4NsvARB'));
	VertexAttrib4NubARB := SYSTEM.VAL(TglVertexAttrib4NubARB, GetProcAddress('glVertexAttrib4NubARB'));
	VertexAttrib4NubvARB := SYSTEM.VAL(TglVertexAttrib4NubvARB, GetProcAddress('glVertexAttrib4NubvARB'));
	VertexAttrib4NuivARB := SYSTEM.VAL(TglVertexAttrib4NuivARB, GetProcAddress('glVertexAttrib4NuivARB'));
	VertexAttrib4NusvARB := SYSTEM.VAL(TglVertexAttrib4NusvARB, GetProcAddress('glVertexAttrib4NusvARB'));
	VertexAttrib4bvARB := SYSTEM.VAL(TglVertexAttrib4bvARB, GetProcAddress('glVertexAttrib4bvARB'));
	VertexAttrib4dARB := SYSTEM.VAL(TglVertexAttrib4dARB, GetProcAddress('glVertexAttrib4dARB'));
	VertexAttrib4dvARB := SYSTEM.VAL(TglVertexAttrib4dvARB, GetProcAddress('glVertexAttrib4dvARB'));
	VertexAttrib4fARB := SYSTEM.VAL(TglVertexAttrib4fARB, GetProcAddress('glVertexAttrib4fARB'));
	VertexAttrib4fvARB := SYSTEM.VAL(TglVertexAttrib4fvARB, GetProcAddress('glVertexAttrib4fvARB'));
	VertexAttrib4ivARB := SYSTEM.VAL(TglVertexAttrib4ivARB, GetProcAddress('glVertexAttrib4ivARB'));
	VertexAttrib4sARB := SYSTEM.VAL(TglVertexAttrib4sARB, GetProcAddress('glVertexAttrib4sARB'));
	VertexAttrib4svARB := SYSTEM.VAL(TglVertexAttrib4svARB, GetProcAddress('glVertexAttrib4svARB'));
	VertexAttrib4ubvARB := SYSTEM.VAL(TglVertexAttrib4ubvARB, GetProcAddress('glVertexAttrib4ubvARB'));
	VertexAttrib4uivARB := SYSTEM.VAL(TglVertexAttrib4uivARB, GetProcAddress('glVertexAttrib4uivARB'));
	VertexAttrib4usvARB := SYSTEM.VAL(TglVertexAttrib4usvARB, GetProcAddress('glVertexAttrib4usvARB'));
	VertexAttribPointerARB := SYSTEM.VAL(TglVertexAttribPointerARB, GetProcAddress('glVertexAttribPointerARB'));
	EnableVertexAttribArrayARB := SYSTEM.VAL(TglEnableVertexAttribArrayARB, GetProcAddress('glEnableVertexAttribArrayARB'));
	DisableVertexAttribArrayARB := SYSTEM.VAL(TglDisableVertexAttribArrayARB, GetProcAddress('glDisableVertexAttribArrayARB'));
	ProgramStringARB := SYSTEM.VAL(TglProgramStringARB, GetProcAddress('glProgramStringARB'));
	BindProgramARB := SYSTEM.VAL(TglBindProgramARB, GetProcAddress('glBindProgramARB'));
	DeleteProgramsARB := SYSTEM.VAL(TglDeleteProgramsARB, GetProcAddress('glDeleteProgramsARB'));
	GenProgramsARB := SYSTEM.VAL(TglGenProgramsARB, GetProcAddress('glGenProgramsARB'));
	ProgramEnvParameter4dARB := SYSTEM.VAL(TglProgramEnvParameter4dARB, GetProcAddress('glProgramEnvParameter4dARB'));
	ProgramEnvParameter4dvARB := SYSTEM.VAL(TglProgramEnvParameter4dvARB, GetProcAddress('glProgramEnvParameter4dvARB'));
	ProgramEnvParameter4fARB := SYSTEM.VAL(TglProgramEnvParameter4fARB, GetProcAddress('glProgramEnvParameter4fARB'));
	ProgramEnvParameter4fvARB := SYSTEM.VAL(TglProgramEnvParameter4fvARB, GetProcAddress('glProgramEnvParameter4fvARB'));
	ProgramLocalParameter4dARB := SYSTEM.VAL(TglProgramLocalParameter4dARB, GetProcAddress('glProgramLocalParameter4dARB'));
	ProgramLocalParameter4dvARB := SYSTEM.VAL(TglProgramLocalParameter4dvARB, GetProcAddress('glProgramLocalParameter4dvARB'));
	ProgramLocalParameter4fARB := SYSTEM.VAL(TglProgramLocalParameter4fARB, GetProcAddress('glProgramLocalParameter4fARB'));
	ProgramLocalParameter4fvARB := SYSTEM.VAL(TglProgramLocalParameter4fvARB, GetProcAddress('glProgramLocalParameter4fvARB'));
	GetProgramEnvParameterdvARB := SYSTEM.VAL(TglGetProgramEnvParameterdvARB, GetProcAddress('glGetProgramEnvParameterdvARB'));
	GetProgramEnvParameterfvARB := SYSTEM.VAL(TglGetProgramEnvParameterfvARB, GetProcAddress('glGetProgramEnvParameterfvARB'));
	GetProgramLocalParameterdvARB := SYSTEM.VAL(TglGetProgramLocalParameterdvARB, GetProcAddress('glGetProgramLocalParameterdvARB'));
	GetProgramLocalParameterfvARB := SYSTEM.VAL(TglGetProgramLocalParameterfvARB, GetProcAddress('glGetProgramLocalParameterfvARB'));
	GetProgramivARB := SYSTEM.VAL(TglGetProgramivARB, GetProcAddress('glGetProgramivARB'));
	GetProgramStringARB := SYSTEM.VAL(TglGetProgramStringARB, GetProcAddress('glGetProgramStringARB'));
	GetVertexAttribdvARB := SYSTEM.VAL(TglGetVertexAttribdvARB, GetProcAddress('glGetVertexAttribdvARB'));
	GetVertexAttribfvARB := SYSTEM.VAL(TglGetVertexAttribfvARB, GetProcAddress('glGetVertexAttribfvARB'));
	GetVertexAttribivARB := SYSTEM.VAL(TglGetVertexAttribivARB, GetProcAddress('glGetVertexAttribivARB'));
	GetVertexAttribPointervARB := SYSTEM.VAL(TglGetVertexAttribPointervARB, GetProcAddress('glGetVertexAttribPointervARB'));
	IsProgramARB := SYSTEM.VAL(TglIsProgramARB, GetProcAddress('glIsProgramARB'));
END Read_GL_ARB_vertex_program;

PROCEDURE Read_GL_ARB_window_pos*;
BEGIN
	WindowPos2dARB := SYSTEM.VAL(TglWindowPos2dARB, GetProcAddress('glWindowPos2dARB'));
	WindowPos2dvARB := SYSTEM.VAL(TglWindowPos2dvARB, GetProcAddress('glWindowPos2dvARB'));
	WindowPos2fARB := SYSTEM.VAL(TglWindowPos2fARB, GetProcAddress('glWindowPos2fARB'));
	WindowPos2fvARB := SYSTEM.VAL(TglWindowPos2fvARB, GetProcAddress('glWindowPos2fvARB'));
	WindowPos2iARB := SYSTEM.VAL(TglWindowPos2iARB, GetProcAddress('glWindowPos2iARB'));
	WindowPos2ivARB := SYSTEM.VAL(TglWindowPos2ivARB, GetProcAddress('glWindowPos2ivARB'));
	WindowPos2sARB := SYSTEM.VAL(TglWindowPos2sARB, GetProcAddress('glWindowPos2sARB'));
	WindowPos2svARB := SYSTEM.VAL(TglWindowPos2svARB, GetProcAddress('glWindowPos2svARB'));
	WindowPos3dARB := SYSTEM.VAL(TglWindowPos3dARB, GetProcAddress('glWindowPos3dARB'));
	WindowPos3dvARB := SYSTEM.VAL(TglWindowPos3dvARB, GetProcAddress('glWindowPos3dvARB'));
	WindowPos3fARB := SYSTEM.VAL(TglWindowPos3fARB, GetProcAddress('glWindowPos3fARB'));
	WindowPos3fvARB := SYSTEM.VAL(TglWindowPos3fvARB, GetProcAddress('glWindowPos3fvARB'));
	WindowPos3iARB := SYSTEM.VAL(TglWindowPos3iARB, GetProcAddress('glWindowPos3iARB'));
	WindowPos3ivARB := SYSTEM.VAL(TglWindowPos3ivARB, GetProcAddress('glWindowPos3ivARB'));
	WindowPos3sARB := SYSTEM.VAL(TglWindowPos3sARB, GetProcAddress('glWindowPos3sARB'));
	WindowPos3svARB := SYSTEM.VAL(TglWindowPos3svARB, GetProcAddress('glWindowPos3svARB'));
END Read_GL_ARB_window_pos;

PROCEDURE Read_GL_ARB_draw_buffers*;
BEGIN
	DrawBuffersARB := SYSTEM.VAL(TglDrawBuffersARB, GetProcAddress('glDrawBuffersARB'));
END Read_GL_ARB_draw_buffers;

PROCEDURE Read_GL_ARB_color_buffer_float*;
BEGIN
	ClampColorARB := SYSTEM.VAL(TglClampColorARB, GetProcAddress('glClampColorARB'));
END Read_GL_ARB_color_buffer_float;

PROCEDURE Read_GL_ARB_Shader_Objects*;
BEGIN
	(*  GL_ARB_Shader_Objects  *)
	CreateShaderObjectARB := SYSTEM.VAL(TglCreateShaderObjectARB, GetProcAddress('glCreateShaderObjectARB'));
	ShaderSourceARB := SYSTEM.VAL(TglShaderSourceARB, GetProcAddress('glShaderSourceARB'));
	CompileShaderARB := SYSTEM.VAL(TglCompileShaderARB, GetProcAddress('glCompileShaderARB'));
	DeleteObjectARB := SYSTEM.VAL(TglDeleteObjectARB, GetProcAddress('glDeleteObjectARB'));
	GetHandleARB := SYSTEM.VAL(TglGetHandleARB, GetProcAddress('glGetHandleARB'));
	DetachObjectARB := SYSTEM.VAL(TglDetachObjectARB, GetProcAddress('glDetachObjectARB'));
	CreateProgramObjectARB := SYSTEM.VAL(TglCreateProgramObjectARB, GetProcAddress('glCreateProgramObjectARB'));
	AttachObjectARB := SYSTEM.VAL(TglAttachObjectARB, GetProcAddress('glAttachObjectARB'));
	LinkProgramARB := SYSTEM.VAL(TglLinkProgramARB, GetProcAddress('glLinkProgramARB'));
	UseProgramObjectARB := SYSTEM.VAL(TglUseProgramObjectARB, GetProcAddress('glUseProgramObjectARB'));
	ValidateProgramARB := SYSTEM.VAL(TglValidateProgramARB, GetProcAddress('glValidateProgramARB'));
	GetObjectParameterfvARB := SYSTEM.VAL(TglGetObjectParameterfvARB, GetProcAddress('glGetObjectParameterfvARB'));
	GetObjectParameterivARB := SYSTEM.VAL(TglGetObjectParameterivARB, GetProcAddress('glGetObjectParameterivARB'));
	GetActiveUniformARB := SYSTEM.VAL(TglGetActiveUniformARB, GetProcAddress('glGetActiveUniformARB'));
	GetAttachedObjectsARB := SYSTEM.VAL(TglGetAttachedObjectsARB, GetProcAddress('glGetAttachedObjectsARB'));
	GetShaderSourceARB := SYSTEM.VAL(TglGetShaderSourceARB, GetProcAddress('glGetShaderSourceARB'));
	GetUniformfvARB := SYSTEM.VAL(TglGetUniformfvARB, GetProcAddress('glGetUniformfvARB'));
	GetUniformivARB := SYSTEM.VAL(TglGetUniformivARB, GetProcAddress('glGetUniformivARB'));
	XglGetUniformLocationARB := SYSTEM.VAL(TglGetUniformLocationARB, GetProcAddress('glGetUniformLocationARB'));
	GetInfoLogARB := SYSTEM.VAL(TglGetInfoLogARB, GetProcAddress('glGetInfoLogARB'));
	Uniform1fARB := SYSTEM.VAL(TglUniform1fARB, GetProcAddress('glUniform1fARB'));
	Uniform2fARB := SYSTEM.VAL(TglUniform2fARB, GetProcAddress('glUniform2fARB'));
	Uniform3fARB := SYSTEM.VAL(TglUniform3fARB, GetProcAddress('glUniform3fARB'));
	Uniform4fARB := SYSTEM.VAL(TglUniform4fARB, GetProcAddress('glUniform4fARB'));
	Uniform1iARB := SYSTEM.VAL(TglUniform1iARB, GetProcAddress('glUniform1iARB'));
	Uniform2iARB := SYSTEM.VAL(TglUniform2iARB, GetProcAddress('glUniform2iARB'));
	Uniform3iARB := SYSTEM.VAL(TglUniform3iARB, GetProcAddress('glUniform3iARB'));
	Uniform4iARB := SYSTEM.VAL(TglUniform4iARB, GetProcAddress('glUniform4iARB'));
	Uniform1fvARB := SYSTEM.VAL(TglUniform1fvARB, GetProcAddress('glUniform1fvARB'));
	Uniform2fvARB := SYSTEM.VAL(TglUniform2fvARB, GetProcAddress('glUniform2fvARB'));
	Uniform3fvARB := SYSTEM.VAL(TglUniform3fvARB, GetProcAddress('glUniform3fvARB'));
	Uniform4fvARB := SYSTEM.VAL(TglUniform4fvARB, GetProcAddress('glUniform4fvARB'));
	Uniform1ivARB := SYSTEM.VAL(TglUniform1ivARB, GetProcAddress('glUniform1ivARB'));
	Uniform2ivARB := SYSTEM.VAL(TglUniform2ivARB, GetProcAddress('glUniform2ivARB'));
	Uniform3ivARB := SYSTEM.VAL(TglUniform3ivARB, GetProcAddress('glUniform3ivARB'));
	Uniform4ivARB := SYSTEM.VAL(TglUniform4ivARB, GetProcAddress('glUniform4ivARB'));
	UniformMatrix2fvARB := SYSTEM.VAL(TglUniformMatrix2fvARB, GetProcAddress('glUniformMatrix2fvARB'));
	UniformMatrix3fvARB := SYSTEM.VAL(TglUniformMatrix3fvARB, GetProcAddress('glUniformMatrix3fvARB'));
	UniformMatrix4fvARB := SYSTEM.VAL(TglUniformMatrix4fvARB, GetProcAddress('glUniformMatrix4fvARB'));
	(* GL_ARB_vertex_shader  *)
	GetActiveAttribARB := SYSTEM.VAL(TglGetActiveAttribARB, GetProcAddress('glGetActiveAttribARB'));
	XglGetAttribLocationARB := SYSTEM.VAL(TglGetAttribLocationARB, GetProcAddress('glGetAttribLocationARB'));
	XglBindAttribLocationARB := SYSTEM.VAL(TglBindAttribLocationARB, GetProcAddress('glBindAttribLocationARB'));
	GetVertexAttribPointervARB := SYSTEM.VAL(TglGetVertexAttribPointervARB, GetProcAddress('glGetVertexAttribPointervARB'));
END Read_GL_ARB_Shader_Objects;

PROCEDURE Read_GL_ARB_occlusion_query*;
BEGIN
	GenQueriesARB := SYSTEM.VAL(TglGenQueriesARB, GetProcAddress('glGenQueriesARB'));
	DeleteQueriesARB := SYSTEM.VAL(TglDeleteQueriesARB, GetProcAddress('glDeleteQueriesARB'));
	IsQueryARB := SYSTEM.VAL(TglIsQueryARB, GetProcAddress('glIsQueryARB'));
	BeginQueryARB := SYSTEM.VAL(TglBeginQueryARB, GetProcAddress('glBeginQueryARB'));
	EndQueryARB := SYSTEM.VAL(TglEndQueryARB, GetProcAddress('glEndQueryARB'));
	GetQueryivARB := SYSTEM.VAL(TglGetQueryivARB, GetProcAddress('glGetQueryivARB'));
	GetQueryObjectivARB := SYSTEM.VAL(TglGetQueryObjectivARB, GetProcAddress('glGetQueryObjectivARB'));
	GetQueryObjectuivARB := SYSTEM.VAL(TglGetQueryObjectuivARB, GetProcAddress('glGetQueryObjectuivARB'));
END Read_GL_ARB_occlusion_query;

PROCEDURE Read_GL_ARB_draw_instanced*;
BEGIN
	DrawArraysInstancedARB := SYSTEM.VAL(TglDrawArraysInstancedARB, GetProcAddress('glDrawArraysInstancedARB'));
	DrawElementsInstancedARB := SYSTEM.VAL(TglDrawElementsInstancedARB, GetProcAddress('glDrawElementsInstancedARB'));
END Read_GL_ARB_draw_instanced;

PROCEDURE Read_GL_ARB_framebuffer_object*;
BEGIN
	IsRenderbuffer := SYSTEM.VAL(TglIsRenderbuffer, GetProcAddress('glIsRenderbuffer'));
	BindRenderbuffer := SYSTEM.VAL(TglBindRenderbuffer, GetProcAddress('glBindRenderbuffer'));
	DeleteRenderbuffers := SYSTEM.VAL(TglDeleteRenderbuffers, GetProcAddress('glDeleteRenderbuffers'));
	GenRenderbuffers := SYSTEM.VAL(TglGenRenderbuffers, GetProcAddress('glGenRenderbuffers'));
	RenderbufferStorage := SYSTEM.VAL(TglRenderbufferStorage, GetProcAddress('glRenderbufferStorage'));
	GetRenderbufferParameteriv := SYSTEM.VAL(TglGetRenderbufferParameteriv, GetProcAddress('glGetRenderbufferParameteriv'));
	IsFramebuffer := SYSTEM.VAL(TglIsFramebuffer, GetProcAddress('glIsFramebuffer'));
	BindFramebuffer := SYSTEM.VAL(TglBindFramebuffer, GetProcAddress('glBindFramebuffer'));
	DeleteFramebuffers := SYSTEM.VAL(TglDeleteFramebuffers, GetProcAddress('glDeleteFramebuffers'));
	GenFramebuffers := SYSTEM.VAL(TglGenFramebuffers, GetProcAddress('glGenFramebuffers'));
	CheckFramebufferStatus := SYSTEM.VAL(TglCheckFramebufferStatus, GetProcAddress('glCheckFramebufferStatus'));
	FramebufferTexture1D := SYSTEM.VAL(TglFramebufferTexture1D, GetProcAddress('glFramebufferTexture1D'));
	FramebufferTexture2D := SYSTEM.VAL(TglFramebufferTexture2D, GetProcAddress('glFramebufferTexture2D'));
	FramebufferTexture3D := SYSTEM.VAL(TglFramebufferTexture3D, GetProcAddress('glFramebufferTexture3D'));
	FramebufferRenderbuffer := SYSTEM.VAL(TglFramebufferRenderbuffer, GetProcAddress('glFramebufferRenderbuffer'));
	GetFramebufferAttachmentParameteriv := SYSTEM.VAL(TglGetFramebufferAttachmentParameteriv, GetProcAddress('glGetFramebufferAttachmentParameteriv'));
	GenerateMipmap := SYSTEM.VAL(TglGenerateMipmap, GetProcAddress('glGenerateMipmap'));
	BlitFramebuffer := SYSTEM.VAL(TglBlitFramebuffer, GetProcAddress('glBlitFramebuffer'));
	RenderbufferStorageMultisample := SYSTEM.VAL(TglRenderbufferStorageMultisample, GetProcAddress('glRenderbufferStorageMultisample'));
	FramebufferTextureLayer := SYSTEM.VAL(TglFramebufferTextureLayer, GetProcAddress('glFramebufferTextureLayer'));
END Read_GL_ARB_framebuffer_object;

PROCEDURE Read_GL_ARB_geometry_shader4*;
BEGIN
	ProgramParameteriARB := SYSTEM.VAL(TglProgramParameteriARB, GetProcAddress('glProgramParameteriARB'));
	FramebufferTextureARB := SYSTEM.VAL(TglFramebufferTextureARB, GetProcAddress('glFramebufferTextureARB'));
	FramebufferTextureLayerARB := SYSTEM.VAL(TglFramebufferTextureLayerARB, GetProcAddress('glFramebufferTextureLayerARB'));
	FramebufferTextureFaceARB := SYSTEM.VAL(TglFramebufferTextureFaceARB, GetProcAddress('glFramebufferTextureFaceARB'));
END Read_GL_ARB_geometry_shader4;

PROCEDURE Read_GL_ARB_instanced_arrays*;
BEGIN
	VertexAttribDivisorARB := SYSTEM.VAL(TglVertexAttribDivisorARB, GetProcAddress('glVertexAttribDivisorARB'));
END Read_GL_ARB_instanced_arrays;

PROCEDURE Read_GL_ARB_map_buffer_range*;
BEGIN
	MapBufferRange := SYSTEM.VAL(TglMapBufferRange, GetProcAddress('glMapBufferRange'));
	FlushMappedBufferRange := SYSTEM.VAL(TglFlushMappedBufferRange, GetProcAddress('glFlushMappedBufferRange'));
END Read_GL_ARB_map_buffer_range;

PROCEDURE Read_GL_ARB_texture_buffer_object*;
BEGIN
	TexBufferARB := SYSTEM.VAL(TglTexBufferARB, GetProcAddress('glTexBufferARB'));
END Read_GL_ARB_texture_buffer_object;

PROCEDURE Read_GL_ARB_vertex_array_object*;
BEGIN
	BindVertexArray := SYSTEM.VAL(TglBindVertexArray, GetProcAddress('glBindVertexArray'));
	DeleteVertexArrays := SYSTEM.VAL(TglDeleteVertexArrays, GetProcAddress('glDeleteVertexArrays'));
	GenVertexArrays := SYSTEM.VAL(TglGenVertexArrays, GetProcAddress('glGenVertexArrays'));
	IsVertexArray := SYSTEM.VAL(TglIsVertexArray, GetProcAddress('glIsVertexArray'));
END Read_GL_ARB_vertex_array_object;

PROCEDURE Read_GL_ARB_uniform_buffer_object*;
BEGIN
	GetUniformIndices := SYSTEM.VAL(TglGetUniformIndices, GetProcAddress('glGetUniformIndices'));
	GetActiveUniformsiv := SYSTEM.VAL(TglGetActiveUniformsiv, GetProcAddress('glGetActiveUniformsiv'));
	GetActiveUniformName := SYSTEM.VAL(TglGetActiveUniformName, GetProcAddress('glGetActiveUniformName'));
	XglGetUniformBlockIndex := SYSTEM.VAL(TglGetUniformBlockIndex, GetProcAddress('glGetUniformBlockIndex'));
	GetActiveUniformBlockiv := SYSTEM.VAL(TglGetActiveUniformBlockiv, GetProcAddress('glGetActiveUniformBlockiv'));
	GetActiveUniformBlockName := SYSTEM.VAL(TglGetActiveUniformBlockName, GetProcAddress('glGetActiveUniformBlockName'));
	UniformBlockBinding := SYSTEM.VAL(TglUniformBlockBinding, GetProcAddress('glUniformBlockBinding'));
END Read_GL_ARB_uniform_buffer_object;

PROCEDURE Read_GL_ARB_copy_buffer*;
BEGIN
	CopyBufferSubData := SYSTEM.VAL(TglCopyBufferSubData, GetProcAddress('glCopyBufferSubData'));
END Read_GL_ARB_copy_buffer;

PROCEDURE Read_GL_ARB_draw_elements_base_vertex*;
BEGIN
	DrawElementsBaseVertex := SYSTEM.VAL(TglDrawElementsBaseVertex, GetProcAddress('glDrawElementsBaseVertex'));
	DrawRangeElementsBaseVertex := SYSTEM.VAL(TglDrawRangeElementsBaseVertex, GetProcAddress('glDrawRangeElementsBaseVertex'));
	DrawElementsInstancedBaseVertex := SYSTEM.VAL(TglDrawElementsInstancedBaseVertex, GetProcAddress('glDrawElementsInstancedBaseVertex'));
	MultiDrawElementsBaseVertex := SYSTEM.VAL(TglMultiDrawElementsBaseVertex, GetProcAddress('glMultiDrawElementsBaseVertex'));
END Read_GL_ARB_draw_elements_base_vertex;

PROCEDURE Read_GL_ARB_provoking_vertex*;
BEGIN
	ProvokingVertex := SYSTEM.VAL(TglProvokingVertex, GetProcAddress('glProvokingVertex'));
END Read_GL_ARB_provoking_vertex;

PROCEDURE Read_GL_ARB_sync*;
BEGIN
	FenceSync := SYSTEM.VAL(TglFenceSync, GetProcAddress('glFenceSync'));
	IsSync := SYSTEM.VAL(TglIsSync, GetProcAddress('glIsSync'));
	DeleteSync := SYSTEM.VAL(TglDeleteSync, GetProcAddress('glDeleteSync'));
	ClientWaitSync := SYSTEM.VAL(TglClientWaitSync, GetProcAddress('glClientWaitSync'));
	WaitSync := SYSTEM.VAL(TglWaitSync, GetProcAddress('glWaitSync'));
	GetInteger64v := SYSTEM.VAL(TglGetInteger64v, GetProcAddress('glGetInteger64v'));
	GetSynciv := SYSTEM.VAL(TglGetSynciv, GetProcAddress('glGetSynciv'));
END Read_GL_ARB_sync;

PROCEDURE Read_GL_ARB_texture_multisample*;
BEGIN
	TexImage2DMultisample := SYSTEM.VAL(TglTexImage2DMultisample, GetProcAddress('glTexImage2DMultisample'));
	TexImage3DMultisample := SYSTEM.VAL(TglTexImage3DMultisample, GetProcAddress('glTexImage3DMultisample'));
	GetMultisamplefv := SYSTEM.VAL(TglGetMultisamplefv, GetProcAddress('glGetMultisamplefv'));
	SampleMaski := SYSTEM.VAL(TglSampleMaski, GetProcAddress('glSampleMaski'));
END Read_GL_ARB_texture_multisample;

PROCEDURE Read_GL_ARB_draw_buffers_blend*;
BEGIN
	BlendEquationiARB := SYSTEM.VAL(TglBlendEquationiARB, GetProcAddress('glBlendEquationiARB'));
	BlendEquationSeparateiARB := SYSTEM.VAL(TglBlendEquationSeparateiARB, GetProcAddress('glBlendEquationSeparateiARB'));
	BlendFunciARB := SYSTEM.VAL(TglBlendFunciARB, GetProcAddress('glBlendFunciARB'));
	BlendFuncSeparateiARB := SYSTEM.VAL(TglBlendFuncSeparateiARB, GetProcAddress('glBlendFuncSeparateiARB'));
END Read_GL_ARB_draw_buffers_blend;

PROCEDURE Read_GL_ARB_sample_shading*;
BEGIN
	MinSampleShadingARB := SYSTEM.VAL(TglMinSampleShadingARB, GetProcAddress('glMinSampleShadingARB'));
END Read_GL_ARB_sample_shading;

PROCEDURE Read_GL_ARB_shading_language_include*;
BEGIN
	XglNamedStringARB := SYSTEM.VAL(TglNamedStringARB, GetProcAddress('glNamedStringARB'));
	XglDeleteNamedStringARB := SYSTEM.VAL(TglDeleteNamedStringARB, GetProcAddress('glDeleteNamedStringARB'));
	CompileShaderIncludeARB := SYSTEM.VAL(TglCompileShaderIncludeARB, GetProcAddress('glCompileShaderIncludeARB'));
	XglIsNamedStringARB := SYSTEM.VAL(TglIsNamedStringARB, GetProcAddress('glIsNamedStringARB'));
	XglGetNamedStringARB := SYSTEM.VAL(TglGetNamedStringARB, GetProcAddress('glGetNamedStringARB'));
	XglGetNamedStringivARB := SYSTEM.VAL(TglGetNamedStringivARB, GetProcAddress('glGetNamedStringivARB'));
END Read_GL_ARB_shading_language_include;

PROCEDURE Read_GL_ARB_blend_func_extended*;
BEGIN
	XglBindFragDataLocationIndexed := SYSTEM.VAL(TglBindFragDataLocationIndexed, GetProcAddress('glBindFragDataLocationIndexed'));
	XglGetFragDataIndex := SYSTEM.VAL(TglGetFragDataIndex, GetProcAddress('glGetFragDataIndex'));
END Read_GL_ARB_blend_func_extended;

PROCEDURE Read_GL_ARB_sampler_objects*;
BEGIN
	GenSamplers := SYSTEM.VAL(TglGenSamplers, GetProcAddress('glGenSamplers'));
	DeleteSamplers := SYSTEM.VAL(TglDeleteSamplers, GetProcAddress('glDeleteSamplers'));
	IsSampler := SYSTEM.VAL(TglIsSampler, GetProcAddress('glIsSampler'));
	BindSampler := SYSTEM.VAL(TglBindSampler, GetProcAddress('glBindSampler'));
	SamplerParameteri := SYSTEM.VAL(TglSamplerParameteri, GetProcAddress('glSamplerParameteri'));
	SamplerParameteriv := SYSTEM.VAL(TglSamplerParameteriv, GetProcAddress('glSamplerParameteriv'));
	SamplerParameterf := SYSTEM.VAL(TglSamplerParameterf, GetProcAddress('glSamplerParameterf'));
	SamplerParameterfv := SYSTEM.VAL(TglSamplerParameterfv, GetProcAddress('glSamplerParameterfv'));
	SamplerParameterIiv := SYSTEM.VAL(TglSamplerParameterIiv, GetProcAddress('glSamplerParameterIiv'));
	SamplerParameterIuiv := SYSTEM.VAL(TglSamplerParameterIuiv, GetProcAddress('glSamplerParameterIuiv'));
	GetSamplerParameteriv := SYSTEM.VAL(TglGetSamplerParameteriv, GetProcAddress('glGetSamplerParameteriv'));
	GetSamplerParameterIiv := SYSTEM.VAL(TglGetSamplerParameterIiv, GetProcAddress('glGetSamplerParameterIiv'));
	GetSamplerParameterfv := SYSTEM.VAL(TglGetSamplerParameterfv, GetProcAddress('glGetSamplerParameterfv'));
	GetSamplerParameterIuiv := SYSTEM.VAL(TglGetSamplerParameterIuiv, GetProcAddress('glGetSamplerParameterIuiv'));
END Read_GL_ARB_sampler_objects;

PROCEDURE Read_GL_ARB_timer_query*;
BEGIN
	QueryCounter := SYSTEM.VAL(TglQueryCounter, GetProcAddress('glQueryCounter'));
	GetQueryObjecti64v := SYSTEM.VAL(TglGetQueryObjecti64v, GetProcAddress('glGetQueryObjecti64v'));
	GetQueryObjectui64v := SYSTEM.VAL(TglGetQueryObjectui64v, GetProcAddress('glGetQueryObjectui64v'));
END Read_GL_ARB_timer_query;

PROCEDURE Read_GL_ARB_vertex_type_2_10_10_10_rev*;
BEGIN
	VertexP2ui := SYSTEM.VAL(TglVertexP2ui, GetProcAddress('glVertexP2ui'));
	VertexP2uiv := SYSTEM.VAL(TglVertexP2uiv, GetProcAddress('glVertexP2uiv'));
	VertexP3ui := SYSTEM.VAL(TglVertexP3ui, GetProcAddress('glVertexP3ui'));
	VertexP3uiv := SYSTEM.VAL(TglVertexP3uiv, GetProcAddress('glVertexP3uiv'));
	VertexP4ui := SYSTEM.VAL(TglVertexP4ui, GetProcAddress('glVertexP4ui'));
	VertexP4uiv := SYSTEM.VAL(TglVertexP4uiv, GetProcAddress('glVertexP4uiv'));
	TexCoordP1ui := SYSTEM.VAL(TglTexCoordP1ui, GetProcAddress('glTexCoordP1ui'));
	TexCoordP1uiv := SYSTEM.VAL(TglTexCoordP1uiv, GetProcAddress('glTexCoordP1uiv'));
	TexCoordP2ui := SYSTEM.VAL(TglTexCoordP2ui, GetProcAddress('glTexCoordP2ui'));
	TexCoordP2uiv := SYSTEM.VAL(TglTexCoordP2uiv, GetProcAddress('glTexCoordP2uiv'));
	TexCoordP3ui := SYSTEM.VAL(TglTexCoordP3ui, GetProcAddress('glTexCoordP3ui'));
	TexCoordP3uiv := SYSTEM.VAL(TglTexCoordP3uiv, GetProcAddress('glTexCoordP3uiv'));
	TexCoordP4ui := SYSTEM.VAL(TglTexCoordP4ui, GetProcAddress('glTexCoordP4ui'));
	TexCoordP4uiv := SYSTEM.VAL(TglTexCoordP4uiv, GetProcAddress('glTexCoordP4uiv'));
	MultiTexCoordP1ui := SYSTEM.VAL(TglMultiTexCoordP1ui, GetProcAddress('glMultiTexCoordP1ui'));
	MultiTexCoordP1uiv := SYSTEM.VAL(TglMultiTexCoordP1uiv, GetProcAddress('glMultiTexCoordP1uiv'));
	MultiTexCoordP2ui := SYSTEM.VAL(TglMultiTexCoordP2ui, GetProcAddress('glMultiTexCoordP2ui'));
	MultiTexCoordP2uiv := SYSTEM.VAL(TglMultiTexCoordP2uiv, GetProcAddress('glMultiTexCoordP2uiv'));
	MultiTexCoordP3ui := SYSTEM.VAL(TglMultiTexCoordP3ui, GetProcAddress('glMultiTexCoordP3ui'));
	MultiTexCoordP3uiv := SYSTEM.VAL(TglMultiTexCoordP3uiv, GetProcAddress('glMultiTexCoordP3uiv'));
	MultiTexCoordP4ui := SYSTEM.VAL(TglMultiTexCoordP4ui, GetProcAddress('glMultiTexCoordP4ui'));
	MultiTexCoordP4uiv := SYSTEM.VAL(TglMultiTexCoordP4uiv, GetProcAddress('glMultiTexCoordP4uiv'));
	NormalP3ui := SYSTEM.VAL(TglNormalP3ui, GetProcAddress('glNormalP3ui'));
	NormalP3uiv := SYSTEM.VAL(TglNormalP3uiv, GetProcAddress('glNormalP3uiv'));
	ColorP3ui := SYSTEM.VAL(TglColorP3ui, GetProcAddress('glColorP3ui'));
	ColorP3uiv := SYSTEM.VAL(TglColorP3uiv, GetProcAddress('glColorP3uiv'));
	ColorP4ui := SYSTEM.VAL(TglColorP4ui, GetProcAddress('glColorP4ui'));
	ColorP4uiv := SYSTEM.VAL(TglColorP4uiv, GetProcAddress('glColorP4uiv'));
	SecondaryColorP3ui := SYSTEM.VAL(TglSecondaryColorP3ui, GetProcAddress('glSecondaryColorP3ui'));
	SecondaryColorP3uiv := SYSTEM.VAL(TglSecondaryColorP3uiv, GetProcAddress('glSecondaryColorP3uiv'));
	VertexAttribP1ui := SYSTEM.VAL(TglVertexAttribP1ui, GetProcAddress('glVertexAttribP1ui'));
	VertexAttribP1uiv := SYSTEM.VAL(TglVertexAttribP1uiv, GetProcAddress('glVertexAttribP1uiv'));
	VertexAttribP2ui := SYSTEM.VAL(TglVertexAttribP2ui, GetProcAddress('glVertexAttribP2ui'));
	VertexAttribP2uiv := SYSTEM.VAL(TglVertexAttribP2uiv, GetProcAddress('glVertexAttribP2uiv'));
	VertexAttribP3ui := SYSTEM.VAL(TglVertexAttribP3ui, GetProcAddress('glVertexAttribP3ui'));
	VertexAttribP3uiv := SYSTEM.VAL(TglVertexAttribP3uiv, GetProcAddress('glVertexAttribP3uiv'));
	VertexAttribP4ui := SYSTEM.VAL(TglVertexAttribP4ui, GetProcAddress('glVertexAttribP4ui'));
	VertexAttribP4uiv := SYSTEM.VAL(TglVertexAttribP4uiv, GetProcAddress('glVertexAttribP4uiv'));
END Read_GL_ARB_vertex_type_2_10_10_10_rev;

PROCEDURE Read_GL_ARB_draw_indirect*;
BEGIN
	DrawArraysIndirect := SYSTEM.VAL(TglDrawArraysIndirect, GetProcAddress('glDrawArraysIndirect'));
	DrawElementsIndirect := SYSTEM.VAL(TglDrawElementsIndirect, GetProcAddress('glDrawElementsIndirect'));
END Read_GL_ARB_draw_indirect;

PROCEDURE Read_GL_ARB_gpu_shader_fp64*;
BEGIN
	Uniform1d := SYSTEM.VAL(TglUniform1d, GetProcAddress('glUniform1d'));
	Uniform2d := SYSTEM.VAL(TglUniform2d, GetProcAddress('glUniform2d'));
	Uniform3d := SYSTEM.VAL(TglUniform3d, GetProcAddress('glUniform3d'));
	Uniform4d := SYSTEM.VAL(TglUniform4d, GetProcAddress('glUniform4d'));
	Uniform1dv := SYSTEM.VAL(TglUniform1dv, GetProcAddress('glUniform1dv'));
	Uniform2dv := SYSTEM.VAL(TglUniform2dv, GetProcAddress('glUniform2dv'));
	Uniform3dv := SYSTEM.VAL(TglUniform3dv, GetProcAddress('glUniform3dv'));
	Uniform4dv := SYSTEM.VAL(TglUniform4dv, GetProcAddress('glUniform4dv'));
	UniformMatrix2dv := SYSTEM.VAL(TglUniformMatrix2dv, GetProcAddress('glUniformMatrix2dv'));
	UniformMatrix3dv := SYSTEM.VAL(TglUniformMatrix3dv, GetProcAddress('glUniformMatrix3dv'));
	UniformMatrix4dv := SYSTEM.VAL(TglUniformMatrix4dv, GetProcAddress('glUniformMatrix4dv'));
	UniformMatrix2x3dv := SYSTEM.VAL(TglUniformMatrix2x3dv, GetProcAddress('glUniformMatrix2x3dv'));
	UniformMatrix2x4dv := SYSTEM.VAL(TglUniformMatrix2x4dv, GetProcAddress('glUniformMatrix2x4dv'));
	UniformMatrix3x2dv := SYSTEM.VAL(TglUniformMatrix3x2dv, GetProcAddress('glUniformMatrix3x2dv'));
	UniformMatrix3x4dv := SYSTEM.VAL(TglUniformMatrix3x4dv, GetProcAddress('glUniformMatrix3x4dv'));
	UniformMatrix4x2dv := SYSTEM.VAL(TglUniformMatrix4x2dv, GetProcAddress('glUniformMatrix4x2dv'));
	UniformMatrix4x3dv := SYSTEM.VAL(TglUniformMatrix4x3dv, GetProcAddress('glUniformMatrix4x3dv'));
	GetUniformdv := SYSTEM.VAL(TglGetUniformdv, GetProcAddress('glGetUniformdv'));
END Read_GL_ARB_gpu_shader_fp64;

PROCEDURE Read_GL_ARB_shader_subroutine*;
BEGIN
	XglGetSubroutineUniformLocation := SYSTEM.VAL(TglGetSubroutineUniformLocation, GetProcAddress('glGetSubroutineUniformLocation'));
	XglGetSubroutineIndex := SYSTEM.VAL(TglGetSubroutineIndex, GetProcAddress('glGetSubroutineIndex'));
	GetActiveSubroutineUniformiv := SYSTEM.VAL(TglGetActiveSubroutineUniformiv, GetProcAddress('glGetActiveSubroutineUniformiv'));
	GetActiveSubroutineUniformName := SYSTEM.VAL(TglGetActiveSubroutineUniformName, GetProcAddress('glGetActiveSubroutineUniformName'));
	GetActiveSubroutineName := SYSTEM.VAL(TglGetActiveSubroutineName, GetProcAddress('glGetActiveSubroutineName'));
	UniformSubroutinesuiv := SYSTEM.VAL(TglUniformSubroutinesuiv, GetProcAddress('glUniformSubroutinesuiv'));
	GetUniformSubroutineuiv := SYSTEM.VAL(TglGetUniformSubroutineuiv, GetProcAddress('glGetUniformSubroutineuiv'));
	GetProgramStageiv := SYSTEM.VAL(TglGetProgramStageiv, GetProcAddress('glGetProgramStageiv'));
END Read_GL_ARB_shader_subroutine;

PROCEDURE Read_GL_ARB_tessellation_shader*;
BEGIN
	PatchParameteri := SYSTEM.VAL(TglPatchParameteri, GetProcAddress('glPatchParameteri'));
	PatchParameterfv := SYSTEM.VAL(TglPatchParameterfv, GetProcAddress('glPatchParameterfv'));
END Read_GL_ARB_tessellation_shader;

PROCEDURE Read_GL_ARB_transform_feedback2*;
BEGIN
	BindTransformFeedback := SYSTEM.VAL(TglBindTransformFeedback, GetProcAddress('glBindTransformFeedback'));
	DeleteTransformFeedbacks := SYSTEM.VAL(TglDeleteTransformFeedbacks, GetProcAddress('glDeleteTransformFeedbacks'));
	GenTransformFeedbacks := SYSTEM.VAL(TglGenTransformFeedbacks, GetProcAddress('glGenTransformFeedbacks'));
	IsTransformFeedback := SYSTEM.VAL(TglIsTransformFeedback, GetProcAddress('glIsTransformFeedback'));
	PauseTransformFeedback := SYSTEM.VAL(TglPauseTransformFeedback, GetProcAddress('glPauseTransformFeedback'));
	ResumeTransformFeedback := SYSTEM.VAL(TglResumeTransformFeedback, GetProcAddress('glResumeTransformFeedback'));
	DrawTransformFeedback := SYSTEM.VAL(TglDrawTransformFeedback, GetProcAddress('glDrawTransformFeedback'));
END Read_GL_ARB_transform_feedback2;

PROCEDURE Read_GL_ARB_transform_feedback3*;
BEGIN
	DrawTransformFeedbackStream := SYSTEM.VAL(TglDrawTransformFeedbackStream, GetProcAddress('glDrawTransformFeedbackStream'));
	BeginQueryIndexed := SYSTEM.VAL(TglBeginQueryIndexed, GetProcAddress('glBeginQueryIndexed'));
	EndQueryIndexed := SYSTEM.VAL(TglEndQueryIndexed, GetProcAddress('glEndQueryIndexed'));
	GetQueryIndexediv := SYSTEM.VAL(TglGetQueryIndexediv, GetProcAddress('glGetQueryIndexediv'));
END Read_GL_ARB_transform_feedback3;

PROCEDURE Read_GL_ARB_ES2_compatibility*;
BEGIN
	ReleaseShaderCompiler := SYSTEM.VAL(TglReleaseShaderCompiler, GetProcAddress('glReleaseShaderCompiler'));
	ShaderBinary := SYSTEM.VAL(TglShaderBinary, GetProcAddress('glShaderBinary'));
	GetShaderPrecisionFormat := SYSTEM.VAL(TglGetShaderPrecisionFormat, GetProcAddress('glGetShaderPrecisionFormat'));
	DepthRangef := SYSTEM.VAL(TglDepthRangef, GetProcAddress('glDepthRangef'));
	ClearDepthf := SYSTEM.VAL(TglClearDepthf, GetProcAddress('glClearDepthf'));
END Read_GL_ARB_ES2_compatibility;

PROCEDURE Read_GL_ARB_get_program_binary*;
BEGIN
	GetProgramBinary := SYSTEM.VAL(TglGetProgramBinary, GetProcAddress('glGetProgramBinary'));
	ProgramBinary := SYSTEM.VAL(TglProgramBinary, GetProcAddress('glProgramBinary'));
	ProgramParameteri := SYSTEM.VAL(TglProgramParameteri, GetProcAddress('glProgramParameteri'));
END Read_GL_ARB_get_program_binary;

PROCEDURE Read_GL_ARB_separate_shader_objects*;
BEGIN
	UseProgramStages := SYSTEM.VAL(TglUseProgramStages, GetProcAddress('glUseProgramStages'));
	ActiveShaderProgram := SYSTEM.VAL(TglActiveShaderProgram, GetProcAddress('glActiveShaderProgram'));
	CreateShaderProgramv := SYSTEM.VAL(TglCreateShaderProgramv, GetProcAddress('glCreateShaderProgramv'));
	BindProgramPipeline := SYSTEM.VAL(TglBindProgramPipeline, GetProcAddress('glBindProgramPipeline'));
	DeleteProgramPipelines := SYSTEM.VAL(TglDeleteProgramPipelines, GetProcAddress('glDeleteProgramPipelines'));
	GenProgramPipelines := SYSTEM.VAL(TglGenProgramPipelines, GetProcAddress('glGenProgramPipelines'));
	IsProgramPipeline := SYSTEM.VAL(TglIsProgramPipeline, GetProcAddress('glIsProgramPipeline'));
	GetProgramPipelineiv := SYSTEM.VAL(TglGetProgramPipelineiv, GetProcAddress('glGetProgramPipelineiv'));
	ProgramUniform1i := SYSTEM.VAL(TglProgramUniform1i, GetProcAddress('glProgramUniform1i'));
	ProgramUniform1iv := SYSTEM.VAL(TglProgramUniform1iv, GetProcAddress('glProgramUniform1iv'));
	ProgramUniform1f := SYSTEM.VAL(TglProgramUniform1f, GetProcAddress('glProgramUniform1f'));
	ProgramUniform1fv := SYSTEM.VAL(TglProgramUniform1fv, GetProcAddress('glProgramUniform1fv'));
	ProgramUniform1d := SYSTEM.VAL(TglProgramUniform1d, GetProcAddress('glProgramUniform1d'));
	ProgramUniform1dv := SYSTEM.VAL(TglProgramUniform1dv, GetProcAddress('glProgramUniform1dv'));
	ProgramUniform1ui := SYSTEM.VAL(TglProgramUniform1ui, GetProcAddress('glProgramUniform1ui'));
	ProgramUniform1uiv := SYSTEM.VAL(TglProgramUniform1uiv, GetProcAddress('glProgramUniform1uiv'));
	ProgramUniform2i := SYSTEM.VAL(TglProgramUniform2i, GetProcAddress('glProgramUniform2i'));
	ProgramUniform2iv := SYSTEM.VAL(TglProgramUniform2iv, GetProcAddress('glProgramUniform2iv'));
	ProgramUniform2f := SYSTEM.VAL(TglProgramUniform2f, GetProcAddress('glProgramUniform2f'));
	ProgramUniform2fv := SYSTEM.VAL(TglProgramUniform2fv, GetProcAddress('glProgramUniform2fv'));
	ProgramUniform2d := SYSTEM.VAL(TglProgramUniform2d, GetProcAddress('glProgramUniform2d'));
	ProgramUniform2dv := SYSTEM.VAL(TglProgramUniform2dv, GetProcAddress('glProgramUniform2dv'));
	ProgramUniform2ui := SYSTEM.VAL(TglProgramUniform2ui, GetProcAddress('glProgramUniform2ui'));
	ProgramUniform2uiv := SYSTEM.VAL(TglProgramUniform2uiv, GetProcAddress('glProgramUniform2uiv'));
	ProgramUniform3i := SYSTEM.VAL(TglProgramUniform3i, GetProcAddress('glProgramUniform3i'));
	ProgramUniform3iv := SYSTEM.VAL(TglProgramUniform3iv, GetProcAddress('glProgramUniform3iv'));
	ProgramUniform3f := SYSTEM.VAL(TglProgramUniform3f, GetProcAddress('glProgramUniform3f'));
	ProgramUniform3fv := SYSTEM.VAL(TglProgramUniform3fv, GetProcAddress('glProgramUniform3fv'));
	ProgramUniform3d := SYSTEM.VAL(TglProgramUniform3d, GetProcAddress('glProgramUniform3d'));
	ProgramUniform3dv := SYSTEM.VAL(TglProgramUniform3dv, GetProcAddress('glProgramUniform3dv'));
	ProgramUniform3ui := SYSTEM.VAL(TglProgramUniform3ui, GetProcAddress('glProgramUniform3ui'));
	ProgramUniform3uiv := SYSTEM.VAL(TglProgramUniform3uiv, GetProcAddress('glProgramUniform3uiv'));
	ProgramUniform4i := SYSTEM.VAL(TglProgramUniform4i, GetProcAddress('glProgramUniform4i'));
	ProgramUniform4iv := SYSTEM.VAL(TglProgramUniform4iv, GetProcAddress('glProgramUniform4iv'));
	ProgramUniform4f := SYSTEM.VAL(TglProgramUniform4f, GetProcAddress('glProgramUniform4f'));
	ProgramUniform4fv := SYSTEM.VAL(TglProgramUniform4fv, GetProcAddress('glProgramUniform4fv'));
	ProgramUniform4d := SYSTEM.VAL(TglProgramUniform4d, GetProcAddress('glProgramUniform4d'));
	ProgramUniform4dv := SYSTEM.VAL(TglProgramUniform4dv, GetProcAddress('glProgramUniform4dv'));
	ProgramUniform4ui := SYSTEM.VAL(TglProgramUniform4ui, GetProcAddress('glProgramUniform4ui'));
	ProgramUniform4uiv := SYSTEM.VAL(TglProgramUniform4uiv, GetProcAddress('glProgramUniform4uiv'));
	ProgramUniformMatrix2fv := SYSTEM.VAL(TglProgramUniformMatrix2fv, GetProcAddress('glProgramUniformMatrix2fv'));
	ProgramUniformMatrix3fv := SYSTEM.VAL(TglProgramUniformMatrix3fv, GetProcAddress('glProgramUniformMatrix3fv'));
	ProgramUniformMatrix4fv := SYSTEM.VAL(TglProgramUniformMatrix4fv, GetProcAddress('glProgramUniformMatrix4fv'));
	ProgramUniformMatrix2dv := SYSTEM.VAL(TglProgramUniformMatrix2dv, GetProcAddress('glProgramUniformMatrix2dv'));
	ProgramUniformMatrix3dv := SYSTEM.VAL(TglProgramUniformMatrix3dv, GetProcAddress('glProgramUniformMatrix3dv'));
	ProgramUniformMatrix4dv := SYSTEM.VAL(TglProgramUniformMatrix4dv, GetProcAddress('glProgramUniformMatrix4dv'));
	ProgramUniformMatrix2x3fv := SYSTEM.VAL(TglProgramUniformMatrix2x3fv, GetProcAddress('glProgramUniformMatrix2x3fv'));
	ProgramUniformMatrix3x2fv := SYSTEM.VAL(TglProgramUniformMatrix3x2fv, GetProcAddress('glProgramUniformMatrix3x2fv'));
	ProgramUniformMatrix2x4fv := SYSTEM.VAL(TglProgramUniformMatrix2x4fv, GetProcAddress('glProgramUniformMatrix2x4fv'));
	ProgramUniformMatrix4x2fv := SYSTEM.VAL(TglProgramUniformMatrix4x2fv, GetProcAddress('glProgramUniformMatrix4x2fv'));
	ProgramUniformMatrix3x4fv := SYSTEM.VAL(TglProgramUniformMatrix3x4fv, GetProcAddress('glProgramUniformMatrix3x4fv'));
	ProgramUniformMatrix4x3fv := SYSTEM.VAL(TglProgramUniformMatrix4x3fv, GetProcAddress('glProgramUniformMatrix4x3fv'));
	ProgramUniformMatrix2x3dv := SYSTEM.VAL(TglProgramUniformMatrix2x3dv, GetProcAddress('glProgramUniformMatrix2x3dv'));
	ProgramUniformMatrix3x2dv := SYSTEM.VAL(TglProgramUniformMatrix3x2dv, GetProcAddress('glProgramUniformMatrix3x2dv'));
	ProgramUniformMatrix2x4dv := SYSTEM.VAL(TglProgramUniformMatrix2x4dv, GetProcAddress('glProgramUniformMatrix2x4dv'));
	ProgramUniformMatrix4x2dv := SYSTEM.VAL(TglProgramUniformMatrix4x2dv, GetProcAddress('glProgramUniformMatrix4x2dv'));
	ProgramUniformMatrix3x4dv := SYSTEM.VAL(TglProgramUniformMatrix3x4dv, GetProcAddress('glProgramUniformMatrix3x4dv'));
	ProgramUniformMatrix4x3dv := SYSTEM.VAL(TglProgramUniformMatrix4x3dv, GetProcAddress('glProgramUniformMatrix4x3dv'));
	ValidateProgramPipeline := SYSTEM.VAL(TglValidateProgramPipeline, GetProcAddress('glValidateProgramPipeline'));
	GetProgramPipelineInfoLog := SYSTEM.VAL(TglGetProgramPipelineInfoLog, GetProcAddress('glGetProgramPipelineInfoLog'));
END Read_GL_ARB_separate_shader_objects;

PROCEDURE Read_GL_ARB_vertex_attrib_64bit*;
BEGIN
	VertexAttribL1d := SYSTEM.VAL(TglVertexAttribL1d, GetProcAddress('glVertexAttribL1d'));
	VertexAttribL2d := SYSTEM.VAL(TglVertexAttribL2d, GetProcAddress('glVertexAttribL2d'));
	VertexAttribL3d := SYSTEM.VAL(TglVertexAttribL3d, GetProcAddress('glVertexAttribL3d'));
	VertexAttribL4d := SYSTEM.VAL(TglVertexAttribL4d, GetProcAddress('glVertexAttribL4d'));
	VertexAttribL1dv := SYSTEM.VAL(TglVertexAttribL1dv, GetProcAddress('glVertexAttribL1dv'));
	VertexAttribL2dv := SYSTEM.VAL(TglVertexAttribL2dv, GetProcAddress('glVertexAttribL2dv'));
	VertexAttribL3dv := SYSTEM.VAL(TglVertexAttribL3dv, GetProcAddress('glVertexAttribL3dv'));
	VertexAttribL4dv := SYSTEM.VAL(TglVertexAttribL4dv, GetProcAddress('glVertexAttribL4dv'));
	VertexAttribLPointer := SYSTEM.VAL(TglVertexAttribLPointer, GetProcAddress('glVertexAttribLPointer'));
	GetVertexAttribLdv := SYSTEM.VAL(TglGetVertexAttribLdv, GetProcAddress('glGetVertexAttribLdv'));
END Read_GL_ARB_vertex_attrib_64bit;

PROCEDURE Read_GL_ARB_viewport_array*;
BEGIN
	ViewportArrayv := SYSTEM.VAL(TglViewportArrayv, GetProcAddress('glViewportArrayv'));
	ViewportIndexedf := SYSTEM.VAL(TglViewportIndexedf, GetProcAddress('glViewportIndexedf'));
	ViewportIndexedfv := SYSTEM.VAL(TglViewportIndexedfv, GetProcAddress('glViewportIndexedfv'));
	ScissorArrayv := SYSTEM.VAL(TglScissorArrayv, GetProcAddress('glScissorArrayv'));
	ScissorIndexed := SYSTEM.VAL(TglScissorIndexed, GetProcAddress('glScissorIndexed'));
	ScissorIndexedv := SYSTEM.VAL(TglScissorIndexedv, GetProcAddress('glScissorIndexedv'));
	DepthRangeArrayv := SYSTEM.VAL(TglDepthRangeArrayv, GetProcAddress('glDepthRangeArrayv'));
	DepthRangeIndexed := SYSTEM.VAL(TglDepthRangeIndexed, GetProcAddress('glDepthRangeIndexed'));
	GetFloati_v := SYSTEM.VAL(TglGetFloati_v, GetProcAddress('glGetFloati_v'));
	GetDoublei_v := SYSTEM.VAL(TglGetDoublei_v, GetProcAddress('glGetDoublei_v'));
END Read_GL_ARB_viewport_array;

	(*! GL 4.2  *)
PROCEDURE Read_GL_ARB_base_instance*;
BEGIN
	DrawArraysInstancedBaseInstance := SYSTEM.VAL(TglDrawArraysInstancedBaseInstance, GetProcAddress('glDrawArraysInstancedBaseInstance'));
	DrawElementsInstancedBaseInstance := SYSTEM.VAL(TglDrawElementsInstancedBaseInstance, GetProcAddress('glDrawElementsInstancedBaseInstance'));
	DrawElementsInstancedBaseVertexBaseInstance := SYSTEM.VAL(TglDrawElementsInstancedBaseVertexBaseInstance, GetProcAddress('glDrawElementsInstancedBaseVertexBaseInstance'));
END Read_GL_ARB_base_instance;

PROCEDURE Read_GL_ARB_transform_feedback_instanced*;
BEGIN
	DrawTransformFeedbackInstanced := SYSTEM.VAL(TglDrawTransformFeedbackInstanced, GetProcAddress('glDrawTransformFeedbackInstanced'));
	DrawTransformFeedbackStreamInstanced := SYSTEM.VAL(TglDrawTransformFeedbackStreamInstanced, GetProcAddress('glDrawTransformFeedbackStreamInstanced'));
END Read_GL_ARB_transform_feedback_instanced;

PROCEDURE Read_GL_ARB_internalformat_query*;
BEGIN
	GetInternalformativ := SYSTEM.VAL(TglGetInternalformativ, GetProcAddress('glGetInternalformativ'));
END Read_GL_ARB_internalformat_query;

PROCEDURE Read_GL_ARB_shader_atomic_counters*;
BEGIN
	GetActiveAtomicCounterBufferiv := SYSTEM.VAL(TglGetActiveAtomicCounterBufferiv, GetProcAddress('glGetActiveAtomicCounterBufferiv'));
END Read_GL_ARB_shader_atomic_counters;

PROCEDURE Read_GL_ARB_shader_image_load_store*;
BEGIN
	BindImageTexture := SYSTEM.VAL(TglBindImageTexture, GetProcAddress('glBindImageTexture'));
	MemoryBarrier := SYSTEM.VAL(TglMemoryBarrier, GetProcAddress('glMemoryBarrier'));
END Read_GL_ARB_shader_image_load_store;

PROCEDURE Read_GL_ARB_texture_storage*;
BEGIN
	TexStorage1D := SYSTEM.VAL(TglTexStorage1D, GetProcAddress('glTexStorage1D'));
	TexStorage2D := SYSTEM.VAL(TglTexStorage2D, GetProcAddress('glTexStorage2D'));
	TexStorage3D := SYSTEM.VAL(TglTexStorage3D, GetProcAddress('glTexStorage3D'));
	TextureStorage1DEXT := SYSTEM.VAL(TglTextureStorage1DEXT, GetProcAddress('glTextureStorage1DEXT'));
	TextureStorage2DEXT := SYSTEM.VAL(TglTextureStorage2DEXT, GetProcAddress('glTextureStorage2DEXT'));
	TextureStorage3DEXT := SYSTEM.VAL(TglTextureStorage3DEXT, GetProcAddress('glTextureStorage3DEXT'));
END Read_GL_ARB_texture_storage;

	(* GL 4.3  *)
PROCEDURE Read_GL_KHR_debug*;
BEGIN
	DebugMessageControl := SYSTEM.VAL(TglDebugMessageControl, GetProcAddress('glDebugMessageControl'));
	DebugMessageInsert := SYSTEM.VAL(TglDebugMessageInsert, GetProcAddress('glDebugMessageInsert'));
	DebugMessageCallback := SYSTEM.VAL(TglDebugMessageCallback, GetProcAddress('glDebugMessageCallback'));
	GetDebugMessageLog := SYSTEM.VAL(TglGetDebugMessageLog, GetProcAddress('glGetDebugMessageLog'));
	PushDebugGroup := SYSTEM.VAL(TglPushDebugGroup, GetProcAddress('glPushDebugGroup'));
	PopDebugGroup := SYSTEM.VAL(TglPopDebugGroup, GetProcAddress('glPopDebugGroup'));
	ObjectLabel := SYSTEM.VAL(TglObjectLabel, GetProcAddress('glObjectLabel'));
	GetObjectLabel := SYSTEM.VAL(TglGetObjectLabel, GetProcAddress('glGetObjectLabel'));
	ObjectPtrLabel := SYSTEM.VAL(TglObjectPtrLabel, GetProcAddress('glObjectPtrLabel'));
	GetObjectPtrLabel := SYSTEM.VAL(TglGetObjectPtrLabel, GetProcAddress('glGetObjectPtrLabel'));
END Read_GL_KHR_debug;

PROCEDURE Read_GL_ARB_clear_buffer_object*;
BEGIN
	ClearBufferData := SYSTEM.VAL(TglClearBufferData, GetProcAddress('glClearBufferData'));
	ClearBufferSubData := SYSTEM.VAL(TglClearBufferSubData, GetProcAddress('glClearBufferSubData'));
	ClearNamedBufferDataEXT := SYSTEM.VAL(TglClearNamedBufferDataEXT, GetProcAddress('glClearNamedBufferDataEXT'));
	ClearNamedBufferSubDataEXT := SYSTEM.VAL(TglClearNamedBufferSubDataEXT, GetProcAddress('glClearNamedBufferSubDataEXT'));
END Read_GL_ARB_clear_buffer_object;

PROCEDURE Read_GL_ARB_compute_shader*;
BEGIN
	DispatchCompute := SYSTEM.VAL(TglDispatchCompute, GetProcAddress('glDispatchCompute'));
	DispatchComputeIndirect := SYSTEM.VAL(TglDispatchComputeIndirect, GetProcAddress('glDispatchComputeIndirect'));
END Read_GL_ARB_compute_shader;

PROCEDURE Read_GL_ARB_copy_image*;
BEGIN
	CopyImageSubData := SYSTEM.VAL(TglCopyImageSubData, GetProcAddress('glCopyImageSubData'));
END Read_GL_ARB_copy_image;

PROCEDURE Read_GL_ARB_framebuffer_no_attachments*;
BEGIN
	FramebufferParameteri := SYSTEM.VAL(TglFramebufferParameteri, GetProcAddress('glFramebufferParameteri'));
	GetFramebufferParameteriv := SYSTEM.VAL(TglGetFramebufferParameteriv, GetProcAddress('glGetFramebufferParameteriv'));
	NamedFramebufferParameteriEXT := SYSTEM.VAL(TglNamedFramebufferParameteriEXT, GetProcAddress('glNamedFramebufferParameteriEXT'));
	GetNamedFramebufferParameterivEXT := SYSTEM.VAL(TglGetNamedFramebufferParameterivEXT, GetProcAddress('glGetNamedFramebufferParameterivEXT'));
END Read_GL_ARB_framebuffer_no_attachments;

PROCEDURE Read_GL_ARB_internalformat_query2;
BEGIN
	GetInternalformati64v := SYSTEM.VAL(TglGetInternalformati64v, GetProcAddress('glGetInternalformati64v'));
END Read_GL_ARB_internalformat_query2;

PROCEDURE Read_GL_ARB_invalidate_subdata*;
BEGIN
	InvalidateTexSubImage := SYSTEM.VAL(TglInvalidateTexSubImage, GetProcAddress('glInvalidateTexSubImage'));
	InvalidateTexImage := SYSTEM.VAL(TglInvalidateTexImage, GetProcAddress('glInvalidateTexImage'));
	InvalidateBufferSubData := SYSTEM.VAL(TglInvalidateBufferSubData, GetProcAddress('glInvalidateBufferSubData'));
	InvalidateBufferData := SYSTEM.VAL(TglInvalidateBufferData, GetProcAddress('glInvalidateBufferData'));
	InvalidateFramebuffer := SYSTEM.VAL(TglInvalidateFramebuffer, GetProcAddress('glInvalidateFramebuffer'));
	InvalidateSubFramebuffer := SYSTEM.VAL(TglInvalidateSubFramebuffer, GetProcAddress('glInvalidateSubFramebuffer'));
END Read_GL_ARB_invalidate_subdata;

PROCEDURE Read_GL_ARB_multi_draw_indirect*;
BEGIN
	MultiDrawArraysIndirect := SYSTEM.VAL(TglMultiDrawArraysIndirect, GetProcAddress('glMultiDrawArraysIndirect'));
	MultiDrawElementsIndirect := SYSTEM.VAL(TglMultiDrawElementsIndirect, GetProcAddress('glMultiDrawElementsIndirect'));
END Read_GL_ARB_multi_draw_indirect;

PROCEDURE Read_GL_ARB_program_interface_query*;
BEGIN
	GetProgramInterfaceiv := SYSTEM.VAL(TglGetProgramInterfaceiv, GetProcAddress('glGetProgramInterfaceiv'));
	GetProgramResourceIndex := SYSTEM.VAL(TglGetProgramResourceIndex, GetProcAddress('glGetProgramResourceIndex'));
	GetProgramResourceName := SYSTEM.VAL(TglGetProgramResourceName, GetProcAddress('glGetProgramResourceName'));
	GetProgramResourceiv := SYSTEM.VAL(TglGetProgramResourceiv, GetProcAddress('glGetProgramResourceiv'));
	GetProgramResourceLocation := SYSTEM.VAL(TglGetProgramResourceLocation, GetProcAddress('glGetProgramResourceLocation'));
	GetProgramResourceLocationIndex := SYSTEM.VAL(TglGetProgramResourceLocationIndex, GetProcAddress('glGetProgramResourceLocationIndex'));
END Read_GL_ARB_program_interface_query;

PROCEDURE Read_GL_ARB_shader_storage_buffer_object*;
BEGIN
	ShaderStorageBlockBinding := SYSTEM.VAL(TglShaderStorageBlockBinding, GetProcAddress('glShaderStorageBlockBinding'));
END Read_GL_ARB_shader_storage_buffer_object;

PROCEDURE Read_GL_ARB_texture_buffer_range*;
BEGIN
	TexBufferRange := SYSTEM.VAL(TglTexBufferRange, GetProcAddress('glTexBufferRange'));
	TextureBufferRangeEXT := SYSTEM.VAL(TglTextureBufferRangeEXT, GetProcAddress('glTextureBufferRangeEXT'));
END Read_GL_ARB_texture_buffer_range;

PROCEDURE Read_GL_ARB_texture_storage_multisample*;
BEGIN
	TexStorage2DMultisample := SYSTEM.VAL(TglTexStorage2DMultisample, GetProcAddress('glTexStorage2DMultisample'));
	TexStorage3DMultisample := SYSTEM.VAL(TglTexStorage3DMultisample, GetProcAddress('glTexStorage3DMultisample'));
	TextureStorage2DMultisampleEXT := SYSTEM.VAL(TglTextureStorage2DMultisampleEXT, GetProcAddress('glTextureStorage2DMultisampleEXT'));
	TextureStorage3DMultisampleEXT := SYSTEM.VAL(TglTextureStorage3DMultisampleEXT, GetProcAddress('glTextureStorage3DMultisampleEXT'));
END Read_GL_ARB_texture_storage_multisample;

PROCEDURE Read_GL_ARB_texture_view*;
BEGIN
	TextureView := SYSTEM.VAL(TglTextureView, GetProcAddress('glTextureView'));
END Read_GL_ARB_texture_view;

PROCEDURE Read_GL_ARB_vertex_attrib_binding*;
BEGIN
	BindVertexBuffer := SYSTEM.VAL(TglBindVertexBuffer, GetProcAddress('glBindVertexBuffer'));
	VertexAttribFormat := SYSTEM.VAL(TglVertexAttribFormat, GetProcAddress('glVertexAttribFormat'));
	VertexAttribIFormat := SYSTEM.VAL(TglVertexAttribIFormat, GetProcAddress('glVertexAttribIFormat'));
	VertexAttribLFormat := SYSTEM.VAL(TglVertexAttribLFormat, GetProcAddress('glVertexAttribLFormat'));
	VertexAttribBinding := SYSTEM.VAL(TglVertexAttribBinding, GetProcAddress('glVertexAttribBinding'));
	VertexBindingDivisor := SYSTEM.VAL(TglVertexBindingDivisor, GetProcAddress('glVertexBindingDivisor'));
	VertexArrayBindVertexBufferEXT := SYSTEM.VAL(TglVertexArrayBindVertexBufferEXT, GetProcAddress('glVertexArrayBindVertexBufferEXT'));
	VertexArrayVertexAttribFormatEXT := SYSTEM.VAL(TglVertexArrayVertexAttribFormatEXT, GetProcAddress('glVertexArrayVertexAttribFormatEXT'));
	VertexArrayVertexAttribIFormatEXT := SYSTEM.VAL(TglVertexArrayVertexAttribIFormatEXT, GetProcAddress('glVertexArrayVertexAttribIFormatEXT'));
	VertexArrayVertexAttribLFormatEXT := SYSTEM.VAL(TglVertexArrayVertexAttribLFormatEXT, GetProcAddress('glVertexArrayVertexAttribLFormatEXT'));
	VertexArrayVertexAttribBindingEXT := SYSTEM.VAL(TglVertexArrayVertexAttribBindingEXT, GetProcAddress('glVertexArrayVertexAttribBindingEXT'));
	VertexArrayVertexBindingDivisorEXT := SYSTEM.VAL(TglVertexArrayVertexBindingDivisorEXT, GetProcAddress('glVertexArrayVertexBindingDivisorEXT'));
END Read_GL_ARB_vertex_attrib_binding;

PROCEDURE Read_GL_NV_path_rendering*;
BEGIN
	GenPathsNV := SYSTEM.VAL(TglGenPathsNV, GetProcAddress('glGenPathsNV'));
	DeletePathsNV := SYSTEM.VAL(TglDeletePathsNV, GetProcAddress('glDeletePathsNV'));
	IsPathNV := SYSTEM.VAL(TglIsPathNV, GetProcAddress('glIsPathNV'));
	PathCommandsNV := SYSTEM.VAL(TglPathCommandsNV, GetProcAddress('glPathCommandsNV'));
	PathCoordsNV := SYSTEM.VAL(TglPathCoordsNV, GetProcAddress('glPathCoordsNV'));
	PathSubCommandsNV := SYSTEM.VAL(TglPathSubCommandsNV, GetProcAddress('glPathSubCommandsNV'));
	PathSubCoordsNV := SYSTEM.VAL(TglPathSubCoordsNV, GetProcAddress('glPathSubCoordsNV'));
	PathStringNV := SYSTEM.VAL(TglPathStringNV, GetProcAddress('glPathStringNV'));
	PathGlyphsNV := SYSTEM.VAL(TglPathGlyphsNV, GetProcAddress('glPathGlyphsNV'));
	PathGlyphRangeNV := SYSTEM.VAL(TglPathGlyphRangeNV, GetProcAddress('glPathGlyphRangeNV'));
	WeightPathsNV := SYSTEM.VAL(TglWeightPathsNV, GetProcAddress('glWeightPathsNV'));
	CopyPathNV := SYSTEM.VAL(TglCopyPathNV, GetProcAddress('glCopyPathNV'));
	InterpolatePathsNV := SYSTEM.VAL(TglInterpolatePathsNV, GetProcAddress('glInterpolatePathsNV'));
	TransformPathNV := SYSTEM.VAL(TglTransformPathNV, GetProcAddress('glTransformPathNV'));
	PathParameterivNV := SYSTEM.VAL(TglPathParameterivNV, GetProcAddress('glPathParameterivNV'));
	PathParameteriNV := SYSTEM.VAL(TglPathParameteriNV, GetProcAddress('glPathParameteriNV'));
	PathParameterfvNV := SYSTEM.VAL(TglPathParameterfvNV, GetProcAddress('glPathParameterfvNV'));
	PathParameterfNV := SYSTEM.VAL(TglPathParameterfNV, GetProcAddress('glPathParameterfNV'));
	PathDashArrayNV := SYSTEM.VAL(TglPathDashArrayNV, GetProcAddress('glPathDashArrayNV'));
	PathStencilFuncNV := SYSTEM.VAL(TglPathStencilFuncNV, GetProcAddress('glPathStencilFuncNV'));
	PathStencilDepthOffsetNV := SYSTEM.VAL(TglPathStencilDepthOffsetNV, GetProcAddress('glPathStencilDepthOffsetNV'));
	StencilFillPathNV := SYSTEM.VAL(TglStencilFillPathNV, GetProcAddress('glStencilFillPathNV'));
	StencilStrokePathNV := SYSTEM.VAL(TglStencilStrokePathNV, GetProcAddress('glStencilStrokePathNV'));
	StencilFillPathInstancedNV := SYSTEM.VAL(TglStencilFillPathInstancedNV, GetProcAddress('glStencilFillPathInstancedNV'));
	StencilStrokePathInstancedNV := SYSTEM.VAL(TglStencilStrokePathInstancedNV, GetProcAddress('glStencilStrokePathInstancedNV'));
	PathCoverDepthFuncNV := SYSTEM.VAL(TglPathCoverDepthFuncNV, GetProcAddress('glPathCoverDepthFuncNV'));
	PathColorGenNV := SYSTEM.VAL(TglPathColorGenNV, GetProcAddress('glPathColorGenNV'));
	PathTexGenNV := SYSTEM.VAL(TglPathTexGenNV, GetProcAddress('glPathTexGenNV'));
	PathFogGenNV := SYSTEM.VAL(TglPathFogGenNV, GetProcAddress('glPathFogGenNV'));
	CoverFillPathNV := SYSTEM.VAL(TglCoverFillPathNV, GetProcAddress('glCoverFillPathNV'));
	CoverStrokePathNV := SYSTEM.VAL(TglCoverStrokePathNV, GetProcAddress('glCoverStrokePathNV'));
	CoverFillPathInstancedNV := SYSTEM.VAL(TglCoverFillPathInstancedNV, GetProcAddress('glCoverFillPathInstancedNV'));
	CoverStrokePathInstancedNV := SYSTEM.VAL(TglCoverStrokePathInstancedNV, GetProcAddress('glCoverStrokePathInstancedNV'));
	GetPathParameterivNV := SYSTEM.VAL(TglGetPathParameterivNV, GetProcAddress('glGetPathParameterivNV'));
	GetPathParameterfvNV := SYSTEM.VAL(TglGetPathParameterfvNV, GetProcAddress('glGetPathParameterfvNV'));
	GetPathCommandsNV := SYSTEM.VAL(TglGetPathCommandsNV, GetProcAddress('glGetPathCommandsNV'));
	GetPathCoordsNV := SYSTEM.VAL(TglGetPathCoordsNV, GetProcAddress('glGetPathCoordsNV'));
	GetPathDashArrayNV := SYSTEM.VAL(TglGetPathDashArrayNV, GetProcAddress('glGetPathDashArrayNV'));
	GetPathMetricsNV := SYSTEM.VAL(TglGetPathMetricsNV, GetProcAddress('glGetPathMetricsNV'));
	GetPathMetricRangeNV := SYSTEM.VAL(TglGetPathMetricRangeNV, GetProcAddress('glGetPathMetricRangeNV'));
	GetPathSpacingNV := SYSTEM.VAL(TglGetPathSpacingNV, GetProcAddress('glGetPathSpacingNV'));
	GetPathColorGenivNV := SYSTEM.VAL(TglGetPathColorGenivNV, GetProcAddress('glGetPathColorGenivNV'));
	GetPathColorGenfvNV := SYSTEM.VAL(TglGetPathColorGenfvNV, GetProcAddress('glGetPathColorGenfvNV'));
	GetPathTexGenivNV := SYSTEM.VAL(TglGetPathTexGenivNV, GetProcAddress('glGetPathTexGenivNV'));
	GetPathTexGenfvNV := SYSTEM.VAL(TglGetPathTexGenfvNV, GetProcAddress('glGetPathTexGenfvNV'));
	IsPointInFillPathNV := SYSTEM.VAL(TglIsPointInFillPathNV, GetProcAddress('glIsPointInFillPathNV'));
	IsPointInStrokePathNV := SYSTEM.VAL(TglIsPointInStrokePathNV, GetProcAddress('glIsPointInStrokePathNV'));
	GetPathLengthNV := SYSTEM.VAL(TglGetPathLengthNV, GetProcAddress('glGetPathLengthNV'));
	PointAlongPathNV := SYSTEM.VAL(TglPointAlongPathNV, GetProcAddress('glPointAlongPathNV'));
END Read_GL_NV_path_rendering;

PROCEDURE Read_GL_AMD_stencil_operation_extended*;
BEGIN
	StencilOpValueAMD := SYSTEM.VAL(TglStencilOpValueAMD, GetProcAddress('glStencilOpValueAMD'));
END Read_GL_AMD_stencil_operation_extended;

PROCEDURE Read_GL_NV_bindless_texture*;
BEGIN
	GetTextureHandleNV := SYSTEM.VAL(TglGetTextureHandleNV, GetProcAddress('glGetTextureHandleNV'));
	GetTextureSamplerHandleNV := SYSTEM.VAL(TglGetTextureSamplerHandleNV, GetProcAddress('glGetTextureSamplerHandleNV'));
	MakeTextureHandleResidentNV := SYSTEM.VAL(TglMakeTextureHandleResidentNV, GetProcAddress('glMakeTextureHandleResidentNV'));
	MakeTextureHandleNonResidentNV := SYSTEM.VAL(TglMakeTextureHandleNonResidentNV, GetProcAddress('glMakeTextureHandleNonResidentNV'));
	GetImageHandleNV := SYSTEM.VAL(TglGetImageHandleNV, GetProcAddress('glGetImageHandleNV'));
	MakeImageHandleResidentNV := SYSTEM.VAL(TglMakeImageHandleResidentNV, GetProcAddress('glMakeImageHandleResidentNV'));
	MakeImageHandleNonResidentNV := SYSTEM.VAL(TglMakeImageHandleNonResidentNV, GetProcAddress('glMakeImageHandleNonResidentNV'));
	UniformHandleui64NV := SYSTEM.VAL(TglUniformHandleui64NV, GetProcAddress('glUniformHandleui64NV'));
	UniformHandleui64vNV := SYSTEM.VAL(TglUniformHandleui64vNV, GetProcAddress('glUniformHandleui64vNV'));
	ProgramUniformHandleui64NV := SYSTEM.VAL(TglProgramUniformHandleui64NV, GetProcAddress('glProgramUniformHandleui64NV'));
	ProgramUniformHandleui64vNV := SYSTEM.VAL(TglProgramUniformHandleui64vNV, GetProcAddress('glProgramUniformHandleui64vNV'));
	IsTextureHandleResidentNV := SYSTEM.VAL(TglIsTextureHandleResidentNV, GetProcAddress('glIsTextureHandleResidentNV'));
	IsImageHandleResidentNV := SYSTEM.VAL(TglIsImageHandleResidentNV, GetProcAddress('glIsImageHandleResidentNV'));
END Read_GL_NV_bindless_texture;

PROCEDURE Read_GL_ARB_cl_event*;
BEGIN
	CreateSyncFromCLeventARB := SYSTEM.VAL(TglCreateSyncFromCLeventARB, GetProcAddress('glCreateSyncFromCLeventARB'));
END Read_GL_ARB_cl_event;

PROCEDURE Read_GL_ARB_debug_output*;
BEGIN
	DebugMessageControlARB := SYSTEM.VAL(TglDebugMessageControlARB, GetProcAddress('glDebugMessageControlARB'));
	DebugMessageInsertARB := SYSTEM.VAL(TglDebugMessageInsertARB, GetProcAddress('glDebugMessageInsertARB'));
	(*     glDebugMessageCallbackARB := SYSTEM.VAL(TglDebugMessageCallbackARB, GetProcAddress('glDebugMessageCallbackARB'));  *)
	GetDebugMessageLogARB := SYSTEM.VAL(TglGetDebugMessageLogARB, GetProcAddress('glGetDebugMessageLogARB'));
END Read_GL_ARB_debug_output;

PROCEDURE Read_GL_ARB_robustness*;
BEGIN
	GetGraphicsResetStatusARB := SYSTEM.VAL(TglGetGraphicsResetStatusARB, GetProcAddress('glGetGraphicsResetStatusARB'));
	GetnMapdvARB := SYSTEM.VAL(TglGetnMapdvARB, GetProcAddress('glGetnMapdvARB'));
	GetnMapfvARB := SYSTEM.VAL(TglGetnMapfvARB, GetProcAddress('glGetnMapfvARB'));
	GetnMapivARB := SYSTEM.VAL(TglGetnMapivARB, GetProcAddress('glGetnMapivARB'));
	GetnPixelMapfvARB := SYSTEM.VAL(TglGetnPixelMapfvARB, GetProcAddress('glGetnPixelMapfvARB'));
	GetnPixelMapuivARB := SYSTEM.VAL(TglGetnPixelMapuivARB, GetProcAddress('glGetnPixelMapuivARB'));
	GetnPixelMapusvARB := SYSTEM.VAL(TglGetnPixelMapusvARB, GetProcAddress('glGetnPixelMapusvARB'));
	GetnPolygonStippleARB := SYSTEM.VAL(TglGetnPolygonStippleARB, GetProcAddress('glGetnPolygonStippleARB'));
	GetnColorTableARB := SYSTEM.VAL(TglGetnColorTableARB, GetProcAddress('glGetnColorTableARB'));
	GetnConvolutionFilterARB := SYSTEM.VAL(TglGetnConvolutionFilterARB, GetProcAddress('glGetnConvolutionFilterARB'));
	GetnSeparableFilterARB := SYSTEM.VAL(TglGetnSeparableFilterARB, GetProcAddress('glGetnSeparableFilterARB'));
	GetnHistogramARB := SYSTEM.VAL(TglGetnHistogramARB, GetProcAddress('glGetnHistogramARB'));
	GetnMinmaxARB := SYSTEM.VAL(TglGetnMinmaxARB, GetProcAddress('glGetnMinmaxARB'));
	GetnTexImageARB := SYSTEM.VAL(TglGetnTexImageARB, GetProcAddress('glGetnTexImageARB'));
	ReadnPixelsARB := SYSTEM.VAL(TglReadnPixelsARB, GetProcAddress('glReadnPixelsARB'));
	GetnCompressedTexImageARB := SYSTEM.VAL(TglGetnCompressedTexImageARB, GetProcAddress('glGetnCompressedTexImageARB'));
	GetnUniformfvARB := SYSTEM.VAL(TglGetnUniformfvARB, GetProcAddress('glGetnUniformfvARB'));
	GetnUniformivARB := SYSTEM.VAL(TglGetnUniformivARB, GetProcAddress('glGetnUniformivARB'));
	GetnUniformuivARB := SYSTEM.VAL(TglGetnUniformuivARB, GetProcAddress('glGetnUniformuivARB'));
	GetnUniformdvARB := SYSTEM.VAL(TglGetnUniformdvARB, GetProcAddress('glGetnUniformdvARB'));
END Read_GL_ARB_robustness;

PROCEDURE Read_GL_ATI_draw_buffers*;
BEGIN
	DrawBuffersATI := SYSTEM.VAL(TglDrawBuffersATI, GetProcAddress('glDrawBuffersATI'));
END Read_GL_ATI_draw_buffers;

PROCEDURE Read_GL_ATI_element_array*;
BEGIN
	ElementPointerATI := SYSTEM.VAL(TglElementPointerATI, GetProcAddress('glElementPointerATI'));
	DrawElementArrayATI := SYSTEM.VAL(TglDrawElementArrayATI, GetProcAddress('glDrawElementArrayATI'));
	DrawRangeElementArrayATI := SYSTEM.VAL(TglDrawRangeElementArrayATI, GetProcAddress('glDrawRangeElementArrayATI'));
END Read_GL_ATI_element_array;

PROCEDURE Read_GL_ATI_envmap_bumpmap*;
BEGIN
	TexBumpParameterivATI := SYSTEM.VAL(TglTexBumpParameterivATI, GetProcAddress('glTexBumpParameterivATI'));
	TexBumpParameterfvATI := SYSTEM.VAL(TglTexBumpParameterfvATI, GetProcAddress('glTexBumpParameterfvATI'));
	GetTexBumpParameterivATI := SYSTEM.VAL(TglGetTexBumpParameterivATI, GetProcAddress('glGetTexBumpParameterivATI'));
	GetTexBumpParameterfvATI := SYSTEM.VAL(TglGetTexBumpParameterfvATI, GetProcAddress('glGetTexBumpParameterfvATI'));
END Read_GL_ATI_envmap_bumpmap;

PROCEDURE Read_GL_ATI_fragment_shader*;
BEGIN
	GenFragmentShadersATI := SYSTEM.VAL(TglGenFragmentShadersATI, GetProcAddress('glGenFragmentShadersATI'));
	BindFragmentShaderATI := SYSTEM.VAL(TglBindFragmentShaderATI, GetProcAddress('glBindFragmentShaderATI'));
	DeleteFragmentShaderATI := SYSTEM.VAL(TglDeleteFragmentShaderATI, GetProcAddress('glDeleteFragmentShaderATI'));
	BeginFragmentShaderATI := SYSTEM.VAL(TglBeginFragmentShaderATI, GetProcAddress('glBeginFragmentShaderATI'));
	EndFragmentShaderATI := SYSTEM.VAL(TglEndFragmentShaderATI, GetProcAddress('glEndFragmentShaderATI'));
	PassTexCoordATI := SYSTEM.VAL(TglPassTexCoordATI, GetProcAddress('glPassTexCoordATI'));
	SampleMapATI := SYSTEM.VAL(TglSampleMapATI, GetProcAddress('glSampleMapATI'));
	ColorFragmentOp1ATI := SYSTEM.VAL(TglColorFragmentOp1ATI, GetProcAddress('glColorFragmentOp1ATI'));
	ColorFragmentOp2ATI := SYSTEM.VAL(TglColorFragmentOp2ATI, GetProcAddress('glColorFragmentOp2ATI'));
	ColorFragmentOp3ATI := SYSTEM.VAL(TglColorFragmentOp3ATI, GetProcAddress('glColorFragmentOp3ATI'));
	AlphaFragmentOp1ATI := SYSTEM.VAL(TglAlphaFragmentOp1ATI, GetProcAddress('glAlphaFragmentOp1ATI'));
	AlphaFragmentOp2ATI := SYSTEM.VAL(TglAlphaFragmentOp2ATI, GetProcAddress('glAlphaFragmentOp2ATI'));
	AlphaFragmentOp3ATI := SYSTEM.VAL(TglAlphaFragmentOp3ATI, GetProcAddress('glAlphaFragmentOp3ATI'));
	SetFragmentShaderConstantATI := SYSTEM.VAL(TglSetFragmentShaderConstantATI, GetProcAddress('glSetFragmentShaderConstantATI'));
END Read_GL_ATI_fragment_shader;

PROCEDURE Read_GL_ATI_map_object_buffer*;
BEGIN
	MapObjectBufferATI := SYSTEM.VAL(TglMapObjectBufferATI, GetProcAddress('glMapObjectBufferATI'));
	UnmapObjectBufferATI := SYSTEM.VAL(TglUnmapObjectBufferATI, GetProcAddress('glUnmapObjectBufferATI'));
END Read_GL_ATI_map_object_buffer;

PROCEDURE Read_GL_ATI_pn_triangles*;
BEGIN
	PNTrianglesiATI := SYSTEM.VAL(TglPNTrianglesiATI, GetProcAddress('glPNTrianglesiATI'));
	PNTrianglesfATI := SYSTEM.VAL(TglPNTrianglesfATI, GetProcAddress('glPNTrianglesfATI'));
END Read_GL_ATI_pn_triangles;

PROCEDURE Read_GL_ATI_separate_stencil*;
BEGIN
	StencilOpSeparateATI := SYSTEM.VAL(TglStencilOpSeparateATI, GetProcAddress('glStencilOpSeparateATI'));
	StencilFuncSeparateATI := SYSTEM.VAL(TglStencilFuncSeparateATI, GetProcAddress('glStencilFuncSeparateATI'));
END Read_GL_ATI_separate_stencil;

PROCEDURE Read_GL_ATI_vertex_array_object*;
BEGIN
	NewObjectBufferATI := SYSTEM.VAL(TglNewObjectBufferATI, GetProcAddress('glNewObjectBufferATI'));
	IsObjectBufferATI := SYSTEM.VAL(TglIsObjectBufferATI, GetProcAddress('glIsObjectBufferATI'));
	UpdateObjectBufferATI := SYSTEM.VAL(TglUpdateObjectBufferATI, GetProcAddress('glUpdateObjectBufferATI'));
	GetObjectBufferfvATI := SYSTEM.VAL(TglGetObjectBufferfvATI, GetProcAddress('glGetObjectBufferfvATI'));
	GetObjectBufferivATI := SYSTEM.VAL(TglGetObjectBufferivATI, GetProcAddress('glGetObjectBufferivATI'));
	FreeObjectBufferATI := SYSTEM.VAL(TglFreeObjectBufferATI, GetProcAddress('glFreeObjectBufferATI'));
	ArrayObjectATI := SYSTEM.VAL(TglArrayObjectATI, GetProcAddress('glArrayObjectATI'));
	GetArrayObjectfvATI := SYSTEM.VAL(TglGetArrayObjectfvATI, GetProcAddress('glGetArrayObjectfvATI'));
	GetArrayObjectivATI := SYSTEM.VAL(TglGetArrayObjectivATI, GetProcAddress('glGetArrayObjectivATI'));
	VariantArrayObjectATI := SYSTEM.VAL(TglVariantArrayObjectATI, GetProcAddress('glVariantArrayObjectATI'));
	GetVariantArrayObjectfvATI := SYSTEM.VAL(TglGetVariantArrayObjectfvATI, GetProcAddress('glGetVariantArrayObjectfvATI'));
	GetVariantArrayObjectivATI := SYSTEM.VAL(TglGetVariantArrayObjectivATI, GetProcAddress('glGetVariantArrayObjectivATI'));
END Read_GL_ATI_vertex_array_object;

PROCEDURE Read_GL_ATI_vertex_attrib_array_object*;
BEGIN
	VertexAttribArrayObjectATI := SYSTEM.VAL(TglVertexAttribArrayObjectATI, GetProcAddress('glVertexAttribArrayObjectATI'));
	GetVertexAttribArrayObjectfvATI := SYSTEM.VAL(TglGetVertexAttribArrayObjectfvATI, GetProcAddress('glGetVertexAttribArrayObjectfvATI'));
	GetVertexAttribArrayObjectivATI := SYSTEM.VAL(TglGetVertexAttribArrayObjectivATI, GetProcAddress('glGetVertexAttribArrayObjectivATI'));
END Read_GL_ATI_vertex_attrib_array_object;

PROCEDURE Read_GL_ATI_vertex_streams*;
BEGIN
	VertexStream1sATI := SYSTEM.VAL(TglVertexStream1sATI, GetProcAddress('glVertexStream1sATI'));
	VertexStream1svATI := SYSTEM.VAL(TglVertexStream1svATI, GetProcAddress('glVertexStream1svATI'));
	VertexStream1iATI := SYSTEM.VAL(TglVertexStream1iATI, GetProcAddress('glVertexStream1iATI'));
	VertexStream1ivATI := SYSTEM.VAL(TglVertexStream1ivATI, GetProcAddress('glVertexStream1ivATI'));
	VertexStream1fATI := SYSTEM.VAL(TglVertexStream1fATI, GetProcAddress('glVertexStream1fATI'));
	VertexStream1fvATI := SYSTEM.VAL(TglVertexStream1fvATI, GetProcAddress('glVertexStream1fvATI'));
	VertexStream1dATI := SYSTEM.VAL(TglVertexStream1dATI, GetProcAddress('glVertexStream1dATI'));
	VertexStream1dvATI := SYSTEM.VAL(TglVertexStream1dvATI, GetProcAddress('glVertexStream1dvATI'));
	VertexStream2sATI := SYSTEM.VAL(TglVertexStream2sATI, GetProcAddress('glVertexStream2sATI'));
	VertexStream2svATI := SYSTEM.VAL(TglVertexStream2svATI, GetProcAddress('glVertexStream2svATI'));
	VertexStream2iATI := SYSTEM.VAL(TglVertexStream2iATI, GetProcAddress('glVertexStream2iATI'));
	VertexStream2ivATI := SYSTEM.VAL(TglVertexStream2ivATI, GetProcAddress('glVertexStream2ivATI'));
	VertexStream2fATI := SYSTEM.VAL(TglVertexStream2fATI, GetProcAddress('glVertexStream2fATI'));
	VertexStream2fvATI := SYSTEM.VAL(TglVertexStream2fvATI, GetProcAddress('glVertexStream2fvATI'));
	VertexStream2dATI := SYSTEM.VAL(TglVertexStream2dATI, GetProcAddress('glVertexStream2dATI'));
	VertexStream2dvATI := SYSTEM.VAL(TglVertexStream2dvATI, GetProcAddress('glVertexStream2dvATI'));
	VertexStream3sATI := SYSTEM.VAL(TglVertexStream3sATI, GetProcAddress('glVertexStream3sATI'));
	VertexStream3svATI := SYSTEM.VAL(TglVertexStream3svATI, GetProcAddress('glVertexStream3svATI'));
	VertexStream3iATI := SYSTEM.VAL(TglVertexStream3iATI, GetProcAddress('glVertexStream3iATI'));
	VertexStream3ivATI := SYSTEM.VAL(TglVertexStream3ivATI, GetProcAddress('glVertexStream3ivATI'));
	VertexStream3fATI := SYSTEM.VAL(TglVertexStream3fATI, GetProcAddress('glVertexStream3fATI'));
	VertexStream3fvATI := SYSTEM.VAL(TglVertexStream3fvATI, GetProcAddress('glVertexStream3fvATI'));
	VertexStream3dATI := SYSTEM.VAL(TglVertexStream3dATI, GetProcAddress('glVertexStream3dATI'));
	VertexStream3dvATI := SYSTEM.VAL(TglVertexStream3dvATI, GetProcAddress('glVertexStream3dvATI'));
	VertexStream4sATI := SYSTEM.VAL(TglVertexStream4sATI, GetProcAddress('glVertexStream4sATI'));
	VertexStream4svATI := SYSTEM.VAL(TglVertexStream4svATI, GetProcAddress('glVertexStream4svATI'));
	VertexStream4iATI := SYSTEM.VAL(TglVertexStream4iATI, GetProcAddress('glVertexStream4iATI'));
	VertexStream4ivATI := SYSTEM.VAL(TglVertexStream4ivATI, GetProcAddress('glVertexStream4ivATI'));
	VertexStream4fATI := SYSTEM.VAL(TglVertexStream4fATI, GetProcAddress('glVertexStream4fATI'));
	VertexStream4fvATI := SYSTEM.VAL(TglVertexStream4fvATI, GetProcAddress('glVertexStream4fvATI'));
	VertexStream4dATI := SYSTEM.VAL(TglVertexStream4dATI, GetProcAddress('glVertexStream4dATI'));
	VertexStream4dvATI := SYSTEM.VAL(TglVertexStream4dvATI, GetProcAddress('glVertexStream4dvATI'));
	NormalStream3bATI := SYSTEM.VAL(TglNormalStream3bATI, GetProcAddress('glNormalStream3bATI'));
	NormalStream3bvATI := SYSTEM.VAL(TglNormalStream3bvATI, GetProcAddress('glNormalStream3bvATI'));
	NormalStream3sATI := SYSTEM.VAL(TglNormalStream3sATI, GetProcAddress('glNormalStream3sATI'));
	NormalStream3svATI := SYSTEM.VAL(TglNormalStream3svATI, GetProcAddress('glNormalStream3svATI'));
	NormalStream3iATI := SYSTEM.VAL(TglNormalStream3iATI, GetProcAddress('glNormalStream3iATI'));
	NormalStream3ivATI := SYSTEM.VAL(TglNormalStream3ivATI, GetProcAddress('glNormalStream3ivATI'));
	NormalStream3fATI := SYSTEM.VAL(TglNormalStream3fATI, GetProcAddress('glNormalStream3fATI'));
	NormalStream3fvATI := SYSTEM.VAL(TglNormalStream3fvATI, GetProcAddress('glNormalStream3fvATI'));
	NormalStream3dATI := SYSTEM.VAL(TglNormalStream3dATI, GetProcAddress('glNormalStream3dATI'));
	NormalStream3dvATI := SYSTEM.VAL(TglNormalStream3dvATI, GetProcAddress('glNormalStream3dvATI'));
	ClientActiveVertexStreamATI := SYSTEM.VAL(TglClientActiveVertexStreamATI, GetProcAddress('glClientActiveVertexStreamATI'));
	VertexBlendEnviATI := SYSTEM.VAL(TglVertexBlendEnviATI, GetProcAddress('glVertexBlendEnviATI'));
	VertexBlendEnvfATI := SYSTEM.VAL(TglVertexBlendEnvfATI, GetProcAddress('glVertexBlendEnvfATI'));
END Read_GL_ATI_vertex_streams;

PROCEDURE Read_GL_AMD_performance_monitor*;
BEGIN
	GetPerfMonitorGroupsAMD := SYSTEM.VAL(TglGetPerfMonitorGroupsAMD, GetProcAddress('glGetPerfMonitorGroupsAMD'));
	GetPerfMonitorCountersAMD := SYSTEM.VAL(TglGetPerfMonitorCountersAMD, GetProcAddress('glGetPerfMonitorCountersAMD'));
	GetPerfMonitorGroupStringAMD := SYSTEM.VAL(TglGetPerfMonitorGroupStringAMD, GetProcAddress('glGetPerfMonitorGroupStringAMD'));
	GetPerfMonitorCounterStringAMD := SYSTEM.VAL(TglGetPerfMonitorCounterStringAMD, GetProcAddress('glGetPerfMonitorCounterStringAMD'));
	GetPerfMonitorCounterInfoAMD := SYSTEM.VAL(TglGetPerfMonitorCounterInfoAMD, GetProcAddress('glGetPerfMonitorCounterInfoAMD'));
	GenPerfMonitorsAMD := SYSTEM.VAL(TglGenPerfMonitorsAMD, GetProcAddress('glGenPerfMonitorsAMD'));
	DeletePerfMonitorsAMD := SYSTEM.VAL(TglDeletePerfMonitorsAMD, GetProcAddress('glDeletePerfMonitorsAMD'));
	SelectPerfMonitorCountersAMD := SYSTEM.VAL(TglSelectPerfMonitorCountersAMD, GetProcAddress('glSelectPerfMonitorCountersAMD'));
	BeginPerfMonitorAMD := SYSTEM.VAL(TglBeginPerfMonitorAMD, GetProcAddress('glBeginPerfMonitorAMD'));
	EndPerfMonitorAMD := SYSTEM.VAL(TglEndPerfMonitorAMD, GetProcAddress('glEndPerfMonitorAMD'));
	GetPerfMonitorCounterDataAMD := SYSTEM.VAL(TglGetPerfMonitorCounterDataAMD, GetProcAddress('glGetPerfMonitorCounterDataAMD'));
END Read_GL_AMD_performance_monitor;

PROCEDURE Read_GL_AMD_vertex_shader_tesselator*;
BEGIN
	TessellationFactorAMD := SYSTEM.VAL(TglTessellationFactorAMD, GetProcAddress('glTessellationFactorAMD'));
	TessellationModeAMD := SYSTEM.VAL(TglTessellationModeAMD, GetProcAddress('glTessellationModeAMD'));
END Read_GL_AMD_vertex_shader_tesselator;

PROCEDURE Read_GL_AMD_draw_buffers_blend*;
BEGIN
	BlendFuncIndexedAMD := SYSTEM.VAL(TglBlendFuncIndexedAMD, GetProcAddress('glBlendFuncIndexedAMD'));
	BlendFuncSeparateIndexedAMD := SYSTEM.VAL(TglBlendFuncSeparateIndexedAMD, GetProcAddress('glBlendFuncSeparateIndexedAMD'));
	BlendEquationIndexedAMD := SYSTEM.VAL(TglBlendEquationIndexedAMD, GetProcAddress('glBlendEquationIndexedAMD'));
	BlendEquationSeparateIndexedAMD := SYSTEM.VAL(TglBlendEquationSeparateIndexedAMD, GetProcAddress('glBlendEquationSeparateIndexedAMD'));
END Read_GL_AMD_draw_buffers_blend;

PROCEDURE Read_GL_AMD_name_gen_delete*;
BEGIN
	GenNamesAMD := SYSTEM.VAL(TglGenNamesAMD, GetProcAddress('glGenNamesAMD'));
	DeleteNamesAMD := SYSTEM.VAL(TglDeleteNamesAMD, GetProcAddress('glDeleteNamesAMD'));
	IsNameAMD := SYSTEM.VAL(TglIsNameAMD, GetProcAddress('glIsNameAMD'));
END Read_GL_AMD_name_gen_delete;

PROCEDURE Read_GL_AMD_debug_output*;
BEGIN
	DebugMessageEnableAMD := SYSTEM.VAL(TglDebugMessageEnableAMD, GetProcAddress('glDebugMessageEnableAMD'));
	DebugMessageInsertAMD := SYSTEM.VAL(TglDebugMessageInsertAMD, GetProcAddress('glDebugMessageInsertAMD'));
	(*     glDebugMessageCallbackAMD := SYSTEM.VAL(TglDebugMessageCallbackAMD, GetProcAddress('glDebugMessageCallbackAMD'));  *)
	GetDebugMessageLogAMD := SYSTEM.VAL(TglGetDebugMessageLogAMD, GetProcAddress('glGetDebugMessageLogAMD'));
END Read_GL_AMD_debug_output;

PROCEDURE Read_GL_EXT_blend_color*;
BEGIN
	BlendColorEXT := SYSTEM.VAL(TglBlendColorEXT, GetProcAddress('glBlendColorEXT'));
END Read_GL_EXT_blend_color;

PROCEDURE Read_GL_EXT_blend_func_separate*;
BEGIN
	BlendFuncSeparateEXT := SYSTEM.VAL(TglBlendFuncSeparateEXT, GetProcAddress('glBlendFuncSeparateEXT'));
END Read_GL_EXT_blend_func_separate;

PROCEDURE Read_GL_EXT_blend_minmax*;
BEGIN
	BlendEquationEXT := SYSTEM.VAL(TglBlendEquationEXT, GetProcAddress('glBlendEquationEXT'));
END Read_GL_EXT_blend_minmax;

PROCEDURE Read_GL_EXT_color_subtable*;
BEGIN
	ColorSubTableEXT := SYSTEM.VAL(TglColorSubTableEXT, GetProcAddress('glColorSubTableEXT'));
	CopyColorSubTableEXT := SYSTEM.VAL(TglCopyColorSubTableEXT, GetProcAddress('glCopyColorSubTableEXT'));
END Read_GL_EXT_color_subtable;

PROCEDURE Read_GL_EXT_compiled_vertex_array*;
BEGIN
	LockArraysEXT := SYSTEM.VAL(TglLockArraysEXT, GetProcAddress('glLockArraysEXT'));
	UnlockArraysEXT := SYSTEM.VAL(TglUnlockArraysEXT, GetProcAddress('glUnlockArraysEXT'));
END Read_GL_EXT_compiled_vertex_array;

PROCEDURE Read_GL_EXT_convolution*;
BEGIN
	ConvolutionFilter1DEXT := SYSTEM.VAL(TglConvolutionFilter1DEXT, GetProcAddress('glConvolutionFilter1DEXT'));
	ConvolutionFilter2DEXT := SYSTEM.VAL(TglConvolutionFilter2DEXT, GetProcAddress('glConvolutionFilter2DEXT'));
	ConvolutionParameterfEXT := SYSTEM.VAL(TglConvolutionParameterfEXT, GetProcAddress('glConvolutionParameterfEXT'));
	ConvolutionParameterfvEXT := SYSTEM.VAL(TglConvolutionParameterfvEXT, GetProcAddress('glConvolutionParameterfvEXT'));
	ConvolutionParameteriEXT := SYSTEM.VAL(TglConvolutionParameteriEXT, GetProcAddress('glConvolutionParameteriEXT'));
	ConvolutionParameterivEXT := SYSTEM.VAL(TglConvolutionParameterivEXT, GetProcAddress('glConvolutionParameterivEXT'));
	CopyConvolutionFilter1DEXT := SYSTEM.VAL(TglCopyConvolutionFilter1DEXT, GetProcAddress('glCopyConvolutionFilter1DEXT'));
	CopyConvolutionFilter2DEXT := SYSTEM.VAL(TglCopyConvolutionFilter2DEXT, GetProcAddress('glCopyConvolutionFilter2DEXT'));
	GetConvolutionFilterEXT := SYSTEM.VAL(TglGetConvolutionFilterEXT, GetProcAddress('glGetConvolutionFilterEXT'));
	GetConvolutionParameterfvEXT := SYSTEM.VAL(TglGetConvolutionParameterfvEXT, GetProcAddress('glGetConvolutionParameterfvEXT'));
	GetConvolutionParameterivEXT := SYSTEM.VAL(TglGetConvolutionParameterivEXT, GetProcAddress('glGetConvolutionParameterivEXT'));
	GetSeparableFilterEXT := SYSTEM.VAL(TglGetSeparableFilterEXT, GetProcAddress('glGetSeparableFilterEXT'));
	SeparableFilter2DEXT := SYSTEM.VAL(TglSeparableFilter2DEXT, GetProcAddress('glSeparableFilter2DEXT'));
END Read_GL_EXT_convolution;

PROCEDURE Read_GL_EXT_coordinate_frame*;
BEGIN
	Tangent3bEXT := SYSTEM.VAL(TglTangent3bEXT, GetProcAddress('glTangent3bEXT'));
	Tangent3bvEXT := SYSTEM.VAL(TglTangent3bvEXT, GetProcAddress('glTangent3bvEXT'));
	Tangent3dEXT := SYSTEM.VAL(TglTangent3dEXT, GetProcAddress('glTangent3dEXT'));
	Tangent3dvEXT := SYSTEM.VAL(TglTangent3dvEXT, GetProcAddress('glTangent3dvEXT'));
	Tangent3fEXT := SYSTEM.VAL(TglTangent3fEXT, GetProcAddress('glTangent3fEXT'));
	Tangent3fvEXT := SYSTEM.VAL(TglTangent3fvEXT, GetProcAddress('glTangent3fvEXT'));
	Tangent3iEXT := SYSTEM.VAL(TglTangent3iEXT, GetProcAddress('glTangent3iEXT'));
	Tangent3ivEXT := SYSTEM.VAL(TglTangent3ivEXT, GetProcAddress('glTangent3ivEXT'));
	Tangent3sEXT := SYSTEM.VAL(TglTangent3sEXT, GetProcAddress('glTangent3sEXT'));
	Tangent3svEXT := SYSTEM.VAL(TglTangent3svEXT, GetProcAddress('glTangent3svEXT'));
	Binormal3bEXT := SYSTEM.VAL(TglBinormal3bEXT, GetProcAddress('glBinormal3bEXT'));
	Binormal3bvEXT := SYSTEM.VAL(TglBinormal3bvEXT, GetProcAddress('glBinormal3bvEXT'));
	Binormal3dEXT := SYSTEM.VAL(TglBinormal3dEXT, GetProcAddress('glBinormal3dEXT'));
	Binormal3dvEXT := SYSTEM.VAL(TglBinormal3dvEXT, GetProcAddress('glBinormal3dvEXT'));
	Binormal3fEXT := SYSTEM.VAL(TglBinormal3fEXT, GetProcAddress('glBinormal3fEXT'));
	Binormal3fvEXT := SYSTEM.VAL(TglBinormal3fvEXT, GetProcAddress('glBinormal3fvEXT'));
	Binormal3iEXT := SYSTEM.VAL(TglBinormal3iEXT, GetProcAddress('glBinormal3iEXT'));
	Binormal3ivEXT := SYSTEM.VAL(TglBinormal3ivEXT, GetProcAddress('glBinormal3ivEXT'));
	Binormal3sEXT := SYSTEM.VAL(TglBinormal3sEXT, GetProcAddress('glBinormal3sEXT'));
	Binormal3svEXT := SYSTEM.VAL(TglBinormal3svEXT, GetProcAddress('glBinormal3svEXT'));
	TangentPointerEXT := SYSTEM.VAL(TglTangentPointerEXT, GetProcAddress('glTangentPointerEXT'));
	BinormalPointerEXT := SYSTEM.VAL(TglBinormalPointerEXT, GetProcAddress('glBinormalPointerEXT'));
END Read_GL_EXT_coordinate_frame;

PROCEDURE Read_GL_EXT_copy_texture*;
BEGIN
	CopyTexImage1DEXT := SYSTEM.VAL(TglCopyTexImage1DEXT, GetProcAddress('glCopyTexImage1DEXT'));
	CopyTexImage2DEXT := SYSTEM.VAL(TglCopyTexImage2DEXT, GetProcAddress('glCopyTexImage2DEXT'));
	CopyTexSubImage1DEXT := SYSTEM.VAL(TglCopyTexSubImage1DEXT, GetProcAddress('glCopyTexSubImage1DEXT'));
	CopyTexSubImage2DEXT := SYSTEM.VAL(TglCopyTexSubImage2DEXT, GetProcAddress('glCopyTexSubImage2DEXT'));
	CopyTexSubImage3DEXT := SYSTEM.VAL(TglCopyTexSubImage3DEXT, GetProcAddress('glCopyTexSubImage3DEXT'));
END Read_GL_EXT_copy_texture;

PROCEDURE Read_GL_EXT_cull_vertex*;
BEGIN
	CullParameterdvEXT := SYSTEM.VAL(TglCullParameterdvEXT, GetProcAddress('glCullParameterdvEXT'));
	CullParameterfvEXT := SYSTEM.VAL(TglCullParameterfvEXT, GetProcAddress('glCullParameterfvEXT'));
END Read_GL_EXT_cull_vertex;

PROCEDURE Read_GL_EXT_draw_range_elements*;
BEGIN
	DrawRangeElementsEXT := SYSTEM.VAL(TglDrawRangeElementsEXT, GetProcAddress('glDrawRangeElementsEXT'));
END Read_GL_EXT_draw_range_elements;

PROCEDURE Read_GL_EXT_fog_coord*;
BEGIN
	FogCoordfEXT := SYSTEM.VAL(TglFogCoordfEXT, GetProcAddress('glFogCoordfEXT'));
	FogCoordfvEXT := SYSTEM.VAL(TglFogCoordfvEXT, GetProcAddress('glFogCoordfvEXT'));
	FogCoorddEXT := SYSTEM.VAL(TglFogCoorddEXT, GetProcAddress('glFogCoorddEXT'));
	FogCoorddvEXT := SYSTEM.VAL(TglFogCoorddvEXT, GetProcAddress('glFogCoorddvEXT'));
	FogCoordPointerEXT := SYSTEM.VAL(TglFogCoordPointerEXT, GetProcAddress('glFogCoordPointerEXT'));
END Read_GL_EXT_fog_coord;

PROCEDURE Read_GL_EXT_framebuffer_object*;
BEGIN
	IsRenderbufferEXT := SYSTEM.VAL(TglIsRenderbufferEXT, GetProcAddress('glIsRenderbufferEXT'));
	BindRenderbufferEXT := SYSTEM.VAL(TglBindRenderbufferEXT, GetProcAddress('glBindRenderbufferEXT'));
	DeleteRenderbuffersEXT := SYSTEM.VAL(TglDeleteRenderbuffersEXT, GetProcAddress('glDeleteRenderbuffersEXT'));
	GenRenderbuffersEXT := SYSTEM.VAL(TglGenRenderbuffersEXT, GetProcAddress('glGenRenderbuffersEXT'));
	RenderbufferStorageEXT := SYSTEM.VAL(TglRenderbufferStorageEXT, GetProcAddress('glRenderbufferStorageEXT'));
	GetRenderbufferParameterivEXT := SYSTEM.VAL(TglGetRenderbufferParameterivEXT, GetProcAddress('glGetRenderbufferParameterivEXT'));
	IsFramebufferEXT := SYSTEM.VAL(TglIsFramebufferEXT, GetProcAddress('glIsFramebufferEXT'));
	BindFramebufferEXT := SYSTEM.VAL(TglBindFramebufferEXT, GetProcAddress('glBindFramebufferEXT'));
	DeleteFramebuffersEXT := SYSTEM.VAL(TglDeleteFramebuffersEXT, GetProcAddress('glDeleteFramebuffersEXT'));
	GenFramebuffersEXT := SYSTEM.VAL(TglGenFramebuffersEXT, GetProcAddress('glGenFramebuffersEXT'));
	CheckFramebufferStatusEXT := SYSTEM.VAL(TglCheckFramebufferStatusEXT, GetProcAddress('glCheckFramebufferStatusEXT'));
	FramebufferTexture1DEXT := SYSTEM.VAL(TglFramebufferTexture1DEXT, GetProcAddress('glFramebufferTexture1DEXT'));
	FramebufferTexture2DEXT := SYSTEM.VAL(TglFramebufferTexture2DEXT, GetProcAddress('glFramebufferTexture2DEXT'));
	FramebufferTexture3DEXT := SYSTEM.VAL(TglFramebufferTexture3DEXT, GetProcAddress('glFramebufferTexture3DEXT'));
	FramebufferRenderbufferEXT := SYSTEM.VAL(TglFramebufferRenderbufferEXT, GetProcAddress('glFramebufferRenderbufferEXT'));
	GetFramebufferAttachmentParameterivEXT := SYSTEM.VAL(TglGetFramebufferAttachmentParameterivEXT, GetProcAddress('glGetFramebufferAttachmentParameterivEXT'));
	GenerateMipmapEXT := SYSTEM.VAL(TglGenerateMipmapEXT, GetProcAddress('glGenerateMipmapEXT'));
END Read_GL_EXT_framebuffer_object;

PROCEDURE Read_GL_EXT_histogram*;
BEGIN
	GetHistogramEXT := SYSTEM.VAL(TglGetHistogramEXT, GetProcAddress('glGetHistogramEXT'));
	GetHistogramParameterfvEXT := SYSTEM.VAL(TglGetHistogramParameterfvEXT, GetProcAddress('glGetHistogramParameterfvEXT'));
	GetHistogramParameterivEXT := SYSTEM.VAL(TglGetHistogramParameterivEXT, GetProcAddress('glGetHistogramParameterivEXT'));
	GetMinmaxEXT := SYSTEM.VAL(TglGetMinmaxEXT, GetProcAddress('glGetMinmaxEXT'));
	GetMinmaxParameterfvEXT := SYSTEM.VAL(TglGetMinmaxParameterfvEXT, GetProcAddress('glGetMinmaxParameterfvEXT'));
	GetMinmaxParameterivEXT := SYSTEM.VAL(TglGetMinmaxParameterivEXT, GetProcAddress('glGetMinmaxParameterivEXT'));
	HistogramEXT := SYSTEM.VAL(TglHistogramEXT, GetProcAddress('glHistogramEXT'));
	MinmaxEXT := SYSTEM.VAL(TglMinmaxEXT, GetProcAddress('glMinmaxEXT'));
	ResetHistogramEXT := SYSTEM.VAL(TglResetHistogramEXT, GetProcAddress('glResetHistogramEXT'));
	ResetMinmaxEXT := SYSTEM.VAL(TglResetMinmaxEXT, GetProcAddress('glResetMinmaxEXT'));
END Read_GL_EXT_histogram;

PROCEDURE Read_GL_EXT_index_func*;
BEGIN
	IndexFuncEXT := SYSTEM.VAL(TglIndexFuncEXT, GetProcAddress('glIndexFuncEXT'));
END Read_GL_EXT_index_func;

PROCEDURE Read_GL_EXT_index_material*;
BEGIN
	IndexMaterialEXT := SYSTEM.VAL(TglIndexMaterialEXT, GetProcAddress('glIndexMaterialEXT'));
END Read_GL_EXT_index_material;

PROCEDURE Read_GL_EXT_light_texture*;
BEGIN
	ApplyTextureEXT := SYSTEM.VAL(TglApplyTextureEXT, GetProcAddress('glApplyTextureEXT'));
	TextureLightEXT := SYSTEM.VAL(TglTextureLightEXT, GetProcAddress('glTextureLightEXT'));
	TextureMaterialEXT := SYSTEM.VAL(TglTextureMaterialEXT, GetProcAddress('glTextureMaterialEXT'));
END Read_GL_EXT_light_texture;

PROCEDURE Read_GL_EXT_multi_draw_arrays*;
BEGIN
	MultiDrawArraysEXT := SYSTEM.VAL(TglMultiDrawArraysEXT, GetProcAddress('glMultiDrawArraysEXT'));
	MultiDrawElementsEXT := SYSTEM.VAL(TglMultiDrawElementsEXT, GetProcAddress('glMultiDrawElementsEXT'));
END Read_GL_EXT_multi_draw_arrays;

PROCEDURE Read_GL_EXT_multisample*;
BEGIN
	SampleMaskEXT := SYSTEM.VAL(TglSampleMaskEXT, GetProcAddress('glSampleMaskEXT'));
	SamplePatternEXT := SYSTEM.VAL(TglSamplePatternEXT, GetProcAddress('glSamplePatternEXT'));
END Read_GL_EXT_multisample;

PROCEDURE Read_GL_EXT_paletted_texture*;
BEGIN
	ColorTableEXT := SYSTEM.VAL(TglColorTableEXT, GetProcAddress('glColorTableEXT'));
	GetColorTableEXT := SYSTEM.VAL(TglGetColorTableEXT, GetProcAddress('glGetColorTableEXT'));
	GetColorTableParameterivEXT := SYSTEM.VAL(TglGetColorTableParameterivEXT, GetProcAddress('glGetColorTableParameterivEXT'));
	GetColorTableParameterfvEXT := SYSTEM.VAL(TglGetColorTableParameterfvEXT, GetProcAddress('glGetColorTableParameterfvEXT'));
END Read_GL_EXT_paletted_texture;

PROCEDURE Read_GL_EXT_pixel_transform*;
BEGIN
	PixelTransformParameteriEXT := SYSTEM.VAL(TglPixelTransformParameteriEXT, GetProcAddress('glPixelTransformParameteriEXT'));
	PixelTransformParameterfEXT := SYSTEM.VAL(TglPixelTransformParameterfEXT, GetProcAddress('glPixelTransformParameterfEXT'));
	PixelTransformParameterivEXT := SYSTEM.VAL(TglPixelTransformParameterivEXT, GetProcAddress('glPixelTransformParameterivEXT'));
	PixelTransformParameterfvEXT := SYSTEM.VAL(TglPixelTransformParameterfvEXT, GetProcAddress('glPixelTransformParameterfvEXT'));
END Read_GL_EXT_pixel_transform;

PROCEDURE Read_GL_EXT_point_parameters*;
BEGIN
	PointParameterfEXT := SYSTEM.VAL(TglPointParameterfEXT, GetProcAddress('glPointParameterfEXT'));
	PointParameterfvEXT := SYSTEM.VAL(TglPointParameterfvEXT, GetProcAddress('glPointParameterfvEXT'));
END Read_GL_EXT_point_parameters;

PROCEDURE Read_GL_EXT_polygon_offset*;
BEGIN
	PolygonOffsetEXT := SYSTEM.VAL(TglPolygonOffsetEXT, GetProcAddress('glPolygonOffsetEXT'));
END Read_GL_EXT_polygon_offset;

PROCEDURE Read_GL_EXT_secondary_color*;
BEGIN
	SecondaryColor3bEXT := SYSTEM.VAL(TglSecondaryColor3bEXT, GetProcAddress('glSecondaryColor3bEXT'));
	SecondaryColor3bvEXT := SYSTEM.VAL(TglSecondaryColor3bvEXT, GetProcAddress('glSecondaryColor3bvEXT'));
	SecondaryColor3dEXT := SYSTEM.VAL(TglSecondaryColor3dEXT, GetProcAddress('glSecondaryColor3dEXT'));
	SecondaryColor3dvEXT := SYSTEM.VAL(TglSecondaryColor3dvEXT, GetProcAddress('glSecondaryColor3dvEXT'));
	SecondaryColor3fEXT := SYSTEM.VAL(TglSecondaryColor3fEXT, GetProcAddress('glSecondaryColor3fEXT'));
	SecondaryColor3fvEXT := SYSTEM.VAL(TglSecondaryColor3fvEXT, GetProcAddress('glSecondaryColor3fvEXT'));
	SecondaryColor3iEXT := SYSTEM.VAL(TglSecondaryColor3iEXT, GetProcAddress('glSecondaryColor3iEXT'));
	SecondaryColor3ivEXT := SYSTEM.VAL(TglSecondaryColor3ivEXT, GetProcAddress('glSecondaryColor3ivEXT'));
	SecondaryColor3sEXT := SYSTEM.VAL(TglSecondaryColor3sEXT, GetProcAddress('glSecondaryColor3sEXT'));
	SecondaryColor3svEXT := SYSTEM.VAL(TglSecondaryColor3svEXT, GetProcAddress('glSecondaryColor3svEXT'));
	SecondaryColor3ubEXT := SYSTEM.VAL(TglSecondaryColor3ubEXT, GetProcAddress('glSecondaryColor3ubEXT'));
	SecondaryColor3ubvEXT := SYSTEM.VAL(TglSecondaryColor3ubvEXT, GetProcAddress('glSecondaryColor3ubvEXT'));
	SecondaryColor3uiEXT := SYSTEM.VAL(TglSecondaryColor3uiEXT, GetProcAddress('glSecondaryColor3uiEXT'));
	SecondaryColor3uivEXT := SYSTEM.VAL(TglSecondaryColor3uivEXT, GetProcAddress('glSecondaryColor3uivEXT'));
	SecondaryColor3usEXT := SYSTEM.VAL(TglSecondaryColor3usEXT, GetProcAddress('glSecondaryColor3usEXT'));
	SecondaryColor3usvEXT := SYSTEM.VAL(TglSecondaryColor3usvEXT, GetProcAddress('glSecondaryColor3usvEXT'));
	SecondaryColorPointerEXT := SYSTEM.VAL(TglSecondaryColorPointerEXT, GetProcAddress('glSecondaryColorPointerEXT'));
END Read_GL_EXT_secondary_color;

PROCEDURE Read_GL_EXT_stencil_two_side*;
BEGIN
	ActiveStencilFaceEXT := SYSTEM.VAL(TglActiveStencilFaceEXT, GetProcAddress('glActiveStencilFaceEXT'));
END Read_GL_EXT_stencil_two_side;

PROCEDURE Read_GL_EXT_subtexture*;
BEGIN
	TexSubImage1DEXT := SYSTEM.VAL(TglTexSubImage1DEXT, GetProcAddress('glTexSubImage1DEXT'));
	TexSubImage2DEXT := SYSTEM.VAL(TglTexSubImage2DEXT, GetProcAddress('glTexSubImage2DEXT'));
END Read_GL_EXT_subtexture;

PROCEDURE Read_GL_EXT_texture3D*;
BEGIN
	TexImage3DEXT := SYSTEM.VAL(TglTexImage3DEXT, GetProcAddress('glTexImage3DEXT'));
	TexSubImage3DEXT := SYSTEM.VAL(TglTexSubImage3DEXT, GetProcAddress('glTexSubImage3DEXT'));
END Read_GL_EXT_texture3D;

PROCEDURE Read_GL_EXT_texture_object*;
BEGIN
	AreTexturesResidentEXT := SYSTEM.VAL(TglAreTexturesResidentEXT, GetProcAddress('glAreTexturesResidentEXT'));
	BindTextureEXT := SYSTEM.VAL(TglBindTextureEXT, GetProcAddress('glBindTextureEXT'));
	DeleteTexturesEXT := SYSTEM.VAL(TglDeleteTexturesEXT, GetProcAddress('glDeleteTexturesEXT'));
	GenTexturesEXT := SYSTEM.VAL(TglGenTexturesEXT, GetProcAddress('glGenTexturesEXT'));
	IsTextureEXT := SYSTEM.VAL(TglIsTextureEXT, GetProcAddress('glIsTextureEXT'));
	PrioritizeTexturesEXT := SYSTEM.VAL(TglPrioritizeTexturesEXT, GetProcAddress('glPrioritizeTexturesEXT'));
END Read_GL_EXT_texture_object;

PROCEDURE Read_GL_EXT_texture_perturb_normal*;
BEGIN
	TextureNormalEXT := SYSTEM.VAL(TglTextureNormalEXT, GetProcAddress('glTextureNormalEXT'));
END Read_GL_EXT_texture_perturb_normal;

PROCEDURE Read_GL_EXT_vertex_array*;
BEGIN
	ArrayElementEXT := SYSTEM.VAL(TglArrayElementEXT, GetProcAddress('glArrayElementEXT'));
	ColorPointerEXT := SYSTEM.VAL(TglColorPointerEXT, GetProcAddress('glColorPointerEXT'));
	DrawArraysEXT := SYSTEM.VAL(TglDrawArraysEXT, GetProcAddress('glDrawArraysEXT'));
	EdgeFlagPointerEXT := SYSTEM.VAL(TglEdgeFlagPointerEXT, GetProcAddress('glEdgeFlagPointerEXT'));
	GetPointervEXT := SYSTEM.VAL(TglGetPointervEXT, GetProcAddress('glGetPointervEXT'));
	IndexPointerEXT := SYSTEM.VAL(TglIndexPointerEXT, GetProcAddress('glIndexPointerEXT'));
	NormalPointerEXT := SYSTEM.VAL(TglNormalPointerEXT, GetProcAddress('glNormalPointerEXT'));
	TexCoordPointerEXT := SYSTEM.VAL(TglTexCoordPointerEXT, GetProcAddress('glTexCoordPointerEXT'));
	VertexPointerEXT := SYSTEM.VAL(TglVertexPointerEXT, GetProcAddress('glVertexPointerEXT'));
END Read_GL_EXT_vertex_array;

PROCEDURE Read_GL_EXT_vertex_shader*;
BEGIN
	BeginVertexShaderEXT := SYSTEM.VAL(TglBeginVertexShaderEXT, GetProcAddress('glBeginVertexShaderEXT'));
	EndVertexShaderEXT := SYSTEM.VAL(TglEndVertexShaderEXT, GetProcAddress('glEndVertexShaderEXT'));
	BindVertexShaderEXT := SYSTEM.VAL(TglBindVertexShaderEXT, GetProcAddress('glBindVertexShaderEXT'));
	GenVertexShadersEXT := SYSTEM.VAL(TglGenVertexShadersEXT, GetProcAddress('glGenVertexShadersEXT'));
	DeleteVertexShaderEXT := SYSTEM.VAL(TglDeleteVertexShaderEXT, GetProcAddress('glDeleteVertexShaderEXT'));
	ShaderOp1EXT := SYSTEM.VAL(TglShaderOp1EXT, GetProcAddress('glShaderOp1EXT'));
	ShaderOp2EXT := SYSTEM.VAL(TglShaderOp2EXT, GetProcAddress('glShaderOp2EXT'));
	ShaderOp3EXT := SYSTEM.VAL(TglShaderOp3EXT, GetProcAddress('glShaderOp3EXT'));
	SwizzleEXT := SYSTEM.VAL(TglSwizzleEXT, GetProcAddress('glSwizzleEXT'));
	WriteMaskEXT := SYSTEM.VAL(TglWriteMaskEXT, GetProcAddress('glWriteMaskEXT'));
	InsertComponentEXT := SYSTEM.VAL(TglInsertComponentEXT, GetProcAddress('glInsertComponentEXT'));
	ExtractComponentEXT := SYSTEM.VAL(TglExtractComponentEXT, GetProcAddress('glExtractComponentEXT'));
	GenSymbolsEXT := SYSTEM.VAL(TglGenSymbolsEXT, GetProcAddress('glGenSymbolsEXT'));
	SetInvariantEXT := SYSTEM.VAL(TglSetInvariantEXT, GetProcAddress('glSetInvariantEXT'));
	SetLocalConstantEXT := SYSTEM.VAL(TglSetLocalConstantEXT, GetProcAddress('glSetLocalConstantEXT'));
	VariantbvEXT := SYSTEM.VAL(TglVariantbvEXT, GetProcAddress('glVariantbvEXT'));
	VariantsvEXT := SYSTEM.VAL(TglVariantsvEXT, GetProcAddress('glVariantsvEXT'));
	VariantivEXT := SYSTEM.VAL(TglVariantivEXT, GetProcAddress('glVariantivEXT'));
	VariantfvEXT := SYSTEM.VAL(TglVariantfvEXT, GetProcAddress('glVariantfvEXT'));
	VariantdvEXT := SYSTEM.VAL(TglVariantdvEXT, GetProcAddress('glVariantdvEXT'));
	VariantubvEXT := SYSTEM.VAL(TglVariantubvEXT, GetProcAddress('glVariantubvEXT'));
	VariantusvEXT := SYSTEM.VAL(TglVariantusvEXT, GetProcAddress('glVariantusvEXT'));
	VariantuivEXT := SYSTEM.VAL(TglVariantuivEXT, GetProcAddress('glVariantuivEXT'));
	VariantPointerEXT := SYSTEM.VAL(TglVariantPointerEXT, GetProcAddress('glVariantPointerEXT'));
	EnableVariantClientStateEXT := SYSTEM.VAL(TglEnableVariantClientStateEXT, GetProcAddress('glEnableVariantClientStateEXT'));
	DisableVariantClientStateEXT := SYSTEM.VAL(TglDisableVariantClientStateEXT, GetProcAddress('glDisableVariantClientStateEXT'));
	BindLightParameterEXT := SYSTEM.VAL(TglBindLightParameterEXT, GetProcAddress('glBindLightParameterEXT'));
	BindMaterialParameterEXT := SYSTEM.VAL(TglBindMaterialParameterEXT, GetProcAddress('glBindMaterialParameterEXT'));
	BindTexGenParameterEXT := SYSTEM.VAL(TglBindTexGenParameterEXT, GetProcAddress('glBindTexGenParameterEXT'));
	BindTextureUnitParameterEXT := SYSTEM.VAL(TglBindTextureUnitParameterEXT, GetProcAddress('glBindTextureUnitParameterEXT'));
	BindParameterEXT := SYSTEM.VAL(TglBindParameterEXT, GetProcAddress('glBindParameterEXT'));
	IsVariantEnabledEXT := SYSTEM.VAL(TglIsVariantEnabledEXT, GetProcAddress('glIsVariantEnabledEXT'));
	GetVariantBooleanvEXT := SYSTEM.VAL(TglGetVariantBooleanvEXT, GetProcAddress('glGetVariantBooleanvEXT'));
	GetVariantIntegervEXT := SYSTEM.VAL(TglGetVariantIntegervEXT, GetProcAddress('glGetVariantIntegervEXT'));
	GetVariantFloatvEXT := SYSTEM.VAL(TglGetVariantFloatvEXT, GetProcAddress('glGetVariantFloatvEXT'));
	GetVariantPointervEXT := SYSTEM.VAL(TglGetVariantPointervEXT, GetProcAddress('glGetVariantPointervEXT'));
	GetInvariantBooleanvEXT := SYSTEM.VAL(TglGetInvariantBooleanvEXT, GetProcAddress('glGetInvariantBooleanvEXT'));
	GetInvariantIntegervEXT := SYSTEM.VAL(TglGetInvariantIntegervEXT, GetProcAddress('glGetInvariantIntegervEXT'));
	GetInvariantFloatvEXT := SYSTEM.VAL(TglGetInvariantFloatvEXT, GetProcAddress('glGetInvariantFloatvEXT'));
	GetLocalConstantBooleanvEXT := SYSTEM.VAL(TglGetLocalConstantBooleanvEXT, GetProcAddress('glGetLocalConstantBooleanvEXT'));
	GetLocalConstantIntegervEXT := SYSTEM.VAL(TglGetLocalConstantIntegervEXT, GetProcAddress('glGetLocalConstantIntegervEXT'));
	GetLocalConstantFloatvEXT := SYSTEM.VAL(TglGetLocalConstantFloatvEXT, GetProcAddress('glGetLocalConstantFloatvEXT'));
END Read_GL_EXT_vertex_shader;

PROCEDURE Read_GL_EXT_vertex_weighting*;
BEGIN
	VertexWeightfEXT := SYSTEM.VAL(TglVertexWeightfEXT, GetProcAddress('glVertexWeightfEXT'));
	VertexWeightfvEXT := SYSTEM.VAL(TglVertexWeightfvEXT, GetProcAddress('glVertexWeightfvEXT'));
	VertexWeightPointerEXT := SYSTEM.VAL(TglVertexWeightPointerEXT, GetProcAddress('glVertexWeightPointerEXT'));
END Read_GL_EXT_vertex_weighting;

PROCEDURE Read_GL_EXT_depth_bounds_test*;
BEGIN
	ImageTransformParameteriHP := SYSTEM.VAL(TglImageTransformParameteriHP, GetProcAddress('glImageTransformParameteriHP'));
	DepthBoundsEXT := SYSTEM.VAL(TglDepthBoundsEXT, GetProcAddress('glDepthBoundsEXT'));
END Read_GL_EXT_depth_bounds_test;

PROCEDURE Read_GL_EXT_blend_equation_separate*;
BEGIN
	BlendEquationSeparateEXT := SYSTEM.VAL(TglBlendEquationSeparateEXT, GetProcAddress('glBlendEquationSeparateEXT'));
END Read_GL_EXT_blend_equation_separate;

PROCEDURE Read_GL_EXT_stencil_clear_tag*;
BEGIN
	StencilClearTagEXT := SYSTEM.VAL(TglStencilClearTagEXT, GetProcAddress('glStencilClearTagEXT'));
END Read_GL_EXT_stencil_clear_tag;

PROCEDURE Read_GL_EXT_framebuffer_blit*;
BEGIN
	BlitFramebufferEXT := SYSTEM.VAL(TglBlitFramebufferEXT, GetProcAddress('glBlitFramebufferEXT'));
END Read_GL_EXT_framebuffer_blit;

PROCEDURE Read_GL_EXT_framebuffer_multisample*;
BEGIN
	RenderbufferStorageMultisampleEXT := SYSTEM.VAL(TglRenderbufferStorageMultisampleEXT, GetProcAddress('glRenderbufferStorageMultisampleEXT'));
END Read_GL_EXT_framebuffer_multisample;

PROCEDURE Read_GL_EXT_timer_query*;
BEGIN
	GetQueryObjecti64vEXT := SYSTEM.VAL(TglGetQueryObjecti64vEXT, GetProcAddress('glGetQueryObjecti64vEXT'));
	GetQueryObjectui64vEXT := SYSTEM.VAL(TglGetQueryObjectui64vEXT, GetProcAddress('glGetQueryObjectui64vEXT'));
END Read_GL_EXT_timer_query;

PROCEDURE Read_GL_EXT_gpu_program_parameters*;
BEGIN
	ProgramEnvParameters4fvEXT := SYSTEM.VAL(TglProgramEnvParameters4fvEXT, GetProcAddress('glProgramEnvParameters4fvEXT'));
	ProgramLocalParameters4fvEXT := SYSTEM.VAL(TglProgramLocalParameters4fvEXT, GetProcAddress('glProgramLocalParameters4fvEXT'));
END Read_GL_EXT_gpu_program_parameters;

PROCEDURE Read_GL_EXT_bindable_uniform*;
BEGIN
	UniformBufferEXT := SYSTEM.VAL(TglUniformBufferEXT, GetProcAddress('glUniformBufferEXT'));
	GetUniformBufferSizeEXT := SYSTEM.VAL(TglGetUniformBufferSizeEXT, GetProcAddress('glGetUniformBufferSizeEXT'));
	GetUniformOffsetEXT := SYSTEM.VAL(TglGetUniformOffsetEXT, GetProcAddress('glGetUniformOffsetEXT'));
END Read_GL_EXT_bindable_uniform;

PROCEDURE Read_GL_EXT_draw_buffers2*;
BEGIN
	ColorMaskIndexedEXT := SYSTEM.VAL(TglColorMaskIndexedEXT, GetProcAddress('glColorMaskIndexedEXT'));
	GetBooleanIndexedvEXT := SYSTEM.VAL(TglGetBooleanIndexedvEXT, GetProcAddress('glGetBooleanIndexedvEXT'));
	GetIntegerIndexedvEXT := SYSTEM.VAL(TglGetIntegerIndexedvEXT, GetProcAddress('glGetIntegerIndexedvEXT'));
	EnableIndexedEXT := SYSTEM.VAL(TglEnableIndexedEXT, GetProcAddress('glEnableIndexedEXT'));
	DisableIndexedEXT := SYSTEM.VAL(TglDisableIndexedEXT, GetProcAddress('glDisableIndexedEXT'));
	IsEnabledIndexedEXT := SYSTEM.VAL(TglIsEnabledIndexedEXT, GetProcAddress('glIsEnabledIndexedEXT'));
END Read_GL_EXT_draw_buffers2;

PROCEDURE Read_GL_EXT_draw_instanced*;
BEGIN
	DrawArraysInstancedEXT := SYSTEM.VAL(TglDrawArraysInstancedEXT, GetProcAddress('glDrawArraysInstancedEXT'));
	DrawElementsInstancedEXT := SYSTEM.VAL(TglDrawElementsInstancedEXT, GetProcAddress('glDrawElementsInstancedEXT'));
END Read_GL_EXT_draw_instanced;

PROCEDURE Read_GL_EXT_geometry_shader4*;
BEGIN
	ProgramParameteriEXT := SYSTEM.VAL(TglProgramParameteriEXT, GetProcAddress('glProgramParameteriEXT'));
	FramebufferTextureEXT := SYSTEM.VAL(TglFramebufferTextureEXT, GetProcAddress('glFramebufferTextureEXT'));
	FramebufferTextureFaceEXT := SYSTEM.VAL(TglFramebufferTextureFaceEXT, GetProcAddress('glFramebufferTextureFaceEXT'));
END Read_GL_EXT_geometry_shader4;

PROCEDURE Read_GL_EXT_gpu_shader4*;
BEGIN
	VertexAttribI1iEXT := SYSTEM.VAL(TglVertexAttribI1iEXT, GetProcAddress('glVertexAttribI1iEXT'));
	VertexAttribI2iEXT := SYSTEM.VAL(TglVertexAttribI2iEXT, GetProcAddress('glVertexAttribI2iEXT'));
	VertexAttribI3iEXT := SYSTEM.VAL(TglVertexAttribI3iEXT, GetProcAddress('glVertexAttribI3iEXT'));
	VertexAttribI4iEXT := SYSTEM.VAL(TglVertexAttribI4iEXT, GetProcAddress('glVertexAttribI4iEXT'));
	VertexAttribI1uiEXT := SYSTEM.VAL(TglVertexAttribI1uiEXT, GetProcAddress('glVertexAttribI1uiEXT'));
	VertexAttribI2uiEXT := SYSTEM.VAL(TglVertexAttribI2uiEXT, GetProcAddress('glVertexAttribI2uiEXT'));
	VertexAttribI3uiEXT := SYSTEM.VAL(TglVertexAttribI3uiEXT, GetProcAddress('glVertexAttribI3uiEXT'));
	VertexAttribI4uiEXT := SYSTEM.VAL(TglVertexAttribI4uiEXT, GetProcAddress('glVertexAttribI4uiEXT'));
	VertexAttribI1ivEXT := SYSTEM.VAL(TglVertexAttribI1ivEXT, GetProcAddress('glVertexAttribI1ivEXT'));
	VertexAttribI2ivEXT := SYSTEM.VAL(TglVertexAttribI2ivEXT, GetProcAddress('glVertexAttribI2ivEXT'));
	VertexAttribI3ivEXT := SYSTEM.VAL(TglVertexAttribI3ivEXT, GetProcAddress('glVertexAttribI3ivEXT'));
	VertexAttribI4ivEXT := SYSTEM.VAL(TglVertexAttribI4ivEXT, GetProcAddress('glVertexAttribI4ivEXT'));
	VertexAttribI1uivEXT := SYSTEM.VAL(TglVertexAttribI1uivEXT, GetProcAddress('glVertexAttribI1uivEXT'));
	VertexAttribI2uivEXT := SYSTEM.VAL(TglVertexAttribI2uivEXT, GetProcAddress('glVertexAttribI2uivEXT'));
	VertexAttribI3uivEXT := SYSTEM.VAL(TglVertexAttribI3uivEXT, GetProcAddress('glVertexAttribI3uivEXT'));
	VertexAttribI4uivEXT := SYSTEM.VAL(TglVertexAttribI4uivEXT, GetProcAddress('glVertexAttribI4uivEXT'));
	VertexAttribI4bvEXT := SYSTEM.VAL(TglVertexAttribI4bvEXT, GetProcAddress('glVertexAttribI4bvEXT'));
	VertexAttribI4svEXT := SYSTEM.VAL(TglVertexAttribI4svEXT, GetProcAddress('glVertexAttribI4svEXT'));
	VertexAttribI4ubvEXT := SYSTEM.VAL(TglVertexAttribI4ubvEXT, GetProcAddress('glVertexAttribI4ubvEXT'));
	VertexAttribI4usvEXT := SYSTEM.VAL(TglVertexAttribI4usvEXT, GetProcAddress('glVertexAttribI4usvEXT'));
	VertexAttribIPointerEXT := SYSTEM.VAL(TglVertexAttribIPointerEXT, GetProcAddress('glVertexAttribIPointerEXT'));
	GetVertexAttribIivEXT := SYSTEM.VAL(TglGetVertexAttribIivEXT, GetProcAddress('glGetVertexAttribIivEXT'));
	GetVertexAttribIuivEXT := SYSTEM.VAL(TglGetVertexAttribIuivEXT, GetProcAddress('glGetVertexAttribIuivEXT'));
	Uniform1uiEXT := SYSTEM.VAL(TglUniform1uiEXT, GetProcAddress('glUniform1uiEXT'));
	Uniform2uiEXT := SYSTEM.VAL(TglUniform2uiEXT, GetProcAddress('glUniform2uiEXT'));
	Uniform3uiEXT := SYSTEM.VAL(TglUniform3uiEXT, GetProcAddress('glUniform3uiEXT'));
	Uniform4uiEXT := SYSTEM.VAL(TglUniform4uiEXT, GetProcAddress('glUniform4uiEXT'));
	Uniform1uivEXT := SYSTEM.VAL(TglUniform1uivEXT, GetProcAddress('glUniform1uivEXT'));
	Uniform2uivEXT := SYSTEM.VAL(TglUniform2uivEXT, GetProcAddress('glUniform2uivEXT'));
	Uniform3uivEXT := SYSTEM.VAL(TglUniform3uivEXT, GetProcAddress('glUniform3uivEXT'));
	Uniform4uivEXT := SYSTEM.VAL(TglUniform4uivEXT, GetProcAddress('glUniform4uivEXT'));
	GetUniformuivEXT := SYSTEM.VAL(TglGetUniformuivEXT, GetProcAddress('glGetUniformuivEXT'));
	XglBindFragDataLocationEXT := SYSTEM.VAL(TglBindFragDataLocationEXT, GetProcAddress('glBindFragDataLocationEXT'));
	XglGetFragDataLocationEXT := SYSTEM.VAL(TglGetFragDataLocationEXT, GetProcAddress('glGetFragDataLocationEXT'));
END Read_GL_EXT_gpu_shader4;

PROCEDURE Read_GL_EXT_texture_array*;
BEGIN
	FramebufferTextureLayerEXT := SYSTEM.VAL(TglFramebufferTextureLayerEXT, GetProcAddress('glFramebufferTextureLayerEXT'));
END Read_GL_EXT_texture_array;

PROCEDURE Read_GL_EXT_texture_buffer_object*;
BEGIN
	TexBufferEXT := SYSTEM.VAL(TglTexBufferEXT, GetProcAddress('glTexBufferEXT'));
END Read_GL_EXT_texture_buffer_object;

PROCEDURE Read_GL_EXT_texture_integer*;
BEGIN
	ClearColorIiEXT := SYSTEM.VAL(TglClearColorIiEXT, GetProcAddress('glClearColorIiEXT'));
	ClearColorIuiEXT := SYSTEM.VAL(TglClearColorIuiEXT, GetProcAddress('glClearColorIuiEXT'));
	TexParameterIivEXT := SYSTEM.VAL(TglTexParameterIivEXT, GetProcAddress('glTexParameterIivEXT'));
	TexParameterIuivEXT := SYSTEM.VAL(TglTexParameterIuivEXT, GetProcAddress('glTexParameterIuivEXT'));
	GetTexParameterIivEXT := SYSTEM.VAL(TglGetTexParameterIivEXT, GetProcAddress('glGetTexParameterIivEXT'));
	GetTexParameterIiuvEXT := SYSTEM.VAL(TglGetTexParameterIiuvEXT, GetProcAddress('glGetTexParameterIiuvEXT'));
END Read_GL_EXT_texture_integer;

PROCEDURE Read_GL_EXT_transform_feedback*;
BEGIN
	BeginTransformFeedbackEXT := SYSTEM.VAL(TglBeginTransformFeedbackEXT, GetProcAddress('glBeginTransformFeedbackEXT'));
	EndTransformFeedbackEXT := SYSTEM.VAL(TglEndTransformFeedbackEXT, GetProcAddress('glEndTransformFeedbackEXT'));
	BindBufferRangeEXT := SYSTEM.VAL(TglBindBufferRangeEXT, GetProcAddress('glBindBufferRangeEXT'));
	BindBufferOffsetEXT := SYSTEM.VAL(TglBindBufferOffsetEXT, GetProcAddress('glBindBufferOffsetEXT'));
	BindBufferBaseEXT := SYSTEM.VAL(TglBindBufferBaseEXT, GetProcAddress('glBindBufferBaseEXT'));
	TransformFeedbackVaryingsEXT := SYSTEM.VAL(TglTransformFeedbackVaryingsEXT, GetProcAddress('glTransformFeedbackVaryingsEXT'));
	GetTransformFeedbackVaryingEXT := SYSTEM.VAL(TglGetTransformFeedbackVaryingEXT, GetProcAddress('glGetTransformFeedbackVaryingEXT'));
END Read_GL_EXT_transform_feedback;

PROCEDURE Read_GL_EXT_direct_state_access*;
BEGIN
	ClientAttribDefaultEXT := SYSTEM.VAL(TglClientAttribDefaultEXT, GetProcAddress('glClientAttribDefaultEXT'));
	PushClientAttribDefaultEXT := SYSTEM.VAL(TglPushClientAttribDefaultEXT, GetProcAddress('glPushClientAttribDefaultEXT'));
	MatrixLoadfEXT := SYSTEM.VAL(TglMatrixLoadfEXT, GetProcAddress('glMatrixLoadfEXT'));
	MatrixLoaddEXT := SYSTEM.VAL(TglMatrixLoaddEXT, GetProcAddress('glMatrixLoaddEXT'));
	MatrixMultfEXT := SYSTEM.VAL(TglMatrixMultfEXT, GetProcAddress('glMatrixMultfEXT'));
	MatrixMultdEXT := SYSTEM.VAL(TglMatrixMultdEXT, GetProcAddress('glMatrixMultdEXT'));
	MatrixLoadIdentityEXT := SYSTEM.VAL(TglMatrixLoadIdentityEXT, GetProcAddress('glMatrixLoadIdentityEXT'));
	MatrixRotatefEXT := SYSTEM.VAL(TglMatrixRotatefEXT, GetProcAddress('glMatrixRotatefEXT'));
	MatrixRotatedEXT := SYSTEM.VAL(TglMatrixRotatedEXT, GetProcAddress('glMatrixRotatedEXT'));
	MatrixScalefEXT := SYSTEM.VAL(TglMatrixScalefEXT, GetProcAddress('glMatrixScalefEXT'));
	MatrixScaledEXT := SYSTEM.VAL(TglMatrixScaledEXT, GetProcAddress('glMatrixScaledEXT'));
	MatrixTranslatefEXT := SYSTEM.VAL(TglMatrixTranslatefEXT, GetProcAddress('glMatrixTranslatefEXT'));
	MatrixTranslatedEXT := SYSTEM.VAL(TglMatrixTranslatedEXT, GetProcAddress('glMatrixTranslatedEXT'));
	MatrixFrustumEXT := SYSTEM.VAL(TglMatrixFrustumEXT, GetProcAddress('glMatrixFrustumEXT'));
	MatrixOrthoEXT := SYSTEM.VAL(TglMatrixOrthoEXT, GetProcAddress('glMatrixOrthoEXT'));
	MatrixPopEXT := SYSTEM.VAL(TglMatrixPopEXT, GetProcAddress('glMatrixPopEXT'));
	MatrixPushEXT := SYSTEM.VAL(TglMatrixPushEXT, GetProcAddress('glMatrixPushEXT'));
	MatrixLoadTransposefEXT := SYSTEM.VAL(TglMatrixLoadTransposefEXT, GetProcAddress('glMatrixLoadTransposefEXT'));
	MatrixLoadTransposedEXT := SYSTEM.VAL(TglMatrixLoadTransposedEXT, GetProcAddress('glMatrixLoadTransposedEXT'));
	MatrixMultTransposefEXT := SYSTEM.VAL(TglMatrixMultTransposefEXT, GetProcAddress('glMatrixMultTransposefEXT'));
	MatrixMultTransposedEXT := SYSTEM.VAL(TglMatrixMultTransposedEXT, GetProcAddress('glMatrixMultTransposedEXT'));
	TextureParameterfEXT := SYSTEM.VAL(TglTextureParameterfEXT, GetProcAddress('glTextureParameterfEXT'));
	TextureParameterfvEXT := SYSTEM.VAL(TglTextureParameterfvEXT, GetProcAddress('glTextureParameterfvEXT'));
	TextureParameteriEXT := SYSTEM.VAL(TglTextureParameteriEXT, GetProcAddress('glTextureParameteriEXT'));
	TextureParameterivEXT := SYSTEM.VAL(TglTextureParameterivEXT, GetProcAddress('glTextureParameterivEXT'));
	TextureImage1DEXT := SYSTEM.VAL(TglTextureImage1DEXT, GetProcAddress('glTextureImage1DEXT'));
	TextureImage2DEXT := SYSTEM.VAL(TglTextureImage2DEXT, GetProcAddress('glTextureImage2DEXT'));
	TextureSubImage1DEXT := SYSTEM.VAL(TglTextureSubImage1DEXT, GetProcAddress('glTextureSubImage1DEXT'));
	TextureSubImage2DEXT := SYSTEM.VAL(TglTextureSubImage2DEXT, GetProcAddress('glTextureSubImage2DEXT'));
	CopyTextureImage1DEXT := SYSTEM.VAL(TglCopyTextureImage1DEXT, GetProcAddress('glCopyTextureImage1DEXT'));
	CopyTextureImage2DEXT := SYSTEM.VAL(TglCopyTextureImage2DEXT, GetProcAddress('glCopyTextureImage2DEXT'));
	CopyTextureSubImage1DEXT := SYSTEM.VAL(TglCopyTextureSubImage1DEXT, GetProcAddress('glCopyTextureSubImage1DEXT'));
	CopyTextureSubImage2DEXT := SYSTEM.VAL(TglCopyTextureSubImage2DEXT, GetProcAddress('glCopyTextureSubImage2DEXT'));
	GetTextureImageEXT := SYSTEM.VAL(TglGetTextureImageEXT, GetProcAddress('glGetTextureImageEXT'));
	GetTextureParameterfvEXT := SYSTEM.VAL(TglGetTextureParameterfvEXT, GetProcAddress('glGetTextureParameterfvEXT'));
	GetTextureParameterivEXT := SYSTEM.VAL(TglGetTextureParameterivEXT, GetProcAddress('glGetTextureParameterivEXT'));
	GetTextureLevelParameterfvEXT := SYSTEM.VAL(TglGetTextureLevelParameterfvEXT, GetProcAddress('glGetTextureLevelParameterfvEXT'));
	GetTextureLevelParameterivEXT := SYSTEM.VAL(TglGetTextureLevelParameterivEXT, GetProcAddress('glGetTextureLevelParameterivEXT'));
	TextureImage3DEXT := SYSTEM.VAL(TglTextureImage3DEXT, GetProcAddress('glTextureImage3DEXT'));
	TextureSubImage3DEXT := SYSTEM.VAL(TglTextureSubImage3DEXT, GetProcAddress('glTextureSubImage3DEXT'));
	CopyTextureSubImage3DEXT := SYSTEM.VAL(TglCopyTextureSubImage3DEXT, GetProcAddress('glCopyTextureSubImage3DEXT'));
	MultiTexParameterfEXT := SYSTEM.VAL(TglMultiTexParameterfEXT, GetProcAddress('glMultiTexParameterfEXT'));
	MultiTexParameterfvEXT := SYSTEM.VAL(TglMultiTexParameterfvEXT, GetProcAddress('glMultiTexParameterfvEXT'));
	MultiTexParameteriEXT := SYSTEM.VAL(TglMultiTexParameteriEXT, GetProcAddress('glMultiTexParameteriEXT'));
	MultiTexParameterivEXT := SYSTEM.VAL(TglMultiTexParameterivEXT, GetProcAddress('glMultiTexParameterivEXT'));
	MultiTexImage1DEXT := SYSTEM.VAL(TglMultiTexImage1DEXT, GetProcAddress('glMultiTexImage1DEXT'));
	MultiTexImage2DEXT := SYSTEM.VAL(TglMultiTexImage2DEXT, GetProcAddress('glMultiTexImage2DEXT'));
	MultiTexSubImage1DEXT := SYSTEM.VAL(TglMultiTexSubImage1DEXT, GetProcAddress('glMultiTexSubImage1DEXT'));
	MultiTexSubImage2DEXT := SYSTEM.VAL(TglMultiTexSubImage2DEXT, GetProcAddress('glMultiTexSubImage2DEXT'));
	CopyMultiTexImage1DEXT := SYSTEM.VAL(TglCopyMultiTexImage1DEXT, GetProcAddress('glCopyMultiTexImage1DEXT'));
	CopyMultiTexImage2DEXT := SYSTEM.VAL(TglCopyMultiTexImage2DEXT, GetProcAddress('glCopyMultiTexImage2DEXT'));
	CopyMultiTexSubImage1DEXT := SYSTEM.VAL(TglCopyMultiTexSubImage1DEXT, GetProcAddress('glCopyMultiTexSubImage1DEXT'));
	CopyMultiTexSubImage2DEXT := SYSTEM.VAL(TglCopyMultiTexSubImage2DEXT, GetProcAddress('glCopyMultiTexSubImage2DEXT'));
	GetMultiTexImageEXT := SYSTEM.VAL(TglGetMultiTexImageEXT, GetProcAddress('glGetMultiTexImageEXT'));
	GetMultiTexParameterfvEXT := SYSTEM.VAL(TglGetMultiTexParameterfvEXT, GetProcAddress('glGetMultiTexParameterfvEXT'));
	GetMultiTexParameterivEXT := SYSTEM.VAL(TglGetMultiTexParameterivEXT, GetProcAddress('glGetMultiTexParameterivEXT'));
	GetMultiTexLevelParameterfvEXT := SYSTEM.VAL(TglGetMultiTexLevelParameterfvEXT, GetProcAddress('glGetMultiTexLevelParameterfvEXT'));
	GetMultiTexLevelParameterivEXT := SYSTEM.VAL(TglGetMultiTexLevelParameterivEXT, GetProcAddress('glGetMultiTexLevelParameterivEXT'));
	MultiTexImage3DEXT := SYSTEM.VAL(TglMultiTexImage3DEXT, GetProcAddress('glMultiTexImage3DEXT'));
	MultiTexSubImage3DEXT := SYSTEM.VAL(TglMultiTexSubImage3DEXT, GetProcAddress('glMultiTexSubImage3DEXT'));
	CopyMultiTexSubImage3DEXT := SYSTEM.VAL(TglCopyMultiTexSubImage3DEXT, GetProcAddress('glCopyMultiTexSubImage3DEXT'));
	BindMultiTextureEXT := SYSTEM.VAL(TglBindMultiTextureEXT, GetProcAddress('glBindMultiTextureEXT'));
	EnableClientStateIndexedEXT := SYSTEM.VAL(TglEnableClientStateIndexedEXT, GetProcAddress('glEnableClientStateIndexedEXT'));
	DisableClientStateIndexedEXT := SYSTEM.VAL(TglDisableClientStateIndexedEXT, GetProcAddress('glDisableClientStateIndexedEXT'));
	MultiTexCoordPointerEXT := SYSTEM.VAL(TglMultiTexCoordPointerEXT, GetProcAddress('glMultiTexCoordPointerEXT'));
	MultiTexEnvfEXT := SYSTEM.VAL(TglMultiTexEnvfEXT, GetProcAddress('glMultiTexEnvfEXT'));
	MultiTexEnvfvEXT := SYSTEM.VAL(TglMultiTexEnvfvEXT, GetProcAddress('glMultiTexEnvfvEXT'));
	MultiTexEnviEXT := SYSTEM.VAL(TglMultiTexEnviEXT, GetProcAddress('glMultiTexEnviEXT'));
	MultiTexEnvivEXT := SYSTEM.VAL(TglMultiTexEnvivEXT, GetProcAddress('glMultiTexEnvivEXT'));
	MultiTexGendEXT := SYSTEM.VAL(TglMultiTexGendEXT, GetProcAddress('glMultiTexGendEXT'));
	MultiTexGendvEXT := SYSTEM.VAL(TglMultiTexGendvEXT, GetProcAddress('glMultiTexGendvEXT'));
	MultiTexGenfEXT := SYSTEM.VAL(TglMultiTexGenfEXT, GetProcAddress('glMultiTexGenfEXT'));
	MultiTexGenfvEXT := SYSTEM.VAL(TglMultiTexGenfvEXT, GetProcAddress('glMultiTexGenfvEXT'));
	MultiTexGeniEXT := SYSTEM.VAL(TglMultiTexGeniEXT, GetProcAddress('glMultiTexGeniEXT'));
	MultiTexGenivEXT := SYSTEM.VAL(TglMultiTexGenivEXT, GetProcAddress('glMultiTexGenivEXT'));
	GetMultiTexEnvfvEXT := SYSTEM.VAL(TglGetMultiTexEnvfvEXT, GetProcAddress('glGetMultiTexEnvfvEXT'));
	GetMultiTexEnvivEXT := SYSTEM.VAL(TglGetMultiTexEnvivEXT, GetProcAddress('glGetMultiTexEnvivEXT'));
	GetMultiTexGendvEXT := SYSTEM.VAL(TglGetMultiTexGendvEXT, GetProcAddress('glGetMultiTexGendvEXT'));
	GetMultiTexGenfvEXT := SYSTEM.VAL(TglGetMultiTexGenfvEXT, GetProcAddress('glGetMultiTexGenfvEXT'));
	GetMultiTexGenivEXT := SYSTEM.VAL(TglGetMultiTexGenivEXT, GetProcAddress('glGetMultiTexGenivEXT'));
	GetFloatIndexedvEXT := SYSTEM.VAL(TglGetFloatIndexedvEXT, GetProcAddress('glGetFloatIndexedvEXT'));
	GetDoubleIndexedvEXT := SYSTEM.VAL(TglGetDoubleIndexedvEXT, GetProcAddress('glGetDoubleIndexedvEXT'));
	GetPointerIndexedvEXT := SYSTEM.VAL(TglGetPointerIndexedvEXT, GetProcAddress('glGetPointerIndexedvEXT'));
	CompressedTextureImage3DEXT := SYSTEM.VAL(TglCompressedTextureImage3DEXT, GetProcAddress('glCompressedTextureImage3DEXT'));
	CompressedTextureImage2DEXT := SYSTEM.VAL(TglCompressedTextureImage2DEXT, GetProcAddress('glCompressedTextureImage2DEXT'));
	CompressedTextureImage1DEXT := SYSTEM.VAL(TglCompressedTextureImage1DEXT, GetProcAddress('glCompressedTextureImage1DEXT'));
	CompressedTextureSubImage3DEXT := SYSTEM.VAL(TglCompressedTextureSubImage3DEXT, GetProcAddress('glCompressedTextureSubImage3DEXT'));
	CompressedTextureSubImage2DEXT := SYSTEM.VAL(TglCompressedTextureSubImage2DEXT, GetProcAddress('glCompressedTextureSubImage2DEXT'));
	CompressedTextureSubImage1DEXT := SYSTEM.VAL(TglCompressedTextureSubImage1DEXT, GetProcAddress('glCompressedTextureSubImage1DEXT'));
	GetCompressedTextureImageEXT := SYSTEM.VAL(TglGetCompressedTextureImageEXT, GetProcAddress('glGetCompressedTextureImageEXT'));
	CompressedMultiTexImage3DEXT := SYSTEM.VAL(TglCompressedMultiTexImage3DEXT, GetProcAddress('glCompressedMultiTexImage3DEXT'));
	CompressedMultiTexImage2DEXT := SYSTEM.VAL(TglCompressedMultiTexImage2DEXT, GetProcAddress('glCompressedMultiTexImage2DEXT'));
	CompressedMultiTexImage1DEXT := SYSTEM.VAL(TglCompressedMultiTexImage1DEXT, GetProcAddress('glCompressedMultiTexImage1DEXT'));
	CompressedMultiTexSubImage3DEXT := SYSTEM.VAL(TglCompressedMultiTexSubImage3DEXT, GetProcAddress('glCompressedMultiTexSubImage3DEXT'));
	CompressedMultiTexSubImage2DEXT := SYSTEM.VAL(TglCompressedMultiTexSubImage2DEXT, GetProcAddress('glCompressedMultiTexSubImage2DEXT'));
	CompressedMultiTexSubImage1DEXT := SYSTEM.VAL(TglCompressedMultiTexSubImage1DEXT, GetProcAddress('glCompressedMultiTexSubImage1DEXT'));
	GetCompressedMultiTexImageEXT := SYSTEM.VAL(TglGetCompressedMultiTexImageEXT, GetProcAddress('glGetCompressedMultiTexImageEXT'));
	NamedProgramStringEXT := SYSTEM.VAL(TglNamedProgramStringEXT, GetProcAddress('glNamedProgramStringEXT'));
	NamedProgramLocalParameter4dEXT := SYSTEM.VAL(TglNamedProgramLocalParameter4dEXT, GetProcAddress('glNamedProgramLocalParameter4dEXT'));
	NamedProgramLocalParameter4dvEXT := SYSTEM.VAL(TglNamedProgramLocalParameter4dvEXT, GetProcAddress('glNamedProgramLocalParameter4dvEXT'));
	NamedProgramLocalParameter4fEXT := SYSTEM.VAL(TglNamedProgramLocalParameter4fEXT, GetProcAddress('glNamedProgramLocalParameter4fEXT'));
	NamedProgramLocalParameter4fvEXT := SYSTEM.VAL(TglNamedProgramLocalParameter4fvEXT, GetProcAddress('glNamedProgramLocalParameter4fvEXT'));
	GetNamedProgramLocalParameterdvEXT := SYSTEM.VAL(TglGetNamedProgramLocalParameterdvEXT, GetProcAddress('glGetNamedProgramLocalParameterdvEXT'));
	GetNamedProgramLocalParameterfvEXT := SYSTEM.VAL(TglGetNamedProgramLocalParameterfvEXT, GetProcAddress('glGetNamedProgramLocalParameterfvEXT'));
	GetNamedProgramivEXT := SYSTEM.VAL(TglGetNamedProgramivEXT, GetProcAddress('glGetNamedProgramivEXT'));
	GetNamedProgramStringEXT := SYSTEM.VAL(TglGetNamedProgramStringEXT, GetProcAddress('glGetNamedProgramStringEXT'));
	NamedProgramLocalParameters4fvEXT := SYSTEM.VAL(TglNamedProgramLocalParameters4fvEXT, GetProcAddress('glNamedProgramLocalParameters4fvEXT'));
	NamedProgramLocalParameterI4iEXT := SYSTEM.VAL(TglNamedProgramLocalParameterI4iEXT, GetProcAddress('glNamedProgramLocalParameterI4iEXT'));
	NamedProgramLocalParameterI4ivEXT := SYSTEM.VAL(TglNamedProgramLocalParameterI4ivEXT, GetProcAddress('glNamedProgramLocalParameterI4ivEXT'));
	NamedProgramLocalParametersI4ivEXT := SYSTEM.VAL(TglNamedProgramLocalParametersI4ivEXT, GetProcAddress('glNamedProgramLocalParametersI4ivEXT'));
	NamedProgramLocalParameterI4uiEXT := SYSTEM.VAL(TglNamedProgramLocalParameterI4uiEXT, GetProcAddress('glNamedProgramLocalParameterI4uiEXT'));
	NamedProgramLocalParameterI4uivEXT := SYSTEM.VAL(TglNamedProgramLocalParameterI4uivEXT, GetProcAddress('glNamedProgramLocalParameterI4uivEXT'));
	NamedProgramLocalParametersI4uivEXT := SYSTEM.VAL(TglNamedProgramLocalParametersI4uivEXT, GetProcAddress('glNamedProgramLocalParametersI4uivEXT'));
	GetNamedProgramLocalParameterIivEXT := SYSTEM.VAL(TglGetNamedProgramLocalParameterIivEXT, GetProcAddress('glGetNamedProgramLocalParameterIivEXT'));
	GetNamedProgramLocalParameterIuivEXT := SYSTEM.VAL(TglGetNamedProgramLocalParameterIuivEXT, GetProcAddress('glGetNamedProgramLocalParameterIuivEXT'));
	TextureParameterIivEXT := SYSTEM.VAL(TglTextureParameterIivEXT, GetProcAddress('glTextureParameterIivEXT'));
	TextureParameterIuivEXT := SYSTEM.VAL(TglTextureParameterIuivEXT, GetProcAddress('glTextureParameterIuivEXT'));
	GetTextureParameterIivEXT := SYSTEM.VAL(TglGetTextureParameterIivEXT, GetProcAddress('glGetTextureParameterIivEXT'));
	GetTextureParameterIuivEXT := SYSTEM.VAL(TglGetTextureParameterIuivEXT, GetProcAddress('glGetTextureParameterIuivEXT'));
	MultiTexParameterIivEXT := SYSTEM.VAL(TglMultiTexParameterIivEXT, GetProcAddress('glMultiTexParameterIivEXT'));
	MultiTexParameterIuivEXT := SYSTEM.VAL(TglMultiTexParameterIuivEXT, GetProcAddress('glMultiTexParameterIuivEXT'));
	GetMultiTexParameterIivEXT := SYSTEM.VAL(TglGetMultiTexParameterIivEXT, GetProcAddress('glGetMultiTexParameterIivEXT'));
	GetMultiTexParameterIuivEXT := SYSTEM.VAL(TglGetMultiTexParameterIuivEXT, GetProcAddress('glGetMultiTexParameterIuivEXT'));
	ProgramUniform1fEXT := SYSTEM.VAL(TglProgramUniform1fEXT, GetProcAddress('glProgramUniform1fEXT'));
	ProgramUniform2fEXT := SYSTEM.VAL(TglProgramUniform2fEXT, GetProcAddress('glProgramUniform2fEXT'));
	ProgramUniform3fEXT := SYSTEM.VAL(TglProgramUniform3fEXT, GetProcAddress('glProgramUniform3fEXT'));
	ProgramUniform4fEXT := SYSTEM.VAL(TglProgramUniform4fEXT, GetProcAddress('glProgramUniform4fEXT'));
	ProgramUniform1iEXT := SYSTEM.VAL(TglProgramUniform1iEXT, GetProcAddress('glProgramUniform1iEXT'));
	ProgramUniform2iEXT := SYSTEM.VAL(TglProgramUniform2iEXT, GetProcAddress('glProgramUniform2iEXT'));
	ProgramUniform3iEXT := SYSTEM.VAL(TglProgramUniform3iEXT, GetProcAddress('glProgramUniform3iEXT'));
	ProgramUniform4iEXT := SYSTEM.VAL(TglProgramUniform4iEXT, GetProcAddress('glProgramUniform4iEXT'));
	ProgramUniform1fvEXT := SYSTEM.VAL(TglProgramUniform1fvEXT, GetProcAddress('glProgramUniform1fvEXT'));
	ProgramUniform2fvEXT := SYSTEM.VAL(TglProgramUniform2fvEXT, GetProcAddress('glProgramUniform2fvEXT'));
	ProgramUniform3fvEXT := SYSTEM.VAL(TglProgramUniform3fvEXT, GetProcAddress('glProgramUniform3fvEXT'));
	ProgramUniform4fvEXT := SYSTEM.VAL(TglProgramUniform4fvEXT, GetProcAddress('glProgramUniform4fvEXT'));
	ProgramUniform1ivEXT := SYSTEM.VAL(TglProgramUniform1ivEXT, GetProcAddress('glProgramUniform1ivEXT'));
	ProgramUniform2ivEXT := SYSTEM.VAL(TglProgramUniform2ivEXT, GetProcAddress('glProgramUniform2ivEXT'));
	ProgramUniform3ivEXT := SYSTEM.VAL(TglProgramUniform3ivEXT, GetProcAddress('glProgramUniform3ivEXT'));
	ProgramUniform4ivEXT := SYSTEM.VAL(TglProgramUniform4ivEXT, GetProcAddress('glProgramUniform4ivEXT'));
	ProgramUniformMatrix2fvEXT := SYSTEM.VAL(TglProgramUniformMatrix2fvEXT, GetProcAddress('glProgramUniformMatrix2fvEXT'));
	ProgramUniformMatrix3fvEXT := SYSTEM.VAL(TglProgramUniformMatrix3fvEXT, GetProcAddress('glProgramUniformMatrix3fvEXT'));
	ProgramUniformMatrix4fvEXT := SYSTEM.VAL(TglProgramUniformMatrix4fvEXT, GetProcAddress('glProgramUniformMatrix4fvEXT'));
	ProgramUniformMatrix2x3fvEXT := SYSTEM.VAL(TglProgramUniformMatrix2x3fvEXT, GetProcAddress('glProgramUniformMatrix2x3fvEXT'));
	ProgramUniformMatrix3x2fvEXT := SYSTEM.VAL(TglProgramUniformMatrix3x2fvEXT, GetProcAddress('glProgramUniformMatrix3x2fvEXT'));
	ProgramUniformMatrix2x4fvEXT := SYSTEM.VAL(TglProgramUniformMatrix2x4fvEXT, GetProcAddress('glProgramUniformMatrix2x4fvEXT'));
	ProgramUniformMatrix4x2fvEXT := SYSTEM.VAL(TglProgramUniformMatrix4x2fvEXT, GetProcAddress('glProgramUniformMatrix4x2fvEXT'));
	ProgramUniformMatrix3x4fvEXT := SYSTEM.VAL(TglProgramUniformMatrix3x4fvEXT, GetProcAddress('glProgramUniformMatrix3x4fvEXT'));
	ProgramUniformMatrix4x3fvEXT := SYSTEM.VAL(TglProgramUniformMatrix4x3fvEXT, GetProcAddress('glProgramUniformMatrix4x3fvEXT'));
	ProgramUniform1uiEXT := SYSTEM.VAL(TglProgramUniform1uiEXT, GetProcAddress('glProgramUniform1uiEXT'));
	ProgramUniform2uiEXT := SYSTEM.VAL(TglProgramUniform2uiEXT, GetProcAddress('glProgramUniform2uiEXT'));
	ProgramUniform3uiEXT := SYSTEM.VAL(TglProgramUniform3uiEXT, GetProcAddress('glProgramUniform3uiEXT'));
	ProgramUniform4uiEXT := SYSTEM.VAL(TglProgramUniform4uiEXT, GetProcAddress('glProgramUniform4uiEXT'));
	ProgramUniform1uivEXT := SYSTEM.VAL(TglProgramUniform1uivEXT, GetProcAddress('glProgramUniform1uivEXT'));
	ProgramUniform2uivEXT := SYSTEM.VAL(TglProgramUniform2uivEXT, GetProcAddress('glProgramUniform2uivEXT'));
	ProgramUniform3uivEXT := SYSTEM.VAL(TglProgramUniform3uivEXT, GetProcAddress('glProgramUniform3uivEXT'));
	ProgramUniform4uivEXT := SYSTEM.VAL(TglProgramUniform4uivEXT, GetProcAddress('glProgramUniform4uivEXT'));
	NamedBufferDataEXT := SYSTEM.VAL(TglNamedBufferDataEXT, GetProcAddress('glNamedBufferDataEXT'));
	NamedBufferSubDataEXT := SYSTEM.VAL(TglNamedBufferSubDataEXT, GetProcAddress('glNamedBufferSubDataEXT'));
	MapNamedBufferEXT := SYSTEM.VAL(TglMapNamedBufferEXT, GetProcAddress('glMapNamedBufferEXT'));
	UnmapNamedBufferEXT := SYSTEM.VAL(TglUnmapNamedBufferEXT, GetProcAddress('glUnmapNamedBufferEXT'));
	MapNamedBufferRangeEXT := SYSTEM.VAL(TglMapNamedBufferRangeEXT, GetProcAddress('glMapNamedBufferRangeEXT'));
	FlushMappedNamedBufferRangeEXT := SYSTEM.VAL(TglFlushMappedNamedBufferRangeEXT, GetProcAddress('glFlushMappedNamedBufferRangeEXT'));
	NamedCopyBufferSubDataEXT := SYSTEM.VAL(TglNamedCopyBufferSubDataEXT, GetProcAddress('glNamedCopyBufferSubDataEXT'));
	GetNamedBufferParameterivEXT := SYSTEM.VAL(TglGetNamedBufferParameterivEXT, GetProcAddress('glGetNamedBufferParameterivEXT'));
	GetNamedBufferPointervEXT := SYSTEM.VAL(TglGetNamedBufferPointervEXT, GetProcAddress('glGetNamedBufferPointervEXT'));
	GetNamedBufferSubDataEXT := SYSTEM.VAL(TglGetNamedBufferSubDataEXT, GetProcAddress('glGetNamedBufferSubDataEXT'));
	TextureBufferEXT := SYSTEM.VAL(TglTextureBufferEXT, GetProcAddress('glTextureBufferEXT'));
	MultiTexBufferEXT := SYSTEM.VAL(TglMultiTexBufferEXT, GetProcAddress('glMultiTexBufferEXT'));
	NamedRenderbufferStorageEXT := SYSTEM.VAL(TglNamedRenderbufferStorageEXT, GetProcAddress('glNamedRenderbufferStorageEXT'));
	GetNamedRenderbufferParameterivEXT := SYSTEM.VAL(TglGetNamedRenderbufferParameterivEXT, GetProcAddress('glGetNamedRenderbufferParameterivEXT'));
	CheckNamedFramebufferStatusEXT := SYSTEM.VAL(TglCheckNamedFramebufferStatusEXT, GetProcAddress('glCheckNamedFramebufferStatusEXT'));
	NamedFramebufferTexture1DEXT := SYSTEM.VAL(TglNamedFramebufferTexture1DEXT, GetProcAddress('glNamedFramebufferTexture1DEXT'));
	NamedFramebufferTexture2DEXT := SYSTEM.VAL(TglNamedFramebufferTexture2DEXT, GetProcAddress('glNamedFramebufferTexture2DEXT'));
	NamedFramebufferTexture3DEXT := SYSTEM.VAL(TglNamedFramebufferTexture3DEXT, GetProcAddress('glNamedFramebufferTexture3DEXT'));
	NamedFramebufferRenderbufferEXT := SYSTEM.VAL(TglNamedFramebufferRenderbufferEXT, GetProcAddress('glNamedFramebufferRenderbufferEXT'));
	GetNamedFramebufferAttachmentParameterivEXT := SYSTEM.VAL(TglGetNamedFramebufferAttachmentParameterivEXT, GetProcAddress('glGetNamedFramebufferAttachmentParameterivEXT'));
	GenerateTextureMipmapEXT := SYSTEM.VAL(TglGenerateTextureMipmapEXT, GetProcAddress('glGenerateTextureMipmapEXT'));
	GenerateMultiTexMipmapEXT := SYSTEM.VAL(TglGenerateMultiTexMipmapEXT, GetProcAddress('glGenerateMultiTexMipmapEXT'));
	FramebufferDrawBufferEXT := SYSTEM.VAL(TglFramebufferDrawBufferEXT, GetProcAddress('glFramebufferDrawBufferEXT'));
	FramebufferDrawBuffersEXT := SYSTEM.VAL(TglFramebufferDrawBuffersEXT, GetProcAddress('glFramebufferDrawBuffersEXT'));
	FramebufferReadBufferEXT := SYSTEM.VAL(TglFramebufferReadBufferEXT, GetProcAddress('glFramebufferReadBufferEXT'));
	GetFramebufferParameterivEXT := SYSTEM.VAL(TglGetFramebufferParameterivEXT, GetProcAddress('glGetFramebufferParameterivEXT'));
	NamedRenderbufferStorageMultisampleEXT := SYSTEM.VAL(TglNamedRenderbufferStorageMultisampleEXT, GetProcAddress('glNamedRenderbufferStorageMultisampleEXT'));
	NamedRenderbufferStorageMultisampleCoverageEXT := SYSTEM.VAL(TglNamedRenderbufferStorageMultisampleCoverageEXT, GetProcAddress('glNamedRenderbufferStorageMultisampleCoverageEXT'));
	NamedFramebufferTextureEXT := SYSTEM.VAL(TglNamedFramebufferTextureEXT, GetProcAddress('glNamedFramebufferTextureEXT'));
	NamedFramebufferTextureLayerEXT := SYSTEM.VAL(TglNamedFramebufferTextureLayerEXT, GetProcAddress('glNamedFramebufferTextureLayerEXT'));
	NamedFramebufferTextureFaceEXT := SYSTEM.VAL(TglNamedFramebufferTextureFaceEXT, GetProcAddress('glNamedFramebufferTextureFaceEXT'));
	TextureRenderbufferEXT := SYSTEM.VAL(TglTextureRenderbufferEXT, GetProcAddress('glTextureRenderbufferEXT'));
	MultiTexRenderbufferEXT := SYSTEM.VAL(TglMultiTexRenderbufferEXT, GetProcAddress('glMultiTexRenderbufferEXT'));
	ProgramUniform1dEXT := SYSTEM.VAL(TglProgramUniform1dEXT, GetProcAddress('glProgramUniform1dEXT'));
	ProgramUniform2dEXT := SYSTEM.VAL(TglProgramUniform2dEXT, GetProcAddress('glProgramUniform2dEXT'));
	ProgramUniform3dEXT := SYSTEM.VAL(TglProgramUniform3dEXT, GetProcAddress('glProgramUniform3dEXT'));
	ProgramUniform4dEXT := SYSTEM.VAL(TglProgramUniform4dEXT, GetProcAddress('glProgramUniform4dEXT'));
	ProgramUniform1dvEXT := SYSTEM.VAL(TglProgramUniform1dvEXT, GetProcAddress('glProgramUniform1dvEXT'));
	ProgramUniform2dvEXT := SYSTEM.VAL(TglProgramUniform2dvEXT, GetProcAddress('glProgramUniform2dvEXT'));
	ProgramUniform3dvEXT := SYSTEM.VAL(TglProgramUniform3dvEXT, GetProcAddress('glProgramUniform3dvEXT'));
	ProgramUniform4dvEXT := SYSTEM.VAL(TglProgramUniform4dvEXT, GetProcAddress('glProgramUniform4dvEXT'));
	ProgramUniformMatrix2dvEXT := SYSTEM.VAL(TglProgramUniformMatrix2dvEXT, GetProcAddress('glProgramUniformMatrix2dvEXT'));
	ProgramUniformMatrix3dvEXT := SYSTEM.VAL(TglProgramUniformMatrix3dvEXT, GetProcAddress('glProgramUniformMatrix3dvEXT'));
	ProgramUniformMatrix4dvEXT := SYSTEM.VAL(TglProgramUniformMatrix4dvEXT, GetProcAddress('glProgramUniformMatrix4dvEXT'));
	ProgramUniformMatrix2x3dvEXT := SYSTEM.VAL(TglProgramUniformMatrix2x3dvEXT, GetProcAddress('glProgramUniformMatrix2x3dvEXT'));
	ProgramUniformMatrix2x4dvEXT := SYSTEM.VAL(TglProgramUniformMatrix2x4dvEXT, GetProcAddress('glProgramUniformMatrix2x4dvEXT'));
	ProgramUniformMatrix3x2dvEXT := SYSTEM.VAL(TglProgramUniformMatrix3x2dvEXT, GetProcAddress('glProgramUniformMatrix3x2dvEXT'));
	ProgramUniformMatrix3x4dvEXT := SYSTEM.VAL(TglProgramUniformMatrix3x4dvEXT, GetProcAddress('glProgramUniformMatrix3x4dvEXT'));
	ProgramUniformMatrix4x2dvEXT := SYSTEM.VAL(TglProgramUniformMatrix4x2dvEXT, GetProcAddress('glProgramUniformMatrix4x2dvEXT'));
	ProgramUniformMatrix4x3dvEXT := SYSTEM.VAL(TglProgramUniformMatrix4x3dvEXT, GetProcAddress('glProgramUniformMatrix4x3dvEXT'));
END Read_GL_EXT_direct_state_access;

PROCEDURE Read_GL_EXT_separate_shader_objects*;
BEGIN
	UseShaderProgramEXT := SYSTEM.VAL(TglUseShaderProgramEXT, GetProcAddress('glUseShaderProgramEXT'));
	ActiveProgramEXT := SYSTEM.VAL(TglActiveProgramEXT, GetProcAddress('glActiveProgramEXT'));
	XglCreateShaderProgramEXT := SYSTEM.VAL(TglCreateShaderProgramEXT, GetProcAddress('glCreateShaderProgramEXT'));
END Read_GL_EXT_separate_shader_objects;

PROCEDURE Read_GL_EXT_shader_image_load_store*;
BEGIN
	BindImageTextureEXT := SYSTEM.VAL(TglBindImageTextureEXT, GetProcAddress('glBindImageTextureEXT'));
	MemoryBarrierEXT := SYSTEM.VAL(TglMemoryBarrierEXT, GetProcAddress('glMemoryBarrierEXT'));
END Read_GL_EXT_shader_image_load_store;

PROCEDURE Read_GL_EXT_vertex_attrib_64bit*;
BEGIN
	VertexAttribL1dEXT := SYSTEM.VAL(TglVertexAttribL1dEXT, GetProcAddress('glVertexAttribL1dEXT'));
	VertexAttribL2dEXT := SYSTEM.VAL(TglVertexAttribL2dEXT, GetProcAddress('glVertexAttribL2dEXT'));
	VertexAttribL3dEXT := SYSTEM.VAL(TglVertexAttribL3dEXT, GetProcAddress('glVertexAttribL3dEXT'));
	VertexAttribL4dEXT := SYSTEM.VAL(TglVertexAttribL4dEXT, GetProcAddress('glVertexAttribL4dEXT'));
	VertexAttribL1dvEXT := SYSTEM.VAL(TglVertexAttribL1dvEXT, GetProcAddress('glVertexAttribL1dvEXT'));
	VertexAttribL2dvEXT := SYSTEM.VAL(TglVertexAttribL2dvEXT, GetProcAddress('glVertexAttribL2dvEXT'));
	VertexAttribL3dvEXT := SYSTEM.VAL(TglVertexAttribL3dvEXT, GetProcAddress('glVertexAttribL3dvEXT'));
	VertexAttribL4dvEXT := SYSTEM.VAL(TglVertexAttribL4dvEXT, GetProcAddress('glVertexAttribL4dvEXT'));
	VertexAttribLPointerEXT := SYSTEM.VAL(TglVertexAttribLPointerEXT, GetProcAddress('glVertexAttribLPointerEXT'));
	GetVertexAttribLdvEXT := SYSTEM.VAL(TglGetVertexAttribLdvEXT, GetProcAddress('glGetVertexAttribLdvEXT'));
	VertexArrayVertexAttribLOffsetEXT := SYSTEM.VAL(TglVertexArrayVertexAttribLOffsetEXT, GetProcAddress('glVertexArrayVertexAttribLOffsetEXT'));
END Read_GL_EXT_vertex_attrib_64bit;

PROCEDURE Read_GL_HP_image_transform*;
BEGIN
	ImageTransformParameteriHP := SYSTEM.VAL(TglImageTransformParameteriHP, GetProcAddress('glImageTransformParameteriHP'));
	ImageTransformParameterfHP := SYSTEM.VAL(TglImageTransformParameterfHP, GetProcAddress('glImageTransformParameterfHP'));
	ImageTransformParameterivHP := SYSTEM.VAL(TglImageTransformParameterivHP, GetProcAddress('glImageTransformParameterivHP'));
	ImageTransformParameterfvHP := SYSTEM.VAL(TglImageTransformParameterfvHP, GetProcAddress('glImageTransformParameterfvHP'));
	GetImageTransformParameterivHP := SYSTEM.VAL(TglGetImageTransformParameterivHP, GetProcAddress('glGetImageTransformParameterivHP'));
	GetImageTransformParameterfvHP := SYSTEM.VAL(TglGetImageTransformParameterfvHP, GetProcAddress('glGetImageTransformParameterfvHP'));
END Read_GL_HP_image_transform;

PROCEDURE Read_GL_IBM_multimode_draw_arrays*;
BEGIN
	MultiModeDrawArraysIBM := SYSTEM.VAL(TglMultiModeDrawArraysIBM, GetProcAddress('glMultiModeDrawArraysIBM'));
	MultiModeDrawElementsIBM := SYSTEM.VAL(TglMultiModeDrawElementsIBM, GetProcAddress('glMultiModeDrawElementsIBM'));
END Read_GL_IBM_multimode_draw_arrays;

PROCEDURE Read_GL_IBM_vertex_array_lists*;
BEGIN
	ColorPointerListIBM := SYSTEM.VAL(TglColorPointerListIBM, GetProcAddress('glColorPointerListIBM'));
	SecondaryColorPointerListIBM := SYSTEM.VAL(TglSecondaryColorPointerListIBM, GetProcAddress('glSecondaryColorPointerListIBM'));
	EdgeFlagPointerListIBM := SYSTEM.VAL(TglEdgeFlagPointerListIBM, GetProcAddress('glEdgeFlagPointerListIBM'));
	FogCoordPointerListIBM := SYSTEM.VAL(TglFogCoordPointerListIBM, GetProcAddress('glFogCoordPointerListIBM'));
	IndexPointerListIBM := SYSTEM.VAL(TglIndexPointerListIBM, GetProcAddress('glIndexPointerListIBM'));
	NormalPointerListIBM := SYSTEM.VAL(TglNormalPointerListIBM, GetProcAddress('glNormalPointerListIBM'));
	TexCoordPointerListIBM := SYSTEM.VAL(TglTexCoordPointerListIBM, GetProcAddress('glTexCoordPointerListIBM'));
	VertexPointerListIBM := SYSTEM.VAL(TglVertexPointerListIBM, GetProcAddress('glVertexPointerListIBM'));
END Read_GL_IBM_vertex_array_lists;

PROCEDURE Read_GL_INGR_blend_func_separate*;
BEGIN
	BlendFuncSeparateINGR := SYSTEM.VAL(TglBlendFuncSeparateINGR, GetProcAddress('glBlendFuncSeparateINGR'));
END Read_GL_INGR_blend_func_separate;

PROCEDURE Read_GL_INTEL_parallel_arrays*;
BEGIN
	VertexPointervINTEL := SYSTEM.VAL(TglVertexPointervINTEL, GetProcAddress('glVertexPointervINTEL'));
	NormalPointervINTEL := SYSTEM.VAL(TglNormalPointervINTEL, GetProcAddress('glNormalPointervINTEL'));
	ColorPointervINTEL := SYSTEM.VAL(TglColorPointervINTEL, GetProcAddress('glColorPointervINTEL'));
	TexCoordPointervINTEL := SYSTEM.VAL(TglTexCoordPointervINTEL, GetProcAddress('glTexCoordPointervINTEL'));
END Read_GL_INTEL_parallel_arrays;

PROCEDURE Read_GL_MESA_resize_buffers*;
BEGIN
	ResizeBuffersMESA := SYSTEM.VAL(TglResizeBuffersMESA, GetProcAddress('glResizeBuffersMESA'));
END Read_GL_MESA_resize_buffers;

PROCEDURE Read_GL_MESA_window_pos*;
BEGIN
	WindowPos2dMESA := SYSTEM.VAL(TglWindowPos2dMESA, GetProcAddress('glWindowPos2dMESA'));
	WindowPos2dvMESA := SYSTEM.VAL(TglWindowPos2dvMESA, GetProcAddress('glWindowPos2dvMESA'));
	WindowPos2fMESA := SYSTEM.VAL(TglWindowPos2fMESA, GetProcAddress('glWindowPos2fMESA'));
	WindowPos2fvMESA := SYSTEM.VAL(TglWindowPos2fvMESA, GetProcAddress('glWindowPos2fvMESA'));
	WindowPos2iMESA := SYSTEM.VAL(TglWindowPos2iMESA, GetProcAddress('glWindowPos2iMESA'));
	WindowPos2ivMESA := SYSTEM.VAL(TglWindowPos2ivMESA, GetProcAddress('glWindowPos2ivMESA'));
	WindowPos2sMESA := SYSTEM.VAL(TglWindowPos2sMESA, GetProcAddress('glWindowPos2sMESA'));
	WindowPos2svMESA := SYSTEM.VAL(TglWindowPos2svMESA, GetProcAddress('glWindowPos2svMESA'));
	WindowPos3dMESA := SYSTEM.VAL(TglWindowPos3dMESA, GetProcAddress('glWindowPos3dMESA'));
	WindowPos3dvMESA := SYSTEM.VAL(TglWindowPos3dvMESA, GetProcAddress('glWindowPos3dvMESA'));
	WindowPos3fMESA := SYSTEM.VAL(TglWindowPos3fMESA, GetProcAddress('glWindowPos3fMESA'));
	WindowPos3fvMESA := SYSTEM.VAL(TglWindowPos3fvMESA, GetProcAddress('glWindowPos3fvMESA'));
	WindowPos3iMESA := SYSTEM.VAL(TglWindowPos3iMESA, GetProcAddress('glWindowPos3iMESA'));
	WindowPos3ivMESA := SYSTEM.VAL(TglWindowPos3ivMESA, GetProcAddress('glWindowPos3ivMESA'));
	WindowPos3sMESA := SYSTEM.VAL(TglWindowPos3sMESA, GetProcAddress('glWindowPos3sMESA'));
	WindowPos3svMESA := SYSTEM.VAL(TglWindowPos3svMESA, GetProcAddress('glWindowPos3svMESA'));
	WindowPos4dMESA := SYSTEM.VAL(TglWindowPos4dMESA, GetProcAddress('glWindowPos4dMESA'));
	WindowPos4dvMESA := SYSTEM.VAL(TglWindowPos4dvMESA, GetProcAddress('glWindowPos4dvMESA'));
	WindowPos4fMESA := SYSTEM.VAL(TglWindowPos4fMESA, GetProcAddress('glWindowPos4fMESA'));
	WindowPos4fvMESA := SYSTEM.VAL(TglWindowPos4fvMESA, GetProcAddress('glWindowPos4fvMESA'));
	WindowPos4iMESA := SYSTEM.VAL(TglWindowPos4iMESA, GetProcAddress('glWindowPos4iMESA'));
	WindowPos4ivMESA := SYSTEM.VAL(TglWindowPos4ivMESA, GetProcAddress('glWindowPos4ivMESA'));
	WindowPos4sMESA := SYSTEM.VAL(TglWindowPos4sMESA, GetProcAddress('glWindowPos4sMESA'));
	WindowPos4svMESA := SYSTEM.VAL(TglWindowPos4svMESA, GetProcAddress('glWindowPos4svMESA'));
END Read_GL_MESA_window_pos;

PROCEDURE Read_GL_NV_evaluators*;
BEGIN
	MapControlPointsNV := SYSTEM.VAL(TglMapControlPointsNV, GetProcAddress('glMapControlPointsNV'));
	MapParameterivNV := SYSTEM.VAL(TglMapParameterivNV, GetProcAddress('glMapParameterivNV'));
	MapParameterfvNV := SYSTEM.VAL(TglMapParameterfvNV, GetProcAddress('glMapParameterfvNV'));
	GetMapControlPointsNV := SYSTEM.VAL(TglGetMapControlPointsNV, GetProcAddress('glGetMapControlPointsNV'));
	GetMapParameterivNV := SYSTEM.VAL(TglGetMapParameterivNV, GetProcAddress('glGetMapParameterivNV'));
	GetMapParameterfvNV := SYSTEM.VAL(TglGetMapParameterfvNV, GetProcAddress('glGetMapParameterfvNV'));
	GetMapAttribParameterivNV := SYSTEM.VAL(TglGetMapAttribParameterivNV, GetProcAddress('glGetMapAttribParameterivNV'));
	GetMapAttribParameterfvNV := SYSTEM.VAL(TglGetMapAttribParameterfvNV, GetProcAddress('glGetMapAttribParameterfvNV'));
	EvalMapsNV := SYSTEM.VAL(TglEvalMapsNV, GetProcAddress('glEvalMapsNV'));
END Read_GL_NV_evaluators;

PROCEDURE Read_GL_NV_fence*;
BEGIN
	DeleteFencesNV := SYSTEM.VAL(TglDeleteFencesNV, GetProcAddress('glDeleteFencesNV'));
	GenFencesNV := SYSTEM.VAL(TglGenFencesNV, GetProcAddress('glGenFencesNV'));
	IsFenceNV := SYSTEM.VAL(TglIsFenceNV, GetProcAddress('glIsFenceNV'));
	TestFenceNV := SYSTEM.VAL(TglTestFenceNV, GetProcAddress('glTestFenceNV'));
	GetFenceivNV := SYSTEM.VAL(TglGetFenceivNV, GetProcAddress('glGetFenceivNV'));
	FinishFenceNV := SYSTEM.VAL(TglFinishFenceNV, GetProcAddress('glFinishFenceNV'));
	SetFenceNV := SYSTEM.VAL(TglSetFenceNV, GetProcAddress('glSetFenceNV'));
END Read_GL_NV_fence;

PROCEDURE Read_GL_NV_fragment_program*;
BEGIN
	XglProgramNamedParameter4fNV := SYSTEM.VAL(TglProgramNamedParameter4fNV, GetProcAddress('glProgramNamedParameter4fNV'));
	XglProgramNamedParameter4dNV := SYSTEM.VAL(TglProgramNamedParameter4dNV, GetProcAddress('glProgramNamedParameter4dNV'));
	XglProgramNamedParameter4fvNV := SYSTEM.VAL(TglProgramNamedParameter4fvNV, GetProcAddress('glProgramNamedParameter4fvNV'));
	XglProgramNamedParameter4dvNV := SYSTEM.VAL(TglProgramNamedParameter4dvNV, GetProcAddress('glProgramNamedParameter4dvNV'));
	XglGetProgramNamedParameterfvNV := SYSTEM.VAL(TglGetProgramNamedParameterfvNV, GetProcAddress('glGetProgramNamedParameterfvNV'));
	XglGetProgramNamedParameterdvNV := SYSTEM.VAL(TglGetProgramNamedParameterdvNV, GetProcAddress('glGetProgramNamedParameterdvNV'));
END Read_GL_NV_fragment_program;

PROCEDURE Read_GL_NV_half_float*;
BEGIN
	Vertex2hNV := SYSTEM.VAL(TglVertex2hNV, GetProcAddress('glVertex2hNV'));
	Vertex2hvNV := SYSTEM.VAL(TglVertex2hvNV, GetProcAddress('glVertex2hvNV'));
	Vertex3hNV := SYSTEM.VAL(TglVertex3hNV, GetProcAddress('glVertex3hNV'));
	Vertex3hvNV := SYSTEM.VAL(TglVertex3hvNV, GetProcAddress('glVertex3hvNV'));
	Vertex4hNV := SYSTEM.VAL(TglVertex4hNV, GetProcAddress('glVertex4hNV'));
	Vertex4hvNV := SYSTEM.VAL(TglVertex4hvNV, GetProcAddress('glVertex4hvNV'));
	Normal3hNV := SYSTEM.VAL(TglNormal3hNV, GetProcAddress('glNormal3hNV'));
	Normal3hvNV := SYSTEM.VAL(TglNormal3hvNV, GetProcAddress('glNormal3hvNV'));
	Color3hNV := SYSTEM.VAL(TglColor3hNV, GetProcAddress('glColor3hNV'));
	Color3hvNV := SYSTEM.VAL(TglColor3hvNV, GetProcAddress('glColor3hvNV'));
	Color4hNV := SYSTEM.VAL(TglColor4hNV, GetProcAddress('glColor4hNV'));
	Color4hvNV := SYSTEM.VAL(TglColor4hvNV, GetProcAddress('glColor4hvNV'));
	TexCoord1hNV := SYSTEM.VAL(TglTexCoord1hNV, GetProcAddress('glTexCoord1hNV'));
	TexCoord1hvNV := SYSTEM.VAL(TglTexCoord1hvNV, GetProcAddress('glTexCoord1hvNV'));
	TexCoord2hNV := SYSTEM.VAL(TglTexCoord2hNV, GetProcAddress('glTexCoord2hNV'));
	TexCoord2hvNV := SYSTEM.VAL(TglTexCoord2hvNV, GetProcAddress('glTexCoord2hvNV'));
	TexCoord3hNV := SYSTEM.VAL(TglTexCoord3hNV, GetProcAddress('glTexCoord3hNV'));
	TexCoord3hvNV := SYSTEM.VAL(TglTexCoord3hvNV, GetProcAddress('glTexCoord3hvNV'));
	TexCoord4hNV := SYSTEM.VAL(TglTexCoord4hNV, GetProcAddress('glTexCoord4hNV'));
	TexCoord4hvNV := SYSTEM.VAL(TglTexCoord4hvNV, GetProcAddress('glTexCoord4hvNV'));
	MultiTexCoord1hNV := SYSTEM.VAL(TglMultiTexCoord1hNV, GetProcAddress('glMultiTexCoord1hNV'));
	MultiTexCoord1hvNV := SYSTEM.VAL(TglMultiTexCoord1hvNV, GetProcAddress('glMultiTexCoord1hvNV'));
	MultiTexCoord2hNV := SYSTEM.VAL(TglMultiTexCoord2hNV, GetProcAddress('glMultiTexCoord2hNV'));
	MultiTexCoord2hvNV := SYSTEM.VAL(TglMultiTexCoord2hvNV, GetProcAddress('glMultiTexCoord2hvNV'));
	MultiTexCoord3hNV := SYSTEM.VAL(TglMultiTexCoord3hNV, GetProcAddress('glMultiTexCoord3hNV'));
	MultiTexCoord3hvNV := SYSTEM.VAL(TglMultiTexCoord3hvNV, GetProcAddress('glMultiTexCoord3hvNV'));
	MultiTexCoord4hNV := SYSTEM.VAL(TglMultiTexCoord4hNV, GetProcAddress('glMultiTexCoord4hNV'));
	MultiTexCoord4hvNV := SYSTEM.VAL(TglMultiTexCoord4hvNV, GetProcAddress('glMultiTexCoord4hvNV'));
	FogCoordhNV := SYSTEM.VAL(TglFogCoordhNV, GetProcAddress('glFogCoordhNV'));
	FogCoordhvNV := SYSTEM.VAL(TglFogCoordhvNV, GetProcAddress('glFogCoordhvNV'));
	SecondaryColor3hNV := SYSTEM.VAL(TglSecondaryColor3hNV, GetProcAddress('glSecondaryColor3hNV'));
	SecondaryColor3hvNV := SYSTEM.VAL(TglSecondaryColor3hvNV, GetProcAddress('glSecondaryColor3hvNV'));
	VertexWeighthNV := SYSTEM.VAL(TglVertexWeighthNV, GetProcAddress('glVertexWeighthNV'));
	VertexWeighthvNV := SYSTEM.VAL(TglVertexWeighthvNV, GetProcAddress('glVertexWeighthvNV'));
	VertexAttrib1hNV := SYSTEM.VAL(TglVertexAttrib1hNV, GetProcAddress('glVertexAttrib1hNV'));
	VertexAttrib1hvNV := SYSTEM.VAL(TglVertexAttrib1hvNV, GetProcAddress('glVertexAttrib1hvNV'));
	VertexAttrib2hNV := SYSTEM.VAL(TglVertexAttrib2hNV, GetProcAddress('glVertexAttrib2hNV'));
	VertexAttrib2hvNV := SYSTEM.VAL(TglVertexAttrib2hvNV, GetProcAddress('glVertexAttrib2hvNV'));
	VertexAttrib3hNV := SYSTEM.VAL(TglVertexAttrib3hNV, GetProcAddress('glVertexAttrib3hNV'));
	VertexAttrib3hvNV := SYSTEM.VAL(TglVertexAttrib3hvNV, GetProcAddress('glVertexAttrib3hvNV'));
	VertexAttrib4hNV := SYSTEM.VAL(TglVertexAttrib4hNV, GetProcAddress('glVertexAttrib4hNV'));
	VertexAttrib4hvNV := SYSTEM.VAL(TglVertexAttrib4hvNV, GetProcAddress('glVertexAttrib4hvNV'));
	VertexAttribs1hvNV := SYSTEM.VAL(TglVertexAttribs1hvNV, GetProcAddress('glVertexAttribs1hvNV'));
	VertexAttribs2hvNV := SYSTEM.VAL(TglVertexAttribs2hvNV, GetProcAddress('glVertexAttribs2hvNV'));
	VertexAttribs3hvNV := SYSTEM.VAL(TglVertexAttribs3hvNV, GetProcAddress('glVertexAttribs3hvNV'));
	VertexAttribs4hvNV := SYSTEM.VAL(TglVertexAttribs4hvNV, GetProcAddress('glVertexAttribs4hvNV'));
END Read_GL_NV_half_float;

PROCEDURE Read_GL_NV_occlusion_query*;
BEGIN
	GenOcclusionQueriesNV := SYSTEM.VAL(TglGenOcclusionQueriesNV, GetProcAddress('glGenOcclusionQueriesNV'));
	DeleteOcclusionQueriesNV := SYSTEM.VAL(TglDeleteOcclusionQueriesNV, GetProcAddress('glDeleteOcclusionQueriesNV'));
	IsOcclusionQueryNV := SYSTEM.VAL(TglIsOcclusionQueryNV, GetProcAddress('glIsOcclusionQueryNV'));
	BeginOcclusionQueryNV := SYSTEM.VAL(TglBeginOcclusionQueryNV, GetProcAddress('glBeginOcclusionQueryNV'));
	EndOcclusionQueryNV := SYSTEM.VAL(TglEndOcclusionQueryNV, GetProcAddress('glEndOcclusionQueryNV'));
	GetOcclusionQueryivNV := SYSTEM.VAL(TglGetOcclusionQueryivNV, GetProcAddress('glGetOcclusionQueryivNV'));
	GetOcclusionQueryuivNV := SYSTEM.VAL(TglGetOcclusionQueryuivNV, GetProcAddress('glGetOcclusionQueryuivNV'));
END Read_GL_NV_occlusion_query;

PROCEDURE Read_GL_NV_pixel_data_range*;
BEGIN
	PixelDataRangeNV := SYSTEM.VAL(TglPixelDataRangeNV, GetProcAddress('glPixelDataRangeNV'));
	FlushPixelDataRangeNV := SYSTEM.VAL(TglFlushPixelDataRangeNV, GetProcAddress('glFlushPixelDataRangeNV'));
END Read_GL_NV_pixel_data_range;

PROCEDURE Read_GL_NV_point_sprite*;
BEGIN
	PointParameteriNV := SYSTEM.VAL(TglPointParameteriNV, GetProcAddress('glPointParameteriNV'));
	PointParameterivNV := SYSTEM.VAL(TglPointParameterivNV, GetProcAddress('glPointParameterivNV'));
END Read_GL_NV_point_sprite;

PROCEDURE Read_GL_NV_primitive_restart*;
BEGIN
	PrimitiveRestartNV := SYSTEM.VAL(TglPrimitiveRestartNV, GetProcAddress('glPrimitiveRestartNV'));
	PrimitiveRestartIndexNV := SYSTEM.VAL(TglPrimitiveRestartIndexNV, GetProcAddress('glPrimitiveRestartIndexNV'));
END Read_GL_NV_primitive_restart;

PROCEDURE Read_GL_NV_register_combiners*;
BEGIN
	CombinerParameterfvNV := SYSTEM.VAL(TglCombinerParameterfvNV, GetProcAddress('glCombinerParameterfvNV'));
	CombinerParameterfNV := SYSTEM.VAL(TglCombinerParameterfNV, GetProcAddress('glCombinerParameterfNV'));
	CombinerParameterivNV := SYSTEM.VAL(TglCombinerParameterivNV, GetProcAddress('glCombinerParameterivNV'));
	CombinerParameteriNV := SYSTEM.VAL(TglCombinerParameteriNV, GetProcAddress('glCombinerParameteriNV'));
	CombinerInputNV := SYSTEM.VAL(TglCombinerInputNV, GetProcAddress('glCombinerInputNV'));
	CombinerOutputNV := SYSTEM.VAL(TglCombinerOutputNV, GetProcAddress('glCombinerOutputNV'));
	FinalCombinerInputNV := SYSTEM.VAL(TglFinalCombinerInputNV, GetProcAddress('glFinalCombinerInputNV'));
	GetCombinerInputParameterfvNV := SYSTEM.VAL(TglGetCombinerInputParameterfvNV, GetProcAddress('glGetCombinerInputParameterfvNV'));
	GetCombinerInputParameterivNV := SYSTEM.VAL(TglGetCombinerInputParameterivNV, GetProcAddress('glGetCombinerInputParameterivNV'));
	GetCombinerOutputParameterfvNV := SYSTEM.VAL(TglGetCombinerOutputParameterfvNV, GetProcAddress('glGetCombinerOutputParameterfvNV'));
	GetCombinerOutputParameterivNV := SYSTEM.VAL(TglGetCombinerOutputParameterivNV, GetProcAddress('glGetCombinerOutputParameterivNV'));
	GetFinalCombinerInputParameterfvNV := SYSTEM.VAL(TglGetFinalCombinerInputParameterfvNV, GetProcAddress('glGetFinalCombinerInputParameterfvNV'));
	GetFinalCombinerInputParameterivNV := SYSTEM.VAL(TglGetFinalCombinerInputParameterivNV, GetProcAddress('glGetFinalCombinerInputParameterivNV'));
END Read_GL_NV_register_combiners;

PROCEDURE Read_GL_NV_register_combiners2*;
BEGIN
	CombinerStageParameterfvNV := SYSTEM.VAL(TglCombinerStageParameterfvNV, GetProcAddress('glCombinerStageParameterfvNV'));
	GetCombinerStageParameterfvNV := SYSTEM.VAL(TglGetCombinerStageParameterfvNV, GetProcAddress('glGetCombinerStageParameterfvNV'));
END Read_GL_NV_register_combiners2;

PROCEDURE Read_GL_NV_vertex_array_range*;
BEGIN
	FlushVertexArrayRangeNV := SYSTEM.VAL(TglFlushVertexArrayRangeNV, GetProcAddress('glFlushVertexArrayRangeNV'));
	VertexArrayRangeNV := SYSTEM.VAL(TglVertexArrayRangeNV, GetProcAddress('glVertexArrayRangeNV'));
END Read_GL_NV_vertex_array_range;

PROCEDURE Read_GL_NV_vertex_program*;
BEGIN
	AreProgramsResidentNV := SYSTEM.VAL(TglAreProgramsResidentNV, GetProcAddress('glAreProgramsResidentNV'));
	BindProgramNV := SYSTEM.VAL(TglBindProgramNV, GetProcAddress('glBindProgramNV'));
	DeleteProgramsNV := SYSTEM.VAL(TglDeleteProgramsNV, GetProcAddress('glDeleteProgramsNV'));
	ExecuteProgramNV := SYSTEM.VAL(TglExecuteProgramNV, GetProcAddress('glExecuteProgramNV'));
	GenProgramsNV := SYSTEM.VAL(TglGenProgramsNV, GetProcAddress('glGenProgramsNV'));
	GetProgramParameterdvNV := SYSTEM.VAL(TglGetProgramParameterdvNV, GetProcAddress('glGetProgramParameterdvNV'));
	GetProgramParameterfvNV := SYSTEM.VAL(TglGetProgramParameterfvNV, GetProcAddress('glGetProgramParameterfvNV'));
	GetProgramivNV := SYSTEM.VAL(TglGetProgramivNV, GetProcAddress('glGetProgramivNV'));
	GetProgramStringNV := SYSTEM.VAL(TglGetProgramStringNV, GetProcAddress('glGetProgramStringNV'));
	GetTrackMatrixivNV := SYSTEM.VAL(TglGetTrackMatrixivNV, GetProcAddress('glGetTrackMatrixivNV'));
	GetVertexAttribdvNV := SYSTEM.VAL(TglGetVertexAttribdvNV, GetProcAddress('glGetVertexAttribdvNV'));
	GetVertexAttribfvNV := SYSTEM.VAL(TglGetVertexAttribfvNV, GetProcAddress('glGetVertexAttribfvNV'));
	GetVertexAttribivNV := SYSTEM.VAL(TglGetVertexAttribivNV, GetProcAddress('glGetVertexAttribivNV'));
	GetVertexAttribPointervNV := SYSTEM.VAL(TglGetVertexAttribPointervNV, GetProcAddress('glGetVertexAttribPointervNV'));
	IsProgramNV := SYSTEM.VAL(TglIsProgramNV, GetProcAddress('glIsProgramNV'));
	LoadProgramNV := SYSTEM.VAL(TglLoadProgramNV, GetProcAddress('glLoadProgramNV'));
	ProgramParameter4dNV := SYSTEM.VAL(TglProgramParameter4dNV, GetProcAddress('glProgramParameter4dNV'));
	ProgramParameter4dvNV := SYSTEM.VAL(TglProgramParameter4dvNV, GetProcAddress('glProgramParameter4dvNV'));
	ProgramParameter4fNV := SYSTEM.VAL(TglProgramParameter4fNV, GetProcAddress('glProgramParameter4fNV'));
	ProgramParameter4fvNV := SYSTEM.VAL(TglProgramParameter4fvNV, GetProcAddress('glProgramParameter4fvNV'));
	ProgramParameters4dvNV := SYSTEM.VAL(TglProgramParameters4dvNV, GetProcAddress('glProgramParameters4dvNV'));
	ProgramParameters4fvNV := SYSTEM.VAL(TglProgramParameters4fvNV, GetProcAddress('glProgramParameters4fvNV'));
	RequestResidentProgramsNV := SYSTEM.VAL(TglRequestResidentProgramsNV, GetProcAddress('glRequestResidentProgramsNV'));
	TrackMatrixNV := SYSTEM.VAL(TglTrackMatrixNV, GetProcAddress('glTrackMatrixNV'));
	VertexAttribPointerNV := SYSTEM.VAL(TglVertexAttribPointerNV, GetProcAddress('glVertexAttribPointerNV'));
	VertexAttrib1dNV := SYSTEM.VAL(TglVertexAttrib1dNV, GetProcAddress('glVertexAttrib1dNV'));
	VertexAttrib1dvNV := SYSTEM.VAL(TglVertexAttrib1dvNV, GetProcAddress('glVertexAttrib1dvNV'));
	VertexAttrib1fNV := SYSTEM.VAL(TglVertexAttrib1fNV, GetProcAddress('glVertexAttrib1fNV'));
	VertexAttrib1fvNV := SYSTEM.VAL(TglVertexAttrib1fvNV, GetProcAddress('glVertexAttrib1fvNV'));
	VertexAttrib1sNV := SYSTEM.VAL(TglVertexAttrib1sNV, GetProcAddress('glVertexAttrib1sNV'));
	VertexAttrib1svNV := SYSTEM.VAL(TglVertexAttrib1svNV, GetProcAddress('glVertexAttrib1svNV'));
	VertexAttrib2dNV := SYSTEM.VAL(TglVertexAttrib2dNV, GetProcAddress('glVertexAttrib2dNV'));
	VertexAttrib2dvNV := SYSTEM.VAL(TglVertexAttrib2dvNV, GetProcAddress('glVertexAttrib2dvNV'));
	VertexAttrib2fNV := SYSTEM.VAL(TglVertexAttrib2fNV, GetProcAddress('glVertexAttrib2fNV'));
	VertexAttrib2fvNV := SYSTEM.VAL(TglVertexAttrib2fvNV, GetProcAddress('glVertexAttrib2fvNV'));
	VertexAttrib2sNV := SYSTEM.VAL(TglVertexAttrib2sNV, GetProcAddress('glVertexAttrib2sNV'));
	VertexAttrib2svNV := SYSTEM.VAL(TglVertexAttrib2svNV, GetProcAddress('glVertexAttrib2svNV'));
	VertexAttrib3dNV := SYSTEM.VAL(TglVertexAttrib3dNV, GetProcAddress('glVertexAttrib3dNV'));
	VertexAttrib3dvNV := SYSTEM.VAL(TglVertexAttrib3dvNV, GetProcAddress('glVertexAttrib3dvNV'));
	VertexAttrib3fNV := SYSTEM.VAL(TglVertexAttrib3fNV, GetProcAddress('glVertexAttrib3fNV'));
	VertexAttrib3fvNV := SYSTEM.VAL(TglVertexAttrib3fvNV, GetProcAddress('glVertexAttrib3fvNV'));
	VertexAttrib3sNV := SYSTEM.VAL(TglVertexAttrib3sNV, GetProcAddress('glVertexAttrib3sNV'));
	VertexAttrib3svNV := SYSTEM.VAL(TglVertexAttrib3svNV, GetProcAddress('glVertexAttrib3svNV'));
	VertexAttrib4dNV := SYSTEM.VAL(TglVertexAttrib4dNV, GetProcAddress('glVertexAttrib4dNV'));
	VertexAttrib4dvNV := SYSTEM.VAL(TglVertexAttrib4dvNV, GetProcAddress('glVertexAttrib4dvNV'));
	VertexAttrib4fNV := SYSTEM.VAL(TglVertexAttrib4fNV, GetProcAddress('glVertexAttrib4fNV'));
	VertexAttrib4fvNV := SYSTEM.VAL(TglVertexAttrib4fvNV, GetProcAddress('glVertexAttrib4fvNV'));
	VertexAttrib4sNV := SYSTEM.VAL(TglVertexAttrib4sNV, GetProcAddress('glVertexAttrib4sNV'));
	VertexAttrib4svNV := SYSTEM.VAL(TglVertexAttrib4svNV, GetProcAddress('glVertexAttrib4svNV'));
	VertexAttrib4ubNV := SYSTEM.VAL(TglVertexAttrib4ubNV, GetProcAddress('glVertexAttrib4ubNV'));
	VertexAttrib4ubvNV := SYSTEM.VAL(TglVertexAttrib4ubvNV, GetProcAddress('glVertexAttrib4ubvNV'));
	VertexAttribs1dvNV := SYSTEM.VAL(TglVertexAttribs1dvNV, GetProcAddress('glVertexAttribs1dvNV'));
	VertexAttribs1fvNV := SYSTEM.VAL(TglVertexAttribs1fvNV, GetProcAddress('glVertexAttribs1fvNV'));
	VertexAttribs1svNV := SYSTEM.VAL(TglVertexAttribs1svNV, GetProcAddress('glVertexAttribs1svNV'));
	VertexAttribs2dvNV := SYSTEM.VAL(TglVertexAttribs2dvNV, GetProcAddress('glVertexAttribs2dvNV'));
	VertexAttribs2fvNV := SYSTEM.VAL(TglVertexAttribs2fvNV, GetProcAddress('glVertexAttribs2fvNV'));
	VertexAttribs2svNV := SYSTEM.VAL(TglVertexAttribs2svNV, GetProcAddress('glVertexAttribs2svNV'));
	VertexAttribs3dvNV := SYSTEM.VAL(TglVertexAttribs3dvNV, GetProcAddress('glVertexAttribs3dvNV'));
	VertexAttribs3fvNV := SYSTEM.VAL(TglVertexAttribs3fvNV, GetProcAddress('glVertexAttribs3fvNV'));
	VertexAttribs3svNV := SYSTEM.VAL(TglVertexAttribs3svNV, GetProcAddress('glVertexAttribs3svNV'));
	VertexAttribs4dvNV := SYSTEM.VAL(TglVertexAttribs4dvNV, GetProcAddress('glVertexAttribs4dvNV'));
	VertexAttribs4fvNV := SYSTEM.VAL(TglVertexAttribs4fvNV, GetProcAddress('glVertexAttribs4fvNV'));
	VertexAttribs4svNV := SYSTEM.VAL(TglVertexAttribs4svNV, GetProcAddress('glVertexAttribs4svNV'));
	VertexAttribs4ubvNV := SYSTEM.VAL(TglVertexAttribs4ubvNV, GetProcAddress('glVertexAttribs4ubvNV'));
END Read_GL_NV_vertex_program;

PROCEDURE Read_GL_NV_depth_buffer_float*;
BEGIN
	DepthRangedNV := SYSTEM.VAL(TglDepthRangedNV, GetProcAddress('glDepthRangedNV'));
	ClearDepthdNV := SYSTEM.VAL(TglClearDepthdNV, GetProcAddress('glClearDepthdNV'));
	DepthBoundsdNV := SYSTEM.VAL(TglDepthBoundsdNV, GetProcAddress('glDepthBoundsdNV'));
END Read_GL_NV_depth_buffer_float;

PROCEDURE Read_GL_NV_framebuffer_multisample_coverage*;
BEGIN
	RenderbufferStorageMultsampleCoverageNV := SYSTEM.VAL(TglRenderbufferStorageMultsampleCoverageNV, GetProcAddress('glRenderbufferStorageMultsampleCoverageNV'));
END Read_GL_NV_framebuffer_multisample_coverage;

PROCEDURE Read_GL_NV_geometry_program4*;
BEGIN
	ProgramVertexLimitNV := SYSTEM.VAL(TglProgramVertexLimitNV, GetProcAddress('glProgramVertexLimitNV'));
END Read_GL_NV_geometry_program4;

PROCEDURE Read_GL_NV_gpu_program4*;
BEGIN
	ProgramLocalParameterI4iNV := SYSTEM.VAL(TglProgramLocalParameterI4iNV, GetProcAddress('glProgramLocalParameterI4iNV'));
	ProgramLocalParameterI4ivNV := SYSTEM.VAL(TglProgramLocalParameterI4ivNV, GetProcAddress('glProgramLocalParameterI4ivNV'));
	ProgramLocalParametersI4ivNV := SYSTEM.VAL(TglProgramLocalParametersI4ivNV, GetProcAddress('glProgramLocalParametersI4ivNV'));
	ProgramLocalParameterI4uiNV := SYSTEM.VAL(TglProgramLocalParameterI4uiNV, GetProcAddress('glProgramLocalParameterI4uiNV'));
	ProgramLocalParameterI4uivNV := SYSTEM.VAL(TglProgramLocalParameterI4uivNV, GetProcAddress('glProgramLocalParameterI4uivNV'));
	ProgramLocalParametersI4uivNV := SYSTEM.VAL(TglProgramLocalParametersI4uivNV, GetProcAddress('glProgramLocalParametersI4uivNV'));
	ProgramEnvParameterI4iNV := SYSTEM.VAL(TglProgramEnvParameterI4iNV, GetProcAddress('glProgramEnvParameterI4iNV'));
	ProgramEnvParameterI4ivNV := SYSTEM.VAL(TglProgramEnvParameterI4ivNV, GetProcAddress('glProgramEnvParameterI4ivNV'));
	ProgramEnvParametersI4ivNV := SYSTEM.VAL(TglProgramEnvParametersI4ivNV, GetProcAddress('glProgramEnvParametersI4ivNV'));
	ProgramEnvParameterI4uiNV := SYSTEM.VAL(TglProgramEnvParameterI4uiNV, GetProcAddress('glProgramEnvParameterI4uiNV'));
	ProgramEnvParameterI4uivNV := SYSTEM.VAL(TglProgramEnvParameterI4uivNV, GetProcAddress('glProgramEnvParameterI4uivNV'));
	ProgramEnvParametersI4uivNV := SYSTEM.VAL(TglProgramEnvParametersI4uivNV, GetProcAddress('glProgramEnvParametersI4uivNV'));
	GetProgramLocalParameterIivNV := SYSTEM.VAL(TglGetProgramLocalParameterIivNV, GetProcAddress('glGetProgramLocalParameterIivNV'));
	GetProgramLocalParameterIuivNV := SYSTEM.VAL(TglGetProgramLocalParameterIuivNV, GetProcAddress('glGetProgramLocalParameterIuivNV'));
	GetProgramEnvParameterIivNV := SYSTEM.VAL(TglGetProgramEnvParameterIivNV, GetProcAddress('glGetProgramEnvParameterIivNV'));
	GetProgramEnvParameterIuivNV := SYSTEM.VAL(TglGetProgramEnvParameterIuivNV, GetProcAddress('glGetProgramEnvParameterIuivNV'));
END Read_GL_NV_gpu_program4;

PROCEDURE Read_GL_NV_parameter_buffer_object*;
BEGIN
	ProgramBufferParametersfvNV := SYSTEM.VAL(TglProgramBufferParametersfvNV, GetProcAddress('glProgramBufferParametersfvNV'));
	ProgramBufferParametersIivNV := SYSTEM.VAL(TglProgramBufferParametersIivNV, GetProcAddress('glProgramBufferParametersIivNV'));
	ProgramBufferParametersIuivNV := SYSTEM.VAL(TglProgramBufferParametersIuivNV, GetProcAddress('glProgramBufferParametersIuivNV'));
END Read_GL_NV_parameter_buffer_object;

PROCEDURE Read_GL_NV_transform_feedback*;
BEGIN
	BeginTransformFeedbackNV := SYSTEM.VAL(TglBeginTransformFeedbackNV, GetProcAddress('glBeginTransformFeedbackNV'));
	EndTransformFeedbackNV := SYSTEM.VAL(TglEndTransformFeedbackNV, GetProcAddress('glEndTransformFeedbackNV'));
	TransformFeedbackAttribsNV := SYSTEM.VAL(TglTransformFeedbackAttribsNV, GetProcAddress('glTransformFeedbackAttribsNV'));
	BindBufferRangeNV := SYSTEM.VAL(TglBindBufferRangeNV, GetProcAddress('glBindBufferRangeNV'));
	BindBufferOffsetNV := SYSTEM.VAL(TglBindBufferOffsetNV, GetProcAddress('glBindBufferOffsetNV'));
	BindBufferBaseNV := SYSTEM.VAL(TglBindBufferBaseNV, GetProcAddress('glBindBufferBaseNV'));
	TransformFeedbackVaryingsNV := SYSTEM.VAL(TglTransformFeedbackVaryingsNV, GetProcAddress('glTransformFeedbackVaryingsNV'));
	XglActiveVaryingNV := SYSTEM.VAL(TglActiveVaryingNV, GetProcAddress('glActiveVaryingNV'));
	XglGetVaryingLocationNV := SYSTEM.VAL(TglGetVaryingLocationNV, GetProcAddress('glGetVaryingLocationNV'));
	GetActiveVaryingNV := SYSTEM.VAL(TglGetActiveVaryingNV, GetProcAddress('glGetActiveVaryingNV'));
	GetTransformFeedbackVaryingNV := SYSTEM.VAL(TglGetTransformFeedbackVaryingNV, GetProcAddress('glGetTransformFeedbackVaryingNV'));
	TransformFeedbackStreamAttribsNV := SYSTEM.VAL(TglTransformFeedbackStreamAttribsNV, GetProcAddress('glTransformFeedbackStreamAttribsNV'));
END Read_GL_NV_transform_feedback;

PROCEDURE Read_GL_NV_conditional_render*;
BEGIN
	BeginConditionalRenderNV := SYSTEM.VAL(TglBeginConditionalRenderNV, GetProcAddress('glBeginConditionalRenderNV'));
	EndConditionalRenderNV := SYSTEM.VAL(TglEndConditionalRenderNV, GetProcAddress('glEndConditionalRenderNV'));
END Read_GL_NV_conditional_render;

PROCEDURE Read_GL_NV_present_video*;
BEGIN
	PresentFrameKeyedNV := SYSTEM.VAL(TglPresentFrameKeyedNV, GetProcAddress('glPresentFrameKeyedNV'));
	PresentFrameDualFillNV := SYSTEM.VAL(TglPresentFrameDualFillNV, GetProcAddress('glPresentFrameDualFillNV'));
	GetVideoivNV := SYSTEM.VAL(TglGetVideoivNV, GetProcAddress('glGetVideoivNV'));
	GetVideouivNV := SYSTEM.VAL(TglGetVideouivNV, GetProcAddress('glGetVideouivNV'));
	GetVideoi64vNV := SYSTEM.VAL(TglGetVideoi64vNV, GetProcAddress('glGetVideoi64vNV'));
	GetVideoui64vNV := SYSTEM.VAL(TglGetVideoui64vNV, GetProcAddress('glGetVideoui64vNV'));
END Read_GL_NV_present_video;

PROCEDURE Read_GL_NV_explicit_multisample*;
BEGIN
	GetMultisamplefvNV := SYSTEM.VAL(TglGetMultisamplefvNV, GetProcAddress('glGetMultisamplefvNV'));
	SampleMaskIndexedNV := SYSTEM.VAL(TglSampleMaskIndexedNV, GetProcAddress('glSampleMaskIndexedNV'));
	TexRenderbufferNV := SYSTEM.VAL(TglTexRenderbufferNV, GetProcAddress('glTexRenderbufferNV'));
END Read_GL_NV_explicit_multisample;

PROCEDURE Read_GL_NV_transform_feedback2*;
BEGIN
	BindTransformFeedbackNV := SYSTEM.VAL(TglBindTransformFeedbackNV, GetProcAddress('glBindTransformFeedbackNV'));
	DeleteTransformFeedbacksNV := SYSTEM.VAL(TglDeleteTransformFeedbacksNV, GetProcAddress('glDeleteTransformFeedbacksNV'));
	GenTransformFeedbacksNV := SYSTEM.VAL(TglGenTransformFeedbacksNV, GetProcAddress('glGenTransformFeedbacksNV'));
	IsTransformFeedbackNV := SYSTEM.VAL(TglIsTransformFeedbackNV, GetProcAddress('glIsTransformFeedbackNV'));
	PauseTransformFeedbackNV := SYSTEM.VAL(TglPauseTransformFeedbackNV, GetProcAddress('glPauseTransformFeedbackNV'));
	ResumeTransformFeedbackNV := SYSTEM.VAL(TglResumeTransformFeedbackNV, GetProcAddress('glResumeTransformFeedbackNV'));
	DrawTransformFeedbackNV := SYSTEM.VAL(TglDrawTransformFeedbackNV, GetProcAddress('glDrawTransformFeedbackNV'));
END Read_GL_NV_transform_feedback2;

PROCEDURE Read_GL_NV_video_capture*;
BEGIN
	BeginVideoCaptureNV := SYSTEM.VAL(TglBeginVideoCaptureNV, GetProcAddress('glBeginVideoCaptureNV'));
	BindVideoCaptureStreamBufferNV := SYSTEM.VAL(TglBindVideoCaptureStreamBufferNV, GetProcAddress('glBindVideoCaptureStreamBufferNV'));
	BindVideoCaptureStreamTextureNV := SYSTEM.VAL(TglBindVideoCaptureStreamTextureNV, GetProcAddress('glBindVideoCaptureStreamTextureNV'));
	EndVideoCaptureNV := SYSTEM.VAL(TglEndVideoCaptureNV, GetProcAddress('glEndVideoCaptureNV'));
	GetVideoCaptureivNV := SYSTEM.VAL(TglGetVideoCaptureivNV, GetProcAddress('glGetVideoCaptureivNV'));
	GetVideoCaptureStreamivNV := SYSTEM.VAL(TglGetVideoCaptureStreamivNV, GetProcAddress('glGetVideoCaptureStreamivNV'));
	GetVideoCaptureStreamfvNV := SYSTEM.VAL(TglGetVideoCaptureStreamfvNV, GetProcAddress('glGetVideoCaptureStreamfvNV'));
	GetVideoCaptureStreamdvNV := SYSTEM.VAL(TglGetVideoCaptureStreamdvNV, GetProcAddress('glGetVideoCaptureStreamdvNV'));
	VideoCaptureNV := SYSTEM.VAL(TglVideoCaptureNV, GetProcAddress('glVideoCaptureNV'));
	VideoCaptureStreamParameterivNV := SYSTEM.VAL(TglVideoCaptureStreamParameterivNV, GetProcAddress('glVideoCaptureStreamParameterivNV'));
	VideoCaptureStreamParameterfvNV := SYSTEM.VAL(TglVideoCaptureStreamParameterfvNV, GetProcAddress('glVideoCaptureStreamParameterfvNV'));
	VideoCaptureStreamParameterdvNV := SYSTEM.VAL(TglVideoCaptureStreamParameterdvNV, GetProcAddress('glVideoCaptureStreamParameterdvNV'));
END Read_GL_NV_video_capture;

PROCEDURE Read_GL_NV_copy_image*;
BEGIN
	CopyImageSubDataNV := SYSTEM.VAL(TglCopyImageSubDataNV, GetProcAddress('glCopyImageSubDataNV'));
END Read_GL_NV_copy_image;

PROCEDURE Read_GL_NV_shader_buffer_load*;
BEGIN
	MakeBufferResidentNV := SYSTEM.VAL(TglMakeBufferResidentNV, GetProcAddress('glMakeBufferResidentNV'));
	MakeBufferNonResidentNV := SYSTEM.VAL(TglMakeBufferNonResidentNV, GetProcAddress('glMakeBufferNonResidentNV'));
	IsBufferResidentNV := SYSTEM.VAL(TglIsBufferResidentNV, GetProcAddress('glIsBufferResidentNV'));
	MakeNamedBufferResidentNV := SYSTEM.VAL(TglMakeNamedBufferResidentNV, GetProcAddress('glMakeNamedBufferResidentNV'));
	MakeNamedBufferNonResidentNV := SYSTEM.VAL(TglMakeNamedBufferNonResidentNV, GetProcAddress('glMakeNamedBufferNonResidentNV'));
	IsNamedBufferResidentNV := SYSTEM.VAL(TglIsNamedBufferResidentNV, GetProcAddress('glIsNamedBufferResidentNV'));
	GetBufferParameterui64vNV := SYSTEM.VAL(TglGetBufferParameterui64vNV, GetProcAddress('glGetBufferParameterui64vNV'));
	GetNamedBufferParameterui64vNV := SYSTEM.VAL(TglGetNamedBufferParameterui64vNV, GetProcAddress('glGetNamedBufferParameterui64vNV'));
	GetIntegerui64vNV := SYSTEM.VAL(TglGetIntegerui64vNV, GetProcAddress('glGetIntegerui64vNV'));
	Uniformui64NV := SYSTEM.VAL(TglUniformui64NV, GetProcAddress('glUniformui64NV'));
	Uniformui64vNV := SYSTEM.VAL(TglUniformui64vNV, GetProcAddress('glUniformui64vNV'));
	GetUniformui64vNV := SYSTEM.VAL(TglGetUniformui64vNV, GetProcAddress('glGetUniformui64vNV'));
	ProgramUniformui64NV := SYSTEM.VAL(TglProgramUniformui64NV, GetProcAddress('glProgramUniformui64NV'));
	ProgramUniformui64vNV := SYSTEM.VAL(TglProgramUniformui64vNV, GetProcAddress('glProgramUniformui64vNV'));
END Read_GL_NV_shader_buffer_load;

PROCEDURE Read_GL_NV_vertex_buffer_unified_memory*;
BEGIN
	BufferAddressRangeNV := SYSTEM.VAL(TglBufferAddressRangeNV, GetProcAddress('glBufferAddressRangeNV'));
	VertexFormatNV := SYSTEM.VAL(TglVertexFormatNV, GetProcAddress('glVertexFormatNV'));
	NormalFormatNV := SYSTEM.VAL(TglNormalFormatNV, GetProcAddress('glNormalFormatNV'));
	ColorFormatNV := SYSTEM.VAL(TglColorFormatNV, GetProcAddress('glColorFormatNV'));
	IndexFormatNV := SYSTEM.VAL(TglIndexFormatNV, GetProcAddress('glIndexFormatNV'));
	TexCoordFormatNV := SYSTEM.VAL(TglTexCoordFormatNV, GetProcAddress('glTexCoordFormatNV'));
	EdgeFlagFormatNV := SYSTEM.VAL(TglEdgeFlagFormatNV, GetProcAddress('glEdgeFlagFormatNV'));
	SecondaryColorFormatNV := SYSTEM.VAL(TglSecondaryColorFormatNV, GetProcAddress('glSecondaryColorFormatNV'));
	FogCoordFormatNV := SYSTEM.VAL(TglFogCoordFormatNV, GetProcAddress('glFogCoordFormatNV'));
	VertexAttribFormatNV := SYSTEM.VAL(TglVertexAttribFormatNV, GetProcAddress('glVertexAttribFormatNV'));
	VertexAttribIFormatNV := SYSTEM.VAL(TglVertexAttribIFormatNV, GetProcAddress('glVertexAttribIFormatNV'));
	GetIntegerui64i_vNV := SYSTEM.VAL(TglGetIntegerui64i_vNV, GetProcAddress('glGetIntegerui64i_vNV'));
END Read_GL_NV_vertex_buffer_unified_memory;

PROCEDURE Read_GL_NV_gpu_program5*;
BEGIN
	ProgramSubroutineParametersuivNV := SYSTEM.VAL(TglProgramSubroutineParametersuivNV, GetProcAddress('glProgramSubroutineParametersuivNV'));
	GetProgramSubroutineParameteruivNV := SYSTEM.VAL(TglGetProgramSubroutineParameteruivNV, GetProcAddress('glGetProgramSubroutineParameteruivNV'));
END Read_GL_NV_gpu_program5;

PROCEDURE Read_GL_NV_gpu_shader5*;
BEGIN
	Uniform1i64NV := SYSTEM.VAL(TglUniform1i64NV, GetProcAddress('glUniform1i64NV'));
	Uniform2i64NV := SYSTEM.VAL(TglUniform2i64NV, GetProcAddress('glUniform2i64NV'));
	Uniform3i64NV := SYSTEM.VAL(TglUniform3i64NV, GetProcAddress('glUniform3i64NV'));
	Uniform4i64NV := SYSTEM.VAL(TglUniform4i64NV, GetProcAddress('glUniform4i64NV'));
	Uniform1i64vNV := SYSTEM.VAL(TglUniform1i64vNV, GetProcAddress('glUniform1i64vNV'));
	Uniform2i64vNV := SYSTEM.VAL(TglUniform2i64vNV, GetProcAddress('glUniform2i64vNV'));
	Uniform3i64vNV := SYSTEM.VAL(TglUniform3i64vNV, GetProcAddress('glUniform3i64vNV'));
	Uniform4i64vNV := SYSTEM.VAL(TglUniform4i64vNV, GetProcAddress('glUniform4i64vNV'));
	Uniform1ui64NV := SYSTEM.VAL(TglUniform1ui64NV, GetProcAddress('glUniform1ui64NV'));
	Uniform2ui64NV := SYSTEM.VAL(TglUniform2ui64NV, GetProcAddress('glUniform2ui64NV'));
	Uniform3ui64NV := SYSTEM.VAL(TglUniform3ui64NV, GetProcAddress('glUniform3ui64NV'));
	Uniform4ui64NV := SYSTEM.VAL(TglUniform4ui64NV, GetProcAddress('glUniform4ui64NV'));
	Uniform1ui64vNV := SYSTEM.VAL(TglUniform1ui64vNV, GetProcAddress('glUniform1ui64vNV'));
	Uniform2ui64vNV := SYSTEM.VAL(TglUniform2ui64vNV, GetProcAddress('glUniform2ui64vNV'));
	Uniform3ui64vNV := SYSTEM.VAL(TglUniform3ui64vNV, GetProcAddress('glUniform3ui64vNV'));
	Uniform4ui64vNV := SYSTEM.VAL(TglUniform4ui64vNV, GetProcAddress('glUniform4ui64vNV'));
	GetUniformi64vNV := SYSTEM.VAL(TglGetUniformi64vNV, GetProcAddress('glGetUniformi64vNV'));
	ProgramUniform1i64NV := SYSTEM.VAL(TglProgramUniform1i64NV, GetProcAddress('glProgramUniform1i64NV'));
	ProgramUniform2i64NV := SYSTEM.VAL(TglProgramUniform2i64NV, GetProcAddress('glProgramUniform2i64NV'));
	ProgramUniform3i64NV := SYSTEM.VAL(TglProgramUniform3i64NV, GetProcAddress('glProgramUniform3i64NV'));
	ProgramUniform4i64NV := SYSTEM.VAL(TglProgramUniform4i64NV, GetProcAddress('glProgramUniform4i64NV'));
	ProgramUniform1i64vNV := SYSTEM.VAL(TglProgramUniform1i64vNV, GetProcAddress('glProgramUniform1i64vNV'));
	ProgramUniform2i64vNV := SYSTEM.VAL(TglProgramUniform2i64vNV, GetProcAddress('glProgramUniform2i64vNV'));
	ProgramUniform3i64vNV := SYSTEM.VAL(TglProgramUniform3i64vNV, GetProcAddress('glProgramUniform3i64vNV'));
	ProgramUniform4i64vNV := SYSTEM.VAL(TglProgramUniform4i64vNV, GetProcAddress('glProgramUniform4i64vNV'));
	ProgramUniform1ui64NV := SYSTEM.VAL(TglProgramUniform1ui64NV, GetProcAddress('glProgramUniform1ui64NV'));
	ProgramUniform2ui64NV := SYSTEM.VAL(TglProgramUniform2ui64NV, GetProcAddress('glProgramUniform2ui64NV'));
	ProgramUniform3ui64NV := SYSTEM.VAL(TglProgramUniform3ui64NV, GetProcAddress('glProgramUniform3ui64NV'));
	ProgramUniform4ui64NV := SYSTEM.VAL(TglProgramUniform4ui64NV, GetProcAddress('glProgramUniform4ui64NV'));
	ProgramUniform1ui64vNV := SYSTEM.VAL(TglProgramUniform1ui64vNV, GetProcAddress('glProgramUniform1ui64vNV'));
	ProgramUniform2ui64vNV := SYSTEM.VAL(TglProgramUniform2ui64vNV, GetProcAddress('glProgramUniform2ui64vNV'));
	ProgramUniform3ui64vNV := SYSTEM.VAL(TglProgramUniform3ui64vNV, GetProcAddress('glProgramUniform3ui64vNV'));
	ProgramUniform4ui64vNV := SYSTEM.VAL(TglProgramUniform4ui64vNV, GetProcAddress('glProgramUniform4ui64vNV'));
END Read_GL_NV_gpu_shader5;

PROCEDURE Read_GL_NV_vertex_attrib_integer_64bit*;
BEGIN
	VertexAttribL1i64NV := SYSTEM.VAL(TglVertexAttribL1i64NV, GetProcAddress('glVertexAttribL1i64NV'));
	VertexAttribL2i64NV := SYSTEM.VAL(TglVertexAttribL2i64NV, GetProcAddress('glVertexAttribL2i64NV'));
	VertexAttribL3i64NV := SYSTEM.VAL(TglVertexAttribL3i64NV, GetProcAddress('glVertexAttribL3i64NV'));
	VertexAttribL4i64NV := SYSTEM.VAL(TglVertexAttribL4i64NV, GetProcAddress('glVertexAttribL4i64NV'));
	VertexAttribL1i64vNV := SYSTEM.VAL(TglVertexAttribL1i64vNV, GetProcAddress('glVertexAttribL1i64vNV'));
	VertexAttribL2i64vNV := SYSTEM.VAL(TglVertexAttribL2i64vNV, GetProcAddress('glVertexAttribL2i64vNV'));
	VertexAttribL3i64vNV := SYSTEM.VAL(TglVertexAttribL3i64vNV, GetProcAddress('glVertexAttribL3i64vNV'));
	VertexAttribL4i64vNV := SYSTEM.VAL(TglVertexAttribL4i64vNV, GetProcAddress('glVertexAttribL4i64vNV'));
	VertexAttribL1ui64NV := SYSTEM.VAL(TglVertexAttribL1ui64NV, GetProcAddress('glVertexAttribL1ui64NV'));
	VertexAttribL2ui64NV := SYSTEM.VAL(TglVertexAttribL2ui64NV, GetProcAddress('glVertexAttribL2ui64NV'));
	VertexAttribL3ui64NV := SYSTEM.VAL(TglVertexAttribL3ui64NV, GetProcAddress('glVertexAttribL3ui64NV'));
	VertexAttribL4ui64NV := SYSTEM.VAL(TglVertexAttribL4ui64NV, GetProcAddress('glVertexAttribL4ui64NV'));
	VertexAttribL1ui64vNV := SYSTEM.VAL(TglVertexAttribL1ui64vNV, GetProcAddress('glVertexAttribL1ui64vNV'));
	VertexAttribL2ui64vNV := SYSTEM.VAL(TglVertexAttribL2ui64vNV, GetProcAddress('glVertexAttribL2ui64vNV'));
	VertexAttribL3ui64vNV := SYSTEM.VAL(TglVertexAttribL3ui64vNV, GetProcAddress('glVertexAttribL3ui64vNV'));
	VertexAttribL4ui64vNV := SYSTEM.VAL(TglVertexAttribL4ui64vNV, GetProcAddress('glVertexAttribL4ui64vNV'));
	GetVertexAttribLi64vNV := SYSTEM.VAL(TglGetVertexAttribLi64vNV, GetProcAddress('glGetVertexAttribLi64vNV'));
	GetVertexAttribLui64vNV := SYSTEM.VAL(TglGetVertexAttribLui64vNV, GetProcAddress('glGetVertexAttribLui64vNV'));
	VertexAttribLFormatNV := SYSTEM.VAL(TglVertexAttribLFormatNV, GetProcAddress('glVertexAttribLFormatNV'));
END Read_GL_NV_vertex_attrib_integer_64bit;

PROCEDURE Read_GL_NV_vdpau_interop*;
BEGIN
	VDPAUInitNV := SYSTEM.VAL(TglVDPAUInitNV, GetProcAddress('glVDPAUInitNV'));
	VDPAUFiniNV := SYSTEM.VAL(TglVDPAUFiniNV, GetProcAddress('glVDPAUFiniNV'));
	VDPAURegisterVideoSurfaceNV := SYSTEM.VAL(TglVDPAURegisterVideoSurfaceNV, GetProcAddress('glVDPAURegisterVideoSurfaceNV'));
	VDPAURegisterOutputSurfaceNV := SYSTEM.VAL(TglVDPAURegisterOutputSurfaceNV, GetProcAddress('glVDPAURegisterOutputSurfaceNV'));
	VDPAUIsSurfaceNV := SYSTEM.VAL(TglVDPAUIsSurfaceNV, GetProcAddress('glVDPAUIsSurfaceNV'));
	VDPAUUnregisterSurfaceNV := SYSTEM.VAL(TglVDPAUUnregisterSurfaceNV, GetProcAddress('glVDPAUUnregisterSurfaceNV'));
	VDPAUGetSurfaceivNV := SYSTEM.VAL(TglVDPAUGetSurfaceivNV, GetProcAddress('glVDPAUGetSurfaceivNV'));
	VDPAUSurfaceAccessNV := SYSTEM.VAL(TglVDPAUSurfaceAccessNV, GetProcAddress('glVDPAUSurfaceAccessNV'));
	VDPAUMapSurfacesNV := SYSTEM.VAL(TglVDPAUMapSurfacesNV, GetProcAddress('glVDPAUMapSurfacesNV'));
	VDPAUUnmapSurfacesNV := SYSTEM.VAL(TglVDPAUUnmapSurfacesNV, GetProcAddress('glVDPAUUnmapSurfacesNV'));
END Read_GL_NV_vdpau_interop;

PROCEDURE Read_GL_NV_texture_barrier*;
BEGIN
	TextureBarrierNV := SYSTEM.VAL(TglTextureBarrierNV, GetProcAddress('glTextureBarrierNV'));
END Read_GL_NV_texture_barrier;

PROCEDURE Read_GL_PGI_misc_hints*;
BEGIN
	HintPGI := SYSTEM.VAL(TglHintPGI, GetProcAddress('glHintPGI'));
END Read_GL_PGI_misc_hints;

PROCEDURE Read_GL_SGIS_detail_texture*;
BEGIN
	DetailTexFuncSGIS := SYSTEM.VAL(TglDetailTexFuncSGIS, GetProcAddress('glDetailTexFuncSGIS'));
	GetDetailTexFuncSGIS := SYSTEM.VAL(TglGetDetailTexFuncSGIS, GetProcAddress('glGetDetailTexFuncSGIS'));
END Read_GL_SGIS_detail_texture;

PROCEDURE Read_GL_SGIS_fog_function*;
BEGIN
	FogFuncSGIS := SYSTEM.VAL(TglFogFuncSGIS, GetProcAddress('glFogFuncSGIS'));
	GetFogFuncSGIS := SYSTEM.VAL(TglGetFogFuncSGIS, GetProcAddress('glGetFogFuncSGIS'));
END Read_GL_SGIS_fog_function;

PROCEDURE Read_GL_SGIS_multisample*;
BEGIN
	SampleMaskSGIS := SYSTEM.VAL(TglSampleMaskSGIS, GetProcAddress('glSampleMaskSGIS'));
	SamplePatternSGIS := SYSTEM.VAL(TglSamplePatternSGIS, GetProcAddress('glSamplePatternSGIS'));
END Read_GL_SGIS_multisample;

PROCEDURE Read_GL_SGIS_pixel_texture*;
BEGIN
	PixelTexGenParameteriSGIS := SYSTEM.VAL(TglPixelTexGenParameteriSGIS, GetProcAddress('glPixelTexGenParameteriSGIS'));
	PixelTexGenParameterivSGIS := SYSTEM.VAL(TglPixelTexGenParameterivSGIS, GetProcAddress('glPixelTexGenParameterivSGIS'));
	PixelTexGenParameterfSGIS := SYSTEM.VAL(TglPixelTexGenParameterfSGIS, GetProcAddress('glPixelTexGenParameterfSGIS'));
	PixelTexGenParameterfvSGIS := SYSTEM.VAL(TglPixelTexGenParameterfvSGIS, GetProcAddress('glPixelTexGenParameterfvSGIS'));
	GetPixelTexGenParameterivSGIS := SYSTEM.VAL(TglGetPixelTexGenParameterivSGIS, GetProcAddress('glGetPixelTexGenParameterivSGIS'));
	GetPixelTexGenParameterfvSGIS := SYSTEM.VAL(TglGetPixelTexGenParameterfvSGIS, GetProcAddress('glGetPixelTexGenParameterfvSGIS'));
END Read_GL_SGIS_pixel_texture;

PROCEDURE Read_GL_SGIS_point_parameters*;
BEGIN
	PointParameterfSGIS := SYSTEM.VAL(TglPointParameterfSGIS, GetProcAddress('glPointParameterfSGIS'));
	PointParameterfvSGIS := SYSTEM.VAL(TglPointParameterfvSGIS, GetProcAddress('glPointParameterfvSGIS'));
END Read_GL_SGIS_point_parameters;

PROCEDURE Read_GL_SGIS_sharpen_texture*;
BEGIN
	SharpenTexFuncSGIS := SYSTEM.VAL(TglSharpenTexFuncSGIS, GetProcAddress('glSharpenTexFuncSGIS'));
	GetSharpenTexFuncSGIS := SYSTEM.VAL(TglGetSharpenTexFuncSGIS, GetProcAddress('glGetSharpenTexFuncSGIS'));
END Read_GL_SGIS_sharpen_texture;

PROCEDURE Read_GL_SGIS_texture4D*;
BEGIN
	TexImage4DSGIS := SYSTEM.VAL(TglTexImage4DSGIS, GetProcAddress('glTexImage4DSGIS'));
	TexSubImage4DSGIS := SYSTEM.VAL(TglTexSubImage4DSGIS, GetProcAddress('glTexSubImage4DSGIS'));
END Read_GL_SGIS_texture4D;

PROCEDURE Read_GL_SGIS_texture_color_mask*;
BEGIN
	TextureColorMaskSGIS := SYSTEM.VAL(TglTextureColorMaskSGIS, GetProcAddress('glTextureColorMaskSGIS'));
END Read_GL_SGIS_texture_color_mask;

PROCEDURE Read_GL_SGIS_texture_filter4*;
BEGIN
	GetTexFilterFuncSGIS := SYSTEM.VAL(TglGetTexFilterFuncSGIS, GetProcAddress('glGetTexFilterFuncSGIS'));
	TexFilterFuncSGIS := SYSTEM.VAL(TglTexFilterFuncSGIS, GetProcAddress('glTexFilterFuncSGIS'));
END Read_GL_SGIS_texture_filter4;

PROCEDURE Read_GL_SGIX_async*;
BEGIN
	AsyncMarkerSGIX := SYSTEM.VAL(TglAsyncMarkerSGIX, GetProcAddress('glAsyncMarkerSGIX'));
	FinishAsyncSGIX := SYSTEM.VAL(TglFinishAsyncSGIX, GetProcAddress('glFinishAsyncSGIX'));
	PollAsyncSGIX := SYSTEM.VAL(TglPollAsyncSGIX, GetProcAddress('glPollAsyncSGIX'));
	GenAsyncMarkersSGIX := SYSTEM.VAL(TglGenAsyncMarkersSGIX, GetProcAddress('glGenAsyncMarkersSGIX'));
	DeleteAsyncMarkersSGIX := SYSTEM.VAL(TglDeleteAsyncMarkersSGIX, GetProcAddress('glDeleteAsyncMarkersSGIX'));
	IsAsyncMarkerSGIX := SYSTEM.VAL(TglIsAsyncMarkerSGIX, GetProcAddress('glIsAsyncMarkerSGIX'));
END Read_GL_SGIX_async;

PROCEDURE Read_GL_SGIX_flush_raster*;
BEGIN
	FlushRasterSGIX := SYSTEM.VAL(TglFlushRasterSGIX, GetProcAddress('glFlushRasterSGIX'));
END Read_GL_SGIX_flush_raster;

PROCEDURE Read_GL_SGIX_fragment_lighting*;
BEGIN
	FragmentColorMaterialSGIX := SYSTEM.VAL(TglFragmentColorMaterialSGIX, GetProcAddress('glFragmentColorMaterialSGIX'));
	FragmentLightfSGIX := SYSTEM.VAL(TglFragmentLightfSGIX, GetProcAddress('glFragmentLightfSGIX'));
	FragmentLightfvSGIX := SYSTEM.VAL(TglFragmentLightfvSGIX, GetProcAddress('glFragmentLightfvSGIX'));
	FragmentLightiSGIX := SYSTEM.VAL(TglFragmentLightiSGIX, GetProcAddress('glFragmentLightiSGIX'));
	FragmentLightivSGIX := SYSTEM.VAL(TglFragmentLightivSGIX, GetProcAddress('glFragmentLightivSGIX'));
	FragmentLightModelfSGIX := SYSTEM.VAL(TglFragmentLightModelfSGIX, GetProcAddress('glFragmentLightModelfSGIX'));
	FragmentLightModelfvSGIX := SYSTEM.VAL(TglFragmentLightModelfvSGIX, GetProcAddress('glFragmentLightModelfvSGIX'));
	FragmentLightModeliSGIX := SYSTEM.VAL(TglFragmentLightModeliSGIX, GetProcAddress('glFragmentLightModeliSGIX'));
	FragmentLightModelivSGIX := SYSTEM.VAL(TglFragmentLightModelivSGIX, GetProcAddress('glFragmentLightModelivSGIX'));
	FragmentMaterialfSGIX := SYSTEM.VAL(TglFragmentMaterialfSGIX, GetProcAddress('glFragmentMaterialfSGIX'));
	FragmentMaterialfvSGIX := SYSTEM.VAL(TglFragmentMaterialfvSGIX, GetProcAddress('glFragmentMaterialfvSGIX'));
	FragmentMaterialiSGIX := SYSTEM.VAL(TglFragmentMaterialiSGIX, GetProcAddress('glFragmentMaterialiSGIX'));
	FragmentMaterialivSGIX := SYSTEM.VAL(TglFragmentMaterialivSGIX, GetProcAddress('glFragmentMaterialivSGIX'));
	GetFragmentLightfvSGIX := SYSTEM.VAL(TglGetFragmentLightfvSGIX, GetProcAddress('glGetFragmentLightfvSGIX'));
	GetFragmentLightivSGIX := SYSTEM.VAL(TglGetFragmentLightivSGIX, GetProcAddress('glGetFragmentLightivSGIX'));
	GetFragmentMaterialfvSGIX := SYSTEM.VAL(TglGetFragmentMaterialfvSGIX, GetProcAddress('glGetFragmentMaterialfvSGIX'));
	GetFragmentMaterialivSGIX := SYSTEM.VAL(TglGetFragmentMaterialivSGIX, GetProcAddress('glGetFragmentMaterialivSGIX'));
	LightEnviSGIX := SYSTEM.VAL(TglLightEnviSGIX, GetProcAddress('glLightEnviSGIX'));
END Read_GL_SGIX_fragment_lighting;

PROCEDURE Read_GL_SGIX_framezoom*;
BEGIN
	FrameZoomSGIX := SYSTEM.VAL(TglFrameZoomSGIX, GetProcAddress('glFrameZoomSGIX'));
END Read_GL_SGIX_framezoom;

PROCEDURE Read_GL_SGIX_igloo_interface*;
BEGIN
	IglooInterfaceSGIX := SYSTEM.VAL(TglIglooInterfaceSGIX, GetProcAddress('glIglooInterfaceSGIX'));
END Read_GL_SGIX_igloo_interface;

PROCEDURE Read_GL_SGIX_instruments*;
BEGIN
	GetInstrumentsSGIX := SYSTEM.VAL(TglGetInstrumentsSGIX, GetProcAddress('glGetInstrumentsSGIX'));
	InstrumentsBufferSGIX := SYSTEM.VAL(TglInstrumentsBufferSGIX, GetProcAddress('glInstrumentsBufferSGIX'));
	PollInstrumentsSGIX := SYSTEM.VAL(TglPollInstrumentsSGIX, GetProcAddress('glPollInstrumentsSGIX'));
	ReadInstrumentsSGIX := SYSTEM.VAL(TglReadInstrumentsSGIX, GetProcAddress('glReadInstrumentsSGIX'));
	StartInstrumentsSGIX := SYSTEM.VAL(TglStartInstrumentsSGIX, GetProcAddress('glStartInstrumentsSGIX'));
	StopInstrumentsSGIX := SYSTEM.VAL(TglStopInstrumentsSGIX, GetProcAddress('glStopInstrumentsSGIX'));
END Read_GL_SGIX_instruments;

PROCEDURE Read_GL_SGIX_list_priority*;
BEGIN
	GetListParameterfvSGIX := SYSTEM.VAL(TglGetListParameterfvSGIX, GetProcAddress('glGetListParameterfvSGIX'));
	GetListParameterivSGIX := SYSTEM.VAL(TglGetListParameterivSGIX, GetProcAddress('glGetListParameterivSGIX'));
	ListParameterfSGIX := SYSTEM.VAL(TglListParameterfSGIX, GetProcAddress('glListParameterfSGIX'));
	ListParameterfvSGIX := SYSTEM.VAL(TglListParameterfvSGIX, GetProcAddress('glListParameterfvSGIX'));
	ListParameteriSGIX := SYSTEM.VAL(TglListParameteriSGIX, GetProcAddress('glListParameteriSGIX'));
	ListParameterivSGIX := SYSTEM.VAL(TglListParameterivSGIX, GetProcAddress('glListParameterivSGIX'));
END Read_GL_SGIX_list_priority;

PROCEDURE Read_GL_SGIX_pixel_texture*;
BEGIN
	PixelTexGenSGIX := SYSTEM.VAL(TglPixelTexGenSGIX, GetProcAddress('glPixelTexGenSGIX'));
END Read_GL_SGIX_pixel_texture;

PROCEDURE Read_GL_SGIX_polynomial_ffd*;
BEGIN
	DeformationMap3dSGIX := SYSTEM.VAL(TglDeformationMap3dSGIX, GetProcAddress('glDeformationMap3dSGIX'));
	DeformationMap3fSGIX := SYSTEM.VAL(TglDeformationMap3fSGIX, GetProcAddress('glDeformationMap3fSGIX'));
	DeformSGIX := SYSTEM.VAL(TglDeformSGIX, GetProcAddress('glDeformSGIX'));
	LoadIdentityDeformationMapSGIX := SYSTEM.VAL(TglLoadIdentityDeformationMapSGIX, GetProcAddress('glLoadIdentityDeformationMapSGIX'));
END Read_GL_SGIX_polynomial_ffd;

PROCEDURE Read_GL_SGIX_reference_plane*;
BEGIN
	ReferencePlaneSGIX := SYSTEM.VAL(TglReferencePlaneSGIX, GetProcAddress('glReferencePlaneSGIX'));
END Read_GL_SGIX_reference_plane;

PROCEDURE Read_GL_SGIX_sprite*;
BEGIN
	SpriteParameterfSGIX := SYSTEM.VAL(TglSpriteParameterfSGIX, GetProcAddress('glSpriteParameterfSGIX'));
	SpriteParameterfvSGIX := SYSTEM.VAL(TglSpriteParameterfvSGIX, GetProcAddress('glSpriteParameterfvSGIX'));
	SpriteParameteriSGIX := SYSTEM.VAL(TglSpriteParameteriSGIX, GetProcAddress('glSpriteParameteriSGIX'));
	SpriteParameterivSGIX := SYSTEM.VAL(TglSpriteParameterivSGIX, GetProcAddress('glSpriteParameterivSGIX'));
END Read_GL_SGIX_sprite;

PROCEDURE Read_GL_SGIX_tag_sample_buffer*;
BEGIN
	TagSampleBufferSGIX := SYSTEM.VAL(TglTagSampleBufferSGIX, GetProcAddress('glTagSampleBufferSGIX'));
END Read_GL_SGIX_tag_sample_buffer;

PROCEDURE Read_GL_SGI_color_table*;
BEGIN
	ColorTableSGI := SYSTEM.VAL(TglColorTableSGI, GetProcAddress('glColorTableSGI'));
	ColorTableParameterfvSGI := SYSTEM.VAL(TglColorTableParameterfvSGI, GetProcAddress('glColorTableParameterfvSGI'));
	ColorTableParameterivSGI := SYSTEM.VAL(TglColorTableParameterivSGI, GetProcAddress('glColorTableParameterivSGI'));
	CopyColorTableSGI := SYSTEM.VAL(TglCopyColorTableSGI, GetProcAddress('glCopyColorTableSGI'));
	GetColorTableSGI := SYSTEM.VAL(TglGetColorTableSGI, GetProcAddress('glGetColorTableSGI'));
	GetColorTableParameterfvSGI := SYSTEM.VAL(TglGetColorTableParameterfvSGI, GetProcAddress('glGetColorTableParameterfvSGI'));
	GetColorTableParameterivSGI := SYSTEM.VAL(TglGetColorTableParameterivSGI, GetProcAddress('glGetColorTableParameterivSGI'));
END Read_GL_SGI_color_table;

PROCEDURE Read_GL_SUNX_constant_data*;
BEGIN
	FinishTextureSUNX := SYSTEM.VAL(TglFinishTextureSUNX, GetProcAddress('glFinishTextureSUNX'));
END Read_GL_SUNX_constant_data;

PROCEDURE Read_GL_SUN_global_alpha*;
BEGIN
	GlobalAlphaFactorbSUN := SYSTEM.VAL(TglGlobalAlphaFactorbSUN, GetProcAddress('glGlobalAlphaFactorbSUN'));
	GlobalAlphaFactorsSUN := SYSTEM.VAL(TglGlobalAlphaFactorsSUN, GetProcAddress('glGlobalAlphaFactorsSUN'));
	GlobalAlphaFactoriSUN := SYSTEM.VAL(TglGlobalAlphaFactoriSUN, GetProcAddress('glGlobalAlphaFactoriSUN'));
	GlobalAlphaFactorfSUN := SYSTEM.VAL(TglGlobalAlphaFactorfSUN, GetProcAddress('glGlobalAlphaFactorfSUN'));
	GlobalAlphaFactordSUN := SYSTEM.VAL(TglGlobalAlphaFactordSUN, GetProcAddress('glGlobalAlphaFactordSUN'));
	GlobalAlphaFactorubSUN := SYSTEM.VAL(TglGlobalAlphaFactorubSUN, GetProcAddress('glGlobalAlphaFactorubSUN'));
	GlobalAlphaFactorusSUN := SYSTEM.VAL(TglGlobalAlphaFactorusSUN, GetProcAddress('glGlobalAlphaFactorusSUN'));
	GlobalAlphaFactoruiSUN := SYSTEM.VAL(TglGlobalAlphaFactoruiSUN, GetProcAddress('glGlobalAlphaFactoruiSUN'));
END Read_GL_SUN_global_alpha;

PROCEDURE Read_GL_SUN_mesh_array*;
BEGIN
	DrawMeshArraysSUN := SYSTEM.VAL(TglDrawMeshArraysSUN, GetProcAddress('glDrawMeshArraysSUN'));
END Read_GL_SUN_mesh_array;

PROCEDURE Read_GL_SUN_triangle_list*;
BEGIN
	ReplacementCodeuiSUN := SYSTEM.VAL(TglReplacementCodeuiSUN, GetProcAddress('glReplacementCodeuiSUN'));
	ReplacementCodeusSUN := SYSTEM.VAL(TglReplacementCodeusSUN, GetProcAddress('glReplacementCodeusSUN'));
	ReplacementCodeubSUN := SYSTEM.VAL(TglReplacementCodeubSUN, GetProcAddress('glReplacementCodeubSUN'));
	ReplacementCodeuivSUN := SYSTEM.VAL(TglReplacementCodeuivSUN, GetProcAddress('glReplacementCodeuivSUN'));
	ReplacementCodeusvSUN := SYSTEM.VAL(TglReplacementCodeusvSUN, GetProcAddress('glReplacementCodeusvSUN'));
	ReplacementCodeubvSUN := SYSTEM.VAL(TglReplacementCodeubvSUN, GetProcAddress('glReplacementCodeubvSUN'));
	ReplacementCodePointerSUN := SYSTEM.VAL(TglReplacementCodePointerSUN, GetProcAddress('glReplacementCodePointerSUN'));
END Read_GL_SUN_triangle_list;

PROCEDURE Read_GL_SUN_vertex*;
BEGIN
	Color4ubVertex2fSUN := SYSTEM.VAL(TglColor4ubVertex2fSUN, GetProcAddress('glColor4ubVertex2fSUN'));
	Color4ubVertex2fvSUN := SYSTEM.VAL(TglColor4ubVertex2fvSUN, GetProcAddress('glColor4ubVertex2fvSUN'));
	Color4ubVertex3fSUN := SYSTEM.VAL(TglColor4ubVertex3fSUN, GetProcAddress('glColor4ubVertex3fSUN'));
	Color4ubVertex3fvSUN := SYSTEM.VAL(TglColor4ubVertex3fvSUN, GetProcAddress('glColor4ubVertex3fvSUN'));
	Color3fVertex3fSUN := SYSTEM.VAL(TglColor3fVertex3fSUN, GetProcAddress('glColor3fVertex3fSUN'));
	Color3fVertex3fvSUN := SYSTEM.VAL(TglColor3fVertex3fvSUN, GetProcAddress('glColor3fVertex3fvSUN'));
	Normal3fVertex3fSUN := SYSTEM.VAL(TglNormal3fVertex3fSUN, GetProcAddress('glNormal3fVertex3fSUN'));
	Normal3fVertex3fvSUN := SYSTEM.VAL(TglNormal3fVertex3fvSUN, GetProcAddress('glNormal3fVertex3fvSUN'));
	Color4fNormal3fVertex3fSUN := SYSTEM.VAL(TglColor4fNormal3fVertex3fSUN, GetProcAddress('glColor4fNormal3fVertex3fSUN'));
	Color4fNormal3fVertex3fvSUN := SYSTEM.VAL(TglColor4fNormal3fVertex3fvSUN, GetProcAddress('glColor4fNormal3fVertex3fvSUN'));
	TexCoord2fVertex3fSUN := SYSTEM.VAL(TglTexCoord2fVertex3fSUN, GetProcAddress('glTexCoord2fVertex3fSUN'));
	TexCoord2fVertex3fvSUN := SYSTEM.VAL(TglTexCoord2fVertex3fvSUN, GetProcAddress('glTexCoord2fVertex3fvSUN'));
	TexCoord4fVertex4fSUN := SYSTEM.VAL(TglTexCoord4fVertex4fSUN, GetProcAddress('glTexCoord4fVertex4fSUN'));
	TexCoord4fVertex4fvSUN := SYSTEM.VAL(TglTexCoord4fVertex4fvSUN, GetProcAddress('glTexCoord4fVertex4fvSUN'));
	TexCoord2fColor4ubVertex3fSUN := SYSTEM.VAL(TglTexCoord2fColor4ubVertex3fSUN, GetProcAddress('glTexCoord2fColor4ubVertex3fSUN'));
	TexCoord2fColor4ubVertex3fvSUN := SYSTEM.VAL(TglTexCoord2fColor4ubVertex3fvSUN, GetProcAddress('glTexCoord2fColor4ubVertex3fvSUN'));
	TexCoord2fColor3fVertex3fSUN := SYSTEM.VAL(TglTexCoord2fColor3fVertex3fSUN, GetProcAddress('glTexCoord2fColor3fVertex3fSUN'));
	TexCoord2fColor3fVertex3fvSUN := SYSTEM.VAL(TglTexCoord2fColor3fVertex3fvSUN, GetProcAddress('glTexCoord2fColor3fVertex3fvSUN'));
	TexCoord2fNormal3fVertex3fSUN := SYSTEM.VAL(TglTexCoord2fNormal3fVertex3fSUN, GetProcAddress('glTexCoord2fNormal3fVertex3fSUN'));
	TexCoord2fNormal3fVertex3fvSUN := SYSTEM.VAL(TglTexCoord2fNormal3fVertex3fvSUN, GetProcAddress('glTexCoord2fNormal3fVertex3fvSUN'));
	TexCoord2fColor4fNormal3fVertex3fSUN := SYSTEM.VAL(TglTexCoord2fColor4fNormal3fVertex3fSUN, GetProcAddress('glTexCoord2fColor4fNormal3fVertex3fSUN'));
	TexCoord2fColor4fNormal3fVertex3fvSUN := SYSTEM.VAL(TglTexCoord2fColor4fNormal3fVertex3fvSUN, GetProcAddress('glTexCoord2fColor4fNormal3fVertex3fvSUN'));
	TexCoord4fColor4fNormal3fVertex4fSUN := SYSTEM.VAL(TglTexCoord4fColor4fNormal3fVertex4fSUN, GetProcAddress('glTexCoord4fColor4fNormal3fVertex4fSUN'));
	TexCoord4fColor4fNormal3fVertex4fvSUN := SYSTEM.VAL(TglTexCoord4fColor4fNormal3fVertex4fvSUN, GetProcAddress('glTexCoord4fColor4fNormal3fVertex4fvSUN'));
	ReplacementCodeuiVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiVertex3fSUN, GetProcAddress('glReplacementCodeuiVertex3fSUN'));
	ReplacementCodeuiVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiVertex3fvSUN, GetProcAddress('glReplacementCodeuiVertex3fvSUN'));
	ReplacementCodeuiColor4ubVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiColor4ubVertex3fSUN, GetProcAddress('glReplacementCodeuiColor4ubVertex3fSUN'));
	ReplacementCodeuiColor4ubVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiColor4ubVertex3fvSUN, GetProcAddress('glReplacementCodeuiColor4ubVertex3fvSUN'));
	ReplacementCodeuiColor3fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiColor3fVertex3fSUN, GetProcAddress('glReplacementCodeuiColor3fVertex3fSUN'));
	ReplacementCodeuiColor3fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiColor3fVertex3fvSUN, GetProcAddress('glReplacementCodeuiColor3fVertex3fvSUN'));
	ReplacementCodeuiNormal3fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiNormal3fVertex3fSUN, GetProcAddress('glReplacementCodeuiNormal3fVertex3fSUN'));
	ReplacementCodeuiNormal3fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiNormal3fVertex3fvSUN, GetProcAddress('glReplacementCodeuiNormal3fVertex3fvSUN'));
	ReplacementCodeuiColor4fNormal3fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiColor4fNormal3fVertex3fSUN, GetProcAddress('glReplacementCodeuiColor4fNormal3fVertex3fSUN'));
	ReplacementCodeuiColor4fNormal3fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiColor4fNormal3fVertex3fvSUN, GetProcAddress('glReplacementCodeuiColor4fNormal3fVertex3fvSUN'));
	ReplacementCodeuiTexCoord2fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fVertex3fSUN, GetProcAddress('glReplacementCodeuiTexCoord2fVertex3fSUN'));
	ReplacementCodeuiTexCoord2fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fVertex3fvSUN, GetProcAddress('glReplacementCodeuiTexCoord2fVertex3fvSUN'));
	ReplacementCodeuiTexCoord2fNormal3fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN, GetProcAddress('glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN'));
	ReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN, GetProcAddress('glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN'));
	ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN, GetProcAddress('glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN'));
	ReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN := SYSTEM.VAL(TglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN, GetProcAddress('glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN'));
END Read_GL_SUN_vertex;


PROCEDURE ReadExtensions*;
BEGIN
	(*  ReadOpenGLCore; *)
(*	KernelLog.String(" ReadExtensions "); *)
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
	Read_GL_ARB_shading_language_include;
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
	Read_GL_ARB_ES2_compatibility;
	Read_GL_ARB_get_program_binary;
	Read_GL_ARB_separate_shader_objects;
	Read_GL_ARB_vertex_attrib_64bit;
	Read_GL_ARB_viewport_array;
	Read_GL_ARB_cl_event;
	Read_GL_ARB_debug_output;
	Read_GL_ARB_robustness;
	(*  *)
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

(*	KernelLog.String(" Ok. ");  KernelLog.Ln;*)
END ReadExtensions;

(* utilities  *)
(* Get string from address  *)
PROCEDURE GetStringFromAddr*(adr: LONGINT): Strings.String;
VAR  sadr, sadr1: LONGINT;
		i, cnt: LONGINT;
		ch: CHAR;
		s: Strings.String;
BEGIN
	sadr := adr;

	(* find length  *)
	cnt  := 0;
	sadr1 := sadr;
	IF sadr1 # 0 THEN
		SYSTEM.GET(sadr1,ch);
		WHILE (ch # 0X) DO  INC(cnt); INC(sadr1); SYSTEM.GET(sadr1,ch); END;
	END;

	IF cnt = 0 THEN  (* empty string  *)
		NEW(s,1); s[0] := 0X; 	RETURN s
	END;

	NEW(s, cnt+1);
	i := 0;
	sadr1 := sadr;
	SYSTEM.GET(sadr1,ch);
	WHILE (i< cnt) & (ch # 0X) DO
		s^[i] := ch; INC(i); INC(sadr1);
		SYSTEM.GET(sadr1,ch);
	END;
	RETURN s;

END GetStringFromAddr;

(* wrapper procedures  *)
PROCEDURE GetString*(name: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
	sadr := XglGetString(name);
	RETURN GetStringFromAddr(sadr);
END GetString;

PROCEDURE GLXQueryExtensionString*(display: DisplayPtr; screen: LONGINT): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
  	sadr := glXQueryExtensionsString(display, screen);
	RETURN GetStringFromAddr(sadr);
END GLXQueryExtensionString;

PROCEDURE GLXGetClientString*(display: DisplayPtr; name: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
  	sadr := glXGetClientString(display, name);
	RETURN GetStringFromAddr(sadr);
END GLXGetClientString;

PROCEDURE GLXQueryServerString*(display: DisplayPtr; screen: Int; name: Enum): Strings.String;
VAR  sadr: ADDRESS;
BEGIN
  	sadr := glXQueryServerString(display, screen, name);
	RETURN GetStringFromAddr(sadr);
END GLXQueryServerString;

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
		Unix.Dlsym(GL_LibHandle, "glGetString", ADDRESSOF( XglGetString));
	END;

	Buffer := GetString(GLC.GL_VERSION );
	TrimAndSplitVersionString(Buffer^, MajorVersion, MinorVersion);
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
	END;
END ReadCoreVersion;

PROCEDURE Int_GetExtensionString(): Strings.String;
VAR
	buffer0 : Strings.String;
	len0 : LONGINT;
BEGIN
	(* general extension string  *)
	IF XglGetString = NIL THEN
		Unix.Dlsym(GL_LibHandle, "glGetString", ADDRESSOF( XglGetString));
	END;

	IF XglGetString # NIL THEN
		buffer0 := GetString(GLC.GL_EXTENSIONS);
		len0 := Strings.Length(buffer0^)
	END;
	RETURN buffer0;
END Int_GetExtensionString;

PROCEDURE Int_CheckExtension( allextensions: Strings.String; CONST thisextension: ARRAY OF CHAR): BOOLEAN;
VAR pos: LONGINT;
BEGIN
	pos := Strings.Pos(thisextension, allextensions^);
	IF debug & (pos = -1) THEN
		KernelLog.String(thisextension); KernelLog.String(": NOT AVAILABLE"); KernelLog.Ln;
	END;
	RETURN pos > 0;
END Int_CheckExtension;

(** check wether extension available  *)
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

	(* Check all extensions  *)
	Buffer := Int_GetExtensionString();

	(* === 3DFX ====================================================================  *)
	GL_3DFX_multisample := Int_CheckExtension(Buffer, 'GL_3DFX_multisample');
	GL_3DFX_tbuffer := Int_CheckExtension(Buffer, 'GL_3DFX_tbuffer');
	GL_3DFX_texture_compression_FXT1 := Int_CheckExtension(Buffer, 'GL_3DFX_texture_compression_FXT1');

	(* === APPLE ===================================================================  *)
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

	(* === ARB =====================================================================  *)
	GL_ARB_depth_texture := Int_CheckExtension(Buffer, 'GL_ARB_depth_texture');
	GL_ARB_fragment_program := Int_CheckExtension(Buffer, 'GL_ARB_fragment_program');
	GL_ARB_imaging := Int_CheckExtension(Buffer, 'GL_ARB_imaging');
	GL_ARB_matrix_palette := Int_CheckExtension(Buffer, 'GL_ARB_matrix_palette');
	GL_ARB_multisample := Int_CheckExtension(Buffer, 'GL_ARB_multisample');
	GL_ARB_multitexture := Int_CheckExtension(Buffer, 'GL_ARB_multitexture');
	GL_ARB_point_parameters := Int_CheckExtension(Buffer, 'GL_ARB_point_parameters');
	GL_ARB_shadow := Int_CheckExtension(Buffer, 'GL_ARB_shadow');
	GL_ARB_shadow_ambient := Int_CheckExtension(Buffer, 'GL_ARB_shadow_ambient');
	GL_ARB_texture_border_clamp := Int_CheckExtension(Buffer, 'GL_ARB_texture_border_clamp');
	GL_ARB_texture_compression := Int_CheckExtension(Buffer, 'GL_ARB_texture_compression');
	GL_ARB_texture_cube_map := Int_CheckExtension(Buffer, 'GL_ARB_texture_cube_map');
	GL_ARB_texture_env_add := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_add');
	GL_ARB_texture_env_combine := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_combine');
	GL_ARB_texture_env_crossbar := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_crossbar');
	GL_ARB_texture_env_dot3 := Int_CheckExtension(Buffer, 'GL_ARB_texture_env_dot3');
	GL_ARB_texture_mirrored_repeat := Int_CheckExtension(Buffer, 'GL_ARB_texture_mirrored_repeat');
	GL_ARB_transpose_matrix := Int_CheckExtension(Buffer, 'GL_ARB_transpose_matrix');
	GL_ARB_vertex_blend := Int_CheckExtension(Buffer, 'GL_ARB_vertex_blend');
	GL_ARB_vertex_buffer_object := Int_CheckExtension(Buffer, 'GL_ARB_vertex_buffer_object');
	GL_ARB_vertex_program := Int_CheckExtension(Buffer, 'GL_ARB_vertex_program');
	GL_ARB_window_pos := Int_CheckExtension(Buffer, 'GL_ARB_window_pos');
	GL_ARB_shader_objects := Int_CheckExtension(Buffer, 'GL_ARB_shader_objects');
	GL_ARB_vertex_shader := Int_CheckExtension(Buffer, 'GL_ARB_vertex_shader');
	GL_ARB_fragment_shader := Int_CheckExtension(Buffer, 'GL_ARB_fragment_shader');
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
	GL_ARB_sampler_objects := Int_CheckExtension(Buffer, 'GL_ARB_sampler_objects');
	GL_ARB_shader_bit_encoding := Int_CheckExtension(Buffer, 'GL_ARB_shader_bit_encoding');
	GL_ARB_texture_rgb10_a2ui := Int_CheckExtension(Buffer, 'GL_ARB_texture_rgb10_a2ui');
	GL_ARB_texture_swizzle := Int_CheckExtension(Buffer, 'GL_ARB_texture_swizzle');
	GL_ARB_timer_query := Int_CheckExtension(Buffer, 'GL_ARB_timer_query');
	GL_ARB_vertex_type_2_10_10_10_rev := Int_CheckExtension(Buffer, 'GL_ARB_vertex_type_2_10_10_10_rev');
	GL_ARB_draw_indirect := Int_CheckExtension(Buffer, 'GL_ARB_draw_indirect');
	GL_ARB_gpu_shader5 := Int_CheckExtension(Buffer, 'GL_ARB_gpu_shader5');
	GL_ARB_gpu_shader_fp64 := Int_CheckExtension(Buffer, 'GL_ARB_gpu_shader_fp64');
	GL_ARB_shader_subroutine := Int_CheckExtension(Buffer, 'GL_ARB_shader_subroutine');
	GL_ARB_tessellation_shader := Int_CheckExtension(Buffer, 'GL_ARB_tessellation_shader');
	GL_ARB_texture_buffer_object_rgb32 := Int_CheckExtension(Buffer, 'GL_ARB_texture_buffer_object_rgb32');
	GL_ARB_transform_feedback2 := Int_CheckExtension(Buffer, 'GL_ARB_transform_feedback2');
	GL_ARB_transform_feedback3 := Int_CheckExtension(Buffer, 'GL_ARB_transform_feedback3');
	GL_ARB_ES2_compatibility := Int_CheckExtension(Buffer, 'GL_ARB_ES2_compatibility');
	GL_ARB_get_program_binary := Int_CheckExtension(Buffer, 'GL_ARB_get_program_binary');
	GL_ARB_separate_shader_objects := Int_CheckExtension(Buffer, 'GL_ARB_separate_shader_objects');
	GL_ARB_shader_precision := Int_CheckExtension(Buffer, 'GL_ARB_shader_precision');
	GL_ARB_vertex_attrib_64bit := Int_CheckExtension(Buffer, 'GL_ARB_vertex_attrib_64bit');
	GL_ARB_viewport_array := Int_CheckExtension(Buffer, 'GL_ARB_viewport_array');
	(* GL 4.2  *)
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
	(* GL 4.3  *)
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
	(*  *)
	GL_ARB_cl_event := Int_CheckExtension(Buffer, 'GL_ARB_cl_event');
	GL_ARB_debug_output := Int_CheckExtension(Buffer, 'GL_ARB_debug_output');
	GL_ARB_robustness := Int_CheckExtension(Buffer, 'GL_ARB_robustness');
	GL_ARB_shader_stencil_export := Int_CheckExtension(Buffer, 'GL_ARB_shader_stencil_export');

	(* === ATI/AMD ================================================================  *)
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
	(* 4.3  *)
	GL_AMD_pinned_memory := Int_CheckExtension(Buffer, 'GL_AMD_pinned_memory');
	GL_AMD_stencil_operation_extended := Int_CheckExtension(Buffer, 'GL_AMD_stencil_operation_extended');
	GL_AMD_vertex_shader_viewport_index := Int_CheckExtension(Buffer, 'GL_AMD_vertex_shader_viewport_index');
	GL_AMD_vertex_shader_layer := Int_CheckExtension(Buffer, 'GL_AMD_vertex_shader_layer');
	GL_AMD_query_buffer_object := Int_CheckExtension(Buffer, 'GL_AMD_query_buffer_object');

	(* === EXT =====================================================================  *)
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

	(* === HP ======================================================================  *)
	GL_HP_convolution_border_modes := Int_CheckExtension(Buffer, 'GL_HP_convolution_border_modes');
	GL_HP_image_transform := Int_CheckExtension(Buffer, 'GL_HP_image_transform');
	GL_HP_occlusion_test := Int_CheckExtension(Buffer, 'GL_HP_occlusion_test');
	GL_HP_texture_lighting := Int_CheckExtension(Buffer, 'GL_HP_texture_lighting');

	(* === IBM =====================================================================  *)
	GL_IBM_cull_vertex := Int_CheckExtension(Buffer, 'GL_IBM_cull_vertex');
	GL_IBM_multimode_draw_arrays := Int_CheckExtension(Buffer, 'GL_IBM_multimode_draw_arrays');
	GL_IBM_rasterpos_clip := Int_CheckExtension(Buffer, 'GL_IBM_rasterpos_clip');
	GL_IBM_texture_mirrored_repeat := Int_CheckExtension(Buffer, 'GL_IBM_texture_mirrored_repeat');
	GL_IBM_vertex_array_lists := Int_CheckExtension(Buffer, 'GL_IBM_vertex_array_lists');

	(* === INGR ====================================================================  *)
	GL_INGR_blend_func_separate := Int_CheckExtension(Buffer, 'GL_INGR_blend_func_separate');
	GL_INGR_color_clamp := Int_CheckExtension(Buffer, 'GL_INGR_color_clamp');
	GL_INGR_interlace_read := Int_CheckExtension(Buffer, 'GL_INGR_interlace_read');
	GL_INGR_palette_buffer := Int_CheckExtension(Buffer, 'GL_INGR_palette_buffer');

	(* === INTEL ===================================================================  *)
	GL_INTEL_parallel_arrays := Int_CheckExtension(Buffer, 'GL_INTEL_parallel_arrays');
	GL_INTEL_texture_scissor := Int_CheckExtension(Buffer, 'GL_INTEL_texture_scissor');

	(* === MESA ====================================================================  *)
	GL_MESA_resize_buffers := Int_CheckExtension(Buffer, 'GL_MESA_resize_buffers');
	GL_MESA_window_pos := Int_CheckExtension(Buffer, 'GL_MESA_window_pos');

	(* === NVIDIA ==================================================================  *)
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
	(* 4.3  *)
	GL_NV_path_rendering := Int_CheckExtension(Buffer, 'GL_NV_path_rendering');
	GL_NV_bindless_texture := Int_CheckExtension(Buffer, 'GL_NV_bindless_texture');
	GL_NV_shader_atomic_float := Int_CheckExtension(Buffer, 'GL_NV_shader_atomic_float');

	(* === OML =====================================================================  *)
	GL_OML_interlace := Int_CheckExtension(Buffer, 'GL_OML_interlace');
	GL_OML_resample := Int_CheckExtension(Buffer, 'GL_OML_resample');
	GL_OML_subsample := Int_CheckExtension(Buffer, 'GL_OML_subsample');

	(* === PGI =====================================================================  *)
	GL_PGI_misc_hints := Int_CheckExtension(Buffer, 'GL_PGI_misc_hints');
	GL_PGI_vertex_hints := Int_CheckExtension(Buffer, 'GL_PGI_vertex_hints');

	(* === REND ====================================================================  *)
	GL_REND_screen_coordinates := Int_CheckExtension(Buffer, 'GL_REND_screen_coordinates');

	(* === S3 ======================================================================  *)
	GL_S3_s3tc := Int_CheckExtension(Buffer, 'GL_S3_s3tc');

	(* === SGIS ====================================================================  *)
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

	(* === SGIX ====================================================================  *)
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

	(* === SGI =====================================================================  *)
	GL_SGI_color_matrix := Int_CheckExtension(Buffer, 'GL_SGI_color_matrix');
	GL_SGI_color_table := Int_CheckExtension(Buffer, 'GL_SGI_color_table');
	GL_SGI_depth_pass_instrument := Int_CheckExtension(Buffer, 'GL_SGI_depth_pass_instrument');
	GL_SGI_texture_color_table := Int_CheckExtension(Buffer, 'GL_SGI_texture_color_table');

	(* === SUN =====================================================================  *)
	GL_SUNX_constant_data := Int_CheckExtension(Buffer, 'GL_SUNX_constant_data');
	GL_SUN_convolution_border_modes := Int_CheckExtension(Buffer, 'GL_SUN_convolution_border_modes');
	GL_SUN_global_alpha := Int_CheckExtension(Buffer, 'GL_SUN_global_alpha');
	GL_SUN_mesh_array := Int_CheckExtension(Buffer, 'GL_SUN_mesh_array');
	GL_SUN_slice_accum := Int_CheckExtension(Buffer, 'GL_SUN_slice_accum');
	GL_SUN_triangle_list := Int_CheckExtension(Buffer, 'GL_SUN_triangle_list');
	GL_SUN_vertex := Int_CheckExtension(Buffer, 'GL_SUN_vertex');

	(* === WIN =====================================================================  *)
	GL_WIN_phong_shading := Int_CheckExtension(Buffer, 'GL_WIN_phong_shading');
	GL_WIN_specular_fog := Int_CheckExtension(Buffer, 'GL_WIN_specular_fog');


	(* LINUX  *)
	(* for Linux, use GLXQueryServerString and GLXGetClientString  *)
	(* === GLX =====================================================================  *)
	GLX_ARB_multisample := Int_CheckExtension(Buffer, 'GLX_ARB_multisample');
	GLX_ARB_fbconfig_float := Int_CheckExtension(Buffer, 'GLX_ARB_fbconfig_float');
	GLX_ARB_get_proc_address := Int_CheckExtension(Buffer, 'GLX_ARB_get_proc_address');
	GLX_ARB_create_context := Int_CheckExtension(Buffer, 'GLX_ARB_create_context');
	GLX_ARB_create_context_profile := Int_CheckExtension(Buffer, 'GLX_ARB_create_context_profile');
	GLX_ARB_vertex_buffer_object := Int_CheckExtension(Buffer, 'GLX_ARB_vertex_buffer_object');
	GLX_ARB_framebuffer_sRGB := Int_CheckExtension(Buffer, 'GLX_ARB_framebuffer_sRGB');
	GLX_ARB_create_context_robustness := Int_CheckExtension(Buffer, 'GLX_ARB_create_context_robustness');
	GLX_EXT_visual_info := Int_CheckExtension(Buffer, 'GLX_EXT_visual_info');
	GLX_EXT_visual_rating := Int_CheckExtension(Buffer, 'GLX_EXT_visual_rating');
	GLX_EXT_import_context := Int_CheckExtension(Buffer, 'GLX_EXT_import_context');
	GLX_EXT_fbconfig_packed_float := Int_CheckExtension(Buffer, 'GLX_EXT_fbconfig_packed_float');
	GLX_EXT_framebuffer_sRGB := Int_CheckExtension(Buffer, 'GLX_EXT_framebuffer_sRGB');
	GLX_EXT_texture_from_pixmap := Int_CheckExtension(Buffer, 'GLX_EXT_texture_from_pixmap');
	GLX_EXT_swap_control := Int_CheckExtension(Buffer, 'GLX_EXT_swap_control');
	GLX_EXT_create_context_es2_profile := Int_CheckExtension(Buffer, 'GLX_EXT_create_context_es2_profile');

	(* ImplementationRead := TRUE;  *)
END ReadImplementationProperties;


(*! wrapper procedures for darwin compatibility  *)
PROCEDURE BindAttribLocation*(programObj: Handle; index: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglBindAttribLocation(programObj, index, ADDRESSOF(name[0]));
END BindAttribLocation;

PROCEDURE GetAttribLocation* (programObj: Handle; CONST chars: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetAttribLocation(programObj, ADDRESSOF(chars[0]));
END GetAttribLocation;

PROCEDURE GetUniformLocation* (programObj: Handle; CONST chars: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetUniformLocation (programObj, ADDRESSOF(chars[0]));
END GetUniformLocation;

PROCEDURE BindFragDataLocation* (xprogram: Uint; color: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglBindFragDataLocation(xprogram,color, ADDRESSOF(name[0]));
END BindFragDataLocation;

PROCEDURE GetFragDataLocation*(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetFragDataLocation(xprogram, ADDRESSOF(name[0]));
END GetFragDataLocation;

PROCEDURE GetAttribLocationARB*(programObj: HandleARB; CONST chars: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetAttribLocationARB(programObj, ADDRESSOF(chars[0]));
END GetAttribLocationARB;

PROCEDURE BindAttribLocationARB*(programObj: HandleARB; index: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglBindAttribLocationARB(programObj, index,  ADDRESSOF(name[0]));
END BindAttribLocationARB;

PROCEDURE GetUniformLocationARB*(programObj: HandleARB; CONST chars: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetUniformLocationARB(programObj, ADDRESSOF(chars[0]));
END GetUniformLocationARB;

PROCEDURE GetUniformBlockIndex* (xprogram: Uint; CONST uniformBlockName: ARRAY OF CHAR): Uint;
BEGIN
	RETURN XglGetUniformBlockIndex(xprogram, ADDRESSOF(uniformBlockName[0]));
END GetUniformBlockIndex;

PROCEDURE NamedStringARB*(xtype: Enum; namelen: Int; CONST name: ARRAY OF CHAR; stringlen: Int; CONST xstring: ARRAY OF CHAR);
BEGIN
	XglNamedStringARB(xtype, namelen, ADDRESSOF(name[0]), stringlen, ADDRESSOF(xstring[0]));
END NamedStringARB;

PROCEDURE DeleteNamedStringARB*(namelen: Int; CONST name: ARRAY OF CHAR);
BEGIN
	XglDeleteNamedStringARB(namelen, ADDRESSOF(name[0]));
END DeleteNamedStringARB;

PROCEDURE IsNamedStringARB*(namelen: Int; CONST name: ARRAY OF CHAR): Boolean;
BEGIN
	RETURN XglIsNamedStringARB(namelen, ADDRESSOF(name[0]));
END IsNamedStringARB;

PROCEDURE GetNamedStringARB*(namelen: Int; CONST name: ARRAY OF CHAR; bufSize: Sizei; stringlen: Int; xstring: PChar);
BEGIN
	XglGetNamedStringARB(namelen, ADDRESSOF(name[0]), bufSize, stringlen, xstring);
END GetNamedStringARB;

PROCEDURE GetNamedStringivARB*(namelen: Int; CONST name: ARRAY OF CHAR; pname: Enum; params: Pint);
BEGIN
	XglGetNamedStringivARB(namelen, ADDRESSOF(name[0]), pname, params);
END GetNamedStringivARB;

(* GL_ARB_blend_func_extended *)
PROCEDURE BindFragDataLocationIndexed*(xprogram: Uint; colorNumber: Uint; index: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglBindFragDataLocationIndexed(xprogram, colorNumber, index, ADDRESSOF(name[0]));
END BindFragDataLocationIndexed;

PROCEDURE GetFragDataIndex*(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetFragDataIndex(xprogram, ADDRESSOF(name[0]));
END GetFragDataIndex;

PROCEDURE GetSubroutineUniformLocation*(xprogram: Uint; shadertype: Enum; CONST name: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetSubroutineUniformLocation(xprogram, shadertype, ADDRESSOF(name[0]));
END GetSubroutineUniformLocation;

PROCEDURE GetSubroutineIndex*(xprogram: Uint; shadertype: Enum; CONST name: ARRAY OF CHAR): Uint;
BEGIN
	RETURN XglGetSubroutineIndex (xprogram, shadertype, ADDRESSOF(name[0]));
END GetSubroutineIndex;

PROCEDURE BindFragDataLocationEXT*(xprogram: Uint; colorNumber: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglBindFragDataLocationEXT(xprogram, colorNumber, ADDRESSOF(name[0]));
END BindFragDataLocationEXT;

PROCEDURE GetFragDataLocationEXT*(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetFragDataLocationEXT(xprogram, ADDRESSOF(name[0]));
END GetFragDataLocationEXT;

PROCEDURE CreateShaderProgramEXT* (xtype: Enum; CONST xstring: ARRAY OF CHAR): Uint;
BEGIN
	RETURN XglCreateShaderProgramEXT(xtype, ADDRESSOF(xstring[0]));
END CreateShaderProgramEXT;

PROCEDURE ProgramNamedParameter4fNV* (id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; x: Float; y: Float; z: Float; w: Float);
BEGIN
	XglProgramNamedParameter4fNV(id, len, ADDRESSOF(name[0]), x, y, z, w);
END ProgramNamedParameter4fNV;

PROCEDURE ProgramNamedParameter4dNV* (id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; x: Double; y: Double; z: Double; w: Double);
BEGIN
	XglProgramNamedParameter4dNV(id, len, ADDRESSOF(name[0]), x, y, z, w);
END ProgramNamedParameter4dNV;

PROCEDURE ProgramNamedParameter4fvNV*(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR;  v: PFloat);
BEGIN
	XglProgramNamedParameter4fvNV (id, len, ADDRESSOF(name[0]), v);
END ProgramNamedParameter4fvNV;

PROCEDURE ProgramNamedParameter4dvNV*(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR;  v: PDouble);
BEGIN
	XglProgramNamedParameter4dvNV(id, len, ADDRESSOF(name[0]), v);
END ProgramNamedParameter4dvNV;

PROCEDURE GetProgramNamedParameterfvNV*(id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; params: PFloat);
BEGIN
	XglGetProgramNamedParameterfvNV(id, len,  ADDRESSOF(name[0]), params);
END GetProgramNamedParameterfvNV;

PROCEDURE GetProgramNamedParameterdvNV* (id: Uint; len: Sizei; CONST name: ARRAY OF CHAR; params: PDouble);
BEGIN
	XglGetProgramNamedParameterdvNV (id, len, ADDRESSOF(name[0]), params);
END GetProgramNamedParameterdvNV;

PROCEDURE ActiveVaryingNV* (xprogram: Uint; CONST name: ARRAY OF CHAR);
BEGIN
	XglActiveVaryingNV(xprogram, ADDRESSOF(name[0]));
END ActiveVaryingNV;

PROCEDURE GetVaryingLocationNV*(xprogram: Uint; CONST name: ARRAY OF CHAR): Int;
BEGIN
	RETURN XglGetVaryingLocationNV (xprogram, ADDRESSOF(name[0]));
END GetVaryingLocationNV;

(* ------------------  *)
(*! wrapper procedures  *)

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
BEGIN
	IF GL_LibHandle # 0 THEN
		Unix.Dlclose(GL_LibHandle);
		KernelLog.String(GL_LibName); KernelLog.String(" unloaded."); KernelLog.Ln;
	END;
END OnClose;

BEGIN

	Modules.InstallTermHandler(OnClose);

	(* add following serach paths for libGL.so.1 to mulitiarch i386 systems*)
	(* nvidia *)
	libraryPaths[1] := "/usr/lib32/nvidia-current";
	libraryPaths[0] := "/usr/lib/i386-linux-gnu";

	(* amd, ati *)
	libraryPaths[2] := "/usr/lib32/fglrx";
	libraryPaths[3] := "/usr/lib/i386-linux-gnu/fglrx";
	(* mesa *)
	libraryPaths[7] := "/usr/lib/i386-linux-gnu/mesa";

	(* i386 systems *)
	libraryPaths[4] := "/usr/lib/nvidia-current";
	libraryPaths[5] := "/usr/lib/fglrx";
	(* mesa *)
	libraryPaths[6] := "/usr/lib/mesa";

	InitOpenGL();
	ReadOpenGLCore();
END OpenGL.
