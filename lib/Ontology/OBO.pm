#-------------------------------------------------------------------------------
#------                              Ontology::OBO                     ---------
#-------------------------------------------------------------------------------
package Ontology::OBO;

use strict;
use warnings;

use Ontology::Ontology;
use Ontology::Parser::OBO;

BEGIN {
  use vars qw( $VERSION @ISA );

  $VERSION     = 0.01;
  @ISA         = qw (
		     Ontology::Ontology
		    );
}
#-------------------------------------------------------------------------------
sub new
 {
	my $class = shift;
	my $source  = shift;

	my $self = {};

	bless($self, $class);

	if(defined($source)){
		$self->source($source);
	}
	elsif (defined($ENV{'VAAST_OBO_SOURCE'})){
		$self->source($ENV{'VAAST_OBO_SOURCE'});
	}
	else {
		print "\n#######################################################\n";
		print "Error in Ontology::SO.pm.\n";
		print "You must either set the VAAST_OBO_SOURCE environment varible\n";
		print "or provide a so.obo file.\n";
		print "#######################################################\n\n";
		die;
	}

	# might want to instantiate a variety of parsers, depending on
	# the source....

	$self->parser(new Ontology::Parser::OBO($self->source));
	$self->nodes($self->parser->parse());
	$self->_index_on_node_names();
	return $self;
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
	    print STDERR "Ontology::OBO::AutoLoader called for: ",
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

