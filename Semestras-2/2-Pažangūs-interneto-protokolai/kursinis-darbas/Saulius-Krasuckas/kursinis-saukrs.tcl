# Susidėliokim simuliatorių:
set ns [new Simulator]

# Generuosime TR-formato treisus:
set nf [open kursinis-saukrs.tr w]
$ns trace-all $nf

# Prireiks uždarymo procedūros:
proc finish {} {
    puts "Simuliacijos pabaiga."
    global ns nf                    ; # pasiimam pora globalių kintamųjų:
    $ns flush-trace                 ; # išsaugom treiso likučius į failą:
    close $nf                       ; # uždarom treisą:
    # startuojam vizualizaciją
    # TODO ateičiai
    exit 0
}

# Kuriame nodus (pagal sample.tcl pradžiai):
set node_siustuvas_1   [$ns node]   ; # 0
set node_siustuvas_2   [$ns node]   ; # 1
set node_parinktuvas   [$ns node]   ; # 2
set node_imtuvas       [$ns node]   ; # 3

# Sukuriame reikiamas ryšio linijas pagal pvz.:
$ns duplex-link $node_siustuvas_1 $node_parinktuvas 2Mb 10ms DropTail
$ns duplex-link $node_siustuvas_2 $node_parinktuvas 2Mb 10ms DropTail
$ns duplex-link $node_parinktuvas $node_imtuvas 1.7Mb 20ms DropTail

# Tiriamai linijai nustatome Queue Size pagal pvz.:
$ns queue-limit $node_parinktuvas $node_imtuvas 10

# Sukuriame vieną TCP srauto šaltinį:
set tcp_source_1 [new Agent/TCP]
$tcp_source_1 set class_ 2
$tcp_source_1 set fid_ 1            ; # priskiriam Flow-id
# BUG: jei "fid_" priskiriame prieš "class_", Trace-faile Flow-id tampa = 1 kažkodėl
$node_siustuvas_1 attach $tcp_source_1  ; # Prijungiame srauto šaltinį prie siustuvo_1:

# Sukuriame vieną TCP srauto imtuvą:
set tcp_destination [new Agent/TCPSink]
$node_imtuvas attach $tcp_destination

# Sujungiame TCP agentus tarp "siustuvas_1" ir "imtuvas":
$ns connect $tcp_source_1 $tcp_destination

# Prisegame FTP užpildą (Payload) prie pirmojo TCP srauto šaltinio:
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp_source_1
$ftp1 set type_ FTP

# Sukuriame vieną UDP srauto šaltinį:
set udp_source_2 [new Agent/UDP]
$udp_source_2 set fid_ 2            ; # priskiriam Flow-id

# Prijungiame šį srauto šaltinį prie siustuvo_2:
$node_siustuvas_2 attach $udp_source_2

# Sukuriame UDP srauto imtuvą (per Null-agentą su turbūt begaliniu pralaidumu):
set udp_destination [new Agent/Null]
$node_imtuvas attach $udp_destination

# Sujungiame UDP agentus tarp "siustuvas_2" ir "imtuvas":
$ns connect $udp_source_2 $udp_destination

# Prisegame CBR užpildą (Payload) prie UDP srauto šaltinio:
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp_source_2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

# Sudarome tinklo įvykių grafiką (vėlgi pagal pvz.):
$ns at 0.1 "$cbr2 start"
$ns at 1.0 "$ftp1 start"
$ns at 4.0 "$ftp1 stop"
$ns at 4.5 "$cbr2 stop"

# Įvykdome uždarymo procedūrą praėjus 5s simuliacijos laiko:
$ns at 5.0 "finish"

puts "Simuliacijos pradžia..."

# Pradedame:
$ns run
