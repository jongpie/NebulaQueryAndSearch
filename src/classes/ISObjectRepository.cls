public interface ISObjectRepository {

    SObject getRecord(Id recordId);
    List<SObject> getList(List<Id> recordIdList);

}