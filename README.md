-----

# Kraken 2 Optimized

An improved version of the Kraken 2 metagenomics classification tool developed with the goal of [increase accuracy and reduce memory consumption].

-----

**Note:** This project is a modified version of **Kraken 2 version 2.1.2**[cite: 5]. The main repository is located at [DerrickWood/kraken2](https://github.com/DerrickWood/kraken2).

## Key differences and improvements

This version includes the following changes compared to the original version 2.1.2:

  * **Improvement in algorithm X:** [modification]. This change resulted in **Y percent memory reduction**.
  * **Fixation in file Z:** [modification]. This **increased classification accuracy by X times**.
  * **Running on GTDB_v220:** [modification]. This **increased classification accuracy by X times**.
  * **[other improvements]**

## Prerequisites

To install and run Kraken 2, your system needs to meet the following requirements:

  * **Operating System**: A POSIX-compatible operating system like Linux is recommended. macOS is not explicitly supported by the developers. The default installation of GCC on macOS may not include OpenMP support, which limits Kraken 2 to single-threaded operation.
  * **Compiler**: A C++ compiler compliant with the C++11 standard is required (e.g., a recent version of g++).
  * **Core Utilities**: Many scripts rely on standard Linux utilities like `sed`, `find`, `wget` and `rsync`. Scripts are written in the Bash shell and Perl.
  * **Multithreading**: Multithreading is handled by OpenMP.
  * **Masking (Optional but enabled by default)**: By default, Kraken 2 attempts to use `dustmasker` or `segmasker` from the NCBI BLAST+ suite to mask low-complexity sequences. If you do not wish to install the BLAST+ suite, you can disable this feature by using the `--no-masking` flag during the build process.

## How to Install

The installation script compiles all the necessary C++ code and sets up the program directory.

1.  Navigate to the directory where you have the Kraken 2 source code.

2.  Run the installation script, replacing `$KRAKEN2_DIR` with the full path where you want Kraken 2's programs and scripts to be installed.

    ```bash
    ./install_kraken2.sh $KRAKEN2_DIR
    ```

3.  Installation is successful when you see the message: `Kraken 2 installation complete.`.

4.  After installation, you may want to copy the main scripts (`kraken2`, `kraken2-build`, `kraken2-inspect`) into a directory in your `PATH` for easier access (e.g., `$HOME/bin`).


## Building a Database

Before classifying sequences, you must build or download a Kraken 2 database. A database is a directory containing at least three primary files (`hash.k2d`, `opts.k2d`, `taxo.k2d`), but you only need to reference the directory name when running commands.

This guide covers three main methods for creating a database.

### 1\. Standard Database Build

This is the easiest method and creates a comprehensive database. The standard database includes taxonomic information from NCBI, along with complete genomes for bacteria, archaea, and viruses from RefSeq, plus the human genome and a collection of known vectors (UniVec\_Core).

To build the standard database, use the following command, replacing `$DBNAME` with your desired database directory path:

```bash
kraken2-build --standard --db $DBNAME
```

**Important Notes:**

  * **Disk Space**: The build process requires approximately 100 GB of disk space. This can be reduced after the build is complete using the `--clean` flag.
  * **Multithreading**: To speed up the time-consuming build process, you can use multiple processor cores with the `--threads` option:
    ```bash
    kraken2-build --standard --threads 24 --db $DBNAME
    ```

### 2\. Building the Strain-Exclusion Database (Kraken 2 Paper Method)

This section describes how to build the specialized "strain-exclusion" database that was used for benchmarking in the original Kraken 2 paper. This process involves downloading reference genomes, selecting specific strains to exclude (for fair testing), and then building a database from the remaining sequences.

All scripts required for this process are provided in the `db_build_scripts/` directory of this repository, adapted from the official [kraken2-experiment-code repository](https://github.com/DerrickWood/kraken2-experiment-code).

**Step 1: Prerequisites**

The helper scripts are written in Perl and C++. You must compile the C++ utility first.

```bash
# Navigate to the Utilities directory
cd db_build_scripts/Utilities/

# Compile the C++ program
make
# Return to the project root
cd ../../
```

**Step 2: Prepare and Run the Build Process**

The entire workflow, from downloading data to building the final database, is defined in the provided scripts. You will need to ensure the paths inside `db_build_scripts/BuildScripts/build_kraken2.bash` (specifically `working_root`) are configured for your system.

The main workflow is described in `db_build_scripts/README_DataGeneration.md`. It performs the following key actions:

1.  Downloads genome and taxonomy data from NCBI.
2.  Selects specific bacterial and viral strains to exclude for testing.
3.  Generates a final reference FASTA file (`strain_excluded.fna`) with these strains removed.
4.  Builds the final Kraken 2 database named `strex`.

To execute the entire process, you can run the commands from `README_DataGeneration.md` followed by the build script. For simplicity, it is recommended to combine them into a master script.

**Step 3: Locate the Final Database**

After all steps are completed successfully, the final database will be located in the directory specified within the `build_kraken2.bash` script (by default, `/data/Databases/Kraken2/strex`). You can then use this path for the `--db` option in your classification tasks.

### 3\. Building the Custom GTDB Database

This section provides instructions for building a custom Kraken 2 database using representative genomes from the **Genome Taxonomy Database (GTDB)**. This process maps the GTDB genomes to the standard **NCBI taxonomy**, leveraging the `ncbi_taxid` provided in the GTDB metadata.

All necessary custom scripts (`unzip_genome.sh`, `modify_headers.py`, etc.) and the master script (`build_gtdb_db.sh`) should be placed in a dedicated `gtdb_build_scripts/` directory within this repository.

#### Prerequisites

Ensure you have the following command-line tools installed: `wget`, `tar`, `gunzip`, `bash`, and `python3`.

#### Instructions

The entire workflow is automated by a single master script. Before running, please configure the necessary paths and parameters.

**Step 1: Configure Build Parameters**

Open the `gtdb_build_scripts/build_kraken2.bash` script and modify the following variables:

  * `working_root`: Set this to the absolute path of your project directory.
  * `--kmer-len X` and `--minimizer-len Y`: Replace `X` and `Y` with your desired integer values for the k-mer and minimizer lengths.

**Step 2: Run the Automated Build**

Once configured, execute the master script from the project's root directory. It will handle downloading data, decompressing files, rewriting FASTA headers, and building the final database.

```bash
# Make the scripts executable
chmod +x gtdb_build_scripts/*.sh

# Run the master build script
bash gtdb_build_scripts/build_gtdb_db.sh
```

#### The Automated Process

The master script performs the following sequence of operations:

1.  **Downloads Data**: Fetches the GTDB representative genomes (Release 220), GTDB metadata, and an NCBI-style taxonomy dump.
2.  **Extracts Files**: Decompresses all downloaded archives.
3.  **Decompresses Genomes**: Unzips the individual `.fna.gz` genome files.
4.  **Rewrites FASTA Headers**: The `modify_headers.py` script reads the metadata, maps each genome's accession to its corresponding NCBI TaxID, and rewrites the headers of the FASTA files to include the `kraken:taxid|...` tag.
5.  **Builds Database**: The `build_kraken2.bash` script uses the rewritten FASTA files and the NCBI taxonomy files to build the final Kraken 2 database with your specified parameters.

Upon successful completion, the database will be created in the directory defined in the `build_kraken2.bash` script. You can then use this path for the `--db` option in your classification tasks.
## Basic Usage


## Output Format

[cite\_start]Each classified sequence produces a single line of output with five tab-delimited fields[cite: 87]:

1.  [cite\_start]A single letter: 'C' for classified or 'U' for unclassified[cite: 88].
2.  [cite\_start]The sequence ID from the input file's header[cite: 89].
3.  [cite\_start]The taxonomy ID assigned to the sequence by Kraken 2 (0 if unclassified)[cite: 89].
4.  [cite\_start]The length of the sequence in base pairs[cite: 90]. [cite\_start]For paired-end reads, this will be the length of each mate separated by a pipe character (e.g., "98|94")[cite: 91].
5.  [cite\_start]A space-delimited list showing the Lowest Common Ancestor (LCA) mapping for each k-mer in the sequence[cite: 92].

## Citation

[cite\_start]If you use this work, please cite the original Kraken 2 paper as appropriate[cite: 20].

  * **Kraken 2:** Wood, D. E., Lu, J., & Langmead, B. (2019). Improved metagenomic analysis with Kraken 2. *Genome biology*, 20(1), 1-13.
  * **Original Kraken:** Wood, D. E., & Salzberg, S. L. (2014). Kraken: ultrafast metagenomic sequence classification using exact alignments. *Genome biology*, 15(3), 1-12.