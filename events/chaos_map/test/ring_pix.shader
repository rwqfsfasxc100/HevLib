shader_type canvas_item;

uniform int mode : hint_range(0, 2) = 0;
uniform bool raw = false;

uniform sampler2D ring_map: hint_black;

vec3 hsv2rgb(float r) {
	vec3 c = vec3(r,1.0,1.0);
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float pixelToKm = 10000.0;
	vec2 u = UV;
	vec2 pos = (u / (TEXTURE_PIXEL_SIZE));
	vec2 size = vec2(textureSize(ring_map,0));
	float x = (floor(clamp(floor(pos.x), 0.0, size.x - 1.0)));
	int sy = int(floor(size.y));
	float y = float(((int(floor(pos.y)) % sy) + sy) % sy);
	float x1 = (clamp(float(x + 1.0), 0.0, size.x - 1.0));
	float y1 = float(int(y + 1.0) % int(size.y));
	
	vec4 out_color = vec4(0.0,0.0,0.0,0.0);
	
	if (x > 0.0) {
		vec2 tpx = TEXTURE_PIXEL_SIZE;
		vec4 p00 = texture(ring_map, vec2(x,y) * tpx);
		vec4 p01 = texture(ring_map, vec2(x1,y) * tpx);
		vec4 p11 = texture(ring_map, vec2(x1,y1) * tpx);
		vec4 p10 = texture(ring_map, vec2(x,y1) * tpx);
		
		float cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm;
		float cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm;
		
		vec4 pu = (p00 * (1.0 - cx) + p10 * (cx));
		vec4 pd = (p01 * (1.0 - cx) + p11 * (cx));
		
		out_color = pu * (1.0 - cy) + pd * (cy);
		if (raw) {
			if (mode == 1) {
				out_color = vec4(0.0,out_color.g,0.0,1.0);
			}
			else if (mode == 2) {
				out_color = vec4(0.0,0.0,out_color.b,1.0);
			}
			else {
				out_color = vec4(out_color.r,0.0,0.0,1.0);
			}
		}
		else {
			if (mode == 1) {
				out_color = vec4(hsv2rgb(out_color.g),1.0);
			}
			else if (mode == 2) {
				out_color = vec4(hsv2rgb(out_color.b),1.0);
			}
			else {
				out_color = vec4(hsv2rgb(out_color.r),1.0);
			}
		}
	}
	COLOR = out_color;
}