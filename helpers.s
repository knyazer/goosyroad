.text

.global getCorrectRockTextureWithI

getCorrectRockTextureWithI:
    movq $0, %rax
    movl %edi, %eax
    movl $8, %ecx
    mul %ecx
    addq $rockTextures, %rax
    movq (%rax), %rax
    ret

.global getCars

getCars:
    movq $cars, %rax
    ret

.global getRocks

getRocks:
    movq $rocks, %rax
    ret
    
.global setRocksSize

setRocksSize:
    movq $0, %rax
    movl %edi, (rocksSize)
    ret

.global getCarsFirstEmpty

getCarsFirstEmpty:
    movq $0, %rax
    movl (carsFirstEmpty), %eax
    ret

.global setCarsFirstEmpty

setCarsFirstEmpty:
    movq $0, %rax
    movl %edi, (carsFirstEmpty)
    ret

.global getGNoRender

getGNoRender:
    movq $0, %rax
    movl $0, %eax
    movb (g_no_render), %al
    ret

.global getGStaticRender

getGStaticRender:
    movq $0, %rax
    movl $0, %eax
    movb (g_static_render), %al
    ret

.global getGHeight

getGHeight:
    movq $0, %rax
    movl (g_height), %eax
    ret

.global getHeroL

getHeroL:
    movq (heroL), %rax
    ret

.global getHeroR

getHeroR:
    movq (heroR), %rax
    ret

.global getHeroSL

getHeroSL:
    movq (heroSL), %rax
    ret

.global getHeroSR

getHeroSR:
    movq (heroSR), %rax
    ret

.global getGWidth

getGWidth:
    movq $0, %rax
    movl (g_width), %eax
    ret

.global getRenderer

getRenderer:
    movq (renderer), %rax
    ret

.global getRoadTexture

getRoadTexture:
    movq (roadTexture), %rax
    ret

.global getHorizontalResolution

getHorizontalResolution:
    movq $0, %rax
    movl (horizontalResolution), %eax
    ret

.global getPlayerDirection

getPlayerDirection:
    movq $0, %rax
    movl (playerDirection), %eax
    ret

.global getRockTextures

getRockTextures:
    movq (rockTextures), %rax
    ret

.global getNumberOfRowsToDraw

getNumberOfRowsToDraw:
    movq $0, %rax
    movl (numberOfRowsToDraw), %eax
    ret

.global getCurrentRow

getCurrentRow:
    movq $0, %rax
    cvtss2si (currentRow), %eax
    ret

.global getCorrectRockDrawY

getCorrectRockDrawY:
    movq $0, %rax
    movl %edi, %eax
    movq $12, %rcx
    mul %rcx
    addq $rocks, %rax
    movl (%rax), %r10d
    cvtsi2ss %r10d, %xmm0
    movss (currentRow), %xmm1
    subss %xmm1, %xmm0
    
    cvtsi2ss (numberOfRowsToDraw), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, %xmm0

    # rax = g_height / numberOfRowsToDraw
    cvtsi2ss (g_height), %xmm1
    cvtsi2ss (numberOfRowsToDraw), %xmm2
    divss %xmm2, %xmm1
    mulss %xmm1, %xmm0
    cvtss2si %xmm0, %eax

    movl %eax, %r8d

    movl %esi, %eax
    movq $0, %rdx
    movl $2, %ecx
    div %rcx
    
    subl %eax, %r8d
    
    movq $0, %rax
    movl %r8d, %eax
    ret

.global getCarX

getCarX:
    # rdi = carIndex
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rcx
    mul %rcx
    addq $cars, %rax
    movl (%rax), %eax
    
    movss 4(%rax), %xmm0
    cvtsi2ss (g_width), %xmm1
    mulss %xmm1, %xmm0
    cvtsi2ss (horizontalResolution), %xmm1
    divss %xmm1, %xmm0
    cvtss2si %xmm0, %eax
    ret

.global getCarY

getCarY:
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rcx
    mul %rcx
    addq $cars, %rax
    movl (%rax), %r10d
    cvtsi2ss %r10d, %xmm0
    movss (currentRow), %xmm1
    subss %xmm1, %xmm0
    
    cvtsi2ss (numberOfRowsToDraw), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, %xmm0

    # rax = g_height / numberOfRowsToDraw
    cvtsi2ss (g_height), %xmm1
    cvtsi2ss (numberOfRowsToDraw), %xmm2
    divss %xmm2, %xmm1
    mulss %xmm1, %xmm0
    cvtss2si %xmm0, %eax

    movl %eax, %r8d

    movl %esi, %eax
    movq $0, %rdx
    movl $2, %ecx
    div %rcx
    
    subl %eax, %r8d
    
    movq $0, %rax
    movl %r8d, %eax
    ret

