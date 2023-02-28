<?xml version="1.0" encoding="UTF-8"?>
<!--
    @title generateIndex.xsl
    @autor emchateau
    @version 001
    @since 2019-10
    @todo deal with notes, label, figures, bibl
-->
<xsl:stylesheet 
  xmlns="http://www.tei-c.org/ns/1.0" 
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:f="perso/functions"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="f fn xs"
  version="3.0" expand-text="true">
  
  <!-- @todo produire un résultat TEI valide -->
  
  <xsl:output indent="yes" method="xml" encoding="UTF-8" />
  <xsl:strip-space elements="*"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="allPersons" select="//person"/>
  <xsl:variable name="allPlaces" select="//place"/>
  <xsl:variable name="allObjects" select="//object"/>
  
  <xsl:template match="div|front|body|back|text">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <metadata n="{@xml:id}">
        <title>
          <xsl:call-template name="getTitle">
            <xsl:with-param name="item" select="."/>
          </xsl:call-template></title>
        <textId><xsl:sequence select="f:getTextIdWithRegex(.)"/></textId>
        <pages><xsl:sequence select="f:pages(.)"/></pages>
        <indexes><xsl:sequence select="f:getIndexEntries(.)"/></indexes>
        <size><xsl:sequence select="f:getWordsCount(.)"/></size>
      </metadata>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="getTitle">
    <xsl:param name="item"/>
    <xsl:choose>
      <xsl:when test="$item/label">
        <xsl:apply-templates select="$item/label" mode="title"/>
      </xsl:when>
      <xsl:when test="$item[not(head)]/p/label">
        <xsl:apply-templates select="$item/*/label" mode="title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$item/head" mode="title" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="persName | objectName | orgName | geogName | placeName | date | lb | expan | abbr | soCalled | ref | sic | seg | bibl | pb " mode="title">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="@rend[.='capital' or 'bigger' or 'initial' or 'alignCenter']" mode="title"/>
  <xsl:template match="@n | @resp | @xml:lang[.='fr']" mode="title"/>
  <xsl:template match="hi[@rend='capital' or 'bigger' or 'initial' or 'alignCenter']" mode="title">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="@type[.='main' or 'sup']" mode="title"/>
  
  <!-- @todo récupérer le contenu des notes pour la recherche -->
  <xsl:template match="note" mode="title"/>
  <xsl:template match="supplied" mode="title">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="./node()"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="title">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="title"/>
      <xsl:apply-templates mode="title"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:function name="f:pages" as="element()*">
    <xsl:param name="item" as="element()"/>
    <xsl:variable name="f:pageBefore" select="$item/preceding::fw[@type = 'pageNum'][1]"/>
    <xsl:variable name="f:fw" select="$item//fw[@type = 'pageNum']"/>
    <xsl:sequence>
      <prefix>{if ($f:fw) then 'pp.' else 'p.'}</prefix>
      <range>{fn:string-join(($f:pageBefore, $f:fw[fn:last()]), '–')}</range>
    </xsl:sequence>
  </xsl:function>
  
  <xsl:function name="f:getIndexEntries" as="element()*">
    <xsl:param name="item" as="element()"/>
    <xsl:variable name="f:personsRefs" select="$item//persName/@xml:id union $item//orgName/@xml:id"/>
    <xsl:variable name="f:placesRefs" select="$item//placeName/@xml:id union $item//geogName/@xml:id"/>
    <xsl:variable name="f:objectsRefs" select="$item//objectName/@xml:id"/>
    <persons>
      <xsl:variable name="persons" select="for $f:personRef in $f:personsRefs 
        return $allPersons[listRelation/relation[fn:contains(@passive, '#' || $f:personRef)]]"/>
      <xsl:for-each-group select="$persons" group-by="@xml:id">
        <person>
          <personId>{current-group()/@xml:id}</personId>
          <persName>{current-group()/(persName[1]|orgName[1])}</persName>
          <quantity>{count(current-group())}</quantity>
        </person>
      </xsl:for-each-group>
    </persons>
    <places>
      <xsl:variable name="places" select="for $f:placeRef in $f:placesRefs
        return $allPlaces[listRelation/relation[fn:contains(@passive, '#' || $f:placeRef)]]"/>
      <xsl:for-each-group select="$places" group-by="@xml:id">
        <places>
          <placeId>{current-group()/@xml:id}</placeId>
          <placeName>{current-group()/placeName[1]}</placeName>
          <quantity>{count(current-group())}</quantity>
        </places>
      </xsl:for-each-group>
    </places>
    <objects>
      <xsl:variable name="objects" select="for $f:objectRef in $f:objectsRefs
        return $allObjects[listRelation/relation[fn:contains(@passive, '#' || $f:objectRef)]]"/>
      <xsl:for-each-group select="$objects" group-by="@xml:id">
        <object>
          <objectId>{current-group()/@xml:id}</objectId>
          <objectName>{current-group()/objectName[1]}</objectName>
          <quantity>{count(current-group())}</quantity>
          <!--<xsl:variable name="refs" select="for $i in ./listRelation/relation/@passive return tokenize(.)"/>
          <xsl:variable name="currentRefs" select="for $i in $f:objectsRefs return concat('#', .)"/>
          <xsl:variable name="duplicateRefs" select="($refs, $currentRefs)"/>
          <xsl:variable name="deDuplicatedRefs" select="$duplicateRefs[index-of($duplicateRefs,.)[2]]"/>
          <refs>
            <head>test</head>
            <deduplicatedRefs>{$deDuplicatedRefs}</deduplicatedRefs>
            <!-\-<xsl:for-each select="$deDuplicatedRefs">
              <ref>{.}</ref>
            </xsl:for-each>-\->
          </refs>-->
        </object>
      </xsl:for-each-group>
    </objects>
  </xsl:function>
  
  <xsl:function name="f:getWordsCount" as="element()*">
    <xsl:param name="item" as="element()"/>
    <unit>mots</unit>
    <quantity>{fn:count(fn:tokenize($item, '\W+')[. != '']) }</quantity>
  </xsl:function>
  
  <xsl:function name="f:getTextIdWithRegex" as="xs:string">
    <xsl:param name="item" as="element()"/>
    <xsl:variable name="f:extractId" select="$item/ancestor::*[@xml:id][1]/@xml:id"/>
    <xsl:variable name="f:parse" select="fn:analyze-string($f:extractId, '^gdp.*[1-9]{4}')"/>
    <xsl:sequence select="fn:string($f:parse/fn:match)"/>
  </xsl:function>
  <!--
  {
      let $pageBefore := $item/preceding::fw[@type = 'pageNum'][1]
      let $fw := $item//fw[@type = 'pageNum']
      (:let $pages := ($pageBefore, $fw):)
      return (
        <prefix>{if ($fw) then 'pp.' else 'p.'}</prefix>,
        <range>{fn:string-join(($pageBefore, $fw[fn:last()]), '–')}</range>
      )
    }
  -->
  
  <xsl:template match="head | div/quote | div/argument | div/cit | div/list">
    <p>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="./p">
          <xsl:apply-templates select="./p/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>
  
  <xsl:template match="
    abbr | 
    att | 
    bibl | 
    choice | 
    date | 
    emph | 
    expan | 
    figDesc | 
    figure | 
    foreign |
    gap | 
    gi | 
    geo | 
    geogName | 
    graphic | 
    hi | 
    ident | 
    item | 
    label |
    lg/head | 
    lg | 
    l | 
    p/list | 
    list/head | 
    metamark | 
    num | 
    objectName | 
    orgName | 
    orig | 
    persName | 
    placeName | 
    q | 
    quote | 
    ref | 
    rs | 
    said | 
    seg | 
    sic | 
    soCalled | 
    space | 
    supplied | 
    surplus | 
    title | 
    trailer | 
    unclear | 
    val">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="quote/p | quote/lg | quote/l">
    <xsl:apply-templates select="child::*"/>
  </xsl:template>
  <!-- @todo check cit et quote -->
  <xsl:template match="lb | cb | pb"/>
  <xsl:template match="fw" />
  <xsl:template match="comment()" />
  <!-- @todo -->
  <xsl:template match="note"/>
  <xsl:template match="reg"/>
  
</xsl:stylesheet>