rule all:
    input:
        "SRR11413027.html",
        "SRR11413027_hg38.vcf"


rule fastqc:
    input:
        "{sample}.fastq.gz"
    output:
        "{sample}.html"
    shell:
        """
        fastqc {wildcards.sample}.fastq.gz
        mv {wildcards.sample}_fastqc.html {wildcards.sample}.html
        rm {wildcards.sample}_fastqc.zip"""

rule bwa_map:
    input:
        "{ref}.fa",
        "{sample}.fastq.gz"
    output:
        "{sample}_{ref}.sam"
    shell:
        "bwa mem {input} > {output}"
rule sam_to_bam:
    input:
        "{sample}.sam"
    output:
        "{sample}.bam"
    shell:
        "samtools view -b {input} -o {output}"

rule samtools_flagstat:
    input:
        "{sample}.bam"
    output:
        "{sample}.txt"
    shell:
        "samtools flagstat {input} > {output}"

rule check_mapping_quality:
    input:
        "{sample}.txt"
    output:
        touch("{sample}-quality_check_passed.txt")
    script:
        "quality_check.py"

rule samtools_sort:
    input:
        "{sample}-quality_check_passed.txt",
        bam="{sample}.bam"
    output:
        "{sample}.sorted.bam"
    shell:
        "samtools sort {input.bam} > {output}"

rule freebayes:
    input:
        bam="{sample}_{ref}.sorted.bam",
        reference="{ref}.fa"
    output:
        "{sample}_{ref}.vcf"
    shell:
        "freebayes -f {input.reference} {input.bam} > {output}"
