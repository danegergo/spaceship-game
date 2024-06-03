extends Node3D

@onready var pulse_effect: GPUParticles3D = $PulseEffect
@onready var pulse_sound: AudioStreamPlayer3D = $PulseSound

func _ready():
	var animation_life_time = max(pulse_effect.lifetime, pulse_sound.stream.get_length())
	
	pulse_effect.emitting = true;
	pulse_sound.play()
	await get_tree().create_timer(animation_life_time).connect('timeout', func(): queue_free())
