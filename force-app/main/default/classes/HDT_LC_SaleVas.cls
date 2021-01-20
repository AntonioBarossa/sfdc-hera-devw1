/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/01/2021
* @description Apex controller for hdtSaleVas.js component
* @history Keltin Mesonjesi – 19/01/2021 – Created class
*/
public inherited sharing class HDT_LC_SaleVas {
    
    private static HDT_SRV_Opportunity opportunitySrv = new HDT_SRV_Opportunity();
    private static HDT_SRV_Quote quoteSrv = new HDT_SRV_Quote();

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

                // Opportunity newOpportunity = opportunitySrv.createRecord(new Opportunity(
                    // Sale__c = sale.Id,
                    // Name = opportunitySrv.generateName(sale),
                    // CloseDate = Date.today().addDays(30),
                    // StageName = 'Proposal'
                    // AccountId = sale.Account__c
                // ));

                // SBQQ__Quote__c newQuote = quoteSrv.createRecord(new SBQQ__Quote__c(
                    // Vendita__c = sale.Id,
                    // SBQQ__Opportunity2__c = newOpportunity.Id,
                    // SBQQ__Account__c = sale.Account__c,
                    // SBQQ__Primary__c = true,
                    // Agency__c = sale.Agency__c,
                    // Market__c = sale.Market__c,
                    // Channel__c = sale.Channel__c,
                    // FriendCode__c = sale.FriendCode__c,
                    // CampaignCode__c = sale.CampaignCode__c,
                    // CreatedBy__c = sale.CreatedBy__c,
                    // SalesCompany__c = sale.SalesCompany__c,
                    // Comune_Fornitura__c = inputText
                // ));
            }
            
        }
    }
}
