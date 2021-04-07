import { LightningElement, track,wire,api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getOptions';
import validateRecord from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.validateRecord';
import getContentDocs from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getContentDocs';
import { updateRecord } from 'lightning/uiRecordApi';
import getOptions from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getOptions';
import prePopulateFields from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.prePopulateFields';
import getFieldToPrePopulate from '@salesforce/apex/HDT_LC_RecordEditFormFlowController.getFieldToPrePopulate';


export default class HdtRecordEditFormInformativeFlow extends LightningElement {

    @api processType;
    @api objectName;
    @api recordId;
    @api context;
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
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

    @track loadingSpinner;
    @track errorMessage;
    @track error;
    @track fieldsJSON;
    @track fieldsJSONReadOnly;
    @track wiredResponse;
    @track firstColumn = [];
    @track secondColumn = [];
    @track firstColumnReadOnly = [];
    @track secondColumnReadOnly = [];
    @track serviceClass="HDT_SRV_InformativeManager";
    @track contentDocument;
    @track formats=[];
    @track showInputSection = false;
    @track show = false;
    @track cluster;
    @track disabledCluster = false;
    @track selectedCluster;
    @track process;
    @track selectedProcess;
    @track disabledProcess = false;;
    @track showProcess=false;
    @track showTopic = false;
    @track topic;
    @track selectedTopic;
    @track disabledTopic = false;
    @track showDettaglioInfo;
    @track dettaglioInfo;
    @track selectedDettaglioInfo;
    @track disabledDettaglioInfo = false;
    @track showTitolo = false;
    @track requiredTitolo = false;
    @track disabledTitolo = false;
    @track showServizio = false;
    @track selectedCommodity;
    @track commodity;
    @track disabledCommodity = false;
    @track selectedCluster;
    @track hiddenFields=false;
    @track validateClass;
    @track wiredResponse;

    connectedCallback(){
        this.loadingSpinner = true;

        if(this.serviceClass){
            var params = {
                method:'cluster',
                context: this.context
            }
            getOptions({

                serviceClass: this.serviceClass,
                params: JSON.stringify(params)
            })
                .then(result => {
                    this.cluster = result;
                    this.showInputSection = true;
                    prePopulateFields({recordId: this.recordId, context: this.context})
                    .then(result => {

                        console.log('#PrePopulateResult -> '+result);

                        getFieldToPrePopulate({recordId: this.recordId})
                        .then(result => {

                            var payload = result;
                        
                            console.log('#Payload -> '+JSON.stringify(payload));

                            if(payload.InformativeCluster__c != null 
                                && payload.InformativeCluster__c != undefined 
                                && payload.InformativeCluster__c != ''){
                                
                                var cluster = result.InformativeCluster__c;
                                this.selectedCluster = cluster;

                                console.log('#Cluster -> '+cluster);

                                params = {
                                    method:'process',
                                    cluster: cluster
                                }

                                console.log('#ParamsProcess -> '+JSON.stringify(params));

                                getOptions({
                                    serviceClass: this.serviceClass,
                                    params: JSON.stringify(params)
                                }).then(result => {
                                    this.disabledCluster = true;
                                    this.process = result;
                                    this.showProcess = true;
                                    if(payload.InformativeType__c != null 
                                        && payload.InformativeType__c != undefined 
                                        && payload.InformativeType__c != ''){

                                        var process = payload.InformativeType__c ;
                                        console.log('#Type -> '+process);
                                        this.selectedProcess = process;
                                        this.disabledProcess = true;
                                        this.showServizio = true;
                                        if(this.selectedCluster.localeCompare('VAS') === 0){
                                            var resultVAS = [
                                                {
                                                    label:'VAS',
                                                    value:'VAS'
                                                }
                                            ];
                                            this.commodity = JSON.stringify(resultVAS);
                                        }else{
                                            var result = [
                                                {
                                                    label:'Energia Elettrica',
                                                    value:'Energia Elettrica'
                                                },
                                                {
                                                    label:'Gas',
                                                    value:'Gas'
                                                }
                                            ];
                                            this.commodity = JSON.stringify(result);
                                        }
                                        if(payload.CommodityFormula__c != null 
                                            && payload.CommodityFormula__c != undefined 
                                            && payload.CommodityFormula__c != ''){

                                            var commodity = payload.CommodityFormula__c;    
                                            this.selectedCommodity = commodity;
                                            console.log('#Commodity -> '+commodity);
                                            params = {
                                                method:'topic',
                                                cluster: cluster,
                                                context: this.context
                                            }
                                            //Topic ThenCatch
                                            getOptions({
                                                serviceClass: this.serviceClass,
                                                params: JSON.stringify(params)
                                            }).then(result => {
                                                console.log('topic ' + result);
                                                this.disabledCommodity = true;
                                                this.topic = result;
                                                this.showTopic = true;
                                                this.showTitolo = false;
                                            })
                                            .catch(error => {
                                                console.log('#GetTopic error -> '+error);
                                                this.error = true;
                                                this.loadingSpinner = false;
                                            });
                                            //Topic ThenCatch    
                                        }

                                    }
                                
                                this.loadingSpinner = false;

                                }).catch(error =>{
                                    console.log('#GetProcess error -> '+error);
                                    this.error = true;
                                    this.loadingSpinner = false;
                                });
                            
                            }

                            this.loadingSpinner = false;

                        }).catch(error => {
                            console.log('#GetPopulatedField error -> '+error);
                            this.error = true;
                            this.loadingSpinner = false;
                        });

                    }).catch(error => {
                        console.log('#Errore prePopulate -> '+error);
                        this.error = true;
                        this.loadingSpinner = false;
                    })

                })
                .catch(error => {
                    console.log('#GetCluster error -> '+JSON.stringify(error));
                    this.error = true;
                    this.loadingSpinner = false;
                });

                
        }
    }


    getProcess(event){
        var cluster = event.detail;
        this.selectedCluster = cluster;
        var params = {
            method:'process',
            cluster:cluster
        }
        getOptions({
            serviceClass: this.serviceClass,
            params: JSON.stringify(params)
        })
            .then(result => {
                console.log('process ' + result);
                this.showProcess = true;
                this.process = result;
                this.selectedProcess = null;
                this.selectedTopic = null;
                this.topic = null;
                this.commodity = null;
                this.selectedCommodity = null;
                this.dettaglioInfo = null;
                this.selectedDettaglioInfo = null;
                this.showTitolo = false;
            })
            .catch(error => {
                this.error = true;
            });
    }
    getTopic(event){
        var commodity = event.detail;
        var params = {
            method:'topic',
            cluster:this.selectedCluster,
            context:this.context
        }
        getOptions({
            serviceClass: this.serviceClass,
            params: JSON.stringify(params)
        })
            .then(result => {
                console.log('topic ' + result);
                this.selectedCommodity = commodity;
                this.topic = result;
                this.showTopic = true;
                this.showTitolo = false;
            })
            .catch(error => {
                this.error = true;
            });
    }
    getInfo(event){
        var topic = event.detail;
        var params = {
            method:'info',
            cluster:this.selectedCluster,
            topic:topic,
            context:this.context
        }
        getOptions({
            serviceClass: this.serviceClass,
            params: JSON.stringify(params)
        })
            .then(result => {
                console.log('info ' + result);
                this.selectedTopic = topic;
                this.dettaglioInfo = result;
                this.showDettaglioInfo = true;
                this.showTitolo = false;
            })
            .catch(error => {
                this.error = true;
            });
    }
    checkSubject(event){
        var info = event.detail;
        console.log('in check ' + info);
        this.selectedDettaglioInfo = info;
        if(info.localeCompare('Info non censita') === 0){
            this.showTitolo = true;
            this.requiredTitolo = true;
            console.log('equals ' + info.localeCompare('Info non censita'))
        }else{
            this.showTitolo = false;
            console.log('no equals ' + info.localeCompare('Info non censita'))
        }
            
    }
    getServizio(event){
        var process = event.detail;
        this.selectedProcess = process;
        this.showServizio = true;
        if(this.selectedCluster.localeCompare('VAS') === 0){
            var resultVAS = [
                {
                    label:'VAS',
                    value:'VAS'
                }
            ];
            this.commodity = JSON.stringify(resultVAS);
        }else{
            var result = [
                {
                    label:'Energia Elettrica',
                    value:'Energia Elettrica'
                },
                {
                    label:'Gas',
                    value:'Gas'
                }
            ];
            this.commodity = JSON.stringify(result);
            this.selectedCommodity = null;
            this.dettaglioInfo = null;
            this.selectedDettaglioInfo = null;
            this.topic = null;
            this.selectedTopic = null;
            this.showTitolo = false;
        }
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

    handleError(event){

        let obj = event.detail.output.fieldErrors;

        let message = obj[Object.keys(obj)[0]][0].message;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Errore',
                message: message,
                variant: 'error',
            }),
        );
    }

    handleDraft(event){
        console.log('draft handle');
        const fields = event.detail.fields;
        fields.InformativeCluster__c = this.selectedCluster;
        fields.InformativeType__c = this.selectedProcess;
        fields.Commodity__c = this.selectedCommodity;
        fields.MacroTopic__c = this.selectedTopic;
        fields.InformationDetail__c = this.selectedDettaglioInfo;
        this.saveInDraft = true;
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    showMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            }),
        );
    }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        this.saveInDraft = false;
        const fields = event.detail.fields;
        if(this.selectedCluster == null || this.selectedProcess == null || this.selectedCommodity == null || this.selectedTopic == null || this.selectedDettaglioInfo == null || (this.showTitolo && fields.Subject == null)){
            console.log('valorizza obbligatori');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message:'Attenzione! Valorizzare tutti i campi obbligatori.',
                    variant: 'error',
                }),
            );
        }else{
            const fields = event.detail.fields;
            fields.InformativeCluster__c = this.selectedCluster;
            fields.InformativeType__c = this.selectedProcess;
            fields.Commodity__c = this.selectedCommodity;
            fields.MacroTopic__c = this.selectedTopic;
            fields.InformationDetail__c = this.selectedDettaglioInfo;
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
                console.log('submit');
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
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