.global getCarsRowType

getCarsRowType:
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rcx
    mul %rcx
    addq $cars, %rax
    movl (%rax), %r10d

    movq $0, %rax
    movl %r10d, %eax
    movq $4, %rcx
    mul %rcx
    addq $rowType, %rax
    movl (%rax), %eax
    ret

.global getCarTextureR

getCarTextureR:
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rcx
    mul %rcx
    addq $cars, %rax
    movl 8(%rax), %r10d

    movq $0, %rax
    movl %r10d, %eax
    movq $8, %rcx
    mul %rcx
    addq $carTexturesR, %rax
    movq (%rax), %rax
    ret

.global getCarTextureL

getCarTextureL:
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rcx
    mul %rcx
    addq $cars, %rax
    movl 8(%rax), %r10d

    movq $0, %rax
    movl %r10d, %eax
    movq $8, %rcx
    mul %rcx
    addq $carTexturesL, %rax
    movq (%rax), %rax
    ret

.global getGPlayable

getGPlayable:
    movq $0, %rax
    movb (g_playable), %al
    ret

.global getPlayerRowF

getPlayerRowF:
    movss (playerRowF), %xmm0
    ret

.global getPlayerRow

getPlayerRow:
    movq $0, %rax
    movl (playerRow), %eax
    ret

.global getPlayerColumnF

getPlayerColumnF:
    movss (playerColumnF), %xmm0
    ret

.global getPlayerColumn

getPlayerColumn:
    movq $0, %rax
    movl (playerColumn), %eax
    ret

.global getFloatCurrentRow

getFloatCurrentRow:
    movss (currentRow), %xmm0
    ret

.global getGPost

getGPost:
    movq $0, %rax
    movl (g_post), %eax
    ret

.global getGPrev

getGPrev:
    movq $0, %rax
    movl (g_prev), %eax
    ret

.global setGPost

setGPost:
    movl %edi, (g_post)
    ret

.global setGPrev

setGPrev:
    movl %edi, (g_prev)
    ret

.global setGPrevScore

setGPrevScore:
    movl %edi, (g_prev_score)
    ret

.global getGPrevScore

getGPrevScore:
    movq $0, %rax
    movl (g_prev_score), %eax
    ret

.global getGCurrentScore

getGCurrentScore:
    movq $0, %rax
    movl (g_current_score), %eax
    ret

.global setGCurrentScore

setGCurrentScore:
    movl %edi, (g_current_score)
    ret

.global getGBestScore

getGBestScore:
    movq $0, %rax
    movl (g_best_score), %eax
    ret

.global setGBestScore

setGBestScore:
    movl %edi, (g_best_score)
    ret

.global getState

getState:
    movq $0, %rax
    movl (state), %eax
    ret

.global setState

setState:
    movl %edi, (state)
    ret

.global getGClick

getGClick:
    movq $0, %rax
    movb (g_click), %al
    ret

.global getGAlpha

getGAlpha:
    movq $0, %rax
    movl (g_alpha), %eax
    ret

.global getGScreen

getGScreen:
    movq $0, %rax
    movl (g_screen), %eax
    ret

.global getRectY

.data
f05: .float 0.5
.text
getRectY:
    cvtsi2ss %edi, %xmm0
    movss (currentRow), %xmm1
    subss %xmm1, %xmm0
    
    cvtsi2ss (numberOfRowsToDraw), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, %xmm0
    movss (f05), %xmm1
    subss %xmm1, %xmm0

    # rax = g_height / numberOfRowsToDraw
    cvtsi2ss (g_height), %xmm1
    cvtsi2ss (numberOfRowsToDraw), %xmm2
    divss %xmm2, %xmm1
    mulss %xmm1, %xmm0
    cvtss2si %xmm0, %eax

    movl %eax, %r8d
    movq $0, %rax
    movl %r8d, %eax
    ret

.global makeCarPosition

.data
fm04: .float -0.4
f14: .float 1.4

.text

makeCarPosition:
    # get rowType[rdi]
    movq $0, %rax
    movl %edi, %eax
    movq $4, %rcx
    mul %rcx
    addq $rowType, %rax
    movl (%rax), %r10d

    cmp $1, %r10d
    jne mcpleft
    
    cvtsi2ss (horizontalResolution), %xmm0
    movss (fm04), %xmm1
    mulss %xmm1, %xmm0
    ret

mcpleft:
    cvtsi2ss (horizontalResolution), %xmm0
    movss (f14), %xmm1
    mulss %xmm1, %xmm0
    ret

.global getRenderPlayY

