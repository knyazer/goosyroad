.bss
    event: .skip 4

.data
    forward_lock: .byte 0
    backward_lock: .byte 0
    left_lock: .byte 0
    right_lock: .byte 0

.text

.global updateEvents
.global main

updateEvents:
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %r15

    movb $0, (g_click)
    movb $0, (g_forward)
    movb $0, (g_backward)
    movb $0, (g_left)
    movb $0, (g_right)
    movl $0, (event)
    
updateEventsPolling:

    movq $event, %rdi
    call SDL_PollEvent

    cmpl $0, %eax
    je updateEventsDoneWithFalse
    
    call getSDL_Quit
    cmpl %eax, (event)
    je updateEventsDoneWithTrue
    
    call getSDL_MouseMotion
    cmpl %eax, (event)
    je doMouseMotion
    
    call getSDL_MouseButtonDown
    cmpl %eax, (event)
    je doMouseButtonDown
    
    call getSDL_KeyDown
    cmpl %eax, (event)
    je doKeyDown
    
    call getSDL_KeyUp
    cmpl %eax, (event)
    je doKeyUp

    jmp updateEventsPolling

doMouseMotion:
    movq $event, %rdi
    call getMotionX
    movl %eax, (g_mouse_x)

    movq $event, %rdi
    call getMotionY
    movl %eax, (g_mouse_y)

    jmp updateEventsPolling

doMouseButtonDown:
    movb $1, (g_click)
    jmp updateEventsPolling

doKeyDown:
    # check that event.key.keysym.scabcode is SDL_SCANCODE_W
    movq $event, %rdi
    call getScancode
    movl %eax, %r12d
    
    cmpl $26, %r12d
    je doKeyDownW

    # check that event.key.keysym.scabcode is SDL_SCANCODE_S
    cmpl $22, %r12d
    je doKeyDownS

    # check that event.key.keysym.scabcode is SDL_SCANCODE_A
    cmpl $4, %r12d
    je doKeyDownD

    # check that event.key.keysym.scabcode is SDL_SCANCODE_D
    cmpl $7, %r12d
    je doKeyDownA
dkdd:
dkds:
dkdw:
dkda:

    jmp updateEventsPolling

doKeyDownW:
    cmpb $0, (forward_lock)
    jne dkdw

    movb $1, (g_forward)
    movb $1, (forward_lock)
    jmp dkdw

doKeyDownS:
    cmpb $0, (backward_lock)
    jne dkds

    movb $1, (g_backward)
    movb $1, (backward_lock)
    jmp dkds

doKeyDownA:
    cmpb $0, (left_lock)
    jne dkda

    movb $1, (g_left)
    movb $1, (left_lock)
    jmp dkda

doKeyDownD:
    cmpb $0, (right_lock)
    jne dkdd

    movb $1, (g_right)
    movb $1, (right_lock)
    jmp dkdd

doKeyUp:
    # check that event.key.keysym.scabcode is SDL_SCANCODE_W
    movl $event, %edi
    call getScancode
    movl %eax, %r12d

    cmpl $26, %r12d
    je doKeyUpW
dkuw:

    # check that event.key.keysym.scabcode is SDL_SCANCODE_S
    cmpl $22, %r12d
    je doKeyUpS
dkus:

    # check that event.key.keysym.scabcode is SDL_SCANCODE_A
    cmpl $4, %r12d
    je doKeyUpD
dkud:

    # check that event.key.keysym.scabcode is SDL_SCANCODE_D
    cmpl $7, %r12d
    je doKeyUpA
dkua:

    jmp updateEventsPolling

doKeyUpW:
    movb $0, (forward_lock)
    jmp dkuw

doKeyUpS:
    movb $0, (backward_lock)
    jmp dkus

doKeyUpA:
    movb $0, (left_lock)
    jmp dkua

doKeyUpD:
    movb $0, (right_lock)
    jmp dkud

updateEventsDoneWithFalse:
    movq $0, %rax
    jmp updateEventsDone

updateEventsDoneWithTrue:
    movq $1, %rax
    jmp updateEventsDone

