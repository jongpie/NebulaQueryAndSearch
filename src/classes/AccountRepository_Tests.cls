@isTest
public class AccountRepository_Tests {
    @testSetup
    static void setupData() {
        List<Account> accounts = new List<Account>();
        for(Integer i =0; i <3; i++) {
            Account account = new Account();
            account.FirstName = 'George' + i;
            account.LastName = 'Washington';
            account.AladdinCustomerId__c = (Decimal)RandomizerUtils.generateInteger(10) + i;

            accounts.add(account);
        }

        insert accounts;
    }

    @isTest
    static void it_should_return_an_account_by_id() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account returnedAccount = new AccountRepository().getById(account.Id);
        Test.stopTest();

        System.assertEquals(account.Id,returnedAccount.Id);
    }
}