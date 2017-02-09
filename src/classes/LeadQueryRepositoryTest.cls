@isTest
private class LeadQueryRepositoryTest {

    @testSetup
    static void setup() {
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            Lead lead = new Lead(
                Company  = 'My Test Company',
                LastName = 'Gillespie'
            );
            leadList.add(lead);
        }
        insert leadList;
    }

    @isTest
    static void getLeadById_Test() {
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();

        Lead returnedLead = LeadQueryRepository.getLeadById(expectedLead.Id);

        Test.stopTest();
    }

    @isTest
    static void getLeadsById_WHEN_parameterIsAListOfIds() {
        List<Lead> expectedLeads    = [SELECT Id FROM Lead];
        List<Id> expectedLeadIdList = new List<Id>(new Map<Id, Lead>(expectedLeads).keySet());

        Test.startTest();

        List<Lead> returnedLeadList = LeadQueryRepository.getLeadsById(expectedLeadIdList);

        Test.stopTest();
    }

    @isTest
    static void getLeadsById_WHEN_parameterIsAListOfRecords() {
        List<Lead> expectedLeadList = [SELECT Id FROM Lead];

        Test.startTest();

        List<Lead> returnedLeads = LeadQueryRepository.getLeadsById(expectedLeadList);

        Test.stopTest();
    }

    @isTest
    static void getLeadsById_WHEN_parameterIsAMap() {
        Map<Id, Lead> expectedLeadMap = new Map<Id, Lead>([SELECT Id FROM Lead]);

        Test.startTest();

        List<Lead> returnedLeads = LeadQueryRepository.getLeadsById(expectedLeadMap);

        Test.stopTest();
    }

    @isTest
    static void getLeadsById_WHEN_parameterIsASetOfIds() {
        Set<Id> expectedLeadIdSet = new Map<Id, Lead>([SELECT Id FROM Lead]).keySet();

        Test.startTest();

        List<Lead> returnedLeadList = LeadQueryRepository.getLeadsById(expectedLeadIdSet);

        Test.stopTest();
    }

    @isTest
    static void getLeadsByStatus() {
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];

        Test.startTest();

        List<Lead> returnedLeadList = LeadQueryRepository.getLeadsByStatus(lead.Status);

        Test.stopTest();
    }

    @isTest
    static void getLeadsByStatuses() {
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];
        List<String> leadStatusList = new List<String>{lead.Status};

        Test.startTest();

        List<Lead> returnedLeadList = LeadQueryRepository.getLeadsByStatuses(leadStatusList);

        Test.stopTest();
    }

}