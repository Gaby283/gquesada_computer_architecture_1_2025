section .data
    filename db 'resultx86.txt', 0    ; Nombre del archivo
    filemode db 2                    ; Modo de apertura (lectura y escritura)
    newline db 10                     ; Salto de línea
    position dd 100                   ; Posición en la que modificar el número
    old_length db 2                    ; Longitud del número original
    new_value db '15,', 0             ; Nuevo valor con formato CSV
    new_length db 3                    ; Longitud del nuevo número

section .bss
    filedesc resb 4                   ; Descriptor de archivo
    buffer resb 1024                   ; Buffer de lectura y escritura

section .text
    global _start

_start:
    ; Abrir el archivo
    mov eax, 5      ; syscall open
    mov ebx, filename
    mov ecx, filemode
    int 0x80
    mov [filedesc], eax ; Guardar descriptor

    ; Leer el archivo completo en buffer
    mov eax, 3      ; syscall read
    mov ebx, [filedesc]
    mov ecx, buffer
    mov edx, 1024
    int 0x80
    mov edi, eax    ; Guardar tamaño del archivo leído

    ; Calcular desplazamiento necesario
    mov al, [new_length]
    sub al, [old_length]
    movzx ebx, al   ; Diferencia de longitud
    add edi, ebx    ; Ajustar tamaño total del buffer

    ; Mover datos para hacer espacio si es necesario
    mov esi, [position]
    add esi, [old_length] ; Posición después del número viejo
    add edi, ebx
    mov edi, esi
    add edi, ebx
    std
    rep movsb
    cld

    ; Escribir el nuevo número
    mov eax, 4      ; syscall write
    mov ebx, [filedesc]
    mov ecx, new_value
    mov edx, [new_length]
    int 0x80

    ; Escribir el resto del archivo
    mov eax, 4      ; syscall write
    mov ebx, [filedesc]
    mov ecx, buffer
    mov edx, edi    ; Nuevo tamaño del archivo
    int 0x80

    ; Cerrar el archivo
    mov eax, 6      ; syscall close
    mov ebx, [filedesc]
    int 0x80

    ; Salir
    mov eax, 1      ; syscall exit
    xor ebx, ebx
    int 0x80

