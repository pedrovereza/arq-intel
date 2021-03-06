;
;====================================================================
;	- Fonte base para a escrita de programa para o 8086
;	- Utiliza o modelo small
;====================================================================
;

	.model		small
	
	.stack

	.data
MAXSTRING	equ		200
String	db		MAXSTRING dup (?)	; Declarar no segmento de dados
FileBuffer	db		10 dup (?)		; Declarar no segmento de dados
sw_n		dw		0
sw_f		db		0
sw_m		dw		0

msg_entrada	db		'Pedro Vereza - Cartao 242250', 0
msg_menu	db		13, 10, '>> Caracteres de comandos', 13, 10, 9, '[a] solicita novo arquivo de dados', 13, 10, 9, '[g] apresenta o relatorio geral', 13, 10, 9, '[e] apresenta relatorio de um engenheiro', 13, 10, 9, '[f] encerra o programa', 13, 10, 9,'[?] lista os comandos validos', 0
msg_cmd	db		13, 10, 'Comando> ', 0
msg_arq	db		13, 10, '>> Forneca o nome arquivo de dados:', 13, 10, 0
msg_dados1	db		13, 10, 9, 'Arquivo de dados:',10 ,13, 9, 9, 'Numero de cidades...... ', 0
msg_dados2	db		13, 10, 9, 9, 'Numero de engenheiros.. ', 0
msg_eng	db		13, 10, '>> Forneca o numero do engenheiro:', 0
msg_eng_inv	db		13, 10, 'Numero de engenheiro invalido', 0
msg_fim	db		13, 10, 'Fim da execucao', 0
TAB		db		'        ', 0
TOTAL		db		13, 10, '     Total', 0
decimal	db		',00', 0

rel_g_geral	db		13, 10, '>> Relatorio Geral', 0
rel_g_tab	db		13, 10, 32, 32, 32, 32, 'Engenheiro', 32, 32, 'Visitas', 32, 32, 32, 32, 32, 32, 'Lucro', 32, 32, 32, 32, 32, 32, 'Prejuizo', 0

rel_e_eng	db		13, 10, 9, 'Relatorio do Engenheiro ', 0
rel_e_vis	db		13, 10, 9, 'Numero de visitas: ', 0
rel_e_tab	db		13, 10, 32, 32, 32, 32,  'Cidade', 32, 32, 32, 32, 32, 32, 32, 32, 32, 'Lucro', 32, 32, 32, 32, 32, 32, 'Prejuizo', 0
rel_align	db		13, 10, 9, 0
new_line	db		13, 10, 0
space		db		32, 0

nro_cidades	dw		0
nro_eng	dw		0
end_cidades	dw		0
end_engs	dw		0
index_dados	dw		0
dados		db		0
;cidades
;engenheiros
;visitas_por_engenheiro

	.code
	.startup

	lea	bx,	msg_entrada
	call	printf_s

	call	readFile

	call	ajuda

	call	menu	

	.exit

ajuda		proc	near
	lea	bx, msg_menu
	call	printf_s

	ret
ajuda		endp

;-----------------------------------------------------------------------
; Funcao: Menu
;do {
;        printf("comando>");
;        scanf("%s", &opcao);
;        
;        switch (opcao) {
;            case 'a':
;                readFile();
;                break;
;            case 'r':
;                resumo();
;                break;
;                
;            case 'e':
;                relatorioEngenheiro();
;                break;
;                
;            case 'g':
;                relatorioGeral();
;                break;
;                
;            case 'f':
;                encerramento();
;            default:
;                break;
;        }
;        
;        
;    } while (opcao != 'f');
;-----------------------------------------------------------------------
menu		proc	near
menu1:
	lea	bx, msg_cmd
	call	printf_s

	call	gets

	cmp	[bx], 'a' 	
	je	menu_readFile

	cmp	[bx], 'e' 	
	je	menu_eng

	cmp	[bx], 'f' 	
	je	menu_fim

	cmp	[bx], 'g' 	
	je	menu_geral

	cmp	[bx], '?' 	
	je	menu_ajuda

	jmp	menu1

menu_readFile:
	call	readFile
	jmp	menu1

menu_eng:
	call	relatorioEngenheiro
	jmp	menu1

menu_ajuda:
	call	ajuda
	jmp	menu1

menu_fim:
	lea	bx, msg_fim
	call	printf_s
	ret

menu_geral:
	call	relatorioGeral
	jmp	menu1

menu	endp

