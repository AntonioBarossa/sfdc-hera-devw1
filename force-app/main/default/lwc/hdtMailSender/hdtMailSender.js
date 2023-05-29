import { LightningElement, wire, api, track} from "lwc";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getMetadata from '@salesforce/apex/HDT_LC_MailSender.getMetadata';
import getBodyMailMerged from '@salesforce/apex/HDT_LC_MailSender.getBodyMailMerged';
import sendMailToApex from '@salesforce/apex/HDT_LC_MailSender.sendMail';
import getContentDocs from '@salesforce/apex/HDT_LC_MailSender.getContentDocs';
import deletePendingFiles from '@salesforce/apex/HDT_LC_MailSender.deletePendingFiles';
import getContentSizeAttachments from '@salesforce/apex/HDT_LC_MailSender.getContentSizeAttachments';
export default class HdtMailSender extends NavigationMixin(LightningElement) {
    
    @api recordIdFromAura;
    cardTitle;
    buttonLabel;
    reminderMode = false;
    mailSender;
    mailReceiver;
    bodyMail = '';
    options = [];
    recordId;
    render = false;
    spinner = true;
    mailStructure = {
        recordId: '',
        isReminder: false,
        orgWideAddId: '',
        bodyMail: '',
        toAddress: '',
        templateName: '',
        attachmentsIdList: []
    };
    newCaseId;
    reminderMailCounter;
    templateName;

