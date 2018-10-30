#Semelhante ao 1, ordenar descrescente.
lw $t1, 0($gp) #A
lw $t2, 4($gp) #B
lw $t3, 8($gp) #C
lw $t5, 12($gp)
lw $t6, 16($gp)
#testet1t2 => faz o primeiro teste de t1 com t2
#é preciso atualizar t1, t2, t3 antes de trocar
testet1t2: lw $t1, 0($gp) #A
	   lw $t2, 4($gp) #B
 	   lw $t3, 8($gp) #C
	   slt $t4, $t1, $t2 #se $t1 < $t2 grava 1; else grava 0
	   beq $t4, $zero, t1gtt2
#t1ltt2 => como t1<t2 entao troca e dps chama o teste de t2 com t3
t1ltt2:	lw $t1, 0($gp) #A
	lw $t2, 4($gp) #B
 	lw $t3, 8($gp) #C
	lw $t5, 0($gp)
	lw $t6, 4($gp)
	sw $t6, 0($gp)
	sw $t5, 4($gp)
	jal testet2t3
#testet2t3 => verifica se (t2<t3)? troca e chama o teste de t1,t2 : nao precisa trocar, apenas termina
#antes de fazer os teste é preciso atualizar t1, t2, t3
testet2t3: lw $t1, 0($gp) #A
	   lw $t2, 4($gp) #B
           lw $t3, 8($gp) #C
	   slt $t4, $t2, $t3 #se t2 < t3 grava 1
	   beq $t4, $zero, fim
	   lw $t5, 4($gp)
	   lw $t6, 8($gp)
	   sw $t6,4($gp)
	   sw $t5, 8($gp)
	   jal testet1t2
#t1gtt2 => como t1 > t2 entao nao precisa trocar, apenas chama o teste de t2 com t3
t1gtt2: jal testet2t3
fim: nop
      

