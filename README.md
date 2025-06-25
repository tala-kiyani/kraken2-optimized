-----

# Kraken 2 Optimized

An improved version of the Kraken 2 metagenomics classification tool developed with the goal of [increase accuracy and reduce memory consumption].

-----

[cite\_start]**Note:** This project is a modified version of **Kraken 2 version 2.1.2**[cite: 5]. The main repository is located at [DerrickWood/kraken2](https://github.com/DerrickWood/kraken2).

## Key differences and improvements

This version includes the following changes compared to the original version 2.1.2:

  * **Improvement in algorithm X:** [modification]. This change resulted in **Y percent memory reduction**.
  * **Fixation in file Z:** [modification]. This **increased classification accuracy by X times**.
  * **Running on GTDB VX:** [modification]. This **increased classification accuracy by X times**.
  * **[other improvements]**

## Prerequisites

To install and run Kraken 2, your system needs to meet the following requirements:

  * [cite\_start]**Operating System**: A POSIX-compatible operating system like Linux is recommended [cite: 35][cite\_start]. macOS is not explicitly supported by the developers[cite: 35]. [cite\_start]The default installation of GCC on macOS may not include OpenMP support, which limits Kraken 2 to single-threaded operation[cite: 36, 37].
  * [cite\_start]**Compiler**: A C++ compiler compliant with the C++11 standard is required (e.g., a recent version of g++)[cite: 30].
  * [cite\_start]**Core Utilities**: Many scripts rely on standard Linux utilities like `sed`, `find`, `wget` and `rsync`[cite: 28, 31]. [cite\_start]Scripts are written in the Bash shell and Perl[cite: 29].
  * [cite\_start]**Multithreading**: Multithreading is handled by OpenMP[cite: 31].
  * [cite\_start]**Masking (https://www.google.com/search?q=Optional but enabled by default)**: By default, Kraken 2 attempts to use `dustmasker` or `segmasker` from the NCBI BLAST+ suite to mask low-complexity sequences[cite: 34, 155]. [cite\_start]If you do not wish to install the BLAST+ suite, you can disable this feature by using the `--no-masking` flag during the build process[cite: 157].

## How to Install

[cite\_start]The installation script compiles all the necessary C++ code and sets up the program directory[cite: 53].

1.  Navigate to the directory where you have the Kraken 2 source code.

2.  [cite\_start]Run the installation script, replacing `$KRAKEN2_DIR` with the full path where you want Kraken 2's programs and scripts to be installed[cite: 52].

    ```bash
    ./install_kraken2.sh $KRAKEN2_DIR
    ```

3.  [cite\_start]Installation is successful when you see the message: `Kraken 2 installation complete.`[cite: 53].

4.  [cite\_start](https://www.google.com/search?q=Optional) After installation, you may want to copy the main scripts (`kraken2`, `kraken2-build`, `kraken2-inspect`) into a directory in your `PATH` for easier access (e.g., `$HOME/bin`)[cite: 53].

## Building a Database


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