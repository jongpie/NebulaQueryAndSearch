@isTest
private class CollectionUtils_Test {

    @testSetup
    static void setupData() {
        List<Lead> leadToInsertList = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            Lead leadToInsert = new Lead(
                Company  = 'My Test Company',
                LastName = 'Gillespie ' + i
            );
            leadToInsertList.add(leadToInsert);
        }

        insert leadToInsertList;
    }

    @isTest
    static void toString_WHEN_recordList() {
                List<Lead> leadList = [SELECT Id FROM Lead];
        List<Id> leadIdList = new List<Id>(new Map<Id, Lead>(leadList).keySet());

        String expectedString = '(\'' + String.join(leadIdList, '\',\'') + '\')';
        String returnedString = CollectionUtils.toString(leadList);

        System.assertEquals(expectedString, returnedString);
    }

    @isTest
    static void toString_WHEN_recordIdSet() {
        List<Lead> leadList = [SELECT Id FROM Lead];
        List<Id> leadIdList = new List<Id>(new Map<Id, Lead>(leadList).keySet());

        String expectedString = '(\'' + String.join(leadIdList, '\',\'') + '\')';
        String returnedString = CollectionUtils.toString(new Map<Id, Lead>(leadList).keySet());

        System.assertEquals(expectedString, returnedString);
    }

    @isTest
    static void toString_WHEN_recordIdList() {
        List<Lead> leadList = [SELECT Id FROM Lead];
        List<Id> leadIdList = new List<Id>(new Map<Id, Lead>(leadList).keySet());

        String expectedString = '(\'' + String.join(leadIdList, '\',\'') + '\')';
        String returnedString = CollectionUtils.toString(leadIdList);

        System.assertEquals(expectedString, returnedString);
    }

    @isTest
    static void toString_WHEN_stringSet() {
        Set<String> stringSet = new Set<String>{'Hola', 'Hello'};

        String expectedString = '(\'' + String.join(new List<String>(stringSet), '\',\'') + '\')';
        String returnedString = CollectionUtils.toString(stringSet);

        System.assertEquals(expectedString, returnedString);
    }

    @isTest
    static void toString_WHEN_stringList() {
        List<String> stringList = new List<String>{'Hola', 'Hello'};

        String expectedString = '(\'' + String.join(stringList, '\',\'') + '\')';
        String returnedString = CollectionUtils.toString(stringList);

        System.assertEquals(expectedString, returnedString);
    }

}