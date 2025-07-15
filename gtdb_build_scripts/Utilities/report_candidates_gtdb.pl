#!/usr/bin/env perl

use strict;
use warnings;

my $taxonomy = "Taxonomy/";

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
  $rank_map{$node} = $rank;
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

my %merged_map;
open my $merged_fh, "<", "$taxonomy/merged.dmp"
  or die "can't open $taxonomy/merged.dmp: $!\n";
while (<$merged_fh>) {
  chomp;
  my @fields = split /\t\|\t?/;
  my ($node, $new_node) = @fields[0, 1];
  $merged_map{$node} = $new_node;
}
close $merged_fh;

my %seen_taxids;
while (<>) {
  chomp;
  # اینجا تنها بخش عددی بعد از اولین "|" استخراج می‌شود
  if (/^[^|]+\|(\d+)/) {
    my $taxid = $1;
    $seen_taxids{$taxid} = 1;
  } else {
    warn "نمیتوان taxid را از خط استخراج کرد: $_\n";
  }
}

my %genera_species_map;
my %species_strains_map;
my %strain_ancestor_map;

TAXID: for my $taxid (keys %seen_taxids) {
  my $node = $taxid;
  if (exists $merged_map{$node}) {
    $node = $merged_map{$node};
  }
  my $strain = $taxid;
  my $species;
  my $genus;
  STEP: while ($node != 1) {
    if (! exists $rank_map{$node}) {
      die "non existent rank for $node\n";
    }
    if ($rank_map{$node} eq "species") {
      $species = $node;
      if ($species != $strain) {
        $species_strains_map{$node} ||= {};
        $species_strains_map{$node}{$strain}++;
      }
    }
    elsif ($rank_map{$node} eq "genus") {
      $genus = $node;
      if ($node != $species && $node != $strain) {
        $genera_species_map{$node} ||= {};
        $genera_species_map{$node}{$species}++;
      }
      last STEP;
    }
    $node = $parent_map{$node};
  }
  $strain_ancestor_map{$strain} = [$species, $genus];
}

for my $strain (keys %strain_ancestor_map) {
  my ($species, $genus) = @{$strain_ancestor_map{$strain}};
  next if ! defined $species || ! defined $genus;
  if (keys %{$genera_species_map{$genus}} > 2) {
    if (keys %{$species_strains_map{$species}} > 2) {
      print "$strain\t$species\t$genus\t$name_map{$strain}\n";
    }
  }
}

