/*
    @Author:            Davide Viola
    LAstModifiedDate:   30/06/2022
*/
@isTest
public with sharing class HDT_LC_AccountReAssignToMeTst {

    @testSetup
    static void setupData() {
        
        HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Famiglie');
    }

    @isTest
    public static void assignAccountToUserTst(){
        
        String retVal = '';
        Account myAcc = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        retVal = HDT_LC_AccountReAssignToMe.assignAccountToUser(myAcc.Id);
        System.assertEquals(retVal, 'OK', 'Modifica avvenuta con Successo.');        
        Test.stopTest();

        myAcc = [SELECT Id, Name, OwnerId FROM Account LIMIT 1];
        System.assertEquals(UserInfo.getUserId(), myAcc.OwnerId, 'Owner Modificato.');

        delete myAcc;
        retVal = HDT_LC_AccountReAssignToMe.assignAccountToUser(myAcc.Id);
        System.assertEquals(retVal, 'Errore. Assegnazione non riuscita.', 'Account non trovato.'); 
    }
}
