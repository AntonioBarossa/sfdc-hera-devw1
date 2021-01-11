/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 11/11/2020
* @description Apex controller for hdtGeneralInfo.js component
* @history Keltin Mesonjesi – 11/11/2020 – Created class
*/
public inherited sharing class HDT_LC_GeneralInfo {

    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        saleSrv.updateRecord(sale);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get current username
     * @return String username
     */
    @AuraEnabled
    public static String getCurrentUserName(){
        String userName = UserInfo.getUserName();
        return userName;
    }
}
