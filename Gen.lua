--Version 1.0
--Made by Kris (xXxKrisstalDragonxXx)
--Pars table example:
--[[

{
	Noise = {
		Amplitude = 3,
		Persistence = 0.5,
		Octaves = 20,
		MountainsMod = 1.5,
		MountainsFrom = 0.45,
		NoiseDivider = 7,
		Seed = 0.148
	},
	Sea = {
		Radius = 5080,
		Color = Color3.fromRGB(52, 106, 255),
		Transparency = 0.65,
		Material = Enum.Material.SmoothPlastic
	},
	Gen = {
		Resolution = 5,
		Radius = 5000,
		Weld = false,
		IsSmoothSubdivide = true,
		IsAnchored = true,
		Coroutines = 100,
		Position = Vector3.new(0, 0, 0)
	},
	PrintStatus = false
}

]]
--Biomes table example:
--[[

{
	Sand = {
		Material = Enum.Material.Sand,
		Color = Color3.fromRGB(109, 93, 0),
		Min = 0.48,
		Max = 0.505
	},
	Grass = {
		Material = Enum.Material.Grass,
		Color = Color3.fromRGB(0, 130, 4),
		Min = 0.505,
		Max = 0.53
	},
	Rocky = {
		Material = Enum.Material.Rock,
		Color = Color3.fromRGB(94, 94, 94),
		Min = 0.53,
		Max = 0.545
	},
	Mountain = {
		Material = Enum.Material.Snow,
		Color = Color3.fromRGB(255, 255, 255),
		Min = 0.545,
		Max = 1
	},
	Deep = {
		Material = Enum.Material.Granite,
		Color = Color3.fromRGB(121, 121, 121),
		Min = 0,
		Max = 0.48
	}
	
}

]]

local module = {}

--Variables

local RunService = game:GetService("RunService");
local IcosphereInformation = require(script.IcosphereInformation);
local Draw3DTriangle = require(script.Draw3DTriangle);
local Vertices = IcosphereInformation[2];
local TriSet = IcosphereInformation[1];
local ThreeDNoise = require(script.PerlinNoise);

--Functions

local function SetProperties(Object, Properties)
	for Property, Value in pairs(Properties) do
		Object[Property] = Value;
	end;
end;

local GetMedian = function(Position1, Position2)
	return (Position1 + Position2) / 2;
end;

local GetCentre = function()
	local Median = Vertices[1];
	for _, Vertice in pairs(Vertices) do
		Median = GetMedian(Median, Vertice);
	end;
	return Median;
end;

local function countTable(tab)
	local i = 0
	for _, _ in pairs(tab) do
		i += 1
	end
	return i
end

local function findIndex(tab, tofind)
	for i, v in pairs(tab) do
		if i == tofind then return v end
	end
end

local function fromNumber(tab, num)
	local i2 = 0
	for i, v in pairs(tab) do
		i2 += 1
		if i2 == num then return v end
	end
end

--Module functions

