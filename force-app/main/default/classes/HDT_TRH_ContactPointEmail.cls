public with sharing class HDT_TRH_ContactPointEmail extends HDT_TRH_TriggerHandler {
    public override void beforeInsert(){
        System.debug('HDT_TRH_ContactPointConsent.insert');
    }

    protected override void beforeUpdate() {
        System.debug('HDT_TRH_ContactPointConsent.beforeUpdate');


    }

    public override void afterUpdate(){
        System.debug('HDT_TRH_ContactPointConsent.afterUpdate');

    }
    public override void afterInsert(){
        System.debug('HDT_TRH_ContactPointConsent.afterInsert');

    }


    
}
