This gem adds `rubydictionary` formatter to RDoc.

## Prerequisites

You will need latest [*Xcode* developer tools](http://developer.apple.com/).

## Install

    gem install rubydictionary

## Building dictionary

Create documentation from the source code like you normally would. Only do not forget to pass `--format=rubydictionary` option:

    rdoc --format=rubydictionary --dict-name=Sinatra --dict-id=com.sinatrarb.Dictionary ./sourcedir

If all goes well, you should have .dictionary file under ./doc/objects directory. Drop it into `~/Library/Dictionaries/` folder.

# Links

* [Dictionary Services programming guide at Apple Developer site](http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/index.html)
* [https://github.com/breakpointer/ajax-rdoc](https://github.com/breakpointer/ajax-rdoc)