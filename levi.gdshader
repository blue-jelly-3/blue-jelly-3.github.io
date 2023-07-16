shader_type canvas_item;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void fragment() {
	if (UV.x > 0.97*sin(2.0*TIME) || UV.x<0.03*cos(TIME) || UV.y > 0.97*cos(TIME) || UV.y < 0.03*sin(TIME*2.0)){
		COLOR = vec4(UV.x + sin(TIME),UV.y + sin(TIME),random(UV),1);
	}
}


