public class LeadQueryRepository {

    // Each SObject should have its own repository class that contains methods for commonly used queries
    // Each method can use a different field set to generate the query fields,
    // or you can use 1 field set for all methods - tweak the code to fit your use case
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