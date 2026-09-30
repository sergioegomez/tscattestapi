Feature: confConvoLang WS - directo al WS de preprod (AG_ECF0003 + SLT_2026)

  # Operacion: confConvoLang | Agrupador: AG_ECF0003/0683_0001 | Convocatoria: SLT_2026_00000462
  # Endpoint: WS directo (preprod)
  #
  # Primera ejecucion → guardar golden file:
  #   mvn test -Dtest=SoapTest#testAll -Dmode=record
  #
  # Ejecuciones posteriores → comparar contra golden:
  #   mvn test -Dtest=SoapTest#testAll

  Background:
    * def helpers      = call read('classpath:tscat/soap/soap-helpers.js')
    * def goldenFile   = 'confConvoLangWS.xml'
    * def dynamicPaths = []

  Scenario: confConvoLang WS - grabar o comparar respuesta SOAP
    Given url soapWsUrl
    And header Content-Type = 'text/xml; charset=utf-8'
    And header SOAPAction = soapAction
    And request read('classpath:tscat/soap/requests/confConvoLangWS.xml')
    When method POST
    Then status 200

    * def normalizedActual = helpers.normalizeXml(dynamicPaths)
    * if (mode == 'record') helpers.saveGolden(goldenFile, normalizedActual)

    * def expected = helpers.getExpected(mode, goldenFile, normalizedActual)
    * xml actualXml = normalizedActual
    * xml expectedXml = expected
    * match actualXml == expectedXml
