.data
SpaceInput: .space 1002 #takes up to 1000 characters and the newline and null term
null_msg: .asciiz "NULL" #message for null input
semicolon: .asciiz ";" #semicolon for separation
.align 2
strint: .space #array for integer result

.text
.globl main

main:
    li $t0, 30 #hard coded N, loaded into $t0
    li $t1, 10 #loads 10 into $t1
    sub $t2, $t0, $t1 #Calculates M

    li $v0, 8 #reads user input
    la $a0, SpaceInput #input characters
    li $a1, 1002 #loads characters
    syscall #calls command

    la $t3, SpaceInput #strips the newline

strip_nl:
    lb $t0, 0($t3) #loads first byte of input
    beqz $t0, done_strip #checks if it is equal tp the finished strip
    li $t4, 0x0A #loads into $t4
    beq $t0, $t4, do_null #if equal do_null
    addi $t3, $t3, 1 #adds 1 to keep loop going
    j strip_nl #jumps to strip_nl to loop

do_null:
    sb $zero, 0($t3) #stores first byte of $t3

done_strip:
    la $a0, SpaceInput #loads the intput 
    la $a1, strint #loads adress of strint
    jal process_string #returns substring count

    move $t0, $v0 #counts, moves value of $t0
    li $t1, 0 #loads 0 into $t1
    la $t5, strint

print_loop:
    beq $t1, $t0, exit_main #if equal, exit loop

    lw $t6, 0($t5) #loads first byte of the input
    li $t7, 0x7FFFFFFF #loads 0x7FFFFFFF into $t7
    beq $t6, $t7, print_null #if byte and 0x7FFFFFFF are equal, prints null

    li $v0, 1 #number for printing an integer
    move $a0, $t6 #stores value of $a0 into $t6
    syscall #calls print command

    j do_semicolon #jumps to do_semicolon function

print_null:
    li $v0, 4 #number for printing a byte
    la $a0, null_msg #loads null message
    syscall #calls function to print

skip_sem:
    addi $t5, $t5, 4 #adds 4 to $t5 to skip this segment
    j print_loop #jumps to print loop function

exit_main:
    li $v0, 10 #number to exit
    syscall #calls function to exit

process_string:
    addi $sp, $sp, -16 #subtracts 16 from sp
    sw $ra, 0($sp) #stores first byte of sp into ra
    sw $t8, 4($sp) #stores second byte
    sw $t9, 8($sp) #stores third byte
    sw $s0, 12($sp) #stores fourth byte

    move $t8, $a1 # saves value of $t8
    move $t9, $a0 # saves value of $t9
    li $s0, 0 # loads 0 into $s0 for count

ps_loop:
    lb $t0, 0($t9) #loads first byte of $t9 into $t0
    beqz $t0, ps_done #if equal, goes to ps_done

    addi $sp, $sp, -4 #pushes adress back 4 bits
    sw $t9, 0($sp)

    jal get_substring_value #jumps to get_substring_value function

    lw $t1, 0($sp) #Gets value for t1
    addi $sp, $sp, 4 #pushes address up 4 bits

    sw $t1, 0($t8) #stores $t1
    addi $t8, $t8, 4 #pushes by 4 bits
    addi $s0, $s0, 1 #pushes by 1 bit
    addi $t9, $t9, 10 #pushes by 10 bits
    j ps_loop #jumps to ps_loop function

ps_done:
    move $v0, $s0 #returns the count

    lw $ra, 0($sp) #restores ra, t8, t9, and s0
    lw $t8, 4($sp)
    lw $t9, 8($sp)
    lw $s0, 12($sp)

    addi $sp, $sp, 16
    jr $ra

get_substring_value:
    lw $a0, 0($sp) #puts first byte into $a0
    addi $sp, $sp, 4 #pushes by 4 bits

    addi $sp, $sp, -12 #goes back 12 bits
    sw $t9, 8($sp) #saves values of t9, s0, s1
    sw $s0, 4($sp) 
    sw $s1, 0($sp)

    li $s2, 0 #charater index
    li $t9, 0 #G
    li $s0, 0 #H
    li $s1, 0 # valid digit count

gsv_loop:
    bge $s2, 10, gsv_done #finishes loop if index reaches 10
    lb $s3, 0($a0) #loads first byte of a0 to print
    beqz $s3, gsv_pad #goes to gsv_pad if s3 equal
    j gsv_check #jumps to gsv_check function

gsv_pad:
    li $s3, 32 #loads space

gsv_check:
    li $t3, 48 #loads 48 for '0'
    li $t4, 57 #loads 57 for '9'
    blt $s3, $t3, gsv_low #if less than, go to gsv_low
    bgt $s3, $t4, gsv_low #if greater than, go to gsv_low
    sub $s4, $s3, $t3 #subtracks the characters
    j gsv_valid #jumps to gsv_valid function

gsv_low:
    li $t3, 97 #loads 97 for 'a'
    blt $s3, $t3, gsv_up #if less than, goes to gsv_up
    add $t4, $t3, $t2 #a + M
    bge $s3, $t4, gsv_up #if greater than, goes to gsv_up
    sub $s4, $s3, $t3 # 'a' + M - 1
    addi $s4, $s4, 10
    j gsv_valid #jumps to gsv_valid function

gsv_up:
    li $t3, 65 #loads 65 for 'A'
    blt $s3, $t3, gsv_next #if less than, goes to hsv next
    add $t4, $t3, $t2 # 'A' + M - 1
    bge $s3, $t4, gsv_next #if greater than, goes to gsv_next
    sub $s4, $s3, $t3
    addi $s4, $s4, 10

gsv_valid:
    addi $s1, $s1, 1 #increases digit count by 1
    li $t3, 5 #loads 5 into t3
    blt $s2, $t3, gsv_addG #if less than, goes to G
    add $s0, $s0, $s4
    j gsv_next #jumps to gsv next

gsv_addG:
    add $t9, $t9, $s4 #adds G

gsv_next:
    addi $s2, $s2, 1 # goes to the next character index
    addi $a0, $a0, 1 
    j gsv_loop #jumps to gsv_loop function

gsv_done:
    beqz $s1, gsv_null #goes to null if equal
    sub $t0, $t9, $s0
    j gsv_store #jumps to gsv_store function

gsv_null:
    li $t0, 0x7FFFFFFF #loads null value

gsv_store:
    lw $t9, 8($sp) #restores t9, s0, and s1 values
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12

    addi $sp, $sp, -4 #return
    sw $t0, 0($sp)
    jr $ra