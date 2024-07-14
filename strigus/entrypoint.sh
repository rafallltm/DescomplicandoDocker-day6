#!/bin/bash

# Função para exibir mensagens de log
log() {
    echo "[$(date +"%Y-%m-%d %T")] $1"
}

# Verificar se o Python3 e pip estão instalados
log "Verificando se o Python3 e pip estão instalados..."
if ! command -v python3 &> /dev/null; then
    log "Python3 não encontrado. Isso é inesperado, pois a imagem base é python:3.9-alpine."
    exit 1
else
    log "Python3 já está instalado. Versão: $(python3 --version)"
fi

if ! command -v pip &> /dev/null; then
    log "pip não encontrado. Isso é inesperado, pois a imagem base é python:3.9-alpine."
    exit 1
else
    log "pip já está instalado. Versão: $(pip --version)"
fi

# Instalar o ambiente virtual (já incluído na imagem base do Python)
log "Instalando o ambiente virtual Python..."
apk add --no-cache python3-dev
if [ $? -ne 0 ]; then
    log "Falha na instalação do módulo python3-dev."
    exit 1
fi

# Criar e ativar o ambiente virtual
log "Criando e ativando o ambiente virtual..."
python3 -m venv my-env
if [ $? -ne 0 ]; then
    log "Falha na criação do ambiente virtual."
    exit 1
fi
source my-env/bin/activate

# Instalar as dependências da aplicação
log "Instalando as dependências da aplicação..."
pip install --no-cache-dir -r requirements.txt
if [ $? -ne 0 ]; then
    log "Falha na instalação das dependências."
    exit 1
fi

# Instalar o Redis
log "Instalando o Redis..."
apk add --no-cache redis
if [ $? -ne 0 ]; then
    log "Falha na instalação do Redis."
    exit 1
fi

# Iniciar o Redis
log "Iniciando o Redis..."
redis-server &
if [ $? -ne 0 ]; then
    log "Falha ao iniciar o Redis."
    exit 1
fi

# Configurar a variável de ambiente para o Redis
log "Configurando a variável de ambiente para o Redis..."
export REDIS_HOST=localhost

# Iniciar a aplicação
log "Iniciando a aplicação..."
flask run --host=0.0.0.0 --port=${PORT}
