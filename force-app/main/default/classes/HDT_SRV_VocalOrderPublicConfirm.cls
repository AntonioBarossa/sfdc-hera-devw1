public without sharing class HDT_SRV_VocalOrderPublicConfirm {
   public static VocalOrderPublicConfirm__c createRecord(VocalOrderPublicConfirm__c c){
      insert c;
      return c;
   }
}
