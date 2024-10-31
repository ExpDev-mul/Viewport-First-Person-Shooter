local humanoid = (script.Parent:WaitForChild("Humanoid"));
function HealthChanged()
	if (humanoid.Health <= 0) then
		humanoid.Health = 100
	end;
end;

humanoid:GetPropertyChangedSignal("Health"):Connect(HealthChanged)