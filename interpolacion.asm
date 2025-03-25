section .data
    file_name db 'resultx86.txt', 0  ; Nombre del archivo
    newline db 10                    ; Carácter de nueva línea
    buffer db '00000000', 10, 0      ; Espacio para escribir cada número en binario con nueva línea
    fd_out dq 0                      ; Descriptor de archivo (64 bits)

section .text
    global _start

_start:
    ; Crear o abrir el archivo para escritura
    mov rax, 2           ; sys_open (en 64 bits)
    mov rdi, file_name   ; Nombre del archivo
    mov rsi, 0666o       ; Permisos rw-rw-rw-
    mov rdx, 0102o       ; Flags O_CREAT | O_WRONLY
    syscall              ; Llamada al sistema

    mov [fd_out], rax    ; Guardar el descriptor de archivo
    
    mov bl, 0b01010011  ; Semilla inicial
    mov r8, 10          ; Contador de números a generar
    
generar_numero:
    mov dl, bl

    ; Convertir dl a binario y almacenar en buffer
    mov rax, 8           ; Contador de bits
    mov rsi, buffer      ; Dirección de buffer
    
convertir_binario:
    shl dl, 1            ; Desplazar el número a la izquierda (para que el bit más significativo quede en el bit 0)
    jc bit_1             ; Si hay acarreo, el bit es 1
    mov byte [rsi], '0'  ; Si no hay acarreo, el bit es 0
    jmp siguiente_bit

bit_1:
    mov byte [rsi], '1'  ; Si hay acarreo, el bit es 1

siguiente_bit:
    inc rsi              ; Avanzar al siguiente byte en el buffer
    dec rax              ; Decrementar el contador de bits
    jnz convertir_binario

LFSR:
    ; Escribir en el archivo
    mov rax, 1           ; sys_write
    mov rdi, [fd_out]    ; Descriptor de archivo
    mov rsi, buffer      ; Dirección del buffer
    mov rdx, 9           ; Tamaño (8 bits + '\n')
    syscall              ; Llamada al sistema
    
    ; Extraer bit 6 y bit 7
    mov al, bl            ; Copiar el valor de bl en al
    and al, 0x04          ; Extraer bit 6 (0000 0100)
    shr al, 2             ; Desplazarlo a la posición 0
    mov dl, bl            ; Copiar bl en dl
    and dl, 0x02          ; Extraer bit 7 (0000 0010)
    shr dl, 1             ; Desplazarlo a la posición 0

    ; XOR de ambos bits
    xor al, dl            ; al = bit6 XOR bit7

    ; Desplazar bl a la derecha
    shr bl, 1             ; Desplazar bl un bit a la derecha

    ; Insertar el bit generado en la posición 7
    shl al, 7             ; Mover el resultado XOR a la posición 7
    or bl, al

    ; Si r8 llega a 0, salimos del ciclo
    dec r8
    test r8, r8
    jz salir
    jmp generar_numero

salir:
    mov eax, 60           ; Llamada al sistema exit
    xor edi, edi          ; Código de salida 0
    syscall               ; Terminar el programa
