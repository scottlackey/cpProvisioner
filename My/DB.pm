# File: My/DB.pm
  package My::DB;

  use Rose::DB;
  our @ISA = qw(Rose::DB);

  # Use a private registry for this class
  __PACKAGE__->use_private_registry;

 # Register your lone data source using the default type and domain
    __PACKAGE__->register_db(
      driver   => 'mysql',
      database => 'cp',
      host     => 'localhost',
      username => 'root',
      password => 'power',
    );
1;