updateEventsDone:
    popq %r15
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    
    movq %rbp, %rsp
    popq %rbp
    ret

.bss
    win: .skip 8
.data
    asdfasdfasdf: .quad 0
    quit: .byte 0
    kljsdljk: .quad 0

.text
    fontpath: .asciz "pixelfont.ttf"
    gamename: .asciz "Goosy Road"
main:
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %r15
    
    movq $g_screen, %rdi
    movq $0, (%rdi)
    movl (g_width), %eax
    movl %eax, 8(%rdi)
    movl (g_height), %eax
    movl %eax, 12(%rdi)

    movq $62001, %rdi
    call SDL_Init

    call TTF_Init
    
    movq $2, %rdi
    call IMG_Init
    
    movq $fontpath, %rdi
    movq $32, %rsi
    call TTF_OpenFont
    movq %rax, (Sans)

    movq $gamename, %rdi
    movq $805240832, %rsi
    movq $805240832, %rdx
    movq (g_width), %rcx
    movq (g_height), %r8
    movq $0, %r9
    call SDL_CreateWindow
    movq %rax, (win)

    movq %rax, %rdi
    call createRenderer

    call firstInitOfGame

    movl $1, (state)
    movb $0, (quit)
mainLoop:
    cmpb $0, quit
    jnz mainDone

    call getRenderer
    movq %rax, %rdi
    movq $0, %rsi
    movq $0, %rdx
    movq $80, %rcx
    movq $255, %r8
    call SDL_SetRenderDrawColor
    
    call getRenderer
    movq %rax, %rdi
    call SDL_RenderClear

    call updateEvents
    cmpq $1, %rax
    jne quitSetSkip
    movb $1, (quit)
quitSetSkip:
    
    movq $0, %rax
    movl (state), %eax

    cmp $0, %eax
    je transitionIf
    cmp $1, %eax
    je menuIf
    cmp $2, %eax
    je gameplayIf
    cmp $3, %eax
    je scoreIf
    
mainLoopIfDone:
    call getRenderer
    movq %rax, %rdi
    call SDL_RenderPresent

    movq $8, %rdi
    call SDL_Delay

    jmp mainLoop

mainDone:
    movq $0, %rax

    popq %r15
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    movq %rbp, %rsp
    popq %rbp
    ret

transitionIf:
    movl (g_prev), %edi
    movl (g_post), %esi
    call drawTransition
    cmpq $1, %rax
    je transReturned
    jmp mainLoopIfDone

transReturned:
    movl (g_post), %eax
    movl %eax, (state)
    movl $255, (g_alpha)
    jmp mainLoopIfDone

menuIf:
    call drawMenu
    cmpq $1, %rax
    je menuQuit
    cmpq $2, %rax
    je menuPlay
    jmp mainLoopIfDone

menuQuit:
    movb $1, (quit)
    jmp mainLoopIfDone

menuPlay:
    movl $0, (state)
    movl $1, (g_prev)
    movl $2, (g_post)
    call setupTransition
    jmp mainLoopIfDone

gameplayIf:
    call drawGame
    cmpq $1, %rax
    je gameplayToScore
    cmpq $2, %rax
    je gameplayExit
    jmp mainLoopIfDone

gameplayToScore:
    movl $0, (state)
    movl $2, (g_prev)
    movl $3, (g_post)
    call setupTransition
    jmp mainLoopIfDone

gameplayExit:
    movl $0, (state)
    movl $2, (g_prev)
    movl $1, (g_post)
    call setupTransition
    jmp mainLoopIfDone

scoreIf:
    call drawScore
    cmpq $1, %rax
    je scoreToGameplay
    cmpq $2, %rax
    je scoreToMenu
    jmp mainLoopIfDone

scoreToGameplay:
    movl $0, (state)
    movl $3, (g_prev)
    movl $2, (g_post)
    call setupTransition
    jmp mainLoopIfDone

scoreToMenu:
    call initGame
    movl $0, (state)
    movl $3, (g_prev)
    movl $1, (g_post)
    call setupTransition
    jmp mainLoopIfDone
