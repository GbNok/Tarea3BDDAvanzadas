// ============================================================
// Tarea 3: Neo4j y análisis de grafos
// ============================================================


// ------------------------------------------------------------
// Verificación
// ------------------------------------------------------------

// Verificar versión de GDS
RETURN gds.version() AS versionGDS;

// Verificar carga
MATCH (e:Estudiante)
RETURN count(e) AS estudiantes;

MATCH (c:Casa)
RETURN count(c) AS casas;

MATCH (:Estudiante)-[r:PIDIO_DULCES]->(:Casa)
RETURN count(r) AS visitas;


// ------------------------------------------------------------
// PARTE 1: Exploración y consultas Cypher
// ------------------------------------------------------------

// Parte 1.1: Visualización e interpretación del grafo
MATCH (n) 
OPTIONAL MATCH (n)-[r]->() 
RETURN n, r;

// Parte 1.2: Casa con más visitas
MATCH (c:Casa)
OPTIONAL MATCH ()-[r:PIDIO_DULCES]->(c)
RETURN c.id AS identificador, c.direccion AS direccion, count(r) AS cantidad_visitas
ORDER BY cantidad_visitas DESC
LIMIT 10;

// Parte 1.3: Estudiantes con más dulces
MATCH (e:Estudiante)-[r:PIDIO_DULCES]->(c:Casa)
RETURN e.id AS Nombre, count(r) AS Visitas, sum(r.cantidad) AS CantDulces
ORDER BY CantDulces DESC;

// Parte 1.4: Visitas cuya cantidad es 0
MATCH (e:Estudiante)-[r:PIDIO_DULCES]->(c:Casa)
WHERE r.cantidad = 0
RETURN e.id AS Nombre, r.tipo, c.direccion;

// Parte 1.4: Cantidad de visitas sin dulce y porcentaje respecto del total de visitas
MATCH (e:Estudiante)-[r:PIDIO_DULCES]->(c:Casa)
WHERE r.cantidad = 0
WITH count(r) AS VisitasSinDulce
RETURN VisitasSinDulce, (toFloat(VisitasSinDulce)/75)*100 AS Porcentaje;


// ------------------------------------------------------------
// PARTE 2: Análisis con GDS
// ------------------------------------------------------------

// Parte 2.1: Proyección del grafo
CALL gds.graph.project(
  'halloween',
  ['Estudiante', 'Casa'],
  {PIDIO_DULCES: {orientation: 'NATURAL'}}
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;

// Parte 2.2: Degree Centrality
CALL gds.degree.stream('halloween', {
  orientation: 'REVERSE'
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS nodo, score
WHERE 'Casa' IN labels(nodo)
RETURN labels(nodo) AS etiquetas, nodo.id AS id, nodo.direccion AS direccion, score
ORDER BY score DESC;

// Parte 2.3: 5 parejas distintas con mayor similitud entre sí
CALL gds.nodeSimilarity.stream('halloween', {
  similarityMetric: 'JACCARD',
  topK: 14,
  similarityCutoff: 0.0001
})
YIELD node1, node2, similarity
WITH gds.util.asNode(node1).id AS estudiante1,
     gds.util.asNode(node2).id AS estudiante2,
     similarity
WHERE estudiante1 < estudiante2
RETURN estudiante1, estudiante2, similarity
ORDER BY similarity DESC, estudiante1 ASC, estudiante2 ASC
LIMIT 5;

// Parte 2.3: Casas que ambas, Antonia y Camila, visitaron
MATCH (a:Estudiante {id: 'Antonia'})-[:PIDIO_DULCES]->(c:Casa)<-[:PIDIO_DULCES]-(b:Estudiante {id: 'Camila'})
RETURN c AS CasasCompartidas;

// Parte 2.3: Cantidad de casas visitadas por Antonia
MATCH (a:Estudiante {id: 'Antonia'})-[:PIDIO_DULCES]->(c:Casa)
RETURN count(c) AS CantidadCasas;

// Parte 2.3: Cantidad de casas visitadas por Camila
MATCH (a:Estudiante {id: 'Camila'})-[:PIDIO_DULCES]->(c:Casa)
RETURN count(c) AS CantidadCasas;


// ------------------------------------------------------------
// PARTE 3: Búsqueda de caminos
// ------------------------------------------------------------

// Parte 3.1: Casas compartidas
MATCH path = (a:Estudiante {id: 'Antonia'})-[:PIDIO_DULCES]-(c:Casa)-[:PIDIO_DULCES]-(b:Estudiante {id: 'Camila'})
RETURN path;

// Parte 3.2: Camino más corto entre Antonia y Camila
MATCH (a:Estudiante {id: 'Antonia'}), (b:Estudiante {id: 'Camila'})
OPTIONAL MATCH p = shortestPath((a)-[:PIDIO_DULCES*1..24]-(b))
RETURN p, length(p) AS longitud, nodes(p) AS recorrido;


// ------------------------------------------------------------
// PARTE 4: Cierre
// ------------------------------------------------------------

// Parte 4.2: Liberar la proyección halloween
CALL gds.graph.drop('halloween', false)
YIELD graphName
RETURN graphName;

// Parte 4.2: Comprobar que la proyección ya no existe (debe dar false)
CALL gds.graph.exists('halloween')
YIELD exists
RETURN exists;