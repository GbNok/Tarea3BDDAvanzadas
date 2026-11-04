## Parte 1

### 1.1 Visualización e interpretación del grafo

```sh
MATCH (n) 
OPTIONAL MATCH (n)-[r]->() 
RETURN n, r;
```

### 1.2

```sh
MATCH (c:Casa)
OPTIONAL MATCH ()-[r:PIDIO_DULCES]->(c)
RETURN c.id AS identificador, c.direccion AS direccion, count(r) AS cantidad_visitas
ORDER BY cantidad_visitas DESC
LIMIT 10;
```

## Parte 2

### 2.1

```sh
CALL gds.graph.project(
  'halloween',
  ['Estudiante', 'Casa'],
  {PIDIO_DULCES: {orientation: 'NATURAL'}}
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;
```

### 2.2

```sh
CALL gds.degree.stream('halloween', {
  orientation: 'REVERSE'
})
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS nodo, score
WHERE 'Casa' IN labels(nodo)
RETURN labels(nodo) AS etiquetas, nodo.id AS id, nodo.direccion AS direccion, score
ORDER BY score DESC;
```