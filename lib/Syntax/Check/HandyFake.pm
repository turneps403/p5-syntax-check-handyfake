package Syntax::Check::HandyFake;
use strict;
use warnings;

use Scalar::Util qw();
use File::Spec qw();
use Cwd qw();
use PPI qw();

my $FILE = '.p5-handyfake';

BEGIN {
  die "Operating system does not suitable for usage " . __PACKAGE__
    if grep {$^O eq $_} qw(MSWin32 os2 VMS NetWare symbian dos cygwin amigaos);
}

sub import {
  my $class = shift;

  my $exp_func = {};
  my $cnf_file = shift || _findConfigFile();
  if ($cnf_file) {
    if (-f $cnf_file) {
      open(CNF, "<", $cnf_file) or die $!;
      while(<CNF>) {
        $_ =~ s/^\s+|\s+$//g;
        next unless $_;
        next if /^\s*#/;
        my ($pkg, @exp) = split /\s+/, $_;
        $exp_func->{$pkg} = \@exp;
      }
      close(CNF);
    } else {
      die "'".$cnf_file."' not a file";
    }
  }

  my $q = qr/^([^\(]+)(?:\(([^\)]{0,})\))?$/o;

  my $cur_pkg = 'main';
  for (PPI::Document->new($0)->children) {
    if ($_->isa('PPI::Statement::Package')) {
      $cur_pkg = ($_->children)[2]->content;
    } elsif ($_->isa('PPI::Statement::Include')) {
      my $module = $_->module;
      (my $pkg_path = $module .".pm") =~ s/::/\//g;
      $INC{$pkg_path} = $INC[0]."/FAKE/".$pkg_path;
      my $efunc = $exp_func->{$module} || [];
      for (@$efunc) {
        my ($fname, $prttp) = $_ =~ $q;
        $DB::signal = 1;
        my $sub = $cur_pkg . '::' . $fname;
        no strict 'refs';
        if ($prttp) {
          *$sub = Scalar::Util::set_prototype(sub {}, $prttp);
        } else {
          *$sub = sub {};
        }
      }
    }
  }

  for (@{ $exp_func->{"-"} || [] }) {
    my ($sub, $prttp) = $_ =~ $q;
    no strict 'refs';
    if ($prttp) {
      *$sub = Scalar::Util::set_prototype(sub {}, $prttp);
    } else {
      *$sub = sub {};
    }
  }

  return 1;
}

sub _findConfigFile {
  my $cur = Cwd::abs_path();
  while(1) {
    my $file = File::Spec->catfile($cur, $FILE);
    return $file if -e $file;
    last if $cur eq Cwd::abs_path($cur . "/..");
    $cur = Cwd::abs_path($cur . "/..");
  }
  return $ENV{HOME} && -e File::Spec->catfile($ENV{HOME}, $FILE) ? 
    File::Spec->catfile($ENV{HOME}, $FILE) : undef;
}

1;
__END__

=head1 NAME

Syntax::Check::HandyFake helps you to avoid installation some packages and pass by syntax check

=head1 SYNOPSIS

  $ cat ~/.handyfake
  My::Awesome::Package
  Another::Stupid::Thing -> useless_func_one, useless_func_two


  $ cat test.pl
  #!/usr/local/bin/perl
  use strict;
  use warnings;

  use My::Awesome::Package;
  use Another::Stupid::Thing;

  print My::Awesome::Package->VERSION . "\n";
  print Another::Stupid::Thing->VERSION . "\n";

  useless_func_one;

  exit;


  $ perl -I some/lib -MSyntax::Check::HandyFake -wc test.pl
  test.pl syntax OK

=head1 DESCRIPTION

Stub documentation for Syntax::Check::HandyFake, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
