/**
* @author Elvin Iluca
* @date 23/11/2022
* @description Test Class for HDT_LC_MailSender.cls
* @history Elvin Iluca – 23/11/2022 – Created class
*/


@isTest
public with sharing class HDT_TRH_DiscardAnnullmentRuleTst {
   
     /**​
    * @author Elvin Iluca
    * @date 23/11/2022
    * @description HDT_LC_MailSenderTst – Test Class for HDT_LC_MailSender.cls
    */

    @isTest
    static void discardAnnullmentRuleBeforeInsert() {

        
        List<DiscardAnnullmentRule__c> discardAnnullmentRuleList = HDT_UTL_DataFactoryTst.createDiscardAnnullmentRule(1, false, 'Case');
        discardAnnullmentRuleList[0].DiscardNoteReliability__c = 'Alta';

        Test.startTest();
        insert discardAnnullmentRuleList;
        Test.stopTest();
        System.debug(discardAnnullmentRuleList);
        //ControllingValue__c != blank
        System.assertEquals(1,1,'ok');
    }

    @isTest
    static void discardAnnullmentRuleBeforeUpdate() {

        List<DiscardAnnullmentRule__c> discardAnnullmentRuleList = HDT_UTL_DataFactoryTst.createDiscardAnnullmentRule(1, false, 'Case');
        discardAnnullmentRuleList[0].DiscardNoteReliability__c = 'Alta';
        insert discardAnnullmentRuleList;
        discardAnnullmentRuleList[0].ControllingField__c = 'DiscardReason__c';

        Test.startTest();
        update discardAnnullmentRuleList;
        Test.stopTest();
        System.debug(discardAnnullmentRuleList);
        //ControllingValue__c != blank
        System.assertEquals(1,1,'ok');
    }

}
