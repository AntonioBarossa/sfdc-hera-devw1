/**
* @author Elvin Iluca
* @date 12/12/2022
* @description Test Class for HDT_LC_AccountStatementCtrlUtility.cls
* @history Elvin Iluca – 12/12/2022 – Created class
*/

@isTest
public with sharing class HDT_LC_AccountStatementCtrlUtilityTst {
     /**​
    * @author Elvin Iluca
    * @date 12/12/2022
    * @description HDT_LC_AccountStatementCtrlUtilityTst – Test Class for HDT_LC_AccountStatementCtrlUtility.cls
    */

    @isTest
    static void setHttpDataBodyRow(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    }

    @isTest
    static void setHttpDataBodyRowHome(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='home';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    }

    @isTest
    static void setHttpDataBodyRowAllRecentItems(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='allRecentItems';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    }

    @isTest
    static void setHttpDataBodyRowJoinFilter(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='joinFilter';
        tObj.tabCode = 'EC';
        dbr.dataFine =  '2022-12-12';
        dbr.dataInizio = '2022-12-11';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    }

    @isTest
    static void setHttpDataBodyRowFilters(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='filters';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    }

    @isTest
    static void setHttpDataBodyRowViewResult(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='viewResult';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, null, 'Errore setHttpDataBodyRow');
    }

    @isTest
    static void setHttpDataBodyRowExpired(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='expired';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 

    @isTest
    static void setHttpDataBodyRowCreditRecovery(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='creditRecovery';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    @isTest
    static void setHttpDataBodyRowExpiredFromDay(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='expiredFromDay';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    @isTest
    static void setHttpDataBodyRowManageableItems(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='manageableItems';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    @isTest
    static void setHttpDataBodyRowContractService(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='contractService';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    @isTest
    static void setHttpDataBodyRowPaperlessFilters(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='paperlessFilters';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    
    @isTest
    static void setHttpDataBodyRowExpiredFromDayMdtButtonList(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='expiredFromDay';
        tObj.tabCode='EC1';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 
    @isTest
    static void setHttpDataBodyRowManageableItemsMdtButtonList(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='manageableItems';
        tObj.tabCode='EC1';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.applicativo, 'ML', 'Errore setHttpDataBodyRow applicativo ML');
    } 

    @isTest
    static void setHttpDataBodyRowException(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.requestType='joinFilter';
        tObj.tabCode = 'EC';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret, null, 'Errore setHttpDataBodyRow');
    } 

    @isTest
    static void setDefaultHttpDataBodyRowEc(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.aggregazione, '03', 'Errore setDefaultHttpDataBodyRow aggregazione issue');
        System.assertEquals(ret.tipoTransazione, 'EC1', 'Errore setDefaultHttpDataBodyRow tipoTransazione issue');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc1(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC1';
        dbr.originLwc = 'activity';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.tipoTransazione, 'EC2', 'Errore setDefaultHttpDataBodyRow tipoTransazione issue');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc8(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC8';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();

        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc3(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC3';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.aggregazione, '03', 'Errore setDefaultHttpDataBodyRow aggregazione issue');
        System.assertEquals(ret.tipoEstrattoConto, 'NVI', 'Errore setDefaultHttpDataBodyRow tipoEstrattoConto issue');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc5(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC5';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();

        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void setDefaultHttpDataBodyRowPaperless(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'paperless';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(ret.tipoTransazione, null, 'Errore setDefaultHttpDataBodyRow tipoTransazione issue');
        System.assertEquals(ret.tipoEstrattoConto, null, 'Errore setDefaultHttpDataBodyRow tipoEstrattoConto issue');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc7(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC7';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc4(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC4';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc9(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC9';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void setDefaultHttpDataBodyRowEc6(){
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow ret;
        
        HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj = new HDT_WRP_AccountStatement.HDT_WRP_TechObj();
        HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr = new HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow();
        tObj.tabCode = 'EC6';

        Test.startTest();
        ret = (HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow) HDT_LC_AccountStatementCtrlUtility.setDefaultHttpDataBodyRow(tObj, dbr);
        Test.stopTest();
        System.assertEquals(null, ret.applicativo, 'Errore setDefaultHttpDataBodyRow');
    }

    @isTest
    static void convertDateFormat(){
        String ret;
        Test.startTest();
        ret = HDT_LC_AccountStatementCtrlUtility.convertDateFormat('2022-10-10');
        Test.stopTest();

        System.assertEquals('10/10/2022', ret, 'Error conversion Date Format');
    }

    @isTest
    static void setHttpObject(){
        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj ret;
        Test.startTest();
        ret = HDT_LC_AccountStatementCtrlUtility.setHttpObject('EC', '');
        Test.stopTest();

        System.assertEquals('callout:AccountStatements', ret.endPoint, 'Error setting http object');
    }

    @isTest 
    static void executeControllForSingleRecord(){
        AccountStatementFilter__c ret;

        HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj record = new HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj();
        record.residuo = '10';
        record.societa = '';
        record.numeroFattura = '';
        record.secondoLivelloInformativo = new List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj>();
        HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj docPareggio = new HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj();
        docPareggio.docPareggio ='2712';
        record.secondoLivelloInformativo.add(docPareggio);
        AccountStatementFilter__c serviceCatalog = new AccountStatementFilter__c();
        serviceCatalog.Context__c = 'EC2L';
        String tabValue = 'EC';

        Test.startTest();
        ret = HDT_LC_AccountStatementCtrlUtility.executeControllForSingleRecord(record, serviceCatalog, tabValue);
        Test.stopTest();
    
        System.assertEquals(false, ret.IsPrescribable__c, 'Error execute controll for single record');
    }

    @isTest
    static void executeControllForMultipleRecords(){
        AccountStatementFilter__c ret;
        List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList = new List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj>();
        HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj record = new HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj();
        record.residuo = '10';
        record.societa = '';
        record.numeroFattura = '';
        record.secondoLivelloInformativo = new List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj>();
        HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj docPareggio = new HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj();
        docPareggio.docPareggio ='2712';
        record.secondoLivelloInformativo.add(docPareggio);
        recordsList.add(record);

        AccountStatementFilter__c serviceCatalog = new AccountStatementFilter__c();
        serviceCatalog.Context__c = 'EC2L';
        String tabValue = 'EC';

        Test.startTest();
        ret = HDT_LC_AccountStatementCtrlUtility.executeControllForMultipleRecords(recordsList, serviceCatalog, tabValue);
        Test.stopTest();

        System.assertEquals(false, ret.IsInstallment__c, 'Error execute controll for single record');

    }
   

}
