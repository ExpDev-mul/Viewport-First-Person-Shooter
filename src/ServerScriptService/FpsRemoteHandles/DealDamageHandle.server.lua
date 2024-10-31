local replicatedStorage = (game:GetService("ReplicatedStorage"));
function OnServerEvent(player, humanoid, damage, v)
	if (v == "%!#*~!#%") then
		humanoid.Health = humanoid.Health - damage
	else
		player:Kick("Cheats detected.")
	end;
end;

replicatedStorage.FpsRemoteEvents.DealDamage.OnServerEvent:Connect(OnServerEvent)