getRenderPlayY:
    movq %rdi, %r10
    movss (currentRow), %xmm1
    subss %xmm1, %xmm0
    
    cvtsi2ss (numberOfRowsToDraw), %xmm1
    subss %xmm0, %xmm1
    movss %xmm1, %xmm0

    # rax = g_height / numberOfRowsToDraw
    cvtsi2ss (g_height), %xmm1
    cvtsi2ss (numberOfRowsToDraw), %xmm2
    divss %xmm2, %xmm1
    mulss %xmm1, %xmm0
    cvtss2si %xmm0, %eax

    movl %eax, %r8d

    movl %r10d, %eax
    movq $0, %rdx
    movl $2, %ecx
    div %rcx
    
    subl %eax, %r8d
    
    movq $0, %rax
    movl %r8d, %eax
    ret

.global setGAlpha

setGAlpha:
    movl %edi, (g_alpha)
    ret

.global setGStaticRender

setGStaticRender:
    movb %dil, (g_static_render)
    ret

.global setGPlayable

setGPlayable:
    movb %dil, (g_playable)
    ret

.global getRowType

getRowType:
    movq $rowType, %rax
    ret

.global cfPart

cfPart:
    # cfPart(int* a, float * b)
    # if (*a > *b + eps) 
    # *b += eps;
    
    movl (%rdi), %eax
    cvtsi2ss %eax, %xmm0
    movss (%rsi), %xmm1
    movss (eps), %xmm2
    addss %xmm2, %xmm1
    ucomiss %xmm1, %xmm0
    ja cfpart1

    # if (*a < *b - eps)
    # *b -= eps;
    movss (eps), %xmm2
    subss %xmm2, %xmm1
    ucomiss %xmm1, %xmm0
    jb cfpart2

    ret

cfpart1:
    movss %xmm1, (%rsi)
    ret

cfpart2:
    movss (eps), %xmm0
    subss %xmm0, %xmm1
    movss %xmm1, (%rsi)
    ret

.global updateComplemenetaryFilters

.data
f3: .float 3.0
f005: .float 0.05
f0005: .float 0.005
f98: .float 0.98
f02: .float 0.02

.text
updateComplemenetaryFilters:
    # cfPart(&playerRow, &playerRowF)
    movq $playerRow, %rdi
    movq $playerRowF, %rsi
    call cfPart
    # cfPart(&playerColumn, &playerColumnF)
    movq $playerColumn, %rdi
    movq $playerColumnF, %rsi
    call cfPart

    # if (!g_no_render && playerRowF > (currentRow + 3))
    #       functionCall();
    movb (g_no_render), %al
    test %al, %al
    jne ucf1

    movss (playerRowF), %xmm0
    movss (currentRow), %xmm1
    movss (f3), %xmm2
    addss %xmm2, %xmm1
    ucomiss %xmm1, %xmm0
    ja updatecomplemenetaryfilters2
    jmp ucf1

updatecomplemenetaryfilters2:
    # targetRow += 0.05 * ((playerRowF - currentRow - 3) / numberOfRowsToDraw);
    movss (playerRowF), %xmm0
    movss (currentRow), %xmm1
    movss (f3), %xmm2
    addss %xmm2, %xmm1
    subss %xmm1, %xmm0
    cvtsi2ss (numberOfRowsToDraw), %xmm1
    divss %xmm1, %xmm0
    movss (f005), %xmm1
    mulss %xmm1, %xmm0
    movss (targetRow), %xmm1
    addss %xmm1, %xmm0
    movss %xmm0, (targetRow)

ucf1:
    # if (!g_no_render)
    #    targetRow += 0.005
    movb (g_no_render), %al
    test %al, %al
    jne ucf2
    
    movss (targetRow), %xmm0
    movss (f0005), %xmm1
    addss %xmm1, %xmm0
    movss %xmm0, (targetRow)
    
ucf2:
    # currentRow = 0.98 * currentRow + 0.02 * targetRow;
    movss (currentRow), %xmm0
    movss (f98), %xmm1
    mulss %xmm1, %xmm0
    movss (targetRow), %xmm1
    movss (f02), %xmm2
    mulss %xmm2, %xmm1
    addss %xmm1, %xmm0
    movss %xmm0, (currentRow)

    ret

.global getComplexAndCondition

.data
fm25: .float -0.25
f25: .float 0.25
.text

.global gcac1

gcac1:
    movq $cars, %r8
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rdx
    mul %rdx
    addq %r8, %rax
    movq %rax, %r8
    
    # if 20(%r8) == 1 -> return 1
    # else return 0
    movb 20(%r8), %al
    test %al, %al
    jne gcac1_second
    movq $0, %rax
    ret

gcac1_second:
    movq $1, %rax
    ret


.global gcac3

