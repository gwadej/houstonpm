<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output encoding="utf-8"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="talk|date|abstract|example">
   <div class="{name()}">
     <xsl:apply-templates/>
   </div>
</xsl:template>

<xsl:template match="presenter">
   <div class="presenter"><span class="label">Presenter:</span><xsl:text>
      </xsl:text><xsl:apply-templates/>
   </div>
</xsl:template>

<xsl:template match="topic">
   <div class="topic"><span class="label">Topic:</span><xsl:text>
      </xsl:text>
     <xsl:choose>
       <xsl:when test="@href">
         <a href="{@href}"><xsl:value-of select="title"/></a>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="title"/>
       </xsl:otherwise>
     </xsl:choose>
   </div>
   <xsl:apply-templates/>
</xsl:template>

<!-- already processed -->
<xsl:template match="title"/>

</xsl:stylesheet>
