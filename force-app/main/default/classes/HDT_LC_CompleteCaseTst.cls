/**
 * Header of the class "HDT_LC_CompleteCaseTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_CompleteCase"
 * @history
 * @Created 01/10/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_CompleteCaseTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
            
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', constants.CASE_RECORDTYPEID_MOROSITA, constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'In Lavorazione', constants.CASE_RECORDTYPEID_MOROSITA, constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			Id accId = accs[0].id;
            
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1,false,accId,null,null,null,null);
            for(Case c : cases){
                c.type = 'Contratti/Bonus Commerciale';
                c.phase__c = 'Bozza';
            }
            insert cases;
            
            List<Case> casesModifica = HDT_UTL_DataFactoryTst.createCase(1,false,accId,null,null,null,null);
            for(Case c : casesModifica){
                c.type = 'Modifica Contratti PreAttivazione';
                c.phase__c = 'In Lavorazione';
            }
            insert casesModifica;
            Id caseId = casesModifica[0].id;
            
            List<wrts_prcgvr__Activity__c> activities =  HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
            for(wrts_prcgvr__Activity__c a : activities){
                a.wrts_prcgvr__Status__c = 'Chiusa';
                a.case__c = caseId;
            }
            insert activities;
            
            List<Case> casesDocumentale = HDT_UTL_DataFactoryTst.createCase(1,false,accId,null,null,null,null);
            for(Case c : casesDocumentale){
                c.type = 'Documentale/Copia Contratto';
                c.phase__c = 'In Lavorazione';
            }
            insert casesDocumentale;
            
            
            List<wrts_prcgvr__Activity__c> activitiesOpen =  HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
            for(wrts_prcgvr__Activity__c a : activitiesOpen){
                a.wrts_prcgvr__Status__c = 'Aperta';
                a.case__c = casesDocumentale[0].id;
            }
            insert activitiesOpen;
                        
        }
     }

  @isTest
	static void testContratti(){
        
        String caseId = [Select id From Case Where type = 'Contratti/Bonus Commerciale'].id;
        
        Test.startTest();
        
        String res = HDT_LC_CompleteCase.completeCase(caseId);
        
        Test.stopTest();
        
        System.assertEquals('success', res, 'The method does not return the correct string');
        
        System.assertNotEquals(null, res, 'String not returned');
        
    }
    
  @isTest
	static void testModificaContratti(){
        
        String caseId = [Select id From Case Where type = 'Modifica Contratti PreAttivazione'].id;
        
        Test.startTest();
        
        String res = HDT_LC_CompleteCase.completeCase(caseId);
        
        Test.stopTest();
        
        System.assertEquals('success', res, 'The method does not return the correct string');
        
        System.assertNotEquals([Select phase__c from Case where id =: caseId].phase__c , 'In Lavorazione', 'Case not updated');
        
    }
    
  @isTest
	static void testDocumentale(){
        
        String caseId = [Select id From Case Where type = 'Documentale/Copia Contratto'].id;
        
        Test.startTest();
        
        String res = HDT_LC_CompleteCase.completeCase(caseId);
        
        Test.stopTest();
        
        System.assertEquals('Per poter chiudere il case, l\'activity  deve essere in stato "Completato"', res, 'The method does not return the correct string');
        
        System.assertNotEquals(null, res, 'String not returned');
        
    }
}