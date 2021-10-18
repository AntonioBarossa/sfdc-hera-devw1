/**
 * Header of the class "HDT_SRV_VocalOrderPublicConfirmTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_SRV_VocalOrderPublicConfirm"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/
@isTest
public class HDT_SRV_VocalOrderPublicConfirmTst {
    
    @isTest static void test(){
        
        HDT_SRV_VocalOrderPublicConfirm.createRecord(new VocalOrderPublicConfirm__c());
        
        List<VocalOrderPublicConfirm__c> query = [Select id from VocalOrderPublicConfirm__c];
        
        System.assertEquals(1, query.size(), 'VocalOrderPublicConfirm not created correctly');
        System.assertNotEquals(null, query, 'VocalOrderPublicConfirm not created correctly');
        
    }
}