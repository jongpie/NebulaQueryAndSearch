public without sharing class TaskRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Task.FieldSets.MyFieldSet;

    public TaskRepository() {
        super(TaskRepository.DEFAULT_FIELD_SET);
    }

    public Task getRecord(Id taskId) {
        String query = this
            .addConditionIdEquals(taskId)
            .setAsUpdate()
            .getQuery();

        return (Task)Database.query(query)[0];
    }

     public List<Task> getList(List<Id> taskIdList) {
        String query = this
            .addConditionIdIn(taskIdList)
            .setAsUpdate()
            .getQuery();

        return (List<Task>)Database.query(query);
    }

    public List<Task> getListOfOpenForWhoId(Id whoId) {
        return getListOfOpenForWhoId(new List<Id>{whoId});
    }

    public List<Task> getListOfOpenForWhoId(List<Id> whoIdList) {
        String query = this
            .addConditionWhoIdIn(whoIdList)
            .addConditionIsClosed(false)
            .orderBy(Schema.Task.WhoId)
            .orderBy(Schema.Task.CreatedDate, SObjectRepository.SortOrder.DESCENDING)
            .getQuery();

        return (List<Task>)Database.query(query);
    }

    public List<Task> searchInAllFields(String searchTerm) {
        String query = this
            .addConditionIsClosed(false)
            .orderBy(Schema.Task.WhoId)
            .limitCount(10)
            .getSearchQuery(searchTerm, SObjectRepository.SearchGroup.ALL_FIELDS);

        return (List<Task>)Search.query(query)[0];
    }

    private TaskRepository addConditionIsClosed(Boolean bool) {
        return (TaskRepository)this.addCondition(Schema.Task.IsClosed + ' = ' + bool);
    }

    private TaskRepository addConditionWhoIdIn(List<Id> whoIdList) {
        return (TaskRepository)this.addCondition(Schema.Task.WhoId + ' IN ' + CollectionUtils.toString(whoIdList));
    }

}