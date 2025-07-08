#!/usr/bin/env python3

import os

TSV_DIR = "tsv"

META_FILES = [
    os.path.join(TSV_DIR, "bac120_metadata_r220.tsv"),
    os.path.join(TSV_DIR, "arc53_metadata_r220.tsv")
]

FASTA_DIR = "GTDB/gtdb_genomes_reps_r220/modified_gtdb_genomes"

OUT_DIR = "GTDB/gtdb_genomes_reps_r220/modified_gtdb_genomes_2"
os.makedirs(OUT_DIR, exist_ok=True)

accession2taxid = {}

for mf in META_FILES:
    with open(mf, 'r') as f:
        header = f.readline().rstrip('\n').split('\t')
        try:
            acc_idx = header.index("accession")
            tax_idx = header.index("ncbi_taxid")
        except ValueError:
            print(f"[WARNING] Column 'accession' or 'ncbi_taxid' not found in {mf}.")
            continue
        
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            parts = line.split('\t')
            if len(parts) <= max(acc_idx, tax_idx):
                continue
            
            acc_raw = parts[acc_idx]
            ncbi_taxid = parts[tax_idx].strip()
            
            if not ncbi_taxid or ncbi_taxid.lower() == "none":
                continue
            
            acc_clean = acc_raw.replace("RS_", "").replace("GB_", "")
            
            accession2taxid[acc_clean] = ncbi_taxid

for fname in os.listdir(FASTA_DIR):
    if not fname.endswith(".fna"):
        continue
    
    base_name = fname[:-4]
    base_name = base_name.replace("_genomic", "")
    
    if base_name not in accession2taxid:
        print(f"[WARNING] Accession not found in metadata: {base_name}")
        continue
    
    taxid = accession2taxid[base_name]
    
    in_path = os.path.join(FASTA_DIR, fname)
    out_path = os.path.join(OUT_DIR, fname)
    
    with open(in_path, 'r') as fin, open(out_path, 'w') as fout:
        for line in fin:
            if line.startswith(">"):
                old_header = line.strip()[1:]
                new_line = f">kraken:taxid|{taxid} {old_header}\n"
                fout.write(new_line)
            else:
                fout.write(line)

print("Done. Modified FASTA files are in:", OUT_DIR)
