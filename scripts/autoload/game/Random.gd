extends Node

var IV1 = 1415935623
var IV2 = 1919161955

#var IV1_15BIT = 0
#var IV1_7BIT = 0
#var IV1_3BIT = 0
#
#var IV2_15BIT = 0
#var IV2_7BIT = 0
#var IV2_3BIT = 0

# 31-bit Fibonacci LFSR (taps at bit 0 and bit 4)
func _lsfr_step(IV):
	var feedback = (IV ^ (IV >> 4)) & 1		# bit0 XOR bit4
	return (IV >> 1) | (feedback << 30) 	# shift right, feed into bit 30
func scramble():
	for i in 31:
		IV1 = _lsfr_step(IV1)
		IV2 = _lsfr_step(IV2)
func next_IV1(mask = 0xffffffff):
	scramble()
	return IV1 & mask
func next_IV2(mask = 0xffffffff):
	scramble()
	return IV2 & mask
