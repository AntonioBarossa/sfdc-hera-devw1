trigger HDT_NewsNotificationCenter on NewsNotificationCenter__c (before insert) 
{
    //HDT_TRH_NewsNotificationCenter.getPotentialDuplicate(Trigger.new);
    /*
        @Author: Francesco Vitiello - 09/11/2021
        Description: Modifica per aggiunta estensione TriggerHandler
    */
    HDT_TRH_NewsNotificationCenter myClass = new HDT_TRH_NewsNotificationCenter();
    myClass.run();
}