# Susidėliokim simuliatorių:
set ns [new Simulator]

# Generuosime TR-formato treisus:
set ntf [open kursinis-saukrs.tr w]
$ns trace-all $ntf

# Generuosime NAM-formato treisus:
set nmf [open kursinis-saukrs.nam w]
$ns namtrace-all $nmf

# Prireiks uždarymo procedūros:
proc finish {} {
    puts "Simuliacijos pabaiga."
    global ns ntf nmf               ; # pasiimam pora globalių kintamųjų
    $ns flush-trace                 ; # išsaugom treiso likučius į failą
    close $ntf                      ; # uždarom treisą
    close $nmf                      ; # uždarom NAM-treisą
    exec nam kursinis-saukrs.nam &  ; # startuojam vizualizaciją
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
$tcp_source_1 set class_ 2              ; # BUG: jei "fid_" priskiriame prieš "class_", Trace-faile Flow-id tampa = 2
$tcp_source_1 set fid_ 1                ; # priskiriam Flow-id
$node_siustuvas_1 attach $tcp_source_1  ; # Prijungiame jį prie siustuvo_1

# Sukuriame vieną TCP srauto imtuvą:
set tcp_destination [new Agent/TCPSink]
$node_imtuvas attach $tcp_destination   ; # Prijungiame jį prie imtuvo nodo

# Sujungiame TCP agentus tarp "siustuvas_1" ir "imtuvas":
$ns connect $tcp_source_1 $tcp_destination

# Sukuriame FTP užpildą (Payload):
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp_source_1        ; # Prisegame jį prie TCP šaltinio
$ftp1 set type_ FTP

# Sukuriame UDP srauto šaltinį:
set udp_source_2 [new Agent/UDP]
$udp_source_2 set fid_ 2                ; # priskiriam Flow-id
$node_siustuvas_2 attach $udp_source_2  ; # Prijungiame jį prie siustuvo_2

# Sukuriame UDP srauto imtuvą (per Null-agentą su turbūt begaliniu pralaidumu):
set udp_destination [new Agent/Null]
$node_imtuvas attach $udp_destination   ; # Prijungiame jį prie imtuvo nodo

# Sujungiame UDP agentus tarp "siustuvas_2" ir "imtuvas":
$ns connect $udp_source_2 $udp_destination

# Sukuriame CBR užpildą (Payload):
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp_source_2        ; # Prisegame jį prie UDP šaltinio
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

# Tinklo topologiją žymime grafiškai:
$ns duplex-link-op $node_siustuvas_1 $node_parinktuvas orient down
$ns duplex-link-op $node_siustuvas_2 $node_parinktuvas orient right-up
$ns duplex-link-op $node_parinktuvas $node_imtuvas     orient right

puts "Simuliacijos pradžia..."

# Pradedame:
$ns run
