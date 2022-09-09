/**@frpanico 2022-09-08
 * Utility class of the SaleActions controller HDT_LC_SaleActions
 */
public with sharing class HDT_UTL_SaleActions
{

    private static final Set<String> COMMODITY_PRODUCT_SET = new Set<String>{'POD', 'PDR','Punto Fornitura Acqua','Punto Fornitura','Punto Fornitura Ambiente'};
    private static final Set<String> VAS_PRODUCT_SET = new Set<String>{'VAS Fatturabili','VAS Prodotto','VAS Servizio'};
    private static final String NON_TARI_KEY = 'nonTari';
    private static final String QUOTE_PROCESS_NAME = 'Vendita Guidata Offerte';


    /**@frpanico 2022-09-08
     * This method creates the GroupLines to perform order split
     * It takes in input the SaleId
     * Returns a wrapper that contains group and/or an error message if needed
     */
    public static HDT_WRP_SaleActions groupQuoteLines(String saleId)
    {
        HDT_WRP_SaleActions result = new HDT_WRP_SaleActions();
        /* Get All QuoteLines */
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id,
            Name,
            BillingProfile__c,
            ServicePoint__c,
            ServicePoint__r.CommoditySector__c,
            SBQQ__ProductFamily__c,
            SBQQ__RequiredBy__c,
            SBQQ__Product__r.Service__c,
            SBQQ__Product__r.ApprovalType__c,
            SBQQ__Product__r.IntegratedSAP__c,
            SBQQ__Product__r.Name,
            SBQQ__Quote__c,
            SBQQ__Quote__r.ContractReference__c,
            SBQQ__Quote__r.OrderReference__c,
            SBQQ__Quote__r.AllowChangeUse__c,
            SBQQ__Quote__r.AmendmentAllowed__c,
            SBQQ__Quote__r.Sale__r.Account__c,
            SBQQ__RequiredBy__r.BillingProfile__c,
            SBQQ__RequiredBy__r.Name,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Name
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__r.Sale__c = :saleId 
            WITH SECURITY_ENFORCED];

            Map<String, List<SBQQ__QuoteLine__c>> groupingMap = identifyPrimaryQuoteLines(allQuoteLines);
            List<SBQQ__QuoteLine__c> quoteLinesWithoutBilling = checkBillingProfileAssociation(groupingMap);
            if(!quoteLinesWithoutBilling.isEmpty())
            {
                result.errorMessage = 'Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento';
                return result;
            }
            Map<String,HDT_WRP_PrimaryGroup> quoteLineGroupObj = createQuoteLineGroups(groupingMap);
            allQuoteLines = associateQuoteLinesToGroups(quoteLineGroupObj, allQuoteLines);
            System.debug(JSON.serialize(allQuoteLines));

        return result;
    }


    private static Map<String, List<SBQQ__QuoteLine__c>> identifyPrimaryQuoteLines(List<SBQQ__QuoteLine__c> quoteLines)
    {
        Map<String, List<SBQQ__QuoteLine__c>> result = new Map<String, List<SBQQ__QuoteLine__c>>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            quoteLineMap.put(quoteLine.Id, quoteLine);
        }

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {   
            if(quoteLine.SBQQ__Product__r.Service__c != null && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente'))
            {
                String key = quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c);
                if(!result.containsKey(key))
                {
                    result.put(key, new List<SBQQ__QuoteLine__c>());
                }
                (result.get(key)).add(quoteLine);
            }
            else
            {
                String key = quoteLine.BillingProfile__c != null ? NON_TARI_KEY + quoteLine.Name : NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.Name;
                if(!result.containsKey(key))
                {
                    result.put(key, new List<SBQQ__QuoteLine__c>());
                }
                if(COMMODITY_PRODUCT_SET.contains(quoteLine.SBQQ__Product__r.Name))
                {
                    (result.get(key)).add(quoteLineMap.get(quoteLine.SBQQ__RequiredBy__c));
                }
                else if(
                    VAS_PRODUCT_SET.contains(quoteLine.SBQQ__ProductFamily__c) 
                    && 
                    (
                        (quoteLine.SBQQ__Quote__r.ContractReference__c == null || quoteLine.SBQQ__Quote__r.OrderReference__c == null)
                        || (
                            quoteLine.SBQQ__Quote__r.ContractReference__c != null 
                            && (quoteLine.SBQQ__Quote__r.AllowChangeUse__c == null || quoteLine.SBQQ__Quote__r.AllowChangeUse__c == false)
                            && (quoteLine.SBQQ__Quote__r.AmendmentAllowed__c == null || quoteLine.SBQQ__Quote__r.AmendmentAllowed__c == false)
                        )
                    )
                )
                {
                    (result.get(key)).add(quoteLineMap.get(quoteLine.Id));
                }
            }
        }

        return result;
    }


    private static List<SBQQ__QuoteLine__c> checkBillingProfileAssociation(Map<String, List<SBQQ__QuoteLine__c>> groupingMap)
    {
        List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();
        for(String key : groupingMap.keySet())
        {
            if(key.containsIgnoreCase(NON_TARI_KEY))
            {
                for(SBQQ__QuoteLine__c quoteLine : groupingMap.get(key))
                {
                    if(quoteLine.BillingProfile__c == null)
                    {
                        result.add(quoteLine);
                    }
                }
            }
            else
            {
                Boolean check = false;
                for(SBQQ__QuoteLine__c quoteLine : groupingMap.get(key))
                {
                    if(quoteLine.BillingProfile__c != null || quoteLine.SBQQ__RequiredBy__r.BillingProfile__c != null )
                    {
                        check = true;
                        break;
                    }
                }
                if(!check)
                {
                    result.add((groupingMap.get(key))[0]);
                }
            }
        }

        return result;
    }

    private static Map<String,HDT_WRP_PrimaryGroup> createQuoteLineGroups(Map<String, List<SBQQ__QuoteLine__c>> groupingMap)
    {
        Map<String,HDT_WRP_PrimaryGroup>  result = new Map<String,HDT_WRP_PrimaryGroup>();
        List<SBQQ__QuoteProcess__c> quoteProcess = [SELECT Id FROM SBQQ__QuoteProcess__c WHERE Name = :QUOTE_PROCESS_NAME WITH SECURITY_ENFORCED];
        for(String key : groupingMap.keySet())
        {
            if(key.containsIgnoreCase(NON_TARI_KEY))
            {
                for(SBQQ__QuoteLine__c quoteLine : groupingMap.get(key))
                {
                    HDT_WRP_PrimaryGroup groupObj = new HDT_WRP_PrimaryGroup();
                    SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
                    newGroup.SBQQ__Account__c = quoteLine.SBQQ__Quote__r.Sale__r.Account__c;
                    newGroup.Name = quoteLine.Name + ' Group';
                    newGroup.SBQQ__Quote__c = quoteLine.SBQQ__Quote__c;
                    newGroup.SBQQ__QuoteProcess__c = quoteProcess[0].Id;
                    groupObj.groupLine = newGroup;
                    groupObj.mainQuoteLineId = quoteLine.Id;
                    result.put(key, groupObj);
                }
            }
            else
            {
                SBQQ__QuoteLine__c mainQuoteLine = new SBQQ__QuoteLine__c();
                for(SBQQ__QuoteLine__c quoteLine : groupingMap.get(key))
                {
                    if(quoteLine.SBQQ__RequiredBy__c == null)
                    {
                        mainQuoteLine = quoteLine;
                        break;
                    }
                }
                if(mainQuoteLine.Id == null)
                {
                    mainQuoteLine = (groupingMap.get(key))[0];
                }
                HDT_WRP_PrimaryGroup groupObj = new HDT_WRP_PrimaryGroup();
                SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
                newGroup.SBQQ__Account__c = mainQuoteLine.SBQQ__Quote__r.Sale__r.Account__c;
                newGroup.Name = mainQuoteLine.Name + ' Group';
                newGroup.SBQQ__Quote__c = mainQuoteLine.SBQQ__Quote__c;
                newGroup.SBQQ__QuoteProcess__c = quoteProcess[0].Id;
                groupObj.groupLine = newGroup;
                groupObj.mainQuoteLineId = mainQuoteLine.Id;
                result.put(key, groupObj);
            }
        }

        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        for(String key : result.keySet())
        {
            quoteLineGroups.add((result.get(key)).groupLine);
        }
        HDT_UTL_DatabaseService.insertSObject(quoteLineGroups);

        return result;
    }

    private static List<SBQQ__QuoteLine__c> associateQuoteLinesToGroups(Map<String, HDT_WRP_PrimaryGroup> quoteLineGroupObj, List<SBQQ__QuoteLine__c> quoteLines)
    {
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            String key;
            Boolean isTari = quoteLine.SBQQ__Product__r.Service__c != null && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente');
            if(isTari)
            {
                key = quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c);
            }
            else
            {
                key = quoteLine.BillingProfile__c != null ? NON_TARI_KEY + quoteLine.Name : NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.Name;
            }
            if(quoteLineGroupObj.get(key) == null)
            {
                key = NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Name;
            }
            quoteLine.SBQQ__Group__c = quoteLineGroupObj.get(key).groupLine.Id;
            if(isTari && quoteLine.Id == quoteLineGroupObj.get(key).mainQuoteLineId && quoteLine.BillingProfile__c == null)
            {
                quoteLine.BillingProfile__c = quoteLine.SBQQ__RequiredBy__r.BillingProfile__c;
            }
        }

        return quoteLines;
    }
    // private static Boolean existGroupName(String groupName, List<HDT_WRP_PrimaryGroup> groups)
    // {
    //     for(HDT_WRP_PrimaryGroup singleGroup : groups)
    //     {
    //         if(singleGroup.groupName.equalsIgnoreCase(groupName))
    //         {
    //             return true;
    //         }
    //     }
    //     return false;
    // }

    public class HDT_WRP_SaleActions
    {
        public String errorMessage;
        public List<SBQQ__QuoteLine__c> quoteLineGrouped;
    }

    class HDT_WRP_PrimaryGroup
    {
         public String mainQuoteLineId;
         public SBQQ__QuoteLineGroup__c groupLine;
    }
}
