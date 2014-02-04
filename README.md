<h1>IOBO Images to Ontologies</h1>

<h2>Introduction</h2>

IOBO is a Image (poster, etc) to ontology creator.  It uses <a href="http://www.perldancer.org" target="_blank">Dancer</a>
and sqlite3 to collect all relationships, and if desired, produces a OBO file useful for a number of downstream
applications.

IOBO was created as a joint project between the M.Yandell & K.Eilbeck labs to transform this <a href="http://www.garlandscience.com/res/9780815342199/supplementary/Pathways_in_Human_Cancer.pdf" target="_blank">image</a>
into a transversable ontology.

Version 0.0.3

<h2>Requirements</h2>

<a href="http://www.perldancer.org" target="_blank">Dancer</a><br>
<a href="https://metacpan.org/pod/Dancer::Plugin::Database" target="_blank">Dancer::Plugin::Database</a><br>
<a href="https://metacpan.org/pod/Template" target="_blank">Template</a><br>
<a href="https://metacpan.org/pod/JSON::XS" target="_blank">JSON::XS</a><br>

SQlite3


<h2>Installation</h2>

Installing IOBO will be as easy as following the tutorial and deployment found on the Dancer <a href="http://www.perldancer.org/documentation" target="_blank">website</a>
Additionally a working understanding of how to use and work with apache, etc is assumed.


<h2>Incompatibilities</h2>

None know.

BUGS AND LIMITATIONS

Please report any bugs or feature requests to: shawn.rynearson@gmail.com

AUTHOR Shawn Rynearson <shawn.rynearson@gmail.com>

LICENCE AND COPYRIGHT Copyright (c) 2013, Shawn Rynearson <shawn.rynearson@gmail.com> All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

DISCLAIMER OF WARRANTY BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.)))
