package Resource;

    use base 'My::DB::Object';

    __PACKAGE__->meta->setup
    (
      table      => 'resource',
      columns    => [ qw(resource_id resource_type_id resource_version_id account_id resourceserver_id resourceidentifier resource_size_parameters) ],
      #pk_columns => 'id',
    );
1;
