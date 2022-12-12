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

    /* @TestSetup
	static void setup(){

    } */

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
        System.assertEquals(ret.applicativo, null, 'Errore setHttpDataBodyRow applicativo ML');
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
        System.debug(ret);
        System.assertEquals(ret, null, 'ok');
    } 
   

}
