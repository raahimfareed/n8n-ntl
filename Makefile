.PHONY: up down logs shell backup restore clean

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f n8n

logs-all:
	docker compose logs -f

shell:
	docker compose exec n8n sh

backup:
	docker compose exec postgres pg_dump -U n8n n8n > backup_$(shell date +%Y%m%d_%H%M%S).sql

restore:
	@echo "Usage: make restore FILE=backup_file.sql"
	docker compose exec -T postgres psql -U n8n -d n8n < $(FILE)

clean:
	docker compose down -v
	docker system prune -f
