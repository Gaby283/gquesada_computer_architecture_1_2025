section .data
    filename db 'matriz_nueva.txt', 0   
    filemode db 2                    ; Modo de apertura 
    position dd 97
    
    
    
section .bss
    buffer resb 4
    sum resb 1                    

section .text
    global _start


_start:
    ; Abrir el archivo para escritura 
    mov eax, 5                    ; syscall open
    mov ebx, filename
    mov ecx, 02                   ; O_WRONLY 
    mov edx, 0644o                ; Permisos rw-r--r--
    int 0x80
    test eax, eax
    js error
    mov edi, eax           
    

    ; Asignar un valor de prueba a sum
    mov byte [sum], 253      
    
    ;Puntero de la posición del archivo
    mov eax, 19
    mov ebx, edi
    mov ecx, [position]
    mov edx, 0
    int 0x80
    
    ; Convertir sum a ASCII
    call convert_to_ascii

    ; Escribir el número convertido en el archivo
    mov eax, 4                    ; syscall write
    mov ebx, edi
    mov ecx, buffer
    mov edx, 3                    ; Escribir 3 caracteres 
    int 0x80
    
salir:   
    ; Cerrar el archivo
    mov eax, 6      ; syscall close
    mov ebx, edi
    int 0x80

    mov eax, 1      ; syscall exit
    xor ebx, ebx
    int 0x80
    
error:
    mov eax, 1
    mov ebx, -1
    int 0x80
    
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

