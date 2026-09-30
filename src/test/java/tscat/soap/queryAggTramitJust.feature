Feature: queryAggTramitJust - via GestorFormularis (codiTramit TSCAT0)

  # Operacion: queryAggTramitJust | CodiTramit: TSCAT0
  # Endpoint: GestorFormularis
  #
  # Primera ejecucion → guardar golden file:
  #   mvn test -Dtest=SoapTest#testAll -Dmode=record
  #
  # Ejecuciones posteriores → comparar contra golden:
  #   mvn test -Dtest=SoapTest#testAll

  Background:
    * def helpers      = call read('classpath:tscat/soap/soap-helpers.js')
    * def goldenFile   = 'queryAggTramitJust.xml'
    * def dynamicPaths = []

  Scenario: queryAggTramitJust - grabar o comparar respuesta SOAP
    Given url soapGfUrl
    And header Content-Type = 'text/xml; charset=utf-8'
    And header SOAPAction = soapAction
    And request read('classpath:tscat/soap/requests/queryAggTramitJust.xml')
    When method POST
    Then status 200

    * def normalizedActual = helpers.normalizeXml(dynamicPaths)
    * if (mode == 'record') helpers.saveGolden(goldenFile, normalizedActual)

    * def expected = helpers.getExpected(mode, goldenFile, normalizedActual)
    * xml actualXml = normalizedActual
    * xml expectedXml = expected
    * match actualXml == expectedXml
