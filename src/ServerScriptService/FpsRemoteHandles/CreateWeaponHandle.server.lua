local replicatedStorage = (game:GetService("ReplicatedStorage"));
function OnServerEvent(player, weapon)
	for _, possibleTool in next, player.Character:GetChildren() do
		if (possibleTool:IsA("Tool")) then
			possibleTool:Destroy()
		end;
	end;
	
	weapon = replicatedStorage.FpsItems:FindFirstChild(weapon)
	weapon = weapon:Clone()
	weapon.Parent = player.Character
	player.Character.Humanoid:EquipTool(weapon)
end;

replicatedStorage.FpsRemoteEvents.CreateWeapon.OnServerEvent:Connect(OnServerEvent)