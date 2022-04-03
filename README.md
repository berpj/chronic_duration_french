# Chronic Duration - in french

A simple Ruby natural language parser for elapsed time.

## Usage

    >> require 'chronic_duration_french'
    => true
    >> ChronicDuration.parse('4 minutes et 30 secondes')
    => 270
    >> ChronicDuration.parse('0 secondes')
    => nil
    >> ChronicDuration.parse('0 secondes', :keep_zero => true)
    => 0

Nil is returned if the string can't be parsed

Examples of parse-able strings:

* '12.4 secs'
* '1:20'
* '1:20.51'
* '4:01:01'
* '3 mins 4 sec'
* '2 heures 20 min'
* '2h20min'
* '6 mois 1 jour'
* '47 ans 6 mois et 4j'
* 'deux heures et vingt minutes'
* '3 semaines et 2 jours'

ChronicDuration.raise_exceptions can be set to true to raise exceptions when the string can't be parsed.

    >> ChronicDuration.raise_exceptions = true
    => true
    >> ChronicDuration.parse('4 éléphants et 3 pommes')
    ChronicDuration::DurationParseError: An invalid word "éléphants" was used in the string to be parsed.

## Contributing

Fork and pull request after your specs are green. Add your handle to the list below.
Also looking for additional maintainers.

## Contributors

errm, pdf, brianjlandau, jduff, olauzon, roboman, ianlevesque, bolandrm, berpj
