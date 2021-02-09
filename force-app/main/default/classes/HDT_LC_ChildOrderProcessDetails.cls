/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 08/02/2021
 * @description HDT_LC_ChildOrderProcessDetails.cls - Class that holds methods that are called from hdtChildOrderProcessDetails.js component
 * @history Keltin Mesonjesi – 08/01/2021 – Created class
 */
public inherited sharing class HDT_LC_ChildOrderProcessDetails {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 08/02/2021
     * @description Configure fields for each section of details
     * @param orderId
     * @param String selectedProcess - selected process for child order
     */
    @AuraEnabled
    public static Map<String,List<Map<String,String>>> initFields(){
        Map<String,List<Map<String,String>>> allSections = new Map<String,List<Map<String,String>>>();

        List<Map<String,String>> creditCheck = new List<Map<String,String>>{
            new Map<String,String>{
                'label' => 'Esito credit Check Entrante',
                'apiname' => 'BillingCity',
                'type' => 'ele/gas',
                'required' => 'false',
                'disabled' => 'true'
            },
            new Map<String,String>{
                'label' => 'Esito credit Check Uscente',
                'apiname' => 'BillingCity',
                'type' => 'ele/gas',
                'required' => 'false',
                // 'disabled' => 'true',
                'disabled' => 'false'
            },
            new Map<String,String>{
                'label' => 'Descrizione esito',
                'apiname' => 'BillingCity',
                'type' => 'ele/gas',
                'required' => 'false',
                'disabled' => 'true'
            }
        };

        

        allSections.put('creditCheck', creditCheck);

        return allSections;
    }

}
