public class LeadQueryRepository {

    public static Lead getLeadById(Id leadId) {
        // Created a string for your where clause
        String whereClause = 'WHERE Id = :leadId';
        // Created a new instance of QueryGenerator, using a field set and your where clause
        String query = new QueryGenerator(SObjectType.Lead.FieldSets.MyFieldSet).buildQuery(whereClause);

        // Database.query returns generic SObjects, so cast it to the desired SObject type & return it
        return (Lead)Database.query(query);
    }

    public static List<Lead> getLeadsByStatus(String status) {
        // Created a string for your where clause
        String whereClause = 'WHERE Status = :status';
        // Created a new instance of QueryGenerator, using a field set and your where clause
        String query = new QueryGenerator(SObjectType.Lead.FieldSets.MyFieldSet).buildQuery(whereClause);

        // Database.query returns generic SObjects, so cast it to the desired SObject type & return it
        return (List<Lead>)Database.query(query);
    }

}