<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0">
  <!-- xpath-default-namespace slmt en XSLT2.0 -->
  
  <xsl:output indent="yes" method="xml" encoding="UTF-8" />
  
  <!-- choix du préfixe -->
  <xsl:param name="prefix" select="'gdpBrice1784'" />
  <xsl:param name="foliotation" select="'pageNum'" />
  <!--<xsl:param name="foliotation" select="'pageNum'" />-->
  
  <!-- Copie à l'identique du fichier -->
  <xsl:strip-space elements="*" />
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  
  <!-- numérotation des pb -->
  <xsl:template match="pb">
    <xsl:variable name="num">
      <xsl:number level="any" />
    </xsl:variable>
    <xsl:variable name="autoNum">
      <xsl:choose>
        <xsl:when test="($foliotation='foliotation') and ($num mod 2 != 1)">
          <xsl:sequence
            select="concat( format-number($num  div 2, '0') , 'v' )" />
        </xsl:when>
        <xsl:when test="($foliotation='foliotation') and ($num mod 2 = 1)">
          <xsl:sequence select="format-number( ($num + 1 ) div 2 , '0' ) " />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="format-number( $num, '0' )" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="($foliotation='foliotation')">
            <xsl:sequence
              select="concat( $prefix , 'Fol' , $autoNum )" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="concat( $prefix, 'P' , $autoNum )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
  
  <!-- Copie à l'identique du fichier (toutes les passes) -->
  <xsl:template match="node()|@*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="#current" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>