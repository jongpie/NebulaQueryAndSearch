public interface ISObjectRepository {

    SObject getRecord(Id recordId);
    SObject getList(List<Id> recordIdList);

}