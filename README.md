# Creating an event using the SimpleVpim gem


    require 'simplevpim'

    s = '
    # vevent

    title: Book Festival
    start: 15 Aug
    end:   17 Aug
    location: Edinburgh
    description: Refreshments included
    '

    card = SimpleVpim.new(s).to_vevent
    puts card

Output:

<pre>
BEGIN:VEVENT
SUMMARY:Book Festival
DTSTART;VALUE=DATE:20210815
DTEND;VALUE=DATE:20210817
LOCATION:Edinburgh
DESCRIPTION:Refreshments included
END:VEVENT
</pre>

simplevpim event calendar vevent

# The SimplevPim gem version 0.1.2

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

*update: 04-Nov-2014 @ 21:02*

The gem can now handle a single URL or multiple URLs:

e.g.

    require 'simplevpim'
    
    s = '
    # vcard

    name: James Robertson
    email:
      home: james@jamesrobertson.eu
      work: jrobertsonfunjob@gmail.com
    url:  http://www.jamesrobertson.eu/
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
URL:http://www.jamesrobertson.eu/
END:VCARD
</pre>

    require 'simplevpim'

    s = '
    # vcard

    name: James Robertson
    email:
      home: james@jamesrobertson.eu
      work: jrobertsonfunjob@gmail.com
    url:
      http://www.jamesrobertson.eu/
      https://github.com/jrobertson/
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
URL:http://www.jamesrobertson.eu/
URL:https://github.com/jrobertson/
END:VCARD
</pre>

## Resources

* ?simplevpim https://rubygems.org/gems/simplevpim?
* ?vCard Maker - Free electronic business card generator http://vcardmaker.com/?
* ?sam-github/vpim https://github.com/sam-github/vpim?
* ?vCard https://en.wikipedia.org/wiki/VCard?
* ?vCard and iCalendar are now government open standards https://governmenttechnology.blog.gov.uk/2014/10/31/vcard-and-icalendar-are-now-government-open-standards-2/?

simplevpim gem vpim vcard
