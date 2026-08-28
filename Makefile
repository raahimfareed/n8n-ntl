.PHONY: up down logs logs-all shell db-shell backup restore restore-dump clean

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

db-shell:
	docker compose exec postgres psql -U $${POSTGRES_USER:-n8n} -d $${POSTGRES_DB:-n8n}

backup:
	@mkdir -p backup
	docker compose exec postgres pg_dump -Fc -U $${POSTGRES_USER:-n8n} $${POSTGRES_DB:-n8n} > backup/n8n_backup_$(shell date +%Y%m%d_%H%M%S).dump
	@echo "Backup saved to backup/"

restore:
	@if [ -z "$(FILE)" ]; then echo "Usage: make restore FILE=backup/file.sql"; exit 1; fi
	docker compose exec -T postgres psql -U $${POSTGRES_USER:-n8n} -d $${POSTGRES_DB:-n8n} < $(FILE)

restore-dump:
	@if [ -z "$(FILE)" ]; then echo "Usage: make restore-dump FILE=backup/myfile.dump"; exit 1; fi
	@echo "==> Stopping n8n..."
	docker compose stop n8n
	@echo "==> Dropping and recreating database..."
	docker compose exec postgres dropdb -U $${POSTGRES_USER:-n8n} --if-exists $${POSTGRES_DB:-n8n}
	docker compose exec postgres createdb -U $${POSTGRES_USER:-n8n} $${POSTGRES_DB:-n8n}
	@echo "==> Restoring from $(FILE)..."
	docker compose exec postgres pg_restore -U $${POSTGRES_USER:-n8n} -d $${POSTGRES_DB:-n8n} --no-owner --no-privileges /backup/$(notdir $(FILE))
	@echo "==> Starting n8n (will run pending migrations)..."
	docker compose start n8n
	@echo "==> Done. Check logs with: make logs"

clean:
	docker compose down -v
	docker system prune -f
