local once = {}

local noop = function () end

function once.new(obj)
    return setmetatable({_obj = obj, _used = {}},  once)
end

function once:__index(k)
    local f = self._obj[k]
    if k == "free" then
        return once.free
    elseif f then
        if not self._used[f] then
            self._used[f] = true
            f(self._obj)
        end
    end
    return noop
end

function once:__call(f, ...)
    f = type(f) == "string" and self._obj[f] or f
    if not self._used[f] then
        self._used[f] = true
        return f(self._obj, ...)
    end
end

function once:free(f, f2, ...)
    f = type(f) == "string" and self._obj[f] or f
    f2 = type(f2) == "string" and self._obj[f2] or f2
    if self._used[f] then
        self._used[f] = nil
        if f2 then
            return f2(self._obj, ...)
        end
    end
end

return once