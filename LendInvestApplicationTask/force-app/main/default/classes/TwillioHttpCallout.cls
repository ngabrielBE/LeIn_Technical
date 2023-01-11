public class TwillioHttpCallout {

    public static HttpResponse TwillioHttpCallout(String toNumber, String smsBody) {

        String accountSid = SmsSettings.ACCOUNT_SID;
        String token = SmsSettings.TOKEN;
        String fromNumber = SmsSettings.FROM_NUMBER;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/SMS/Messages.json');
        req.setMethod('POST');
        req.setHeader('Accept-Charset', 'utf-8');

        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountSid + ':' + token)));

        req.setBody('To=' + EncodingUtil.urlEncode(toNumber, 'UTF-8') + '&From=' + EncodingUtil.urlEncode(fromNumber, 'UTF-8') + '&Body=' + smsBody);
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 201) {
            System.debug(res.getBody());
        } else {
            System.debug('Error. Status :' + res.getStatusCode());
        }
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> sendCustomSMS(String messageBody, String toNumber, String accountId) {
        try {
            String fromNumber = SmsSettings.FROM_NUMBER;
            HttpResponse res = TwillioHttpCallout.TwillioHttpCallout(toNumber, messageBody);

            Map <String, Object> resultsMap = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
            String status = String.valueOf(resultsMap.get('status'));
            CheckSMSResponseSmsLog(accountId, toNumber, fromNumber, messageBody, status);

            return resultsMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future(callout = true)
    public static void sendGoldAccountSmsToManager(String accountName, String accountId) {
        try {
            String toNumber = SmsSettings.MANAGERS_NUMBER;
            String smsBody = 'Great News! A customer has reached Gold. ' + accountName + ' will get VIP Treatment.';
            String fromNumber = SmsSettings.FROM_NUMBER;
            
            HttpResponse res = TwillioHttpCallout.TwillioHttpCallout(toNumber, smsBody);

            Map <String, Object> resultsMap = (Map <String, Object> ) JSON.deserializeUntyped(res.getBody());
            String status = String.valueOf(resultsMap.get('status'));
           
            CheckSMSResponseSmsLog(accountId, toNumber, fromNumber, smsBody, status);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static void checkSMSResponseSmsLog(String accountId, String toNum, String fromNum, String smsBody, String status) {
        List <Account> accs = new List <Account>();
        
        if (status == '200' || status == '201' || status == 'queued' || status == 'accepted') {
            insert new SMS_Log__c(Account__c = accountId, To_Number__c = toNum, From_Number__c = fromNum, SMS_Body__c = smsBody, status__c = 'Passed');
          
            accs = [SELECT Id, Gold_Alert_SMS_Sent__c, Name FROM Account WHERE Id =: accountId];
            for (Account a: accs) {
                if(a.Gold_Alert_SMS_Sent__c == FALSE){
                    a.Gold_Alert_SMS_Sent__c = TRUE;
                }
            }
        } else {
                insert new SMS_Log__c(Account__c = accountId, To_Number__c = toNum, From_Number__c = fromNum, SMS_Body__c = smsBody, status__c = 'Failed');
   	    }

        if(accs.size()>0){
            update accs;
        }
        
    }
}