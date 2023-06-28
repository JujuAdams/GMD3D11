show_debug_overlay(true);

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
draw_set_lighting(true);

model = vertex_buffer_load("rubber_duck_toy_1k.bin", vertex_format_pnuc);
vertex_freeze(model);

vs = d3d11_shader_compile_vs(working_directory + "shaders/TestVS.hlsl", "main", "vs_4_0");

if (!d3d11_shader_exists(vs))
{
	show_error(d3d11_get_error_string(), true);
}

ps = d3d11_shader_compile_ps(working_directory + "shaders/TestPS.hlsl", "main", "ps_4_0");

if (!d3d11_shader_exists(ps))
{
	show_error(d3d11_get_error_string(), true);
}

instanceNumber = 4096;

d3d11_cbuffer_begin();
// Instance position could be just float3, but cbuffer size must be divisible by 16!
d3d11_cbuffer_add_float(4 * instanceNumber);
instanceData = d3d11_cbuffer_end();

if (!d3d11_cbuffer_exists(instanceData))
{
	show_error("Could not create instanceData!", true);
}

var _buffer = buffer_create(d3d11_cbuffer_get_size(instanceData), buffer_fixed, 1);

repeat (instanceNumber)
{
	buffer_write(_buffer, buffer_f32, random(room_width));
	buffer_write(_buffer, buffer_f32, random(room_height));
	buffer_write(_buffer, buffer_f32, 0.0);
	buffer_write(_buffer, buffer_f32, 0.0);
}

d3d11_cbuffer_update(instanceData, _buffer);

buffer_delete(_buffer);

camera = camera_create();
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-70, -window_get_width() / window_get_height(), 0.1, 10000));
z = 0;
directionUp = 0;
mouseLastX = 0;
mouseLastY = 0;
