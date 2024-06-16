local wave = [[
    extern number time;
    extern vec2 center;    // center of the circle
    extern number radius;  // radius of the circle

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 displacement = vec2(sin(texture_coords.y * 25.0 + time) * 0.03, 0.0);

        // Calculate the distance from the center of the circle to current pixel
        float dist = distance(screen_coords, center);

        // If it's outside the circle, don't apply the wave effect
        if (dist > radius) {
            displacement = vec2(0.0, 0.0);
        }

        return Texel(texture, texture_coords + displacement);
    }
]]

return wave
