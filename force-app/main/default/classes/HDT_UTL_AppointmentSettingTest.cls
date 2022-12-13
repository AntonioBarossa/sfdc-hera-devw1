@isTest
public with sharing class HDT_UTL_AppointmentSettingTest {
    @IsTest
    public static void executeGetAtoaFlag(){
        Test.startTest();
 //era: System.assertEquals(true, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','INRETE DIST. ENER.-13R0000000','Gas',null).Flag__c, 'Il metodo non ha restituito vero vero');
        System.assertEquals(false, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','INRETE DIST. ENER.-13R0000000','Gas',null).Flag__c, 'Il metodo non ha restituito vero vero');
        System.assertEquals(null, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','Distributore non presente','commidity non presente',null), 'Il metodo non ha restituito vero vero');
 //aggiunto:
        System.assertEquals(true, HDT_UTL_AppointmentSetting.getAtoaFlag('SubentrosuGdMchiuso','MARCHE MULTISERV.-10R0000212','Gas','10V0000160').Flag__c, 'Il metodo non ha restituito vero vero'); 
       
        //E' necessario che siano presenti nella org i record del custom metadata "HDT_AppointmentSetting__mdt" opportuni (guardare dev 6 e dev w2) 
        System.assertEquals(true, HDT_UTL_AppointmentSetting.getAtoaFlag('test','test','test','test').Flag__c, 'Il metodo non ha restituito vero vero'); 
        
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
        List<HDT_AppointmentSetting__mdt> qlList = [SELECT Value1__c,Value2__c,Value3__c,Value4__c FROM HDT_AppointmentSetting__mdt WHERE IsActive__c = true AND Type__c = 'Quick Link'];
        Test.startTest();
        System.assertEquals(HDT_UTL_AppointmentSetting.getQuickLink('Nome Errato', '','').get('errorMessage'), 'Nessun Link valido per il presente distributore.', 'Gestione link non presente non funzionante');
        if (!qlList.isEmpty()){
            System.assertEquals(HDT_UTL_AppointmentSetting.getQuickLink(qlList[0].Value1__c, qlList[0].Value2__c, qlList[0].Value3__c).get('link'), qlList[0].Value4__c, 'Gestione link presente non funzionante');
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void executeGetCommunityLink(){
        Test.startTest();
        HDT_UTL_AppointmentSetting.getCommunityLink(UserInfo.getOrganizationId());
        System.assertEquals(HDT_UTL_AppointmentSetting.getCommunityLink('Nome Errato'), 'link inesistente', 'Gestione get Community non funzionante');
        Test.stopTest();
    }
}