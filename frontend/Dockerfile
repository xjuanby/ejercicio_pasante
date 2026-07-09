FROM node:22-bullseye

# CLI de Angular disponible globalmente
RUN npm install -g @angular/cli@latest

WORKDIR /app

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 4200

ENTRYPOINT ["entrypoint.sh"]
