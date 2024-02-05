extends TileMap

var i = { blocks = [0x0F00, 0x2222, 0x00F0, 0x4444], color = 'cyan'   }
var j = { blocks = [0x44C0, 0x8E00, 0x6440, 0x0E20], color = 'blue'   }
var l = { blocks = [0x4460, 0x0E80, 0xC440, 0x2E00], color = 'orange' }
var o = { blocks = [0xCC00, 0xCC00, 0xCC00, 0xCC00], color = 'yellow' }
var s = { blocks = [0x06C0, 0x8C40, 0x6C00, 0x4620], color = 'green'  }
var t = { blocks = [0x0E40, 0x4C40, 0x4E00, 0x4640], color = 'purple' }
var z = { blocks = [0x0C60, 0x4C80, 0xC600, 0x2640], color = 'red'    }

func blocks_to_vector2i(blocks):
	var vector_arr = []
	for block in blocks:
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
