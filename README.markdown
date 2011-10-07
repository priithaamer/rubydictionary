This gem adds `rubydictionary` formatter to RDoc.

## Prerequisites

You will need latest [*Xcode* developer tools](http://developer.apple.com/).

## Install

    gem install rubydictionary

## Building dictionary

Run `rubydictionary` in your source code directory. For example for source of Sinatra:

    rubydictionary --dict-name=Sinatra --dict-id=com.sinatrarb.Dictionary

If all goes well, you should now have `Sinatra.dictionary` file under `./doc/objects` directory. Drop it into `~/Library/Dictionaries/` folder.

## Authors

See the [Github contributors page](https://github.com/priithaamer/rubydictionary/contributors).

## Links

* [Dictionary Services programming guide at Apple Developer site](http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/index.html)
* [https://github.com/breakpointer/ajax-rdoc](https://github.com/breakpointer/ajax-rdoc)