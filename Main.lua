--[[
Version 2.0

Made by Kris (dc: kris_the_dev)

> Reworked the whole code
> New noise system
> New biome system
> New customization settings (view Utils.Default)

]]

local module = {}

--Variables

local utils = script.Parent.Utils

local icoInfo = require(utils.IcosphereInfo)
local createTriangle = require(utils.TriangleCreator)
local perlinNoise = require(utils.PerlinNoise)
local weldingModule = require(utils.Welding)
local types = require(utils.Types)
local default = require(utils.Default)


export type Parameters = types.Parameters
export type Biome = types.Biome

--Functions

local function changeProperties(object:Instance|{}, props:{})
	for i, v in pairs(props) do
		object[i] = v
	end
end

local function getMedian(pos1:Vector3, pos2:Vector3)
	return (pos1 + pos2) / 2
end

local function getCentre()
	local median = icoInfo.Vertices[1]
	
	for _, vert in pairs(icoInfo.Vertices) do
		median = getMedian(median, vert)
	end
	
	return median
end

local function countTable(tbl:{})
	local i = 0
	
	for _, _ in pairs(tbl) do
		i += 1
	end
	
	return i
end

--[[local function findIndex(tab, tofind)
	for i, v in pairs(tab) do
		if i == tofind then return v end
	end
end]]

local function findInTable(tbl:{}, index:number)
	local curIndex = 0
	for _, v in pairs(tbl) do
		curIndex += 1
		if curIndex == index then return v end
	end
end

local function autoFill(v, auto)
	if v == nil then return auto
	else return v end
end

local function getTerrainHeight(pos:Vector3, centre:Vector3, rad:number, deform:Vector3)
	local posDiff = pos-centre
	local diff = posDiff.Magnitude * (posDiff.Unit / deform).Magnitude / rad-1
	return diff*1000
end

--Module functions

