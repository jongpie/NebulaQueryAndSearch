@isTest
public class AccountRepository_Tests {
    @testSetup
    static void setupData() {
        List<Account> accounts = new List<Account>();
        for(Integer i =0; i <3; i++) {
            Account account = new Account();
            account.FirstName = 'George' + i;
            account.LastName = 'Washington';

            accounts.add(account);
        }

        insert accounts;
    }

 @isTest
    static void it_should_return_an_account_by_id() {
        //Given I have a known account Id
        //When I query for that record in particular
        //Then it should be returned
        Account account = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account returnedAccount = new AccountRepository().getById(account.Id);
        Test.stopTest();

        System.assertEquals(account.Id,returnedAccount.Id);
    }

    @isTest
    static void it_should_return_accounts_by_id_list() {
        //Given that I have known accounts
        //When I query for them by Id
        //Then the accounts should be returned

        List<Account> expectedAccounts = [SELECT Id FROM Account];
        List<Id> expectedAccountIds = new List<Id>(new Map<Id, Account>(expectedAccounts).keySet());

        Test.startTest();
        Map<Id,Account> returnedAccountsMap = new Map<Id,Account>(new AccountRepository().getById(expectedAccountIds));
        Test.stopTest();

        System.assertEquals(expectedAccounts.size(),returnedAccountsMap.size());
    }

    @isTest
    static void it_should_return_accounts_for_a_given_time_period() {
        //Given that I have accounts
        //When I query for them with a given field and time range
        //Then only accounts that match both those criteria should be returned
        List<Account> expectedAccounts = [SELECT Id  FROM Account];

        //Now create an account that should not be returned.
        Account account = TestDataGenerator.createPersonAccount();
        account.CreatedDate = System.today().addDays(-1);
        insert account;

        Test.startTest();
        Schema.SObjectField source = Schema.Account.AccountSource;
        Map<Id,Account> returnedAccountsMap = new Map<Id,Account>(new AccountRepository().getByFieldAndTypeForGivenTimePeriod(source, 'Web', new DateLiterals().TODAY));
        Test.stopTest();

        System.assertEquals(expectedAccounts.size(),returnedAccountsMap.size());
        for(Account acc : returnedAccountsMap.values()) {
            System.assertNotEquals(account.Id,acc.Id);
        }
    }

    @isTest
    static void it_should_return_accounts_by_field_for_a_set_of_ids() {
        //Given I have a set of account Ids
        //When I query for those accounts and a specific field
        //Then the matching accounts should be returned
        List<Account> expectedAccounts = [SELECT Id FROM Account];
        Set<Id> accountIds = new Set<Id>(new List<Id>(new Map<Id,Account>(expectedAccounts).keySet()));

        Test.startTest();
        Schema.SObjectField source = Schema.Account.AccountSource;
        List<Account> returnedAccounts = new AccountRepository().getByFieldForIds(source,'Web',accountIds);
        Test.stopTest();

        System.assertEquals(expectedAccounts.size(),returnedAccounts.size());
    }

    @isTest
    static void it_should_return_accounts_by_field_for_a_list_of_ids() {
        //Given I have a list of account Ids
        //When I query for those accounts and a specific field
        //Then the matching accounts should be returned
        List<Account> expectedAccounts = [SELECT Id FROM Account];
        List<Id> accountIds = new List<Id>(new Map<Id,Account>(expectedAccounts).keySet());

        Test.startTest();
        Schema.SObjectField source = Schema.Account.AccountSource;
        List<Account> returnedAccounts = new AccountRepository().getByFieldForIds(source,'Web',accountIds);
        Test.stopTest();

        System.assertEquals(expectedAccounts.size(),returnedAccounts.size());
    }

    @isTest
    static void it_should_return_accounts_that_match_sosl_search_term() {
        //Given that I have a string
        //When I search accounts for that string
        //Then the accounts with a matching string should be returned

        List<Account> expectedAccounts = (List<Account>)[FIND 'Web' IN ALL FIELDS RETURNING Account][0];

        Test.startTest();
        Map<Id,Account> returnedAccountsMap = new Map<Id,Account>(new AccountRepository().searchInAllFields('Web'));
        Test.stopTest();

        for(Account account : expectedAccounts) {
            System.assert(returnedAccountsMap.containsKey(account.Id));
        }
    }
}