build-docker:
	docker build -t cpu_stress .
push:
	docker tag cpu_stress:latest 10.29.5.40:5000/cpu_stress:latest
	docker push --tls-verify=false 10.29.5.40:5000/cpu_stress:latest
