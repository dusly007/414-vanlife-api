# ─── Étape 1 : Build de l'application ───
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
# Installe TOUTES les dépendances (y compris le compilateur NestJS)
RUN npm ci

COPY . .
# Compile le TypeScript en JavaScript (crée le dossier /dist)
RUN npm run build

# ─── Étape 2 : Image de production finale ───
FROM node:20-alpine AS runner
WORKDIR /app

# Définir l'environnement sur production
ENV NODE_ENV=production

COPY package*.json ./
# Installe UNIQUEMENT les dépendances requises pour l'exécution (sans les devDependencies)
RUN npm ci --only=production

# Copie uniquement le code compilé depuis l'étape précédente
COPY --from=builder /app/dist ./dist

# Sécurité : Exécuter l'application avec un utilisateur non-privilégié
USER node

EXPOSE 3000

CMD ["node", "dist/main"]