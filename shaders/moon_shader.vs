extern vec4 color1;
extern vec4 color2;
extern float moonRadius;
extern float moonPhase;
extern vec2 moonCenter;
extern float time;

#define PI 3.1415926535

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

float easeInOutCirc (float x) {
	return x < 0.5
  	? (1 - sqrt(1 - pow(2 * x, 2))) / 2
  	: (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
}

float easeInOutCubic (float x) {
	return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st -= moonCenter;
	st = st / vec2(moonRadius); // -1 to 1 coordinates

	float radius = length(st);
	float width = sqrt(1. - st.y*st.y);

	// st.x = length(st);

	st.x = st.x / width;

	float phase = mod(st.x / 4. + moonPhase, 1.);

	phase = phase - smoothstep(0.9, 1.1, phase);
	phase = phase + smoothstep(0.1, -0.1, phase);

	color = mix(color1, color2, phase);
	return color;
}