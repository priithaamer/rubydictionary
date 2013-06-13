require 'erb'
require 'rdoc'
require 'rdoc/rdoc'
require 'rdoc/generator'

require 'nokogiri'

class RDoc::Options
  attr_accessor :dictionary_name
  
  attr_accessor :dictionary_identifier
  
  attr_accessor :kit_path
end

class RDoc::Generator::Dictionary
  
  RDoc::RDoc.add_generator self
  
  XMLNS = 'http://www.w3.org/1999/xhtml'
  
  XMLNS_D = 'http://www.apple.com/DTDs/DictionaryService-1.0.rng'

  # TODO: Raise an error when dictionary name is missing
  def self.setup_options(options)
    opt = options.option_parser
    opt.separator "Dictionary generator options:"
    opt.separator nil
    opt.on('--dict-name=NAME', 'Title that appears in Dictionary.app') do |value|
      options.dictionary_name = value
    end
    opt.on('--dict-id=IDENTIFIER', 'Dictionary bundle identifier, such as', 'org.rubyonrails.Rails') do |value|
      options.dictionary_identifier = value
    end
    opt.on('--kit-path=DICTIONARY_KIT_PATH', 'Full path to Dictionary Development Kit') do |value|
      options.kit_path = value
    end
    opt.separator nil
  end
  
  def initialize(options)
    @options = options
    @template_dir = Pathname.new(File.expand_path('../../rdoc/generator/template', __FILE__))
    
    # Keep the track of methods and classes already rendered and avoid duplication
    @class_ids = []
    @method_ids = []
  end
  
  def generate(top_levels)
    builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
      xml.send('dictionary', 'xmlns' => XMLNS, 'xmlns:d' => XMLNS_D) do
        xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D)
        
        RDoc::TopLevel.all_classes_and_modules.each do |clazz|
          unless @class_ids.include?(class_id(clazz))
            append_class_entry(clazz, xml)
            @class_ids << class_id(clazz)
            
            clazz.method_list.each do |mthd|
              unless @method_ids.include?(method_id(mthd))
                append_method_entry(mthd, xml)
                @method_ids << method_id(mthd)
              end
            end
          end
        end
      end
    end
    
    xml_file = 'Dictionary.xml'
    
    File.open(File.join(Pathname.pwd, xml_file), 'w') { |f| f << builder.to_xml }
    
    dict_src_path = File.join(Pathname.pwd, xml_file)
    
    css_path = File.join(@template_dir, 'Dictionary.css')
    File.open(File.join(Pathname.pwd, 'Dictionary.plist'), 'w') { |f| f.write render_plist(@options.dictionary_name, bundle_identifier) }
    
    plist_path = File.join(Pathname.pwd, 'Dictionary.plist')
    
    dict_build_tool = File.join((@options.kit_path || '/Developer/Extras/Dictionary Development Kit'), 'bin', 'build_dict.sh')
    
    %x{"#{dict_build_tool}" "#{@options.dictionary_name}" #{dict_src_path} #{css_path} #{plist_path}}
  end
  
  def file_dir
    ''
  end
  
  def class_dir
    'classes'
  end
  
  private
  
  def append_class_entry(cls, xml)
    xml.entry('id' => class_id(cls), 'd:title' => class_title(cls)) do
      xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D)
      xml.index('d:value' => cls.full_name) { xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D) }
      
      xml.h1(cls.full_name, :xmlns => XMLNS)
      
      xml.div(:xmlns => XMLNS) do
        xml << strip_pre_markup(cls.description)
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
  
  def append_method_entry(mthd, xml)
    xml.entry('id' => method_id(mthd), 'd:title' => method_title(mthd)) do
      xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D)
      
      xml.index('d:value' => mthd.full_name) { xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D) }
      xml.index('d:value' => mthd.name) { xml.parent.namespace = xml.parent.add_namespace_definition('d', XMLNS_D) }
      
      xml.h1(mthd.arglists, :xmlns => XMLNS)
      
      xml.p(mthd.full_name, :class => 'method_name', :xmlns => XMLNS)
      
      xml.div(:xmlns => XMLNS) do
        xml << strip_pre_markup(mthd.description)
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
    mthd.name
  end
  
  def method_url(mthd)
    "x-dictionary:r:#{method_id(mthd)}:#{bundle_identifier}"
  end
  
  def method_id(mthd)
    'method_' << mthd.object_id.to_s(36)
  end
  
  # Strips ruby markup span elements generated by RDoc
  def strip_pre_markup(content)
    content.gsub!(/<pre class="ruby">.*?<\/pre>/m) do |m|
      '<pre>' + m.gsub(/<\/?[^>]*>/, '') + '</pre>'
    end
  end
  
  def bundle_identifier
    @options.dictionary_identifier
  end
  
  # Render .plist file from erb template
  def render_plist(bundle_name, bundle_identifier)
    ERB.new(File.read(File.join(@template_dir, 'Dictionary.plist.erb'))).result(binding)
  end
end
