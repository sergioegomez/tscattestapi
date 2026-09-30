Feature: listJustLang (APOR) - via GestorFormularis (EMT_2025_00000091)

  # Operacion: listJustLang | TipoTramit: APOR | Expedient: EMT_2025_00000091_000000038
  # Endpoint: GestorFormularis
  #
  # Primera ejecucion → guardar golden file:
  #   mvn test -Dtest=SoapTest#testAll -Dmode=record
  #
  # Ejecuciones posteriores → comparar contra golden:
  #   mvn test -Dtest=SoapTest#testAll

  Background:
    * def helpers      = call read('classpath:tscat/soap/soap-helpers.js')
    * def goldenFile   = 'listJustLangApor.xml'
    * def dynamicPaths = []

  Scenario: listJustLang APOR - grabar o comparar respuesta SOAP
    Given url soapGfUrl
    And header Content-Type = 'text/xml; charset=utf-8'
    And header SOAPAction = soapAction
    And request read('classpath:tscat/soap/requests/listJustLangApor.xml')
    When method POST
    Then status 200

    * def normalizedActual = helpers.normalizeXml(dynamicPaths)
    * if (mode == 'record') helpers.saveGolden(goldenFile, normalizedActual)

    * def expected = helpers.getExpected(mode, goldenFile, normalizedActual)
    * xml actualXml = normalizedActual
    * xml expectedXml = expected
    * match actualXml == expectedXml
