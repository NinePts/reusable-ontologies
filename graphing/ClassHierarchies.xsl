<?xml version="1.0" encoding="UTF-8" standalone="no"?>
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
    
    <!-- create Thing as the center of the graph  -->
    <xsl:call-template name="classImage">
    	<xsl:with-param name="cName" select="'Thing'"/>
    	<xsl:with-param name="cLabel" select="'Thing'"/>
    </xsl:call-template>
  
    <!-- process each class -->
    <xsl:for-each select="/rdf:RDF/owl:Class">  
    
      <!-- get the class name -->
      <xsl:variable name="cName" select="substring-after(./@rdf:about,'#')"/>
      
      <!-- get the class label -->
      <xsl:variable name="cLabel">
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
      <xsl:call-template name="classImage">
        <xsl:with-param name="cName" select="$cName"/>
        <xsl:with-param name="cLabel" select="$cLabel"/>
      </xsl:call-template>    
    
      <!-- add the superclass edges -->  
      <xsl:choose>
      
        <!-- if a superclass is defined -->
        <xsl:when test="./rdfs:subClassOf">  
          <xsl:for-each select="./rdfs:subClassOf">  <!-- there may be more than one defined -->
        	<xsl:call-template name="drawInheritance">
        	  <xsl:with-param name="node1" select="$cName"/>
        	  <xsl:with-param name="node2" select="substring-after(./@rdf:resource,'#')"/>
        	</xsl:call-template>	
          </xsl:for-each>
        </xsl:when>  
        
        <!-- if a superclass is NOT defined -->
        <xsl:otherwise>   <!-- no superclass is defined -->
          <xsl:call-template name="drawInheritance">
            <xsl:with-param name="node1" select="$cName"/>
            <xsl:with-param name="node2" select="'Thing'"/>
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
  
  <!-- drawing a class -->
  <xsl:template name="classImage">
  	<xsl:param name="cName"/>
  	<xsl:param name="cLabel"/>
  	<xsl:param name="width" select="string-length($cLabel)*6"/>
  	<xsl:param name="size" select="$width+10"/>
    <node >
    	<xsl:attribute name="id">
    		<xsl:value-of select="$cName"/>
    	</xsl:attribute>	
      <data key="d5"/>
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry height="100.0" width="100.0" x="0.0" y="0.0"/>
          <y:Fill color="#99CCFF" transparent="false"/>
          <y:BorderStyle color="#000000" type="line" width="2.0"/>
          <y:NodeLabel alignment="center" autoSizePolicy="content" 
            fontFamily="Dialog" fontSize="12" fontStyle="plain" 
            hasBackgroundColor="false" hasLineColor="false" height="18" 
            modelName="internal" modelPosition="c"
            textColor="#000000" visible="true">
            <xsl:attribute name="width">
            	<xsl:value-of select="$width"/>
            </xsl:attribute>
            <xsl:value-of select="$cLabel"/>
          </y:NodeLabel>
          <y:Shape type="ellipse"/>
        </y:ShapeNode>
      </data>
    </node>
  </xsl:template>
    
  <!-- drawing a class-superclass edge -->
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