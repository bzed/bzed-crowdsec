# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`crowdsec`](#crowdsec): Install and manage crowdsec
* [`crowdsec::local_api`](#crowdsec--local_api): A short summary of the purpose of this class
* [`crowdsec::params`](#crowdsec--params): The params class defines some basic defaults for crowdsec.
* [`crowdsec::sources`](#crowdsec--sources): configure crowdsec repositories

### Defined types

* [`crowdsec::local_api::register`](#crowdsec--local_api--register): Registers a machine at the local apu
* [`crowdsec::module`](#crowdsec--module): Install crowdsec modules from the hub.

### Data types

* [`Crowdsec::Module_name`](#Crowdsec--Module_name)
* [`Crowdsec::Module_type`](#Crowdsec--Module_type)

## Classes

### <a name="crowdsec"></a>`crowdsec`

The whole config part that should go into config.yaml.local.
$config['api']['server']['enable'] is overwritten in case
$local_api_puppet_certname is set and == $trusted['certname']

Setup apt sources from the crowdsec repositories.
Defaults to true.

The local api url crowdsec should connect to. Defaults to http://127.0.0.1:8080

The login/user used to authenticate against the local api server.

The password used to login on the local api server.

Use a hash over fqdn and  password instead of the puppet certname.
This sounds weird, but it makes sure that we update user/password
in case the password changes. There is not way to verify an existing password
unfortunately.
Don't disable if you plan to connect to the central API.

If this option is set and matches $trusted['certname'], enable the local api
and collect host registrations exported for that certname.

Nobody reads the documentation. If you actually did so, raise this number: 0
Pull requests for it are fine!

Set this to true if you really want to run the local api server without TLS.
Absolutely not recommended.

Register machine automatically if $local_api_url and $local_api_puppet_certname
is configured properly.

Configure crowdsec to run as LAPI server

Defaults to true, when false we configure a user/group for crowdsec.

Update packages from the crowdsec hub automatically. Defaults to true.

Base directory for all crowdsec config files.

Name of the service used to control the crowdsec daemon.

Remove modules/configs that are not installed by puppet.
Keep in mind that this *will* break collections - you will have to list everything
contained by a collection manually.

Either the name of the module or an array, containing the module name and
all the params to pass to crowdsec::module to install the module.

See parsers

See parsers

See parsers

See parsers

See parsers

See parsers

#### Examples

##### 

```puppet
include crowdsec
```

#### Parameters

The following parameters are available in the `crowdsec` class:

* [`config`](#-crowdsec--config)
* [`manage_sources`](#-crowdsec--manage_sources)
* [`local_api_url`](#-crowdsec--local_api_url)
* [`local_api_login`](#-crowdsec--local_api_login)
* [`local_api_password`](#-crowdsec--local_api_password)
* [`use_anonymous_api_logins`](#-crowdsec--use_anonymous_api_logins)
* [`local_api_puppet_certname`](#-crowdsec--local_api_puppet_certname)
* [`force_local_api_no_tls`](#-crowdsec--force_local_api_no_tls)
* [`register_machine`](#-crowdsec--register_machine)
* [`enable_local_api`](#-crowdsec--enable_local_api)
* [`run_as_root`](#-crowdsec--run_as_root)
* [`automatic_hub_updates`](#-crowdsec--automatic_hub_updates)
* [`config_basedir`](#-crowdsec--config_basedir)
* [`service_name`](#-crowdsec--service_name)
* [`manage_modules`](#-crowdsec--manage_modules)
* [`parsers`](#-crowdsec--parsers)
* [`postoverflows`](#-crowdsec--postoverflows)
* [`scenarios`](#-crowdsec--scenarios)
* [`contexts`](#-crowdsec--contexts)
* [`appsec_configs`](#-crowdsec--appsec_configs)
* [`appsec_rules`](#-crowdsec--appsec_rules)
* [`collections`](#-crowdsec--collections)

##### <a name="-crowdsec--config"></a>`config`

Data type: `Hash`



Default value: `{}`

##### <a name="-crowdsec--manage_sources"></a>`manage_sources`

Data type: `Boolean`



Default value: `true`

##### <a name="-crowdsec--local_api_url"></a>`local_api_url`

Data type: `Stdlib::HTTPUrl`



Default value: `'http://127.0.0.1:8080'`

##### <a name="-crowdsec--local_api_login"></a>`local_api_login`

Data type: `String`



Default value:

```puppet
if $use_anonymous_api_logins {
    sha256("${trusted['certname']} ${local_api_password}")
  } else {
    $trusted['certname']
```

##### <a name="-crowdsec--local_api_password"></a>`local_api_password`

Data type: `Sensitive[String]`



Default value:

```puppet
Sensitive(
    fqdn_rand_string(
      32,
      undef,
      $facts['networking']['mac'],
    )
  )
```

##### <a name="-crowdsec--use_anonymous_api_logins"></a>`use_anonymous_api_logins`

Data type: `Boolean`



Default value: `true`

##### <a name="-crowdsec--local_api_puppet_certname"></a>`local_api_puppet_certname`

Data type: `Optional[Stdlib::Fqdn]`



Default value: `undef`

##### <a name="-crowdsec--force_local_api_no_tls"></a>`force_local_api_no_tls`

Data type: `Boolean`



Default value: `false`

##### <a name="-crowdsec--register_machine"></a>`register_machine`

Data type: `Boolean`



Default value: `($local_api_url != 'http://127.0.0.1:8080') and $local_api_puppet_certname`

##### <a name="-crowdsec--enable_local_api"></a>`enable_local_api`

Data type: `Boolean`



Default value: `$local_api_puppet_certname and $local_api_puppet_certname == $trusted['certname']`

##### <a name="-crowdsec--run_as_root"></a>`run_as_root`

Data type: `Boolean`



Default value: `!$enable_local_api`

##### <a name="-crowdsec--automatic_hub_updates"></a>`automatic_hub_updates`

Data type: `Boolean`



Default value: `true`

##### <a name="-crowdsec--config_basedir"></a>`config_basedir`

Data type: `Stdlib::Absolutepath`



Default value: `$crowdsec::params::config_basedir`

##### <a name="-crowdsec--service_name"></a>`service_name`

Data type: `String`



Default value: `$crowdsec::params::service_name`

##### <a name="-crowdsec--manage_modules"></a>`manage_modules`

Data type: `Boolean`



Default value: `false`

##### <a name="-crowdsec--parsers"></a>`parsers`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--postoverflows"></a>`postoverflows`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--scenarios"></a>`scenarios`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--contexts"></a>`contexts`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--appsec_configs"></a>`appsec_configs`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--appsec_rules"></a>`appsec_rules`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value: `[]`

##### <a name="-crowdsec--collections"></a>`collections`

Data type: `Tuple[Variant[Crowdsec::Module_name, Tuple[Crowdsec::Module_name, Hash, 2, 2]], 0]`



Default value:

```puppet
[
    'crowdsecurity/linux',
    'crowdsecurity/sshd',
  ]
```

### <a name="crowdsec--local_api"></a>`crowdsec::local_api`

A description of what this class does

#### Examples

##### 

```puppet
include crowdsec::local_api
```

### <a name="crowdsec--params"></a>`crowdsec::params`

The params class defines some basic defaults for crowdsec.

#### Examples

##### 

```puppet
include crowdsec::params
```

### <a name="crowdsec--sources"></a>`crowdsec::sources`

setup apt sources lists and necessary keys.

#### Examples

##### 

```puppet
include crowdsec::sources
```

#### Parameters

The following parameters are available in the `crowdsec::sources` class:

* [`keyring_source`](#-crowdsec--sources--keyring_source)
* [`include_sources`](#-crowdsec--sources--include_sources)

##### <a name="-crowdsec--sources--keyring_source"></a>`keyring_source`

Data type: `String`



Default value: `'puppet:///modules/crowdsec/crowdsec-archive-keyring.gpg'`

##### <a name="-crowdsec--sources--include_sources"></a>`include_sources`

Data type: `Boolean`



Default value: `false`

## Defined types

### <a name="crowdsec--local_api--register"></a>`crowdsec::local_api::register`

Registering machines at the local api is done using puppetdb_query,
so we only collect exported ressources. Don't try to use this define
directly.

#### Examples

##### 

```puppet
@@crowdsec::local_api::register { 'namevar':
  password => 'mysecret',
}
```

#### Parameters

The following parameters are available in the `crowdsec::local_api::register` defined type:

* [`password`](#-crowdsec--local_api--register--password)
* [`machine_id`](#-crowdsec--local_api--register--machine_id)

##### <a name="-crowdsec--local_api--register--password"></a>`password`

Data type: `String`



##### <a name="-crowdsec--local_api--register--machine_id"></a>`machine_id`

Data type: `String`



Default value: `$name`

### <a name="crowdsec--module"></a>`crowdsec::module`

This rather generic defined_type allows to install all
the different crowdsec parts that come directly from the crowdsec
hub.
- parsers
- postoverflows
- scenarios
- contexts
- appsec-configs
- appsec-rules
- collections

Required parameter to specify the type of module to install from the hub
(parsers, collections, .....)

Set to 'present' to install, 'absent' to uninstall.


Hash to specify necessay install options like API keys for the hub.
  { 'foo'  => 'bar' }
results in
  --foo bar
being pass as option to cscli .... install.

Defaults to $name. Sets the name of the hub module to install/uninstall.

Module is not from the hub, use this source as source for the file.

Module is not from the hub, use this content for the file.

"module_subtype" of the module, for example s01-parse to install in crowdsec/parsers/s01-parse

#### Examples

##### 

```puppet
crowdsec::module { 'crowdsecurity/ssh-bf':
  type => 'collections',
}
```

#### Parameters

The following parameters are available in the `crowdsec::module` defined type:

* [`module_type`](#-crowdsec--module--module_type)
* [`ensure`](#-crowdsec--module--ensure)
* [`install_options`](#-crowdsec--module--install_options)
* [`module`](#-crowdsec--module--module)
* [`source`](#-crowdsec--module--source)
* [`content`](#-crowdsec--module--content)
* [`module_subtype`](#-crowdsec--module--module_subtype)

##### <a name="-crowdsec--module--module_type"></a>`module_type`

Data type: `Crowdsec::Module_type`



##### <a name="-crowdsec--module--ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`



Default value: `'present'`

##### <a name="-crowdsec--module--install_options"></a>`install_options`

Data type: `Hash[Pattern[/[a-z]+/], String]`



Default value: `{}`

##### <a name="-crowdsec--module--module"></a>`module`

Data type: `Crowdsec::Module_name`



Default value: `$name`

##### <a name="-crowdsec--module--source"></a>`source`

Data type: `Optional[String]`



Default value: `undef`

##### <a name="-crowdsec--module--content"></a>`content`

Data type: `Optional[String]`



Default value: `undef`

##### <a name="-crowdsec--module--module_subtype"></a>`module_subtype`

Data type: `Optional[String]`



Default value: `undef`

## Data types

### <a name="Crowdsec--Module_name"></a>`Crowdsec::Module_name`

The Crowdsec::Module_name data type.

Alias of `Pattern[/[a-z0-9_-]+\/[a-z0-9_-]+/]`

### <a name="Crowdsec--Module_type"></a>`Crowdsec::Module_type`

The Crowdsec::Module_type data type.

Alias of `Enum['parsers', 'postoverflows', 'scenarios', 'contexts', 'appsec-configs', 'appsec-rules', 'collections']`

