include C:\MASM614\include\console.inc

;TODO: elem should be dd

.data

N equ 100000

a equ 48271

m equ 2147483647

solved db 1

solind dd -1 ;index of possible solution in X

elem dd ? ;random number

M db ? ;size of population

L db ? ;num of variables per individual

LM dd ? ;L*M

A db N dup(?) ;coefficients, size = L

D db ? ;sum{A_i * X_i} = D

X db N dup(?) ;population, size = M * L

vint dd N dup(?) ;A_i*X_i array for single X

V dd N dup(?) ;array of residuals for single population

arrsum dd ? ;last result of sum_array proc

V_balanced dd N dup(?) ;V_balanced_i = sum{V} / V_i * [*smth]

prefarr dd N dup (?)

child db N dup (?) ;single child

X_new db N dup(?) ;next population after current X

smth equ 10000

.code

public generate_single

generate_single proc
   
    push edx
    push ebx
    
    mov eax, elem
    mov ebx, m
    mov edx, a

    mul edx
    div ebx
    
    mov eax, edx
    
    mov elem, eax
    
    pop ebx
    pop edx
    
    ;outintln eax
    
    ret
generate_single endp

generate_array proc
    
    push esi
    push ebx
    push ecx
    push edx
    push ebp
    
    mov eax, elem
    mov ebx, m
    mov edx, a
    
    mov [ebp], al
    ;outintln [ebp]
    
    genstart:
        
        dec ecx
        ;outintln ecx
        cmp ecx, 0
        je genend
        ;outstrln 'in genstart'
        
        push edx
        
        mul edx
        div ebx
        
        inc esi
        
        mov [ebp + esi], dl
        
        mov eax, edx
        
        mov elem, eax
        
        pop edx
        
        ;outintln [ebp + esi]
        
        jmp genstart
    
    genend:
    
    ;outstrln 'genend'
    
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop ebp
    
    ret
generate_array endp

calculate_residuals proc

    push eax
    push ecx
    push edx
    push esi
    push edi

    mov ch, M
    mov esi, 0
    
    external_start:
    
        mov cl, L
        mov edi, 0
        
        mov ah, 0
        
        internal_start:
            
            mov al, A[edi]
            cbw
            cwde
            mov [ebp + 4*edi], eax
            
            ;outint [ebp + 4*edi]
            ;outchar ' '
            
            mov eax, esi
            mul L
            add eax, edi
                        
            mov al, X[eax]
            cbw
            cwde
            
            outstr 'x'
            outint edi
            outstr '='
            outint eax
            outstr '; '
            
            mov edx, [ebp + 4*edi]
            mul edx
            
            mov [ebp + 4*edi], eax
            
            ;outint eax
            ;outchar ' '
            ;outintln [ebp + 4*edi]
            
            ;outint vint[edi]
            ;outchar ' '
            
            inc edi
            dec cl
            cmp cl, 0
            jne internal_start
            jmp internal_end
        
        internal_end:
        
        ;outstrln ' '
        
        mov cl, L
        mov edi, 0
        
        xor edx, edx
        
        internal_second_start:
        
            mov eax, [ebp + 4*edi]
            ;outintln [ebp + 4*edi]
            add edx, eax
            ;outintln edx
        
            inc edi
            dec cl
            cmp cl, 0
            jne internal_second_start
            jmp internal_second_end
        
        internal_second_end:
        
        mov al, D
        cbw
        cwde
        
        cmp edx, eax
        jl sub1
        jge sub2
        
        sub1:
            
            sub eax, edx
            mov [ebx + 4*esi], eax
            jmp transfer
            
        sub2:
            
            sub edx, eax
            mov [ebx + 4*esi], edx
            
            cmp edx, 0
            je equation_solved
            jne equation_not_solved
            
            equation_solved:
            
                mov solved, 0
                mov solind, esi
                jmp transfer
                
            equation_not_solved:
            
                mov solved, 1
                jmp transfer
            
            ;jmp transfer
        
        transfer:
        
            outstr 'residual='
            outintln [ebx + 4*esi]
            
            inc esi
            dec ch
            cmp ch, 0
            jne external_start
            jmp external_end
         
    external_end:
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop eax
    
    ret
calculate_residuals endp

sum_array proc

    push eax
    push ebx
    push ecx
    push esi
    
    mov al, M
    cbw
    cwde
    mov ecx, eax
    xor eax, eax
    
    mov esi, 0
    
    lstart:
    
        mov ebx, [ebp + 4*esi]
        add eax, ebx
        ;outintln ebx
        
        inc esi
        dec ecx
        cmp ecx, 0
        jne lstart
        jmp lend
    
    lend:
    
    mov arrsum, eax
    
    pop esi
    pop ecx
    pop ebx
    pop eax
    
    ret
sum_array endp

