#Somatório de um Vetor, os elementos são maiores que 0. O termino é marcado com um elemento igual a 0.
lw $t1, 0($gp) #valor da soma
addi $t2, $gp, 4 #indice do primeiro elemento do vetor
lw $t3, 4($gp)
loop:	beq $t3, $zero, fim
	lw $t3, 0($t2)
	add $t1, $t1, $t3
	addi $t2, $t2, 4
	jal loop
fim: nop
