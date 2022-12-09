/**
* @author Elvin Iluca
* @date 09/12/2022
* @description Test Class for HDT_WRP_ComunicationsSearchList.cls
* @history Elvin Iluca – 09/12/2022 – Created class
*/

@isTest
public with sharing class HDT_WRP_ComunicationsSearchListTst {
     /**​
    * @author Elvin Iluca
    * @date 09/12/2022
    * @description HDT_WRP_ComunicationsSearchListTst – Test Class for HDT_WRP_ComunicationsSearchList.cls
    */
     
    @isTest
    static void webServiceObjTest(){

        Test.startTest();
        HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj tst = new  HDT_WRP_ComunicationsSearchList.HDT_WRP_WebServiceObj();
        Test.stopTest();

        System.assertNotEquals(tst, null, 'Error initialization HDT_WRP_WebServiceObj');
    }

    @isTest
    static void responseObjTest(){

        Test.startTest();
        HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj tst = new  HDT_WRP_ComunicationsSearchList.HDT_WRP_ResponseObj();
        Test.stopTest();

        System.assertNotEquals(tst, null, 'Error initialization HDT_WRP_ResponseObj');
    }
}
