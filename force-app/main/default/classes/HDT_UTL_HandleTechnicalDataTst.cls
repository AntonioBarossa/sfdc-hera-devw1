/**
 * @author Valere (valere@noeli-it.net)
 * @date 6/10/2021
 * @description HDT_UTL_VasManagementTst Test Class
 * @history valere - 6/10/2021– Created Class
 */
@isTest
private class HDT_UTL_HandleTechnicalDataTst {

@testSetup 
  static void setup() {

    List<Account> accountList= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie');

    //List<Order> order = 
    HDT_UTL_DataFactoryTst.createOrder(1,true, accountList[0].id,'Bozza');


    //List<ServicePoint__c> servicePoint = 
    HDT_UTL_DataFactoryTst.createServicePoint(1,true);


  }
    
  @isTest
  static void testhandleE154Flow() {

    Order order=[SELECT id,EstimateAmount__c,QuotationType__c, SupplyType__c, ValidityDateEstimate__c,QuotationNumber__c,WorkExecutionTime__c FROM Order];  

    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.handleE154Flow(new Map<String,String>{
        'IMP_PREV_DIST'=>'10',
        'DT_MAX_PREV'=>'20220502',
        'NUMPREV'=>'10',
        'TEMP_ES_PREV'=>'10'
    },order);
    

    System.assertEquals('Analitico',order.QuotationType__c, 'value of parameters is matching');
    System.assertNotEquals('code',order.QuotationType__c, 'value of parameters is  not  matching');

  }



  @isTest
  static void testhandleE150Flow() {

    Order order=[SELECT id,FareCode__c,WorkExecutionTime__c FROM Order];  

    ServicePoint__c service=[SELECT
                              DispatchingPoint__c,
                              CorrectorType__c,
                              RegimeDate2G__c,
                              DistributorTreatment__c,
                              kActive__c,
                              kReactive__c,
                              kPower__c,
                              MeterActiveSN__c,
                              MeterReactiveSN__c,
                              MeterPowerSN__c,
                              InstallationDateActive__c,
                              InstallationDateReactive__c,
                              InstallationDatePower__c,
                              DigitNumberActive__c,
                              DigitNumberReactive__c,
                              MeterGroup__c,
                              Forfait__c,
                              MarketTypeCode__c,
                              ServicePointCode__c
                              FROM ServicePoint__c LIMIT 1];

    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handleE150Flow(new Map<String,String>{
        'PUNTODISPACCIAMENTO'=>'DispatchingPoint',
        'TIPO_MISURATORE'=>'CorrectorType',
        'DATA_REGIME_2G'=>'10',
        'TRATTAMENTO_DT'=>'10',


        'K_ATT'=>'10',
        'K_REATT'=>'20220502',
        'K_POT'=>'10',
        'MATR_MIS_ATTIVA_NEW'=>'10',


        'MATR_MIS_REATTIVA_NEW'=>'10',
        'MATR_MIS_POTENZA_NEW'=>'20220502',
        'DATA_INST_ATT'=>'10',
        'DATA_INST_REA'=>'10',


        'DATA_INST_POT'=>'10',
        'CIFRE_ATTIVA'=>'20220502',
        'CIFRE_REATTIVA'=>'10',
        'CIFRE_POT'=>'10',


        'GRUPPO_MIS'=>'10',
        'FORFAIT'=>'20220502',
        'CODICE_TARIFFA'=>'10',
        'SERV_TUTELA'=>'10',
        'GRUPPO_MIS_DT'=>'10',
        'TEMP_ES_PREV'=>'10'

    },order);
    

    System.assertEquals('10',order.FareCode__c, 'value of parameters is matching');
    System.assertNotEquals('code',order.FareCode__c, 'value of parameters is  not  matching');

  }


  @isTest
  static void testhandlE351Flow() {

    Order order=[SELECT id,MeterSN__c,WorkExecutionTime__c FROM Order];  


    ServicePoint__c service=[SELECT
                              DistributorTreatment__c,
                              MeterDigitNumber__c,
                              CorrectorSN__c,
                              CorrectorDigitNumber__c,
                              CorrectiveCoefficient__c,
                              Collection__c,
                              MeterClass__c,
                              CorrectorWithdrawal__c,
                              MeterGroup__c,
                              ServicePointCode__c

                             FROM ServicePoint__c LIMIT 1];

    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handlE351Flow(new Map<String,String>{
        'TRATTAMENTO_DT'=>'TRATTAMENTO_DT',
        'MATR_MIS'=>'MATR_MIS',
        'N_CIFRE_MIS'=>'N_CIFRE_MIS',
        'MATR_CONV'=>'MATR_CONV',


        'N_CIFRE_CONV'=>'N_CIFRE_CONV',
        'COEFF_CORRETTIVO'=>'COEFF_CORRETTIVO',
        'RACCOLTA'=>'RACCOLTA',
        'VOL_ANNUO_SOST'=>'VOL_ANNUO_SOST',


        
        'PRE_CONV'=>'PRE_CONV',
        'GRUPPO_MIS_INT'=>'GRUPPO_MIS_INT',
        'TEMP_ES_PREV'=>'10'

    },order);
    

    System.assertEquals('MATR_MIS',order.MeterSN__c, 'value of parameters is matching');
    System.assertNotEquals('code',order.MeterSN__c, 'value of parameters is  not  matching');

  }



