<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:qf="http://www.quickfixj.org" version="2.0">
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="text()"/>

  <xsl:template match="fix/header">
  </xsl:template>

  <xsl:template match="fix/trailer">
  </xsl:template>

  <xsl:template match="fix">{
  "$id": "https://fix.protocol/schemas/messages",

  "type": "object",
   "properties": {
    <xsl:for-each select="/fix/messages/message[@name='QuoteRequest']/field|/fix/messages/message[@name='QuoteRequest']/group|/fix/messages/message[@name='QuoteRequest']/component">
        <xsl:call-template name="object-definition"/>
      <xsl:if test="position() != last()">,
      </xsl:if>
    </xsl:for-each>
  },
  "$defs": {
    <!-- ############ Define fields ############### -->
    <xsl:for-each select="/fix/fields/field"><xsl:call-template name="field-definition"/><xsl:if test="position() != last()"></xsl:if>,
    </xsl:for-each>

    <!-- ############ Define components ############# -->
    <xsl:for-each select="/fix/components/component">
      "<xsl:value-of select="@name"/>": {
        "type": "object",
        "properties": {
          <xsl:for-each select="field|group|component">
              <xsl:call-template name="object-definition"/> 
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each>
        }
      }     
      <xsl:if test="position() != last()">,
      </xsl:if>
    </xsl:for-each>
  }
  
  }
  </xsl:template>


<!--  ############## Object definition ################-->

<xsl:template name="object-definition">
 <xsl:choose>
            <xsl:when test="name()='group'"><xsl:call-template name="group-property"/></xsl:when>
            <xsl:when test="name()='field'">"<xsl:value-of select="@name"/>": {"$ref": "#/$defs/<xsl:value-of select="@name"/>", "position" : <xsl:value-of select="position()"/> }</xsl:when>
            <xsl:when test="name()='component'">"<xsl:value-of select="@name"/>": {"$ref": "#/$defs/<xsl:value-of select="@name"/>", "position" : <xsl:value-of select="position()"/> }</xsl:when>
</xsl:choose>

</xsl:template>

<!-- ######### Group property #############-->
<xsl:template name="group-property">
  "<xsl:value-of select="@name"/>": {
    "type": "array",
    "items": {
        "type": "object",
        "properties": {
        <xsl:for-each select="field|group|component">
          <xsl:call-template name="object-definition"/>
        <xsl:if test="position() != last()">,
        </xsl:if>
        </xsl:for-each>
        }
      }
  }
</xsl:template>


<!-- ########### Field definintion template -->
  <xsl:template name="field-definition">"<xsl:value-of select="@name"/>": { 
    "type": "<xsl:call-template name="get-field-type"/>" 
    <xsl:if test="value">,
    "enum":[<xsl:call-template name="values-enum"/>] ,
    "enumNames":[<xsl:call-template name="values-enumNames"/>] 
    </xsl:if>
    }
    
</xsl:template>

<xsl:template name="get-field-type">
<xsl:choose>
  <xsl:when test="@type='STRING'">string</xsl:when>
  <xsl:when test="@type='CHAR'">string</xsl:when>
  <xsl:when test="@type='PRICE'">number</xsl:when>
  <xsl:when test="@type='INT'">number</xsl:when>
  <xsl:when test="@type='AMT'">number</xsl:when>
  <xsl:when test="@type='QTY'">number</xsl:when>
  <xsl:when test="@type='CURRENCY'">string</xsl:when>
  <xsl:when test="@type='UTCTIMESTAMP'">string</xsl:when>
  <xsl:when test="@type='UTCTIME'">string</xsl:when>
  <xsl:when test="@type='UTCTIMEONLY'">string</xsl:when>
  <xsl:when test="@type='UTCDATE'">string</xsl:when>
  <xsl:when test="@type='UTCDATEONLY'">string</xsl:when>
  <xsl:when test="@type='BOOLEAN'">boolean</xsl:when>
  <xsl:when test="@type='FLOAT'">number</xsl:when>
  <xsl:when test="@type='PRICEOFFSET'">number</xsl:when>
  <xsl:when test="@type='NUMINGROUP'">number</xsl:when>
  <xsl:when test="@type='PERCENTAGE'">number</xsl:when>
  <xsl:when test="@type='SEQNUM'">number</xsl:when>
  <xsl:when test="@type='LENGTH'">number</xsl:when>
  <xsl:when test="@type='COUNTRY'">string</xsl:when>
  <xsl:when test="@type='MULTIPLESTRINGVALUE'">string</xsl:when>
  <xsl:when test="@type='MULTIPLEVALUESTRING'">string</xsl:when>
  <xsl:otherwise>string</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="y-or-n-to-bool">
<xsl:choose>
  <xsl:when test="@enum='Y'">true</xsl:when>
  <xsl:when test="@enum='N'">false</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:function name="qf:sanitiseDescription">
<xsl:param name="text" />
<xsl:if test="contains('0123456789', substring($text, 1, 1))">
  <xsl:text>N_</xsl:text>
</xsl:if>
<xsl:variable name="toReplace">.,+-=:()/&amp;&quot;&apos;&lt;&gt;</xsl:variable>
<xsl:for-each select="tokenize(translate($text,$toReplace,''),' ')">
  <xsl:value-of select="upper-case(substring(.,1,1))" />
  <xsl:value-of select="substring(.,2)" />
</xsl:for-each>
</xsl:function>

<xsl:template name="values-enum">
<xsl:for-each select="value">"<xsl:value-of select="@enum"/>"<xsl:if test =" position() != last()">,</xsl:if></xsl:for-each>
</xsl:template>
<xsl:template name="values-enumNames">
<xsl:for-each select="value">"<xsl:value-of select="@description"/>"<xsl:if test =" position() != last()">,</xsl:if></xsl:for-each>
</xsl:template>
<!--
<xsl:template name="version">fix<xsl:value-of select="//fix/@major"/>
<xsl:value-of select="//fix/@minor"/>
</xsl:template>
-->
</xsl:stylesheet>
