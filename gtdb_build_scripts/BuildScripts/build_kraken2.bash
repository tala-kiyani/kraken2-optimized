#!/bin/bash

set -e

working_root="/kraken2-2.1.2"

output_dir="$working_root/Databases_KX_LY_C3/Kraken2"

reference="GTDB/gtdb_genomes_reps_r220/modified_gtdb_genomes_2"
db_name="strex"

build_prog="$working_root/kraken2-build"

mkdir -p $output_dir/$db_name/taxonomy

cp /Taxonomy/{nodes,names}.dmp $output_dir/$db_name/taxonomy/

echo "Adding reference to Kraken 2 library"
$build_prog --kmer-len X --minimizer-len Y --minimizer-spaces 0 --db $output_dir/$db_name --add-to-library $reference --no-masking

echo "Running build program for Kraken 2"
$build_prog --kmer-len X --minimizer-len Y --minimizer-spaces 0 --db $output_dir/$db_name --threads 6 --build --no-masking
