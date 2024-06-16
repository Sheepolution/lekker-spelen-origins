local _ = require "base.utils"

local list = {
	border = {
		body = [[
			finTex.r = border_color[0]/255.0;
			finTex.g = border_color[1]/255.0;
			finTex.b = border_color[2]/255.0;
		]],
		externs = { color = { 255, 255, 255 } }
	},

	mask = {
		body = [[
			float mask_value = Texel(mask_image, p).a;
			finTex.a *= 1.0 - mask_value;
		]],
		externs = { image = "Image" }
	},
	mask_gradient = {
		body = [[
			float mask_value = Texel(mask_gradient_image, p).g;
			if (mask_value < mask_gradient_threshold) {
				finTex.a  = 0.0;
			}
		]],
		externs = { image = "Image", threshold = 0 }
	},
	blur = {
		body = [[
			color = vec4(0);
			vec2 st;
			vec2 pixdir = blur_direction / blur_imageSize;
			for (float i = -blur_radius; i <= blur_radius; i++) {
			st.xy = i * pixdir;
			color += Texel(tex, p + st);
			}
			return color / (2.0 * blur_radius + 1.0);
	   ]],
		externs = { direction = { 1, 1 }, imageSize = { 1, 1 }, radius = 1 }
	},

	noise = {
		body = [[
			p += rand(p, noise_rnd)/(1000/noise_amount);
			finTex = Texel(tex, p);
		]],
		externs = { amount = 10, rnd = 1 },
		funcs = { "rand" }
	},

	waves = {
		body = [[
			a = 1.0 - pow(2.0*p.x - 1.0, 2.0);
			p.x += sin(p.y*waves_curves+waves_time*6)*(waves_amount*0.03) * a;
			finTex = Texel(tex, p);
		]],
		externs = { time = 0, curves = 5, amount = 1 }
	},

	waves_area = {
		body = [[
			np = vec2(0, 0);
			
			for (int i = 0; i < 2; i++) {
				vec2 center = waves_area_circles[i];
				float radius = waves_area_radius;
				// Calculate the distance from the center of the circle to current pixel
				float dist = distance(pc, center);

				// If it's inside the circle, apply the wave effect
				if (dist <= radius) {
					np += vec2(sin(p.y * waves_area_curves + waves_area_time * waves_area_speed) * (waves_area_amount * 0.03), 0.0);
				}
			}

			p += np;

			finTex = Texel(tex, p);
		]],
		externs = { time = 0, speed = 1, curves = 5, amount = 1, radius = 4, circles = { { 0, 0 }, { 0, 0 } } }
	},
	teeth = {
		body = [[
			p.x += asin(sin(p.y*teeth_curves+teeth_time*6))*(teeth_amount*0.03);
			finTex = Texel(tex, p);
		]],
		externs = { time = 0, curves = 5, amount = 1 }
	},

	bulge = {
		body = [[
			np = vec2(p.x - bulge_pos.x, p.y - bulge_pos.y);
			a = length(np);
			b = atan(np.y, np.x);
			a = (a*a);
			np = a * vec2(cos(b), sin(b));
			p = np + bulge_pos;
			finTex = Texel(tex, p);
		]],
		externs = { pos = { 0.5, 0.5 } }
	},

	pinch = {
		body = [[
			np = vec2(p.x - pinch_pos.x, p.y - pinch_pos.y);
			a = length(np);
			b = atan(np.y, np.x);
			a = sqrt(a);
			np = a * vec2(cos(b), sin(b));
			p = np + pinch_pos;
			finTex = Texel(tex, p);
		]],
		externs = { pos = { 0.5, 0.5 } }
	},

	pixel = {
		body = [[
			p = floor(p*pixel_amount)/(pixel_amount);
			finTex = Texel(tex, p);
		]],
		externs = { amount = 1 }
	},

	sucker = {
		body = [[
			a = atan(sucker_pos.x - p.y, sucker_pos.y - p.x);
			p += -vec2(cos(a)/(100/(sucker_amount*sucker_amount)), sin(a)/(100/(sucker_amount*sucker_amount)));
			finTex = Texel(tex, p);
		]],
		externs = { amount = 1, pos = { 0.5, 0.5 } }
	},

	insidespin = {
		body = [[
			a = atan(0.5 - p.y, 0.5 - p.x);
			p += vec2(cos(a)/insidespin_amount, sin(a)/insidespin_amount);
			finTex = Texel(tex, p);
		]],
		externs = { amount = 1 }
	},

	curve = {
		body = [[
			a = abs(p.x - 0.5);
			p.y -= (a*a)*3;
			p.x += (p.x > 0.5 ? a : -a)*(p.y/2);
			finTex = Texel(tex, p);
		]],
		externs = {}
	},

	rgb = {
		body = [[
			a = 0.0025 * rgb_amount;
			finTex.r = 	texture2D(tex, vec2(p.x + a * rgb_dirs[0], p.y + a * rgb_dirs[1])).r;
			finTex.g = texture2D(tex, vec2(p.x + a * rgb_dirs[2], p.y + a * rgb_dirs[3])).g;
			finTex.b = 	texture2D(tex, vec2(p.x + a * rgb_dirs[4], p.y + a * rgb_dirs[5])).b;
		]],
		externs = { dirs = { 1, 0, 0, 1, -1, -1 }, amount = 3 }
	},

	monochrome = {
		body = [[
			vec3 lightGreen = vec3(123.0/255.0, 255.0/255.0, 48.0/255.0);

			// Convert RGB value to grayscale
			float grayscale = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
			
			// Assign the grayscale value to all RGB channels
			finTex.rgb = mix(lightGreen, lightGreen, grayscale);
		]],
		externs = {}
	},


	tvnoise = {
		body = [[
			finTex.r -= -tvnoise_light + 1 + rand(p, tvnoise_rnd);
			finTex.g -= -tvnoise_light + 1 + rand(p, tvnoise_rnd);
			finTex.b -= -tvnoise_light + 1 + rand(p, tvnoise_rnd);
		]],
		externs = { light = 1, rnd = 1 },
		funcs = { "rand" }
	},

	invert = {
		body = [[
			finTex.r = 1.0-finTex.r;
			finTex.g = 1.0-finTex.g;
			finTex.b = 1.0-finTex.b;
		]],
		externs = {}
	},

	distortion = {
		body = [[
			finTex.r = (sin(finTex.r * distortion_amount) + 1.) * .5;
			finTex.g = (sin(finTex.g * distortion_amount) + 1.) * .5;
			finTex.b = (sin(finTex.b * distortion_amount) + 1.) * .5;
		]],
		externs = { amount = 20 },
		funcs = { "wave" }
	},

	spinsucker = {
		body = [[
			a = atan(p.y - 0.5, 0.5 - p.x);
			p.x += sin(a) * spinsucker_amount;
			p.y += cos(a) * spinsucker_amount;
			finTex = Texel(tex, p);
		]],
		externs = { amount = 1 }
	},

	circle = {
		body = [[
			a = sqrt(abs(p.x - circle_pos[0])*abs(p.x - circle_pos[0]) + abs(p.y - circle_pos[1])*abs(p.y - circle_pos[1]));
			if (circle_soft) {
				finTex.a = 1 - a*2 / circle_amount;
			} else {
				finTex.a = floor( 1 + (1 - a*2 * circle_amount));
			}
		]],
		externs = { amount = 1, soft = true, pos = { 0.5, 0.5 } }
	},

	color = {
		body = [[
			finTex.r *= color_color[0]/255.0;
			finTex.g *= color_color[1]/255.0;
			finTex.b *= color_color[2]/255.0;
		]],
		externs = { color = { 255, 255, 255 } }
	},

	scan = {
		body = [[
		if (p.y > scan_y && p.y < scan_y + scan_height) {
			finTex.r -= -scan_light + 1 + rand(p, scan_rnd);
			finTex.g -= -scan_light + 1 + rand(p, scan_rnd);
			finTex.b -= -scan_light + 1 + rand(p, scan_rnd);
		}
		]],
		externs = { y = 0, height = 1, light = 1, rnd = 1 },
		funcs = { "rand" }
	},

	experiment = {
		body = [[
		]],
		externs = {}
	}
}

