/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/01/2021
* @description Apex controller for hdtSaleVas.js component
* @history Keltin Mesonjesi – 19/01/2021 – Created class
*/
public inherited sharing class HDT_LC_SaleVas {
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Handles confirm action logic
     * @param String selectedOption
     */
    @AuraEnabled
    public static void confirmAction(String selectedOption, String inputText){
        switch on selectedOption {
            when  'Ordini in corso'{
                system.debug('selectedOption: ' + selectedOption);
                system.debug('inputText: ' + inputText);
            }
            when 'Contratti Attivi'{
                system.debug('selectedOption: ' + selectedOption);
                system.debug('inputText: ' + inputText);
            }
            when 'VAS stand alone'{
                system.debug('selectedOption: ' + selectedOption);
                system.debug('inputText: ' + inputText);
            }
            
        }
    }
}
