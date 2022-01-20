import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivity from '@salesforce/apex/HDT_LC_AppointmentAgenda.getActivity';
import getCommunityBaseUrl from '@salesforce/apex/HDT_LC_AppointmentAgenda.getCommunityBaseUrl';
import getEncryptedId from '@salesforce/apex/HDT_LC_AppointmentAgenda.getEncryptedId';
import SMS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Mobile__c';
import EMAIL_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Email__c';
import ID_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.Id';
import STATUS_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c';
import CRIPTO_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.CustomRecordId__c';
import URL_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.URL__c';
import SELF_FIELD from '@salesforce/schema/wrts_prcgvr__Activity__c.isSelfAppointment__c';

const SEND_OPTION = [{ label: 'SMS', value: 'sms' },{ label: 'EMAIL', value: 'email' }];
const OBJECT_FIELDS =[
    'wrts_prcgvr__Status__c',
    'Email__c',
    'Mobile__c',
    'Contact__c',
    'Contact__r.Email',
    'Contact__r.MobilePhone',
    'CustomRecordId__c',
    'URL__c'
];

export default class HdtAppointmentSelf extends LightningElement {
    recordId;
    @api activityid;
    showSpinner = false;
    options = SEND_OPTION;
    @track value;
    @track nameField = '';
    showForm = false;
    disabledRadio = true;
    activity = {};
    default = {'email' : '','mobile':''};
    communityBasePath;

    @wire(getActivity,{activityId : '$recordId',fields : '$fieldsToRetrieve'})
    wireRecord({error,data}){
        if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
        if (data){
            this.wiredActivity = data;
            this.activity = JSON.parse(data);
            let stato = this.activity.wrts_prcgvr__Status__c;
            if (stato && stato.localeCompare('Creata') === 0 ){
                if (this.activity.Email__c || this.activity.Mobile__c){
                    this.default.email = this.activity.Email__c;
                    this.default.mobile = this.activity.Mobile__c;
                }else if (this.activity.Contact__c){
                    this.default.email = this.activity.Contact__r.Email;
                    this.default.mobile = this.activity.Contact__r.MobilePhone;
                }
                this.disabledRadio = false;
            }
            
        }
    }

    connectedCallback(){
        this.fieldsToRetrieve = OBJECT_FIELDS;
        this.recordId = this.activityid;
        getCommunityBaseUrl()
        .then(result => {
            this.communityBasePath = result; 
        })
    }

    get isEmail(){
        return this.value === "email";
    }

    get isSms(){
        return this.value === "sms";
    }

    get emailDefault(){
        return this.default.email;
    }

    get mobileDefault(){
        return this.default.mobile;
    }

    get objectApiName(){
        return 'wrts_prcgvr__Activity__c';
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        let keysList = Object.keys(fields);
        let updateRecord = false;
        //Aggiungere logica validazione campo.
        let isValid = false;
        if (keysList[0].localeCompare(EMAIL_FIELD.fieldApiName) === 0){
            fields[SMS_FIELD.fieldApiName] = '';
            updateRecord = true;
            isValid = this.isValid(fields[EMAIL_FIELD.fieldApiName],'Indirizzo Email');
        }else if (keysList[0].localeCompare(SMS_FIELD.fieldApiName) === 0){
            fields[EMAIL_FIELD.fieldApiName] = '';
            updateRecord = true;
            isValid = this.isValid(fields[SMS_FIELD.fieldApiName],'Numero Cellulare');
        }
                            
        if(isValid){                                            
            if (updateRecord){
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[STATUS_FIELD.fieldApiName] = 'Invio app.to SELF cliente';
                fields[SELF_FIELD.fieldApiName] = true;
                const recordInput = { fields };
                let formRecordEdit = this.template.querySelector('lightning-record-edit-form');
                getEncryptedId({
                    activityId : this.recordId
                }).then((data) => {
                    fields[CRIPTO_FIELD.fieldApiName] = data;
                    this.communityBasePath+="?c__activityId="+data;
                    console.log("Krist  "+ data);
                    fields[URL_FIELD.fieldApiName] = this.communityBasePath;
                    formRecordEdit.submit(fields);
                    this.closeModal(updateRecord);
                }).catch((error) => {
                    console.error(error);
                });
            }else{
                this.closeModal(updateRecord);
            }
        }
        
    }

    handleCancel(event){
        this.closeModal(false);
    }

    handleChange(event){
        const selectedOption = event.detail.value;
        if (selectedOption && selectedOption.localeCompare('sms') === 0){
            this.nameField = SMS_FIELD;
            this.value = 'sms';
        }else if (selectedOption && selectedOption.localeCompare('email') === 0){
            this.nameField = EMAIL_FIELD;
            this.value = 'email';
        }
        this.showForm = true;
    }

    handleClose(event){
        this.closeModal(false);
    }

    closeModal(refreshRecord){
        this.showSpinner = true;
        if(!refreshRecord){
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : refreshRecord}));
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Operazione Riuscita',
                    message: 'Verrà inviato il link all\'utente per poter richiedere l\'appuntamento',
                    variant: 'success'
                })
            );
            setTimeout(function(){window.location.reload()},3000);
        }
        
    }

    isValid(fieldValue,fieldName){
        let isValid = false;
        switch (fieldName){
            case 'Numero Cellulare':
                isValid = this.checkMobile(fieldValue);
            break;
            case 'Indirizzo Email':
                isValid = this.checkEmail(fieldValue);
            break;
        }
        if (!isValid){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: fieldName+ ' non valido.',
                    variant: 'error'
                })
            ); 
        }
        return isValid;
    }

    checkEmail(email){
        return String(email)
        .toLowerCase()
        .match(
            /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
        );
    }

    checkMobile(mobile){
        return mobile.match(/^(([+]|[0]{2})\d{1,3}[ ]?)?\d{10,12}$/);
    }
}