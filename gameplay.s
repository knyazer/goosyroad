.data

decimal: .asciz "%d"
threeQuarters: .float 0.75

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
    .global drawRock
    .global renderPlayer
    .global updateCar
    .global drawCar
    .global firstInitOfGame
    .global drawGame

    ROADL:  .quad   1

.data
    tempRect:   .quad 0
                .quad 0

.text
# rax, rcx, rdx, rdi, rsi, r8, r9, r10, r11

// gameplay.h methods

drawGame:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    pushq   %rbx
    pushq   %rbx

drawGameGNoRenderCheck:
    call    getGNoRender
    cmpq    $0, %rax
    jne     drawGameGetBlocked

    call    getRenderer
    movq    %rax, %r12
    call    getGAlpha
    movq    %rax, %r8
    movq    %r12, %rdi
    movq    $87, %rsi
    movq    $148, %rdx
    movq    $105, %rcx
    call    SDL_SetRenderDrawColor

    call    getGScreen
    movq    %rax, %rsi
    movq    %r12, %rdi
    call    SDL_RenderFillRect

drawGameGetBlocked:

    call    cameraAndPlayerUpdate
    movq    %rax, %r12 #//! r12 = blocked

drawGameCalculateLandH:
    call    getCurrentRow
    movq    %rax, %r13
    decq    %r13 #//! r13 = l

    call    getNumberOfRowsToDraw
    addq    %r13, %rax
    addq    $3, %rax
    movq    %rax, %r14 #//! r14 = h

    movq    $0, %r15
    movq    %r14, %r15 #//! r15 = i = (h) (counter)
    incq    %r15

    call    getRowType
    movq    %rax, %rbx #//! rbx = rowType*

drawGameRenderRoadSaveLoop:
    decq    %r15

    movq    $0, %rdi
    movl    (%rbx, %r15, 4), %edi

    cmpl    $0, %edi # comparing to SAVE
    je      drawGamecontinueRenderLoopCheck
    # nothing to do, because renderSave doesn't do anything

drawGamecontinueRenderLoopCheck:
    cmpl    $1, %edi # Comparing to ROADL
    je      drawGameRenderRoad

    cmpl    $2, %edi # comparing to ROADR
    je      drawGameRenderRoad

    jmp     drawGameRenderRoadSaveLoopContinue

drawGameRenderRoad:
    movl    %r15d, %edi
    call    renderRoad
    jmp     drawGameRenderRoadSaveLoopContinue

drawGameRenderRoadSaveLoopContinue:
    cmpl    %r13d, %r15d
    jg      drawGameRenderRoadSaveLoop

drawGameDrawRocksAndCars:
    movl    %r13d, %edi
    movl    %r14d, %esi
    call    drawCars

    movl    %r13d, %edi
    movl    %r14d, %esi
    call    drawRocks

    # r14, r15, rbx free
    # we can still use r13 (l) for currentRow - 1 = l
    # setting up the counter (i = currentRow + (numberOfRowsToDraw * 3) + 2)
    # should start 1 above (decrementing loop)
    call    getNumberOfRowsToDraw
    movq    $3, %r14
    mulq    %r14
    movq    %rax, %r14

    call    getCurrentRow
    addq    %rax, %r14 
    addq    $3, %r14 #//! r14 = counter (i)

    call    getRowType
    movq    %rax, %r15 #//! r15 = int* rowType

drawGameUpdateAndGenerateCarLoop:
    decq    %r14

    movl    (%r15, %r14, 4), %ebx

    cmpl    $1, %ebx # comparing to ROADL
    je      drawGameUpdateCars

    cmpl    $2, %ebx # comparing to ROADR
    je      drawGameUpdateCars

    jmp     drawGameUpdateAndGenerateCarLoopContinue

drawGameUpdateCars:

    movq    %r14, %rdi
    call    generateCars
    movq    %r14, %rdi
    call    updateCar
    jmp     drawGameUpdateAndGenerateCarLoopContinue

drawGameUpdateAndGenerateCarLoopContinue:
    cmpl    %r14d, %r13d
    jl      drawGameUpdateAndGenerateCarLoop

    call    cleanupCars

    # r13, r14, r15, rbx free
    call    getGPlayable
    cmpq    $0, %rax
    je      drawGameUpdateCurrentScore

drawGameRenderPlayerCuzPlayable:
    // movq    %r12, %rdi
    // call    renderPlayerHelper
    subq    $16, %rsp
    call    getPlayerRowF
    movss   %xmm0, (%rsp)
    call    getPlayerColumnF
    movss   %xmm0, %xmm1
    movss   (%rsp), %xmm0
    addq    $16, %rsp

    movq    $1, %rdi
    cmpq    $0, %r12
    cmovne  %rdi, %r12

    movq    %r12, %rdi

    // cvtsi2ss %r13, %xmm0 # playerRow (x)
    // cvtsi2ss %r14, %xmm1 # playerColumn (y)

    call    renderPlayer

# r12, r13, r14, r15, rbx free
drawGameUpdateCurrentScore:
    call    getGPlayable
    cmpq    $0, %rax
    je      drawGameReturnCarLoopStart
    
    call    getGNoRender
    cmpq    $0, %rax
    jne     drawGameReturnCarLoopStart

    call    getGCurrentScore
    movq    %rax, %r12
    call    getPlayerRow
    movq    %r12, %rdi
    subq    $2, %rax
    cmpq    %rax, %r12
    cmovl   %rax, %rdi 
    call    setGCurrentScore

    # char buffer[32];
    subq    $32, %rsp

    movq    %rsp, %rdi
    movq    $decimal, %rsi
    movq    %r12, %rdx
    call    sprintf

    movq    %rsp, %rdi
    movq    $1, %rsi
    movq    $219, %rdx
    movq    $167, %rcx
    movq    $11, %r8
    call    drawText

    # removing buffer
    addq    $32, %rsp

