# Prática de síntese e temporização do contador — Cadence Genus, Legacy UI.
# No Linux: entre em genuscounter e abra o Genus com genus ou genus -legacy_ui.
# No Genus: digite as instruções na ordem dos slides, uma de cada vez.
# Para executar o arquivo de uma vez: source /caminho/para/Roteiro_Counter_Genus.tcl
# Entradas esperadas na pasta de partida: source/counter.v e library/fast.lib.
# Restrições acrescentadas para a aula: um clock, T = 10.000 ps, e entrada m com 1.000 ps.
# Os comandos nativos define_clock e external_delay abaixo usam picosegundos.

# Seleciona a Legacy UI antes da leitura da biblioteca e do RTL.
if {[is_common_ui_mode]} {
  set_db common_ui false
}

# 02 — Pasta de trabalho e caminhos de entrada
# Se library estiver no diretório pai, ajuste LIB_PATH na atribuição abaixo.
# Captura o caminho da pasta atual do Linux. Os colchetes executam o comando interno.
set LOCAL_DIR "[exec pwd]"
# Copia o caminho para uma variável reservada pelo template.
set SYNTH_DIR $LOCAL_DIR
# Monta o caminho da pasta onde está o código Verilog.
set RTL_PATH $LOCAL_DIR/source
# Monta o caminho da pasta onde está a biblioteca de células.
set LIB_PATH $LOCAL_DIR/library

# 03 — Arquivos de entrada e módulo de topo
# Seleciona o arquivo Liberty que descreve as células da condição rápida.
set LIBRARY {fast.lib}
# Guarda o nome do único arquivo RTL usado neste exemplo.
set FILE_LIST {counter.v}
# Define o nome do módulo de topo para a elaboração.
set DESIGN counter
# Guarda uma segunda cópia do nome do topo, reservada pelo template.
set top_module $DESIGN
# Guarda a flag de DFT com valor zero. O trecho enviado apenas armazena esse valor.
set WITH_DFT 0

# 04 — Esforço de síntese
# Escolhe esforço alto para a síntese genérica da lógica RTL.
set SYN_EFFORT high
# Escolhe esforço alto para o mapeamento em células da biblioteca.
set MAP_EFFORT high
# Escolhe esforço alto para a otimização incremental da netlist.
set OPT_EFFORT high

# 05 — Pastas de cada execução
# Obtém a data e a hora. O formato usa mês abreviado, dia, hora, minuto e segundo.
set DATE [clock format [clock seconds] -format "%b%d-%T"]
# Define o nome da pasta que receberá a netlist e o SDC.
set _OUTPUTS_PATH outputs_${DATE}
# Reserva um nome de pasta para logs do projeto.
set _LOG_PATH logs_${DATE}
# Define a pasta dos relatórios de síntese e temporização.
set _REPORTS_PATH reports_${DATE}
# Acréscimo ao template. Cria as pastas antes de gravar qualquer arquivo.
file mkdir $_OUTPUTS_PATH $_LOG_PATH $_REPORTS_PATH

# 06 — Identificação da máquina
# Mostra a data da execução. A sequência \n acrescenta uma quebra de linha.
puts "The DATE is ${DATE} \n"
# Se o arquivo existir, o primeiro grep lista o modelo da CPU e o segundo consulta a frequência informada pelo Linux.
if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz" /proc/cpuinfo
}
# Imprime o nome da máquina em que o Genus está rodando.
puts "Hostname : [info hostname]"

# 07 — Leitura e elaboração do contador
# Na Legacy UI, carrega a biblioteca de células indicada no atributo library da raiz.
set_attribute library $LIB_PATH/$LIBRARY /
# Lê e analisa a descrição Verilog de counter.v.
read_hdl $RTL_PATH/$FILE_LIST
# Elabora o módulo counter e resolve sua hierarquia, instâncias e parâmetros.
elaborate $DESIGN

# 08 — Verificação do projeto elaborado
# Imprime a mensagem do template. Neste ponto, a elaboração também já terminou.
puts "Runtime & Memory after 'read_hdl'"
# Registra estatísticas de execução no marco identificado como Elaboration.
timestat Elaboration
# Procura referências a módulos ou células que ficaram sem resolução.
check_design -unresolved

