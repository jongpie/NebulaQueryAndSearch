public without sharing class TaskQueryRepository {

    // This class largely follows the same pattern as LeadQueryRepository.cls
    // For more information on how these classes should work, refer to the lead class
    // The main difference in this class is the inclusion of the getTasksByWhoId methods
    // Even though you may want to get all tasks for a lead, the query to handle
    // querying for those records should live in this class since ultimately
    // they are task records, so they fall under the TaskQueryRepository's domain

    public static Task getTaskById(Id taskid) {
        return getTasksById(new Set<Id>{taskid})[0];
    }

    public static List<Task> getTasksById(List<Task> taskList) {
        return getTasksById(new Map<Id, Task>(taskList).keySet());
    }

    public static List<Task> getTasksById(List<Id> taskIdSet) {
        return getTasksById(new Set<Id>(taskIdSet));
    }

    public static List<Task> getTasksById(Map<Id, Task> taskMap) {
        return getTasksById(taskMap.keySet());
    }

    public static List<Task> getTasksById(Set<Id> taskIdSet) {
        String whereClause = 'WHERE ' +  Schema.Task.Id + ' IN :taskIdSet';
        String query = new QueryGenerator(SObjectType.Task.FieldSets.MyFieldSet).buildQuery(whereClause);

        return (List<Task>)Database.query(query);
    }

    public static List<Task> getTasksByWhoId(Id whoId) {
        return getTasksByWhoIds(new List<Id>{whoId});
    }

    public static List<Task> getTasksByWhoIds(List<Id> whoIdList) {
        String whereClause = 'WHERE ' + Schema.Task.WhoId + ' IN :whoIdList';
        String query = new QueryGenerator(SObjectType.Task.FieldSets.MyFieldSet).buildQuery(whereClause);

        return (List<Task>)Database.query(query);
    }

}