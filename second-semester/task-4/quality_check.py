import re

with open(snakemake.input[0], 'r') as f:
    successful_parsing = False
    for line in f:
        match = re.match(r'^(\d+\s\+\s\d+ mapped \((\d{1,2}\.\d{1,2})%)', line)
        if match:
            successful_parsing = True
            mapped = float(match.group(2).strip())
            if mapped < 90:
                raise ValueError("Mapping quality is below 90%")
            else:
                print(f"Mapping quality is sufficient: {mapped}% mapped")
if (not successful_parsing):
    raise ValueError(f'Unable to parse {snakemake.input[0]}')
