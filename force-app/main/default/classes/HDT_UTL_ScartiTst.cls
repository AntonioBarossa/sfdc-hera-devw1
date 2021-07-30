/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 22/07/2021
 * @description HDT_UTL_ScartiTst - Test Class of HDT_UTL_Scarti
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
@isTest
public with sharing class HDT_UTL_ScartiTst {
    @TestSetup
    static void makeData(){
        List<wrts_prcgvr__ActivityTemplate__c> multipleTemplates= new list<wrts_prcgvr__ActivityTemplate__c>();
        wrts_prcgvr__ActivityTemplate__c CanoneTemplate= new wrts_prcgvr__ActivityTemplate__c(Name='CBS_CAR002__CANONE_RAI');
        wrts_prcgvr__ActivityTemplate__c BonusTemplate= new wrts_prcgvr__ActivityTemplate__c(Name='CBS_FAT011__BONUS_SOCIALE');
        wrts_prcgvr__ActivityTemplate__c DocumentalTemplatePost= new wrts_prcgvr__ActivityTemplate__c(Name='CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES');
        wrts_prcgvr__ActivityTemplate__c DocumentalTemplateSales= new wrts_prcgvr__ActivityTemplate__c(Name='CBS_CRP003__SCARTI_DOCUMENTALI_SALES');
        multipleTemplates.add(CanoneTemplate);
        multipleTemplates.add(BonusTemplate);
        multipleTemplates.add(DocumentalTemplatePost);
        multipleTemplates.add(DocumentalTemplateSales);
        insert(multipleTemplates);

        List<Account> multipleAccounts= new list<Account>();
        Account CanoneAccount= new Account(Name='CanoneAccount', CustomerCode__c='clienteidcanone',CompanyOwner__c='HERA COMM',CustomerMarking__c='Condominio', Category__c='Grandi Condomini',VATNumber__c='testiva123',BillingStreetName__c='via generica',BillingStreetNumber__c='16',BillingCity='città',BillingState='provincia',BillingPostalCode='00000',BillingCountry='nazione',BillingIsAddressVerified__c=true,SBQQ__PreserveBundle__c=true,ActiveMonitoring__c=false,BillingAddressIsForeign__c=false,ConsentSignature__c=false,DataLimitation__c=false,IsActive__c=false,IsDocumentAcquired__c=false,IsMigrated__c=false,IsVATGroupJoined__c=false,IsWrongFiscalData__c=true,SBQQ__AssetQuantitiesCombined__c=false,SBQQ__CoTermedContractsCombined__c=false,SBQQ__IgnoreParentContractedPrices__c=false);
        Account BonusAccount= new Account(Name='BonusAccount', CustomerCode__c='clienteidbonus',CompanyOwner__c='HERA COMM',CustomerMarking__c='Condominio', Category__c='Grandi Condomini', VATNumber__c='123testiva',BillingStreetName__c='via generica',BillingStreetNumber__c='12',BillingCity='città',BillingState='provincia',BillingPostalCode='00000',BillingCountry='nazione',BillingIsAddressVerified__c=true,SBQQ__PreserveBundle__c=true,ActiveMonitoring__c=false,BillingAddressIsForeign__c=false,ConsentSignature__c=false,DataLimitation__c=false,IsActive__c=false,IsDocumentAcquired__c=false,IsMigrated__c=false,IsVATGroupJoined__c=false,IsWrongFiscalData__c=true,SBQQ__AssetQuantitiesCombined__c=false,SBQQ__CoTermedContractsCombined__c=false,SBQQ__IgnoreParentContractedPrices__c=false);
        multipleAccounts.add(CanoneAccount);
        multipleAccounts.add(BonusAccount);
        insert(multipleAccounts);
    }
    @isTest private static void setLookupFieldsTst(){
        wrts_prcgvr__Activity__c CanoneActivity= new wrts_prcgvr__Activity__c(BPCode__c='clienteidcanone', Type__c='Canone RAI');
        wrts_prcgvr__Activity__c BonusActivity= new wrts_prcgvr__Activity__c(BPCode__c='clienteidbonus', Type__c='Bonus sociale');
        list<wrts_prcgvr__Activity__c> dataActivities= new list<wrts_prcgvr__Activity__c>();
        dataActivities.add(CanoneActivity);
        dataActivities.add(BonusActivity);
        List<wrts_prcgvr__Activity__c> results=HDT_UTL_Scarti.setLookupFields(dataActivities);
        Account canoneId=[SELECT Id FROM Account WHERE CustomerCode__c='clienteidcanone'];
        Account bonusId=[SELECT Id FROM Account WHERE CustomerCode__c='clienteidbonus'];
        system.assertEquals(canoneId.Id, results[0].Account__c, 'canone: lookup account');
        system.assertEquals(bonusId.Id, results[1].Account__c, 'bonus: lookup account');

        wrts_prcgvr__ActivityTemplate__c canoneTemplateId=[SELECT Id FROM wrts_prcgvr__ActivityTemplate__c WHERE Name='CBS_CAR002__CANONE_RAI'];
        wrts_prcgvr__ActivityTemplate__c bonusTemplateId=[SELECT Id FROM wrts_prcgvr__ActivityTemplate__c WHERE Name='CBS_FAT011__BONUS_SOCIALE'];
        system.assertEquals(canoneTemplateId.Id, results[0].wrts_prcgvr__ActivityTemplate__c, 'canone: lookup template');
        system.assertEquals(bonusTemplateId.Id, results[1].wrts_prcgvr__ActivityTemplate__c, 'bonus: lookup template');
    }
    
    /*
    @isTest private static void executeTst(){
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkActivityCreation(Canone)',
                                                              'sender'=>null};
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        classInstance.execute(argsMap);
    }
    */

    @isTest private static void createScartoForMarketingCloudTst(){
        Account fakeAccount= new Account(Name='nameAccount', CustomerCode__c='clienteiddocumental',CompanyOwner__c='HERA COMM',CustomerMarking__c='Condominio', Category__c='Grandi Condomini', VATNumber__c='ivafaketest',BillingStreetName__c='via generica',BillingStreetNumber__c='15',BillingCity='città',BillingState='provincia',BillingPostalCode='00000',BillingCountry='nazione',BillingIsAddressVerified__c=true,SBQQ__PreserveBundle__c=true,ActiveMonitoring__c=false,BillingAddressIsForeign__c=false,ConsentSignature__c=false,DataLimitation__c=false,IsActive__c=false,IsDocumentAcquired__c=false,IsMigrated__c=false,IsVATGroupJoined__c=false,IsWrongFiscalData__c=true,SBQQ__AssetQuantitiesCombined__c=false,SBQQ__CoTermedContractsCombined__c=false,SBQQ__IgnoreParentContractedPrices__c=false);
        insert fakeAccount;
        list<SObject> objectRelations= new list<SObject>();
        case fakeCase= new case(Status='New',Origin='Phone');
        order fakeOrder= new order(Status='Draft',EffectiveDate=date.today(),AccountId=fakeAccount.Id);
        objectRelations.add(fakeCase);
        objectRelations.add(fakeOrder);
        insert objectRelations;
        contact fakeContact= new contact(LastName='cognome');
        insert fakeContact;
        et4ae5__Automated_Send__c fakeSend= new et4ae5__Automated_Send__c();
        insert fakeSend;
        list<SObject> toInsert= new list<SObject>();
        et4ae5__IndividualEmailResult__c emailScarto= new et4ae5__IndividualEmailResult__c(BounceSubCategory__c='errore',OrderID__c=fakeOrder.Id,et4ae5__Contact__c=fakeContact.Id,et4ae5__TriggeredSendDefinition__c=fakeSend.Id);
        SMSTracking__c smsScarto= new SMSTracking__c(Undelivered__c=true,CaseID__c=fakeCase.Id,ActionDateTime__c=date.today(),MessageID__c=57,Mobile__c='(517)-424-5199',MobileMessageTrackingID__c=10,ModifiedDateTime__c=date.today());
        toInsert.add(emailScarto);
        toInsert.add(smsScarto);
        insert toInsert;
        HDT_UTL_Scarti.createScartoForMarketingCloud(toInsert);
    }
}
