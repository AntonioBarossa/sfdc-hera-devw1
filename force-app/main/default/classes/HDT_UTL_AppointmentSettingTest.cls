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

    @IsTest
    public static void executeGetQuickLink(){
        List<HDT_AppointmentSetting__mdt> qlList = [SELECT Value1__c,Value2__c FROM HDT_AppointmentSetting__mdt WHERE IsActive__c = true AND Type__c = 'Quick Link'];
        Test.startTest();
            System.assertEquals(HDT_UTL_AppointmentSetting.getQuickLink('Nome Errato').get('errorMessage'), 'Nessun Link valido per il presente distributore.', 'Gestione link non presente non funzionante');
            if (!qlList.isEmpty()){
                System.assertEquals(HDT_UTL_AppointmentSetting.getQuickLink(qlList[0].Value1__c).get('link'), qlList[0].Value2__c, 'Gestione link presente non funzionante');
            }
        Test.stopTest();
    }
}
