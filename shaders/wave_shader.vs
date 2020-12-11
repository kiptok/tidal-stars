uniform vec4 color1;
uniform vec4 color2;
uniform vec2 waveResolution;
uniform vec2 wavePosition;
uniform vec2 offset;
uniform float time;
uniform vec2 tide;
uniform float ripX1[6];
uniform float ripX2[6];
uniform float ripX3[6];
uniform float ripX4[6];
uniform float ripY1[6];
uniform float ripY2[6];

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
	// st = mod(st, waveResolution);
	st = st / waveResolution; // something is wrong here where the screen changes when x resets to 0

	vec2 ripple;
	ripple.x += sin(st.y*ripX1[0]*2.*PI+ripX1[1]+time*ripX1[2])*ripX1[3]*cos(time*ripX1[4]+ripX1[5]);
	ripple.x += sin(st.y*ripX2[0]*2.*PI+ripX2[1]+time*ripX2[2])*ripX2[3]*cos(time*ripX2[4]+ripX2[5]);
	ripple.x += sin(st.y*ripX3[0]*2.*PI+ripX3[1]+time*ripX3[2])*ripX3[3]*cos(time*ripX3[4]+ripX3[5]);
	ripple.x += sin(st.y*ripX4[0]*2.*PI+ripX4[1]+time*ripX4[2])*ripX4[3]*cos(time*ripX4[4]+ripX4[5]);
	ripple.y += sin(st.x*ripY1[0]*2.*PI+ripY1[1]+time*ripY1[2])*ripY1[3]*cos(time*ripY1[4]+ripY1[5]);
	ripple.y += sin(st.x*ripY2[0]*2.*PI+ripY2[1]+time*ripY2[2])*ripY2[3]*cos(time*ripY2[4]+ripY2[5]);

	st += ripple;
  st += tide;

  // st.x = (st.x + 0.12) / 0.24;
  // st.y = (st.y + 1.1) / 2.2; // how do i do this

  float stepscale = 0.4;
  st = fract(st);

  // st.x = st.x - smoothstep(0.)

	st.x = st.x - smoothstep(0.990, 1.01, st.x);
	st.x = st.x + smoothstep(0.990, 1.01, 1.-st.x);
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