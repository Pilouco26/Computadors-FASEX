@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;==                                                          			=
@;=== Programador tarea 1E: miguel.lopes@estudiants.urv.cat				  ===
@;=                                                         	      	=

@; Mascaras para bajar_verticales
MASK_BUIT= 7
MASK_BLOC = 7
MASK_HUECO = 15
MASK_GELATINA = 7

.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
		.global cuenta_repeticiones
cuenta_repeticiones:

		push {r1-r6, r8, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #MASK_GELATINA				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones
		
		cmp r5, #7
		beq .Lconrep_fin
		cmp r5, #0
		beq .Lconrep_fin
		cmp r3, #0
		beq .Lconrep_este		@; Indicamos la orientacion
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		
		
		.Lconrep_este:
				add r4, #1 			@; Avanzamos una casilla
				cmp r2, #COLUMNS-1
				bge .Lconrep_fin 		@;R4 apunta al elemento (f,c) de 'mat'
				ldrb r8, [r4]
				and r8, #MASK_GELATINA			@; Quitamos el valor de gelatina
				
				cmp r5, r8			@; comparamos el valor incial con el siguiente
				bne .Lconrep_fin			@; Si no es igual, acabamos
				
				add r2, #1			
				add r0, #1			@; Si lo es, sumamos 1 repeticion
				
				b .Lconrep_este
		
		
		
		.Lconrep_oeste:
				sub r4, #1 			@; Retrocedemos una casilla
				cmp r2, #0
				bls .Lconrep_fin 		@;R4 apunta al elemento (f,c) de 'mat'
				ldrb r8, [r4]
				and r8, #MASK_GELATINA				@; Quitamos el valor de gelatina
				
				cmp r5, r8			@; comparamos el valor incial con el siguiente 
				bne .Lconrep_fin			@; Si no es igual, acabamos
				
				sub r2, #1			@; Si lo es, sumamos 1 repeticion
				add r0, #1
				
				b .Lconrep_oeste
		
		
		.Lconrep_sur:
		
			add r4, #COLUMNS 	@; Bajamos una casilla(avanzar 9)
			cmp r1, #ROWS-1
			bge .Lconrep_fin 		@;R4 apunta al elemento (f,c) de 'mat'
			ldrb r8, [r4]		@; Cargamos valor
			and r8, #MASK_GELATINA				@; Quitamos el valor de gelatina
				
			cmp r5, r8			@; comparamos el valor incial con el siguiente 
			bne .Lconrep_fin			
				
			add r1, #1			@; Si lo es, sumamos 1 repeticion
			add r0, #1
				
				b .Lconrep_sur
			
		.Lconrep_norte:

			sub r4, #COLUMNS 	@; Subimos una casilla(retroceder 9)
			cmp r1, #0
			ble .Lconrep_fin 		@;R4 apunta al elemento (f,c) de 'mat'
			ldrb r8, [r4]		@; Cargamos valor
			and r8, #MASK_GELATINA			@; Quitamos el valor de gelatina
				
			cmp r5, r8			@; comparamos el valor incial con el siguiente 
			bne .Lconrep_fin
				
			sub r1, #1			@; Si lo es, sumamos 1 repeticion
			add r0, #1
				
			b .Lconrep_norte
		


		.Lconrep_fin: 
		
			
		pop {r1-r6, r8, pc}


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r4, lr}
		mov r4, r0
		mov r0, #0

		bl baja_verticales
		
		cmp r0, #0
		bleq baja_laterales
		

		pop {r4, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@; 		R2 =  dirección base de la matriz que contiene un numero diferente a 0
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:

		push {r1-r4, r5-r8,lr}
		mov r1, #ROWS
		mov r2, #COLUMNS
		sub r6, r2, #1		
		add r6, r4						@; Primera fila (0,8)
		mov r3, r4						@; Primera casella
		mla r4, r1, r2, r4				@; Apuntem a l'ultima casella
		sub r4, #1
		mov r0, #0						@; Inicialitzem moviments a 0
		
		.LInici:
		ldrb r5, [r4]
		tst r5, #7				@; Comprovem buit
		beq .LPujar				@; Si es buit
		
		.LBucle:
		sub r4, #1				@; Tirem una casella cap a l'esquerra
		cmp r4, r6				@; Comprovem que no estiguem a primera fila
		bgt .LInici		
		cmp r4, r3				@; Comprovem que estiguem dins de la matriu
		blt .Lend			
		ldrb r5, [r4]
		tst r5, #7				@; Comprovem si existeix un buit a primera fila
		beq .Lrandom			@; Si es buit, cridem la funció random
		b .LBucle
		
		.LPujar:
		sub r2, r4, #COLUMNS		@; Pujo 1 casella cap a dalt 
		
		.LVacio:	
		ldrb r1, [r2]			@; Carreguem direccio de la matriu 1 casella per sobre
		cmp r1, #15				@; Comprovem si es un bloc solid
		beq .LBucle	
		cmp r1, #15				@; Comprovem si es un hueco
		beq .LHueco		
		tst r1, #7				@;Comprovem si es un espai
		beq .LBucle				@; Si es un espai, avanço fins trobar un no espai. 
		
		.LIntercanvi: 
		
				mov r8, r1				@; Guardo el numero
				and r1, #MASK_BLOC		@; Elimino gelatina
				sub r8, r1				@; Guardo el tipus de gelatina
				add r1, r5
				strb r8, [r2]			@; Intercanvio el espai/hueco
				strb r1, [r4]			@; Intercanvio el valor
				mov r0, #1				@; moviments = 1
				
				b .LBucle
		
		
		.LHueco:
		sub r2, #COLUMNS			@; Pujem una casella
		cmp r2, r3					@; Comprovem que estiguem dins la matriu
		bge .LVacio					@; Si surt, generem un numero a sota del hueco
		
		.Lrandom: 
		mov r0, #6						@; Rang fins a 5
		bl mod_random
		add r0, #1 						@; Afegim 1 per no generar 0
		add r5, r0 						@; Afegim al 0 el numero generat
		strb r5, [r4]					@; Carreguem el numero en la posició de la matriu desitjada
		mov r0, #1						@; moviment completat
		b .LBucle	
		
		.Lend:


		pop {r1-r4, r5-r8,pc}




@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:

		push {r1-r3, r5-r9,  lr}
		
		
		
		
		pop {r1-r3, r5-r9, pc}



.end