drawGameReturnCarLoopStart:
    # all registers free, we going
    movq    $-1, %r12 #//! r12 = i (counter)


drawGameReturnCarLoop:
    incq    %r12

    movq    %r12, %rdi
    call    getComplexAndCondition

    cmpq    $0, %rax
    je      drawGameReturnCarLoopContinue

    movq    $1, %rax
    jmp     drawGameEnd

drawGameReturnCarLoopContinue:
    cmpq    carsSize, %r12
    jl      drawGameReturnCarLoop

    call    getPlayerRow
    movq    %rax, %r12
    call    getFloatCurrentRow
    movss   %xmm0, %xmm1
    cvtsi2ss %r12, %xmm0 # playerRow
    movss (threeQuarters), %xmm2 # threeQuarters

    subss   %xmm2, %xmm1 # currentRow - 0.75
    comiss  %xmm0, %xmm1
    jbe     drawGamePlayerRowCheck

    movq    $1, %rax
    jmp     drawGameEnd

drawGamePlayerRowCheck:

    call    getPlayerRow
    cmpq    $999, %rax
    jl      drawGamePreEnd

    movq    $1, %rax
    jmp     drawGameEnd

drawGamePreEnd:
    movq    $0, %rax

drawGameEnd:
    popq    %rbx
    popq    %rbx
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret



drawCar:
    pushq   %rbp
    movq    %rsp, %rbp
    
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    pushq   %rbx

    movq    %rdi, %r12      #//! r12 = i
    movq    %rdi, %rbx

    call    getGNoRender
    cmpq    $0, %rax
    jne     drawCarEnd

    movq    $24, %rax   # 24 into rax
    mulq    %r12        # rax = 24 * i  
    movq    %rax, %r13  # r13 = 24 * i
    call    getCars
    addq    %rax, %r13  # cars pointer + 24 * i
                        #//! r13 = cars[i] (mem_address)
    
    call    getNumberOfRowsToDraw
    movq    %rax, %r14  #//! r14 = numberOfRowsToDraw
    call    getGHeight
    movq    $0, %rdx
    divq    %r14    
    shlq    %rax
    movq    $3, %rcx
    movq    $0, %rdx
    divq    %rcx
    movq    %rax, %r15  #//! r15 = h

    call    getHorizontalResolution
    movq    %rax, %r14

    call    getGWidth
    movq    $0, %rdx
    divq    %r14
    cvtsi2ss %rax, %xmm0    #//! xmm0 = g_width / horizontalRes

    movl    16(%r13) ,%eax
    subq    $16, %rsp
    movl    %eax, (%rsp)
    movss   (%rsp), %xmm1
    mulss   %xmm0, %xmm1
    cvtss2si %xmm1, %rax # rax = w
    movq    %rax, %r12  #//! r12 = w

    # space on stack already allocated, so we all good
    # (for SDL_Rect rect;)
    movl    4(%r13), %r8d
    movl    %r8d, (%rsp)
    movss   (%rsp), %xmm1   # xmm1 = cars[i].position

    mulss   %xmm0, %xmm1    # xmm1 = xmm1(cars[i].pos) * xmm0 (g_width/horizontal)
    cvtss2si %xmm1, %r8

    movq    $tempRect, %r11
    movl    %r8d, (%r11)    #//! rect.x = equation
    
    movq    %rbx, %rdi
    movq    %r15, %rsi
    call    getCarY
    movq    $tempRect, %r11
    movl    %eax, 4(%r11)

    movl    %r12d, 8(%r11)
    movl    %r15d, 12(%r11)
    
    call    getRowType
    movq    %rax, %r15  #//! r15 = rowType*

    call    getRenderer
    movq    %rax, %r12  #//! renderer in r12

    movl    (%r13), %r13d    #//! r13 = cars[i].row
    movl    (%r15, %r13, 4), %r13d

    cmpl    $1, %r13d
    # check if equal to ROADL
    jne     drawCarRoadR

    movq    %rbx, %rdi
    call    getCarTextureL
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    $tempRect, %rcx
    call    SDL_RenderCopy

    jmp     drawCarEnd

drawCarRoadR:
    cmpl    $2, %r13d
    # check if equal to ROADR
    jne     drawCarEnd

    movq    %rbx, %rdi
    call    getCarTextureR
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    $tempRect, %rcx
    call    SDL_RenderCopy

drawCarEnd:
    addq    $16, %rsp

    popq    %rbx
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret

