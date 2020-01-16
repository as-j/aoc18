
Bitmap = {}
Bitmap.__index = Bitmap

function Bitmap.new(width, height)
    local self = {}
    setmetatable(self, Bitmap)
    self.data = {}
    for y=1,height do
        self.data[y] = {}
        for x=1,width do
            self.data[y][x] = {255,255,255}
        end
    end
    self.width = width
    self.height = height
    return self
end

function Bitmap:writeRawPixel(file, c)
    local dt
    file:write(string.pack("B", c))
end

function Bitmap:writeComment(fh, ...)
    local strings = {...}
    local str = ""
    local result
    for _, s in pairs(strings) do
        str = str .. tostring(s)
    end
    result = string.format("# %s\n", str)
    fh:write(result)
end

function Bitmap:writeP6(filename)
    local fh = io.open(filename, 'w')
    if not fh then
        error(string.format("failed to open %q for writing", filename))
    else
        fh:write(string.format("P6\n%d %d\n", self.width, self.height))
        self:writeComment(fh, "automatically generated at ", os.date())
        fh:write("255\n")
        for y, row in ipairs(self.data) do
            for x, pixel in ipairs(row) do
                self:writeRawPixel(fh, pixel[1])
                self:writeRawPixel(fh, pixel[2])
                self:writeRawPixel(fh, pixel[3])
            end
        end
    end
end

function Bitmap:fill(x, y, width, heigth, color)
    width = (width == nil) and self.width or width
    height = (height == nil) and self.height or height
    width = width + x
    height = height + y
    for i=y, height-1 do
        for j=x, width-1 do
            self:setPixel(j, i, color)
        end
    end
end

function Bitmap:setPixel(x, y, color)
    if x > self.width then
        error("x is bigger than self.width!")
        return false
    elseif x < 1 then
        error("x is smaller than 1!")
        return false
    elseif y > self.height then
        error("y is bigger than self.height!")
        return false
    elseif y < 1 then
        error("y is smaller than 1!")
        return false
    end
    self.data[y][x] = color
    return true
end

function example_colorful_stripes()
    local w = 256
    local h = 256
    local b = Bitmap.new(w, h)
    b:fill(1, 1, w, h, {255,255,255})
    for i=1, w do
        b:setPixel(i,1, {0,0,0})
        b:setPixel(1,i, {0,0,0})
        b:setPixel(i,w, {0,0,0})
        b:setPixel(h,i, {0,0,0})
    end
    return b
end

example_colorful_stripes():writeP6('p6.ppm')

return Bitmap
