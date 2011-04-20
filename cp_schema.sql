CREATE TABLE IF NOT EXISTS user (
  user_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  username varchar(16),
  password varchar(32),
  unique (user_id),
  unique (username),
  index (username)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS osimage (
  osimage_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  distro varchar(256),
  distro_version varchar(256),
  repo_reference varchar(256),
  unique (osimage_id),
  unique (distro),
  index (distro),
  index (distro, distro_version)
) ENGINE=InnoDB;

/* The appenv refers to the application environment selected by the user.
/  Right now, we just have one (standard Apache+PHP), but this will include
/  other languages, servers, etc. */
CREATE TABLE IF NOT EXISTS appenv (
  appenv_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  appenv_name varchar(256)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS appenv_version (
  appenv_version_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  appenv_version_name varchar(256),
  appenv_id int unsigned NOT NULL,
  repo_reference varchar(256),
  unique (appenv_version_id),
  index (appenv_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chrootimage (
  chrootimage_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  appenv_id int unsigned,
  appenv_version_id int unsigned,
  repo_reference varchar(256),
  unique (chrootimage_id),
  index (appenv_id),
  index (appenv_id, appenv_version_id)
) ENGINE=InnoDB;

/* appinstances are the entities our users think most about. */
/* The appenv_id is dictated by the user.  The appenv_version_id may be
/  dictated by the user or by other business logic.  The chrootimage_id is
/  more of a back-end technical issue. */
CREATE TABLE IF NOT EXISTS appinstance (
  appinstance_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  appinstance_name varchar(256),
  account_id int unsigned,
  threads_requested int unsigned,
  threads_live int unsigned,
  appenv_id int unsigned,
  appenv_version_id int unsigned,
  chrootimage_id int unsigned,
  is_live boolean DEFAULT 0,
  unique (appinstance_id),
  index (account_id),
  index (appenv_id),
  index (appenv_id, appenv_version_id),
  index (chrootimage_id)
) ENGINE=InnoDB;

/* keeps track of the appservers.  is_live indicates whether the server is
/  considered to be in production at all.  is_allocating indicates that it is
/  accepting requests to allocate new threadpacks (giving us an easy way to
/  pause addition of new demand to a server without deleting its
/  unused_threadpacks */
CREATE TABLE IF NOT EXISTS appserver (
  appserver_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  hostname varchar(256),
  osimage_id int unsigned,
  thread_count int unsigned,
  threads_used int unsigned, /* not sure if this is best way to track... */
  is_live boolean DEFAULT 0,
  is_allocating boolean DEFAULT 0,
  unique (appserver_id),
  unique (hostname),
  index (osimage_id)
) ENGINE=InnoDB;

/* The identifier is used as the base from which to derive both the port number
/  and the UID. */
CREATE TABLE IF NOT EXISTS threadpack (
  threadpack_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  thread_count int unsigned,
  appinstance_id int unsigned,
  chrootimage_id int unsigned,
  appserver_id int unsigned,
  identifier int unsigned,
  is_live boolean DEFAULT 0,
  used boolean DEFAULT 0,
  locked boolean DEFAULT 0,
  unique (threadpack_id),
  index (appinstance_id),
  index (chrootimage_id),
  index (appserver_id)
) ENGINE=InnoDB;

/* used for both web frontends and direct resource access.  Many fields (e.g.
/  the private_* ones) are optional, depending on which kind it is.  Even
/  appinstance is optional here. */
CREATE TABLE IF NOT EXISTS public_interface (
  public_interface_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  account_id int unsigned NOT NULL,
  appinstance_id int unsigned,
  network_interface_id int unsigned,
  is_shared boolean DEFAULT 1,
  public_ipv6 boolean DEFAULT 0,
  public_ip varchar(16),
  public_port smallint unsigned,
  private_ipv6 boolean DEFAULT 0,
  private_ip varchar(16),
  private_port smallint unsigned,
  unique (network_interface_id),
  index (appinstance_id),
  index (private_ip, private_port),
  index (public_ip, public_port)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS resource_type (
  resource_type_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  resource_type_name varchar(256),
  tcpip_based boolean,
  requires_agent boolean,
  standard_port smallint unsigned,
  unique (resource_type_id),
  unique (resource_type_name),
  index (standard_port)
) ENGINE=InnoDB;

/*Incorporated resource_version as a row of resource 4/20/2011 Scott Lackey*/
/* This table keeps track of things such as the different builds of MySQL 
CREATE TABLE IF NOT EXISTS resource_version (
  resource_version_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  resource_version_name varchar(256),
  resource_type_id int unsigned NOT NULL,
  unique (resource_version_id),
  index (resource_type_id)
) ENGINE=InnoDB;
*/

/* Tracks the servers providing each type of resource.  Our assumption is that
/  each server will handle not just a single kind of resource, but a single
/  version (though this could easily be changed).  The meanings of server_size
/  and server_usage are specific to a given resource_type, but in general,
/  server_usage ranges from 0 to server_size depending on how much of the
/  server is used.  (Resources tracked in unused_resources are NOT counted
/  towards the server_usage.) */
CREATE TABLE IF NOT EXISTS resourceserver (
  resourceserver_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  hostname varchar(256),
  osimage_id int unsigned,
  resource_type_id int unsigned,
  resource_version_id int unsigned,
  server_size int unsigned,
  server_usage int unsigned,
  is_live boolean DEFAULT 0,
  is_allocating boolean DEFAULT 0,
  unique (resourceserver_id),
  unique (hostname),
  index (resource_type_id),
  index (resource_version_id),
  index (osimage_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS resourceserver_type_xr (
  id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  resourceserver_id int unsigned NOT NULL,
  resource_type_id int unsigned NOT NULL,
  index (id),
) ENGINE=InnoDB;

/* Resources are associated with accounts, rather than with appinstances.  The
/  relationship between resources and appinstnaces is thought of as a set of
/  access rules, and tracked in the resourceaccess table.  Note that this table
/  does NOT include resources which have been pre-created but not allocated;
/  those are in the unused_resource table. */
/* A resourceidentifier is a sort of bucketid within a resourceserver.  It
/  is unique among resources on that resourceserver, and may correspond to
/  a TCP port, UID or other system id(s) for that resource. */
CREATE TABLE IF NOT EXISTS resource (
  resource_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  resource_type_id int unsigned NOT NULL,
  resource_version float NOT NULL,
  account_id int unsigned,
  resourceserver_id int unsigned,
  resourceidentifier int unsigned,
  resource_size_parameters varchar(256),
  resource_other_parameters varchar(1024),
  locked boolean DEFAULT 0,
  used boolean DEFAULT 0,
  fake_ipv6 boolean DEFAULT 0,
  fake_ip varchar(16),
  fake_port smallint unsigned,
  real_ipv6 boolean DEFAULT 0,
  real_ip varchar(16),
  real_port smallint unsigned,
  unique (resource_id),
  index (resource_type_id),
  index (resource_type_id,resource_version),
  index (resourceserver_id),
  index (fake_ip, fake_port),
  index (real_ip, real_port)
) ENGINE=InnoDB;

/* This table tracks what appinstances are allowed to access which resources.
/  All it reall needs to function is the resource_id and the appinstance_id,
/  but it also includes some audit information with each entry. */
CREATE TABLE IF NOT EXISTS resourceaccess (
  resourceaccess_id int unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
  resource_id int unsigned NOT NULL,
  appinstance_id int unsigned NOT NULL,
  authorizing_account_id int unsigned,
  authorizing_user_id int unsigned,
  date_access_granted datetime,
  unique (resourceaccess_id),
  index (resource_id),
  index (appinstance_id)
) ENGINE=InnoDB;

