.text
j __main
j __interrupt
j __exception
__main:
# reset sp
addi $sp, $zero, 0x800
# reset digits
addi $27, $zero, 1
addi $28, $zero, 0x0000
# reset timer
lui  $t8, 0x4000 # $t8: timer base addr
sw   $zero, 0x0008($t8)
lui  $t9, 0xffff # TH -50000
addi $t9, $t9, 0xb3f8
sw   $t9, 0($t8)
ori  $t9, $t9, 0xffff
sw   $t9, 0x0004($t8)
addi $t9, $zero, 3
sw   $t9, 0x0008($t8)
la   $t9, main
andi $t9, $t9, 0x07ff
jr   $t9
__interrupt:
# close timer
addi $sp, $sp, -24
sw   $1, 20($sp)
sw   $t7, 16($sp)
sw   $t8, 12($sp)
sw   $t9, 8($sp)
sw   $t0, 4($sp)
sw   $t1, 0($sp)
lui  $t8, 0x4000 # $t8: timer base addr
lw   $t9, 0x0008($t8) # TCON
andi $t9, $t9, 0xfff9
sw   $t9, 0x0008($t8)
# Interrupt Program START
# $27 - WHICH ONE IS SHOWED BEFORE
# $28 - SHOW NUMBER
srl  $t1, $28, 0
beq  $27, 1, __show
srl  $t1, $28, 4
beq  $27, 2, __show
srl  $t1, $28, 8
beq  $27, 4, __show
srl  $t1, $28, 12
beq  $27, 8, __show
__show:
andi $t1, $t1, 0x000f
addi $t0, $zero, 0x00C0
beq  $t1, 0, __digit_out
addi $t0, $zero, 0x00F9
beq  $t1, 1, __digit_out
addi $t0, $zero, 0x00A4
beq  $t1, 2, __digit_out
addi $t0, $zero, 0x00B0
beq  $t1, 3, __digit_out
addi $t0, $zero, 0x0099
beq  $t1, 4, __digit_out
addi $t0, $zero, 0x0092
beq  $t1, 5, __digit_out
addi $t0, $zero, 0x0082
beq  $t1, 6, __digit_out
addi $t0, $zero, 0x00F8
beq  $t1, 7, __digit_out
addi $t0, $zero, 0x0080
beq  $t1, 8, __digit_out
addi $t0, $zero, 0x0090
beq  $t1, 9, __digit_out
addi $t0, $zero, 0x0088
beq  $t1, 10, __digit_out
addi $t0, $zero, 0x0083
beq  $t1, 11, __digit_out
addi $t0, $zero, 0x00C6
beq  $t1, 12, __digit_out
addi $t0, $zero, 0x00A1
beq  $t1, 13, __digit_out
addi $t0, $zero, 0x0086
beq  $t1, 14, __digit_out
addi $t0, $zero, 0x008E
beq  $t1, 15, __digit_out
addi $t0, $zero, 0x00FF
__digit_out:
nor  $t1, $27, $zero
sll  $t1, $t1, 8
andi $t1, $t1, 0x0f00
add  $t1, $t0, $t1
sw   $t1, 0x10($t8)
beq  $27, 8, __reset
sll  $27, $27, 1
j    __out
__reset:
addi $27, $zero, 1
__out:
# Interrupt Program END
addi $t7, $zero, 0x0002
or   $t9, $t9, $t7
sw   $t9, 0x0008($t8)
lw   $t1, 0($sp)
lw   $t0, 4($sp)
lw   $t9, 8($sp)
lw   $t8, 12($sp)
lw   $t7, 16($sp)
lw   $1, 20($sp)
addi $sp, $sp, 24
jr   $k0
__exception:
# Exception Program START
addi $sp, $sp, -12
sw   $1, 8($sp)
sw   $t8, 4($sp)
sw   $t9, 0($sp)
lui  $t8, 0x4000
lw   $t9, 0xC($t8)
ori  $t9, $t9, 0x0080
sw   $t9, 0xC($t8)
lw   $t9, 0($sp)
lw   $t8, 4($sp)
lw   $1, 8($sp)
addi $sp, $sp, 12
# Exception Program END
addi $k0, $k0, 4
jr   $k0

main:
	lw		$a2, 0($zero)
# copy data
	li		$t2, 0	# cnt
	li		$t0, 4
	addi 		$t1, $a2, 1
	sll		$t1, $t1, 2	# new base addr 
	move 		$a0, $t1
	move		$s2, $a0
	move		$s4, $a2