balance_array proc

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov al, M
    cbw
    cwde
    mov ecx, eax
    xor eax, eax
    
    mov esi, 0
    
    lstart:
    
        xor edx, edx
        mov eax, arrsum
        mov edi, [ebp + 4*esi]
        
        div edi
        ;outintln eax
        mov edi, smth
        mul edi
        ;outintln eax 
        
        mov [ebx + 4*esi], eax
        
        inc esi
        dec ecx
        cmp ecx, 0
        jne lstart
        jmp lend
    
    lend:
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret
balance_array endp

prefix_sum proc

    push eax
    push ebx
    push ecx
    push esi
    push edi

    mov al, M
    cbw
    cwde
    mov ecx, eax
    xor eax, eax
    
    mov esi, 0
    
    lstart:
    
        mov edi, [ebp + 4*esi]
        ;outintln edi
        add eax, edi
        ;outintln eax
        
        mov [ebx + 4*esi], eax
    
        inc esi
        dec ecx
        cmp ecx, 0
        jne lstart
        jmp lend
    
    lend:

    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax

    ret
prefix_sum endp

select_single_ids proc

    push eax
    push ebx
    push ecx
    push edx
    push ebp
    
    lea ebp, V_balanced
    call sum_array

    call generate_single
    
    mov edx, 0
    mov ebx, arrsum
    div ebx
    mov eax, edx
    
    ;outstr 'first thrown number: '
    ;outintln eax
    
    lea ebp, prefarr
    mov cl, M
    mov esi, 0
    
    lfirst_start:
    
        mov ebx, [ebp + 4*esi]
        ;outintln ebx
        cmp ebx, eax
        jae lfirst_end
        
        inc esi
        dec cl
        cmp cl, 0
        je lfirst_end
        jmp lfirst_start
    
    lfirst_end:
    
    ;outstr 'father: '
    ;outintln esi
    
    call generate_single
    
    mov edx, 0
    mov ebx, arrsum
    div ebx
    mov eax, edx
    
    ;outstr 'second thrown number: '
    ;outintln eax
    
    lea ebp, prefarr
    mov cl, M
    mov edi, 0
    
    lsecond_start:
    
        mov ebx, [ebp + 4*edi]
        ;outintln ebx
        cmp ebx, eax
        jae lsecond_end
        
        inc edi
        dec cl
        cmp cl, 0
        je lsecond_end
        jmp lsecond_start
    
    lsecond_end:
    
    ;outstr 'mother: '
    ;outintln edi
    
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret
select_single_ids endp

new_child proc

    push eax
    push ebx
    push ecx
    push edx
    push ebp
    push esi
    push edi
    
    lea ebp, X
    
    call select_single_ids
    
    mov al, L
    cbw
    cwde
    mul esi
    mov esi, eax
    
    mov al, L
    cbw
    cwde
    mul edi
    mov edi, eax
    
    mov al, L
    cbw
    cwde
    mov ebx, eax
    xor eax, eax
    
    ;mov al, [ebp+edi]
    ;outintln al
    
    ;outintln ecx
    
    lstart_nch:
        
        xor edx, edx
        mov dh, [ebp+esi]
        mov dl, [ebp+edi]
        
        ;outstr 'father x_i: '
        ;outintln dh
        ;outstr 'mother x_i: '
        ;outintln dl
        ;outnumln dx,,b
        
        ;cannnot do that with ah and al as 2nd operand: error A2070. Why?
        
        call generate_single
        and al, 7
        
        mov cl, al
        
        shr dh, cl
        shl dh, cl
        
        shl dl, cl
        shr dl, cl
        
        ;shr dh, 4
        ;shl dh, 4
        
        ;shl dl, 4
        ;shr dl, 4
        
        ;outnumln dx,,b
        
        xor dh, dl
        
        ;outnumln dh,,b
        
        mov al, L
        cbw
        cwde
        
        ;outint eax
        ;outchar ' '
        ;outint ecx
        ;outchar ' '
        
        sub eax, ebx
        
        ;outint eax
        ;outchar ' '
        ;outint esi
        ;outchar ' '
        ;outintln edi
        
        ;outstr 'new x_i: '
        ;outintln dh
        
        mov child[eax], dh
        
        ;outintln dh
        
        inc esi
        inc edi
        dec ebx
        cmp ebx, 0
        jne lstart_nch
        jmp lend_nch
    
    lend_nch:
    
    pop edi
    pop esi
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret
new_child endp

