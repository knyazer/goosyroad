.data

g_no_render: .byte 0
g_static_render: .byte 0
g_playable: .byte 0

g_post: .int 0
g_prev: .int 0
g_current_score: .int 0
g_best_score: .int 0

g_alpha: .int 255

g_width: .int 1000
g_height: .int 1000

g_mouse_x: .int 0
g_mouse_y: .int 0
g_prev_score: .int 0

g_click: .byte 0
g_left: .byte 0
g_right: .byte 0
g_forward: .byte 0
g_backward: .byte 0
g_screen: .quad 0
renderer: .quad 0

currentRow: .float 1
targetRow: .float 1
eps: .float 0.05
numberOfRowsToDraw: .int 12
horizontalResolution: .int 12
playerRow: .int 3
playerColumn: .int 6

playerRowF: .float 3
playerColumnF: .float 6

playerDirection: .int 0

carsSize: .int 100
rocksSize: .int 1000
carsFirstEmpty: .int 0

heroL: .quad 0
heroR: .quad 0
heroSL: .quad 0
heroSR: .quad 0

__: .quad 0
state: .int 1
___: .quad 0
.bss
Sans: .skip 8
rowType: .skip 4000
carTexturesR: .skip 8
carTexturesL: .skip 8
rockTextures: .skip 48
roadTexture: .skip 8
cars: .skip 2400
rocks: .skip 12000
.global rocks
.global cars
.global carTexturesR
.global carTexturesL
.global rockTextures
.global roadTexture

.global rowType
.global carsSize
.global rocksSize
.global carsFirstEmpty
.global playerRow
.global playerColumn
.global playerRowF
.global playerColumnF
.global playerDirection
.global currentRow
.global targetRow
.global eps
.global numberOfRowsToDraw


.global horizontalResolution
.global g_mouse_x
.global g_mouse_y
.global g_click
.global g_left
.global g_right
.global g_forward
.global g_backward
.global g_screen
.global renderer
.global g_width
.global g_height
.global g_alpha

.global g_current_score
.global g_best_score
.global g_prev_score
.global g_post
.global g_prev
.global g_no_render
.global g_static_render
.global g_playable


.global Sans

.global state

.global heroL
.global heroR
.global heroSL
.global heroSR
