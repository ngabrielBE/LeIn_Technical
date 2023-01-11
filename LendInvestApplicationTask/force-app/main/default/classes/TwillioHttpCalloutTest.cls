@IsTest
private class TwillioHttpCalloutTest {
    
    @isTest
    private static void testTwillioHttpCallout(){
        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());
        
        HttpResponse res = TwillioHttpCallout.TwillioHttpCallout('toNumber', 'smsBody');
        String expected = '{"Test Response":["Message","One"]}';
        System.assertEquals(201,res.getStatusCode());
        System.assertEquals(res.getBody(), expected);
    }

    @IsTest
    private static void testSendCustomSMS() {
        Account acc = new Account(name = 'New Account');
        insert acc;
        
        String messageBody = 'This is a new message';
        String toNumber = '+1234567890';

        List <Sms_Log__c> smsLog = [select id, Account__c from SMS_Log__c where Account__c =: acc.id];
        System.assertEquals(smsLog.size(), 0, 'Should not have any sms in log');

        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());
        Test.startTest();
        Map <String, Object> resultsMap = TwillioHttpCallout.sendCustomSMS(messageBody, toNumber, acc.Id);
        Test.stopTest();

        String result = String.valueOf(resultsMap);
        system.debug(result);

        System.assertEquals(result, '{Test Response=(Message, One)}', 'Should return test mock body');

    }
    
    @IsTest
    private static void testsendGoldAccountSmsToManager() {
        Account acc = new Account(name = 'New Account');
        insert acc;

        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMockClass());
        Test.startTest();

        TwillioHttpCallout.sendGoldAccountSmsToManager(acc.Name, acc.Id);
        Test.stopTest();

    }
    
    @IsTest
    private static void testCheckSMSResponseSmsLog_StatusOk() {
        Account acc = new Account(name = 'New Account');
        insert acc;
        String toNum = '+1234567890';
        String fromNum = '+0987654321';
        String smsBody = 'hello message';
        String status = '201';

        List <Sms_Log__c> smsLog = [select id, Account__c from SMS_Log__c where Account__c =: acc.id];
        System.assertEquals(smsLog.size(), 0, 'Should not have any sms is log');

        TwillioHttpCallout.checkSMSResponseSmsLog(acc.Id, toNum, fromNum, smsBody, status);

        List <Sms_Log__c> smsNewLog = [select id, Account__c, status__c from SMS_Log__c where Account__c =: acc.id];
        System.assertEquals(smsNewLog.size(), 1, 'Should have 1 sms log');
            System.assertEquals(smsNewLog[0].status__c, 'Passed', 'Should have 1 Passed log');

    }
    
    @IsTest
    private static void testCheckSMSResponseSmsLog_StatusNotOk() {
        Account acc = new Account(name = 'New Account');
        insert acc;
        String toNum = '+1234567890';
        String fromNum = '+0987654321';
        String smsBody = 'hello message';
        String status = '400';

        List <Sms_Log__c> smsLog = [select id, Account__c from SMS_Log__c where Account__c =: acc.id];
        System.assertEquals(smsLog.size(), 0, 'Should not have any sms is log');

        TwillioHttpCallout.checkSMSResponseSmsLog(acc.Id, toNum, fromNum, smsBody, status);

        List <Sms_Log__c> smsNewLog = [select id, status__c, Account__c from SMS_Log__c where Account__c =: acc.id limit 1];
        System.assertEquals(smsNewLog.size(), 1, 'Should have 1 sms log');
        System.assertEquals(smsNewLog[0].status__c, 'Failed', 'Should have 1 failed log');
    
    }
}