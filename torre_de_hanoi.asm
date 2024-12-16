section .data
    ; MENSAGEM DE INPUT E FINALIZAÇÃO
    mensagem_algoritmo db 'Digite um número (inteiro) para ativar o algoritmo da torre de Hanoi...', 0xa; Mensagem solicitando o número de discos
    tam_msg_algoritmo equ $ - mensagem_algoritmo ; Comprimento da mensagem de entrada do usuário
    final db 'TORRE DE HANOI CONCLUIDA!!!', 0xa, 0
    len_f equ $ - final
   
    ; DECLARAÇÃO DAS 3 TORRES
    t_inicial db 'A', 10, 0; Nome da torre inicial
    t_aux db 'B', 10, 0; Nome da torre auxiliar
    t_final db 'C', 10, 0  ; Nome da torre final
   
   
    ; LINHA E MENSAGEM DA QUANTIDADE DE DISCOS INSERIDOS PELO USER
    line db '-----------------------------------------', 10, 0
    len_line equ $ - line
    Iniciando db 'Iniciando TORRE DE HANOI com '
    len_iniciando equ $ - Iniciando
    discos db ' discos...', 10, 0
    len_d equ $ - discos
   
    ; MENSAGENS DE MOVIMENTO, ORIGEM E DESTINO DOS DISCOS
    movimento_1 db ' Disco ', 0  ; Mensagem sobre movimentação do disco
    len_mov1 equ $ - movimento_1
    movimento_2 db ' da Torre ' ; Complemento da mensagem de movimentação
    len_mov2 equ $ - movimento_2
    movimento_3 db ' para a Torre ', 0  ; Complemento da mensagem de movimentação
    len_mov3 equ $ - movimento_3
   
    tam_num_to EQU 3  ; Espaço reservado para até 3 caracteres de entrada e das torres

section .bss
    entradaUsuario resb tam_num_to  ; Reserva espaço para a entrada do usuário (máximo de 3 bytes)
    numero_de_discos resw 1    ; Reserva 3 bytes para armazenar o número de discos
    buffer resb 16; Reserva espaço para armazenar a string de saída (número convertido)

section .text
    global _start  ; Declaração do ponto de entrada do programa

_start:
    ; Exibindo a mensagem solicitando o número de discos
    mov ecx, mensagem_algoritmo     ; Carrega o endereço da mensagem de entrada em ECX
    mov edx, tam_msg_algoritmo     ; Carrega o comprimento da mensagem em EDX
    call funcao_print     ; Chama a sub-rotina para exibir a mensagem
   
   
    call funcaoRead        ; Chama a sub-rotina para ler a entrada do usuário
    call string_para_inteiro  ; Converte a entrada de string para inteiro
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call funcao_print
   
    ; Exibe mensagem de inicio do algoritmo
    mov ecx, Iniciando
    mov edx, len_iniciando
    call funcao_print
    call print_numero_discos           ; Exibe o número de discos
   
    ; Exibe com quantos discos o programa será executado
    mov ecx, discos
    mov edx, len_d
    call funcao_print
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call funcao_print
   
    call torre_de_hanoi ; Chamada para inicio da TORRE DE HANOI
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call funcao_print
   
    mov ecx, final
    mov edx, len_f
    call funcao_print
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call funcao_print
   
    ; Finalizando o programa
    mov eax, 1                ; Código de saída (sys_exit)
    xor ebx, ebx              ; Código de status 0
    int 0x80                  ; Realiza a chamada de sistema para finalizar

funcao_print:  
    ; Sub-rotina para exibir uma mensagem na saída padrão
    ; ECX: Endereço da mensagem
    ; EDX: Comprimento da mensagem
    mov eax, 4                ; Código de chamada (sys_write)
    mov ebx, 1                ; Saída padrão (stdout)
    int 0x80                  ; Chamada de sistema para exibir a mensagem
    ret                       ; Retorna para a chamada anterior
 
funcaoRead:
    ; Lê o número digitado pelo usuário
    mov eax, 3                ; Código de chamada (sys_read)
    mov ebx, 0                ; Entrada padrão (stdin)
    mov ecx, entradaUsuario       ; Endereço para armazenar a entrada
    mov edx, tam_num_to         ; Tamanho máximo da entrada
    int 0x80                  ; Chamada de sistema para ler a entrada
    ret

print_numero_discos:
    ; Exibe o número de discos
    movzx eax, word [numero_de_discos]  ; Acessa numero_de_discos
    lea edi, [buffer + 4]            ; Endereço do buffer para armazenar a string
    call loop_str_int               ; Converte o número para string
   
    mov eax, 4                      ; Chamada para sys_write
    mov ebx, 1                      ; Saída padrão (stdout)
    lea ecx, [edi]                  ; Endereço do número convertido
    lea edx, [buffer + 4]           ; Carrega o final do buffer
    sub edx, ecx                    ; Calcula o comprimento da string
    int 0x80                        ; Chamada de sistema para exibir o número de discos
    ret

string_para_inteiro:
    ; Converte a string de entrada para inteiro
    xor eax, eax                   ; Zera o registrador EAX (acumulador)
    xor ecx, ecx                   ; Zera o índice ECX

loop_conversao:
    movzx edx, byte [entradaUsuario + ecx] ; Carrega o próximo caractere da string
    cmp edx, 0x0A                    ; Verifica se é o caractere de nova linha (Enter)
    je finalizar_conversao               ; Se for Enter, finaliza a conversão
    sub edx, '0'                     ; Converte o caractere ASCII para valor numérico
    imul eax, eax, 10                ; Multiplica o acumulador (EAX) por 10
    add eax, edx                     ; Adiciona o valor do dígito atual
    inc ecx                          ; Avança para o próximo caractere
    jmp loop_conversao                 ; Repete o loop para o próximo dígito

