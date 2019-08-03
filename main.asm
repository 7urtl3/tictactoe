		global main
		extern printf
		extern scanf
		section .data
princ: db ' ',' ',' ',' ',' ',' ',' ',' ',' '
fmt: db "|%c|%c|%c|", 10, 0
u: db   "-------", 10, 0
d: db 	"%d", 0
x: db	"X", 0
o: db	"O", 0
hooray_x: db "Hooray! X won!", 10, 0
hooray_o: db "Hooray! O won!", 10, 0
draw: 	  db "This is draw :)", 10, 0
input_your_shit: db "Input your move>>", 0
clear: db `\033[H\033[2J`, 0
input dw 0

		section .text
do_printf:
		push rbp				;
		mov rbp, rsp				;
		xor rax, rax				;
		call printf				;
		leave 					;
		ret 					;
clear_func:
		push rbp				;	clear_func()
		mov rbp, rsp				;
		mov rdi, clear 				;
		call do_printf				;
		leave 					;
		ret 					;


paint:
		push rbp				;	paint()
		mov rbp, rsp				;
		call clear_func 			;
		xor rbx, rbx				;
	label:
		mov rdi, fmt 				;
		mov rsi, [princ+rbx*3]			;
		mov rdx, [princ+rbx*3+1]		;
		mov rcx, [princ+rbx*3+2]		;
		call do_printf				;
		cmp ebx, 2				;
		jge finish 				;
		mov rdi, u 				;
		call do_printf				;
		inc ebx					;
		jmp label 				;
	finish:
		leave 					;
		ret 					;

user_input:
		push rbp				;	user_input()
		mov rbp, rsp				;
		mov rdi, input_your_shit 		;
		call do_printf				;
		mov rdi, d 				;
		mov rsi, input 				;
		call scanf				;
		mov rdi, [input] 			;
		leave 					;
		ret 					;

mod:
		push rbp				;	mod(int rdi, int rsi)
		mov rbp, rsp				;
		xor rdx, rdx				;
		mov rcx, rsi 				;
		mov rax, rdi				;
		div rcx					;
		mov rax, rdx				;
		leave 					;
		ret 					;

fill_in:
		push rbp				;  rdi - число введенное пользователем, rsi - счетчик основного цикла
		mov rbp, rsp				;  fill_in(int rdi, int rsi)
		push rdi				;
		mov rdi, rsi				;
		mov rsi, 2				;
		call mod 				;
		pop rdi					;
		cmp rax, 1				;
		je O_L 					;
		mov rsi, x 				;
		jmp done 				;
	O_L:
		mov rsi, o,				;
	done:
		mov al, byte [rsi]			;
		mov [princ+rdi-1], al			;
		leave 					;
		ret 					;

is_able:
		push rbp				;	is_empty(int rdi)
		mov rbp, rsp				;

		cmp rdi, 9				;
		jg not_eq 				;
		cmp rdi, 0				;
		jl not_eq 				;

		mov al, byte [princ+rdi-1]		;
		cmp al, 32				;
		jne not_eq 				;
		jmp is_able_finish 			;
	not_eq:
		mov rax, 1				;
	is_able_finish:
		leave 					;
		ret 					;

is_won:
		push rbp				;
		mov rbp, rsp				;
		xor rbx, rbx				;
	is_won_label1:
		xor eax, eax				;
		add ah, byte [princ+rbx*3]		;
		add ah, byte [princ+rbx*3+1]		;
		add ah, byte [princ+rbx*3+2]		;
		cmp eax, 800h				;
		je X_WON				;
		cmp eax, 60672				;
		je O_WON				;
		inc ebx					;
		cmp ebx, 3				;
		jge is_won_bridge1			;
		jmp is_won_label1			;
	is_won_bridge1:
		xor ebx, ebx				;
	is_won_label2:
		xor eax, eax				;
		add ah, byte [princ+rbx]		;
		add ah, byte [princ+rbx+3]		;
		add ah, byte [princ+rbx+6]		;
		cmp eax, 800h				;
		je X_WON				;
		cmp eax, 60672				;
		je O_WON				;
		inc ebx					;
		cmp ebx, 3				;
		jge is_won_bridge2			;
		jmp is_won_label2			;
	is_won_bridge2:
		mov ebx, 4				;
		xor rcx, rcx				;
	is_won_label3:
		xor eax, eax				;
		add ah, byte [princ+ecx]		;
		add ah, byte [princ+ecx+ebx]		;
		add ah, byte [princ+ecx+ebx*2]		;
		cmp eax, 800h				;
		je X_WON				;
		cmp eax, 60672				;
		je O_WON				;
		sub ebx, 2				;
		add ecx, 2				;
		cmp ebx, 0				;
		je is_won_finish			;
		jmp is_won_label3			;
	is_won_finish:
		mov rax, 0				;
		leave 					;
		ret 					;
	X_WON:
		mov rax, 1				;
		leave 					;
		ret 					;
	O_WON:
		mov rax, 2				;
		leave 					;
		ret 					;

main:
		push rbp				;
		mov rbp, rsp				;
		sub rsp, 16				;
		mov byte [rbp-8], 0			; 
	game_cycle:
		call paint 				;
		call is_won 				;
		cmp rax, 1				;
		je X_WIN 				;
		cmp rax, 2				;
		je O_WIN 				;
		cmp byte [rbp-8], 9			;
		jge DRAW		

		call user_input 			;

		call is_able 				;
		cmp al, 1				;
		je game_cycle 				;

		xor rsi, rsi				;
		mov sil, byte [rbp-8]			;
		call fill_in 	 			;

		mov al, byte [rbp-8]			;
		inc al					;
		mov byte [rbp-8], al			;
		jmp game_cycle 				;
	X_WIN:
		mov rdi, hooray_x 			;
		call do_printf				;
		jmp game_over 				;
	O_WIN:
		mov rdi, hooray_o 			;
		call do_printf				;
		jmp game_over 				;
	DRAW:
		mov rdi, draw 	 			;
		call do_printf				;
		jmp game_over 				;
	game_over:
		leave 					;
		ret 					;
