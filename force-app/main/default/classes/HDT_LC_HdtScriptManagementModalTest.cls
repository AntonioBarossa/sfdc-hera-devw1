@isTest public class HDT_LC_HdtScriptManagementModalTest {
    @isTest public static void testScriptWithDataBinding(){
        Id processTypeId = ((SObject)Type.forName('Schema','ScriptConfig__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_RT_Processo').getRecordTypeId();
        ScriptConfig__c config = new ScriptConfig__c(Name='my Script', RecordTypeId=processTypeId);
        insert config;

    }
}
