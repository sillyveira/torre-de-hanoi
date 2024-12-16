section .data
    ; MENSAGEM DE INPUT E FINALIZAÇÃO
    msg_for_user db 'Digite um número (inteiro) de 1 a 99 para ativar o algoritmo da torre...', 0xa; Mensagem solicitando o número de discos
    len_msg_user equ $ - msg_for_user ; Comprimento da mensagem de entrada do usuário
    final db 'TORRE DE HANOI CONCLUIDA!!!', 0xa, 0
    len_f equ $ - final
   
    ; DECLARAÇÃO DAS 3 TORRES
    Torre_inicial db 'A', 10, 0; Nome da torre inicial
    Torre_auxiliar db 'B', 10, 0; Nome da torre auxiliar
    Torre_final db 'C', 10, 0  ; Nome da torre final
   
   
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
    input_user resb tam_num_to  ; Reserva espaço para a entrada do usuário (máximo de 3 bytes)
    number_discos resw 1    ; Reserva 3 bytes para armazenar o número de discos
    buffer resb 16; Reserva espaço para armazenar a string de saída (número convertido)

section .text
    global _start  ; Declaração do ponto de entrada do programa

_start:
    ; Exibindo a mensagem solicitando o número de discos
    mov ecx, msg_for_user     ; Carrega o endereço da mensagem de entrada em ECX
    mov edx, len_msg_user     ; Carrega o comprimento da mensagem em EDX
    call mensage_bv_input     ; Chama a sub-rotina para exibir a mensagem
   
   
    call leitura_input        ; Chama a sub-rotina para ler a entrada do usuário
    call process_convert_str_int  ; Converte a entrada de string para inteiro
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call mensage_bv_input
   
    ; Exibe mensagem de inicio do algoritmo
    mov ecx, Iniciando
    mov edx, len_iniciando
    call mensage_bv_input
    call print_disc           ; Exibe o número de discos
   
    ; Exibe com quantos discos o programa será executado
    mov ecx, discos
    mov edx, len_d
    call mensage_bv_input
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call mensage_bv_input
   
    call algoritm_tower ; Chamada para inicio da TORRE DE HANOI
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call mensage_bv_input
   
    mov ecx, final
    mov edx, len_f
    call mensage_bv_input
   
    ; Exibindo linha
    mov ecx, line
    mov edx, len_line
    call mensage_bv_input
   
    ; Finalizando o programa
    mov eax, 1                ; Código de saída (sys_exit)
    xor ebx, ebx              ; Código de status 0
    int 0x80                  ; Realiza a chamada de sistema para finalizar

mensage_bv_input:  
    ; Sub-rotina para exibir uma mensagem na saída padrão
    ; ECX: Endereço da mensagem
    ; EDX: Comprimento da mensagem
    mov eax, 4                ; Código de chamada (sys_write)
    mov ebx, 1                ; Saída padrão (stdout)
    int 0x80                  ; Chamada de sistema para exibir a mensagem
    ret                       ; Retorna para a chamada anterior
 
leitura_input:
    ; Lê o número digitado pelo usuário
    mov eax, 3                ; Código de chamada (sys_read)
    mov ebx, 0                ; Entrada padrão (stdin)
    mov ecx, input_user       ; Endereço para armazenar a entrada
    mov edx, tam_num_to         ; Tamanho máximo da entrada
    int 0x80                  ; Chamada de sistema para ler a entrada
    ret

print_disc:
    ; Exibe o número de discos
    movzx eax, word [number_discos]  ; Acessa number_discos
    lea edi, [buffer + 4]            ; Endereço do buffer para armazenar a string
    call loop_str_int               ; Converte o número para string
   
    mov eax, 4                      ; Chamada para sys_write
    mov ebx, 1                      ; Saída padrão (stdout)
    lea ecx, [edi]                  ; Endereço do número convertido
    lea edx, [buffer + 4]           ; Carrega o final do buffer
    sub edx, ecx                    ; Calcula o comprimento da string
    int 0x80                        ; Chamada de sistema para exibir o número de discos
    ret

process_convert_str_int:
    ; Converte a string de entrada para inteiro
    xor eax, eax                   ; Zera o registrador EAX (acumulador)
    xor ecx, ecx                   ; Zera o índice ECX

convert_loop:
    movzx edx, byte [input_user + ecx] ; Carrega o próximo caractere da string
    cmp edx, 0x0A                    ; Verifica se é o caractere de nova linha (Enter)
    je done_conversion               ; Se for Enter, finaliza a conversão
    sub edx, '0'                     ; Converte o caractere ASCII para valor numérico
    imul eax, eax, 10                ; Multiplica o acumulador (EAX) por 10
    add eax, edx                     ; Adiciona o valor do dígito atual
    inc ecx                          ; Avança para o próximo caractere
    jmp convert_loop                 ; Repete o loop para o próximo dígito

