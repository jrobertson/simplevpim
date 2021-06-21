#!/usr/bin/env ruby

# file: simplevpim.rb

require 'hlt'
require 'nokogiri'
require 'vpim/vcard'
require 'rexle-builder'
require 'kvx'
require 'unichron'


class SimpleVpim

  attr_reader :to_vcard, :to_vevent, :to_xml

  def initialize(s)

    kvx = Kvx.new(s)
    @h = kvx.to_h

    if s.lstrip =~ /# vcard/ and @h[:name] then
      
      @to_vcard = make_vcard @h
      @to_xml = vcard_xml @h      
      
    elsif @h[:title] or @h[:summary]
      
      @to_vevent = make_vevent @h
      @to_xml = vevent_xml kvx.to_xml
      
    end

  end
  
  alias to_vcf to_vcard
  
  def to_hcard(layout=nil)
    make_hcard layout, @h
  end
  
  def to_xcard()
    make_xcard @to_xml    
  end
    
  
  private
  
  def extract_names(name)
    
    a = name.split
    
    if a.length == 2 then
      
      firstname, surname = a[0],nil,a[-1], name
      
    elsif a[0][/^Mrs?|Ms|Miss|Dr/] then

      prefix = a.shift
      
      if a.length == 2 then
        firstname, surname = a[0],nil,a[-1], name
      else
        [*a, a.join(' ')]
      end
      
    else
      [*a, a.join(' ')]
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
      
      firstname, middlename, surname, fullname = extract_names(h[:name])
      
      maker.add_name do |name|
        name.prefix = prefix if prefix
        name.given = firstname
        name.family = surname
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
  
  def make_vevent(h)

    dstart, dend = %i(start end).map do |x|
      Unichron.new(h[x]).to_date.strftime("%Y%m%d")
    end
    
s = "BEGIN:VEVENT
SUMMARY:#{h[:title] || h[:summary]}
DTSTART;VALUE=DATE:#{dstart}
DTEND;VALUE=DATE:#{dend}
"

s += 'LOCATION:' + h[:location] + "\n" if h[:location]
s += 'DESCRIPTION:' + h[:description] + "\n" if h[:description]
s += 'END:VEVENT'

  end

  def make_hcard(raw_s, h)
    
    raw_s ||= %q(
# hcard

img.photo
h1.fn
.email
.n

home:
  .label
  .adr
  .tel

work:
  .label
  .adr
  .tel
)
    
    s = raw_s.split(/\n(?=\w+:?)/).inject('') do |r, x|
      
      x.sub!(/^\s*#\s+.*/,'') # ignore comments
      
      lines = x.lines
      type = lines[0][/^(\w+):/,1]
      
      if type then
        
        lines.shift

        r << lines.map do |line|
          
          if line[/\s*\.\w+/] then
            indent =  line[/^ +/].to_s
            "%s%sspan.type %s" % [line.sub(/^ {2}/,''), indent, type]
          else
            line
          end
          
        end.join("\n") + "\n"
        
      else
        
        r << x + "\n"
      end
      
      r

    end

    html_string = Hlt.new(s).to_html
    html_template = <<EOF
<html>
  <head>
    <link rel="profile" href="http://microformats.org/profile/hcard" />
  </head>
  <body>
    <div class='vcard'>#{html_string}</div>
  </body>
</html>
EOF
    doc = Rexle.new(html_template)
    
    def doc.set(selector, val=nil)
      
      e = self.at_css selector
      return unless e
      block_given? ? yield(e) : e.text = val
      
    end

    firstname, middlename, surname, fullname = extract_names(h[:name])
    doc.set '.fn', fullname
    
    #-- name ---------
    
    e = doc.at_css '.n'
    e.text = 'First Name:'
    fname = Rexle::Element.new('span')
    fname.attributes[:class] = 'given-name'
    fname.text = firstname
    e.add_element fname
    e.add_element Rexle::Element.new('br')
    e.add_text 'Last Name:'
    lname = Rexle::Element.new('span')
    lname.attributes[:class] = 'family-name'
    lname.text = surname
    e.add_element lname
    
    
    
    doc.at_css('.photo').delete unless h[:photo]
    doc.css('.tel').each(&:delete) unless h[:tel]
    doc.css('.adr').each(&:delete) unless h[:adr]
    doc.css('.label').each(&:delete) unless h[:label]
    
    if h[:email].is_a? String then
      
      e = doc.at_css '.email'
      e.text = 'Email:'
      alink = Rexle::Element.new('a')
      alink.attributes[:class] = 'value'
      alink.attributes[:href] = 'mailto:' + h[:email]
      alink.text = h[:email]
      e.add_element alink
      
    elsif h[:email].is_a? Hash then
      
      node = doc.at_css('.email')
     
      h[:email].reverse_each do |k,v|
        e = node.clone
        type = Rexle::Element.new('span')
        type.attributes[:class] = 'type'
        type.text = k.capitalize
        e.add_element type
        e.add_text ' Email:'
        alink = Rexle::Element.new('a')
        alink.attributes[:class] = 'value'
        alink.attributes[:href] = 'mailto:' + v
        alink.text = v
        e.add_element alink      
        
        node.insert_after e
      end
      node.delete

    end
    
    doc.xml pretty: true, declaration: false
    
  end
  
  def make_xcard(xml)
    #lib = File.dirname(__FILE__)
    lib = 'http://a0.jamesrobertson.me.uk/rorb/r/ruby/simplevpim'
    xsl = open(lib + '/xcard.xsl','UserAgent' => 'SimplevPim').read
    doc = Nokogiri::XML(xml)
    xslt  = Nokogiri::XSLT(xsl)
    xslt.transform(doc).to_s    
  end
  
  def vcard_xml(h)

    prefix = h[:prefix]
    suffix = h[:suffix]
    
    firstname, middlename, surname, fullname = extract_names(h[:name])    
    
    xml = RexleBuilder.new
    
    a = xml.vcard do
      
      xml.name do
        
        xml.prefix prefix if prefix
        xml.given firstname
        xml.family surname
        xml.suffix suffix if suffix
        xml.fullname fullname if fullname
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
  
  def vevent_xml(xml)  
    
    doc = Rexle.new(xml)
    doc.root.name = 'vevent'
    doc.root.xml    
    
  end

end
