shader_type canvas_item;
render_mode blend_add;
uniform sampler2D tex : hint_screen_texture, filter_linear;
uniform float strength: hint_range(0.0, 1.0, 0.01);


void fragment() {
	vec4 col = texture(tex, UV);
	float avg = (col.r + col.g + col.b)/3.0;
	COLOR = vec4(avg, avg, avg, col.a);
	//COLOR += vec4(avg, avg, avg, strength);
	
	//COLOR.rgb = mix(col.rgb, vec3(avg), strength);
	//COLOR.a = strength;
}
