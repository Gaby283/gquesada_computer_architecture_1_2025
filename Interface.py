import tkinter as tk
from tkinter import filedialog, Toplevel
from PIL import Image, ImageTk
import numpy as np
import subprocess

# Crear la ventana principal
ventana = tk.Tk()
ventana.title("Interpolación")
ventana.geometry("900x575")  

# Variables globales para almacenar la imagen
imagen_tk = None
imagen_original = None  # Imagen original sin modificaciones

# Función para cargar la imagen
def cargar_imagen():
    archivo_imagen = filedialog.askopenfilename(title="Selecciona una imagen")

    if archivo_imagen:
        # Abrir la imagen con Pillow
        imagen = Image.open(archivo_imagen).convert("L")  # Convertir a escala de grises

        # Redimensionar la imagen 
        imagen = imagen.resize((390, 390))

        global imagen_original
        imagen_original = imagen  # Guardar la imagen original

        # Convertir la imagen a un formato compatible con Tkinter
        global imagen_tk
        imagen_tk = ImageTk.PhotoImage(imagen)

        # Dibujar la imagen en el canvas
        canvas.create_image(0, 0, anchor=tk.NW, image=imagen_tk)

        # Dibujar la cuadrícula sobre la imagen
        dibujar_cuadricula()

# Función para dibujar la cuadrícula
def dibujar_cuadricula():
    for i in range(1, 4):
        x = i * 97
        y = i * 97
        canvas.create_line(x, 0, x, 390, fill="red")  # Líneas verticales
        canvas.create_line(0, y, 390, y, fill="red")  # Líneas horizontales

# Función para realizar el recorte y procesar los píxeles
def realizar_recorte():
    try:
        # Obtener el número de cuadrante ingresado
        numero = int(entry_numero.get())

        if numero < 1 or numero > 16:
            raise ValueError("El número debe estar entre 1 y 16.")

        # Calcular coordenadas del cuadrante
        fila = (numero - 1) // 4  
        columna = (numero - 1) % 4  

        x1 = columna * 97
        y1 = fila * 97
        x2 = x1 + 97
        y2 = y1 + 97

        # Recortar la imagen
        imagen_recortada = imagen_original.crop((x1, y1, x2, y2))

        # Obtener la matriz de píxeles
        matriz_pixeles = np.array(imagen_recortada)

        # Guardar la matriz en un archivo de texto
        guardar_matriz_en_txt(matriz_pixeles)

        # Mostrar mensaje de éxito
        label_error.config(text="Matriz guardada en 'matriz_pixeles.txt'", fg="green")
    
    except ValueError as e:
        label_error.config(text=str(e), fg="red")

# Función para guardar la matriz en un archivo de texto
def guardar_matriz_en_txt(matriz):
    with open("matriz_pixeles.txt", "w") as f:
        for fila in matriz:
            f.write(" ".join(f"{pixel:03d}" for pixel in fila) + "\n")

# Función para leer una matriz desde un archivo TXT
def leer_matriz_desde_txt():
    archivo_matriz = "matriz_nueva.txt"  #
    
    try:
        matriz = np.loadtxt(archivo_matriz, dtype=np.uint8)
    except Exception as e:
        label_error.config(text="Error al leer la matriz: " + str(e), fg="red")


# Función para ensamblar y ejecutar el código ensamblador interpolacion.asm
def ejecutar_ensamblador():
    try:
        # Ensamblar el archivo .asm con NASM
        subprocess.run(["nasm", "-f", "elf64", "interpolacion.asm"], check=True)

        # Enlazar el archivo objeto con ld para generar el ejecutable
        subprocess.run(["ld", "-o", "interpolacion", "interpolacion.o"], check=True)

        # Ejecutar el ensamblador generado
        resultado = subprocess.run(["./interpolacion"], capture_output=True, text=True)

        # Mostrar la salida en la interfaz
        label_error.config(text="Salida del ensamblador:\n" + resultado.stdout, fg="blue")
    
    except subprocess.CalledProcessError as e:
        label_error.config(text=f"Error al ejecutar ensamblador:\n{e}", fg="red")
        

