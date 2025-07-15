# Strain exclusion data generation code

This code was run in ; some of the underlying data has changed 
since then, but similar results should still be obtainable.

## Code to download/extract GTDB and taxonomy information
    mkdir -p GTDB/modified_gtdb_genomes GTDB/modified_gtdb_genomes_2 Taxonomy tsv

    wget -O gtdb_genomes_reps_r220.tgz \
      https://data.ace.uq.edu.au/public/gtdb/data/releases/release220/220.0/genomic_files_reps/gtdb_genomes_reps_r220.tar.gz
    wget -O taxdump.tar.gz \
      https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/taxdump_20240914.tar.gz
    wget -P tsv/ 
      https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/ar53_metadata.tsv.gz
    wget -P tsv/ https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/bac120_metadata.tsv.gz

    gunzip -c tsv/ar53_metadata.tsv.gz > tsv/ar53_metadata_r220.tsv
    gunzip -c tsv/bac120_metadata.tsv.gz > tsv/bac120_metadata_r220.tsv
    
    tar -C GTDB -xf gtdb_genomes_reps_r220.tgz
    tar -C Taxonomy -xf taxdump.tar.gz

    # Decompressing Individual Genomes,
    # This script reads genome_paths.tsv and unzips .fna.gz files
    bash unzip_genome.sh
  
## This script reads metadata, finds NCBI TaxIDs, and rewrites FASTA headers.
    # Modifying FASTA Headers with NCBI TaxIDs
    # Add taxid info to that list
    python3 modify_headers.py

## Code to select the strains for exclusion
    # Look at all genome files, only select those with "complete genome",
    # exclude plasmids and 2nd/3rd chromosomes; this gives a list containing one
    # entry per genome.  This code does not delete any sequences, and all sequences
    # are still available for reference/simulation data later.
    find GTDB/modified_gtdb_genomes_2/ -name '*.fna' | xargs cat | grep '^>' | grep "complete genome" \
      | grep -v plasmid | grep -v 'chromosome \(2\|3\|II\)' > gtdb_taxids.list


    # Given taxid list, report taxids that are good candidates (2 sister species &
    # 2 sister subspecies taxa present).  Sort list by genus, then species, then strain
    # taxids.  Select one entry per genus at random.  Command prints out a blank line at
    # top, so discard, then shuffle entries.  Select first 40 entries.
    report_candidates_gtdb.pl gtdb_taxids.list | sort -k3,3n -k2,2n -k1,1n \
      | perl -anle 'BEGIN { srand(42) } if ($F[2] == $l) { push @x, $_ } else { print $x[rand @x]; @x = ($_) } $l = $F[2]; END { print $x[rand @x] }' \
      | tail -n +2 | perl -MList::Util=shuffle -le 'srand 42; print shuffle(<>)' \
      | head -40 > selected_gtdb.list
    
## Gather all nucleotide data, and add taxonomy information
    # All downloaded nucleotide data is gathered into original_data.fna
    find GTDB/modified_gtdb_genomes_2  -name '*.fna' | xargs cat > original_data.fna


## Perform strain exclusion using the selection lists
    # filter_fasta.pl will remove all sequences from the FASTA input
    # that are associated with taxa provided on STDIN
    cut -f1 selected_gtdb.list | filter_fasta_gtdb.pl original_data.fna \
      > strain_excluded.fna
    
## Create references for selected projects
    mkdir -p Selected
    # select_fasta.pl will write into the Selected/ directory a
    # file for each taxid provided via STDIN, containing all of the
    # FASTA input sequences that are associated with that taxid
    cut -f1 selected_gtdb.list | ./select_fasta.pl original_data.fna


## Simulate read data from selected genomes
    for file in Selected/*.fa; do
      mason_simulator -ir $file --seed 42 -n 500000 --num-threads 4 \
        -o Selected/$(basename $file .fa)_1.fq \
        -or Selected/$(basename $file .fa)_2.fq \
        --read-name-prefix taxid_$(basename $file .fa).
    done

      # Grab the first 1000 reads for accuracy study
      head -qn 4000 Selected/*_1.fq > gtdb_1.fq
      head -qn 4000 Selected/*_2.fq > gtdb_2.fq
    done

