public without sharing class CollectionUtils {

    public static String toString(List<SObject> recordList) {
        List<String> recordIdStringList = new List<String>();
        for(SObject record : recordList) recordIdStringList.add(record.Id);
        return toString(recordIdStringList);
    }

    public static String toString(Set<Id> recordIdSet) {
        List<String> stringList = new List<String>();
        for(Id recordId : new List<Id>(recordIdSet)) stringList.add(recordId);
        return toString(stringList);
    }

    public static String toString(Set<String> stringSet) {
        return toString(new List<String>(stringSet));
    }

    public static String toString(List<String> stringList) {
        return toString(stringList, true);
    }

    public static String toString(List<String> stringList, Boolean wrapWithParentheses) {
        List<String> parsedStringList = new List<String>();
        for(String str : stringList) parsedStringList.add('\'' + str + '\'');

        String parsedString = String.join(parsedStringList, ',');

        if(wrapWithParentheses) parsedString = '(' + parsedString + ')';

        return parsedString;
    }

}