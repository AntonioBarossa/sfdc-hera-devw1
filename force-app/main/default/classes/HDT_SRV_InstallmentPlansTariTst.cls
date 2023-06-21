/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 04/08/2022
 * @description test class for HDT_SRV_InstallmentPlansTari
 * @history Andrei Necsulescu – 04/08/2022 – Created class
 */

@isTest
public with sharing class HDT_SRV_InstallmentPlansTariTst {
    
    @TestSetup
    static void makeData(){
        
        HDT_UTL_DataFactoryTst.installPhaseManagerSObjectSetting('Çase');
        HDT_UTL_DataFactoryTst.installCsDependecyPhaseCheckSetting('Bozza');
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME').get(0);
        Contact con = HDT_UTL_DataFactoryTst.createContact(1, true, acc.Id).get(0);
        ServicePoint__c svp = HDT_UTL_DataFactoryTst.createServicePoint(1, true).get(0);
        Contract cnt = HDT_UTL_DataFactoryTst.createContract(1, true, acc.Id).get(0);
        
        HDT_UTL_DataFactoryTst.createcase(1, true, acc.Id, con.Id, null, cnt.Id, null);
        
        RentProcessRule__c rpr = HDT_UTL_DataFactoryTst.createRentProcessRule(1, false, false, false).get(0);
        rpr.City__c = 'Bologna';
        rpr.RateCategory__C = 'rate category';
        rpr.MandatoryAttachments__c = 'file1, file2';

        insert rpr;

    }

    @IsTest
    static void predefaultTariInstallmentFieldsTest(){

        HDT_SRV_InstallmentPlansTari.HDT_UTL_FlowInputs input = new HDT_SRV_InstallmentPlansTari.HDT_UTL_FlowInputs();

        input.recordId = [SELECT Id FROM Case LIMIT 1].Id;
        input.comuneUbicazione = 'Bologna';
        input.importoDaRateizzare = 1045.65;
        input.prodottoDiPrimoLivello = 'rate category';

        Test.startTest();
            
            HDT_SRV_InstallmentPlansTari.predefaultTariInstallmentFields(new List<HDT_SRV_InstallmentPlansTari.HDT_UTL_FlowInputs>{input});

            System.assertEquals('file1, file2', [SELECT MandatoryAttachments__c FROM Case LIMIT 1].MandatoryAttachments__c, 'The MandatoryAttachments__c field was not updated properly');

        Test.stopTest();
        
    }

    // @IsTest
    // static void evaluateExpressiontest(){

    //     Test.startTest();
        
    //         System.assertEquals(false, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} > 800.85', '{0}'), 'The expression > was not evaluated correctly');
    //         System.assertEquals(false, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} >= 800.85', '{0}'), 'The expression >= was not evaluated correctly');
    //         System.assertEquals(true, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} < 800.85', '{0}'), 'The expression < was not evaluated correctly');
    //         System.assertEquals(true, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} <= 800.85', '{0}'), 'The expression <=> was not evaluated correctly');
    //         System.assertEquals(true, HDT_SRV_InstallmentPlansTari.evaluateExpression(800.85, '{0} = 800.85', '{0}'), 'The expression = was not evaluated correctly');
    //         System.assertEquals(false, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} == 800.85', '{0}'), 'The expression == was not evaluated correctly');
    //         System.assertEquals(false, HDT_SRV_InstallmentPlansTari.evaluateExpression(420.69, '{0} $ 800.85', '{0}'), 'The expression invalid was not evaluated correctly');
        
    //     Test.stopTest();
        
    // }

}
