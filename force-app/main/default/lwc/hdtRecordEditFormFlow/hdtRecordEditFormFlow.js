import { LightningElement, track,wire,api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getFields';
import validateRecord from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.validateRecord';
import getContentDocs from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getContentDocs';
import { updateRecord } from 'lightning/uiRecordApi';

export default class HdtRecordEditFormFlow extends LightningElement {

    @api processType;
    @api objectName;
    @api recordId;
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api addContentDocument;
    @api contentDocumentLabel;
    @api acceptedFormats;
    @api nextStep;
    @api showReadOnly;
    @api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api availableActions = [];
    @api variantSaveButton;

    @track errorMessage;
    @track error;
    @track fieldsJSON;
    @track fieldsJSONReadOnly;
    @track wiredResponse;
    @track firstColumn = [];
    @track secondColumn = [];
    @track firstColumnReadOnly = [];
    @track secondColumnReadOnly = [];
    @track validateClass="";
    @track contentDocument;
    @track formats=[];
    @track showInputSection = false;
    //@track showNotificationMessage = false;
    //@track notificationDescription = '';
    //@track notificationType = '';
    //@track delay = 3000;
    @track show = false;

    @wire(getFields, { processType: '$processType' }) 
        wiredFieldsJSON ({ error, data }) {
            if (data) {
                console.log(JSON.stringify(data));
                this.wiredResponse = JSON.parse(data);
                this.validateClass = this.wiredResponse[0].ValidateClass__c;
                if(this.wiredResponse[0].hasOwnProperty("FieldsJSON__c")){
                    this.fieldsJSON = JSON.parse(this.wiredResponse[0].FieldsJSON__c);
                    this.fieldsJSON.forEach(obj => {
                        if(obj.Column == 1){
                            this.firstColumn.push(obj);
                        }else{
                            this.secondColumn.push(obj);
                        }
                    });
                    this.showInputSection = true;
                }
                if(this.showReadOnly){
                    this.fieldsJSONReadOnly = JSON.parse(this.wiredResponse[0].ReadOnlyFields__c);
                    this.fieldsJSONReadOnly.forEach(obj => {
                        if(obj.Column == 1){
                            this.firstColumnReadOnly.push(obj);
                        }else{
                            this.secondColumnReadOnly.push(obj);
                        }
                    });
                }
            } else if (error) {
                this.error = true;
                this.errorMessage = error;
                this.errorMessage = error.message;
            }
        }

        updateRecordView(recordId) {
            updateRecord({fields: { Id: recordId }});
        }

        @api
        get variantButton() {
            if(this.variantSaveButton != null && this.variantSaveButton != "" && this.variantSaveButton != "undefined" )
            return this.variantSaveButton;
        else
            return "brand";
        }
        /*
        @wire(getContentDocs, {arecordId : '$recordId'}) 
            wiredContentDocument({ error, data }) {
                console.log('finitoo ' + JSON.stringify(error));
                if (data) {
                    this.contentDocument = data;
                } else if (error) {
                    this.error = true;
                    this.errorMessage = error;
                }
            }
        */
    selectContentDocument(){
        getContentDocs({
            arecordId: this.recordId
            })
            .then(result => {
                console.log(JSON.stringify(result));
                if(Object.keys(result).length > 0 )
                    this.contentDocument = result;
                else
                this.contentDocument = null;
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    connectedCallback(){
        if(this.addContentDocument){
            this.selectContentDocument();
        }
        console.log(this.acceptedFormats);
        if(this.acceptedFormats){
            console.log(this.acceptedFormats);
            this.formats = this.acceptedFormats.split(";");
            console.log(JSON.stringify(this.formats));
        }
        updateRecord({fields: { Id: this.recordId }});
        
    }
    /*get formats(){
        var formats = [];
        console.log(this.acceptedFormats);
        if(this.acceptedFormats){
            console.log(this.acceptedFormats);
            formats = this.acceptedFormats.split(";");
            console.log(JSON.stringify(formats));
        }
        return formats;
    }*/
    handleUploadFinished(){
        this.selectContentDocument();
    }
    handleActionFinished(){
        this.selectContentDocument();
    }
    getRecordType(){
        if(this.recordType)
            return this.recordType;
        else
            return null;
    }
    handleSuccess(event) {
        if(this.availableActions.find(action => action === 'FINISH')){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: event.detail.apiName + ' aggiornato.',
                    variant: 'success',
                }),
            );
        }
        this.handleGoNext();
    }

    handleDraft(event){
        console.log('draft handle');
        if(event.target.name === 'draft'){

            this.saveInDraft = true;

        } else if(event.target.name === 'cancel'){

            this.cancelCase = true;

        }

        this.template.querySelector('lightning-record-edit-form').submit();
    }

    showMessage(title,message,variant){

        /*this.notificationDescription = title + ': ' + message;

        this.notificationType = variant;

        this.showNotificationMessage = true;

        setTimeout(() => {

            this.showNotificationMessage = false;
        
        }, this.delay);*/

        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
        /*console.log('errore ' + message);
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant 
        });
        this.dispatchEvent(event);*/
    }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        this.saveInDraft = false;
        this.cancelCase = false;
        const fields = event.detail.fields;
        console.log('fields ' + JSON.stringify(fields));
        if(this.validateClass){
            validateRecord({
                validateClass: this.validateClass,
                fields: JSON.stringify(fields),
                recordId: this.recordId
            })
                .then(result => {
                    var resultWrapper = JSON.parse(result);
                    if(resultWrapper.outcomeCode === "OK"){ 
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                    }else{
                        console.log('ErrorMessage: ' +resultWrapper.outcomeDescription);
                        this.showMessage('Errore',resultWrapper.outcomeDescription,'error');  
                    }
                })
                .catch(error => {
                    this.error = true;
                });
        }else{
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } 
    }

    handleAttributeChange() {
        // notify the flow of the new value 
        const attributeChangeEvent = new FlowAttributeChangeEvent('varName', 'value');
        this.dispatchEvent(attributeChangeEvent);
    }

    handleGoNext() {
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }
    
    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
}