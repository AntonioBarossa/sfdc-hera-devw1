public without sharing virtual class HDT_UTL_ProcessExecution {
    public static HDT_QR_StaticResource         staticResourceQr        = new HDT_QR_StaticResource()           ;
    public HDT_QR_Account                       qrAcc                   = new HDT_QR_Account()                  ;
    public HDT_QR_ServicePoint                  qrSerPoint              = new HDT_QR_ServicePoint()             ;
    public static HDT_QR_AccountContactRelation accoContRelQr           = new HDT_QR_AccountContactRelation()   ;
    public static HDT_QR_Contact                qrCont                  = new HDT_QR_Contact()                  ;
    public static HDT_QR_Order                  qrOrder                 = new HDT_QR_Order()                    ;
    public static HDT_QR_Case                   qrCase                  = new HDT_QR_Case()                     ;
    public HDT_UTL_Constants                    constant                = new HDT_UTL_Constants()               ;
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr   = new HDT_QR_MassiveLoaderProcess()     ;
    public HDT_WRP_ProcessEntities              currentProcess                                                  ;


    public String splitCharacter = '\\|';
    //public  MassiveLoaderRequestItem__c varRequestItem;
    public  String processName;
    public  Map<Integer, String> mapHeaderByPosition    = new  Map<Integer, String>();
    public  Map<String, Integer> mapHeaderForWrapper    = new  Map<String, Integer>(); 
    public  Map<Integer, String> mapRequiredByPosition  = new  Map<Integer, String>(); 
    public  Id recordTypeBus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
    public  Id recordTypeRes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();

    //public List<Id> accountIdList = new List<Id>();

    // --------- montors fix for bulk develop  ---------
    public void setMassiveLoaderRequestItemList(list<MassiveLoaderRequestItem__c> requestItemList){

        currentProcess = new HDT_WRP_ProcessEntities();
        this.currentProcess.currentRequestItemList = requestItemList;   
       
        for(MassiveLoaderRequestItem__c item : this.currentProcess.currentRequestItemList){
            if ( String.isBlank(item.MassiveLoaderRequest__r.ProcessType__c)) {
                throw new HDT_WRP_ProcessEntitiesException( 'NullPointerExceptions','ProcessType can\'t be null');
            }
        }
    
        this.processName = this.currentProcess.currentRequestItemList[0].MassiveLoaderRequest__r.ProcessType__c;
        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(processName);
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcess.DeveloperName);
 

        mapHeaderByPosition = new Map<Integer, String>();
        Integer count=0;
        for (String temp : staticResources.get(0).Body.toString().remove('\r').remove('\n').split(',')) {
           if (temp.containsIgnoreCase('*')) {
                temp=temp.remove('*');
                mapRequiredByPosition.put(count,temp);
            }
            mapHeaderByPosition.put(count,temp);
            mapHeaderForWrapper.put(temp, count);
            count++;
        }
    }
    // --------- montors fix for bulk develop  ---------

    //public void setMassiveLoaderRequestItem(MassiveLoaderRequestItem__c requestItem){
    //
    //    currentProcess=new HDT_WRP_ProcessEntities();
    //    this.currentProcess.currentRequestItem=requestItem;   
    //   
    //
    //    if ( String.isBlank( this.currentProcess.currentRequestItem.MassiveLoaderRequest__r.ProcessType__c)) {
    //        throw new HDT_WRP_ProcessEntitiesException( 'NullPointerExceptions','ProcessType can\'t be null');
    //    }
    //
    //    this.processName= this.currentProcess.currentRequestItem.MassiveLoaderRequest__r.ProcessType__c;
    //    HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(processName);
    //    List<StaticResource> staticResources = staticResourceQr.getRecordByName(selectedProcess.DeveloperName);
    //
    //
    //    mapHeaderByPosition = new Map<Integer, String>();
    //    Integer count=0;
    //    for (String temp : staticResources.get(0).Body.toString().remove('\r').remove('\n').split(',')) {
    //       if (temp.containsIgnoreCase('*')) {
    //            temp=temp.remove('*');
    //            mapRequiredByPosition.put(count,temp);
    //        }
    //        mapHeaderByPosition.put(count,temp);
    //        count++;
    //    }
    //}

    public virtual void checks(){
        System.debug('checks');
    }
    public virtual void getRecords(){
        System.debug('getRecords');
    }
    public virtual void registryCreation(){
        System.debug('registryCreation');
    }
    public virtual void makeProcess(){ // creazione processo
        System.debug('makeProcess');
    }
    public virtual void finalUpdate(){
        System.debug('finalUpdate');
    }
    public virtual void execute(){
        System.debug('execute');
        checks();
        getRecords();
        registryCreation();
        makeProcess();
        finalUpdate();

    }
   
    // --------- montors fix for bulk develop  ---------
    public virtual void manageCatchException(Integer batchSize, List<MassiveLoaderRequestItem__c> itemList, String message){
        System.debug('manageCatchException');
    }
    // --------- montors fix for bulk develop  ---------

    /**
    * @description :
    * @param objName 
    * @param fieldApiName 
    * @return String 
    **/
    public String getTypeField(String objName,String fieldApiName){

        String fieldTypeName = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType().name().toupperCase(); 
        return fieldTypeName;
    }

    public String mapTypeField(SObject sObj, Map<String, String> mapSobjField, Integer position, String value){

        try {
            String typeField=getTypeField(String.valueOf(sObj.getSObjectType()),mapSobjField.get(mapHeaderByPosition.get(position)));
            switch on typeField.toUpperCase() {
                when 'BOOLEAN'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Boolean.valueOf(value));
                }
                when 'DOUBLE'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Decimal.valueOf(value));
                }
                when 'INTEGER'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Integer.valueOf(value));
                }
                when 'DATETIME'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Datetime.valueOf(value));
                }
                when 'DATE'  {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),Date.valueOf(value));
                }
                when else {
                    sObj.put(mapSobjField.get(mapHeaderByPosition.get(position)),value);
                }
            }
            return null;
        } catch (Exception e){
            return e.getMessage() + ' - on filed [' + mapSobjField.get(mapHeaderByPosition.get(position)) + ']';
        }
    }

    public List<HDT_MassiveFieldsObjectMap__mdt> getMapFieldsObject(String objectType, String processType){
        return [SELECT objectType__c, labelField__c, nameField__c 
                FROM HDT_MassiveFieldsObjectMap__mdt 
                WHERE objectType__c=:objectType AND processType__c=:processType
                WITH SECURITY_ENFORCED
                ];
    }

    /**
   * @description mapping Contact by Account
   **/
   public void makeContact(){
        currentProcess.currentPrimaryContact.DegreeOfStudies__c                 = currentProcess.currentAccount.DegreeOfStudies__c                   ;
        currentProcess.currentPrimaryContact.CompanyOwner__c                    = currentProcess.currentAccount.CompanyOwner__c                      ;
        currentProcess.currentPrimaryContact.LastName                           = currentProcess.currentAccount.LastName__c                          ;
        currentProcess.currentPrimaryContact.Gender__c                          = currentProcess.currentAccount.Gender__c                            ;
        currentProcess.currentPrimaryContact.FirstName                          = currentProcess.currentAccount.FirstName__c                         ;
        currentProcess.currentPrimaryContact.Birthdate                          = currentProcess.currentAccount.BirthDate__c                         ;
        currentProcess.currentPrimaryContact.FiscalCode__c                      = currentProcess.currentAccount.FiscalCode__c                        ;
        currentProcess.currentPrimaryContact.Birthcity__c                       = currentProcess.currentAccount.BirthProvince__c                     ;
        currentProcess.currentPrimaryContact.MobilePhonePrefix__c               = currentProcess.currentAccount.MobilePhonePrefix__c                 ;
        currentProcess.currentPrimaryContact.Phone                              = currentProcess.currentAccount.Phone                                ;
        currentProcess.currentPrimaryContact.MobilePhone                        = currentProcess.currentAccount.MobilePhone__c                       ;
        currentProcess.currentPrimaryContact.Email                              = currentProcess.currentAccount.PrimaryEmail__c                      ;
        currentProcess.currentPrimaryContact.PhonePrefix__c                     = currentProcess.currentAccount.PhonePrefix__c                       ;
        currentProcess.currentPrimaryContact.Fax                                = currentProcess.currentAccount.FAX__c                               ;                       
        currentProcess.currentPrimaryContact.Profession__c                      = currentProcess.currentAccount.Profession__c                        ;             
        currentProcess.currentPrimaryContact.MailingCity                        = currentProcess.currentAccount.BillingCity                          ;           
        currentProcess.currentPrimaryContact.MailingCityCode__c                 = currentProcess.currentAccount.BillingCityCode__c                   ;                  
        currentProcess.currentPrimaryContact.MailingCountry                     = currentProcess.currentAccount.BillingCountry                       ;              
        currentProcess.currentPrimaryContact.MailingPostalCode                  = currentProcess.currentAccount.BillingPostalCode                    ;                 
        currentProcess.currentPrimaryContact.MailingState                       = currentProcess.currentAccount.BillingState                         ;            
        currentProcess.currentPrimaryContact.MailingStreet                      = currentProcess.currentAccount.BillingStreet                        ;             
        currentProcess.currentPrimaryContact.MailingStreetName__c               = currentProcess.currentAccount.BillingStreetName__c                 ;                    
        currentProcess.currentPrimaryContact.MailingStreetCode__c               = currentProcess.currentAccount.BillingStreetCode__c                 ;                    
        currentProcess.currentPrimaryContact.MailingStreetNumber__c             = currentProcess.currentAccount.BillingStreetNumber__c               ;                      
        currentProcess.currentPrimaryContact.MailingStreetNumberExtension__c    = currentProcess.currentAccount.BillingStreetNumberExtension__c      ;                               
        currentProcess.currentPrimaryContact.MailingStreetToponym__c            = currentProcess.currentAccount.BillingStreetToponym__c              ;                       
        currentProcess.currentPrimaryContact.MailingRegion__c                   = currentProcess.currentAccount.BillingRegion__c                     ;                
        currentProcess.currentPrimaryContact.MailingPlace__c                    = currentProcess.currentAccount.BillingPlace__c                      ;                
        currentProcess.currentPrimaryContact.MailingPlaceCode__c                = currentProcess.currentAccount.BillingPlaceCode__c                  ;                    
        currentProcess.currentPrimaryContact.MailingIsAddressVerified__c        = currentProcess.currentAccount.BillingIsAddressVerified__c          ;                           
    }

    public void makeFatherOrder(){

        currentProcess.currentFatherOrder.AccountId             = currentProcess.currentChildOrder.AccountId                                                               ;
        currentProcess.currentFatherOrder.Sale__c               = currentProcess.currentChildOrder.Sale__c                                                                 ;
        currentProcess.currentFatherOrder.ServicePoint__c       = currentProcess.currentChildOrder.ServicePoint__c                                                         ;
        currentProcess.currentFatherOrder.RecordTypeId          = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_OrderDossier').getRecordTypeId();

        currentProcess.currentFatherOrder.ContractSigned__c     = currentProcess.currentChildOrder.ContractSigned__c                                                       ;
        currentProcess.currentFatherOrder.SignatureMethod__c    = currentProcess.currentChildOrder.SignatureMethod__c                                                      ;
        currentProcess.currentFatherOrder.DocSendingMethod__c   = currentProcess.currentChildOrder.DocSendingMethod__c                                                     ;
        currentProcess.currentFatherOrder.Status                = currentProcess.currentChildOrder.Status                                                                  ;
        currentProcess.currentFatherOrder.EffectiveDate         = currentProcess.currentChildOrder.EffectiveDate                                                           ;
    }

    public void makeServiceRequest(){

        currentProcess.currentServiceRequest.ServicePointCode__c = currentProcess.currentServicePoint.Name; 
        currentProcess.currentServiceRequest.Status__c = 'Bozza';
        currentProcess.currentServiceRequest.Order__c = currentProcess.currentChildOrder.Id;
        currentProcess.currentServiceRequest.CommoditySector__c = currentProcess.currentServicePoint.CommoditySector__c;
        currentProcess.currentServiceRequest.Type__c = 'Order'; 
        if(currentProcess.currentServicePoint.Id != null){
            currentProcess.currentServiceRequest.ServicePoint__c = currentProcess.currentServicePoint.Id;
        }else{
            currentProcess.currentServiceRequest.Account__c = currentProcess.currentChildOrder.AccountId;
            currentProcess.currentServiceRequest.BillingProfile__c = currentProcess.currentChildOrder.BillingProfile__c;
        }
        currentProcess.currentServiceRequest.ProcessType__c= HDT_UTL_MatrixCompatibility.getProcessType(currentProcess.currentChildOrder.ProcessType__c, 'Order', String.valueOf(currentProcess.currentServicePoint.CommoditySector__c));
    }

    public  void verifyAccountAddress(){
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resp= HDT_WS_HerokuAddressSearch.callServiceMass(
            currentProcess.currentAccount.BillingCity,
            currentProcess.currentAccount.BillingStreetName__c,
            currentProcess.currentAccount.BillingStreetNumber__c
        );

        List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> listPrestazioni=resp.prestazione;
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj retObj=analizeRespVerifyAddress(listPrestazioni,currentProcess.currentAccount.BillingCity,currentProcess.currentAccount.BillingStreetName__c, currentProcess.currentAccount.BillingStreetNumber__c,currentProcess.currentAccount.BillingPostalCode);
        
        if (retObj!=null ) {
            currentProcess.currentAccount.BillingCity                   = retObj.city1;
            currentProcess.currentAccount.BillingCityCode__c            = retObj.cityCode;
            currentProcess.currentAccount.BillingStreetName__c          = retObj.street;
            currentProcess.currentAccount.BillingPlaceCode__c           = retObj.cityPCode;
            currentProcess.currentAccount.BillingPlace__c               = retObj.cityPName;
            currentProcess.currentAccount.BillingIsAddressVerified__c   = true;
        }
        else {
            currentProcess.currentAccount.BillingIsAddressVerified__c   = false;
        }  
    }

    public Account verifyAccountAddress(Account account){
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resp= HDT_WS_HerokuAddressSearch.callServiceMass(
            account.BillingCity,
            account.BillingStreetName__c,
            account.BillingStreetNumber__c
        );

        List<HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> listPrestazioni = resp.prestazione;
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj retObj = analizeRespVerifyAddress(listPrestazioni, account.BillingCity, account.BillingStreetName__c, account.BillingStreetNumber__c, account.BillingPostalCode);
        
        if(retObj != null) {
            account.BillingCity = retObj.city1;
            account.BillingCityCode__c = retObj.cityCode;
            account.BillingStreetName__c = retObj.street;
            account.BillingPlaceCode__c = retObj.cityPCode;
            account.BillingPlace__c = retObj.cityPName;
            account.BillingIsAddressVerified__c = true;
        } else {
            account.BillingIsAddressVerified__c = false;
        }
        return account;
    }

    /** 
    * @description confronta gli indirizzi che restituisce il servizio con l'indirizzo in input  
    * restituisce l'indirizzo che ha il numero matching points maggiore 
    * @param rs  lista di indirizzi HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj
    * @param city 
    * @param street 
    * @param myNumber 
    * @param postalCode 
    **/
    public  HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj analizeRespVerifyAddress(List <HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj> rs,String city,String street,String myNumber,String postalCode){
        HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj addressWinner=rs.get(0);
        Integer matchingPoints = 0;
        for (HDT_WS_HerokuAddressSearch.HDT_WS_PrestazioneObj tempRes : rs) {
           Integer tempMatchingPoints=0;
           
           if(tempRes.city1.equalsIgnoreCase(city)){
                tempMatchingPoints=tempMatchingPoints+1;
            }
            if(tempRes.street.equalsIgnoreCase(street)){
                tempMatchingPoints=tempMatchingPoints+1;
            }
            if(tempRes.houseNum1.equalsIgnoreCase(myNumber)){
                tempMatchingPoints=tempMatchingPoints+1;
            }
            if(tempRes.postCode1.equalsIgnoreCase(postalCode)){
                tempMatchingPoints=tempMatchingPoints+1;
            }
            if(tempMatchingPoints>matchingPoints){
                matchingPoints=tempMatchingPoints;
                addressWinner=tempRes;
            }

          
        }
        return addressWinner;
    }
    public void arricchimentoDati(){
        if (String.isBlank( currentProcess.currentServicePoint.ServicePointCode__c)   ) {
            throw new HDT_WRP_ProcessEntitiesException( 'NullPointerExceptions','ServicePointCode can\'t be null');

        }
        HDT_WS_ArrichmentDataEntityResponse serResp=HDT_WS_ArrichmentDataEntityInvoker.callService('',currentProcess.currentServicePoint.ServicePointCode__c);
        HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(currentProcess.currentServicePoint, serResp);
       
    }

   public class HDT_WRP_ProcessEntities{
      public Account                      currentAccount                ;
      public Lead                         currentLead                   ;
      public Individual                   currentIndividual             ;
      public Contact                      currentPrimaryContact         ;
      public Order                        currentFatherOrder            ;
      public Order                        currentChildOrder             ;
      public ServiceRequest__c            currentServiceRequest         ;//AA 21/09/2021 ad ogni order Figlio è associato un oggetto tecnico ServiceRequest__c
      public Contract                     currentContract               ;
      public Quote                        currentQuote                  ;
      public Case                         currentCase                   ;
      public ServicePoint__c              currentServicePoint           ;
      public BillingProfile__c            currentBillingProfile         ;
      public MassiveLoaderRequestItem__c  currentRequestItem            ;
      public List<MassiveLoaderRequestItem__c>  currentRequestItemList  ;
      public AccountContactRelation       currentAccountContactRelation ;
      public Sale__c                      currentSale                   ;
      public OrderItem                    currentOrderItem              ;
      public String                       role ;


        public  HDT_WRP_ProcessEntities(){          
            currentAccount                  =   new  Account                     ();
            currentLead                     =   new  Lead                        ();
            currentIndividual               =   new  Individual                  ();
            currentPrimaryContact           =   new  Contact                     ();
            currentFatherOrder              =   new  Order                       ();
            currentChildOrder               =   new  Order                       ();  
            currentServiceRequest           =   new  ServiceRequest__c           ();
            currentOrderItem                =   new  OrderItem                   ();
            currentContract                 =   new  Contract                    ();
            currentQuote                    =   new  Quote                       ();
            currentCase                     =   new  Case                        ();
            currentServicePoint             =   new  ServicePoint__c             ();
            currentBillingProfile           =   new  BillingProfile__c           ();
            currentRequestItem              =   new  MassiveLoaderRequestItem__c ();
            currentAccountContactRelation   =   new  AccountContactRelation      ();
            currentSale                     =   new  Sale__c                     ();
        }
   }
   //---------- Gestione Errore -------------
   public class HDT_WRP_ProcessEntitiesException extends Exception{
        public String Type;
        public String Message;

        public HDT_WRP_ProcessEntitiesException(String varType,String varMessage){
            this.Type      = varType;
            this.message   = varMessage;
        }
    }

    public MassiveLoaderRequestItem__c setErrorItem(String itemId, String message){
        MassiveLoaderRequestItem__c itemError = new MassiveLoaderRequestItem__c();
        itemError.Id = itemId;
        itemError.Status__c = 'Errore';
        itemError.StatusDescription__c = message;
        return itemError;
    }

}