local functions = {
	rand = [[float rand(vec2 co, float v) {
			return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 * v);
		}]],
	wave = [[float wave(float x, float amount) {
			return (sin(x * amount) + 1.) * .5;
		}]],
	dist = [[float dist(vec2 a, vec2 b){
			return sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2));
		}]]
}

local function getExternType(a)
	local t = type(a)
	if t == "number" then return "float" end
	if t == "boolean" then return "bool" end
	if t == "table" then
		local t2 = type(a[1])
		if t2 == "number" then
			if #a <= 4 then
				return "vec" .. #a
			else
				return "float[" .. #a .. "]"
			end
		elseif t2 == "table" then
			return "vec" .. #a[1] .. "[" .. #a .. "]"
		end
	end

	return a
end

local Shader = {}

function Shader.new(...)
	local names = { ... }

	local funcs = {}
	local externs = {}
	local header = [[
		vec4 effect(vec4 color, Image tex, vec2 p, vec2 pc) {
		vec4 finTex = Texel(tex, p);
		vec2 np;
		float a, b, c;
	]]
	local bodies = {}

	for i, v in ipairs(names) do
		local shader = list[v]
		table.insert(bodies, shader.body)

		for k, ext in pairs(shader.externs) do
			table.insert(externs, "extern " .. getExternType(ext) .. " " .. v .. "_" .. k .. ";\n")
		end

		if shader.funcs then
			for j, func in ipairs(shader.funcs) do
				table.insert(funcs, functions[shader.funcs[j]])
			end
		end
	end

	local extern_string = table.concat(externs, "")
	local funcs_string = table.concat(_.unique(funcs), "")
	local body_string = table.concat(bodies, "")
	local footer = "return finTex;}"
	local final = extern_string .. funcs_string .. header .. body_string .. footer

	local s = love.graphics.newShader(final)
	for i, v in ipairs(names) do
		for k, ext in pairs(list[v].externs) do
			if type(ext) == "table" and (#ext > 4 or type(ext[1]) == "table") then
				s:send(v .. "_" .. k, unpack(ext))
			else
				if ext ~= "Image" then
					s:send(v .. "_" .. k, ext)
				end
			end
		end
	end
	return s
end

--check whether a shader has a certain extern
function Shader.has(name, extern)
	return list[name].externs[extern]
end

return Shader
