#!/bin/bash

shopt -s lastpipe

DIR=$(builtin cd $(dirname $0)"/.."; pwd)
FILE_PREFIX="kursinis-saukrs"

LOSS_P="0" #%
echo "$LOSS_P / 100" | bc -l | xargs printf "%.2f" | read LOSS

# $ftp1 veikia steke su CC-algoritmu HSTCP
# $ftp2 veikia steke su CC-algoritmu BIC

# Vėlinimas pagal kursinio darbo užduotį, ms:
for DELAY in 2 6 80; do
    ns $DIR/Saulius-Krasuckas/kursinis-saukrs.tcl -- "${DELAY}ms" ${LOSS} ${FILE_PREFIX} \
        0.1 '$ftp1 start' \
        0.1 '$ftp2 start' \
        2.8 '$ftp1 stop'  \
        2.8 '$ftp2 stop'  \
        3.0 'finish'
    cat ${FILE_PREFIX}.tr | grep '^r .* 2 3' | awk -f $DIR/tools/NS-2/Throughput.awk 2>&1 \
      1>${FILE_PREFIX}-${DELAY}ms-${LOSS_P}%.throughput
done

ls -l ${FILE_PREFIX}*.{tr,nam,throughput}
rm -v ${FILE_PREFIX}*.{tr,nam}

DIAGRAM1="${DIR}/Saulius-Krasuckas/output/kursinis-saukrs-0%.throughput-by-time.png"
gnuplot -e 'file_out="'${DIAGRAM1}'"' $DIR/Saulius-Krasuckas/kursinis-saukrs-throughput-by-delay.p
gio open ${DIAGRAM1}
