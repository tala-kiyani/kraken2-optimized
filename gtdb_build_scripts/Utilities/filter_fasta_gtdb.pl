#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw/:seek/;

my $taxonomy   = "Taxonomy/";
my $fasta_file = shift;

chomp(my @excluded_taxids_list = <>);
my %excluded_taxids = map { $_ => 1 } @excluded_taxids_list;

my %parent_map;
my %rank_map;
my %name_map;

open my $nodes_fh, "<", "$taxonomy/nodes.dmp"
  or die "can't open $taxonomy/nodes.dmp: $!\n";
while (<$nodes_fh>) {
    chomp;
    my @fields = split /\t\|\t/;
    my ($node, $parent, $rank) = @fields[0..2];
    $parent_map{$node} = $parent;
    $rank_map{$node}   = $rank;
}
close $nodes_fh;

open my $names_fh, "<", "$taxonomy/names.dmp"
  or die "can't open $taxonomy/names.dmp: $!\n";
while (<$names_fh>) {
    chomp;
    my @fields = split /\t\|\t?/;
    my ($node, $name, $type) = @fields[0, 1, 3];
    $name_map{$node} = $name if $type eq "scientific name";
}
close $names_fh;

open my $fasta_fh, "<", $fasta_file
  or die "can't open fasta file $fasta_file: $!\n";
my $printing_sequence = 0;
while (<$fasta_fh>) {
    if (/^>/) { 
        $printing_sequence = 1;
        if (/kraken:taxid\|(\d+)/) {
            my $taxid = $1;
            STEP: while (defined($taxid) && $taxid != 1) {
                if (exists $excluded_taxids{$taxid}) {
                    $printing_sequence = 0;
                    last STEP;
                }
                $taxid = $parent_map{$taxid};
            }
        }
    }
    print if $printing_sequence;
}
close $fasta_fh;
