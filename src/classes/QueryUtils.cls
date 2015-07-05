public class QueryUtils {
	private static String getQueryFields(List<Schema.FieldSetMember> fieldSet) {
		String queryFields = '';
		for(Schema.FieldSetMember field : fieldSet) {
			queryFields += field.getFieldPath() + ', ';
		}
		queryFields = queryFields.Substring(0, queryFields.length() - 2);

		return queryFields;
	}
}