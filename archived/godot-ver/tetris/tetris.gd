extends TileMapLayer

# some logic code from https://codeincomplete.com/articles/javascript-tetris/
# tetris tetrominos all laid out
const piece_types: Array[String] = ["I", "J", "L", "O", "S", "T", "Z"]
const pieces = {
	"I" = [0x0F00, 0x2222, 0x00F0, 0x4444],
	"J" = [0x44C0, 0x8E00, 0x6440, 0x0E20],
	"L" = [0x4460, 0x0E80, 0xC440, 0x2E00],
	"O" = [0xCC00, 0xCC00, 0xCC00, 0xCC00],
	"S" = [0x06C0, 0x8C40, 0x6C00, 0x4620],
	"T" = [0x0E40, 0x4C40, 0x4E00, 0x4640],
	"Z" = [0x0C60, 0x4C80, 0xC600, 0x2640]
}

var board = [] # tetris board, [rows][col]
const ROW_LEN = 20
const COL_LEN = 10
enum BLOCK { EMPTY, STATIC, ACTIVE }

var piece_queue: Array[String] = []
var hold = null

func fill_piece_queue(copy_count: int = 4):
	var temp_queue = []
	# bag of default 4x of each type of piece, not random each time!
	for i in copy_count:
		for p in piece_types:
			temp_queue.append(p)
	temp_queue.shuffle()
	piece_queue.append_array(temp_queue)

# for queue data...? probably not needed
func get_block_type(piece: Array):
	pass


func init_board():
	board.resize(ROW_LEN)
	board.fill([])
	for row in board:
		row.resize(COL_LEN)
		row.fill(BLOCK.EMPTY)

# spawn "upwards" according to shine!
func spawn_piece():
	set_cell(Vector2i(10, 5), 0)
	print("what the hell")


func log_piece(piece: Array, piece_idx: int):
	var val = "";
	for idx in range(16):
		if idx % 4 == 0:
			val += "\n"
		val += str((piece[piece_idx] >> idx) & 1) + " "
	print(val)



# piece movement functions
enum DIR { LEFT, RIGHT, UP, DOWN };
var move_queue: Array[DIR] = []

func soft_drop(): # move by one
	pass
	
func hard_drop(): # move to bottom
	pass

func lateral_move(): # move side to side
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	init_board()
	fill_piece_queue()
	
	
	
	#print(queue)
	
	# testing?
	#log_piece(pieces.J, 3);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update queue with new values when queue is less than pieces size
	if piece_queue.size() <= pieces.size():
		fill_piece_queue(3)
	
	
	if Input.is_key_pressed(KEY_RIGHT):
		move_queue.append(DIR.RIGHT)
		spawn_piece()
	if Input.is_key_pressed(KEY_LEFT):
		move_queue.append(DIR.LEFT)
	if Input.is_key_pressed(KEY_UP):
		move_queue.append(DIR.UP)
	if Input.is_key_pressed(KEY_DOWN):
		move_queue.append(DIR.DOWN)
