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
    
