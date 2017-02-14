public without sharing class CollectionUtils {

    public static String toString(Set<SObject> recordSet) {
        return toString(new List<SObject>(recordSet));
    }

    public static String toString(List<SObject> recordList) {
        return toString(new Map<Id, SObject>(recordList).keySet());
    }

    public static String toString(Set<Id> recordIdSet) {
        return toString(new List<Id>(recordIdSet));
    }

    public static String toString(List<Id> recordIdList) {
        return toString(recordIdList, true);
    }

    public static String toString(List<Id> recordIdList, Boolean wrapWithParentheses) {
        List<String> recordIdStringList = new List<String>();
        for(Id recordId : recordIdList) recordIdStringList.add('\'' + recordId + '\'');

        String parsedString = String.join(recordIdStringList, ',');

        if(wrapWithParentheses) parsedString = '(' + parsedString + ')';

        return parsedString;
    }

}