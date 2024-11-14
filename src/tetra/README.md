# Simple Key Elements for Tetra

## game logic
- lose if a static piece is on the 1,2 rows going down
  - 3 spawn rows along with 20 rows and 10 cols for base game
- gravity for active piece
- clear rows if completely full of static pieces

## movement logic
- position: x,y at top left corner of 4x4 grid
- rotations: coded tables for each orientation on a 4x4 grid
- hold piece!
- hard drop to bottom
- soft drop increases gravity
- check if valid move on the playfield

## kicks
- check 0,0 offset for x,y first, then the kicks in order
- jlstz and i have different kick tables, o has no kicks
- 90 deg and 180 deg have different kicks for each permutation of rotation
- NOTE: MY KICK TABLES IN `minos.lua` ARE DX,-DY OFFSETS BECAUSE THEY WERE TAKEN FROM AN ONLINE WIKI WITH +Y AS UP INSTEAD OF DOWN

## custom
- ARR (Automatic Repeat Rate): how fast the lateral movement repeats
- DAS (Delayed Auto Shift): time between initial lateral movement keypress and automatic repeated movements
- DCD (DAS Cut Delay): delay after rotations/hard drops until DAS cuts back in
- SDF (Soft Drop Factor): multiplier against gravity for increasing soft drop speed