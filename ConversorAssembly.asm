.model small
.stack 100h

.data
titulo db 13,10,'=== CONVERSOR DE BASES NUMERICAS ===',13,10,'$'

menu db 13,10,'1. Decimal -> Binario'
     db 13,10,'2. Decimal -> Hexadecimal'
     db 13,10,'3. Binario -> Decimal'
     db 13,10,'4. Hexadecimal -> Decimal'
     db 13,10,'5. Salir'
     db 13,10,'Seleccione una opcion: $'

msgIngreso db 13,10,'Ingrese numero: $'
msgError db 13,10,'Entrada invalida. Intente nuevamente.',13,10,'$'
msgRango db 13,10,'Error: el decimal debe estar entre 0 y 255.',13,10,'$'

etqBin db 13,10,'Resultado en binario: $'
etqHex db 13,10,'Resultado en hexadecimal: $'
etqDec db 13,10,'Resultado en decimal: $'

salto db 13,10,'$'

buffer db 20
       db ?
       db 20 dup(?)

opcion db ?
tipo db ?
resultadoTipo db ?

numero dw ?
resultado dw ?

.code

main PROC
    mov ax,@data ;carga la direccion del segmento de datos
    mov ds,ax ;inicializa el registro DS

MENU_INICIO:
    call MENU_PRINCIPAL  ;muestra el menu y lee la opcion del usuario

    cmp opcion,'1'  ;selecciono Decimal -> Binario?
    je OPC_DEC_BIN

    cmp opcion,'2'  ;selecciono Decimal -> Hexadecimal?
    je OPC_DEC_HEX

    cmp opcion,'3'
    je OPC_BIN_DEC

    cmp opcion,'4'
    je OPC_HEX_DEC

    cmp opcion,'5'
    je SALIR

    call MOSTRAR_ERROR
    jmp MENU_INICIO


OPC_DEC_BIN:
    mov tipo,1
    call LEER_NUMERO
    call DEC_A_BIN
    mov resultadoTipo,1
    call MOSTRAR_RESULTADO
    jmp MENU_INICIO


OPC_DEC_HEX:
    mov tipo,1
    call LEER_NUMERO
    call DEC_A_HEX
    mov resultadoTipo,2
    call MOSTRAR_RESULTADO
    jmp MENU_INICIO


OPC_BIN_DEC:
    mov tipo,2
    call LEER_NUMERO
    call BIN_A_DEC
    mov resultadoTipo,3
    call MOSTRAR_RESULTADO
    jmp MENU_INICIO


OPC_HEX_DEC:
    mov tipo,3
    call LEER_NUMERO
    call HEX_A_DEC
    mov resultadoTipo,3
    call MOSTRAR_RESULTADO
    jmp MENU_INICIO


SALIR:
    mov ah,4Ch
    int 21h

main ENDP


;----------------------------------------------------
; MENU_PRINCIPAL
; Objetivo: muestra el menu principal y lee la opcion.
; Modifica: AX, DX

MENU_PRINCIPAL PROC
    mov ah,09h
    lea dx,titulo
    int 21h

    mov ah,09h
    lea dx,menu
    int 21h

    mov ah,01h
    int 21h
    mov opcion,al

    ret
MENU_PRINCIPAL ENDP


;-------------------------------------------------
; LEER_NUMERO
; Objetivo: lee una cadena con INT 21h funcion 0Ah
; y valida segun el tipo de entrada.
; tipo = 1 decimal, 2 binario, 3 hexadecimal.
; Modifica: AX, DX

LEER_NUMERO PROC
REINTENTAR:
    mov ah,09h
    lea dx,msgIngreso
    int 21h

    mov ah,0Ah   ;funcion 0Ah:lectura de cadena
    lea dx,buffer ;direccion del buffer de entrada
    int 21h   ;leer numero desde teclado

    cmp buffer[1],0
    je ERROR_LECTURA

    cmp tipo,1
    je LLAMAR_VAL_DEC

    cmp tipo,2
    je LLAMAR_VAL_BIN

    cmp tipo,3
    je LLAMAR_VAL_HEX


LLAMAR_VAL_DEC:
    call VALIDAR_DECIMAL
    cmp al,1
    je FIN_LEER
    jmp ERROR_LECTURA