# 09 — Clock de 100 MHz
# Exemplo didático de setup; quando houver um SDC do projeto, use uma única fonte de restrições.
# Um clock de 100 MHz tem período de 10 ns, ou 10.000 ps.
set PERIOD_PS 10000
# Obtém a porta de clock que o Genus reconheceu no contador elaborado.
set CLK_PORT [clock_ports]
# Confere que o exemplo tem uma única porta de clock reconhecida.
if {[llength $CLK_PORT] != 1} {
  error "Confira a porta de clock do contador."
}
# Cria o clock clk_aula e guarda o objeto que será usado nas restrições.
set CLK_OBJ [define_clock -name clk_aula -period $PERIOD_PS $CLK_PORT]

# 10 — Atraso de entrada de m
# Localiza a porta m usada no exemplo da aula.
set M_PORT [find / -port m]
# Confere que a busca retornou uma única porta.
if {[llength $M_PORT] != 1} {
  error "Confira a porta de entrada m no RTL."
}
# Modela a chegada do dado em m a 1.000 ps da borda de referência do clock.
external_delay -input 1000 -clock $CLK_OBJ $M_PORT
# Exibe os clocks ativos. Localize clk_aula e confira seu período.
report clocks

# 11 — Síntese genérica
# Aplica à ferramenta o esforço escolhido para esta fase.
set_attribute syn_generic_effort $SYN_EFFORT /
# Executa a síntese genérica do circuito.
syn_generic
# Identifica a fase concluída no texto do console.
puts "Runtime & Memory after 'synthesize -to_generic'"
# Registra as estatísticas de execução após a síntese genérica.
timestat GENERIC
# Grava o relatório das estruturas de datapath reconhecidas nesta fase.
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_generic.rpt

# 12 — Mapeamento em células padrão
# Aplica o esforço de mapeamento.
set_attribute syn_map_effort $MAP_EFFORT /
# Mapeia e otimiza a lógica usando as células disponíveis na biblioteca.
syn_map
# Identifica no console o fim do mapeamento.
puts "Runtime & Memory after 'synthesize -to_map'"
# Registra as estatísticas de execução após o mapeamento.
timestat MAPPED
# Grava o relatório de datapath correspondente à versão mapeada.
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_map.rpt

# 13 — Otimização incremental
# Configura o esforço da etapa incremental.
set_attribute syn_opt_effort $OPT_EFFORT /
# Otimiza a implementação mapeada considerando as restrições ativas.
syn_opt
# Imprime o nome da etapa que acabou de terminar.
puts "Runtime & Memory after incremental synthesis"
# Registra as estatísticas do processo com o rótulo INCREMENTAL.
timestat INCREMENTAL

# 14 — Área e células mapeadas
# Mostra a área reportada para o projeto. Identifique a linha do módulo counter.
report area
# Grava o mesmo tipo de relatório em counter_area.rpt.
report area > $_REPORTS_PATH/${DESIGN}_area.rpt
# Lista as células mapeadas e suas quantidades. Procure portas e flip-flops.
report gates
# Grava o relatório de células em counter_gates.rpt.
report gates > $_REPORTS_PATH/${DESIGN}_gates.rpt

# 15 — Relatórios de temporização
# Verifica possíveis lacunas ou inconsistências nas restrições de temporização.
report timing -lint
# Exibe o relatório de temporização para os caminhos selecionados pelo Genus.
report timing
# Salva o relatório geral em counter_timing.rpt.
report timing > $_REPORTS_PATH/${DESIGN}_timing.rpt
# Restringe a consulta aos caminhos que começam na entrada m.
report timing -from $M_PORT
# Salva a consulta específica em counter_timing_m.rpt.
report timing -from $M_PORT > $_REPORTS_PATH/${DESIGN}_timing_m.rpt

# 17 — Netlist e restrições para a próxima etapa
# Escreve a netlist Verilog mapeada em counter.v, na pasta de saídas.
write_hdl > ${_OUTPUTS_PATH}/${DESIGN}.v
# Exporta as restrições ativas da sessão para o arquivo counter.sdc.
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}.sdc

# 18 — Fim da execução
# Anuncia a leitura final de recursos no console.
puts "Final Runtime & Memory."
# Registra as estatísticas de execução ao final do fluxo.
timestat FINAL
# Execute as três linhas em sequência. Cada puts imprime uma linha da mensagem final.
puts "============================"
puts "Synthesis Finished ........."
puts "============================"
# A linha é um comentário. A sessão permanece disponível para consultar os resultados.
#exit

# Opcional, no prompt do Genus com sessão gráfica disponível:
# gui_show
