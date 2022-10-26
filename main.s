.data


.text
    // Defining consts
    carsSize:   .quad 100
    rocksSize:   .quad 1000
    
    // Setting Globals
    .global renderSave
    .global addCar
    .global removeCar
    .global drawRocks
    .global drawCars

# rax, rcx, rdx, rdi, rsi, r8, r9, r10, r11

// gameplay.h methods
renderSave:
    ret

addCar:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15


    call    getCars
    movq    %rax, %r14          # r14 contains cars[0] <- pointer
    addq    $20, %r14           # adding 20, to point to the exist boolean

    call    getCarsFirstEmpty   # rax now contains carsFirstEmpty - used as counter
    movq    %rax, %r12          # r12 contains carsFirstEmpty
    movq    $24, %rcx           # moving 24 to rcx, as that is sizeof Car
    mulq    %rcx                # multiplying by 24, to get pointer to first car
    movq    %rax, %r13          # r13 contains carsFirstEmpty * 24
    movq    %r12, %rax          # 
    dec     %rax
firstLoop:
    inc     %rax
    movb    (%r14, %r13), %r15b
    cmpb    $0x00, %r15b 
    jne     firstLoopContinue

firstReturn:
    movq    %rax, %r15
    movq    %rax, %rdi
    inc     %rdi
    call    setCarsFirstEmpty

    movq    %r15, %rax
    jmp     addCarEnd

firstLoopContinue:
    addq    $24, %r13
    cmpq    carsSize, %rax
    jl      firstLoop

    movq    $-1, %rax

secondLoop:
    inc     %rax
    movb    20(%r14, %r13), %r15b
    cmpb    $0x00, %r15b
    jne     secondLoopContinue

secondReturn:
    movq    %rax, %r15
    movq    %rax, %rdi
    inc     %rdi
    call    setCarsFirstEmpty

    movq    %r15, %rax
    jmp     addCarEnd

secondLoopContinue:
    addq    $24, %r13
    cmpq    %r12, %rax
    jle     secondLoop


    # Error code of -1, if no loop gave anything
    movq    $-1, %rax
addCarEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp
    ret


// void removeCar(int i);
removeCar:

    pushq   %rbp
    movq    %rsp, %rbp
    
    pushq   %r12
    pushq   %r13

    movq    %rdi, %r12              # saving i into r12
    call    getGStaticRender
    cmpq    $0, %rax
    jne     removeCarEnd

    call    getCars                 # rax now contains pointer to cars[0]
    movq    $24, %rcx               # storing sizeof Car into rcx
    movq    %rax, %r13              # storing pointer in r13
    movq    %r12, %rax              # copying i to rax
    mulq    %rcx                    # i * 24 gives us Car to address
    addq    $20, %rax               # adding 20, for the .exist address

    movb    $0x00, (%r13, %rax)     # false (0) into (Cars[0] + ((i * 24) + 20))
    call    getCarsFirstEmpty       # resets all registers, except r12 = i, r13 = cars[0]

    cmpq    %r12, %rax              # check if, compare i to carsFirstEmpty, jump if carsFirstEmpty is less than or equal to i
    jle     removeCarEnd            # carsFirstEmpty > i, i.e. jump to end if carsFirstEmpty <= i

    movq    %r12, %rdi              # otherwise put i as first argument
    call    setCarsFirstEmpty       # set carsFirstEmpty = i

removeCarEnd:
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp
    ret

// void drawRocks(int low, int high);
drawRocks:
    pushq   %rbp                    # prologue
    movq    %rsp, %rbp

    pushq   %r12                    # push callee-saved
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r14              # move low into r14
    movq    %rsi, %r15              # move high into r15

    movq    $0, %r12                # r12 will be the counter
    call    getRocks                # rock has a size of 12 bytes, 3 ints (row, pos, type)
    movq    %rax, %r13              # r13 now holds rocks[0] pointer

drawRocksLoop:

    cmpq    rocksSize, %r12         # if r12 is greater than or equal to rocksSize
    jge     drawRocksEnd            # 


firstDrawRocksAnd:
    cmpl    %r14d, (%r13)
    jl      drawRocksLoopContinue


secondDrawRocksAnd:
    cmpl    %r15d, (%r13)
    jge     drawRocksLoopContinue

    movq    %r12, %rdi
    call    drawRock

drawRocksLoopContinue:
    addq    $12, %r13

    inc     %r12
    jmp     drawRocksLoop

drawRocksEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret

drawCars:
    pushq   %rbp                    # prologue
    movq    %rsp, %rbp

    pushq   %r12                    # push callee-saved
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r14              # move low into r14
    movq    %rsi, %r15              # move high into r15

    movq    $0, %r12                # r12 will be the counter
    call    getCars                 # rock has a size of 12 bytes, 3 ints (row, pos, type)
    movq    %rax, %r13              # r13 now holds rocks[0] pointer

drawCarsLoop:

    cmpq    carsSize, %r12         # if r12 is greater than or equal to rocksSize
    jge     drawCarsEnd            # 


firstDrawCarsAnd:
    cmpl    %r14d, (%r13)
    jl      drawCarsLoopContinue


secondDrawCarsAnd:
    cmpl    %r15d, (%r13)
    jge     drawCarsLoopContinue

    movq    %r12, %rdi
    call    drawCar

drawCarsLoopContinue:
    addq    $24, %r13

    inc     %r12
    jmp     drawCarsLoop

drawCarsEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret


// funcs.h methods

