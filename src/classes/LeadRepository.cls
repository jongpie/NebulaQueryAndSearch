public without sharing class LeadRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Lead.FieldSets.MyFieldSet;

    public LeadRepository() {
        super(LeadRepository.DEFAULT_FIELD_SET);
    }

    public LeadRepository(Schema.FieldSet fieldSet, Boolean addCommonQueryFields) {
        super(fieldSet, addCommonQueryFields);
    }

    // ISObjectRepository requires at least 2 methods, getRecord & getList
    public Lead getRecord(Id leadId) {
        String query = this
            .addConditionIdEquals(leadId)
            .setAsUpdate(true)
            .getQuery();

        return (Lead)Database.query(query)[0];
    }

    public Lead getList(List<Id> leadIdList) {
        String query = this
            .addConditionIdIn(leadIdList)
            .setAsUpdate(true)
            .getQuery();

        return (Lead)Database.query(query)[0];
    }

    // Add public methods that return the results of any queries needed
    // All 'builder' methods should be kept as private or protected
    public List<Lead> getListForSources(List<String> leadSourceList) {
        String query = this
            .addCondition(Schema.Lead.LeadSource + ' IN ' + CollectionUtils.toString(leadSourceList))
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public List<Lead> getRecentlyConvertedList() {
        String query = this
            .addConditionIsConverted(true)
            .addCondition(Schema.Lead.ConvertedDate + ' >= N_DAYS_AGO:7')
            .limitCount(10)
            .orderBy(Schema.Lead.ConvertedDate, SObjectRepository.SortOrder.DESCENDING)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public List<Lead> getListForStatus(String status, Integer limitCount) {
        String query = this
            .addConditionIsConverted(false)
            .addConditionStatusEquals(status)
            .limitCount(limitCount)
            .orderBy(Schema.Lead.LastModifiedDate, SObjectRepository.SortOrder.DESCENDING)
            .setAsUpdate(true)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    // You can add additional methods for any commonly used filters for this SObject
    private LeadRepository addConditionIsConverted(Boolean bool) {
        return (LeadRepository)this.addCondition(Schema.Lead.IsConverted + ' = ' + bool);
    }

    private LeadRepository addConditionStatusEquals(String status) {
        return (LeadRepository)this.addCondition(Schema.Lead.Status + ' = ' + StringUtils.wrapInSingleQuotes(status));
    }

}