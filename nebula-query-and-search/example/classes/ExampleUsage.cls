public with sharing class ExampleUsage {
    private static final ExampleUsage SELF = new ExampleUsage();

    private SObjectRepository accountRepo;
    private SObjectRepository contactRepo;

    public ExampleUsage() {
        this.accountRepo = new SObjectRepository(
            Schema.Account.SObjectType,
            new List<SOQL.QueryField>{ new SOQL.QueryField(Schema.Account.Description), new SOQL.QueryField(Schema.Account.OwnerId) }
        );
        this.contactRepo = new SObjectRepository(
            Schema.Contact.SObjectType,
            new List<SOQL.QueryField>{ new SOQL.QueryField(Schema.Contact.FirstName), new SOQL.QueryField(Schema.Contact.LastName) }
        );
    }

    public static void doSomething() {
        List<Account> matchingAccounts = SELF.accountRepo.query(new SOQL.QueryFilter(Account.Name, SOQL.Operator.EQUALS, 'My Account'));
        List<Contact> matchingContacts = SELF.contactRepo.query(
            new List<SOQL.QueryFilter>{
                new SOQL.QueryFilter(Contact.AccountId, SOQL.Operator.IS_IN, matchingAccounts),
                new SOQL.QueryFilter(Contact.LastName, SOQL.Operator.EQUALS, 'SomeName')
            }
        );
        
        for (Contact contact : matchingContacts) {
            // TODO do something
        }
        SELF.contactRepo.updateRecords(matchingContacts, System.AccessLevel.USER_MODE);
    }
}