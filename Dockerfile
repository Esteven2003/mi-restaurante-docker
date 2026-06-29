# Usamos la imagen oficial de Nginx en su versión más ligera (alpine)
FROM nginx:alpine

# Copiamos nuestra página web a la carpeta pública de Nginx
COPY index.html /usr/share/nginx/html/index.html

# Exponemos el puerto 80 (el puerto web por defecto)
EXPOSE 80