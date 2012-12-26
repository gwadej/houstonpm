<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="talks2html.xsl"/>

<xsl:param name="year2" select='05'/>

<xsl:output encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="talklist">
   <xsl:for-each select="talk">
     <xsl:sort select="@num" order="ascending"/>
     <xsl:if test="starts-with( @num, $year2 ) or starts-with( @num, concat( '0', $year2 ) )">
        <div class="talk">
          <xsl:apply-templates match="talk"/>
        </div><xsl:text>
    </xsl:text>
     </xsl:if>
   </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
