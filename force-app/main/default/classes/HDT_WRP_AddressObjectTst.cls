/**
 * Header of the class "HDT_WRP_AddressObjectTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WRP_AddressObject"
 * @history
 * @Created 01/10/2021
 * Modified By:
 **/

@isTest
public class HDT_WRP_AddressObjectTst {
    
    @isTest
    static void test(){
        
        Test.startTest();

        HDT_WRP_AddressObject ao = new HDT_WRP_AddressObject('Stato','Provincia','Comune','CAP','Via','Civico','CodiceComuneSAP','EstensCivico',
                                                             'CodiceViaStradarioSAP',true, true,'Localita','CodiceLocalita');
        
        HDT_WRP_AddressObject aoVoid = new HDT_WRP_AddressObject();
        
        HDT_WRP_AddressObject aoInstance = HDT_WRP_AddressObject.getInstance();
        
        Test.stopTest();
        
    	System.assertEquals('Stato', ao.Stato, 'Value of the field Stato not correctly set');
        
    	System.assertNotEquals(null, aoVoid, 'HDT_WRP_AddressObject.getInstance did not work correctly');
        System.assertNotEquals(null, aoInstance, 'HDT_WRP_AddressObject.getInstance did not work correctly');
        
    }
}