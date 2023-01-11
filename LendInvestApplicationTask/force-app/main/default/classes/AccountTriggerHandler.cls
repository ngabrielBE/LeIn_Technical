public class AccountTriggerHandler {

    public static Boolean isFirstTime = true;

    public static void updateAccountGold(List <Account> accounts, Map <Id, Account> oldAccounts) {
        if (isFirstTime) {

            for (Account account: accounts) {
                Account oldAccount = oldAccounts.get(account.Id);
                if (account.Customer_Classification__c <> oldAccount.Customer_Classification__c &&
                    account.Customer_Classification__c == 'GOLD' && oldAccount.Customer_Classification__c != 'GOLD' &&
                    account.Gold_Alert_SMS_Sent__c == FALSE) {

                    TwillioHttpCallout.sendGoldAccountSmsToManager(account.Name, account.Id);
                }
            }
            isFirstTime = false;
        }
    }
    public static void newAccountGold(Set <Id> accountIds) {
        String accName;
        List <Account> accounts = new List <Account>([SELECT Customer_Classification__c, Gold_Alert_SMS_Sent__c, Name FROM Account WHERE Id IN: accountIds]);

        for (Account account: accounts) {
            if (account.Customer_Classification__c == 'GOLD' && account.Gold_Alert_SMS_Sent__c == FALSE) {
                TwillioHttpCallout.sendGoldAccountSmsToManager(account.Name, account.id);
            }
        }
    }
}