# AWSSSH

[![Gem Version](https://badge.fury.io/rb/awsssh.png)](http://badge.fury.io/rb/awsssh) || Master: [![Build Status](https://travis-ci.org/sethiele/awsssh.svg?branch=master)](https://travis-ci.org/sethiele/awsssh) || develop: [![Build Status](https://travis-ci.org/sethiele/awsssh.svg?branch=develop)](https://travis-ci.org/sethiele/awsssh)

This gem helps you to connect to any `Amazon Web Service` `Opsworks` instances you have permissions for via ssh.
You don't have to setup your ssh configuration for dynamic Hostnames or dynamic IPs. And this over the borders of profiles (AWS accounts).

This gem reads the AWS Opsworks Stackinformations and looks for the right server to connect. All You have to know is the right Server Hostname (when the host name follows the pattern `PROFILENAME-WHATEVER` this is all you need) and the profile name.

## Installation

1. `gem install awsssh`

### Configurationen

* Be shure you have seted up the Enviroment variable `AWS_CREDENTIAL_FILE` with the path to your credential File. (`echo $AWS_CREDENTIAL_FILE`) If not set the Enviroment variable with `export AWS_CREDENTIAL_FILE=~/.aws/credentials`.
* Inside the credential file you have to place all your credentials in the following format (its aws standard):
```
[PROFILE-1]
aws_access_key_id=VALUE
aws_secret_access_key=VALUE
[PROFILE-n]
aws_access_key_id=VALUE
aws_secret_access_key=VALUE
```

## Use `awsssh`

### Connect to Server

If the profile name is the first part of the host name (like `PROFILENAME-WHATEVER`) connect with:<br>
`awsssh connect HOSTNAME`

**Example:**<br>
`awsssh connect profile-live-1`

If the profile name is not the first part of the hostname (like `app-1`) connect with:<br>
`awsssh connect HOSTNAME --profile PROFILE`

**Example:**<br>
`awsssh connect app-1 --profile PROFILENAME`

### List all profiles
`awsssh list_profiles`

### List all server for a given profile
`awsssh list_server PROFILENAME`

### Help
`awsssh help`

### Version
`awsssh version`

## Contact

Sebastian Thiele<br>
(Twitter: [@sebat](https://twitter.com/sebat))

issues:
[github](https://github.com/sethiele/awsssh)

## Changelog
**2016-02-29 - v 3.2.0.rc1**
* [enh] Connect to multible Server at once, if tmux is running

**2016-02-24 - v 3.1.1**
* [enh] Version Check

**2016-02-24 - v 3.1.0**
* [enh] Show only online Server
* [enh] colors in output
* [enh] connect to server from list_server
* [fix] error message for list_servers with unkown profile

**2016-02-18 - v 3.0.0**
* readme in english
* Tests

**2016-02-04 - v 3.0.0.rc1**
* redesign
* new credential format

**2015-11-25 - v 2.2.2**
* [fix] List all Servers

**2015-03-02 - v 2.2.1**
* [add] Version information

**2015-03-02 - v 2.2.0**
* [enh] Alias for list servers and accounts changed
* [fix] Build own punlic DNS if no public dns is set

**2014-08-01 - v 2.1.2**
* [enh] Alias for `--list-servers` and `--list-accounts`

**2014-03-** - v 2.1.2
* [fix] alias with -

**2014-03-05** - v 2.1.1
* [enh] using thor as CLI Class
* **New connection call** call `awsssh -s SERVER`
* [enh] use a account for connections `awsssh -s SERVER -a ACCOUNT`

**2014-03-04** - v 2.1.0
* [enh] use AWS Ruby SDK
* [enh] use ENV variables to access configurations

**2014-02-27** - v 2.0.1 *the Ronald Fix*
* [code] Code optimization
* [enh] return a error message if config not found

**2014-02-14** - v 2.0.0
* [enh] first gem version

**earlier**
* Some experiences
