trigger HDT_NewsNotificationCenter on NewsNotificationCenter__c (before insert) 
{
    HDT_TRH_NewsNotificationCenter.getPotentialDuplicate(Trigger.new);
}