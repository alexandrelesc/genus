# --------------------------------------------------------------
# Obtém o diretório atual onde o script está sendo executado
# --------------------------------------------------------------
set LOCAL_DIR [exec pwd]

# --------------------------------------------------------------
# Define o caminho onde está o código RTL (SystemVerilog)
# --------------------------------------------------------------
set RTL_PATH  $LOCAL_DIR/source

# --------------------------------------------------------------
# Define o caminho da biblioteca tecnológica (.lib)
# --------------------------------------------------------------
set LIB_PATH  $LOCAL_DIR/library

# --------------------------------------------------------------
# Nome da biblioteca utilizada (define tecnologia, timing, área)
# --------------------------------------------------------------
set LIBRARY   fast.lib

# --------------------------------------------------------------
# Nome do arquivo RTL
# --------------------------------------------------------------
set RTL_FILE  counter.sv

# --------------------------------------------------------------
# Nome do módulo top (deve bater com o RTL)
# --------------------------------------------------------------
set DESIGN    counter

# --------------------------------------------------------------
# Gera uma string com data/hora (para evitar sobrescrever arquivos)
# --------------------------------------------------------------
set DATE [clock format [clock seconds] -format "%b%d-%H-%M-%S"]

# --------------------------------------------------------------
# Define pasta de saída (netlist)
# --------------------------------------------------------------
set OUT_DIR outputs_$DATE

# --------------------------------------------------------------
# Define pasta de relatórios
# --------------------------------------------------------------
set REP_DIR reports_$DATE

# --------------------------------------------------------------
# Cria as pastas (se não existirem)
# --------------------------------------------------------------
file mkdir $OUT_DIR
file mkdir $REP_DIR

# --------------------------------------------------------------
# Carrega a biblioteca tecnológica
# Contém:
# - delays
# - área
# - potência
# --------------------------------------------------------------
read_lib $LIB_PATH/$LIBRARY

# --------------------------------------------------------------
# Lê o código RTL (SystemVerilog)
# -sv ativa suporte a SystemVerilog
# --------------------------------------------------------------
read_hdl -sv $RTL_PATH/$RTL_FILE

# --------------------------------------------------------------
# Elabora o design
# Resolve conexões e hierarquia
# --------------------------------------------------------------
elaborate $DESIGN

# --------------------------------------------------------------
# Define o design atual (top)
# --------------------------------------------------------------
current_design $DESIGN

# --------------------------------------------------------------
# Verifica erros no design:
# - sinais não conectados
# - módulos inexistentes
# --------------------------------------------------------------
check_design -unresolved

# --------------------------------------------------------------
# Define o clock do sistema
# period = 10 ns → 100 MHz
# --------------------------------------------------------------
create_clock -name clk -period 10 [get_ports clk]

# --------------------------------------------------------------
# Define atraso das entradas (exceto clk e rst)
# Significa que os dados chegam 1 ns após o clock
# --------------------------------------------------------------
set_input_delay 1 -clock clk \
    [remove_from_collection [all_inputs] [get_ports {clk rst}]]

# --------------------------------------------------------------
# Define atraso das saídas
# Significa que o circuito externo precisa de 1 ns
# --------------------------------------------------------------
set_output_delay 1 -clock clk [all_outputs]

# --------------------------------------------------------------
# Síntese genérica (RTL → lógica abstrata)
# --------------------------------------------------------------
syn_gen

# --------------------------------------------------------------
# Mapeamento tecnológico (lógica → células reais)
# --------------------------------------------------------------
syn_map

# --------------------------------------------------------------
# Otimização (melhora timing, área, potência)
# --------------------------------------------------------------
syn_opt

# --------------------------------------------------------------
# Gera relatório de área
# --------------------------------------------------------------
report area   > $REP_DIR/${DESIGN}_area.rpt

# --------------------------------------------------------------
# Gera relatório de potência
# --------------------------------------------------------------
report power  > $REP_DIR/${DESIGN}_power.rpt

# --------------------------------------------------------------
# Gera relatório de portas/células
# --------------------------------------------------------------
report gates  > $REP_DIR/${DESIGN}_gates.rpt

# --------------------------------------------------------------
# Gera relatório de timing (o mais importante)
# --------------------------------------------------------------
report timing > $REP_DIR/${DESIGN}_timing.rpt

# --------------------------------------------------------------
# Exporta netlist sintetizada (Verilog)
# --------------------------------------------------------------
write_hdl > $OUT_DIR/${DESIGN}_netlist.v

# --------------------------------------------------------------
# Exporta constraints (SDC)
# --------------------------------------------------------------
write_sdc > $OUT_DIR/${DESIGN}.sdc

# --------------------------------------------------------------
# Encerra o Genus
# --------------------------------------------------------------
exit
