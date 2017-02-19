public without sharing class LeadRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Lead.FieldSets.MyFieldSet;

    public LeadRepository() {
        super(LeadRepository.DEFAULT_FIELD_SET);
    }

    // Overload the constructor if you want to allow other code to specify the field set used
    public LeadRepository(Schema.FieldSet fieldSet, Boolean addCommonQueryFields) {
        super(fieldSet, addCommonQueryFields);
    }

    // ISObjectRepository requires at least 2 methods, getRecord & getList
    public Lead getRecord(Id leadId) {
        String query = this
            .addConditionIdEquals(leadId)
            .setAsForUpdate()
            .getQuery();

        return (Lead)Database.query(query)[0];
    }

    public List<Lead> getList(List<Id> leadIdList) {
        String query = this
            .addConditionIdIn(leadIdList)
            .setAsForUpdate()
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public List<Lead> searchInAllFields(String searchTerm) {
        String query = this
            .addConditionIsConverted(false)
            .getSearchQuery(searchTerm);

        return (List<Lead>)Search.query(query)[0];
    }

    // Add public methods needed that return the query results
    // Only methods that return an SObject or collection of SObjects should be made public
    public List<Lead> getListForSources(List<String> leadSourceList) {
        String query = this
            .addCondition(Schema.Lead.LeadSource + ' IN ' + CollectionUtils.toString(leadSourceList))
            .orderBy(Schema.Lead.CreatedDate)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public List<Lead> getListForStatus(String status, Integer limitCount) {
        String query = this
            .addConditionIsConverted(false)
            .addConditionStatusEquals(status)
            .limitCount(limitCount)
            .orderBy(Schema.Lead.LastModifiedDate, SObjectRepository.SortOrder.DESCENDING)
            .setAsForUpdate()
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    // You can add additional builder methods for any commonly used filters for this SObject
    // All builder methods should be kept as private or protected
    private LeadRepository addConditionIsConverted(Boolean bool) {
        return (LeadRepository)this.addCondition(Schema.Lead.IsConverted + ' = ' + bool);
    }

    private LeadRepository addConditionStatusEquals(String status) {
        return (LeadRepository)this.addCondition(Schema.Lead.Status + ' = ' + StringUtils.wrapInSingleQuotes(status));
    }

}