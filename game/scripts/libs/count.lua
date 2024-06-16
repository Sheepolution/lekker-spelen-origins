--
-- count
--
-- Copyright (c) 2019 Sheepolution

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local function rand(range)
    return math.random(range[1], range[2])
end

local count = {}
count.__index = count

function count:__call(reset)
    if reset == true then
        self.count = self.max
        return
    end

    if reset == false then
        return self.count <= 0
    end

    if self.count <= 0 and not self.auto then
        return true
    end

    self.count = self.count - 1
    if self.count <= 0 then
        if self.auto then
            self.count = self.range and rand(self.range) or self.max
        end

        return true
    end

    return false
end

function count.new(a, b, auto)
    if type(b) == "boolean" then
        auto = b
        b = nil
    end

    local range = b and { a, b } or nil
    a = range and rand(range) or a
    return setmetatable({
        range = range,
        max = a,
        count = a,
        auto = auto ~= false
    }, count)
end

return count
