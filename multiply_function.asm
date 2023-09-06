
#How this program works:
#we input 2 integers from user, n1 and n2,  in the "Run I/O"  window.
#then we print the result n1*n2 

#n1*n2 is done by the multiply function
#multiply function itself calls another function sum

#NOTE: This code ONLY works if n2>=0!
#If you input n2<0, you will always get 0 output!

#You can tinker with this script to better understand the ins and outs of RISCV assembly
#But do so ONLY after having fully understood how this code works!!!


.macro exit #macro to exit program
		li a7, 10
		ecall
		.end_macro	

.macro print_str(%string1) #macro to print any string
	li a7,4 
	la a0, %string1
	ecall
	.end_macro
	
.macro print_int (%x)  #macro to print any integer or register
	li a7, 1
	add a0, zero, %x
	#zero here refers to register #0
	#the zero register always has constant value of 0
	ecall
	.end_macro
	
.macro read_int #macro to input integer in a0
	li a7, 5
	ecall 
	.end_macro 

#later on, when we use functions in code, be VERY careful when creating macros!
#Macros might unintentionally change register values that can cause runtime errors
#as your code becomes dense, it becomes difficult to track the changing register values

.data 				
#we are now in the data section of memory.

	prompt1: .asciz  "Enter first number n1 :"
	prompt2: .asciz  "Enter second number n2 :"
	outputMsg: .asciz  " (n1) multiplied with "
	outputMsg2: .asciz  " (n2) gives the result "
	newline: .asciz  "\n"  #this prints a newline
	#In case you might want to print one
	#we dont use it in this program

#-------End of .data section!---------

.text 				
#we are now in the section devoted to storing the actual lines of code in our program.


main: # Label to define the main program.

	#print prompt1 string on console
	print_str(prompt1)
	read_int
	#set t0->n1
	addi t0, a0, 0
	
	#print prompt2 string on console
	print_str(prompt2)
	read_int
	#set t1->n2
	addi t1, a0, 0

#t1*t2 will occur in the multiply(n1,n2) function
#this function accepts arguments n1,n2 in a0,a1 registers
#it returns n1*n2 in a0 
#This is the ONLY info main knows about multiply(n1,n2) function!

#Let's load up a0,a1 with correct t0,t1 respectively!
	addi a0, t0, 0
	addi a1, t1, 0

#preserve t0,t1 to stack
	addi sp, sp, -16
	sd t0, 0(sp)
	sd t1, 8(sp)

#Now are ready to call multiply function!
	jal multiply
	

#We have no idea if sum manipulated t0,t1 values or not
#Ofcourse, here you can peek at sum function to verify this
#But in a program with say, a million functions, it is diffucult to keep track!
#So we stick to the RISCV function convention 
#We assume the worst and reload t0,t1 with the preserved values
	
	ld t0, 0(sp)
	ld t1, 8(sp)
#reset stack pointer to original level
	addi sp, sp, 16
	
	
#now we need to display the sentence:
#" n1 added to n2  gives the result (n1+n2)"
#so let's get to it!
	
#before we use the macros, remember they will modify a0 quite a lot!
#so we need to transfer current a0 value someplace else!
	addi t2, a0, 0
	
#let's print the result
print_int(t0)#n1
print_str(outputMsg)
print_int(t1)#n2
print_str(outputMsg2)
print_int(t2)#n1*n2

exit

multiply: #ennter multiply function

#accepts a0 and a1 as arguments for n1,m2
#retrurns n1*n2 in a0

#multiply in our example is callee to main but is itself caller to sum funciton
#using sum function herely is purely for demonstrational purposes only
#in reality , we would not need to call a funciton just to add 2 numbers!

#in this function, we are not using any s registers.
#so we are not concerned with preserving them to stack before we change modify them
#however, we need to preserve ra
	addi sp, sp, -8
	sd ra, 0(sp)

#trasnsfer a0,a1 to t0,t1
	addi t0,a0,0
	addi t1,a1,0

	#counter i=0
	addi t3,zero,0
	#result =0
	addi t4,zero, 0
	
loop:	beq t3,t1, loop_exit #exit loop when i=n2
	
#let's call function sum to compute: t4+t0

	#preserve t0,t1,t2,t3,t4 to stack as caller funciton
	addi sp, sp, -40
	sd t0, 0(sp)
	sd t1, 8(sp)
	sd t2, 16(sp)
	sd t3, 24(sp)
	sd t4, 32(sp)
	
	#place arguments in a0,a1
	addi a0, t4, 0
	addi a1, t0, 0
	
	jal sum
	#a0 returns with n1+n2
	
	#restore stack values as caller 
	ld t0, 0(sp)
	ld t1, 8(sp)
	ld t2, 16(sp)
	ld t3, 24(sp)
	ld t4, 32(sp)
	addi sp, sp, 40
	
	#acumulate a0 in  t4
	addi t4, a0, 0
	
loop_update:
	addi, t3,t3,1
	b loop
	
loop_exit:
	#restore ra fo the convenience of multiply's caller
	ld ra, 0(sp)
	addi sp, sp, 8

#done with multiply function!
	ret


sum: #exact same function from add_function.asm
#function accepts arguments in a0,a1
#function computes a0+a1
#function returns result in a0

#in this function, we are not using any s registers.
#so we are not concerned with preserving them to stack before we change modify them

#also sum is a LEAF function;i.e. it does not itself call any other function
#so no need to preserve the return address (ra) as well

	add a0 , a0, a1
#now let's return to which ever function called us!
	ret
#-------End of .text section!---------



