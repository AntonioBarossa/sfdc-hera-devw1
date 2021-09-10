public without sharing virtual class HDT_UTL_ProcessExecution {
    public void checks(){}
    public void getRecords(){}
    public void registryCreation(){}
    public void postSalesCreation(){}
    public void finalUpdate(){}

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