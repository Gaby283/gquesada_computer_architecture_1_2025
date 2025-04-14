#  gquesada_computer_architecture_1_2025 - Aplicación de Interpolación a imagenes

Programa en Python + Ensamblador que hace una Interpolación bilineal a un cuadrante seleccionado de una imagen cuadrada(390x390 px) en escala de grises. Simplemente se debe seleccionar una imagen, seleccionar un cuadrante y presionar el botón "Realizar Interpolación".

#Intrucciones de uso 
-Se debe clonar el repositorio de https://github.com/Gaby283/gquesada_computer_architecture_1_2025.git
-Para ejecutar la aplicación debe moverse en consola a la ubicación en la que se clonó el repositorio
-Ingrese la línea source mi_entorno/bin/activate
-Ingrese la línea "python3 Interpolación.py"
-En la esquina superior izquierda encontrará un botón que le permite seleccionar una imagen
-La imagen se dividirá en 16 cuadrantes 
-El usuario deberá ingresar el número correspondiente al cuadrante al que desea aplicarle la interpolación (Los cuadrantes se cuentan de izquierda a derecha y de la fila superior a la inferior)
-Al presionar el botón "Calcular Interpolación" ubicado en el centro de la pantalla, podrá observar una pantalla emergente la cual motrará (de izquierda a derecha) la imagen original, el cuadrante seleccionado por el usuario y el cuadrante con la interpolación realizada.

#Una vez realizada la Interpolación
Después de realizar la interpolación el usuario cuenta con tres opciones:
-Si desea realizar la interpolación de otro cuadrante de la misma imagen simplemente debe ingresar el número de cuadrante correspondiente y dar click en "Realizar Interpolación".
-Si desea realizar la interpolación de una nueva imagen simplemente debe seguir la instrucciones de uso indicadas anteriormente a partir de la cuarta instrucción.
-Si no desea realizar más interpolaciones simplemente debe cerrar la ventana ya sea dando click en el botón "Salir" ubicado en la parte inferior de la pantalla o bien en la "x" en la esquina superior derecha de la pantalla.

#Características 
-Intefaz gráfica en python para la selección de imágenes y cuadrantes.
-Procesamiento en bajo nivel en ensamblador x86-64 para realizar cálculos
-Generación de archivos de matrices de: el cuadrante original (alto nivel) y la matriz interpolada (bajo nivel).
-Visualización de la imagen original, el cuadrante y la interpolación

#Requisitos 
-Sistema operativo Linux
-Mínimo 2GB de RAM
-Espacio en disco de 200MB libres
-Procesador compatible con arquitecturaa x86-64
-Python versión 3.6 o superior y las siguientes librerias:
    tkinter
    Pillow
    numpy
-NASM

