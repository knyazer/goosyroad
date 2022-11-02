.data

decimal: .asciz "called: %d\n"

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

    ROADL:  .quad   1

.data
    tempRect:   .quad 0
                .quad 0

.text
# rax, rcx, rdx, rdi, rsi, r8, r9, r10, r11

// gameplay.h methods
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
    call    malloc

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

// funcs.h methods

