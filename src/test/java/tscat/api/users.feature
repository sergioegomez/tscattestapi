Feature: Ejemplos de llamadas API con validacion del response

  # 'background' se ejecuta antes de cada Scenario.
  # 'baseUrl' viene definido en karate-config.js
  Background:
    * url baseUrl

  Scenario: GET - obtener un usuario y validar el response
    Given path 'users', 1
    When method GET
    Then status 200
    # Validaciones sobre el body de la respuesta
    And match response.id == 1
    And match response.name == '#string'
    And match response.username == '#present'
    And match response.email == '#regex .+@.+\\..+'
    And match response.address.city == '#string'

  Scenario: GET - obtener lista de usuarios y validar el esquema
    Given path 'users'
    When method GET
    Then status 200
    # La respuesta debe ser un array con al menos 1 elemento
    And assert response.length > 0
    # Cada elemento debe cumplir este esquema
    And match each response ==
      """
      {
        id: '#number',
        name: '#string',
        username: '#string',
        email: '#string',
        address: '#object',
        phone: '#string',
        website: '#string',
        company: '#object'
      }
      """

  Scenario: POST - crear un recurso y validar la respuesta
    Given path 'users'
    And request
      """
      {
        "name": "Juan Perez",
        "username": "jperez",
        "email": "jperez@tscat.com"
      }
      """
    When method POST
    Then status 201
    And match response.name == 'Juan Perez'
    And match response.username == 'jperez'
    And match response.email == 'jperez@tscat.com'
    And match response.id == '#number'

  Scenario: PUT - actualizar un recurso existente
    Given path 'users', 1
    And request { name: 'Nombre Actualizado', username: 'actualizado', email: 'nuevo@tscat.com' }
    When method PUT
    Then status 200
    And match response.name == 'Nombre Actualizado'
    And match response.id == 1

  Scenario: DELETE - eliminar un recurso
    Given path 'users', 1
    When method DELETE
    Then status 200

  Scenario: GET con query params y cabeceras
    Given path 'posts'
    And param userId = 1
    And header Accept = 'application/json'
    When method GET
    Then status 200
    And assert response.length > 0
    And match each response contains { userId: 1 }
