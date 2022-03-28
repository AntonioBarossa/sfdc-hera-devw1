import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
//import getRecord  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivity';
import getActivityOwner  from '@salesforce/apex/HDT_LC_AppointmentExtraSist.getActivityOwner';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Id';
import ATOA_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.isAtoA__c';
import FERMO_SYS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.isManualAppoitment__c';

const OBJECT_FIELDS =[
    ID_FIELD,
    FERMO_SYS_FIELD,
    ATOA_FIELD
];
/* const OBJECT_FIELDS =[
    'Id',
    'isManualAppoitment__c',
    'isAtoA__c'
] */
export default class HdtAppointmentStopSystem extends LightningElement {
  
    @api recordId;
    @track showSpinner=true;
    @track activity = {};

    @wire(getRecord, { recordId: '$recordId', fields: OBJECT_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message: message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            console.log('@@@@data wired method ');
            this.activity = data;
            

            let atoa = this.activity.fields.isAtoA__c.value;
            let fermo = this.activity.fields.isManualAppoitment__c.value;
            const fields = {};

            if (atoa == true && fermo == false){

                fields[ID_FIELD.fieldApiName] = this.activity.fields.Id.value;
                fields[FERMO_SYS_FIELD.fieldApiName] = true;
                fields[ATOA_FIELD.fieldApiName] = false;

                const recordInput = { fields };
                this.submitRecord(recordInput);
            }else if (atoa == false && fermo == true){

                fields[ID_FIELD.fieldApiName] = this.activity.fields.Id.value;
                fields[FERMO_SYS_FIELD.fieldApiName] = false;
                fields[ATOA_FIELD.fieldApiName] = true;

                const recordInput = { fields };
                this.submitRecord(recordInput);
            }
            console.log('@@@@fine data wired method');
            
        }
    }

    submitRecord(recordInput){
        getActivityOwner({activityId: this.recordId}).then(data => {
            if (data === true || data === 'true'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                        variant: 'error',
                    }),
                );
                this.closeQuickAction();    
            }else {
                updateRecord(recordInput).then(() => {
                    console.log('@@@@@SUCCESS');
                    window.location.reload();
                }).catch(error => {
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
                    this.closeQuickAction();
                });
            }
        }); 
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}