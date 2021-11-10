public without sharing class ConnectorSettingsController {
    
    public Connector_Settings__c connectorSettings;

    public ConnectorSettingsController() {
        
        this.loadValues();
    }

    public void loadValues(){
        
        connectorSettings = Connector_Settings__c.getOrgDefaults();
        this.GEN_INTEGRATION_TYPE = connectorSettings.GEN_INTEGRATION_TYPE__c;
        this.GEN_SF_EXPERIENCE = connectorSettings.GEN_SF_EXPERIENCE__c;
        this.GEN_LOG_LEVEL = connectorSettings.GEN_LOG_LEVEL__c;
        this.GEN_EXTERNAL_ROUTING = connectorSettings.GEN_EXTERNAL_ROUTING__c;
        this.WDE_PROTOCOL = connectorSettings.WDE_PROTOCOLTYPE__c;
        this.WDE_HOST = connectorSettings.WDE_HOSTNAME__c;
        this.WDE_PORT = Integer.valueOf(connectorSettings.WDE_PORTNUMBER__c);
        this.WDE_IXN_MGR_URL = connectorSettings.WDE_IXN_MGR_URL__c;
        this.PEF_GC_ENVIRONMENT = connectorSettings.PEF_GC_ENVIRONMENT__c;
        this.PEF_NOT_READY_ID = connectorSettings.PEF_NOT_READY_ID__c;
        this.PEF_ON_QUEUE_ID = connectorSettings.PEF_ON_QUEUE_ID__c;
        this.WWE_URL = connectorSettings.WWE_URL__c;
        this.ER_OMNI_READY_ID= connectorSettings.ER_OMNI_READY_ID__c;
        this.ER_OMNI_NOT_READY_ID= connectorSettings.ER_OMNI_NOT_READY_ID__c;
        this.ER_OMNI_NO_SYNC_ID= connectorSettings.ER_OMNI_NO_SYNC_ID__c;
        this.ER_SYNC_WDE_TO_OMNI= connectorSettings.Setup_Done__c ? connectorSettings.ER_SYNC_WDE_TO_OMNI__c : true;
        this.ER_SYNC_OMNI_TO_WDE= connectorSettings.Setup_Done__c ? connectorSettings.ER_SYNC_OMNI_TO_WDE__c : true;
        this.ER_OMNI_BUSY_ID = connectorSettings.ER_OMNI_BUSY_ID__c;
        this.ER_WDE_BUSY_ID = connectorSettings.ER_WDE_BUSY_ID__c;
        
        this.ER_WDE_CHANNELS_TO_SYNC= connectorSettings.Setup_Done__c ? connectorSettings.ER_WDE_CHANNELS_TO_SYNC__c : 'workitem';
        this.PEF_HIDE_WEB_RTC_POP_UP_OPTION = connectorSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION__c;
        this.PEF_ENABLE_CALL_LOGS = connectorSettings.Setup_Done__c ? connectorSettings.PEF_ENABLE_CALL_LOGS__c : true;
        this.PEF_HIDE_CALL_LOG_SUBJECT = connectorSettings.PEF_HIDE_CALL_LOG_SUBJECT__c;
        this.PEF_HIDE_CALL_LOG_CONTACT = connectorSettings.PEF_HIDE_CALL_LOG_CONTACT__c;
        this.PEF_HIDE_CALL_LOG_RELATION = connectorSettings.PEF_HIDE_CALL_LOG_RELATION__c;
        this.PEF_DEDICATED_LOGIN_WINDOW = connectorSettings.PEF_DEDICATED_LOGIN_WINDOW__c;
        this.PEF_EMBED_WEB_RTC_BY_DEFAULT = connectorSettings.Setup_Done__c ? connectorSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT__c : true;
        this.PEF_ENABLE_TRANSFER_CONTEXT = connectorSettings.Setup_Done__c ? connectorSettings.PEF_ENABLE_TRANSFER_CONTEXT__c : true;
        this.PEF_EMBEDDED_INTERACTION_WINDOW = connectorSettings.Setup_Done__c ? connectorSettings.PEF_EMBEDDED_INTERACTION_WINDOW__c : true;
        this.PEF_ENABLE_CONFIGURABLE_CALLER_ID = connectorSettings.PEF_ENABLE_CONFIGURABLE_CALLER_ID__c;
        this.PEF_ENABLE_SERVER_SIDE_LOGGING = connectorSettings.PEF_ENABLE_SERVER_SIDE_LOGGING__c;
        this.PEF_ENABLE_CALL_HISTORY = connectorSettings.PEF_ENABLE_CALL_HISTORY__c;
        this.ER_ENABLE_SYNC_ON_OMNI_CAPACITY = connectorSettings.ER_ENABLE_SYNC_ON_OMNI_CAPACITY__c;
        this.ER_OMNI_BUSY_ON_VOICE_ESTABLISHED = connectorSettings.ER_OMNI_BUSY_ON_VOICE_ESTABLISHED__c;
        this.ER_CAPACITY_THRESHOLD = connectorSettings.ER_CAPACITY_THRESHOLD__c != null ? Integer.valueOf(connectorSettings.ER_CAPACITY_THRESHOLD__c) : 50;
        this.ER_SYNC_DIRECTION = connectorSettings.ER_SYNC_DIRECTION__c != null ? connectorSettings.ER_SYNC_DIRECTION__c : 'genesys';
    }

    public String GEN_INTEGRATION_TYPE {get;set;}
    public String GEN_SF_EXPERIENCE {get;set;}
    public String GEN_LOG_LEVEL {get;set;}
    public Boolean GEN_EXTERNAL_ROUTING {get;set;}
    public String WDE_PROTOCOL {get;set;}
    public String WDE_HOST {get;set;}
    public Integer WDE_PORT {get;set;}
    public String WDE_IXN_MGR_URL {get;set;}
    public String PEF_GC_ENVIRONMENT {get;set;}
    public String PEF_NOT_READY_ID {get;set;}
    public String PEF_ON_QUEUE_ID {get;set;}
    public String WWE_URL {get;set;}
    public String ER_OMNI_READY_ID {get;set;}
    public String ER_OMNI_NOT_READY_ID {get;set;}
    public String ER_OMNI_NO_SYNC_ID {get;set;} 
    public Boolean ER_SYNC_WDE_TO_OMNI {get;set;}
    public Boolean ER_SYNC_OMNI_TO_WDE {get;set;}
    public String ER_WDE_CHANNELS_TO_SYNC {get;set;}
    public Boolean PEF_HIDE_WEB_RTC_POP_UP_OPTION {get;set;}
    public Boolean PEF_ENABLE_CALL_LOGS {get;set;}
    public Boolean PEF_HIDE_CALL_LOG_SUBJECT {get;set;}
    public Boolean PEF_HIDE_CALL_LOG_CONTACT {get;set;}
    public Boolean PEF_HIDE_CALL_LOG_RELATION {get;set;}
    public Boolean PEF_DEDICATED_LOGIN_WINDOW {get;set;}
    public Boolean PEF_EMBED_WEB_RTC_BY_DEFAULT {get;set;}
    public Boolean PEF_ENABLE_TRANSFER_CONTEXT {get;set;}
    public Boolean PEF_EMBEDDED_INTERACTION_WINDOW {get;set;}
    public Boolean PEF_ENABLE_CONFIGURABLE_CALLER_ID {get;set;}
    public Boolean PEF_ENABLE_SERVER_SIDE_LOGGING {get;set;}
    public Boolean PEF_ENABLE_CALL_HISTORY {get;set;}
    public Boolean ER_ENABLE_SYNC_ON_OMNI_CAPACITY {get;set;}
    public Boolean ER_OMNI_BUSY_ON_VOICE_ESTABLISHED {get;set;}
    public String ER_OMNI_BUSY_ID {get;set;}
    public Integer ER_CAPACITY_THRESHOLD {get;set;}
    public String ER_WDE_BUSY_ID {get;set;}
    public String ER_SYNC_DIRECTION {get;set;}

    public List<SelectOption> getIntegrationTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('WDE','WDE'));
        options.add(new SelectOption('PURECLOUD','Genesys Cloud'));
        options.add(new SelectOption('WWE','WWE'));
        return options;
    }

    public List<SelectOption> getSFExperienceOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('Classic','Classic'));
        options.add(new SelectOption('Lightning','Lightning'));
        return options;
    }

    public List<SelectOption> getLogLevelOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('Debug','Debug'));
        options.add(new SelectOption('Error','Error'));
        return options;
    }

    public List<SelectOption> getProtocolOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        options.add(new SelectOption('http','http'));
        options.add(new SelectOption('https','https'));
        options.add(new SelectOption('ws','ws'));
        options.add(new SelectOption('wss','wss'));
        return options;
    }

    public List<SelectOption> getEnvironmentOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('mypurecloud.com','mypurecloud.com'));
        options.add(new SelectOption('mypurecloud.com.au','mypurecloud.com.au'));
        options.add(new SelectOption('mypurecloud.de','mypurecloud.de'));
        options.add(new SelectOption('mypurecloud.jp','.mypurecloud.jp'));
        options.add(new SelectOption('mypurecloud.ie','.mypurecloud.ie'));
        return options;
    }

    //Jayasekara Malan
    public List<SelectOption> getPresenceStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select-'));
        try{
            List<sObject> spsList =  Database.query('SELECT id, MasterLabel FROM ServicePresenceStatus');
            for(sObject sps : spsList){
                String id = (String)sps.get('id');
                String masterLable = (String)sps.get('MasterLabel');
                options.add(new SelectOption(id, masterLable));
            }               
        }catch(Exception e){
        System.debug('The salesforce omni feature is disabled');        
        }
        return options;
    }

    public pageReference saveSettings(){
        system.debug('***' + GEN_INTEGRATION_TYPE);
        Connector_Settings__c connectorSettings = Connector_Settings__c.getOrgDefaults();
        if(
            this.GEN_INTEGRATION_TYPE == null
            || this.GEN_SF_EXPERIENCE == null
            || this.GEN_LOG_LEVEL == null
            ||
                (
                    this.GEN_INTEGRATION_TYPE == 'WDE' &&
                        (
                            this.WDE_PROTOCOL == null
                            || String.isBlank(this.WDE_HOST)
                            || this.WDE_PORT <= 0
                            || String.isBlank(WDE_IXN_MGR_URL)
                        )
                )
            ||
                (
                    this.GEN_INTEGRATION_TYPE == 'WWE' && 
                        (
                            String.isBlank(WDE_IXN_MGR_URL)
                            || String.isBlank(this.WWE_URL)
                        )
                )
            || 
                (
                    this.GEN_EXTERNAL_ROUTING == true && 
                        (
                            String.isBlank(this.ER_OMNI_READY_ID)
                            || this.GEN_INTEGRATION_TYPE == 'WDE' &&
                                (
                                    String.isBlank(ER_WDE_CHANNELS_TO_SYNC)
                                )
                            ||  this.ER_ENABLE_SYNC_ON_OMNI_CAPACITY == true && 
                                (
                                    this.ER_CAPACITY_THRESHOLD <= 0
                                    || String.isBlank(this.ER_WDE_BUSY_ID)
                                )
                            || this.ER_OMNI_BUSY_ON_VOICE_ESTABLISHED == true && 
                                (
                                    String.isBlank(this.ER_OMNI_BUSY_ID)
                                )
                        )
                )
            ||
                (this.ER_SYNC_DIRECTION == null)    
        ){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Please fill all the required fields!');
            ApexPages.getMessages().clear();
            ApexPages.addMessage(errorMsg);
        }else if( this.GEN_EXTERNAL_ROUTING == true && 
			(this.ER_OMNI_READY_ID == this.ER_OMNI_NOT_READY_ID 
			|| this.ER_OMNI_READY_ID == this.ER_OMNI_NO_SYNC_ID 
			|| this.ER_OMNI_READY_ID == this.ER_OMNI_BUSY_ID
            || (this.ER_OMNI_BUSY_ID == this.ER_OMNI_NOT_READY_ID && !String.isBlank(this.ER_OMNI_NOT_READY_ID))
			|| (this.ER_OMNI_BUSY_ID == this.ER_OMNI_NO_SYNC_ID && !String.isBlank(this.ER_OMNI_NO_SYNC_ID))
            || (!String.isBlank(this.ER_OMNI_NOT_READY_ID) && !String.isBlank(this.ER_OMNI_NO_SYNC_ID) && this.ER_OMNI_NOT_READY_ID == this.ER_OMNI_NO_SYNC_ID))
        ){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'The states Ready, Not Ready, No Sync, and Busy must be different from each other!');
            ApexPages.getMessages().clear();
            ApexPages.addMessage(errorMsg);
        }else{
            try{
                connectorSettings.GEN_INTEGRATION_TYPE__c = this.GEN_INTEGRATION_TYPE;
                connectorSettings.GEN_SF_EXPERIENCE__c = this.GEN_SF_EXPERIENCE;
                connectorSettings.GEN_LOG_LEVEL__c = this.GEN_LOG_LEVEL;
                connectorSettings.GEN_EXTERNAL_ROUTING__c = this.GEN_EXTERNAL_ROUTING;
                connectorSettings.WDE_PROTOCOLTYPE__c = this.WDE_PROTOCOL;
                connectorSettings.WDE_HOSTNAME__c = this.WDE_HOST;
                connectorSettings.WDE_PORTNUMBER__c = this.WDE_PORT;
                connectorSettings.WDE_IXN_MGR_URL__c = this.WDE_IXN_MGR_URL;
                connectorSettings.PEF_GC_ENVIRONMENT__c = this.PEF_GC_ENVIRONMENT;
                connectorSettings.PEF_NOT_READY_ID__c = this.PEF_NOT_READY_ID;
                connectorSettings.PEF_ON_QUEUE_ID__c = this.PEF_ON_QUEUE_ID;
                connectorSettings.WWE_URL__c = this.WWE_URL;
                connectorSettings.ER_OMNI_READY_ID__c = this.ER_OMNI_READY_ID;
                connectorSettings.ER_OMNI_NOT_READY_ID__c = this.ER_OMNI_NOT_READY_ID;
                connectorSettings.ER_OMNI_NO_SYNC_ID__c = this.ER_OMNI_NO_SYNC_ID; 
                connectorSettings.ER_SYNC_WDE_TO_OMNI__c = this.ER_SYNC_WDE_TO_OMNI;
                connectorSettings.ER_SYNC_OMNI_TO_WDE__c = this.ER_SYNC_OMNI_TO_WDE;
                connectorSettings.ER_WDE_CHANNELS_TO_SYNC__c = this.ER_WDE_CHANNELS_TO_SYNC;
                connectorSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION__c = this.PEF_HIDE_WEB_RTC_POP_UP_OPTION;
                connectorSettings.PEF_ENABLE_CALL_LOGS__c = this.PEF_ENABLE_CALL_LOGS;
                connectorSettings.PEF_HIDE_CALL_LOG_SUBJECT__c = this.PEF_HIDE_CALL_LOG_SUBJECT;
                connectorSettings.PEF_HIDE_CALL_LOG_CONTACT__c = this.PEF_HIDE_CALL_LOG_CONTACT;
                connectorSettings.PEF_HIDE_CALL_LOG_RELATION__c = this.PEF_HIDE_CALL_LOG_RELATION;
                connectorSettings.PEF_DEDICATED_LOGIN_WINDOW__c = this.PEF_DEDICATED_LOGIN_WINDOW;
                connectorSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT__c = this.PEF_EMBED_WEB_RTC_BY_DEFAULT;
                connectorSettings.PEF_ENABLE_TRANSFER_CONTEXT__c = this.PEF_ENABLE_TRANSFER_CONTEXT;
                connectorSettings.PEF_EMBEDDED_INTERACTION_WINDOW__c = this.PEF_EMBEDDED_INTERACTION_WINDOW;
                connectorSettings.PEF_ENABLE_CONFIGURABLE_CALLER_ID__c = this.PEF_ENABLE_CONFIGURABLE_CALLER_ID;
                connectorSettings.PEF_ENABLE_SERVER_SIDE_LOGGING__c = this.PEF_ENABLE_SERVER_SIDE_LOGGING;
                connectorSettings.PEF_ENABLE_CALL_HISTORY__c = this.PEF_ENABLE_CALL_HISTORY;
                connectorSettings.ER_ENABLE_SYNC_ON_OMNI_CAPACITY__c = this.ER_ENABLE_SYNC_ON_OMNI_CAPACITY;
                connectorSettings.ER_OMNI_BUSY_ON_VOICE_ESTABLISHED__c = this.ER_OMNI_BUSY_ON_VOICE_ESTABLISHED;
                connectorSettings.ER_OMNI_BUSY_ID__c = this.ER_OMNI_BUSY_ID;
                connectorSettings.ER_CAPACITY_THRESHOLD__c = this.ER_CAPACITY_THRESHOLD;
                connectorSettings.ER_WDE_BUSY_ID__c = this.ER_WDE_BUSY_ID;
                connectorSettings.ER_SYNC_DIRECTION__c = this.ER_SYNC_DIRECTION;
                connectorSettings.ER_SYNC_WDE_TO_OMNI__c = this.ER_SYNC_DIRECTION == 'genesys' ? true : false;
                connectorSettings.ER_SYNC_OMNI_TO_WDE__c= this.ER_SYNC_DIRECTION == 'omni' ? true : false;
                connectorSettings.Setup_Done__c = true;
                
                upsert connectorSettings;
                ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, 'Saved');
                ApexPages.getMessages().clear();
                ApexPages.addMessage(successMsg);
            }catch(Exception e){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
                ApexPages.getMessages().clear();
                ApexPages.addMessage(errorMsg);
            }
        }
        return null;
    }
}