package IOBO;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Template;
use JSON;

our $VERSION = '0.0.1';

#---------------------------
# hooks

hook 'before_template_render' => sub {
    my $tokens = shift;

    $tokens->{'css_url'} = request->base . 'css/style.css';
};

#---------------------------
# Dancer routes

get '/' => sub {
    template 'index';
};

#---------------------------

get '/add_node' => sub {

    json_writer();
    template 'add_node',
      {
        add_node_term => uri_for('/node_upload'),
      };
};

#---------------------------

post '/node_upload' => sub {

    req_check();
    dups_check();
    gene_insert();
    relationship_insert();
    redirect '/add_node';
};

#---------------------------

get '/update_node' => sub {

    json_writer();
    template 'update_node',
      {
        update_node_term => uri_for('/node_update'),
      };
};

#---------------------------

post '/node_update' => sub {

    gene_update();
    relationship_insert();
    redirect '/update_node';
};

#---------------------------

get '/delete_node' => sub {

    json_writer();
    template 'delete_node',
      {
        delete_node_term => uri_for('/node_remove'),
      };
};

#---------------------------

post '/node_remove' => sub {

    my $gene = request->params;
    node_remove();
    redirect '/delete_node';
};

#---------------------------
# IOBO subs

sub node_remove {

    my $post = request->params;

    my $select =
      database->quick_select( 'gene_info',
        { image_gene => $post->{'image_gene'} },
      );

    # delete from gene_info and relationships table
    my $id = $select->{'id'};
    database->quick_delete( 'gene_info',     { id      => $id } );
    database->quick_delete( 'relationships', { subject => $id } );
    return;
}

#---------------------------

sub gene_insert {

    my $post = request->params;

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
            location               => $post->{'location'},
        }
    );
    return;
}

#---------------------------

sub relationship_insert {

    my $post = request->params;

    # get id
    my $select = database->quick_select( 'gene_info',
        { image_gene => $post->{'image_gene'} } );
    my $gene_id = $select->{'id'};

    # Edge (relationships)
    if ( $post->{'relationships'} ) {

        my $relations = $post->{'relationships'};
        my @rels = split( "\n", $relations );

        foreach my $i (@rels) {
            $i =~ s/\s+//g;
            my ( $pre, $obj ) = split /\:/, $i;
            unless ( $pre and $obj ) {
                send_error( "Predicate and Object required", 401 );
            }

            database->quick_insert(
                'relationships',
                {
                    subject   => $gene_id,
                    predicate => $pre,
                    object    => $obj,
                }
            );
        }
    }

    # complexs_with information
    if ( $post->{'complexes_with'} ) {
        my $comp_list = $post->{'complexes_with'};
        my @gene_list = split( "\n", $comp_list );

        foreach my $i (@gene_list) {
            database->quick_insert(
                'relationships',
                {
                    subject   => $gene_id,
                    predicate => 'complexes_with',
                    object    => $i,
                }
            );
        }
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

sub dups_check {
    my $post = request->params;

    # check if gene has been entered into database already.
    my $image =
      database->quick_select( 'gene_info',
        { image_gene => $post->{'image_gene'} },
      );
    if ($image) {
        halt("Gene already entered into database");
    }
    return;
}

#---------------------------

sub json_writer {

    my $JFH = IO::File->new( '../public/iobo.json', 'w' );

    my @genes     = database->quick_select( 'gene_info',     {} );
    my @relations = database->quick_select( 'relationships', {} );

    my %test;

    # head tag
    $test{'name'} = "IOBO";

    my $gene_name;
    foreach my $gene (@genes) {
        $gene_name = $gene->{'image_gene'};

        my @rels;
        foreach my $rels (@relations) {
            if ( $gene->{'id'} eq $rels->{'subject'} ) {
                my $value = "$rels->{predicate} : $rels->{'object'}";
                push @rels, { name => $value };
            }
        }

        my $thing = {
            name     => $gene_name,
            children => \@rels,
        };
        push @{ $test{'children'} }, $thing;
    }

    my $flare = encode_json \%test;
    print $JFH $flare;
    $JFH->close;

}

#---------------------------

