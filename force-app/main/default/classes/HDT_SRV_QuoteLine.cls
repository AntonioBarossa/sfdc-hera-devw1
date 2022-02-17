/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 16/11/2020
* @description HDT_SRV_QuoteLine – Contains methods for crud and business logic regarding SBQQ__QuoteLine__c
* @history Keltin Mesonjesi – 16/11/2020 – Created class
*/

public inherited sharing class HDT_SRV_QuoteLine {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__QuoteLine__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Check if current user has create permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Create records in bulk
    * @param objectsList
    * @return List<SBQQ__QuoteLine__c>
    */

    /**@frpanico 17/02/2022
     * Metodo deprecato in quanto non utilizzato
     */
    /*public List<SBQQ__QuoteLine__c> createRecords(List<SBQQ__QuoteLine__c> objectsList){

        for (SBQQ__QuoteLine__c quoteLine : objectsList) {
            List<String> fields = helperMethods.getObjAttrList(quoteLine);
            checkCreateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.insertSObject(objectsList);

        return objectsList;
    }*/

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update single record
    * @param quoteLine
    */
    public void updateRecord(SBQQ__QuoteLine__c quoteLine){
        
        List<String> fields = helperMethods.getObjAttrList(quoteLine);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(quoteLine);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update records in bulk
    * @param objectsList
    */
    public void updateRecords(List<SBQQ__QuoteLine__c> objectsList){
        
        for (SBQQ__QuoteLine__c quoteLine : objectsList) {
            List<String> fields = helperMethods.getObjAttrList(quoteLine);
            checkUpdateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.updateSObject(objectsList);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 18/11/2020
    * @description Group QuoteLines in a list of maps based on Quotes they belong to
    * @param quoteList
    * @param quoteLineList
    * @return List<Map<String,List<SObject>>>
    */
    public List<Map<String,List<SObject>>> groupRecordsByQuote(List<SBQQ__Quote__c> quoteList, List<SBQQ__QuoteLine__c> quoteLineList){

        List<Map<String,List<SObject>>> groupedQuoteLines = new List<Map<String,List<SObject>>>();

        for (SBQQ__Quote__c quote : quoteList) {

            List<SBQQ__Quote__c> tempListQuotes = new List<SBQQ__Quote__c>{quote};
            List<SBQQ__QuoteLine__c> tempListQuoteLines = new List<SBQQ__QuoteLine__c>();
            Map<String,List<SObject>> tempMap = new Map<String,List<SObject>>();

            for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
                
                if (quoteLine.SBQQ__Quote__r.Id == quote.Id) {
                    tempListQuoteLines.add(quoteLine);
                }
            }

            tempMap.put('quote',tempListQuotes);
            tempMap.put('quoteLines',tempListQuoteLines);
            groupedQuoteLines.add(tempMap);
            
        }
        

        return groupedQuoteLines;

    }

}
