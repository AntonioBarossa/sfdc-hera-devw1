/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Class that holds crud and business logic for Opportunity
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/

public inherited sharing class HDT_SRV_Opportunity {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_QR_Opportunity opportunityQuery = new HDT_QR_Opportunity();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Quote quoteService = new HDT_SRV_Quote();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has update permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Generate default Opportunity name when creating SaleServiceItem
     * @param sale
     * @return String name ex. 'Opportunity 1 Vendita 50'
     */
    public String generateName(Sale__c sale){

        List<String> saleNameList = sale.Name.split(' ');

        return 'Opportunity' + ' ' + (opportunityQuery.countRecordsBySale(sale.Id)+1) + ' ' + saleNameList[0] + ' ' + saleNameList[saleNameList.size() - 1];
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create Opportunity record
     * @param opportunity
     * @return Opportunity
     */
    public Opportunity createRecord(Opportunity opportunity){
        
        List<String> fields = helperMethods.getObjAttrList(opportunity);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        HDT_UTL_DatabaseService.insertSObject(opportunity);

        return opportunity;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Update Opportunity record based on Opportunity.Id
    * @param opportunity - Opportunity record with fields to update
    */
    public void updateRecord(Opportunity opportunity){
        List<String> fields = helperMethods.getObjAttrList(opportunity);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(opportunity);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 14/12/2020
    * @description Update Opportunity records based on Opportunity.Id
    * @param opportunities
    */
    public void updateRecords(List<Opportunity> opportunities){

        for (Opportunity opp : opportunities) {
            List<String> fields = helperMethods.getObjAttrList(opp);
            checkUpdateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.updateSObject(opportunities);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Delete single record
     * @param opportunityId
     */
    public void deleteRecord(String opportunityId){
        List<SaleServiceItem__c> saleServiceItemRecords = saleServiceItemQuery.getRecordsByOpportunityId(opportunityId);
        
        if (!saleServiceItemRecords.isEmpty()) {
            saleServiceItemService.deleteRecords(saleServiceItemRecords);
        }

        Opportunity opp = opportunityQuery.getRecordById(opportunityId);
        
        quoteService.deleteRecord(opp.SBQQ__PrimaryQuote__c);
        HDT_UTL_DatabaseService.deleteSObject(opportunityId);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Delete records
     * @param opportunities
     */
    public void deleteRecords(List<String> opportunities){
        HDT_UTL_DatabaseService.deleteSObject(opportunities);
    }
}
