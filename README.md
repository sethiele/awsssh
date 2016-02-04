# AWSSSH

[![Gem Version](https://badge.fury.io/rb/awsssh.png)](http://badge.fury.io/rb/awsssh)

Mit hilfe dieses Gems kann man sich auf alle (bekannten) AWS EC2 Instancen verbinden die man durch seine Configurationen erreichen darf.
Momentan ist das beschränkt auf EC2 Instancen, die durch OpsWorks verwaltet werden.

Da sich die IP und der Public DNS der Server bei jedem Neustart ändern kann fragt dieses Gem immer bei AWS nach der aktuellen IP/DNS Name.

## Installation

Mitlerweile ist aus `awsssh` ein richtiges gem geworden.

1. `gem install awsssh`

### Configurationen
* Es muss die Variable `AWS_CREDENTIAL_FILE` auf das Credentialfile gesetzt sein.
* In der Datei müssen die Zugangsdaten in der folgenden Form enthalten sein:
```
[PROFILE-1]
aws_access_key_id=VALUE
aws_secret_access_key=VALUE
[PROFILE-n]
aws_access_key_id=VALUE
aws_secret_access_key=VALUE
```

## Aufruf

### Mit Server verbinden

Wenn der Profilname im Hostname enthalten ist:<br>
`awsssh HOSTNAME`

**Beispiel**<br>
`awsssh profile-live-1`

Wenn der Profilname nicht im Hostname enthalten ist:<br>
`awsssh HOSTNAME --profile PROFILE`

**Beispiel**<br>
`awsssh live-1 --profile KundeXY`

### Liste aller Profile
`awsssh list_profiles`

### Liste aller Server für ein Profil
`awsssh list_server PROFIL`

### Hilfe
`awsssh help`

### Version
`awsssh version`

## Kontakt

Sebastian Thiele Twitter: (@sebat)

## Changelog
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
