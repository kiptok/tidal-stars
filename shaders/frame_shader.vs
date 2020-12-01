extern vec4 color1;
extern vec4 color2;
extern float time;

#define PI 3.1415926535

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 st) {
	st = st / love_ScreenSize.xy;

  float pct = smoothstep(0.0, 0.5, fract(st.x+time*0.04));
  pct += smoothstep(1.0, 0.5, fract(st.x+time*0.04));

	// st.x -= smoothstep(0.6, 0.8, st.x);

	color = mix(color1, color2, pct);
	return color;
}