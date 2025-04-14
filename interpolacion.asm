section .data
    filename db 'matriz_nueva.txt', 0   
    filemode db 2        ; Modo de apertura 
    position dd 0       ;nuevo
    posipix dd 0   ;original
    lim_r dd 0 ;contador de filas
    lim_c dd 0; contador de columnas
    pixelFile db 'matriz_pixeles.txt'
    aux1 dq 0
    aux2 dq 0
    
    pixelBuffer dd 0
    
section .bss
    buffer resb 4
    newpix resb 1 
    
section .text
    global _start

_start:
  
loop_start:  

    ; Reiniciar todos los registros y variables .data
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    xor rsi, rsi
    xor rdi, rdi
    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15
    
    mov qword [aux1], 0
    mov qword [aux2], 0
    mov dword [pixelBuffer], 0
    
    call open_file 
    call generate_inter
    
    sub dword [position], 3472 
    sub dword [posipix], 384
    add dword [lim_c], 1
    
    cmp dword [lim_c], 96
    jl loop_start
    
    
 ;*****************************************cuando termina la fila*************************************
    add dword [position], 2316
    add dword [posipix], 4
    add dword [lim_r], 1
    mov dword [lim_c], 0
    
    cmp dword [lim_r], 96
    jl loop_start 
 

 ;***********************************************************************************************************************   
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
    
generate_inter:
	;Necesito escribir el primer pixel
    mov [newpix], r8 
    call write_doc
    
;****multiplicar para calcular los primeros**************
    
    ;r15 es el de 2/3
    ;r14 es eld e 1/3
    
    ;para a
    mov r15, r8
    mov r14, r9
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;para b
    mov r15, r9
    mov r14, r8
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;segundo pixel
    mov [newpix], r9 
    call write_doc


    ;siguiente linea
    add dword [position], 1140
    
    ;para f
    mov r15, r9
    mov r14, r13
    call  cal_new
    mov [aux1], r15 ; lo guardo para no calcularlo despues
    
    ;para c
    mov r15, r8
    mov r14, r10
    call  cal_new
    mov [newpix], r15 
    mov [aux2], r15 ; lo guardo para no calcularlo despues
    call write_doc
    
    ;para d
    mov r14, [aux1]
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;para e
    mov r14, [aux2]
    mov r15, [aux1]
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;escribir f
    mov rax, [aux1]
    mov [newpix], rax 
    call write_doc
    
    add dword [position], 1140
    
    ;para j
    mov r15, r13
    mov r14, r9
    call  cal_new
    mov [aux1], r15 ; lo guardo para no calcularlo despues
    
    ;para g
    mov r15, r10
    mov r14, r8
    call  cal_new
    mov [newpix], r15 
    mov [aux2], r15 ; lo guardo para no calcularlo despues
    call write_doc
    
    ;para h
    mov r14, [aux1]
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;para i
    mov r14, [aux2]
    mov r15, [aux1]
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;escribir j
    mov rax, [aux1]
    mov [newpix], rax 
    call write_doc
    
    add dword [position], 1140
    
    mov [newpix], r10 
    call write_doc
 	
   ;para k
    mov r15, r10
    mov r14, r13
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    ;para l
    mov r15, r13
    mov r14, r10
    call  cal_new
    mov [newpix], r15 
    call write_doc
    
    mov [newpix], r13
    call write_doc 
    ret
    
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
    xor rsi, rsi
    mov rsi, pixelBuffer
    mov rdx, 7
    syscall
    ret

obtain_pixel:
    ; Leer primer número 
    movzx rax, byte [pixelBuffer]  ; Obtener el primer byte
    sub rax, '0'                   ; Convertir de ASCII a valor numérico
    mov rcx, 100                   
    imul rax, rcx                         

    movzx rcx, byte [pixelBuffer+1]  ; segundo 
    sub rcx, '0'                     
    imul rcx, 10                    
    add rax, rcx                   

    movzx rcx, byte [pixelBuffer+2]  ; tercero
    sub rcx, '0'                     
    add rax, rcx                    

    ; Repetir el proceso para el segundo número
    xor rbx, rbx 
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
    
    movzx ax, byte [newpix]    ; de 8 bits a 16 bits
    
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
    
cal_new:
    imul r14, r14, 100
    imul r15, r15, 100
    ; el de dos tercios
    imul r15, r15, 2
    mov rax, r15
    xor rdx, rdx
    mov rcx, 3
    div rcx
    mov r15, rax
    
    ;el de un tercio
    mov rax, r14
    xor rdx, rdx
    mov rcx, 3
    div rcx
    mov r14, rax
    
    ;se suman para generar ahora sí el nuevo pixel
    add r15, r14
  
    mov rax, r15
    xor rdx, rdx
    mov rcx, 100
    div rcx
    mov r15, rax
    
    ret

 ; Abrir el archivo para escritura ********************************************************************
write_doc: 
    mov rax, 2                    ; syscall open
    mov rdi, filename
    mov rsi, 1                   ; O_WRONLY 
    mov edx, 0644                ; Permisos rw-r--r--
    syscall
    test rax, rax
    js error
    mov r12, rax           
      
    
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
    
    mov rax, 3                    ; sys_close
    mov rdi, r12
    syscall
    
    ;Tiene que aumentar la posicion en la que se escribe
    add dword [position], 4
    mov rsi, 0
    ret

open_file:
    
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
    add dword [posipix], 388
    call read_pixel
    call obtain_pixel
    mov r10, rax       ; Tercer valor
    mov r13, rbx       ; Cuarto valor
    
    ; Cerrar el archivo
    mov rax, 3      ; syscall close
    syscall
    ret     
    
