import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAccountAlerts from '@salesforce/apex/HDT_LC_AccountAlerts.getAccountAlerts';
import getAvailableRules from '@salesforce/apex/HDT_LC_AccountAlerts.getAvailableRulesFor';
import addAlertToAccount from '@salesforce/apex/HDT_LC_AccountAlerts.addAlertToAccount';
import ACCOUNT_CATEGORY from '@salesforce/schema/Account.Category__c';


const columns = [
    { label: 'Regola Alert', fieldName: 'AlertRule__c' },
    { label: 'Alert Attivo', fieldName: 'IsActive__c', type: 'boolean', editable : 'true'},
    { label: 'Email', fieldName: 'IsEmailChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SMS', fieldName: 'IsSmsChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Push', fieldName: 'IsPushChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SOL', fieldName: 'IsSolChannelActive__c', type: 'boolean', editable : 'true'},
];

export default class HdtAccountAlerts extends LightningElement {

    @api recordId;
    @track record;
    @track wireError;
    @track alertColumns;
    @track accountAlerts;
    @track menuItems = [];
    availableAlerts;
    accountCategory = '';

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_CATEGORY] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            this.wireError = undefined;
            this.accountCategory = this.record.fields.Category__c.value;
            this.getAvailableRules();
        } else if (error) {
            console.log('wire failed to fetch data: ' + error);
            this.wireError = error;
            this.record = undefined;
        }
    }

    get disableAlertMenu(){
        return this.menuItems.length === 0;
    }

    getAccountAlerts(){
        try{
            getAccountAlerts({
                accountId: this.recordId
                })
                .then(result => {
                    //console.log('getAccountAlerts result: ' + result);
                    this.accountAlerts = JSON.parse(result);
                    
                })
                .catch(error => {
                    console.log('failed to get account alerts, accountId: ' + this.recordId);
                });
        }catch(error){
                console.error(error);
        }
    }

    getAvailableRules(){
        try{
            getAvailableRules({
                accountCategory: this.accountCategory
                })
                .then(result => {
                    //console.log('result: ' + result);
                    this.availableAlerts = JSON.parse(result);
                    this.updateAlertMenu();
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error));
                });
        }catch(error){
                console.error(error);
        }
    }

    refreshAccountAlertsAndMenu(){
        try{
            getAccountAlerts({
                accountId: this.recordId
                })
                .then(result => {
                    //console.log('getAccountAlerts result: ' + result);
                    this.accountAlerts = JSON.parse(result);
                    this.updateAlertMenu();
                    
                })
                .catch(error => {
                    console.log('failed to get account alerts, accountId: ' + this.recordId);
                });
        }catch(error){
                console.error(error);
        }
    }

    connectedCallback() {
        console.log('account id: ' + this.recordId);
        this.alertColumns = columns;
        this.getAccountAlerts();
    }

    updateAlertMenu() {
        let menuItems = [];
        let activeRules = new Set();
        this.accountAlerts.forEach(alert => {
            activeRules.add(alert.AlertRule__c);
        });

        this.availableAlerts.forEach(alert => {
            //console.log('alert: ' + JSON.stringify(alert));

            if (!activeRules.has(alert.AlertRule__c)) {
                menuItems.push(
                    {
                        id : alert.Id,
                        label : alert.AlertRule__c,
                        value : alert
                    }
                );
            }
        });

        this.menuItems = menuItems;
        console.log('updateAlertMenu new menuItems: ' + this.menuItems);
    }

    addAlert(event) {

        try{
            addAlertToAccount({
                alertRule: JSON.stringify(event.detail.value),
                accountId: this.recordId
                })
                .then(result => {
                    console.log('addAlertToAccount result: ' + result);
                    this.refreshAccountAlertsAndMenu();
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error));
                });
        }catch(error){
                console.error(error);
        }
    }

}