package tscat.api;

import com.intuit.karate.junit5.Karate;

/**
 * Runner JUnit 5 para los tests de API con Karate.
 *
 * Ejecuta todos los archivos .feature que esten en el mismo paquete
 * (y subpaquetes) que esta clase.
 */
class ApiTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run().relativeTo(getClass());
    }

    // Ejecuta unicamente el feature de usuarios
    @Karate.Test
    Karate testUsers() {
        return Karate.run("users").relativeTo(getClass());
    }

    // Ejecuta unicamente el feature de posts
    @Karate.Test
    Karate testPosts() {
        return Karate.run("posts").relativeTo(getClass());
    }
}
