public inherited sharing class HDT_SRV_Opportunity {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_QR_Opportunity opportunityQuery = new HDT_QR_Opportunity();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Quote quoteService = new HDT_SRV_Quote();
    private static String CREATEPERMISSION = 'create';
    private static String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * Generate default Opportunity name when creating SaleServiceItem
     * @param String Sale__c.Name
     * @return String name ex. 'Opportunity 1 Vendita 50'
     */
    public String generateName(Sale__c sale){

        List<String> saleNameList = sale.Name.split(' ');

        return 'Opportunity' + ' ' + (opportunityQuery.countRecordsBySale(sale.Id)+1) + ' ' + saleNameList[0] + ' ' + saleNameList[saleNameList.size() - 1];
    }

    /**
     * Create Opportunity record
     * @param Opportunity
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
    * @param Opportunity opportunity - Opportunity record with fields to update
    */
    public void updateRecord(Opportunity opportunity){
        List<String> fields = helperMethods.getObjAttrList(opportunity);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(opportunity);
    }

    /**
     * Delete single record
     * @param Opportunity.Id
     */
    public void deleteRecord(String opportunityId){
        List<SaleServiceItem__c> saleServiceItemRecords = saleServiceItemQuery.getRecordsByOpportunityId(opportunityId);
        String quoteId = saleServiceItemRecords[0].Quote__c;
        saleServiceItemService.deleteRecords(saleServiceItemRecords);
        quoteService.deleteRecord(quoteId);

        HDT_UTL_DatabaseService.deleteSObject(opportunityId);
    }
}
