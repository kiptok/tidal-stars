uniform vec4 color1;
uniform vec4 color2;
uniform float moonRadius;
uniform float moonPhase;
uniform vec2 moonCenter;
uniform float time;

#define PI 3.1415926535

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

vec2 random2(vec2 st){
  st = vec2( dot(st,vec2(127.1,311.7)), dot(st,vec2(269.5,183.3)) );
  return -1.0 + 2.0*fract(sin(st)*43758.5453123);
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

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st -= moonCenter;
	st = st / vec2(moonRadius); // -1 to 1 coordinates

	float radius = length(st);
	vec2 wh = vec2(sqrt(1. - st.y*st.y), sqrt(1. - st.x*st.x)); // width/height at each point

	st = st / wh; // make points circular ratios

	float phase = mod(st.x / 4. + moonPhase, 1.); // phase of each point

	phase = phase - smoothstep(0.9, 1.1, phase);
	phase = phase + smoothstep(0.1, -0.1, phase);

	color = mix(color1, color2, phase);

	// terrain map
	float scale = 10;
	float peaks = smoothstep(0.5, 0.6, noise(mod(st*scale+phase*scale*4.,scale*4.)));
	float valleys = smoothstep(0.5, 0.6, noise(mod(st*scale+phase*scale*4.,scale*4.)+scale*4.));

	color.rgb = (color.rgb+peaks-valleys)/3.+1./3.;

	return color;
}