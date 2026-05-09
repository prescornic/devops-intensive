# Full-Stack Docker Compose Application
This project is a multi-container full-stack application built with Docker Compose. It includes a React frontend, a NestJS backend API, PostgreSQL database, Redis cache, and an Nginx reverse proxy.

The services are fully containerized and communicate through isolated Docker networks. PostgreSQL and Redis use named volumes for data persistence. The backend exposes a REST API with a health check endpoint, and Nginx routes traffic between the frontend and backend.

The setup supports environment-based configuration, service health checks, and backend scaling using Docker Compose.

## Architecture

```txt
Browser
   |
   v
   Nginx
  |     \
  |      \
  v       v
Frontend  Backend
            |
      -------------
      |           |
      v           v
 PostgreSQL     Redis
 ```


## Folder structure
```
fullstack-app/
│
├── frontend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   └── src/
│       ├── main.jsx
│       └── App.jsx
│
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── package.json
│   ├── tsconfig.json
│   ├── nest-cli.json
│   └── src/
│       ├── main.ts
│       ├── app.module.ts
│       ├── app.controller.ts
│       └── app.service.ts
│
├── nginx/
│   └── nginx.conf
│
├── scripts/
│   └── init-db.sql
│
├── .env.example
├── docker-compose.yaml
├── docker-compose.override.yaml
├── docker-compose.prod.yaml
├── start.sh
├── stop.sh
├── logs.sh
├── README.md
└── .gitignore
```

## Evidence

**1.**
![alt text](<../task-5-fullstack-app/evidence/1.png>)

**2.**
![alt text](<../task-5-fullstack-app/evidence/2.png>)

**3.**
![alt text](<../task-5-fullstack-app/evidence/3.png>)

**4.**
![alt text](<../task-5-fullstack-app/evidence/4.png>)

**5.**
![alt text](<../task-5-fullstack-app/evidence/5.png>)

**6.**
![alt text](<../task-5-fullstack-app/evidence/6.png>)