# Usar una imagen base oficial de Python
FROM public.ecr.aws/docker/library/python:3.10-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de requirements
COPY requirements.txt ./

# Instalar las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY app/ ./app/

# Exponer el puerto en el que corre Flask
EXPOSE 5000

# Comando para ejecutar la app
CMD ["python", "app/app.py"]
