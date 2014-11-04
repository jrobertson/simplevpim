The SimplevPim gem version 0.1.1

This morning I read that the government were adopting the vCard and iCalendar formats as standard. Out of interest I discovered there was a Ruby gem which could generate a vCard, and iCalendar format, however it didn't seem that convenient to use. Which is why I created the SimplevPim gem which is a wrapper for the vPim gem.

e.g.

    require 'simplevpim'

    s = '
    # vcard

    name: James Robertson
    email:
      home: james@jamesrobertson.eu
      work: jrobertsonfunjob@gmail.com
    '

    card = SimpleVpim.new(s).to_vcard
    puts card

<pre>
BEGIN:VCARD
VERSION:3.0
N:Robertson;James;;;
FN:James Robertson
EMAIL;TYPE=work:jrobertsonfunjob@gmail.com
EMAIL;TYPE=home:james@jamesrobertson.eu
END:VCARD
</pre>

I only just wrote the gem today, however it has potential to be a convenient tool for anyone wanting to generate their own vCard.

## Resources

* ?simplevpim https://rubygems.org/gems/simplevpim?
* ?vCard Maker - Free electronic business card generator http://vcardmaker.com/?
* ?sam-github/vpim https://github.com/sam-github/vpim?
* ?vCard https://en.wikipedia.org/wiki/VCard?
* ?vCard and iCalendar are now government open standards https://governmenttechnology.blog.gov.uk/2014/10/31/vcard-and-icalendar-are-now-government-open-standards-2/?

simplevpim gem vpim vcard