function generationDone(parent:Model, params:types.Parameters, biomes:{types.Biome})
	local radius, deform = params.Gen.Radius, params.Gen.Deform
	
	local centre = getCentre()
	
	-- functions
	
	local function randomize(num:number)
		num *= (math.random(98, 102) / 100)
		num = math.clamp(num, 0, 1)
		
		return num
	end
	
	local function randBiome()
		local rand = math.random(1, countTable(biomes))
		local index = 0
		
		for name, v in pairs(biomes) do
			index += 1
			if index == rand then
				return name
			end
		end
	end
	
	--filling biomes
	
	for i, v in pairs(biomes) do
		if not v.Weight then
			v.Weight = math.random(1, countTable(biomes))
		end
	end
	
	--Painting
	
	local triangles:{WedgePart} = parent:GetChildren()
	local completed = 0
	
	local function paintTriangles(imin, imax)
		for i=imin, imax do
			local triangle = triangles[i]
			local height = getTerrainHeight(triangle.Position, getCentre(), params.Gen.Radius, params.Gen.Deform)-- / (500 * (Pars.Gen.Radius / 1000));
			local biome, maxWeight = nil, 0
			
			for _, v in pairs(biomes) do
				if v:IsValid(height) then
					if v.Weight > maxWeight then
						maxWeight = v.Weight
						biome = v
					end
				end
			end
			
			if not biome then
				biome = randBiome()
			end
			
			triangle.Color = Color3.new(randomize(biome.Color.R),randomize(biome.Color.G),randomize(biome.Color.B))
			triangle.Material = biome.Material
			triangle.Name = biome.Name.."["..tostring(height).."]"
			
			completed += 1
			if i % (params.Gen.LoadingSpeed * 2) == 0 then task.wait() end
		end;
	end
	local partcount: number = params.Gen.TerrainCoroutines
	local part = math.ceil(#triangles/partcount)
	
	for i=1, partcount do
		if i == partcount then
			coroutine.wrap(paintTriangles)(part*(i-1) + 1, #triangles)
		else
			coroutine.wrap(paintTriangles)(part*(i-1) + 1, part*i)
		end
	end
	
	repeat
		task.wait()
		if params.PrintStatus then print("Painting: "..completed.."/"..#triangles) end
	until completed == #triangles
	task.wait()
	
	local core = Instance.new("Part")
	changeProperties(core, {
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.CrackedLava,
		Anchored = params.Gen.IsAnchored,
		Name = "Core",
		Position = getCentre(),
		Parent = parent,
		Color = Color3.fromRGB(255, 0, 0)
	})
	task.wait()
	
	local coreMesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
	changeProperties(coreMesh, {
		Scale = Vector3.new(1, 1, 1) * (params.Gen.Radius * 0.75),
		Parent = core
	});
	task.wait()
	
	parent.PrimaryPart = core
	
	if params.Sea.Radius > 0 then
		local Water = Instance.new("Part");
		changeProperties(Water, {
			Color = params.Sea.Color,
			Material = params.Sea.Material,
			Size = Vector3.new(1, 1, 1),
			Position = getCentre(),
			Name = "Sea",
			CastShadow = false,
			Transparency = params.Sea.Transparency,
			CanCollide = false,
			Anchored = false,
			Parent = parent
		});
		task.wait()
		
		local Mesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
		changeProperties(Mesh, {
			Scale = Vector3.new(1, 1, 1) * params.Gen.Deform * params.Sea.Radius * 2,
			Parent = Water
		})
		task.wait()
		
		local Weld = Instance.new("WeldConstraint")
		changeProperties(Weld, {
			Part0 = parent.PrimaryPart,
			Part1 = Water,
			Parent = parent.PrimaryPart,
			Name = "SeaWeld"
		})
	end
	--welding
	local weldingType = params.Gen.WeldingType
	
	if weldingType then
		local parts = {}
		
		for i, v in pairs(parent:GetChildren()) do
			if v:IsA("WedgePart") then table.insert(parts, v) end
		end
		
		if weldingType == "Random" then
			weldingModule.randomWeld(parts, core, 100, params.PrintStatus)
		elseif weldingType == "Default" then
			weldingModule.weld(parts, core, 100, params.PrintStatus)
		end
	else
		for i, v: WedgePart in pairs(parent:GetChildren()) do
			if not v:IsA("WedgePart") then continue end
			v.Transparency = 0
			v.CanCollide = true
		end
	end
	
	parent:PivotTo(CFrame.new(params.Gen.Position))
	
	if params.PrintStatus then print("Completed") end
	--And done!
end;

function startGeneration(parent, params:types.Parameters, biomes:{types.Biome})
	-- Import
	
	local resolution, radius = params.Gen.Resolution, params.Gen.Radius
	local isSmoothSubdivide = params.Gen.IsSmoothSubdivide
	
	local mountStart, mountMod = params.Noise.MountainsStart, params.Noise.MountainsModifier
	local noiseSeed = params.Noise.Seed
	local noiseAmpl, noiseSmoothness, noiseOffset = params.Noise.Amplitude, params.Noise.Smoothness, params.Noise.Offset
	
	
	local centre = getCentre()
	local trianglesTable = {}
	
	
	-- Start
	
	for _, triangle in pairs(icoInfo.Triangles) do
		local corners = {1}

		for i, vertNum in pairs(triangle) do
			local vert = icoInfo.Vertices[vertNum +1]

			corners[i] = vert * radius
		end

		table.insert(trianglesTable, corners)
	end
	
	--[[local function getCoords(centre, point)
		local dir = (point - centre).Unit
		local up = Vector3.new(0, 1, 0)
		local right = Vector3.new(1, 0, 0)

		local y = math.deg(math.acos(up:Dot(dir)))
		local x = math.deg(math.atan2(dir.Z,dir.X))

		return Vector2.new(x, y)
	end]]
	
	local function getCoords(pos:Vector3)
		return pos/noiseSmoothness/(radius/35)
	end
	
	local loadingSpeed = params.Gen.LoadingSpeed
	local completed = 0

	local partcount: number = params.Gen.TerrainCoroutines
	local part = math.ceil(#trianglesTable/partcount)
	
	local function subdivide(amount, isSmooth)
		local deform = params.Gen.Deform
		for i = 1, amount do
			local newTriangles = {}
			for _, triangle in pairs(trianglesTable) do
				local corners = {}
				
				for i, vert in pairs(triangle) do
					corners[i] = vert
				end
				
				local A:Vector3 = getMedian(corners[1], corners[2])
				local B:Vector3 = getMedian(corners[2], corners[3])
				local C:Vector3 = getMedian(corners[3], corners[1])
				
				if isSmooth then
					A = (A-centre).Unit*radius
					B = (B-centre).Unit*radius
					C = (C-centre).Unit*radius
				end
				
				table.insert(newTriangles, {corners[1], A, C})
				table.insert(newTriangles, {corners[2], B, A})
				table.insert(newTriangles, {corners[3], C, B})
				table.insert(newTriangles, {A, B, C})
			end
			
			trianglesTable = newTriangles
			
			task.wait()
			if params.PrintStatus then print("Subdivide: "..i) end
		end
	end
	local function pasteTriangles(iMin, iMax)
		for i=iMin, iMax do
			local Triangle = trianglesTable[i]
			local w1, w2 = createTriangle(Triangle[1], Triangle[2], Triangle[3], parent)
			completed += 1
			if i % math.round(loadingSpeed / 4) == 0 then task.wait() end
		end
	end
	
	subdivide(resolution, isSmoothSubdivide)
	
	--Applying noise
	local deform = params.Gen.Deform
	
	for triangleIndex, vertices in pairs(trianglesTable) do
		for vertIndex, vertice in pairs(vertices) do
			vertices[vertIndex] = (vertice - centre).Unit*deform*radius
			
			local vert = vertices[vertIndex]
			local noise = perlinNoise.new(getCoords(vert), noiseSeed, noiseAmpl, noiseOffset)
			local dir = (vert - centre)
			
			if noise > mountStart then noise *= mountMod end
			
			vertices[vertIndex] = vert + (dir * (noise * 0.10))
		end;
		
		if triangleIndex % 2500 == 0 then
			task.wait()
			if params.PrintStatus then
				print("Generating: "..tostring(triangleIndex).."/"..#trianglesTable)
			end
		end
	end
	
	for i=1, partcount do
		if i == partcount then
			coroutine.wrap(pasteTriangles)(part*(i-1) + 1, #trianglesTable)
		else
			coroutine.wrap(pasteTriangles)(part*(i-1) + 1, part*i)
		end
	end
	
	repeat
		task.wait()
		if params.PrintStatus then print("Pasting: "..completed.."/"..#trianglesTable) end
	until completed == #trianglesTable
	
	generationDone(parent, params, biomes);
end;

function module.GenerateSpaceObject(name:string, params:types.Parameters, biomes:{types.Biome}, parent:Instance)
	local obj = Instance.new("Model")
	obj.Name = name
	obj.Parent = parent
	
	local function checkParams(defaultTbl:{}, paramsTbl:{})
		for i, v in pairs(defaultTbl) do
			if paramsTbl[i] then
				if typeof(v) == "table" then
					checkParams(v, params[i])
				end
			else
				paramsTbl[i] = v
			end
		end
	end
	
	checkParams(default, params)
	
	startGeneration(obj,params,biomes)
end

print("This planet generator was made by Kris (dc: kris_the_dev)")

return module