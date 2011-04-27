package Appenv::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Appenv' }

    __PACKAGE__->make_manager_methods('appenvs');
package Appenvversion::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Appenvversion' }

    __PACKAGE__->make_manager_methods('appenvversions');
package Appinstance::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Appinstance' }

    __PACKAGE__->make_manager_methods('appinstances');
package Appservers::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Appserver' }

    __PACKAGE__->make_manager_methods('appservers');
package Chrootimage::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Chrootimage' }

    __PACKAGE__->make_manager_methods('chrootimages');
package Osimage::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Osimage' }

    __PACKAGE__->make_manager_methods('osimages');
package Publicinterface::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Publicinterface' }

    __PACKAGE__->make_manager_methods('publicinterfaces');
package Resource::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Resource' }

    __PACKAGE__->make_manager_methods('resources');
package Resourcetype::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Resourcetype' }

    __PACKAGE__->make_manager_methods('resourcetypes');
#package Resourceversion::Manager;
#use base qw(Rose::DB::Object::Manager);
#
#    sub object_class { 'Resourceversion' }
#
#    __PACKAGE__->make_manager_methods('resourceversions');
package Resourceaccess::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Resourceaccess' }

    __PACKAGE__->make_manager_methods('resourceaccesses');
package Resourceserver::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Resourceserver' }

    __PACKAGE__->make_manager_methods('resourceservers');
package Threadpack::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Threadpack' }

    __PACKAGE__->make_manager_methods('threadpacks');
package Account::Manager;
use base qw(Rose::DB::Object::Manager);

    sub object_class { 'Account' }

    __PACKAGE__->make_manager_methods('accounts');
1;