renderPlayer:
    pushq   %rbp
    movq    %rsp, %rbp
    
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r15                  #//! r15 = state
# float x => xmm0, float y => xmm1, state = rdi

    ## if (g_no_render) return;
    call    getGNoRender
    cmpq    $0, %rax
    jne     renderPlayerEnd

    ## int h = (g_height / numberOfRowsToDraw) / 2;
    call    getNumberOfRowsToDraw
    movq    %rax, %r12
    call    getGHeight
    movq    $0, %rdx
    divq    %r12
    shrq    %rax
    movq    %rax, %r12                  #//! r12 = h

    ## int w = h;
    movq    %r12, %r13                  #//! r13 = w

    ## SDL_Rect rect;
    subq    $16, %rsp                   #//! rsp = SDL_Rect rect;

    ## rect.x = ((y / horizontalResolution) * (g_width)) - (w / 2);
    # sub. => DST-SRC

    call    getHorizontalResolution
    # Greatest instruction ever
    cvtsi2ss %rax, %xmm2

    # DIVSS => DST / SRC
    # xmm1 = y
    divss   %xmm2, %xmm1        # xmm1 = y / horizontalResolution

    # I don't expect most of these to use the xmm registers
    call    getGWidth
    cvtsi2ss %rax, %xmm2        # xmm2 = g_width
    mulss   %xmm1, %xmm2

    cvtss2si %xmm2, %rax        # rax = ((y/horizRes) * (g_width))
    shrq    %r13                # w / 2

    subq    %r13, %rax          # rax now holds rect.x value
    shlq    %r13                # w * 2

    movl    %eax, (%rsp)        #//! rect.x = (%rsp)
                                #//! xmm0 = x

    // ## rect.y = ((numberOfRowsToDraw - (x - currentRow)) * (g_height / numberRowsDraw)) - h / 2;
    // call    getCurrentRow
    // cvtsi2ss %rax, %xmm2

    // subss   %xmm2, %xmm0

    // cvtss2si %xmm0, %r14       # r14 = x - currentRow

    // call    getNumberOfRowsToDraw 
    // subq    %r14, %rax 
    // movq    %rax, %r14          #//! r14 = numR - (x - currentRow)

    // call    getNumberOfRowsToDraw
    // pushq   %rax

    // call    getGHeight
    // popq    %rdi
    // movq    $0, %rdx
    // divq    %rdi

    // mulq    %r14
    // # rax = THING (without - h/2)
    // shrq    %r12
    // subq    %r12, %rax
    // shlq    %r12

    // # rax = correct rect.y value
    movq    %r12, %rdi
    call    getRenderPlayY
    movl    %eax, 4(%rsp)

    movl    %r13d, 8(%rsp)
    movl    %r12d, 12(%rsp)

    cmpq    $0, %r15
    jne     renderPlayerFirstEndIfBody

    addl    %r12d, 12(%rsp)     # effectively rect.h *= 2
    subl    %r12d, 4(%rsp)

renderPlayerFirstEndIfBody:
    call    getRenderer
    movq    %rax, %r12          #//! renderer in rdi

    call    getPlayerDirection
    cmpq    $0, %rax

    jne     renderPlayerRenderElse

    cmpq    $0, %r15
    jne     renderPlayerSecondIfSecondIf

    call    getHeroR
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    %rsp, %rcx
    call    SDL_RenderCopy

    movq    %r12, %rdi

    jmp     renderPlayerEnd

renderPlayerSecondIfSecondIf:

    call    getHeroSR
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    %rsp, %rcx
    call    SDL_RenderCopy

    jmp     renderPlayerEnd

renderPlayerRenderElse:

    cmpq    $0, %r15
    jne     renderPlayerElseSecondIf

    call    getHeroL
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    %rsp, %rcx
    call    SDL_RenderCopy

    jmp     renderPlayerEnd

renderPlayerElseSecondIf:

    call    getHeroSL
    movq    %rax, %rsi
    movq    %r12, %rdi
    movq    $0, %rdx
    movq    %rsp, %rcx
    call    SDL_RenderCopy

renderPlayerEnd:
    addq    $16, %rsp
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret

updateCar:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r12         #//! r12 = i

    call    getGStaticRender
    cmpq    $0, %rax
    jne     updateCarEnd

    call    getRowType
    movq    %rax, %r14         #//! rowType* in r14

    call    getCars
    movq    %rax, %r13      #//! r13 = cars*

    movq    $-1, %rcx
    # sizeof Car = 24 Bytes
    movq    $0, %r9
updateCarLoop:
    inc     %rcx
    movq    $24, %rax               #//! rcx = j
    mulq    %rcx
    addq    %r13, %rax              #//! rax = cars[j] (mem address)

    ## if (cars[j].row == i && cars[j].exist)
    cmpl    (%rax), %r12d
    jne     updateCarLoopContinue
    cmpb    $0, 20(%rax)
    je      updateCarLoopContinue

    ## basically you add either the negative or the positive
    ## so basically I will take the speed, and flip the sign bit of
    ## it works, and add that to the position
    movl    $0x80000000, %r8d
    cmpq    $1, (%r14, %r12, 4) #Compare to ROADL
    cmove   %r9, %r8
    xorl    12(%rax), %r8d

    # reserve 32 byes on stack
    subq    $32, %rsp
    movq    $0, (%rsp)
    movq    $0, 16(%rsp)
    # move updated speed to top of that stack (4-byte float)
    movl    %r8d, (%rsp)

    # move top of stack to xmm0
    movss   (%rsp), %xmm0
    
    # move car[j].position to xmm1
    movl    4(%rax), %r10d
    movl    %r10d, 16(%rsp)
    movss   16(%rsp), %xmm1

    addss   %xmm1, %xmm0
    movss   %xmm0, (%rsp)

    movl    (%rsp), %r10d
    movl    %r10d, 4(%rax)

    addq    $32, %rsp

updateCarLoopContinue:
    cmpq    carsSize, %rcx
    jl      updateCarLoop

updateCarEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp
    ret

