/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 17/09/2021
 * @description HDT_TRH_Order Test Class
 * @history Keltin Mesonjesi – 17/09/2021 – Created Class
 */
public inherited sharing class HDT_TRH_Order extends HDT_TRH_TriggerHandler {
    
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public override void beforeUpdate(){

        system.debug(LoggingLevel.DEBUG,'Inizio beforeUpdate - Query utilizzate: '+Limits.getQueries()+'/'+Limits.getLimitQueries());
        if (!HDT_UTL_OrderProcess.transitorySiebelManagement(Trigger.new, Trigger.oldMap)){
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
                ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration')).beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
            }
            //Checks Mandatory Activity
            ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils')).bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});
            
            HDT_UTL_OrderProcess.salesProcessManagementBefore(trigger.new,trigger.old);
            HDT_UTL_OrderProcess.recalculateOrderDateAfterKo(trigger.new,trigger.old);
            HDT_UTL_OrderProcess.updateServiceRequest(trigger.new, trigger.old);
            HDT_UTL_OrderProcess.checkCreditProcessStatus(Trigger.new, Trigger.oldMap);

            HDT_UTL_Dependencies.processSequentializationBefore(Trigger.newMap,Trigger.oldMap,'Order');
            HDT_UTL_PclickBulkActionVas.checkVasContractAlignmentBeforeUpdate(trigger.new);

        }
        system.debug(LoggingLevel.DEBUG,'Fine beforeUpdate - Query utilizzate: '+Limits.getQueries()+'/'+Limits.getLimitQueries());

    }
    
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public override void afterUpdate() {

        system.debug(LoggingLevel.DEBUG,'Inizio afterUpdate - Query utilizzate: '+Limits.getQueries()+'/'+Limits.getLimitQueries());

        HDT_UTL_OrderProcess.overturningFields((List<Order>)Trigger.old,(List<Order>)Trigger.new);
        //Execute creation Activities 
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils')).bulkSaveActivityContext(null);
        //Handles callout (update only)
        ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils')).bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old});

        HDT_UTL_OrderProcess.checkSatisfationIndex(trigger.newMap, trigger.oldMap);
        HDT_UTL_OrderProcess.orderPhaseManagementAfterUpdate(trigger.new,trigger.old);
        //HDT_UTL_OrderProcess.orderCalulateDateUpdate(trigger.new,trigger.old);
        HDT_UTL_OrderProcess.calculateOrderDate(trigger.new,trigger.old);
        HDT_UTL_OrderProcess.creditCheckManager2(trigger.newMap,trigger.oldMap);
        HDT_UTL_PrClickDoubleTransaction.enqueueDoublePhaseTransactions();
        HDT_UTL_OrderTriggerVas.cancelLinkedVasOrders(Trigger.newMap, Trigger.oldMap);     
        
        HDT_SRV_VoltureChangeManager vltMgr = new HDT_SRV_VoltureChangeManager();
        vltMgr.orderPrecheckOk(Trigger.new);
        system.debug(LoggingLevel.DEBUG,'Fine afterUpdate - Query utilizzate: '+Limits.getQueries()+'/'+Limits.getLimitQueries());
        
    }
}