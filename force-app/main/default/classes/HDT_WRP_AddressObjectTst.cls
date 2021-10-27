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
    static void test1(){
        
        Test.startTest();

        HDT_WRP_AddressObject ao1 = new HDT_WRP_AddressObject('Stato','Provincia','Comune','CAP','Via','Civico','CodiceComuneSAP','EstensCivico',
                                                             'CodiceViaStradarioSAP',true, true,'Localita','CodiceLocalita');
        
        HDT_WRP_AddressObject ao2 = new HDT_WRP_AddressObject();
        
        HDT_WRP_AddressObject ao3 = HDT_WRP_AddressObject.getInstance();
        
        Test.stopTest();
        
    	System.assertEquals('Stato', ao1.Stato, 'Value of the field Stato not correctly set');
        
    	System.assertNotEquals(null, ao3, 'HDT_WRP_AddressObject.getInstance did not work correctly');
        
    }
}