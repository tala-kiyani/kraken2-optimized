#!/bin/bash
# Master script to build a Kraken 2 database using GTDB representative genomes
# mapped to NCBI taxonomy.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- STAGE 1: Preparing Directories and Downloading Data ---"
mkdir -p GTDB/modified_gtdb_genomes GTDB/modified_gtdb_genomes_2 Taxonomy tsv

echo "Downloading GTDB representative genomes (Release 220)..."
wget -O gtdb_genomes_reps_r220.tgz \
  https://data.ace.uq.edu.au/public/gtdb/data/releases/release220/220.0/genomic_files_reps/gtdb_genomes_reps_r220.tar.gz

echo "Downloading NCBI-style taxonomy dump..."
wget -O taxdump.tar.gz https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/taxdump_20240914.tar.gz

echo "Downloading GTDB metadata..."
wget -P tsv/ https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/ar53_metadata.tsv.gz
wget -P tsv/ https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/bac120_metadata.tsv.gz

echo "--- STAGE 2: Extracting Data ---"
echo "Extracting metadata..."
gunzip -c tsv/ar53_metadata.tsv.gz > tsv/ar53_metadata_r220.tsv
gunzip -c tsv/bac120_metadata.tsv.gz > tsv/bac120_metadata_r220.tsv

echo "Extracting genome archive..."
tar -C GTDB -xf gtdb_genomes_reps_r220.tgz

echo "Extracting NCBI taxonomy..."
tar -C Taxonomy -xf taxdump.tar.gz

echo "--- STAGE 3: Decompressing Individual Genomes ---"
# This script reads genome_paths.tsv and unzips .fna.gz files
bash unzip_genome.sh

echo "--- STAGE 4: Modifying FASTA Headers with NCBI TaxIDs ---"
# This script reads metadata, finds NCBI TaxIDs, and rewrites FASTA headers.
python3 modify_headers.py

echo "--- STAGE 5: Building the Final Kraken 2 Database ---"
# This script adds the modified genomes to the library and builds the database.
# IMPORTANT: Edit the paths and parameters (X, Y) inside this script first!
bash build_kraken2.bash

echo "✅ All stages complete. GTDB database build process finished."