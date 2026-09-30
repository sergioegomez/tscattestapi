# TSCAT SOAP API Tests

Suite de tests de regresión para los endpoints del servicio SOAP **GSITWebService** (aggregator) de la plataforma TSCAT/GSIT.  
Cada test llama a un endpoint real en **preprod**, captura la respuesta XML completa y la compara contra una respuesta de referencia previamente guardada (**golden file**).

> Para la documentación completa con diagramas y ejemplos: abre [`wiki.html`](wiki.html) en el navegador.

---

## Stack técnico

| Componente | Versión |
|---|---|
| Java | 17 |
| Maven | 3.x |
| Karate | 1.4.1 |
| JUnit | 5.10.2 |
| GraalVM | 24.1.1 |

---

## Cómo funciona

El servicio expone un único método WSDL (`aggregator`) que actúa como enrutador: el campo `Operation` del body determina qué lógica se ejecuta. Cada operación es, en la práctica, un endpoint independiente.

### Patrón Golden File

```
1ª ejecución  →  llama al endpoint  →  guarda la respuesta como golden file
Ejecuciones   →  llama al endpoint  →  normaliza XML  →  compara vs golden
```

**Pasos por feature:**
1. `POST` al endpoint SOAP con el body de `requests/`
2. Valida `status 200`
3. Normaliza el XML (enmascara campos dinámicos configurados en `dynamicPaths`)
4. En modo `record`: guarda el golden file
5. En modo `compare`: `match actualXml == expectedXml` (comparación estructural nodo a nodo)

---

## Endpoints validados (10 operaciones)

| Feature | Operación SOAP | Endpoint | Parámetros clave |
|---|---|---|---|
| `confJustLang` | confConvoLang | GestorFormularis | AG_EMT0059/0001_0001 · CATALA |
| `queryAggTramit` | queryAggTramit | GestorFormularis | codiTramit: COSPE1 · ca_ES |
| `queryAggTramitLang` | queryAggTramitLang | **WS directo** | codiTramit: TRI004 · CATALA |
| `queryAggTramitJust` | queryAggTramitJust | GestorFormularis | codiTramit: TSCAT0 · CATALA |
| `listJustLangJust` | listJustLang | GestorFormularis | ECF_2025_00003677 · JUST · TSCAT3 |
| `listJustLangApor` | listJustLang | GestorFormularis | EMT_2025_00000091 · APOR · TSCAT4 |
| `confConvoLang` | confConvoLang | GestorFormularis | AG_ECF0003/0683_0001 · TSCAT9 |
| `justMigracions` | justMigracions | GestorFormularis | CLT320/25/000001 · CATALA |
| `readXMLCospe` | leerXMLCospe | GestorFormularis | _(sin InputJSON)_ |
| `confConvoLangWS` | confConvoLang | **WS directo** | AG_ECF0003 · SLT_2026_00000462 |

### URLs de los endpoints

| Tipo | URL |
|---|---|
| WS directo (preprod) | `https://preproduccio.eco.out.apps.gencat.cat/TSCAT_GSIT_API/GSITWebService.asmx` |
| GestorFormularis | `https://configuracio.ovt.gencat.cat/gsitgf/AppJava/services/GestorFormularis` |

---

## Comandos Maven

### Primera ejecución — grabar golden files

```bash
mvn test -Dtest=SoapTest -Dmode=record
```

Llama a los 10 endpoints y guarda las respuestas en `src/test/java/tscat/soap/golden/`.  
**Commitea estos ficheros al repositorio** — son la referencia de lo que es correcto.

### Ejecución normal — comparar

```bash
mvn test -Dtest=SoapTest
```

Llama a los 10 endpoints y compara cada respuesta contra su golden file.  
Si algún campo difiere, el test falla indicando el nodo exacto.

### Ejecutar un único test

```bash
mvn test -Dtest=SoapTest -Dkarate.options="classpath:tscat/soap/confConvoLang.feature"
```

### Regenerar un golden file concreto

```bash
mvn test -Dtest=SoapTest -Dmode=record -Dkarate.options="classpath:tscat/soap/confConvoLang.feature"
```

> El informe HTML detallado (request/response por step) queda en `target/karate-reports/karate-summary.html`.

---

## Campos dinámicos

Si un campo del response cambia en cada llamada (timestamp, fecha de creación, ID de sesión…), añade su XPath en el array `dynamicPaths` del `Background` del feature correspondiente:

```gherkin
Background:
  * def helpers      = call read('classpath:tscat/soap/soap-helpers.js')
  * def goldenFile   = 'confConvoLang.xml'
  * def dynamicPaths = ['//dataCreacio', '//timestamp']   # ← añadir aquí
```

El helper reemplazará el contenido de esos nodos por `__DYNAMIC__` en ambos XMLs antes de compararlos.

> Tras añadir un XPath a `dynamicPaths`, regenera el golden file con `-Dmode=record`.

---

## Estructura de ficheros

```
src/test/java/
├── karate-config.js              # URLs, modo (record/compare) y timeouts
└── tscat/
    ├── api/
    │   ├── ApiTest.java          # Runner tests REST existentes
    │   ├── users.feature
    │   └── posts.feature
    └── soap/
        ├── SoapTest.java         # Runner SOAP — ejecuta todos los .feature
        ├── soap-helpers.js       # normalizeXml · saveGolden · getExpected
        ├── requests/             # Body XML de cada petición (extraído del SoapUI)
        │   ├── confJustLang.xml
        │   ├── queryAggTramit.xml
        │   ├── queryAggTramitLang.xml
        │   ├── queryAggTramitJust.xml
        │   ├── listJustLangJust.xml
        │   ├── listJustLangApor.xml
        │   ├── confConvoLang.xml
        │   ├── justMigracions.xml
        │   ├── readXMLCospe.xml
        │   └── confConvoLangWS.xml
        ├── golden/               # Respuestas de referencia (commitear)
        │   ├── confJustLang.xml
        │   ├── queryAggTramit.xml
        │   └── ...
        ├── confJustLang.feature
        ├── queryAggTramit.feature
        ├── queryAggTramitLang.feature
        ├── queryAggTramitJust.feature
        ├── listJustLangJust.feature
        ├── listJustLangApor.feature
        ├── confConvoLang.feature
        ├── justMigracions.feature
        ├── readXMLCospe.feature
        └── confConvoLangWS.feature
```

---

## Añadir un nuevo test

1. Crea el body SOAP en `requests/miOperacion.xml`
2. Copia un `.feature` existente y actualiza `goldenFile`, la URL y el `request`
3. Graba el golden: `mvn test -Dtest=SoapTest -Dmode=record -Dkarate.options="classpath:tscat/soap/miOperacion.feature"`
4. Commitea el golden file generado en `golden/`
