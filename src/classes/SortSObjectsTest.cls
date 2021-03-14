/**
 * Test class for SortSObjects
 */
@IsTest
public with sharing class SortSObjectsTest {

    @IsTest
    private static void testSortStrings() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(null);
        contacts.add(new Contact(FirstName = 'FirstName2', LastName = 'LastName1'));
        contacts.add(new Contact(FirstName = 'FirstName2'));
        contacts.add(new Contact(FirstName = 'FirstName10', LastName = 'LastName1'));
        contacts.add(new Contact(FirstName = 'FirstName2', LastName = 'LastName2'));
        contacts.add(new Contact(FirstName = 'FirstName3', LastName = 'LastName1'));

        List<Integer> correctSortingResult = new List<Integer>{3, 1, 4, 2, 5, 0};

        List<Contact> sortedContacts = new SortSObjects()
                .ascending(Contact.FirstName)
                .ascending(Contact.LastName)
                .sort(contacts);

        for (Integer i = 0; i < correctSortingResult.size(); i++) {
            System.assertEquals(contacts.get(correctSortingResult.get(i)), sortedContacts.get(i));
        }
    }

    @IsTest
    private static void testSortDatetimes() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 6; i++) {
            contacts.add(new Contact());
        }
        contacts[1] = (Contact) setNotWritableField(contacts[1], Contact.CreatedDate, Datetime.now());
        contacts[2] = (Contact) setNotWritableField(contacts[2], Contact.CreatedDate, Datetime.now().addHours(-5));
        contacts[3] = (Contact) setNotWritableField(contacts[3], Contact.CreatedDate, Datetime.now().addHours(2));
        contacts[4] = (Contact) setNotWritableField(contacts[4], Contact.CreatedDate, Datetime.now().addHours(1));
        contacts[5] = (Contact) setNotWritableField(contacts[5], Contact.CreatedDate, Datetime.now().addHours(-10));

        List<Integer> correctSortingResult = new List<Integer>{3, 4, 1, 2, 5, 0};

        List<Contact> sortedContacts = new SortSObjects()
                .descending(Contact.CreatedDate)
                .sort(contacts);

        for (Integer i = 0; i < correctSortingResult.size(); i++) {
            System.assertEquals(contacts.get(correctSortingResult.get(i)), sortedContacts.get(i));
        }
    }

    @IsTest
    private static void testSortIntegers() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(NumberOfEmployees = 5));
        accounts.add(new Account());
        accounts.add(new Account(NumberOfEmployees = 1));
        accounts.add(null);
        accounts.add(new Account(NumberOfEmployees = 3));

        List<Integer> correctSortingResult = new List<Integer>{2, 4, 0, 1, 3};

        List<Account> sortedAccounts = new SortSObjects()
                .ascending(Account.NumberOfEmployees)
                .sort(accounts);

        for (Integer i = 0; i < correctSortingResult.size(); i++) {
            System.assertEquals(accounts.get(correctSortingResult.get(i)), sortedAccounts.get(i));
        }
    }

    @IsTest
    private static void testSortDoubles() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(AnnualRevenue = 100.51));
        accounts.add(new Account(AnnualRevenue = 99.5));
        accounts.add(new Account(AnnualRevenue = 100.5));
        accounts.add(new Account(AnnualRevenue = 99.49));
        accounts.add(new Account(AnnualRevenue = 100));

        List<Integer> correctSortingResult = new List<Integer>{3, 1, 4, 2, 0};

        List<Account> sortedAccounts = new SortSObjects()
                .ascending(Account.AnnualRevenue)
                .sort(accounts);

        for (Integer i = 0; i < correctSortingResult.size(); i++) {
            System.assertEquals(accounts.get(correctSortingResult.get(i)), sortedAccounts.get(i));
        }
    }

    @IsTest
    private static void testSortDates() {
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(CloseDate = Date.today().addDays(5)));
        opportunities.add(new Opportunity(CloseDate = Date.today()));
        opportunities.add(new Opportunity(CloseDate = Date.today().addDays(-5)));
        opportunities.add(new Opportunity());
        opportunities.add(new Opportunity(CloseDate = Date.today().addDays(3)));

        List<Integer> correctSortingResult = new List<Integer>{2, 1, 4, 0, 3};

        List<Opportunity> sortedOpportunities = new SortSObjects()
                .ascending(Opportunity.CloseDate)
                .sort(opportunities);

        for (Integer i = 0; i < correctSortingResult.size(); i++) {
            System.assertEquals(opportunities.get(correctSortingResult.get(i)), sortedOpportunities.get(i));
        }
    }

    private static SObject setNotWritableField(SObject sobj, SObjectField field, Object value) {
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sobj));
        parsed.put(field.getDescribe().name, value);
        SObject result = (SObject) JSON.deserialize(JSON.serialize(parsed), SObject.class);
        return result;
    }
}