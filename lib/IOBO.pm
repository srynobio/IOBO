package IOBO;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Template;
##use JSON::XS;

use Data::Dumper;
our $VERSION = '0.0.2';

#---------------------------
# hooks
#---------------------------

hook 'before_template_render' => sub {
    my $tokens = shift;

    $tokens->{'css_url'} = request->base . 'css/style.css';
};

#---------------------------
# Dancer routes
#---------------------------

get '/' => sub {
    redirect '/add_node';
};

#---------------------------

get '/gene_list' => sub {
    template 'gene_list', { create_gene_list => uri_for('/create_gene_list'), };
};

#---------------------------

post '/create_gene_list' => sub {
    list_insert('gene');
    redirect '/gene_list';
};

#---------------------------

get '/complex_list' => sub {
    template 'complex_list',
      { create_complex_list => uri_for('/create_complex_list'), };
};

#---------------------------

post '/create_complex_list' => sub {
    complex_insert();
    redirect '/complex_list';
};

#---------------------------

get '/metabolic_list' => sub {
    template 'metabolic_list',
      { create_metabolic_list => uri_for('/create_metabolic_list'), };
};

#---------------------------

post '/create_protein_list' => sub {
    list_insert('protein');
    redirect '/protein_list';
};

#---------------------------

get '/protein_list' => sub {
    template 'protein_list',
      { create_protein_list => uri_for('/create_protein_list'), };
};

#---------------------------

post '/create_metabolic_list' => sub {
    list_insert('metabolic');
    redirect '/metabolic_list';
};

#---------------------------

get '/add_node' => sub {

    #json_writer();
    template 'add_node', { add_node_term => uri_for('/node_upload'), };
};

#---------------------------

post '/node_upload' => sub {

    my $post = request->params;

    req_check();
    gene_insert();
    relationship_insert();

    redirect '/add_node';
};

#---------------------------

get '/update_node' => sub {

    #json_writer();
    template 'update_node', { update_node_term => uri_for('/node_update'), };
};

#---------------------------

post '/node_update' => sub {

    gene_update();
    relationship_insert();
    redirect '/update_node';
};

#---------------------------

get '/delete_node' => sub {

    #json_writer();
    template 'delete_node', { delete_node_term => uri_for('/node_remove'), };
};

#---------------------------

post '/node_remove' => sub {

    my $gene = request->params;
    node_remove();
    redirect '/delete_node';
};

#---------------------------
# IOBO subs
#---------------------------

sub node_remove {

    my $post = request->params;

    my $select = database->quick_select(
        'gene_info',
        { image_gene => $post->{'image_gene'} },
        { pathway    => $post->{'pathway'} },
    );

    # delete from gene_info and relationships table
    my $id = $select->{'id'};
    database->quick_delete( 'gene_info',     { id      => $id } );
    database->quick_delete( 'relationships', { subject => $id } );
    return;
}

#---------------------------

sub complex_insert {

    my $post = request->params;

    $post->{'complex_parts'} =~ s/(^\s+|\s+$)//g;
    $post->{'complex_name'} =~ s/^\s+//g;
    ( my $parts = $post->{'complex_parts'} ) =~ s/\s+/\:/g;
    ( my $name  = $post->{'complex_name'} ) =~ s/(^\s+|\s+$)//g;

    database->quick_insert(
        'complex_info',
        {
            parts   => $parts,
            name    => $name,
            pathway => $post->{'complex_pathway'},
        }
    );
}

#---------------------------

sub list_insert {

    my $type = shift;
    ( my $key = $type ) =~ s/$/_list/g;

    my $post = request->params;
    my @list = split /\n/, $post->{$key};

    foreach my $i (@list) {
        chomp $i;

        # clean up.
        next if ( $i =~ /^\s+$/ );
        $i =~ s/(^\s+|\s+$)//g;

        database->quick_insert(
            $key,
            {
                name => $i,
            }
        );
    }
}

#---------------------------

