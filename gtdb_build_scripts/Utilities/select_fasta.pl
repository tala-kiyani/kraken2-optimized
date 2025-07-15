#!/usr/bin/env perl

use strict;
use warnings;
use Fcntl qw/:seek/;

my $taxonomy = "/home/sara.keshavarz99.sharif/kraken2/kraken2_gtdb/ncbi_taxdump/";
my $fasta_file = shift;

# خواندن ورودی: فقط خطوطی که شامل کاراکتر غیر فاصله‌ای هستند گرفته شود
chomp(my @included_taxids_list = grep { /\S/ } <>);
my %included_taxids = map {
    my @fields = split;
    defined $fields[0] ? ($fields[0] => 1) : ()
} @included_taxids_list;

my %parent_map;
my %rank_map;
my %name_map;

# خواندن فایل nodes.dmp
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

# خواندن فایل names.dmp
open my $names_fh, "<", "$taxonomy/names.dmp"
  or die "can't open $taxonomy/names.dmp: $!\n";
while (<$names_fh>) {
  chomp;
  my @fields = split /\t\|\t?/;
  my ($node, $name, $type) = @fields[0,1,3];
  $name_map{$node} = $name if $type eq "scientific name";
}
close $names_fh;

# پردازش فایل FASTA
open my $fasta_fh, "<", $fasta_file
  or die "can't open fasta file $fasta_file: $!\n";

my $printing_sequence = 0;
my $out_fh;  # فایل خروجی جاری

while (<$fasta_fh>) {
  if (/^>/) { 
    $printing_sequence = 0;
    # بستن فایل خروجی قبلی (در صورت باز بودن)
    if (defined $out_fh) {
      close $out_fh;
      undef $out_fh;
    }
    if (/kraken:taxid\|(\d+)/) {
      my $taxid = $1;
      # پیمایش تا رسیدن به ریشه (taxid == 1)
      while (defined($taxid) && $taxid != 1) {
        if (exists $included_taxids{$taxid}) {
          $printing_sequence = 1;
          open $out_fh, ">>", "Selected/$taxid.fa"
            or die "can't open Selected/$taxid.fa: $!\n";
          last;
        }
        $taxid = $parent_map{$taxid};
      }
    } else {
      $printing_sequence = 0;
    }
  }
  print $out_fh $_ if $printing_sequence && defined $out_fh;
}

close $fasta_fh;
close $out_fh if defined $out_fh;
