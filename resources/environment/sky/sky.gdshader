shader_type sky;

uniform sampler2D tex : filter_nearest , repeat_enable;
global uniform float speed : hint_range(0.0, 100.0, 5.) = 1.0;


void sky(){
	vec2 uv =  SKY_COORDS+vec2(SKY_COORDS.y*PI+TIME*speed/1000.);

	COLOR.rgb = pow(texture(tex, uv).rgb, vec3(2.));


}