sub gene_insert {

    my $post = request->params;

    my $location = $post->{'location'};
    my @local;

    ( ref $location eq 'ARRAY' )
      ? @local = @{$location}
      : push @local, $location;

    my $places;
    ( scalar @local < 1 )
      ? $places = shift @local
      : $places = join( ":", @local );

    # Node (gene info)
    database->quick_insert(
        'gene_info',
        {
            image_gene             => $post->{'image_gene'},
            hugo_gene              => $post->{'hugo_gene'},
            complex_name           => $post->{'complex_name'},
            genetic_alterations    => $post->{'genetic_alterations'},
            conferred_capabilities => $post->{'conferred_capabilities'},
            mutation_type          => $post->{'mutation_type'},
            pathway                => $post->{'pathway'},
            definition             => $post->{'definition'},
            dbxref                 => $post->{'dbxref'},
            location               => $places,
        }
    );
    return;
}

#---------------------------

sub relationship_insert {

    my $post = request->params;

    return unless ( $post->{'relationship'} and $post->{'relationship_gene'} );

    # get id
    my $select = database->quick_select( 'gene_info',
        { image_gene => $post->{'image_gene'} } );
    my $gene_id = $select->{'id'};

    # information can come in as scalar or arrayref
    # this is done to unify the structure.
    my $predicate = $post->{'relationship'};
    my $object    = $post->{'relationship_gene'};
    my ( @relationships, @genes );

    ( ref $predicate eq 'ARRAY' )
      ? @relationships = @{$predicate}
      : push @relationships, $predicate;

    ( ref $object eq 'ARRAY' )
      ? @genes = @{$object}
      : push @genes, $object;

    unless ( scalar @relationships eq scalar @genes ) {
        halt("Genes and relationships not added");
    }

    for ( my $i = 0 ; $i <= scalar @genes ; $i++ ) {
        database->quick_insert(
            'relationships',
            {
                subject   => $gene_id,
                predicate => shift @relationships,
                object    => shift @genes,
            }
        );
    }
    return;
}

#---------------------------

sub gene_update {

    my $post = request->params;

    # get original data info
    my $row =
      database->quick_select( 'gene_info',
        { image_gene => $post->{'image_gene'} },
      );

    # set id
    my $id = $row->{'id'};

    while ( my ( $table, $value ) = each %{$post} ) {
        next unless ($value);
        next if ( $table eq 'id' );
        next unless exists $row->{$table};

        # replace gene_info data
        database->quick_update(
            'gene_info',
            { 'id'   => $id },
            { $table => $post->{$table} },
        );
    }
    return;
}

#---------------------------

sub req_check {
    my $post = request->params;

    # check for both gene names
    unless ( $post->{'image_gene'} and $post->{'hugo_gene'} ) {
        halt("Image and Hugo gene name required");
    }
    return;
}

#---------------------------

#sub dups_check {
#    my $post = request->params;
#
#    # check if gene has been entered into database already.
#    my $image =
#      database->quick_select( 'gene_info',
#        { image_gene => $post->{'image_gene'} },
#      );
#    if ($image) {
#        halt("Gene already entered into database");
#    }
#    return;
#}

#---------------------------

#sub json_writer {
#
#    my $JFH = IO::File->new( '../public/json/iobo.json', 'w' );
#
#    my @genes     = database->quick_select( 'gene_info',     {} );
#    my @relations = database->quick_select( 'relationships', {} );
#
#    my %test;
#
#    # head tag
#    $test{'name'} = "IOBO";
#
#    my $gene_name;
#    foreach my $gene (@genes) {
#        $gene_name = $gene->{'image_gene'};
#
#        my @rels;
#        foreach my $rels (@relations) {
#            if ( $gene->{'id'} eq $rels->{'subject'} ) {
#                my $value = "$rels->{predicate} : $rels->{'object'}";
#                push @rels, { name => $value };
#            }
#        }
#
#        my $thing = {
#            name     => $gene_name,
#            children => \@rels,
#        };
#        push @{ $test{'children'} }, $thing;
#    }
#
#    my $flare = encode_json \%test;
#    print $JFH $flare;
#    $JFH->close;
#
#    return;
#}

#---------------------------

