all: build

build:
	@echo $(PATH)
	@docker build --tag=andybrucenet/jinja2 .

release: build
	docker build --tag=andybrucenet/jinja2:$(shell cat VERSION) .

push: release
	docker push andybrucenet/jinja2:latest
	docker push andybrucenet/jinja2:$(shell cat VERSION)

