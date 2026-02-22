# Usar una imagen base oficial de Python
FROM public.ecr.aws/docker/library/python:3.10-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de requirements
COPY requirements.txt ./

# Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY app/ ./

# Exponer el puerto
EXPOSE 5000

# Comando para ejecutar con Gunicorn
# -w 3: Los 3 workers que calculamos para 1 vCPU
# -b 0.0.0.0:5000: Escuchar en todas las interfaces en el puerto 5000
# app:app -> Busca el archivo app.py y la variable 'app' (Flask)
CMD ["gunicorn", "-w", "3", "-b", "0.0.0.0:5000", "app:app"]
