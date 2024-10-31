local replicatedStorage = (game:GetService("ReplicatedStorage"));
local debris = (game:GetService("Debris"));

function ReplicateShot(muzzleEmitter)
	muzzleEmitter:Emit(150)
end;

replicatedStorage.FpsRemoteEvents.ReplicateShot.OnClientEvent:Connect(ReplicateShot)

function ReplicateSound(instanceOrigin, soundId, requestedVolume)
	local sound = Instance.new("Sound")
	sound.Parent = instanceOrigin
	sound.SoundId = soundId
	sound.Volume = requestedVolume
	sound.RollOffMinDistance = 80
	sound:Play()
	debris:AddItem(sound, 5)
end;

replicatedStorage.FpsRemoteEvents.ReplicateSounds.OnClientEvent:Connect(ReplicateSound)