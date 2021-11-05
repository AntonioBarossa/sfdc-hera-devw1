/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 16/09/2021
 * @description HDT_WRP_PaperProcessing Test Class
 * @history Luca Molino – 29/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_WRP_PaperProcessingTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);
 
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
 
        internalUser.UserPermissionsMarketingUser=true;
 
        insert internalUser;        
    }
    
    @isTest
    public static void testGetPaperProcessing() {
 
        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
 
        System.runAs(u){
            
            Test.startTest();
            List<HDT_WRP_PaperProcessing> listPaper = new List<HDT_WRP_PaperProcessing>();
			HDT_WRP_PaperProcessing paper = new HDT_WRP_PaperProcessing();
 			paper.aggregazione='test';
            paper.CRM_communication_Id='test';
            paper.campo2 ='test';
            paper.campo3 ='test';
            paper.campo4 ='test';
            paper.campo4 ='test';
            paper.campo6 ='test';
            paper.campo7 ='test';
            paper.campo8 ='test';
            paper.campo9 ='test';
            paper.campo10 ='test';
            paper.campo11='test';
            paper.campo12='test';
            paper.campo13='test';
            paper.campo14='test';
            paper.campo15='test';
            paper.campo16='test';
            paper.campo17='test';
            paper.campo18='test';
            paper.campo19='test';
            paper.campo20='test';
            paper.campo21 ='test';
            paper.campo22='test';
            paper.campo23='test';
            paper.campo24='test';
            paper.campo25='test';
            paper.campo26='test';
            paper.campo27='test';
            paper.campo28 ='test';
            paper.campo29 ='test';
            paper.campo30 ='test';
            paper.campo31='test';
            paper.campo32='test';
            paper.campo33='test';
            paper.campo34='test';
            paper.campo35='test';
            paper.campo36='test';
            paper.campo37='test';
            paper.campo38='test';
            paper.campo39='test';
            paper.campo40='test';
            paper.codCa='test';
            paper.codCliente='test';
            paper.codContratto='test';
            paper.codFiscale='test';
            paper.codPodPdr='test';
            paper.protocollo='test';
            paper.pIva='test';
            paper.cognome='test';
            paper.dataAttivazione='test';
            paper.dataLettera='test';
            paper.dataLotto=Date.today();
            paper.frnCap='test';
            paper.frnCivico='test';
            paper.frnComune='test';
            paper.frnIndirizzo='test';
            paper.frnProv='test';
            paper.impianto='test';
            paper.lotto='test';
            paper.modalitaSpedizione='test';
            paper.nome='test';
            paper.offerta='test';
            paper.raccoCap='test';
            paper.raccoCivico='test';
            paper.raccoComune='test';
            paper.raccoIndirizzo='test';
            paper.raccoMittente='test';
            paper.raccoProv='test';
            paper.ragSociale='test';
            paper.recCap='test';
            paper.recCivico='test';
            paper.recComune='test';
            paper.recIndirizzo='test';
            paper.recIntestatario='test';
            paper.recNazione='test';
            paper.recProv='test';
            paper.resCap='test';
            paper.resCivico='test';
            paper.resComune='test';
            paper.resIndirizo='test';
            paper.resProv='test';
            paper.servizio='test';
            paper.societa='test';
            paper.tipoLettera='test';
            listPaper.add(paper);
            System.assertEquals(false, listPaper.isEmpty(),'The list of PaperProcessings was created');
            System.assertNotEquals(true, listPaper.isEmpty(),'The list of PaperProcessings was not created');
            
            Test.stopTest();

        }
    }    
}