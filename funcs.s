.text

.global drawText
.global drawButton

.bss
    rect: .space 16
    charSize: .space 4
    color: .space 4

.text

drawText:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    pushq %rbp
    movq %rsp, %rbp

    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8

    cmpq $0, %rsi
    je firstCond
    cmpq $2, %rsi
    je firstCond
    cmpq $3, %rsi
    je firstCond
    cmpq $1, %rsi
    je secondCond

    jmp condEnd

firstCond:
    movl (g_width), %ecx
    movl %ecx, (charSize)
    movl (charSize), %eax
    movl $10, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, (charSize)

    cmpq $2, %rsi
    jne fcmbret
firstCondMul:
    movl (charSize), %eax
    movl $2, %ecx
    mul %ecx
    movl %eax, (charSize)
    jmp fcmbret
fcmbret:

    movq -8(%rbp), %rdi
    call strlen
    movl %eax, %r12d

    drawTextLoop:
    movl (charSize), %eax
    movl $4, %ecx
    mul %ecx
    movl $5, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, (charSize)

    # r13 is rectangle x for now
    movl (g_width), %eax
    movq $0, %rdx
    movl $2, %ecx
    div %ecx
    movl %eax, %r13d

    movl (charSize), %eax
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    mul %r12d
    sub %eax, %r13d

    cmp $0, %r13d
    jle drawTextLoop
    movq $rect, %rbx
    movl %r13d, (%rbx)
drawTextLoopEnd:
    
    movq -16(%rbp), %rsi
    
    cmpq $0, %rsi
    je fcInsideIf1
    cmpq $2, %rsi
    je fcInsideIf2
    cmpq $3, %rsi
    je fcInsideIf3
    jmp fcInsideIfEnd

fcInsideIf1:
    movl (g_height), %eax
    movl $4, %ecx
    movl $0, %edx
    div %ecx
    movq $rect, %rbx
    movl %eax, 4(%rbx)
    jmp fcInsideIfEnd

fcInsideIf2:
    movl (g_height), %eax
    movl $9, %ecx
    div %ecx
    movl $0, %edx
    movl $2, %ecx
    mul %ecx
    movq $rect, %rbx
    movl %eax, 4(%rbx)
    jmp fcInsideIfEnd

fcInsideIf3:
    movl (g_height), %eax
    movl $11, %ecx
    movl $0, %edx
    div %ecx
    movq $rect, %rbx
    movl %eax, 4(%rbx)
    jmp fcInsideIfEnd

fcInsideIfEnd:
    movl (charSize), %eax
    movl %r12d, %ecx
    mul %ecx
    movq $rect, %rbx
    movl %eax, 8(%rbx)
    
    movl (charSize), %eax
    movl %eax, 12(%rbx)
    jmp condEnd

secondCond:
    movl (g_width), %eax
    movl $0, %edx
    movl $10, %ecx
    div %ecx
    movl %eax, (charSize)
    
    call strlen
    movl %eax, %r12d

    movl (g_width), %eax
    movl $0, %edx
    movl $16, %ecx
    div %ecx
    movl %eax, (rect)
    
    movl (g_height), %eax
    movl $0, %edx
    movl $16, %ecx
    div %ecx
    movq $rect, %rbx
    movl %eax, 4(%rbx)

    movl (charSize), %eax
    movl %r12d, %ecx
    mul %ecx
    movl %eax, 8(%rbx)
    
    movl (charSize), %eax
    movl %eax, 12(%rbx)

    jmp condEnd

condEnd:
    movq $color, %rbx
    movq -8(%rbp), %r12
    movq -16(%rbp), %r13

    movq -24(%rbp), %rdi
    movq -32(%rbp), %rsi
    movq -40(%rbp), %rdx
    call makeSDLColor

    movq Sans, %rdi
    movq %r12, %rsi
    movq %rax, %rdx
    call TTF_RenderText_Solid
    movq %rax, %r14

    call getRenderer
    movq %rax, %rdi
    movq %r14, %rsi
    call SDL_CreateTextureFromSurface
    movq %rax, %r15

    call getRenderer
    movq %rax, %rdi
    movq %r15, %rsi
    movq $0, %rdx
    movq $rect, %rcx
    call SDL_RenderCopy

    movq %r14, %rdi
    call SDL_FreeSurface
    movq %r15, %rdi
    call SDL_DestroyTexture

    # epilogue
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi

    movq %rbp, %rsp
    popq %rbp

    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    ret


