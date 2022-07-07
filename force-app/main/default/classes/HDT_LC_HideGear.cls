public with sharing class HDT_LC_HideGear 
{

    @AuraEnabled
    public static Boolean checkAdministratorProfile()
    {
        Id currentProfileId = UserInfo.getProfileId();
        String currentProfileName = [SELECT Name FROM Profile Where Id = :currentProfileId].Name;
        return (currentProfileName.equalsIgnoreCase('Hera System Administrator') || currentProfileName.equalsIgnoreCase('System Administrator') || currentProfileName.equalsIgnoreCase('Amministratore del sistema')|| currentProfileName.equalsIgnoreCase('Hera M2M Integration User')|| currentProfileName.equalsIgnoreCase('Hera System Integrator'));
    }


}