    //Variabili per gestione allegati
    @api documentRecordId;
    @track contentDocument;
    @track formats=[];
    @api acceptedFormats;
    documentRecordIdList = [];
    attachmentsSize = 0;
    isSendDisabled = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log('>>> CASE ID: ' + this.recordId);
    }

    connectedCallback(){
        this.selectContentDocument();

        console.log('### Accepted Format ' + this.acceptedFormats);
        if(this.acceptedFormats){
            console.log(this.acceptedFormats);
            this.formats = this.acceptedFormats.split(";");
            console.log(JSON.stringify(this.formats));
        }

        console.log('>>> recordIdFromAura: ' + this.recordIdFromAura);
        console.log('>>> recordId from LWC: ' + this.recordId);

        if(this.recordId===undefined || this.recordId===''){
            this.recordId = this.recordIdFromAura;
        }

        this.getMetadata();
    }

    getMetadata(){
        getMetadata({recordId: this.recordId})
        .then(result => {
            console.log('# getMetadata #');
            console.log('>>> ' + JSON.stringify(result));
            if(result.success){
                console.log('# SUCCESS #');

                this.mailSender = result.mailData.sender;
                this.mailStructure.recordId = this.recordId;
                this.mailStructure.orgWideAddId = result.mailData.orgWideEmailAddressId;
                this.reminderMode = result.isReminder;
                this.mailStructure.isReminder = result.isReminder;

                if(this.reminderMode){
                    this.cardTitle = 'Comunicazione con il Gestore - Sollecito (' + result.mailData.reminderMailCounter + ')';
                    this.bodyMail = result.mailData.reminderBodyMail;
                    this.mailReceiver = result.mailData.receiver;
                    this.reminderMailCounter = result.mailData.reminderMailCounter;
                } else {
                    this.cardTitle = 'Comunicazione con il Gestore';
                    result.templateList.forEach(li => {
                        this.options.push({label: li.label, value: li.value});
                    });
                }

                this.render = true;
                this.spinner = false;
            } else {
                console.log('# FAIL #');
                this.closeAction();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE',
                        message: result.message,
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
            }

        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ATTENZIONE',
                    message: JSON.stringify(error),
                    variant: 'warning',
                    mode: 'sticky'
                })
            );
        });
    }

    handleTemplateChange(event) {
        this.spinner = true;

        console.log('# getBodyMailMerged #');
        console.log('# event.detail.value: ' + event.detail.value);
        this.templateName = event.target.options.find(opt => opt.value === event.detail.value).label;
        console.log('# templateName #: ' + this.templateName);
        getBodyMailMerged({templateName: this.templateName, templateId: event.detail.value, recordId: this.recordId})
        .then(result => {
            console.log('# getBodyMailMerged #');
            console.log('>>> ' + JSON.stringify(result));

            if(result.success){
                console.log('# SUCCESS #');
                this.bodyMail = result.bodyMail;
                this.mailReceiver = result.receiver;
                this.checkBodyMail();
                this.spinner = false;
            } else {
                console.log('# FAIL #');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE',
                        message: result.message,
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
                
            }

        })
        .catch(error => {
            console.log('# ERROR # ' + error);
        });

        
    }

    handleMailChange(event){
        this.mailReceiver = event.target.value;
    }

    handleChange(event) {
        this.bodyMail = event.target.value;
        this.checkBodyMail();
    }

    checkBodyMail(){
        var disableButton = false;
        if(this.bodyMail === undefined || this.bodyMail === ''){
            disableButton = true;
        } else {
            disableButton = false;
        }
        
        this.isSendDisabled = disableButton;
    }

    sendMail(event){
        //prima di inviare la mail di comunicazione gestore e creare il case, controllo se la dimensione totale degli eventuali allegati rimane al di sotto dei 10 MB
        getContentSizeAttachments({cdIdList: this.documentRecordIdList})
        .then(result => {
            this.attachmentsSize = JSON.stringify(result);
            console.log('attachmentsSize: ' + this.attachmentsSize);

            if(this.bodyMail === undefined || this.bodyMail === ''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE',
                        message: 'Il messaggio non contiene nulla',
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
            } else if (this.attachmentsSize > 10){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE',
                        message: 'La dimensione totale degli allegati supera i 10 MB.',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            }else {
                this.spinner = true;
                this.sendMailToApex();
            }
        })
        .catch(error => {
            console.log('# ERROR # ' + error);
        });
    }

    sendReminderMail(event){

        if(this.reminderMailCounter>=3){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ATTENZIONE',
                    message: 'Sono già stati inviati 3 solleciti.',
                    variant: 'warning',
                    mode: 'sticky'
                })
            );
        } else {
            this.spinner = true;
            this.sendMailToApex();
        }

    }

    textChange(event){
        this.bodyMail = event.target.value;
        this.checkBodyMail();
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    sendMailToApex(){

        this.mailStructure.bodyMail = this.bodyMail;
        this.mailStructure.toAddress = this.mailReceiver;
        this.mailStructure.templateName = this.templateName;
        console.log('this.documentRecordIdList: ' + JSON.stringify(this.documentRecordIdList));
        this.mailStructure.attachmentsIdList = this.documentRecordIdList;
        console.log('>>> send this: ' + JSON.stringify(this.mailStructure));

        sendMailToApex({mailStructure: JSON.stringify(this.mailStructure)})
        .then(result => {
            console.log('# getBodyMailMerged #');
            console.log('>>> ' + JSON.stringify(result));

            if(result.success){
                console.log('# SUCCESS #');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'SUCCESSO',
                        message: result.message,
                        variant: 'success',
                        mode: 'sticky'
                    })
                );
                this.newCaseId = result.caseId;
                this.spinner = false;
                this.goToNewRecord();
                this.closeAction();
                eval("$A.get('e.force:refreshView').fire();");
            } else {
                console.log('# FAIL #');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE',
                        message: result.message,
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
                this.spinner = false;
            }

        })
        .catch(error => {
            console.log('# ERROR # ' + error);
        });
    }

    goToNewRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newCaseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    selectContentDocument(){

        if(this.documentRecordId == null || this.documentRecordId == undefined || this.documentRecordId == ''){
            this.documentRecordId = this.recordId;
        }
        

        getContentDocs({
            arecordId: this.documentRecordId
            })
            .then(result => {
                console.log('getContentDocs: ' + JSON.stringify(result));
                if(Object.keys(result).length > 0 ){
                    this.contentDocument = result;
                    result.forEach(element => {
                        let elem = JSON.stringify(element);
                        this.documentRecordIdList.push(JSON.parse(elem).Id);
                    });
                }else{
                    this.contentDocument = null;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleUploadFinished(){
        this.selectContentDocument();
    }
    handleActionFinished(){
        this.selectContentDocument();
    }

    handleCancel(){
        deletePendingFiles({cdIdList: this.documentRecordIdList})
        .then(result => {
            console.log('# deletingPendingFiles #');
            this.closeAction();
        })
        .catch(error => {
            console.log('# ERROR # ' + error);
        });
    }

}