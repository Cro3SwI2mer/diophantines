include C:\MASM614\include\console.inc

;TODO: elem should be dd

.data

N equ 100000

a equ 48271

m equ 2147483647

solved db 0

elem db ? ;random number

M db ? ;size of population

L db ? ;num of variables per individual

Lf db ? ;num of gens from father

Lm db ? ;num of gens from mother

A db N dup(?) ;coefficients, size = L

D db ? ;sum{A_i * X_i} = D

X db N dup(?) ;population, size = M * L

vint dd N dup(?) ;A_i*X_i array for single X

V dd N dup(?) ;array of resifuals for single population

arrsum dd ?

V_balanced dd N dup(?) ;V_balanced_i = sum{V} / V_i * [*smth]

prefarr dd N dup (?)

X_next db N dup(?) ;next population after current X

smth equ 10000

.code

public generate_single

generate_single proc
   
    push edx
    push ebx

    mul edx
    div ebx
    
    mov eax, edx
    
    mov elem, al
    
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
        ;cbw
        ;cwde
        
        mov elem, al
        
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
            
                mov solved, 1
                jmp transfer
                
            equation_not_solved:
            
                mov solved, 0
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
    
    mov ebx, arrsum
    mov edx, a
    
    xor eax, eax
    mov al, elem
    cbw
    cwde
    
    call generate_single
    outstr 'first thrown number: '
    outintln eax
    
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
    
    outstr 'father: '
    outintln esi
    
    call generate_single
    outstr 'second thrown number: '
    outintln eax
    
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
    
    outstr 'mother: '
    outintln edi
    
    pop ebp
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret
select_single_ids endp

new_generation proc

    push eax
    push ebx

    mov al, L
    cbw
    cwde
    mov ebx, eax
    xor eax, eax
    
    mov edx, a
    
    outstr 'current random value: '
    outintln elem
    mov al, elem
    cbw
    cwde
    
    outintln edx
    outintln ebx
    mul edx
    div ebx
    
    mov eax, edx
    outnumln eax,,b
    
    mov elem, al
    outnumln al,,b
    
    pop ebx
    pop eax

    ret
new_generation endp

start:

    ;generate A-array

    inint L
    
    mov al, L
    cbw
    mov bl, 2
    div bl
    mov Lf, al
    add al, ah
    mov Lm, al
    
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
        mov al, elem
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
    xor eax, eax
    xor edx, edx
    
    mov al, elem
    cbw
    cwde
    
    mov edx, a
    mov ebx, m
    mov esi, 0
    lea ebp, X
    
    call generate_array
    
    solve:
    
        lea ebp, vint
        lea ebx, V
        call calculate_residuals
        
        lea ebp, V
        call sum_array
        
        ;outintln arrsum
        
        lea ebx, V_balanced
        call balance_array
        
        lea ebp, V_balanced
        lea ebx, prefarr
        call prefix_sum
        
        call select_single_ids
        
        call new_generation
        
    end_solve:
    
    exit
end start
