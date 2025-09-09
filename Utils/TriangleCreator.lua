--!strict
local wedge = Instance.new("WedgePart");
wedge.Anchored = true;
wedge.TopSurface = Enum.SurfaceType.Smooth;
wedge.BottomSurface = Enum.SurfaceType.Smooth;
wedge.CanCollide = false
wedge.CanTouch = false
wedge.CanQuery = false
--wedge.Transparency = 1

function draw3dTriangle(a: Vector3, b: Vector3, c: Vector3, parent:Instance)
	local ab, ac, bc = b - a, c - a, c - b;
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc);

	if (abd > acd and abd > bcd) then
		c, a = a, c;
	elseif (acd > bcd and acd > abd) then
		a, b = b, a;
	end

	ab, ac, bc = b - a, c - a, c - b;

	local right = ac:Cross(ab).Unit;
	local up = bc:Cross(right).Unit;
	local back = bc.Unit;

	local height = math.abs(ab:Dot(up));

	local w1 = wedge:Clone();
	w1.Size = Vector3.new(1/2, height, math.abs(ab:Dot(back)));
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back);
	w1.Parent = parent;

	local w2 = wedge:Clone();
	w2.Size = Vector3.new(1/2, height, math.abs(ac:Dot(back)));
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back);
	w2.Parent = parent;
	
	return w1, w2
end;

return draw3dTriangle;