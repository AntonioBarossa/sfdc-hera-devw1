import { LightningElement, wire} from "lwc";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getMetadata from '@salesforce/apex/HDT_LC_MailSender.getMetadata';
import getBodyMailMerged from '@salesforce/apex/HDT_LC_MailSender.getBodyMailMerged';
import sendMailToApex from '@salesforce/apex/HDT_LC_MailSender.sendMail';

export default class HdtMailSender extends NavigationMixin(LightningElement) {
    
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
        caseId: '',
        isReminder: false,
        orgWideAddId: '',
        bodyMail: '',
        toAddress: ''
    };
    newCaseId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
        console.log('>>> CASE ID: ' + this.recordId);
    }

    connectedCallback(){
        console.log('>>> CASE ID: ' + this.recordId);
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
                this.mailStructure.caseId = this.recordId;
                this.mailStructure.orgWideAddId = result.mailData.orgWideEmailAddressId;
                this.reminderMode = result.isReminder;
                this.mailStructure.isReminder = result.isReminder;

                if(this.reminderMode){
                    this.cardTitle = 'Comunicazione con il Gestore - Sollecito';
                    this.bodyMail = result.mailData.reminderBodyMail;
                    this.mailReceiver = result.mailData.receiver;
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

        getBodyMailMerged({templateId: event.detail.value, recordId: this.recordId})
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
        this.template.querySelectorAll('lightning-button').forEach((button) => {
            button.disabled = disableButton; 
        });
    }

    sendMail(event){

        if(this.bodyMail === undefined || this.bodyMail === ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ATTENZIONE',
                    message: 'Il messaggio non contiene nulla',
                    variant: 'warning',
                    mode: 'sticky'
                })
            );
        } else {
            this.spinner = true;
            this.sendMailToApex();
        }
        
    }

    sendReminderMail(event){
        this.sendMailToApex();
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

}