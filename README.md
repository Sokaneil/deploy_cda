# 89 Progress - Déploiement

Ce dépôt contient les configurations nécessaires pour déployer l'application 89 Progress, un système d'évaluation pour l'École 89.

## Dépendances Externes

### Backend (API)
- Node.js: v18.x
- Express: v4.18.x
- TypeScript: v5.1.x
- Sequelize: v6.32.x
- SQLite: v5.1.x
- JWT: v9.0.x
- Argon2: v0.41.x
- Zod: v3.22.x
- Express-rate-limit: v7.5.x

### Frontend
- Node.js: v18.x
- Next.js: v14.x
- React: v18.x
- Tailwind CSS: v3.x
- Headless UI: v1.x
- Heroicons: v2.x
- Axios: v1.x

### Infrastructure
- Docker: v24.x
- Docker Compose: v2.x
- Caddy: v2.x (Serveur Web et Proxy Inverse)

## Dépendances de Services

### Base de données
- Type: SQLite
- URL: Fichier local dans le volume Docker `database-data`
- Variables d'environnement:
  - `DB_STORAGE`: Chemin vers le fichier SQLite

### API Backend
- URL de production: http://backend:3000
- URL publique: http://HOSTNAME/api
- Variables d'environnement:
  - `NODE_ENV`: environment (production)
  - `PORT`: Port d'écoute (3000)
  - `JWT_SECRET`: Clé secrète pour la génération des tokens JWT
  - `ALLOWED_ORIGIN`: Origine autorisée pour CORS

### Frontend
- URL: http://HOSTNAME
- Variables d'environnement:
  - `NEXT_PUBLIC_API_URL`: URL de l'API (http://HOSTNAME/api)

## Déploiement

### Prérequis
- Docker et Docker Compose installés
- Accès SSH au serveur
- Git installé

### Instructions
1. Clonez les trois dépôts (backend, frontend, déploiement)
2. Copiez les Dockerfiles dans les dépôts frontend et backend
3. Créez un fichier `.env` dans le dépôt de déploiement avec toutes les variables d'environnement nécessaires
4. Exécutez `docker-compose up -d` dans le dépôt de déploiement

### Variables d'environnement
Créez un fichier `.env` dans le dépôt de déploiement avec les variables suivantes: