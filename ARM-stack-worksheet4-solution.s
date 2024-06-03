	.cpu cortex-a53
	.syntax unified
	.arch	armv6
	.extern fopen
    .extern perror
    .extern fscanf
    .extern fprintf
    .extern stdout

	.section .data
	.align 2
	.global a
	.global b
a:	.word 20
b:	.hword 10

	.section .bss
	.global c
	.align 1
c:	.skip 2
	
	.section .rodata
.Lfmt1:	.string "r"
.Lfmt2:	.string "error open file"
.Lfmt3: .string "%d"

	.section .text
	.align 2
	.global main
	.type main, %function
	.equ SIZE, 4
	.equ FP_OFF, 12
	.equ ARR, FP_OFF + 4*4
	.equ F, ARR + 4
	.equ I, F + 4
	.equ PAD, I+0
	.equ OARG6, PAD + 4
	.equ OARG5, OARG6 + 4
	.equ FRMADD, OARG5 - FP_OFF

main:	#create stack frame
	push {r4, r5, fp, lr}
	add fp, sp, FP_OFF
	sub sp, sp, FRMADD

	# FILE *f = fopen(argv[1], "r");
	add r1, r1, 4//r1 is &argv[1]
	ldr r0, [r1] //r0 is argv[1]
	ldr r1, =.Lfmt1
	bl fopen
	//r0 is f. save to f
	str r0, [fp, -F]

	//if (f == NULL)
	cmp r0, 0
	bne .Lendif
	ldr r0, =.Lfmt2
	bl perror
	b .LreturnF
.Lendif:
    //start for loop

	mov r0, 0
	str r0, [fp, -I]
	cmp r0, SIZE
	bge .Lendfor
	//use r4 as a backup for &arr[i]
	add r4, fp, -ARR
.Lfor:
	ldr r0, [fp, -F]
	ldr r1, =.Lfmt3
	mov r2, r4
	bl fscanf

	//get ready to call printf
	ldr r0, =.Lfmt3
	ldr r1, [r4]
	bl printf
	add r4, r4, 4

	//i++
	ldr r0, [fp, -I]
	add r0, r0, 1
	str r0, [fp, -I]
	//check condition
	cmp r0, SIZE
	blt .Lfor
.Lendfor:

	//call a = dosth(arr[0], arr[1], arr[2], arr[3], c, b)
	ldr r0, =c
	ldrsh r0, [r0]

	str r0, [fp, -OARG5]
	ldr r0, =b
	ldrh r0, [r0]
	str r0, [fp, -OARG6]
	ldr r0, [fp, -ARR]
	ldr r1, [fp, -ARR+4]
	ldr r2, [fp, -ARR+8]
	ldr r3, [fp, -ARR+12]
	bl dosth
	ldr r1, =a
	str r0, [r1]

	//call printf("%d", a);
	mov r1, r0
	ldr r0, =.Lfmt3
	bl printf
	b .LreturnS


.LreturnF:
	mov r0, -1
	b .Ldone
.LreturnS:
	mov r0, 0
.Ldone:
	sub sp, fp, FP_OFF
	pop {r4, r5, fp, lr}
	#go back to the caller
	bx lr
.size main, (. - main)

	.section .text
	.align 2
	.global dosth
	.type dosth, %function
	.equ FP_OFF, 4
	.equ ARG5, 4
	.equ ARG6, ARG5 + 4

dosth:
	push {fp, lr}
	add fp, sp, FP_OFF

	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3
	ldr r1, [fp, ARG5]
	add r0, r0, r1
	ldr r1, [fp, ARG6]
	add r0, r0, r1
	//return
	sub sp, fp, FP_OFF
	pop {fp, lr}
	bx lr
.size dosth, (. - dosth)
.section .note.GNU-stack, "", %progbits	
.end
	
