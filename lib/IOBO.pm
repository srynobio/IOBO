package IOBO;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::FlashMessage;
use Template;

use Data::Dumper;

our $VERSION = '0.1.5';


use Data::Dumper;

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
    redirect '/add_protein';
};

#---------------------------

get '/add_protein' => sub {
    template 'add_protein', { add_protein => uri_for('/protein_upload'), };
};

#---------------------------

post '/protein_upload' => sub {
    req_check();
    gene_insert();

    my $protein = request->params->{protein_name};
    flash message => "$protein added!";

    redirect '/add_protein';
};

#---------------------------

get '/add_complex' => sub {
    template 'add_complex', { add_complex_list => uri_for('/upload_complex'), };
};

#---------------------------

post '/upload_complex' => sub {
    complex_insert();

    my $complex = request->params->{complex_parts};
    flash message => "$complex added!";

    redirect '/add_complex';
};

#---------------------------

get '/add_metabolite' => sub {
    template 'add_metabolite',
      { add_metabolite_list => uri_for('/upload_metabolite'), };
};

#---------------------------

post '/upload_metabolite' => sub {
    list_insert('metabolite');
    flash message => "metabolite added!";
    redirect '/add_metabolite';
};

#---------------------------

get '/add_hugo' => sub {
    template 'add_hugo',
        { add_hugo_annotation => uri_for('/upload_annotation') };
};

#---------------------------

post '/upload_annotation' => sub {
    annotation_insert();
    redirect '/add_hugo';
};

#---------------------------

get '/add_relationship' => sub {
    template 'add_relationship',
      { relationship_info => uri_for('/upload_relationship') };
};

#---------------------------

post '/upload_relationship' => sub {
    relationship_insert();
    flash message => 'relationship added!';
    redirect '/add_relationship';
};

#---------------------------

get '/add_comment' => sub {
    template 'add_comment',
        { add_comment => uri_for('/upload_comment') };
};

#---------------------------

post '/upload_comment' => sub {
    comment_insert();
    redirect '/add_comment';
};

#---------------------------

get '/delete_relationship' => sub {
    template 'delete_relationship',
      { delete_relationship => uri_for('/delete'), };
};

#---------------------------

post '/delete' => sub {
    delete_relationship();
    flash message => 'relationship deleted!';
    redirect '/delete_relationship';
};

#---------------------------
# IOBO subs
#---------------------------

sub annotation_insert {
    my $post = request->params;

    $post->{'comment_list'} =~ s/^\s+|\s+$//g;
    $post->{'hugo_list'}    =~ s/^\s+|\s+$//g;
    $post->{'comment_list'} =~ s/\R/ /g;
    $post->{'hugo_list'}    =~ s/\R/:/g;

   database->quick_insert(
        'add_hugo_annotation',
        {
            protein_name           => $post->{'protein_name'},
            hugo_list              => $post->{'hugo_list'},
            comment_list           => $post->{'comment_list'},
            pathway                => $post->{'pathway'},
        }
    );
    return;
}

#---------------------------

sub delete_relationship {
    my $post = request->params;

    my $select = database->quick_select(
        'relationships',
        { subject => $post->{'image_gene'} },
        { pathway => $post->{'pathway'} },
    );

    # delete from gene_info and relationships table
    my $id = $select->{'id'};
    database->quick_delete( 'relationships', { id => $id } );
    return;
}

#---------------------------

sub comment_insert {
    my $post = request->params;

    # remove any whitespace.
    $post->{'comment_list'} =~ s/^\s+|\s+$//g;
    $post->{'comment_list'} =~ s/\R/ /g;

    database->quick_insert(
        'add_comment',
        {
            comment     => $post->{'comment_list'},
            pathway     => $post->{'pathway'},
            originating => $post->{'type'},
        }
    );
    return;
}

#---------------------------