drawRock:
    pushq   %rbp
    movq    %rsp, %rbp

    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15


    movq    %rdi, %r14          # int i now in r14
    movq    %rdi, %r15          # r15 = i 

    call    getGNoRender
    cmpq    $0, %rax
    jne     drawRockEnd

    call    getHorizontalResolution
    movq    %rax, %r12

    call    getGWidth
    movq    $0, %rdx
    divq    %r12
    # the step is now in rax
    movq    %rax, %r13          # the  step is now r13

    shlq    $1, %rax            # multiply rax by 2

    movq    $0, %rdx
    movq    $3, %r12
    divq    %r12
    # size is now in rax
    movq    %rax, %r12          # size is now in r12

    # making space on the stack for SDL_Rect
    subq    $16, %rsp

    movq    $12, %rax
    mulq    %r14
    movq    %rax, %r14  # r14 = i * 12
    # r12 = size, r13 = step, r14 = i * sizeof Rock
    # rect.x = (rocks[i].position * step) - (size / 2);
    shrq    %r12                # r12 = size / 2

    call    getRocks
    addq    $4, %rax            # rax = rocks[0].position
    movq    (%rax, %r14), %rax  # rax = rocks[i].position

    mulq    %r13                # rax = (rocks[i].position * step)
    subq    %r12, %rax          # rax = (rocks[i].position * step) - (size / 2)

    movl    %eax, (%rsp)

    shlq    %r12
    # r12 = size, r14 = i * 12
    # rect. y = ((numRows - (rocks[i].row - currentRow)) * (g_height / numberRows)) - size / 2

    movq    %r15, %rdi
    movq    %r12, %rsi
    call    getCorrectRockDrawY
    
    movl    %eax, 4(%rsp)

    movl    %r12d, 8(%rsp)          # rect.w (or rect.h is doesn't matter, both the same)
    movl    %r12d, 12(%rsp)         # = size

    call    getRenderer
    movq    %rax, %r13              # SDL_Renderer* renderer in r13

    call    getRocks
    addq    $8, %rax                # add 8 to get .type
    movq    (%rax, %r14), %rdi      # r14 = i * 12, therefore rocks[i].type
    # r14 = rocks[i].type, r13 = renderer

    call    getCorrectRockTextureWithI
    movq    %rax, %rsi
    movq    %r13, %rdi

    movq    $0, %rdx
    movq    %rsp, %rcx
    
    call    SDL_RenderCopy

    addq    $16, %rsp

drawRockEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp
    ret

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

    movq    %rdi, %r12  #//! r12 = low
    movq    %rsi, %r13  #//! r13 = high

    movq    $-1, %r14    #//! r14 = i

    call    getCars
    movq    %rax, %r15  #//! r15 = cars*
    
drawCarsLoop:
    inc     %r14

    movq    $24, %rax
    mulq    %r14
    movq    %rax, %rdi
    addq    %r15, %rdi #//! rdi = cars[i]

drawCarsCarExist:
    cmpb    $0, 20(%rdi)
    je      drawCarsLoopContinue

drawCarsRowMoreThanLow:
    cmpl    %r12d, (%rdi)
    jl      drawCarsLoopContinue

drawCarsRowLessThanHigh:
    cmpl    %r13d, (%rdi)
    jge     drawCarsLoopContinue

    // for some reason drawCar does not preserve the r15 register
    // I have implemented this as a quick solution for now
    pushq   %r15
    movq    %r14, %rdi
    call    drawCar
    popq    %r15

drawCarsLoopContinue:
    cmpq    carsSize, %r14
    jl      drawCarsLoop

drawCarsEnd:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp
    
    ret

.global renderRoad

renderRoad:
    pushq   %rbp                    # prologue
    movq    %rsp, %rbp

    pushq   %r12                    # push callee-saved
    pushq   %r13
    pushq   %r14
    pushq   %r15

    movq    %rdi, %r14              # move i into r14

renderRoadGNoRenderCheck:           # if (g_no_render) { return; }
    call    getGNoRender
    cmpq    $0, %rax
    jne     renderRoadEnd

renderRoadBody:
    # SDL_Rect has a size of 16 bytes (4 ints)
    # creating SDL_Rect rect;
    movq    $16, %rdi
    call    malloc # TODO: fix memory leak

    movq    %rax, %r15          # saving pointer to that malloc in r15
    movl    $0, (%r15)          # moving 0 to first int

    movq    %r14, %rdi          # proving int i for getRectY()
    call    getRectY
    movl    %eax, 4(%r15)       # moving result of getRectY to rax+4 (meaning rect.y)

    # r15 = pointer to rect
    movq    $0, %rdx            # because rdx is also used during division and I hate floating point exception
    call    getNumberOfRowsToDraw
    movq    %rax, %r14          # move numberOfRowsToDraw to r14
    call    getGHeight          # g_height in rax

    div     %r14                # result of division in rax
    movl    %eax, 12(%r15)      # moving result of division to rect.h
    addl    $2, 12(%r15)        # rect.h += 2
    subl    $1, 4(%r15)         # rect.y -= 1
    movl    %eax, 8(%r15)       # moving same value to rect.w (because, that is kinda what you do)

    call    getGWidth

    # r15 = rect (address)
    # r14 = lets make that renderer
    call    getRenderer
    movq    %rax, %r14          # SDL_Renderer* renderer in r14 now
    # r13 = roadTexture
    call    getRoadTexture
    movq    %rax, %r13          # SDL_Texture* roadTexture in r13 now

    call    getGWidth
    movq    %rax, %r12
    movq    $0, %rdi
renderRoadWhile:
    cmpl    %r12d, (%r15)        # compare rect.x and g_width
    jge     renderRoadEnd       # if rect.x is greater or equal to g_width, end the function (while loop)

    movq    %r14, %rdi
    movq    %r13, %rsi
    movq    $0, %rdx
    movq    %r15, %rcx
    call    SDL_RenderCopy

    movl    8(%r15), %edi
    addl    (%r15), %edi
checking:
    movl    %edi, (%r15)

    jmp     renderRoadWhile

renderRoadEnd:
    // cannot free the memory - could this become a problem?, should we check this out?
    // movq    %r15, %rdi
    // call    free

    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp, %rsp
    popq    %rbp

    ret

