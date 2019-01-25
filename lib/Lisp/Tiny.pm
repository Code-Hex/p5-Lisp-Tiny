package Lisp::Tiny;

use strict;
use warnings;
use Lisp::Tiny::Parser;
use Lisp::Tiny::VM;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    return bless +{}, $class;
}

sub parse {
    my ($self, $syntax) = @_;
    my $stack = Lisp::Tiny::Parser->new->parse($syntax);
    return $stack;
}

sub eval {
    my ($self, $stack) = @_;
    return Lisp::Tiny::VM->new->eval($stack);
}

1;
__END__

=encoding utf-8

=head1 NAME

Lisp::Tiny - It's new $module

=head1 SYNOPSIS

    use Lisp::Tiny;

=head1 DESCRIPTION

Lisp::Tiny is ...

=head1 LICENSE

Copyright (C) Kei Kamikawa.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kei Kamikawa E<lt>x00.x7f@gmail.comE<gt>

=cut

