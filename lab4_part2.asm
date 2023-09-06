#in this section of code, you must direct the new position of the pixel based on the label we branched to in lab4.asm

#remember at this point, (x,y) coordinates are in a0,a1 registers respectively
#do the appropriate change in a0 a1 values based on the labels below.

#within each label, make sure to jump to the final line in this .asm file. 
#This is so that exactly one of the labels moveleft,moveright, movedown, moveup is executed depending on which key user enetered as defined in lab4.asm

#NOTE: To make sure you ONLY use a0,a1 registers in your instructions below. There is no need to involve any other rgeister in this section of code!

#HINT: make sure to jump to the correct label within lab4.asm within each of the sections: moveleft, movedown,moveright,moveup,moveDiagonalLeftUp,moveDiagonalLeftDown,
#  ,moveDiagonalRightUp and moveDiagonalRightDown
#that is, each jump instruction at teh end of each section would look like "j <lab4.asm label name>"

moveleft:
	#enter code here
	
	addi a0, a0, -1
	j newPosition
	
movedown:
	#enter code here
	
	addi a1, a1, 1
	j newPosition
	
moveright:
	#enter code here
	
	addi a0, a0, 1
	j newPosition
	
moveup:
	#enter code here
	
	addi a1, a1, -1
	j newPosition
	
moveDiagonalLeftUp:
	#enter code here
	
	addi a0, a0, -1
	addi a1, a1, -1
	j newPosition
	
moveDiagonalLeftDown:
	#enter code here
		
	addi a0, a0, -1
	addi a1, a1, 1
	j newPosition	
 	
moveDiagonalRightUp:
	#enter code here
	
	addi a0, a0, 1
	addi a1, a1, -1
	j newPosition
	
moveDiagonalRightDown:
	#enter code here
	
	addi a0, a0, 1
	addi a1, a1, 1
	j newPosition
