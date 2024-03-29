@SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidDeeplyNestedIfStmts, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.FormalParameterNamingConventions')
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

        String userId = UserInfo.getUserId();
        User currentUser = HDT_QR_UserQueries.getRoleAndProfile(userId)[0];

        if(String.isBlank(objectName)){
            Id objId = id;
            objectName = objId.getSObjectType().getDescribe().getName();
        }
        
        if(!currentUser.IsPortalEnabled){
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
            }
            else {
                return null;
            }
        }
        else {
            if(objectName.equalsIgnoreCase('Contact')){
                return  campaignMemberQr.getCampaignsByContactPartner(id, currentUser);
            }
            else if(objectName.equalsIgnoreCase('Lead')) {
                return  campaignMemberQr.getCampaignsByLeadPartner(id, currentUser);
            }else if(objectName.equalsIgnoreCase('Account')) {
                //return all active campaigns related to all contacts related to this Account
                List<String> contacts = contactQr.getContactsIdByAccountId(id);
                if (String.isNotBlank(category)) {
                    if (String.isNotBlank(channel)) {
                        return campaignMemberQr.filterCampaignsByCategoryAndChannelWithStatus(contacts, category, channel);
                    }
                    return campaignMemberQr.filterCampaignsByCategoryWithStatus(contacts, category);
                }
                return campaignMemberQr.getCampaignsFilteredByContactsWithStatus(contacts);
            }
            else {
                return null;
            }
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
        }
        catch (Exception e) {
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
            return null;
        }        
    }
    
    @AuraEnabled
    public static Case createNewCase(Case c){
        Case newCase = caseSrv.createRecord(c);
        return newCase;
    }

    @AuraEnabled
    public static String getServiceCatalogUrlByCaseType(Case c, string campaignMemberId){
        //Case newCase = caseSrv.createRecord(c);
        String s = HDT_QR_ServiceCatalog.getServiceLinkItemAccountRedirectUrlByCategory(c.cluster__c, c.type);
        String res = '';
        if(s != null){
            res = s.replace('{!Id}',c.AccountId);
            res = res + '&c__campaignId=' + c.Campaign__c;
            res = res + '&c__campaignMemberId=' + campaignMemberId;
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
    public static CampaignMember updateCampaignMemberSurveyResponse(String campaignMemberId, String surveyResponseId,String response){
        try {
            CampaignMember cm = new CampaignMember(
            Id = campaignMemberId,
            SurveyResponse__c = surveyResponseId,
            SurveyResponseTracking__c = response
            );
            campaignMemberSrv.updateRecord(cm);
            return cm;
        }
        catch (Exception e) {
            return null;
        }
    }
    
    @AuraEnabled
    public static CommercialCode__c createCommercialCode(String campaignId){

        Campaign cmp = campaignQr.getCommercialCodeCampaign(campaignId);
        try {
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
        }
        catch (Exception e) {
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
            if (cmList.size() > 0) {
                List<CampaignMember> updateMembers = new List<CampaignMember>();
                for (CampaignMember cm : cmList) {
                    if (cm.Agency__c != null) {
                        CampaignMember newCm = new CampaignMember(
                        Id = cm.Id,
                        Agency__c = null
                        );
                        updateMembers.add(newCm);
                    }
                }
                try {
                    campaignMemberSrv.updateRecords(updateMembers);
                    return true;
                }
                catch (Exception e) {
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
            friendCodeRec.AvailabilityUsesEE__c = friendCodeRec.AvailabilityUsesEE__c > 0 ? friendCodeRec.AvailabilityUsesEE__c - 1 : 0;
            friendCodeRec.AvailabilityUsesGAS__c = friendCodeRec.AvailabilityUsesGAS__c > 0 ? friendCodeRec.AvailabilityUsesGAS__c - 1 : 0;
            friendCodeRec.AvailabilityUsesVAS__c = friendCodeRec.AvailabilityUsesVAS__c > 0 ? friendCodeRec.AvailabilityUsesVAS__c - 1 : 0;
            order.FriendCode__c = null;
            try {
                commercialCodeSrv.updateRecord(friendCodeRec);
                orderSrv.updateRecord(order);
                return true;
            } catch (Exception e) {
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
            return e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getUserRole(String userId){
        try {
            User usr = [SELECT Id, Name, UserRole.Name FROM User WHERE Id = :userId WITH SECURITY_ENFORCED];
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
            List<CampaignMember>campMemUp =updateCampaignMembersStatus(campaignMemberIds, 'Non Proposto Auto');
            return campMemUp!=null && campMemUp.size()>0?true:false;
        }
        return false;
    }

    @AuraEnabled
    public static  List <CampaignMember> requiredCampaignCheck(String id){

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
        
        return campaignMemberIds;
    }

    @AuraEnabled
    public static  Account getCurrentAccount(String id){

        if (String.isBlank(id)) {
            return null;
        }
        List<Account> listAcc =accountQr.getAccountById(id);
        Account currentAccount = listAcc.get(0);
        
        return currentAccount;        
    }
    
    @AuraEnabled(cacheable=true)
    public static CampaignMember getCampaignAndAccountByMember(String campaignMemberId){
        try {
            CampaignMember cm = [SELECT Id, GenericField1__c ,Contact.AccountId, LeadId, CampaignId, Campaign.CaseCategory__c, Campaign.CaseSubCategory__c, Campaign.ProcessType__c, Campaign.PositiveOutcomeDefaultStatus__c FROM CampaignMember WHERE Id = :campaignMemberId WITH SECURITY_ENFORCED];
            return cm;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static  String getAccountId(String campaignMemberId){
        if (String.isBlank(campaignMemberId)) {
            return null;
        }

        list <CampaignMember> cm = [SELECT Id, GenericField1__c FROM CampaignMember WHERE Id = :campaignMemberId WITH SECURITY_ENFORCED];

        if(cm!=null && cm.size()>0 && String.isNotBlank(cm[0].GenericField1__c)){
            List <Account> acc=[SELECT Id FROM Account WHERE Id=:cm[0].GenericField1__c WITH SECURITY_ENFORCED];
            if (acc!=null && acc.size()>0) {
                return acc[0].Id;
            }
        }
        return null;
    }

    @AuraEnabled
    public static  String getCampaignChannel(String campaignMemberId){
        if (String.isBlank(campaignMemberId)) {
            return null;
        }

        list <CampaignMember> cm = [SELECT Id, Campaign.Channel__c FROM CampaignMember WHERE Id = :campaignMemberId WITH SECURITY_ENFORCED];

        if(cm!=null && cm.size()>0 && String.isNotBlank(cm[0].Campaign.Channel__c)){
            return cm[0].Campaign.Channel__c;
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, String> getOutcomeValues(String campaignMemberId, String outcomeType){

        Map<String, String> partialOutcomeValues = new Map<String, String>();
        Set<String> campaignIds = new Set<String>();
        List<Campaign> campaignList = new List<Campaign>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();

        List<HDT_CampaignMemberStatus__mdt> campaignStatusMdt = HDT_QR_CampaignMemberStatusMetadata.getRecords();

        campaignMemberList = [SELECT Id, CampaignId FROM CampaignMember WHERE Id =: campaignMemberId];

        for(CampaignMember cm : campaignMemberList){
            campaignIds.add(cm.CampaignId);
        }

        campaignList = [SELECT Id, Category__c, Channel__c FROM Campaign WHERE Id IN: campaignIds];

        for(HDT_CampaignMemberStatus__mdt cmdt : campaignStatusMdt){
            if (
                ((cmdt.Category__c == 'Entrambi' && cmdt.Channel__c == 'Tutti' && campaignList[0].Channel__c!='Door to Door') ||
                (campaignList[0].Category__c == 'Campagna CRM' && (cmdt.Category__c == 'Inbound' || cmdt.Category__c == 'Entrambi') && cmdt.Channel__c == 'Tutti') || (
                    (campaignList[0].Category__c == 'Campagna Outbound' && cmdt.Category__c == 'Outbound') && (
                        (campaignList[0].Channel__c == 'Telefonico Outbound' && cmdt.Channel__c == 'Telefonico Outbound') ||
                        (campaignList[0].Channel__c == 'Cartaceo' && cmdt.Channel__c == 'Cartaceo')
                    )
                ) ||
                (campaignList[0].Category__c == 'Campagna Marketing Cloud' && cmdt.Category__c == 'Marketing Cloud') || 
                (cmdt.Category__c == 'Outbound' && cmdt.Channel__c == 'Door to Door' && campaignList[0].Channel__c=='Door to Door')) && (cmdt.OutcomeCategory__c == outcomeType)
            )  {
                if(outcomeType !=  'Esito Parziale')
                    partialOutcomeValues.put(cmdt.StatusName__c, cmdt.StatusName__c);
                else
                    partialOutcomeValues.put(cmdt.StatusName__c, cmdt.DeveloperName);

            }
        }
        return partialOutcomeValues;
    }

    @AuraEnabled
    public static Boolean getCurrUserRole(){

        String roleId=UserInfo.getUserRoleId();
        List <UserRole> currUserRole=new List <UserRole>();
        if(String.isNotBlank(roleId)){
            currUserRole=[SELECT Id, Name FROM UserRole WHERE Id=:roleId LIMIT 1];
            if (currUserRole[0].Name.containsIgnoreCase('Front')) {
                return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static string getCampaignMemberPhone(String campaignMemberId){
        HDT_QR_CampaignMember cmquery = new HDT_QR_CampaignMember();
        CampaignMember cm = cmquery.getRecordById(campaignMemberId);
        if(cm.PhoneNumber__c != null && cm.PhoneNumber__c != ''){
            return cm.PhoneNumber__c;
        }else{
            return null;
        }
         
    }

    @AuraEnabled
    public static List<CampaignMember> getCampaignMember(String campaignMemberId){
        HDT_QR_CampaignMember cmquery = new HDT_QR_CampaignMember();
        List<CampaignMember> campaignMembers = new List<CampaignMember>();    
        campaignMembers.add(cmquery.getRecordById(campaignMemberId));
        if(!campaignMembers.isEmpty()){
            return campaignMembers;
        }
        else{
            return null;
        }         
    }

    @AuraEnabled
    public static string getCampaignTipology(String campaignMemberId){
        HDT_QR_CampaignMember cmquery = new HDT_QR_CampaignMember();
        CampaignMember cm = cmquery.getRecordById(campaignMemberId);
        if(cm.Campaign.Tipology__c != null && cm.Campaign.Tipology__c != ''){
            return cm.Campaign.Tipology__c;
        }else{
            return '';
        }
    }

    @AuraEnabled
    public static string getEcid(String campaignMemberId){
        try{
            HDT_QR_CampaignMember cmquery = new HDT_QR_CampaignMember();
            CampaignMember cm = cmquery.getRecordById(campaignMemberId);
            if(cm.Campaign.ObligatorySurvey__c && cm.SurveyResponse__c == null){
                return System.label.ObligatoryClientSurvey;
            }else if(cm.Ecid__c != null && cm.Ecid__c != ''){
                return cm.Ecid__c;
            }else{
                String response = submitRequest(campaignMemberId);
    
                system.debug('response --> '+response);
    
                Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(response);
                Map<String,Object> data = new Map<String,Object>();
                List<Object> rowList = new List<Object>();
                Map<String,Object> rowMap = new Map<String,Object>();
                String jsonEcid = '';
    
    
                if(!jsonMap.isEmpty() && jsonMap != null){
                    data = (Map<String,Object>)jsonMap.get('data');
                    system.debug('data --> '+data);
                    if(!data.isEmpty() && data != null){
                        system.debug('data valorizzato');
                        rowList = (List<Object>)data.get('rowList');
                        system.debug('rowList --> '+rowList);
    
                        if(!rowList.isEmpty() && rowList != null){
                            system.debug('rowList valorizzato');
    
                            rowMap =  (Map<String,Object>)rowList[0];
            
                            system.debug('rowMap --> '+rowMap);
            
                            if(!rowMap.isEmpty()){
                                jsonEcid = (String)rowMap.get('builtinEcid');
                            }
                        } 
                    }
                }
    
                system.debug('data --> '+data);
                system.debug('rowList --> '+rowList);
                system.debug('jsonEcid --> '+jsonEcid);

                if(jsonEcid != '' && jsonEcid != null){
                    cm.Ecid__c = jsonEcid;
                    HDT_UTL_DatabaseService.updateSObject(cm);
                }

    
                return jsonEcid;
            }
        }
        catch(Exception ex){

            System.debug('ERROR --> '+ex.getMessage());
            return null;

        }
        
         
    }

    private static String submitRequest(String campaignMemberId){

        String params = '{\n'
            +'\"listFieldToSearch\": [\n'
            +'    {\n'
            +'        \"value\": \"'+campaignMemberId+'\",\n'
            +'        \"categorizedFieldKeyCode\": \"CAMPAIGN_MEMBER_ID\"\n'
            +'    }\n'
            +'],\n'
            +'\"fieldList\": [\n'
            +'    \"BUILTIN_ECID\"\n'
            +'],\n'
            +'\"searchMode\": \"REGEXP\",\n'
            +'\"macroActivityRegExp\" : \".*\",\n'
            +'\"enabled\": true,\n'
            +'\"active\": true,\n'
            +'\"excludeTerminated\": true\n'
        +'}\n';

        HttpRequest req = new HttpRequest();
        try {
            System.debug(LoggingLevel.DEBUG, 'body: ' + params);
            req.setEndpoint('Callout:MulesoftBasePath/campaigns/ecid/search');
            req.setMethod('POST');
            req.setBody(params);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(28000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'submitRequest - Exception StackTraceString: ' + ex.getStackTraceString());
        }
        return null;
    }

    @AuraEnabled
    public static String getCurrentProfile(){

        User currentUser = [SELECT Id, UserCompany__c, LoginChannel__c, CreatorGroup__c, ProfileName__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

        return currentUser.ProfileName__c;

    }

    
}