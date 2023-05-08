shader_type canvas_item;

uniform float battery : hint_range(0.0,1.0) = 1.0;
uniform float anchor : hint_range(-1.0,1.0) = -0.5;
uniform float speed_scale : hint_range(1.0, 10.0) = 1.0;
uniform float fov : hint_range(0.01, 1.0) = 0.2;
uniform vec4 background_color : hint_color = vec4(0.0, 0.1, 0.2, 1.0);
uniform vec4 grid_color : hint_color = vec4(1.0, 0.5, 1.0, 1.0);

float grid(vec2 uv, float batt) {
    vec2 size = vec2(uv.y, uv.y * uv.y * 0.2) * 0.01;
    uv += vec2(0.0, TIME * speed_scale * (batt + 0.05));
    uv = abs(fract(uv) - 0.5);
	vec2 lines = smoothstep(size, vec2(0.0), uv);
//	vec2 lines = step(size, vec2(0.0));
	lines += smoothstep(size * 5.0, vec2(0.0), uv) * 0.125 * batt;
//	lines += step(size * 5.0, vec2(0.0)) * 0.4 * batt;
    return clamp(lines.x + lines.y, 0.0, 1.0);
}

void fragment() {
	vec2 uv = UV;
	vec4 col = background_color;
    uv.y = 3.0 / (abs(uv.y + fov) + 0.05);
	uv.x += anchor;
    uv.x *= uv.y * 1.0;
    float gridVal = grid(uv, battery);
    col = mix(background_color, grid_color, gridVal);
	COLOR = col;
}