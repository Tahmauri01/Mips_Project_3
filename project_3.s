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
    