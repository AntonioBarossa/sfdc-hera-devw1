/**
 * @author Valere (valere@noeli-it.net)
 * @date 24/09/2021
 * @description HDT_Subscription Test Class
 * @history valere - 24/09/2021– Created Class
 */
@isTest
private class HDT_WS_ArrichmentDataEntityRequestTst {
    @isTest 
    static void testBuilderArrichmentDataEntityRequestTst() {

        HDT_WS_ArrichmentDataEntityRequest arrichmentData= new HDT_WS_ArrichmentDataEntityRequest('one pod ', ' one contratto ');

        HDT_WS_ArrichmentDataEntityRequest arrichmentDataSecond = new HDT_WS_ArrichmentDataEntityRequest('second pod ', ' second contratto ');

        System.assertEquals(true, arrichmentData.pod!= arrichmentDataSecond.pod, 'because we created two HDT_WS_ArrichmentDataEntityRequest with different pod');
        System.assertNotEquals(false, arrichmentData.pod!= arrichmentDataSecond.pod, 'because we created two HDT_WS_ArrichmentDataEntityRequest with different pod');
    }
}