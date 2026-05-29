# Use uma imagem base com Ruby
FROM ruby:3.1.0

# Instala dependências
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl gnupg postgresql-client python3 python3-pip \
    && pip3 install pandas \
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js e npm via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Instala Yarn (Node.js version) via npm
RUN npm install -g yarn

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia Gemfile
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

# Copia package.json
COPY package.json yarn.lock* ./
RUN yarn install

# Copia código
COPY . .

# Expõe a porta
EXPOSE 3000

# Comando para iniciar
CMD ["sh", "-c", "rails db:migrate:status | grep 'down' > /dev/null && rails db:migrate || echo 'Migrações já aplicadas'; rails db:seed && rails server -b 0.0.0.0"]