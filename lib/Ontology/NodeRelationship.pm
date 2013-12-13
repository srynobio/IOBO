#-------------------------------------------------------------------------------
#------                     Ontology::NodeRelationship                 ---------
#-------------------------------------------------------------------------------
package Ontology::NodeRelationship;
use strict;
use warnings;

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

	my $self ={};
	bless($self, $class);

	foreach my $k (keys %{$hash}){
		my $v = $hash->{$k};
		
		if    ($k eq 'object_id'){
			$self->oF($v);
		}
		 elsif ($k eq 'subject_id'){
			$self->sF($v);
		}	
                elsif ($k eq 'type'){
                        $self->logus($v);
                }
		else {
			$self->{$k} = $v;
		}
	}

	return $self;
}
#-------------------------------------------------------------------------------
sub oF
 {
	my $self = shift;
	my $id   = shift;

	if (defined($id)){
		$self->{oF} = $id;
	}
	else {
		return $self->{oF}
	}
}
#-------------------------------------------------------------------------------
sub sF
 {
        my $self = shift;
        my $id   = shift;

        if (defined($id)){
                $self->{sF} = $id;
        }
        else {
                return $self->{sF}
        }

}
#-------------------------------------------------------------------------------
sub logus
 {
	my $self = shift;
	my $type = shift;

        if (defined($type)){
                $self->{logus} = $type;
        }
        else {
                return $self->{logus}
        }

}
#-------------------------------------------------------------------------------
#------------------------------- PRIVATE ---------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#------------------------------- FUNCTIONS -------------------------------------
#-------------------------------------------------------------------------------
sub AUTOLOAD
 {
        my ($self, $arg) = @_;

        my $caller = caller();
        use vars qw($AUTOLOAD);
        my ($call) = $AUTOLOAD =~/.*\:\:(\w+)$/;
        $call =~/DESTROY/ && return;

        if($ENV{VAAST_CHATTER}) {
	    print STDERR "Annotation::FeatureRelationship::AutoLoader called for: ",
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

