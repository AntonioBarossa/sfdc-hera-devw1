@RestResource(urlMapping='/CertifiedEmailInboundService/*')
global with sharing class HDT_WS_CertifiedEmail {
    
    @HttpGet
    global static List<Task> doGet() {

        HDT_QR_Task queryHandler = new HDT_QR_Task();

        return queryHandler.getCertifiedEmails();
    }
}