public interface ISObjectRepository {

    ISObjectRepository whereFieldEquals(Schema.SObjectField field, Object value);
    ISObjectRepository whereFieldIn(Schema.SObjectField field, Set<Object> valueSet);
    ISObjectRepository whereFieldIn(Schema.SObjectField field, Map<Id, Object> valueMap);
    ISObjectRepository whereFieldIn(Schema.SObjectField field, List<Object> valueList);
    ISObjectRepository whereIdEquals(Id recordId);
    ISObjectRepository whereIdIn(Set<SObject> recordSet);
    ISObjectRepository whereIdIn(Map<Id, SObject> recordMap);
    ISObjectRepository whereIdIn(List<SObject> recordList);
    ISObjectRepository whereRecordTypeIdEquals(Id recordTypeId);
    ISObjectRepository orderBy(Schema.SObjectField orderByField);
    ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder);
    ISObjectRepository limitCount(Integer limitCount);
    ISObjectRepository setAsUpdate(Boolean bool);

    SObject getRecord();
    List<SObject> getList();

}