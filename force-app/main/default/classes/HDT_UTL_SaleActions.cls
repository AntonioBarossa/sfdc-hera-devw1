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
     * Returns a wrapper that contains QuoteLines updated and/or an error message if needed
     */
    public static HDT_WRP_SaleActions groupQuoteLines(String saleId)
    {
        HDT_WRP_SaleActions result = new HDT_WRP_SaleActions();
        /* Get All QuoteLines associated with the input sale*/
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id,
            Name,
            BillingProfile__c,
            ServicePoint__c,
            ServicePoint__r.CommoditySector__c,
            SBQQ__ProductFamily__c,
            SBQQ__RequiredBy__c,
            SBQQ__ProductCode__c,
            SBQQ__Product__r.Service__c,
            SBQQ__Product__r.ApprovalType__c,
            SBQQ__Product__r.IntegratedSAP__c,
            SBQQ__Product__r.Name,
            SBQQ__Quote__c,
            SBQQ__Quote__r.ContractReference__c,
            SBQQ__Quote__r.OrderReference__c,
            SBQQ__Quote__r.AllowChangeUse__c,
            SBQQ__Product__r.Family,
            SBQQ__Quote__r.AmendmentAllowed__c,
            SBQQ__Quote__r.Sale__r.Account__c,
            SBQQ__RequiredBy__r.BillingProfile__c,
            SBQQ__RequiredBy__r.Name,
            SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Name,
            SBQQ__RequiredBy__r.ServicePoint__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__r.Sale__c = :saleId AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            WITH SECURITY_ENFORCED];
        /* Identifies primary quote lines (see method for further information) */
        Map<String, List<SBQQ__QuoteLine__c>> groupingMap = identifyPrimaryQuoteLines(allQuoteLines);
        /* A check is performed to ensure that all primary quote lines have a Billing Profile associated to (see method for further information) */
        List<SBQQ__QuoteLine__c> quoteLinesWithoutBilling = checkBillingProfileAssociation(groupingMap);
        /* If the previous method returns a non empty list an error is thrown */
        if(!quoteLinesWithoutBilling.isEmpty())
        {
            result.errorMessage = 'Attenzione! Ai bundle “' + String.join(quoteLinesWithoutBilling, ',') +'” non è stato associato un Metodo di Pagamento';
            return result;
        }
        /* Once the Billing Profile association check has been performed, Quote Line Groups are inserted starting from primary quote lines (see method for further information) */
        Map<String,HDT_WRP_PrimaryGroup> quoteLineGroupObj = createQuoteLineGroups(groupingMap);
        /* After Quote Line Groups are created, all quotelines are associated with its group (see method for further information)*/
        allQuoteLines = associateQuoteLinesToGroups(quoteLineGroupObj, allQuoteLines);
        /* Since TARI groups can consist of options only ServicePoint need to be associated with the main quote line of these particular groups (see method for further information) */
        allQuoteLines = associateServicePointToQuoteLines(quoteLineGroupObj, allQuoteLines);
        /* Quote Lines are updated */
        HDT_UTL_DatabaseService.updateSObject(allQuoteLines);
        /* Wrapper to be returned is populated with an empty string as error message */
        result.quoteLineGrouped = allQuoteLines;
        result.errorMessage = '';


        return result;
    }

    /** This method identifies primary quote lines
     * Takes in input all quote lines associated with the current sale
     * returns a map<String, List<SBQQ__QuoteLine__c>>
     * Where the string is the group "identifier"
     * And the List contains primary quote lines for that particular group
     */
    private static Map<String, List<SBQQ__QuoteLine__c>> identifyPrimaryQuoteLines(List<SBQQ__QuoteLine__c> quoteLines)
    {
        Map<String, List<SBQQ__QuoteLine__c>> result = new Map<String, List<SBQQ__QuoteLine__c>>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        /* A map Id, QuoteLine is created to simplify following operations  */
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            quoteLineMap.put(quoteLine.Id, quoteLine);
        }

        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {   
            if(quoteLine.SBQQ__Product__r.Service__c != null && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente'))
            {
                /** TARI Order Split
                 * Tari order split is performed based on two fields on the Product2 Object
                 * ApprovalType__c and IntegratedSap__c
                 * All quotelines with the same combination of ApprovalType__c and IntegratedSap__c belongs to the same group
                 * The group "identifier" is generated as "ApprovalType__c" + "IntegratedSap__c"
                 */
                String key = quoteLine.SBQQ__Product__r.Family != null && quoteLine.SBQQ__Product__r.Family == 'Opzioni TARI'?
                                    quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) + 'Opzioni TARI' : 
                                    quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) ;
                if(!result.containsKey(key))
                {
                    result.put(key, new List<SBQQ__QuoteLine__c>());
                }
                (result.get(key)).add(quoteLine);
            }
            else
            {
                /** NON TARI Order Split
                 * Energy and Water order split is performed based on the presence of the main quote line
                 * which is the one with the Billing Profile Associated
                 * The Key is generated based on the quoteLine name if the Billing Profile is populated on the quote line
                 * Otherwise it is based on the RequiredBy__c field of the quote line
                 */
                Boolean isAnaconsNoEnergy = 'ACQ_DIARIO_CONSUMI'.equalsIgnoreCase(quoteline.SBQQ__ProductCode__c) || 'TLR_DIARIO_CONSUMI'.equalsIgnoreCase(quoteline.SBQQ__ProductCode__c) ? true : false;
                String key = quoteLine.BillingProfile__c != null && !isAnaconsNoEnergy ? NON_TARI_KEY + quoteLine.Name : NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.Name;
                if(!result.containsKey(key))
                {
                    result.put(key, new List<SBQQ__QuoteLine__c>());
                }
                /* If the quoteLine is of the type "Punto Fornitura" a group is created putting the RequiredBy__c as main quote line */
                if(COMMODITY_PRODUCT_SET.contains(quoteLine.SBQQ__Product__r.Name))
                {
                    (result.get(key)).add(quoteLineMap.get(quoteLine.SBQQ__RequiredBy__c));
                }
                /* This branch identifies those quote lines "VAS" and "Cambio Offerta" using the same check performed to associate the Billing Profile
                * Check HDT_LC_ApplyBillingProfileModal.getEligibleQuoteLinesToApply for further information
                */
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

    /** This method performs the Billing Profile Association check
     * Takes in input a map<String, List<SBQQ__QuoteLine__c>> which is the group generated in identifyPrimaryQuoteLines
     * returns a list of quote lines which does not have a Billing Profile associated
     */
    private static List<SBQQ__QuoteLine__c> checkBillingProfileAssociation(Map<String, List<SBQQ__QuoteLine__c>> groupingMap)
    {
        List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();
        for(String key : groupingMap.keySet())
        {
            /** NON TARI Check
             * If the group is Energy or Water
             * It is simply checked if the quote line has a billing profile associated
             */
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
            /** TARI Check
             * Since groups can be consisted of options only
             * It is not only checked that the BillingProfile is associated to the quote line
             * But it is check if the RequiredBy__r.BillingProfile__c is populated on the quote line
             */
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

    /** This method creates and insert the Quote Line Groups
     * Takes in input a map<String, List<SBQQ__QuoteLine__c>> which is the group generated in identifyPrimaryQuoteLines
     * returns a map<String, HDT_WRP_PrimaryGroup>
     * Where the string is the group "identifier" and the wrapper contains the main quote line and its group
     * The method is strightforward and does not need many explanation
     */
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
            /** TARI Caveat
             * Since TARI groups can be option only
             * There is not a "main quote line" so the first of the group is selected as the main
             */
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
    
    /** This method associate all quote lines associated to the sale to quote line groups
     * It takes in input the map generated in the method createQuoteLineGroups
     * return a list of quote lines with the group associated
     * The method has a simple logic, build the key as it has been build in the identifyPrimaryQuoteLines
     * From the quoteLineGroupObj map the wrapper with the group is retrieved using the key (which is the group "identifier") and associated to the quote line
     */
    private static List<SBQQ__QuoteLine__c> associateQuoteLinesToGroups(Map<String, HDT_WRP_PrimaryGroup> quoteLineGroupObj, List<SBQQ__QuoteLine__c> quoteLines)
    {
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            String key;
            Boolean isTari = quoteLine.SBQQ__Product__r.Service__c != null && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente');
            if(isTari)
            {
                key = quoteLine.SBQQ__Product__r.Family != null && quoteLine.SBQQ__Product__r.Family == 'Opzioni TARI'?
                                quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) + 'Opzioni TARI' : 
                                quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) ;
            }
            else
            {
                Boolean isAnaconsNoEnergy = 'ACQ_DIARIO_CONSUMI'.equalsIgnoreCase(quoteLine.SBQQ__ProductCode__c) || 'TLR_DIARIO_CONSUMI'.equalsIgnoreCase(quoteLine.SBQQ__ProductCode__c) ? true : false;
                key = quoteLine.BillingProfile__c != null && !isAnaconsNoEnergy ? NON_TARI_KEY + quoteLine.Name : NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.Name;
            }
            if(quoteLineGroupObj.get(key) == null)
            {
                key = NON_TARI_KEY + quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Name;
            }
            quoteLine.SBQQ__Group__c = quoteLineGroupObj.get(key).groupLine.Id;
            /** TARI Caveat
             * Since TARI groups can consists of options only, the billing profile from the "Offerta Commerciale" quote line
             * is associated to the "main" quote line of the options only group
             */
            if(isTari && quoteLine.Id == quoteLineGroupObj.get(key).mainQuoteLineId && quoteLine.BillingProfile__c == null)
            {
                quoteLine.BillingProfile__c = quoteLine.SBQQ__RequiredBy__r.BillingProfile__c;
                
            }
        }

        return quoteLines;
    }
    /** This method associate the Service Point to the TARI options only groups
     * It takes in input the map generated in the method createQuoteLineGroups and all the quote lines associated with the sale
     * return a list of quote lines with the service point associated where needed
     * The method has a simple logic.
     * First Service Point TARI are identified with the respective main quote line
     * Than the "main" quote lines of TARI options only groups are associated with the Service Point
     * Using the RequiredBy__c field as "identifier"
     */
    private static List<SBQQ__QuoteLine__c> associateServicePointToQuoteLines(Map<String, HDT_WRP_PrimaryGroup> quoteLineGroupObj, List<SBQQ__QuoteLine__c> quoteLines)
    {
        Map<Id, Id> quoteLineServicePointMap = new Map<Id, Id>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.ServicePoint__c != null && quoteLine.SBQQ__Product__r.Service__c != null  && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente'))
            {
                quoteLineServicePointMap.put(quoteLine.SBQQ__RequiredBy__c, quoteLine.ServicePoint__c);
            }
        }
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            Boolean isTari = quoteLine.SBQQ__Product__r.Service__c != null && quoteLine.SBQQ__Product__r.Service__c.equalsIgnoreCase('Ambiente');
            if(!isTari)
            {
                continue;
            }
            String key = quoteLine.SBQQ__Product__r.Family != null && quoteLine.SBQQ__Product__r.Family == 'Opzioni TARI'?
                                    quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) + 'Opzioni TARI' : 
                                    quoteLine.SBQQ__Product__r.ApprovalType__c + String.valueOf(quoteLine.SBQQ__Product__r.IntegratedSAP__c) ;
            if((quoteLineGroupObj.get(key)).mainQuoteLineId == quoteLine.Id && quoteLine.ServicePoint__c == null)
            {
                quoteLine.ServicePoint__c = quoteLineServicePointMap.get(quoteLine.SBQQ__RequiredBy__c);
            }
        }
        
        return quoteLines;
    }
    /* Wrapper returned by the core method */
    public class HDT_WRP_SaleActions
    {
        public String errorMessage;
        public List<SBQQ__QuoteLine__c> quoteLineGrouped;
    }
    /* Wrapper that helps the quote line - quote line groups associated */
    class HDT_WRP_PrimaryGroup
    {
         public String mainQuoteLineId;
         public SBQQ__QuoteLineGroup__c groupLine;
    }
}