LLAMAR_VAL_BIN:
    call VALIDAR_BINARIO
    cmp al,1
    je FIN_LEER
    jmp ERROR_LECTURA


LLAMAR_VAL_HEX:
    call VALIDAR_HEXADECIMAL
    cmp al,1
    je FIN_LEER
    jmp ERROR_LECTURA


ERROR_LECTURA:
    call MOSTRAR_ERROR
    jmp REINTENTAR


FIN_LEER:
    ret
LEER_NUMERO ENDP


;-----------------------------------------------
; VALIDAR_DECIMAL
; Objetivo: valida caracteres 0-9 y rango 0-255.
; Guarda el valor numerico en variable numero.
; Retorna: AL=1 valido, AL=0 invalido.
; Modifica: AX, BX, CX, DX, SI

VALIDAR_DECIMAL PROC
    mov cl,buffer[1]
    mov ch,0
    lea si,buffer[2]
    mov bx,0

VD_LOOP:
    mov al,[si]

    cmp al,'0'
    jb VD_ERROR

    cmp al,'9'
    ja VD_ERROR

    sub al,30h  ;convierte ASCII a valor numerico
    mov ah,0

    push ax

    mov ax,bx
    mov dx,10
    mul dx    ;multiplica el acumulador por 10
    mov bx,ax

    pop ax
    add bx,ax  ;agrega el nuevo digito al numero

    cmp bx,255  ;verifica que este dentro del rango permitido
    ja VD_RANGO

    inc si
    loop VD_LOOP

    mov numero,bx
    mov al,1
    ret


VD_RANGO:
    mov ah,09h
    lea dx,msgRango
    int 21h

VD_ERROR:
    mov al,0
    ret
VALIDAR_DECIMAL ENDP


;-------------------------------------------------
; VALIDAR_BINARIO
; Objetivo: valida que la cadena tenga solo 0 y 1.
; Retorna: AL=1 valido, AL=0 invalido.
; Modifica: AX, CX, SI

VALIDAR_BINARIO PROC
    mov cl,buffer[1]
    mov ch,0
    lea si,buffer[2]

VB_LOOP:
    mov al,[si]

    cmp al,'0'
    je VB_OK

    cmp al,'1'
    je VB_OK

    mov al,0
    ret

VB_OK:
    inc si
    loop VB_LOOP

    mov al,1
    ret
VALIDAR_BINARIO ENDP


;--------------------------------------------
; VALIDAR_HEXADECIMAL
; Objetivo: valida caracteres 0-9, A-F y a-f.
; Retorna: AL=1 valido, AL=0 invalido.
; Modifica: AX, CX, SI

VALIDAR_HEXADECIMAL PROC
    mov cl,buffer[1]
    mov ch,0
    lea si,buffer[2]

VH_LOOP:
    mov al,[si]

    cmp al,'0'
    jb VH_ERROR

    cmp al,'9'
    jbe VH_OK

    cmp al,'A'
    jb VH_ERROR

    cmp al,'F'
    jbe VH_OK

    cmp al,'a'
    jb VH_ERROR

    cmp al,'f'
    jbe VH_OK

VH_ERROR:
    mov al,0
    ret

VH_OK:
    inc si
    loop VH_LOOP

    mov al,1
    ret
VALIDAR_HEXADECIMAL ENDP


;---------------------------------------------------
; DEC_A_BIN
; Objetivo: convierte decimal a binario.
; El decimal esta en numero.
; El resultado se guarda temporalmente en resultado.
; Modifica: AX, BX

DEC_A_BIN PROC
    mov ax,numero
    mov resultado,ax
    ret
DEC_A_BIN ENDP


;-----------------------------------------------------------------
; DEC_A_HEX
; Objetivo: prepara el valor decimal para mostrarlo en hexadecimal.
; El decimal esta en numero.
; El resultado se guarda en resultado.
; Modifica: AX

DEC_A_HEX PROC
    mov ax,numero
    mov resultado,ax
    ret
DEC_A_HEX ENDP


;---------------------------------------
; BIN_A_DEC
; Objetivo: convierte binario a decimal.
; Guarda el resultado en resultado.
; Modifica: AX, BX, CX, SI

BIN_A_DEC PROC
    mov cl,buffer[1]
    mov ch,0
    lea si,buffer[2]
    mov bx,0

