package tscat.soap;

import com.intuit.karate.junit5.Karate;

class SoapTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run().relativeTo(getClass());
    }
}
