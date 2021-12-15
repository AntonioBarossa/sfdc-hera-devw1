@isTest
public with sharing class HDT_UTL_AppointmentSettingTest {
    @IsTest
    public static void executeGetAtoaFlag(){
        Test.startTest();
            System.assertEquals(true, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','INRETE DIST. ENER.-13R0000000','Gas').Flag__c, 'Il metodo non ha restituito vero vero');
            System.assertEquals(false, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','Distributore non presente','commidity non presente').Flag__c, 'Il metodo non ha restituito vero vero');
        Test.stopTest();

    }

    @IsTest
    public static void executeGetResponseKeysMap(){
        Test.startTest();
            System.assert(!HDT_UTL_AppointmentSetting.getResponseKeysMap().isEmpty(), 'Il metodo non ha restituito nessuna mappa');
        Test.stopTest();
    }
}
