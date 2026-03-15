shader_type canvas_item;

uniform sampler2D mask: hint_white;
uniform vec2 maskScale = vec2(11,1);

uniform sampler2D charges: hint_black;
uniform sampler2D map;
uniform sampler2D paintJob;
uniform sampler2D normalMap: hint_normal;
uniform vec2 frames = vec2(1.0,1.0);

uniform float paintJobFactor = 0.0;
uniform float paintJobBrightAdjust = 16;

uniform float maxval = 2.0;
uniform float sparkBias = 0.0;
uniform vec2 scale = vec2(0.5,1.0);
uniform vec3 sparkColor = vec3(50.0,10.0,100.0);
uniform vec3 coatColor = vec3(0.02,0.02,0.02);
uniform vec4 sparkSpeed = vec4(0.011,0.013,0.017,0.019);
uniform float ref = 0.1;
uniform float roughness = 0.5;
uniform float reflectiveness = 1.0;
uniform float shine = 1;

float getCharge( vec2 pos, float t) {
	vec2 ps = pos * scale;
	return max( sparkBias + texture( map, pos ).b * 0.25 - 0.25
		 - texture(charges, ps + vec2(t*sparkSpeed.x,0.0)).r
	     - texture(charges, ps + vec2(0.0, t*sparkSpeed.y)).g
		 - texture(charges, ps - vec2(t*sparkSpeed.z,0.0)).b
		 - texture(charges, ps - vec2(0.0, t*sparkSpeed.a)).a, 0.0);
}

vec2 vmmv( vec2 o, vec2 u ) {
	if (u.x>o.x) o.x=u.x;
	if (u.y<o.y) o.y=u.y;
	return o;
}

vec2 vmm( vec2 o, float u) {
	if (u>o.x) o.x=u;
	if (u<o.y) o.y=u;
	return o;	
}

vec2 getNeighbourCharge(vec2 pos, vec2 stp, float time) {
	float c = getCharge(pos,time);
	vec2 o = vec2(c,c);
	
	o = vmm( o, getCharge(pos + vec2( stp.x,0.0), time));
	o = vmm( o, getCharge(pos + vec2(-stp.x,0.0), time));
	o = vmm( o, getCharge(pos + vec2(0.0,  stp.y), time));
	o = vmm( o, getCharge(pos + vec2(0.0, -stp.y), time));
	
	o = vmm( o, getCharge(pos + vec2( stp.x,  stp.y), time));
	o = vmm( o, getCharge(pos + vec2(-stp.x,  stp.y), time));
	o = vmm( o, getCharge(pos + vec2(-stp.x, -stp.y), time));
	o = vmm( o, getCharge(pos + vec2( stp.x, -stp.y), time));
	return o;
}

vec3 clampVec(vec3 v, float m) {
	return vec3(clamp(v.r,0.0,m),clamp(v.g,0.0,m),clamp(v.b,0.0,m));
}

void fragment() {
	vec4 m = texture( map, UV );
	vec4 nm = texture( normalMap, UV);
	NORMAL.xy = nm.xy*2.0-1.0;
	NORMAL.z = sqrt(max(0.0, 1.0 - dot(NORMAL.xy, NORMAL.xy)));
	vec2 refPos = (vec2(0.5,0.5)-SCREEN_UV)*0.5+vec2(0.5,0.5)+((nm.xy-vec2(0.5,0.5))*ref);
	vec4 pxmr = texture( SCREEN_TEXTURE, refPos, roughness );
	vec4 pxm = vec4(clampVec(pxmr.rgb,1.0), pxmr.a);
	vec4 tpx = texture( TEXTURE, UV );
	vec4 pjc = texture( paintJob, UV*frames );
	float paintFactor = max((1.0-m.r),pjc.a) * paintJobFactor;
	vec4 oc = tpx*(1.0-paintFactor) + pjc*(paintFactor)/paintJobBrightAdjust;
	
	vec3 reflectionColor = normalize(tpx.rgb+coatColor.rgb);
	vec3 reflectedPixel = reflectionColor * reflectiveness;
	vec3 reflection =  reflectedPixel * m.r * pxm.rgb;
	//vec4 px = vec4( tpx.rgb + reflection, tpx.a);
	vec4 px = vec4( oc.rgb + reflection, tpx.a);
	vec4 mapx = texture( mask, UV*maskScale );
	
	if (sparkBias > 0.0) {
		float c = getCharge(UV, TIME);
		float spark = 0.0;
		
		{
			vec2 p = UV + vec2( TEXTURE_PIXEL_SIZE.x,0.0 );
			if ( getCharge( p, TIME) > c ) {
				vec2 n = getNeighbourCharge( p, TEXTURE_PIXEL_SIZE, TIME);
				if (n.y == c ) {
					spark += n.x-c;
				}
			}
		}
		{
			vec2 p = UV + vec2( -TEXTURE_PIXEL_SIZE.x,0.0 );
			if ( getCharge( p, TIME) > c ) {
				vec2 n = getNeighbourCharge( p, TEXTURE_PIXEL_SIZE, TIME);
				if (n.y == c ) {
					spark += n.x-c;
				}
			}
		}
		{
			vec2 p = UV + vec2( 0.0, TEXTURE_PIXEL_SIZE.y );
			if ( getCharge( p, TIME) > c ) {
				vec2 n = getNeighbourCharge( p, TEXTURE_PIXEL_SIZE, TIME);
				if (n.y == c ) {
					spark += n.x-c;
				}
			}
		}
		{
			vec2 p = UV + vec2( 0.0, -TEXTURE_PIXEL_SIZE.y );
			if ( getCharge( p, TIME) > c ) {
				vec2 n = getNeighbourCharge( p, TEXTURE_PIXEL_SIZE, TIME);
				if (n.y == c ) {
					spark += n.x-c;
				}
			}
		}
		
		vec2 n = getNeighbourCharge( UV, TEXTURE_PIXEL_SIZE, TIME);
		if ( c == 0.0 && n.x > 0.0 ) {
			spark += n.x * 4.0;	
		}
		
		spark = clamp(spark,0.0,1.0);
		
		
		//COLOR = vec4( spark, c, 0.0, 1.0);
		COLOR = vec4( clampVec(px.rgb + sparkColor.rgb * spark * spark, maxval), min(px.a,mapx.a));
	} else {
		COLOR = vec4( clampVec(px.rgb,maxval), min(px.a,mapx.a));
	}
}

void light() {
	vec3 light_dir = normalize(vec3(-LIGHT_VEC, LIGHT_HEIGHT));
	float d = max(0.0, dot(NORMAL, light_dir))*2.0;
	vec4 l = LIGHT;
	vec4 t = texture(map,UV);
	float b = d*d*shine;
	
	LIGHT = max((l*(1.0-t.r) + l*b*t.r)*t.b,0.0);
}
