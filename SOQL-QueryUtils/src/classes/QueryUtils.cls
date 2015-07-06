public class QueryUtils {
	public static String getSObjectQuery(String sobjectApiName) {
		Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectAPIName);
        
        List<String> fields = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
		 for(Schema.SObjectField sobjectField : fieldMap.values()) {
			fields.add(sobjectField.getDescribe().getName());
		 }
        
        return buildQuery(sobjectApiName, fields);
	}
    
    private static String buildQuery(String sobjectApiName, List<String> fields) {
        String queryFields = String.join(fields, ', ' );
        String query = 'SELECT ' + queryFields
			+ ' FROM ' + sobjectApiName;
        
        return query;
    }

	private static String getQueryFields(List<Schema.FieldSetMember> fieldSet) {
		String queryFields = '';
		for(Schema.FieldSetMember field : fieldSet) {
			queryFields += field.getFieldPath() + ', ';
		}
		queryFields = queryFields.Substring(0, queryFields.length() - 2);

		return queryFields;
	}
}