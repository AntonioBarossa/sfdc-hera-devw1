/**
 * Header of the class "HDT_WS_CampagenDmDmpDataResponseTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_CampagenDmDmpDataResponse"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_CampagenDmDmpDataResponseTst {
    @TestSetup
    static void makedata(){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
    }
    @isTest
    static void test(){
        
        Test.startTest();
        
        HDT_WS_CampagenDmDmpDataResponse res = new HDT_WS_CampagenDmDmpDataResponse();
        res.status = 'test0';
        res.correlationId = 'test1';
        res.timestamp = 'test2';
               
        res.data.testata = new HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_TestataObject();
        res.data.testata.esito = 'test3';
        res.data.testata.messaggio = 'test4';
        
        res.data.posizioni = new List<HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_posizioniResponseObject>();
        HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_posizioniResponseObject one = new HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_posizioniResponseObject();
        HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_posizioniResponseObject two = new HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_posizioniResponseObject();
        res.data.posizioni.add(one);
        res.data.posizioni.add(two);
        res.data.posizioni[0].campo = 'test5';
        res.data.posizioni[0].valore = 'test6';
        
        res.errorDetails = new List<HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_ErrorResponseObject>();
        HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_ErrorResponseObject uno = new HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_ErrorResponseObject();
        HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_ErrorResponseObject due = new HDT_WS_CampagenDmDmpDataResponse.HDT_WRP_ErrorResponseObject();
        res.errorDetails.add(uno);
        res.errorDetails.add(due);
        res.errorDetails[0].code = 'test7';
        res.errorDetails[0].message = 'test8';
        res.errorDetails[0].additionalInfo = 'test9';
        
        Test.stopTest();
                
        System.assertEquals('test4', res.data.testata.messaggio, 'Value of the field messaggio not set');
        System.assertNotEquals(null, res.errorDetails[0].additionalInfo, 'Value of the field additionalInfo not set');
            
    }

}