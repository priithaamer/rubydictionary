This gem adds `rubydictionary` formatter to RDoc.

## Prerequisites

You will need latest [Command Line Tools for Xcode](https://developer.apple.com/downloads/index.action).

### Dictionary Development Kit

Since OS X Mountain Lion, Dictionary Development Kit required to build dictionaries is not included by default with developer tools.

Dictionary Development Kit can be downloaded from [Downloads for Apple Developers](https://developer.apple.com/downloads/index.action) page and it is inside **Auxiliary Tools for Xcode** package. You must copy `Dictionary Development Kit` manually to `/Developer/Extras` folder.

## Install

    gem install rubydictionary

## Building dictionary

Run `rubydictionary` in your source code directory. For example for source of Sinatra:

    rubydictionary --dict-name=Sinatra --dict-id=com.sinatrarb.Dictionary

If everything goes well, you should now have `Sinatra.dictionary` file under `./doc/objects` directory. Drop it into `~/Library/Dictionaries/` folder.

## Authors

See the [Github contributors page](https://github.com/priithaamer/rubydictionary/contributors).

## Links

* [Dictionary Services programming guide at Apple Developer site](http://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/index.html)
* [https://github.com/breakpointer/ajax-rdoc](https://github.com/breakpointer/ajax-rdoc)