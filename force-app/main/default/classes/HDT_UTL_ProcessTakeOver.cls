public without sharing class HDT_UTL_ProcessTakeOver extends  HDT_UTL_ProcessExecution {
   private HDT_WRP_ProcessEntities currentProcess;
   private MassiveLoaderRequestRequestItem__c myRequestItem;
   private Map<Integer,String> mapHeaderByPosition;

   public  HDT_UTL_ProcessTakeOver(MassiveLoaderRequestRequestItem__c varRequestItem){
        System.debug('HDT_UTL_ProcessTakeOver : '+varRequestItem);
        if (varRequestItem==null) {
            throw new HDT_WRP_ProcessEntitiesException('Null Pointer Exceptions','varRequestItem can\'t be null');
        } 
        this.myRequestItem=varRequestItem;   
        currentProcess=new HDT_WRP_ProcessEntities();
   }

    public override void registryCreation(){

        Map<String, String> mapAccountFields = new Map<String, String>{
         
            'Nome'=>'FirstName__c',
            'Cognome/Ragione Sociale'=>'LastName__c',
            'Codice Fiscale'=>'FiscalCode__c',
            'P.IVA'=>'VATNumber__c',
            'BP'=>'BPSAPModel__c',
            'Marcatura'=>'CustomerMarking__c',
            'Categoria'=>'Category__c',
            'Ruolo'=>'role',
            'Silos'=>'CompanyOwner__c',
            'Comune'=>'BillingCity',
            'Via'=>'BillingStreet',
            'Civico'=>'BillingStreetCode__c',
            'Barrato'=>'',
            'Indirizzo Estero'=>'ShippingAddressIsForeign__c',
            'Prefisso Cellulare'=>'MobilePhonePrefix__c',
            'Cellulare'=>'MobilePhone__c',
            'Prefisso telefono fisso'=>'PhonePrefix__c',
            'Telefono fisso'=>'Phone',
            'Email'=>'PrimaryEmail__c',
            'FAX'=>'FAX__c'
        };
        if ( String.isNotBlank( myRequestItem.Data__c)) {
            mapHeaderByPosition=getTemplateHeader('Subentro');
            Integer count=0;
           
            for (String tempField : myRequestItem.Data__c.split(',')) {
              
                if (mapAccountFields.get(mapHeaderByPosition.get(count))!=null) {
                    // Account
                    System.debug('column N° :'+count+' FieldapiName : '+mapAccountFields.get(mapHeaderByPosition.get(count))+'  HeaderName : '+mapHeaderByPosition.get(count) + ' FieldValue : '+tempField );
                    currentProcess.currentAccount.put(mapAccountFields.get(mapHeaderByPosition.get(count)),tempField);
                }
              
               
                count++;
            }
        }

    }
    //public void postSalesCreation(){}
   // public void finalUpdate(){}
   
   
}
