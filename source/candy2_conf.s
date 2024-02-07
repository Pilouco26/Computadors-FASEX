@;=                                                        				=
@;=== candy2_conf: variables globales de configuración del juego  	  ===
@;=                                                       	        	=
@;=== autor: santiago.romani@urv.cat 	(2014-10-06)			  	  ===
@;=                                                       	        	=


@;-- .data. variables globales inicializadas ---
.data
		.align 2


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;								(MAXLEVEL está definida en "include/candy1.h")
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
max_mov:	.byte 20, 27, 11, 25, 24, 8, 21, 30, 25


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 2
		.global pun_obj
pun_obj:	.word -1000, -330, -500, 0, -240, -500, -200, -900, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatinas simple (a sumarle código de elemento)
@;		15:		hueco (no hay casilla de juego)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
mapas:

	@; mapa 0: gelatina doble
		.byte 21,20,21,20,21,20,21,20
		.byte 21,19,21,20,21,22,21,20
		.byte 22,19,22,21,22,20,22,19
		.byte 21,22,21,20,22,22,21,19
		.byte 22,20,22,22,21,20,22,20
		.byte 21,20,21,20,21,20,21,20

	@; mapa 1: bloques solidos
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7
		.byte 7,7,7,7,7,7,7,7

	@; mapa 2: huecos
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15
	
	@; mapa 3: gelatinas simples
		.byte 9,10,10,8,8,9,10,10
		.byte 11,1,10,0,8,0,0,7
		.byte 0,0,8,7,8,10,7,0
		.byte 7,7,8,0,8,0,0,7
		.byte 0,7,7,0,7,7,0,0
		.byte 7,0,8,7,8,10,7,7

	@; mapa 4: mix
		.byte 20,15,20,15,0,7,20,15
		.byte 20,0,7,0,20,7,20,20
		.byte 10,3,10,1,1,4,3,3
		.byte 10,1,9,0,0,20,3,4
		.byte 17,2,15,15,3,19,4,3
		.byte 3,2,10,0,0,20,0,15

	@; mapa 5: 0 gelatinas
		.byte 1,2,4,15,4,2,4,2
		.byte 3,4,3,5,3,15,7,7
		.byte 4,1,4,6,4,4,15,7
		.byte 1,4,4,2,6,3,7,0
		.byte 5,2,2,15,5,7,5,7
		.byte 6,5,5,2,5,6,7,6

	@; mapa 6: combinaciones en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15
		.byte 1,3,1,4,2,5,7,15
		.byte 1,3,4,4,2,5,15,7
		.byte 2,3,4,2,6,15,2,7
		.byte 2,3,4,15,6,6,5,7
		.byte 2,7,4,3,5,15,6,7

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 1,2,3,3,4,3,7,0
		.byte 1,2,7,5,3,7,7,0
		.byte 4,1,1,2,3,16,7,0
		.byte 1,4,4,2,6,3,7,0
		.byte 4,2,2,5,2,2,7,0
		.byte 4,5,5,2,5,5,7,0
		
	@; mapa 8: no hay combinaciones ni secuencias
		.byte 1,2,3,3,7,3,15,15
		.byte 1,2,7,5,3,7,15,15
		.byte 7,1,1,2,3,9,15,15
		.byte 1,4,20,10,9,6,15,15
		.byte 6,18,22,5,6,2,15,15
		.byte 12,5,4,3,11,5,15,15

	@; etc.



.end
	
