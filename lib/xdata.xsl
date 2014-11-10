<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>
  <xsl:output method='xml' indent='yes'/>


  <xsl:template match='vcard'>
    <xsl:element name='vcards'>
    <xsl:attribute name='xmlns'>urn:ietf:params:xml:ns:vcard-4.0</xsl:attribute>
    <xsl:element name='vcard'>
  
    <xsl:apply-templates select='name' />
    <xsl:apply-templates select='email' />
    </xsl:element>
    </xsl:element>

  </xsl:template>

  <xsl:template match='name'>
    <xsl:element name='fn'>
      <xsl:element name='text'><xsl:value-of select='fullname'/></xsl:element></xsl:element>
    <xsl:element name='n'>
      <xsl:element name="surname"><xsl:value-of select='family' /></xsl:element>
      <xsl:element name="given"><xsl:value-of select='given' /></xsl:element>
      <xsl:element name="additional"><xsl:value-of select='middlename' /></xsl:element> 
      <xsl:element name="prefix"><xsl:value-of select='prefix' /></xsl:element>
      <xsl:element name="suffix"><xsl:value-of select='suffix' /></xsl:element>
    </xsl:element>

  </xsl:template>


  <xsl:template match='email'>

    <xsl:element name='email'>
      <xsl:element name="parameters">
      <xsl:element name='type'>
        <xsl:element name='text'>
        <xsl:value-of select='@location'/>
        </xsl:element>
      </xsl:element>
      </xsl:element>
      <xsl:element name='text'>
        <xsl:value-of select='.' />
      </xsl:element>
      
    </xsl:element>

  </xsl:template>

</xsl:stylesheet>