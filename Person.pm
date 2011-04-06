package Person;
use Moose;

has 'name' => (
	is => 'rw',
	isa => 'Str'
);
has 'age' => (
	is => 'rw',
	isa => 'Int'
);
1;



