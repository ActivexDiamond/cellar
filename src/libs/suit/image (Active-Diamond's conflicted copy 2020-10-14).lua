local BASE = (...):match('(.-)[^%.]+$')

local function isType(val, typ)
	return type(val) == "userdata" and val.typeOf and val:typeOf(typ)
end

local function ImageButton(core, normal, ...)
	local opt, x, y, sx, sy = core.getOptionsAndSize(...)	-------------------
	sx, sy = sx or 1, sy or 1
	opt.normal = normal or opt.normal or opt[1]
	opt.hovered = opt.hovered or opt[2] or opt.normal
	opt.active = opt.active or opt[3] or opt.hovered
	opt.id = opt.id or opt.normal

	local image = assert(opt.normal, "No image for state `normal'")

	core:registerMouseHit(opt.id, x, y, function(u,v)
		-- mouse in image?
		u, v = math.floor(u+.5), math.floor(v+.5)
		if u < 0 or u >= (image:getWidth()*sx) or v < 0 or v >= (image:getHeight()*sy) then	-----------------------
			return false
		end

		if opt.mask then
			-- alpha test
			assert(isType(opt.mask, "ImageData"), "Option `mask` is not a love.image.ImageData")
			assert(u < opt.mask:getWidth() and v < opt.mask:getHeight(), "Mask may not be smaller than image.")
			local _,_,_,a = opt.mask:getPixel(u,v)
			return a > 0
		end

		return true
	end)

	if core:isActive(opt.id) then
		image = opt.active
	elseif core:isHovered(opt.id) then
		image = opt.hovered
	end

	assert(isType(image, "Image"), "state image is not a love.graphics.image")

	core:registerDraw(opt.draw or function(image, x, y, sx, sy, r, g, b, a)
		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(image, x, y, 0, sx, sy)
	end, image, x, y, sx, sy, love.graphics.getColor())

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end

local mask = love.image.newImageData(256, 256)  --TODO: base on max allowed rese

return function(core, normal, x, y, sx, sy)
	sx, sy = sx or 1, sy or 1
	return ImageButton(core, normal, {mask = mask}, x, y, sx, sy)	
end 
