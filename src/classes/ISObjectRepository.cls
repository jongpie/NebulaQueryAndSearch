public interface ISObjectRepository {

    ISObjectRepository addCondition(String condition);
    ISObjectRepository addConditionIdIn(Set<Id> recordIdSet);
    ISObjectRepository addConditionIdIn(List<Id> recordIdList);
    ISObjectRepository orderBy(Schema.SObjectField orderByField);
    ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder);
    ISObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder, SObjectRepository.NullsSortOrder nullsSortOrder);
    ISObjectRepository limitCount(Integer limitCount);
    ISObjectRepository setAsUpdate(Boolean bool);

    String getQuery();

}