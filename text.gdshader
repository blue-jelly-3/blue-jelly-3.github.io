shader_type canvas_item;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void fragment() {
	//if (UV.x > 0.97 || UV.x<0.03 || UV.y > 0.97 || UV.y < 0.03){
	//	COLOR = vec4(UV.x + sin(TIME),UV.y + sin(TIME),random(UV),1);
	//}
	
	if (UV.x > 0.9999 || UV.x<0.0001 || UV.y > 0.9999 || UV.y < 0.0001){
		COLOR = vec4(UV,1,1);
	}
}


