/* vim: set filetype=gas : */

.text
str_1: .asciz "Your score:"
percent_d: .asciz "%d"
str_restart: .asciz "Restart"
str_menu: .asciz "Menu"

.bss
    t_buffer: .skip 30

.text

.global drawScore

drawScore:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %r15

    call drawGame
    
    call getState
    cmpl $0, %eax # If state == transition -> line 14 skip
    jne dsFirstIfDo

    call getGPost
    cmpl $2, %eax # If gPost == gameplay -> line 14 skip
    jne dsFirstIfDo

    jmp dsFirstIfDone
dsFirstIfDo:
    # set the g_prev_score
    call getGCurrentScore
    movl %eax, %edi
    call setGPrevScore

dsFirstIfDone:
    
    # max
    call getGBestScore
    movl %eax, %r12d
    call getGPrevScore
    movl %eax, %r13d
    movl %r13d, %edi
    cmpl %r12d, %r13d
    cmovl %r12d, %edi
    call setGBestScore

    # SDL Setup
    call getRenderer
    mov %rax, %rdi
    mov %rax, %r12
    mov $1, %rsi
    call SDL_SetRenderDrawBlendMode
    
    call getGAlpha
    movq $0, %rdx
    movq $190, %r10
    mul %r10
    movq $256, %rcx
    div %rcx
    mov %rax, %r9
    
    mov %r12, %rdi
    mov $160, %rsi
    mov $160, %rdx
    mov $180, %rcx
    movq $180, %r8
    call SDL_SetRenderDrawColor

    call getGScreen
    mov %rax, %rsi
    mov %r12, %rdi
    call SDL_RenderFillRect

# text stuff

    movq $str_1, %rdi
    movq $3, %rsi
    movq $100, %rdx
    movq $100, %rcx
    movq $220, %r8
    call drawText
    
    call getGPrevScore
    movq $t_buffer, %rdi
    movq $percent_d, %rsi
    movq %rax, %rdx
    call sprintf

    movq $t_buffer, %rdi
    movq $2, %rsi
    movq $100, %rdx
    movq $100, %rcx
    movq $220, %r8
    call drawText

    movq $str_restart, %rdi
    movq $4, %rsi
    movq $30, %rdx
    movq $200, %rcx
    movq $120, %r8
    call drawButton
    
    mov $0, %r15

    cmp $1, %rax
    jne ordsskip
    call oneRetDrawScore
ordsskip:

    movq $str_menu, %rdi
    movq $6, %rsi
    movq $125, %rdx
    movq $0, %rcx
    movq $70, %r8
    call drawButton

    cmp $1, %rax
    jne trdsskip
    call twoRetDrawScore
trdsskip:

    movq %r15, %rax
    jmp drawScoreEnd

oneRetDrawScore:
    call getGClick
    cmp $1, %eax
    jne sk_1b
    mov $1, %r15
    sk_1b:
    ret

twoRetDrawScore:
    call getGClick
    cmp $1, %eax
    jne sk_1a
    mov $2, %r15
    sk_1a:
    ret

drawScoreEnd:
    popq %r15
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    movq %rbp, %rsp
    popq %rbp
    ret
    
