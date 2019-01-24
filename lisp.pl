#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature qw/say/;
use Data::Dumper;
use lib 'lib';

use Lisp::Tiny;

# http://cui.unige.ch/isi/bnf/LISP/BNFindex.html
=pod
s_expression = atomic_symbol | "(" s_expression "."s_expression ")" | list 
list = "(" s_expression { s_expression } ")"
atomic_symbol = letter atom_part
atom_part = empty | letter atom_part | number atom_part
letter = "a" ... "z"
number = "1" ... "9"
empty = " "
=cut

my $lisp = Lisp::Tiny->new;


# my $obj = $lisp->parse("(defun length (L) (if L (+ 1 (length (cdr L))) 0))");
# my $obj = $lisp->parse("(aa . (b . (c . (a))))");
my $obj = $lisp->parse('(write-line "Welcome to \"Tutorials Point\"" "s" aaa)');
say Dumper $obj;