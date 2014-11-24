;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; check_win (column C , row R ,player P) Checks if
; the game is over given the last move
;
; returns 1 if player P wins, 0 otherwised 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extern printf, board
global check_win

%define WIDTH 6
%define SIZE_1D 24
%define SIZE 144

  SECTION .rodata

test_msg: db "ROW %d, COL %d, %d",0xA,0
one:  dd 1
  SECTION .text

check_win:
  push ebp
  mov ebp, esp
  push ebx
  push esi
 
  mov eax, [ebp + 8]     ; row 
  imul eax, SIZE_1D  
 
  mov ebx, [ebp + 12]    ; player
 
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check Horizontal win condition
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mov esi, 4      ; Check for 4 in a row
  mov ecx, 0      ; iterate over row
hor_loop:
  
  mov edx, [board + ecx + eax]  
  cmp edx, ebx                  ; current player's piece
  je hor_player 
 
  mov esi, 4                    ; reset 4 in a row count  
  jmp iter_horiz

hor_player:                            
  dec esi                       ; decrement 4 in a row count
  cmp esi, 0                   
  cmove eax, [one]              ; if 4 player pieces in a row seen,
  je exit                       ; return 1
  
iter_horiz:                     ; increment loop condition
  add ecx, 4
  cmp ecx, SIZE_1D
  jle hor_loop 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check Vertical win condition
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  mov esi, 4                      ; Checks for 4 in a row
  mov eax, [ebp + 16]             ; column paramter
  dec eax
  shl eax, 2                      ; convert column to pointer
  mov ecx, 0                      ; loop iterator

ver_loop:
  mov edx,[board + ecx + eax]
  cmp edx, ebx                   ; current player's piece
  je ver_player

  mov esi, 4                     ; reset 4 in a row count
  jmp iter_ver

ver_player:
  dec esi                        ; decrement 4 in a row count
  cmp esi, 0 
  cmove eax, [one]               ; if 4 player pieces in a column
  je exit                        ; return 1

iter_ver:                        ; increment loop codition
 add ecx, SIZE_1D
 cmp ecx, SIZE
 jle ver_loop

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check Diagonal top right win condition
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mov esi, 4                    ; 4 in a row counter
  mov eax, [ebp +8]             ; row index
  mov ecx, [ebp + 16]           ; column index
  dec ecx

tr_intersec:                    ; find where the diagonal line intersecs the axis
  cmp eax, -1
  jle tr_break
  cmp ecx, -1
  jle tr_break

  dec ecx
  dec eax
  jmp tr_intersec

tr_break:                        
  inc ecx
  shl ecx, 2

  inc eax
  imul eax, SIZE_1D

top_r_loop:                    ; examine pieces in the diagonal for 4 user pieces in a row
  mov edx, [board + ecx + eax ]  
  cmp ebx, edx
  je top_r_player
 
  mov esi, 4
  jmp iter_top_r 

top_r_player:                 ; decrement counter
  dec esi                  
  cmp esi, 0
  cmove eax, [one]            ; if 4th piece in a row seen, return 1
  je exit
 
iter_top_r:                   ; iterate loop
  add ecx, 4
  add eax, SIZE_1D  

  cmp eax, SIZE
  jge down_left 
  cmp ecx, SIZE_1D
  jge down_left
  
  jmp top_r_loop  
 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Check Diagonal down & left win condition
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
down_left:

  mov esi, 4                  ; 4 in a row counter
  mov eax, [ebp +8]           ; row index  
  mov ecx, [ebp + 16]         ; column index
  dec ecx

dl_intersec:                  ; find where diagonal cuts the axis
  cmp eax, -1
  jle dl_break
  cmp ecx, SIZE_1D
  jge dl_break

  inc ecx
  dec eax
  jmp dl_intersec

dl_break:
  dec ecx
  shl ecx, 2

  inc eax
  imul eax, SIZE_1D

down_l_loop:                  ; test for 4 player piece in a row on diagonal
  mov edx, [board + ecx + eax ]  
  cmp ebx, edx
  je down_l_player
 
  mov esi, 4
  jmp iter_down_l 

down_l_player:               ; if player piece, decrement counter 
  dec esi
  cmp esi, 0
  cmove eax, [one]           ; if 4th player piece in a row on diagonal return 1
  je exit
 
iter_down_l:                 ; iterate loop
  sub ecx, 4
  add eax, SIZE_1D  

  cmp eax, SIZE
  jge ret 
  cmp ecx, 0
  jl ret
  
  jmp down_l_loop  
 
 ;
 ; No winning condition found, return 0
 ;
ret:
 mov eax, 0                    

exit:  
  pop esi
  pop ebx
  pop ebp
  ret