  @isTest
  static void testhandlE300Flow() {

    Order order=[SELECT id,MeterSN__c,BonusData__c,WorkExecutionTime__c FROM Order];  

    ServicePoint__c service=[SELECT
                              MeterDigitNumber__c,
                              MeterClass__c,
                              MeterYear__c,
                              MeterSignal__c,
                              CorrectorSN__c,
                              CorrectorDigitNumber__c,
                              CorrectorSignal__c,
                              CorrectiveCoefficient__c,
                              MeterAccessible__c,
                              Pressure__c,
                              MaxHourWithdrawal__c,
                              AnnualConsumption__c,
                              OrderDueDate__c,
                              RenewalMonth__c,
                              ServicePointCode__c
   
                             FROM ServicePoint__c LIMIT 1];

    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handlE300Flow(new Map<String,String>{
        'MATR_MIS'=>'MATR_MIS',
        'TIPO_PDR'=>'TIPO_PDR',
        'DATA_REGIME_2G'=>'DATA_REGIME_2G',
        

        'ANNO_FABB_MIS'=>'ANNO_FABB_MIS',
        'SEGN_MIS_AVVIO'=>'SEGN_MIS_AVVIO',
        'MATR_CONV'=>'MATR_CONV',
        'N_CIFRE_CONV'=>'N_CIFRE_CONV',


        'SEGN_CONV'=>'SEGN_CONV',
        'COEFF_CORRETTIVO'=>'COEFF_CORRETTIVO',
        'ACC_MIS'=>'ACC_MIS',
        'COD_PROF_PREL'=>'COD_PROF_PREL',


        'COD_REMI'=>'COD_REMI',
        'PRESS_MIS'=>'10',
        'MAX_PRELIEVO_ORA'=>'MAX_PRELIEVO_ORA',
        'CONS_ANNUO'=>'10',


        'DATA_SCAD_DS'=>'DATA_SCAD_DS',
        'BONUSGAS'=>'BONUSGAS',
        'BONUS_INIZ'=>'BONUS_INIZ',
        'BONUS_FINE'=>'BONUS_FINE',
        'MESE_RIN'=>'MESE_RIN',
        'TIPO_BONUS'=>'TIPO_BONUS',
        'TEMP_ES_PREV'=>'10'

    },order);
    

    System.assertEquals('MATR_MIS',order.MeterSN__c, 'value of parameters is matching');
    System.assertNotEquals('code',order.MeterSN__c, 'value of parameters is  not  matching');

  }


  @isTest
  static void testhandleCompletataActivo() {

    ServicePoint__c service=[SELECT
                              SAPImplantCode__c,
                              SAPContractCode__c,
                              MeterStatus__c,
                              Status__c,
                              RecordTypeId,
                              ServicePointCode__c
                             FROM ServicePoint__c LIMIT 1];
    Account acc = [SELECT Id FROM Account LIMIT 1];
    String recordTypeId = Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Gas').getRecordTypeId();
    service.RecordTypeId = recordTypeId;
    service.CommoditySector__c = 'Gas';
    update service;
    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handleCompletata(new Map<String,String>{
        'ANLAGE'=>'10',
        'VERTRAG'=>'20',
        'ANLAGE_ST'=>'Open',
        'supplyType' => 'A-Domestico',
        'implantType' => '1004-Riscaldamento promiscuo',
        'NuovoAccount' => acc.Id
   
    });
    
    System.assertEquals('Attivo',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is matching');
    System.assertNotEquals('code',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is  not  matching');

  }

  @isTest
  static void testhandleCompletataInattivo() {

   ServicePoint__c service=[SELECT
                              SAPImplantCode__c,
                              SAPContractCode__c,
                              MeterStatus__c,
                              Status__c,
                              ServicePointCode__c
                                

                             FROM ServicePoint__c LIMIT 1];

    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handleCompletata(new Map<String,String>{
        'ANLAGE'=>'10',
        'VERTRAG'=>'20',
        'ANLAGE_ST'=>'Impianto chiuso per morosita'
   
    });
    
    System.assertEquals('Inattivo',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is matching');
    System.assertNotEquals('code',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is  not  matching');

  }


  @isTest
  static void testhandleCompletataSospeso() {

      ServicePoint__c service=[SELECT
                                SAPImplantCode__c,
                                SAPContractCode__c,
                                MeterStatus__c,
                                Status__c,
                                ServicePointCode__c
                              

                            FROM ServicePoint__c LIMIT 1];
    HDT_UTL_HandleTechnicalData handleTechnicalData = new HDT_UTL_HandleTechnicalData();
    handleTechnicalData.sp= service;
    handleTechnicalData.handleCompletata(new Map<String,String>{
        'ANLAGE'=>'10',
        'VERTRAG'=>'20',
        'ANLAGE_ST'=>'Interr. avviata per morosita'
   
    });
    
    System.assertEquals('Sospeso',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is matching');
    System.assertNotEquals('code',  handleTechnicalData.sp.MeterStatus__c, 'value of parameters is  not  matching');

  }



}