gcac3:
    movq $cars, %r8
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rdx
    mul %rdx
    addq %r8, %rax
    movq %rax, %r8

    # if float(4(%r8)) < playerColumnF -> return 1
    # else return 0
    movss 4(%r8), %xmm0
    movss (playerColumnF), %xmm1
    ucomiss %xmm1, %xmm0
    jb gcac3_second
    movq $0, %rax
    ret

gcac3_second:
    movq $1, %rax
    ret

.global gcac4

gcac4:
    movq $cars, %r8
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rdx
    mul %rdx
    addq %r8, %rax
    movq %rax, %r8
    
    # if float(4(%r8)) + float(16(%r8)) > playerColumnF -> return 1
    # else return 0
    movss 4(%r8), %xmm0
    movss 16(%r8), %xmm1
    addss %xmm1, %xmm0
    movss (playerColumnF), %xmm1
    ucomiss %xmm1, %xmm0
    ja gcac4_second
    movq $0, %rax
    ret

gcac4_second:
    movq $1, %rax
    ret

.global gcac21

gcac21:
    movq $cars, %r8
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rdx
    mul %rdx
    addq %r8, %rax
    movq %rax, %r8
    
    # if float((%r8)) < playerRowF + 0.25 -> return 1
    # else return 0

    cvtsi2ssl (%r8), %xmm0
    movss (playerRowF), %xmm1
    movss (f25), %xmm2
    addss %xmm2, %xmm1
    ucomiss %xmm1, %xmm0
    jb gcac21_second
    movq $0, %rax
    ret

gcac21_second:
    movq $1, %rax
    ret

.global gcac22

gcac22:
    movq $cars, %r8
    movq $0, %rax
    movl %edi, %eax
    movq $24, %rdx
    mul %rdx
    addq %r8, %rax
    movq %rax, %r8
    
    # if float((%r8)) > playerRowF - 0.25 -> return 1
    # else return 0

    cvtsi2ssl (%r8), %xmm0
    movss (playerRowF), %xmm1
    movss (fm25), %xmm2
    addss %xmm2, %xmm1
    ucomiss %xmm1, %xmm0
    ja gcac22_second
    movq $0, %rax
    ret

gcac22_second:
    movq $1, %rax
    ret

.global gcac2

gcac2:
    pushq %r12
    movq $0, %r12

    call gcac21
    addq %rax, %r12
    call gcac22
    addq %rax, %r12

    cmpq $2, %r12
    jne gcac2_second
    movq $1, %rax
    popq %r12
    ret

gcac2_second:
    movq $0, %rax
    popq %r12
    ret


.global getComplexAndCondition

getComplexAndCondition:
    pushq %r12
    movq $0, %r12

    call gcac1
    addq %rax, %r12
    call gcac2
    addq %rax, %r12
    call gcac3
    addq %rax, %r12
    call gcac4
    addq %rax, %r12

    cmpq $4, %r12
    jne getComplexAndCondition_second
    movq $1, %rax
    popq %r12
    ret

getComplexAndCondition_second:
    movq $0, %rax
    popq %r12
    ret

.global setRenderer

setRenderer:
    movq %rdi, (renderer)
    ret

.global createRenderer

createRenderer:
    pushq %rbp
    movq %rsp, %rbp

    movl $-1, %esi
    movl $2, %edx
    call SDL_CreateRenderer
    movq %rax, (renderer)

    movq %rbp, %rsp
    popq %rbp
    ret

.global getSDL_Quit

getSDL_Quit:
    movq $256, %rax
    ret

.global getSDL_MouseMotion

getSDL_MouseMotion:
    movq $1024, %rax
    ret

.global getSDL_MouseButtonUp
    
getSDL_MouseButtonUp:
    movq $1026, %rax
    ret

.global getSDL_MouseButtonDown

getSDL_MouseButtonDown:
    movq $1025, %rax
    ret

.global getSDL_KeyUp

getSDL_KeyUp:
    movq $769, %rax
    ret

.global getSDL_KeyDown

getSDL_KeyDown:
    movq $768, %rax
    ret

.global makeSDLColor

makeSDLColor:
	pushq	%rbp
	movq	%rsp, %rbp

	subq	$16, %rsp
	movq $0, %rax
	movl	%edi, %eax
	movb	%al, -12(%rbp)
	movl	%esi, %eax
	movb	%al, -11(%rbp)
	movl	%edx, %eax
	movb	%al, -10(%rbp)
	movl	-12(%rbp), %eax

    movq %rbp, %rsp
    popq %rbp
    ret

.global getMotionX

getMotionX:
    movl 20(%rdi), %eax
    ret

.global getMotionY

getMotionY:
    movl 24(%rdi), %eax
    ret

.global getScancode

getScancode:
    movl 16(%rdi), %eax
    ret
