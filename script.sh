#!/bin/bash

echo "           ___                     _             
 _____ ___|_  |___ ___ ___ ___ ___|_|___ ___ ___ 
|     | . |_  | . |  _| . | .'|   | |- _| -_|  _|
|_|_|_|  _|___|___|_| |_  |__,|_|_|_|___|___|_|  
      |_|             |___|                      "
echo "..."

### Crear directorios
mkdir MP3s Albums

### Criterio de separacion/ordenamiento en segundos
# 15 minutos
segundos=900
# 35 minutos
#segundos=2100

# *Intente usar 'archivos_mp3=$(ls *.mp3)' pero no funciona para archivos que tienen espacios en su nombre 
### Desglose de find:
# '.' -> Indica la ruta o directorio donde comenzara la busqueda, en este caso el punto indica busqueda en el directorio actual
# '-maxdepth 1' -> Indica que tan profundo va a buscar en el arbol de directorios, en este caso (1) solo va a buscar en el directorio donde se encuentra y no buscara dentro de otros directorios que puedan llegar a estar en el directorio actual
# '-type f' -> Especifica que solo va a buscar archivos regulares ignorando otro tipo de archivos como directorios (Everything is a file)
# '-name "*.mp3"' -> Especifica que va a buscar archivos que puedan tener cualquier nombre pero con la terminacion '.mp3'
# '-print0" -> Devuelve los resultados separados por un caracter nulo
# '|' (pipe) -> Redirige la salida de un comando con otro (En este caso, de 'find' a 'while')
### Desglose de while:
# 'read' -> Lee una linea de entrada y la asigna a una variable (archivo)
# '-r' -> Evita que read interprete caracteres de escape especiales, por ejemplo '\r' o '\n'
# '-d ''' -> Establece el delimitador que marca el final de la línea de entrada con un caracter nulo '' (Relacionado con '-print0' de find)
# 'archivo' -> Variable donde se asignara uno de los elementos que se encontraron
find . -maxdepth 1 -type f -name "*.mp3" -print0 | while read -r -d '' archivo; do

    ### Obtiene la duracion del archivo con ffmpeg
    # 'ffprobe' -> Herramientda de ffmpeg que ayuda a obtener informacion de archivos multimedia
    # '-v error' -> Se omite mostrar la informacion a expcepcion de los errores
    # '-show_entries format=duration' -> De toda la informacion obtenida del archivo, solo obtiene la duracion del archivo mp3
    # 'of' -> Se le indica el formato de salida
    # 'default=' -> Le decimos a 'of' que queremos utilizar el formato de salida pero con ciertos modificadores
    # 'noprint_wrappers=1:nokey=1' -> Hace que no se muestren envoltorios adicionales alrededor del valor de duración, por ejemplo, sin esto la salida seria "duration=xxx.xxx"
    # '$archivo' -> El nombre del archivo mp3 del cual se desea obtener la duración
    duracion=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$archivo")

    # Se crea una comparación separada porque al parecer la estructura if no soporta comparar flotantes con enteros directamente
    # 'bc' es una utilidad que actua como una calculadora
    comparacion=$(echo "$duracion < $segundos" | bc)

    if [ "$comparacion" -eq 1 ]; then
        mv "$archivo" MenosDe15Minutos/
    else
        mv "$archivo" MasDe15Minutos/
    fi

done

echo "OK"
