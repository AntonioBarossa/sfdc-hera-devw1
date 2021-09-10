public without sharing virtual class HDT_UTL_ProcessExecution {
    private static HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();

    public virtual void checks(){}
    public virtual void getRecords(){}
    public virtual void registryCreation(){}
    public virtual void postSalesCreation(){}
    public virtual void finalUpdate(){}


    public Map<Integer,String> getTemplateHeader(String process){
        System.debug('HDT_UTL_ProcessExecution.getTemplateHeader: '+process);
        List<StaticResource> staticResources = staticResourceQr.getRecordByName(process);
        Map<Integer, String> mapHeaderByPosition = new Map<Integer, String>();
        Integer count=0;
        for (String temp : staticResources.get(0).Body.toString().split(',')) {
            mapHeaderByPosition.put(count,temp);
            count++;
        }
        return mapHeaderByPosition ;
    }

   public class HDT_WRP_ProcessEntities{
      public Account               currentAccount         ;
      public Contact               currentPrimaryContact  ;
      public Order                 currentOrder           ;
      public Contract              currentContract        ;
      public Quote                 currentQuote           ;
      public Case                  currentCase            ;
      public ServicePoint__c       currentServicePoint    ;
      public BillingProfile__c     currentBillingProfile  ;

        public  HDT_WRP_ProcessEntities(){
            currentAccount         =   new  Account            ();
            currentPrimaryContact  =   new  Contact            ();
            currentOrder           =   new  Order              ();
            currentContract        =   new  Contract           ();
            currentQuote           =   new  Quote              ();
            currentCase            =   new  Case               ();
            currentServicePoint    =   new  ServicePoint__c    ();
            currentBillingProfile  =   new  BillingProfile__c  ();
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