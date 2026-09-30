Feature: confJustLang - confConvoLang via GestorFormularis (AG_EMT0059)

  # Operacion: confConvoLang | Agrupador: AG_EMT0059/0001_0001 | Tramit: PRTAI2
  # Endpoint: GestorFormularis
  #
  # Primera ejecucion → guardar golden file:
  #   mvn test -Dtest=SoapTest#testAll -Dmode=record
  #
  # Ejecuciones posteriores → comparar contra golden:
  #   mvn test -Dtest=SoapTest#testAll
  #
  # Campos dinamicos: anadir XPaths en dynamicPaths si la respuesta contiene
  # valores que cambian entre llamadas (fechas, IDs de sesion, etc.).
  # Ejemplo: * def dynamicPaths = ['//dataCreacio', '//@timestamp']

  Background:
    * def helpers      = call read('classpath:tscat/soap/soap-helpers.js')
    * def goldenFile   = 'confJustLang.xml'
    * def dynamicPaths = []

  Scenario: confJustLang - grabar o comparar respuesta SOAP
    Given url soapGfUrl
    And header Content-Type = 'text/xml; charset=utf-8'
    And header SOAPAction = soapAction
    And request read('classpath:tscat/soap/requests/confJustLang.xml')
    When method POST
    Then status 200

    * def normalizedActual = helpers.normalizeXml(dynamicPaths)
    * if (mode == 'record') helpers.saveGolden(goldenFile, normalizedActual)

    * def expected = helpers.getExpected(mode, goldenFile, normalizedActual)
    * xml actualXml = normalizedActual
    * xml expectedXml = expected
    * match actualXml == expectedXml
