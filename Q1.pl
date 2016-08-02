#!/opt/perl/bin/perl
use strict;
use warnings;

use Bio::Perl;
use Bio::Seq;

print "Input File Name:";
chomp (my $file = <STDIN>);

my @bio_seq_objects = read_all_sequences( $file , 'fasta' );

my %seqInfo;
foreach my $seq( @bio_seq_objects ) {
	my $key = (split(/\|/, $seq->display_id))[0];
	my $val = $seq->seq;
	$seqInfo{$key} = $val;
}

if (keys %seqInfo) {
	print "Sequences contained within FASTA file: \n";
	print "\t$_\n" for (keys %seqInfo); 
	print "\nSelect Sequence You'd Like to BLAST:\n"; 
	my @userinput = split(/\s+/, <>); 
		
	my $i = 1;
	foreach my $arg (@userinput){
		if ($arg = $seqInfo{$arg}) {
			my %rhash = reverse %seqInfo;
			my $key = $rhash{$arg};

			my $seq_obj = Bio::Seq->new(-seq => $arg, -display_id => $key);	
			if ($seq_obj->alphabet() eq 'dna'){	

				my $prot_obj = $seq_obj->translate(); 
				my $blast = blast_sequence( $prot_obj );
				write_blast( ">".$key."_BLAST" , $blast );
				print "File: ".$key."_BLAST Created\n";
			}
			if ($seq_obj->alphabet() eq 'protein'){
				my $blast = blast_sequence( $seq_obj );
				write_blast( ">".$key."_BLAST" , $blast );
				print "File: ".$key."_BLAST Created\n";
			}
		}else{print "ERROR! INPUT NOT FOUND! in $file!\n"; $i++;}
	}
}else{print "ERROR! INPUT NOT FOUND! in $file!\n";}
