trigger AccountTrigger on Account(after insert, after update,before insert, before update) {

    switch on Trigger.operationType {
        
        when AFTER_INSERT {
            AccountTriggerHandler.newAccountGold(trigger.newmap.keyset());
            system.debug('insert');
        }
        
        when BEFORE_UPDATE {
                        AccountTriggerHandler.updateAccountGold(trigger.new, trigger.oldMap);

             system.debug('update');
        }
    }
}