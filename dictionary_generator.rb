require 'erb'
require 'rubygems'
require 'rdoc/rdoc'
require 'rdoc/generators/ri_generator'

@indent = ''

def get_template(file)
  erb = ''
  File.open("./templates/#{file}", 'r') { |f| erb = f.read }
  ERB.new(erb)
end

def object_id(obj)
  obj.full_name.downcase.gsub('::', '_')
end

def method_id(mthd)
  mthd.full_name.gsub('::', '_').gsub('#', '-').gsub('<', '-lt-').gsub('&', '-amp-')
end

class_template = get_template('class.erb')

def render_class(cls)
  tpl = get_template('class.erb')
  @class = cls
  @description = @reader.get_class(cls)
  tpl.result(binding)
end

def render_method(mthd)
  tpl = get_template('method.erb')
  @method = mthd
  @description = @reader.get_method(mthd)
  tpl.result(binding)
end

def render_comment(item, prefix = @indent)
  case item
  when Array
    item.collect{ |c| render_comment(c) }.join
  when SM::Flow::P
    "<p>#{item.body}</p>"
  when SM::Flow::LI
    "<li>#{item.body}</li>"
  when SM::Flow::LIST
    render_list(item)
  when SM::Flow::VERB
    "<pre>#{item.body}</pre>"
  when SM::Flow::H
    "<h#{item.level}>#{item.text}</h#{item.level}>"
  when SM::Flow::RULE
    "<hr/>"
  else
  end
end

def render_list(list)
  case list.type
  when SM::ListBase::BULLET 
    prefixer = proc { |ignored| @indent + "*   " }

  when SM::ListBase::NUMBER, SM::ListBase::UPPERALPHA, SM::ListBase::LOWERALPHA

    start = case list.type
            when SM::ListBase::NUMBER      then 1
            when  SM::ListBase::UPPERALPHA then 'A'
            when SM::ListBase::LOWERALPHA  then 'a'
            end
    prefixer = proc do |ignored|
      res = @indent + "#{start}.".ljust(4)
      start = start.succ
      res
    end
    
  when SM::ListBase::LABELED
    prefixer = proc do |li|
      li.label
    end

  when SM::ListBase::NOTE
    longest = 0
    list.contents.each do |item|
      if item.kind_of?(SM::Flow::LI) && item.label.length > longest
        longest = item.label.length
      end
    end

    prefixer = proc do |li|
      @indent + li.label.ljust(longest+1)
    end

  else
  end

  out = '<ul>'
  list.contents.each do |item|
    if item.kind_of? SM::Flow::LI
      prefix = prefixer.call(item)
      out << render_comment(item)
    else
      out << render_comment(item)
    end
  end
  out << '</ul>'
  out
end

puts "Building XML files from sources"

cache = RI::RiCache.new('/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/share/ri/1.8/system')

@reader = RI::RiReader.new(cache)
@classes = Array.new
@methods = Array.new

def find_all_classes(parent)
  parent.each do |com|
    @classes << render_class(com)
    com.methods_matching('', nil).each do |mthd|
      @methods << render_method(mthd)
    end
    find_all_classes(com.classes_and_modules)
  end
end

find_all_classes(cache.toplevel.classes_and_modules)
File.open('./Ruby.xml', 'w') { |file| file.puts get_template('dictionary.erb').result(binding) }

puts "Dictionary XML file generation complete"
