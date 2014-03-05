# AWSSSH

Mit hilfe dieses Gems kann man sich auf alle (bekannten) AWS EC2 Instancen verbinden die man durch seine Configurationen erreichen darf.
Momentan ist das beschränkt auf EC2 Instancen, die durch OpsWorks verwaltet werden.

Da sich die IP und der Public DNS der Server bei jedem Neustart ändern kann fragt dieses Gem immer bei AWS nach der aktuellen IP/DNS Name.

## Installation

Mitlerweile ist aus `awsssh` ein richtiges gem geworden.

1. `gem install awsssh`

### Configurationen
1. Die Konfigurationsdateien müssen unter `/Users/<username>/.aws/` liegen. Wenn dem nicht so ist muss es eine Umgebungsvariable geben, die den Pfad zu den Configurationsdateien beinhaltet: `export ENV['AWSSSH_CONFIG_DIR']=/path/to/configs/`
3. Die Konfigurationsdateien müssen den Namen `aws_config_<kundenname>` haben. Wenn dem nicht so ist muss es eine Umgebungsvariable geben, die den Anfang der Configurationsdateien beinhaltet: `export ENV['AWSSSH_CONFIG_FILE']=awsconf_`

## Aufruf

`awsssh HOST`

**Beispiel**<br>
`awsssh kunde-live-1`

## Hilfe

`awsssh --help`<br>
Zeigt die Hilfe an

## Kontakt

Sebastian Thiele (@sethiele)

## Changelog

**2014-03-04** - v 2.1.1
* [enh] This readme
* [enh] Add a extra parameter to the connection to choose a account. (If this is not clear by the hostname)

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