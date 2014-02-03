# AWSSSH

Im [Mitarbeiterhandbuch](https://employeeapps.infopark.de/manual/03_Security) sind SSH-Configurationen vorgegeben, mit denen man alle AWS-EC2s abfängt.
Da ich aber nicht jedesmal nachschauen will, wie der Public-DNS Name einer instance ist, will ich das weiterhin in meiner ssh config pflegen und habe dort einträge wie:

```Host sihl-live1
  Hostname ec2-54-194-243-71.eu-west-1.compute.amazonaws.com```

da ein Aufruf von `$ ssh sihl-live1` dann aber die einstellung ignoriert der umweg über dieses script.

## Installation

1. Herunterladen
2. an die Stelle verschieben, an der es am ende liegen soll
3. wenn bei 2. nicht /usr/* angegeben ist `rake install` ausführen. Das erstellt ein Link in `/usr/local/bin`

_Erstelle dir bitte eine Umgebunsvariable mit Namen `AWS_SSH_CONFIG_PATH` die den Pfad zu deiner config.yml-Datei enthält._

Beispiel:<br>
`export AWS_SSH_CONFIG_PATH=~/Projekte/support/scripte/ruby/awsssh/config.yml`

## Aufruf

`awsssh HOST`

**Beispiel**<br>
`awsssh sihl-live1`

## Inhalte

`Gemfile`: zum installieren aller benötigten gems<br>
`README.md`: diese README<br>
`Rakefile`: für die installation<br>
`awsssh.rb`: Erstellt die verbidnung (Programmlogik)<br>
`config.yml`: Verbindung Projekt <-> Stack

## Kontakt

Sebastian Thiele <[mailto:sebastian.thiele@infopark.de]>
