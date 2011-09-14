require 'rdoc'
require 'rdoc/rdoc'
require 'rdoc/generator'

require 'nokogiri'

class Rubydictionary::Generator
  
  RDoc::RDoc.add_generator self
  
  XMLNS = 'http://www.w3.org/1999/xhtml'
  
  XMLNS_D = 'http://www.apple.com/DTDs/DictionaryService-1.0.rng'
  
  def self.setup_options(options)
  end
  
  def initialize(options)
  end
  
  def generate(top_levels)
    
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send('dictionary', 'xmlns' => XMLNS, 'xmlns:d' => XMLNS_D) do
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        RDoc::TopLevel.all_classes.each do |clazz|
          append_class_entry(clazz, xml)
        end
      end
    end
    
    puts "Writing into Ruby.xml..."
    File.open('Ruby.xml', 'w') { |f| f << builder.to_xml }
  end
  
  def class_dir
    'classes'
  end
  
  private
  
  # <d:entry id="activerecord_base" d:title="ActiveRecord::Base">
  #     <d:index d:value="ActiveRecord::Base"/>
  #     <d:index d:value="Base"/>
  #     <h1>ActiveRecord::Base</h1>
  def append_class_entry(cls, xml)
    xml.entry('id' => class_id(cls), 'd:title' => class_title(cls)) do
      xml.index('d:value' => cls.full_name)
      # xml.index('d:value' => class_index_name(clazz))
      
      xml.h1(cls.full_name, :xmlns => XMLNS)
      
      xml.div(:xmlns => XMLNS) do
        xml.cdata cls.description
      end

      # Link to class methods
      unless cls.class_method_list.empty?
        xml.h3('Class methods', :xmlns => XMLNS)
        xml.ul(:xmlns => XMLNS) do
          cls.class_method_list.each do |mthd|
            xml.li(:xmlns => XMLNS) do
              xml.a(mthd.name, :href => method_url(mthd), :xmlns => XMLNS)
            end
          end
        end
      end
      
      # Link to instance methods
      unless cls.instance_method_list.empty?
        xml.h3('Instance methods', :xmlns => XMLNS)
        xml.ul(:xmlns => XMLNS) do
          cls.instance_method_list.each do |mthd|
            xml.li(:xmlns => XMLNS) do
              xml.a(mthd.name, :href => method_url(mthd), :xmlns => XMLNS)
            end
          end
        end
      end
    end
  end
  
  def class_id(cls)
    cls.full_name.downcase.gsub('::', '_')
  end
  
  def class_title(cls)
    cls.full_name
  end
  
  def method_url(mthd)
    "x-dictionary:r:method_#{method_id(mthd)}:org.ruby-lang.Dictionary"
  end
  
  def method_id(mthd)
    mthd.name
  end
end
