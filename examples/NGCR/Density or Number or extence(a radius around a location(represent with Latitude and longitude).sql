# Number
# facility type: dwelling(building=residential),leisure(leisure=*), bank(amenity=bank), shop(landuse=shop/commercial),
# park(leisure=park), private leisure facility, non-residential land use, point of interest.

# Density(a radius around a location)
# facility type: building(building=*), dwelling(building=residential),leisure(leisure=*)
# public transport stop(public transport=stop), street(highway=*), park(leisure=park)

# extence of the following facilities
#rest area (Q786014);footpath;signage (Q1211272)
#;sidewalk (Q177749);traffic calming (Q1198538);traffic light (Q8004);
#step (Q13222221);toilet (Q7857);shelter (Q989946);waste container (Q216530);drinking water (Q7892);
#vending machine (Q211584);streetlight (Q503958);obstacle (Q264661);parking facility (Q55697304)
#####Qclever link: https://qlever.dev/osm-planet/SyIewg

PREFIX geo: <http://www.opengis.net/ont/geosparql#>
PREFIX geof: <http://www.opengis.net/def/function/geosparql/>
PREFIX uom: <http://www.opengis.net/def/uom/OGC/1.0/>
PREFIX osm: <https://www.openstreetmap.org/wiki/Key:>

PREFIX osm: <https://www.openstreetmap.org/>
PREFIX osmrel: <https://www.openstreetmap.org/relation/>
PREFIX ogc: <http://www.opengis.net/rdf#>
PREFIX osmkey: <https://www.openstreetmap.org/wiki/Key:>
SELECT ?zipcode_start 
    (COUNT(?park) AS ?parkCount)
    (IF(COUNT(?park)=0, 0, COUNT(?park)) AS ?parkNumber)
    (IF(COUNT(?parkNumber) >= 1, "extence", "absent") AS ?Extence)
    (IF(COUNT(?park)=0, 0, COUNT(?park)/(3.14*500*500)) AS ?parkDensity)
    
WHERE {
  # find parks within 500m
  VALUES ?zipcode_start {"POINT (4.900000 52.370500)"^^geo:wktLiteral "POINT (4.895168 52.370216)"^^geo:wktLiteral}
  osmrel:47811 ogc:sfContains ?way .
  ?way osmkey:leisure "park" .
       ?way osmkey:name ?park .
       ?way geo:hasGeometry/geo:asWKT ?geom .		
  # get point for distance calculation
  BIND(
    IF(STRSTARTS(STR(?geom), "POINT"), 
       ?geom, 
       geof:centroid(?geom)
    ) AS ?geom_for_distance
  )
  # calculate distance in meters
  BIND(
    geof:distance(?zipcode_start, ?geom_for_distance) AS ?dist
  )
  FILTER(?dist<500)
}
GROUP BY ?zipcode_start 
