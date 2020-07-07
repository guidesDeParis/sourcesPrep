<?xml version="1.0" encoding="UTF-8"?>
<!--
    @title generateIndex.xsl
    @autor emchateau
    @version 001
    @since 2019-10
    @todo deal with notes, label, figures, bibl
-->
<xsl:stylesheet 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output indent="yes" method="xml" encoding="UTF-8" />
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="tei:abbr | tei:bibl | tei:date | tei:emph | tei:expan | tei:foreign | tei:geo | tei:geoName | tei:hi | tei:item | tei:lg | tei:l | tei:list | tei:objectName | tei:orgName | tei:persName | tei:placeName | tei:q | tei:quote | tei:ref | tei:rs | tei:seg | tei:sic | tei:soCalled | tei:supplied | tei:title | tei:unclear">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="tei:fw"/>
  <xsl:template match="tei:figure"/>
  <xsl:template match="tei:gap"/>
  <xsl:template match="tei:graphic"/>
  <xsl:template match="tei:label"/>
  <xsl:template match="tei:lb"/>
  <xsl:template match="tei:pb"/>
  <xsl:template match="tei:metamark"/>
  <xsl:template match="tei:note"/>
  <xsl:template match="tei:num"/>
  <xsl:template match="tei:space"/>
  <xsl:template match="tei:surplus"/>
  
  
  <!-- Copie à l’identique -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>