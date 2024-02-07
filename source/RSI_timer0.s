@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=== Programador tarea 2E: josep.ribas@estudiants.urv.cat				===
@;=== Programador tarea 2G:	miguel.lopes@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	-5237			@;divisor de frecuencia inicial para timer 0

	@; El contenido de la variable divFreq0 se tiene que calcular para conseguir mover un elemento
	@; de una casilla a otra en menos de 0,35 segundos. Ésta será la velocidad inicial, que se irá 
	@; incrementando a medida que los elementos se muevan, hasta que se paren todo el movimiento.

	@; si Periodo 0,35 seg -> 2,857 Hz -> x32Pixels x casilla = 91,43 Freq de salida minima
	@; establecemos 100Hz (freq de salida) [La cual se irá acelerando]

	@; para la freq entrada, elegiremos el mayor que admita el rango

	@;			Freq Maxima		Freq Minima
	@; 33.513.982 Hz	33.513.982 Hz		511,38 Hz		Necesitamos 100Hz
	@; (FreqBase / 1)							No es posible

	@;			Freq Maxima		Freq Minima
	@; 523.655,96875 Hz	523.656 Hz		7,99 Hz			Necesitamos 100Hz
	@; (FreqBase / 1)							Mejor opción


	@; Divisor de frequencia = - (Freq Entrada/Freq Salida)
	@; Divisor de frequencia = - (523.656/100) = -5237

@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r9, lr}		@; actualizarlo cuando todo el mundo haya puesto su codigo
		
@;Tareas 2Ea
@;rsi_vblank() que debe actualizar los sprites, llamando a la rutina SPR_actualizarSprites() 
@;cuando se haya producido un cambio en la posición o forma de alguno de los sprites del juego, 
@;lo cual se podrá detectar a través de la variable global update_spr declarada dentro del fichero 
@;RSI_timer0.s s. Después de dicha actualización, habrá que desactivar (poner a cero) la variable update_spr spr.

		ldr r2, =update_spr		@; cargamos direccion de update_spr
		ldrh r3, [r2]			@; cargamos el valor
		cmp r3, #0			@; Si update_spr vale 0 no se actualizan los sprites
		beq .LfinTarea2Ea		@; saltamos al final de la parte 2Ea
		.LactuSprites:			@; actualizamos sprites si update_spr vale 1
			ldr r0, =0x07000000			@; En r0 cargamos la direccion oam del procesador grafico
			mov r1, #128				@; En r1 pasamos 128 (# sprites)
			bl SPR_actualizarSprites		@; llamamos a SPR_actualizarSprites para copiar oam_data a
								@; los registros E/S de los sprites activos.
			mov r3, #0				@; movemos 0 a r3
			strh r3, [r2]				@; y ese 0 lo guardamos en r2 update_spr para ponerlo a 0
		.LfinTarea2Ea:

@;Tarea 2Ga

		ldr r0, =update_gel
		ldrh r1, [r0]
		cmp r1, #0
		beq .LFINAL
		
		ldr r9, =mat_gel
		ldr r0, =0x06000000
		mov r6, #COLUMNS
		mov r7, #GEL_TAM
		mov r1, #0			@; R1: Indice filas
		mov r2, #0			@; R2: Indice columnas
		
		.LFILAS: 
		
		.LCOLUMNAS:
		mla r5, r1, r6, r2		    @; R5 = (fil * COLUMNS + col)
		mla r4, r5, r7, r9			@; R4 = @mat_gel + (fil*COLUMNS + col) * GEL_TAM;
		ldsb r8, [r4, #GEL_II]		@; R8 = mat_gel[i][j].ii
		cmp r8, #0					@; if(r8 == 0)
		bne .LNEXT
		
		ldrb r3, [r4, #GEL_IM]		@; R3 = mat_gel.im (indice metabaldosa)
		bl fija_metabaldosa			@; tot be pero a partir de sobte activa gelatines que no ho son
		mov r8, #10					@; campo ii reinicializado a 10
		strb r8, [r4, #GEL_II]		@; mat_gel[i][j].ii = 10;
		
		
		.LNEXT:
		add r2, #1
		cmp r2, #COLUMNS
		blo .LCOLUMNAS				@; si el indice es igual a las columnas saltamos de filas
		
		
		add r1, #1
		mov r2, #0
		cmp r1, #ROWS
		blo .LFILAS					@; si el indice de filas es igual a las filas acabamos rsi
		
		
		ldr r0, =update_gel			
		mov r1, #0
		strh r1, [r0]				@; desactivamos update_gel
		
		.LFINAL:
@;Tarea 2Ha

		
		pop {r0-r9, pc}

@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original 'divFreq0'

@; si init no es 0, el valor de la variable divFreq0 se copiará en otra variable de nombre divF0, además de en 
@; el registro E/S de datos del timer 0

@; si init es 0, no se modificará de ningún modo la variable divF0 ni el 
@; registro E/S de datos del timer 0, ya que se debe mantener el divisor de frecuencia anterior en dichas entidades (variable y registro de E/S).

@; 0400 0100	TIMER0_DATA		Valor del contador; carga de divisor de frecuencia
@; 0400 0102	TIMER0_CR		Registro de control del timer 0

@; 1..0		Prescaler Selection	Indica la frecuencia de entrada requerida:
@;		00-> F/1,
@;		01-> F/64
@;		10-> F/256
@;		11-> F/1.024
@;		donde F = 33.513.982 Hz

@; 2		Count-up Timing		Indica si hay que enlazar el contador con el timer
@;		0 -> No
@;		1 -> Sí
@; 6		Timer IRQ		Enable 0 -> interrupciones desactivadas
@;					       1 -> interrupciones activadas
@; 7		Timer Start/Stop 	0 -> timer parado
@;					1 -> timer en marcha



	.global activa_timer0
activa_timer0:
		push {r0 - r4, lr}
			cmp r0, #0			@; miramos en r0 (init) si es 1 o 0 para mantener o no el div
			beq .Lactivacion		@; Si r0=0-> no cambiamos [divF0..registro E/S timer0]
			.Linicializacion:		@; Si r0=1-> copiamos divFreq0
				ldr r1, =divFreq0
				ldr r3, =divF0
				ldr r4, =0x04000100	@; Cargamos en R4 la direccion en memoria de TIMER0_DATA 0x04000100
				
				ldsh r2, [r1]		@; Cargamos valor de divFreq0 calculado al principio
				
				strh r2, [r3]		@; Guardamos este valor calculado en divF0
				strh r2, [r4]		@; y lo guardamos también en registro E/S de datos.
				
			.Lactivacion:
				ldr r3, =timer0_on	@; cargamos direccion de timer0_on
				mov r0, #1		
				strh r0, [r3]		@; Ponemos a 1 el timer0_on del timer 0
				
				@; Rutina para activar el timer 0 a través de su registro E/S de control
				ldr r1, =0x04000102	@; Cargamos en r1 la direccion en memoria de TIMER0_CR[0x04000102]
				mov r2, #0b11000001	@; ponemos el Prescaler 01 -> F/64 | el Countup a 0 | Interrupciones y timer Start ON (bits 6 y 7)
				strb r2, [r1]		@; lo guardamos en TIMER0_CR
			.Lfin:
		
		pop {r0 - r4, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0 - r2, lr}
			ldr r1, =timer0_on	@; cargamos direccion de timer0_on
			mov r0, #0
			strh r0, [r1]		@; Ponemos a 0 el timer0_on del timer 0
			
			@; Rutina para activar el timer 0 a través de su registro E/S de control
			ldr r1, =0x04000102	@; Cargamos en r1 la direccion en memoria de TIMER0_CR[0x04000102]
			mov r2, #0b00000001	@; ponemos el Prescaler 01 -> F/64 | el Countup a 0 | Interrupciones y timer Start OFF (bits 6 y 7)
			strb r2, [r1]		@; lo guardamos en TIMER0_CR
		pop {r0 - r2, pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector 'vect_elem' y, en el caso que el código de
@;	activación (ii) sea mayor que 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas;
@;	si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).


@; Recorrer los n_sprites iniciales del vector de elementos vect_elem[] y actualizar 
@; la posición de los sprites activos, a partir de los siguientes pasos: 

@; • si el campo ii del elemento analizado está desactivado (-1) o vale 0, ignorar ese elemento
@; • en otro caso, decrementar el valor del campo ii y actualizar los campos de posición px y 
@; py según el valor de los campos de velocidad vx y vyvy
@; • actualizar la posición del sprite correspondiente al elemento analizado, llamando 
@; a la rutina SPR_moverSprite() 
@; • si se ha movido algún elemento, activar la variable update_spr y reducir el divisor de 
@; frecuencia del timer para provocar el efecto de aceleración, evitando superar cierto límite
@;  de velocidad máxima (a fijar según criterio del programador)
@; • si no se ha movido ningún elemento, invocar a desactivar_timer0() timer0(), lo cual 
@; provocará la puesta a cero de la variable timer0_on on.


	.global rsi_timer0
rsi_timer0:
		push {r0 - r12, lr}
			ldr r3, =n_sprites	@; r3 -> direccion de n_sprites
			ldr r4, [r3]		@; r4 -> valor n_sprites
			ldr r5, =vect_elem	@; r5 -> direccion elemento 0 de vector vect_elem
			mov r0, #0 			@; r0 -> indice [i = 0]	
			mov r6, #0			@; r6 -> bool para saber si ha habido movimiento o no
			.Lrecor_vectElem:
				ldsh r8, [r5, #ELE_II]			@; r8 = elem.ii
				cmp r8, #0				@; comparamos con 0 el elem.ii
				ble .LsigElem				@; miramos si es -1(desact) o 0 para ignorar el elemento y saltar al final (cmp enteros)
				@;cmp r6, #0	FUNCIONA SIN?		@; si hay 0 en el r6
				moveq r6, #1 				@; lo ponemos a 1 para indicar que vamos a mover al menos un elemento
				.Lmovimiento:
					sub r8, #1			@; Disminuimos en 1 ii que es el numero de interrupciones pendientes (0..32)/(-1 desact)
					strh r8, [r5, #ELE_II]		@; cargamos en r8 el elem.ii del vect_elem
					
					@; Carga de los valores de posicion  (X Y) y velocidad (X Y) del elemento de la matriz
					
					ldsh r1, [r5, #ELE_PX]		@; r1 = Pos X elem
					ldsh r2, [r5, #ELE_PY]		@; r2 = Pos Y elem
					ldsh r9, [r5, #ELE_VX]		@; r9 = Vel X elem
					ldsh r10, [r5, #ELE_VY]		@; r10 = Vel Y elem
					
					@; Actualizamos la posicion X Y con las velocidades

					add r1, r9			@; PosX = PosX + VelX
					add r2, r10			@; PosY = PosY + VelY
					strh r1, [r5, #ELE_PX]		@; r1 -> almacenamos con la posicion X actualizada
					strh r2, [r5, #ELE_PY]		@; R2 -> almacenamos con la posicion Y actualizada

					@; Llamamos a la funcion SPR_moverSprite para mover el sprite 
					@; Parametros --> [r0 = indice // r1 = PosX // r2 = PosY]

					bl SPR_moverSprite		@; llamamos funcion SPR_moverSprite

				.Lfinmov:
				
			.LsigElem:
				cmp r0, r4				@; comparamos el indice con el numero de sprites, y en el caso que el indice sea menor:
				addlo r0, #1				@; Actualizamos el indice, sumandole 1
				addlo r5, #ELE_TAM			@; Sumandole ELE_TAM, pasamos al siguiente elemento de la matriz vect_elem
				blo .Lrecor_vectElem			@; saltamos al siguiente elemento
				
				cmp r6, #0				@; Si no hemos movido ningun elemento en todos los n_sprites->desactivamos el timer0
				beq .Lllamada_desactiva			@; saltamos al final a desactivar el timer y a fin de RSI_timer0
				ldr r11, =update_spr			@; Si no, hemos movido algun elemento, y por tanto, tenemos que actu sprites 
				mov r12, #1				@; por tanto cargamos en r11 direccion "update_sprites", y le ponemos 1 a r12
				strh r12, [r11]				@; y actualizamos con el valor

				@;Cambio de frequencia para la aceleracion
				ldr r11, =divF0				@; cargamos la direccon de la frecuencia en r11
				ldsh r12, [r11]				@; cargamos el valor en r12

				@; Aceleracion de velocidad: 
				@; si Periodo 0,35 seg -> 2,857 Hz -> x32Pixels x casilla = 91,43 Freq de salida minima
				@; establecemos 100Hz (freq de salida)[La cual se irá acelerando] -> Devisor maximo -5237
				
				@; Si aumentamos de 60 en 60, y se moveran 32 sprites como maximo, cambiará de -5237 hasta -3317
				@; dado que se aumentara como mucho a 60*32 =1920, obteniendo una frecuencia de salida de 157,87 Hz
				add r12, #60
				strh r12, [r11]				@; guardamos el nuevo valor en la direccion de la frecuencia
				ldr r11, =0x04000100		@; cargamos la direccion del TIMER0_DATA -> carga de divisor de frecuencia
				strh r12, [r11]				@; Guardamos el nuevo divisor en TIMER0_DATA
				b .LfinalRSI0				@; saltamos al final del timer0
				
			.Lllamada_desactiva:
				bl desactiva_timer0		@; Desactivamos el timer0.
			.LfinalRSI0:
		pop {r0 - r12, pc}
.end
