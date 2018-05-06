%include "io.inc"

section .rodata
  L0 db "%d%d",0
  L1 db "%d",0
  L2 db "%d %d",0xa,0

section .text
CEXTERN scanf
CEXTERN printf
CEXTERN getchar 
CEXTERN malloc
CEXTERN free
global CMAIN
CMAIN:
  push ebp
  mov ebp, esp
  push ebx
  push esi
  push edi
  and esp, -16
  sub esp, 32
  xor ebx, ebx ;char c
  mov dword[ebp-16], 0; struct node *tree = 0
  .while_loop:
  call getchar
  mov ebx, eax
  cmp ebx, 'F'
  je .end_while_loop
  mov dword[ebp-20], 0 ;int a
  mov dword[ebp-24], 0 ;int b
  ;switch(c)
  cmp ebx, 'A'
  jne .case_s
  mov dword[esp], L0
  lea eax, [ebp-20]
  mov dword[esp+4], eax
  lea eax, [ebp-24]
  mov dword[esp+8], eax
  call scanf 
  mov eax, dword[ebp-20]
  mov dword[esp+4], eax
  mov eax, dword[ebp-24]
  mov dword[esp+8], eax
  mov eax, dword[ebp-16]
  mov dword[esp], eax
  call insert
  mov dword[ebp-16], eax
  jmp .end_switch
  .case_s:
  cmp ebx, 'S'
  jne .case_d
  mov dword[esp], L1
  lea eax, [ebp-20]
  mov dword[esp+4], eax
  call scanf
  mov eax, dword[ebp-20]
  mov dword[esp], eax
  mov eax, dword[ebp-16]
  mov dword[esp+4], eax
  call find_node
  test eax, eax
  jz .skip
  mov dword[esp], L2
  mov ecx, dword[eax] ;temp->key
  mov edx, dword[eax+4] ;temp->data
  mov dword[esp+4], ecx
  mov dword[esp+8], edx
  call printf
  .skip:
  jmp .end_switch
  .case_d:
  cmp ebx, 'D'
  jne .end_switch
  mov dword[esp], L1
  lea eax, [ebp-20]
  mov dword[esp+4], eax
  call scanf
  mov eax, dword[ebp-20]
  mov dword[esp+4], eax
  mov eax, dword[ebp-16]
  mov dword[esp], eax
  call removen
  mov dword[ebp-16], eax
  jmp .end_switch
  .end_switch:
  jmp .while_loop
  .end_while_loop:
  mov eax, dword[ebp-16]
  mov dword[esp], eax
  call free_tree
  mov esp, ebp
  mov edi, dword[esp-12]
  mov esi, dword[esp-8]
  mov ebx, dword[esp-4]
  xor eax, eax
  pop ebp
  ret
  xor eax, eax
  ret
  
free_tree:
  push ebp
  mov ebp, esp
  sub esp, 8
  mov eax, dword[ebp+8]
  test eax, eax
  jz .epilog
  mov eax, dword[eax+12]
  mov dword[esp], eax
  call free_tree
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  call free_tree
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call free
  .epilog:
  mov esp, ebp
  pop ebp
  ret
  
find_node:
  push ebp
  mov ebp, esp
  mov eax, dword[ebp+8] ;eax=int key
  mov ecx, dword[ebp+12] ;ecx=struct node *t
  .while_loop:
  test ecx, ecx
  jz .end_while_loop
  mov edx, dword[ecx]
  cmp edx, eax
  je .end_while_loop
  jle .else
  mov ecx, dword[ecx+12]
  jmp .end_if
  .else:
  mov ecx, dword[ecx+16]
  .end_if:
  jmp .while_loop
  .end_while_loop: 
  mov eax, ecx
  mov esp, ebp
  pop ebp
  ret
  
remove_min: ;register memory???
  push ebp
  mov ebp, esp
  sub esp, 8
  mov eax, dword[ebp+8]
  mov eax, dword[eax+12]
  test eax, eax
  jz .special_case
  mov dword[esp], eax
  call remove_min
  mov ecx, dword[ebp+8]
  mov dword[esp], ecx
  mov dword[ecx+12], eax
  call balance
  .epilog:
  mov esp, ebp
  pop ebp
  ret
  
  .special_case:
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  jmp .epilog
  
removen:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, dword[ebp+8]
  test eax, eax
  jz .retzero
  mov eax, dword[ebp+8]
  mov eax, dword[eax]
  cmp dword[ebp+12], eax
  jg .greater
  je .equal
  mov eax, dword[ebp+8]
  mov eax, dword[eax+12]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov dword[esp+4], eax
  call removen
  mov ecx, dword[ebp+8]
  mov dword[ecx+12], eax
  jmp .end
  .greater:
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov dword[esp+4], eax
  call removen
  mov ecx, dword[ebp+8]
  mov dword[ecx+16], eax
  jmp .end
  .equal:
  mov eax, dword[ebp+8]
  mov eax, dword[eax+12]
  mov dword[ebp-4], eax
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  mov dword[ebp-8], eax
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call free
  mov eax, dword[ebp-8]
  test eax, eax
  jz .retq
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call find_min
  mov dword[ebp-12], eax
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call remove_min
  mov ecx, dword[ebp-12]
  mov dword[ecx+16], eax
  mov eax, dword[ebp-4]
  mov dword[ecx+12], eax
  mov eax, dword[ebp-12]
  mov dword[esp], eax
  call balance
  mov esp, ebp
  pop ebp
  ret 
  .retq:
  mov eax, dword[ebp-4]
  mov esp, ebp
  pop ebp
  ret 
  .retzero:
  mov eax, 0
  mov esp, ebp
  pop ebp
  ret
  .end:
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call balance 
  mov esp, ebp
  pop ebp
  ret
  
