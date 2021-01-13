/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/01/2021
* @description Apex controller hdtOrderDossierWizardSignature component
* @history Keltin Mesonjesi – 13/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizardSignature {

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order(); 

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 13/01/2021
    * @description Handle next action on signature section
    * @param Order orderUpdates
    */
    @AuraEnabled
    public static void next(Order orderUpdates){
        
        orderSrv.updateRecord(orderUpdates);

    }

}
