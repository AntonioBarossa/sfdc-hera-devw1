public without sharing virtual class HDT_UTL_ProcessExecution {
    public static HDT_QR_StaticResource staticResourceQr       = new HDT_QR_StaticResource();
    public HDT_QR_Account qrAcc                                = new HDT_QR_Account();
    public static HDT_QR_AccountContactRelation accoContRelQr  = new HDT_QR_AccountContactRelation();
    public static HDT_QR_Contact qrCont                        = new HDT_QR_Contact();
    public String processName;
    public  Map<Integer, String> mapHeaderByPosition; 
    public  Map<Integer, String> mapRequiredByPosition; 
    public  Id recordTypeBus;
    public  Id recordTypeRes;

    public virtual void checks(){
        System.debug('checks');
    }
    public virtual void getRecords(){
        System.debug('getRecords');
    }
    public virtual void registryCreation(){
        System.debug('registryCreation');
    }
    public virtual void postSalesCreation(){
        System.debug('postSalesCreation');
    }
    public virtual void finalUpdate(){
        System.debug('finalUpdate');
    }
    public virtual void execute(){
        System.debug('execute');
        checks();
        getRecords();
        registryCreation();
        postSalesCreation();
        finalUpdate();

    }
    public void setProcessName(String prName){
        if ( String.isBlank(prName)) {
            throw new HDT_WRP_ProcessEntitiesException( 'NullPointerExceptions','ProcessName can\'t be null');
        }
        this.processName=prName;
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(prName);
        mapHeaderByPosition = new Map<Integer, String>();
        Integer count=0;
        for (String temp : staticResources.get(0).Body.toString().split(',')) {
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



   public class HDT_WRP_ProcessEntities{
      public Account                      currentAccount                ;
      public Contact                      currentPrimaryContact         ;
      public Order                        currentOrder                  ;
      public Contract                     currentContract               ;
      public Quote                        currentQuote                  ;
      public Case                         currentCase                   ;
      public ServicePoint__c              currentServicePoint           ;
      public BillingProfile__c            currentBillingProfile         ;
      public MassiveLoaderRequestItem__c  currentRequestItem            ;
      public AccountContactRelation       currentAccountContactRelation ;
      public String                       role ;


        public  HDT_WRP_ProcessEntities(){          
            currentAccount                  =   new  Account                     ();
            currentPrimaryContact           =   new  Contact                     ();
            currentOrder                    =   new  Order                       ();
            currentContract                 =   new  Contract                    ();
            currentQuote                    =   new  Quote                       ();
            currentCase                     =   new  Case                        ();
            currentServicePoint             =   new  ServicePoint__c             ();
            currentBillingProfile           =   new  BillingProfile__c           ();
            currentRequestItem              =   new  MassiveLoaderRequestItem__c ();
            currentAccountContactRelation   =   new  AccountContactRelation      ();
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