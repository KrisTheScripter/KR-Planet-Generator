local module = {}

function module.randomWeld(parts:{BasePart}, base:BasePart, coroutines:number, printStatus:boolean)
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
	
	for i=1, coroutines do
		coroutine.wrap(weldloop)()
	end
	
	repeat
		task.wait()
		if printStatus then print("Welding: "..completed.."/"..#parts) end
	until completed >= #parts
end

function module.weld(parts:{BasePart}, base:BasePart, partsPerLoop:number, printStatus:boolean)
	local partSize = math.ceil(#parts / partsPerLoop)
	local completed = 0
	
	local function weldloop(imin, imax)
		for i=imin, imax do
			local v = parts[i]
			local w = Instance.new("WeldConstraint")
			w.Part0 = base
			w.Part1 = v
			w.Parent = v
			completed += 1
			if i % (5000) then task.wait() end
		end
	end
	
	for i=1, partsPerLoop do
		if i == partsPerLoop then
			coroutine.wrap(weldloop)(partSize*(i-1)+1, #parts)
		else
			coroutine.wrap(weldloop)(partSize*(i-1)+1, partSize*i)
		end
	end
	
	repeat
		task.wait()
		if printStatus then print("Welding: "..completed.."/"..#parts) end
	until completed >= #parts
end

return module