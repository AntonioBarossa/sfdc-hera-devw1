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
    public static List<AtecoMatrix__c> getAtecoMatrixList(String filterType, String filterValue, String supplyCity){
        
        List<AtecoMatrix__c> atecoMatrixList = new List<AtecoMatrix__c>();

        system.debug(supplyCity);

        switch on filterType {
            when 'City__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByComune(filterValue);
            }
            when 'IstatCode__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat(filterValue);
            }
            when 'CityRonchi' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByComuneRonchi(filterValue);
            }
            when 'IstatCodeAndCity' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstatRonchi(filterValue, supplyCity);
            }
            when 'RonchiCodeAndCity' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceRonchi(filterValue, supplyCity);
            }
        }

        return atecoMatrixList;

    }

    @AuraEnabled
    public static List<AtecoMatrix__c> getAtecoMatrixListIstatRonchi(String filterType, String filterValue, String whichCode){
        
        List<AtecoMatrix__c> atecoMatrixList = new List<AtecoMatrix__c>();

        switch on filterType {
            when 'City__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByComune(filterValue,whichCode);
            }
            when 'IstatCode__c' {
                atecoMatrixList = HDT_QR_AtecoMatrix.getAtecoMatrixByCodiceIstat(filterValue,whichCode);
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
            RonchiCodeDescription__c = params.get('ronchiDescription')
        ));
    }

    @AuraEnabled
    public static void saveIstatRonchiCase(Case caseRecord, String whichCode, Map<String,String> params){
        if('Istat'.equalsIgnoreCase(whichCode)){
            caseSrv.updateRecord(new Case(
                Id = caseRecord.Id,
                AtecoCode__c = params.get('atecoCode'),
                SupplyCityCode__c = params.get('istatCode')
            ));
        }else if('Ronchi'.equalsIgnoreCase(whichCode)){
            caseSrv.updateRecord(new Case(
                Id = caseRecord.Id,
                RonchiCode__c = params.get('ronchiCode'),
                RonchiSubcategory__c = params.get('ronchiSubcategory'),
                RonchiCodeDescription__c = params.get('ronchiDescription')
            )); 
        }
    }

}