<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="talks2html.xsl"/>

<xsl:output encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="talklist">
   <xsl:for-each select="talk">
     <xsl:sort select="@num" order="descending"/>
     <xsl:if test="position() &lt; 4">
        <div class="talk">
          <xsl:apply-templates match="talk"/>
        </div><xsl:text>
    </xsl:text>
     </xsl:if>
   </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
