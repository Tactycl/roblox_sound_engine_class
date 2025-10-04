local SoundService = game:GetService("SoundService")

local SoundEngine = {}
SoundEngine.__index = SoundEngine

local _instance: SoundEngine? = nil

export type SoundEngine = {
	activeSounds: {[string]: {Sound}},
	channelVolumes: {[string]: number},
	soundPool: {[number]: {Sound}},
	
	_getSound: (self: SoundEngine, soundId: string | number, adornee: Instance?) -> (Sound),
	_registerSoundToChannel: (self: SoundEngine, channel: string, sound: Sound) -> (),
	
	Play: (self: SoundEngine, soundId: string | number, channel: string, volume: number?, pitch: number?, isLoop: boolean?, adornee: Instance?) -> (Sound),
	StopChannel: (self: SoundEngine, channel: string) -> (),
	SetChannelVolume: (self: SoundEngine, channel: string, volume: number) -> (),
	IsPlaying: (self: SoundEngine, channel: string, soundId: string) -> (boolean),
	StopAll: (self: SoundEngine) -> (),
}

function SoundEngine.new(): SoundEngine
	if _instance then
		return _instance
	end

	local self = (setmetatable({}, SoundEngine):: unknown):: SoundEngine

	self.activeSounds = {}
	self.channelVolumes = {}
	self.soundPool = {}
	
	_instance = self
	return self
end

function SoundEngine:_getSound(soundId: string | number, adornee: Instance?): Sound
	local assetId = "rbxassetid://" .. soundId
	local pool = self.soundPool[assetId]
	
	local sound
	if pool and #pool > 0 then
		sound = table.remove(pool)
		sound.Parent = adornee or SoundService
		
	else
		sound = Instance.new("Sound")
		sound.SoundId = assetId
		sound.Name = "Sound_" .. soundId
		sound.RollOffMode = Enum.RollOffMode.Linear
		sound.Volume = 1
		sound.Archivable = false
		sound.Parent = adornee or SoundService
	end
	
	return sound
end

function SoundEngine:_registerSoundToChannel(channel: string, sound: Sound)
	self.activeSounds[channel] = self.activeSounds[channel] or {}
	table.insert(self.activeSounds[channel], sound)

	local conn
	conn = sound.Ended:Connect(function()
		conn:Disconnect()
		
		sound:Stop()
		sound.Parent = SoundService
		
		self.soundPool[sound.SoundId] = self.soundPool[sound.SoundId] or {}
		table.insert(self.soundPool[sound.SoundId], sound)

		local sounds = self.activeSounds[channel]
		if sounds then
			for i = 1, #sounds do
				if sounds[i] == sound then
					table.remove(sounds, i)
					break
				end
			end
			if #sounds == 0 then
				self.activeSounds[channel] = nil
			end
		end
	end)
end

function SoundEngine:Play(soundId: string | number, channel: string, volume: number?, pitch: number?, isLoop: boolean?, adornee: Instance?): Sound
	if isLoop then
		self:StopChannel(channel)
	end

	local sound: Sound = self:_getSound(soundId, adornee)
	sound.Looped = isLoop or false
	sound:SetAttribute("BaseVolume", volume or 1.0)

	local channelVolume = self.channelVolumes[channel] or 1.0
	sound.Volume = (sound:GetAttribute("BaseVolume") or 1.0) * channelVolume

	if pitch then
		sound.PlaybackSpeed = pitch
	end

	sound:Play()
	self:_registerSoundToChannel(channel, sound)

	return sound
end

function SoundEngine:StopChannel(channel: string)
	local sounds = self.activeSounds[channel]
	if not sounds then return end

	for i = 1, #sounds do
		local sound = sounds[i]
		sound:Stop()
		sound:Destroy()
	end

	self.activeSounds[channel] = nil
end

function SoundEngine:SetChannelVolume(channel: string, volume: number)
	self.channelVolumes[channel] = volume
	local sounds = self.activeSounds[channel]
	if not sounds then return end

	for i = 1, #sounds do
		local sound = sounds[i]
		if sound and sound:IsDescendantOf(game) then
			local baseVolume = sound:GetAttribute("BaseVolume") or 1.0
			sound.Volume = baseVolume * volume
		end
	end
end

function SoundEngine:IsPlaying(channel: string, soundId: string): boolean
	local sounds = self.activeSounds[channel]
	if not sounds then return false end

	local targetId = "rbxassetid://" .. tostring(soundId)
	for i = 1, #sounds do
		local sound = sounds[i]
		if sound.SoundId == targetId and sound.IsPlaying then
			return true
		end
	end

	return false
end

function SoundEngine:StopAll()
	for channel, _ in self.activeSounds do
		self:StopChannel(channel)
	end
end

return SoundEngine.new()
