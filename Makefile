CLUSTER = haystack-cluster
BACKEND_IMAGE_INDEXING = backend-indexing:local
BACKEND_IMAGE_QUERY = backend-query:local
FRONTEND_IMAGE = frontend:local

build-backend-indexing:
	docker build -f src/backend/Dockerfile.indexing -t $(BACKEND_IMAGE_INDEXING) ./src/backend/

build-backend-query:
	docker build -f src/backend/Dockerfile.query -t $(BACKEND_IMAGE_QUERY) ./src/backend/

build-frontend:
	docker build -f src/frontend/Dockerfile.frontend -t $(FRONTEND_IMAGE) ./src/frontend/

build: build-backend-indexing build-backend-query build-frontend
