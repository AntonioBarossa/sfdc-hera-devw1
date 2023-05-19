@isTest
public with sharing class HDT_UTL_CheckCompatibilitySalesTst {
    private static HDT_UTL_Constants utlconstants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId(),'HDT_RT_OrderDossier');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId(),'HDT_RT_SwitchIn');
            HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId(),'HDT_RT_VAS');

            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G3 - MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts) {
                c.Company__c='MMS';
            }
            insert contacts;
            Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            Id parentOrderId = parentOrders[0].id;
            parentOrders[0].Contact__c = contactId;
            parentOrders[0].Phase__c='In Lavorazione';
            parentOrders[0].recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();
            insert parentOrders;
            List<ServicePoint__c> vasPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            vasPoints[0].ServicePointCode__c='00720503018142';
            vasPoints[0].CommoditySector__c='Gas';
            insert vasPoints;
            List<Order> orderss = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            orderss[0].Username__c='test';
            orderss[0].Password__c='test1';
            orderss[0].NotRegisteredMeterCase__c=true;
            orderss[0].EffectiveDate__c=date.today();
            orderss[0].PowerCommitted__c=2;
            orderss[0].ImplantType__c='13A0-Usi di Abitazione BT';
            orderss[0].RequestOption__c='Domestici-TD';
            orderss[0].CreditCheckDescription__c='test1';
            orderss[0].QualityCall__c=true;  
            orderss[0].ComfortCallDaysDue__c=null;
            orderss[0].WizardCompletedDate__c=date.today()-60;
            orderss[0].ParentOrder__c = parentOrderId;
            orderss[0].Contact__c = contactId;
            orderss[0].QualityCallUnique__c=false;
            orderss[0].AgencyCode__c='001';
            orderss[0].recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchIn').getRecordTypeId();
            orderss[0].Phase__c = 'Bozza';
            orderss[0].SignatureMethod__c='Contratto già firmato';
            orderss[0].ProcessType__c='Switch in Gas';
            orderss[0].VasSubtype__c='';
            orderss[0].ParentOrder__c=parentOrders[0].Id;
            orderss[0].ServicePoint__c=vasPoints[0].Id;
            insert orderss;
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            String processName='Lead';
            MassiveLoaderRequest__c mlrSwitch=HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{'HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test'});
            List<MassiveLoaderRequestItem__c> itemList=new List<MassiveLoaderRequestItem__c>();
            for(MassiveLoaderRequestItem__c item:[SELECT Id FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__r.ProcessType__c='Lead']){
                HDT_UTL_ProcessSales.HDT_WRP_NextDataObj nextObj=new HDT_UTL_ProcessSales.HDT_WRP_NextDataObj();
                nextObj.parentOrderId=parentOrders[0].Id;
                nextObj.accountId=accId;
                nextObj.billProfId='';
                nextObj.contactId=contacts[0].Id;
                nextObj.servPointId=vasPoints[0].Id;
                item.NextStepData__c=JSON.serialize(nextObj);
                item.MassiveLoaderRequest__c=mlrSwitch.Id;
                itemList.add(item);
            }
            update itemList;
        List<Order> analisiConsumi = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
        analisiConsumi[0].Username__c='testAn';
        analisiConsumi[0].Password__c='test1An';
        analisiConsumi[0].NotRegisteredMeterCase__c=true;
        analisiConsumi[0].EffectiveDate__c=date.today();
        analisiConsumi[0].PowerCommitted__c=2;
        analisiConsumi[0].ImplantType__c='13A0-Usi di Abitazione BT';
        analisiConsumi[0].RequestOption__c='Domestici-TD';
        analisiConsumi[0].CreditCheckDescription__c='test1';
        analisiConsumi[0].QualityCall__c=true;
        analisiConsumi[0].ComfortCallDaysDue__c=null;
        analisiConsumi[0].WizardCompletedDate__c=date.today()-60;
        analisiConsumi[0].ParentOrder__c = parentOrders[0].Id;
        analisiConsumi[0].Contact__c = contactId;
        analisiConsumi[0].QualityCallUnique__c=false;
        analisiConsumi[0].AgencyCode__c='001';
        analisiConsumi[0].RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        analisiConsumi[0].Phase__c = 'Bozza';
        analisiConsumi[0].SignatureMethod__c='Contratto già firmato';
        analisiConsumi[0].ProcessType__c='VAS';
        analisiConsumi[0].VasSubtype__c='Analisi Consumi';
        analisiConsumi[0].ServicePoint__c=vasPoints[0].Id;
        insert analisiConsumi;
    }
    @isTest
    public static void Execute(){
        Order otherOrder=[SELECT Id,Contact__c,AccountId,ParentOrder__c,ServicePoint__c FROM ORder WHERE RecordType.DeveloperName='HDT_RT_SwitchIn'];
        //
        //
        List<MassiveLoaderRequestItem__c> listReqItem = [SELECT id ,Status__c,NextStepData__c,MassiveLoaderRequest__r.ProcessType__c FROM MassiveLoaderRequestItem__c];
        System.debug('size is: '+listReqItem.size());
        HDT_UTL_CheckCompatibilitySales testClass =  new HDT_UTL_CheckCompatibilitySales();
        Test.startTest();
        testClass.setRequestItemList(listReqItem);
        testClass.generateWrapperMap();
        testClass.getRecords();
        testClass.runCheckCompatibilitySales();
        Test.stopTest();
    }
}