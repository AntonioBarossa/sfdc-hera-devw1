@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@isTest
public with sharing class HDT_UTL_EquipmentValidationTst {
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);    
        caseList[0].Type = 'Associa Dotazioni';
        caseList[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        insert caseList;
        insert new ProcessEquipment__c(Case__c=caseList[0].Id);
    }


    @isTest
    static void testAssociaDot(){
        HDT_UTL_EquipmentValidation validation = new  HDT_UTL_EquipmentValidation();
        ProcessEquipment__c prEq = [SELECT id, Case__c FROM ProcessEquipment__c LIMIT 1];
        Map<String, Object> mapFieldValues = new Map<String, Object>();
        Map<String, Object> result = new Map<String, Object>();
        HDT_UTL_Tqrif fieldsSuffix = new HDT_UTL_Tqrif();
        
        for(String s : fieldsSuffix.fieldsName){
            mapFieldValues.put('New'+s, null);
        }

        Test.startTest();

        
        //BLANK TEST START
        result = (Map<String, Object>) JSON.deserializeUntyped(validation.validate(JSON.serialize(mapFieldValues), prEq.Id));
        Assert.areEqual('Error', getCode(result));
        Assert.areEqual('Popolare almeno un campo', getDescription(result));
        //BLANK TEST END

        //Associa Dot. OK TEST START
        mapFieldValues.put('NewCardKey1__c', 'TEST');
        result = (Map<String, Object>) JSON.deserializeUntyped(validation.validate(JSON.serialize(mapFieldValues), prEq.Id));
        Assert.areEqual('OK', getCode(result));
        Assert.areEqual('Success', getDescription(result));
        //Associa Dot. OK TEST END

        Test.stopTest();
        
    }

    @isTest
    static void testRichiestaRiparazione(){
        HDT_UTL_EquipmentValidation validation = new  HDT_UTL_EquipmentValidation();
        ProcessEquipment__c prEq = [SELECT id, Case__c FROM ProcessEquipment__c LIMIT 1];
        Map<String, Object> mapFieldValues = new Map<String, Object>();
        Map<String, Object> result = new Map<String, Object>();
        HDT_UTL_Tqrif fieldsSuffix = new HDT_UTL_Tqrif();
        
        for(String s : fieldsSuffix.fieldsName){
            mapFieldValues.put('Old'+s, null);
        }

        update new Case(Id=prEq.Case__c, Type='Gestione Sost./Furto/Smarr. Dot.');

        Test.startTest();

        //Dot. da rit OK TEST START
        mapFieldValues.put('OldCardKey1__c', 'TEST');

        result = (Map<String, Object>) JSON.deserializeUntyped(validation.validate(JSON.serialize(mapFieldValues), prEq.Id));
        Assert.areEqual('OK', getCode(result));
        Assert.areEqual('Success', getDescription(result));
        //Dot. da rit OK TEST END

        //Dot. da cons OK TEST START
        mapFieldValues.clear();
        for(String s : fieldsSuffix.fieldsName){
            mapFieldValues.put('New'+s, null);
        }
        mapFieldValues.put('NewCardKey1__c', 'TESTNew');
        update new ProcessEquipment__c(Id=prEq.Id, OldCardKey1__c='TestOld');
        result = (Map<String, Object>) JSON.deserializeUntyped(validation.validate(JSON.serialize(mapFieldValues), prEq.Id));
        Assert.areEqual('OK', getCode(result));
        Assert.areEqual('Success', getDescription(result));
        //Dot. da cons OK TEST END

        //Dot. da cons KO TEST START
        mapFieldValues.clear();
        for(String s : fieldsSuffix.fieldsName){
            mapFieldValues.put('New'+s, null);
        }
        mapFieldValues.put('NewCardKey2__c', 'TESTNew');
        result = (Map<String, Object>) JSON.deserializeUntyped(validation.validate(JSON.serialize(mapFieldValues), prEq.Id));
        Assert.areEqual('Error', getCode(result));
        Assert.areEqual('Popolare tutti e soli i campi valorizzati nella sezione precedente', getDescription(result));
        Assert.isInstanceOfType(result.get('mandatoryFields'), List<Object>.class);
        Assert.isFalse(checkEmpty(result.get('mandatoryFields')));
        Assert.isInstanceOfType(result.get('fieldsToBlank'), List<Object>.class);
        Assert.isFalse(checkEmpty(result.get('fieldsToBlank')));
        //Dot. da cons KO TEST END

        Test.stopTest();
        
    }

    static Boolean checkEmpty(Object m){
        List<Object> l = (List<Object>) m;
        return l.isEmpty();
    }

    static String getCode(Map<String, Object> m){
        return STRING.valueOf(m.get('outcomeCode'));
    }

    static String getDescription(Map<String, Object> m){
        return STRING.valueOf(m.get('outcomeDescription'));
    }
}