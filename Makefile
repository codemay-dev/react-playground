local:
	@make update_local
	@make build_local
	@make run_local

docker_dev:
	@make update_local
	@make build_docker_dev
	@make run_docker_dev

docker_prod:
	@make update_local
	@make build_docker_prod
	@make run_docker_prod

build_local:
	$(info ******** Building App ********)
	@ npm install

run_local:
	$(info ******** Starting App ********)
	@ npm start

build_docker_dev:
	$(info ******** Building Dev Environment ********)
	@ docker build -t react-playground:dev .

run_docker_dev:
	$(info ******** Starting Dev ********)
	@ docker run -it --rm -v ${PWD}:/app -v /app/node_modules -p 3000:3000 -e CHOKIDAR_USEPOLLING=true react-playground:dev

build_docker_prod:
	$(info ******** Building Production Environment ********)
	@ docker build -f dockerfile.prod -t react-playground:prod .

run_docker_prod:
	$(info ******** Starting Production ********)
	@ docker run -it --rm -p 8080:80 react-playground:prod

BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

update_local:
ifeq ($(BRANCH),master)
	$(info ******** Updating Master ********)
	@ git pull
else
	$(info ******** Updating Master & Branch ********)
	@ git stash
	@ git checkout master
	@ git pull
	@ git checkout $(BRANCH)
	@ git rebase master
	@ git stash pop
endif

push:
ifeq ($(BRANCH),master)
	$(info ******** Already On Master ********)
	@echo "Currently on master, checkout branch"
else
	$(info ******** Rebase & Push Branch ********)
	@ git checkout master
	@ git pull
	@ git checkout $(BRANCH)
	@ git rebase master
	@ git push origin $(BRANCH)
endif
