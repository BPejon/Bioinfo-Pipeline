#!/bin/bash

# Configurações
FASTQ_DIR="raw_data"
FASTQC_DIR="fastqc_results"
ALIGNED_DIR="aligned"
GENOME_INDEX="/caminho/para/genome_index"  # Índice do genoma pré-construído
THREADS=8

# Criar diretórios de saída
mkdir -p $FASTQC_DIR
mkdir -p $ALIGNED_DIR

# 1. Controle de qualidade com FastQC
echo "=== Executando FastQC ==="
for fastq_file in $FASTQ_DIR/*.fastq.gz; do
    sample_name=$(basename $fastq_file .fastq.gz)
    echo "Processando: $sample_name"
    
    fastqc $fastq_file -o $FASTQC_DIR -t $THREADS
done

# Gerar relatório multimostra do FastQC
multiqc $FASTQC_DIR -o $FASTQC_DIR

# 2. Alinhamento com TopHat2
echo "=== Executando TopHat2 ==="

# Para dados single-end
for fastq_file in $FASTQ_DIR/*.fastq.gz; do
    sample_name=$(basename $fastq_file .fastq.gz)
    echo "Alinhando: $sample_name"
    
    tophat2 -p $THREADS \
            -o $ALIGNED_DIR/${sample_name}_tophat \
            $GENOME_INDEX \
            $fastq_file
done

# Para dados paired-end (descomente se for o caso)
# for read1 in $FASTQ_DIR/*_1.fastq.gz; do
#     read2=${read1/_1.fastq.gz/_2.fastq.gz}
#     sample_name=$(basename $read1 _1.fastq.gz)
#     
#     tophat2 -p $THREADS \
#             -o $ALIGNED_DIR/${sample_name}_tophat \
#             $GENOME_INDEX \
#             $read1 $read2
# done

echo "=== Pipeline concluído ==="
