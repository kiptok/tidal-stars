uniform vec4 color1;
uniform vec4 color2;
uniform float moonRadius;
uniform float moonPhase;
uniform vec2 moonCenter;
uniform float seed;

#define PI 3.1415926535

// Perlin's quintic interpolation curve
float quinticStep (float edge0, float edge1, float x) {
	float t;
	t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t*t*t*(t*(t*6.-15.)+10.);
}

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

vec2 random2(vec2 st){
  st = vec2( dot(st,vec2(127.1,311.7)), dot(st,vec2(269.5,183.3)) );
  return -1.0 + 2.0*fract(sin(st)*43758.5453123+seed*9761.2035667);
}

// Gradient Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/XdXGW8
float noise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);

  vec2 u = f*f*(3.0-2.0*f);

  return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
    dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
		mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
    dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

// float octaveNoise(vec2 st, int octaves) {

// }

float repeatNoise(vec2 st, float limit) {
	vec2 i = floor(st);
	vec2 f = fract(st);

	vec2 u = f*f*(3.0-2.0*f);

	return mix(mix(dot(random2(mod(i+vec2(0.0,0.0), limit)), f-vec2(0.0,0.0)),
								 dot(random2(mod(i+vec2(1.0,0.0), limit)), f-vec2(1.0,0.0)), u.x),
						 mix(dot(random2(mod(i+vec2(0.0,1.0), limit)), f-vec2(0.0,1.0)),
						 		 dot(random2(mod(i+vec2(1.0,1.0), limit)), f-vec2(1.0,1.0)), u.x), u.y);
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st -= moonCenter;
	st = st / vec2(moonRadius); // -1 to 1 coordinates

	float radius = length(st);
	vec2 wh = vec2(sqrt(1. - st.y*st.y), sqrt(1. - st.x*st.x)); // width/height at each point

	st = st / wh; // make points circular ratios

	float phase = mod(st.x / 4. + moonPhase, 1.); // phase of each point

	// terrain map
	float scale 	= 2.;
	float terrain;
	terrain += repeatNoise(vec2(st.x*scale, st.y*wh.y*scale),scale*2.)*.5+.5;
	terrain += repeatNoise(vec2(st.x*2.*scale, st.y*wh.y*2.*scale)+scale*3.,scale*4.)*.25+.25;
	terrain += repeatNoise(vec2(st.x*4.*scale, st.y*wh.y*4.*scale)+scale*9.,scale*8.)*.125+.125;
	terrain += repeatNoise(vec2(st.x*8.*scale, st.y*wh.y*8.*scale)+scale*21.,scale*16.)*.0625+.0625;

	float peaks 	= smoothstep(0.875, 2., terrain);
	float valleys = smoothstep(0.875, -.25, terrain);

	// float shadow = smoothstep(0.175, 0.325, phase) - smoothstep(0.675, 0.825, phase);
	// shadow = smoothstep(0.2, 0.3, phase) - smoothstep(0.7, 0.8, phase);
	// phase *= smoothstep(0.175, 0.325, phase);
	// phase *= smoothstep(0.825, 0.675, phase);
	// phase *= shadow;
	float shadow = quinticStep(0.1875, 0.3125, phase) - quinticStep(0.6875, 0.8125, phase);

	vec4 light = color1;
	vec4 dark = color2;

	light = mix(light, vec4(1.0), peaks);
	dark = mix(dark, vec4(vec3(0.0),1.0), valleys);

	color = mix(light, dark, shadow);
	// color = mix(color, vec4(1.0), peaks);
	// color = mix(color, vec4(vec3(0.0),1.0), valleys);

	return color;
}