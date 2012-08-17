package App::Services::ObjStore::Container;

use Moo;

use common::sense;

#use MooX::Types::MooseLike::Base;

use Bread::Board;

extends 'Bread::Board::Container';

use App::Services::Logger::Container;

sub BUILD {
	$_[0]->build_container;
}

has log_conf => (
	is      => 'rw',
	default => sub {'log4perl.conf' },
);

has +name => (
	is      => 'rw',
#	isa     => 'Str',
	default => sub { 'obj_store' },
);

sub build_container {
	my $s = shift;
	
	my $log_cntnr = App::Services::Logger::Container->new(
		log_conf => $s->log_conf,
		name => 'log'
	);

	container $s => as {

		service 'obj_store_svc' => (
			class        => 'App::Services::ObjStore::Service',
			dependencies => {
				logger_svc => depends_on('log/logger_svc'),
			}
		);

	};
	
	$s->add_sub_container($log_cntnr);
	
	return $s;
}

no Moo;

1;
