/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 30/06/2021
* @description Class HDT_LC_CodiceAteco
* @history Keltin Mesonjesi – 30/06/2021 – Created class
*/
public inherited sharing class HDT_LC_CodiceAteco {

    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
    
    @AuraEnabled
    public static List<AtecoMatrix__c> getAtecoMatrixList(String filterType, String filterValue){
        
        List<AtecoMatrix__c> atecoMatrixList = new List<AtecoMatrix__c>();

        switch on filterType {
            when 'City__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByComune(filterValue);
            }
            when 'IstatCode__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat(filterValue);
            }
        }

        return atecoMatrixList;

    }

    @AuraEnabled
    public static void saveAtecoCode(Order order, Map<String,String> params){
        orderSrv.updateRecord(new Order(
            Id = order.Id,
            AtecoCode__c = params.get('atecoCode'),
            HerAteco__c = params.get('istatCode')
        ));
    }

    @AuraEnabled
    public static void saveAtecoRonchiCode(Order order, Map<String,String> params){
        orderSrv.updateRecord(new Order(
            Id = order.Id,
            AtecoCode__c = params.get('atecoCode'),
            HerAteco__c = params.get('istatCode'),
            RonchiCode__c = params.get('ronchiCode'),
            RonchiSubcat__c = params.get('ronchiSubcategory'),
            RonchiDescription__c = params.get('ronchiDescription')
        ));
    }

    @AuraEnabled
    public static void saveAtecoRonchiCodeCase(Case caseRecord, Map<String,String> params){
        caseSrv.updateRecord(new Case(
            Id = caseRecord.Id,
            AtecoCode__c = params.get('atecoCode'),
            SupplyCityCode__c = params.get('istatCode'),
            RonchiCode__c = params.get('ronchiCode'),
            RonchiSubcategory__c = params.get('ronchiSubcategory'),
            RonchiDescription__c = params.get('ronchiDescription')
        ));
    }

}