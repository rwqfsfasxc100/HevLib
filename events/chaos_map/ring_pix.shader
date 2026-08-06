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
// mode 8 : Most prevalent ringroid size. Further along the heatmap, the larger class of ringroid is the most common for it's target density
uniform int mode : hint_range(0, 8) = 0;

// Opacity of the display
uniform float opacity : hint_range(0.0, 1.0,0.05) = 1.0;

// Minimum and maximum values that a pixel must have to not be darkened
uniform float min_val : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform float max_val : hint_range(0.0, 1.0, 0.05) = 1.0;

// Multiplier used for all pixels with values outside of the minimum and maximum values
uniform float darken_factor : hint_range(0.0, 1.0,0.01) = 0.0;

// Ring map texture
// Use res://ring/ring-map.png
uniform sampler2D ring_map: hint_black;

// Creates an HSV colour using a value for the Hue
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

// Fragment shader to mimic the behaviour of the getPixelAt() / getTargetDensityAt() methods from res://TheRing.gd
void fragment() {
	vec3 out_color = vec3(0.0,0.0,0.0);
	float this_opacity = opacity;
	// Only processes when opacity is above zero, for efficiency
	if (this_opacity > 0.0) {
		// Gets pixel data and clamps to nearest neighbour
		float pixelToKm = 10000.0;
		vec2 pos = (UV / TEXTURE_PIXEL_SIZE);
		vec2 size = vec2(textureSize(ring_map,0));
		float x = (floor(clamp(floor(pos.x), 0.0, size.x - 1.0)));
		int sy = int(floor(size.y));
		float y = float(((int(floor(pos.y)) % sy) + sy) % sy);
		float x1 = (clamp(float(x + 1.0), 0.0, size.x - 1.0));
		float y1 = float(int(y + 1.0) % int(size.y));
		
		// Only process if x is above zero. Means left most pixel is always transparent.
		if (x > 0.0) {
			vec4 p00 = texture(ring_map, vec2(x,y) * TEXTURE_PIXEL_SIZE);
			vec4 p01 = texture(ring_map, vec2(x1,y) * TEXTURE_PIXEL_SIZE);
			vec4 p11 = texture(ring_map, vec2(x1,y1) * TEXTURE_PIXEL_SIZE);
			vec4 p10 = texture(ring_map, vec2(x,y1) * TEXTURE_PIXEL_SIZE);
			
			float cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm;
			float cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm;
			
			vec4 pu = (p00 * (1.0 - cx) + p10 * (cx));
			vec4 pd = (p01 * (1.0 - cx) + p11 * (cx));
			
			// Usual output of getPixelAt()
			out_color = vec4(pu * (1.0 - cy) + pd * (cy)).rgb;
			
			// Processing modes, used for transforming of pixel data
			if (mode == 0) {
				// Display chaos (red channel)
				float val = out_color.r;
				if (val < min_val) {
					this_opacity *= darken_factor;
				}
				else if (val > max_val) {
					this_opacity *= darken_factor;
				}
				if (heatmap) {
					out_color = hue2rgb(val);
				}
				else {
					out_color = vec3(val,0.0,0.0);
				}
			}
			else if (mode == 1) {
				// Display size bias (green channel)
				float val = out_color.g;
				if (val < min_val) {
					this_opacity *= darken_factor;
				}
				else if (val > max_val) {
					this_opacity *= darken_factor;
				}
				if (heatmap) {
					out_color = hue2rgb(val);
				}
				else {
					out_color = vec3(0.0,val,0.0);
				}
			}
			else if (mode == 2) {
				// Display raw density (blue channel)
				float val = out_color.b;
				if (val < min_val) {
					this_opacity *= darken_factor;
				}
				else if (val > max_val) {
					this_opacity *= darken_factor;
				}
				if (heatmap) {
					out_color = hue2rgb(val);
				}
				else {
					out_color = vec3(0.0,0.0,val);
				}
			}
			else if (mode > 2 && mode < 9) {
				// Format to getTargetDensityAt() output
				float a = 0.0;
				float b = 0.0;
				float c = 0.0;
				float d = 0.0;
				float e = 0.0;
				float initial_mass = out_color.b  * 1024.0;
				float total_mass = initial_mass;
				float size_bias = out_color.g;
				
				float mc = pow(5.0, 2.0);
				a = float(clamp(int(total_mass * pow(1.0 - abs(1.0 - size_bias),3.0) / mc), 0, 64));
				total_mass = max(0,(total_mass - (a * mc)));
				
				float mc1 = pow(4.0, 2.0);
				b = float(clamp(int(total_mass * pow(1.0 - abs(0.75 - size_bias),3.0) / mc1), 0, 96));
				total_mass = max(0,(total_mass - (b * mc1)));
				
				float mc2 = pow(3.0, 2.0);
				c = float(clamp(int(total_mass * pow(1.0 - abs(0.5 - size_bias),3.0) / mc2), 0, 128));
				total_mass = max(0,(total_mass - (c * mc2)));
				
				float mc3 = pow(2.0, 2.0);
				d = float(clamp(int(total_mass * pow(1.0 - abs(0.25 - size_bias),3.0) / mc3), 0, 160));
				total_mass = max(0,(total_mass - (d * mc3)));
				
				e = float(clamp(int(total_mass * pow(1.0 - abs(0.0 - size_bias),3.0) / float(pow(float(1), 2.0))), 0, 192));
				float ov = 0.0;
				
				if (mode > 2 && mode < 8) {
					if (mode == 3) {
						// Display class 1 ringroids (getTargetDensityAt() index 0)
						ov = (a / 64.0);
					}
					else if (mode == 4) {
						// Display class 2 ringroids (getTargetDensityAt() index 1)
						ov = (b / 96.0);
					}
					else if (mode == 5) {
						// Display class 3 ringroids (getTargetDensityAt() index 2)
						ov = (c / 128.0);
					}
					else if (mode == 6) {
						// Display class 4 ringroids (getTargetDensityAt() index 3)
						ov = (d / 160.0);
					}
					else if (mode == 7) {
						// Display class 5 ringroids (getTargetDensityAt() index 4)
						ov = (e / 192.0);
					}
					if (ov < min_val) {
						this_opacity *= darken_factor;
					}
					else if (ov > max_val) {
						this_opacity *= darken_factor;
					}
					if (heatmap) {
						out_color = hue2rgb(ov);
					}
					else {
						out_color = vec3(0.0,0.0,ov);
					}
				}
				else if (mode == 8) {
					// Display the most prevalent ringroid size (highest value within getTargetDensityAt() output)
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
					if (blue < min_val) {
						this_opacity *= darken_factor;
					}
					else if (blue > max_val) {
						this_opacity *= darken_factor;
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
	}
	// Change colour to output
	COLOR = vec4(out_color,this_opacity);
}