;-----------------------------------------------------------------------
; Funcao que calcula o rendimento e imprime a tabela do relatorio de engenheiro
;
; void relatorioEngenheiro() {
;     int engenheiro = 0;
;     
;     printf("Forneca o numero do engenheiro:");
;     scanf("%d", &engenheiro);
;     
;     if (engenheiro < 0 || engenheiro >= numero_engenheiros) {
;         mensagemErro();
;         getchar();
;         relatorioEngenheiro();
;         return;
;     }
;     
;     rendimentoEngenheiroWithOutput(engenheiro);
; }
; 
; void rendimentoEngenheiroWithOutput(int engenheiro) {
;     printf("\tRelatorio do engenheiro %d\n", engenheiro);
;     short rendimento = 0;
;     unsigned short eng = (memory[endEngenheiros + engenheiro]);
;     unsigned short visitas = memory[eng];
;     printf("\tNumero de visitas: %d\n", visitas);
;     printf("\tCidade\tLucro\tPrejuizo\n");
;     
;     for (short i = 1; i <= visitas; ++i) {
;         short cidade = memory[eng + i];
;         short rendimentoCidade = memory[endCidades + cidade];
;         
;         if (rendimentoCidade < 0) {
;             printf("\t\t%d\t\t\t\t%d\n", cidade, rendimentoCidade);
;         }
;         else {
;             printf("\t\t%d\t\t%d\n", cidade, rendimentoCidade);
;         }
;         rendimento +=  rendimentoCidade;
;     }
;     if (rendimento < 0) {
;         printf("\t\tTOTAL\t\t\t%d\n", rendimento);
;     }
;     else {
;         printf("\t\tTOTAL\t%d\n", rendimento);
;     }
; }
;-----------------------------------------------------------------------
relatorioEngenheiro	proc	near
relatorio_eng_1:
	lea	bx, msg_eng
	call	printf_s

	call	gets
	cmp	[bx], 0
	jne	valido

	ret

valido:
	call	atoi

	cmp	ax, nro_eng
	jge	invalido

	cmp	ax, 0
	jl	invalido
					;-------------------------------------------
	lea	bx, rel_e_eng	;Relatorio do engenheiro x
	call	printf_s

	call	printNumber
					;-------------------------------------------
	add	ax, ax

	mov	si, end_engs		
	add	si, ax		;si = inicio do array de visitas do engenheiro

	mov	si, [si]
	mov	cx, [si]
					;-------------------------------------------
	lea	bx, rel_e_vis	;Numero de visitas: y
	call	printf_s
	mov	ax, cx
	call	printNumber
					;-------------------------------------------
	lea	bx, rel_e_tab	;cabecalho da tabela
	call	printf_s

	mov	dx, 0
	mov	bp, end_cidades
cada_visita:
	cmp	cx, 0
	je	fim_cada_visita

	inc	si
	inc	si

	lea	bx, new_line
	call	printf_s

	mov	ax, [si]
	call	alinhamentoGeral
	call	printNumber		; numero da cidade

	mov	di, [si]
	add	di, [si]

	mov	ax, [bp+di]	
	call	printRendimento

	add	dx, ax	

	dec	cx
	jmp	cada_visita
fim_cada_visita:

	lea	bx, TOTAL
	call	printf_s

	mov	ax, dx	
	call printRendimento

	ret

invalido:
	lea	bx, msg_eng_inv
	call	printf_s

	jmp	relatorio_eng_1

relatorioEngenheiro	endp

;-----------------------------------------------------------------------
; Funcao que imprime o relatorio geral
;-----------------------------------------------------------------------
relatorioGeral	proc	near
	lea	bx, rel_g_geral	
	call	printf_s

	lea	bx, rel_g_tab
	call	printf_s	

	mov	ax, 0
	mov	cx, 0		;total rendimento
	mov	dx, 0		;total visitas
eng:
	cmp	ax, nro_eng
	je	fimRelGeral

	push	dx
	push	cx
	push	ax
	call	rendimentoEng
	pop	ax

	pop	cx
	add	cx, dx

	pop	dx
	add	dx, bx

	inc	ax

	jmp eng

fimRelGeral:
	lea	bx, TOTAL	
	call	printf_s
	
	mov	ax, dx

	call	alinhamentoGeral
	call	printNumber

	mov	ax, cx
	call	printRendimento

	ret
relatorioGeral	endp

;-----------------------------------------------------------------------
;Calcula o rendimento do engenheiro, sem outputs do processo
;		AX -> id do engenheiro
;		DX <- rendimento
;		BX <- visitas		
;-----------------------------------------------------------------------
rendimentoEng	proc	near
	lea	bx, new_line
	call	printf_s

	call	alinhamentoGeral

	call	printNumber

	add	ax, ax

	mov	si, end_engs		
	add	si, ax		;si = inicio do array de visitas do engenheiro

	mov	si, [si]
	mov	cx, [si]

	mov	ax, cx
	call	alinhamentoGeral
	call	printNumber

	push	cx

	mov	dx, 0
	mov	bp, end_cidades