phero: .asciz "res/hero.png"
pheroa: .asciz "res/heroa.png"
pherob: .asciz "res/herob.png"
pheroba: .asciz "res/heroba.png"
pcar1: .asciz "res/car1.png"
pcar1a: .asciz "res/car1a.png"
pcar2: .asciz "res/car2.png"
pcar2a: .asciz "res/car2a.png"
pcar3: .asciz "res/car3.png"
pcar3a: .asciz "res/car3a.png"
pstone1: .asciz "res/stone1.png"
pstone2: .asciz "res/stone2.png"
pstone3: .asciz "res/stone3.png"
pstone4: .asciz "res/stone4.png"
pstone5: .asciz "res/stone5.png"
pstone6: .asciz "res/stone6.png"
proad: .asciz "res/road.png"

# first init of the game
firstInitOfGame:
    pushq %rbp
    movq %rsp, %rbp

    pushq %r12
    pushq %r13

    call getRenderer
    movq %rax, %r12

    movq %r12, %rdi
    movq $phero, %rsi
    call IMG_LoadTexture
    movq %rax, (heroSR)

    movq %r12, %rdi
    movq $pheroa, %rsi
    call IMG_LoadTexture
    movq %rax, (heroSL)

    movq %r12, %rdi
    movq $pherob, %rsi
    call IMG_LoadTexture
    movq %rax, (heroR)

    movq %r12, %rdi
    movq $pheroba, %rsi
    call IMG_LoadTexture
    movq %rax, (heroL)

    movq %r12, %rdi
    movq $pcar1, %rsi
    call IMG_LoadTexture
    movq %rax, (carTexturesL)

    movq %r12, %rdi
    movq $pcar1a, %rsi
    call IMG_LoadTexture
    movq %rax, (carTexturesR)
    
    movq %r12, %rdi
    movq $pcar2, %rsi
    call IMG_LoadTexture
    movq $carTexturesL, %rdi
    movq %rax, 8(%rdi)

    movq %r12, %rdi
    movq $pcar2a, %rsi
    call IMG_LoadTexture
    movq $carTexturesR, %rdi
    movq %rax, 8(%rdi)
    
    movq %r12, %rdi
    movq $pcar3, %rsi
    call IMG_LoadTexture
    movq $carTexturesL, %rdi
    movq %rax, 16(%rdi)

    movq %r12, %rdi
    movq $pcar3a, %rsi
    call IMG_LoadTexture
    movq $carTexturesR, %rdi
    movq %rax, 16(%rdi)
    
    movq $rockTextures, %r13
    movq %r12, %rdi
    movq $pstone1, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $pstone2, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $pstone3, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $pstone4, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $pstone5, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $pstone6, %rsi
    call IMG_LoadTexture
    movq %rax, (%r13)
    addq $8, %r13

    movq %r12, %rdi
    movq $proad, %rsi
    call IMG_LoadTexture
    movq %rax, (roadTexture)

    call initGame

    popq %r13
    popq %r12

    movq %rbp, %rsp
    popq %rbp

    ret
.global initGame
# init game
.data
f50: .float 50.0
f200: .float 200.0
f1: .float 1.0
f005: .float 0.05
f0: .float 0.0
.text

initGame:
    pushq %rbp
    movq %rsp, %rbp

    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    
    movq $8, %rcx
    movq $rowType, %rax
.initGameFLoop:
    movl $0, (%rax)
    addq $4, %rax
    decq %rcx
    jnz .initGameFLoop
    
    movq %rax, %r12

    call rand
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    addl $1, %edx
    movl %edx, (%r12)
    addq $4, %r12

    movq $9, %r13
.initGameLoop2:
    cvtsi2ssq %r13, %xmm0
    divss (f50), %xmm0
    addss (f1), %xmm0
    mulss (f200), %xmm0
    addss (f200), %xmm0
    cvttss2si %xmm0, %r14
    call rand
    movq $0, %rdx
    div %r14
    
    # x is in rdx
    cmpq $200, %rdx
    jl .igl_setSave
    
    call rand
    movl $2, %ecx
    movl $0, %edx
    div %ecx
    addl $1, %edx
    movl %edx, (%r12)
    addq $4, %r12
    
.igl_setSave_ret: 
    
    incq %r13
    cmpq $1000, %r13
    jl .initGameLoop2
    
    jmp initGameCarsProcessing

.igl_setSave:
    movl $0, (%r12)
    addq $4, %r12
    jmp .igl_setSave_ret

initGameCarsProcessing:
    movq (carsSize), %rcx
    movq $cars, %rax

.igcploop:
    movb $0, 20(%rax)
    addq $24, %rax
    subq $1, %rcx
    jnz .igcploop

    movl $0, (carsFirstEmpty)

.data
    k: .quad 0
.text
    movq $0, (k)
    movq $6, %r14 #r14 is i

rocksLoop:
    movq $rowType, %r9
    cmpl $0, (%r9, %r14, 4)
    je rockGeneration
.rockGenerationBack:
    
    incq %r14
    cmpq $1000, %r14
    jl rocksLoop
    
    jmp afterMathSetupInitGame

rockGeneration:
    movq $0, %r12 # num is r12
    movl $0, %r15d

rockGenRandomLoop:
    incq %r12
    movq $rocks, %r13 # r13 is pointer to the rock, rocks are 3 byte size
    movq (k), %rax
    movq $12, %r8
    mulq %r8
    addq %rax, %r13

    movl %r14d, (%r13)
    
    call rand
    movl $7, %ecx
    movq $0, %rdx
    div %ecx

    inc %edx
    addl %edx, %r15d
    cmpl (horizontalResolution), %r15d
    jge rockGenRandomLoopDoneWSkip
    jmp continueRockGenRandomLoop

