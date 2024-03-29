/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 19/05/2021
* @description HDT_UTL_CommunicationLog.cls
* @history Lorenzo – 19/05/2021 – created class
*/
public class HDT_UTL_CommunicationLog {

    public CommunicationLog__c instanceCommunicationLog(String cluster,String process,string phase,string status,string motivazioneCausale,String orderId,String caseid,String contactid,String accountId,String company,String companyOwner){
        
        CommunicationLog__c comm = new CommunicationLog__c();
        comm.Cluster__c= cluster;
        //09/09/2021 gabriele.rota@webresults.it - Added default value as Processo__c is required
        comm.Processo__c = String.isBlank(process)?'Default':process;
        comm.Fase__c = phase;
        comm.Stato__c = status;
        comm.Causale__c = motivazioneCausale;
        if(caseid != null && caseId != ''){
            comm.CaseID__c = caseid;
        }
        if(orderId != null && orderId != ''){
            comm.OrderID__c = orderId;
        }
        if(contactid != null && contactid != ''){
           comm.ContactID__c= contactid;
        }
        if(accountId != null && accountId != ''){
            comm.AccountID__c= accountId;
        }
        comm.CompanyOwner__c = String.isNotBlank(companyOwner)?companyOwner:'HERA COMM';
        comm.Company__c = company;
        return comm;
    }   
}