# Función para mostrar una ventana con las tres imágenes
def resultado():
    if imagen_original is None:
        label_error.config(text="Primero carga una imagen.", fg="red")
        return

    try:
        # Leer la imagen procesada desde matriz_nueva.txt
        archivo_matriz = "matriz_nueva.txt"
        matriz_procesada = np.loadtxt(archivo_matriz, dtype=np.uint8)
        imagen_procesada = Image.fromarray(matriz_procesada, mode="L")

        # Recortar el cuadrante seleccionado
        numero = int(entry_numero.get())

        if numero < 1 or numero > 16:
            raise ValueError("El número debe estar entre 1 y 16.")

        fila = (numero - 1) // 4  
        columna = (numero - 1) % 4  

        x1 = columna * 97
        y1 = fila * 97
        x2 = x1 + 97
        y2 = y1 + 97

        imagen_recortada = imagen_original.crop((x1, y1, x2, y2))

        # Crear ventana emergente
        ventana_resultado = Toplevel(ventana)
        ventana_resultado.title("Resultado de la Interpolación")

        # Convertir imágenes para Tkinter
        imagen_tk_original = ImageTk.PhotoImage(imagen_original)
        imagen_tk_recortada = ImageTk.PhotoImage(imagen_recortada)
        imagen_tk_procesada = ImageTk.PhotoImage(imagen_procesada)

        # Crear labels y mostrar imágenes
        tk.Label(ventana_resultado, text="Imagen Original").grid(row=0, column=0)
        tk.Label(ventana_resultado, image=imagen_tk_original).grid(row=1, column=0)

        tk.Label(ventana_resultado, text="Cuadrante Recortado").grid(row=0, column=1)
        tk.Label(ventana_resultado, image=imagen_tk_recortada).grid(row=1, column=1)

        tk.Label(ventana_resultado, text="Imagen Procesada").grid(row=0, column=2)
        tk.Label(ventana_resultado, image=imagen_tk_procesada).grid(row=1, column=2)

        # Mantener referencias para evitar que se borren
        ventana_resultado.imagen_tk_original = imagen_tk_original
        ventana_resultado.imagen_tk_recortada = imagen_tk_recortada
        ventana_resultado.imagen_tk_procesada = imagen_tk_procesada

    except ValueError as e:
        label_error.config(text=str(e), fg="red")
    except Exception as e:
        label_error.config(text="Error al generar la vista de resultado: " + str(e), fg="red")



def ejecutar():
    realizar_recorte()
    leer_matriz_desde_txt()
    ejecutar_ensamblador()
    resultado()

# Crear la barra de menú
menu_barra = tk.Menu(ventana)
menu_imagen = tk.Menu(menu_barra, tearoff=0)
menu_imagen.add_command(label="Cargar Imagen", command=cargar_imagen)
menu_barra.add_cascade(label="Imagen", menu=menu_imagen)
ventana.config(menu=menu_barra)

# Crear un canvas para mostrar la imagen
canvas = tk.Canvas(ventana, width=390, height=390)
canvas.pack()

# Crear la entrada para el número de cuadrante
label_entrada = tk.Label(ventana, text="Elige una parte (1-16):")
label_entrada.pack()
entry_numero = tk.Entry(ventana)
entry_numero.pack()

# Botón para realizar TODO
boton_realizar = tk.Button(ventana, text="Realizar Interpolación", command=ejecutar)
boton_realizar.pack(pady=10)

# Label para mostrar errores o mensajes
label_error = tk.Label(ventana, fg="red")
label_error.pack()

# Botón para salir
boton_salir = tk.Button(ventana, text="Salir", command=ventana.quit)
boton_salir.pack(pady=10)

# Ejecutar la interfaz
ventana.mainloop()

