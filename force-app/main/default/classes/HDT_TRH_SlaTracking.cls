@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing  class HDT_TRH_SlaTracking extends HDT_TRH_TriggerHandler {

    public override void beforeUpdate(){
        HDT_UTL_SlaTracking.calculateSlaRealValue((SlaTracking__c[])Trigger.New);
    }

    public override void beforeInsert(){
        HDT_UTL_SlaTracking.calculateSlaForecastValue((SlaTracking__c[])Trigger.New);
    }

}