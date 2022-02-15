;(nasm "%f" -felf64 -o "%e".o) && (ld -m elf_x86_64 "%e".o -o"%e")
global read_char, print_char, read_int, print_int, read_string, print_string

section .text

; ---------------------------------------------------------------------
read_char:
	sub rsp, 8
	mov qword[rsp], 0                  ; clean
	mov     rax, 0                     ; sys_read
	mov     rdi, 0                     ; keyboard
	mov     rsi, rsp                   ; address
	mov     rdx, 1                     ; 1 byte to read
	syscall
	pop rax
	ret

; --------------------------------------------------------------------- 
print_char:
	push rdi
	mov     rax, 1                     ; sys_write
	mov     rdi, 1                     ; screen
	mov     rsi, rsp                   ; adress
	mov     rdx, 1                     ; 1 byte to print   
	syscall
	pop rdi
	ret

; ---------------------------------------------------------------------  
read_int:
	push rbx
	
	mov r9, 0                          ; 0 - non-negative
	call read_char
	cmp al, '-'
	jne non_negative
	
	call read_char
	mov r9, 1                          ; 1 - negative
	
	non_negative:

	xor rbx, rbx
	read_next_digit:
		sub rax, '0'                   ; convert char to number
		push rax
		mov rax, rbx
		mov rdi, 10  
		xor rdx, rdx
		mul rdi                        ; rax*=10
		pop rbx
		add rax, rbx
		mov rbx, rax

		call read_char
		cmp al, 0ah                    ; while char!='\n'
		jne read_next_digit

	cmp r9, 1
	jne .dont_negate
	
	neg rbx
	
	.dont_negate:
		mov rax, rbx
		pop rbx
		ret

; --------------------------------------------------------------------- 
print_int:
	push r12
	movsx rax, edi
	sub rsp, 8
	mov r12, rsp                       ; copy rsp
	cmp rax, 0
	jg .dont_negate
	
	neg rax
	
	.dont_negate:
	push_next_digit:
		mov rsi, 10
		xor rdx, rdx
		div rsi
		add rdx, '0'                   ; convert number to char
		sub rsp, 1
		mov byte[rsp], dl              ; push consecutive digits on stack
		
		cmp rax, 0
		jne push_next_digit

	cmp edi, 0
	jge no_sign
	
	sub rsp, 1
	mov byte[rsp], '-'
	
	no_sign:
	xor rdi, rdi
	print_next_digit:		
		mov dil, byte[rsp]
		add rsp, 1
		call print_char
		cmp rsp, r12                   ; check if stack is 'empty'
		jne print_next_digit

	add rsp, 8                         ; restore rsp
	pop r12
	ret

; ---------------------------------------------------------------------
read_string:
	push rbx
	push r12
	push r13
	mov r12, 1                         ; r12=string length (+1 for null)

	read_next_char:
		call read_char
		cmp al, 0ah                    ; read string until the new line is encountered
		je allocate_mem

		dec rsp
		mov byte[rsp], al              ; push consecutive chars on stack
		inc r12
		jmp read_next_char

	allocate_mem:
		dec rsp
		mov byte[rsp], 0               ; add null for c-style string

		mov   rax, 12                  ; sys_brk
		mov   rdi, 0                   ; heap base
		syscall
		mov   r13, rax                 ; r13=&heap base
		lea   rdi, [rax + r12]         ; allocate r12 bytes
		mov   rax, 12
		syscall

	copy_next_char:
		cmp r12, 0
		je return_adress
		
		mov bl, [rsp] 
		mov byte[r13+r12-1], bl        ; copy char from stack to allocated memory
		inc rsp
		dec r12
		jmp copy_next_char

	return_adress:
		mov rax, r13
		pop r13
		pop r12
		pop rbx
		ret

; ---------------------------------------------------------------------
print_string:
	mov rsi, rdi
	mov rcx, -1                        ; rcx counts string length
	mov rax, 0                         ; until 0 is encountered
	cld
	repne scasb
	
	mov rax, -2
	sub rax, rcx                       ; inverse negative counter into length
	mov rcx, rax

	mov     rax, 1                     ; sys_write
	mov     rdi, 1                     ; screen
	mov     rdx, rcx                   ; x bytes to print
	syscall
	ret

