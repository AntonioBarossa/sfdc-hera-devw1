/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Class that holds crud and business logic for SaleServiceItem__c
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_SRV_SaleServiceItem {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_SRV_Opportunity opportunityService = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteService = new HDT_SRV_Quote();
    private static HDT_QR_SaleServiceItem saleServiceItemQuery = new HDT_QR_SaleServiceItem();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();
    private static HDT_SRV_ServicePoint servicePointSrv = new HDT_SRV_ServicePoint();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SaleServiceItem__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create SaleServiceItem__c record
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     * @return SaleServiceItem__c saleServiceItem
     */
    public SaleServiceItem__c createRecord(ServicePoint__c servicePoint, Sale__c sale){

        servicePointSrv.checkReadAccess('ServicePointCode__c,RecordType.Name');
        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordById(servicePoint.Id, 'ServicePointCode__c,RecordType.Name');

        String recordTypeName = existingServicePoint[0].RecordType.Name;
        String supplyCity = servicePoint.SupplyCity__c;

        checkReadAccess('Opportunity__c,Opportunity__r.Name,Quote__c,ServicePoint__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.RecordType.Name,Opportunity__r.Sale__c');
        List<SaleServiceItem__c> existingSaleServiceItems = saleServiceItemQuery.queryExsistingCityAndType(sale.Id, supplyCity, recordTypeName);

        SaleServiceItem__c newSaleServiceItem = new SaleServiceItem__c();

        if (!existingSaleServiceItems.isEmpty()) {

            if (isServicePointConfirmed(existingSaleServiceItems, servicePoint.Id)) {
                throw new AuraHandledException('Service Point già presente in ' + existingSaleServiceItems[0].Opportunity__r.Name);
            }

            newSaleServiceItem = new SaleServiceItem__c(
                Opportunity__c = existingSaleServiceItems[0].Opportunity__c,
                Quote__c = existingSaleServiceItems[0].Quote__c,
                ServicePoint__c = servicePoint.Id
            );
        } else {
            Opportunity newOpportunity = opportunityService.createRecord(new Opportunity(
                Sale__c = sale.Id,
                Name = opportunityService.generateName(sale),
                CloseDate = Date.today().addDays(30),
                StageName = 'Proposal',
                AccountId = sale.Account__c
            ));

            SBQQ__Quote__c newQuote = quoteService.createRecord(new SBQQ__Quote__c(
                Vendita__c = sale.Id,
                SBQQ__Opportunity2__c = newOpportunity.Id,
                SBQQ__Account__c = sale.Account__c,
                SBQQ__Primary__c = true,
                Agency__c = sale.Agency__c,
                Market__c = sale.Market__c,
                Channel__c = sale.Channel__c,
                FriendCode__c = sale.FriendCode__c,
                CampaignCode__c = sale.CampaignCode__c,
                CreatedBy__c = sale.CreatedBy__c,
                SalesCompany__c = sale.SalesCompany__c,
                Comune_Fornitura__c = servicePoint.SupplyCity__c
            ));

            newOpportunity.SBQQ__PrimaryQuote__c = newQuote.Id;

            opportunityService.updateRecord(newOpportunity);

            newSaleServiceItem = new SaleServiceItem__c(
                Opportunity__c = newOpportunity.Id,
                Quote__c = newQuote.Id,
                ServicePoint__c = servicePoint.Id
            );
        }

        List<String> fields = helperMethods.getObjAttrList(newSaleServiceItem);

        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(newSaleServiceItem);

        return newSaleServiceItem;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Delete multiple SaleServiceItem__c records
     * @param List<SaleServiceItem__c>
     */
    public void deleteRecords(List<SaleServiceItem__c> records){
        HDT_UTL_DatabaseService.deleteSObject(records);
    }
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if Service Point is already confirmed for current Sale__c and Opportunity
     * @param List<SaleServiceItem__c> saleServiceItems
     * @param String servicePointId
     * @return Boolean
     */
    private Boolean isServicePointConfirmed(List<SaleServiceItem__c> saleServiceItems, String servicePointId){
        for (SaleServiceItem__c item : saleServiceItems) {
            if (item.ServicePoint__c == servicePointId) {
                return true;
            }
        }

        return false;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Group records by Opportunity
     * @param List<Opportunity>
     * @param List<SaleServiceItem__c>
     * @return List<List<SaleServiceItem__c>>
     */
    public List<List<SaleServiceItem__c>> groupRecordsByOpportunity(List<Opportunity> oppsList, List<SaleServiceItem__c> itemsList){

        List<List<SaleServiceItem__c>> oppItems = new List<List<SaleServiceItem__c>>();

        for(Opportunity opp : oppsList){

            List<SaleServiceItem__c> tempList = new List<SaleServiceItem__c>();

            for(SaleServiceItem__c item : itemsList){
                if(item.Opportunity__c == opp.Id){
                    tempList.add(item);
                }
            }

            oppItems.add(tempList);
        }

        return oppItems;
    }
}
