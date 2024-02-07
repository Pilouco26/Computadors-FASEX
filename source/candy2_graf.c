/*------------------------------------------------------------------------------

	$ candy2_graf.c $
	Funciones de inicialización de gráficos (ver "candy2_main.c")

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: josep.ribas@estudiants.urv.cat
	Programador tarea 2B: ivan.morillas@estudiants.urv.cat
	Programador tarea 2C: miguel.lopes@estudiants.urv.cat
	Programador tarea 2D: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <candy2_incl.h>
#include <Graphics_data.h>
#include <Sprites_sopo.h>


/* variables globales */
int n_sprites = 0;					// número total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representación de los elementos de las casillas de la matriz que se pasa
	por parámetro (independientemente de los códigos de gelatinas).*/


	/* ocultar todos los 128 sprites y desactivar todos los ROWS*COLUMNS elementos del vector 
	vect_elem[] elem[], recorrer la matriz del juego e invocar a la función crea_elemento() 
	para todas las casillas donde exista un elemento (con o sin gelatina), actualizar la 
	variable global n_spritesn_sprites, de acuerdo con el número de sprites creados. 
	actualizar OAM según el número de sprites creados */
void genera_sprites(char mat[][COLUMNS])
{
	//Variables
	int i = 0;
	
	// ocultar todos los 128 sprites
	SPR_ocultarSprites(128);
	/* El propósito de las rutinas SPR_... es guardar los parámetros en los campos de los registros
	   de control del sprite referenciado por su índice (número entre 0 y 127). Sin embargo, estos 
	   cambios se almacenan temporalmente sobre la variable oam_data data, que replica la estructura 
	   de los registros de control de los sprites, ubicados a partir de la dirección de memoria 
	   x07000000 para el procesador gráfico principal */

	// SPR_actualizarSprites() cuando se haya producido un cambio en la posición o forma de alguno de los sprites del juego
	// llamamos a SPR_act... porque se han ocultado los Sprites

	SPR_actualizarSprites((u16*)0x07000000, 128);		// direccion procesador grafico principal y numero de sprites activos
	//desactivar todos los ROWS*COLUMNS elementos del vector vect_elem[] elem[]
	while (i<(ROWS*COLUMNS)){
		vect_elem[i].ii = -1;
		i++;
	}

	// extern void SPR_actualizarSprites (u16* base, int limite)

	// llamamos a SPR_act... porque se han desactivado los elems
	//SPR_actualizarSprites((u16*)0x07000000, n_sprites);

	//Recorrido por la matriz invocando a "Crea elemento" cuando sea necesario
	i=0;
	int j = 0;
	int codigoElem = 0;		// codigo del elemento (sin gelatinas)
	int indBaldosa = 0;		// Indice baldosa retornado en crea_elemento
	n_sprites = 0;

	while (indBaldosa != (ROWS*COLUMNS)){
		while (i<ROWS){
			while (j<COLUMNS){
				codigoElem = (mat[i][j] & 7);			// mascara de [111] para el codigo del elemento
				if (mat[i][j] != 7 && mat[i][j] != 15){		// ignoramos los huecos(7) y bloques sólidos(15)
					indBaldosa = crea_elemento(codigoElem, i, j);		//Creamos un elemento en esta posicion
					if (indBaldosa < (ROWS*COLUMNS)){		// si el indice Baldosa esta dentro del Rows*Columns
						n_sprites++;						// actualizamos numero sprites a +1 
					}
				}
				j++;
			}	
			i++;
			j=0;
		}
		indBaldosa = ROWS*COLUMNS;
	}

	// llamamos a SPR_act... porque se han creado los elems (actualizar OAM según el número de sprites creados)
	SPR_actualizarSprites((u16*)0x07000000, n_sprites);


}



// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas como un tablero ajedrezado
	de metabaldosas de 32x32 píxeles (4x4 baldosas), en las posiciones de la
	matriz donde haya que visualizar elementos con o sin gelatina, bloques
	sólidos o espacios vacíos sin elementos, excluyendo solo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{


}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas correspondiente a la
	representación de las casillas de la matriz que se pasa por parámetro,
	utilizando metabaldosas de 32x32 píxeles (4x4 baldosas), visualizando
	las gelatinas simples y dobles y los bloques sólidos con las metabaldosas
	correspondientes, (para las gelatinas, basta con utilizar la primera
	metabaldosa de la animación); además, hay que inicializar la matriz de
	control de la animación de las gelatinas mat_gel[][COLUMNS]. */
