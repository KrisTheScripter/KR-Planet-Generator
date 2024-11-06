local module = {}

function module.RandomWeld(parts: {BasePart}, base: BasePart, cors: number, prstatus: boolean)
	local completed = 0
	local function weldloop()
		for i, v: BasePart in pairs(parts) do
			if v:FindFirstChildOfClass("WeldConstraint") then continue end
			local w = Instance.new("WeldConstraint")
			w.Part0 = base
			w.Part1 = v
			w.Parent = v
			completed += 1
			task.wait()
		end
	end
	for i=1, cors do
		coroutine.wrap(weldloop)()
	end
	repeat
		task.wait()
		if prstatus then print("Welding: "..completed.."/"..#parts) end
	until completed >= #parts
end

function module.PartsWeld(stack: {BasePart}, base: BasePart, partscount: number, loadingspeed: number, prstatus: boolean)
	local partsize = math.ceil(#stack / partscount)
	local completed = 0
	local function weldloop(imin, imax)
		for i=imin, imax do
			local v = stack[i]
			local w = Instance.new("WeldConstraint")
			w.Part0 = base
			w.Part1 = v
			w.Parent = v
			completed += 1
			if i % (5000) then task.wait() end
		end
	end
	for i=1, partscount do
		if i == partscount then
			coroutine.wrap(weldloop)(partsize*(i-1)+1, #stack)
		else
			coroutine.wrap(weldloop)(partsize*(i-1)+1, partsize*i)
		end
	end
	repeat
		task.wait()
		if prstatus then print("Welding: "..completed.."/"..#stack) end
	until completed >= #stack
end

return module
