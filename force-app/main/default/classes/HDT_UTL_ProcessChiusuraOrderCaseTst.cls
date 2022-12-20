/**
* @author Elvin Iluca
* @date 16/12/2022
* @description Test Class for HDT_UTL_ProcessChiusuraOrderCase.cls
* @history Elvin Iluca – 16/12/2022 – Created class
*/

@isTest
public with sharing class HDT_UTL_ProcessChiusuraOrderCaseTst {
     /**​
    * @author Elvin Iluca
    * @date 16/12/2022
    * @description HDT_UTL_ProcessChiusuraOrderCaseTst – Test Class for HDT_UTL_ProcessChiusuraOrderCase.cls
    */

    @TestSetup
	static void setup(){
        String recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_DisattivazioniTari').getRecordTypeId();
        String recordTypeIdOrder = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_AttivazioneAmbiente').getRecordTypeId();
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato per decorrenza dei termini' , 'In attesa perfezionamento documentazione', recordTypeIdCase, 'Disattivazioni Ambiente');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato per decorrenza dei termini' , 'In attesa perfezionamento documentazione', recordTypeIdOrder, 'Attivazione Ambiente');
     
        List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');    
        List<Contact> contactList= HDT_UTL_DataFactoryTst.createContact(2, true, accountList[0].Id);
        List<ServicePoint__c> servicePointList = HDT_UTL_DataFactoryTst.createServicePoint(2, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(2, true, accountList[0].Id);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accountList[1].Id, 'In attesa perfezionamento documentazione');
        orderList[0].Status = 'In Lavorazione';
        orderList[0].RecordTypeId = recordTypeIdOrder;
        insert orderList;
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseMorosita(1, false, accountList[0].Id, contactList[0].Id, servicePointList[0].Id, contractList[0].Id, orderList[0].Id);
        caseList[0].Phase__c = 'In attesa perfezionamento documentazione';
        caseList[0].Status = 'In Lavorazione';
        caseList[0].RecordTypeId = recordTypeIdCase;
        insert caseList;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 8;
        request.Priority__c = 240;
        request.ProcessType__c = 'ChiusuraOrderCase';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        for(Integer n=0; n<2; n++){
            MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            switch on n {
                when 0 {
                    item.Data__c= caseList[0].Id + '|';
                }
                when 1 {
                    item.Data__c='|' + orderList[0].Id;
                }
            }
            itemsList.add(item);
        }
        insert itemsList;

    }

    @isTest
    static void executeTst(){

        MassiveLoaderRequest__c myBulkRequest = [SELECT Id,ProcessType__c FROM MassiveLoaderRequest__c WHERE ProcessType__c='ChiusuraOrderCase' WITH SECURITY_ENFORCED LIMIT 1  ];
        List<MassiveLoaderRequestItem__c> bulkItems = [SELECT Id, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, NextStepData__c, Result__c, RelatedRequestItem__c, VasOrder__c,Status__c FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c=:myBulkRequest.Id];
        HDT_UTL_ProcessChiusuraOrderCase processChiusuraOrderCaseBulk = new HDT_UTL_ProcessChiusuraOrderCase();
        processChiusuraOrderCaseBulk.setRequestId(myBulkRequest.Id);
        processChiusuraOrderCaseBulk.setProcess(myBulkRequest.ProcessType__c);
        processChiusuraOrderCaseBulk.setMassiveLoaderRequestItemList(bulkItems);
        
        Test.startTest();
        processChiusuraOrderCaseBulk.execute();
        Test.stopTest();

        List<Case> retCase = [SELECT Id, Phase__c, Status FROM Case];
        List<Order> retOrder = [SELECT Id, Phase__c, Status FROM Order];

        System.assertEquals('Annullato per decorrenza dei termini', retCase[0].Phase__c, 'Error Case process');
        System.assertEquals('Annullato per decorrenza dei termini', retOrder[0].Phase__c, 'Error Order process');
    }
}
