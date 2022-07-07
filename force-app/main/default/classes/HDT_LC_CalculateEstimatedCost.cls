/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/02/2021
* @description HDT_LC_CalculateEstimatedCost
* @history Keltin Mesonjesi – 27/02/2021 – Created class
*/
public inherited sharing class HDT_LC_CalculateEstimatedCost {
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    @AuraEnabled
    public static void updateOrder(Order order){
        orderSrv.updateRecord(new Order(
            Id = order.Id,
            EstimateAmount__c = order.EstimateAmount__c,
            PowerQuote__c = order.PowerQuote__c,
            AdministrativeBurden__c = order.AdministrativeBurden__c.setScale(2),
            EstimatedVAT__c = order.EstimatedVAT__c,
            ValidityDateEstimate__c = order.ValidityDateEstimate__c,
            VariableAmount__c = (order.EstimateAmount__c - order.AdministrativeBurden__c).setScale(2),
            OperationCode__c = Order.OperationCode__c,
            QuotationType__c = order.QuotationType__c
        ));
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 01-08-2021 
    * @param ord 
    * @return string 
    **/
    @AuraEnabled
    public static HDT_WRP_ExtimatedCost getExtimatedCost(Order ord){
        HDT_WRP_ExtimatedCost wrp = new HDT_WRP_ExtimatedCost();
        HDT_LC_ChildOrderProcessDetails.HDT_WRP_QuoteType typeAndCode = HDT_LC_ChildOrderProcessDetails.getQuoteTypeMtd(ord);
        wrp.quoteType=typeAndCode.quoteType;
        wrp.quoteCode=typeAndCode.quoteCode;
        try{
            if(wrp.quoteType=='Rapido'){
                getFixedQuotes(ord, wrp);
                system.debug('voltage level '+ord.VoltageLevel__c);
                Integer daysToBeAdded = ord.VoltageLevel__c=='BT'? 90 : 180;
                wrp.validityDate=DateTime.now().addDays(daysToBeAdded).format('dd-MM-yyyy');
            }
        }catch(Exception e){
            system.debug(e.getStackTraceString()+' at line '+e.getLineNumber());
            system.debug(e.getMessage()+' '+e.getCause());
        }
        return wrp;
    }
	@TestVisible
    private static void getFixedQuotes(Order ord, HDT_WRP_ExtimatedCost wrp){
        String supplyType = [SELECT SupplyType__c FROM Order WHERE Id = :ord.Id WITH SECURITY_ENFORCED LIMIT 1].SupplyType__c;
        String searchKey = (new Set<String>{'Domestico', 'A-Domestico'}.contains(supplyType)) ? 'Domestico' : 'Non Domestico';
        HDT_CalcoloPreventivi__mdt fixedQuotes = [SELECT VAT__c, DistributorFixedQuote__c, PowerQuote__c, SellerFixedQuote__c FROM HDT_CalcoloPreventivi__mdt WHERE Type__c=:searchKey WITH SECURITY_ENFORCED];
        wrp.fixedQuotes=fixedQuotes;
        Decimal variableAmount =  fixedQuotes.PowerQuote__c*((ord.PowerRequested__c*(ord.PowerAvailable__c>30?1.0:1.1))-ord.PowerAvailable__c);
        wrp.estimatedAmount=(variableAmount+fixedQuotes.DistributorFixedQuote__c+fixedQuotes.SellerFixedQuote__c);
        wrp.estimatedAmount=wrp.estimatedAmount.setScale(2);
        return;
    }

    public Map<String,Decimal> getAmounts(String supplyType, Decimal estimatedAmount)
    {
        Map<String,Decimal> resultMap = new Map<String,Decimal>();
        String searchKey = (new Set<String>{'Domestico', 'A-Domestico'}.contains(supplyType)) ? 'Domestico' : 'Non Domestico';
        HDT_CalcoloPreventivi__mdt fixedQuotes = [SELECT VAT__c, DistributorFixedQuote__c, PowerQuote__c, SellerFixedQuote__c FROM HDT_CalcoloPreventivi__mdt WHERE Type__c=:searchKey WITH SECURITY_ENFORCED];
        resultMap.put('fixedAmount',(fixedQuotes.DistributorFixedQuote__c + fixedQuotes.SellerFixedQuote__c).setScale(2));
        resultMap.put('variableAmount',(estimatedAmount - (resultMap.get('fixedAmount'))).setScale(2));
        return resultMap;
    }

    public class HDT_WRP_ExtimatedCost{
        @AuraEnabled public String quoteType {get;set;}
        @AuraEnabled public String quoteCode {get;set;}
        @AuraEnabled public HDT_CalcoloPreventivi__mdt fixedQuotes {get;set;}
        @AuraEnabled public String validityDate {get;set;}
        @AuraEnabled public Decimal estimatedAmount {get;set;}
    }
}