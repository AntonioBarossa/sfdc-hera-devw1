@IsTest
public with sharing class HDT_LC_HideGearTst 
{ 

    @IsTest
    static void checkAdministratorProfileTst()
    {
        Test.startTest();
            Boolean result = HDT_LC_HideGear.checkAdministratorProfile();
        Test.stopTest();
        System.assertEquals(true, result, 'Check non superato');
    }

}