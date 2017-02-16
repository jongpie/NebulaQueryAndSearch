@isTest
private class StringUtils_Test {

    @isTest
    static void wrapInSingleQuotes() {
        String originalValue = 'Hola';
        String expectedValue = '\'' + originalValue + '\'';

        Test.startTest();

        System.assertEquals(expectedValue, StringUtils.wrapInSingleQuotes(originalValue));

        Test.stopTest();
    }

}