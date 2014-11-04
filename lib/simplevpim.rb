#!/usr/bin/env ruby

# file: simplevpim.rb

require 'vpim/vcard'
require 'simple-config'


class SimpleVpim

  attr_reader :to_vcard

  def initialize(s)

    h = SimpleConfig.new(s).to_h

    if h[:name] then
      @to_vcard = make_vcard h
    end

  end

  private

  def make_vcard(h)

    prefix = h[:prefix]
    suffix = h[:suffix]
    a = h[:name].split

    if a.length == 2 then
      firstname, lastname = a 
    elsif a[0][/^Mrs?|Ms|Miss|Dr/] then

      prefix = a.shift
      
      if a.length == 2 then
        firstname, lastname = a 
      else
        firstname, middlename, lastname = a
        fullname = a.join ' '
      end
    else
      firstname, middlename, lastname = a
      fullname = a.join ' '
    end

    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.prefix = prefix if prefix
        name.given = firstname
        name.family = lastname
        name.suffix = suffix if suffix
        name.fullname = fullname if fullname
      end

      e = h[:email]
      eh = h[:email][:home]
      ew = h[:email][:work]
      maker.add_email(ew) { |e| e.location = 'work' } if ew
      maker.add_email(eh) { |e| e.location = 'home' } if eh
      
      if h[:url] then
        
        if h[:url].is_a? String then
          maker.add_url h[:url] 
        else
          
          # unfortunately vPim doesn't use a block with the add_url method
          #maker.add_url (h[:url][:work]){|e| e.location = 'work'} if h[:url][:work]
          h[:url][:items].each {|url| maker.add_url url }
          
        end
        
      end
    end
  end

end