rockGenRandomLoopDoneWSkip:
    movq $-1000, (%r13)
    movq $0, 4(%r13)
    jmp rockGenRandomLoopDone

    continueRockGenRandomLoop:
    movl %r15d, 4(%r13)

    call rand
    movl $6, %ecx
    movq $0, %rdx
    div %ecx
    movl %edx, 8(%r13)

    incq (k)

    movq (k), %rax
    cmpq %rax, (rocksSize)
    je rockGenRandomLoopDone

    jmp rockGenRandomLoop

rockGenRandomLoopDone:
jmp .rockGenerationBack
    movq (k), %r10
    subq %r12, %r10
.n1l:
    cmpq %r10, (k)
    jl .n1ldone
    
    movq %r10, %r11
    addq $1, %r11
.n2l:
    cmpq %r11, (k)
    jl .n2ldone
    
    movq $rocks, %r8
    movq %r10, %rax
    movq $12, %rcx
    mul %rcx
    addq %rax, %r8
    
    movq $rocks, %r9
    movq %r11, %rax
    movq $12, %rcx
    mul %rcx
    addq %rax, %r9

    movl 4(%r8), %eax
    cmpl %eax, 4(%r9)
    jne .ifskipn2l
    
    movl $-1000, (%r8)

.ifskipn2l:
    incq %r11
.n2ldone:

    incq %r10

.n1ldone:
    movq (k), %rax
    cmpq %rax, (rocksSize)
    jge .rockGenerationBack

afterMathSetupInitGame:
    movq (k), %rdi
    call setRocksSize

    # setting up a bunch of random variables
    movb $1, (g_no_render)
    movb (g_playable), %r12b
    movb $0, (g_playable)
    movq $600, %r14
.afterMathLoop:
    call drawGame

    decq %r14
    jnz .afterMathLoop
    
    movb %r12b, (g_playable)
    movb $0, (g_no_render)

    movss (f0), %xmm0
    movss %xmm0, (currentRow)
    movss %xmm0, (targetRow)

    movss (f005), %xmm0
    movss %xmm0, (eps)

    movl $12, (numberOfRowsToDraw)
    movl $12, (horizontalResolution)

    call rand
    movq $0, %rdx
    movl $2, %ecx
    div %ecx
    movl %edx, (playerDirection)

    movl $3, (playerRow)
    movl $6, (playerColumn)
    
    cvtsi2ss (playerRow), %xmm0
    movss %xmm0, (playerRowF)

    cvtsi2ss (playerColumn), %xmm0
    movss %xmm0, (playerColumnF)

    cmpb $1, (g_playable)
    jne .afterMathDone
    cmpb $0, (g_static_render)
    jne .afterMathDone

    movb $1, (g_current_score)
    .afterMathDone:
    
    popq %r15
    popq %r14
    popq %r13
    popq %r12

    movq %rbp, %rsp
    popq %rbp

    ret

.global generateCars

.data
    f015: .float 0.15
    f0025: .float 0.025
    f04: .float 0.4
    f14: .float 1.4
    distanceAmongCars: .float 0.0
    carPosition: .float 0.0
    fm04: .float -0.4
    fRAND_MAX: .float 2147483647.0
    minSpeed: .float 0.0
    maxSpeed: .float 0.0
    dontGenerate: .byte 0

.text

generateCars:
    cmpl $1, (g_static_render)
    jne .firstgcifend
    ret

.firstgcifend:
    pushq %rbp
    movq %rsp, %rbp

    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    
    movq %rdi, %r12 # r12 is the row index

    call rand
    movq $0, %rdx
    movl $150, %ecx
    div %ecx
    cmpl $0, %edx
    jne doneWithGenerateCars
    
    movb $0, (dontGenerate)
    movss (f015), %xmm0
    movss %xmm0, (maxSpeed)
    movss (f0025), %xmm0
    movss %xmm0, (minSpeed)

    movq $0, %r14 # r14 is j
    movq $cars, %r13 # r13 is pointer to the car
genCarsLoop:
    cmpl (carsSize), %r14d
    jge doneWithgcloop

    cmpl %r12d, (%r13)
    jne .skipgcloop

    cmpb $1, 20(%r13)
    jne .skipgcloop
    
    # divide the execution into two parts: for rowType[i] being ROADL and ROADR
    movq $rowType, %rcx
    movq %r12, %rax
    movq $4, %r8
    mul %r8
    addq %rax, %rcx

    cmpl $1, (%rcx)
    je .roadl_gloop
    cmpl $2, (%rcx)
    je .roadr_gloop

    .skipgcloop:
    incq %r14
    addq $24, %r13
    jmp genCarsLoop

doneWithgcloop:
    # dontgenerate is set to 1 if we want to skip this, and finish
    cmpb $1, (dontGenerate)
    je doneWithGenerateCars

    # if we are here, we are going to generate a car
    call addCar
    # there is a car index in rax
    movq $cars, %r13
    movq $24, %r8
    mul %r8
    addq %rax, %r13
    # r13 is now the pointer to the new car
    # car row = rdi
    movl %r12d, (%r13)
    # car position is carPosition
    movl %r12d, %edi
    call makeCarPosition
    movss %xmm0, 4(%r13)
    # car type is random between 0 and 1
    call rand
    movq $0, %rdx
    movl $3, %ecx # TODO: add more cars and chage the value here
    div %ecx
    movl %edx, 8(%r13)
    # car speed is minSpeed + (rand()/RAND_MAX) * (maxSpeed - minSpeed)
    call rand
    cvtsi2ss %rax, %xmm0
    divss (fRAND_MAX), %xmm0
    movss (maxSpeed), %xmm1
    subss (minSpeed), %xmm1
    mulss %xmm1, %xmm0
    addss (minSpeed), %xmm0
    movss %xmm0, 12(%r13)
    # car width is 1 (dependent on type, but whatever)
    movss (f1), %xmm0
    movss %xmm0, 16(%r13)
    # exist is 1
    movl $0, 20(%r13)
    movb $1, 20(%r13)

