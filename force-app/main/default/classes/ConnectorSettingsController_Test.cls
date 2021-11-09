@isTest

private class ConnectorSettingsController_Test {
    static testMethod void unitTest1() {
        Test.startTest();

        PageReference pageRef = Page.ConnectorSettings;
        Test.setCurrentPage(pageRef);    
        ConnectorSettingsController controller = new ConnectorSettingsController();
        Connector_Settings__c cs = controller.connectorSettings;
        List<SelectOption> integrationTypeOptions = controller.getIntegrationTypeOptions();
        List<SelectOption> SFExperienceOptions = controller.getSFExperienceOptions();
        List<SelectOption> logLevelOptions = controller.getLogLevelOptions();
        List<SelectOption> protocolOptions = controller.getProtocolOptions();
        List<SelectOption> environmentOptions = controller.getEnvironmentOptions();
        List<SelectOption> presenceStatus = controller.getPresenceStatusOptions();
        controller.saveSettings();

        controller.GEN_INTEGRATION_TYPE = 'WDE';
        controller.GEN_SF_EXPERIENCE = 'Lightning';
        controller.GEN_LOG_LEVEL = 'Debug';
        controller.GEN_EXTERNAL_ROUTING = true;
        controller.WDE_PROTOCOL = 'HTTPS';
        controller.WDE_HOST = 'localhost';
        controller.WDE_PORT = 4040;
        controller.WDE_IXN_MGR_URL = 'test.test.it';
        controller.PEF_GC_ENVIRONMENT = 'mypurecloud.com';
        controller.PEF_NOT_READY_ID = '';
        controller.PEF_ON_QUEUE_ID = '';
        controller.WWE_URL = 'test.it';
        controller.ER_OMNI_READY_ID = '123';
        controller.ER_CAPACITY_THRESHOLD = 0;
        controller.ER_OMNI_BUSY_ID = '123';
        controller.ER_OMNI_NOT_READY_ID = '321';
        controller.ER_OMNI_NO_SYNC_ID = '456';
        controller.saveSettings();

        Test.stopTest();
    }
    static testMethod void unitTest2() {
        Test.startTest();

        PageReference pageRef = Page.ConnectorSettings;
        Test.setCurrentPage(pageRef);    
        ConnectorSettingsController controller = new ConnectorSettingsController();

        controller.GEN_INTEGRATION_TYPE = 'WDE';
        controller.GEN_SF_EXPERIENCE = 'Lightning';
        controller.GEN_LOG_LEVEL = 'Debug';
        controller.GEN_EXTERNAL_ROUTING = true;
        controller.WDE_PROTOCOL = 'HTTPS';
        controller.WDE_HOST = 'localhost';
        controller.WDE_PORT = 4040;
        controller.WDE_IXN_MGR_URL = 'test.test.it';
        controller.PEF_GC_ENVIRONMENT = 'mypurecloud.com';
        controller.PEF_NOT_READY_ID = '';
        controller.PEF_ON_QUEUE_ID = '';
        controller.WWE_URL = 'test.it';
        controller.ER_OMNI_READY_ID = '123';
        controller.ER_CAPACITY_THRESHOLD = 0;
        controller.ER_OMNI_BUSY_ID = '123';
        controller.ER_OMNI_READY_ID = '321';
        controller.saveSettings();

        Test.stopTest();
    }
}