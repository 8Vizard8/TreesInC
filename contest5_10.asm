%include "io.inc"

section .rodata
  L0 db "%d%d",0
  L1 db "%d",0
  L2 db "%d %d",0xa,0

section .text
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
  mov dword[ebp-4], 0; struct node *tree = 0
  .while_loop:
  call getchar
  mov ebx, eax
  cmp ebx, 'F'
  je .end_while_loop
  mov dword[ebp-8], 0 ;int a
  xor dword[ebp-12], 0 ;int b
  ;switch(c)
  cmp ebx, 'A'
  jne .case_s
  mov dword[esp], L0
  lea eax, [ebp-8]
  mov dword[esp+4], eax
  lea eax, [ebp-12]
  mov dword[esp+8], eax
  call scanf 
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  mov eax, dword[ebp-12]
  mov dword[esp+4], eax
  mov eax, dword[ebp-4]
  mov dword[esp+8], eax
  call insert_node
  mov dword[ebp-4], eax
  jmp .end_switch
  .case_s:
  cmp ebx, 'S'
  jne .case_d
  mov dword[esp], L1
  lea eax, [ebp-8]
  mov dword[esp+4], eax
  call scanf
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  mov eax, dword[ebp-4]
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
  lea eax, [ebp-8]
  mov dword[esp+4], eax
  call scanf
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  mov eax, dword[ebp-4]
  mov dword[esp+4], eax
  call delete_node
  mov dword[ebp-4], eax
  jmp .end_switch
  .end_switch:
  jmp .while_loop
  .end_while_loop:
  mov eax, dword[ebp-4]
  mov dword[esp], eax
  call free_tree
  mov esp, ebp
  mov edi, dword[esp-12]
  mov esi, dword[esp-8]
  mov ebx, dword[esp-4]
  pop ebp
  xor eax, eax
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
  mov ecx, dword[ecx+12]
  jmp .while_loop
  .end_while_loop:
  .epilog:
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

insert_node:
  push ebp
  mov ebp ,esp
  sub esp, 24
  mov eax, dword[ebp+16]
  test eax, eax
  jnz .skip
  mov dword[esp], 20 ;if (!t)
  call malloc
  mov dword[ebp+16], eax
  mov ecx, dword[ebp+8]
  mov dword[eax], ecx
  mov ecx, dword[ebp+12]
  mov dword[eax+4], ecx
  mov dword[eax+8], 1
  mov dword[eax+12], 0
  mov dword[eax+16], 0
  jmp .epilog
  .skip: ;else if (key == t->key)
  mov eax, dword[eax] ;eax=t->key
  cmp dword[ebp+8], eax
  jne .skip2
  mov eax, dword[ebp+16]
  mov ecx, dword[ebp+12]
  mov dword[eax+4], ecx
  mov eax, dword[ebp+16]
  jmp .special_case
  .skip2: ;else if (key < t->key)
  jge .skip3
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov dword[esp+4], eax
  mov eax, dword[ebp+16]
  mov eax, dword[eax+12]
  mov dword[esp+8], eax
  call insert_node
  mov ecx, dword[ebp+16]
  mov dword[ecx+12] ,eax
  jmp .epilog
  .skip3: ;else
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov dword[esp+4], eax
  mov eax, dword[ebp+16]
  mov eax, dword[eax+16]
  mov dword[esp+8], eax
  call insert_node
  mov ecx, dword[ebp+16]
  mov dword[ecx+16] ,eax
  .epilog:
  mov eax, dword[ebp+16]
  mov dword[esp], eax
  call balance
  .special_case:
  mov esp, ebp
  pop ebp
  ret

