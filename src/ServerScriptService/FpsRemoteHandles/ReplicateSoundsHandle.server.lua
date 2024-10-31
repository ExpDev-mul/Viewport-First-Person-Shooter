local players = (game:GetService("Players"));
local debrisService = (game:GetService("Debris"));
local replicatedStorage = (game:GetService("ReplicatedStorage"));

function OnServerEvent(player, instanceOrigin, soundId, requestedVolume)
	for _, notPlayer in next, players:GetChildren() do
		if (notPlayer == player) then continue end;
		replicatedStorage.FpsRemoteEvents.ReplicateSounds:FireClient(notPlayer, instanceOrigin, soundId, requestedVolume)
	end;
end;

replicatedStorage.FpsRemoteEvents.ReplicateSounds.OnServerEvent:Connect(OnServerEvent)