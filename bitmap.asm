#
# Bitmap Display Configuration for RARS:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display on Bitmap: 0x10008000 (gp)
#
.data
	displayAddress:	.word	0x10008000
	#base address from which we start displaying pixels
.text
main:
	lw t0, displayAddress	# t0 stores the base address for display
	
printPattern:
	li t1, 0xff0000	# t1 stores the HTML red colour code
	li t2, 0x00ff00	# t2 stores the HTML green colour code
	li t3, 0x0000ff	# t3 stores the HTML blue colour code
	
	sw t1, 0(t0)	 # paint the first (top-left) unit red. 
	sw t2, 4(t0)	 # paint the second unit on the first row green. Why t0+4?
	sw t3, 128(t0) # paint the first unit on the second row blue. Why +128?
	sw t3, 132(t0) # paint the first unit on the second row blue. Why +128?
	sw t3, 60(t0) # paint the first unit on the second row blue. Why +128?
	sw t3, 124(t0) # paint the first unit on the second row blue. Why +128?

#Note we are using lw/sw instea dof ld/sd for pixel color values. Working with double words would have worked as well.
#except when we are storing to memory, our data content doubles in size. Representing color values as word is sufficent .
Exit:
	li a7, 10 # terminate the program gracefully
	ecall
        
