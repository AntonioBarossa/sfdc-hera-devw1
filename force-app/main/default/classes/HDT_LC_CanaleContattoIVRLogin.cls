public with sharing class HDT_LC_CanaleContattoIVRLogin {
    //public static HDT_QR_ConsumptionCode consumptionCodeQr = new HDT_QR_ConsumptionCode();
    public static HDT_QR_Order orderQr = new HDT_QR_Order();
    public static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    @AuraEnabled
    public static Order checkLogin(String username, String password){
        System.debug('It\'s inside the method checkLogin' );
        List<Order> listOrd = orderQr.getOrderByUsernamePassword(username, password);
            if(listOrd.size() > 0){
                return listOrd[0];
        }
        return null ;

    }
    
    @AuraEnabled
    public static String checkContractualEnvelope(String orderId,String username,String password ){
        Set<String> transitoryStopPhase = new Set<String>{
            'ESPORTAZIONE VS SIEBEL',
            'IN CORSO CARICAMENTO SIEBEL',
            'CARICAMENTO SIEBEL OK',
            'CARICAMENTO SIEBEL KO',
            'ANNULLATO',
            'COMPLETATA'

        };
        String result = '';
        List<Order> childOrderList = new List<Order>();
        List<HDT_PEV_VoltureChangeManagerUpdateSObj__e> platformEvents = new List<HDT_PEV_VoltureChangeManagerUpdateSObj__e>();
        Order parentOrder = new Order();
        HDT_WRP_ContractConfirmation checkConfirmation = checkContractConfirmation(username,password);
        if(checkConfirmation.checkContract)
        {
            result = 'Validato';
        }
        else
        {
            parentOrder.Id = orderId;
            parentOrder.MethodSignedAccepted__c = 'web assistito';
            parentOrder.SignedDate__c = System.today();
            platformEvents.add(new HDT_PEV_VoltureChangeManagerUpdateSObj__e(SerializedSobj__c=JSON.serialize(parentOrder)));
            childOrderList = checkConfirmation.childOrders;
            for(Order childOrder : childOrderList)
            {
                if (childOrder.isTransition__c && String.isNotBlank(childOrder.Phase__c) && transitoryStopPhase.contains(childOrder.Phase__c.toUpperCase())){
                    continue;
                }
                Order childOrd = new Order();
                childOrd.Id = childOrder.Id;
                String phase = childOrder.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_VAS') && (childOrder.VasSubtype__c == null || (childOrder.VasSubtype__c != null && !childOrder.VasSubtype__c.equalsIgnoreCase('Analisi Consumi')))
                    ? 'Comunicazione Motore VAS'
                    : 'Comunicazione verso Heroku';
                childOrd.Phase__c = phase;
                //childOrd.Phase__c = 'Comunicazione verso Heroku';
                childOrd.SignedDate__c = System.today();
                childOrd.ConfirmCustomerContract__c = 'Web';
                platformEvents.add(new HDT_PEV_VoltureChangeManagerUpdateSObj__e(SerializedSobj__c=JSON.serialize(childOrd)));
            }
            if(platformEvents.size() > 1){
                List<Database.SaveResult> srList = Eventbus.publish(platformEvents);   
                for(Database.SaveResult sr : srList)
                {
                    if(sr.isSuccess())
                    {
                        result = 'success';
                    }
                    else 
                    {
                        result = 'Errore';
                        break;
                    }
                }
            }else {
                result = 'success';
            }
        }
        return result;

        /*if(orderId == checkLogin(username,password).id){
            try {
                System.debug('It\'s inside the method checkContractualEnvelope');
                //  ConsumptionCode__c consumptionCode = consumptionCodeQr.getRecordById(consumptionCodeId);
               // Order order = orderQr.getRecordById(orderId);
                List<VocalOrderPublicConfirm__c> voList = HDT_QR_VocalOrderPublicConfirm.getVocalPublicConfirm(orderId);
                if(voList != null && voList.isEmpty()){
                    VocalOrderPublicConfirm__c vo = new VocalOrderPublicConfirm__c();
                    vo.order__c = orderId;
                    HDT_SRV_VocalOrderPublicConfirm.createRecord(vo);
                    return 'success';
                }
                System.debug('********');
                return 'Validato';//order;    
            } catch (Exception e) {
                System.debug(e.getMessage()); 
                throw new AuraHandledException(e.getMessage());
            }
        }
        else{
            return 'Errore';
        }*/
    }

    private static HDT_WRP_ContractConfirmation checkContractConfirmation(String username, String password)
    {
        Order checkOrder = orderQr.getOrderByUsernamePassword(username,password)[0];
        return new HDT_WRP_ContractConfirmation(checkOrder.MethodSignedAccepted__c != null && checkOrder.MethodSignedAccepted__c.equalsIgnoreCase('web assistito'),
            checkOrder.Orders__r);
    }
    private class HDT_WRP_ContractConfirmation
    {
        public Boolean checkContract;
        public List<Order> childOrders;

        public HDT_WRP_ContractConfirmation(Boolean checkContract, List<Order> childOrders)
        {
            this.checkContract = checkContract;
            this.childOrders = childOrders;
        }

    }
            
    @AuraEnabled
    public static map<String,String> checkListenVo(String orderId,String username,String password){
        map<String,String> mapReturn = new Map<String,String>();
        List<wrts_prcgvr__Activity__c> voActivity = new List<wrts_prcgvr__Activity__c>();
        try {
            voActivity = [SELECT Id, 
            RecordingLink__c 
            FROM wrts_prcgvr__Activity__c 
            WHERE Type__c = 'Validazione Vocal Order'
            AND Order__c = :orderId
            WITH SECURITY_ENFORCED];
            if(!voActivity.isEmpty()){
                mapReturn.put('res',voActivity[0].RecordingLink__c);
                return mapReturn;
            }
            else{
                mapReturn.put('res','NonPossibile');
                return mapReturn;
            }
        }
        catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
        }
  
    }
    @AuraEnabled
    public static Map<String, String> downloadDocument(String orderId,String username,String password){
        map<String,String> mapReturn = new Map<String,String>();
        try {
                String id = checkLogin(username,password).id;
                String documentRecordId;
                List<DocumentalActivity__c> dc = new List<DocumentalActivity__c>();
                List<DocumentSendTracking__c> dst = new List<DocumentSendTracking__c>();
                if(id == orderId){
                    HDT_LC_CanaleIVRNoShare qrsha = new HDT_LC_CanaleIVRNoShare();
                    dc.add(qrsha.getActivityByOrder(orderId));
                    //mapReturn.put('base64','UFJPVkFET1dOTE9BRFBST1ZB');
                    //String s = HDT_LC_DocumentSignatureManager.showOriginalDocument(dc.id);
                // System.debug('*********:'+ s);
                    if(dc != null)
                    {
                        dst.add(qrsha.getDocumentalSendTracking(orderId));
                        documentRecordId = !dst.isEmpty() ? dst[0].Id : '';
                    }
                    else
                    {
                        documentRecordId = dc[0].Id;
                    }
                    mapReturn = qrsha.getPlico(documentRecordId); 
                    System.debug('*********:'+ mapReturn);//(Map<String,String>)JSON.deserialize(s, Map<String,String>.class);
                /*  Order ord = orderQr.getRecordById(orderId);
                    String recordId = ord.DocumentalActivity__c;
                    mapReturn = HDT_LC_DocumentSignatureManager.showOriginalDocument(recordId);
                    return serializedOutput; */
                    return mapReturn;
                }
                else{
                    mapReturn.put('res','NonPossibile');
                    return mapReturn;
                }
            }
         catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Order checkFinalConfirmationOfTheContract(String orderId){
        System.debug('It\'s inside the method checkFinalConfirmationOfTheContract');
        //ConsumptionCode__c consumptionCode = consumptionCodeQr.getRecordById(consumptionCodeId);
        Order ord = orderQr.getRecordById(orderId);
        return ord;     
   }

   @AuraEnabled
   public static List<Order> getOrderSiblings(String parentId){
       try {
           System.debug(orderQr.getChildOrdersByParentId(parentId));
           return orderQr.getChildOrdersByParentId(parentId);
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
    
   @AuraEnabled(cacheable = true)
   public static List<Order> getOrderSiblingsDocumentalActivity (String parentId){
       System.debug('prova teknike');
    try {
       
        System.debug(orderQr.getChildOrdersDocumentalActivityByParentId(parentId));
        return orderQr.getChildOrdersDocumentalActivityByParentId(parentId);
        
    } catch (Exception e) {
        System.debug(e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
   }

   @AuraEnabled
   public static void generateUsernameAndPassword(String child){

    //Order parentOrd = orderQr.getRecordById(parentOrder);
    Order childOrder = orderQr.getRecordById(child);
    Order parentOrd = orderQr.getRecordById(childOrder.parentOrder__c);
    
    if (/*parentOrd.Account.category__c == 'Famiglie' && parentOrd.Sale__r.Channel__c == 'Teleselling Outbound' &&*/ parentOrd.SignatureMethod__c == 'Vocal Order' && parentOrd.Username__c == null){
      
      String podCode = childOrder.ServicePoint__r.ServicePointCode__c;
      Integer lengthOfPodCode = podCode.length();
      
      Integer startingCharacter = lengthOfPodCode - 8;
      String partOne = podCode.substring(startingCharacter,lengthOfPodCode);
      String thirdPosition = partOne.substring(2,3);
      
      String sixthPosition = partOne.substring(5,6);
      Integer ninthPosition = 9 - Integer.valueof(thirdPosition);
      Integer tenthPosition = 9 - Integer.valueof(sixthPosition);
      
      String username = partOne + String.valueOf(ninthPosition) + String.valueOf(tenthPosition);
      String contactFiscalCode = childOrder.Contact__c != null? childOrder.Contact__r.FiscalCode__c:'';
      String accountFiscalCode = childOrder.Account.FiscalCode__c;
      Date birthDate;
      if(String.isNotBlank(accountFiscalCode) && accountFiscalCode.isAlphanumeric()){
        birthDate = HDT_UTL_CheckFiscalCodeTaxNumber.getBirthDayFromCode(accountFiscalCode);
      }else if(String.isNotBlank(contactFiscalCode) && contactFiscalCode.isAlphanumeric()) {
        birthDate = HDT_UTL_CheckFiscalCodeTaxNumber.getBirthDayFromCode(contactFiscalCode);
      }else {
        birthDate = Date.today();
      }
      //Date birthDate = (Date)childOrder.Account.BirthDate__c != null?(Date)childOrder.Account.BirthDate__c:HDT_UTL_CheckFiscalCodeTaxNumber.getBirthDayFromCode(childOrder.Account.FiscalCode__c);  
      String year = String.valueOf(birthDate.year());
      
      String month = birthDate.month() > 9 ? String.valueOf(birthDate.month()) : '0'+String.valueOf(birthDate.month());
      String day = birthDate.day() > 9 ? String.valueOf(birthDate.day()) : '0'+String.valueOf(birthDate.day());
      String password = day + month + year.substring(2,4);
      

      String ecid = parentOrd.Sale__r.Ecid__c;
      //text to encrypt
      //16 byte string. since characters used are ascii, each char is 1 byte.
      Blob key = Crypto.generateAesKey(128);
      //encrypted blob
      Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(username+password));
      //encrypted string
      String encodedCipherText = EncodingUtil.base64Encode(cipherText);

      Order newOrder = new Order();
      newOrder.Id = childOrder.parentOrder__c;
      newOrder.UniqueCredentials__c = username + '_' + password;
      newOrder.UniqueAutentication__c = ecid + '_' + encodedCipherText;
      newOrder.Username__c = username;
      newOrder.Password__c = password;
      orderSrv.updateRecord(newOrder);
    }
}



@AuraEnabled
   public static void generateUsernameAndPassword(String orderchild,String parentOrder){

      //List<Order> orderList = orderQr.getChildOrdersByParentId(parentOrder);
      Order parentOrd = orderQr.getRecordById(parentOrder);
      Order childOrder = orderQr.getRecordById(orderchild);
      System.debug('********:2User');
      System.debug('********:2User:' + parentOrd.Sale__r.Channel__c);
      System.debug('********:2User:' + parentOrd.SignatureMethod__c);
      System.debug('********:2User:' + parentOrd.Account.category__c);
      System.debug('********:2User:' + parentOrd.Username__c);
      if (parentOrd.Account.category__c == 'Famiglie' && parentOrd.Sale__r.Channel__c == 'Teleselling Outbound' && parentOrd.SignatureMethod__c == 'Vocal Order' && parentOrd.Username__c == null){
        System.debug('********:3User');
        String podCode = childOrder.ServicePoint__r.ServicePointCode__c;
        Integer lengthOfPodCode = podCode.length();
        Integer startingCharacter = lengthOfPodCode - 8;
        String partOne = podCode.substring(startingCharacter,lengthOfPodCode);
        String thirdPosition = partOne.substring(2,3);
        String sixthPosition = partOne.substring(5,6);
        Integer ninthPosition = 9 - Integer.valueof(thirdPosition);
        Integer tenthPosition = 9 - Integer.valueof(sixthPosition);
        String username = partOne + String.valueOf(ninthPosition) + String.valueOf(tenthPosition);

        Date birthDate = (Date)childOrder.ServicePoint__r.Account__r.BirthDate__c;  
        String year = String.valueOf(birthDate.year());
        String month = birthDate.month() > 9 ? String.valueOf(birthDate.month()) : '0'+String.valueOf(birthDate.month());
        String day = birthDate.day() > 9 ? String.valueOf(birthDate.day()) : '0'+String.valueOf(birthDate.day());
        String password = day + month + year.substring(2,4);
        System.debug('********:4User');
        //System.debug(password);
        String ecid = parentOrd.Sale__r.Ecid__c;
        //text to encrypt
        //16 byte string. since characters used are ascii, each char is 1 byte.
        Blob key = Crypto.generateAesKey(128);
        //encrypted blob
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(username+password));
        //encrypted string
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);


        Order newOrder = new Order();
        newOrder.Id = parentOrder;
        newOrder.UniqueCredentials__c = username + '_' + password;
        newOrder.Username__c = username;
        newOrder.UniqueAutentication__c = ecid + '_' + encodedCipherText;
        newOrder.Password__c = password;
        orderSrv.updateRecord(newOrder);
    
    }
}
}