drawButton:
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    
    pushq %rbp
    movq %rsp, %rbp

    pushq %rdi
    pushq %rsi
    pushq %rdx
    pushq %rcx
    pushq %r8

    movq $rect, %rbx

    # 4(rect) = g_width / 4
    movl (g_width), %eax
    movl $0, %edx
    movl $4, %ecx
    div %ecx
    movl %eax, (%rbx)

    # 8(%rbx) = rsi * g_height / 8
    movl (g_height), %eax
    movl $0, %edx
    movl $8, %ecx
    div %ecx
    mul %rsi
    movl %eax, 4(%rbx)

    # 12(%rbx) = g_width / 2
    movl (g_width), %eax
    movl $0, %edx
    movl $2, %ecx
    div %ecx
    movl %eax, 8(%rbx)

    # 16(%rbx) = g_height / 7
    movl (g_height), %eax
    movl $0, %edx
    movl $7, %ecx
    div %ecx
    movl %eax, 12(%rbx)

    call getRenderer
    movq %rax, %r12
    call getGAlpha
    
    movq %rax, %r8
    movq %r12, %rdi
    movq -24(%rbp), %rsi
    movq -32(%rbp), %rdx
    movq -40(%rbp), %rcx
    call SDL_SetRenderDrawColor

    movq %r12, %rdi
    movq $rect, %rsi
    call SDL_RenderFillRect

    # r14 = g_width / 98
    movl (g_width), %eax
    movl $0, %edx
    movl $98, %ecx
    div %ecx
    movl %eax, %r14d

    movl %r14d, %eax
    movl $2, %ecx
    mul %ecx
    movq $rect, %rbx
    subl %eax, 8(%rbx)
    subl %eax, 12(%rbx)
    addl %r14d, (%rbx)
    addl %r14d, 4(%rbx)

    # color averaging
    movl -24(%rbp), %eax
    addl $128, %eax
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -24(%rbp)

    movl -32(%rbp), %eax
    addl $128, %eax
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -32(%rbp)

    movl -40(%rbp), %eax
    addl $128, %eax
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -40(%rbp)

    movq $0, %r15   # r15 is hovered, aka return value

    # huge condition
    movl (g_mouse_x), %eax
    cmpl %eax, (%rbx)
    jg notHovered
    movl (g_mouse_y), %eax
    cmpl %eax, 4(%rbx)
    jg notHovered
    movq (%rbx), %rax
    addq 8(%rbx), %rax
    cmpl (g_mouse_x), %eax
    jl notHovered
    movq 4(%rbx), %rax
    addq 12(%rbx), %rax
    cmpl (g_mouse_y), %eax
    jl notHovered

    # we are here, so hovered, transform colors
    # r = r * 2 / 3
    movl -24(%rbp), %eax
    movl $2, %ecx
    movl $0, %edx
    mul %ecx
    movl $3, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -24(%rbp)

    # g = g * 2 / 3
    movl -32(%rbp), %eax
    movl $2, %ecx
    movl $0, %edx
    mul %ecx
    movl $3, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -32(%rbp)

    # b = b * 2 / 3
    movl -40(%rbp), %eax
    movl $2, %ecx
    movl $0, %edx
    mul %ecx
    movl $3, %ecx
    movl $0, %edx
    div %ecx
    movl %eax, -40(%rbp)

    movq $1, %r15

notHovered:
    # SDL_SetRenderDrawColor
    call getRenderer
    movq %rax, %r12

    call getGAlpha
    movq %rax, %r8
    movq %r12, %rdi
    movq -24(%rbp), %rsi
    movq -32(%rbp), %rdx
    movq -40(%rbp), %rcx
    call SDL_SetRenderDrawColor

    # SDL_RenderFillRect
    movq %r12, %rdi
    movq $rect, %rsi
    call SDL_RenderFillRect

    # color
    movl $255, %edi
    subl -24(%rbp), %edi
    movl $255, %esi
    subl -32(%rbp), %esi
    movl $255, %edx
    subl -40(%rbp), %edx
    call makeSDLColor

    # TTF_RenderText_Solid
    movq Sans, %rdi
    movq -8(%rbp), %rsi
    movq %rax, %rdx
    call TTF_RenderText_Solid
    pushq %rax
    pushq %rax

    # SDL_CreateTextureFromSurface
    call getRenderer
    movq %rax, %r12
    movq %r12, %rdi
    popq %rax
    pushq %rax
    movq %rax, %rsi
    call SDL_CreateTextureFromSurface
    pushq %rax
    pushq %rax

    # SDL_SetTextureAlphaMod
    call getGAlpha
    movq %rax, %rsi
    popq %rdi
    pushq %rdi
    call SDL_SetTextureAlphaMod

    # r14 = g_width / 58
    movl (g_width), %eax
    movl $0, %edx
    movl $58, %ecx
    div %ecx
    movl %eax, %r14d

    # (%rbx) = (%rbx) - r14 * 2
    movl %r14d, %eax
    movl $2, %ecx
    mul %ecx
    subl %eax, 8(%rbx)
    subl %eax, 12(%rbx)
    addl %r14d, (%rbx)
    addl %r14d, 4(%rbx)
    
    # SDL_RenderCopy
    movq %r12, %rdi
    popq %rsi
    pushq %rsi
    movq $0, %rdx
    movq $rect, %rcx
    call SDL_RenderCopy

    # SDL_DestroyTexture
    popq %rdi
    popq %rdi
    call SDL_DestroyTexture

    # SDL_FreeSurface
    popq %rdi
    popq %rdi
    call SDL_FreeSurface

    movq %r15, %rax

    # epilogue
    
    popq %r8
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rdi

    movq %rbp, %rsp
    popq %rbp

    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    ret
