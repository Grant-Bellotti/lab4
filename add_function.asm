
#How this program works:
#we input 2 integers from user, n1 and n2,  in the "Run I/O"  window.
#then we print the result n1+n2 
#the n1+n2 is calculated withion the sum function in code

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
	ecall
	.end_macro
	
.macro read_int #macro to input integer in a0
	li a7, 5
	ecall 
	.end_macro 

.macro print_int(%t0) #macro to print any integer
	li a7, 1
	addi a0, %t0,0
	ecall
	.end_macro 
.data 				

	prompt1: .asciz  "Enter first number n1 :"
	prompt2: .asciz  "Enter second number n2 :"
	outputMsg: .asciz  " (n1) added to "
	outputMsg2: .asciz  " (n2) gives the result "
	newline: .asciz  "\n"  #this prints a newline
	#In case you might want to print one
	#we dont use it in this program

#-------End of .data section!---------

.text 				
#we are now in the section devoted to storing the actual lines of code in our program.


main: 			

	print_str(prompt1)
	read_int
	#a0 now contains user input n1	
#before we might overwrite a0 , lets preserve n1 value in t0
	addi t0, a0, 0
	
	print_str(prompt2)
	read_int
	#a0 now contains user input n2	
	#put n2 value in t1 register
	addi t1, a0, 0

#the addition of t1+t0 will occur in the sum(n1,n2) function
#this function accepts arguments n1,n2 in a0,a1 registers
#it returns n1+n2 in a0 
#This is the ONLY info main knows about sum(n1,n2) function!

#Let's load up a0,a1 with correct t0,t1 respectively!
	addi a0, t0, 0
	addi a1, t1, 0
	
#Before we pass a0,a1 as arguments, ask yourself this question:
#Do we care about the values of t0,t1?
#Anser, we do! We need to print n1,n2 later in I/O console!
#As per RISCV function convention, callee function (sum) has no responsibility towards prserving t0,t1
#So we need to preserve t0,t1 to stack

#make way for 2 doublewords in stack
	addi sp, sp, -16
#send over t0,t1 values to stack for posterity
	sd t0, 0(sp)
	sd t1, 8(sp)

#Now are ready to call sum function!
	jal sum

#We have returned from sum with return value in a0

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
#output n1 value
	print_int(t0)	
# output outputMsg string
	print_str(outputMsg)
#output n2 value
	print_int(t1)	
# output outputMsg2 string
	print_str(outputMsg2)
#output n1+n2 value
	print_int(t2)

	exit	#exit from main()
	
sum:
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

#Now that you have read the code, assemble the code!
#Click Assemble (Wrench and screwdiver icon)
#If teh Run Buttom becomes green , assembly is successful
#Click on the Run button
#Voila, you have added 2 input integers through a function!