cada_visita2:
	cmp	cx, 0
	je	fim_cada_visita2
	
	inc	si
	inc	si

	mov	di, [si]
	add	di, [si]

	mov	ax, [bp+di]	

	add	dx, ax	

	dec	cx
	jmp	cada_visita2
fim_cada_visita2:

	mov	ax, dx
	call printRendimento

	pop	bx	;visitas	

ret

rendimentoEng	endp

;-----------------------------------------------------------------------
; Funcao que determina quantos espacos em branco sao necessarios para alinhar o relatorio geral
; baseado no tamanho do numero que precisa ser escrito
;-----------------------------------------------------------------------
alinhamentoGeral	proc	near
	push	cx

	cmp	ax, 10
	jl	um_digito

	cmp	ax, 100
	jl	dois_digitos

	jmp	tres_digitos
	
um_digito:
	mov	cx, 9	
	jmp	fim_align

dois_digitos:
	mov	cx, 8	
	jmp	fim_align

tres_digitos:
	mov	cx, 7	
	jmp	fim_align	

fim_align:

espacos:
	lea	bx, space
	call	printf_s

LOOP espacos

	pop	cx
	ret

alinhamentoGeral	endp

;-----------------------------------------------------------------------
; Funcao que determina quantos espacos em branco sao necessarios para alinhar o relatorio de engenheiro
; baseado no tamanho do numero que precisa ser escrito
;-----------------------------------------------------------------------
alinhamentoRendimento	proc	near
	push	cx
	push	ax

	mov	cx, 6

	test	ax, ax
	jns	alinhamento_r

	neg	ax

alinhamento_r:
	cmp	ax, 10000
	jge	fim_align_r

	inc	cx

	cmp	ax, 1000
	jge	fim_align_r
	
	inc	cx

	cmp	ax, 100
	jge	fim_align_r
	
	inc	cx

	cmp	ax, 10
	jge	fim_align_r

	inc	cx

fim_align_r:

espacos_r:
	lea	bx, space
	call	printf_s
LOOP espacos_r

	pop	ax
	pop	cx
	ret

alinhamentoRendimento	endp

;-----------------------------------------------------------------------
; Funcao utilizada para imprimir espacos em branco ao inves do rendimento em si (utilizada pra alinhamento das tabelas)
;-----------------------------------------------------------------------
fakePrintRendimento	proc	near
	push	cx
	push	ax

	mov	cx, 8

	test	ax, ax
	jns	fakePrint

	neg	ax

fakePrint:
	cmp	ax, 10000
	jge	fim_fake

	dec	cx

	cmp	ax, 1000
	jge	fim_fake
	
	dec	cx

	cmp	ax, 100
	jge	fim_fake
	
	dec	cx

	cmp	ax, 10
	jge	fim_fake

	dec	cx

fim_fake:

espacos_fake:
	lea	bx, space
	call	printf_s
LOOP espacos_fake

	pop	ax
	pop	cx
	ret

fakePrintRendimento	endp

;-----------------------------------------------------------------------
;Funcao	Le do arquivo as estruturas do sistema e guarda na memoria	
; void readFile() {
;     printf(">>Forneca o nome do arquivo de dados:\n");
;     scanf("%s", file_name);
;     
;     fp = fopen(file_name, "r");
;     
;     parseFile();
;     fclose(fp);
; }
; 
; void parseFile() {
;     numero_engenheiros = readNumber();
;     numero_cidades = readNumber();
;     
;     int i = 0;
;     
;     for (i = 0; i < numero_cidades; ++i) {
;         memory[i] = readNumber();
;     }
;     
;     memoryIndex += i;
;     endEngenheiros = memoryIndex;
;     memoryIndex += numero_engenheiros;
;     
;     for (int j = 0; j < numero_engenheiros; ++j) {
;         memory[endEngenheiros+j] = memoryIndex;
;         
;         int visitas = readNumber();
;         memory[memoryIndex] = visitas;
;         
;         for (i = 1; i <= visitas; ++i) {
;             memory[memoryIndex+i] = readNumber();
;         }
;         memoryIndex += i;
;     }
; }
; 
;-----------------------------------------------------------------------
readFile	proc	near
	lea	bx,	msg_arq
	call	printf_s

	call gets				;Leitura do nome do arquivo	

	mov	dx, bx
	call	fopen

	call	readNumber
	mov	nro_eng, ax

	call	readNumber
	mov	nro_cidades, ax

	mov	cx, nro_cidades

	lea	si, dados
	mov	end_cidades, si

