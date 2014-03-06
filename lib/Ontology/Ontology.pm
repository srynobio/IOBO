#-------------------------------------------------------------------------------
#------                       Ontology::Ontology                       ---------
#-------------------------------------------------------------------------------
package Ontology::Ontology;

use strict;
use warnings;

use Ontology::Node;
use Ontology::Trace;
use Ontology::NodeRelationship;
use PostData;

BEGIN {
    use vars qw( $VERSION @ISA );

    $VERSION = 0.01;
    @ISA     = qw ( );    # XXXX superclasses go here.
}

#-------------------------------------------------------------------------------
sub new {

    die "Should be implemented in subclass.";
}

#-------------------------------------------------------------------------------
sub nodes {
    my $self = shift;

    if (@_) {
        $self->{nodes} = shift;
    }

    return $self->{nodes};
}

#-------------------------------------------------------------------------------
sub find_depth {
    my $self   = shift;
    my $a      = shift;
    my $a_node = $self->node_by_name($a);
    return undef unless ( defined $a_node );
    my $depth = $self->trace( $a_node, 'parents' )->depth;
    return $depth;
}

#-------------------------------------------------------------------------------
sub find_depth_to_leaf {
    my $self   = shift;
    my $a      = shift;
    my $a_node = $self->node_by_name($a);
    return undef unless ( defined $a_node );
    my $depth = $self->trace( $a_node, 'children' )->depth;

    #my @terminii = $self->trace($a_node, 'children')->terminii;
    return $depth;
}

#-------------------------------------------------------------------------------
sub name_id_index {
    my $self  = shift;
    my $names = shift;

    if ( defined($names) ) {
        $self->{name_id_index} = $names;
    }
    else {
        return $self->{name_id_index};
    }

}

#-------------------------------------------------------------------------------
sub file {
    my $self = shift;
    my $file = shift;

    if ( defined($file) ) {
        $self->{file} = $file;
    }
    else {
        return $self->{file};
    }

}

#-------------------------------------------------------------------------------
sub all_b_have_a {
    my $self = shift;
    my $b    = shift;
    my $a    = shift;

    my $a_node = $self->node_by_name($a);
    my $b_node = $self->node_by_name($b);

    foreach my $part ( $self->trace( $b_node, 'parts' )->features(0) ) {
        return 1 if $part->name eq $a_node->name();
    }

    my $p_trace_obj = $self->trace( $b_node, 'parents' );

    foreach my $parents ( $p_trace_obj->features ) {
        foreach my $parent ( @{$parents} ) {
            foreach my $part ( $self->trace( $parent, 'parts' )->features(0) ) {
                return 2 if $part->name eq $a_node->name();
            }
        }
    }
    return 0;

}

#-------------------------------------------------------------------------------
sub some_b_have_a {
    my $self = shift;
    my $b    = shift;
    my $a    = shift;

    my $a_node = $self->node_by_name($a);
    my $b_node = $self->node_by_name($b);

    return 1 if $self->all_b_have_a( $b, $a );

    foreach my $part ( $self->trace( $b_node, 'parts' )->features(0) ) {
        return 2 if $self->a_is_hyponym_of_b( $a_node->name(), $part->name );
    }

    my $c_trace_obj = $self->trace( $b_node, 'children' );

    foreach my $children ( $c_trace_obj->features ) {
        foreach my $child ( @{$children} ) {
            foreach my $part ( $self->trace( $child, 'parts' )->features(0) ) {
                return 3 if $part->name eq $a_node->name();
                return 4
                  if $self->a_is_hyponym_of_b( $a_node->name(), $part->name );
            }
        }
    }

    return 0;
}

#-------------------------------------------------------------------------------
sub some_b_could_have_a {
    my $self = shift;
    my $b    = shift;
    my $a    = shift;

    my $a_node = $self->node_by_name($a);
    my $b_node = $self->node_by_name($b);

    return 1 if $self->some_b_have_a( $b, $a );

    my $p_trace_obj = $self->trace( $b_node, 'parents' );

    foreach my $parent ( $p_trace_obj->features ) {
        foreach my $parent ( @{$parent} ) {
            foreach my $part ( $self->trace( $parent, 'parts' )->features(0) ) {
                return 3 if $part->name eq $a_node->name();
                return 4
                  if $self->a_is_hyponym_of_b( $a_node->name(), $part->name );
            }
        }
    }

    return 0;
}

#-------------------------------------------------------------------------------
sub a_is_an_optional_part_of_b {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    my $a_node = $self->node_by_name($a);
    my $b_node = $self->node_by_name($b);

    foreach my $part ( $self->trace( $b_node, 'parts' )->features(0) ) {
        return 0 if $part->name eq $a_node->name();
        return 1 if $self->a_is_hyponym_of_b( $a_node->name(), $part->name );
    }
    return 0;

}

