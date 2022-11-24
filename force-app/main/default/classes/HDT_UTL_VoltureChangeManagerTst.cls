/**@frpanico 12/10/2021
 * Test Class for the Class HDT_UTL_VoltureChangeManagerTst
 */
@IsTest
public with sharing class HDT_UTL_VoltureChangeManagerTst {
    
    private static HDT_UTL_VoltureChangeManager voltureChangeUtl = new HDT_UTL_VoltureChangeManager();
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Order> orderList = new List<Order>();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;	
		orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        orderList[0].ServicePoint__c = spList[0].Id;
        update orderList;
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
        List<Order> currentOrder = [SELECT Id, SupplyStreetName__c, SupplyStreetNumber__c, SupplyPostalCode__c, SupplyCity__c,
        SupplyState__c, SupplyCountry__c, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
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
            'DATA_DECORRENZA_SW' => '01/12/2021,01/01/2022,',
            'DATA_DECORRENZA_VT_TIT_III' => '01/01/2022',
            'DATA_DECORRENZA_VT_TIT_IV' => '01/01/2022',
            'POTCONTRIMP' => '3.97',
            'POTDISP' => '4.00',
			'result' => 'OK',
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
			'result' => 'ko',
            'COD_PRAT_DISTR' => '123812938123_DL'
        };
        Test.startTest();
        currentOrder[0] = voltureChangeUtl.handleResponse(fieldsMap, currentOrder[0]);
        Test.stopTest();
        System.assertEquals('Comunicazione verso Heroku KO', currentOrder[0].TecnicalPhase__c,'Fase non calcolata correttamente');
        System.assertEquals(null, currentOrder[0].CausalCode__c,'Codice causale calcolato correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckTrueTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.lowerThreshold;
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.btLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        Map<String,Object> result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(true, (Boolean)result.get('result'), 'Check True non eseguito correttamente');
        System.assertEquals('', (String)result.get('message'),'Check True non eseguito correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckTensionTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        Map<String,Object> result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(false,(Boolean)result.get('result'), 'Check False non eseguito correttamente');
        System.assert(String.isNotEmpty((String)result.get('message')), 'Check False non eseguito correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckPowerAvailableTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        Map<String,Object> result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(false,(Boolean)result.get('result'), 'Check False non eseguito correttamente');
        System.assert(String.isNotEmpty((String)result.get('message')), 'Check False non eseguito correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckPowerCommittedTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
        
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.lowerThreshold,
            'VIA' => 'A',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        Map<String,Object> result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(false,(Boolean)result.get('result'), 'Check False non eseguito correttamente');
        System.assert(String.isNotEmpty((String)result.get('message')), 'Check False non eseguito correttamente');
    }

    @IsTest
    static void handleAmmissibilityCheckAddressTst()
    {
        List<Order> orderList = [SELECT Id, VoltageLevel__c, PowerAvailable__c, PowerCommitted__c FROM Order];
        
        orderList[0].VoltageLevel__c = 'MT';
        orderList[0].PowerAvailable__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].PowerCommitted__c = HDT_UTL_VoltureChangeUtilities.higherThreshold;
        orderList[0].SupplyStreetName__c = 'A';
        orderList[0].SupplyStreetNumber__c = 'B';
        orderList[0].SupplyPostalCode__c = 'C';
        orderList[0].SupplyCityCode__c = 'D';
        orderList[0].SupplyCity__c = 'E';
        orderList[0].SupplyState__c = 'F';
        orderList[0].SupplyCountry__c = 'G';
    
        Map<String,Object> paramsMap = new Map<String,Object>
        {
            'TENSIONE' => HDT_UTL_VoltureChangeUtilities.mtLimit,
            'POTDISP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'POTCONTRIMP' => HDT_UTL_VoltureChangeUtilities.higherThreshold,
            'VIA' => 'H',
            'CIV' => 'B',
            'CAP' => 'C',
            'ISTAT' => 'D',
            'LOCALITA' => 'E',
            'PROV' => 'F',
            'NAZIONE' => 'G'
        };

        Test.startTest();
        Map<String,Object> result = voltureChangeUtl.handleAmmissibilityCheck(paramsMap, orderList[0]);
        Test.stopTest();

        System.assertEquals(false,(Boolean)result.get('result'), 'Check False non eseguito correttamente');
        System.assert(String.isNotEmpty((String)result.get('message')), 'Check False non eseguito correttamente');
    }

    @IsTest
    static void enrichSobjTst()
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
        CompanyOwner__c,
        CommodityFormula__c
        FROM Order];  

        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = new  List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posImposte = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAteco = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAddReg = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posAnnCons = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posImposte.campo = 'IMPOSTE';
        posImposte.valore = 'E_IMPOST';
        posAteco.campo = 'CODICE_ATECO';
        posAteco.valore = '9999';
        posAddReg.campo = 'ADDIZIONALEREGIONALE';
        posAddReg.valore = '0.34';
        posAnnCons.campo = 'CONSUMOANNUOEE';
        posAnnCons.valore = '1000';
        posizioni.add(posImposte);
        posizioni.add(posAteco);
        posizioni.add(posAddReg);
        posizioni.add(posAnnCons);

        List<HDT_GenericDataEnrichmentTranscode__mdt> transcodeConfigs = voltureChangeQr.getDataEnrichmentTranscodeByObjectName(new List<String>{'Order'});

        Map<String,Object> inputMap = new Map<String,Object>
        {
            'posizioni' => JSON.serialize(posizioni),
            'configs' => JSON.serialize(transcodeConfigs),
            'sobj' => orderList[0]
        };

        Test.startTest();
        orderList[0] = (Order)voltureChangeUtl.enrichSobj(inputMap);
        Test.stopTest();

        System.assertEquals(0.34, orderList[0].RegionalAdditional__c, 'Arricchimento fallito');
        System.assertEquals('9999', orderList[0].AtecoCode__c, 'Arricchimento fallito');
        System.assertEquals('Imposta usi domestici', orderList[0].ExciseEle__c, 'Arricchimento fallito');
        System.assertEquals(1000, orderList[0].AnnualConsumption__c, 'Arricchimento fallito');

    }

    @IsTest
    static void handleDataEnrichmentConfigMethodTst()
    {
        HDT_GenericDataEnrichmentTranscode__mdt config = [SELECT SapField__c,
        SfdcField__c,
        Method__c,
        IsNumber__c,
        Precision__c,
        Commodity__c,
        CommodityField__c,
        ObjectName__c
        FROM HDT_GenericDataEnrichmentTranscode__mdt
        WHERE SapField__c = 'IMPOSTE'
        LIMIT 1];
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'IMPOSTE';
        posizione.valore = 'E_IMPOST';

        Test.startTest();
        Object result = voltureChangeUtl.handleDataEnrichmentConfig(config, posizione);
        Test.stopTest();

        System.assert(result != null, 'Something was wrong');
    }

    
    @IsTest
    static void handleDataEnrichmentConfigNumberTst()
    {
        HDT_GenericDataEnrichmentTranscode__mdt config = [SELECT SapField__c,
        SfdcField__c,
        Method__c,
        IsNumber__c,
        Precision__c,
        Commodity__c,
        CommodityField__c,
        ObjectName__c
        FROM HDT_GenericDataEnrichmentTranscode__mdt
        WHERE SapField__c = 'ADDIZIONALEREGIONALE'
        LIMIT 1];
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'ADDIZIONALEREGIONALE';
        posizione.valore = '0.34';

        Test.startTest();
        Object result = voltureChangeUtl.handleDataEnrichmentConfig(config, posizione);
        Test.stopTest();

        System.assertEquals(posizione.valore, String.valueOf(result),'Arricchimento fallito');
    }

    @IsTest
    static void handleDataEnrichmentConfigTextTst()
    {
        HDT_GenericDataEnrichmentTranscode__mdt config = [SELECT SapField__c,
        SfdcField__c,
        Method__c,
        IsNumber__c,
        Precision__c,
        Commodity__c,
        CommodityField__c,
        ObjectName__c
        FROM HDT_GenericDataEnrichmentTranscode__mdt
        WHERE SapField__c = 'CODICE_ATECO'
        LIMIT 1];
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'CODICE_ATECO';
        posizione.valore = '9999';

        Test.startTest();
        Object result = voltureChangeUtl.handleDataEnrichmentConfig(config, posizione);
        Test.stopTest();

        System.assertEquals(posizione.valore, String.valueOf(result),'Arricchimento fallito');
    }

    @IsTest
    static void methodDispatcherTst()
    {
        HDT_GenericDataEnrichmentTranscode__mdt config = [SELECT SapField__c,
        SfdcField__c,
        Method__c,
        IsNumber__c,
        Precision__c,
        Commodity__c,
        CommodityField__c,
        ObjectName__c
        FROM HDT_GenericDataEnrichmentTranscode__mdt
        WHERE SapField__c = 'IMPOSTE'
        LIMIT 1];
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'IMPOSTE';
        posizione.valore = 'E_IMPOST';

        Test.startTest();
        String result = voltureChangeUtl.methodDispatcher(config, posizione);
        Test.stopTest();

        System.assert(result != null, 'Something was wrong');
    }

    @IsTest
    static void numberDispatcherDecimalTst()
    {
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'CODICE_ATECO';
        posizione.valore = '0.231';

        Test.startTest();
        Decimal result = (Decimal)voltureChangeUtl.numberDispatcher(3, posizione);
        Test.stopTest();

        System.assertEquals(0.231, result, 'Numero non calcolato correttamente');
    }

    @IsTest
    static void numberDispatcherIntegerTst()
    {
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'CODICE_ATECO';
        posizione.valore = '9999';

        
        Test.startTest();
        Integer result = (Integer)voltureChangeUtl.numberDispatcher(0, posizione);
        Test.stopTest();

        System.assertEquals(Integer.valueOf(posizione.valore), result, 'Numero non calcolato correttamente');
        
    }

    @IsTest
    static void processCheckTst()
    {
        Order newOrder = new Order();
        Order currentOrder = new Order();

        newOrder.NotRegisteredMeterCase__c = false;
        newOrder.VoltureType__c = 'Ordinaria';
        newOrder.EffectiveDate__c = System.today().addDays(6);
        newOrder.Subprocess__c = 'Standard';

        Boolean isReading = false;
        Boolean isRetroactive = false;
        Boolean isUpdateStep = true;
        Date readingDate = System.today();

        Map<String, Object> testMap = new Map<String, Object>
        {
            'orderNew' => newOrder,
            'currentOrder' => currentOrder,
            'isReading' => isReading,
            'isRetroactive' => isRetroactive,
            'isUpdateStep' => isUpdateStep,
            'readingDate' => readingDate
        };
        Test.startTest();
            HDT_WRP_VoltureChangeManager.HDT_WRP_ProcessCheck result = HDT_UTL_VoltureChangeManager.processCheck(testMap);
        Test.stopTest();
        System.assertEquals('OK', result.result, 'Check Fallito');
    }

}