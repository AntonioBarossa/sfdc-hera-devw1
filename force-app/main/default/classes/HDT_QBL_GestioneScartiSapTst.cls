@IsTest
public with sharing class HDT_QBL_GestioneScartiSapTst {
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<wrts_prcgvr__Activity__c> acts = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accList[0].Id);
        /* List<wrts_prcgvr__ActivityTemplate__c> actTempl = HDT_UTL_DataFactoryTst.createActivityTemplate(1,false);
        actTempl[0].Name = 'Errore Lavorazione SAP';
        actTempl[0].wrts_prcgvr__ObjectType__c = 'Order';
        actTempl[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
        insert actTempl;
        List<wrts_prcgvr__ActivityAction__c> action = HDT_UTL_DataFactoryTst.createActivityAction(1,false,actTempl[0].Id);
        action[0].wrts_prcgvr__Value__c	= 'Errore Lavorazione Sap';
        action[0].wrts_prcgvr__Operation__c	= 'equals';
        action[0].wrts_prcgvr__Value__c	= '{!Type__c}';
        insert action; */
        acts[0].wrts_prcgvr__Status__c = 'Aperta';
        acts[0].DiscardCategory__c = 'Tracciatura';
        acts[0].Type__c = 'Errore Lavorazione SAP';
        acts[0].Order__c = orderList[0].Id;
        insert acts;
    }

    @IsTest
    public static void testClass(){
        Order o = [SELECT id FROM Order LIMIT 1];
        Map<String, String> mapActivityField = new Map<String,String>{
            'DATA_ELABORAZIONE' => '2022-06-22 15:44:55',
            'CMP' => 'CMP_TEST',
            'UTENZA' => 'UTENZA_TEST',
            'NOTE_ERR' => 'NOTE_ERR_TEST'
        };
        
        List<HDT_GestioneScartiSap__mdt> rules  = new List<HDT_GestioneScartiSap__mdt>{
            new HDT_GestioneScartiSap__mdt(
                ActivityInitialStatus__c = 'Aperta',
                ActivityToClose__c = 'Errore Lavorazione SAP',
                Activity__c = 'Errore Lavorazione SAP',
                CreateActivity__c = true
            )
        
        };
        Test.startTest();
            HDT_QBL_GestioneScartiSap gss = new HDT_QBL_GestioneScartiSap(o.Id,rules,mapActivityField);
            gss.execute(null);
        Test.stopTest();
        List<wrts_prcgvr__Activity__c> act = [SELECT id,wrts_prcgvr__Status__c  FROM wrts_prcgvr__Activity__c WHERE Type__c = 'Errore Lavorazione SAP' AND wrts_prcgvr__Status__c = 'Chiusa'];
        System.assertEquals(1, act.size(), 'Non è stata chiusa l\'activity');


    }
}