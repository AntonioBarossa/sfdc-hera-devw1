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
        Account               currentAccount         ;
        Contact               currentPrimaryContact  ;
        Order                 currentOrder           ;
        Contract              currentContract        ;
        Quote                 currentQuote           ;
        Case                  currentCase            ;
        ServicePoint__c       currentServicePoint    ;
        BillingProfile__c     currentBillingProfile  ;

        // public void HDT_WRP_ProcessEntities(){
        //     currentAccount         =   new  Account            ();
        //     currentPrimaryContact  =   new  Contact            ();
        //     currentOrder           =   new  Order              ();
        //     currentContract        =   new  Contract           ();
        //     currentQuote           =   new  Quote              ();
        //     currentCase            =   new  Case               ();
        //     currentServicePoint    =   new  ServicePoint__c    ();
        //     currentBillingProfile  =   new  BillingProfile__c  ();
        // }
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