
.data

drawTransitionState:
        .quad  255

.text
    .global setupTransition
    .global drawTransition

setupTransition:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq %rbx
    pushq %r12

    movq $0, (drawTransitionState)

    call getGPost
    movq %rax, %r12
    cmpq $2, %r12
    je stFirstIf # gameplay
    cmpq $3, %r12
    je stSecondIf # score
    cmpq $1, %r12
    je stThirdIf # menu

stFirstIf:
    movq $0, %rdi
    call setGStaticRender
    movq $1, %rdi
    call setGPlayable
    call initGame
    jmp stIfsEnd

stSecondIf:
    movq $1, %rdi
    call setGStaticRender
    movq $0, %rdi
    call setGPlayable
    jmp stIfsEnd

stThirdIf:
    movq $0, %rdi
    call setGStaticRender
    movq $0, %rdi
    call setGPlayable
    call initGame
    jmp stIfsEnd

stIfsEnd:
    popq %r12
    popq %rbx
    movq %rbp, %rsp
    popq %rbp

    ret

drawTransition:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12

    movq %rdi, %r12
    movq %rsi, %rbx

    addq $7, (drawTransitionState)

    cmpq $255, (drawTransitionState)
    jl asdfjkl
    movq $255, (drawTransitionState)
    asdfjkl:

    movq $255, %rdi
    call setGAlpha

choosePre:
    cmpq $2, %r12
    je choosePreFirst # gameplay
    cmpq $3, %r12
    je choosePreSecond # score
    cmpq $1, %r12
    je choosePreThird # menu

choosePreFirst:
    call drawGame
    jmp choosePreEnd

choosePreSecond:
    call drawScore
    jmp choosePreEnd

choosePreThird:
    call drawMenu
    jmp choosePreEnd

choosePreEnd:
    
    movq (drawTransitionState), %rdi
    call setGAlpha

choosePost:
    cmpq $2, %rbx
    je choosePostFirst # gameplay
    cmpq $3, %rbx
    je choosePostSecond # score
    cmpq $1, %rbx
    je choosePostThird # menu

choosePostFirst:
    call drawGame
    jmp choosePostEnd

choosePostSecond:
    call drawScore
    jmp choosePostEnd

choosePostThird:
    call drawMenu
    jmp choosePostEnd

choosePostEnd:
    movq $0, %rax
    cmpq $255, (drawTransitionState)
    jl asdfjkl2
    movq $1, %rax
    asdfjkl2:

    popq %r12
    popq %rbx
    movq %rbp, %rsp
    popq %rbp
    ret
