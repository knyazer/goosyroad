.bss

buf: .skip 30

.text

game_name: .asciz "Goosy Road"
best_score_text: .asciz "Best Score: %d"
play_text: .asciz "Play"
exit_text: .asciz "Exit"

.global drawMenu

drawMenu:
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %r15

    call drawGame

    # SDL_SetRenderDrawBlendMode
    call getRenderer
    movq %rax, %rdi
    movq %rax, %r12
    movl $1, %esi
    call SDL_SetRenderDrawBlendMode

    call getGAlpha
    movl $190, %ecx
    mul %ecx
    movq $0, %rdx
    movl $256, %ecx
    div %ecx
    movl %eax, %r8d

    movq %r12, %rdi
    movl $160, %esi
    movl $160, %edx
    movl $180, %ecx
    call SDL_SetRenderDrawColor

    call getGScreen
    movq %rax, %rsi
    movq %r12, %rdi
    call SDL_RenderFillRect

    call getGBestScore
    cmpq $0, %rax
    jne drawBestScore

    # draw the name of the game
    movq $game_name, %rdi
    movl $0, %esi
    movl $100, %edx
    movl $100, %ecx
    movl $220, %r8d
    call drawText
    jmp firstIfEnd

drawBestScore:
    # draw the best score
    movq $buf, %rdi
    movq $best_score_text, %rsi
    movq %rax, %rdx
    call sprintf

    movq $buf, %rdi
    movl $0, %esi
    movl $100, %edx
    movl $100, %ecx
    movl $220, %r8d
    call drawText

    jmp firstIfEnd

firstIfEnd:
    # store the return value in %r15
    movq $0, %r15

    movq $play_text, %rdi
    movl $4, %esi
    movl $30, %edx
    movl $200, %ecx
    movl $120, %r8d
    call drawButton

    cmpq $1, %rax
    je playButtonHoveredCheck
pbhcEnd:

    movq $exit_text, %rdi
    movl $6, %esi
    movl $125, %edx
    movl $0, %ecx
    movl $70, %r8d
    call drawButton

    cmpq $1, %rax
    je exitButtonHoveredCheck
ebhcEnd:

    jmp endOfDrawMenu

playButtonHoveredCheck:
    call getGClick
    cmpq $1, %rax
    jne pbhcEnd
    movq $2, %r15
    jmp pbhcEnd

exitButtonHoveredCheck:
    call getGClick
    cmpq $1, %rax
    jne ebhcEnd
    movq $1, %r15
    jmp ebhcEnd

endOfDrawMenu:
    movq %r15, %rax

    popq %r15
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    movq %rbp, %rsp
    popq %rbp

    ret



