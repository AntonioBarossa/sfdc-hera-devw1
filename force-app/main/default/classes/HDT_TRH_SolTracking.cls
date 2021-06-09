public with sharing class HDT_TRH_SolTracking extends HDT_TRH_TriggerHandler {
    
    protected override void beforeInsert() {
        replaceUserTags();
        HDT_UTL_CompanyOwner.feedCompanOwner(trigger.new);
    }

    /**
     * Sostituisce gli UserTag presenti nel testo.
     * Marketing Cloud inserisce le stringhe "UserTagN" senza nessun carattere speciale (parentesi o altro).
     */
    private void replaceUserTags() {

        for (SolTracking__c sol : (List<SolTracking__c>) Trigger.new) {
            if (sol.Text__c != null && sol.Text__c.contains('UserTag')) {
                String userTag1 = sol.UserTag1__c != null ? sol.UserTag1__c : '';
                String userTag2 = sol.UserTag2__c != null ? sol.UserTag2__c : '';
                String userTag3 = sol.UserTag3__c != null ? sol.UserTag3__c : '';
                String userTag4 = sol.UserTag4__c != null ? sol.UserTag4__c : '';
                String userTag5 = sol.UserTag5__c != null ? sol.UserTag5__c : '';

                String replacedText = sol.Text__c.replace('UserTag1', userTag1);
                replacedText = replacedText.replace('UserTag2', userTag2);
                replacedText = replacedText.replace('UserTag3', userTag3);
                replacedText = replacedText.replace('UserTag4', userTag4);
                replacedText = replacedText.replace('UserTag5', userTag5);

                sol.Text__c = replacedText;
            }
        }
    }

}
