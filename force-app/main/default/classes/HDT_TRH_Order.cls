/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 17/09/2021
 * @description HDT_TRH_Order Test Class
 * @history Keltin Mesonjesi – 17/09/2021 – Created Class
 */
public inherited sharing class HDT_TRH_Order extends HDT_TRH_TriggerHandler {

    //public override void beforeInsert(){}
 	//public override void beforeDelete(){}
 	//public override void afterDelete(){}
  //	public override void afterUndelete(){}
    	
    public override void beforeUpdate(){
        //Checks Phase Transition


        HDT_UTL_OrderProcess.updatePhase(trigger.new,trigger.old);

        /**@frpanico 15/12/2021 
         * DM Voltura - Aggiunto metodo 
         * gestione del ritorno da Docusign
         * Voltura con Switch - EE
        */
        HDT_UTL_OrderProcess.updatePhaseForFirm(trigger.new);
        Boolean skipForCancellation = HDT_UTL_OrderProcess.manageCancellationProcess(trigger.new,Trigger.oldMap);
        //EVERIS: Gestione Scarti SAP
        Boolean skipForGestioneScarti = HDT_UTL_Scarti.manageSapDiscard(Trigger.new, Trigger.oldMap);
	    if(!skipForCancellation && !skipForGestioneScarti){
            ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration'))
            .beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
        }
        
        //Checks Mandatory Activity
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});
        
        HDT_UTL_OrderProcess.salesProcessManagementBefore(trigger.new,trigger.old); 

        HDT_UTL_OrderProcess.updateServiceRequest(trigger.new, trigger.old);
        
       // HDT_UTL_OrderProcess.updatePhaseForFirm(trigger.new);

        HDT_UTL_Dependencies.processSequentializationBefore(Trigger.newMap,Trigger.oldMap,'Order'); 
        
        //HDT_UTL_OrderProcess.updateServicePointToComplete(trigger.old,trigger.new);
        //HDT_UTL_OrderProcess.updatePhaseForFirm(trigger.new);

        HDT_UTL_PclickBulkActionVas.checkVasContractAlignmentBeforeUpdate(trigger.new);
    }
    public override void afterUpdate() {
        HDT_UTL_OrderProcess.overturningFields((List<Order>)Trigger.old,(List<Order>)Trigger.new); // HRDTR-00_HRAWRM-638
        //Execute creation Activities 
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkSaveActivityContext(null);
        
        //Handles callout (update only)
        ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils'))
                .bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old});

        HDT_UTL_OrderProcess.checkSatisfationIndex(trigger.newMap, trigger.oldMap);

        // HDT_UTL_OrderProcess.salesProcessManagementAfter(trigger.new,trigger.old);

        //Handle 'Plico validato Firmato' case for Order Dossier
        HDT_UTL_OrderProcess.orderPhaseManagementAfterUpdate(trigger.new,trigger.old);

        // START @Picchiri HRADTR-77 Calcolo Date 01.06.21
        HDT_UTL_OrderProcess.orderCalulateDateUpdate(trigger.new,trigger.old);
        // END @Picchiri HRADTR-77 Calcolo Date 01.06.21

        // START @Picchiri Credit Check 04.06.21
        HDT_UTL_OrderProcess.creditCheckManager2(trigger.newMap,trigger.oldMap);
        // END @Picchiri Credit Check 04.06.21

        HDT_UTL_PrClickDoubleTransaction.enqueueDoublePhaseTransactions();

        HDT_UTL_OrderTriggerVas.cancelLinkedVasOrders(Trigger.newMap, Trigger.oldMap);
        
    }

    //Andrei Necsulescu - 02/07/2021: Commented as it created an exception when importing more than a certain number of Orders at a time.
    /*
    public override void afterInsert(){   
        wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt ObjectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');

        for(Order o : (Order[])trigger.New){
            //call the check for the candidate SObject
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
                (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult) ObjectCompatibility.check(new Map<String,Object>{'sObject' => o});

            if(result.incompatibilities.size() > 0) {
                String msg = (result.incompatibilities.size() == 1) ? 'Incompatibility found on Order: ' : 'Incompatibilities found on Order: ';
                o.addError(msg + getIncompatibilityMessage((Order[])result.incompatibilities));
            }
        }
    }
    private static String getIncompatibilityMessage(Order[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        for(Order o : incomps){
            conflictIds.add(o.Id);
        }

        Set<String> conflicts = new Set<String>();
        for(Order o : [SELECT Id, OrderNumber, RecordType.Name FROM Order WHERE Id IN :conflictIds]) {
            conflicts.add(o.OrderNumber + ' (' + o.RecordType.Name + ')');
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }
    */
}