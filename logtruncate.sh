#!/bin/bash

# Nome do arquivo de log
LOG_FILE="mega_log"
DATE=$(date +"%Y%m%d")
BACKUP_FILE="mega_log-$DATE.gz"

# Inicia o buffer dos logs atuais em segundo plano
tail -F "$LOG_FILE" > temp_log &
TAIL_PID=$!

# Captura o PID do tail e garante que será encerrado ao sair do script
trap "kill $TAIL_PID; rm -f temp_log" EXIT

# Faz uma cópia do log antes de truncar
cp "$LOG_FILE" "${LOG_FILE}_copy"

# Trunca o log sem perder o file descriptor (  no AIX: cat /dev/null > "$LOG_FILE" )
truncate -s 0 "$LOG_FILE"

# Concatena o buffer ao backup antes de matar o tail
cat temp_log >> "${LOG_FILE}_copy"

# Mata o processo tail
kill $TAIL_PID
wait $TAIL_PID 2>/dev/null  # Aguarda a finalização

# Compacta e arquiva o log
gzip "${LOG_FILE}_copy"
mv "${LOG_FILE}_copy.gz" "$BACKUP_FILE"

# Limpa arquivos temporários
rm -f temp_log

# Valida se continua escrevendo no arquivo truncado
tail -F "$LOG_FILE"
