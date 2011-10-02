require 'rdoc'
require 'rdoc/rdoc'
require 'rdoc/generator'

require 'nokogiri'

class RDoc::Options
  attr_accessor :dictionary_name
end

class Rubydictionary::Generator
  
  RDoc::RDoc.add_generator self
  
  XMLNS = 'http://www.w3.org/1999/xhtml'
  
  XMLNS_D = 'http://www.apple.com/DTDs/DictionaryService-1.0.rng'
  
  def self.setup_options(options)
    opt = options.option_parser
    opt.separator nil
    opt.separator "Dictionary generator options:"
    opt.separator nil
    opt.on('--dictionary-name', 'Name of the dictionary to be created') do |value|
      options.dictionary_name = value
    end
    opt.separator nil

    opt.separator nil
  end
  
  def initialize(options)
    @options = options
    @template_dir = Pathname.new(File.expand_path('../../rdoc/generator/template', __FILE__))
  end
  
  def generate(top_levels)
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send('dictionary', 'xmlns' => XMLNS, 'xmlns:d' => XMLNS_D) do
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        RDoc::TopLevel.all_classes.each do |clazz|
          append_class_entry(clazz, xml)
          clazz.method_list.each do |mthd|
            append_method_entry(mthd, xml)
          end
        end
      end
    end
    
    xml_file = 'Ruby.xml'
    
    puts "Writing into Ruby.xml..."
    File.open(xml_file, 'w') { |f| f << builder.to_xml }
    
    dict_src_path = File.join(Pathname.pwd, xml_file)
    
    css_path = File.join(@template_dir, 'Dictionary.css')
    plist_path = File.join(@template_dir, 'Myinfo.plist')
    
    dict_build_tool = "/Developer/Extras/Dictionary Development Kit/bin/build_dict.sh"
    
    # TODO: read from options
    dictionary_name = 'Ruby'
    
    %x{"#{dict_build_tool}" #{dictionary_name} #{dict_src_path} #{css_path} #{plist_path}}
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
        xml << cls.description
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
  
  # <d:entry id="method_method_id" d:title="method-Name">
  #     <d:index d:value="method full name"/>
  #     <d:index d:value="method name"/>
  #     <h1><a href="x-dictionary:r:class_id:org.ruby-lang.Dictionary">class full name</a> <span class="methodtype"> <%= @method.singleton ? '::' : '#' %> </span> <%= @method.name.escape %> <span class="visibility">(<%= @method.visibility %>)</span></h1>
  #     <% unless @method.arglists.nil? %><p class="signatures"><%= @method.arglists.escape %></p><% end %>
  #     <% unless !@method.respond_to?(:aliases) || @method.aliases.empty? %><p>Aliases: <%= @method.aliases.map {|a| a.new_name }.join(", ").escape %></p><% end %>
  #     <% unless !@method.respond_to?(:is_alias_for) || @method.is_alias_for.nil? %><p>Alias for: <%= @method.is_alias_for.escape %></p><% end %>
  #     <% unless @description.empty? %>
  #     <%= @description %>
  #     <% end %>
  # </d:entry>
  def append_method_entry(mthd, xml)
    xml.entry('id' => method_id(mthd), 'd:title' => method_title(mthd)) do
      xml.index('d:value' => mthd.full_name)
      
      xml.h1(mthd.full_name, :xmlns => XMLNS)
      
      xml.div(:xmlns => XMLNS) do
        xml << mthd.description
      end
    end
  end
  
  def class_id(cls)
    'class_' << cls.object_id.to_s(36)
  end
  
  def class_title(cls)
    cls.full_name
  end
  
  def method_title(mthd)
    # TODO: escape <>
    mthd.name
  end
  
  def method_url(mthd)
    # TODO: org.ruby-lang.Dictionary is a bundle identifier defined in .plist file
    "x-dictionary:r:#{method_id(mthd)}:org.ruby-lang.Dictionary"
  end
  
  def method_id(mthd)
    'method_' << mthd.object_id.to_s(36)
  end
end
