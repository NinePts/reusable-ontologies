<?xml version="1.0" encoding="UTF-8" standalone="no"?>

<!-- The MIT License (MIT)

Copyright (c) 2014 Nine Points Solutions, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. 
-->

<xsl:stylesheet version="1.0" 
  xmlns="http://graphml.graphdrawing.org/xmlns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:y="http://www.yworks.com/xml/graphml"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:owl="http://www.w3.org/2002/07/owl#"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">  <!-- root element -->
  
    <!-- output the graphml tags, keys (based on yEd's capabilities) and 
         define the containing graph -->
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:y="http://www.yworks.com/xml/graphml" xmlns:yed="http://www.yworks.com/xml/yed/3" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://www.yworks.com/xml/schema/graphml/1.1/ygraphml.xsd">
  <key for="graphml" id="d0" yfiles.type="resources"/>
  <key for="port" id="d1" yfiles.type="portgraphics"/>
  <key for="port" id="d2" yfiles.type="portgeometry"/>
  <key for="port" id="d3" yfiles.type="portuserdata"/>
  <key attr.name="url" attr.type="string" for="node" id="d4"/>
  <key attr.name="description" attr.type="string" for="node" id="d5"/>
  <key for="node" id="d6" yfiles.type="nodegraphics"/>
  <key attr.name="Description" attr.type="string" for="graph" id="d7"/>
  <key attr.name="url" attr.type="string" for="edge" id="d8"/>
  <key attr.name="description" attr.type="string" for="edge" id="d9"/>
  <key for="edge" id="d10" yfiles.type="edgegraphics"/>
  <graph edgedefault="directed" id="G">
    <data key="d7"/>
  
    <!-- process each individual -->
    <!-- assumes that individuals are defined in the ontology to provide enum values
            (too simplistic) -->
    <xsl:for-each select="/rdf:RDF/owl:NamedIndividual">
      
      <!-- get the individual name -->
      <xsl:variable name="eName" select="substring-after(./@rdf:about,'#')"/>
      
      <!-- get the individual label -->
      <xsl:variable name="eLabel">
        <xsl:choose>
      	  <xsl:when test="./skos:prefLabel">
      	    <xsl:value-of select="./skos:prefLabel/text()"/>
      	  </xsl:when>
      	  <xsl:otherwise>
      	    <xsl:value-of select="substring-after(./@rdf:about,'#')"/>
      	  </xsl:otherwise>  
        </xsl:choose>
      </xsl:variable>  

      <!-- add the individual to the graph -->
      <xsl:call-template name="entityImage">
        <xsl:with-param name="eName" select="$eName"/>
        <xsl:with-param name="eLabel" select="$eLabel"/>
        <xsl:with-param name="type" select="'individual'"/>
      </xsl:call-template>     
   
    </xsl:for-each>
    
    <!-- get classes with oneOf semantics -->
    <!-- again, assuming a very simplistic approach to enumerations -->
    <xsl:for-each select="/rdf:RDF/owl:Class">
    
      <!-- check for presence of oneOf -->
      <xsl:if test=".//owl:oneOf">
            
        <!-- get the class name that uses oneOf -->
        <xsl:variable name="eName" select="substring-after(./@rdf:about,'#')"/>
        
        <!-- get the class label -->
        <xsl:variable name="eLabel">
          <xsl:choose>
      	    <xsl:when test="./skos:prefLabel">
      	      <xsl:value-of select="./skos:prefLabel/text()"/>
      	    </xsl:when>
      	    <xsl:otherwise>
      	      <xsl:value-of select="substring-after(./@rdf:about,'#')"/>
      	    </xsl:otherwise>  
          </xsl:choose>
        </xsl:variable>  
        
        <!-- add the class to the graph -->
        <xsl:call-template name="entityImage">
          <xsl:with-param name="eName" select="$eName"/>
          <xsl:with-param name="eLabel" select="$eLabel"/>
          <xsl:with-param name="type" select="'class'"/>
        </xsl:call-template>     
      
        <!-- get the rdf:Description entries that define the oneOf members -->
        <xsl:for-each select=".//owl:oneOf/rdf:Description">
              
          <!-- get the individual name -->
          <xsl:variable name="iName" select="substring-after(./@rdf:about,'#')"/>
      
          <!-- draw an edge from the individual to the class --> 
          <xsl:call-template name="drawClassIndividualEdge">
            <xsl:with-param name="cName" select="$eName"/>
            <xsl:with-param name="iName" select="$iName"/>
          </xsl:call-template>     
   
        </xsl:for-each>
        
      </xsl:if> 
      
    </xsl:for-each>   
    
    <!-- finish the graph definition -->
  </graph>
  <data key="d0">
    <y:Resources/>
  </data>
</graphml>
  
  </xsl:template>  
  
  <!-- drawing an entity (class or individual) -->
  <xsl:template name="entityImage">
  	<xsl:param name="eName"/>
  	<xsl:param name="eLabel"/>
  	<xsl:param name="type"/>
  	<xsl:param name="width" select="string-length($eLabel)*6"/>
  	<xsl:param name="size" select="$width+10"/>
    <node >
    	<xsl:attribute name="id">
    		<xsl:value-of select="$eName"/>
    	</xsl:attribute>	
      <data key="d5"/>
      <data key="d6">
        <y:ShapeNode>
          <xsl:choose>
            <xsl:when test="$type = 'class'">
          <y:Geometry height="120.0" width="120.0" x="0.0" y="0.0"/>
            </xsl:when>
            <xsl:otherwise>
          <y:Geometry height="90.0" width="90.0" x="0.0" y="0.0"/>
            </xsl:otherwise>
            </xsl:choose>
          <y:Fill transparent="false">
            <xsl:attribute name="color">
              <xsl:choose>
                <xsl:when test="$type = 'class'">
                  <xsl:value-of select="'#99CCFF'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'#CCFFFF'"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </y:Fill>
          <y:BorderStyle color="#000000" type="line" width="2.0"/>
          <y:NodeLabel alignment="center" autoSizePolicy="content" 
            fontFamily="Dialog" fontSize="12" fontStyle="plain" 
            hasBackgroundColor="false" hasLineColor="false" height="18" 
            modelName="internal" modelPosition="c"
            textColor="#000000" visible="true">
            <xsl:attribute name="width">
            	<xsl:value-of select="$width"/>
            </xsl:attribute>
            <xsl:value-of select="$eLabel"/>
          </y:NodeLabel>
          <xsl:choose> 
            <xsl:when test="$type = 'class'">
              <y:Shape type="ellipse"/>
            </xsl:when>
            <xsl:otherwise>
              <y:Shape type="octagon"/>
            </xsl:otherwise>  
          </xsl:choose>
        </y:ShapeNode>
      </data>
    </node>
  </xsl:template>
  
  <!-- drawing domain-object or object-range property edges -->
  <xsl:template name="drawClassIndividualEdge">
    <xsl:param name="cName"/>
    <xsl:param name="iName"/>
    <edge>
      <xsl:attribute name="id"> 
        <xsl:value-of select="concat($cName,'-',$iName)"/>
      </xsl:attribute>
      <xsl:attribute name="source">
        <xsl:value-of select="$iName"/>
      </xsl:attribute>
      <xsl:attribute name="target">
        <xsl:value-of select="$cName"/>
      </xsl:attribute>
      <data key="d9"/>
      <data key="d10">
        <y:PolyLineEdge>
          <y:Path sx="0.0" sy="0.0" tx="0.0" ty="0.0"/>
          <y:LineStyle color="#0000FF" type="line" width="2.0"/>
          <y:Arrows source="none" target="standard"/>
          <y:BendStyle smoothed="false"/>
        </y:PolyLineEdge>
      </data>
    </edge>  
    
  </xsl:template>
    
</xsl:stylesheet>