function GenerationDone(Planet,Biomes,LoadingSpeed,Pars)
	--Filling the biomes' parameters if not set
	for i, v in pairs(Biomes) do
		if not v.Min or not v.Max then --PLEASE CONSIDER USING YOUR OWN MIN AND MAX THIS THING IS SMTH
			v.Min = math.random(400, 550) / 1000
			local biome
			repeat
				biome = fromNumber(Biomes, math.random(1, countTable(Biomes)))
			until biome ~= v
			if findIndex(biome, "Max") then v.Min = biome.Max end
			v.Max = 0
			for i2, v2 in pairs(Biomes) do
				if not v2["Min"] then continue end
				if v2.Min > v.Min then v.Max = v2.Min end
			end
			if v.Max == 0 then v.Max = math.random(v.Min * 1000, 600) / 1000 end
		end
		if not v.Weight then
			v.Weight = math.random(1, countTable(Biomes))
		end
	end
	local function randomize(num)--randomize color
		num *= (math.random(97, 103) / 100)
		num = math.clamp(num, 0, 1)
		return num
	end
	local function rBiome()--random biome
		local rand = math.random(1, countTable(Biomes))
		local i2 = 0
		for i, v in pairs(Biomes) do
			i2 += 1
			if i2 == rand then
				return i
			end
		end
	end
	--Painting
	for i, Triangle in pairs(Planet:GetChildren()) do
		local Noise = (Triangle.Position - GetCentre()).Magnitude / (1000 * (Pars.Gen.Radius / 500));
		local material, weight, color = nil, 0, Color3.new(0, 0, 0)
		for i2, v in pairs(Biomes) do
			if Noise*1000 > v.Min*1000 and Noise*1000 < v.Max*1000 then
				if v.Weight > weight then
					--P. s. random weight, min and max here is smth, so fill them in your script manually
					material = v.Material :: Enum.Material
					weight = v.Weight
					color = v.Color
				end
			end
		end
		if not material then--a random biome. If your don't fill the min and max then random can't even assign it properly so we result in a random biome
			local biome = rBiome()
			color = Biomes[biome].Color
			material = Biomes[biome].Material
		end
		Triangle.Color = Color3.new(randomize(color.R),randomize(color.G),randomize(color.B))
		Triangle.Material = material
		Triangle.Name = material.Name;
		if i % (LoadingSpeed * 2) == 0 then task.wait()
			if Pars.PrintStatus then print("Painting: "..i.."/"..#Planet:GetChildren()) end
		end
	end;
	--creating the core
	local core = Instance.new("Part")
	SetProperties(core, {
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.CrackedLava,
		Anchored = Pars.Gen.IsAnchored,
		Name = "Core",
		Position = GetCentre(),
		Parent = Planet,
		Color = Color3.fromRGB(255, 0, 0)
	})
	local coreMesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
	SetProperties(coreMesh, {
		Scale = Vector3.new(1, 1, 1) * (Pars.Gen.Radius * 0.75);
		Parent = core;
	});
	Planet.PrimaryPart = core
	--creating the sea
	if Pars.Sea.Radius > 0 then
		local Water = Instance.new("Part");
		SetProperties(Water, {
			Color = Pars.Sea.Color;
			Material = Pars.Sea.Material;
			Size = Vector3.new(1, 1, 1);
			Position = GetCentre();
			Name = "Sea";
			CastShadow = false;
			Transparency = Pars.Sea.Transparency;
			CanCollide = false;
			Anchored = false;
			Parent = Planet;
		});
		local Mesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
		SetProperties(Mesh, {
			Scale = Vector3.new(1, 1, 1) * Pars.Sea.Radius * 2;
			Parent = Water;
		});
		local Weld = Instance.new("WeldConstraint")
		SetProperties(Weld, {
			Part0 = Planet.PrimaryPart;
			Part1 = Water;
			Parent = Planet.PrimaryPart;
			Name = "SeaWeld"
		});
	end
	--welding (now "silent". My fps won't drop again just because of this)
	if Pars.Gen.Weld then
		local i = 0
		if Pars.PrintStatus then print("Started welding") end
		local function repeatWeld()
			for i, Part in pairs(Planet:GetChildren()) do
				if not Part:IsA("WedgePart") or Part:FindFirstChildOfClass("WeldConstraint") then continue end
				local Weld = Instance.new("WeldConstraint");
				Part.Anchored = false;
				SetProperties(Weld, {
					Part0 = Planet.PrimaryPart;
					Part1 = Part;
					Parent = Planet.PrimaryPart;
				});
				task.wait()
			end
		end
		for i=1,Pars.Gen.Coroutines do--Coroutines do the work!
			coroutine.wrap(repeatWeld)()
		end
		local maxweld = 0
		for i, v in pairs(Planet:GetChildren()) do
			if v:IsA("WedgePart") then maxweld += 1 end
		end
		repeat
			task.wait(0.5)
			local welded = 0
			for i, v in pairs(Planet.PrimaryPart:GetChildren()) do
				if v:IsA("WeldConstraint") then welded += 1 end
			end
			if Pars.PrintStatus then print("Welded: "..welded.."/"..maxweld) end
		until welded >= maxweld
		if Pars.PrintStatus then print("Completed welding") end
	end
	Planet:PivotTo(CFrame.new(Pars.Gen.Position))
	--And done!
end;

function Awake(Planet,Pars,LoadingSpeed,Biomes)
	--Importing variables from Parameters
	
	local res, rad = Pars.Gen.Resolution, Pars.Gen.Radius
	local nstab = Pars.Noise
	local mountmod, ndiv, ampl, octs, pers = nstab.MountainsMod, nstab.NoiseDivider, nstab.Amplitude, nstab.Octaves, nstab.Persistence
	local mountfrom = nstab.MountainsFrom
	local issmooth = Pars.Gen.IsSmoothSubdivide
	
	local Triangles = {};
	
	--From Kris: No clue how this works
	for Index, Tris in pairs(TriSet) do
		local Corners = {1};

		for Index, VerticeNumber in pairs(Tris) do
			local Vertice = Vertices[VerticeNumber +1];

			Corners[Index] = Vertice * rad;
		end;

		table.insert(Triangles, Corners);
	end;
	
	--From Kris: No clue how this works but I needed it for another module anyway
	local GetLatitudeAndLongitude = function(Center, Point)
		local dir = (Point-Center).Unit;
		local up = Vector3.new(0,1,0);
		local right = Vector3.new(1,0,0);

		local longitude = math.deg(math.acos(up:Dot(dir)));
		local latitude = math.deg(math.atan2(dir.Z,dir.X));

		return Vector2.new(latitude,longitude);
	end;

	local Centre = GetCentre();
	local Subdivide =  function(Amount, IsSmooth) --| IsSmooth pushes all points to an equal radius around the core
		--From Kris: No clue how this works
		for i = 1, Amount do
			local Corners = {};
			local NewTriangles = {};
			for Index, Tris in pairs(Triangles) do
				for Index, Vertice in pairs(Tris) do
					Corners[Index] = Vertice;
				end;

				--| Replace triangle by 4 triangles
				local A = GetMedian(Corners[1], Corners[2]);
				local B = GetMedian(Corners[2], Corners[3]);
				local C = GetMedian(Corners[3], Corners[1]);

				if (IsSmooth) then 
					A = (A - Centre).Unit * (rad); 
					B = (B - Centre).Unit * (rad); 
					C = (C - Centre).Unit * (rad);
				end;

				table.insert(NewTriangles, {Corners[1]; A, C;});
				table.insert(NewTriangles, {Corners[2]; B, A;});
				table.insert(NewTriangles, {Corners[3]; C, B;});
				table.insert(NewTriangles, {A; B; C;});
			end;

			Triangles = NewTriangles;
			
			task.wait()
			if Pars.PrintStatus then print("Subdivide: "..i) end
		end;
	end;
	Subdivide(res, issmooth);
	
	--Applying noise
	
	for Index, Tris in pairs(Triangles) do
		for Index, Vertice in pairs(Tris) do
			local LatitudeAndLongitude = GetLatitudeAndLongitude(GetCentre(), Vertice) / ndiv;
			local ns = ThreeDNoise.new({LatitudeAndLongitude.X; LatitudeAndLongitude.Y;Pars.Noise.Seed}, ampl, octs, pers);
			local Dir = (Vertice - GetCentre());
			if ((Vertice - GetCentre()).Magnitude / (10000 * (Pars.Gen.Radius / 5000)) >= 0.5) then
				--P. s. I use "10000 * (rad / constrad)" because @Fenix's script was made with a set radius
				Vertice += Vector3.new(0, Vertice.Y * 0.10 * mountmod, 0);
			end;
			if ns > mountfrom then ns *= mountmod end
			Tris[Index] = Vertice + (Dir * (ns * 0.10));
		end;
		if Index % LoadingSpeed == 0 then task.wait()
			if Pars.PrintStatus then print("Generating: "..Index.."/"..#Triangles) end
		end
	end;
	
	-- Drawing triangles (no clue how this works too lol)
	
	for i, Triangle in pairs(Triangles) do
		Draw3DTriangle(Triangle[1], Triangle[2], Triangle[3], Planet);
		if i % (math.round(1000 * (20480/#Triangles))) == 0 then task.wait()
			if Pars.PrintStatus then print("Pasting: "..i.."/"..#Triangles) end
		end
	end;
	
	GenerationDone(Planet,Biomes,LoadingSpeed,Pars);
end;

function module.GenerateSpaceObject(Name:string,Pars:{},Biomes:{},LoadingSpeed:number,Parent:Instance)
	local obj = Instance.new("Model")
	obj.Name = Name
	obj.Parent = Parent
	Awake(obj,Pars,LoadingSpeed,Biomes)
end

return module
