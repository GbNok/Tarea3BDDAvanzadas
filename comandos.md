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