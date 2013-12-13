#-------------------------------------------------------------------------------
#------                          Ontology::Trace                       ---------
#-------------------------------------------------------------------------------
package Ontology::Trace;

use strict;
use warnings;

use Ontology::Node;

BEGIN {
  use vars qw( $VERSION @ISA );

  $VERSION     = 0.01;
  @ISA         = qw ( );	# XXXX superclasses go here.
}
#-------------------------------------------------------------------------------
sub new
 {
	my $class    = shift;

	my $self = {};

	bless($self, $class);

	return $self;
}
#-------------------------------------------------------------------------------
sub depth
 {
	my $self = shift;

	return $#{$self->{features}} + 1;
}
#-------------------------------------------------------------------------------
sub terminii
 {
	my $self = shift;
	
	return $self->features($self->depth -1);
}
#-------------------------------------------------------------------------------
sub show
 {
	my $self = shift;

	my $depth = $self->depth();
	print "Ontology::Trace depth:$depth\n";
	for (my $d = 0; $d < $depth; $d++){
		print "Ontology::Trace\n";
		print "   features level:$d\n";
		foreach my $f ($self->features($d)){
			print "   "." "x $d.$f->id()." ".$f->name."\n";
		}
	}
}
#-------------------------------------------------------------------------------
sub features
 {
	my $self  = shift;
	my $level = shift;

	if (defined($level)){
		return @{$self->{features}->[$level]|| []};
		
	}
	else {
		return @{$self->{features}|| []};
	}
}
#-------------------------------------------------------------------------------
sub add_feature
 {
        my $self = shift;
        my $f    = shift;
        my $l    = shift;

        push(@{$self->{features}->[$l]}, $f);
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
	    print STDERR "Ontology::Trace::AutotoLoader called for: ",
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

