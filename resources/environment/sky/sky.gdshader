shader_type sky;
uniform sampler2D sky_tex : source_color, repeat_disable, hint_default_black;
void sky() {
	const float MAX_UV = 1.0;
	vec2 uv = SKY_COORDS;
	uv.x = abs(2.0 * uv.x - MAX_UV);
	if (uv.y > 0.0)
		uv.y = smoothstep(-0.0, 1.0, uv.y);
	COLOR = texture(sky_tex, uv).rgb;
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
}
