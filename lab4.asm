#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display on Bitmap: 0x10008000 (gp)
# - Base Address for retrieving word from keyboard: 0xffff0004
#
.data
# DO NOT CHANGE ANY LINE OF CODE WITHIN THIS .data SECTION!
	redColor: .word 0x00ff0000
	displayBaseAddress:	.word	0x10008000
	#note these are all ascii values below(in decimal)
	keyboard_w: .word 119
	keyboard_a: .word 97
	keyboard_s: .word 115
	keyboard_d: .word 100
	keyboard_z: .word 122
	keyboard_q: .word 113
	keyboard_e: .word 101	
	keyboard_c: .word 99
	keyboard_x: .word 120
	
	keyboardBaseAddress:	.word	0xffff0004
	readX:	.asciz "Enter starting X coordinate in the range 0 - 31: "
	readY:	.asciz "Enter starting Y coordinate in the range 0 - 31: "
	useKeyboard: .asciz "Now go to the Keyboard and Display MMIO simulator. Use the wasd (lower case) keys on your keyboard to naviagte your pixel on BITMAP display, Press x(lower case) to exit program"

.macro getCoordinates(%readXY)
# DO NOT CHANGE ANY LINE OF CODE WITHIN THIS MACRO!
	# ask user to enter X/Y by printing string %readXY
	li a7, 4
	la a0, %readXY
	ecall
	# read X/Y value and return it.
	li a7, 5
	ecall
	# a0 now has int value x or y
.end_macro

.macro print_str(%str)
# DO NOT CHANGE ANY LINE OF CODE WITHIN THIS MACRO!
	#ask user to read X/Y and read it
	li a7, 4
	la a0, %str
	ecall
.end_macro

.text
# DO NOT CHANGE ANY LINE OF CODE WITHIN THIS .data SECTION!
.globl moveleft movedown moveright moveup moveDiagonalLeftUp moveDiagonalLeftDown  moveDiagonalRightUp moveDiagonalRightDown
j main
# main is the first to be called

# This is where we stitch in your lab4_part1.asm document!
.include "lab4_part1.asm"
# this include defines function: xyCoordinatesToAddress

getkey: # doesn't accept arguments, requests a new key. 
	# set MMIO 0xffff0000 location to 0
	li t0, 0xffff0000
	sw zero, 0(t0)
	ret

polling: # doesn't accept arguments. only returns keystroke character data in a0
	# leaf function.
	li	t0, 0xffff0000
waitloop:
	lw	t1,0(t0)	 # control
	andi	t1,t1,0x0001
	beq	t1,zero,waitloop # wait for data.
	lw	a0,4(t0)	 # return data in a0
	ret
		
main:
	# ask user to read X and return it in a0.
	getCoordinates(readX)
	mv s0, a0		# save X value in s0.
        #
	# ask user to read Y and return it in a0.
	getCoordinates(readY)
	mv s1, a0               # s1 = y
        #
	# save displayBaseAddress in s2
	lw s2, displayBaseAddress 

	# Note: are you surprised by this new syntax surrounding lw?
	# Don't be! Here lw is being used as a pseudo instruction.
	# It directly loads into the s2 destination register 
        # the word found at the address specified by the 
	# static data segement label: displayBaseAddress.
	#
	lw s11, redColor  # store red color (as word) in s11 throughout program. 
        #
        # pass paramdters location parameters for xyCoordinatesToAddress
	mv a0, s0        # a0 = x 
	mv a1, s1        # a1 = y
	mv a2, s2        # a2 = displayBaseAddress
	jal xyCoordinatesToAddress # call xyCoordinatesToAddress
	# returns with pixel address in a0
        #	
	sw s11, 0(a0)    # stores and display red color in pixel address.
	# bitmap will now show the red color at (x,y)
	
	#display prompt on console:
	print_str(useKeyboard)
	
        # Load keyboard values in s3-s10
	lw s3, keyboard_w
	lw s4, keyboard_a
	lw s5, keyboard_s
	lw s6, keyboard_d
	#none of wasd were hit? :( How about the diagonal keys?
	lw s7, keyboard_q
	lw s8, keyboard_z
	lw s9, keyboard_e
	lw s10, keyboard_c
	
# Now loop requesting new pixels.
movePixelThroughKeyboard:
	# get ready to do polling as to accept input from Keyboard MMIO simulator
	jal getkey
	jal polling
	# polling returns keystroke data in a0
	mv t2, a0    # t2 gets the key read.
	#
	mv a0,s0     # restore the values of x,y,base address then go into CASE statement.
        mv a1,s1
	mv a2,s2
	nop  # entering case statement to determine new x,y.
             # base on the key stroke.
	# compare t2 with keys in s3-s10 and do the right thing
	beq t2,s3, moveup	# w
	beq t2,s4, moveleft	# a
	beq t2,s5, movedown	# s
	beq t2,s6, moveright	# d
        #	
	beq t2,s7, moveDiagonalLeftUp	 # q
	beq t2,s8, moveDiagonalLeftDown	 # z
	beq t2,s9, moveDiagonalRightUp	 # e
	beq t2,s10,moveDiagonalRightDown # c
        #
	# oops! user did not enter either of w,a,s,d,q,z,e,c inputs
        # Let's test for an x to see if we exit.
	lw t3, keyboard_x
	beq t2, t3, Exit
        #	
	# Define all the labels for the case statement.
	.include "lab4_part2.asm"
	# This is where we stitch in your lab4_part2.asm document!
        # it defines the movePixelThroughKeyboard label.
        # which contains a case statement based on the keystroke.
	#
	# if none of w,a,s,d,q,z,e,c,x entered, it will end up looping
        #   here and keep to keep waiting for a valid keystroke
	j movePixelThroughKeyboard
newPosition:
        # Case statement returns to here, with:
        # returns new x,y in a0,a1
	# Save new x,y in s0,s1, but s2 has not been changed so no need to save it.
        mv s0,a0  # save x
	mv s1,a1  # save y
        mv a2,s2  # ensure that a2 has the base address.
	# change bitmap display with updated (x,y) values in a0,a1 respectively
	jal xyCoordinatesToAddress # call xyCoordinatesToAddress
	# returns with pixel address for x,y in a0
	sw s11, 0(a0)  # stores redcolor on the x,y location.
	#  pixel at that address stored in a0 will now display color red
	
	#now repeat loop for another key.
	j movePixelThroughKeyboard

Exit:
	li a7, 10 # terminate the program gracefully
	ecall
        
