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
                Description = 'Call about the thing',
                Status      = 'Not Started',
                WhoId       = lead.Id
            );
            taskList.add(task);
        }
        insert taskList;
    }

    @isTest
    static void it_should_return_specific_tasks_by_Id() {
        Task expectedTask = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();

        Task returnedTask = new TaskRepository().getRecord(expectedTask.Id);
        System.assertEquals(expectedTask.Id, returnedTask.Id);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_tasks_by_list() {
        List<Task> expectedTaskList = [SELECT Id FROM Task];
        List<Id> expectedTaskIdList = new List<Id>(new Map<Id, Task>(expectedTaskList).keySet());

        Test.startTest();

        List<Task> returnedTaskList = new TaskRepository().getList(expectedTaskIdList);
        System.assertEquals(expectedTaskList.size(), returnedTaskList.size());

        Test.stopTest();
    }

    @isTest
    static void it_should_return_all_open_tasks_by_who_Id() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Map<Id, Task> expectedTaskMap = new Map<Id, Task>([SELECT Id, WhoId FROM Task WHERE WhoId = :lead.Id AND IsClosed = false]);
        System.assert(expectedTaskMap.size() > 0);

        Test.startTest();

        Map<Id, Task> returnedTaskMap = new Map<Id, Task>(new TaskRepository().getListOfOpenForWhoId(lead.Id));
        System.assertEquals(returnedTaskMap.size(), returnedTaskMap.size());
        for(Id expectedTaskId : expectedTaskMap.keySet()) {
            System.assert(returnedTaskMap.containsKey(expectedTaskId));
        }

        Test.stopTest();
    }

    @isTest
    static void searchInAllFields() {
    @isTest
    static void it_should_not_return_a_task_created_more_than_two_weeks_ago_when_querying_for_last_week() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Task task = TestDataGenerator.createCommunicationTask(lead.Id, null);
        task.CreatedDate = (Datetime)System.today().addDays(-15);

        Test.startTest();
        Map<Id, Task> returnedTaskMap = new Map<Id,Task>(new TaskRepository().getListOfCreatedSinceLastWeek());
        Test.stopTest();

        for(Task tsk : returnedTaskMap.values()) {
            System.assertEquals(false,returnedTaskMap.containsKey(task.Id));
        }
    }

    @isTest
    static void it_should_return_appropriate_tasks_when_querying_with_SOSL() {
        String searchTerm = 'thing';
        List<Task> expectedTaskList = (List<Task>)[FIND :searchTerm IN ALL FIELDS RETURNING Task(Id WHERE IsClosed = false)][0];

        Test.startTest();

        List<Task> returnedTaskList = new TaskRepository().searchInAllFields(searchTerm);
        System.assertEquals(expectedTaskList.size(), returnedTaskList.size());

        Test.stopTest();
    }

}