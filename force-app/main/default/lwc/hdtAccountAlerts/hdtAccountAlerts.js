import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactDetails from '@salesforce/apex/HDT_LC_AccountAlerts.getContactDetails';
import getAccountAlerts from '@salesforce/apex/HDT_LC_AccountAlerts.getAccountAlerts';
import getAvailableRules from '@salesforce/apex/HDT_LC_AccountAlerts.getAvailableRulesFor';
import addAlertToAccount from '@salesforce/apex/HDT_LC_AccountAlerts.addAlertToAccount';
import updateAlert from '@salesforce/apex/HDT_LC_AccountAlerts.updateAlert';
import ACCOUNT_CATEGORY from '@salesforce/schema/Account.Category__c';



const columns = [
    { label: 'Regola Alert', fieldName: 'AlertRule__c' },
    { label: 'Stato Alert', fieldName: 'AlertState__c' },
    { label: 'Flag Attivazione', fieldName: 'IsActive__c', type: 'boolean', editable : 'true'},
    { label: 'Email', fieldName: 'IsEmailChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SMS', fieldName: 'IsSmsChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Push', fieldName: 'IsPushChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'SOL App', fieldName: 'IsSolChannelActive__c', type: 'boolean', editable : 'true'},
    { label: 'Contatto SOL', fieldName: 'ContactName', type: 'text'}
];

export default class HdtAccountAlerts extends LightningElement {

    @api recordId;
    @track record;
    @track wireError;
    @track alertColumns;
    @track accountAlerts = [];    // Gli alert creati sul Cliente
    @track menuItems = [];
    @track availableAlerts = [];  // L'elenco di alert abilitabili per il Cliente (in base alla sua categoria)
    @track noAlertsMessage = '';
    @track noAlertRulesMessage = '';
    @track showContactsModal = false;
    accountCategory = '';
    draftValues = [];
    selectedAlert = null;
    showSolContacts = true;
    selectedContactId;

    @wire(getContactDetails,{'accountId':'$recordId'})
    contactDetails;

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

    get canActivateAlerts(){
        return this.availableAlerts.length > 0;
    }

    get disableContactsModal(){
        return this.selectedAlert === null;
    }

    handleRowSelection(event){
        this.selectedAlert = event.detail.selectedRows;
    }

    handleRecordSelection(event){
        this.selectedContactId = event.detail.selectedRows[0].Id;
    }

    showModal(){
        this.showContactsModal = true;
    }

    hideModal(){
        this.selectedAlert = null;
        this.showContactsModal = false;
    }

    setErrorMessages(){
        this.noAlertsMessage = 'Nessun Alert configurato per il Cliente.';
        this.noAlertRulesMessage = 'Nessun Alert configurabile per questa categoria di cliente.';
    }

    getAvailableRules(){
        try{
            getAvailableRules({
                accountCategory: this.accountCategory,
                accountId: this.recordId
                })
                .then(result => {
                    //console.log('result: ' + result);
                    this.availableAlerts = JSON.parse(result);
                    this.refreshAccountAlertsAndMenu();
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
                    console.log('getAccountAlerts result: ' + result);
                    console.log('email: ' + this.contactDetails.data.email);
                    console.log('mobilePhone: ' + this.contactDetails.data.mobilePhone);

                    let parsedResult = JSON.parse(result);
                    // Convertiamo il json per raggiungere il campo Contact__r.Name
                    this.accountAlerts = parsedResult.map(record => {
                        if (record.Contact__r !== undefined) {
                            return Object.assign({'ContactName': record.Contact__r.Name }, record);
                        } else {
                            return Object.assign({'ContactName': '' }, record);
                        }
                    });

                    // getAvailableRules chiama refreshAccountAlertsAndMenu, quindi qui siamo sicuri di poter chiamare updateAlertMenu.
                    this.updateAlertMenu();
                    // Settiamo gli error messages solo adesso per evitare che si vedano sempre e poi scompaiano dopo aver popolato gli array con gli alert.
                    this.setErrorMessages();
                })
                .catch(error => {
                    console.log('error: ' + error);
                    console.log('failed to get account alerts, accountId: ' + this.recordId);
                });
        }catch(error){
                console.error(error);
        }
    }

    connectedCallback() {
        console.log('account id: ' + this.recordId);
        this.alertColumns = columns;
    }

    // Aggiorna this.menuItems con gli alert che il cliente non ha ancora mai abilitato.
    // Richiede che this.accountAlerts e this.availableAlerts siano entrambi popolati.
    updateAlertMenu() {
        let menuItems = [];
        let activeRules = new Set();
        this.accountAlerts.forEach(alert => {
            activeRules.add(alert.AlertRule__c);
        });

        this.availableAlerts.forEach(alert => {
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
        for (const channel of channels) {
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
                this.draftValues = [];
                return;
            }
        }

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
            this.draftValues = [];
            return;
        }

        // TODO: verificare anche se il cliente ha un contattoSol per poter ricevere l'alert?
        if (newAlert['IsEmailChannelActive__c'] === true && this.contactDetails.data.email === undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Modifica Alert non valida',
                    message: 'Il cliente non ha una Email per poter attivare questo Alert.',
                    variant: 'error'
                })
            );
            this.draftValues = [];
            return;
        }

        if (newAlert['IsSmsChannelActive__c'] === true && this.contactDetails.data.mobilePhone === undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Modifica Alert non valida',
                    message: 'Il cliente non ha una numero di cellulare per poter attivare questo Alert.',
                    variant: 'error'
                })
            );
            this.draftValues = [];
            return;
        }

        updateAlert({
            alert: JSON.stringify(newAlert)
            })
            .then(result => {
                console.log('updateAlert result: ' + result);
                let toastMsg = 'Alert aggiornato';
                if ('IsActive__c' in draftAlert) {
                    toastMsg = draftAlert['IsActive__c'] === true ? 'Alert attivato. Case di Modifica Alert creato.' : 'Alert disattivato. Case di Modifica Alert creato.';
                }
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: toastMsg,
                        variant: 'success'
                    })
                );
                this.refreshAccountAlertsAndMenu();
            })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            });
    }

    updateAlertContact(){
        console.log('selected sol contact: ' + this.selectedContactId);
        if (this.selectedContactId === undefined) {
            return;
        }

        const alertId = this.selectedAlert[0].Id;
        let oldAlert = this.getAccountAlertById(alertId);

        let newAlert = JSON.parse(JSON.stringify(oldAlert)); // deep copy
        newAlert['Contact__c'] = this.selectedContactId;

        updateAlert({
            alert: JSON.stringify(newAlert)
            })
            .then(result => {
                console.log('updateAlert result: ' + result);
                let toastMsg = 'Contatto SOL aggiornato per l\'Alert.';
                this.draftValues = [];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: toastMsg,
                        variant: 'success'
                    })
                );
                this.hideModal();
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