in_copy:
	beq		$t2, $a2, out_copy
	sll		$t3, $t2, 2
	add		$t4, $t3, $t0
	lw		$t7, 0($t4)
	add		$t4, $t3, $t1
	sw		$t7, 0($t4)
	addi 		$t2, $t2, 1
	j 		in_copy
out_copy:
# call quicksort	
	lui		$t0, 0x4000
	lw		$s0, 0x14($t0)	# $s0 - START CLK
	li		$a1, 0
	addi		$a2, $a2, -1
	jal		quicksort
	lui		$t0, 0x4000
	lw		$s1, 0x14($t0)	# $s1 - END CLK
	sub		$28, $s1, $s0
	srl		$28, $28, 16
	jal		delay
	sub		$28, $s1, $s0
	lw		$t1, 0xC($t0)
	ori		$t1, $t1, 0x0001
	sw		$t1, 0xC($t0)
   	jal		exit  		    	
quicksort:
	addi		$sp, $sp, -20		# save s0,1,2,ra,i
	sw		$ra, 16($sp)
	sw		$s3, 12($sp)
	sw		$s2, 8($sp)
	sw		$s1, 4($sp)
	sw 		$s0, 0($sp)
    	move 		$s0, $a0		# arr
    	move    	$s1, $a1            	# left
    	move    	$s2, $a2            	# right
    	move   		$t0, $s1            	# $t0 = i = left
    	move    	$t1, $s2            	# $t1 = j = right
    	add		$t2, $s1, $s2		# $t2 = i + j
    	srl		$t2, $t2, 1 		# $t2 /= 2
    	sll		$t2, $t2, 2		# for lw
    	add		$t2, $s0, $t2 		# $t2 = arr + (i + j)/2
    	lw		$t2, ($t2)		# $t2 = mid
loop1:	bgt		$t0, $t1, exit1		# if i>j, break
loop2:	sll		$t3, $t0, 2
	add		$t4, $s0, $t3		# $t4 = arr + i
	lw		$t5, ($t4)		# $t5 = arr[i]
	bge		$t5, $t2, loop3		# if arr[i] >= mid, break 		
	addi 		$t0, $t0, 1		# i++
	j		loop2
loop3:	sll		$t3, $t1, 2
	add		$t6, $s0, $t3		# $t6 = arr + j
	lw		$t7, ($t6)		# $t7 = arr[j]
	ble		$t7, $t2, exit3		# if arr[j] <= mid, break 		
	addi  		$t1, $t1, -1		# j--
	j		loop3
exit3:  bgt		$t0, $t1, loop1		# if i > j, break
	move		$t3, $t5
	move		$t5, $t7
	move		$t7, $t3		# swap(arr[i],arr[j])
	sw		$t5, ($t4)
	sw 		$t7, ($t6)
	addi		$t0, $t0, 1		# i++
	addi 		$t1, $t1, -1		# j--
	move		$s3, $t0
exit1:  bge		$s1, $t1, skip1		# if left >= j, skip
	move		$a1, $s1
	move 		$a2, $t1
	jal		quicksort
skip1:	bge 		$s3, $s2, skip2		# if i >= right, skip
	move		$a1, $s3
	move		$a2, $s2
	jal 		quicksort
skip2:	lw 		$s0, 0($sp)		# reload s0,1,2
	lw		$s1, 4($sp)
	lw 		$s2, 8($sp)
	lw		$s3, 12($sp)
	lw		$ra, 16($sp)
	addi 		$sp, $sp, 20
	jr		$ra
	
exit:
	li		$s3, 0
show:	
	jal		delay
	sll		$t0, $s3, 2
	add		$t0, $s2, $t0
	lw		$28, 0($t0)
	#move		$28, $t0
	addi		$s3, $s3, 1
	blt		$s3, $s4, show
	
	lui 		$t0, 0x4000
	lw		$t1, 0xC($t0)
	ori		$t1, $t1, 0x2
	sw		$t1, 0xC($t0)
death_loop:
	nop
	nop
	nop
	j 		death_loop
# function delay some cycle
delay:
	lui		$t0, 0x4000
	lw		$t6, 0x14($t0)	# $t6: SYSCLK START
	li		$t1, 0x0510FF40	# 85MHz 1s
in_delay:
	lw		$t7, 0x14($t0) # $t7: SYSCLK END
	sub		$t7, $t7, $t6
	bgt 		$t7, $t1, out_delay
	j 		in_delay
out_delay:
	jr		$ra
