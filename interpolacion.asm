section .data
    filename db 'matriz_nueva.txt', 0   
    filemode db 2        ; Modo de apertura 
    position dd 0
    posipix dd 0
    pixelFile db 'matriz_pixeles.txt'
    
    
section .bss
    buffer resb 4
    sum resb 1 
    pixelBuffer resb 8

section .text
    global _start


_start:
    ; Abrir archivo de pixeles originales
    mov rax, 2
    mov rdi, pixelFile
    mov rsi, 0
    mov rdx, 0
    syscall
    mov r12, rax

    ; Leer primer pixel
    call read_pixel
    call obtain_pixel
    mov r8, rax        ; Primer valor
    mov r9, rbx        ; Segundo valor

    ; Leer segundo pixel
    add dword [posipix], 37629
    call read_pixel
    call obtain_pixel
    mov r10, rax       ; Tercer valor
    mov r13, rbx       ; Cuarto valor

    ; Cerrar el archivo original
    mov rax, 3
    mov rdi, r12
    syscall
    
    
    ; Abrir el archivo para escritura ********************************************************************
    mov rax, 2                    ; syscall open
    mov rdi, filename
    mov rsi, 1                   ; O_WRONLY 
    mov edx, 0644                ; Permisos rw-r--r--
    syscall
    test rax, rax
    js error
    mov r12, rax           
    

    ; Asignar un valor de prueba a sum
    mov byte [sum], 253      
    
    ;Puntero de la posición del archivo
    mov rax, 8
    mov rdi, r12
    mov esi, [position]
    mov rdx, 0
    syscall
    
    ; Convertir sum a ASCII
    call convert_to_ascii

    ; Escribir el número convertido en el archivo
    mov rax, 1                    ; syscall write
    mov rdi, r12
    mov rsi, buffer
    mov rdx, 3
    syscall
    
salir:   
    ; Cerrar el archivo
    mov rax, 3      ; syscall close
    syscall

    mov rax, 60      ; syscall exit
    xor rdi, rdi
    syscall
    
error:
    mov rax, 60
    mov rdi, -1
    syscall
    
read_pixel:
    ; Posicionar en el archivo
    mov rax, 8
    mov rdi, r12
    mov esi, [posipix]
    mov rdx, 0
    syscall

    ; Leer 7 bytes
    mov rax, 0
    mov rdi, r12
    mov rsi, pixelBuffer
    mov rdx, 7
    syscall
    ret

obtain_pixel:
    ; Leer primer número 
    movzx rax, byte [pixelBuffer]  ; Obtener el primer byte
    sub rax, '0'                   ; Convertir de ASCII a valor numérico
    mov rcx, 100                   
    mul rcx                         

    movzx rcx, byte [pixelBuffer+1]  ; segundo 
    sub rcx, '0'                     
    imul rcx, 10                    
    add rax, rcx                   

    movzx rcx, byte [pixelBuffer+2]  ; tercero
    sub rcx, '0'                     
    add rax, rcx                    

    ; Repetir el proceso para el segundo número
    movzx rbx, byte [pixelBuffer+4]  ; Leer el primer byte del segundo número
    sub rbx, '0'                    
    mov rcx, 100                 
    imul rbx, rcx                

    movzx rcx, byte [pixelBuffer+5]  ; segundo 
    sub rcx, '0'                     
    imul rcx, 10                     
    add rbx, rcx                    

    movzx rcx, byte [pixelBuffer+6]  ; tercero
    sub rcx, '0'                     
    add rbx, rcx                    
    ret

    
convert_to_ascii:
    
    movzx ax, byte [sum]    ; de 8 bits a 16 bits
    
    ; Primero los números de tres dígitos
    mov bl, 100             ; Dividir entre 100 para obtener las centenas
    div bl                  ; 
    
    add al, '0'             ; Centenas a ASCII
    mov [buffer], al        ; Guardar centenas en el buffer
    
    ; El resto 
    movzx ax, ah            
    mov bl, 10              
    div bl                  ; AL = decenas, AH = unidades
    
    add al, '0'             
    mov [buffer+1], al      ; Guardar decenas en el buffer
    
    add ah, '0'            
    mov [buffer+2], ah      ; Guardar unidades en el buffer
    
    ret

