import tkinter as tk
from tkinter import filedialog, Toplevel
from PIL import Image, ImageTk
import numpy as np
import subprocess

class InterpolacionApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Interpolación")
        self.root.geometry("900x575")
        
        self.imagen_tk = None
        self.imagen_original = None
        
        self.menu_barra = tk.Menu(self.root)
        menu_imagen = tk.Menu(self.menu_barra, tearoff=0)
        menu_imagen.add_command(label="Cargar Imagen", command=self.cargar_imagen)
        self.menu_barra.add_cascade(label="Imagen", menu=menu_imagen)
        self.root.config(menu=self.menu_barra)
        
        self.canvas = tk.Canvas(self.root, width=390, height=390)
        self.canvas.pack()
        
        tk.Label(self.root, text="Elige una parte (1-16):").pack()
        self.entry_numero = tk.Entry(self.root)
        self.entry_numero.pack()
        
        tk.Button(self.root, text="Realizar Interpolación", command=self.ejecutar).pack(pady=10)
        
        self.label_error = tk.Label(self.root, fg="red")
        self.label_error.pack()
        
        tk.Button(self.root, text="Salir", command=self.root.quit).pack(pady=10)
    
    def cargar_imagen(self):
        archivo_imagen = filedialog.askopenfilename(title="Selecciona una imagen")
        if archivo_imagen:
            self.imagen_original = Image.open(archivo_imagen).convert("L").resize((390, 390))
            self.imagen_tk = ImageTk.PhotoImage(self.imagen_original)
            self.canvas.create_image(0, 0, anchor=tk.NW, image=self.imagen_tk)
            self.dibujar_cuadricula()
    
    def dibujar_cuadricula(self):
        for i in range(1, 4):
            coord = i * 97
            self.canvas.create_line(coord, 0, coord, 390, fill="red")
            self.canvas.create_line(0, coord, 390, coord, fill="red")
    
    def obtener_coordenadas(self):
        try:
            numero = int(self.entry_numero.get())
            if not 1 <= numero <= 16:
                raise ValueError("El número debe estar entre 1 y 16.")
            fila, columna = divmod(numero - 1, 4)
            return columna * 97, fila * 97, (columna + 1) * 97, (fila + 1) * 97
        except ValueError as e:
            self.label_error.config(text=str(e), fg="red")
            return None
    
    def realizar_recorte(self):
        if self.imagen_original is None:
            self.label_error.config(text="Carga una imagen primero", fg="red")
            return
        coordenadas = self.obtener_coordenadas()
        if coordenadas:
            imagen_recortada = self.imagen_original.crop(coordenadas)
            np.savetxt("matriz_pixeles.txt", np.array(imagen_recortada), fmt="%d")
            self.label_error.config(text="Matriz guardada en 'matriz_pixeles.txt'", fg="green")
    
    def ejecutar_ensamblador(self):
        try:
            subprocess.run(["nasm", "-f", "elf64", "interpolacion.asm"], check=True)
            subprocess.run(["ld", "-o", "interpolacion", "interpolacion.o"], check=True)
            resultado = subprocess.run(["./interpolacion"], capture_output=True, text=True)
            self.label_error.config(text="Salida del ensamblador:\n" + resultado.stdout, fg="blue")
        except subprocess.CalledProcessError as e:
            self.label_error.config(text=f"Error al ejecutar ensamblador:\n{e}", fg="red")
    
    def resultado(self):
        if self.imagen_original is None:
            self.label_error.config(text="Carga una imagen primero", fg="red")
            return
        
        coordenadas = self.obtener_coordenadas()
        if coordenadas:
            try:
                matriz_procesada = np.loadtxt("matriz_nueva.txt", dtype=np.uint8)
                imagen_procesada = Image.fromarray(matriz_procesada, mode="L")
                imagen_recortada = self.imagen_original.crop(coordenadas)
                
                ventana_resultado = Toplevel(self.root)
                ventana_resultado.title("Resultado de la Interpolación")
                
                imagenes = {
                    "Imagen Original": self.imagen_original,
                    "Cuadrante Recortado": imagen_recortada,
                    "Imagen con Interpolación": imagen_procesada
                }
                
                for i, (titulo, img) in enumerate(imagenes.items()):
                    tk.Label(ventana_resultado, text=titulo).grid(row=0, column=i)
                    img_tk = ImageTk.PhotoImage(img)
                    tk.Label(ventana_resultado, image=img_tk).grid(row=1, column=i)
                    setattr(ventana_resultado, f"imagen_tk_{i}", img_tk)  # Evitar eliminación
            except Exception as e:
                self.label_error.config(text="Error al generar la vista de resultado: " + str(e), fg="red")
    
    def ejecutar(self):
        self.realizar_recorte()
        self.ejecutar_ensamblador()
        self.resultado()

if __name__ == "__main__":
    root = tk.Tk()
    app = InterpolacionApp(root)
    root.mainloop()