done_conversion:
    mov [number_discos], eax         ; Armazena o número resultante em number_discos
    ret                              ; Retorna para a chamada anterior
   
process_int_string:
    xor ebx, ebx                    ; Zera o registrador EBX (para multiplicaçã)
   
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

algoritm_tower:
    cmp word [number_discos], 1          ; Compara o valor em [number_discos] com 1 para verificar se é o caso base (apenas um disco).
    je caso_b                            ; Se [number_discos] == 1, pula para o caso base (caso_b).
    jmp recursao                         ; Caso contrário, pula para a lógica recursiva (recursao).

caso_b:
    mov ecx, movimento_1                ; Carrega a mensagem "Movendo o disco" no registrador ECX.
    mov edx, len_mov1                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Chama a função para exibir a mensagem.

    call print_disc                     ; Chama a função para imprimir o estado atual do disco.

    mov ecx, movimento_2                ; Carrega a mensagem "da torre" no registrador ECX.
    mov edx, len_mov2                  ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a mensagem.

    mov ecx, Torre_inicial              ; Carrega a torre inicial no registrador ECx.
    mov edx, tam_num_to              ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a torre inicial.

    mov ecx, movimento_3                ; Carrega a mensagem "para a torre" no registrador ECX.
    mov edx, len_mov3                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a mensagem.

    mov ecx, Torre_final                ; Carrega a torre final no registrador ECX.
    mov edx, tam_num_to                     ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a torre final.

    jmp done_tower                      ; Pula para a conclusão do algoritmo.

recursao:
    dec byte [number_discos]            ; Decrementa o número de discos para a chamada recursiva.
    push word [number_discos]           ; Empilha o valor atual de [number_discos] na pilha.

    push word [Torre_inicial]           ; Empilha a torre inicial na pilha.
    push word [Torre_auxiliar]          ; Empilha a torre auxiliar na pilha.
    push word [Torre_final]             ; Empilha a torre final na pilha.

    mov dx, [Torre_auxiliar]            ; Move o valor de Torre_auxiliar para DX.
    mov cx, [Torre_final]               ; Move o valor de Torre_final para CX.
    mov [Torre_final], dx               ; Atualiza Torre_final com o valor de DX (Torre_auxiliar).
    mov [Torre_auxiliar], cx            ; Atualiza Torre_auxiliar com o valor de CX (Torre_final).

    call algoritm_tower                 ; Chama recursivamente o algoritmo para resolver a sub-torre.

    pop word [Torre_final]              ; Restaura o valor original de Torre_final da pilha.
    pop word [Torre_auxiliar]           ; Restaura o valor original de Torre_auxiliar da pilha.
    pop word [Torre_inicial]            ; Restaura o valor original de Torre_inicial da pilha.

    pop word [number_discos]            ; Restaura o valor original de [number_discos] da pilha.

    mov ecx, movimento_1                ; Carrega a mensagem "Movendo o disco" no registrador ECX.
    mov edx, len_mov1                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a mensagem.

    inc byte [number_discos]            ; Incrementa o número de discos antes de imprimir.
    call print_disc                     ; Chama a função para imprimir o estado atual do disco.
    dec byte [number_discos]            ; Decrementa novamente para manter a consistência.

    mov ecx, movimento_2                ; Carrega a mensagem "da torre" no registrador ECX.
    mov edx, len_mov2                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a mensagem.

    mov ecx, Torre_inicial              ; Carrega a torre inicial no registrador ECX.
    mov edx, tam_num_to                     ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a torre inicial.

    mov ecx, movimento_3                ; Carrega a mensagem "para a torre" no registrador ECX.
    mov edx, len_mov3                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a mensagem.

    mov ecx, Torre_final                ; Carrega a torre final no registrador ECX.
    mov edx, tam_num_to                   ; Carrega o comprimento da mensagem em EDX.
    call mensage_bv_input               ; Exibe a torre final.

    mov dx, [Torre_auxiliar]            ; Move o valor de Torre_auxiliar para DX.
    mov cx, [Torre_inicial]             ; Move o valor de Torre_inicial para CX.
    mov [Torre_inicial], dx             ; Atualiza Torre_inicial com o valor de DX (Torre_auxilia).
    mov [Torre_auxiliar], cx            ; Atualiza Torre_auxiliar com o valor de CX (Torre_inicial).

    call algoritm_tower                 ; Chama recursivamente o algoritmo para resolver a sub-torre.

done_tower:
    ret                                 ; Retorna da função, indicando que o algoritmo foi concluído.