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
        wrts_prcgvr__ActivityTemplate__c CanoneTemplate= new wrts_prcgvr__ActivityTemplate__c(Name='Canone');
        wrts_prcgvr__ActivityTemplate__c BonusTemplate= new wrts_prcgvr__ActivityTemplate__c(Name='Bonus');
        multipleTemplates.add(CanoneTemplate);
        multipleTemplates.add(BonusTemplate);
        insert(multipleTemplates);

        List<Account> multipleAccounts= new list<Account>();
        Account CanoneAccount= new Account(Name='CanoneAccount', CustomerCode__c='clienteidcanone',CompanyOwner__c='HERA COMM',CustomerMarking__c='Condominio', Category__c='Grandi Condomini',VATNumber__c='testiva123');
        Account BonusAccount= new Account(Name='BonusAccount', CustomerCode__c='clienteidbonus',CompanyOwner__c='HERA COMM',CustomerMarking__c='Condominio', Category__c='Grandi Condomini', VATNumber__c='123testiva');
        multipleAccounts.add(CanoneAccount);
        multipleAccounts.add(BonusAccount);
        insert(multipleAccounts);
    }
    @isTest private static void setLookupFieldsTst(){
        wrts_prcgvr__Activity__c CanoneActivity= new wrts_prcgvr__Activity__c(BPCode__c='clienteidcanone', Type__c='Canone');
        wrts_prcgvr__Activity__c BonusActivity= new wrts_prcgvr__Activity__c(BPCode__c='clienteidbonus', Type__c='Bonus');
        list<wrts_prcgvr__Activity__c> dataActivities= new list<wrts_prcgvr__Activity__c>();
        dataActivities.add(CanoneActivity);
        dataActivities.add(BonusActivity);
        List<wrts_prcgvr__Activity__c> results=HDT_UTL_Scarti.setLookupFields(dataActivities);
        Account canoneId=[SELECT Id FROM Account WHERE CustomerCode__c='clienteidcanone'];
        Account bonusId=[SELECT Id FROM Account WHERE CustomerCode__c='clienteidbonus'];
        system.assertEquals(canoneId.Id, results[0].Account__c, 'canone: lookup account');
        system.assertEquals(bonusId.Id, results[1].Account__c, 'bonus: lookup account');

        wrts_prcgvr__ActivityTemplate__c canoneTemplateId=[SELECT Id FROM wrts_prcgvr__ActivityTemplate__c WHERE Name='Canone'];
        wrts_prcgvr__ActivityTemplate__c bonusTemplateId=[SELECT Id FROM wrts_prcgvr__ActivityTemplate__c WHERE Name='Bonus'];
        system.assertEquals(canoneTemplateId.Id, results[0].wrts_prcgvr__ActivityTemplate__c, 'canone: lookup template');
        system.assertEquals(bonusTemplateId.Id, results[1].wrts_prcgvr__ActivityTemplate__c, 'bonus: lookup template');
    }
    @isTest private static void executeTst(){
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkActivityCreation(Canone)',
                                                              'sender'=>null};
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        classInstance.execute(argsMap);
    }
}