#-------------------------------------------------------------------------------
sub a_is_an_essential_part_of_some_b {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    my $a_node = $self->node_by_name($a);
    my $b_node = $self->node_by_name($b);

    return 0 if $self->a_is_an_essential_part_of_b( $a, $b );

    return 0 if $self->a_is_an_optional_part_of_b( $a, $b );

    my $p_trace_obj = $self->trace( $b_node, 'parents' );

    foreach my $parents ( $p_trace_obj->features ) {
        foreach my $parent ( @{$parents} ) {
            foreach my $part ( $self->trace( $parent, 'parts' )->features(0) ) {
                return 1 if $part->name eq $a_node->name();
            }
        }
    }
    return 0;

}

#-------------------------------------------------------------------------------
sub a_is_meronym_of_b {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    my $a_f = $self->node_by_name($a);

    my $b_f = $self->node_by_name($b);

    #print "b_f:".$b_f->name."\n";
    foreach my $part ( $self->trace( $b_f, 'parts' )->features(0) ) {

        #print "  part:".$part->name."\n";
        return 1 if $part->name eq $a_f->name();
        return 2 if $self->a_is_hyponym_of_b( $a_f->name, $part->name );
    }

    my $p_trace_obj = $self->trace( $b_f, 'parents' );

    foreach my $parents ( $p_trace_obj->features ) {
        foreach my $parent ( @{$parents} ) {

            #print "parent:".$parent->name."\n";
            foreach my $part ( $self->trace( $parent, 'parts' )->features(0) ) {

                #print "  part:".$part->name."\n";
                return 2
                  if $part->name eq $a_f->name()
                  || $self->a_is_hyponym_of_b( $a_f->name(), $part->name );
            }
        }
    }

    my $c_trace_obj = $self->trace( $b_f, 'children' );

    foreach my $children ( $c_trace_obj->features ) {
        foreach my $child ( @{$children} ) {

            #print "child:".$child->name."\n";
            foreach my $part ( $self->trace( $child, 'parts' )->features(0) ) {

                #print "  part:".$part->name."\n";
                return 3
                  if $part->name eq $a_f->name()
                  || $self->a_is_hyponym_of_b( $a_f->name, $part->name );
            }
        }
    }

    return 0;
}

#-------------------------------------------------------------------------------
sub a_is_hypomeronym_of_b {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    my $a_f = $self->node_by_name($a);

    my $b_f = $self->node_by_name($b);

    return 0 unless ( $a_f and $b_f );    # handle nodes not in Ontology.

    return 1 if $b_f->name() eq $a_f->name();
    my $p_trace_obj = $self->trace( $a_f, 'wholes' );

    #print "a_f:".$a_f->name."\n";
    foreach my $hypermeronyms ( $p_trace_obj->features ) {
        foreach my $hypermeronym ( @{$hypermeronyms} ) {

            #print "hypermeronym:".$hypermeronym->name."\n";
            return 2 if $hypermeronym->name eq $b_f->name();
        }
    }

    return 0;
}

#-------------------------------------------------------------------------------
sub a_is_hyponym_of_b {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    my $a_f = $self->node_by_name($a);

    my $b_f = $self->node_by_name($b);

    return 0 unless ( $a_f and $b_f );    # handle nodes not in Ontology.

    return 1 if $b_f->name() eq $a_f->name();
    my $p_trace_obj = $self->trace( $a_f, 'parents' );

    #print "a_f:".$a_f->name."\n";
    foreach my $parents ( $p_trace_obj->features ) {
        foreach my $parent ( @{$parents} ) {

            #print "parent:".$parent->name."\n";
            return 2 if $parent->name eq $b_f->name();
        }
    }

    return 0;
}

#-------------------------------------------------------------------------------
sub hypernym {
    my $self = shift;
    my $name = shift;

    my $n = $self->node_by_name($name);

    my @hypernyms = $self->trace( $n, 'parents' )->features(0);

    my @names;
    foreach my $hypernym (@hypernyms) {
        push( @names, $hypernym->name() );
    }

    return join( ' & ', @names ) || 'ROOT';

}

#-------------------------------------------------------------------------------
sub hyponym {
    my $self = shift;
    my $name = shift;

    my $n = $self->node_by_name($name);

    my @hyponyms = $self->trace( $n, 'children' )->features(0);

    my @names;
    foreach my $hyponym (@hyponyms) {
        push( @names, $hyponym->name() );
    }

    return join( ' & ', @names ) || 'terminal node';
}

#-------------------------------------------------------------------------------
sub hypermeronym {
    my $self = shift;
    my $name = shift;

    my $n = $self->node_by_name($name);

    my @hypermeronyms = $self->trace( $n, 'wholes' )->features(0);

    my @names;
    foreach my $hypermeronym (@hypermeronyms) {
        push( @names, $hypermeronym->name() );
    }

    return join( ' & ', @names ) || 'ROOT';

}