finalizar_conversao:
    mov [numero_de_discos], eax         ; Armazena o número resultante em numero_de_discos
    ret                              ; Retorna para a chamada anterior
   
inteiro_para_string:
    xor ebx, ebx                    ; Zera o registrador EBX (para multiplicação)
   
dois_digitos:
    cmp byte[esi], 0x0a              ; Verifica se o caractere é a nova linha
    je um_digito                     ; Se for nova linha, finaliza
    movzx eax, byte [esi]            ; Carrega o caractere atual
    inc esi                          ; Avança para o próximo caractere
    sub al, '0'                      ; Converte o caractere para valor numérico
    imul ebx, 0xa                    ; Multiplica o acumulador por 10
    jmp dois_digitos                 ; Repete o processo

um_digito:
    ret                              ; Retorna da função
   
loop_str_int:
    dec edi                          ; Decrementa o ponteiro para o buffer
    xor edx, edx                     ; Zera o registrador EDX (rest)
    mov ecx, 10                      ; Define a base 10
    div ecx                          ; Realiza a divisão
    add dl, '0'                      ; Converte o resto para caractere ASCII
    mov [edi], dl                    ; Armazena o caractere no buffer
    test eax, eax                    ; Verifica se o número é zero
    jnz loop_str_int                 ; Se não for zero, repete o loop
    ret                              ; Retorna da função
   
; Algoritmo para resolver o problema da Torre de Hanói em Assembly
; As variáveis e chamadas são descritas em detalhe para facilitar o entendimento.

torre_de_hanoi:
    cmp word [numero_de_discos], 1          ; Compara o valor em [numero_de_discos] com 1 para verificar se é o caso base (apenas um disco).
    je caso_b                            ; Se [numero_de_discos] == 1, pula para o caso base (caso_b).
    jmp recursao                         ; Caso contrário, pula para a lógica recursiva (recursao).

caso_b:
    mov ecx, movimento_1                ; Carrega a mensagem "Movendo o disco" no registrador ECX.
    mov edx, len_mov1                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Chama a função para exibir a mensagem.

    call print_numero_discos                     ; Chama a função para imprimir o estado atual do disco.

    mov ecx, movimento_2                ; Carrega a mensagem "da torre" no registrador ECX.
    mov edx, len_mov2                  ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a mensagem.

    mov ecx, t_inicial              ; Carrega a torre inicial no registrador ECx.
    mov edx, tam_num_to              ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a torre inicial.

    mov ecx, movimento_3                ; Carrega a mensagem "para a torre" no registrador ECX.
    mov edx, len_mov3                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a mensagem.

    mov ecx, t_final                ; Carrega a torre final no registrador ECX.
    mov edx, tam_num_to                     ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a torre final.

    jmp fim_hanoi                      ; Pula para a conclusão do algoritmo.

recursao:
    dec byte [numero_de_discos]            ; Decrementa o número de discos para a chamada recursiva.
    push word [numero_de_discos]           ; Empilha o valor atual de [numero_de_discos] na pilha.

    push word [t_inicial]           ; Empilha a torre inicial na pilha.
    push word [t_aux]          ; Empilha a torre auxiliar na pilha.
    push word [t_final]             ; Empilha a torre final na pilha.

    mov dx, [t_aux]            ; Move o valor de t_aux para DX.
    mov cx, [t_final]               ; Move o valor de t_final para CX.
    mov [t_final], dx               ; Atualiza t_final com o valor de DX (t_aux).
    mov [t_aux], cx            ; Atualiza t_aux com o valor de CX (t_final).

    call torre_de_hanoi                 ; Chama recursivamente o algoritmo para resolver a sub-torre.

    pop word [t_final]              ; Restaura o valor original de t_final da pilha.
    pop word [t_aux]           ; Restaura o valor original de t_aux da pilha.
    pop word [t_inicial]            ; Restaura o valor original de t_inicial da pilha.

    pop word [numero_de_discos]            ; Restaura o valor original de [numero_de_discos] da pilha.

    mov ecx, movimento_1                ; Carrega a mensagem "Movendo o disco" no registrador ECX.
    mov edx, len_mov1                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a mensagem.

    inc byte [numero_de_discos]            ; Incrementa o número de discos antes de imprimir.
    call print_numero_discos                     ; Chama a função para imprimir o estado atual do disco.
    dec byte [numero_de_discos]            ; Decrementa novamente para manter a consistência.

    mov ecx, movimento_2                ; Carrega a mensagem "da torre" no registrador ECX.
    mov edx, len_mov2                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a mensagem.

    mov ecx, t_inicial              ; Carrega a torre inicial no registrador ECX.
    mov edx, tam_num_to                     ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a torre inicial.

    mov ecx, movimento_3                ; Carrega a mensagem "para a torre" no registrador ECX.
    mov edx, len_mov3                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a mensagem.

    mov ecx, t_final                ; Carrega a torre final no registrador ECX.
    mov edx, tam_num_to                   ; Carrega o comprimento da mensagem em EDX.
    call funcao_print               ; Exibe a torre final.

    mov dx, [t_aux]            ; Move o valor de t_aux para DX.
    mov cx, [t_inicial]             ; Move o valor de t_inicial para CX.
    mov [t_inicial], dx             ; Atualiza t_inicial com o valor de DX (Torre_auxilia).
    mov [t_aux], cx            ; Atualiza t_aux com o valor de CX (t_inicial).

    call torre_de_hanoi                 ; Chama recursivamente o algoritmo para resolver a sub-torre.

fim_hanoi:
    ret                                 ; Retorna da função, indicando que o algoritmo foi concluído.