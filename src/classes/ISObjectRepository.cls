public interface ISObjectRepository {
    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);
    List<SObject> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, String operator, Object value);
    // SOSL
    List<SObject> searchInAllFields(String searchTerm);
}