doneWithGenerateCars:
    popq %r15
    popq %r14
    popq %r13
    popq %r12

    movq %rbp, %rsp
    popq %rbp

    ret

.roadl_gloop:
    # for left road we want to check that cars[j].position > 1
    # and generated distance will be 1.4 * horizontalResolution - position
    movss 4(%r13), %xmm0 # position
    comiss (f1), %xmm0
    jbe .setTheFlaganddone
    

    movss 4(%r13), %xmm0 # position
    movl (horizontalResolution), %eax
    cvtsi2ss %eax, %xmm1
    mulss (f14), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, (distanceAmongCars)
    jmp calculateMaxSpeedcl

.roadr_gloop:
    # for right road we want to check that cars[j].position > horizontalResolution - 1- cars[j].width
    # and generated distance will be cars[j].position + 0.4 * horizontalResolution
    movss 4(%r13), %xmm0 # position
    movl (horizontalResolution), %eax
    cvtsi2ss %eax, %xmm1
    subss (f1), %xmm1
    subss 16(%r13), %xmm1
    comiss %xmm0, %xmm1
    jbe .setTheFlaganddone

    # distanceAmongCars = position + 0.4 * horizontalResolution
    movss 4(%r13), %xmm0 # position
    movl (horizontalResolution), %eax
    cvtsi2ss %eax, %xmm1
    mulss (f04), %xmm1
    addss %xmm0, %xmm1
    movss %xmm1, (distanceAmongCars)
    jmp calculateMaxSpeedcl

.setTheFlaganddone:
    movb $1, (dontGenerate)
    jmp doneWithgcloop

calculateMaxSpeedcl:
    # xmm0 = distanceAmongCars / cars[j].speed
    movss (distanceAmongCars), %xmm0
    movss 12(%r13), %xmm1
    divss %xmm1, %xmm0

    # xmm0 = (1.4 * horizontalResolution) / xmm0
    movl (horizontalResolution), %eax
    cvtsi2ss %eax, %xmm1
    mulss (f14), %xmm1
    divss %xmm0, %xmm1
    movss %xmm1, %xmm0

    # maxSpeed = min(maxSpeed, xmm0)
    movss (maxSpeed), %xmm1
    minss %xmm0, %xmm1
    movss %xmm1, (maxSpeed)
    
    jmp .skipgcloop


.global cameraAndPlayerUpdate

.data
f0005: .float 0.005
forwardEmpty: .byte 0
backwardEmpty: .byte 0
leftEmpty: .byte 0
rightEmpty: .byte 0
blockedPath: .int 30
f15: .float 1.5
fm05: .float -0.5
.text
cameraAndPlayerUpdate:

    cmpb $0, (g_playable)
    jne skipif1capu
    
    movss (f0005), %xmm0
    movss (currentRow), %xmm1
    addss %xmm0, %xmm1
    movss %xmm1, (currentRow)
    
    movq $0, %rax
    ret

skipif1capu:
    
    cmpb $1, (g_static_render)
    jne skipif2capu
    
    movq $0, %rax
    ret

skipif2capu:

    pushq %rbp
    movq %rsp, %rbp

    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movb $1, (forwardEmpty)
    movb $1, (backwardEmpty)
    movb $1, (leftEmpty)
    movb $1, (rightEmpty)

    # check chat rowType[playerRow + 1] == 0
    movl (playerRow), %eax
    movq $0, %rdx
    addq $1, %rax
    movq $rowType, %r9
    movq $4, %r8
    mul %r8
    addl %eax, %r9d
    cmpl $0, (%r9)
    je forwardEmptyPossible
fepret:
    # check that rowType[playerRow - 1] == 0
    cmpb $1, (playerRow)
    jg skipasdf

movb $0, (backwardEmpty)

    skipasdf:
    movl (playerRow), %eax
    subq $1, %rax
    movq $rowType, %r9
    movq $4, %r8
    mul %r8
    addl %eax, %r9d
    cmpl $0, (%r9)
    je backwardEmptyPossible
bepret:
    
    # check that rowType[playerRow] == 0
    movl (playerRow), %eax
    movq $rowType, %r9
    movq $4, %r8
    mul %r8
    addl %eax, %r9d
    cmpl $0, (%r9)
    je leftRightEmptyPossible
lrepret:
    jmp doneWithfirstPartOfCameraAndPlayerUpdate

forwardEmptyPossible:
    # rcx is the counter
    # rdx is the pointer to the current rocks
    movq $0, %rcx
    movq $rocks, %rdx
feploop:
    cmpl %ecx, (rocksSize)
    jl feploopDone

    # check that rocks[i].row == playerRow + 1
    movl (%rdx), %eax
    subl $1, %eax
    cmpl %eax, (playerRow)
    jne feploopContinue

    # check that rocks[i].position == playerColumn
    movl 4(%rdx), %eax
    cmpl %eax, (playerColumn)
    jne feploopContinue

    # we cannot move forward if we are here
    movb $0, (forwardEmpty)
    
feploopContinue:
    addq $12, %rdx
    incq %rcx
    jmp feploop

feploopDone:
    jmp fepret

backwardEmptyPossible:
    # rcx is the counter
    # rdx is the pointer to the current rocks
    movq $0, %rcx
    movq $rocks, %rdx
beploop:
    cmpl %ecx, (rocksSize)
    jl beploopDone

    # check that rocks[i].row == playerRow - 1
    movl (%rdx), %eax
    addl $1, %eax
    cmpl %eax, (playerRow)
    jne beploopContinue

    # check that rocks[i].position == playerColumn
    movl 4(%rdx), %eax
    cmpl %eax, (playerColumn)
    jne beploopContinue

    # we cannot move backward if we are here
    movb $0, (backwardEmpty)

