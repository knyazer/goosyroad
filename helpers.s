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
