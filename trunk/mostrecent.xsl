<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="talklist">
   <xsl:for-each select="talk">
     <xsl:sort select="@num" order="descending"/>
     <xsl:if test="position() = 1">
        <xsl:call-template name="refresh"/>
     </xsl:if>
   </xsl:for-each>
</xsl:template>

<xsl:template name="refresh">
  <xsl:choose>
    <xsl:when test="@href">
  <meta http-equiv="refresh" content="0; url={@href}" />
    </xsl:when>
    <xsl:when test="topic/@href">
  <meta http-equiv="refresh" content="0; url={topic/@href}" />
    </xsl:when>
    <xsl:otherwise>
  <meta http-equiv="refresh" content="0; url=/talks/index.html" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
