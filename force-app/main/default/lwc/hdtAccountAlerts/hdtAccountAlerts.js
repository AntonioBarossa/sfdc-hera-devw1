import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAlerts from '@salesforce/apex/HDT_LC_AccountAlerts.getAccountAlerts';
import getAvailableRules from '@salesforce/apex/HDT_LC_AccountAlerts.getAvailableRulesFor';
import addAlertToAccount from '@salesforce/apex/HDT_LC_AccountAlerts.addAlertToAccount';
import updateAlert from '@salesforce/apex/HDT_LC_AccountAlerts.updateAlert';
import ACCOUNT_CATEGORY from '@salesforce/schema/Account.Category__c';



const columns = [
    { label: 'Regola Alert', fieldName: 'AlertRule__c' },
    { label: 'Alert Attivo', fieldName: 'IsActive__c', type: 'boolean', editable : 'true'},
    { label: 'Canale Email', fieldName: 'IsEmailChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Canale SMS', fieldName: 'IsSmsChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Canale Push', fieldName: 'IsPushChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Canale SOL', fieldName: 'IsSolChannelActive__c', type: 'boolean', editable : 'true'},
];

export default class HdtAccountAlerts extends LightningElement {

    @api recordId;
    @track record;
    @track wireError;
    @track alertColumns;
    @track accountAlerts = [];
    @track menuItems = [];
    availableAlerts;
    accountCategory = '';
    draftValues = [];

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

    get hasAlerts(){
        return this.accountAlerts.length > 0;
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

    handleSave(event) {
        //this.saveDraftValues = event.detail.draftValues;
        console.log(event.detail.draftValues);
        let draftAlert = event.detail.draftValues[0];
        let oldAlert = this.getAccountAlertById(event.detail.draftValues[0].Id);

        // Verifica se l'operatore sta provando ad abilitare un canale che è disabilitato al livello di regola alert.
        let channels = ['Email', 'Sms', 'Push', 'Sol'];
        channels.forEach(channel => {
            let activeKey = `Is${channel}ChannelActive__c`;
            let allowedKey = `Is${channel}ChannelAllowed__c`;

            if (activeKey in draftAlert && oldAlert[allowedKey] === false) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Modifica Alert non valida',
                        message: 'Il gruppo regola <' + oldAlert['AlertRule__c'] + '> non permette l\'abilitazione di questo canale.',
                        variant: 'error'
                    })
                );
            }
        });

        let newAlert = JSON.parse(JSON.stringify(oldAlert)); // deep copy
        Object.keys(draftAlert).forEach(key => {
            newAlert[key] = draftAlert[key];
        });

        if (newAlert['IsActive__c'] === true &&
            newAlert['IsEmailChannelActive__c'] === false &&
            newAlert['IsSmsChannelActive__c'] === false &&
            newAlert['IsPushChannelActive__c'] === false &&
            newAlert['IsSolChannelActive__c'] === false &&
            newAlert['IsSolChannelActive__c'] === false) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Modifica Alert non valida',
                    message: 'Per attivare un Alert è necessario abilitare almeno un canale di comunicazione.',
                    variant: 'error'
                })
            );
        }

        // TODO: verificare anche se il cliente ha cellulare/mail/contattoSol per poter ricevere l'alert?

        updateAlert({
            alert: JSON.stringify(newAlert)
            })
            .then(result => {
                console.log('updateAlert result: ' + result);
                this.draftValues = []; // per nascondere i pulsanti Salva/Cancella
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Alert aggiornato', // TODO: avvisare che il case è stato innescato.
                        variant: 'success'
                    })
                );
                this.refreshAccountAlertsAndMenu();
            })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            });
    }

    getAccountAlertById(alertId){
        let filteredAccountAlerts = this.accountAlerts.filter(alert => alert['Id'] === alertId);
        return filteredAccountAlerts[0];
    }

}