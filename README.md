reusable-ontologies
===================

An open-source repository containing various small- and medium-sized ontologies that are designed (and documented) for reuse. Currently, only meta-data ontologies (mainly based on Dublin Core and SKOS) are available in the metadata directory. The metadata-annotation ontology defines the key concepts as annotation properties, while the meta-data properties file defines many of the concepts as data and object properties. The ontologies are available in a Turtle syntax (.ttl filename) or using RDF/OWL (.owl filename).

A set of simple XSLTs were also created to explore generating various GraphML outputs of an RDF/OWL ontology file. (They can be executed using an XSLT processor such as xsltproc. Once the GraphML outputs are created, a graphical editor (such as yEd) can be used to perform the more difficult task of layout. There are four files in the graphing directory:
  - AnnotationProperties.xsl - A transform of any annotation property definitions in an RDF/XML file, drawing them as rectangles connected to a central entity named "Annotation Properties"
  - ClassHierarchies.xsl - A transform of any class definitions in an RDF/XML file, drawing them in a class-superclass hierarchy
  - ClassProperties.xsl - A transform of any data type and object property definitions in an RDF/XML file, drawing them as rectangles with their types (functional, transitive, etc.) and domains and ranges
  - PropertyHierarchies.xsl - A transform of any data type and object property definitions in an RDF/XML file, drawing their property-super property relationships

