/**
 * @description       : Controller for HDT_LCP_ReportNavigator aura component
 * @author            : gabriele.rota@webresults.it
 * @group             : WR
 * @last modified on  : 2021-09-07
 * @last modified by  : gabriele.rota@webresults.it
**/
public with sharing class HDT_LC_ReportNavigatorController {
    
    /**
    * @description Get report id from API name
    * @author gabriele.rota@webresults.it | 2021-09-07 
    * @param reportName 
    * @return Id 
    **/
    @AuraEnabled
    public static Id getReportId(String reportName){
        try {
            return [SELECT Id FROM Report WHERE DeveloperName=:reportName WITH SECURITY_ENFORCED LIMIT 1].Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
