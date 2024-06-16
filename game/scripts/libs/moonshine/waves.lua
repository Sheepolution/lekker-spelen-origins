--[[
Public domain:

Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
]]
--

return function(moonshine)
    -- Waves distortion
    local shader = love.graphics.newShader [[
      extern float curves;
      extern float time;
      extern float amount;

      vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {
        float fadeFactor = 1.0 - pow(2.0*uv.x - 1.0, 2.0);
        uv.x += sin(uv.y*curves+time*6)*(amount*0.03) * fadeFactor;
        return Texel(tex, uv);
      }
    ]]

    local setters = {}

    setters.curves = function(v)
        assert(type(v) == "number", "Invalid value for `curves'")
        shader:send("curves", v)
    end

    setters.time = function(v)
        assert(type(v) == "number", "Invalid value for `time'")
        shader:send("time", v)
    end

    setters.amount = function(v)
        assert(type(v) == "number", "Invalid value for `amount'")
        shader:send("amount", v)
    end

    local defaults = {
        time = 0,
        curves = 5,
        amount = 1
    }

    return moonshine.Effect {
        name = "waves",
        shader = shader,
        setters = setters,
        defaults = defaults
    }
end
