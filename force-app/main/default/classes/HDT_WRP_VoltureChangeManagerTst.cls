/**@frpanico 12/10/2021
 * Test Class for the class HDT_WRP_VoltureChangeManager
 */

@IsTest
public with sharing class HDT_WRP_VoltureChangeManagerTst {

    @IsTest
    static void tstMethod()
    {
        Test.startTest();
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        accountCheck.nextPhase = 'Comunicazione verso Heroku';
        Test.stopTest(); 
        System.assertEquals('Comunicazione verso Heroku', accountCheck.nextPhase,'Fase non corretta');
    }

}
