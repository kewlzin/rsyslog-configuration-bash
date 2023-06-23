#!/bin/bash

rootlog='if [ $(id -u) -eq 0 ]; then
    function log_command {
        logger -p local1.notice -t "root-shell[$$]" "[$(who):$(pwd)] ran command '\''$BASH_COMMAND'\'' from the root user"
    }
    trap '\''log_command'\'' DEBUG
fi'

main() {
		if(systemctl is-enabled rsyslog.service); then
		configure_log
		else
		install_rsyslog
		fi

}

configure_log() {
	echo "*.*@x.x.x.x:x;RSYSLOG_SyslogProtocol23Format" > /etc/rsyslog.d/60-graylog.conf
		systemctl restart rsyslog

		FILE=/etc/rsyslog.d/60-graylog.conf
		if [ -f "$FILE" ]; then
			echo "$FILE foi criada com sucesso."
			echo "O arquivo de log foi configurado para enviar todos os logs para o servidor"
			echo "Para escolher o tipo de log enviado, altere o arquivo /etc/rsyslog.d/60-graylog.conf"
			echo "Para saber como configurar acesse https://www.rsyslog.com/doc/master/configuration/sysklogd_format.html"
			echo "Para saber como configurar acesse https://wiki.archlinux.org/title/rsyslog"
			if	echo "$rootlog" >> /root/.bashrc ; then
				echo "Log de usuário root feito com sucesso"
			else
				echo "Erro ao criar log de usuário root"
			fi
		else
			echo "ERRO! $FILE não foi criada"
		fi
}

install_rsyslog(){
	echo "rsyslog não encontrado."
	read -p "Instalar rsyslog? (Y/N)" resposta
	case $resposta in
	Y) download_rsyslog;;
	N) echo "Ok, saindo" exit;;
	*) echo "Tente novamente";;
	esac

}

download_rsyslog(){
	echo "instalando rsyslog"
	packagesNeeded='rsyslog'
	if [ -x  "$(command -v apk)" ]; then apk add --no-cache $packagesNeeded
	elif [ -x "$(command -v apt-get)" ]; then apt-get install $packagesNeeded
	elif [ -x "$(command -v apt)" ]; then apt install $packagesNeeded
	elif [ -x "$(command -v dnf)" ]; then dnf install $packagesNeeded 
	else echo "Falha ao instalar o pacote rsyslog, tente instalar manualmente"
	fi
}

main
