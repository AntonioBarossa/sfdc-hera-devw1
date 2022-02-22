public inherited sharing class HDT_LC_CampaignsController {
    
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_Account accountQr =new HDT_QR_Account();
    private static HDT_SRV_CampaignMember campaignMemberSrv = new HDT_SRV_CampaignMember();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    private static HDT_SRV_CommercialCode commercialCodeSrv = new HDT_SRV_CommercialCode();
    private static HDT_QR_CommercialCode commercialCodeQr = new HDT_QR_CommercialCode();
    private static HDT_QR_Campaign campaignQr = new HDT_QR_Campaign();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Product productQr = new HDT_QR_Product();
    private static HDT_SRV_Product productSrv = new HDT_SRV_Product();
    private static HDT_QR_CampaignMemberAssigmentItem cmAssignmentItem = new HDT_QR_CampaignMemberAssigmentItem();
    
    @AuraEnabled(cacheable=true)
    public static List <CampaignMember> getCampaigns(String id, String objectName, String category, String channel) {
        campaignMemberSrv.checkReadAccess('Campaign.Name,Campaign.Status,Campaign.Channel__c,Campaign.EndDate');
        
        if (objectName == 'Contact') {
            //return all active campaigns related to this Contact
            return  campaignMemberQr.getActiveCampaignsByContact(id);
        } else if(objectName == 'Lead') {
            //return all active campaigns related to this Lead
            return campaignMemberQr.getActiveCampaignsByLead(id);
        } else if(objectName == 'Account') {
            //return all active campaigns related to all contacts related to this Account
            List<String> contacts = contactQr.getContactsIdByAccountId(id);
            if (String.isNotBlank(category)) {
                if (String.isNotBlank(channel)) {
                    return campaignMemberQr.filterCampaignsByCategoryAndChannel(contacts, category, channel);
                }
                return campaignMemberQr.filterCampaignsByCategory(contacts, category);
            }
            return campaignMemberQr.getCampaignsFilteredByContacts(contacts);
        } else {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getOutboundCampaigns() {
        return  campaignQr.getOutboundCampaigns();
    }
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getOutboundCampaignsLead() {
        return  campaignQr.getOutboundCampaignsLead();
    }
    @AuraEnabled
    public static CampaignMember updateCampaignMemberStatus(String campaignMemberId, String statusValue){
        try {
            CampaignMember cm = new CampaignMember(
            Id = campaignMemberId,
            Status = statusValue
            );
            campaignMemberSrv.updateRecord(cm);
            return cm;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<CampaignMember> updateCampaignMembersStatus(List<String> campaignMemberIds, String statusValue){
        List<CampaignMember> membersToUpdate = new List<CampaignMember> ();
        for (String id : campaignMemberIds) {
            CampaignMember cm = new CampaignMember(
            Id = id,
            Status = statusValue
            );
            membersToUpdate.add(cm);
        }
        try {
            campaignMemberSrv.updateRecords(membersToUpdate);
            return membersToUpdate;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static Case createNewCase(Case c){
        Case newCase = caseSrv.createRecord(c);
        system.debug(newCase);
        return newCase;
    }
    @AuraEnabled
    public static String getServiceCatalogUrlByCaseType(Case c){
        //Case newCase = caseSrv.createRecord(c);
        String s = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory(c.cluster__c, c.type);
        String res = '';
        if(s != null){
            res = s.replace('{!Id}',c.AccountId);
            res = res + '&c__campaignId=' + c.Campaign__c;
            //s = s.replace('', arg1)
        }
        else{
            res = null;
        }
        
        return res;
    }
    
    
    @AuraEnabled
    public static List<CampaignMember> getUnassignedCampaignMembers(String campaignId) {
        return  campaignMemberQr.getUnassignedCampaignMembers(campaignId);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsforCampaignMembers() {
        return  campaignMemberQr.getAccountsforCampaignMembers();
    }
    
    @AuraEnabled
    public static CampaignMember getAccountAndCampaign(String campaignMemberId) {
        campaignMemberSrv.checkReadAccess('ContactId,LeadId,CampaignId,GenericField1__c');
        return  campaignMemberQr.getAccountAndCampaign(campaignMemberId);
    }
    
    @AuraEnabled
    public static List<CampaignMember> assignCampaignMemberAgency(String campaignId, List<Id> toAssignObj, List<Object> Lavorazione, Date valDate){
        Map<String, String> mapLavorazione=new Map <String, String>();
        for (Object o : Lavorazione){
            string s=JSON.serialize(o);
            map<String, Object> tempMap=(map<String, Object>)JSON.deserializeUntyped(s);
            mapLavorazione.put(string.valueOf(tempMap.get('id')), string.valueOf(tempMap.get('valore')));
        }
        List<CampaignMember> allUnassignedMembers = campaignMemberQr.getUnassignedCampaignMembers(campaignId);
        List<CampaignMember> assignedMembers = new List<CampaignMember>();
        List<CampaignMemberAssigmentItem__c> items = cmAssignmentItem.getItemsByAgency(toAssignObj);
        Map<String,String> agencyProcessingTypeMap = new Map<String,String>();
        for (CampaignMemberAssigmentItem__c item : items) {
            agencyProcessingTypeMap.put((String)item.Agency__c, (String)item.ProcessingType__c);
        }
        for (Id agencyId : toAssignObj) {
            CampaignMember cm = allUnassignedMembers[0];
            cm.Agency__c = agencyId;
            //cm.ProcessingType__c = agencyProcessingTypeMap.get((String)agencyId);
            if(mapLavorazione.containsKey(agencyId)){
                cm.ProcessingType__c=mapLavorazione.get(agencyId);
            }
            if(valDate!=null){
                cm.NumberingValidityStartDate__c=valDate;
            }
            assignedMembers.add(cm);
            allUnassignedMembers.remove(0);            
        }
        
        campaignMemberSrv.updateRecords(assignedMembers);
        return assignedMembers;
    }
    
    @AuraEnabled
    public static CampaignMember updateCampaignMemberSurveyResponse(String campaignMemberId, String surveyResponseId){
        try {
            CampaignMember cm = new CampaignMember(
            Id = campaignMemberId,
            SurveyResponse__c = surveyResponseId
            );
            campaignMemberSrv.updateRecord(cm);
            return cm;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static CommercialCode__c createCommercialCode(String campaignId){
        Campaign cmp = campaignQr.getCommercialCodeCampaign(campaignId);
        System.debug('create Commercial code');
        try {
            System.debug('try to create Commercial code');
            CommercialCode__c cc = new CommercialCode__c (
            Campaign__c = campaignId,
            FullCode__c = cmp.PrefixCode__c,
            Name = cmp.PrefixCode__c,
            MaximalUsesEE__c = cmp.MaxNumberEECodeUse__c,
            MaximalUsesGAS__c = cmp.MaxNumberGASCodeUse__c,
            MaximalUsesVAS__c = cmp.MaxNumberVASCodeUse__c,
            ActualUsesEE__c = 0,
            ActualUsesGAS__c = 0,
            ActualUsesVAS__c = 0,
            RecoveryUsesEE__c = 0,
            RecoveryUsesGAS__c = 0,
            RecoveryUsesVAS__c = 0
            );
            CommercialCode__c res = commercialCodeSrv.createRecord(cc);
            return res;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkCommercialCodeUniqueness(String commercialCode, String campaignId) {
        List<Campaign> campaignsList = campaignQr.getCommercialCode(commercialCode, campaignId);
        if (campaignsList.size() > 0) {
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static Boolean cancelAssignments(String recordId){
        Campaign camp = campaignQr.getRecordById(recordId);
        if (camp.AssignmentType__c == 'Manuale' /*&& (camp.LavorazioneFUB__c == '' || camp.LavorazioneFUB__c == null)*/) {
            List<CampaignMember> cmList = campaignMemberQr.getMembersByCampaign(recordId);
            System.debug(cmList);
            if (cmList.size() > 0) {
                List<CampaignMember> updateMembers = new List<CampaignMember>();
                for (CampaignMember cm : cmList) {
                    if (cm.Agency__c != null) {
                        CampaignMember newCm = new CampaignMember(
                        Id = cm.Id,
                        Agency__c = null
                        );
                        updateMembers.add(newCm);
                        System.debug(updateMembers);
                    }
                }
                try {
                    campaignMemberSrv.updateRecords(updateMembers);
                    return true;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    return false;
                }
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean incrementCommercialCode(String recordId, String commodity){
        CommercialCode__c commCode = commercialCodeQr.getRecordById(recordId);
        Boolean isValid = false;
        if (commodity == 'energia elettrica') {
            if (commCode.AvailabilityUsesEE__c > 0) {
                commCode.ActualUsesEE__c += 1;
                isValid = true;
            }
        } else if (commodity == 'gas') {
            if (commCode.AvailabilityUsesGAS__c > 0) {
                commCode.ActualUsesGAS__c += 1;
                isValid = true;
            }
        } else if (commodity == 'vas') {
            if (commCode.AvailabilityUsesVAS__c > 0) {
                commCode.ActualUsesVAS__c += 1;
                isValid = true;
            }            
        }
        
        System.debug(commCode);
        
        if (isValid) {
            commercialCodeSrv.updateRecord(commCode);
        }
        
        return isValid;
    }
    
    @AuraEnabled
    public static Boolean bulkIncrementCommercialCode(String recordId, Map<String,Integer> commodityQuantity){
        CommercialCode__c commCode = commercialCodeQr.getRecordById(recordId);
        Boolean isValid = false;
        for(String commodity : commodityQuantity.keySet()){
            Integer qnt = commodityQuantity.get(commodity);
            if (commodity == 'energia elettrica') {
                if (commCode.AvailabilityUsesEE__c >= qnt) {
                    commCode.ActualUsesEE__c += qnt;
                    isValid = true;
                }
            } else if (commodity == 'gas') {
                if (commCode.AvailabilityUsesGAS__c >= qnt) {
                    commCode.ActualUsesGAS__c += qnt;
                    isValid = true;
                }
            } else if (commodity == 'vas') {
                if (commCode.AvailabilityUsesVAS__c >= qnt) {
                    commCode.ActualUsesVAS__c += qnt;
                    isValid = true;
                }            
            }
        }
        
        System.debug(commCode);
        
        if (isValid) {
            commercialCodeSrv.updateRecord(commCode);
        }
        return isValid;
    }
    
    @AuraEnabled
    public static Boolean cancelAssignmentsOrder(String recordId){
        Order order = orderQr.getOrderbyId(recordId);
        if (order.FriendCode__c != '' || order.FriendCode__c != null) {
            CommercialCode__c friendCodeRec = commercialCodeQr.getRecordById(order.FriendCode__c);
            System.debug(friendCodeRec);
            friendCodeRec.AvailabilityUsesEE__c = friendCodeRec.AvailabilityUsesEE__c > 0 ? friendCodeRec.AvailabilityUsesEE__c - 1 : 0;
            friendCodeRec.AvailabilityUsesGAS__c = friendCodeRec.AvailabilityUsesGAS__c > 0 ? friendCodeRec.AvailabilityUsesGAS__c - 1 : 0;
            friendCodeRec.AvailabilityUsesVAS__c = friendCodeRec.AvailabilityUsesVAS__c > 0 ? friendCodeRec.AvailabilityUsesVAS__c - 1 : 0;
            order.FriendCode__c = null;
            try {
                commercialCodeSrv.updateRecord(friendCodeRec);
                orderSrv.updateRecord(order);
                return true;
            } catch (Exception e) {
                System.debug(e.getMessage());
                return false;
            }
        }
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllProducts(String IdGruppoEleggibilitCampagne)  {
        try {
            List<Product2> prodList = HDT_QR_Product.getAllProducts(IdGruppoEleggibilitCampagne);
            return prodList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static String assignSelectedProducts(String IdGruppoEleggibilitCampagne, List<Id> productIds, List<Id> deselectProductIds) {
        List<Product2> productList = new List<Product2> ();
        for (String id : productIds) {
            Product2 prod = new Product2(
            Id = id,
            CampaignEleggibilityGroup__c = IdGruppoEleggibilitCampagne
            );
            productList.add(prod);
        }
        
        for (String id : deselectProductIds) {
            Product2 prod = new Product2(
            Id = id,
            CampaignEleggibilityGroup__c = null
            );
            productList.add(prod);
        }
        
        try {
            productSrv.updateRecords(productList);
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getUserRole(String userId){
        try {
            User usr = [SELECT Id, Name, UserRole.Name FROM User WHERE Id = :userId WITH SECURITY_ENFORCED];
            System.debug(usr.UserRole.Name);
            System.debug(userId);
            return usr.UserRole.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean methodClosedTab(String id, String objectName, String category, String channel){
        List <CampaignMember> cm= getCampaigns( id,  objectName,  category,  channel);
        
        List<String> campaignMemberIds = new List<String>();
        if (cm!=null &&cm.size()>0 ) {
            
            
            for (CampaignMember tempCm : cm) {
                if(tempCm.Campaign.Required__c == true && tempCm.Campaign.Category__c == 'Campagna CRM') {
                    
                    campaignMemberIds.add(tempCm.Id);
                }
            }
            System.debug('campaignMemberIds '+campaignMemberIds);
            List<CampaignMember>campMemUp =updateCampaignMembersStatus(campaignMemberIds, 'Non Proposto Auto');
            System.debug('campMemUp : '+campMemUp);
            System.debug('campMemUp!=null : '+String.valueOf(campMemUp!=null));
            System.debug('campMemUp.size()>0 : '+String.valueOf(campMemUp.size()>0));
            return campMemUp!=null && campMemUp.size()>0?true:false;
        }
        
        return false;
        
    }
    @AuraEnabled
    public static  List <CampaignMember> requiredCampaignCheck(String id){
        System.debug('id : '+id);
        if (String.isBlank(id)) {
            return null;
        }
        List <CampaignMember> cm= getCampaigns( id,  'Account',  'Campagna CRM',  '');
        
        
        List<CampaignMember> campaignMemberIds = new List<CampaignMember>();
        
        
        
        for (CampaignMember tempCm : cm) {
            if(tempCm.Campaign.Required__c == true && tempCm.Campaign.Category__c == 'Campagna CRM') {
                
                campaignMemberIds.add(tempCm);
            }
        }
        System.debug('campaignMemberIds '+campaignMemberIds);
        //  List<CampaignMember>campMemUp =updateCampaignMembersStatus(campaignMemberIds, 'Non Proposto Auto');
        
        return campaignMemberIds;
        
        
    }
    @AuraEnabled
    public static  Account getCurrentAccount(String id){
        System.debug('######id :' +id);
        if (String.isBlank(id)) {
            return null;
        }
      //  List<String> listFiels = new List<String>{'name'};
        List<Account> listAcc =accountQr.getAccountById(id);
        Account currentAccount = listAcc.get(0);
        
        return currentAccount ;
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static CampaignMember getCampaignAndAccountByMember(String campaignMemberId){
        try {
            CampaignMember cm = [SELECT Id, GenericField1__c ,Contact.AccountId, CampaignId, Campaign.CaseCategory__c, Campaign.CaseSubCategory__c FROM CampaignMember WHERE Id = :campaignMemberId WITH SECURITY_ENFORCED];
            System.debug(cm);
            return cm;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}