package Lisp::Tiny::Parser;

use strict;
use warnings;
use feature qw/say/;
use Lisp::Tiny::String;
use Lisp::Tiny::Number;
use Data::Dumper;

sub new {
    my $class = shift;
    return bless +{
        stack => +[],
    }, $class;
}

sub parse {
    my ($self, $c) = @_;
    $c =~ s!\r\n?!\n!mg; # normalize linefeed
    $self->_parse() for $c;
    
    return $self->{stack};
}


sub _parse {
    my $self = shift;
    $self->{stack} = $self->_parse_s_expr();
    return if m!\G(?:\s*$/)*\z!msgc;
    $self->_error('Syntax Error');
}

sub _parse_s_expr {
    my $self = shift;
    my $tmp = $self->_parse_list() // +[];
    return $tmp if @$tmp > 0;

    # "(" s_expression "."s_expression ")"
    # car same as left, cdr same as right
    if (/\G\(/mgc) {
        my ($car, $cdr);
        return unless $car = $self->_parse_s_expr();
        return unless /\G\./mgc;
        return unless $cdr = $self->_parse_s_expr();
        return unless /\G\)/mgc;

        return +[$car, $cdr];
    }
    
    return $tmp if defined($tmp = $self->_parse_atomic_symbol());
    return;
}

sub _parse_list {
    my $self = shift;
    my $ret = +[];
    if (/\G\(/mgc) {
        my $tmp;
        return unless defined($tmp = $self->_parse_s_expr());
        do {
            /(?:\s*)/mgc; # skip spaces
            push @$ret, $tmp;
        } while (defined($tmp = $self->_parse_s_expr()));

        return unless /\G\)/mgc;
        return $ret;
    }
    return;
}

sub _parse_atomic_symbol {
    my $self = shift;

    my $tmp;
    return $tmp if defined($tmp = $self->_parse_numeric());
    return $tmp if defined($tmp = $self->_parse_string());
    return $tmp if defined($tmp = $self->_parse_ident());
    return;
}

sub _parse_numeric {
    my $self = shift;
    if (/\G([1-9][0-9]*|[0-9])/mgc) {
        return Lisp::Tiny::Number->new($1 + 0);
    }
    return;
}

sub _parse_string {
    my $self = shift;
    if (/\G("(?:[^"\\]|\\.| )*"|'(?:[^'\\]|\\.| )*')/mgc) {
        return Lisp::Tiny::String->new($1);
    }
    return;
}

sub _parse_ident {
    if (/\G(\+|-|\*|\.)(?:\s+)/mgc) {
        return $1;
    }
    if (/\G([a-zA-Z][0-9a-zA-Z-]*)(?:\s+)?/mgc) {
        return $1;
    }
    return;
}

sub _error {
    my ($self, $msg) = @_;

    my $src   = $_;
    my $line  = 1;
    my $start = pos $src || 0;
    while ($src =~ /$/smgco and pos $src <= pos) {
        $start = pos $src;
        $line++;
    }
    my $end = pos $src;
    my $len = pos() - $start;
    $len-- if $len > 0;

    my $trace = join "\n",
        "${msg}: line:$line",
        substr($src, $start || 0, $end - $start),
        (' ' x $len) . '^';
    die $trace, "\n";
}

1;