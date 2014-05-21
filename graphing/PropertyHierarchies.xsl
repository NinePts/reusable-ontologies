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
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:y="http://www.yworks.com/xml/graphml" 
  xmlns:yed="http://www.yworks.com/xml/yed/3" 
  xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns 
  http://www.yworks.com/xml/schema/graphml/1.1/ygraphml.xsd">
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
    
    <!-- create the Data and Object Property centers for the graph  -->
    <xsl:call-template name="centerImages"/>    
  
    <!-- process each property -->
    <xsl:for-each select="/rdf:RDF/owl:DatatypeProperty | /rdf:RDF/owl:ObjectProperty"> 
    
      <!-- get the property name -->
      <xsl:variable name="pName" select="substring-after(./@rdf:about,'#')"/>
      
      <!-- get the property label -->
      <xsl:variable name="pLabel">
        <xsl:choose>
      	  <xsl:when test="./skos:prefLabel">
      	    <xsl:value-of select="./skos:prefLabel/text()"/>
      	  </xsl:when>
      	  <xsl:otherwise>
      	    <xsl:value-of select="substring-after(./@rdf:about,'#')"/>
      	  </xsl:otherwise>  
        </xsl:choose>
      </xsl:variable>  

	  <!-- add the property to the graph -->
      <xsl:call-template name="propImage">
        <xsl:with-param name="pName" select="$pName"/>
        <xsl:with-param name="pLabel" select="$pLabel"/>
        <!-- use different colors for object vs data properties -->
        <xsl:with-param name="color">
          <xsl:choose>
            <xsl:when test="self::owl:DatatypeProperty">
              <xsl:value-of select="'#99CC00'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'#00FFCC'"/>
            </xsl:otherwise>  
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>    
      
      <!-- add the super-property edges -->
      <xsl:choose>
      
        <!-- check if a super-property is defined -->
        <xsl:when test="./rdfs:subPropertyOf">  
          <xsl:for-each select="./rdfs:subPropertyOf">  <!-- there may be more than one defined -->
            <xsl:call-template name="drawInheritance">
        	  <xsl:with-param name="node1" select="$pName"/>
        	  <xsl:with-param name="node2" select="substring-after(./@rdf:resource,'#')"/>
        	</xsl:call-template>	
          </xsl:for-each>
        </xsl:when>
         
        <!-- no super-property is defined -->
        <xsl:otherwise>
          <xsl:call-template name="drawInheritance">
        	<xsl:with-param name="node1" select="$pName"/>
        	<xsl:with-param name="node2">
        	    <xsl:choose>
      	          <xsl:when test="self::owl:DatatypeProperty">
      	            <xsl:value-of select="'DatatypeProperties'"/>
      	          </xsl:when>
      	          <xsl:otherwise>
      	            <xsl:value-of select="'ObjectProperties'"/>
      	          </xsl:otherwise>  
                </xsl:choose>
              </xsl:with-param>  
        	</xsl:call-template>	
        </xsl:otherwise>
      </xsl:choose>    
       
    </xsl:for-each>
    
    <!-- finish the graph definition -->
  </graph>
  <data key="d0">
    <y:Resources/>
  </data>
</graphml>
  
  </xsl:template>  
  
  <!-- drawing the centers (Data and Object Properties) -->
  <xsl:template name="centerImages">
    <node id="DatatypeProperties" >
      <data key="d5"/>
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry height="60.0" width="120.0" x="0.0" y="0.0"/>
          <y:Fill color="#99CC00" transparent="false"/>
          <y:BorderStyle color="#000000" type="line" width="2.0"/>
          <y:NodeLabel alignment="center" autoSizePolicy="content" 
            fontFamily="Dialog" fontSize="12" fontStyle="plain" 
            hasBackgroundColor="false" hasLineColor="false" height="18" 
            modelName="internal" modelPosition="c"
            textColor="#000000" visible="true" width="110">Datatype Properties</y:NodeLabel>
          <y:Shape type="rectangle"/>
        </y:ShapeNode>
      </data>
    </node>
    <node id="ObjectProperties" >
      <data key="d5"/>
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry height="60.0" width="120.0" x="0.0" y="0.0"/>
          <y:Fill color="#00FFCC" transparent="false"/>
          <y:BorderStyle color="#000000" type="line" width="2.0"/>
          <y:NodeLabel alignment="center" autoSizePolicy="content" 
            fontFamily="Dialog" fontSize="12" fontStyle="plain" 
            hasBackgroundColor="false" hasLineColor="false" height="18" 
            modelName="internal" modelPosition="c"
            textColor="#000000" visible="true" width="105">Object Properties</y:NodeLabel>
          <y:Shape type="rectangle"/>
        </y:ShapeNode>
      </data>
    </node>    
  </xsl:template>  
  
  <!-- drawing a data property -->
  <xsl:template name="propImage">
  	<xsl:param name="pName"/>
  	<xsl:param name="pLabel"/>
  	<xsl:param name="color"/>
  	<xsl:param name="width" select="string-length($pLabel)*6"/>
    <node>
    	<xsl:attribute name="id">
    		<xsl:value-of select="$pName"/>
    	</xsl:attribute>
      <data key="d5"/>
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry height="60" x="50.0" y="50.0">
          	<xsl:attribute name="width">
          	  <xsl:value-of select="$width+10"/>
          	</xsl:attribute>  
          </y:Geometry>
          <y:Fill transparent="false">
            <xsl:attribute name="color">
              <xsl:value-of select="$color"/>
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
            <xsl:value-of select="$pLabel"/>
          </y:NodeLabel>
          <y:Shape type="rectangle"/>
        </y:ShapeNode>
      </data>
    </node>
  </xsl:template> 
    
  <!-- drawing a property-super property edge -->
  <xsl:template name="drawInheritance">
    <xsl:param name="node1"/>
    <xsl:param name="node2"/>
    <edge>
      <xsl:attribute name="id"> 
        <xsl:value-of select="concat($node1,'-',$node2)"/>
      </xsl:attribute>
      <xsl:attribute name="source">
        <xsl:value-of select="$node1"/>
      </xsl:attribute>
      <xsl:attribute name="target">
        <xsl:value-of select="$node2"/>
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