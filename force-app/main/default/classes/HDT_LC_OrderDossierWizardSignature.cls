/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/01/2021
* @description Apex controller hdtOrderDossierWizardSignature component
* @history Keltin Mesonjesi – 13/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizardSignature {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 15/01/2021
    * @description Handle controller initial data fetch
    * @param String orderParentId
    * @param String accountId
    * @return Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> controllerInit(String orderParentId, String accountId){
        Map<String,Object> result = new Map<String,Object>();

        Contact primaryContact = contactQr.getPrimaryContactByAccount(accountId);
        result.put('primaryContactEmail', primaryContact.Email);

        List<Order>ordChildList = orderQr.getChildOrdersByParentId(orderParentId);
        result.put('ordChildList', ordChildList);

        return result;
    }

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
