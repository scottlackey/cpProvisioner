package My::DB::Object;

    use My::DB;
    use base qw(Rose::DB::Object);
    sub init_db { My::DB->new }
1;
