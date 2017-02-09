public class LeadQueryRepository {

    // Each SObject should have its own repository class that contains methods for commonly used queries
    // Each method can use a different field set to generate the query fields,
    // or you can use 1 field set for all methods - tweak the code to fit your use case

    // One of the most common use cases is querying for a record or list of records by ID(s)
    // The simplest way is to have some overloaded methods with self-descriptive names
    // The methods then use your desired field set to generate & execute the query
    public static Lead getLeadById(Id leadId) {
        return getLeadsById(new Set<Id>{leadId})[0];
    }

    public static List<Lead> getLeadsById(List<Lead> leadList) {
        return getLeadsById(new Map<Id, Lead>(leadList).keySet());
    }

    public static List<Lead> getLeadsById(List<Id> leadIdSet) {
        return getLeadsById(new Set<Id>(leadIdSet));
    }

    public static List<Lead> getLeadsById(Map<Id, Lead> leadMap) {
        return getLeadsById(leadMap.keySet());
    }

    public static List<Lead> getLeadsById(Set<Id> leadIdSet) {
        // Created a string for your where clause
        String whereClause = 'WHERE ' +  Schema.Lead.Id + ' IN :leadIdSet';
        // Created a new instance of QueryGenerator, using a field set and your where clause
        String query = new QueryGenerator(SObjectType.Lead.FieldSets.MyFieldSet).buildQuery(whereClause);

        // Database.query returns generic SObjects, so cast it to the desired SObject type & return it
        return (List<Lead>)Database.query(query);
    }

    // Another common use case is to query for status (or list of statuses) or similar field (like opportunity stage)
    // These methods can all be placed into the same query repository class, or you could further break things down
    // into multiple classes for the same SObjectType. Adapt to your use cases, but keep it simple
    public static List<Lead> getLeadsByStatus(String status) {
        return getLeadsByStatuses(new List<String>{status});
    }

    public static List<Lead> getLeadsByStatuses(List<String> statuses) {
        String whereClause = 'WHERE ' + Schema.Lead.Status + ' IN :statuses';
        String query = new QueryGenerator(SObjectType.Lead.FieldSets.MyFieldSet).buildQuery(whereClause);

        return (List<Lead>)Database.query(query);
    }

}