#-------------------------------------------------------------------------------
sub hypomeronym {
    my $self = shift;
    my $name = shift;

    my $n = $self->node_by_name($name);

    my @hypomeronyms = $self->trace( $n, 'parts' )->features(0);

    my @names;
    foreach my $hypomeronym (@hypomeronyms) {
        push( @names, $hypomeronym->name() );
    }

    return join( ' & ', @names ) || 'terminal node';
}

#-------------------------------------------------------------------------------
sub node_by_name {
    my $self = shift;
    my $name = shift;

    my $ids = $self->name_id_index->{$name};

    return $self->node_by_id( $ids->[0] );

}

#-------------------------------------------------------------------------------
sub node_by_id {
    my $self = shift;
    my $id   = shift;

    return $self->nodes->{$id};
}

#-------------------------------------------------------------------------------
sub relationships {
    my $self = shift;

    return @{ $self->{relationships} || [] };
}

#-------------------------------------------------------------------------------
sub trace {
    my $self  = shift;
    my $f     = shift;
    my $type  = shift;
    my $i     = shift;
    my $trace = shift;

    if ( defined($i) ) {
        $i++;
    }
    else {
        $i = 0;
    }

    $trace = new Ontology::Trace unless defined($trace);

    foreach my $r ( $f->relationships ) {
        if ( $type eq 'parts' ) {
            next unless ( $r->logus eq 'part_of'
                || $r->logus eq 'member_of' );
            next unless $r->oF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->sF ), $i );
            $self->trace( $self->node_by_id( $r->sF ), $type, $i, $trace );
        }
        elsif ( $type eq 'producers' ) {
            next
              unless ( $r->logus eq 'produced_by'
                || $r->logus eq 'derives_from' );
            next unless $r->sF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->oF ), $i );
            $self->trace( $self->node_by_id( $r->oF ), $type, $i, $trace );
        }
        elsif ( $type eq 'wholes' ) {
            next unless ( $r->logus eq 'part_of'
                || $r->logus eq 'member_of' );
            next unless $r->sF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->oF ), $i );
            $self->trace( $self->node_by_id( $r->oF ), $type, $i, $trace );
        }
        elsif ( $type eq 'produces' ) {
            next
              unless ( $r->logus eq 'produced_by'
                || $r->logus eq 'derives_from' );
            next unless $r->oF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->sF ), $i );
            $self->trace( $self->node_by_id( $r->sF ), $type, $i, $trace );
        }

        elsif ( $type eq 'children' ) {
            next unless $r->logus eq 'isa';
            next unless $r->oF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->sF ), $i );
            $self->trace( $self->node_by_id( $r->sF ), $type, $i, $trace );
        }
        elsif ( $type eq 'parents' ) {
            next unless $r->logus eq 'isa';
            next unless $r->sF eq $f->id;
            $trace->add_feature( $self->node_by_id( $r->oF ), $i );
            $self->trace( $self->node_by_id( $r->oF ), $type, $i, $trace );
        }
        else {
            die "unknown type($type) in Ontology::trace!\n";
        }
    }

    return $trace;

}

#-------------------------------------------------------------------------------
#--------------------------------- PRIVATE -------------------------------------
#-------------------------------------------------------------------------------
sub _index_on_node_names {
    my $self = shift;

    my %names;
    foreach my $id ( keys %{ $self->nodes } ) {
        my $node = $self->node_by_id($id);

        my $name = $node->name();
        push( @{ $names{$name} }, $id );
        foreach my $syn ( @{ $node->synonyms } ) {
            push( @{ $names{$syn} }, $id );
        }
    }

    $self->name_id_index( \%names );
}

#-------------------------------------------------------------------------------
sub source {
    my $self = shift;

    if (@_) {
        $self->{source} = shift;
    }

    return $self->{source};
}

#-------------------------------------------------------------------------------
sub parser {
    my $self = shift;

    if (@_) {
        $self->{parser} = shift;
    }

    return $self->{parser};
}

#-------------------------------------------------------------------------------
sub AUTOLOAD {
    my ( $self, $arg ) = @_;

    my $caller = caller();
    use vars qw($AUTOLOAD);
    my ($call) = $AUTOLOAD =~ /.*\:\:(\w+)$/;
    $call =~ /DESTROY/ && return;

    if ( $ENV{VAAST_CHATTER} ) {
        print STDERR "Ontology::Ontology::AutoLoader called for: ",
          "\$self->$call", "()\n";
        print STDERR "call to AutoLoader issued from: ", $caller, "\n";
    }

    if ( defined($arg) ) {
        $self->{$call} = $arg;
    }
    else {
        return $self->{$call};
    }
}

#-------------------------------------------------------------------------------
1;    #this line is important and will help the module return a true value
__END__
