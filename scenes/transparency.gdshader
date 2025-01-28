shader_type spatial;
uniform sampler2D tex : hint_default_black;

void vertex(){
	//COLOR.a = texture(tex, UV).a;
	//VERTEX.
}

void fragment() {
	vec3 col = texture(tex, UV).rgb;
	ALPHA = (col.r + col.g + col.b)/3.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
