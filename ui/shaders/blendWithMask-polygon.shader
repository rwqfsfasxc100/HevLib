shader_type canvas_item;
render_mode blend_add;

uniform sampler2D mask: hint_white;
uniform vec2 maskScale = vec2(12,1);


// Added params
const int MAX_POINTS = 64;

uniform int hframes = 1;
uniform int vframes = 1;

uniform sampler2D poly_tex : hint_albedo;
uniform int tex_width = 1;

// Added methods
vec2 get_point(int i, float row_v) {
	return texture(poly_tex, vec2((float(i) + 0.5) / float(tex_width), row_v)).rg;
}

bool point_in_polygon(vec2 p, int count, float row_v) {
	bool inside = false;
	for (int i = 0; i < MAX_POINTS; i++) {
		if (i >= count) {
			break;
		}
		int j = (i == 0) ? count - 1 : i - 1;
		vec2 a = get_point(i, row_v);
		vec2 b = get_point(j, row_v);
		if (((a.y > p.y) != (b.y > p.y)) && (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x)) {
			inside = !inside;
		}
	}
	return inside;
}





void fragment() {
	vec4 px = texture(TEXTURE,UV);
	vec4 mx = texture(mask, UV*maskScale);
	
	COLOR = vec4(px.rgb,min(px.a,mx.a));
	
	// Modified portion
	vec2 grid = vec2(float(hframes), float(vframes));
	vec2 cell = clamp(floor(UV * grid), vec2(0.0), grid - vec2(1.0));
	vec2 local_uv = UV * grid - cell;
	int frame = int(cell.y) * hframes + int(cell.x);
	
	float row_v = (float(frame) + 0.5) / (grid.x * grid.y);
	int count = int(texture(poly_tex, vec2(0.5 / float(tex_width), row_v)).b + 0.5);
	
	if (count < 3 || !point_in_polygon(local_uv, count, row_v)) {
		COLOR.a = 0.0;
	}
}