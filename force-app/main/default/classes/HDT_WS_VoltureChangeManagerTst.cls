@IsTest
public with sharing class HDT_WS_VoltureChangeManagerTst {

    /**@frapnico 13/10/2021
     * Test Class for the Class HDT_WS_VoltureChangeManager
     * TODO: Set Mock and create response
     */

    @TestSetup
    static void setup()
    {
        /*Variable Declarations*/
        String rtId = 'HDT_RT_VolturaConSwitch';
        String rtName = Schema.Order.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get(rtId).getRecordTypeId();
        List<Contact> contactList = new List<Contact>();
        /*Install Process Click*/
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        /*Create Callout Template*/
        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Order","label": "Ordine","sObjectType": "Order","queryable": true,"fields": ['
        +'{"name": "ServicePointCode__c","label": "POD"},'
        +'{"name": "OrderNumber","label": "RIF_RICH"},'
        +'{"name": "Id","label": "RECORD_ID"},'
        +'{"name": "DistributorCode__c","label": "SERVICEID_DIS"},'
        +'{"name": "SalesCompanyCode__c","label": "SERVICEID_VEN"},'
        +'],'
        +'"objects":[{"name":"AccountId","label":"Account","sObjectType": "Account","relationshipName": "Account","queryable": true,"fields": ['
        +'{"name": "FiscalCode__c","label": "COD_FISCALE"},'
        +'{"name": "VATNumber__c","label": "PIVA"}'
        +'],"objects": []'
        +'},'
        +'{"label":"Static Value","queryable": false,"fields": ['
        +'{"name": "","label": "SIST_SORG","value": "SFDC"},'
        +'{"name": "","label": "COD_PRESC","value": "PKE"}'
        +']}'
        ,'Callout_Template.json');
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1,true,'Callout_Prova','prova',true,'Case','Flat',contentVersionList[0].ContentDocumentId);
        /*Create EndpointRule*/
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');
        /*Create Phase Transition*/
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Comunicazione verso Heroku', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_HerokuPostSalesManager(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', rtId, rtName,'A','','','');
        /* Create Records*/	
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        /* Update Order to match the callout template*/
        orderList[0].ServicePointCode__c = 'IT45454546676';
        orderList[0].DistributorCode__c = '13D0000001';
        orderList[0].SalesCompanyCode__c = '13V0000000';
        orderList[0].ProcessType__c = 'Voltura con Switch';
        update orderList;


    }

    @IsTest
    static void executeTst()
    {

    }

}
