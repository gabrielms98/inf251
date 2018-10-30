#C = A * B = ( B + B + B .....+ B). Supor que A pode ser negativo.
lw $t3, 8($gp) #A
lw $t4, 12($gp) #B
li $t2, 0 #C
beq $t3, $zero, fim
slt $t5, $t3, $zero #se $t3 < 0 grava 1; else grava 0
beq $t5, $zero, positivo #se $t5 == 0 vai para positivo, se nao segue prox linha
negativo: sub $t2, $t2, $t4 #t2 -= t4
	  addi $t3, $t3, 1 #diminui o index, t3--
	  beq $t3, $zero, fim #se t3==0 terminamos, pula para o fim, else segue
	  jal negativo #pula para o inicio do loop "negativo"

positivo: add $t2, $t2, $t4 #t2+=t4
	  addi $t3, $t3, -1 ##diminui o index, t3--
	  beq $t3, $zero, fim #se t3==0 terminamos, pula para o fim, else segue
	  jal positivo #pula para o inicio do loop "positivo"
fim: sw $t2, 0($gp)	

