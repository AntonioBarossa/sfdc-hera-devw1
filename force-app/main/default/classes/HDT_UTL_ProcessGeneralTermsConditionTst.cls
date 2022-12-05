
@isTest
public with sharing class HDT_UTL_ProcessGeneralTermsConditionTst {

    @testSetup
    static void setup(){

        List<MassiveFieldsObjectMap__c> mappingList = new List<MassiveFieldsObjectMap__c>();
        MassiveFieldsObjectMap__c mapping;

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'TipoCGC';
        mapping.nameField__c = 'CgcType__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'DataFine';
        mapping.nameField__c = 'EndDate__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'DataInizio';
        mapping.nameField__c = 'StartDate__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'CodiceCGC';
        mapping.nameField__c = 'CgcCode__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'Mercato';
        mapping.nameField__c = 'MarketArea__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'SocietaVendita';
        mapping.nameField__c = 'Vendor__c';
        mappingList.add(mapping);

        mapping = new MassiveFieldsObjectMap__c();
        mapping.objectType__c = 'GeneralTermsCondition__c';
        mapping.processType__c = 'CGC';
        mapping.labelField__c = 'FlagAttivo';
        mapping.nameField__c = 'Active__c';
        mappingList.add(mapping);
        insert mappingList;


        GeneralTermsCondition__c genTermCond = new GeneralTermsCondition__c();
        genTermCond.CgcCode__c = 'EE_CGC(MASSIVE1)';
        insert genTermCond;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'CaricamentoCGC';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        MassiveLoaderRequestItem__c item;

        for(Integer n=0; n<20; n++){
            item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            item.Data__c = 'Energia Elettrica|2022-11-14|2022-12-14|true|Domestico|Hera Comm Marche|EE_CGC(MASSIVE1)';
            itemsList.add(item);
        }
        insert itemsList;

    }

    @isTest
    public static void testGeneralTermsCondition(){
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
    }

}