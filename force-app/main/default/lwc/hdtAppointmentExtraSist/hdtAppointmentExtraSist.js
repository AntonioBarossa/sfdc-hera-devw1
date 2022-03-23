import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getActivityOwner  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivityOwner';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Id';
import STATUS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c';
import ATOA_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.isAtoA__c';
import APP_EDIT_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.IsAppointmentToEdit__c';

import NOTE_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Note__c';
import APP_CODE_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.AppointmentCode__c';
import APP_COMP_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.AppointmentCompetence__c';
import CONF_SLOT_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.AppoitmentTimeSlotConfirmed__c';
import CONF_APP_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.AppointmentDate__c';

const OBJECT_FIELDS =[
    ID_FIELD,
    STATUS_FIELD,
    ATOA_FIELD,
    APP_EDIT_FIELD,
    APP_CODE_FIELD,
    APP_COMP_FIELD,
    CONF_SLOT_FIELD,
    CONF_APP_FIELD
];


export default class HdtAppointmentExtraSist extends LightningElement {
    @api recordId;
    @track showConfirmDialog= false; //show confirm after confirm appointment
    @track showAppointmentModal= false; //show Modal after Edit Appointment
    @track showSpinner=true;
    showAppointmentField = false;
    
    activity = {};
    labelName;
    confermaAppuntamento = true;
    showComponent=false;
    actualState;
    messageConfirmDialog = 'Una volta confermato l\'appuntamento non sarà possibile ritornare allo stato creata. Continuare?';
    isNotOwner;
    //campi record edit form
    slot;
    appCode;
    appointment;
    appComp;

    get showForm() {
        return !this.showConfirmDialog && !this.showSpinner && !this.showAppointmentModal && this.recordId;
    }

    get optionsComp(){
        return[
            {label : 'Vendita',value : 'Vendita'},
            {label : 'Distributore', value : 'Distributore'}
        ];
    }
    @wire(getRecord, { recordId: '$recordId', fields: OBJECT_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('@@@@error wired method');
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
            console.log('@@@@fine error wired method');
        } else if (data) {
            this.activity = data;
            console.log('@@@@data wired method ' + JSON.stringify(data));
            this.actualState = this.activity.fields.wrts_prcgvr__Status__c.value;
            if ((this.actualState === 'Appuntamento confermato' || this.actualState === 'Modifica confermata') && !this.activity.fields.IsAppointmentToEdit__c.value){
                console.log('@@@@ entro in if');
                this.labelName = 'Modifica Appuntamento';
                this.confermaAppuntamento = false;
            }else {
                this.setRecordFieldValue(
                    this.activity.fields.AppointmentDate__c.value,
                    this.activity.fields.AppoitmentTimeSlotConfirmed__c.value,
                    this.activity.fields.AppointmentCompetence__c.value,
                    this.activity.fields.AppointmentCode__c.value
                );
                console.log('@@@@ entro in else');
                this.labelName = 'Conferma Appuntamento';
                this.confermaAppuntamento = true;
            }
            if (this.activity.fields.AppointmentCompetence__c.value === 'Vendita'){
                this.showAppointmentField = true;
            }
            this.showSpinner= false; 
            console.log('@@@@fine data wired method');
        }
    }

    handleConfirmDialogClick(event){
        console.log('@@@@@handleConfirmDialogClick');
        this.showConfirmDialog = false;
        if (event.detail.status){
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.activity.fields.Id.value;
            fields[APP_EDIT_FIELD.fieldApiName] = false;
            fields[NOTE_FIELD.fieldApiName] = '';
            fields[APP_COMP_FIELD.fieldApiName] = this.appComp;
            fields[APP_CODE_FIELD.fieldApiName] = this.appCode;
            fields[CONF_SLOT_FIELD.fieldApiName] = this.slot;
            fields[CONF_APP_FIELD.fieldApiName] = this.appointment;
            if (!this.showAppointmentField){
                fields[STATUS_FIELD.fieldApiName] = 'Appuntamento di competenza Distributore';
            }else{
                fields[STATUS_FIELD.fieldApiName] = (this.actualState === 'Modifica appuntamento in corso')? 'Modifica confermata' : 'Appuntamento confermato';
            };
            


            const recordInput = { fields };
            this.submitRecord(recordInput);
        }
        console.log('@@@@@Fine handleConfirmDialogClick');
    }

