shader_type spatial;

varying float b;

void vertex()
{
	b = INSTANCE_CUSTOM.x;	
}

uniform sampler2D tex;

void fragment()
{
	float hFrameNum = 7.0;
	float vFrameNum = 7.0;
	float diameter = 1.0 / hFrameNum;
	float radius = diameter / 2.0;
	
	// GRID	
	float xGrid = smoothstep(0.05, 0.1, fract(hFrameNum * UV.x));
	float yGrid = smoothstep(0.1, 0.15, fract(vFrameNum * UV.y));

	// CIRC
	float index = 1.;
	vec2 offset = vec2(radius + mod(index, hFrameNum) * diameter, radius + floor(index / (0.999 * vFrameNum)) * diameter);
	vec2 co = vec2(0.5) - offset;
	vec2 uvC = UV - co;
	//float circ = smoothstep(radius, radius + 0.01, length((UV - offset) - co));
	float circ = smoothstep(radius, radius + 0.01, length(uvC - offset));
	
	// COL
	// DEBUG GRID
	vec3 col = vec3(UV.x, UV.y, 0.) * xGrid * yGrid * circ;
	
	// FRAGCOL
	//ALBEDO = col;
	ALBEDO = texture(tex, uvC).xyz * (1. - circ);
	//ALBEDO = vec3(circ);
	//
	//ALBEDO = vec3(1.0);
}