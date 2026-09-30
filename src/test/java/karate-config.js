/**
 * Configuracion global de Karate.
 * Se ejecuta antes de cada Scenario. Aqui se define el entorno,
 * la URL base y las variables comunes a todos los tests.
 */
function fn() {
  var env = karate.env;
  if (!env) { env = 'preprod'; }
  karate.log('karate.env seleccionado:', env);

  var config = {
    env: env,

    // REST (tests existentes)
    baseUrl: 'https://jsonplaceholder.typicode.com',

    // SOAP: endpoint directo al WS de GSIT
    soapWsUrl: 'https://preproduccio.eco.out.apps.gencat.cat/TSCAT_GSIT_API/GSITWebService.asmx',
    // SOAP: endpoint a traves de GestorFormularis
    soapGfUrl: 'https://configuracio.ovt.gencat.cat/gsitgf/AppJava/services/GestorFormularis',
    // SOAPAction comun a todas las operaciones
    soapAction: 'http://TSCAT_GSIT_API/GSITWebService/aggregator',

    // 'record' guarda los golden files; 'compare' valida contra ellos
    mode: karate.properties['mode'] || 'compare'
  };

  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 60000);

  return config;
}
