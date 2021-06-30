tool
extends Button
class_name ShipButton

var ship_id

export onready var ShipType : String setget _SetShipType, _GetShipType
export onready var ShipName : String setget _SetShipName, _GetShipName

export onready var MaxHull : float setget _SetMaxHull, _GetMaxHull
export onready var Hull : float setget _SetHull, _GetHull

export onready var MaxShields : float setget _SetMaxShields, _GetMaxShields
export onready var Shields : float setget _SetShields, _GetShields

export onready var MaxThrust : float setget _SetMaxThrust, _GetMaxThrust
export onready var Thrust : float setget _SetThrust, _GetThrust

export onready var MaxJump : float setget _SetMaxJump, _GetMaxJump
export onready var Jump : float setget _SetJump, _GetJump

func _SetShipType(_property):
	ShipType = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/ShipModel.text = _property

func _GetShipType():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/ShipModel.text

func _SetShipName(_property):
	ShipName = _property
	$MarginContainer/MainVBoxContainer/ShipName.text = _property

func _GetShipName():
	return $MarginContainer/MainVBoxContainer/ShipName.text

func _SetMaxHull(_property):
	MaxHull = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/HullBarContainer/HullBarProgress.max_value = _property

func _GetMaxHull():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/HullBarContainer/HullBarProgress.max_value

func _SetHull(_property):
	MaxHull = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/HullBarContainer/HullBarProgress.value = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/HullBarContainer/HullBarProgress.hint_tooltip = "Hull hitpoints: %s" % _property

func _GetHull():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/HullBarContainer/HullBarProgress.value

func _SetMaxShields(_property):
	MaxShields = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ShieldsBarContainer/ShieldslBarProgress.max_value = _property

func _GetMaxShields():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ShieldsBarContainer/ShieldslBarProgress.max_value

func _SetShields(_property):
	MaxHull = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ShieldsBarContainer/ShieldslBarProgress.value = _property

func _GetShields():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ShieldsBarContainer/ShieldslBarProgress.value

func _SetMaxThrust(_property):
	MaxThrust = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ThrustBarContainer/ThrustBarProgress.max_value = _property

func _GetMaxThrust():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ThrustBarContainer/ThrustBarProgress.max_value

func _SetThrust(_property):
	Thrust = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ThrustBarContainer/ThrustBarProgress.value = _property

func _GetThrust():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/ThrustBarContainer/ThrustBarProgress.value

func _SetMaxJump(_property):
	MaxJump = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/JumpBarContainer/JumpBarProgress.max_value = _property

func _GetMaxJump():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/JumpBarContainer/JumpBarProgress.max_value

func _SetJump(_property):
	Jump = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/JumpBarContainer/JumpBarProgress.value = _property
	$MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/JumpBarContainer/JumpBarProgress.hint_tooltip = "Max Jump range: %s" % _property

func _GetJump():
	return $MarginContainer/MainVBoxContainer/HBoxContainer/VBoxContainer/JumpBarContainer/JumpBarProgress.value
