#!/bin/bash

fastqc "$1.fastq.gz"
mv "$1_fastqc.html" "$1.html"
rm "$1_fastqc.zip"

#bwa index "$2"
bwa mem "$2" "$1.fastq.gz" > "$1.sam"
samtools view -b "$1.sam" -o "$1.bam"
samtools flagstat "$1.bam" > "$1.txt"

mapped=$(cat "$1.txt" | grep -E "^([[:digit:]]+ \+ [[:digit:]] mapped \([[:digit:]]{,2}\.[[:digit:]]{,2}%)" | awk '{print $5}' | tr -d "(%")

if (( $(echo "$mapped < 90" | bc) )); then
    echo "Mapping quality is below 90%. Aborting pipeline."
    exit 1
else
    echo "Mapping quality is sufficient."
fi

samtools sort "$1.bam" > "$1.sorted.bam"
freebayes -f "$2" "$1.sorted.bam" > "$1.vcf"

echo "Pipeline finished successfully. Output VCF file: $1.vcf"
