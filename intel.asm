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
msg_entrada	db		'Pedro Vereza - Cartao 242250', 10, 13, 0
msg_menu	db		'>> Caracteres de comandos', 10, 13, 9, '[a] solicita novo arquivo de dados', 10, 13, 9, '[g] apresenta o relatorio geral', 10, 13, 9, '[e] apresenta relatorio de um engenheiro', 10, 13, 9, '[f] encerra o programa', 10, 13, 9,'[?] lista os comandos validos', 10, 13, 0
msg_cmd	db		'Commando> ', 0
msg_arq	db		'>> Forneca o nome arquivo de dados:', 10, 13, 0

nro_cidades	dw		0
nro_eng	dw		0
end_cidades	dw		0
end_engs	dw		0
index_dados	dw		0
dados		db		0

	.code
	.startup
	
	lea	bx,	msg_entrada
	call	printf_s

	call	readFile

	lea	bx,	msg_menu
	call	printf_s

	.exit

;-----------------------------------------------------------------------
;Funcao	Le do arquivo as estruturas do sistema e guarda na memoria	
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
		push	cx
		call	readNumber
		pop	cx
		mov	[si], ax
		add	si, 2
	LOOP visitas
	
	pop	cx

LOOP engenheiros

	call fclose
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
	call getChar

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
	lea	bx, String
	call	atoi
	pop	bx
	ret

eol:
	call	getChar	;Char 10
	jmp	fim

readNumber endp

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
;Fun��o Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------
