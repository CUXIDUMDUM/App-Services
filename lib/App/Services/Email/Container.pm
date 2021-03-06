package App::Services::Email::Container;

use common::sense;

use Moo;

use Bread::Board;
extends 'Bread::Board::Container';

use App::Services::Logger::Container;

sub BUILD {
	$_[0]->build_container;
}

has log_conf => (
	is      => 'rw',
	default => sub {
		\qq/ 
log4perl.rootLogger=INFO, main
log4perl.appender.main=Log::Log4perl::Appender::Screen
log4perl.appender.main.layout   = Log::Log4perl::Layout::SimpleLayout
/;
	},
);

has msg => (
	is       => 'rw',
	required => 1,

);

has recipients => (
	is       => 'rw',
	required => 1,
);

has timeout => (
	is      => 'rw',
	default => sub { 60 },
);

has mailhost => (
	is       => 'rw',
	required => 1,
);

has from => (
	is       => 'rw',
	required => 1,
);

has subject => (
	is       => 'rw',
	required => 1,
);

has +name => (
	is      => 'rw',
	default => sub { 'email' },
);

sub build_container {
	my $s = shift;

	my $log_cntnr = App::Services::Logger::Container->new(
		log_conf => $s->log_conf,
		name     => 'log'
	);

	container $s => as {

		service log_conf   => $s->log_conf;
		service msg        => $s->msg;
		service mailhost   => $s->mailhost;
		service recipients => $s->recipients;
		service from       => $s->from;
		service subject    => $s->subject;

		service 'logger_svc' => (
			class        => 'App::Services::Logger::Service',
			lifecycle    => 'Singleton',
			dependencies => { log_conf => 'log_conf' },
		);

		service 'email_svc' => (
			class        => 'App::Services::Email::Service',
			dependencies => {
				logger_svc => depends_on('logger_svc'),
				msg        => 'msg',
				recipients => 'recipients',
				mailhost   => 'mailhost',
				from       => 'from',
				subject    => 'subject',
			},
		);

	};

	$s->add_sub_container($log_cntnr);

	return $s;
}

no Moo;

1;

