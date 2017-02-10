public without sharing class LeadRepository extends SObjectRepository {

    /**Static bits**/
    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Lead.FieldSets.MyFieldSet;

    public static Lead getLeadById(Id leadId) {
        return (Lead)new LeadRepository()
            .whereIdEquals(leadId)
            .getRecord();
    }

    public static List<Lead> getConvertedLeads() {
        return new LeadRepository()
            .whereIsConverted(true)
            .limitCount(10)
            .orderBy(Schema.Lead.Name)
            .setAsUpdate(true)
            .getList();
    }

    public static List<Lead> getLeadsByStatus(String status, Integer limitCount) {
        return new LeadRepository()
            .whereIsConverted(false)
            .whereStatusEquals(status)
            .limitCount(limitCount)
            .orderBy(Schema.Lead.Name, SObjectRepository.SortOrder.DESCENDING)
            .setAsUpdate(true)
            .getList();
    }

    /**Instance bits**/
    private LeadRepository() {
        super(LeadRepository.DEFAULT_FIELD_SET);
    }

    public Lead getRecord() {
        return (Lead)super.getSObjectRecord();
    }

    public List<Lead> getList() {
        return (List<Lead>)super.getSObjectList();
    }

    public LeadRepository whereIsConverted(Boolean bool) {
        return (LeadRepository)super.whereFieldEquals(Schema.Lead.IsConverted, bool);
    }

    public LeadRepository whereStatusEquals(String status) {
        return (LeadRepository)this.whereFieldEquals(Schema.Lead.Status, status);
    }

}