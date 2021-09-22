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
    public static Order checkContractualEnvelope(String orderId ){
        try {
            System.debug('It\'s inside the method checkContractualEnvelope');
            //  ConsumptionCode__c consumptionCode = consumptionCodeQr.getRecordById(consumptionCodeId);
              Order order = orderQr.getRecordById(orderId);
            System.debug('********');
              return order;    
        } catch (Exception e) {
            System.debug(e.getMessage()); 
            throw new AuraHandledException(e.getMessage());
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
    public static Map<String, String> downloadDocument(String orderId){
        try {
            HDT_LC_CanaleIVRNoShare qrsha = new HDT_LC_CanaleIVRNoShare();
            DocumentalActivity__c dc = qrsha.getActivityByOrder(orderId);
            map<String,String> mapReturn = new Map<String,String>();
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
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Order checkFinalConfirmationOfTheContract(String orderId){
        System.debug('It\'s inside the method checkFinalConfirmationOfTheContract');
        //ConsumptionCode__c consumptionCode = consumptionCodeQr.getRecordById(consumptionCodeId);
        Order ord = orderQr.getRecordById(orderId);
       /*List<Order> listOrderChildToUpdate = orderQr.getChildOrdersByParentId(orderId);
        List<Order> orderToUpdate = new List<Order>();
        orderToUpdate.add(new Order(id=orderId,))



*/
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
   public static Order generateUsernameAndPassword(Order parentOrder){
    try{
      Order ordParent = [Select id,Account.customerMarking__c,sale__r.Channel__c,SignatureMethod__c from order where id = :parentOrder.id];
      if(ordParent.Account.customerMarking__c == 'Famiglie' && ordParent.SignatureMethod__c == 'Vocal Order' && ordParent.sale__r.Channel__c == 'Teleselling Outbound'){
      List<Order> orderList = orderQr.getChildOrdersByParentId(parentOrder.id);
      if (orderList.size() > 0){
           // Order ordParent = [Select id,Account.customerMarking__c,sale__r.Channel__c,SignatureMethod__c from order where id = :parentOrder.id];
            String podCode = orderList[0].ServicePoint__r.ServicePointCode__c;
            Integer lengthOfPodCode = podCode.length();
            Integer startingCharacter = lengthOfPodCode - 8;
            String partOne = podCode.substring(startingCharacter,lengthOfPodCode);
            String thirdPosition = partOne.substring(2,3);
            String sixthPosition = partOne.substring(5,6);
            Integer ninthPosition = 9 - Integer.valueof(thirdPosition);
            Integer tenthPosition = 9 - Integer.valueof(sixthPosition);
            String username = partOne + String.valueOf(ninthPosition) + String.valueOf(tenthPosition);

            Date birthDate = (Date)orderList[0].ServicePoint__r.Account__r.BirthDate__c;  
            String year = String.valueOf(birthDate.year());
            String month = birthDate.month() > 9 ? String.valueOf(birthDate.month()) : '0'+String.valueOf(birthDate.month());
            String day = birthDate.day() > 9 ? String.valueOf(birthDate.day()) : '0'+String.valueOf(birthDate.day());
            String password = day + month + year.substring(2,4);
            System.debug(password);
           // Order newOrder = new Order();
           // newOrder.Id = parentOrder;
            parentOrder.UniqueCredentials__c = username + '_' + password;
            parentOrder.Username__c = username;
            parentOrder.Password__c = password;
          ///  orderSrv.updateRecord(newOrder);
        }
        }
        
        }catch(Exception e){
            system.debug('******:' + e);
        }
      return parentOrder;
}

}
