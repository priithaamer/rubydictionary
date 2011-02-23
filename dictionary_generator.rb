#!/usr/bin/env ruby

require 'erb'
require 'rubygems'
require 'iconv'

gem 'rdoc', '>= 0'
require 'rdoc/ri'
require 'rdoc/ri/store'
require 'rdoc/ri/paths'
require 'rdoc/markup'
require 'rdoc/markup/formatter'
require 'rdoc/text'

class RDoc::Markup::ToHtml < RDoc::Markup::Formatter
  def self.gen_relative_url(path, target)
    nil
  end
end

class String
  def escape
    gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("'", "&apos;").gsub("\"", "&quot;")
  end
  def to_id
    downcase.gsub('::', '_')
  end
end

def get_template(file)
  erb = ''
  File.open("./templates/#{file}", 'r') { |f| erb = f.read }
  ERB.new(erb)
end

class_template = get_template('class.erb')

def render_class(klass)
  tpl = get_template('class.erb')
  @class = klass
  @class_methods = klass.method_list.reject{ |m| !m.singleton }.sort{ |a,b| a.name <=> b.name }
  @instance_methods = klass.method_list.reject{ |m| m.singleton }.sort{ |a,b| a.name <=> b.name }
  begin
    @description = @iconv.iconv(klass.comment.accept(@formatter))
  rescue
    @description = ""
  end
  tpl.result(binding)
end

def render_class_method(klass, method)
  tpl = get_template('method.erb')
  @klass = klass
  @method = method
  begin
    @description = @iconv.iconv(method.comment.accept(@formatter))
  rescue
    @description = ""
  end
  tpl.result(binding)
end

puts "Loading Ruby documentation"

classes = {}
class_methods    = {}
instance_methods = {}
stores = []
class_count = 0
count = 0

@formatter = RDoc::Markup::ToHtml.new
@iconv = Iconv.new('UTF-8//IGNORE', 'UTF-8')

RDoc::RI::Paths.each(true, true, true, true) do |path, type|
  $stderr.puts path
  store = RDoc::RI::Store.new(path, type)
  store.load_cache
  stores << store
  class_count += store.modules.count
end

stores.each do |store|
  store.modules.each do |name|
    count += 1
    $stderr << "Parse [#{count}/#{class_count}]...\r"
    klass = store.load_class(name)
    oldklass = classes[name]
    unless oldklass.nil? || oldklass.method_list.count < klass.method_list.count
      $stderr.puts "Skipping #{name}..."
      next
    end
    classes[name] = klass
    klass.method_list.each_index do |index|
      method = klass.method_list[index]
      begin
        method = store.load_method(name, "#{method.singleton ? '::' : '#'}#{method.name}")
        klass.method_list[index] = method
      rescue Errno::ENOENT => e
        $stderr.puts e
      end
    end
  end
end

puts "Building XML files from sources"

@classes = []
@methods = []
count = 0

classes.each do |name, klass|
  count += 1
  $stderr << "Render [#{count}/#{class_count}]...\r"
  @classes << render_class(klass)
  klass.method_list.each { |method| @methods << render_class_method(klass, method) }
end

File.open('./Ruby.xml', 'w') { |file| file.puts get_template('dictionary.erb').result(binding) }

puts "Dictionary XML file generation complete"
