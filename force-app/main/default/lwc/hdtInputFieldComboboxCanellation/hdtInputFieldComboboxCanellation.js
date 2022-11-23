import { LightningElement, track,wire,api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import getListOptions from '@salesforce/apex/HDT_UTL_CaseCancellation.getListCanellationReasonLwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";

const FIELDS = ['Case.CancellationReason__c'];
export default class HdtInputFieldComboboxCanellation extends LightningElement {
    @api defaultValue;
    @api variant;
    @api selectedReason;
    @track options;
    @api recordType;
    @api commodity;
    @api processType;
    @api processTypeToCancell;
    @api recordId;
    @track defaultValue2;

    @api interviewId;
    @api required; // ???

    @wire(MessageContext)
	messageContext;

    subscribeMC() {
		// recordId is populated on Record Pages, and this component
		// should not update when this component is on a record page.
        this.subscription = subscribe(
            this.messageContext,
            BUTTONMC,
            (mc) => {if(this.interviewId==mc.sessionid) this.eventButton = mc.message},
            //{ scope: APPLICATION_SCOPE }
        );
		// Subscribe to the message channel
	}

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
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
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            console.log('data ' + JSON.stringify(data));
            this.defaultValue2 = data.fields.ProcessCancellationReason__c.value;
        }
    }*/
    
    connectedCallback(){
        this.subscribeMC(); //Aggiunta Metodo Subscribe
        this.selectedReason = this.defaultValue;
        console.log('this.selectedReason ' + this.selectedReason);
        console.log('this.defaultValue ' + this.defaultValue);
        var RequestCancellationReason = [{
                RequestCancellationReason: { 
                    recordType: this.recordType,
                    commodity: ( this.commodity != null ? this.commodity : "" ),
                    processType: this.processType,
                    processTypeToCancell: this.processTypeToCancell
                }
            },
        ];
        console.log('obj' + JSON.stringify(RequestCancellationReason[0]));
        getListOptions({
            input: JSON.stringify(RequestCancellationReason[0].RequestCancellationReason)
            })
            .then(result => {
                var wrapper = JSON.parse(result);
                if(Object.keys(result).length > 0 ){
                    console.log('Esito ' + wrapper.outcomeDescription);
                    this.options = JSON.parse(wrapper.listReasonDescription);
                }else
                    console.log('Nessuna risposta');
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleChange(event){
        this.selectedReason = event.detail.value;
        this.defaultValue = event.detail.value;
    }

    // // -> VECCHIO VALIDATE <-
    //
    // @api
    // validate() {
    // if(this.selectedReason != null && this.selectedReason != 'undefined') { 
    //      return { isValid: true }; 
    //     } 
    // else { 
    // //If the component is invalid, return the isValid parameter as false and return an error message. 
    //      return { 
    //            isValid: false, 
    //            errorMessage: 'Inserisci un valore.' 
    //             }; 
    //  } 
    // }

    @api validate (){
        console.log("event catched   "+this.eventButton);
        if('cancel' != this.eventButton && 'draft' != this.eventButton){ // 'save' == this.eventButton
            if(this.selectedReason != null && this.selectedReason != 'undefined') { 
                return { isValid : true };
            } 
            else { 
            //If the component is invalid, return the isValid parameter as false and return an error message. 
                return { isValid: false, errorMessage: 'Inserisci un valore.' }; 
            } 
        } 
        else{ 
            return { isValid : true, errorMessage: null };
        }
    }
}