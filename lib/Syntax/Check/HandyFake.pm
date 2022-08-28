package Syntax::Check::HandyFake;
use strict;
use warnings;

use Cwd qw();
use File::Spec qw();

our $VERSION = '0.01';

my $FILE = '.handyfake';

sub import {
  if ($^O =~ /win(?:32|64)/i) {
    warn "Please, dont use this package on the system '".$^O."'";
    exit(1);
  }
  my $class = shift;
  my $file = @_ ? shift : _findConfigFile();
  unless ($file and -f $file) {
    warn "file (by default $FILE) wasnt found";
    return;
  }

  open(CNF, "<", $file) or die $!;
  while(<CNF>) {
    chomp;
    next unless $_;
    next if $_ =~ /^\s*#/;
    $DB::signal = 1;
    my ($pkg_name, $export_names) = split(/\s*\->\s*/, $_);
    next unless $pkg_name;
    next if _isLoaded($pkg_name);
    next if _canBeLoaded($pkg_name);
    $export_names = $export_names ? [split(/\s*,\s*/, $export_names)] : [];
    my $pkg_str = ["package ".$pkg_name.";"];
    if (@$export_names) {
      push @$pkg_str, "use Exporter 'import';";
      push @$pkg_str, "our \@EXPORT = qw(".join(" ", @$export_names).");";
      for (@$export_names) {
        push @$pkg_str, "sub ".$_."{}";
      }
      push @$pkg_str, "our \@EXPORT_OK = \@EXPORT;";
      # push @$pkg_str, "our \%EXPORT_TAGS = (all => \\\@EXPORT_OK,);";
    }
    push @$pkg_str, "sub VERSION { 12 }";
    push @$pkg_str, "1;";
    print join "\n", @$pkg_str; 
    eval join "\n", @$pkg_str;
    (my $pkg_path = $pkg_name .".pm") =~ s/::/\//g;
    $INC{$pkg_path} = $INC[0]."/".$pkg_path;
  }
  close(CNF);
}

sub _isLoaded {
  (my $pkg_name = shift . ".pm") =~ s/::/\//g;
  return $INC{$pkg_name} ? 1 : 0;
}

sub _canBeLoaded {
  (my $pkg_name = shift . ".pm") =~ s/::/\//g;
  return 1 if $INC{$pkg_name};
  for (@INC) {
    return 1 if -e $_.'/'.$pkg_name;
  }
  return;
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

Syntax::Check::HandyFake - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Syntax::Check::HandyFake;
  blah blah blah

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
