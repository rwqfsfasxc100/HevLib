shader_type canvas_item;

// Whether the ring data should be converted into an HSV heatmap to make differences more obvious
uniform bool heatmap = true;

// Whether the heatmap should clamp to steps of 0.05, rounding down to the nearest step amount
uniform bool clamp_heatmap = false;

// Display mode
// mode 0 : Chaos (getPixelAt() red channel)
// mode 1 : Ringroid size bias (getPixelAt() green channel)
// mode 2 : Raw density (getPixelAt() blue channel)
// mode 3 : Class 1 (largest) ringroid density heatmap (getTargetDensityAt() index 0)
// mode 4 : Class 2 ringroid density heatmap (getTargetDensityAt() index 1)
// mode 5 : Class 3 ringroid density heatmap (getTargetDensityAt() index 2)
// mode 6 : Class 4 ringroid density heatmap (getTargetDensityAt() index 3)
// mode 7 : Class 5 (smallest) ringroid density heatmap (getTargetDensityAt() index 4)
// mode 8 : Most prevalent ringroid size. Further along the heatmap, the larger class of ringroid
uniform int mode : hint_range(0, 8) = 0;

// Opacity of the display
uniform float opacity : hint_range(0.0, 1.0,0.05) = 1.0;

// Minimum and maximum values that a pixel must have to not be darkened
uniform float min_val : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform float max_val : hint_range(0.0, 1.0, 0.05) = 1.0;

// Multiplier used for all pixels with values outside of the minimum and maximum values
uniform float darken_factor : hint_range(0.0, 1.0) = 0.0;

// Ring map texture
// Use res://ring/ring-map.png
uniform sampler2D ring_map: hint_black;

vec3 hue2rgb(float r) {
	if (clamp_heatmap) {
		int ctr = 0;
		while (r > 0.0) {
			ctr++;
			r -= 0.05;
		}
		r = 0.05 * float(ctr);
	}
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
	
	vec3 out_color = vec3(0.0,0.0,0.0);
	
	float this_opacity = opacity;
	
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
		
		out_color = vec4(pu * (1.0 - cy) + pd * (cy)).rgb;
		if (mode == 0) {
			float val = out_color.r;
			if (val < min_val || val > max_val) {
				this_opacity *= darken_factor
			}
			if (heatmap) {
				out_color = hue2rgb(val)
			}
			else {
				out_color = vec3(val,0.0,0.0)
			}
		}
		else if (mode == 1) {
			float val = out_color.g;
			if (val < min_val || val > max_val) {
				this_opacity *= darken_factor
			}
			if (heatmap) {
				out_color = hue2rgb(val)
			}
			else {
				out_color = vec3(0.0,val,0.0);
			}
		}
		else if (mode == 2) {
			float val = out_color.b;
			if (val < min_val || val > max_val) {
				this_opacity *= darken_factor
			}
			if (heatmap) {
				out_color = hue2rgb(val)
			}
			else {
				out_color = vec3(0.0,0.0,val);
			}
		}
		else if (mode > 2 && mode < 9) {
			float a = 0.0;
			float b = 0.0;
			float c = 0.0;
			float d = 0.0;
			float e = 0.0;
			float initial_mass = out_color.b  * 1024.0;
			float total_mass = initial_mass;
			float size_bias = out_color.g;
			
			int mc = int(pow(float(5), 2.0));
			float cfv = float(4) / 4.0;
			float dr = 1.0 - abs(cfv - size_bias);
			float pick = total_mass * pow(dr,3.0);
			a = float(clamp(int(pick / float(mc)), 0, 64));
			total_mass = max(0,(total_mass - (a * float(mc))));
			
			int mc1 = int(pow(float(4), 2.0));
			float cfv1 = float(3) / 4.0;
			float dr1 = 1.0 - abs(cfv1 - size_bias);
			float pick1 = total_mass * pow(dr1,3.0);
			b = float(clamp(int(pick1 / float(mc1)), 0, 96));
			total_mass = max(0,(total_mass - (b * float(mc1))));
			
			int mc2 = int(pow(float(3), 2.0));
			float cfv2 = float(2) / 4.0;
			float dr2 = 1.0 - abs(cfv2 - size_bias);
			float pick2 = total_mass * pow(dr2,3.0);
			c = float(clamp(int(pick2 / float(mc2)), 0, 128));
			total_mass = max(0,(total_mass - (c * float(mc2))));
			
			int mc3 = int(pow(float(2), 2.0));
			float cfv3 = float(1) / 4.0;
			float dr3 = 1.0 - abs(cfv3 - size_bias);
			float pick3 = total_mass * pow(dr3,3.0);
			d = float(clamp(int(pick3 / float(mc3)), 0, 160));
			total_mass = max(0,(total_mass - (d * float(mc3))));
			
			int mc4 = int(pow(float(1), 2.0));
			float cfv4 = float(0) / 4.0;
			float dr4 = 1.0 - abs(cfv4 - size_bias);
			float pick4 = total_mass * pow(dr4,3.0);
			e = float(clamp(int(pick4 / float(mc4)), 0, 192));
//				vec4 ov = vec4(mix(mix(a/64.0,b/96.0,0.5),mix(b/96.0,c/128.0,0.5),0.5),mix(mix(b/96.0,c/128.0,0.5),mix(c/128.0,d/160.0,0.5),0.5),mix(mix(c/128.0,d/160.0,0.5),mix(d/160.0,e/192.0,0.5),0.5),1.0);
//				out_color = ov;
			float ov = 0.0;
			if (mode > 2 && mode < 8) {
				if (mode == 3) {
					ov = (a / 64.0)// * 32.0;
				}
				else if (mode == 4) {
					ov = (b / 96.0)// * 16.0;
				}
				else if (mode == 5) {
					ov = (c / 128.0)// * 8.0;
				}
				else if (mode == 6) {
					ov = (d / 160.0)// * 4.0;
				}
				else if (mode == 7) {
					ov = (e / 192.0)// * 2.0;
				}
				if (ov < min_val || ov > max_val) {
					this_opacity *= darken_factor
				}
				if (heatmap) {
					out_color = hue2rgb(ov);
				}
				else {
					out_color = vec3(0.0,0.0,ov);
				}
			}
			else if (mode == 8) {
				float blue = 0.0;
				float ctr = 0.0;
				if (a > 0.0) {
					ctr = a;
					blue = 1.0;
				}
				if (b > ctr) {
					ctr = b;
					blue = 0.8;
				}
				if (c > ctr) {
					ctr = c;
					blue = 0.6;
				}
				if (d > ctr) {
					ctr = d;
					blue = 0.4;
				}
				if (e > ctr) {
					ctr = e;
					blue = 0.2;
				}
				if (blue < min_val || blue > max_val) {
					this_opacity *= darken_factor
				}
				if (heatmap) {
					out_color = hue2rgb(blue * 0.75);
				}
				else {
					out_color = vec3(0.0,0.0,blue);
				}
			}
		}
	}
	COLOR = vec4(out_color,this_opacity);
}