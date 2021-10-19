/**@frpanico 12/10/2021
 * Test Class for the Class HDT_UTL_VoltureChangeManagerTst
 */
@IsTest
public with sharing class HDT_UTL_VoltureChangeManagerTst {
    
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Order> orderList = new List<Order>();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');	
		orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');

    }

    @IsTest
    static void cloneSobjTst()
    {
        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c,
        CompanyOwner__c
        FROM Order];   
        
        Map<String,Object> extraParams = new Map<String,Object>
        {
            'sobjName' => 'Order',
            'excludedFields' => new Set<String>{'Instance326__c'}
        };
        
        Test.startTest();
        Order clonedOrder = (Order)voltureChangeUtl.cloneSObject(orderList[0], extraParams);
        Test.stopTest();

        System.assertEquals(orderList[0].AccountId, clonedOrder.get('AccountId'), 'Order non clonato correttamente');

    }

    @IsTest
    static void accountCheckBusinessTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => orderList[0].Account.RecordType.DeveloperName,
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => System.today(),
            'preavvisoRecesso' => ''
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeUtilities.communicationPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void accountCheckBusinessWaitingTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => orderList[0].Account.RecordType.DeveloperName,
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => '',
            'preavvisoRecesso' => 3
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeUtilities.waitingPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void accountCheckResidenzialeTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderList = [SELECT Id, Account.RecordType.DeveloperName FROM Order WHERE Account.RecordType.DeveloperName = 'HDT_RT_Business'];
        Map<String,Object> accountCheckParams = new Map<String,Object>
        {
            'accountType' => 'HDT_RT_Residenziale',
            'orderId' => orderList[0].Id,
            'dataDecorrenza' => System.today(),
            'preavvisoRecesso' => 3
        };
        Test.startTest();
        accountCheck = voltureChangeUtl.accountCheck(accountCheckParams);
        Test.stopTest();

        System.assertEquals(HDT_UTL_VoltureChangeManager.lawEightyPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void handleResponseTst()
    {
        List<Order> currentOrder = [SELECT Id FROM Order];
        Map<String,Object> fieldsMap = new Map<String,Object>
        {
            'FASE' => 'Amm. Precheck OK SII',
            'CODERR' => 'ERR',
            'ANNOTAZIONI' => 'Error Ok',
            'VIA' => 'VIA NUOVA',
            'CIV' => '12',
            'CAP' => '00076',
            'ISTAT' => '120192380',
            'LOCALITA' => 'ROMA',
            'PROV' => 'RM',
            'NAZIONE' => 'IT',
            'DES_ERR_AEEG' => 'No Error',
            'COD_PRAT_UTENTE' => '10922312839',
            'COD_PRAT_DISTR' => '123812938123_DL',
            'DATA_DECORRENZA_SW' => '2021-10-15',
            'DATA_DECORRENZA_VT_TIT_III' => '2021-10-15',
            'DATA_DECORRENZA_VT_TIT_IV' => '2021-10-15',
            'POTCONTRIMP' => '3.97',
            'POTDISP' => '4.00',
            'TENSIONE' => '13'
        };
        Test.startTest();
        currentOrder[0] = voltureChangeUtl.handleResponse(fieldsMap, currentOrder[0]);
        Test.stopTest();
        System.assertEquals('Amm. Precheck OK SII', currentOrder[0].TecnicalPhase__c,'Fase non calcolata correttamente');
        System.assertEquals('ERR', currentOrder[0].CausalCode__c,'Codice causale calcolato correttamente');
    }

    @IsTest
    static void handleResponseMissingFieldsTst()
    {
        List<Order> currentOrder = [SELECT Id FROM Order];
        Map<String,Object> fieldsMap = new Map<String,Object>
        {
            'FASE' => 'Amm. Precheck OK SII',
            'CODERR' => 'ERR',
            'ANNOTAZIONI' => 'Error Ok',
            'VIA' => 'VIA NUOVA',
            'CIV' => '12',
            'CAP' => '00076',
            'ISTAT' => '120192380',
            'LOCALITA' => 'ROMA',
            'PROV' => 'RM',
            'NAZIONE' => 'IT',
            'DES_ERR_AEEG' => 'No Error',
            'COD_PRAT_UTENTE' => '10922312839',
            'COD_PRAT_DISTR' => '123812938123_DL'
        };
        Test.startTest();
        currentOrder[0] = voltureChangeUtl.handleResponse(fieldsMap, currentOrder[0]);
        Test.stopTest();
        System.assertEquals('Amm. Precheck OK SII', currentOrder[0].TecnicalPhase__c,'Fase non calcolata correttamente');
        System.assertEquals('ERR', currentOrder[0].CausalCode__c,'Codice causale calcolato correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckTrueTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold
        };

        Test.startTest();
        Boolean result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(true, result, 'Check True non eseguito correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckFalseTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold
        };

        Test.startTest();
        Boolean result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(false, result, 'Check False non eseguito correttamente');
    }
}
