TSV_FILE="GTDB/gtdb_genomes_reps_r220/genome_paths.tsv"

BASE_DIR="GTDB/gtdb_genomes_reps_r220/"

DEST_DIR="GTDB/modified_gtdb_genomes"
while read -r filename directory; do
    FULL_PATH="$BASE_DIR$directory$filename"

    if [[ -f "$FULL_PATH" ]]; then
        echo "Extracting: $FULL_PATH"

         gunzip -c "$FULL_PATH" > "$DEST_DIR/${filename%.gz}"

        echo "File extracted to: $DEST_DIR/${filename%.gz}"
    else
        echo "File not found: $FULL_PATH"
    fi
done < "$TSV_FILE"

echo "All files have been extracted and moved to $DEST_DIR"
