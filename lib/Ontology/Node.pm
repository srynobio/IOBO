#-------------------------------------------------------------------------------
#------                          Ontology::Node                        ---------
#-------------------------------------------------------------------------------
package Ontology::Node;

use strict;
use warnings;

use Ontology::NodeRelationship;

BEGIN {
  use vars qw( $VERSION @ISA );

  $VERSION     = 0.01;
  @ISA         = qw ( );	# XXXX superclasses go here.
}
#-------------------------------------------------------------------------------
sub new
 {
	my $class = shift;

	my $hash  = shift;

	my $self = _load_feature($hash);


	bless($self, $class);

	$self->_add_id('id'); # specifies binding, could change!

	return $self;
}
#-------------------------------------------------------------------------------
sub synonyms
 {
	my $self = shift;

	return $self->{synonyms} || [];
}
#-------------------------------------------------------------------------------
sub name
 {
        my $self = shift;

        return $self->{name};

}
#-------------------------------------------------------------------------------
sub type
 {
        my $self = shift;

        return $self->{type};
}
#-------------------------------------------------------------------------------
sub id
 {
	my $self = shift;

	return $self->{id};
}
#-------------------------------------------------------------------------------
sub property
 {
	my $self = shift;
	my $pKey = shift;
	my $pVal = shift;

	if (defined($pKey)){
		$self->{properties}->{$pKey} = $pVal;
	}
	else {
		return $self->{properties}->{$pKey};
	}
}
#-------------------------------------------------------------------------------
sub relationships
 {
        my $self = shift;

        return @{$self->{relationships}|| []};
}
#-------------------------------------------------------------------------------
#------------------------------- PRIVATE ---------------------------------------
#-------------------------------------------------------------------------------
sub _add_id
 {
	my $self    = shift;
	my $binding = shift;

	$self->{id} = $self->{$binding};
}
#-------------------------------------------------------------------------------
sub _load_feature
 {
	my $hash = shift;

	my %feature;
	foreach my $k (keys %{$hash}){
		if ($k eq 'relationships'){
			foreach my $r (@{$hash->{$k}}){
				push(@{$feature{$k}},
					new Ontology::NodeRelationship($r),
				);
			}
		}
		else {
			$feature{$k} = $hash->{$k};	
		}
	}

	return \%feature;
}
#-------------------------------------------------------------------------------
sub _add_relationship
 {
	my $self = shift;
	my $r    = shift;

	push(@{$self->{relationships}}, $r);
}
#-------------------------------------------------------------------------------
#------------------------------- FUNCTIONS -------------------------------------
#-------------------------------------------------------------------------------
sub revCompSeq
 {		# XXXX Why is this here?
	my $seq = shift;

	$seq =~ tr/ACGTYRKMB/TGCARYMKV/;
	
	my @array = split('', $seq); # XXXX OUCH, better way?

	my @rev = reverse(@array);

	return join('', @rev);
}
#-------------------------------------------------------------------------------
sub AUTOLOAD
 {
        my ($self, $arg) = @_;

        my $caller = caller();
        use vars qw($AUTOLOAD);
        my ($call) = $AUTOLOAD =~/.*\:\:(\w+)$/;
        $call =~/DESTROY/ && return;

        if($ENV{VAAST_CHATTER}) {
	    print STDERR "Annotation::Feature::AutoLoader called for: ",
	    "\$self->$call","()\n";
	    print STDERR "call to AutoLoader issued from: ", $caller, "\n";
	}

        if (defined($arg)){
                $self->{$call} = $arg;
        }
        else {
                return $self->{$call};
        }
}
#-------------------------------------------------------------------------------
1; #this line is important and will help the module return a true value
__END__

