public without sharing virtual class HDT_UTL_ProcessExecution {
    public static HDT_QR_StaticResource         staticResourceQr        = new HDT_QR_StaticResource()           ;
    public HDT_QR_Account                       qrAcc                   = new HDT_QR_Account()                  ;
    public HDT_QR_ServicePoint                  qrSerPoint              = new HDT_QR_ServicePoint()             ;
    public static HDT_QR_AccountContactRelation accoContRelQr           = new HDT_QR_AccountContactRelation()   ;
    public static HDT_QR_Contact                qrCont                  = new HDT_QR_Contact()                  ;
    public HDT_UTL_Constants                    constant                = new HDT_UTL_Constants()               ;
    public HDT_WRP_ProcessEntities              currentProcess                                                  ;
    
    //public  MassiveLoaderRequestItem__c varRequestItem;
    public  String processName;
    public  Map<Integer, String> mapHeaderByPosition; 
    public  Map<Integer, String> mapRequiredByPosition; 
    public  Id recordTypeBus;
    public  Id recordTypeRes;

    public void setMassiveLoaderRequestItem(MassiveLoaderRequestItem__c requestItem){

        currentProcess=new HDT_WRP_ProcessEntities();
        this.currentProcess.currentRequestItem=requestItem;   
       

        if ( String.isBlank( this.currentProcess.currentRequestItem.MassiveLoaderRequest__r.ProcessType__c)) {
            throw new HDT_WRP_ProcessEntitiesException( 'NullPointerExceptions','ProcessType can\'t be null');
        }
    
        this.processName= this.currentProcess.currentRequestItem.MassiveLoaderRequest__r.ProcessType__c;
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(processName);
       

        mapHeaderByPosition = new Map<Integer, String>();
        Integer count=0;
        for (String temp : staticResources.get(0).Body.toString().remove('\r').remove('\n').split(',')) {
            if (temp.containsIgnoreCase('*')) {
                temp=temp.remove('*'); 
                mapRequiredByPosition.put(count,temp);
            }
            mapHeaderByPosition.put(count,temp);
            count++;
        }
        recordTypeRes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        recordTypeBus = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Business').getRecordTypeId();
    }

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
   
    public String getTypeField(String objName,String fieldApiName){
        String fieldTypeName = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType().name().toupperCase(); 
        System.debug('fieldTypeName: ' + fieldTypeName);   
        return fieldTypeName;
    }

    public void mapTypeField(SObject sObj,Map<String, String> mapSobjField,Integer position,String value){

        String typeField=getTypeField(String.valueOf(sObj.getSObjectType()),mapSobjField.get(mapHeaderByPosition.get(position)));
        System.debug(String.valueOf(sObj.getSObjectType())+' column N° :'+position+' FieldapiName : '+mapSobjField.get(mapHeaderByPosition.get(position))+'  HeaderName : '+mapHeaderByPosition.get(position) + ' FieldValue : '+value );

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
    }
    public  HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse verifyAccountAddress(){
        HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse resp= HDT_WS_HerokuAddressSearch.callServiceMass(
            currentProcess.currentAccount.BillingCity,
            currentProcess.currentAccount.BillingStreetName__c,
            currentProcess.currentAccount.BillingStreetNumber__c
        );
        return resp;
       
    }
    // public HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse analizeRespVerifyAddress(List <HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse> rs,String city,String street,String number){
    //     Integer matchingPoints=0;
    //     Integer elementNumber=0;
    //     for (HDT_WS_HerokuAddressSearch.HDT_WS_HerokuAddressSearchResponse tempRes : rs) {
    //         tempRes.body
    //     }

    // }


   public class HDT_WRP_ProcessEntities{
      public Account                      currentAccount                ;
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
      public AccountContactRelation       currentAccountContactRelation ;
      public Sale__c                      currentSale                   ;
      public OrderItem                    currentOrderItem              ;
      public String                       role ;


        public  HDT_WRP_ProcessEntities(){          
            currentAccount                  =   new  Account                     ();
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
}