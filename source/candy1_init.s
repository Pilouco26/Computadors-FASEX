@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: josep.ribas@estudiants.urv.cat			  ===
@;=== Programador tarea 1B: josep.ribas@estudiants.urv.cat		      ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinaci�n: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuraci�n indicado por par�metro (a
@;	obtener de la variable global 'mapas'), y despu�s cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = numero de mapa de configuraci�n
@;	Variables:
@;		R1= luego la usamos de i
@;		R2 = j
@;		R3 = Orientacion para "cuenta_repeticiones"
@;		R4 = Auxiliar para guardar la direcci�n base de la matriz de juego
@;		R5 = Saltos necesarios para el primer valor de la matriz deseada
@;		R6 = Auxiliar bucle 1
@;		R7 = Auxiliar bucle recorrido
@;		R8 = Valor de la matriz[i][j]
@;		R9 = ROWSxCOLUMNS
@;		R10 = Variable global mapas


	.global inicializa_matriz
inicializa_matriz:

		push {r0-r10, lr}		@;guardar registros utilizados r0-r5, r7-r10

		
		@; Obtenci�n de mapa de juego y inicializaci�n de variables
		
		ldr r10, =mapas			@; En r10 cargamos la direcci�n base de los mapas (matrices de juegos)
		mov r9, #ROWS*COLUMNS	@; Almacenamos ROWS*COLUMNS en r9
		mul r5, r1, r9			@; En r5 almacenamos los saltos para tener la matriz de juego(obtenida 
								@; de multiplicar ((ROWS*COLUMNS[r9]) * NumMatrizJuego[r1])
		add r10, r5				@; en r10 almacenamos la direcci�n base de la matriz de la partida
								@; obtenida de sumar la @B de los mapas + valor obtenido en r5
		mov r1, #0				@; Inicializamos a 0 r1 para utilizarlo como i
		mov r4, r0				@; Copia de la @Base para no perderla al utilizar mod_random
		
		@; Recorrido a matriz de juego
		mov r7, #0				@; Inicializamos a 0 la variable auxiliar para el recorrido
		
	.Lfori:						@; Bucle for para i
		mov r2, #0				@; Reiniciamos el valor de la j a 0
			
	.Lforj:						@; Bucle for para j
		ldrb r8, [r10, r7]		@; r8 = matriz[i][j] (@BMatriz r10 + despl r7) 
			
	.Lif:						@; con mascaras comprobamos si los 3 bits de menor peso son 0
		tst r8, #7				@; comparamos r8 con la mascara 111 y activa el flagZ en caso de GG000 (0, 8, 16)
		beq .Laleatoris			@; salto a .Laleatoris si flagZ activado
		
	.Lelse:
		strb r8, [r0, r7]		@; Si no se cumple, se almacena directamente el valor obtenido
		b .Lfiif				@; Fin de condicional
			
	.Laleatoris:				@; Numero aleatorio si el valor es 0xXX000
		mov r0, #6				@; Movemos a r0 el valor 6 para indicar el valor maximo que obtenemos
								@; con random 
		bl mod_random			@; llamamos a mod_random para obtener valor (0 a n-1) -> n = r0
		add r0, #1				@; Queremos r0 = 1 a 6, con random obtenemos 0 a 5, por lo tanto, +1
		add r8, r0				@; Sumamos a r8, ese valor + el random para no perder gelatinas
		mov r0, r4				@; devolvemos la @Base de matriz de juego guardada en r4
		strb r8, [r0, r7]		@; almacenamos el valor obtenido en @r0 + despl r7
		ldr r8, [r10, r7] 		@; Volvemos a obtener el valor para que en el caso que haya una 
								@; secuencia, crear otro aleatorio y no perder la gelatina
									
		mov r3, #2				@; A r3 que se usa para la orientaci�n, le pasamos 2 para mirar Oeste
		bl cuenta_repeticiones	@; Llamamos a cuenta repeticiones con r0 (matriz juego), r1 (i),
									@; r2 (j) i r3 con valor #2 para comprobar direcci�n Oeste
		cmp r0, #3				@; En r0 guardamos el numero de repeticiones obtenidas en 
								@; cuenta_repeticiones 
		bhs .Laleatoris			@; En caso que sea 3 o mas, buscamos otro numero aleatorio
			
		mov r0, r4
		mov r3, #3				@; Realizamos la misma comprovacion, pero para orientacion Norte
		bl cuenta_repeticiones	@; cuenta_repeticiones, mismos valores excepto la orientacion(Norte)
		cmp r0, #3				@; Con esta orientaci�n comprobamos si es 3 el valor obtenido
		bhs .Laleatoris			@; En caso de que sea 3 o mas, buscamos otro numero aleatorio
								@; SOLO para Oeste y Norte (Sur y Este no tienen valores aun)
		mov r0, r4				@; En r0 almacenamos otra vez @Base de matriz guardada en r4
			
	.Lfiif:
		add r7, #1				@; Aumentamos 1 en el desplazamiento para la direccion base de la matriz
		add r2, #1				@; Aumentamos 1 en el indice j para el bucle
		cmp r2, #COLUMNS		@; Comprobamos si hemos acabado el recorrido de la j
		blo .Lforj				@; Cierra bucle j
		add r1, #1				@; Aumentamos 1 en el indice i para el bucle
		cmp r1, #ROWS			@; Comprobamos si hemos acabado el recorrido de la i
		blo .Lfori				@; Cierra bucle i
			


	pop {r0-r10, pc}			@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicaci�n de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiar� la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocar� la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocar� la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocar� la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondr� que siempre existir� una recombinaci�n sin secuencias y
@;			con combinaciones
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Variables:
@;		R1 = i
@;		R2 = j
@;		R3 = Orientacion para "cuenta_repeticiones" (tambien lo utilizamos como auxiliar para guardar 0 una vez un elemento ha sido utilizado)
@;		R4 = Direccion base Mat_recomb1
@;		R5 = Direccion base Mat_recomb2
@;		R6 = Auxiliar para guardar la direcci�n base de la matriz de juego
@;		R7 = Desplazamiento de la matriz de juego
@;		R8 = Valor auxiliar para las mat_recomb (para gelatinas por ejemplo)
@;		R9 = Primero Auxiliar para comando AND, luego Auxiliar para guardar posicion aleatoria
@;		R10 = Contador para evitar bucles infinitos de elementos que no sirven
@;		R11 = Auxiliar matriz[i][j] para valor mat_recomb
@;		R12 = Contador para evitar bucles infinitos cuando no hay combinacion

	.global recombina_elementos
recombina_elementos:
		push {r0-r12, lr}
		
		mov r12, #50			@; inicializamos el contador de bucles a 40
		b .Linicio				@; saltamos al inicio del codigo
		
	.Levitarbucle:
		
		sub r12, #1				@; restamos 1 al contador de bucles infinito cuando no hay combinacion
		cmp r12, #0				@; comparamos con 0 el contador anterior
		beq .Lfin				@; si ha llegado a 0, saltamos al final y devolvemos la matriz igual
		
	.Linicio:
	
		mov r6, r0					@; guardamos direcc base matriz en r6 para no perderla
		ldr r4, =mat_recomb1		@; cargamos mat_recomb1 en r4
		ldr r5, =mat_recomb2		@; cargamos mat_recomb2 en r5
		mov r1, #0					@; i = 0
		mov r10, #600				@; Guardamos 600 en un contador para evitar bucles infinitos
		mov r7, #0					@; desplazamiento = 0
	
	.Lforirecor:
		mov r2, #0					@; j = 0
		
	.Lforjrecor:
		ldrb r11, [r6, r7]			@; valor de la matriz de juego[i][j] en r11
		strb r11, [r4, r7]			@; Valor de matriz de juego a matrizrecomb1
		strb r11, [r5, r7]			@; Valor de matriz de juego a matrizrecomb2
		
	.Lifvalor:
		ands r9, r11, #7			@; Realizamos un AND de r11(valor cargado) con la mascara 0b111 y guardamos este en r9	
		beq .Lnoalter				@; Saltamos a noalter si es un elemento aleatorio (GG000) -> (0,8,16)
		cmp r9, #7					@; comparamos valor de AND con la marcara
		beq .Lnoalter				@; Saltamos a noalter si es un solido(7) o hueco(15)
		tst r11, #0b00011000		@; comparamos valor de la matriz con 24(#0b00011000) para quedarnos con el codigo de la gelatina (en caso de haberlo) 
									@; nos sirve para saber si tenemos gelatina(simple o doble con valor)
		bne .Lgelsd
		b .Lelembas					@; Si no es ninguno de los casos anteriores, llegara aqui y significa que tenemos elemento basico
	
	.Lnoalter:						@; saltamos a esta instruccion si es un bloque solido, hueco, gel simp o doble vacia
		mov r8, #0					@; guardamos 0 en r8
		strb r8, [r4, r7]			@; guardamos en matrecomb1 el 0 puesto que es un elemento mencionado anteriormente
									@; En matrecomb2 el valor de r11 ya est�
		b .Lactuind
	
	.Lgelsd:						@; En estas instrucciones llegamos si tenemos gelatina simple o doble
		and r8, r11, #0b00011000	@; Obtenemos el valor de la gelatina con la mascara 111000 (24) y guardamos en r8
		strb r9, [r4, r7]			@; Guardamos el valor del elemento base en matrecomb1
		strb r8, [r5, r7]			@; Guardamos el valor de la gelatina simple o doble en matrecomb2
		b .Lactuind
		
	.Lelembas:						@; Si es un elemento basico [1-6], guardamos 0 en matrecomb2
		mov r8, #0					@; guardamos 0 en r8
		strb r8, [r5, r7]			@; El 0 lo guardamos en matrecomb2
		b .Lactuind					@; Saltamos a actualizar los indices
	
	.Lactuind:
		add r7, #1					@; Actualizar el desplazamiento de la matriz
		add r2, #1					@; j=j+1
		cmp r2, #COLUMNS			@; j = columns?
		blo .Lforjrecor				@; Si j<columns, saltamos al for j del recorrido (salto A<B naturales)
		add r1, #1					@; i=i+1
		cmp r1, #ROWS				@; i=ROWS?
		blo .Lforirecor				@; Si i<rows, saltamos al for i del recorrido (salto A<B naturales)
		
		@; indices = 0
		mov r1, #0					@; i = 0
		mov r7, #0					@; despl = 0
		
	.Lforirecor2:
		mov r2, #0					@; j = 0
		
	.Lforjrecor2:
		ldrb r11, [r6, r7]			@; r11 <-@Matr+despl 
		ands r9, r11, #7			@; Hacemos un AND del valor de la matriz con 7
		beq .Lactuind2				@; Saltamos a noalter si es un bloque solido (0,8,16)
		cmp r9, #7					@; comparamos AND con 7 (Saltara si es un 7 o 15)
		beq .Lactuind2				@; Saltamos a noalter si es un solido o hueco
		
	.Lcambioelem:
		mov r0, #ROWS*COLUMNS		@; En r0 movemos ROWSxCOLUMNS (para opbtener desplazamiento aleatorio)
		bl mod_random				@; En r0 obtenemos numero aleatorio para el desplazamiento
		mov r9, r0					@; En r9 guardamos la posicion aleatoria obtenida
		ldrb r11, [r4, r9]			@; en r11 cargamos el valor obtenido de mat_recomb1 con el desplazamiento obtenido anteriormente en r0
		cmp r11, #0					@; Comprobamos que el valor no sea 0
		beq .Lcambioelem			@; Caso afirmativo, volvemos a buscar otro valor
		
		ldrb r8, [r5, r7]			@; En r8 almacenamos si hay gelatina de mat_recomb2
		add r11, r8					@; Le sumamos el valor al valor aleatorio obtenido
		strb r11, [r5, r7]			@; Almacenamos la suma obtenida en la matriz mat_recomb2
		mov r3, #2					@; Al guardar 2 en r3(orientacion), miraremos con cuenta repeticiones la orientacion oeste
		mov r0, r5					@; A r0 pasamos mat_recomb2(miraremos si hay repeticiones en esa matriz)
		bl cuenta_repeticiones		@; En cuenta_repeticiones, comprobamos si hay combinacion
		
		cmp r0, #3					@; Comprobamos si hay secuencia, si la hay, tenemos que almacenar otra
									@; vez el codigo de la gelatina en mat_recomb2 y buscar otro aleatorio
		movhs r0, r6				@; Si es 3, en r0 ponemos la matriz base de juego
		beq .Lcodigogelatina 		@; Retorna gelatina a su posicion
		
		mov r3, #3					@; Al guardar 3 en r3(orientacion), miraremos con cuenta repeticiones la orientacion Norte
		mov r0, r5					@; A r0 pasamos mat_recomb2(miraremos si hay repeticiones en esa matriz)
		bl cuenta_repeticiones		@; En cuenta_repeticiones, comprobamos si hay combinacion
		
		cmp r0, #3					@; Comprobamos si hay secuencia, si la hay, tenemos que almacenar otra
									@; vez el codigo de la gelatina en mat_recomb2 y buscar otro aleatorio
		movhs r0, r6				@; Si es 3, en r0 ponemos la matriz base de juego
		beq .Lcodigogelatina 		@; Retorna gelatina a su posicion
		
		mov r3, #0					@; Guardamos un 0 en el auxiliar r3 
		strb r3, [r4, r9]			@; En mat_recomb1 (posicion obtenida del aleatorio) guardamos un 0 (Indica que ya ha sido usado)
		b .Lactuind2				@; Vamos a actualizar los indices (i, j, r7 despl)
		
	.Lcodigogelatina:
		strb r8, [r5, r7]			@; Guardamos r8 en mat_recomb2(Si hay gelatina, tiene el c�digo de la misma posici�n)
		
	.Lcontador:
		sub r10, #1					@; Cada vez que llegamos aqui por elemento erroneo, restamos uno al contador auxiliar para evitar bucles infinitos
		cmp r10, #0					@; Comparamos el contador con 0
		beq .Linicio				@; Si el contador ha llegado a 0, saltamos al inicio y empezamos de 0, para evitar quedarnos en un bucle infinito
		b .Lcambioelem				@; En caso contrario, buscamos otro elemento aleatorio
		
	.Lactuind2:
		add r7, #1					@; despl +1
		add r2, #1					@; j=j+1
		cmp r2, #COLUMNS			@; j = columns?
		blo .Lforjrecor2			@; Si j<columns, saltamos al for j del recorrido
		add r1, #1					@; i=i+1
		cmp r1, #ROWS				@; i=ROWS?
		blo .Lforirecor2			@; Si i<rows, saltamos al for i del recorrido
		
	.Lcompruebacombinacion:
		mov r0, r5					@; A r0 pasamos la matriz mat_recomb2
		bl hay_combinacion			@; Miramos si hay una combinaci�n posible o m�s en la matriz nueva final llamando a hay_combinacion
		cmp r0, #0					@; Si r0=1, hay combinaci�n, si r0=0, no la hay y podemos proceder a devolver el resultado por la matriz de juego
		moveq r0, r6				@; Si r0=0, le pasamos la direcci�n base de juego 
		beq .Levitarbucle			@; Comprobamos si estamos en un bucle y volvemos al inicio, empezando de 0
		
	.Lreindespl:
		mov r7, #0					@; Desplazamiento r7 = 0 para copiar elementos de mat_recomb2 a matriz de juego
		
	.Lcopia:
		ldrb r11, [r5, r7]			@; Cargamos el valor de mat_recomb2 con los elementos cambiados
		strb r11, [r6, r7]			@; Guardamos el valor en la matriz de juego (mismas posiciones machacando valores antiguos)
		
	.Lfinalcopia:
		add r7, #1					@; Sumamos 1 al desplazamiento
		cmp r7, #ROWS*COLUMNS		@; Comprobamos el desplazamiento con ROWSxCOLUMNS
		blo .Lcopia					@; Si es menor o igual, saltamos a copia, si es mayor, hemos acabado
		
	.Lfin:
		pop {r0-r12, pc}
	
@;:::RUTINAS DE SOPORTE:::

@; mod_random(n): rutina para obtener un n�mero aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el par�metro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustar� autom�ticamente a estos valores m�nimo y m�ximo
@;	Par�metros:
@;		R0 = el rango del n�mero aleatorio (n)
@;	Resultado:
@;		R0 = el n�mero aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el m�nimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango m�nimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (n�mero m�s alto permitido)
		mov r3, #1				@;R3 = m�scara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una m�scara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = n�mero aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso seg�n m�scara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve n�mero aleatorio restringido a rango
		
		pop {r1-r4, pc}

@; random(): rutina para obtener un n�mero aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (tambi�n se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = direcci�n de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	

.end
