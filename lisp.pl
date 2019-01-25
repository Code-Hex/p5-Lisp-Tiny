#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw/say/;
use Data::Dumper;
use lib 'lib';

use Lisp::Tiny;
use Term::ReadLine;

# http://cui.unige.ch/isi/bnf/LISP/BNFindex.html
=pod
s_expression = atomic_symbol | "(" s_expression "."s_expression ")" | list 
list = "(" s_expression { s_expression } ")"
atomic_symbol = space | identifier | string | numeric
=cut

my $term = Term::ReadLine->new('Tiny lisp interpreter');
my $lisp = Lisp::Tiny->new;

while (defined(my $line = $term->readline('> '))) {
    my $s = $lisp->parse($line);
    say Dumper $s;
    my $ret;
    eval {
        $ret = $lisp->eval($s);
    };
    say $@ and next if $@;
    say "ret: $ret";
}


# my $obj = $lisp->parse("(defun length (L) (if L (+ 1 (length (cdr L))) 0))");
# my $obj = $lisp->parse("(aa . (b . (c . (a))))");
# my $obj = $lisp->parse('(write-line "Welcome to \"Tutorials Point\"" "s" aaa)');
# say Dumper $obj;

#my $expr = '(let ((a 1) (b 2)) (+ a b))';
