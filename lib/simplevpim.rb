#!/usr/bin/env ruby

# file: simplevpim.rb

require 'vpim/vcard'
require 'rexle-builder'
require 'simple-config'


class SimpleVpim

  attr_reader :to_vcard, :to_xml

  def initialize(s)

    h = SimpleConfig.new(s).to_h

    if h[:name] then
      @to_vcard = make_vcard h
      @to_xml = vcard_xml h
    end

  end
  
  alias to_vcf to_vcard
  
  private
  
  def extract_names(name)
    
    a = name.split
    
    if a.length == 2 then
      
      firstname, lastname = a[0],nil,a[-1], name
      
    elsif a[0][/^Mrs?|Ms|Miss|Dr/] then

      prefix = a.shift
      
      if a.length == 2 then
        firstname, lastname = a[0],nil,a[-1], name
      else
        [*a, a.join, ' ']
      end
      
    else
      [*a, a.join, ' ']
    end    
  end
    
  def make_vcard(h)

    card = Vpim::Vcard::Maker.make2 do |maker|
      
      def  maker.add(field_name, value, params={})        
        
        field = Vpim::DirectoryInfo::Field.create field_name, value, params
        add_field field
        
      end

      prefix = h[:prefix]
      suffix = h[:suffix]
      
      firstname, middlename, lastname, fullname = extract_names(h[:name])
      
      maker.add_name do |name|
        name.prefix = prefix if prefix
        name.given = firstname
        name.family = lastname
        name.suffix = suffix if suffix
        name.fullname = fullname if fullname
      end

      # -- email -----------------------------
      
      e = h[:email]
      
      if e then
        
        if e.is_a? String then
          maker.add_email e
        else
          eh = h[:email][:home]
          ew = h[:email][:work]
          maker.add_email(ew) { |e| e.location = 'work' } if ew
          maker.add_email(eh) { |e| e.location = 'home' } if eh
        end
      end
      
      # -- urls ---------------------------------
      
      h[:url] ||= h[:urls]
      
      if h[:url] then
        
        if h[:url].is_a? String then
          maker.add_url h[:url] 
        else
          
          # unfortunately vPim doesn't use a block with the add_url method
          #maker.add_url (h[:url][:work]){|e| e.location = 'work'} if h[:url][:work]
          
          h[:url][:items].each {|url| maker.add_url url }
          
        end
        
      end
      
      # -- photos
      
      maker.add_photo {|photo| photo.link = h[:photo] } if h[:photo]
      
      # -- telephone
      
      tel = h[:tel]
      
      if tel then
      
        if tel.is_a? String then
          
          maker.add_tel tel
          
        else
          th = h[:tel][:home]
          tw = h[:tel][:work]
          maker.add_tel(tw) { |e| e.location = 'work' } if tw
          maker.add_tel(th) { |e| e.location = 'home' } if th
        end
      end
      
      # -- categories ------------      
      maker.add 'CATEGORIES', h[:categories].split(/\s*,\s*/) if h[:categories]
      
      # -- source ------------      
      maker.add 'SOURCE', h[:source] if h[:source]

      # -- Twitter ------------      
      maker.add 'X-TWITTER', h[:twitter] if h[:twitter]
      
      # -- XMPP
      xmpp = h[:jabber] || h[:xmpp]
      maker.add 'X-JABBER', xmpp, 'TYPE' => 'im' if xmpp
      
    end
  end
  
  def vcard_xml(h)

    prefix = h[:prefix]
    suffix = h[:suffix]
    
    firstname, middlename, lastname, fullname = extract_names(h[:name])    
    
    xml = RexleBuilder.new
    
    a = xml.vcard do
      
      xml.name do
        
        xml.prefix = prefix if prefix
        xml.given = firstname
        xml.family = lastname
        xml.suffix = suffix if suffix
        xml.fullname = fullname if fullname
      end
      
      # -- email -----------------------------
      
      e = h[:email]
      
      if e then
        
        if e.is_a? String then
          
          xml.email e
          
        else
          eh = h[:email][:home]
          ew = h[:email][:work]
          xml.email({location: 'work'}, ew) if ew
          xml.email({location: 'home'}, eh) if eh
        end
      end
      
      # -- urls ---------------------------------
      
      h[:url] ||= h[:urls]
      
      if h[:url] then
        
        if h[:url].is_a? String then
          xml.url h[:url] 
        else
          
          # unfortunately vPim doesn't use a block with the add_url method
          #maker.add_url (h[:url][:work]){|e| e.location = 'work'} if h[:url][:work]
          
          h[:url][:items].each {|url| xml.url url }
          
        end
        
      end
      
      # -- photos
      
      xml.photo  link:  h[:photo]  if h[:photo]
      
      # -- telephone
      
      tel = h[:tel]
      
      if tel then
      
        if tel.is_a? String then
          
          xml.tel tel
          
        else
          th = h[:tel][:home]
          tw = h[:tel][:work]
          xml.tel({location: 'work'}, tw) if tw
          xml.tel({location: 'home'}, th) if th
        end
      end
      
      # -- categories ------------      
      xml.categories h[:categories].split(/\s*,\s*/) if h[:categories]
      
      # -- source ------------      
      xml.source h[:source] if h[:source]

      # -- Twitter ------------      
      xml.x_twitter h[:twitter] if h[:twitter]
      
      # -- XMPP
      xmpp = h[:jabber] || h[:xmpp]
      xml.x_jabber({type: 'im'}, xmpp)  if xmpp

    end
    
    Rexle.new(a)
  end

end
