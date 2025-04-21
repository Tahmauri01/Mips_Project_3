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