public without sharing class LeadRepository extends SObjectRepository {

    /** Static bits **/
    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Lead.FieldSets.MyFieldSet;

    public static Lead getLeadById(Id leadId) {
        String query = new LeadRepository()
            .addConditionIdEquals(leadId)
            .getQuery();

        return (Lead)Database.query(query)[0];
    }

    public static List<Lead> getLeadsById(List<Id> leadIdList) {
        String query = new LeadRepository()
            .addConditionIdIn(leadIdList)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public static List<Lead> getLeadsBySource(List<String> leadSourceList) {
        String query = new LeadRepository()
            .addCondition(Schema.Lead.LeadSource + ' IN ' + CollectionUtils.toString(leadSourceList))
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public static List<Lead> getConvertedLeads() {
        String query = new LeadRepository()
            .addConditionIsConverted(true)
            .limitCount(10)
            .orderBy(Schema.Lead.CreatedDate)
            .setAsUpdate(true)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    public static List<Lead> getLeadsByStatus(String status, Integer limitCount) {
        String query = new LeadRepository()
            .addConditionIsConverted(false)
            .addConditionStatusEquals(status)
            .limitCount(limitCount)
            .orderBy(Schema.Lead.LastModifiedDate, SObjectRepository.SortOrder.DESCENDING)
            .setAsUpdate(true)
            .getQuery();

        return (List<Lead>)Database.query(query);
    }

    /** Instance bits **/
    private LeadRepository() {
        super(LeadRepository.DEFAULT_FIELD_SET);
    }

    // You can add additional methods for any commonly used filters for this SObject
    public LeadRepository addConditionIsConverted(Boolean bool) {
        return (LeadRepository)this.addCondition(Schema.Lead.IsConverted + ' = ' + bool);
    }

    public LeadRepository addConditionStatusEquals(String status) {
        return (LeadRepository)this.addCondition(Schema.Lead.Status + ' = ' + StringUtils.wrapInSingleQuotes(status));
    }

}