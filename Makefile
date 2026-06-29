# Las variables se llenarán automáticamente con tus GitHub Secrets
# cuando el pipeline de Actions ejecute el comando.
STACK_NAME=restaurante_stack
SSH_CMD=ssh -o StrictHostKeyChecking=no $(VPS_USER)@$(VPS_HOST)

.PHONY: deploy

deploy:
	@echo "Creando el archivo docker-compose.yml directamente en el VPS..."
	$(SSH_CMD) "cat << 'EOF' > ~/docker-compose-restaurante.yml\n\
version: '3.8'\n\
\n\
services:\n\
  restaurante:\n\
    image: ghcr.io/esteven2003/mi-restaurante-docker:latest\n\
    networks:\n\
      - traefik-public\n\
    deploy:\n\
      replicas: 1\n\
      update_config:\n\
        parallelism: 1\n\
        delay: 10s\n\
        order: start-first\n\
      restart_policy:\n\
        condition: on-failure\n\
      labels:\n\
        - \"traefik.enable=true\"\n\
        - \"traefik.http.routers.estevenrestaurante.rule=Host(restaurante.byronrm.com)\"\n\
        - \"traefik.http.routers.estevenrestaurante.entrypoints=websecure\"\n\
        - \"traefik.http.routers.estevenrestaurante.tls=true\"\n\
        - \"traefik.http.routers.estevenrestaurante.tls.certresolver=le\"\n\
        - \"traefik.http.services.estevenrestaurante.loadbalancer.server.port=80\"\n\
\n\
networks:\n\
  traefik-public:\n\
    external: true\n\
EOF"
	@echo "Desplegando el stack en Docker Swarm..."
	$(SSH_CMD) "docker stack deploy -c ~/docker-compose-restaurante.yml $(STACK_NAME) --with-registry-auth"