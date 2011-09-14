require 'rdoc'
require 'rdoc/rdoc'
require 'rdoc/generator'

require 'nokogiri'

class Rubydictionary::Generator
  
  RDoc::RDoc.add_generator self
  
  def self.setup_options(options)
  end
  
  def initialize(options)
  end
  
  def generate(top_levels)
    
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send('dictionary', 'xmlns' => 'http://www.w3.org/1999/xhtml', 'xmlns:d' => 'http://www.apple.com/DTDs/DictionaryService-1.0.rng') do
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        RDoc::TopLevel.all_classes.first(5).each do |clazz|
          append_class_entry(clazz, xml)
        end
      end
    end
    
    puts builder.to_xml
  end
  
  def class_dir
    'classes'
  end
  
  private
  
  def append_class_entry(clazz, xml)
    xml.entry('id' => class_id(clazz), 'd:title' => class_title(clazz)) do
      xml.index('d:value' => class_index_fullname(clazz))
      xml.index('d:value' => class_index_name(clazz))
      
      xml.h1(clazz.definition, :xmlns => 'http://www.w3.org/1999/xhtml')
      
      xml.div(:xmlns => 'http://www.w3.org/1999/xhtml') do
        xml.cdata clazz.description
      end
    end
  end
  
  def class_id(clazz)
    'foobar'
  end
  
  def class_title(clazz)
    'Title'
  end
  
  def class_index_fullname(clazz)
    'fullname'
  end
  
  def class_index_name(clazz)
    'name'
  end
end