delete_node:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, dword[ebp+12]
  test eax, eax
  jnz .skip
  xor eax, eax
  jmp .epilog
  .skip:
  mov eax, dword[eax] ;eax=t->key
  cmp dword[ebp+8], eax
  jg .case_bigger
  je .case_equal
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov eax, dword[eax+12]
  mov dword[esp+4], eax
  call delete_node
  mov ecx, dword[ebp+12]
  mov dword[ecx+12], eax
  jmp .balanced_epilog
  .case_bigger:
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  mov eax, dword[ebp+12]
  mov eax, dword[eax+16]
  mov dword[esp+4], eax
  call delete_node
  mov ecx, dword[ebp+12]
  mov dword[ecx+16], eax
  jmp .balanced_epilog
  .case_equal:
  mov eax, dword[ebp+12]
  mov ecx, dword[eax+16] ;ecx=t->right
  mov eax, dword[eax+12] ;eax=t->left
  mov dword[ebp-4], eax
  mov dword[ebp-8], ecx
  test ecx, ecx
  jnz .skip2
  mov ecx, dword[ebp+12]
  mov dword[esp], ecx
  call free
  mov eax, dword[ebp-4]
  jmp .epilog
  .skip2:
  mov eax, dword[ebp+12]
  mov dword[esp], eax
  call find_min
  mov dword[ebp-12], eax ;struct node *min = find_min(r)
  mov eax, dword[ebp+12]
  mov dword[esp], eax
  call remove_min
  mov ecx, dword[ebp-12]
  mov dword[ecx+16], eax
  mov eax, dword[ebp-4]
  mov dword[ecx+12], eax
  mov eax, dword[ebp+12]
  mov dword[esp], eax
  call free
  mov eax, dword[ebp-12]
  mov dword[esp], eax
  call balance
  jmp .epilog
  .balanced_epilog:
  mov eax, dword[ebp+12]
  mov dword[esp], eax
  call balance
  .epilog:
  mov esp, ebp
  pop ebp
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

height:
  push ebp
  mov ebp, esp
  mov ecx, dword[ebp+8]
  test ecx, ecx
  jz .tiszero
  mov eax, dword[ecx+8]
  jmp .epilog
  .tiszero:
  mov eax, 0
  .epilog:
  mov esp, ebp
  pop ebp
  ret

max:
  push ebp
  mov ebp, esp
  mov ecx, dword[ebp+8]
  cmp ecx, dword[ebp+12]
  cmovg eax, ecx
  cmovle eax, dword[ebp+12]
  mov esp, ebp
  pop ebp
  ret

balance:
  push ebp
  mov ebp, esp
  sub esp, 24
  mov eax, dword[ebp+8]
  test eax ,eax
  jz .skip
  mov eax, dword[eax+12]
  mov dword[ebp-4], eax
  mov dword[esp], eax
  call height
  mov dword[ebp-12], eax
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  mov dword[ebp-8], eax
  mov dword[esp], eax
  call height
  sub dword[ebp-12], eax
  cmp dword[ebp-12], 2
  jne .elseif
  mov eax, dword[ebp-4]
  mov eax, dword[eax+12]
  mov dword[esp], eax
  call height
  mov dword[ebp-12], eax
  mov eax, dword[ebp-4]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  call height
  sub dword[ebp-12], eax
  cmp dword[ebp-12], 1
  jne .else1
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call RR
  mov dword[ebp+8], eax
  jmp .end_globalif
  .else1:
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call LR
  mov dword[ebp+8], eax  
  jmp .end_globalif
  .elseif:

  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call height
  mov dword[ebp-12], eax
  mov eax, dword[ebp-4]
  mov dword[esp], eax
  call height
  sub dword[ebp-12], eax
  cmp dword[ebp-12], 2
  jne .end_globalif
  mov eax, dword[ebp-8]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  call height
  mov dword[ebp-12], eax
  mov eax, dword[ebp-8]
  mov eax, dword[eax+12]
  mov dword[esp], eax
  call height
  sub dword[ebp-12], eax
  cmp dword[ebp-12], 1
  jne .else2
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call LL
  mov dword[ebp+8], eax
  jmp .end_globalif
  .else2:
  mov eax, dword[ebp+8]
  mov dword[esp], eax
  call RL
  mov dword[ebp+8], eax  
  
  .end_globalif:
  mov eax, dword[ebp-4]
  mov dword[esp], eax
  call height
  mov dword[ebp-12], eax
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call height
  mov dword[esp+4], eax
  mov eax, dword[ebp-12]
  mov dword[esp], eax
  call max
  inc eax
  mov ecx, dword[ebp+8]
  mov dword[ecx+8], eax
  .skip:
  mov eax, dword[ebp+8]
  mov esp, ebp
  pop ebp
  ret
  
