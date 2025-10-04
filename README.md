Roblox SoundEngine Module
=========================

The SoundEngine Module provides a robust, centralized audio management system for Roblox games, enabling:

- Efficient playback and pooling of sounds
- Channel-based volume control
- Easy management of looping and one-shot sounds
- Automatic sound recycling

This module is designed for performance, flexibility, and clean organization of game audio.

Key Features
------------

- Singleton Audio Manager – Only one instance is ever created.
- Channel-Based Control – Group sounds by channels to adjust volume or stop all at once.
- Sound Pooling – Reuses Sound instances to reduce memory allocations and prevent lag spikes.
- Looped and One-Shot Sounds – Supports both continuous loops and individual playback.
- Automatic Cleanup – Finished sounds are automatically recycled into the pool.

API Reference
-------------

Core Methods:

- Play(soundId: string | number, channel: string, volume?: number, pitch?: number, isLoop?: boolean, adornee?: Instance): Sound
  Plays a sound on a given channel. Loops if isLoop is true, and automatically stops existing sounds on the channel if looping.

- StopChannel(channel: string)
  Stops all sounds currently playing on the specified channel.

- SetChannelVolume(channel: string, volume: number)
  Sets the volume multiplier for a specific channel. All active sounds in the channel will adjust accordingly.

- IsPlaying(channel: string, soundId: string): boolean
  Checks if a specific sound is currently playing on a channel.

- StopAll()
  Stops all sounds playing across all channels.

Internal Methods:

- _getSound(soundId: string | number, adornee?: Instance): Sound
  Retrieves a sound from the pool or creates a new one if none are available.

- _registerSoundToChannel(channel: string, sound: Sound)
  Registers a sound to a channel and handles automatic recycling when playback ends.

Example Usage
-------------

-- Playing a sound on a channel
local SoundEngine = require(path.to.SoundEngine)
SoundEngine:Play(12345678, "Music", 0.8, 1.0, true)

-- Adjusting channel volume
SoundEngine:SetChannelVolume("Music", 0.5)

-- Stop a specific channel
SoundEngine:StopChannel("Music")

-- Check if a sound is playing
if SoundEngine:IsPlaying("Music", 12345678) then
    print("Sound is playing!")
end

-- Stop all sounds
SoundEngine:StopAll()
