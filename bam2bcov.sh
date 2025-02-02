#!/bin/bash
file=$1
file_ext=$(basename "${file}")
file_ext=${file_ext##*.}
file_raw=$(basename "${file}")
file_raw=${file_raw%.$file_ext}
file_link=$(basename "${file}")

threads=24
line=$(printf '—%.0s' {1..50})

function log { echo -e "\033[37m$1\033[0m"; }
function err { echo -e "\033[31m$1\033[0m"; }

# --------------------------------------------------------------------------- #
# 1. Download `mosdepth` + `bed2cov`

if [ ! -f './mosdepth' ]; then
  log $line 
  log "mosdepth not found! Downloading in progress\n"
  wget "https://github.com/brentp/mosdepth/releases/download/v0.3.11/mosdepth"
  chmod +x './mosdepth'
fi
if [ ! -f './bed2cov' ]; then
  log $line 
  log "bed2cov not found! Downloading in progress\n"
  wget "https://github.com/comp-bio/Bed2Cov/raw/main/build/bed2cov_$(uname)" -O ./bed2cov
  chmod +x './bed2cov'
fi

# --------------------------------------------------------------------------- #
# 2. .bam file index
if [ ! -f "${file_link}" ]; then
  ln -s "${file}" "${file_link}"
fi
if [ -f "${file}.bai" ]; then
  if [ ! -f "${file_link}.bai" ]; then
    ln -s "${file}.bai" "${file_link}.bai"
  fi
fi
if [ ! -f "${file_link}.bai" ]; then
  if ! command -v samtools &> /dev/null; then
    err $line
    err "ERROR! samtools not found!\n"
  fi
  log "samtools index ${file_link} ...\n"
  samtools index "${file_link}"
fi

# --------------------------------------------------------------------------- #
# 3. Extract depth-of-coverage from .bam file
if [ ! -f "${file_raw}.per-base.bed.gz" ]; then
  log "Extracting depth-of-coverage\n"
  ./mosdepth -t "$threads" "${file_raw}" "${file}";
fi

# --------------------------------------------------------------------------- #
# 4. Converting depth-of-coverage (.bed.gz) to .bcov
log "Converting .bed.gz -> .bcov"
mkdir -p "${file_raw}"
cd "${file_raw}"
gzip -cd ../"${file_raw}".per-base.bed.gz | ../bed2cov
# rm -f ./*_*.bcov ./*HLA*.bcov ./*EBV.bcov GL00*.bcov hs37d5.bcov
cd ../
rm -rf "${file_raw}.*" "${file_link}*" 
