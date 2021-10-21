public without sharing class HDT_UTL_ProcessTakeOver extends  HDT_UTL_ProcessExecution {
    private  Map<String, String> mapAccountFields;
    private Map<String, String> mapSaleFields;
    private Map<String, String> mapServicePointFields;
    private Map<String, String> mapBillingProfileFields;
    private Map<String, String> mapOrderFields;
    private Map<String, String> mapOrderItemFields;
    private List<SObject> listUpdateGeneric ;

       //final String PROCESS_NAME='Subentro';

   public  HDT_UTL_ProcessTakeOver(){
       System.debug('HDT_UTL_ProcessTakeOver');

   }

    public override void checks(){
        
        mapFieldsObject();

       
        if (String.isNotBlank( currentProcess.currentRequestItem.Data__c)) {

            Integer count=0;
            for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
                if ('null'.equalsIgnoreCase(tempField)) {
                    tempField='';
                }
                //! Controllo campi required
                // if (mapRequiredByPosition.get(count)!=null && String.isBlank(tempField) ) {
                //     throw new HDT_WRP_ProcessEntitiesException( 'Missing required field',mapHeaderByPosition.get(count)+' can\'t be null');
                // }
              
                if (String.isBlank(tempField)) {
                    count++;
                    continue;
                }
                // Start AccountContactRelation
                if ( 'Ruolo'.equalsIgnoreCase(mapHeaderByPosition.get(count))) {
                    currentProcess.role=tempField;
                }
                // fine AccountContactRelation

                // Creazione Account
                if (mapAccountFields.get(mapHeaderByPosition.get(count))!=null) {
                   // System.debug('Acc column N° :'+count+' FieldapiName : '+mapAccountFields.get(mapHeaderByPosition.get(count))+'  HeaderName : '+mapHeaderByPosition.get(count) + ' FieldValue : '+tempField );

                    mapTypeField(currentProcess.currentAccount,mapAccountFields,count,tempField);
                    if('Tipo di Account'.equalsIgnoreCase(mapHeaderByPosition.get(count))){
                            // selezione recordtype Account 
                            if ('Business'.equalsIgnoreCase(tempField)) {
                                currentProcess.currentAccount.put('RecordTypeId',recordTypeBus);
                            }
                            else if ('Residenziale'.equalsIgnoreCase(tempField))  {
                                currentProcess.currentAccount.put('RecordTypeId',recordTypeRes);
                            }
                            else {
                                throw new HDT_WRP_ProcessEntitiesException( 'Missing required field',mapHeaderByPosition.get(count)+' not valid!');
                            }
                    }
                   
                }
                //Fine Creazione Account

                // Creazione Sales
                else if(mapSaleFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentSale,mapSaleFields,count,tempField);

                }
                // fine creazione sales

                // start Service Point 
                else if(mapServicePointFields.get(mapHeaderByPosition.get(count))!=null ){
                   mapTypeField(currentProcess.currentServicePoint,mapServicePointFields,count,tempField);
                }
                // Start Billing Profile

                else if(mapBillingProfileFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentBillingProfile,mapBillingProfileFields,count,tempField);
                }
                // End Billing Profile;

                // Start Order
                else if(mapOrderFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentChildOrder,mapOrderFields,count,tempField);
                    
                    if ('SelfCertificationConnection__c'.equalsIgnoreCase(mapOrderFields.get(mapHeaderByPosition.get(count)))) {
                        currentProcess.currentChildOrder.put(mapOrderFields.get(mapHeaderByPosition.get(count)),'Procura'.equalsIgnoreCase(tempField) ? '001':'Contratto firmato'.equalsIgnoreCase(tempField)?'002':null );
                    }
                    
                } // End Order
                // Start OrderItem
                else if(mapOrderItemFields.get(mapHeaderByPosition.get(count))!=null ){
                    mapTypeField(currentProcess.currentOrderItem,mapOrderItemFields,count,tempField);                 
                } // End OrderItem
                count++;
            }
        }

    }
    public override void getRecords(){
        /* Controllo se l'account esiste già se esiste recuperare anche il Contact 
        */
        makeContact();
        List<Account> lAccount=new List<Account>();
        List<ServicePoint__c> listServicePoint=new List<ServicePoint__c>();
        if (currentProcess.currentAccount!=null && 
        String.isNotBlank(currentProcess.currentAccount.CompanyOwner__c)
        &&
        String.isNotBlank(currentProcess.currentAccount.CustomerMarking__c)
        &&
        String.isNotBlank(currentProcess.currentAccount.Category__c)
        &&
        ( String.isNotBlank(currentProcess.currentAccount.FiscalCode__c) 
        || String.isNotBlank(currentProcess.currentAccount.VATNumber__c))
         ) {
            String filter='CompanyOwner__c=\''+currentProcess.currentAccount.CompanyOwner__c+'\' AND CustomerMarking__c = \''+currentProcess.currentAccount.CustomerMarking__c+'\' AND Category__c=\''+currentProcess.currentAccount.Category__c+'\' AND (FiscalCode__c=\''+currentProcess.currentAccount.FiscalCode__c+'\' OR VATNumber__c=\''+currentProcess.currentAccount.VATNumber__c+'\')';
            System.debug('filter: '+filter);
            lAccount= qrAcc.getAccountList(filter) ;
            
        }
        if (lAccount!=null && lAccount.size()>0) {
            System.debug('Update Account esistente');
            currentProcess.currentAccount.Id=lAccount.get(0).Id;  
            System.debug('currentProcess.currentAccount: '+currentProcess.currentAccount); 
            String filterContact='FiscalCode__c=\''+currentProcess.currentAccount.FiscalCode__c+ '\' AND AccountId=\''+ currentProcess.currentAccount.Id+'\' LIMIT 10';
            List<Contact> listContact = qrCont.getContactList(filterContact);
            if (listContact!=null && listContact.size()>0) {
                currentProcess.currentPrimaryContact.Id=listContact.get(0).Id;
            }
        }
        // Start Controllo Service Point
        if (String.isNotBlank(currentProcess.currentServicePoint.Name)) {
            currentProcess.currentServicePoint.ServicePointCode__c=currentProcess.currentServicePoint.Name;
            listServicePoint=qrSerPoint.getServicePointsByCodeWithFilter(currentProcess.currentServicePoint.ServicePointCode__c,'id','');
            if (listServicePoint!=null &&listServicePoint.size()>0 ) {
                // se esiste il Service Point
                currentProcess.currentServicePoint.Id=listServicePoint.get(0).Id;
            }
        }
        // Fine controllo Service Point
        System.debug('*******currentProcess.currentServicePoint '+currentProcess.currentServicePoint);
        arricchimentoDati();
    }

    public override void registryCreation(){
        listUpdateGeneric = new List<SObject>();
        verifyAccountAddress();
     
        HDT_UTL_Account.massiveRequest(currentProcess.currentAccount,currentProcess.currentPrimaryContact); 
        if (currentProcess.currentAccount!=null &&currentProcess.currentAccount.Id==null ) {
            // solo se non esiste
            System.debug('Creazione Account');
            String expectedNewName = String.isBlank( currentProcess.currentAccount.FirstName__c) ?  currentProcess.currentAccount.LastName__c :  currentProcess.currentAccount.FirstName__c + ' ' +  currentProcess.currentAccount.LastName__c;
            currentProcess.currentAccount.Name=expectedNewName;
            //  currentProcess.currentAccount.BillingIsAddressVerified__c=true; 
            insert currentProcess.currentAccount;
            currentProcess.currentPrimaryContact.AccountId=currentProcess.currentAccount.id;
            insert currentProcess.currentPrimaryContact;   
        }
        else {
           

            listUpdateGeneric.add(currentProcess.currentAccount);
            listUpdateGeneric.add(currentProcess.currentPrimaryContact);

        }
        
        if(currentProcess.role!=null){
            System.debug('currentProcess.currentAccount.id '+currentProcess.currentAccount.id);
            System.debug('currentProcess.currentPrimaryContact.Id '+currentProcess.currentPrimaryContact.Id);
            List<AccountContactRelation> listAccCon= accoContRelQr.getAccountContactRelation(currentProcess.currentAccount.id,currentProcess.currentPrimaryContact.Id, 'Id');
            if(listAccCon != null && listAccCon.size() > 0){
                currentProcess.currentAccountContactRelation = new AccountContactRelation(Id= listAccCon[0].Id,Roles=currentProcess.role );
                System.debug('listAccCon '+ currentProcess.currentAccountContactRelation);     
                listUpdateGeneric.add(currentProcess.currentAccountContactRelation);
               
            }
        }

        currentProcess.currentSale.Account__c                       = currentProcess.currentAccount.Id;
        currentProcess.currentServicePoint.Account__c               = currentProcess.currentAccount.Id;
        currentProcess.currentBillingProfile.Account__c             = currentProcess.currentAccount.Id;
        currentProcess.currentChildOrder.AccountId                  = currentProcess.currentAccount.Id;
        currentProcess.currentRequestItem.Account__c                = currentProcess.currentAccount.Id;
        currentProcess.currentOrderItem.SBQQ__ShippingAccount__c    = currentProcess.currentAccount.Id;

        currentProcess.currentChildOrder.RecordTypeId               = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();

        if(currentProcess.currentServicePoint.CommoditySector__c.equalsIgnoreCase('Energia Elettrica')){
            currentProcess.currentChildOrder.ProcessType__c = 'Subentro Ele';
        }else if(currentProcess.currentServicePoint.CommoditySector__c.equalsIgnoreCase('Gas')){
            currentProcess.currentChildOrder.ProcessType__c = 'Subentro Gas';
        }else{
            throw new HDT_WRP_ProcessEntitiesException( 'Missing required field','Servizio not valid!');
        }
        
        makeFatherOrder();

        listUpdateGeneric.add(0, currentProcess.currentSale)           ;
        listUpdateGeneric.add(1, currentProcess.currentServicePoint)   ;
        listUpdateGeneric.add(2, currentProcess.currentBillingProfile) ;
       // listUpdateGeneric.add(currentProcess.currentOrder)          ;


       

    }

    public override void finalUpdate(){
        String compatibilityMessage = '';
        System.debug('finalUpdate');
        if (listUpdateGeneric.size()>0) {
           // Savepoint sp = Database.setSavePoint();
                upsert listUpdateGeneric;
                
                currentProcess.currentFatherOrder.Sale__c                    = ((Sale__c)listUpdateGeneric.get(0)).Id           ;
                currentProcess.currentFatherOrder.ServicePoint__c            = ((ServicePoint__c)listUpdateGeneric.get(1)).Id   ;
                currentProcess.currentFatherOrder.BillingProfile__c          = ((BillingProfile__c)listUpdateGeneric.get(2)).Id ;
                insert currentProcess.currentFatherOrder                                                                        ;

                currentProcess.currentChildOrder.ParentOrder__c              = currentProcess.currentFatherOrder.Id             ;
                currentProcess.currentChildOrder.Sale__c                    = ((Sale__c)listUpdateGeneric.get(0)).Id            ;
                currentProcess.currentChildOrder.ServicePoint__c            = ((ServicePoint__c)listUpdateGeneric.get(1)).Id    ;
                currentProcess.currentChildOrder.BillingProfile__c          = ((BillingProfile__c)listUpdateGeneric.get(2)).Id  ;
                insert currentProcess.currentChildOrder                                                                         ;

                System.debug('OrderId:'+currentProcess.currentChildOrder.Id)                                                    ;

                makeServiceRequest();
                insert currentProcess.currentServiceRequest;
                
                wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = HDT_UTL_MatrixCompatibility.checkCompatibility(currentProcess.currentServiceRequest)   ;
                if(!result.incompatibilities.isEmpty()){
                    compatibilityMessage = HDT_UTL_MatrixCompatibility.getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                    delete currentProcess.currentServiceRequest;
                }
                currentProcess.currentOrderItem.OrderId             = currentProcess.currentChildOrder.Id       ;
                currentProcess.currentOrderItem.BillingProfile__c   = currentProcess.currentBillingProfile.id   ;
                currentProcess.currentOrderItem.ServicePoint__c     = currentProcess.currentServicePoint.id     ;
                // insert currentProcess.currentOrderItem;
        }
        currentProcess.currentRequestItem.Status__c=constant.MASSIVLOADER_STATUS_CHIUSO;
        if(String.isNotBlank(compatibilityMessage)){
            currentProcess.currentRequestItem.StatusDescription__c = 'Compatibility Alert - '+compatibilityMessage;
        }  
        update currentProcess.currentRequestItem; 
    }
   
   private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listAccountFields = getMapFieldsObject('Account', this.processName);
        
        mapAccountFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt accountFields : listAccountFields){
            mapAccountFields.put(accountFields.labelField__c, accountFields.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listSaleFields = getMapFieldsObject('Sale', this.processName);

        mapSaleFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt saleFields : listSaleFields){
            mapSaleFields.put(saleFields.labelField__c, saleFields.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listServicePointFields = getMapFieldsObject('ServicePoint', this.processName);

        mapServicePointFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt servicePointFields : listServicePointFields){
            mapServicePointFields.put(servicePointFields.labelField__c, servicePointFields.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listBillingProfileFields = getMapFieldsObject('BillingProfile', this.processName);

        mapBillingProfileFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt billingProfileFields : listBillingProfileFields){
            mapBillingProfileFields.put(billingProfileFields.labelField__c, billingProfileFields.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listOrderFields = getMapFieldsObject('Order', this.processName);

        mapOrderFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt orderFields : listOrderFields){
            mapOrderFields.put(orderFields.labelField__c, orderFields.nameField__c);
        }

        List<HDT_MassiveFieldsObjectMap__mdt> listOrderItemFields = getMapFieldsObject('OrderItem', this.processName);

        mapOrderItemFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt orderItemFields : listOrderItemFields){
            mapOrderItemFields.put(orderItemFields.labelField__c, orderItemFields.nameField__c);
        }
    } 
}