beploopContinue:
    addq $12, %rdx
    incq %rcx
    jmp beploop

beploopDone:
    jmp bepret

leftRightEmptyPossible:
    # rcx is the counter
    # rdx is the pointer to the current rocks
    movq $0, %rcx
    movq $rocks, %rdx

lreloop:
    cmpl %ecx, (rocksSize)
    jl lreloopDone

    # check that rocks[i].row == playerRow
    movl (%rdx), %eax
    cmpl %eax, (playerRow)
    jne lreloopContinue

    # check that rocks[i].position == playerColumn - 1
    movl 4(%rdx), %eax
    subl $1, %eax
    cmpl %eax, (playerColumn)
    jne lreloopContinue1

    # we cannot move left if we are here
    movb $0, (leftEmpty)

lreloopContinue1:
    # check that rocks[i].position == playerColumn + 1
    movl 4(%rdx), %eax
    addl $1, %eax
    cmpl %eax, (playerColumn)
    jne lreloopContinue2

    # we cannot move right if we are here
    movb $0, (rightEmpty)

lreloopContinue2:
lreloopContinue:
    addq $12, %rdx
    incq %rcx
    jmp lreloop

lreloopDone:
    jmp lrepret

doneWithfirstPartOfCameraAndPlayerUpdate:
    # check if there is an attempt to move forward (g_forward = true)
    cmpb $1, (g_forward)
    jne forwardcheckdone

    # check if we can move forward
    cmpb $1, (forwardEmpty)
    jne forwardisblocked

    # add 0.4 to targetRow, and increment player row
    movss (f04), %xmm0
    addss (targetRow), %xmm0
    movss %xmm0, (targetRow)
    incl (playerRow)
    jmp forwardcheckdone
forwardisblocked:
    movl $30, (blockedPath)

forwardcheckdone:
    # check if there is an attempt to move backward (g_backward = true)
    cmpb $1, (g_backward)
    jne backwardcheckdone

    # check if we can move backward
    cmpb $1, (backwardEmpty)
    jne backwardisblocked

    # subtract 0.4 from targetRow, and decrement player row
    movss (f04), %xmm0
    movss (targetRow), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, (targetRow)
    decl (playerRow)
    jmp backwardcheckdone
    
backwardisblocked:
    movl $30, (blockedPath)

backwardcheckdone:
    # check if there is an attempt to move left (g_left = true)
    cmpb $1, (g_left)
    jne leftcheckdone
    
    movl $0, (playerDirection)
    # check if leftEmpty and playerColumn < horizontalResolution - 1
    cmpb $1, (leftEmpty)
    jne leftisblocked
    movl (horizontalResolution), %eax
    subl $1, %eax
    cmpl (playerColumn), %eax
    jle leftisblocked

    incl (playerColumn)
    jmp leftcheckdone

leftisblocked:
    movl $30, (blockedPath)

leftcheckdone:
    # check if there is an attempt to move right (g_right = true)
    cmpb $1, (g_right)
    jne rightcheckdone

    movl $1, (playerDirection)
    # check if rightEmpty and playerColumn > 1
    cmpb $1, (rightEmpty)
    jne rightisblocked
    cmpl $1, (playerColumn)
    jle rightisblocked

    decl (playerColumn)
    jmp rightcheckdone

rightisblocked:
    movl $30, (blockedPath)

rightcheckdone:
    
    #in case blockedPath > 0, decrement it
    cmpl $0, (blockedPath)
    jle blockedPathDone
    decl (blockedPath)
blockedPathDone:
    
    call updateComplemenetaryFilters

    # return blockedPath != 0
    cmpl $0, (blockedPath)
    jne returnTrue
    jmp returnFalse

returnTrue:
    movb $1, %al
    jmp returnDone

returnFalse:
    movb $0, %al
    jmp returnDone

returnDone:
    popq %r15
    popq %r14
    popq %r13
    popq %r12

    movq %rbp, %rsp
    popq %rbp
    ret


.global cleanupCars
cleanupCars:
    pushq %rbp
    movq %rsp, %rbp

    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    # rcx is the counter
    # rdx is the pointer to the current car
    movq $0, %r13
    movq $cars, %r12
cleanupCarsLoop:
    cmpl %r13d, (carsSize)
    jl cleanupCarsLoopDone

    # check if car exists
    cmpb $1, 20(%r12)
    jne cleanupCarsLoopContinue

    # check that car position < -0.5 * horizontalResolution
    movss 4(%r12), %xmm0
    movss (fm04), %xmm1
    cvtsi2ss (horizontalResolution), %xmm2
    mulss %xmm2, %xmm1
    comiss %xmm1, %xmm0
    jbe removeCarrcl

    # check if car position > 1.5 * horizontalResolution
    movss 4(%r12), %xmm0
    movss (f14), %xmm1
    cvtsi2ss (horizontalResolution), %xmm2
    mulss %xmm2, %xmm1
    comiss %xmm1, %xmm0
    jae removeCarrcl

    # check if car row < currentRow - numberofRowstodraw
    movl (%r12), %eax
    movl (currentRow), %r8d
    subl (numberOfRowsToDraw), %r8d
    cmpl %eax, %r8d
    jl removeCarrcl

    jmp cleanupCarsLoopContinue

removeCarrcl:
    # remove car
    movq %r13, %rdi
    call removeCar
    
cleanupCarsLoopContinue:
    addq $24, %r12
    incq %r13
    jmp cleanupCarsLoop

cleanupCarsLoopDone:
    popq %r15
    popq %r14
    popq %r13
    popq %r12

    movq %rbp, %rsp
    popq %rbp

    ret
