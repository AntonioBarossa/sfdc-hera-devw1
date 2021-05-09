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
    private static HDT_QR_Sale saleQr = new HDT_QR_Sale();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    private static List<Contract> contractsForAmendmentCheck = new List<Contract>();
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
     * @param Map<String,String> extraParams - params needed for special cases
     * @return SaleServiceItem__c saleServiceItem
     */
    public SaleServiceItem__c createRecord(ServicePoint__c servicePoint, Sale__c sale, Map<String,String> extraParams){

        //Get servicePoint data start
        servicePointSrv.checkReadAccess('ServicePointCode__c,RecordType.DeveloperName,SupplyCity__c,MarketOrigin__c,SupplySAPCityCode__c,UseCategory__c,AnnualConsumption__c,PowerContractual__c,MaxRequiredPotential__c,MeterType__c,SupplyProvince__c,Resident__c,Account__c');
        List<ServicePoint__c> existingServicePoint = servicePointQuery.getRecordById(servicePoint.Id, 'ServicePointCode__c,RecordType.DeveloperName,SupplyCity__c,MarketOrigin__c,SupplySAPCityCode__c,UseCategory__c,AnnualConsumption__c,PowerContractual__c,MaxRequiredPotential__c,MeterType__c,SupplyProvince__c,Resident__c,Account__c');
        servicePoint = existingServicePoint[0];
        //Get servicePoint data end

        //Get sale data start
        saleSrv.checkReadAccess('Account__c,Agency__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c,Name');
        Sale__c existingSale = saleQr.getRecordById(sale.id, 'Account__c,Agency__c,Channel__c,FriendCode__c,CampaignCode__c,CreatedBy__c,SalesCompany__c,Campaign__c,Name');
        sale = existingSale;
        //Get sale data end

        //Needed logic start
        Boolean allowChangeUse = false;
        Boolean amendmentAllowed = isAmendmentAllowed(servicePoint, sale);
        String contractReference = amendmentAllowed ? contractsForAmendmentCheck[0].Id : null;
        
        if (extraParams != null) {
            if (extraParams.get('AllowChangeUse__c') != null && extraParams.get('AllowChangeUse__c') == 'true') {
                contractReference = extraParams.get('contractReference');
                amendmentAllowed = false;
                allowChangeUse = true;
            }
        }
        //Needed logic end

        //Start userRoleProfile logic
        List<User> userRoleProfile = HDT_QR_UserQueries.getRoleAndProfile(UserInfo.getUserId());
        //End userRoleProfile logic

        //Start group login logic
        List<LoginGroupItem__c> loginGroupItemList = HDT_QR_LoginGroupItem.getRecordByLogin(UserInfo.getUserId());
        Set<String> groupLoginSet = new Set<String>();
        List<String> groupLoginList = new List<String>();
        String groupLoginString = '';

        if (loginGroupItemList.size() > 1) {
            for (LoginGroupItem__c loginGroupItem : loginGroupItemList) {
                groupLoginSet.add(loginGroupItem.LoginGroup__r.NameGroup__c);
            }
            groupLoginList.addAll(groupLoginSet);
            groupLoginString = String.join(groupLoginList, ',');
        } else if (loginGroupItemList.size() == 1) {
            groupLoginString = loginGroupItemList[0].LoginGroup__r.NameGroup__c;
        } else {
            groupLoginString = '';
        }
        //End group login logic

        //Start newClient logic
        String newClient = 'Y';
        if (amendmentAllowed || allowChangeUse) {
            newClient = 'N';
        }
        //End newClient logic

        //calculate fields based on commodity start
        Decimal consumptionRangeEle = servicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' ? servicePoint.AnnualConsumption__c : null;
        Decimal consumptionRangeGas = servicePoint.RecordType.DeveloperName == 'HDT_RT_Gas' ? servicePoint.AnnualConsumption__c : null;
        Decimal powerFlow = servicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' ? servicePoint.PowerContractual__c : servicePoint.MaxRequiredPotential__c;
        String residentDeliveryAddress = servicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' ? (servicePoint.Resident__c == true ? 'Y' : 'N') : 'N';
        //calculate fields based on commodity end

        //Compare logic to create new quote or not start
        Map<String,String> calculatedStringValues = new Map<String,String>();
        calculatedStringValues.put('login', UserInfo.getUserName());
        calculatedStringValues.put('loginGroup', groupLoginString);
        calculatedStringValues.put('role', userRoleProfile[0].UserRole.Name);
        calculatedStringValues.put('profile', userRoleProfile[0].Profile.Name);
        calculatedStringValues.put('newClient', newClient);
        calculatedStringValues.put('residentDeliveryAddress', residentDeliveryAddress);

        Map<String,Decimal> calculatedDecimalValues = new Map<String,Decimal>();
        calculatedDecimalValues.put('consumptionRangeEle', consumptionRangeEle);
        calculatedDecimalValues.put('consumptionRangeGas', consumptionRangeGas);
        calculatedDecimalValues.put('powerFlow', powerFlow);

        checkReadAccess('Opportunity__c,Opportunity__r.Name,Quote__c,ServicePoint__c,ServicePoint__r.SupplyCity__c,ServicePoint__r.RecordType.Name,ServicePoint__r.RecordType.DeveloperName,ServicePoint__r.RecordType.MarketOrigin__c,Opportunity__r.Sale__c');
        List<SaleServiceItem__c> existingSaleServiceItems = saleServiceItemQuery.queryExsistingCityAndType(sale, servicePoint, calculatedStringValues, calculatedDecimalValues);
        //Compare logic to create new quote or not end

        SaleServiceItem__c newSaleServiceItem = new SaleServiceItem__c();

        system.debug('!isAmendmentAllowed ' + !isAmendmentAllowed(servicePoint, sale));
        system.debug('!existingSaleServiceItems ' + !existingSaleServiceItems.isEmpty());
        system.debug('extraParams ' + extraParams);

        if (!existingSaleServiceItems.isEmpty() && !isAmendmentAllowed(servicePoint, sale) && (extraParams == null || extraParams.isEmpty())) {

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
                Sale__c = sale.Id,
                SBQQ__Status__c = 'In Review',
                SBQQ__Opportunity2__c = newOpportunity.Id,
                SBQQ__Account__c = sale.Account__c,
                SBQQ__Primary__c = true,
                Agency__c = sale.Agency__c,
                Market__c = servicePoint.MarketOrigin__c,
                Channel__c = sale.Channel__c,
                FriendCode__c = sale.FriendCode__c,
                CampaignCode__c = sale.CampaignCode__c,
                CreatedBy__c = sale.CreatedBy__c,
                SalesCompany__c = sale.SalesCompany__c,
                Campaign__c = sale.Campaign__c,
                SupplyCity__c = servicePoint.SupplySAPCityCode__c,
                AmendmentAllowed__c = amendmentAllowed,
                ContractReference__c = contractReference,
                AllowChangeUse__c = allowChangeUse,
                UseCategory__c = servicePoint.UseCategory__c,
                ConsumptionRangeEE__c = consumptionRangeEle,
                ConsumptionRangeGAS__c = consumptionRangeGas,
                PowerFlow__c = powerFlow,
                MarketOrigin__c = servicePoint.MarketOrigin__c,
                ResidentDeliveryAddress__c = residentDeliveryAddress,
                MeterType__c = servicePoint.MeterType__c,
                SupplyProvince__c = servicePoint.SupplyProvince__c,
                Login__c = UserInfo.getUserName(),
                LoginGroup__c = groupLoginString,
                Role__c = userRoleProfile[0].UserRole.Name,
                Profile__c = userRoleProfile[0].Profile.Name,
                NewClient__c = newClient
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

    public void updateRecords(List<SaleServiceItem__c> records){
        HDT_UTL_DatabaseService.updateSObject(records);
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

            if(!tempList.isEmpty()){
                oppItems.add(tempList);
            }

        }

        return oppItems;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if amendment is allowed for this tile creation
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     * @return Boolean
     */
    private Boolean isAmendmentAllowed(ServicePoint__c servicePoint, Sale__c sale){
        Boolean result = false;

        if(servicePoint.Account__c == sale.Account__c){
            String accountId = sale.Account__c;
            contractSrv.checkReadAccess('Name,AccountId,ServicePoint__c,ContractNumber,Status');
            contractsForAmendmentCheck = contractQr.getActiveRecordsByAccountIdAndServicePointId(accountId, servicePoint.Id);

            system.debug('!contractsForAmendmentCheck.isEmpty() ' + !contractsForAmendmentCheck.isEmpty());
            result = !contractsForAmendmentCheck.isEmpty();
        }

        return result;
    }
}
