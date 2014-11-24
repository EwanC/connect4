;
;Ewan Crawford  ewan.cr@gmail.com   
;May 2014
;--------------------------------------------------------------
; 2 player Connect 4 program in 32-bit Linux NASM
;
; TODO
; check win 

%define WIDTH 6                 ; board is a 6x6 grid
%define SIZE_1D 24              ; size of a single row/column using 4 byte ints 
%define SIZE  144               ; total size of board

global _start,board                ; tell linker entry point
extern printf,scanf          ; tell linker that printf & scanf is defined elsewhere
extern check_win             ; function defined in check_win.asm


            SECTION .data

board: dd   0,0,0,0,0,0, \
            0,0,0,0,0,0, \
            0,0,0,0,0,0, \
            0,0,0,0,0,0, \
            0,0,0,0,0,0, \
            0,0,0,0,0,0

             SECTION .rodata    ;Format strings for printf and scanf

welcome_msg: db "Welcome to Connect 4!",0xA,0  
P1_msg:      db 0xA,"Player 1(X) enter a move(1-6): ",0  
P2_msg:      db 0xA,"Player 2(O) enter a move(1-6): ",0
P1win_msg:   db 0xA,"PLAYER 1 WINS!",0xA,0
P2win_msg    db 0xA,"PLAYER 2 WINS!",0xA,0
int_format:  db "%d",0
one:         dd 1
board_ind:   db 0xA,"  1   2   3   4   5   6",0xA,0
board_p1:    db "| X ",0
board_p2:    db "| O ",0
board_empty: db "|   ",0
new_line:    db "|",0xA,0
            
             SECTION .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;main()
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_start:
                             ; Greeting Message using printf
     push welcome_msg
     call printf
     add  esp, 4     
     mov  ebx, 1

                             
game_loop:
     cmp  ebx, 2             ; ebx holds the player with the current turn
     je   p2_turn  

p1_turn:
     push P1_msg
     jmp prompt

p2_turn:
     push P2_msg
     
prompt:    
     call printf             ; prompt player for column input for piece
    
     mov eax,esp             ; get column for user using scanf
     push eax                
     push int_format
     call scanf              
     add  esp, 4
     pop  eax

     mov eax, [eax]          ; validate user input to between 1 - 6
     cmp eax, 0            
     jle  exit
     cmp eax, 6
     jg  exit

     push eax                ; Update board variable, passing column and player
     push ebx
     call move
     add esp, 4
     pop eax 
    

     push eax                ; call check_win to test for end of game
     push ebx
     push edx
     call check_win
     add esp, 12
     
     push eax
     call print_board        ; print updated board
     
     pop eax
     cmp eax, 1
     je win

alt_turn:                    ; switch player with current turn from player 2 to 1, or 1 to 2
     cmp  ebx, 2
     cmove ebx, [one] 
     je game_loop
     mov ebx, 2
     jmp game_loop 


win:
   cmp ebx, 2
   je win2

   push P1win_msg
   call printf
   add esp, 4          
   jmp exit

win2:
  push P2win_msg
  call printf
  add esp, 4  

exit:                        ; exit program with sys_exit system call  
     mov eax, 1             
     int 0x80             

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;print_board(), prints board to stdout  
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_board:                    
     push ebp            ; callee save ebp and update stack pointers
     mov  ebp, esp
     push ebx

     push board_ind      ; print column indices
     call printf
     add esp, 4
     
     mov eax, SIZE       ; use eax to index the row, descending from the largest value
     sub eax, SIZE_1D
     mov ecx, 0          ; ecx indexes the column in the row
    
board_loop:
    
    mov ebx, [board + eax + ecx]  ; ebx holds the current value pointed to
 
    push eax                      ; caller save         
    push ecx
    
    cmp ebx, 1
    je print_p1
   
    cmp ebx, 2
    je print_p2

    push board_empty
    jmp print_piece     

print_p1:    
    push board_p1                     ; printf element
    jmp print_piece
print_p2:
    push board_p2                     

print_piece:
  
    call printf
    add esp, 4

    pop ecx                       ; caller restore
    pop eax

    add ecx, 4                    ; point to next element 
    cmp ecx, SIZE_1D              ; check for end of row
    jl  board_loop

    mov ecx, 0                    ; set ecx to point to start of new row
    sub eax, SIZE_1D
  
    push eax                      ; caller save
    push ecx
  
    push new_line                 ; print new line for end of row
    call printf
    add esp, 4
  
    pop ecx                       ; caller restore                     
    pop eax
    
    cmp eax, -SIZE_1D             ; check if all the rows have been seen
    jg board_loop
    
    pop ebx                       ; restore calle save ebx
    pop ebp                       ; reset stack
    ret                           ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; move(column C , player P), updates to board with 
; player P adding a piece to column C
;
; returns row piece stopped at, -1 on error 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

move:
     push ebp                   ; save callee registers and stack pointers
     mov  ebp, esp
     push ebx

     mov eax,[ebp + 12]         ; set eax to column value from parameter
     dec eax
     shl eax,2
     mov ecx,[ebp + 8]          ; set ecx to player who made to move, passed as parameter
     mov edx, 0           
loop_col:
               
     mov ebx,[board + eax]      ; board pointer for column
     
     cmp ebx, 0                 ; check for free slot
     je space
     
     inc edx
     add eax, SIZE_1D           ; if space if occupied set eax to point to the next column and loop
     cmp eax, SIZE
     jl loop_col    
          
     pop ebx                    ; No free slot found in column
     pop ebp
     mov eax, -1
     ret

space:                          ; When a free slot is found, store the player value   
    mov [board + eax], ecx      
    mov eax, edx                 ; set eax to row

    pop ebx                     ; return 
    pop ebp
    ret
