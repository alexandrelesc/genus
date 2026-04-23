#### Simple Script for RTL->Gate-Level Flow ####
# Este script realiza a síntese de um MUX 4:1 (mux4)
# utilizando o Genus, desde a leitura do RTL até a geração da netlist.
# genus -files run_mux4.tcl

# *************************************************
# * Local Variable settings for this design
# *************************************************

set LOCAL_DIR [exec pwd]
# Obtém o diretório atual onde o script está sendo executado
# Equivalente ao comando "pwd" no terminal Linux

set RTL_PATH  $LOCAL_DIR/source
# Define o caminho onde está o código RTL (SystemVerilog)

set LIB_PATH  $LOCAL_DIR/library
# Define o caminho onde está a biblioteca tecnológica (.lib)

set LIBRARY   tsmc180nm.lib
# set LIBRARY   gscl45nm.lib
# Nome da biblioteca a ser utilizada
# "slow" normalmente representa o pior caso de timing (mais conservador)

set RTL_FILE  mux4.sv
# Nome do arquivo SystemVerilog do design

set DESIGN    mux4
# Nome do módulo principal (top-level)
# Deve ser exatamente igual ao nome do módulo no arquivo .sv

# *********************************************************
# * Display basic info
# *********************************************************

puts "Running synthesis for design: $DESIGN"
# Exibe no console qual design está sendo sintetizado

puts "Current directory: $LOCAL_DIR"
# Mostra o diretório atual

puts "Hostname : [info hostname]"
# Mostra o nome da máquina onde o script está rodando

# ###################################
# # Load Design
# ###################################

read_lib $LIB_PATH/$LIBRARY
# Carrega a biblioteca tecnológica (.lib)
# Contém informações das células padrão:
# - área
# - potência
# - timing

read_hdl -sv $RTL_PATH/$RTL_FILE
# Lê o código RTL em SystemVerilog
# O parâmetro "-sv" garante suporte a:
# - logic
# - always_comb
# - outras construções SystemVerilog

elaborate $DESIGN
# Elabora o design:
# - resolve hierarquia
# - conecta sinais
# - cria representação interna do circuito

# current_design $DESIGN
# (Opcional) Define explicitamente o design atual
# Útil em projetos maiores com múltiplos módulos

puts "Runtime & Memory after elaboration"
# Mensagem informativa

timestat Elaboration
# Mostra estatísticas de tempo e memória após a elaboração

check_design -unresolved
# Verifica erros no design:
# - sinais não conectados
# - módulos não encontrados
# - problemas de ligação

# ###################################
# # Synthesize
# ###################################

syn_gen
# Síntese genérica:
# Converte o RTL em uma representação lógica abstrata
# Ainda não usa células da biblioteca

puts "Runtime & Memory after syn_gen"

timestat GENERIC
# Estatísticas após síntese genérica

syn_map
# Mapeamento tecnológico:
# Substitui a lógica abstrata por células reais da biblioteca

puts "Runtime & Memory after syn_map"

timestat MAPPED
# Estatísticas após mapeamento

syn_opt
# Otimização:
# - melhora área
# - melhora potência
# - pode simplificar lógica

puts "Runtime & Memory after syn_opt"

timestat OPTIMIZED
# Estatísticas após otimização final

# ###################################
# # Reports
# ###################################

report area  > ${DESIGN}_area.txt
# Gera relatório de área total do circuito
# O ">" salva a saída em arquivo

report power > ${DESIGN}_power.txt
# Gera relatório de potência:
# - leakage (estática)
# - internal
# - switching

report gates > ${DESIGN}_gates.txt
# Mostra quantidade de portas/células utilizadas

# ###################################
# # Netlist
# ###################################

write_hdl > ${DESIGN}_netlist.v
# Exporta a netlist final em Verilog
# Já mapeada em células da biblioteca

# ###################################
# # Finalização
# ###################################

puts "============================"
puts "Synthesis Finished ........."
puts "============================"
# Mensagem final

exit
# Encerra o Genus automaticamente