RR:
  push ebp
  mov ebp, esp
  push ebx
  sub esp, 20
  mov ecx, dword[ebp+8]
  add ecx, 12 ;ecx=&(k2->left)
  mov eax, dword[ecx]
  mov dword[ebp-4], eax ;k1 = k2->left
  mov edx, eax
  add edx, 16 ;edx=&(k1->right)
  mov eax, dword[edx]
  mov dword[ecx], eax ;k2->left = k1->right
  mov eax, dword[ebp+8]
  mov dword[edx], eax ;k1->right = k2
  ;registers reset
  mov ebx, dword[ebp+8] ;ebx=k2
  mov eax, dword[ebx+12]
  mov dword[esp], eax
  call height
  mov dword[ebp-8], eax ;ebp-8=height(k2->left)
  mov eax, dword[ebx+16]
  mov dword[esp], eax
  call height
  mov dword[esp+4], eax
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call max
  inc eax
  mov dword[ebx+8], eax
  ;
  mov eax, dword[ebp-4]
  mov eax, dword[eax+12]
  mov dword[esp], eax
  call height
  mov dword[esp], eax
  mov eax, dword[ebx+8]
  mov dword[esp+4], eax
  call max
  inc eax
  mov ecx, dword[ebp-4]
  mov dword[ecx+8], eax
  mov eax, dword[ebp-4]
  mov esp, ebp
  pop ebp
  ret
  
LL:
  push ebp
  mov ebp, esp
  push ebx
  sub esp, 20
  mov ecx, dword[ebp+8]
  add ecx, 16 ;ecx=&(k2->right)
  mov eax, dword[ecx]
  mov dword[ebp-4], eax ;k1 = k2->right
  mov edx, eax
  add edx, 12 ;edx=&(k1->left)
  mov eax, dword[edx]
  mov dword[ecx], eax ;k2->right = k1->left
  mov eax, dword[ebp+8]
  mov dword[edx], eax ;k1->left = k2
  ;registers reset
  mov ebx, dword[ebp+8] ;ebx=k2
  mov eax, dword[ebx+12]
  mov dword[esp], eax
  call height
  mov dword[ebp-8], eax ;ebp-8=height(k2->left)
  mov eax, dword[ebx+16]
  mov dword[esp], eax
  call height
  mov dword[esp+4], eax
  mov eax, dword[ebp-8]
  mov dword[esp], eax
  call max
  inc eax
  mov dword[ebx+8], eax
  ;
  mov eax, dword[ebp-4]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  call height
  mov dword[esp], eax
  mov eax, dword[ebx+8]
  mov dword[esp+4], eax
  call max
  inc eax
  mov ecx, dword[ebp-4]
  mov dword[ecx+8], eax
  mov eax, dword[ebp-4]
  mov esp, ebp
  pop ebp
  ret

LR:
  push ebp
  mov ebp, esp
  sub esp, 8
  mov eax, dword[ebp+8]
  mov eax, dword[eax+12]
  mov dword[esp], eax
  call LL
  mov ecx, dword[ebp+8]
  mov dword[ecx+12], eax
  mov dword[esp], ecx
  call RR
  mov esp, ebp
  pop ebp
  ret

RL:
  push ebp
  mov ebp, esp
  sub esp, 8
  mov eax, dword[ebp+8]
  mov eax, dword[eax+16]
  mov dword[esp], eax
  call RR
  mov ecx, dword[ebp+8]
  mov dword[ecx+16], eax
  mov dword[esp], ecx
  call LL
  mov esp, ebp
  pop ebp
  ret