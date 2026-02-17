shader_type canvas_item;

uniform float aa_strength : hint_range(0.0, 2.0) = 1.0;
uniform float edge_sensitivity : hint_range(0.0, 1.0) = 0.3;
uniform bool adaptive_quality = true;

// Calculate color difference
float color_distance(vec3 c1, vec3 c2) {
    vec3 diff = c1 - c2;
    return sqrt(dot(diff, diff));
}

void fragment() {
    vec2 texel_size = SCREEN_PIXEL_SIZE;
    vec2 uv = SCREEN_UV;
    
    // Sample center and 4-directional neighbors
    vec3 center = texture(SCREEN_TEXTURE, uv).rgb;
    vec3 north = texture(SCREEN_TEXTURE, uv + vec2(0.0, -texel_size.y)).rgb;
    vec3 south = texture(SCREEN_TEXTURE, uv + vec2(0.0, texel_size.y)).rgb;
    vec3 east = texture(SCREEN_TEXTURE, uv + vec2(texel_size.x, 0.0)).rgb;
    vec3 west = texture(SCREEN_TEXTURE, uv + vec2(-texel_size.x, 0.0)).rgb;
    
    // Calculate edge strength
    float edge_h = color_distance(west, east);
    float edge_v = color_distance(north, south);
    float edge_strength = max(edge_h, edge_v);
    
    // Skip AA if no edge detected
    if (edge_strength < edge_sensitivity * 0.5)
        COLOR = vec4(center, 1.0);
    else {
	    // Determine blend amount based on edge strength
	    float blend_factor = smoothstep(edge_sensitivity * 0.5, edge_sensitivity * 2.0, edge_strength);
	    blend_factor *= aa_strength;
	    
	    // Sample diagonal corners for better quality
	    vec3 northwest = texture(SCREEN_TEXTURE, uv + vec2(-texel_size.x, -texel_size.y)).rgb;
	    vec3 northeast = texture(SCREEN_TEXTURE, uv + vec2(texel_size.x, -texel_size.y)).rgb;
	    vec3 southwest = texture(SCREEN_TEXTURE, uv + vec2(-texel_size.x, texel_size.y)).rgb;
	    vec3 southeast = texture(SCREEN_TEXTURE, uv + vec2(texel_size.x, texel_size.y)).rgb;
	    
	    // Adaptive sampling based on edge direction
	    vec3 blended;
	    if (adaptive_quality) {
	        if (edge_h > edge_v)
				// Horizontal edge - blend vertically
	            blended = (center * 2.0 + north + south) * 0.25;
	        else
				// Vertical edge - blend horizontally
	            blended = (center * 2.0 + east + west) * 0.25;
	    } else {
	        // Simple 9-tap filter
	        blended = (
	            center * 4.0 +
	            north + south + east + west +
	            northwest * 0.5 + northeast * 0.5 + southwest * 0.5 + southeast * 0.5
	        ) / 10.0;
	    }
	    
	    // Final blend
	    vec3 result = mix(center, blended, blend_factor);
	    COLOR = vec4(result, 1.0);
	}
}
