package Lisp::Tiny::VM;

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
# use Lisp::Tiny::Builtin;

my $builtin = +{
    "print"   => sub {
        my $arg = shift;
        say $arg;
        return $arg;
    },
    '+'     => sub {
        my $sum;
        $sum += $_ for @_;
        return $sum;
    },
    '-'     => sub {
        my $minus;
        $minus -= $_ for @_;
        return $minus;
    },
    '*'     => sub {
        my $mul = 1;
        $mul *= $_ for @_;
        return $mul;
    },
    '/'    => sub {
        my $div = $_[0];
        $div /= $_ for @_[1..$#_];
        return $div;
    }
};

sub new {
    my $class = shift;
    return bless +{
        global => +{},
        local  => +{},
    }, $class;
}

sub eval {
    my ($self, $exp) = @_;

    # variables
    if (ref($exp) !~ /ARRAY/) {
        # replace identifier to variable
        return $self->{local}{$exp} if $self->{local}{$exp};
        return $self->{global}{$exp} if $self->{global}{$exp};

        # number or string
        if (ref($exp) =~ /Lisp::Tiny::String|Lisp::Tiny::Number/) {
            return $exp->val;
        }
        goto DIE;
    }

    # let
    if ($exp->[0] =~ /let/) {
        my $local_variables = +{};
        goto DIE if ref($exp->[1]) !~ /ARRAY/;

        # (let ((a 1) (b 2) (c 3)) (expr))
        # part of ((a 1) (b 2) (c 3))
        for my $let (@{$exp->[1]}) {
            my $name = $let->[0];
            my $val = $let->[1];
            goto DIE if $val !~ /Lisp::Tiny::String|Lisp::Tiny::Number/;
            $local_variables->{$name} = $val->val;
        }

        goto DIE if ref($exp->[2]) !~ /ARRAY/;
        $self->{local} = $local_variables;
        my $ret = $self->eval($exp->[2]);
        $self->{local} = +{}; # delete local variables
        return $ret;
    }

    # progn
    if ($exp->[0] =~ /progn/) { # (progn exp+)
        my $val;
        for my $e (@$exp[1..$#$exp]) {
            $val = $self->eval($e);
        }
        return $val;
    }

    # defvar
    if ($exp->[0] =~ /defvar/) { # (defvar var exp)
        my $var = $exp->[1];
        $self->{global}{$var} = $self->eval($exp->[2]);
        return $self->{global}{$var};
    }

    # perl
    if ($exp->[0] =~ /perl/) { # (perl (perl code...))
        my $perl = $exp->[1];
        return eval "$perl";
    }

    # builtin
    if (my $fn = $builtin->{$exp->[0]}) {
        my @args;
        push @args, $self->eval($_) for @$exp[1..$#$exp];
        return $fn->(@args);
    }

DIE:
    die "error:". Dumper $exp;
}

1;