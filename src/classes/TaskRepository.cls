public without sharing class TaskRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Task.FieldSets.MyFieldSet;

    public TaskRepository() {
        super(TaskRepository.DEFAULT_FIELD_SET);
    }

    //SOQL
    public Task getById(Id taskId) {
        return (Task)this
            .whereFieldOperatorEqualsValue(Schema.Task.Id, '=', taskId)
            .setAsUpdate()
            .getFirstQueryResult();
    }

     public List<Task> getById(List<Id> taskIdList) {
        return (List<Task>)this
            .whereFieldOperatorEqualsListValues(Schema.Task.Id, 'IN', taskIdList)
            .setAsUpdate()
            .getQueryResults();
    }

    public List<Task> getByWhoId(List<Id> taskWhoIdList) {
        return (List<Task>)this
            .whereFieldOperatorEqualsListValues(Schema.Task.WhoId, 'IN', taskWhoIdList)
            .orderBy(Schema.Task.WhoId)
            .orderBy(Schema.Task.CreatedDate,SObjectRepository.SortOrder.DESCENDING)
            .getQueryResults();
    }

    public List<Task> getByWhatId(List<Id> taskWhatIdList) {
        return (List<Task>)this
            .whereFieldOperatorEqualsListValues(Schema.Task.WhatId,'IN', taskWhatIdList)
            .orderBy(Schema.Task.CreatedDate,SObjectRepository.SortOrder.DESCENDING)
            .getQueryResults();
    }

    public List<Task> getOpenTasksByWhoId(Id whoId) {
        return getOpenTasksByWhoId(new List<Id>{whoId});
    }

    public List<Task> getOpenTasksByWhoId(List<Id> whoIdList) {
        return (List<Task>)this
            .whereFieldOperatorEqualsListValues(Schema.Task.WhoId, 'IN', whoIdList)
            .whereFieldOperatorEqualsValue(Schema.Task.IsClosed, '=', false)
            .orderBy(Schema.Task.WhoId)
            .orderBy(Schema.Task.CreatedDate, SObjectRepository.SortOrder.DESCENDING)
            .getQueryResults();
    }

    public List<Task> getByFieldForWhoIds(Schema.SObjectField field, String value, List<Id> whoIdList) {
        return (List<Task>)this
            .whereFieldOperatorEqualsListValues(Schema.Task.WhoId, 'IN', whoIdList)
            .whereFieldOperatorEqualsValue(field, '=', value)
            .orderBy(Schema.Task.WhoId)
            .orderBy(Schema.Task.CreatedDate, SObjectRepository.SortOrder.DESCENDING)
            .getQueryResults();
    }

    public List<Task> getCreatedSinceTimeValue(Object timeValue) {
        return (List<Task>)this
            .whereFieldOperatorEqualsValue(Schema.Lead.CreatedDate, '>=', timeValue)
            .getQueryResults();
    }

    public List<Task> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, String operator, Object value) {
        return(List<Task>)this
            .whereFieldOperatorEqualsValue(field, '=', operator)
            .whereFieldOperatorEqualsValue(Schema.Task.CreatedDate, '>=', value)
            .getQueryResults();
    }

    //SOSL
    public List<Task> searchInAllFields(String searchTerm) {
        return (List<Task>)this
            .whereFieldOperatorEqualsValue(Schema.Task.IsClosed, '=', false)
            .orderBy(Schema.Task.WhoId)
            .limitCount(10)
            .getSearchResults(searchTerm, SObjectRepository.SearchGroup.ALL_FIELDS);
    }
}