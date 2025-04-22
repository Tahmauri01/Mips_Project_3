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

