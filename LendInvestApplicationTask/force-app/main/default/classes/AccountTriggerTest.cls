@IsTest
public class AccountTriggerTest {

    @IsTest
    private static void testCreateNewAccount_NoStatus() {
        Account acc = new Account(name = 'New Account');

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 1000;

        Test.startTest();
        Insert opp; 
        Test.stopTest();
        
        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];

        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, '', 'Customer Classification should be blank');
        }
    }

    @IsTest
    private static void testCreateNewAccount_BronzeStatus() {
        Account acc = new Account(name = 'New Account');

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 10000;

        Test.startTest();
        Insert opp; 
        Test.stopTest();

        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];

        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, 'BRONZE', 'Customer Classification should be BRONZE');
        }
    }
    @IsTest
    private static void testCreateNewAccount_SilverStatus() {
        Account acc = new Account(name = 'New Account');

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 25000;

        Test.startTest();
        Insert opp; 
        Test.stopTest();

        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];

        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, 'SILVER', 'Customer Classification should be SILVER');
        }
    }
    @IsTest
    private static void testCreateNewAccount_GoldStatus() {
        Account acc = new Account(name = 'New Account');

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 50000;

        List <Account> oldAccountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];

        Test.startTest();
        Insert opp;
        Test.stopTest();
        List < Account > accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];

        for (Account account: oldAccountList) {
            System.assertEquals(account.Customer_Classification__c, '', 'Customer Classification should be blank');
        }
        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, 'GOLD', 'Customer Classification should be GOLD');
        }
    }

}