    submitRecord(recordInput){
        this.showSpinner = true;
        console.log('@@@@@recordInput' + JSON.stringify(recordInput));
        updateRecord(recordInput).then(() => {
            console.log('@@@@@SUCCESS');
            this.showSpinner = false;
            if (!this.confermaAppuntamento){
                this.showAppointmentModal = true;
            }
            return refreshApex(this.activity);
        }).catch(error => {
            console.log('@@@@@ERROR' + JSON.stringify(error));
            console.log('@@@@@ERROR' + JSON.stringify(error.body));
            let message = '';
            if (error.body.output && error.body.output.errors){
                error.body.output.errors.forEach(item =>{
                    if (item.message){
                        message += item.message+' ';
                    }
                });
            }
            if (message.localeCompare('') === 0){
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: message,
                    variant: 'error'
                })
            );
            this.showSpinner = false;
        });
    }

    handleSubmit(event){
        event.preventDefault(); 
        if (this.confermaAppuntamento){
            getActivityOwner({activityId: this.recordId}).then(data => {
                this.isNotOwner = data;
                if (this.isNotOwner === 'true' || this.isNotOwner === true){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                            variant: 'error',
                        }),
                    );
                }else{
                    let appComp= this.template.querySelector("lightning-combobox[data-id='appCompInput']").value;
                    let slot = (this.showAppointmentField) ? this.template.querySelector("lightning-input[data-id='slotInput']").value : ''; 
                    let appointment = (this.showAppointmentField) ? this.template.querySelector("lightning-input[data-id='appointmentInput']").value : null;  
                    let appCode = (this.showAppointmentField) ? this.template.querySelector("lightning-input[data-id='appCodeInput']").value : ''; 
                    if (this.setRecordFieldValue(appointment,slot,appComp,appCode) && (this.notEmpty(appointment,slot,appComp,appCode))){
                        if (!this.showAppointmentField){
                            this.messageConfirmDialog = 'Attenzione! L\'attività verrà impostata in carico al distributore e non sarà più possibile modificarla. Continuare?';
                        }
                        this.showConfirmDialog = true;
                    }
                }
            });
            
        }else{
            console.log('@@@@@else');
            const fields = event.detail.fields;
            console.log('@@@@@else ' + ID_FIELD.fieldApiName);
            fields[ID_FIELD.fieldApiName] = this.activity.fields.Id.value;
            console.log('@@@@@else ' + APP_EDIT_FIELD.fieldApiName);
            fields[APP_EDIT_FIELD.fieldApiName] = true;
            console.log('@@@@@else');
            fields[STATUS_FIELD.fieldApiName] = 'Modifica appuntamento in corso';
            console.log('@@@@@else ' + STATUS_FIELD.fieldApiName);
            const recordInput = {fields};
            console.log('@@@@@recordInput ' + JSON.stringify(recordInput));
            this.submitRecord(recordInput); 
        }
    }

    checkSlot(slot){
        console.log('@@@@@dentro checkslot ' + slot);
        if (slot){
            return String(slot).match(
                /^([0-1][0-9]|[2][0-9])[:][0-5][0-9][/]([0-1][0-9]|[2][0-9])[:][0-5][0-9]$/
            );
        }else{
            return true;
        }   
    }

    setRecordFieldValue(_appointemnt,_slot,_appComp,_appCode){
        console.log('@@@@@dentro set field value');
        if (this.checkSlot(_slot)){
            console.log('@@@@@dentro set field value if');

            this.slot = _slot;
            this.appointment = _appointemnt;
            this.appComp=_appComp;
            this.appCode=_appCode;
            console.log('@@@@@dentro set field value con true');
            return true;
        }else{
            console.log('@@@@@dentro set field value else');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'La fascia appuntamento confermato deve essere nel seguente formato: hh:mm/hh:mm',
                    variant: 'error'
                })
            );
            console.log('@@@@@dentro set field value con false');
            return false;
        }
    }
    
    notEmpty(appointemnt, slot, competenza, codiceAppuntamento){
        console.log('@@@@@not Empty');
        let response = true;
        let message = 'Popolare i seguenti campi: ';
        if (!appointemnt){
            console.log('@@@@@not Empty appointent');
            message += 'Data Appuntamento Confermato; ';
            response = !this.showAppointmentField;
        }
        if (!slot){
            console.log('@@@@@not Empty slot');
            message += 'Fascia appuntamento confermato; ';
            response = !this.showAppointmentField;
        }
        if (!competenza){
            console.log('@@@@@not Empty competenza');
            message += 'Competenza Appuntamento; ';
            response = false;
        }
        if (!codiceAppuntamento){
            console.log('@@@@@not Empty cod app');
            message+= 'Codice Appuntamento; ';
            response = !this.showAppointmentField;
        }
        if (!response){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione!',
                    message: message.substring(0, message.length-2)+'.',
                    variant: 'error'
                })
            ); 
        }
        console.log('@@@@fuorni not empty');
        return response;
    }

    closeModal(event){
        console.log('@@@@closeModal');
        this.showAppointmentModal = false;
    }

    changeValue(event){
        console.log('@@@@change ' +event.detail.value);
        console.log('@@@@change ' +JSON.stringify(event.detail));
        this.showAppointmentField = (event.detail.value === 'Vendita');
    }
}