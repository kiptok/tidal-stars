extern vec4 color1;
extern vec4 color2;
extern vec2 waveResolution;
extern vec2 wavePosition;
extern vec2 offset;
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
	st -= offset;
	st += wavePosition;
	st = st / waveResolution;

	vec2 wave; // wave is an offset
	float wave1 = sin(st.y*2.*PI+time*0.07)*0.005*cos(time*0.47);
	float wave2 = sin((st.y+0.031)*2.7*PI+time*0.061)*0.005*cos(time*0.39+0.117);
	float wave3 = cos((st.y+0.337)*3.7*PI+time*0.037)*0.005*sin(time*0.53+0.571);
	float wave4 = cos((st.y+0.829)*3.1*PI+time*0.051)*0.005*sin(time*0.21+0.883); // randomize the values here
	wave.x = wave1 + wave2 + wave3 + wave4;

	float waveX1 = sin(st.x*4.*PI+time*0.011)*0.5*cos(time*0.39);
	float waveX2 = cos(st.x*8.*PI+time*0.017)*0.5*sin(time*0.35);
	wave.y = wave.y + waveX1 + waveX2;

	vec2 tide;
	float tide1 = cos(time*0.2)*0.05;
	float tide2 = sin(time*0.29)*0.05;
	tide.x = tide.x + tide1 + tide2;

	st += wave;
  st += tide;

  float stepscale = 0.4;

	st.x = st.x - smoothstep(0.998, 1.002, st.x);
	st.x = st.x + smoothstep(0.998, 1.002, 1.-st.x);
	st.x = st.x - smoothstep(0.900, 1.000, st.x) * stepscale;
	st.x = st.x + smoothstep(0.900, 1.000, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.800, 0.900, st.x) * stepscale;
	st.x = st.x + smoothstep(0.800, 0.900, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.700, 0.800, st.x) * stepscale;
	st.x = st.x + smoothstep(0.700, 0.800, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.600, 0.700, st.x) * stepscale;
	st.x = st.x + smoothstep(0.600, 0.700, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.500, 0.600, st.x) * stepscale;
	st.x = st.x + smoothstep(0.500, 0.600, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.400, 0.500, st.x) * stepscale;
	st.x = st.x + smoothstep(0.400, 0.500, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.300, 0.400, st.x) * stepscale;
	st.x = st.x + smoothstep(0.300, 0.400, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.200, 0.300, st.x) * stepscale;
	st.x = st.x + smoothstep(0.200, 0.300, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.100, 0.200, st.x) * stepscale;
	st.x = st.x + smoothstep(0.100, 0.200, 1.-st.x) * stepscale;
	st.x = st.x - smoothstep(0.000, 0.100, st.x) * stepscale;
	st.x = st.x + smoothstep(0.000, 0.100, 1.-st.x) * stepscale;

	st.y = st.y - smoothstep(0.75, 1.25, st.y);
	st.y = st.y + smoothstep(0.75, 1.25, 1.-st.y);

	float pct = st.x*st.y;
	color = mix(color1, color2, pct);
	return color;
}