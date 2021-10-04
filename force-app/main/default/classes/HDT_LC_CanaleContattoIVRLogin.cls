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
        if(orderId == checkLogin(username,password).id){
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
        }
    }
            
    @AuraEnabled
    public static String checkListenVO(String orderId){
        System.debug('It\'s inside the method checkListenVO');
        Order ord = orderQr.getRecordById(orderId);
        String prefix = 'PREFISSO';//+ ord.Ecid__c;
        return prefix;
  
    }
    @AuraEnabled
    public static Map<String, String> downloadDocument(String orderId,String username,String password){
        map<String,String> mapReturn = new Map<String,String>();
        try {
                String id = checkLogin(username,password).id;
                if(id == orderId){
                    HDT_LC_CanaleIVRNoShare qrsha = new HDT_LC_CanaleIVRNoShare();
                    DocumentalActivity__c dc = qrsha.getActivityByOrder(orderId);
                    //mapReturn.put('base64','UFJPVkFET1dOTE9BRFBST1ZB');
                    //String s = HDT_LC_DocumentSignatureManager.showOriginalDocument(dc.id);
                // System.debug('*********:'+ s);
                    mapReturn = qrsha.getPlico(dc.id); 
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
    System.debug('********:2User');
    System.debug('********:2User:' + parentOrd.Sale__r.Channel__c);
    System.debug('********:2User:' + parentOrd.SignatureMethod__c);
    System.debug('********:2User:' + parentOrd.Account.category__c);
    System.debug('********:2User:' + parentOrd.Username__c);
    if (parentOrd.Account.category__c == 'Famiglie' && parentOrd.Sale__r.Channel__c == 'Teleselling Outbound' && parentOrd.SignatureMethod__c == 'Vocal Order' && parentOrd.Username__c == null){
      System.debug('********:3User2');
      String podCode = childOrder.ServicePoint__r.ServicePointCode__c;
      Integer lengthOfPodCode = podCode.length();
      System.debug('********:3User3');
      Integer startingCharacter = lengthOfPodCode - 8;
      String partOne = podCode.substring(startingCharacter,lengthOfPodCode);
      String thirdPosition = partOne.substring(2,3);
      System.debug('********:3User4');
      String sixthPosition = partOne.substring(5,6);
      Integer ninthPosition = 9 - Integer.valueof(thirdPosition);
      Integer tenthPosition = 9 - Integer.valueof(sixthPosition);
      System.debug('********:3User5');
      String username = partOne + String.valueOf(ninthPosition) + String.valueOf(tenthPosition);

      Date birthDate = (Date)childOrder.Account.BirthDate__c;  
      String year = String.valueOf(birthDate.year());
      System.debug('********:3User6');
      String month = birthDate.month() > 9 ? String.valueOf(birthDate.month()) : '0'+String.valueOf(birthDate.month());
      String day = birthDate.day() > 9 ? String.valueOf(birthDate.day()) : '0'+String.valueOf(birthDate.day());
      String password = day + month + year.substring(2,4);
      System.debug('********:4User');
      Order newOrder = new Order();
      newOrder.Id = childOrder.parentOrder__c;
      newOrder.UniqueCredentials__c = username + '_' + password;
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
        Order newOrder = new Order();
        newOrder.Id = parentOrder;
        newOrder.UniqueCredentials__c = username + '_' + password;
        newOrder.Username__c = username;
        newOrder.Password__c = password;
        orderSrv.updateRecord(newOrder);
    
    }
}
}