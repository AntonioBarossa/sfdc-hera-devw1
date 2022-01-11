/*
    Test class for HDT_SRV_FieldCoerenceServicePoint class
    @Author:        Edoardo Zanatta
    CreatedDate:    12/12/2021
*/

@IsTest
public class HDT_SRV_FieldCoerenceServicePointTst {

    @TestSetup
    static void makeData(){
        
        HDT_UTL_DataFactoryTst.createFieldCoerenceServicePoint(1, true, 'GAS');
    }

    @isTest
    public static void checkCoerenceTest() {

        FieldCoerenceServicePoint__c myFieldCsp = new FieldCoerenceServicePoint__c();
        List<FieldCoerenceServicePoint__c> fieldCspList = new  List<FieldCoerenceServicePoint__c>();
        Map<String, String> coerenceMap = new Map<String, String>();

        fieldCspList = [SELECT Id, Name, Commodity__c FROM FieldCoerenceServicePoint__c];
        myFieldCsp = fieldCspList[0];
        myFieldCsp.AccountCategory__c = 'Famiglie';
        myFieldCsp.SupplyType__c = 'A-Domestico';
        myFieldCsp.ImplantType__c = '1001-Cottura cibi';
        //myFieldCsp.Taxes__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        myFieldCsp.UseCategory__c = '001-Uso cottura cibi';
        myFieldCsp.WithdrawalClass__c = '001 - 7 giorni';
        update myFieldCsp;

        coerenceMap.put('CategoriaCliente', myFieldCsp.AccountCategory__c);
        coerenceMap.put('TipoFornitura', myFieldCsp.SupplyType__c);
        coerenceMap.put('TipoImpianto', myFieldCsp.ImplantType__c);
        coerenceMap.put('Servizio', myFieldCsp.Commodity__c);
        coerenceMap.put('ProfiloPrelievo', myFieldCsp.WithdrawalClass__c);
        coerenceMap.put('CategoriaUso', myFieldCsp.UseCategory__c);
        //coerenceMap.put('Imposta', myFieldCsp.Taxes__c);

        Test.startTest();

        Boolean retVal;
        retVal = HDT_SRV_FieldCoerenceServicePoint.checkCoerence(coerenceMap);
        System.assertEquals(retVal, true, 'Positive Test');

        Test.stopTest();
    }

    @isTest
    public static void checkCoerenceErrorTest() {

        FieldCoerenceServicePoint__c myFieldCsp = new FieldCoerenceServicePoint__c();
        List<FieldCoerenceServicePoint__c> fieldCspList = new  List<FieldCoerenceServicePoint__c>();
        Map<String, String> coerenceMap = new Map<String, String>();

        fieldCspList = [SELECT Id, Name, Commodity__c FROM FieldCoerenceServicePoint__c];
        myFieldCsp = fieldCspList[0];
        myFieldCsp.AccountCategory__c = 'Famiglie';
        myFieldCsp.SupplyType__c = 'A-Domestico';
        myFieldCsp.ImplantType__c = '1001-Cottura cibi';
        //myFieldCsp.Taxes__c = 'Imposta Usi Domestici (Cod. G_ICD)';
        myFieldCsp.UseCategory__c = '001-Uso cottura cibi';
        myFieldCsp.WithdrawalClass__c = '001 - 7 giorni';
        update myFieldCsp;

        coerenceMap.put('CategoriaCliente', myFieldCsp.AccountCategory__c);
        coerenceMap.put('TipoFornitura', myFieldCsp.SupplyType__c);
        coerenceMap.put('TipoImpianto', 'Tipo Impianto errato');
        coerenceMap.put('Servizio', myFieldCsp.Commodity__c);
        coerenceMap.put('ProfiloPrelievo', myFieldCsp.WithdrawalClass__c);
        coerenceMap.put('CategoriaUso', myFieldCsp.UseCategory__c);
        //coerenceMap.put('Imposta', myFieldCsp.Taxes__c);

        Test.startTest();

        Boolean retVal;
        retVal = HDT_SRV_FieldCoerenceServicePoint.checkCoerence(coerenceMap);
        System.assertEquals(retVal, false, 'Error case test');

        Test.stopTest();
    }
}