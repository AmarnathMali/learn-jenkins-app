FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm install -g node-jq netlify-cli@20.1.1 serve
RUN apt update
RUN apt install jq -y