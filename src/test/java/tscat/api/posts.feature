Feature: Pruebas sobre la API publica de posts (jsonplaceholder)

  # 'background' se ejecuta antes de cada Scenario.
  # 'baseUrl' viene definido en karate-config.js
  Background:
    * url baseUrl

  Scenario: GET - obtener un post y validar el response
    Given path 'posts', 1
    When method GET
    Then status 200
    And match response.id == 1
    And match response.userId == '#number'
    And match response.title == '#string'
    And match response.body == '#string'

  Scenario: GET - obtener todos los posts y validar el esquema
    Given path 'posts'
    When method GET
    Then status 200
    And assert response.length == 100
    And match each response ==
      """
      {
        userId: '#number',
        id: '#number',
        title: '#string',
        body: '#string'
      }
      """

  Scenario: GET - filtrar posts por userId con query param
    Given path 'posts'
    And param userId = 1
    When method GET
    Then status 200
    And assert response.length > 0
    And match each response contains { userId: 1 }

  Scenario: POST - crear un post y validar la respuesta
    Given path 'posts'
    And request
      """
      {
        "title": "Prueba TSCAT",
        "body": "Contenido de prueba",
        "userId": 5
      }
      """
    When method POST
    Then status 201
    And match response.title == 'Prueba TSCAT'
    And match response.body == 'Contenido de prueba'
    And match response.userId == 5
    And match response.id == '#number'

  Scenario: GET - obtener los comentarios de un post
    Given path 'posts', 1, 'comments'
    When method GET
    Then status 200
    And assert response.length > 0
    And match each response contains { postId: 1 }
    And match each response contains { email: '#regex .+@.+\\..+' }
