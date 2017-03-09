@isTest
private class TaskRepository_Tests {
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

        List<Task> taskList = new List<Task>();
        for(Lead lead : leadList) {
            Task task = new Task(
                Description = 'Call about the ' + staticString(),
                Status      = 'Not Started',
                WhoId       = lead.Id,
                Type__c     = TaskTypes.CALL_OUT
            );

            taskList.add(task);
        }
        insert taskList;

    }

    @isTest
    static void it_should_return_specific_tasks_by_Id() {
        //Given I know the Id of the task
        //When I use getById
        //Then that task should be returned
        Task expectedTask = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();

        Task returnedTask = new TaskRepository().getById(expectedTask.Id);
        System.assertEquals(expectedTask.Id, returnedTask.Id);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_tasks_by_list() {
        //Given that I know task Ids
        //When I use getById
        //Then those tasks should be returned
        List<Task> expectedTaskList = [SELECT Id FROM Task];
        List<Id> expectedTaskIdList = new List<Id>(new Map<Id, Task>(expectedTaskList).keySet());

        Test.startTest();

        List<Task> returnedTaskList = new TaskRepository().getById(expectedTaskIdList);
        System.assertEquals(expectedTaskList.size(), returnedTaskList.size());

        Test.stopTest();
    }

    @isTest
    static void it_should_return_all_open_tasks_by_who_Id() {
        //Given that I know an account or lead Id
        //When I query for all open tasks
        //Then only the open tasks should be returned
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        //Create closed task.  We'll verify that this one in particular is NOT returned in the final asserts.
        Task closedTask = TestDataGenerator.createCommunicationTask(lead.Id, null);
        closedTask.Status = TaskStatuses.COMPLETED;
        insert closedTask;

        Map<Id, Task> expectedTaskMap = new Map<Id, Task>([SELECT Id, WhoId FROM Task WHERE WhoId = :lead.Id AND IsClosed = false]);
        System.assert(expectedTaskMap.size() > 0);

        Test.startTest();
        Map<Id, Task> returnedTaskMap = new Map<Id, Task>(new TaskRepository().getOpenTasksByWhoId(lead.Id));
        Test.stopTest();

        System.assertEquals(returnedTaskMap.size(), returnedTaskMap.size());
        for(Id expectedTaskId : expectedTaskMap.keySet()) {
            System.assert(returnedTaskMap.containsKey(expectedTaskId));
            System.assert(!returnedTaskMap.containsKey(closedTask.Id));
        }
    }

    @isTest
    static void it_should_return_matching_task_when_sObject_field_is_stipulated() {
        //Given that I stipulate a tasks's specific field
        //When I query for that specific field
        //Then only the tasks matching that field's value should be returned
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        //Build the expected task map first - we don't want to include the task that's going to be inserted below
        Map<Id, Task> expectedTaskMap = new Map<Id, Task>([SELECT Id, WhoId, Status FROM Task WHERE WhoId = :lead.Id]);
        System.assert(expectedTaskMap.size() > 0);

        //Create a task that won't match the value we're querying for that's also associated with the same lead
        Task nonMatchingFieldTask = TestDataGenerator.createCommunicationTask(lead.Id, null);
        nonMatchingFieldTask.Status = 'Completed';
        insert nonMatchingFieldTask;

        Test.startTest();
        Schema.SObjectField field = Schema.Task.Status;
        String status = expectedTaskMap.values()[0].Status;
        Map<Id, Task> returnedTaskMap = new Map<Id, Task>(new TaskRepository().getByFieldForWhoIds(field, 'Not Started', new List<Id>{lead.Id}));
        Test.stopTest();

        System.assertEquals(expectedTaskMap.size(), returnedTaskMap.size());
        for(Task tsk : expectedTaskMap.values()) {
            System.assert(returnedTaskMap.containsKey(tsk.Id));
            System.assert(!returnedTaskMap.containsKey(nonMatchingFieldTask.Id));
        }
    }

    @isTest
    static void it_should_not_return_a_task_created_more_than_two_weeks_ago_when_querying_for_last_week() {
        //Given that I have tasks created at different times
        //When I query for a date literal that should exclude certain tasks
        //I should only get the tasks created within that date literals value
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        //Create an additional task that falls outside of the date literals value.
        Task task = TestDataGenerator.createCommunicationTask(lead.Id, null);
        task.CreatedDate = (Datetime)System.today().addDays(-15);
        insert task;

        Test.startTest();
        Map<Id, Task> returnedTaskMap = new Map<Id,Task>(new TaskRepository().getCreatedSinceTimeValue(new DateLiterals().LAST_WEEK));
        Test.stopTest();

        System.assert(returnedTaskMap.size() > 0);
        System.assert(!returnedTaskMap.containsKey(task.Id));
    }

    @isTest
    static void it_should_return_by_who_id() {
        //Given that I have a known account or lead lookup
        //When I query for tasks with that value
        //I should only get the tasks for the whoId provided
        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];
        Lead lead2 = [SELECT Id FROM Lead WHERE Id != :lead1.Id LIMIT 1];

        Test.startTest();
        Map<Id,Task> returnedTaskMap = new Map<Id,Task>(new TaskRepository().getByWhoId(new List<Id>{lead1.Id}));
        Test.stopTest();

        for(Task tsk : returnedTaskMap.values()) {
            System.assertNotEquals(lead2.Id,tsk.WhoId);
            System.assertEquals(lead1.Id,tsk.WhoId);
        }
    }

    @isTest
    static void it_should_return_by_what_id() {
        //Given that I have an object id related to an account or lead
        //If I query for tasks related to that object
        //Then only tasks related to that object's parent (lead or account) should be returned
        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];

        WebConversion__c wc = TestDataGenerator.createWebConversion(lead1.Id);
        insert wc;

        Lead lead2 = [SELECT Id FROM Lead WHERE Id != :lead1.Id LIMIT 1];

        Test.startTest();
        Map<Id,Task> returnedTaskMap = new Map<Id,Task>(new TaskRepository().getByWhatId(new List<Id>{wc.Id}));
        Test.stopTest();

        for(Task tsk : returnedTaskMap.values()) {
            System.assertNotEquals(lead2.Id,tsk.WhoId);
            System.assertEquals(lead1.Id,tsk.WhoId);
        }
    }

    @isTest
    static void it_should_return_by_stipulated_operator_and_soql_value() {
        //Given I want to find something like all promotional material created today
        //When I query for the tasks that match that description
        //Then I should only get those tasks returned to me

        //Address is required for mailings.  Create one to avoid an error being thrown when creating the request task!
        //Trigger settings are required to set up the mailing address fields on the request task being inserted
        TestDataGenerator.insertTriggerSettings();
        Address__c address = TestDataGenerator.createAddress();
        insert address;

        List<Lead> leads = [SELECT Id FROM Lead LIMIT 1];

        Task task = TestDataGenerator.createCatalogTask(leads[0].Id, address.Id);
        insert task;

        Test.startTest();
        String catalogType = TaskTypes.PROMOTIONAL_MATERIAL;
        Schema.SObjectField taskType = Schema.Task.Type__c;
        Map<Id,Task> returnedTaskMap = new Map<Id,Task>(new TaskRepository().getByFieldAndTypeForGivenTimePeriod(taskType, catalogType, new DateLiterals().TODAY));

        System.assertEquals(leads.size(),returnedTaskMap.size());
        System.assert(returnedTaskMap.containsKey(task.Id));
    }

    @isTest
    static void it_should_return_appropriate_tasks_when_querying_with_SOSL() {
        //Given that I have a string that I would like to find the first 10 matching tasks for
        //When I query for that string
        //Then I should get the tasks that match that string returned
        String searchTerm = staticString();
        List<Task> expectedTaskList = (List<Task>)[FIND :searchTerm IN ALL FIELDS RETURNING Task(Id WHERE IsClosed = false)][0];

        Test.startTest();

        List<Task> returnedTaskList = new TaskRepository().searchInAllFields(searchTerm);
        System.assertEquals(expectedTaskList.size(), returnedTaskList.size());

        Test.stopTest();
    }

    private static String staticString() {
        String value = 'thing';
        return value;
    }
}