#pickable.gd
extends StaticBody3D

@onready var itemContainer: Area3D = $itemContainer


func getWeapon(backContainer):
	itemContainer.reparent(backContainer)
	itemContainer.position = Vector3.ZERO
	itemContainer.rotation = Vector3.ZERO
	

	

	
