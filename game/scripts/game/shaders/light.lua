return love.graphics.newShader [[
    const int MAX_LIGHTS = 10;  // Adjust based on your needs
    extern vec2 lightPositions[MAX_LIGHTS];  // Positions of the light sources
    extern vec2 lightRadii[MAX_LIGHTS];      // x and y Radii of the lights
    extern float lightOpacity[MAX_LIGHTS];  // Opacity of the lights
    extern int lightCount;  // Number of lights currently in use
    extern float gradientDefault;  // How dark the screen is by default

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        float gradient = gradientDefault;

        for (int i = 0; i < lightCount; i++) {
            // Calculate the normalized distance in the x and y directions
            vec2 normDist = (screen_coords - lightPositions[i]) / lightRadii[i];

            // Calculate the elliptical distance
            float distance = length(normDist);

            // Calculate gradient based on the distance and accumulate
            gradient -= (1.0 - clamp(distance, 0.0, 1.0)) * lightOpacity[i];
        }

        // Clamp the final gradient between 0.0 and 1.0
        gradient = clamp(gradient, 0.0, 1.0);

        // Return color with modified alpha
        return vec4(color.rgb, gradient);
    }
]]
