public class SmsSettings {

public static final Sms_Setting__mdt SMS_SETTING {
      get {
        if (SMS_SETTING == null) {
          SMS_SETTING = Sms_Setting__mdt.getInstance('TwillioSmsSetting');
        }
        return SMS_SETTING;
      }
      set;
    }
  
    public static final String MANAGERS_NUMBER {
      get {
        if (MANAGERS_NUMBER == null) {
          MANAGERS_NUMBER = SMS_SETTING.ToNumber__c;
        }
        return MANAGERS_NUMBER;
      }
      set;
    }
    
    public static final String FROM_NUMBER {
      get {
        if (FROM_NUMBER == null) {
          FROM_NUMBER = SMS_SETTING.FromNumber__c;
        }
        return FROM_NUMBER;
      }
      set;
    }
    
    public static final String ACCOUNT_SID {
      get {
        if (ACCOUNT_SID == null) {
          ACCOUNT_SID = SMS_SETTING.AccountSID__c;
        }
        return ACCOUNT_SID;
      }
      set;
    }
    
    public static final String TOKEN {
      get {
        if (TOKEN == null) {
          TOKEN = SMS_SETTING.Token__c;
        }
        return TOKEN;
      }
      set;
    }

}