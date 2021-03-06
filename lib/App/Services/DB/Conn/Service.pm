package App::Services::DB::Conn::Service;

use Moo;

use common::sense;

with 'App::Services::Logger::Role';

use DBI;

has dsn => (
	is => 'rw',
	required => 1,
);

has db_user => (
	is => 'rw',
	required => 1,
);

has db_password => (
	is => 'rw',
	required => 1,
);

has dbh => (
	is => 'rw',
	default => \&dbh_builder,
	lazy => 1,
);

sub dbh_builder {
 my $s = shift;

 my $dbh = DBI->connect($s->dsn,$s->db_user,$s->db_password);

 unless ( $dbh ) {
	$s->log->error(DBI->errstr());
	return undef;
 }

 return $dbh;

}

no Moo;

1;

