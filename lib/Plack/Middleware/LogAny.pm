package Plack::Middleware::LogAny;
# ABSTRACT: Use Log::Any to handle logging from your Plack app

use Log::Any qw{};
use Plack::Util::Accessor qw{category logger};
use parent qw{Plack::Middleware};
use strict;
use warnings;

=head1 SYNOPSIS

  builder {
      enable "LogAny", category => "plack";
      $app;
  }

=head1 DESCRIPTION

LogAny is a L<Plack::Middleware> component that allows you to use
L<Log::Any> to handle the logging object, C<psgix.logger>.

It really tries to be the thinnest possible shim, so it doesn't handle
any configuration beyond setting the category to which messages from
plack might be logged.

=head1 CONFIGURATION

=over 4

=item category

The C<Log::Any> category to send logs to. Defaults to C<''> which
means it send to the root logger.

=back

=method prepare_app

This method initializes the logger using the category that you
(optionally) set.

=head1 SEE ALSO

L<Log::Any>

=cut

sub prepare_app {
    my ($self) = @_;
    $self->logger (Log::Any->get_logger (category => $self->category || ''));
}

=method call

Actually handles making sure the logger is invoked.

=cut

sub call {
    my ($self, $env) = @_;

    $env->{'psgix.logger'} = sub {
        my $args = shift;
        my $level = $args->{level};
        $self->logger->$level ($args->{message});
    };

    $self->app->($env);
}

1;