sub complex_insert {

    my $post = request->params;

    unless ( $post->{'complex_parts'} and $post->{'complex_pathway'} ) {
        halt("Complex parts and Pathway required!");
    }

    my @parts   = split /\s+/, $post->{'complex_parts'};
    my @s_parts = sort @parts;
    my $c_parts = join( ":", @s_parts );
    $c_parts =~ s/^://;

    database->quick_insert(
        'add_complex',
        {
            complex => $c_parts,
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

    ## to accept location info
    my $location = $post->{'location'};
    my @local;

    ( ref $location eq 'ARRAY' )
      ? @local = @{$location}
      : push @local, $location;

    my $place;
    ( scalar @local < 1 )
      ? $place = shift @local
      : $place = join( ":", @local );

    ## to accept alteration info
    my $alteration = $post->{'genetic_alterations'};
    my @alts;

    ( ref $alteration eq 'ARRAY' )
      ? @alts = @{$alteration}
      : push @alts, $alteration;

    my $gen_alt;
    ( scalar @alts < 1 )
      ? $gen_alt = shift @alts
      : $gen_alt = join( ":", @alts );

    ## to accept conferred info
    my $conferred = $post->{'conferred_capabilities'}, my @confs;

    ( ref $conferred eq 'ARRAY' )
      ? @confs = @{$conferred}
      : push @confs, $conferred;

    my $conf_cap;
    ( scalar @confs < 1 )
      ? $conf_cap = shift @confs
      : $conf_cap = join( ":", @confs );

    # Node (gene info)
    database->quick_insert(
        'add_protein',
        {
            protein_name           => $post->{'protein_name'},
            genetic_alterations    => $gen_alt,
            conferred_capabilities => $conf_cap,
            mutation_type          => $post->{'mutation_type'},
            pathway                => $post->{'pathway'},
            location               => $place,
        }
    );
    return;
}

#---------------------------

sub relationship_insert {

    my $post = request->params;

    foreach my $rel ( keys %{$post} ) {
        if ( $rel =~ /relationship_gene(\d+)/ ) {
            my $number = $1;
            next unless $post->{$rel};

            database->quick_insert(
                'relationships',
                {
                    subject     => $post->{'image_item'},
                    predicate   => $post->{'relationship_type'}[ $number - 1 ],
                    object      => $post->{$rel},
                    originating => $post->{'type'},
                    pathway     => $post->{'pathway'},
                }
            );
        }
    }
    return;
}

#---------------------------

sub req_check {
    my $post = request->params;

    # check for both gene names
    unless ($post->{'protein_name'}
        and $post->{'pathway'}
        and $post->{'location'} )
    {
        halt("Gene, Location and Pathway Required!");
    }
    return;
}

#---------------------------

#sub json_writer {
#
#    my $JFH = IO::File->new( '../public/json/iobo.json', 'w' );
#
#    my @genes     = database->quick_select( 'gene_info',     {} );
#    my @relations = database->quick_select( 'relationships', {} );
#
#    my %iobo;
#
#    # head tag
#    $iobo{'name'} = "IOBO";
#
#    foreach my $gene (@genes) {
#        my $gene_name = $gene->{'protein_name'};
#        my $location  = $gene->{'location'};
#        my $pathway   = $gene->{'pathway'};
#
#        $gene_name = "$gene_name - $pathway - $location";
#
#        my @rels;
#        foreach my $rels (@relations) {
#            if ( $gene->{'id'} eq $rels->{'subject'} ) {
#                my $value = "$rels->{predicate} : $rels->{'object'}";
#                push @rels, { name => $value };
#            }
#        }
#
#        my $parts = {
#            name     => $gene_name,
#            children => \@rels,
#        };
#        push @{ $iobo{'children'} }, $parts;
#    }
#
#    ##my $flare = encode_json \%iobo;
#    print $JFH $flare;
#    $JFH->close;
#
#    return;
#}

#---------------------------
1;

