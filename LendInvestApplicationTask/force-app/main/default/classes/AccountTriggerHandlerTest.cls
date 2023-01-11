@IsTest
private class AccountTriggerHandlerTest {
    @IsTest
    private static void testupdateAccountGold_NotGold() {

        Account acc = new Account(name = 'New Account');
        insert acc;
        Map < Id, Account > oldAccounts = new Map <Id, Account> ([SELECT Customer_Classification__c, Id FROM Account WHERE Id =: Acc.id]);

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 1000;

        Insert opp;
 
        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];
        Test.startTest();
        AccountTriggerHandler.updateAccountGold(accountList, oldAccounts);
        Test.stopTest();

        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, null, 'Customer Classification should be blank');
        }
    }

    @IsTest
    static void testupdateAccountGold_Gold() {
        Account acc = new Account(name = 'New Account');
        insert acc;
        Map <Id, Account> oldAccounts = new Map < Id, Account > ([SELECT Id, Customer_Classification__c, Name FROM Account WHERE Id =: Acc.id]);

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 60000;

        Insert opp;
        List <Sms_Log__c> smsLog = [select id, Account__c from SMS_Log__c where Account__c =: acc.id];
        
        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c, Name FROM Account WHERE Id =: acc.Id];

        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());
        
        Test.startTest();

        AccountTriggerHandler.updateAccountGold(accountList, oldAccounts);
        Test.stopTest();

        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, 'GOLD', 'Customer Classification should be GOLD');
        }
    }

    @IsTest
    static void newAccountGold_Gold() {

        Account acc = new Account(name = 'New Account');
        insert acc;
        Map <Id, Account > oldAccounts = new Map < Id, Account > ([SELECT Id, Customer_Classification__c, Name FROM Account WHERE Id =: Acc.id]);

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 60000;

        Insert opp;
        List <Sms_Log__c> smsLog = [select id, Account__c from SMS_Log__c where Account__c =: acc.id];
        system.debug(smsLog.size());
        System.assertEquals(smsLog.size(), 0, 'Should not have any sms is log');

        Set <Id> accountIds = new Set < Id > {acc.Id};
        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());

        Test.startTest();
        AccountTriggerHandler.newAccountGold(accountIds);
        Test.stopTest();

        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];
        for (Account account: accountList) {
            System.assertEquals(account.Customer_Classification__c, 'GOLD', 'Customer Classification should be GOLD');
        }
    }
    
    @IsTest
    static void newAccountGold_NotGold() {

        Account acc = new Account(name = 'New Account');
        insert acc;
        Map <Id, Account> oldAccounts = new Map < Id, Account > ([SELECT Id, Customer_Classification__c, Name FROM Account WHERE Id =: Acc.id]);

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today() + 1;
        opp.AccountId = acc.Id;
        opp.Amount = 20000;

        Insert opp;

        Set <Id> accountIds = new Set < Id > {acc.Id};
        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());

        Test.startTest();
        AccountTriggerHandler.newAccountGold(accountIds);
        Test.stopTest();

        List <Account> accountList = [SELECT Id, Total_Customer_Spend__c, Customer_Classification__c FROM Account WHERE Id =: acc.Id];
        for (Account account: accountList) {
            System.assertNotEquals(account.Customer_Classification__c, 'GOLD', 'Customer Classification should not be GOLD');
        }
    }


}