new_generation proc

    push eax
    push ebx
    push ecx
    push edx
    push ebp
    push esi
    push edi

    lea ebp, X_new
    lea ebx, child
    
    mov ch, M
    mov esi, 0
    
    ext_loop_ngen_start:
    
        mov cl, L
        mov edi, 0
        
        call new_child
        
        int_loop_ngen_start:
        
            mov eax, esi
            mul L
            add eax, edi
            
            mov dl, [ebx+edi]
            mov [ebp+eax], dl
            
            ;outintln dl
            
            inc edi
            dec cl
            cmp cl, 0
            jne int_loop_ngen_start
            jmp int_loop_ngen_end
        
        int_loop_ngen_end:
        
        inc esi
        dec ch
        cmp ch, 0
        jne ext_loop_ngen_start
        jmp ext_loop_ngen_end
    
    ext_loop_ngen_end:
    
    mov cl, L
    mov edi, 0
    
    new_single_start:
    
        call generate_single
        
        mov [ebp+edi], al
        
        inc edi
        dec cl
        cmp cl, 0
        jne new_single_start
        jmp new_single_end
    
    new_single_end:
    
    pop edi
    pop esi
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret
new_generation endp

swap_generations proc

    push eax
    push ebx
    push ecx
    push edx
    push ebp
    push esi
    push edi

    lea ebp, X
    lea ebx, X_new
    
    mov ch, M
    mov esi, 0
    
    ext_loop_sgen_start:
    
        mov cl, L
        mov edi, 0
        
        int_loop_sgen_start:
        
            mov eax, esi
            mul L
            add eax, edi
            
            mov dh, [ebx+eax]
            mov [ebp+eax], dh
            ;mov [ebx+eax], 0
            
            ;outstr 'x'
            ;outint edi
            ;outstr ': '
            ;outint dh
            ;outstr '; '
            
            inc edi
            dec cl
            cmp cl, 0
            jne int_loop_sgen_start
            jmp int_loop_sgen_end
        
        int_loop_sgen_end:
        
        ;outcharln ' '
        
        inc esi
        dec ch
        cmp ch, 0
        jne ext_loop_sgen_start
        jmp ext_loop_sgen_end
    
    ext_loop_sgen_end:
    
    pop edi
    pop esi
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax  

    ret
swap_generations endp

mutate proc

    push eax
    push ebx
    push ecx
    push edx
    push ebp
    push esi
    push edi
    
    lea ebp, X
    
    mov ch, M
    mov esi, 0
    
    xor eax, eax
    
    mutate_loop_start:
    
        mov eax, esi
        mul L
        mov edi, eax
        
        mov al, L
        cbw
        cwde
        mov ebx, eax
        
        xor edx, edx
        call generate_single
        div ebx
        
        add edi, edx
        
        call generate_single
        shl eax, 29
        shr eax, 29
        ;outnumln eax,,b
        
        xor edx, edx
        mov dl, 1
        mov cl, al
        shl dl, cl
        mov dh, [ebp+edi]
        
        call generate_single
        cmp al, 128
        jb mutate_bit_start
        jmp mutate_bit_end
        
        mutate_bit_start:
        
            xor dh, dl
            mov [ebp+edi], dh
            jmp mutate_bit_end
        
        mutate_bit_end:
        
        inc esi
        dec ch
        cmp ch, 0
        jne mutate_loop_start
        jmp mutate_loop_end
    
    mutate_loop_end:
    
    pop edi
    pop esi
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret
mutate endp

start:

    ;generate A-array

    inint L
    
    ;outint Lm
    ;outchar ' '
    ;outintln Lf
    
    mov esi, 0
    mov al, L
    cbw
    cwde
    mov ecx, eax
    ;outintln ecx
    xor eax, eax
    
    A_input:
    
        inint elem
        mov eax, elem
        mov A[esi], al
        
        outstr 'A'
        outint esi
        outstr '='
        outint A[esi]
        outchar ' '
        
        dec ecx
        inc esi
        cmp ecx, 0
        jne A_input
        jmp A_end
                
    A_end:
    
    ;input D
    
    inint D
    outstr 'D='
    outint D
    outstrln ' '
    
    ;generate initial population X
    
    inint M
    inint elem
    
    mov al, M
    mov dl, L
    mul dl
    cwde
    mov ecx, eax
    ;outintln ecx
    mov LM, ecx
    xor eax, eax
    xor edx, edx
    
    mov eax, elem
    
    mov edx, a
    mov ebx, m
    mov esi, 0
    lea ebp, X
    
    call generate_array
    
    mov ecx, 2000
    mov esi, 0
    
    solve:
        
        outstr 'iteration: '
        outintln esi
    
        lea ebp, vint
        lea ebx, V
        call calculate_residuals
        
        mov al, solved
        cmp al, 0
        je end_solve 
        
        lea ebp, V
        call sum_array
        
        ;outintln arrsum
        
        lea ebx, V_balanced
        call balance_array
        
        lea ebp, V_balanced
        lea ebx, prefarr
        call prefix_sum
        
        ;call new_child
        
        call new_generation
        call swap_generations
        
        call mutate
        
        inc esi
        dec ecx
        cmp ecx, 0
        jne solve
        
    end_solve:
    
    exit
end start
