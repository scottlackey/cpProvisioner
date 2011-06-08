# Here we map DB table names to Rose:DB objects.

package Appenv;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('appenv');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('appenv');
package Appenvversion;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('appenv_version');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('appenv_version');
package Appinstance;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('appinstance');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('appinstance');
package Appserver;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('appserver');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('appserver');
package Chrootimage;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('chrootimage');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('chrootimage');
package Osimage;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('osimage');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('osimage');
package Publicinterface;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('public_interface');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('public_interface');
package Resource;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('resource');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('resource');
package Resourcetype;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('resource_type');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('resource_type');
#package Resourceversion;
#    use base 'My::DB::Object';
#    __PACKAGE__->meta->table('resource_version');
#    __PACKAGE__->meta->auto_initialize;
#    __PACKAGE__->meta->make_manager_class('resource_version');
package Resourceaccess;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('resourceaccess');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('resourceaccess');
package Resourceserver;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('resourceserver');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('resourceserver');
package Threadpack;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('threadpack');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('threadpack');
package Account;
    use base 'My::DB::Object';
    __PACKAGE__->meta->table('account');
    __PACKAGE__->meta->auto_initialize;
    __PACKAGE__->meta->make_manager_class('account');

1;
