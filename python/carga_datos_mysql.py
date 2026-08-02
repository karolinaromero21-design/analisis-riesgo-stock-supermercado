"""
carga_datos_mysql.py
---------------------
Carga automatizada de archivos CSV/Excel a MySQL usando pandas + SQLAlchemy.

Recorre una carpeta de origen, detecta el formato de cada archivo, y crea
(o reemplaza) la tabla correspondiente en MySQL sin intervención manual.
Pensado para volver a ejecutarse las veces que haga falta: si una tabla ya
existe, se reemplaza por completo (`if_exists="replace"`).
"""

import os
import pandas as pd
from sqlalchemy import create_engine

# ==============================
# CONFIGURACIÓN MYSQL
# ==============================
USUARIO = "root"
PASSWORD = "TU_PASSWORD_AQUI"
HOST = "localhost"
PUERTO = "3306"
BASE_DATOS = "supermercado"

# Carpeta con los archivos de origen (CSV / Excel)
CARPETA_DATOS = r"C:\ruta\a\Base de Datos Supermercado"

# ==============================
# CONEXIÓN
# ==============================
engine = create_engine(
    f"mysql+pymysql://{USUARIO}:{PASSWORD}@{HOST}:{PUERTO}/{BASE_DATOS}"
)
print("Conexión exitosa")

# ==============================
# RECORRER ARCHIVOS Y CARGAR
# ==============================
for archivo in os.listdir(CARPETA_DATOS):
    ruta = os.path.join(CARPETA_DATOS, archivo)
    nombre_tabla = os.path.splitext(archivo)[0]
    nombre_tabla = nombre_tabla.lower().replace(" ", "_")

    try:
        if archivo.endswith(".csv"):
            print(f"Cargando CSV: {archivo}")
            df = pd.read_csv(ruta)
            df.to_sql(nombre_tabla, con=engine, if_exists="replace", index=False)
            print(f"Tabla {nombre_tabla} cargada")

        elif archivo.endswith((".xlsx", ".xls")):
            print(f"Cargando Excel: {archivo}")
            df = pd.read_excel(ruta)
            df.to_sql(nombre_tabla, con=engine, if_exists="replace", index=False)
            print(f"Tabla {nombre_tabla} cargada")

    except Exception as e:
        # Un archivo con problemas no frena la carga del resto
        print(f"Error en {archivo}: {e}")

print("Proceso terminado")
