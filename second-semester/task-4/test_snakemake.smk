rule all:
    input:
        "up_input.txt"
rule test:
    input:
        "{sample}.txt"
    output:
        "up_{sample}.txt"
    shell:
        "cat {input} | tr [:lower:] [:upper:] > {output}"