cidades:
	push	cx
	call	readNumber
	pop	cx
	mov	[si], ax
	add	si, 2	

LOOP	cidades
	mov	end_engs, si

	mov	ax, nro_eng
	add	ax, nro_eng
	add	si, ax

	mov	cx, nro_eng
engenheiros:
	mov	di, nro_eng
	sub	di, cx
	add	di, di
	push	cx

	push	bx
	mov	bx, end_engs
	mov	ax, si
	mov	[bx+di], ax
	pop	bx
	
	call	readNumber
	mov	[si], ax
	add	si, 2

	mov	cx, ax			;Numero de visitas do engenheiro

	visitas:
		cmp	cx, 0
		je	fim_visitas	
		push	cx
		call	readNumber
		pop	cx
		mov	[si], ax
		add	si, 2

		dec	cx	
		jmp	visitas
	fim_visitas:

	pop	cx

LOOP engenheiros

	call fclose
	
	lea	bx, msg_dados1
	call	printf_s

	mov	ax, nro_cidades
	call	printNumber

	lea	bx, msg_dados2
	call	printf_s
	
	mov	ax, nro_eng
	call	printNumber
	
	ret

readFile	endp

;--------------------------------------------------------------------
;Funcao	Le do arquivo até encontrnar "," ou fim da linha	
;Entra: BX -> file handle
;Sai:   AX -> Numero lido
;--------------------------------------------------------------------
readNumber	proc	near
	lea	di, String
read_1:
	call	getChar

	cmp	dl,13
	je	eol
	cmp	dl, 44	;virgula
	je	fim

	mov	[di], dl
	inc	di
	jmp	read_1
fim:
	mov	byte ptr [di], 0
	push	bx
	push	dx
	lea	bx, String
	call	atoi
	pop	dx
	pop	bx
	ret

eol:
	call	getChar	;Char 10
	jmp	fim

readNumber endp

;--------------------------------------------------------------------
; Escreve o numero em ax na coluna de lucro ou prejuizo
;--------------------------------------------------------------------
printRendimento	proc	near
	call	alinhamentoRendimento

	test	ax, ax
	jns	printRendimento1

	call	fakePrintRendimento
	call	alinhamentoRendimento

printRendimento1:
	call	printNumber	

	lea	bx, decimal
	call	printf_s

	ret

printRendimento	endp

;
;--------------------------------------------------------------------
;Função:Converte um ASCII-DECIMAL para HEXA
;Entra: (S) -> DS:BX -> Ponteiro para o string de origem
;Sai:	(A) -> AX -> Valor "Hex" resultante
;Algoritmo:
;	A = 0;
;	while (*S!='\0') {
;		A = 10 * A + (*S - '0')
;		++S;
;	}
;	return
;--------------------------------------------------------------------
atoi	proc near

		; A = 0;
		mov		ax,0
		mov		dl, [bx]
		push		dx
		cmp		dl, '-'
		jne		atoi_2

		inc		bx
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		pop	dx
		cmp	dl, '-'
		je	negativo
		ret

negativo:
		neg	ax
		ret

atoi	endp


;
;====================================================================
;	- Conjunto de fun��es para uso nos programa para o 8086
;	- S�o as seguintes fun��es:
;		- Arquivos: fopen, fcreate, fclose, getChar setChar
;		- Console: gets, printf_s
;====================================================================
;

;--------------------------------------------------------------------
;Fun��o	Abre o arquivo cujo nome est� no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Fun��o Cria o arquivo cujo nome est� no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Fun��o	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp
	
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	lea	bx,	String
	push	bx

	mov		ah,0ah						; L� uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp

;--------------------------------------------------------------------
;Funcaoo Escrever um numero na tela
;	AX -> numero
;--------------------------------------------------------------------
printNumber	proc	near
	push	ax
	push	cx
	push	dx
	push	bp

	lea	bx, String
	call	sprintf_w

	lea	bx, String
	call	printf_s	

	pop	bp
	pop	dx
	pop	cx
	pop	ax
	ret

printNumber	endp

;--------------------------------------------------------------------
;Fun��o Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	push		ax
	push		dx
print1:
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		print1
		
ps_1:
	pop		dx
	pop		ax

	ret
printf_s	endp

sprintf_w	proc	near

	test	ax, ax
	jns	positive

	neg	ax

positive:
;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instrução DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
	ret
		
sprintf_w	endp

;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
