This is a fork of great Priit Haamer's [Ruby Dictionary](https://github.com/priithaamer/rubydictionary). This version uses new *RDoc* format and generates complete documentation also for all installed gems.

This project contains the necessary scripts to generate [*Mac OS X* dictionary bundle](http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/index.html) from your [Ruby 1.8](http://www.ruby-lang.org) documentation.

## Prerequisites

You will need latest [*Xcode* developer tools](http://developer.apple.com/).

## Building dictionary

Convert *RI* documentation for *Ruby* core and all installed gems into dictionary source XML using:

    ./dictionary_generator.rb

Build dictionary bundle using:

    make all

Install dictionary bundle into your home folder `~/Library/Dictionaries` directory:

    make install
