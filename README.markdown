This directory contains the necessary scripts to generate Mac OSX Dictionary from Ruby 1.8 documentation.

## Building dictionary

Run Ruby script included in this package to generate xml file that will be used to generate dictionary.

Generator will look for the Ruby documentation files from ``/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/share/ri/1.8/system``. Feel free to change the path in the ruby script.

    ruby ./dictionary_generator.rb

Build dictionary contents from generated xml file

    make all

Install dictionary to your ``~/Library/Dictionaries`` directory

    make install
