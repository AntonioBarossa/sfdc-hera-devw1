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
        myFieldCsp.Taxes__c = 'G_ICD';
        myFieldCsp.UseCategory__c = '001-Uso cottura cibi';
        myFieldCsp.WithdrawalClass__c = '001 - 7 giorni';
        update myFieldCsp;

        coerenceMap.put('CategoriaCliente', myFieldCsp.AccountCategory__c);
        coerenceMap.put('TipoFornitura', myFieldCsp.SupplyType__c);
        coerenceMap.put('TipoImpianto', myFieldCsp.ImplantType__c);
        coerenceMap.put('Servizio', myFieldCsp.Commodity__c);
        coerenceMap.put('ProfiloPrelievo', myFieldCsp.WithdrawalClass__c);
        coerenceMap.put('CategoriaUso', myFieldCsp.UseCategory__c);
        coerenceMap.put('Imposta', myFieldCsp.Taxes__c);

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
        myFieldCsp.Taxes__c = 'G_ICD';
        myFieldCsp.UseCategory__c = '001-Uso cottura cibi';
        myFieldCsp.WithdrawalClass__c = '001 - 7 giorni';
        update myFieldCsp;

        coerenceMap.put('CategoriaCliente', myFieldCsp.AccountCategory__c);
        coerenceMap.put('TipoFornitura', myFieldCsp.SupplyType__c);
        coerenceMap.put('TipoImpianto', 'Tipo Impianto errato');
        coerenceMap.put('Servizio', myFieldCsp.Commodity__c);
        coerenceMap.put('ProfiloPrelievo', myFieldCsp.WithdrawalClass__c);
        coerenceMap.put('CategoriaUso', myFieldCsp.UseCategory__c);
        coerenceMap.put('Imposta', myFieldCsp.Taxes__c);

        Test.startTest();

        Boolean retVal;
        retVal = HDT_SRV_FieldCoerenceServicePoint.checkCoerence(coerenceMap);
        System.assertEquals(retVal, false, 'Error case test');

        Test.stopTest();
    }

    @isTest
    public static void checkCoerenceServicePointTst()
    {
        Map<String, Object> servicePoint = new Map<String, Object>
        {
            'SupplyType__c' => 'Domestico',
            'MarketOrigin__c' => 'Salvaguardia',
            'CommoditySector__c' => 'Gas',
            'PowerRequested__c' => '13',
            'RequestPhase__c' => 'Monofase'
        };
        Map<String, Object> inputFieldMap = new Map<String, Object>
        {
            'CategoriaCliente' => 'Famiglie',
            'TipoFornitura' => 'A-Domestico',
            'TipoImpianto' => 'Tipo Impianto errato',
            'Servizio' => 'Gas',
            'ProfiloPrelievo' => '001 - 7 giorni',
            'CategoriaUso' => '001-Uso cottura cibi',
            'Imposta' => 'G_ICD'
        };

        List<FieldCoerenceServicePoint__c> fieldCspList = [SELECT Id, Name, Commodity__c FROM FieldCoerenceServicePoint__c];
        fieldCspList[0].AccountCategory__c = 'Famiglie';
        fieldCspList[0].SupplyType__c = 'A-Domestico';
        fieldCspList[0].ImplantType__c = '1001-Cottura cibi';
        fieldCspList[0].Taxes__c = 'G_ICD';
        fieldCspList[0].UseCategory__c = '001-Uso cottura cibi';
        fieldCspList[0].WithdrawalClass__c = '001 - 7 giorni';
        update fieldCspList;

        Map<String, Object> result = new Map<String, Object>();

        Test.startTest();
            result = HDT_SRV_FieldCoerenceServicePoint.checkCoerenceServicePoint(servicePoint, inputFieldMap);
            servicePoint.put('CommoditySector__c', 'Energia Elettrica');
            servicePoint.put('ImplantType__c','Tipo Impianto Errato');
            result = HDT_SRV_FieldCoerenceServicePoint.checkCoerenceServicePoint(servicePoint, inputFieldMap);
            servicePoint.put('SupplyType__c', 'Domestico');
            servicePoint.put('ImplantType__c','13A0-Usi di Abitazione BT');
            servicePoint.put('PowerRequested__c','7');
            servicePoint.put('VoltageLevel__c','MT');
            result = HDT_SRV_FieldCoerenceServicePoint.checkCoerenceServicePoint(servicePoint, inputFieldMap);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Coerenza non controllata');
    }   
}