build-docker:
	docker build -t ram_stress .
push:
	docker tag ram_stress:latest 10.29.5.40:5000/ram_stress:latest
	docker push --tls-verify=false 10.29.5.40:5000/ram_stress:latest
build:
	go build -o ram_stress ram_stress.go
