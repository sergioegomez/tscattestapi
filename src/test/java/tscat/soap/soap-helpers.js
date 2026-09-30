/**
 * Utilidades para golden-file testing de SOAP.
 *
 * Uso en features:
 *   * def helpers = call read('classpath:tscat/soap/soap-helpers.js')
 *
 * Modos (configurados en karate-config.js via -Dmode=record|compare):
 *   record  → guarda la respuesta normalizada como golden file
 *   compare → compara la respuesta normalizada contra el golden file
 *
 * Para campos dinámicos (fechas, IDs, etc.) añadir XPaths en dynamicPaths
 * dentro del Background de cada feature. Ejemplo:
 *   * def dynamicPaths = ['//dataCreacio', '//fecha']
 */
function() {
  var Paths   = Java.type('java.nio.file.Paths');
  var Files   = Java.type('java.nio.file.Files');
  var cwd     = java.lang.System.getProperty('user.dir');

  function goldenDir() {
    return Paths.get(cwd, 'src', 'test', 'java', 'tscat', 'soap', 'golden');
  }

  function saveGolden(fileName, content) {
    var path = goldenDir().resolve(fileName);
    Files.createDirectories(path.getParent());
    Files.write(path, content.getBytes('UTF-8'));
    karate.log('[RECORD] Golden guardado:', path.toString());
  }

  function getExpected(mode, fileName, actual) {
    if (mode !== 'compare') return actual;
    var path = goldenDir().resolve(fileName);
    if (!path.toFile().exists()) {
      karate.fail('Golden file no encontrado: ' + path + '. Ejecuta primero con -Dmode=record');
    }
    return new java.lang.String(Files.readAllBytes(path), 'UTF-8');
  }

  /**
   * Obtiene el response string y lo normaliza: parsea el XML, reemplaza los
   * campos dinámicos indicados por __DYNAMIC__ y devuelve el XML serializado.
   * Lee responseString directamente del contexto Karate con karate.get().
   * @param {string[]} xpaths  - Expresiones XPath de campos a enmascarar
   */
  function normalizeXml(xpaths) {
    var responseBytes = karate.get('responseBytes');
    var xmlString = responseBytes != null
      ? new java.lang.String(responseBytes, 'UTF-8')
      : karate.toXml(karate.get('response'));
    var DocumentBuilderFactory = Java.type('javax.xml.parsers.DocumentBuilderFactory');
    var XPathFactory   = Java.type('javax.xml.xpath.XPathFactory');
    var XPathConstants = Java.type('javax.xml.xpath.XPathConstants');
    var TransformerFactory = Java.type('javax.xml.transform.TransformerFactory');
    var OutputKeys     = Java.type('javax.xml.transform.OutputKeys');
    var DOMSource      = Java.type('javax.xml.transform.dom.DOMSource');
    var StreamResult   = Java.type('javax.xml.transform.stream.StreamResult');
    var StringReader   = Java.type('java.io.StringReader');
    var StringWriter   = Java.type('java.io.StringWriter');
    var InputSource    = Java.type('org.xml.sax.InputSource');

    var dbf = DocumentBuilderFactory.newInstance();
    dbf.setNamespaceAware(true);
    var doc = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(xmlString)));

    if (xpaths && xpaths.length > 0) {
      var xpathObj = XPathFactory.newInstance().newXPath();
      for (var i = 0; i < xpaths.length; i++) {
        var nodes = xpathObj.evaluate(xpaths[i], doc, XPathConstants.NODESET);
        for (var j = 0; j < nodes.getLength(); j++) {
          var node = nodes.item(j);
          if (node.getNodeType() == 2) { // ATTRIBUTE_NODE
            node.setNodeValue('__DYNAMIC__');
          } else {
            node.setTextContent('__DYNAMIC__');
          }
        }
      }
    }

    var tf = TransformerFactory.newInstance().newTransformer();
    tf.setOutputProperty(OutputKeys.INDENT, 'yes');
    tf.setOutputProperty(OutputKeys.ENCODING, 'UTF-8');
    tf.setOutputProperty('{http://xml.apache.org/xslt}indent-amount', '2');
    var writer = new StringWriter();
    tf.transform(new DOMSource(doc), new StreamResult(writer));
    return writer.toString();
  }

  return { saveGolden: saveGolden, getExpected: getExpected, normalizeXml: normalizeXml };
}
