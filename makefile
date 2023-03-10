#!@ Author: Nguyễn Tiến Tài.
#! Description: Make run auto service all.
#!@ Created_At : 20-12-2022.
#!@ Update_At: 28-12-2022,22-01-2023,10-03-2023

###################! Define variables ###################!
SEND_EMAIL_FOLDER="server-send-email-student"
MEDIA_FOLDER="server-media-service"
BACKEND_FOLDER="backend-manager-student"


POSTGRES_VARS = PASSWORD=$$(grep -oP 'POSTGRES_PASSWORD=\K(.*)' ./${BACKEND_FOLDER}/.env); \
				USER_NAME=$$(grep -oP 'POSTGRES_USER=\K(.*)' ./${BACKEND_FOLDER}/.env); \
				POSTGRES_HOST=$$(grep -oP 'POSTGRES_HOST=\K(.*)' ./${BACKEND_FOLDER}/.env); \
				POSTGRES_DB=$$(grep -oP 'POSTGRES_DB=\K(.*)' ./${BACKEND_FOLDER}/.env); \


###################! SETTING HUSKY ###################

# Not file pre-commit 
install-husky:
	npm i -D
	husky install

# But have to configure husky again
install-dev:
	npm i -D
	npx husky-init

###################!DOCKER ###################

# Go to volume root container
docker-root-student:
	docker exec -it server_user_api sh

docker-root-admin:
	docker exec -it server_admin_api sh

docker-root-email:
	docker exec -it send_email_student sh

docker-root-media:
	docker exec -it upload-api sh

docker-root-cron:
	docker exec -it cron_job sh

docker-root-nginx:
	docker exec -it nginx_libary_school bash
	
docker-root-posgresql:
	docker exec -it postgresql bash

docker-root-redis-master:
	docker exec -it redis-master bash

docker-root-redis-slave:
	docker exec -it redis-slave bash

# Export DB
docker-export-db-posgresql:
	$(POSTGRES_VARS) \
		docker exec -it postgresql bash -c "\
			cd docker-entrypoint-initdb.d && \
				rm -rf libary_school_main.sql && \
				 	PGPASSWORD=$${PASSWORD} pg_dump -U $${USER_NAME} --format=p --file=libary_school_main.sql --dbname=$${POSTGRES_DB} --no-owner --no-privileges -w"

# import DB
docker-import-db-posgresql:
	$(POSTGRES_VARS) \
	docker exec -it postgresql bash -c "\
		cd docker-entrypoint-initdb.d && \
			PGPASSWORD=$${PASSWORD} psql -h $${POSTGRES_HOST} -U $${USER_NAME} -d $${POSTGRES_DB} -a -f libary_school_main.sql;"


###################!DEVELOPER ###################

###################! SETTING DOCKER BUILD FILE CHANGE AND BACKGROUND (DEAMON)  ###################
# Run Server Email And Build
run-send-email-build:
	cd ${SEND_EMAIL_FOLDER} && \
		make run-email

# Run Server media And Build
run-media-build:
	cd ${MEDIA_FOLDER} && \
		make run-media

# Run Server Main And Build
run-backend-build:
	cd ${BACKEND_FOLDER} && \
		make run-backend
	

# Run All Server And Build
run-all-build:
	make run-send-email-build && \
		make run-media-build && \
			make run-backend-build

###################! RUN AUTO BACKGROUND (DEAMON) DOCKER  ###################
# Run Server Email 
run-send-email:
	cd ${SEND_EMAIL_FOLDER} && \
		make stg-dev

# Run Server media 
run-media:
	cd ${MEDIA_FOLDER} && \
		make stg-dev

# Run Server Main 
run-backend:
	cd ${BACKEND_FOLDER} && \
		make stg-dev

# Run All Server
run-all-dev:
	@make run-send-email 
	@make run-media 
	@make run-backend

###################! RUN AUTO DOWN CONTAINER DOCKER  ##########################

# Run Down Container Server Email 
run-send-email-dev-down:
	cd ${SEND_EMAIL_FOLDER} && \
		make run-devdown

# Run Down Container Server media 
run-media-dev-down:
	cd ${MEDIA_FOLDER} && \
		make run-devdown

# Run Down Container Server Main 
run-backend-dev-down:
	cd ${BACKEND_FOLDER} && \
		make run-devdown

# Run Down Container All Server
run-all-dev-down:
	make run-backend-dev-down && \
		make run-send-email-dev-down && \
			make run-media-dev-down


###################################### !PRODUCTION ######################################

###################! RUN BUILD AUTO BACKGROUND (DEAMON) DOCKER  ###################

# Run service email
run-build-live-email:
	cd ${SEND_EMAIL_FOLDER} && \
		make run-live-email

# run service media 
run-build-live-media:
	cd ${MEDIA_FOLDER} && \
		make run-live-media

# run service backend
run-build-live-backend:
	cd ${BACKEND_FOLDER} && \
		make run-live-backend

# Run All Service
run-all-build-live-service:
	make run-build-live-email && \
		make run-build-live-media && \
			make run-build-live-backend && \

###################! RUN AUTO BACKGROUND (DEAMON) DOCKER  ###################
# Run service email
run-live-email:
	cd ${SEND_EMAIL_FOLDER} && \
		make stg-prod

# run service media 
run-live-media:
	cd ${MEDIA_FOLDER}&& \
		make stg-prod

# run service backend
run-live-backend:
	cd ${BACKEND_FOLDER} && \
		make stg-prod

# Run All Service
run-all-live-service:
	@make run-live-email
	@make run-live-media
	@make run-live-backend

##############! RUN AUTO DOWN CONTAINER DOCKER  #####################

# Down service email
run-down-live-email:
	cd ${SEND_EMAIL_FOLDER}&& \
		make run-down-live-email

# Down service media 
run-down-live-media:
	cd ${MEDIA_FOLDER} && \
		make run-down-live-media

# Down service backend
run-down-live-backend:
	cd ${BACKEND_FOLDER} && \
		make run-down-live-backend

# Down all service  
run-down-all-live-service:
	make run-down-live-email && \
		make run-down-live-media && \
			make run-down-live-backend && \