void genera_mapa1(char mat[][COLUMNS])
{
	/*INICIALITZAR
	for(int i=0; i<ROWS; i++) 
	{
		for(int j=0; j<COLUMNS; j++)
		{
			mat_gel[i][j].ii = -1;
			
		}
	}*/


	for(int i=0; i<ROWS; i++)
	{
		for(int j=0; j<COLUMNS; j++)
		{
			if(mat[i][j]<7 || mat[i][j] == 15){
			
			mat_gel[i][j].ii = -1;
			mat_gel[i][j].im = 19;
			fija_metabaldosa((u16*)0x06000000, i, j, 19);
			
															//Es elemento o hueco
			
			}else if(mat[i][j]  == 7){
	
			mat_gel[i][j].ii = -1;
			mat_gel[i][j].im = 16;
			fija_metabaldosa((u16*)0x06000000, i, j, 16);		//Es bloque solido
			
			}
			else{
				int imeta =0;
				if(mat[i][j]<15) {
					imeta = mod_random(7);
					fija_metabaldosa((u16*)0x06000000, i, j, imeta);
					mat_gel[i][j].ii= mod_random(9)+1;
					mat_gel[i][j].im= imeta;
				}
				else{
					imeta = mod_random(7)+8; 
					fija_metabaldosa((u16*)0x06000000, i, j, imeta);
					mat_gel[i][j].ii= mod_random(9)+1;
					mat_gel[i][j].im = imeta;
				
				}
			}
	
		}
	}

}



// TAREA 2Db
/* ajusta_imagen3(int ibg): rotar 90 grados a la derecha la imagen del fondo
	cuyo identificador se pasa por parámetro (fondo 3 del procesador gráfico
	principal), y desplazarla para que se visualice en vertical a partir del
	primer píxel de la pantalla. */
void ajusta_imagen3(int ibg)
{


}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gráfico principal,
				reserva de bancos de memoria y carga de información gráfica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg1A, bg2A, bg3A;

	videoSetMode(MODE_3_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000
	vramSetBankF(VRAM_F_MAIN_SPRITE_0x06400000);	// BANCO F SPRITES @0x06400000
// Tareas 2Ba y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000
	vramSetBankE(VRAM_E_MAIN_BG);
// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000




// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// dirección virtual de memoria gráfica para sprites, y cargar los colores
	// de paleta asociados contenidos en la variable SpritesPal[]

	dmaCopy(SpritesTiles, (void *) 0x06400000, sizeof(SpritesTiles));	 // copiar baldosas (variable SpritesTiles @0x06400000)
	dmaCopy(SpritesPal, (void *) 0x05000200, sizeof(SpritesPal));		 // cargar colores paleta (variable SpritesPal @0x05000200)


// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2
	bg2A = bgInit(2, BgType_Text8bpp, BgSize_T_256x256, 0, 1);
	bgSetPriority(bg2A, 2);


// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0

	bg1A = bgInit(1, BgType_Text8bpp, BgSize_T_256x256, 0, 1);
	bgSetPriority(bg1A, 0);

// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la dirección de memoria correspondiente a los gráficos de
	// las baldosas para los fondos 1 y 2, cargar los colores de paleta
	// correspondientes contenidos en la variable BaldosasPal[]
	decompress(BaldosasTiles, bgGetGfxPtr(bg2A), LZ77Vram);  // bgGetGfxPtr et retorna la direcció de memoria 0x06000000  
	dmaCopy(BaldosasPal, BG_PALETTE, sizeof(BaldosasPal)); //tamany 164 bytes	
	
// Tarea 2Da:
	// inicializar el fondo 3 con prioridad 3


	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la dirección virtual de vídeo reservada para dicha imagen
	// fijar display A en pantalla inferior (táctil)
	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla):
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

