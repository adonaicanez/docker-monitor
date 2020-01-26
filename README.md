Descrição

Esse projeto tem a proposta de criar um serviço que execute no linux para realizar a coleta das informações de containers Docker, disponibilizando para o monitoramento pelo Zabbix 4.

O foco do sistema é executar sem precisar instalar pacotes novos no sistema operaçional o que é ruim para servidores que estejam em produção, pois aumenta a lista de vulnerablidades do SO e deixam o sistema mais pesado e lento.

Buscando essa caracteristica o docker-monitor é escrito em shell script, tentando utilizar apenas recursos que mesmo a instalação mais mais básica do sistema tera capacidade de atender.


Instalação

A instalação do sistema é bem simples. Executar todos os comandos comoo root, no servidor que o módulo vai ser instalado. Antes de começar a instalação é necessa´rio que voce já tenha instalado nesse servidor o Docker e o agente do zabbix, ambos já configurados e funcionando.

1) Clonar o projeto no computador que ele vai ser instalado.
root@ns4:~# git clone https://github.com/adonaicanez/docker-monitor.git

2) Entrar na pasta raiz do projeto docker-monitor que foi criada pelo git clone e executar o arquivo de instalação.
Esse instalador ira copiar os arquivos do projeto para os seguintes diretórios:
/etc/systemd/system/ - arquivo que controla o service do projeto, ele ira iniciar e parar o serviço de coleta de estatisticas.
/opt/docker-monitor/ - nesse diretório ira ficar os scripts do serviço que realizam as coletas das estatisticas dos containers.
/etc/zabbix/zabbix_agentd.conf.d/ - arquivo de user parameters do agente do zabbix que sera utilizado pelo template que sera criado no zabbix server.
O usuário zabbix será incluido no grupo docker, isso permite ao zabbix coletar o nome do container, caso não sera feito isso os containers serão identificados pelo id no zabbix, o que fica muito ruim durante a visualização dos dados no dashboard do zabbix
tambem vai ser habilitado e inicilizado o serviço do docker-monitor no systemd

root@ns4:~/docker-monitor# ./install.sh

3) Verifique se realmente o serviço docker-monitor estar em execução

root@ns4:~# systemctl status docker-monitor.service

4) Agora é só importar para o zabbix server o template de itens chamado Template-Docker-monitor.xml, que esta no diretório /docker-monitor/template_zabbix e vincular ele nó servidor que o serviço esta rodando, dentro de alguns minutos os containers e itens irão começar a aparecer no zabbix.

Obs: Esse instalador foi testado no Debian 10, com o Zabbix-agent e o docker instalados atraves dos repositórios oficias de cada projeto, quem uitilizar versões de linux diferentes pode ser necessário fazer alguns ajustes para que tudo funcione perfeitamente.
