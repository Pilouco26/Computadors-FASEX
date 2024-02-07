@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=         
@;=== Programador tarea 2G: miguel.lopes@estudiants.urv.cat			  ===
@;=                                                       	        	=

TIMER2_CR = 0x0400010A
TIMER2_DATA = 0x04000108

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: .hword 	-5236			@;divisor de frecuencia para timer 2 freq_entrada maxima possible para hword entre 10(10hz)



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r3, lr}
		
		ldr r0, =timer2_on
		mov r1, #1
		strh r1, [r0]				@; timer2_on=1;
		
		ldr r0, =TIMER2_DATA			@; @timer2_data
		ldr r2, =divFreq2
		ldsh r3, [r2]
		strh r3, [r0]				@; timer2_data = divfreq2;
		
		ldr r0, =TIMER2_CR			@; @timer2_cr
		ldrh r1, [r0]
		ldr r2, =0x00C1
		orr r1, r2					@; bit 6 i 7 activats	
		strh r1, [r0]				@; guardamos informacion a timer2_data	
		
		pop {r0-r3, pc}

@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r1, lr}
		
		ldr r1, =TIMER2_CR		@; @timer2_Cr	
		ldrh r0, [r1]
		mov r0, #0
		strh r0, [r1]		@; bit 7 de timer2_cr esta a 0
		ldr r1, =timer2_on	
		mov r0, #0
		strb r0, [r1] 		@; timer0_on = 0
		
		pop {r0-r1, pc}

@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz 'mat_gel' y, en el caso que el código de
@;	activación (ii) sea mayor que 0, decrementa dicho código en una unidad y
@;	pasa a analizar la siguiente posición de la matriz 'mat_gel';
@;	en el caso que ii sea igual a 0, incrementa su código de metabaldosa y
@;	activa una variable global 'update_gel' para que la RSI de VBlank actualize
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r9, lr}
		
		ldr r0, =mat_gel

		mov r6, #COLUMNS
		mov r7, #GEL_TAM
		mov r1, #0			@; R1: Indice filas
		mov r2, #0 			@; R2: Indice columnas
		mov r9, #0			@; update_gel
		
		
		
		.LFILAS: 
		
		.LCOLUMNAS:
		mla r5, r1, r6, r2		@; R5 = (fil * COLUMNS + col)
		mla r4, r5, r7, r0			@; R4 = @mat_gel + (fil*COLUMNS + col) * GEL_TAM;
		ldsb r8, [r4, #GEL_II]		@; R8 = mat_gel[i][j].ii
		cmp r8, #0
		bgt .LNEXT
		blt .LNEXT2 				@; no hay gelatina
		
		ldsb r3, [r4, #GEL_IM]				@;	imeta = mat_gel[fil,col].im;
		cmp r3, #7
		moveq r3, #-1						@; 7  --> 0
		cmp r3, #15
		moveq r3, #7						@; 15 --> 8
		add r3, #1
		strb r3, [r4, #GEL_IM]				@; GUARDAMOS INDICE METABALDOSAS
		mov r9, #1							@; update_gel =1
		b .LNEXT2
		
		.LNEXT: 
		sub r8, #1
		strb r8, [r4, #GEL_II]		@; guardamos campo
		
		.LNEXT2: 
		add r2, #1
		cmp r2, #COLUMNS
		blo .LCOLUMNAS				@; si el indice es igual a las columnas saltamos de filas
		
		mov r2, #0
		add r1, #1
		cmp r1, #ROWS
		blo .LFILAS					@; si el indice de filas es igual a las filas acabamos rsi
		
		
	
		ldr r0, =update_gel
		strh r9, [r0]
		
		
		pop {r0-r9, pc}

.end
