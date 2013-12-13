#-------------------------------------------------------------------------------
#------                   Ontology::Parser::OBO                        ---------
#-------------------------------------------------------------------------------
package Ontology::Parser::OBO;

use strict;
use warnings;

use Ontology::Node;
use Ontology::Trace;
use Ontology::NodeRelationship;
use FileHandle;
use PostData;

BEGIN {
  use vars qw( $VERSION @ISA );

  $VERSION     = 0.01;
  @ISA = qw(	   );
}
#-----------------------------------------------------------------------------
sub new {
  my ($class, $file) = @_;

  my $self = bless ({}, $class);

  if ($file) {
      $self->file($file);
  }

  return ($self);
}
#-----------------------------------------------------------------------------
sub parse {
	my ($self, $file) = @_;

	my $fh = new FileHandle();
	
	$file = $self->file() unless (defined($file));

	$fh->open($file);

	my %nodes;
	my $pushback = undef;

	while (my $stanza = _get_term($fh, \$pushback)) {

		my @lines = split(/\n/, $stanza);

		next if $lines[0] =~ /format-version/;

		next unless @lines;

		my $term = _load_lines(\@lines);

		next unless defined($term->{id}->[0]);

		my $node =_term_to_node($term);

		my $isa_relationships = _term_to_isa_feature_relationships($term);
	
		push(@{$node->{relationships}}, @{$isa_relationships}) if @{$isa_relationships};

		my $part_of_relationships = _term_to_part_of_feature_relationships($term);

		push(@{$node->{relationships}}, @{$part_of_relationships}) if @{$part_of_relationships};


		my $f = new Ontology::Node($node);
		$nodes{$f->id} = $f;
	}
	$fh->close;

	_reverse_relationships(\%nodes);

	return \%nodes;
}
#-----------------------------------------------------------------------------
sub _get_term {
  my($fh, $pushback_ref) = @_;
  my($term) = undef;

  # skip over [Typedef] stanzas.
  if ($$pushback_ref && $$pushback_ref =~ m|\[Typedef\]|) {
    while(<$fh>) {
      last if (/\[Term\]/);
    }
  }

  # protect against running into the bottom of the file....
  return($term) if eof($fh);

  while (<$fh>) {
    $term .= $_;
    if ((/\[Term\]/) or (/\[Typedef\]/)) {
      $$pushback_ref = $_;
      return($term);
    }
  }

  return($term);
}
#-----------------------------------------------------------------------------
sub _load_lines {
	my $lines = shift;

	my %data;
	foreach my $line (@{$lines}){
		next unless $line =~ /\S+/;
		next if     $line =~ /\[Term\]/;
		next if     $line =~ /\[Typedef\]/;

		$line =~ s|[^!]!.*$||;
		chomp $line;
		my ($key, $value) = $line =~ /^(\S+)\:\s+(.*)/;

		# XXXX die???
		die unless defined($key) && defined($value);

		$value =~ s/\"//g  if $key eq 'synonym';
		$value =~ s/\[//g  if $key eq 'synonym';
		$value =~ s/\]//g  if $key eq 'synonym';
		$value =~ s/\s+$// if $key eq 'synonym';

		push(@{$data{$key}}, $value);
	}

	return \%data;
}
#-----------------------------------------------------------------------------
sub _term_to_node {
	my $term = shift;


	my %node;

	$node{id}       = $term->{id}->[0];
	$node{name}     = $term->{name}->[0];
        $node{synonyms} = $term->{synonym};
	$node{def}      = $term->{def}->[0];

	return \%node;
}
#-----------------------------------------------------------------------------
sub _term_to_isa_feature_relationships {
        my $term = shift;

	my $s_id = $term->{id}->[0];

	my %hash;
	my @f_rs;
	foreach my $o_id (@{$term->{is_a}}){

		$hash{subject_id} = $s_id;
		$hash{object_id}  = $o_id;
		$hash{type}       = 'isa';
	
		my $f = new Ontology::NodeRelationship(\%hash);

		push(@f_rs, $f);
	}

	return \@f_rs;
}
#-----------------------------------------------------------------------------
sub _term_to_part_of_feature_relationships {
        my $term = shift;

        my $s_id = $term->{id}->[0];

        my %hash;
        my @f_rs;
        foreach my $str (@{$term->{relationship}}){

		my @data = split(/\s+/, $str);

                $hash{subject_id} = $s_id;
                $hash{object_id}  = $data[1];
                $hash{type}       = $data[0];

                my $f = new Ontology::NodeRelationship(\%hash);

                push(@f_rs, $f);
        }

        return \@f_rs;
}
#-----------------------------------------------------------------------------
sub _reverse_relationships {
	my $nodes = shift;

	my %r_hash;
        foreach my $id (keys %{$nodes}){
		my $node = $nodes->{$id};
		foreach my $r ($node->relationships){

			push(@{$r_hash{$r->oF}}, $r);

		}
	}


        foreach my $id (keys %{$nodes}){
		my $node = $nodes->{$id};
		foreach my $r (@{$r_hash{$id}}){
			$node->_add_relationship($r);
		}
	}

}
#-----------------------------------------------------------------------------
sub file
 {
        my $self  = shift;

        if (@_){
                $self->{file} = shift;
        }

	return $self->{file};
}
#-----------------------------------------------------------------------------
sub AUTOLOAD
 {
        my $self = shift;

        my $caller = caller();
        use vars qw($AUTOLOAD);
        my ($call) = $AUTOLOAD =~/.*\:\:(\w+)$/;
        $call =~/DESTROY/ && return;

        if($ENV{VAAST_CHATTER}) {
	    print STDERR "Ontology::Parser::OBO::AutoLoader called for: ",
	    "\$self->$call","()\n";
	    print STDERR "call to AutoLoader issued from: ", $caller, "\n";
	}

        if (@_){
                $self->{$call} = shift;
        }

	return $self->{$call};
}
#-----------------------------------------------------------------------------
1; #this line is important and will help the module return a true value
__END__