BAD_LOOP:
    mov al,[si]
    sub al,30h

    shl bx,1 ;equivale a multiplicr el acumulador por 2

    cmp al,1
    jne BAD_SIG

    add bx,1 ;si el bit es -> se suma al resultado

BAD_SIG:
    inc si
    loop BAD_LOOP

    mov resultado,bx
    ret
BIN_A_DEC ENDP


;-------------------------------------------
; HEX_A_DEC
; Objetivo: convierte hexadecimal a decimal.
; Guarda el resultado en resultado.
; Modifica: AX, BX, CX, DX, SI

HEX_A_DEC PROC
    mov cl,buffer[1]
    mov ch,0
    lea si,buffer[2]
    mov bx,0

HAD_LOOP:
    mov al,[si]

    cmp al,'9'
    jbe HAD_NUM

    cmp al,'F'
    jbe HAD_MAYUS

    sub al,57h
    jmp HAD_VALOR

HAD_MAYUS:
    sub al,37h   ;convierte 'A'-'F' a valores 10-15
    jmp HAD_VALOR

HAD_NUM:
    sub al,30h

HAD_VALOR:
    mov ah,0
    push ax

    mov ax,bx
    mov dx,16
    mul dx      ;multiplica el resultado acumulado por 16
    mov bx,ax

    pop ax
    add bx,ax ;agrega el nuevo digito hexadecimal 

    inc si
    loop HAD_LOOP

    mov resultado,bx
    ret
HEX_A_DEC ENDP


;----------------------------------------------------
; MOSTRAR_RESULTADO
; Objetivo: imprime el resultado segun resultadoTipo.
; resultadoTipo = 1 binario, 2 hexadecimal, 3 decimal.
; Modifica: AX, BX, CX, DX

MOSTRAR_RESULTADO PROC
    cmp resultadoTipo,1
    je MR_BINARIO

    cmp resultadoTipo,2
    je MR_HEXADECIMAL

    cmp resultadoTipo,3
    je MR_DECIMAL

    ret


MR_BINARIO:
    mov ah,09h
    lea dx,etqBin
    int 21h

    mov bx,resultado
    mov cx,8

MR_BIN_LOOP:
    shl bl,1
    jc MR_PRINT_1

    mov dl,'0'
    jmp MR_PRINT_BIT

MR_PRINT_1:
    mov dl,'1'

MR_PRINT_BIT:
    mov ah,02h
    int 21h

    loop MR_BIN_LOOP

    jmp MR_FIN


MR_HEXADECIMAL:
    mov ah,09h
    lea dx,etqHex
    int 21h

    mov ax,resultado
    mov bx,16
    mov cx,0

    cmp ax,0
    jne MR_HEX_DIV

    mov dl,'0'
    mov ah,02h
    int 21h
    jmp MR_FIN


MR_HEX_DIV:
    mov dx,0
    div bx

    push dx
    inc cx

    cmp ax,0
    jne MR_HEX_DIV


MR_HEX_PRINT:
    pop dx

    cmp dl,9
    jbe MR_HEX_DIGITO

    add dl,37h
    jmp MR_HEX_IMPRIMIR

MR_HEX_DIGITO:
    add dl,30h

MR_HEX_IMPRIMIR:
    mov ah,02h
    int 21h

    loop MR_HEX_PRINT

    jmp MR_FIN


MR_DECIMAL:
    mov ah,09h
    lea dx,etqDec
    int 21h

    mov ax,resultado
    mov bx,10
    mov cx,0

    cmp ax,0
    jne MR_DEC_DIV

    mov dl,'0'
    mov ah,02h
    int 21h
    jmp MR_FIN


MR_DEC_DIV:
    mov dx,0
    div bx

    push dx
    inc cx

    cmp ax,0
    jne MR_DEC_DIV


MR_DEC_PRINT:
    pop dx
    add dl,30h

    mov ah,02h
    int 21h

    loop MR_DEC_PRINT


MR_FIN:
    mov ah,09h
    lea dx,salto
    int 21h

    ret
MOSTRAR_RESULTADO ENDP


;------------------------------------
; MOSTRAR_ERROR
; Objetivo: imprime mensaje de error.
; Modifica: AH, DX

MOSTRAR_ERROR PROC
    mov ah,09h
    lea dx,msgError
    int 21h
    ret
MOSTRAR_ERROR ENDP

end main