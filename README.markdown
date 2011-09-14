This gem adds `rubydictionary` formatter to RDoc.

## Prerequisites

You will need latest [*Xcode* developer tools](http://developer.apple.com/).

## Install

    gem install rubydictionary

## Building dictionary

Create documentation from the source code like you normally would. Only do not forget to pass `--format=rubydictionary` option:

    rdoc --format=rubydictionary ./sourcedir

If all goes well, you should have .dictionary file under ./doc directory. Drop it into `~/Library/Dictionaries/` folder.

## TODO

* Set RDoc options from command line:
** Dictionary name
** Dictionary title (optional, name is default)
* Dictinary builder script:
** Store RDoc results into xml file (into doc/ directory)
** Prepare .plist file

# Links

* [Dictionary Services programming guide at Apple Developer site](http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/index.html)
