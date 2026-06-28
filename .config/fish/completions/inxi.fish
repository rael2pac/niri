# Completions for inxi
complete -c inxi -s '-' -l -d "Opções para o inxi"

# Informações gerais
complete -c inxi -s 'S' -d "Informações do sistema (hostname, kernel, distro)"
complete -c inxi -s 'F' -d "Informações completas do sistema"
complete -c inxi -s 'A' -d "Informações de áudio"
complete -c inxi -s 'B' -d "Informações de bateria"
complete -c inxi -s 'I' -d "Informações de dispositivos de entrada/saída"
complete -c inxi -s 'M' -d "Informações de memória (RAM e swap)"
complete -c inxi -s 'R' -d "Executa benchmark do sistema"

# Hardware específico
complete -c inxi -s 'C' -d "Informações da CPU (modelo, velocidade, threads)"
complete -c inxi -s 'G' -d "Informações da GPU e gráficos (driver, resolução)"
complete -c inxi -s 'D' -d "Informações de discos (tamanho, tipos)"
complete -c inxi -s 'P' -d "Informações de partições"
complete -c inxi -s 'N' -d "Informações de rede (interfaces e status)"
complete -c inxi -s 'L' -d "Informações de sensores (temperatura, voltagem)"

# Configuração avançada
complete -c inxi -s 'x' -d "Exibe informações extras detalhadas"
complete -c inxi -s 'xx' -d "Exibe informações muito detalhadas (debug)"
complete -c inxi -s 'xxx' -d "Exibe todas as informações possíveis (modo completo)"
complete -c inxi -s 'z' -d "Oculta informações sensíveis (privacidade)"

# Rede e conectividade
complete -c inxi -s 'r' -d "Informações de repositórios configurados"
complete -c inxi -s 'i' -d "Informações de rede (IP, gateway, DNS)"
complete -c inxi -s 'n' -d "Informações detalhadas de interfaces de rede"
complete -c inxi -s 'w' -d "Informações de Wi-Fi (SSID, sinal, canal)"
complete -c inxi -s 'E' -d "Informações de adaptadores Bluetooth e dispositivos pareados"

# Outras opções úteis
complete -c inxi -s 'h' -d "Exibe a ajuda do comando inxi"
complete -c inxi -s 'v' -d "Exibe a versão do inxi"
complete -c inxi -s 't' -d "Exibe tempos de inicialização de serviços"
complete -c inxi -s 'e' -d "Exibe informações sobre erros"


