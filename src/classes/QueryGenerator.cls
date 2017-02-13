public without sharing class QueryGenerator {

    // Each query repository class will have one or more methods that handle generating a query
    // This class handles taking a fieldSet and an optional string for a WHERE statement
    // Everything is parsed and a query string is returned to the originating query repository class
    // The query repository should handle executing the query so that any relevant variables are in scope
    // Finally, it should cast the SObjects to the appropriate SObjectType

    private Schema.FieldSet fieldSet;
    private SObjectType sobjectType;
    private Set<String> queryFields;

    public QueryGenerator(Schema.FieldSet fieldSet) {
        this.fieldSet    = fieldSet;

        this.sobjectType = fieldSet.getSObjectType();
        this.queryFields = new Set<String>{'Id'}; // Always add the ID field, just in case it's not in the field set

        this.parseFieldSetMembers();
    }

    public String buildQuery() {
        return this.buildQuery(null);
    }

    public String buildQuery(String whereClause) {
        String query =
            'SELECT ' + String.join(new List<String>(this.queryFields), ', ')
            + ' FROM ' + this.sobjectType;

        if(!String.isEmpty(whereClause)) query += ' ' + whereClause;

        return query;
    }

    private void parseFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath());
    }

}