FROM node:22-bookworm

RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*

RUN npm install -g n8n@2.20.9 --unsafe-perm

CMD ["n8n"]