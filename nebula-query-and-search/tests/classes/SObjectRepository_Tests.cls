/*************************************************************************************************
 * This file is part of the Nebula Framework project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
 *************************************************************************************************/
@IsTest
private class SObjectRepository_Tests {
    private class AccountRepository extends SObjectRepository {
        // Test subclass that extends SObjectRepository
        public AccountRepository() {
            super(Schema.Account.SObjectType);
        }

        public List<Account> getMyRecentAccounts(Integer limitCount) {
            return (List<Account>) new Query(this.getSObjectType())
                .usingScope(SOQL.Scope.MINE)
                .limitTo(limitCount)
                .orderByField(new SOQL.QueryField(Schema.Account.LastActivityDate))
                .getResults();
        }

        public Account getAccountAndContactsWithEmails(Id accountId) {
            return (Account) new Query(this.getSObjectType())
                .filterWhere(new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.Id), SOQL.Operator.EQUALS, accountId))
                .includeRelatedRecords(
                    Schema.Contact.AccountId,
                    new Query(Schema.Contact.SObjectType)
                        .addFields(SOQL.FieldCategory.STANDARD)
                        .filterWhere(new SOQL.QueryFilter(new SOQL.QueryField(Schema.Contact.Email), SOQL.Operator.NOT_EQUAL_TO, null))
                )
                .getFirstResult();
        }
    }

    private class UserRepository extends SObjectRepository {
        public UserRepository() {
            super(Schema.User.SObjectType);
        }

        public override List<Database.UpsertResult> upsertRecords(SObject record, Schema.SObjectField externalIdField) {
            return super.upsertRecords(record, externalIdField);
        }
    }

    static Account createAccount() {
        Account account = new Account(Name = 'My Test Company');
        return account;
    }

    static Contact createContact(Id accountId) {
        Contact contact = new Contact(AccountId = accountId, LastName = 'Gillespie');
        return contact;
    }

    @testSetup
    static void setupData() {
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accountList.add(createAccount());
        }
        insert accountList;
    }

    @IsTest
    static void it_should_instantiate_new_instance_with_fieldset() {
        // We don't want to include unnecessary metadata in this project, like custom field sets, but we still want to test functionality
        // We'll pass a null field set to make sure a field set can be used, even though the value is null
        Schema.FieldSet fieldSet;

        Test.startTest();
        AccountRepository accountRepo = new AccountRepository();
        System.assertNotEquals(null, accountRepo);
        Test.stopTest();
    }

    @IsTest
    static void it_should_get_by_id_when_id() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account returnedAccount = (Account) new AccountRepository().query(expectedAccount.Id);
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @IsTest
    static void it_should_get_by_id_using_query_filter() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        SOQL.QueryFilter queryFilter = new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.Id), SOQL.Operator.EQUALS, expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>) new AccountRepository().query(queryFilter))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @IsTest
    static void it_should_get_by_id_using_list_of_query_filters() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        SOQL.QueryFilter queryFilter = new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.Id), SOQL.Operator.EQUALS, expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>) new AccountRepository().query(new List<SOQL.QueryFilter>{ queryFilter }))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @IsTest
    static void it_should_get_by_id_when_list_of_id() {
        Map<Id, Account> expectedAccountList = new Map<Id, Account>([SELECT Id FROM Account]);

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>) new AccountRepository().query(new List<Id>(expectedAccountList.keySet()));
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @IsTest
    static void it_should_return_my_recent_accounts() {
        List<Account> expectedAccountList = [SELECT Id FROM Account LIMIT 2];

        Test.startTest();
        List<Account> returnedAccountList = new AccountRepository().getMyRecentAccounts(expectedAccountList.size());
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    // @IsTest
    // static void it_should_return_for_ids_in_set_and_query_filters() {
    //     Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account]);
    //     SObjectRepository repo = new AccountRepository();

    //     Test.startTest();
    //     SOQL.QueryFilter queryFilter = new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.Name), SOQL.Operator.EQUALS, 'My Test Company');
    //     List<SOQL.QueryFilter> queryFilters = new List<SOQL.QueryFilter>{ queryFilter };
    //     List<Account> returnedAccountList = (List<Account>) repo.getByIdAndQueryFilters(expectedAccountMap.keyset(), queryFilters);
    //     Test.stopTest();

    //     System.assertNotEquals(null, expectedAccountMap);
    //     System.assert(!expectedAccountMap.isEmpty());
    //     System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    // }

    // @IsTest
    // static void it_should_return_by_field_for_ids_in_list() {
    //     Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account]);
    //     List<Schema.SObjectField> accountFields = new List<Schema.SObjectField>{ Schema.Account.Id, Schema.Account.Name };
    //     SObjectRepository repo = new AccountRepository();

    //     Test.startTest();
    //     SOQL.QueryFilter queryFilter = new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.Name), SOQL.Operator.EQUALS, 'My Test Company');
    //     List<SOQL.QueryFilter> queryFilters = new List<SOQL.QueryFilter>{ queryFilter };
    //     List<Account> returnedAccountList = (List<Account>) repo.getByIdAndQueryFilters(new List<Id>(expectedAccountMap.keyset()), queryFilters);
    //     Test.stopTest();

    //     System.assertNotEquals(null, expectedAccountMap);
    //     System.assert(!expectedAccountMap.isEmpty());
    //     System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    // }

    @IsTest
    static void it_should_return_account_and_contacts_as_children_records() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Contact contact = createContact(account.Id);
        contact.Email = 'test@email.com';
        insert contact;
        contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(account.Id, contact.AccountId);

        Account expectedAccount = [
            SELECT Id, (SELECT Id, AccountId FROM Contacts WHERE Email != NULL)
            FROM Account
            WHERE Id = :account.Id
        ];
        System.assertEquals(1, expectedAccount.Contacts.size());

        Test.startTest();
        // Make sure that we have 0 queries used so far
        System.assertEquals(0, Limits.getQueries());

        account = new AccountRepository().getAccountAndContactsWithEmails(account.Id);

        // Make sure that the account & contact query only counts as a singlequery
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

        System.assertEquals(expectedAccount.Contacts.size(), account.Contacts.size());
        Contact firstContact = account.Contacts[0];
        System.assertEquals(contact.Id, firstContact.Id);
    }

    @IsTest
    static void it_should_search_for_search_term() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>) new AccountRepository().search(searchTerm);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @IsTest
    static void it_should_search_for_search_term_and_search_group() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>) new AccountRepository().search(searchTerm, SOSL.SearchGroup.NAME_FIELDS);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @IsTest
    static void it_should_search_for_search_term_and_search_group_and_query_filters() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        SOQL.QueryFilter queryFilter = new SOQL.QueryFilter(new SOQL.QueryField(Schema.Account.CreatedDate), SOQL.Operator.EQUALS, SOQL.FixedDateLiteral.TODAY);
        List<SOQL.QueryFilter> queryFilters = new List<SOQL.QueryFilter>{ queryFilter };
        List<Account> returnedAccountList = (List<Account>) new AccountRepository().search(searchTerm, SOSL.SearchGroup.NAME_FIELDS, queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @IsTest
    static void it_should_insert_a_single_record() {
        Account account = createAccount();
        System.assertEquals(null, account.Id);

        Test.startTest();
        new AccountRepository().insertRecords(account);
        Test.stopTest();

        System.assertNotEquals(null, account.Id);

        List<Account> queriedAccountList = [SELECT Id FROM Account WHERE Id = :account.Id];
        System.assertEquals(1, queriedAccountList.size());
        System.assertEquals(queriedAccountList[0].Id, account.Id);
    }

    @IsTest
    static void it_should_update_a_single_record() {
        Account existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        Datetime originalLastModifiedDate = existingAccount.LastModifiedDate;

        Test.startTest();
        new AccountRepository().updateRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        System.assert(existingAccount.LastModifiedDate > originalLastModifiedDate, existingAccount);
    }

    @IsTest
    static void it_should_upsert_a_single_new_record() {
        Account newAccount = createAccount();
        System.assertEquals(null, newAccount.Id);

        Test.startTest();
        new AccountRepository().upsertRecords(newAccount);
        Test.stopTest();

        System.assertNotEquals(null, newAccount.Id);
    }

    @IsTest
    static void it_should_upsert_a_single_existing_record() {
        Account existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        Datetime originalLastModifiedDate = existingAccount.LastModifiedDate;

        Test.startTest();
        new AccountRepository().upsertRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        System.assert(existingAccount.LastModifiedDate > originalLastModifiedDate, existingAccount);
    }

    @IsTest
    static void it_should_upsert_a_single_existing_record_with_external_id() {
        User existingUser = [SELECT Id, LastModifiedDate, Username FROM User WHERE Id = :UserInfo.getUserId()];
        Datetime originalLastModifiedDate = existingUser.LastModifiedDate;
        System.assertNotEquals(null, existingUser.Username);

        Test.startTest();
        new SObjectRepository_Tests.UserRepository().upsertRecords(existingUser, Schema.User.Username);
        Test.stopTest();

        existingUser = [SELECT Id, LastModifiedDate FROM User LIMIT 1];
        System.assert(existingUser.LastModifiedDate > originalLastModifiedDate, existingUser);
    }

    @IsTest
    static void it_should_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new AccountRepository().deleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(true, existingAccount.IsDeleted);
    }

    @IsTest
    static void it_should_hard_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new AccountRepository().hardDeleteRecords(existingAccount);
        Test.stopTest();

        List<Account> existingAccountList = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assert(existingAccountList[0].IsDeleted);
    }

    @IsTest
    static void it_should_undelete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        delete existingAccount;

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(true, existingAccount.IsDeleted);

        Test.startTest();
        new AccountRepository().undeleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(false, existingAccount.IsDeleted);
    }
}