find_min:
  push ebp
  mov ebp, esp
  mov ecx, dword[ebp+8] ;ecx=struct node* t
  test ecx, ecx
  jz .epilog
  mov eax, dword[ecx+12]
  test eax, eax
  jz .epilog
  .while_loop:
  mov eax, dword[ecx+12]
  test eax, eax
  jz .end_while_loop
  mov ecx, eax
  jmp .while_loop
  .end_while_loop:
  .epilog:
  mov eax, ecx
  mov esp, ebp
  pop ebp
  ret
  
insert:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  test eax, eax
  jnz .notzerop
  mov dword[esp], 20
  call malloc
  mov dword[ebp+8], eax
  mov ecx, dword[ebp+12]
  mov dword[eax], ecx
  mov ecx, dword[ebp+16]
  mov dword[eax+4], ecx
  mov dword[eax+8], 1
  mov dword[eax+12], 0
  mov dword[eax+16], 0
  mov eax, [ebp+8]
  mov esp, ebp
  pop ebp
  ret
  
  .notzerop:
  mov eax, [ebp+8]
  mov eax, [eax]
  cmp dword[ebp+12], eax
  jg .greater
  je .equal
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [esp], eax
  mov eax, [ebp+12]
  mov [esp+4], eax
  mov eax, [ebp+16]
  mov [esp+8], eax
  call insert
  mov ecx, [ebp+8]
  mov [ecx+12], eax
  jmp .end
  .greater:
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [esp], eax
  mov eax, [ebp+12]
  mov [esp+4], eax
  mov eax, [ebp+16]
  mov [esp+8], eax
  call insert
  mov ecx, [ebp+8]
  mov [ecx+16], eax
  jmp .end
  .equal:
  mov ecx, [ebp+16]
  mov eax, [ebp+8]
  mov [eax+4], ecx
  .end:
  mov eax, [ebp+8]
  mov [esp],eax
  call balance
  mov esp, ebp
  pop ebp
  ret
  
balance:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  mov [esp], eax
  call fixheight
  mov eax, [ebp+8]
  mov [esp], eax
  call bfactor
  cmp eax, 2
  jne .skip1
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [esp], eax
  call bfactor
  cmp eax, 0
  jge .skip1_1
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [esp], eax
  call rotateright
  mov ecx, [ebp+8]
  mov [ecx+16], eax
  .skip1_1:
  mov eax, [ebp+8]
  mov [esp], eax
  call rotateleft
  mov esp, ebp
  pop ebp
  ret
  .skip1:
  mov eax, [ebp+8]
  mov [esp], eax
  call bfactor
  cmp eax, -2
  jne .skip2
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [esp], eax
  call bfactor
  cmp eax, 0
  jle .skip2_1
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [esp], eax
  call rotateleft
  mov ecx, [ebp+8]
  mov [ecx+12], eax
  .skip2_1:
  mov eax, [ebp+8]
  mov [esp], eax
  call rotateright
  mov esp, ebp
  pop ebp
  ret
  .skip2:
  mov eax, [ebp+8]
  mov esp, ebp
  pop ebp
  ret

rotateleft:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [ebp-4], eax
  mov eax, [ebp-4]
  mov eax, [eax+12]
  mov ecx, [ebp+8]
  mov [ecx+16], eax
  mov eax, [ebp-4]
  mov ecx, [ebp+8]
  mov [eax+12], ecx
  mov eax, [ebp+8]
  mov [esp], eax
  call fixheight
  mov eax, [ebp-4]
  mov [esp], eax
  call fixheight
  mov eax, [ebp-4]
  mov esp, ebp
  pop ebp
  ret
  
rotateright:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [ebp-4], eax
  mov eax, [ebp-4]
  mov eax, [eax+16]
  mov ecx, [ebp+8]
  mov [ecx+12], eax
  mov eax, [ebp-4]
  mov ecx, [ebp+8]
  mov [eax+16], ecx
  mov eax, [ebp+8]
  mov [esp], eax
  call fixheight
  mov eax, [ebp-4]
  mov [esp], eax
  call fixheight
  mov eax, [ebp-4]
  mov esp, ebp
  pop ebp
  ret
  
fixheight:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [esp], eax
  call height
  mov [ebp-4], eax
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [esp], eax
  call height
  mov [ebp-8], eax
  mov eax, [ebp-4]
  cmp eax, [ebp-8]
  jle .else
  mov ecx, [ebp-4]
  jmp .end
  .else:
  mov ecx, [ebp-8]
  .end:
  inc ecx
  mov eax, [ebp+8]
  mov [eax+8], ecx
  mov esp, ebp
  pop ebp
  ret
  
bfactor:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, [ebp+8]
  mov eax, [eax+16]
  mov [esp], eax
  call height
  mov [ebp-4], eax
  mov eax, [ebp+8]
  mov eax, [eax+12]
  mov [esp], eax
  call height 
  sub [ebp-4], eax
  mov eax, [ebp-4]
  mov esp, ebp
  pop ebp
  ret
  
height:
  push ebp
  mov ebp, esp
  mov eax, [ebp+8]
  test eax, eax
  jz .zerop
  mov eax, [eax+8]
  mov esp, ebp
  pop ebp
  ret
  .zerop:
  mov eax, 0
  mov esp, ebp
  pop ebp
  ret