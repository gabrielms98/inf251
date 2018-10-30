#Dados 2 vetores A e B, positivos maiores que zero. Zero marca o final dos vetores. Calcular C[i] = a[i] - b[i];
lw $t1, 0($gp) #resultado da subtração escalar
addi $t2, $gp, 100 #indice A
addi $t3, $gp, 200 #indice B
lw $t4, 100($gp) #primeiro elemento vetor A
lw $t5, 200($gp) #primeiro elemento vetor B
loop:	beq $t4, $zero, fim
	lw $t4, 0($t2)
	lw $t5, 0($t3)
	sub $t6, $t4, $t5
	add $t1, $t1, $t6
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	jal loop
fim nop
