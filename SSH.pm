package Net::SSH;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK $ssh);
use Exporter;
use IPC::Open2;
use IPC::Open3;

@ISA = qw(Exporter);
@EXPORT_OK = qw( ssh issh sshopen2 sshopen3 );
$VERSION = '0.02';

$ssh = "ssh";

=head1 NAME

Net::SSH - Perl extension for secure shell

=head1 SYNOPSIS

  use Net::SSH qw(ssh issh sshopen2 sshopen3);

  ssh('user@hostname', $command);

  issh('user@hostname', $command);

  sshopen2('user@hostname', $reader, $writer, $command);

  sshopen3('user@hostname', $reader, $writer, $error, $command);

=head1 DESCRIPTION

Simple wrappers around ssh commands.

=head1 SUBROUTINES

=over 4

=item ssh [USER@]HOST, COMMAND [, ARGS ... ]

Calls ssh in batch mode.

=cut

sub ssh {
  my($host, @command) = @_;
  my @cmd = ($ssh, '-o', 'BatchMode yes', $host, @command);
  system(@cmd);
}

=item issh [USER@]HOST, COMMAND [, ARGS ... ]

Prints the ssh command to be executed, waits for the user to confirm, and
(optionally) executes the command.

=cut

sub issh {
  my($host, @command) = @_;
  my @cmd = ($ssh, $host, @command);
  print join(' ', @cmd), "\n";
  if ( &_yesno ) {
    system(@cmd);
  }
}

=item sshopen2 [USER@]HOST, READER, WRITER, COMMAND [, ARGS ... ]

Connects the supplied filehandles to the ssh process (in batch mode).

=cut

sub sshopen2 {
  my($host, $reader, $writer, @command) = @_;
  open2($reader, $writer, $ssh, '-o', 'Batchmode yes', $host, @command);
}

=item sshopen3 HOST, WRITER, READER, ERROR, COMMAND [, ARGS ... ]

Connects the supplied filehandles to the ssh process (in batch mode).

=cut

sub sshopen3 {
  my($host, $writer, $reader, $error, @command) = @_;
  open3($writer, $reader, $error, $ssh, '-o', 'Batchmode yes', $host, @command);
}

sub _yesno {
  print "Proceed [y/N]:";
  my $x = scalar(<STDIN>);
  $x =~ /^y/i;
}

=back

=head1 EXAMPLE

  use Net::SSH qw(sshopen2);
  use strict;

  my $user = "username";
  my $host = "hostname";
  my $cmd = "command";

  sshopen2("$user\@$host", *READER, *WRITER, "$cmd") || die "ssh: $!";

  while (<READER>) {
      chomp();
      print "$_\n";
  }

  close(READER);
  close(WRITER);

=head1 AUTHOR

Ivan Kohler <ivan-netssh_pod@420.am>

=head1 CREDITS

 John Harrison <japh@in-ta.net> contributed an example for the documentation.

=head1 BUGS

Not OO.

Look at IPC::Session (also fsh)

=head1 SEE ALSO

ssh(1), L<IPC::Open2>, L<IPC::Open3>

=cut

1;

